unit RangeFileStream;

interface

uses
  SysUtils, Classes;

type
  TRangeFileStream = class(TFileStream)
  private
    FRangeStart, FRangeEnd: Int64;
    FResponseCode: integer;
    FRangeEnabled: boolean;
    function GetAbsolutePosition: Int64;
    function GetAbsoluteSize: Int64;
  protected
    property AbsolutePosition: Int64 read GetAbsolutePosition;
  public
    constructor Create(const AFileName: String; ARangeStart, ARangeEnd: Int64);
    function Read(var Buffer; Count: Longint): Longint; override;
    function Seek(const Offset: Int64; Origin: TSeekOrigin): Int64; override;
    property AbsoluteSize: Int64 read GetAbsoluteSize;
    property ResponseCode: integer read FResponseCode;
    property RangeEnabled: boolean read FRangeEnabled;
    property RangeStart: Int64 read FRangeStart;
    property RangeEnd: Int64 read FRangeEnd;
  end;

implementation

uses
  IdGlobal;

constructor TRangeFileStream.Create(const AFileName: String; ARangeStart, ARangeEnd: Int64);
var
  LSize: Int64;
begin
  inherited Create(AFileName, fmOpenRead or fmShareDenyWrite);
  FResponseCode := 200;
  if (ARangeStart > -1) or (ARangeEnd > -1) then
  begin
    LSize := AbsoluteSize;
    if ARangeStart > -1 then
    begin
      // requesting prefix range from BOF
      if ARangeStart >= LSize then
      begin
        // range unsatisfiable
        FResponseCode := 416;
        Exit;
      end;
      if ARangeEnd > -1 then
      begin
        if ARangeEnd < ARangeStart then
        begin
          // invalid syntax
          Exit;
        end;
        ARangeEnd := IndyMin(ARangeEnd, LSize - 1);
      end
      else
      begin
        ARangeEnd := LSize - 1;
      end;
    end
    else
    begin
      // requesting suffix range from EOF
      if ARangeEnd = 0 then
      begin
        // range unsatisfiable
        FResponseCode := 416;
        Exit;
      end;
      ARangeStart := IndyMax(LSize - ARangeEnd, 0);
      ARangeEnd := LSize - 1;
    end;
    FResponseCode := 206;
    FRangeEnabled := true;
    FRangeStart := ARangeStart;
    FRangeEnd := ARangeEnd;
  end;
end;

function TRangeFileStream.GetAbsolutePosition: Int64;
begin
  result := inherited Seek(0, soCurrent);
end;

function TRangeFileStream.GetAbsoluteSize: Int64;
var
  LPos: Int64;
begin
  LPos := inherited Seek(0, soCurrent);
  result := inherited Seek(0, soEnd);
  inherited Seek(LPos, soBeginning);
end;

function TRangeFileStream.Read(var Buffer; Count: Longint): Longint;
begin
  if FRangeEnabled then
  begin
    Count := Longint(IndyMin(Int64(Count), (FRangeEnd + 1) - AbsolutePosition));
  end;
  result := inherited Read(Buffer, Count);
end;

function TRangeFileStream.Seek(const Offset: Int64; Origin: TSeekOrigin): Int64;
var
  LPos, LOffset: Int64;
begin
  if FRangeEnabled then
  begin
    case Origin of
      soBeginning:
        LOffset := FRangeStart + Offset;
      soCurrent:
        LOffset := AbsolutePosition + Offset;
      soEnd:
        LOffset := (FRangeEnd + 1) + Offset;
    end;
    LOffset := IndyMax(LOffset, FRangeStart);
    LOffset := IndyMin(LOffset, FRangeEnd + 1);
    result := inherited Seek(LOffset, soBeginning) - FRangeStart;
  end
  else
  begin
    result := inherited Seek(Offset, Origin);
  end;
end;

end.
