unit handlerequests;

interface

uses
  SysUtils, Classes, HTTPApp, SQLiteTable3;

type
  TRokuWeb = class(TObject)
  private
    { Private declarations }
    Fdatabase: TSQLiteDatabase;
    FLocalIP: string;
    function GetFileList(dir, ext: string): TStringList;
  public
    { Public declarations }
    constructor Create(ANPVRDB: string);
    destructor Destroy; override;
    procedure SearchPartial(Request: TStringList; Response: TStringList);
    procedure SearchName(Request: TStringList; Response: TStringList);
    procedure DeleteEpisode(Request: TStringList; Response: TStringList);
    procedure GetEpisodeList(Request: TStringList; Response: TStringList);
    procedure GetEpisodeDetails(Response: TStringList; Request: TStringList);
    procedure GetShowList(Response: TStringList);
    procedure ScheduleSoap(Request: TStringList; Response: TStringList; ACredFile: string; AListenPort: integer);
    function GetMime(ext: string): string;
    property LocalIP: string read FLocalIP write FLocalIP;
  end;

function CreateXMLResponse(ATemplate, AXML: string): string;

implementation

uses
  Main,
  ActiveX,
  IdStack,
  XMLDoc,
  XMLIntf,
  IdGlobal,
  IdURI,
  StrUtils,
  InvokeRegistry,
  ScheduleService1,
  Rio,
  SOAPHTTPClient,
  Windows;

function GMTToLocalTime(GMTTime: TDateTime): TDateTime;
var
  GMTST: Windows.TSystemTime;
  LocalST: Windows.TSystemTime;
begin
  SysUtils.DateTimeToSystemTime(GMTTime, GMTST);
  SysUtils.Win32Check(Windows.SystemTimeToTzSpecificLocalTime(nil, GMTST, LocalST));
  Result := SysUtils.SystemTimeToDateTime(LocalST);
end;

function GMTStringToLocalString(gmts: string): string;
var
  gmt, lt: TDateTime;
  lgmts: string;
  formatSettings: TFormatSettings;
begin
  try
    // get just the 'yyyy-mm-dd hh:nn' part of the sqlite datetime and replace T with a space
    lgmts := copy(StringReplace(gmts, 'T', ' ', [rfReplaceAll]), 1, 16);
    // Furnish the locale format settings record
    GetLocaleFormatSettings(LOCALE_SYSTEM_DEFAULT, formatSettings);
    formatSettings.ShortDateFormat := 'yyyy-mm-dd';
    formatSettings.DateSeparator := '-';
    formatSettings.ShortTimeFormat := 'hh:nn';
    gmt := StrToDateTime(lgmts, formatSettings);
    lt := GMTToLocalTime(gmt);
    Result := FormatDateTime('ddd, mmmm dd hh:nn', lt);
  except
    Result := gmts;
  end;
end;

function ExtractFileNameNoExt(const name: string): string;
begin
  Result := ExtractFileName(name);
  setLength(Result, length(Result) - length(ExtractFileExt(Result)));
end;

function RemoveExtension(const name: string): string;
begin
  Result := name;
  setLength(Result, length(Result) - length(ExtractFileExt(name)));
end;

function MyHTMLEncode(const AStr: string): string;
const
  Convert = ['&', '<', '>', '"'];
begin
  Result := StringReplace(AStr, '&', '&amp;', [rfReplaceAll]);
  Result := StringReplace(Result, '<', '&lt;', [rfReplaceAll]);
  Result := StringReplace(Result, '>', '&gt;', [rfReplaceAll]);
  Result := StringReplace(Result, '"', '&quot;', [rfReplaceAll]);
end;

function DirHasVideoFiles(const dir: string): boolean;
var
  sr: TSearchRec;
  FileAttrs: integer;
  sourcedir: string;
begin
  Result := false;
  FileAttrs := (faAnyFile and not faDirectory);
  sourcedir := IncludeTrailingPathDelimiter(dir);
  if (SysUtils.FindFirst(sourcedir + '*.mp4', FileAttrs, sr) = 0) or (SysUtils.FindFirst(sourcedir + '*.m4v', FileAttrs, sr) = 0) then
    Result := true;
end;

function CreateXMLResponse(ATemplate, AXML: string): string;
var
  xd: IXMLDocument;
  nl: IXMLNodeList;
  fieldname: string;
  fieldvalue: string;
  I: integer;
