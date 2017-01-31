unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, IdBaseComponent, IdComponent, IdTCPServer, IdCustomHTTPServer,
  IdHTTPServer, ExtCtrls, StdCtrls, IdContext, IdCustomTCPServer, IdSync,
  handlerequests, Menus;

type
  TRokuForm = class(TForm)
    HTTPServer: TIdHTTPServer;
    LogMemo: TMemo;
    cbEnableLog: TCheckBox;
    TrayIcon1: TTrayIcon;
    PopupMenu1: TPopupMenu;
    Show1: TMenuItem;
    N1: TMenuItem;
    Exit1: TMenuItem;
    HideTimer: TTimer;
    cbLogSoap: TCheckBox;
    procedure HTTPServerCommandGet(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
    procedure FormCreate(Sender: TObject);
    procedure Show1Click(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure TrayIcon1DblClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure HideTimerTimer(Sender: TObject);
    procedure HTTPRIO1AfterExecute(const MethodName: string; SOAPResponse: TStream);
    procedure HTTPRIO1BeforeExecute(const MethodName: string; SOAPRequest: TStream);
  private
    canClose: boolean;
    LocalPath: string;
    LocalIP: string;
    LocalPort: integer;
    NPVR_db: string;
    SOAP_Login: string;
    SOAP_Password: string;
    SOAP_ListenPort: integer;
    function ReadSOAP(AFilename, ASection: string): string;
  protected
  public
  end;

var
  RokuForm: TRokuForm;

implementation

{$R *.dfm}

uses
  ActiveX,
  RangeFileStream,
//  RegularExpressions,
  IdStack,
  IdGlobal,
  HTTPApp,
  IniFiles,
  XMLDoc,
  XMLIntf,
  ShellAPI;

type
  TLogSync = class(TIdSync)
  protected
    FForm: TRokuForm;
    FText: string;
    procedure DoSynchronize; override;
  public
    constructor Create(AForm: TRokuForm; const AText: string);
    class procedure LogText(AForm: TRokuForm; const AText: string);
  end;

constructor TLogSync.Create(AForm: TRokuForm; const AText: string);
begin
  FForm := AForm;
  FText := AText;
  inherited Create;
end;

class procedure TLogSync.LogText(AForm: TRokuForm; const AText: string);
begin
  with Create(AForm, AText) do
    try
      Synchronize;
    finally
      Free;
    end;
end;

procedure TLogSync.DoSynchronize;
begin
  if FForm.cbEnableLog.Checked then
    FForm.LogMemo.Lines.Add(FText);
end;

type
  TSOAPSync = class(TIdSync)
  protected
    FForm: TRokuForm;
    FCredFile: string;
    FPath: string;
    FLogin: string;
    FPassword: string;
    procedure DoSynchronize; override;
  public
    constructor Create(AForm: TRokuForm; const ACredFile, APath, ALogin, APassword: string);
    class procedure SOAPCall(AForm: TRokuForm; const ACredFile, APath, ALogin, APassword: string);
  end;

constructor TSOAPSync.Create(AForm: TRokuForm; const ACredFile, APath, ALogin, APassword: string);
begin
  FForm := AForm;
  FCredFile := ACredFile;
  FPath := APath;
  FLogin := ALogin;
  FPassword := APassword;
  inherited Create;
end;

class procedure TSOAPSync.SOAPCall(AForm: TRokuForm; const ACredFile, APath, ALogin, APassword: string);
begin
  with Create(AForm, ACredFile, APath, ALogin, APassword) do
    try
      Synchronize;
    finally
      Free;
    end;
end;

procedure TSOAPSync.DoSynchronize;
var
  I: integer;
  Action: string;
  params: string;
  CredFile: string;
begin
  Action := FPath + 'pass.bat';
  CredFile := FPath + FCredFile;
  params := Format('"username=%s" "password=%s" "%s"', [FLogin, FPassword, CredFile]);
  if FileExists(CredFile) then
    DeleteFile(CredFile);
  ShellAPI.ShellExecute(FForm.Handle, PChar('open'), PChar(Action), PChar(params), nil, 0);
  Sleep(1000); // wait to make sure the file is created
end;

procedure TRokuForm.Show1Click(Sender: TObject);
begin
  Show;
end;

procedure TRokuForm.TrayIcon1DblClick(Sender: TObject);
begin
  Show;
end;

procedure TRokuForm.Exit1Click(Sender: TObject);
begin
  if MessageDlg('Are you sure you want to close this application?', mtWarning, [mbYes, mbNo], 0) = mrYes then
  begin
    canClose := True;
  end;
  Close;
end;

procedure TRokuForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if canClose then
    Action := caFree
  else
    Action := caNone;
  Hide;
end;

function TRokuForm.ReadSOAP(AFilename, ASection: string): string;
var
  xd: IXMLDocument;
  nl: IXMLNodeList;
begin
  result := '';
  CoInitialize(nil);
  try
    try
      xd := LoadXMLDocument(AFilename);
      nl := xd.ChildNodes['Settings'].ChildNodes['WebServer'].ChildNodes[ASection].ChildNodes;
      Result := nl[0].Text;
    except
    end;
  finally
    CoUninitialize;
  end;
end;

//function CheckIP(AIP: string): boolean;
//var
//  ipRegExp : String;
//begin
//  ipRegExp := '\b(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b';
//  if TRegEx.IsMatch(AIP, ipRegExp) then
//    result := true
//  else
//    result := false;
//end;

procedure TRokuForm.FormCreate(Sender: TObject);
var
  npvrdir: string;
  function GetLocalIP: string;
  begin
    TIdStack.IncUsage;
    try
      Result := GStack.LocalAddress;
    finally
      TIdStack.DecUsage;
    end;
  end;
begin
  canClose := false;
  LocalPath := ExtractFilePath(ParamStr(0));
  with TIniFile.Create(LocalPath + 'roku.ini') do
    try
      npvrdir := IncludeTrailingPathDelimiter(ReadString('locals', 'npvr_dir', ''));
      LocalIP := ReadString('locals', 'local_ip', '');
      LocalPort := ReadInteger('locals', 'server_port', 8000);
      SOAP_Password := ReadString('locals', 'password', '');
      if (LocalIP = '') or AnsiSameText(LocalIP, 'Auto') then
        LocalIP := GetLocalIP;
      LocalIP := Format('http://%s:%d/', [LocalIP, LocalPort]);
      NPVR_db := npvrdir + 'npvr.db3';
      SOAP_ListenPort := StrToIntDef(ReadSOAP(npvrdir + 'config.xml', 'Port'), 8866);
      SOAP_Login := ReadSOAP(npvrdir + 'config.xml', 'Username');
    finally
      Free;
    end;
  HideTimer.Enabled := false;
  if (SOAP_Password = '__secret__') and FileExists(LocalPath + PathDelim + 'read-me' + PathDelim + 'readme.txt') then
    LogMemo.Lines.LoadFromFile(LocalPath + PathDelim + 'read-me' + PathDelim + 'readme.txt')
  else if not AnsiSameText(ReadSOAP(npvrdir + 'config.xml', 'Enabled'), 'true') then
    LogMemo.Lines.Add('Please enable the web server in N-PVR')
  else
    HideTimer.Enabled := True;
end;

procedure TRokuForm.HideTimerTimer(Sender: TObject);
begin
  HTTPServer.Active := false;
  HTTPServer.DefaultPort := LocalPort;
  HTTPServer.Active := True;
  HideTimer.Enabled := false;
  Hide;
end;

procedure TRokuForm.HTTPRIO1AfterExecute(const MethodName: string; SOAPResponse: TStream);
begin
  if cbLogSoap.Checked then
  begin
    SOAPResponse.Position := 0;
    LogMemo.Lines.LoadFromStream(SOAPResponse);
  end;
end;

procedure TRokuForm.HTTPRIO1BeforeExecute(const MethodName: string; SOAPRequest: TStream);
begin
  if cbLogSoap.Checked then
  begin
    SOAPRequest.Position := 0;
    LogMemo.Lines.LoadFromStream(SOAPRequest);
  end;
end;

procedure TRokuForm.HTTPServerCommandGet(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
var
  ResponseStrings: TStringList;
  RequestStrings: TStringList;
  Roku: TRokuWeb;
  Filename: string;
  ext: string;

  LStartPos, LEndPos: int64;
  FileStrm: TRangeFileStream;
  guid: TGuid;
  CredFile: string;
begin
  try
    Roku := TRokuWeb.Create(NPVR_db);
    RequestStrings := TStringList.Create;
    ResponseStrings := TStringList.Create;
    try
      Roku.LocalIP := LocalIP;
      RequestStrings.Assign(ARequestInfo.params);
      Filename := copy(HTTPDecode(ARequestInfo.Document), 2, MaxInt);
      Filename := StringReplace(Filename, '/', '\', [rfIgnoreCase, rfReplaceAll]);
      if FileExists(Filename) then
      begin
        ext := copy(ExtractFileExt(Filename), 2, MaxInt);
        AResponseInfo.ContentType := Roku.GetMime(ext);
        if ARequestInfo.Ranges.Count = 1 then
        begin
          LStartPos := ARequestInfo.Ranges[0].StartPos;
          LEndPos := ARequestInfo.Ranges[0].EndPos;
        end
        else
        begin
          LStartPos := -1;
          LEndPos := -1;
        end;
        FileStrm := TRangeFileStream.Create(Filename, LStartPos, LEndPos);
        try
          AResponseInfo.ResponseNo := FileStrm.ResponseCode;
          if AResponseInfo.ResponseNo = 416 then
          begin
            AResponseInfo.ContentRangeInstanceLength := FileStrm.AbsoluteSize;
          end
          else
          begin
            if AResponseInfo.ResponseNo = 206 then
            begin
              AResponseInfo.ContentRangeStart := FileStrm.RangeStart;
              AResponseInfo.ContentRangeEnd := FileStrm.RangeEnd;
              AResponseInfo.ContentRangeInstanceLength := FileStrm.AbsoluteSize;
            end;
            AResponseInfo.ContentStream := FileStrm;
            FileStrm := nil;
          end;
        finally
          if FileStrm <> nil then
          begin
            FileStrm.Free;
          end;
        end;
      end
      else
      begin
        if AnsiSameText(RequestStrings.Values['action'], 'search') then
          Roku.SearchPartial(RequestStrings, ResponseStrings)
        else if AnsiSameText(RequestStrings.Values['action'], 'searchname') then
          Roku.SearchName(RequestStrings, ResponseStrings)
        else if AnsiSameText(RequestStrings.Values['action'], 'schedule') then
        begin
          if CoCreateGuid(guid) = S_OK then
            CredFile := GuidToString(guid)
          else
          begin
            Randomize;
            CredFile := FormatDateTime('yyyymmddhhnnsszzz', Now) + IntToStr(Random(999999));
          end;
          TSOAPSync.SOAPCall(self, CredFile, LocalPath, SOAP_Login, SOAP_Password);
          Roku.ScheduleSoap(RequestStrings, ResponseStrings, CredFile, SOAP_ListenPort);
        end
        else if AnsiSameText(RequestStrings.Values['action'], 'delete_episode') then
          Roku.DeleteEpisode(RequestStrings, ResponseStrings)
        else if AnsiSameText(RequestStrings.Values['action'], 'get_episode_list') then
          Roku.GetEpisodeList(RequestStrings, ResponseStrings)
        else if AnsiSameText(RequestStrings.Values['action'], 'get_episode_details') then
          Roku.GetEpisodeDetails(ResponseStrings, RequestStrings)
        else // default
          Roku.GetShowList(ResponseStrings); // get_show_list
        AResponseInfo.ContentType := 'text/xml';
        AResponseInfo.ContentText := ResponseStrings.Text;
      end;
    finally
      RequestStrings.Free;
      ResponseStrings.Free;
      Roku.Free;
    end;
    // some loging
    TLogSync.LogText(self, 'in:  ' + ARequestInfo.RawHTTPCommand + ' --- ' + ARequestInfo.Range);
    TLogSync.LogText(self, 'out: ' + IntToStr(AResponseInfo.ResponseNo) + ': ' + IntToStr(AResponseInfo.ContentRangeStart) + ' - ' +
      IntToStr(AResponseInfo.ContentRangeEnd));
  except
    on e: Exception do
      AResponseInfo.ContentText := '<shows><show title="' + e.Message + '" basename="error"/></shows>';
  end;
end;

end.

