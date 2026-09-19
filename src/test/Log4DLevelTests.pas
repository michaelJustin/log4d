unit Log4DLevelTests;

interface

uses
  {$IFDEF FPC}
  fpcunit, testregistry
  {$ELSE}
  TestFramework
  {$ENDIF};

type

  { TLogLevelTests }

  TLogLevelTests = class(TTestCase)
  published
    procedure TestStandardLevelsAreOrdered;
    procedure TestIsGreaterOrEqual;
    procedure TestGetLevelByName;
    procedure TestGetLevelByNameUnknownReturnsDefault;
    procedure TestGetLevelByValue;
    procedure TestGetLevelByValueUnknownReturnsDefault;
    procedure TestCreateCustomLevel;
  end;

implementation

uses
  Log4D;

{ TLogLevelTests }

procedure TLogLevelTests.TestStandardLevelsAreOrdered;
begin
  CheckTrue(All.Level < Trace.Level, 'All < Trace');
  CheckTrue(Trace.Level < Debug.Level, 'Trace < Debug');
  CheckTrue(Debug.Level < Info.Level, 'Debug < Info');
  CheckTrue(Info.Level < Warn.Level, 'Info < Warn');
  CheckTrue(Warn.Level < Error.Level, 'Warn < Error');
  CheckTrue(Error.Level < Fatal.Level, 'Error < Fatal');
  CheckTrue(Fatal.Level < Off.Level, 'Fatal < Off');
end;

procedure TLogLevelTests.TestIsGreaterOrEqual;
begin
  CheckTrue(Warn.IsGreaterOrEqual(Info), 'Warn should be >= Info');
  CheckTrue(Warn.IsGreaterOrEqual(Warn), 'Warn should be >= Warn');
  CheckFalse(Info.IsGreaterOrEqual(Warn), 'Info should not be >= Warn');
end;

procedure TLogLevelTests.TestGetLevelByName;
begin
  CheckSame(Warn, TLogLevel.GetLevel('warn'));
  CheckSame(Fatal, TLogLevel.GetLevel('fatal'));
end;

procedure TLogLevelTests.TestGetLevelByNameUnknownReturnsDefault;
begin
  CheckSame(Fatal, TLogLevel.GetLevel('not-a-level', Fatal));
end;

procedure TLogLevelTests.TestGetLevelByValue;
begin
  CheckSame(Warn, TLogLevel.GetLevel(WarnValue));
  CheckSame(Error, TLogLevel.GetLevel(ErrorValue));
end;

procedure TLogLevelTests.TestGetLevelByValueUnknownReturnsDefault;
begin
  CheckSame(Fatal, TLogLevel.GetLevel(12345, Fatal));
end;

procedure TLogLevelTests.TestCreateCustomLevel;
var
  Custom: TLogLevel;
begin
  { TLogLevel.Create registers the level in the global level list, which
    owns and frees it at unit finalization - it must not be freed here. }
  Custom := TLogLevel.Create('notice', (InfoValue + WarnValue) div 2);
  CheckEquals('notice', Custom.Name);
  CheckTrue(Custom.IsGreaterOrEqual(Info), 'Custom should be >= Info');
  CheckFalse(Custom.IsGreaterOrEqual(Warn), 'Custom should not be >= Warn');
end;

initialization
  RegisterTest(TLogLevelTests);

end.
