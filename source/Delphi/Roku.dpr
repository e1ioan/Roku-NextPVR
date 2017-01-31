program Roku;

uses
  Forms,
  Main in 'Main.pas' {RokuForm},
  handlerequests in 'handlerequests.pas',
  SQLiteTable3 in 'SQLiteTable3.pas',
  SQLite3 in 'SQLite3.pas',
  sqlite3udf in 'sqlite3udf.pas',
  RangeFileStream in 'RangeFileStream.pas',
  ScheduleService1 in 'ScheduleService1.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TRokuForm, RokuForm);
  Application.Run;

end.