begin
  CoInitialize(nil);
  Result := ATemplate;
  try
    try
      xd := LoadXMLData(AXML);
      for I := 0 to xd.ChildNodes['Event'].ChildNodes.Count - 1 do
      begin
        fieldname := xd.ChildNodes['Event'].ChildNodes[I].NodeName;
        nl := xd.ChildNodes['Event'].ChildNodes[I].ChildNodes;
        if nl.Count > 0 then
        begin
          if AnsiSameText(fieldname, 'StartTime') then
          begin
            fieldvalue := GMTStringToLocalString(nl[0].Text);
          end
          else
            fieldvalue := nl[0].Text;
        end
        else
          fieldvalue := '';
        Result := StringReplace(Result, '{%' + fieldname + '%}', MyHTMLEncode(fieldvalue), [rfReplaceAll, rfIgnoreCase]);
      end;
    except
    end;
  finally
    CoUninitialize;
  end;
end;

function TRokuWeb.GetFileList(dir, ext: string): TStringList;
var
  sr: TSearchRec;
  FileAttrs: integer;
  sourcedir: string;
begin
  Result := TStringList.Create;
  FileAttrs := (faAnyFile and not faDirectory);
  sourcedir := IncludeTrailingPathDelimiter(dir);
  if SysUtils.FindFirst(sourcedir + ext, FileAttrs, sr) = 0 then
    try
      repeat
        if (sr.Attr and faDirectory) = 0 then
          Result.Add(sourcedir + sr.Name);
      until SysUtils.FindNext(sr) <> 0;
    finally
      SysUtils.FindClose(sr);
    end;
end;

function TRokuWeb.GetMime(ext: string): string;
begin
  // get the mimetype for an extension
  if AnsiSameText(ext, 'mp3') then
    Result := 'audio/mpeg'
  else if AnsiSameText(ext, 'm4v') or AnsiSameText(ext, 'mp4') or AnsiSameText(ext, 'mov') then
    Result := 'video/mp4'
  else if AnsiSameText(ext, 'wma') then
    Result := 'audio/x-ms-wma'
  else if AnsiSameText(ext, 'jpg') or AnsiSameText(ext, 'peg') then
    Result := 'image/jpeg'
  else if AnsiSameText(ext, 'png') then
    Result := 'image/png'
  else
    Result := '';
end;

constructor TRokuWeb.Create(ANPVRDB: string);
begin
  Fdatabase := TSQLiteDatabase.Create(ANPVRDB);
end;

destructor TRokuWeb.Destroy;
begin
  Fdatabase.Free;
  inherited;
end;

procedure TRokuWeb.GetShowList(Response: TStringList);
var
  sltb: TSQLiteTable;
  basename: string;
  aline: string;
  event_details: string;
const
  sql_get_show_list = 'select event_details, max(s.filename) as video_file from SCHEDULED_RECORDING s where s.status = 2 group by s.name order by s.name';
  template_get_show_list = '<show title="{%Title%}" basename="{%basename%}"/>';
begin
  Response.Text := '<shows>';
  try
    sltb := Fdatabase.GetTable(sql_get_show_list);
    try
      while not sltb.EOF do
      begin
        event_details := sltb.FieldAsString(sltb.FieldIndex['event_details']);
        aline := CreateXMLResponse(template_get_show_list, event_details);
        basename := ExtractFileDir(sltb.FieldAsString(sltb.FieldIndex['video_file']));
        aline := StringReplace(aline, '{%basename%}', HTTPEncode(basename), [rfReplaceAll, rfIgnoreCase]);
        if DirHasVideoFiles(basename) then
        begin
          Response.Text := Response.Text + aline;
        end;
        sltb.Next;
      end;
    finally
      sltb.Free;
    end;
  finally
    Response.Text := Response.Text + '</shows>';
  end;
end;

procedure TRokuWeb.GetEpisodeList(Request: TStringList; Response: TStringList);
var
  sltb: TSQLiteTable;
  detailsql: string;
  basename: string;
  url: string;
  event_details: string;
  aline: string;
const
  sql_get_episode_list = 'select event_details, s.filename as video_file from SCHEDULED_RECORDING s where s.status = 2 and s.filename like %s';
  template_get_episode_list =
    '<episode title="{%Title%}" subtitle="{%SubTitle%}" basename="{%basename%}" airdate="{%StartTime%}" hd_img="{%url%}_hd.png" sd_img="{%url%}_sd.png"/>';
begin
  Response.Text := '<episodes>';
  try
    basename := HTTPDecode(Request.Values['basename']);
    if Pos('.TS', UpperCase(basename)) > 0 then
      basename := ExtractFileDir(HTTPDecode(Request.Values['basename']));

    detailsql := Format(sql_get_episode_list, [QuotedStr('%%' + basename + '%%')]);
    sltb := Fdatabase.GetTable(detailsql);
    try
      while not sltb.EOF do
      begin
        event_details := sltb.FieldAsString(sltb.FieldIndex['event_details']);
        aline := CreateXMLResponse(template_get_episode_list, event_details);
        basename := sltb.FieldAsString(sltb.FieldIndex['video_file']);
        url := RemoveExtension(basename);
        if FileExists(url + '.mp4') then
        begin
          url := TIdURI.URLEncode(FLocalIP + url);
          aline := StringReplace(aline, '{%basename%}', HTTPEncode(basename), [rfReplaceAll, rfIgnoreCase]);
          aline := StringReplace(aline, '{%url%}', url, [rfReplaceAll, rfIgnoreCase]);
          Response.Text := Response.Text + aline;
        end;
        sltb.Next;
      end;
    finally
      sltb.Free;
    end;
  finally
    Response.Text := Response.Text + '</episodes>';
  end;
