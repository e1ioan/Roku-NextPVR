// ************************************************************************ //
// The types declared in this file were generated from data read from the
// WSDL File described below:
// WSDL     : http://ioan-home.homeip.net:8866/public/services/ScheduleService.asmx?WSDL
// >Import : http://ioan-home.homeip.net:8866/public/services/ScheduleService.asmx?WSDL>0
// Encoding : utf-8
// Version  : 1.0
// (2/17/2011 3:54:02 PM - - $Rev: 19514 $)
// ************************************************************************ //

unit ScheduleService1;

interface

uses InvokeRegistry, SOAPHTTPClient, Types, XSBuiltIns;

const
  IS_OPTN = $0001;
  IS_UNBD = $0002;
  IS_NLBL = $0004;
  IS_REF = $0080;

type

  // ************************************************************************ //
  // The following types, referred to in the WSDL document are not being represented
  // in this file. They are either aliases[@] of other types represented or were referred
  // to but never[!] declared in the document. The types from the latter category
  // typically map to predefined/known XML or Borland types; however, they could also
  // indicate incorrect WSDL documents that failed to declare or import a schema type.
  // ************************************************************************ //
  // !:string          - "http://www.w3.org/2001/XMLSchema"[Gbl]
  // !:int             - "http://www.w3.org/2001/XMLSchema"[Gbl]
  // !:boolean         - "http://www.w3.org/2001/XMLSchema"[Gbl]
  // !:dateTime        - "http://www.w3.org/2001/XMLSchema"[Gbl]

  webServiceAuthentication = class; { "http://tempuri.org/"[Hdr][GblCplx] }
  webServiceScheduleSettings = class; { "http://tempuri.org/"[GblCplx] }
  webServiceEPGEvent = class; { "http://tempuri.org/"[GblCplx] }
  ArrayOfChoice1 = class; { "http://tempuri.org/"[GblCplx] }
  webServiceReturn = class; { "http://tempuri.org/"[GblCplx] }
  webServiceScheduleObject = class; { "http://tempuri.org/"[GblCplx] }
  webServiceRecurringObject = class; { "http://tempuri.org/"[GblCplx] }
  webServiceAuthentication2 = class; { "http://tempuri.org/"[Hdr][GblElm] }
  webServiceEPGEventObject = class; { "http://tempuri.org/"[GblCplx] }

{$SCOPEDENUMS ON}
  { "http://tempuri.org/"[GblSmpl] }
  RecordingQuality = (QUALITY_DEFAULT, QUALITY_GOOD, QUALITY_BETTER, QUALITY_BEST);

  { "http://tempuri.org/"[GblSmpl] }
  recordTimeIntervalType = (recordOnce, recordThisTimeslot, recordAnyTimeslot);

  { "http://tempuri.org/"[GblSmpl] }
  recordDayIntervalType = (recordThisDay, recordAnyDay, recordSpecificDay);

