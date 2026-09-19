# Building and running the unit tests

The tests live in [`src/test/`](src/test/) alongside the `Unittests.lpi`
Lazarus project. They use [FPCUnit](https://www.freepascal.org/docs-html/fcl/fpcunit/index.html)
and are written against `{$IFDEF FPC} fpcunit, testregistry {$ELSE}
TestFramework {$ENDIF}`, so the test units themselves are portable to
Delphi/DUnit, but there is currently no `Unittests.dpr`/`.dproj` to build
them under Delphi - only the FPC/Lazarus project exists for now.

## Free Pascal / Lazarus

From `src/test/`:

```
C:\lazarus\lazbuild.exe -B Unittests.lpi
Unittests.exe
```

This opens the FPCUnit **GUI** test runner (`TGuiTestRunner`) - needs an
interactive desktop.

For a headless run, build the **Console** build mode instead, which produces
a separate console-subsystem executable, and pass it any argument (e.g.
`--all --format=plain`) so it dispatches to the FPCUnit **console** runner
instead of the GUI one:

```
C:\lazarus\lazbuild.exe -B --build-mode=Console Unittests.lpi
UnittestsConsole.exe --all --format=plain
```

The exit code has bit 0 set on failures and bit 1 set on errors (FPCUnit's
`TProgressWriter.GetExitCode`), so scripts/CI can detect a red run from the
process exit status alone. `Unittests.lpr` picks GUI vs. console at runtime
via `ParamCount > 0`, so running `UnittestsConsole.exe` with no arguments
still opens the GUI.

`lazbuild` is not on `PATH` by default on Windows; call it by full path,
e.g. `C:\lazarus\lazbuild.exe`. On Linux, install it from the distribution's
package repository (e.g. `apt-get install lazarus libgtk2.0-dev`) and run
the console build under `xvfb-run`, since the LCL's `Interfaces` unit opens
a display even for a console-subsystem build:

```
xvfb-run --auto-servernum ./UnittestsConsole --all --format=plain
```

## Running a subset

- Console runner: `--suite=<TestCaseClass>` (e.g. `--suite=TLogLevelTests`),
  or `--list` to see the registered suite/test names.
- GUI runner: pick the suite/test in the tree and run it manually.

## What each test file covers

- `Log4DLevelTests.pas` - `TLogLevel` ordering, `IsGreaterOrEqual`, lookup
  by name/value, and creating custom levels.
- `Log4DEventTests.pas` - `TLogEvent` construction: message, level, logger
  name, elapsed time, and exception info with/without an attached error.
- `Log4DLoggerTests.pas` - `TLogLogger`/`TLogHierarchy`: logger identity and
  caching, dotted-name parent/child resolution, level inheritance,
  `IsEnabledFor`, additivity, and attaching/removing appenders.
- `Log4DPatternLayoutTests.pas` - `TLogPatternLayout` conversion patterns
  (`%m`, `%p`, `%c`, `%n`, `%%`, combinations, and the default pattern).
- `Log4DFilterTests.pas` - `TLogDenyAllFilter`, `TLogLevelMatchFilter`,
  `TLogLevelRangeFilter`, and `TLogStringFilter` (including case
  sensitivity).
- `Log4DFileAppenderTests.pas` - `TLogFileAppender`: file creation, append
  vs. overwrite semantics, and creating missing parent directories.
- `Log4DConfiguratorTests.pas` - `TLogBasicConfigurator` (default/explicit
  appender, `ResetConfiguration`), `TLogPropertyConfigurator` (parsing a
  root logger definition from a property list), and the `StrToBool` helper.

## Notes

- Tests that touch the process-wide `DefaultHierarchy` (loggers,
  configurators) use unique, test-specific logger names and call
  `TLogBasicConfigurator.ResetConfiguration` in `TearDown`, since loggers
  created via `TLogLogger.GetLogger` are cached for the lifetime of the
  process and shared across all test cases in the same run.
- `TLogLevel.Create` registers the new level in a global, owned list that is
  freed at unit finalization - do not free a `TLogLevel` instance yourself.
- The project is built with heap tracing (`-gh`/`UseHeaptrc`), so a run
  prints a heap dump to the console on exit; check it for unfreed blocks
  beyond the runner's own (harmless) top-level allocations.

## Continuous integration

See [issue #25](https://github.com/michaelJustin/log4d/issues/25) for
adding a `.github/workflows/tests.yml` that builds the **Console** mode
headless and runs it on both `windows-latest` and `ubuntu-latest`.