end;

procedure TRokuWeb.GetEpisodeDetails(Response: TStringList; Request: TStringList);
var
  sltb: TSQLiteTable;
  detailsql: string;
  event_details: string;
  aline: string;
  url: string;
  basename: string;
const
  sql_get_episode_details = 'select event_details, s.filename as video_file from SCHEDULED_RECORDING s where s.status = 2 and s.filename like %s';
  template_get_episode_details = '<episode title="{%Title%}" subtitle="{%SubTitle%}" basename="{%basename%}" airdate="{%StartTime%}" ' +
    'description="{%Description%}" stream_url="{%url%}.mp4" hd_img="{%url%}_hd.png" sd_img="{%url%}_sd.png" ' +
    'bif_sd_url="{%url%}_sd.bif" bif_hd_url="{%url%}_sd.bif" quality="HD"/>';
begin
  Response.Text := '<episodes>';
  basename := RemoveExtension(HTTPDecode(Request.Values['basename']));
  detailsql := Format(sql_get_episode_details, [QuotedStr('%%' + basename + '%%')]);
  sltb := Fdatabase.GetTable(detailsql);
  try
    if sltb.Count <> 0 then
    begin
      event_details := sltb.FieldAsString(sltb.FieldIndex['event_details']);
      aline := CreateXMLResponse(template_get_episode_details, event_details);
      basename := sltb.FieldAsString(sltb.FieldIndex['video_file']);
      url := TIdURI.URLEncode(FLocalIP + RemoveExtension(basename));
      aline := StringReplace(aline, '{%basename%}', HTTPEncode(basename), [rfReplaceAll, rfIgnoreCase]);
      aline := StringReplace(aline, '{%url%}', url, [rfReplaceAll, rfIgnoreCase]);
      Response.Text := Response.Text + aline;
    end;
  finally
    sltb.Free;
  end;
  Response.Text := Response.Text + '</episodes>';
end;

procedure TRokuWeb.SearchPartial(Request: TStringList; Response: TStringList);
var
  src: string;
  sltb: TSQLiteTable;
  detailsql: string;
  mname: string;
const
  sql_search = 'select p.title as show_title from EPG_EVENT p where p.end_time > datetime(''now'') and p.title like %s limit 10';
  template_search = '<show title="{%Title%}"/>';
begin
  Response.Text := '<shows>';
  try
    src := TrimLeft(Request.Values['q']);
    if AnsiSameText(src, '') then
      Exit;
    if length(src) < 3 then
      detailsql := Format(sql_search, [QuotedStr(src + '%')])
    else
      detailsql := Format(sql_search, [QuotedStr('%' + src + '%')]);
    sltb := Fdatabase.GetTable(detailsql);
    try
      while not sltb.EOF do
      begin
        mname := Trim(sltb.FieldAsString(sltb.FieldIndex['show_title']));
        Response.Text := Response.Text + StringReplace(template_search, '{%Title%}', mname, [rfReplaceAll, rfIgnoreCase]);
        sltb.Next;
      end;
    finally
      sltb.Free;
    end;
  finally
    Response.Text := Response.Text + '</shows>';
  end;
end;

procedure TRokuWeb.SearchName(Request: TStringList; Response: TStringList);
var
  src: string;
  sltb, schedtb: TSQLiteTable;
  detailsql: string;
  scheduled: string;
  aline: string;
  fieldvalue: string;
  I: integer;
const
  sql_searchname =
    'select p.title as Title, p.subtitle as SubTitle, p.start_time as StartTime, p.oid as show_oid from EPG_EVENT p where p.end_time > datetime(''now'') and p.title=%s limit 10';
  sql_check_scheduled = 'select name as Title from SCHEDULED_RECORDING where event_details like %s';
  template_searchname = '<episode title="{%Title%}" subtitle="{%SubTitle%}" airdate="{%StartTime%}" oid="{%show_oid%}" scheduled="{%scheduled%}"/>';