{$SCOPEDENUMS OFF}

  // ************************************************************************ //
  // XML       : webServiceAuthentication, global, <complexType>
  // Namespace : http://tempuri.org/
  // Info      : Header
  // ************************************************************************ //
  webServiceAuthentication = class(TSOAPHeader)
  private
    FR: string;
    FR_Specified: boolean;
    FRL: string;
    FRL_Specified: boolean;
    FRTL: string;
    FRTL_Specified: boolean;
    FUserName: string;
    FUserName_Specified: boolean;
    FPassword: string;
    FPassword_Specified: boolean;
    procedure SetR(Index: Integer; const Astring: string);
    function R_Specified(Index: Integer): boolean;
    procedure SetRL(Index: Integer; const Astring: string);
    function RL_Specified(Index: Integer): boolean;
    procedure SetRTL(Index: Integer; const Astring: string);
    function RTL_Specified(Index: Integer): boolean;
    procedure SetUserName(Index: Integer; const Astring: string);
    function UserName_Specified(Index: Integer): boolean;
    procedure SetPassword(Index: Integer; const Astring: string);
    function Password_Specified(Index: Integer): boolean;
  published
    property R: string Index(IS_OPTN)read FR write SetR stored R_Specified;
    property RL: string Index(IS_OPTN)read FRL write SetRL stored RL_Specified;
    property RTL: string Index(IS_OPTN)read FRTL write SetRTL stored RTL_Specified;
    property UserName: string Index(IS_OPTN)read FUserName write SetUserName stored UserName_Specified;
    property Password: string Index(IS_OPTN)read FPassword write SetPassword stored Password_Specified;
  end;

  // ************************************************************************ //
  // XML       : webServiceScheduleSettings, global, <complexType>
  // Namespace : http://tempuri.org/
  // ************************************************************************ //
  webServiceScheduleSettings = class(TRemotable)
  private
    FepgeventOID: string;
    FepgeventOID_Specified: boolean;
    Fquality: RecordingQuality;
    FqualityBest: RecordingQuality;
    FqualityBetter: RecordingQuality;
    FqualityGood: RecordingQuality;
    FqualityDefault: RecordingQuality;
    Fpre_padding_min: Integer;
    Fpost_padding_min: Integer;
    Fextend_end_time_min: Integer;
    Fdays_to_keep: Integer;
    FrecordTimeInterval: recordTimeIntervalType;
    FrecordDayInterval: recordDayIntervalType;
    FdayMonday: boolean;
    FdayTuesday: boolean;
    FdayWednesday: boolean;
    FdayThursday: boolean;
    FdayFriday: boolean;
    FdaySaturday: boolean;
    FdaySunday: boolean;
    procedure SetepgeventOID(Index: Integer; const Astring: string);
    function epgeventOID_Specified(Index: Integer): boolean;
  published
    property epgeventOID: string Index(IS_OPTN)read FepgeventOID write SetepgeventOID stored epgeventOID_Specified;
    property quality: RecordingQuality read Fquality write Fquality;
    property qualityBest: RecordingQuality read FqualityBest write FqualityBest;
    property qualityBetter: RecordingQuality read FqualityBetter write FqualityBetter;
    property qualityGood: RecordingQuality read FqualityGood write FqualityGood;
    property qualityDefault: RecordingQuality read FqualityDefault write FqualityDefault;
    property pre_padding_min: Integer read Fpre_padding_min write Fpre_padding_min;
    property post_padding_min: Integer read Fpost_padding_min write Fpost_padding_min;
    property extend_end_time_min: Integer read Fextend_end_time_min write Fextend_end_time_min;
    property days_to_keep: Integer read Fdays_to_keep write Fdays_to_keep;
    property recordTimeInterval: recordTimeIntervalType read FrecordTimeInterval write FrecordTimeInterval;
    property recordDayInterval: recordDayIntervalType read FrecordDayInterval write FrecordDayInterval;
    property dayMonday: boolean read FdayMonday write FdayMonday;
    property dayTuesday: boolean read FdayTuesday write FdayTuesday;
    property dayWednesday: boolean read FdayWednesday write FdayWednesday;
    property dayThursday: boolean read FdayThursday write FdayThursday;
    property dayFriday: boolean read FdayFriday write FdayFriday;
    property daySaturday: boolean read FdaySaturday write FdaySaturday;
    property daySunday: boolean read FdaySunday write FdaySunday;
  end;

  // ************************************************************************ //
  // XML       : webServiceEPGEvent, global, <complexType>
  // Namespace : http://tempuri.org/
  // ************************************************************************ //
  webServiceEPGEvent = class(TRemotable)
  private
    FwebServiceEPGEventObjects: ArrayOfChoice1;
    FwebServiceEPGEventObjects_Specified: boolean;
    procedure SetwebServiceEPGEventObjects(Index: Integer; const AArrayOfChoice1: ArrayOfChoice1);
    function webServiceEPGEventObjects_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property webServiceEPGEventObjects: ArrayOfChoice1 Index(IS_OPTN)read FwebServiceEPGEventObjects write SetwebServiceEPGEventObjects stored webServiceEPGEventObjects_Specified;
  end;

  // ************************************************************************ //
  // XML       : ArrayOfChoice1, global, <complexType>
  // Namespace : http://tempuri.org/
  // ************************************************************************ //
  ArrayOfChoice1 = class(TRemotable)
  private
    FwebServiceRecurringObject: webServiceRecurringObject;
    FwebServiceRecurringObject_Specified: boolean;
    FwebServiceReturn: webServiceReturn;
    FwebServiceReturn_Specified: boolean;
    FwebServiceEPGEventObject: webServiceEPGEventObject;
    FwebServiceEPGEventObject_Specified: boolean;
    FwebServiceScheduleObject: webServiceScheduleObject;
    FwebServiceScheduleObject_Specified: boolean;
    procedure SetwebServiceRecurringObject(Index: Integer; const AwebServiceRecurringObject: webServiceRecurringObject);
    function webServiceRecurringObject_Specified(Index: Integer): boolean;
    procedure SetwebServiceReturn(Index: Integer; const AwebServiceReturn: webServiceReturn);
    function webServiceReturn_Specified(Index: Integer): boolean;
    procedure SetwebServiceEPGEventObject(Index: Integer; const AwebServiceEPGEventObject: webServiceEPGEventObject);
    function webServiceEPGEventObject_Specified(Index: Integer): boolean;
    procedure SetwebServiceScheduleObject(Index: Integer; const AwebServiceScheduleObject: webServiceScheduleObject);
    function webServiceScheduleObject_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property webServiceRecurringObject: webServiceRecurringObject Index(IS_OPTN or IS_NLBL)read FwebServiceRecurringObject write SetwebServiceRecurringObject
      stored webServiceRecurringObject_Specified;
    property webServiceReturn: webServiceReturn Index(IS_OPTN or IS_NLBL)read FwebServiceReturn write SetwebServiceReturn stored webServiceReturn_Specified;
    property webServiceEPGEventObject: webServiceEPGEventObject Index(IS_OPTN or IS_NLBL)read FwebServiceEPGEventObject write SetwebServiceEPGEventObject
      stored webServiceEPGEventObject_Specified;
    property webServiceScheduleObject: webServiceScheduleObject Index(IS_OPTN or IS_NLBL)read FwebServiceScheduleObject write SetwebServiceScheduleObject
      stored webServiceScheduleObject_Specified;
  end;

  // ************************************************************************ //
  // XML       : webServiceReturn, global, <complexType>
  // Namespace : http://tempuri.org/
  // ************************************************************************ //
  webServiceReturn = class(TRemotable)
  private
    FError: boolean;
    FMessage_: string;
    FMessage__Specified: boolean;
    procedure SetMessage_(Index: Integer; const Astring: string);
    function Message__Specified(Index: Integer): boolean;
  published
    property Error: boolean read FError write FError;
    property Message_: string Index(IS_OPTN)read FMessage_ write SetMessage_ stored Message__Specified;
  end;

  // ************************************************************************ //
  // XML       : webServiceScheduleObject, global, <complexType>
  // Namespace : http://tempuri.org/
  // ************************************************************************ //
  webServiceScheduleObject = class(TRemotable)
  private
    FOID: Integer;
    FChannelOid: Integer;
    FPriority: Integer;
    FName_: string;
    FName__Specified: boolean;
    Fquality: string;
    FQuality_Specified: boolean;
    FType_: string;
    FType__Specified: boolean;
    FDay: string;
    FDay_Specified: boolean;
    FStartTime: TXSDateTime;
    FEndTime: TXSDateTime;
    FStatus: string;
    FStatus_Specified: boolean;
    FFailuerReason: string;
    FFailuerReason_Specified: boolean;
    FPrePadding: string;
    FPrePadding_Specified: boolean;
    FPostPadding: string;
    FPostPadding_Specified: boolean;
    FMaxRecordings: string;
    FMaxRecordings_Specified: boolean;
    FDownloadURL: string;
    FDownloadURL_Specified: boolean;
    procedure SetName_(Index: Integer; const Astring: string);
    function Name__Specified(Index: Integer): boolean;
    procedure SetQuality(Index: Integer; const Astring: string);
    function Quality_Specified(Index: Integer): boolean;
    procedure SetType_(Index: Integer; const Astring: string);
    function Type__Specified(Index: Integer): boolean;
    procedure SetDay(Index: Integer; const Astring: string);
    function Day_Specified(Index: Integer): boolean;
    procedure SetStatus(Index: Integer; const Astring: string);
    function Status_Specified(Index: Integer): boolean;
    procedure SetFailuerReason(Index: Integer; const Astring: string);
    function FailuerReason_Specified(Index: Integer): boolean;
    procedure SetPrePadding(Index: Integer; const Astring: string);
    function PrePadding_Specified(Index: Integer): boolean;
    procedure SetPostPadding(Index: Integer; const Astring: string);
    function PostPadding_Specified(Index: Integer): boolean;
    procedure SetMaxRecordings(Index: Integer; const Astring: string);
    function MaxRecordings_Specified(Index: Integer): boolean;
    procedure SetDownloadURL(Index: Integer; const Astring: string);
    function DownloadURL_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property OID: Integer read FOID write FOID;
    property ChannelOid: Integer read FChannelOid write FChannelOid;
    property Priority: Integer read FPriority write FPriority;
    property Name_: string Index(IS_OPTN)read FName_ write SetName_ stored Name__Specified;
    property quality: string Index(IS_OPTN)read Fquality write SetQuality stored Quality_Specified;
    property Type_: string Index(IS_OPTN)read FType_ write SetType_ stored Type__Specified;
    property Day: string Index(IS_OPTN)read FDay write SetDay stored Day_Specified;
    property StartTime: TXSDateTime read FStartTime write FStartTime;
    property EndTime: TXSDateTime read FEndTime write FEndTime;
    property Status: string Index(IS_OPTN)read FStatus write SetStatus stored Status_Specified;
    property FailuerReason: string Index(IS_OPTN)read FFailuerReason write SetFailuerReason stored FailuerReason_Specified;
    property PrePadding: string Index(IS_OPTN)read FPrePadding write SetPrePadding stored PrePadding_Specified;
    property PostPadding: string Index(IS_OPTN)read FPostPadding write SetPostPadding stored PostPadding_Specified;
    property MaxRecordings: string Index(IS_OPTN)read FMaxRecordings write SetMaxRecordings stored MaxRecordings_Specified;
    property DownloadURL: string Index(IS_OPTN)read FDownloadURL write SetDownloadURL stored DownloadURL_Specified;
  end;

  // ************************************************************************ //
  // XML       : webServiceRecurringObject, global, <complexType>
  // Namespace : http://tempuri.org/
  // ************************************************************************ //
  webServiceRecurringObject = class(TRemotable)
  private
    FOID: Integer;
    FChannelOid: Integer;
    FPriority: Integer;
    FName_: string;
    FName__Specified: boolean;
    Fquality: string;
    FQuality_Specified: boolean;
    FDay: string;
    FDay_Specified: boolean;
    FRules: string;
    FRules_Specified: boolean;
    FStartTime: TXSDateTime;
    FEndTime: TXSDateTime;
    FType_: string;
    FType__Specified: boolean;
    FPrePadding: string;
    FPrePadding_Specified: boolean;
    FPostPadding: string;
    FPostPadding_Specified: boolean;
    FMaxRecordings: string;
    FMaxRecordings_Specified: boolean;
    procedure SetName_(Index: Integer; const Astring: string);
    function Name__Specified(Index: Integer): boolean;
    procedure SetQuality(Index: Integer; const Astring: string);
    function Quality_Specified(Index: Integer): boolean;
    procedure SetDay(Index: Integer; const Astring: string);
    function Day_Specified(Index: Integer): boolean;
    procedure SetRules(Index: Integer; const Astring: string);
    function Rules_Specified(Index: Integer): boolean;
    procedure SetType_(Index: Integer; const Astring: string);
    function Type__Specified(Index: Integer): boolean;
    procedure SetPrePadding(Index: Integer; const Astring: string);
    function PrePadding_Specified(Index: Integer): boolean;
    procedure SetPostPadding(Index: Integer; const Astring: string);
    function PostPadding_Specified(Index: Integer): boolean;
    procedure SetMaxRecordings(Index: Integer; const Astring: string);
    function MaxRecordings_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property OID: Integer read FOID write FOID;
    property ChannelOid: Integer read FChannelOid write FChannelOid;
    property Priority: Integer read FPriority write FPriority;
    property Name_: string Index(IS_OPTN)read FName_ write SetName_ stored Name__Specified;
    property quality: string Index(IS_OPTN)read Fquality write SetQuality stored Quality_Specified;
    property Day: string Index(IS_OPTN)read FDay write SetDay stored Day_Specified;
    property Rules: string Index(IS_OPTN)read FRules write SetRules stored Rules_Specified;
    property StartTime: TXSDateTime read FStartTime write FStartTime;
    property EndTime: TXSDateTime read FEndTime write FEndTime;
    property Type_: string Index(IS_OPTN)read FType_ write SetType_ stored Type__Specified;
    property PrePadding: string Index(IS_OPTN)read FPrePadding write SetPrePadding stored PrePadding_Specified;
    property PostPadding: string Index(IS_OPTN)read FPostPadding write SetPostPadding stored PostPadding_Specified;
    property MaxRecordings: string Index(IS_OPTN)read FMaxRecordings write SetMaxRecordings stored MaxRecordings_Specified;
  end;

  // ************************************************************************ //
  // XML       : webServiceAuthentication, global, <element>
  // Namespace : http://tempuri.org/
  // Info      : Header
  // ************************************************************************ //
  webServiceAuthentication2 = class(webServiceAuthentication)
  private
  published
  end;

  anyType = type string; { "http://tempuri.org/"[Alias] }
  ArrayOfAnyType = array of anyType; { "http://tempuri.org/"[GblCplx] }

  // ************************************************************************ //
  // XML       : webServiceEPGEventObject, global, <complexType>
  // Namespace : http://tempuri.org/
  // ************************************************************************ //
  webServiceEPGEventObject = class(TRemotable)
  private
    FOID: Integer;
    FUniqueId: string;
    FUniqueId_Specified: boolean;
    FChannelOid: Integer;
    FStartTime: TXSDateTime;
    FEndTime: TXSDateTime;
    FTitle: string;
    FTitle_Specified: boolean;
    FSubtitle: string;
    FSubtitle_Specified: boolean;
    FDesc: string;
    FDesc_Specified: boolean;
    FRating: string;
    FRating_Specified: boolean;
    FGenreList: ArrayOfAnyType;
    FGenreList_Specified: boolean;
    FHasSchedule: boolean;
    FScheduleIsRecurring: boolean;
    procedure SetUniqueId(Index: Integer; const Astring: string);
    function UniqueId_Specified(Index: Integer): boolean;
    procedure SetTitle(Index: Integer; const Astring: string);
    function Title_Specified(Index: Integer): boolean;
    procedure SetSubtitle(Index: Integer; const Astring: string);
    function Subtitle_Specified(Index: Integer): boolean;
    procedure SetDesc(Index: Integer; const Astring: string);
    function Desc_Specified(Index: Integer): boolean;
    procedure SetRating(Index: Integer; const Astring: string);
    function Rating_Specified(Index: Integer): boolean;
    procedure SetGenreList(Index: Integer; const AArrayOfAnyType: ArrayOfAnyType);
    function GenreList_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property OID: Integer read FOID write FOID;
    property UniqueId: string Index(IS_OPTN)read FUniqueId write SetUniqueId stored UniqueId_Specified;
    property ChannelOid: Integer read FChannelOid write FChannelOid;
    property StartTime: TXSDateTime read FStartTime write FStartTime;
    property EndTime: TXSDateTime read FEndTime write FEndTime;
    property Title: string Index(IS_OPTN)read FTitle write SetTitle stored Title_Specified;
    property Subtitle: string Index(IS_OPTN)read FSubtitle write SetSubtitle stored Subtitle_Specified;
    property Desc: string Index(IS_OPTN)read FDesc write SetDesc stored Desc_Specified;
    property Rating: string Index(IS_OPTN)read FRating write SetRating stored Rating_Specified;
    property GenreList: ArrayOfAnyType Index(IS_OPTN)read FGenreList write SetGenreList stored GenreList_Specified;
    property HasSchedule: boolean read FHasSchedule write FHasSchedule;
    property ScheduleIsRecurring: boolean read FScheduleIsRecurring write FScheduleIsRecurring;
  end;

  // ************************************************************************ //
  // Namespace : http://tempuri.org/
  // soapAction: http://tempuri.org/%operationName%
  // transport : http://schemas.xmlsoap.org/soap/http
  // style     : document
  // binding   : ScheduleServiceSoap
  // service   : ScheduleService
  // port      : ScheduleServiceSoap
  // URL       : http://192.168.1.55:8866/public/services/ScheduleService.asmx
  // ************************************************************************ //
  ScheduleServiceSoap = interface(IInvokable)
    ['{1682F60E-A582-57E4-BBD9-E60E26987AFB}']

    // Headers: webServiceAuthentication:pIn
    function Test: string; stdcall;

    // Headers: webServiceAuthentication:pIn
    function scheduleRecording(const schedlSettings: webServiceScheduleSettings): webServiceEPGEvent; stdcall;

    // Headers: webServiceAuthentication:pIn
    function scheduleRecordingSerialized(const schedlSettings: webServiceScheduleSettings): string; stdcall;

    // Headers: webServiceAuthentication:pIn
    function cancelRecording(const scheduleOID: Integer): webServiceEPGEvent; stdcall;

    // Headers: webServiceAuthentication:pIn
    function cancelRecordingSerialized(const scheduleOID: Integer): string; stdcall;

    // Headers: webServiceAuthentication:pIn
    function cancelRecurring(const recurringOID: Integer): webServiceEPGEvent; stdcall;

    // Headers: webServiceAuthentication:pIn
    function cancelRecurringSerialized(const recurringOID: Integer): string; stdcall;

    // Headers: webServiceAuthentication:pIn
    function deleteRecording(const scheduleOID: Integer): webServiceEPGEvent; stdcall;

    // Headers: webServiceAuthentication:pIn
    function deleteRecordingSerialized(const scheduleOID: Integer): string; stdcall;

    // Headers: webServiceAuthentication:pIn
    function cancelAndDeleteRecording(const scheduleOID: Integer): webServiceEPGEvent; stdcall;

    // Headers: webServiceAuthentication:pIn
    function cancelAndDeleteRecordingSerialized(const scheduleOID: Integer): string; stdcall;

    // Headers: webServiceAuthentication:pIn
    function updateRecording(const scheduleOID: Integer; const schedlSettings: webServiceScheduleSettings): webServiceEPGEvent; stdcall;

    // Headers: webServiceAuthentication:pIn
    function updateRecordingSerialized(const scheduleOID: Integer; const schedlSettings: webServiceScheduleSettings): string; stdcall;

    // Headers: webServiceAuthentication:pIn
    function updateRecurring(const recurringOID: Integer; const schedlSettings: webServiceScheduleSettings): webServiceEPGEvent; stdcall;

    // Headers: webServiceAuthentication:pIn
    function updateRecurringSerialized(const recurringOID: Integer; const schedlSettings: webServiceScheduleSettings): string; stdcall;
  end;

