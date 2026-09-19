unit Log4DConfiguratorTests;

interface

uses
  {$IFDEF FPC}
  fpcunit, testregistry,
  {$ELSE}
  TestFramework,
  {$ENDIF}
  Log4D;

type

  { TLogConfiguratorTests }

  TLogConfiguratorTests = class(TTestCase)
  protected
    procedure TearDown; override;
  published
    procedure TestConfigureWithoutAppenderAddsDefaultODSAppender;
    procedure TestConfigureWithAppenderAddsItToRoot;
    procedure TestResetConfigurationRemovesAppenders;
    procedure TestPropertyConfiguratorSetsRootLevelAndAppender;
    procedure TestStrToBoolRecognisesTrueValues;
    procedure TestStrToBoolRecognisesFalseValues;
    procedure TestStrToBoolFallsBackToDefault;
  end;

implementation

uses
  Classes;

{ TLogConfiguratorTests }

procedure TLogConfiguratorTests.TearDown;
begin
  TLogBasicConfigurator.ResetConfiguration;
end;

procedure TLogConfiguratorTests.TestConfigureWithoutAppenderAddsDefaultODSAppender;
begin
  TLogBasicConfigurator.Configure;
  CheckEquals(1, TLogLogger.GetRootLogger.Appenders.Count);
  CheckNotNull(TLogLogger.GetRootLogger.GetAppender('ODS'));
end;

procedure TLogConfiguratorTests.TestConfigureWithAppenderAddsItToRoot;
var
  Appender: ILogAppender;
begin
  Appender := TLogNullAppender.Create('test-configurator-appender');
  TLogBasicConfigurator.Configure(Appender);
  CheckTrue(TLogLogger.GetRootLogger.IsAppender(Appender));
end;

procedure TLogConfiguratorTests.TestResetConfigurationRemovesAppenders;
begin
  TLogBasicConfigurator.Configure;
  CheckTrue(TLogLogger.GetRootLogger.Appenders.Count > 0);
  TLogBasicConfigurator.ResetConfiguration;
  CheckEquals(0, TLogLogger.GetRootLogger.Appenders.Count);
end;

procedure TLogConfiguratorTests.TestPropertyConfiguratorSetsRootLevelAndAppender;
var
  Props: TStringList;
begin
  Props := TStringList.Create;
  try
    Props.Values[RootLoggerKey] := 'warn,testNullAppender';
    Props.Values[AppenderKey + 'testNullAppender'] := 'TLogNullAppender';
    TLogPropertyConfigurator.Configure(Props);
  finally
    Props.Free;
  end;
  CheckSame(Warn, TLogLogger.GetRootLogger.Level);
  CheckNotNull(TLogLogger.GetRootLogger.GetAppender('testNullAppender'));
end;

procedure TLogConfiguratorTests.TestStrToBoolRecognisesTrueValues;
begin
  CheckTrue(StrToBool('true', False));
  CheckTrue(StrToBool('True', False));
  CheckTrue(StrToBool('yes', False));
end;

procedure TLogConfiguratorTests.TestStrToBoolRecognisesFalseValues;
begin
  CheckFalse(StrToBool('false', True));
  CheckFalse(StrToBool('False', True));
  CheckFalse(StrToBool('no', True));
end;

procedure TLogConfiguratorTests.TestStrToBoolFallsBackToDefault;
begin
  CheckTrue(StrToBool('not-a-boolean', True));
  CheckFalse(StrToBool('not-a-boolean', False));
end;

initialization
  RegisterTest(TLogConfiguratorTests);

end.
