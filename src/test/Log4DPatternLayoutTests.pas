unit Log4DPatternLayoutTests;

interface

uses
  {$IFDEF FPC}
  fpcunit, testregistry,
  {$ELSE}
  TestFramework,
  {$ENDIF}
  Log4D;

type

  { TLogPatternLayoutTests }

  TLogPatternLayoutTests = class(TTestCase)
  private
    FLogger: TLogLogger;
    FEvent: TLogEvent;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestMessagePattern;
    procedure TestLevelPattern;
    procedure TestLoggerNamePattern;
    procedure TestLiteralPercent;
    procedure TestNewLine;
    procedure TestCombinedPatternWithStaticText;
    procedure TestDefaultPattern;
  end;

implementation

{ TLogPatternLayoutTests }

procedure TLogPatternLayoutTests.SetUp;
begin
  FLogger := TLogLogger.Create('test.pattern.logger');
  FEvent  := TLogEvent.Create(FLogger, Warn, 'the message', nil);
end;

procedure TLogPatternLayoutTests.TearDown;
begin
  FEvent.Free;
  FLogger.Free;
end;

procedure TLogPatternLayoutTests.TestMessagePattern;
var
  Layout: TLogPatternLayout;
begin
  Layout := TLogPatternLayout.Create('%m');
  try
    CheckEquals('the message', Layout.Format(FEvent));
  finally
    Layout.Free;
  end;
end;

procedure TLogPatternLayoutTests.TestLevelPattern;
var
  Layout: TLogPatternLayout;
begin
  Layout := TLogPatternLayout.Create('%p');
  try
    CheckEquals('warn', Layout.Format(FEvent));
  finally
    Layout.Free;
  end;
end;

procedure TLogPatternLayoutTests.TestLoggerNamePattern;
var
  Layout: TLogPatternLayout;
begin
  Layout := TLogPatternLayout.Create('%c');
  try
    CheckEquals('test.pattern.logger', Layout.Format(FEvent));
  finally
    Layout.Free;
  end;
end;

procedure TLogPatternLayoutTests.TestLiteralPercent;
var
  Layout: TLogPatternLayout;
begin
  Layout := TLogPatternLayout.Create('100%%');
  try
    CheckEquals('100%', Layout.Format(FEvent));
  finally
    Layout.Free;
  end;
end;

procedure TLogPatternLayoutTests.TestNewLine;
var
  Layout: TLogPatternLayout;
begin
  Layout := TLogPatternLayout.Create('%n');
  try
    CheckEquals(#13#10, Layout.Format(FEvent));
  finally
    Layout.Free;
  end;
end;

procedure TLogPatternLayoutTests.TestCombinedPatternWithStaticText;
var
  Layout: TLogPatternLayout;
begin
  Layout := TLogPatternLayout.Create('[%p] %c - %m');
  try
    CheckEquals('[warn] test.pattern.logger - the message', Layout.Format(FEvent));
  finally
    Layout.Free;
  end;
end;

procedure TLogPatternLayoutTests.TestDefaultPattern;
var
  Layout: TLogPatternLayout;
begin
  Layout := TLogPatternLayout.Create;
  try
    CheckEquals(DefaultPattern, Layout.Pattern);
    CheckEquals('the message' + #13#10, Layout.Format(FEvent));
  finally
    Layout.Free;
  end;
end;

initialization
  RegisterTest(TLogPatternLayoutTests);

end.
