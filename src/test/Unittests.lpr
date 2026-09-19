program Unittests;

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  Interfaces, Forms, GuiTestRunner, consoletestrunner,
  fpcunit, testregistry,
  Log4D in '..\main\Log4D.pas',
  Log4DLevelTests in 'Log4DLevelTests.pas',
  Log4DEventTests in 'Log4DEventTests.pas',
  Log4DLoggerTests in 'Log4DLoggerTests.pas',
  Log4DPatternLayoutTests in 'Log4DPatternLayoutTests.pas',
  Log4DFilterTests in 'Log4DFilterTests.pas',
  Log4DFileAppenderTests in 'Log4DFileAppenderTests.pas',
  Log4DConfiguratorTests in 'Log4DConfiguratorTests.pas';

{$R *.res}

begin
  { The individual test units register themselves with the global test
    registry (via RegisterTest in their initialization sections), so the
    only thing left to decide here is which runner to use.

    Console Test Runner: headless, for scripted / CI runs, e.g.
    `UnittestsConsole --all --format=plain`. Exit code has bit 0 set on
    failures and bit 1 set on errors, so scripts and CI can detect a red
    run from the process exit status. See UNIT-TESTS.md. }
  if ParamCount > 0 then
  begin
    consoletestrunner.TTestRunner.Create(nil).Run;
  end
  else
  begin
    Application.Initialize;
    Application.CreateForm(TGuiTestRunner, TestRunner);
    TestRunner.Caption := 'Log4D FPCUnit tests';
    Application.Run;
  end;
end.
