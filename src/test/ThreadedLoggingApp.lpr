program ThreadedLoggingApp;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  SysUtils,
  Classes,
  Windows,
  Log4D in '..\main\Log4D.pas';

type
  { Thread that logs messages }
  TLoggingThread = class(TThread)
  private
    FLogger: TLogLogger;
    FThreadName: string;
    FIterations: Integer;
  protected
    procedure Execute; override;
  public
    constructor Create(const AThreadName: string; AIterations: Integer); reintroduce;
    property Logger: TLogLogger write FLogger;
  end;

{ TLoggingThread }

constructor TLoggingThread.Create(const AThreadName: string; AIterations: Integer);
begin
  inherited Create(True);
  FThreadName := AThreadName;
  FIterations := AIterations;
  FreeOnTerminate := False;
end;

procedure TLoggingThread.Execute;
var
  i: Integer;
begin
  if not Assigned(FLogger) then
    Exit;

  for i := 1 to FIterations do
  begin
    FLogger.Info(FThreadName + ' - Message ' + IntToStr(i));
    { Simulate some work }
    Sleep(100);
  end;

  FLogger.Info(FThreadName + ' - Completed');
end;

var
  RootLogger: TLogLogger;
  Layout: TLogPatternLayout;
  Appender: TLogFileAppender;
  Thread1, Thread2: TLoggingThread;
  LogFileName: string;

begin
  try
    { Set up the log file path }
    LogFileName := GetCurrentDir + '\ThreadedLogging.log';

    { Create and configure the pattern layout }
    { Pattern shows: timestamp [thread] level logger - message }
    Layout := TLogPatternLayout.Create('[%d{yyyy-mm-dd hh:nn:ss.zzz}] [%t] %p %c - %m%n');

    { Create file appender with the pattern layout }
    Appender := TLogFileAppender.Create(
      'FileAppender',
      LogFileName,
      Layout,
      False { overwrite the file }
    );

    { Get the root logger and add the appender }
    RootLogger := TLogLogger.GetRootLogger;
    RootLogger.Level := Info;
    RootLogger.AddAppender(Appender);

    WriteLn('Delphi Console Application using Log4D with Multi-Threading');
    WriteLn('============================================================');
    WriteLn('');
    WriteLn('Log file: ' + LogFileName);
    WriteLn('Starting two logging threads...');
    WriteLn('');

    { Log from main thread }
    RootLogger.Info('Application started');

    { Create and start Thread 1 }
    Thread1 := TLoggingThread.Create('Thread1', 5);
    Thread1.Logger := RootLogger;
    Thread1.Start;

    { Create and start Thread 2 }
    Thread2 := TLoggingThread.Create('Thread2', 5);
    Thread2.Logger := RootLogger;
    Thread2.Start;

    { Wait for threads to complete }
    Thread1.WaitFor;
    Thread2.WaitFor;

    { Free the thread objects }
    Thread1.Free;
    Thread2.Free;

    { Log from main thread }
    RootLogger.Info('Application finished');

    WriteLn('All threads completed. Check log file for results.');
    WriteLn('');
    WriteLn('Press Enter to exit...');
    ReadLn;

  except
    on E: Exception do
    begin
      WriteLn('Error: ' + E.Message);
      ReadLn;
    end;
  end;
end.