function GetScheduleServiceSoap(ListenPort: Integer = 8866; UseWSDL: boolean = System.False; Addr: string = ''; HTTPRIO: THTTPRIO = nil): ScheduleServiceSoap;

implementation

uses SysUtils;

function GetScheduleServiceSoap(ListenPort: Integer; UseWSDL: boolean; Addr: string; HTTPRIO: THTTPRIO): ScheduleServiceSoap;
const
  defWSDL = 'http://localhost:%d/public/services/ScheduleService.asmx?WSDL';
  defURL = 'http://localhost:%d/public/services/ScheduleService.asmx';
  defSvc = 'ScheduleService';
  defPrt = 'ScheduleServiceSoap';
var
  RIO: THTTPRIO;
begin
  Result := nil;
  if (Addr = '') then
  begin
    if UseWSDL then
      Addr := Format(defWSDL, [ListenPort])
    else
      Addr := Format(defURL, [ListenPort]);
  end;
  if HTTPRIO = nil then
    RIO := THTTPRIO.Create(nil)
  else
    RIO := HTTPRIO;
  try
    Result := (RIO as ScheduleServiceSoap);
    if UseWSDL then
    begin
      RIO.WSDLLocation := Addr;
      RIO.Service := defSvc;
      RIO.Port := defPrt;
    end
    else
      RIO.URL := Addr;
  finally
    if (Result = nil) and (HTTPRIO = nil) then
      RIO.Free;
  end;
