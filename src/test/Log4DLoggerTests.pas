unit Log4DLoggerTests;

interface

uses
  {$IFDEF FPC}
  fpcunit, testregistry,
  {$ELSE}
  TestFramework,
  {$ENDIF}
  Log4D;

type

  { TLogLoggerTests }

  TLogLoggerTests = class(TTestCase)
  protected
    procedure TearDown; override;
  published
    procedure TestGetLoggerReturnsSameInstance;
    procedure TestChildLoggerHasDottedParent;
    procedure TestTopLevelLoggerHasRootAsParent;
    procedure TestChildInheritsParentLevel;
    procedure TestExplicitLevelOverridesParent;
    procedure TestIsEnabledForRespectsLevel;
    procedure TestAdditiveDefaultsToTrue;
    procedure TestAddAndRemoveAppender;
  end;

implementation

{ TLogLoggerTests }

procedure TLogLoggerTests.TearDown;
begin
  TLogBasicConfigurator.ResetConfiguration;
end;

procedure TLogLoggerTests.TestGetLoggerReturnsSameInstance;
begin
  CheckSame(TLogLogger.GetLogger('test.logger.same'),
    TLogLogger.GetLogger('test.logger.same'));
end;

procedure TLogLoggerTests.TestChildLoggerHasDottedParent;
var
  Parent, Child: TLogLogger;
begin
  Parent := TLogLogger.GetLogger('test.logger.parent');
  Child  := TLogLogger.GetLogger('test.logger.parent.child');
  CheckSame(Parent, Child.Parent);
end;

procedure TLogLoggerTests.TestTopLevelLoggerHasRootAsParent;
var
  Logger: TLogLogger;
begin
  Logger := TLogLogger.GetLogger('test-logger-top-level');
  CheckSame(TLogLogger.GetRootLogger, Logger.Parent);
end;

procedure TLogLoggerTests.TestChildInheritsParentLevel;
var
  Parent, Child: TLogLogger;
begin
  Parent := TLogLogger.GetLogger('test.logger.levels');
  Child  := TLogLogger.GetLogger('test.logger.levels.child');
  Parent.Level := Warn;
  CheckSame(Warn, Child.Level);
end;

procedure TLogLoggerTests.TestExplicitLevelOverridesParent;
var
  Parent, Child: TLogLogger;
begin
  Parent := TLogLogger.GetLogger('test.logger.levels2');
  Child  := TLogLogger.GetLogger('test.logger.levels2.child');
  Parent.Level := Warn;
  Child.Level  := Debug;
  CheckSame(Debug, Child.Level);
  CheckSame(Warn, Parent.Level);
end;

procedure TLogLoggerTests.TestIsEnabledForRespectsLevel;
var
  Logger: TLogLogger;
begin
  Logger := TLogLogger.GetLogger('test.logger.enabled');
  Logger.Level := Warn;
  CheckTrue(Logger.IsEnabledFor(Error), 'Error should be enabled at Warn level');
  CheckFalse(Logger.IsEnabledFor(Info), 'Info should not be enabled at Warn level');
end;

procedure TLogLoggerTests.TestAdditiveDefaultsToTrue;
var
  Logger: TLogLogger;
begin
  Logger := TLogLogger.GetLogger('test.logger.additive');
  CheckTrue(Logger.Additive, 'loggers should be additive by default');
end;

procedure TLogLoggerTests.TestAddAndRemoveAppender;
var
  Logger: TLogLogger;
  Appender: ILogAppender;
begin
  Logger   := TLogLogger.GetLogger('test.logger.appenders');
  Appender := TLogNullAppender.Create('test-null-appender');
  Logger.AddAppender(Appender);
  try
    CheckTrue(Logger.IsAppender(Appender), 'appender should be attached');
    CheckTrue(Appender = Logger.GetAppender('test-null-appender'),
      'GetAppender should return the attached instance');
    CheckEquals(1, Logger.Appenders.Count);
  finally
    Logger.RemoveAppender(Appender);
  end;
  CheckFalse(Logger.IsAppender(Appender), 'appender should have been removed');
  CheckEquals(0, Logger.Appenders.Count);
end;

initialization
  RegisterTest(TLogLoggerTests);

end.