begin
  Response.Text := '<shows>';
  try
    src := TrimLeft(Request.Values['q']);
    if AnsiSameText(src, '') then
      Exit;
    detailsql := Format(sql_searchname, [QuotedStr(src)]);
    sltb := Fdatabase.GetTable(detailsql);
    try
      while not sltb.EOF do
      begin
        aline := template_searchname;
        for I := 0 to sltb.ColCount - 1 do
        begin
          if AnsiSameText(sltb.Columns[I], 'StartTime') then
            fieldvalue := GMTStringToLocalString(sltb.FieldAsString(I))
          else
            fieldvalue := sltb.FieldAsString(I);
          aline := StringReplace(aline, '{%' + sltb.Columns[I] + '%}', MyHTMLEncode(fieldvalue), [rfReplaceAll, rfIgnoreCase]);
        end;
        scheduled := 'no';
        detailsql := Format(sql_check_scheduled, [QuotedStr('%%<OID>' + sltb.FieldAsString(sltb.FieldIndex['show_oid']) + '</OID>%%')]);
        schedtb := Fdatabase.GetTable(detailsql);
        try
          while not schedtb.EOF do
          begin
            if sltb.FieldAsString(sltb.FieldIndex['Title']) = schedtb.FieldAsString(schedtb.FieldIndex['Title']) then
            begin
              scheduled := 'yes';
              Break;
            end;
          end;
        finally
          schedtb.Free;
        end;
        aline := StringReplace(aline, '{%scheduled%}', scheduled, [rfReplaceAll, rfIgnoreCase]);
        Response.Text := Response.Text + aline;
        sltb.Next;
      end;
    finally
      sltb.Free;
    end;
  finally
    Response.Text := Response.Text + '</shows>';
  end;
end;

procedure TRokuWeb.DeleteEpisode(Request: TStringList; Response: TStringList);
var
  I: integer;
  showname: string;
  showdir: string;
  fileList: TStringList;
const
  sql_delete_episode = 'delete from SCHEDULED_RECORDING where filename like %s';
begin
  showname := ExtractFileNameNoExt(HTTPDecode(Request.Values['basename']));
  showdir := ExtractFileDir(HTTPDecode(Request.Values['basename']));
  fileList := GetFileList(showdir, showname + '*.*');
  Fdatabase.ExecSQL(Format(sql_delete_episode, [QuotedStr('%%' + showname + '%%')]));
  try
    for I := 0 to fileList.Count - 1 do
    begin
      if FileExists(fileList[I]) then
        DeleteFile(PWideChar(fileList[I]));
    end;
    if DirectoryExists(ExtractFilePath(showdir)) then
      RemoveDir(ExtractFilePath(showdir));
  finally
    fileList.Free;
  end;
  GetEpisodeList(Request, Response);
end;

procedure TRokuWeb.ScheduleSoap(Request: TStringList; Response: TStringList; ACredFile: string; AListenPort: integer);
var
  Hdr: webServiceAuthentication;
  Headers: ISOAPHeaders;
  wwsss: webServiceScheduleSettings;
  webServiceRet: webServiceEPGEvent;
  lstresult: TStringList;
  rio: THTTPRIO;
  scheduled: string;
const
  template_schedule = '<schedule><program  OID="%s" Status="%s"/></schedule>';
begin
  scheduled := 'FAIL';
  CoInitialize(nil);
  rio := THTTPRIO.Create(nil);
  try
    if FileExists(ACredFile) then
    begin
      lstresult := TStringList.Create;
      try
        lstresult.LoadFromFile(ACredFile);
        Hdr := webServiceAuthentication.Create;
        Hdr.R := lstresult[0];
        Hdr.RL := lstresult[1];
        Hdr.RTL := lstresult[2];
      finally
        lstresult.Free;
        SysUtils.DeleteFile(ACredFile);
      end;

      rio.OnAfterExecute := RokuForm.HTTPRIO1AfterExecute;
      rio.OnBeforeExecute := RokuForm.HTTPRIO1BeforeExecute;
      rio.WSDLLocation := 'http://localhost:%d/public/services/ScheduleService.asmx?WSDL';
      rio.Service := 'ScheduleService';
      rio.Port := 'ScheduleServiceSoap12';

      Headers := rio as ISOAPHeaders;
      Headers.Send(Hdr);
      rio.SOAPHeaders.SetOwnsSentHeaders(True);
      wwsss := webServiceScheduleSettings.Create;
      try
        wwsss.epgeventOID := Request.Values['oid'];
        webServiceRet := GetScheduleServiceSoap(AListenPort, false, '', rio).scheduleRecording(wwsss);
        try
          if webServiceRet.webServiceEPGEventObjects.webServiceReturn.Error then
            scheduled := 'FAIL'
          else
            scheduled := 'OK';
        finally
          webServiceRet.Free;
        end;
      finally
        wwsss.Free;
      end;
    end;
  finally
    CoUninitialize;
  end;
  Response.Text := Format(template_schedule, [Request.Values['oid'], scheduled]);
end;

end.