end;

procedure webServiceAuthentication.SetR(Index: Integer; const Astring: string);
begin
  FR := Astring;
  FR_Specified := True;
end;

function webServiceAuthentication.R_Specified(Index: Integer): boolean;
begin
  Result := FR_Specified;
end;

procedure webServiceAuthentication.SetRL(Index: Integer; const Astring: string);
begin
  FRL := Astring;
  FRL_Specified := True;
end;

function webServiceAuthentication.RL_Specified(Index: Integer): boolean;
begin
  Result := FRL_Specified;
end;

procedure webServiceAuthentication.SetRTL(Index: Integer; const Astring: string);
begin
  FRTL := Astring;
  FRTL_Specified := True;
end;

function webServiceAuthentication.RTL_Specified(Index: Integer): boolean;
begin
  Result := FRTL_Specified;
end;

procedure webServiceAuthentication.SetUserName(Index: Integer; const Astring: string);
begin
  FUserName := Astring;
  FUserName_Specified := True;
end;

function webServiceAuthentication.UserName_Specified(Index: Integer): boolean;
begin
  Result := FUserName_Specified;
end;

procedure webServiceAuthentication.SetPassword(Index: Integer; const Astring: string);
begin
  FPassword := Astring;
  FPassword_Specified := True;
end;

