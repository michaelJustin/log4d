unit Log4DEventTests;

interface

uses
  {$IFDEF FPC}
  fpcunit, testregistry,
  {$ELSE}
  TestFramework,
  {$ENDIF}
  Log4D;

type

  { TLogEventTests }

  TLogEventTests = class(TTestCase)
  private
    FLogger: TLogLogger;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestMessageAndLevel;
    procedure TestLoggerName;
    procedure TestNoException;
    procedure TestExceptionInfo;
    procedure TestExplicitTimeStamp;
    procedure TestElapsedTimeIsNonNegative;
  end;

implementation

uses
  SysUtils;

{ TLogEventTests }

procedure TLogEventTests.SetUp;
begin
  FLogger := TLogLogger.Create('test.event');
end;

procedure TLogEventTests.TearDown;
begin
  FLogger.Free;
end;

procedure TLogEventTests.TestMessageAndLevel;
var
  Event: TLogEvent;
begin
  Event := TLogEvent.Create(FLogger, Warn, 'hello world', nil);
  try
    CheckEquals('hello world', Event.Message);
    CheckSame(Warn, Event.Level);
  finally
    Event.Free;
  end;
end;

procedure TLogEventTests.TestLoggerName;
var
  Event: TLogEvent;
begin
  Event := TLogEvent.Create(FLogger, Info, 'msg', nil);
  try
    CheckEquals('test.event', Event.LoggerName);
  finally
    Event.Free;
  end;
end;

procedure TLogEventTests.TestNoException;
var
  Event: TLogEvent;
begin
  Event := TLogEvent.Create(FLogger, Info, 'msg', nil);
  try
    CheckEquals('', Event.ErrorClass);
    CheckEquals('', Event.ErrorMessage);
  finally
    Event.Free;
  end;
end;

procedure TLogEventTests.TestExceptionInfo;
var
  Event: TLogEvent;
  Err: Exception;
begin
  Err := Exception.Create('boom');
  try
    Event := TLogEvent.Create(FLogger, Error, 'msg', Err);
    try
      CheckEquals('Exception', Event.ErrorClass);
      CheckEquals('boom (Exception)', Event.ErrorMessage);
    finally
      Event.Free;
    end;
  finally
    Err.Free;
  end;
end;

procedure TLogEventTests.TestExplicitTimeStamp;
var
  Event: TLogEvent;
  Stamp: TDateTime;
begin
  Stamp := EncodeDate(2020, 1, 1);
  Event := TLogEvent.Create(FLogger, Info, 'msg', nil, Stamp);
  try
    CheckEquals(Stamp, Event.TimeStamp, 0);
  finally
    Event.Free;
  end;
end;

procedure TLogEventTests.TestElapsedTimeIsNonNegative;
var
  Event: TLogEvent;
begin
  Event := TLogEvent.Create(FLogger, Info, 'msg', nil);
  try
    CheckTrue(Event.ElapsedTime >= 0, 'elapsed time should not be negative');
  finally
    Event.Free;
  end;
end;

initialization
  RegisterTest(TLogEventTests);

end.