function webServiceAuthentication.Password_Specified(Index: Integer): boolean;
begin
  Result := FPassword_Specified;
end;

procedure webServiceScheduleSettings.SetepgeventOID(Index: Integer; const Astring: string);
begin
  FepgeventOID := Astring;
  FepgeventOID_Specified := True;
end;

function webServiceScheduleSettings.epgeventOID_Specified(Index: Integer): boolean;
begin
  Result := FepgeventOID_Specified;
end;

destructor webServiceEPGEvent.Destroy;
begin
  SysUtils.FreeAndNil(FwebServiceEPGEventObjects);
  inherited Destroy;
end;

procedure webServiceEPGEvent.SetwebServiceEPGEventObjects(Index: Integer; const AArrayOfChoice1: ArrayOfChoice1);
begin
  FwebServiceEPGEventObjects := AArrayOfChoice1;
  FwebServiceEPGEventObjects_Specified := True;
end;

function webServiceEPGEvent.webServiceEPGEventObjects_Specified(Index: Integer): boolean;
begin
  Result := FwebServiceEPGEventObjects_Specified;
end;

destructor ArrayOfChoice1.Destroy;
begin
  SysUtils.FreeAndNil(FwebServiceRecurringObject);
  SysUtils.FreeAndNil(FwebServiceReturn);
  SysUtils.FreeAndNil(FwebServiceEPGEventObject);
  SysUtils.FreeAndNil(FwebServiceScheduleObject);
  inherited Destroy;
end;

procedure ArrayOfChoice1.SetwebServiceRecurringObject(Index: Integer; const AwebServiceRecurringObject: webServiceRecurringObject);
begin
  FwebServiceRecurringObject := AwebServiceRecurringObject;
  FwebServiceRecurringObject_Specified := True;
end;

function ArrayOfChoice1.webServiceRecurringObject_Specified(Index: Integer): boolean;
begin
  Result := FwebServiceRecurringObject_Specified;
end;

procedure ArrayOfChoice1.SetwebServiceReturn(Index: Integer; const AwebServiceReturn: webServiceReturn);
begin
  FwebServiceReturn := AwebServiceReturn;
  FwebServiceReturn_Specified := True;
end;

function ArrayOfChoice1.webServiceReturn_Specified(Index: Integer): boolean;
begin
  Result := FwebServiceReturn_Specified;
end;

procedure ArrayOfChoice1.SetwebServiceEPGEventObject(Index: Integer; const AwebServiceEPGEventObject: webServiceEPGEventObject);
begin
  FwebServiceEPGEventObject := AwebServiceEPGEventObject;
  FwebServiceEPGEventObject_Specified := True;
end;

function ArrayOfChoice1.webServiceEPGEventObject_Specified(Index: Integer): boolean;
begin
  Result := FwebServiceEPGEventObject_Specified;
end;

procedure ArrayOfChoice1.SetwebServiceScheduleObject(Index: Integer; const AwebServiceScheduleObject: webServiceScheduleObject);
begin
  FwebServiceScheduleObject := AwebServiceScheduleObject;
  FwebServiceScheduleObject_Specified := True;
end;

function ArrayOfChoice1.webServiceScheduleObject_Specified(Index: Integer): boolean;
begin
  Result := FwebServiceScheduleObject_Specified;
end;

procedure webServiceReturn.SetMessage_(Index: Integer; const Astring: string);
begin
  FMessage_ := Astring;
  FMessage__Specified := True;
end;

function webServiceReturn.Message__Specified(Index: Integer): boolean;
begin
  Result := FMessage__Specified;
end;

destructor webServiceScheduleObject.Destroy;
begin
  SysUtils.FreeAndNil(FStartTime);
  SysUtils.FreeAndNil(FEndTime);
  inherited Destroy;
end;

procedure webServiceScheduleObject.SetName_(Index: Integer; const Astring: string);
begin
  FName_ := Astring;
  FName__Specified := True;
end;

function webServiceScheduleObject.Name__Specified(Index: Integer): boolean;
begin
  Result := FName__Specified;
end;

procedure webServiceScheduleObject.SetQuality(Index: Integer; const Astring: string);
begin
  Fquality := Astring;
  FQuality_Specified := True;
end;

function webServiceScheduleObject.Quality_Specified(Index: Integer): boolean;
begin
  Result := FQuality_Specified;
end;

procedure webServiceScheduleObject.SetType_(Index: Integer; const Astring: string);
begin
  FType_ := Astring;
  FType__Specified := True;
end;

function webServiceScheduleObject.Type__Specified(Index: Integer): boolean;
begin
  Result := FType__Specified;
end;

procedure webServiceScheduleObject.SetDay(Index: Integer; const Astring: string);
begin
  FDay := Astring;
  FDay_Specified := True;
end;

function webServiceScheduleObject.Day_Specified(Index: Integer): boolean;
begin
  Result := FDay_Specified;
end;

procedure webServiceScheduleObject.SetStatus(Index: Integer; const Astring: string);
begin
  FStatus := Astring;
  FStatus_Specified := True;
end;

function webServiceScheduleObject.Status_Specified(Index: Integer): boolean;
begin
  Result := FStatus_Specified;
end;

procedure webServiceScheduleObject.SetFailuerReason(Index: Integer; const Astring: string);
begin
  FFailuerReason := Astring;
  FFailuerReason_Specified := True;
end;

function webServiceScheduleObject.FailuerReason_Specified(Index: Integer): boolean;
begin
  Result := FFailuerReason_Specified;
end;

procedure webServiceScheduleObject.SetPrePadding(Index: Integer; const Astring: string);
begin
  FPrePadding := Astring;
  FPrePadding_Specified := True;
end;

function webServiceScheduleObject.PrePadding_Specified(Index: Integer): boolean;
begin
  Result := FPrePadding_Specified;
end;

procedure webServiceScheduleObject.SetPostPadding(Index: Integer; const Astring: string);
begin
  FPostPadding := Astring;
  FPostPadding_Specified := True;
end;

function webServiceScheduleObject.PostPadding_Specified(Index: Integer): boolean;
begin
  Result := FPostPadding_Specified;
end;

procedure webServiceScheduleObject.SetMaxRecordings(Index: Integer; const Astring: string);
begin
  FMaxRecordings := Astring;
  FMaxRecordings_Specified := True;
end;

function webServiceScheduleObject.MaxRecordings_Specified(Index: Integer): boolean;
begin
  Result := FMaxRecordings_Specified;
end;

procedure webServiceScheduleObject.SetDownloadURL(Index: Integer; const Astring: string);
begin
  FDownloadURL := Astring;
  FDownloadURL_Specified := True;
end;

function webServiceScheduleObject.DownloadURL_Specified(Index: Integer): boolean;
begin
  Result := FDownloadURL_Specified;
end;

destructor webServiceRecurringObject.Destroy;
begin
  SysUtils.FreeAndNil(FStartTime);
  SysUtils.FreeAndNil(FEndTime);
  inherited Destroy;
end;

procedure webServiceRecurringObject.SetName_(Index: Integer; const Astring: string);
begin
  FName_ := Astring;
  FName__Specified := True;
end;

function webServiceRecurringObject.Name__Specified(Index: Integer): boolean;
begin
  Result := FName__Specified;
end;

procedure webServiceRecurringObject.SetQuality(Index: Integer; const Astring: string);
begin
  Fquality := Astring;
  FQuality_Specified := True;
end;

function webServiceRecurringObject.Quality_Specified(Index: Integer): boolean;
begin
  Result := FQuality_Specified;
end;

procedure webServiceRecurringObject.SetDay(Index: Integer; const Astring: string);
begin
  FDay := Astring;
  FDay_Specified := True;
end;

function webServiceRecurringObject.Day_Specified(Index: Integer): boolean;
begin
  Result := FDay_Specified;
end;

procedure webServiceRecurringObject.SetRules(Index: Integer; const Astring: string);
begin
  FRules := Astring;
  FRules_Specified := True;
end;

function webServiceRecurringObject.Rules_Specified(Index: Integer): boolean;
begin
  Result := FRules_Specified;
end;

procedure webServiceRecurringObject.SetType_(Index: Integer; const Astring: string);
begin
  FType_ := Astring;
  FType__Specified := True;
end;

function webServiceRecurringObject.Type__Specified(Index: Integer): boolean;
begin
  Result := FType__Specified;
end;

procedure webServiceRecurringObject.SetPrePadding(Index: Integer; const Astring: string);
begin
  FPrePadding := Astring;
  FPrePadding_Specified := True;
end;

function webServiceRecurringObject.PrePadding_Specified(Index: Integer): boolean;
begin
  Result := FPrePadding_Specified;
end;

procedure webServiceRecurringObject.SetPostPadding(Index: Integer; const Astring: string);
begin
  FPostPadding := Astring;
  FPostPadding_Specified := True;
end;

function webServiceRecurringObject.PostPadding_Specified(Index: Integer): boolean;
begin
  Result := FPostPadding_Specified;
end;

procedure webServiceRecurringObject.SetMaxRecordings(Index: Integer; const Astring: string);
begin
  FMaxRecordings := Astring;
  FMaxRecordings_Specified := True;
end;

function webServiceRecurringObject.MaxRecordings_Specified(Index: Integer): boolean;
begin
  Result := FMaxRecordings_Specified;
end;

destructor webServiceEPGEventObject.Destroy;
begin
  SysUtils.FreeAndNil(FStartTime);
  SysUtils.FreeAndNil(FEndTime);
  inherited Destroy;
end;

procedure webServiceEPGEventObject.SetUniqueId(Index: Integer; const Astring: string);
begin
  FUniqueId := Astring;
  FUniqueId_Specified := True;
end;

function webServiceEPGEventObject.UniqueId_Specified(Index: Integer): boolean;
begin
  Result := FUniqueId_Specified;
end;

procedure webServiceEPGEventObject.SetTitle(Index: Integer; const Astring: string);
begin
  FTitle := Astring;
  FTitle_Specified := True;
end;

function webServiceEPGEventObject.Title_Specified(Index: Integer): boolean;
begin
  Result := FTitle_Specified;
end;

procedure webServiceEPGEventObject.SetSubtitle(Index: Integer; const Astring: string);
begin
  FSubtitle := Astring;
  FSubtitle_Specified := True;
end;

function webServiceEPGEventObject.Subtitle_Specified(Index: Integer): boolean;
begin
  Result := FSubtitle_Specified;
end;

procedure webServiceEPGEventObject.SetDesc(Index: Integer; const Astring: string);
begin
  FDesc := Astring;
  FDesc_Specified := True;
end;

function webServiceEPGEventObject.Desc_Specified(Index: Integer): boolean;
begin
  Result := FDesc_Specified;
end;

procedure webServiceEPGEventObject.SetRating(Index: Integer; const Astring: string);
begin
  FRating := Astring;
  FRating_Specified := True;
end;

function webServiceEPGEventObject.Rating_Specified(Index: Integer): boolean;
begin
  Result := FRating_Specified;
end;

procedure webServiceEPGEventObject.SetGenreList(Index: Integer; const AArrayOfAnyType: ArrayOfAnyType);
begin
  FGenreList := AArrayOfAnyType;
  FGenreList_Specified := True;
end;

function webServiceEPGEventObject.GenreList_Specified(Index: Integer): boolean;
begin
  Result := FGenreList_Specified;
end;

initialization

InvRegistry.RegisterInterface(TypeInfo(ScheduleServiceSoap), 'http://tempuri.org/', 'utf-8');
InvRegistry.RegisterDefaultSOAPAction(TypeInfo(ScheduleServiceSoap), 'http://tempuri.org/%operationName%');
InvRegistry.RegisterInvokeOptions(TypeInfo(ScheduleServiceSoap), ioDocument);
InvRegistry.RegisterHeaderClass(TypeInfo(ScheduleServiceSoap), webServiceAuthentication2, 'webServiceAuthentication', 'http://tempuri.org/');
RemClassRegistry.RegisterXSClass(webServiceAuthentication, 'http://tempuri.org/', 'webServiceAuthentication');
RemClassRegistry.RegisterXSInfo(TypeInfo(RecordingQuality), 'http://tempuri.org/', 'RecordingQuality');
RemClassRegistry.RegisterXSInfo(TypeInfo(recordTimeIntervalType), 'http://tempuri.org/', 'recordTimeIntervalType');
RemClassRegistry.RegisterXSInfo(TypeInfo(recordDayIntervalType), 'http://tempuri.org/', 'recordDayIntervalType');
RemClassRegistry.RegisterXSClass(webServiceScheduleSettings, 'http://tempuri.org/', 'webServiceScheduleSettings');
RemClassRegistry.RegisterXSClass(webServiceEPGEvent, 'http://tempuri.org/', 'webServiceEPGEvent');
RemClassRegistry.RegisterXSClass(ArrayOfChoice1, 'http://tempuri.org/', 'ArrayOfChoice1');
RemClassRegistry.RegisterXSClass(webServiceReturn, 'http://tempuri.org/', 'webServiceReturn');
RemClassRegistry.RegisterExternalPropName(TypeInfo(webServiceReturn), 'Message_', 'Message');
RemClassRegistry.RegisterXSClass(webServiceScheduleObject, 'http://tempuri.org/', 'webServiceScheduleObject');
RemClassRegistry.RegisterExternalPropName(TypeInfo(webServiceScheduleObject), 'Name_', 'Name');
RemClassRegistry.RegisterExternalPropName(TypeInfo(webServiceScheduleObject), 'Type_', 'Type');
RemClassRegistry.RegisterXSClass(webServiceRecurringObject, 'http://tempuri.org/', 'webServiceRecurringObject');
RemClassRegistry.RegisterExternalPropName(TypeInfo(webServiceRecurringObject), 'Name_', 'Name');
RemClassRegistry.RegisterExternalPropName(TypeInfo(webServiceRecurringObject), 'Type_', 'Type');
RemClassRegistry.RegisterXSClass(webServiceAuthentication2, 'http://tempuri.org/', 'webServiceAuthentication2', 'webServiceAuthentication');
RemClassRegistry.RegisterXSInfo(TypeInfo(anyType), 'http://tempuri.org/', 'anyType');
RemClassRegistry.RegisterXSInfo(TypeInfo(ArrayOfAnyType), 'http://tempuri.org/', 'ArrayOfAnyType');
RemClassRegistry.RegisterXSClass(webServiceEPGEventObject, 'http://tempuri.org/', 'webServiceEPGEventObject');

end.
