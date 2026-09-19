# Changelog

All notable changes to Log4D are documented here.

This project doesn't follow semantic versioning in the usual sense — the
library version (`Log4DVersion` in [`src/main/Log4D.pas`](src/main/Log4D.pas))
has stayed at `1.2.12` since it was imported from the original SourceForge
trunk, so releases are tagged and dated instead of version-bumped.

## [Unreleased]

### Added
- `%r` pattern support for logging elapsed time (a97f04c)

### Fixed
- Corrected casing of the `SyncObjs`/`syncobjs` unit reference for
  case-sensitive Linux builds (f11fc02, cb1e63f)
- Linux CI: install `fp-units-rtl`, `fp-units-fcl` and `fp-units-base` so
  `SyncObjs` resolves under FPC — fixes
  [#17](https://github.com/michaelJustin/log4d/issues/17) (8673e91)
- `ThreadedLoggingApp` example: fixed a thread hang by disabling
  `FreeOnTerminate` and freeing threads after `WaitFor` instead of polling
  (e3b041c, 4fd9a84)

### Changed
- Refactored log file creation in `TLogFileAppender.SetLogFile`
  ([#23](https://github.com/michaelJustin/log4d/pull/23))
- Removed the `HAS_UNIT_CONTNRS` conditional define and its usage
  ([#21](https://github.com/michaelJustin/log4d/pull/21))
- Added a GitHub Actions workflow that compiles and runs `ConsoleApp` with
  FPC on Linux
- Added a Lazarus `.lpi` project file

## [v1.2.12-20260607] - 2026-06-07

"Fixes for Free Pascal"

- Added an FPC/Lazarus `ConsoleApp` example and a CI workflow to compile it
- Iterated the CI workflow: moved from a Windows/Lazarus runner to Ubuntu
  with FPC 3.2.2, fixing compiler flags, unit search paths, and
  badge/artifact wiring along the way
- Renamed `src/Log4D.pas` to `src/main/Log4D.pas`

## [v1.2.12-20260517] - 2026-05-17

- Updated MPL 1.1 license headers
- Updated `Defines.inc`
- General README maintenance

## Earlier history

Before these tags, notable changes (also recorded in the `Log4D.pas` file
header) included:

- Added resource protection (`try..finally`) in
  `TLogFileAppender.SetLogFile`
- Used `const` on string arguments; added overloads with
  `(const Fmt: string; const Args: array of const; const Err: Exception = nil)`
- Replaced `fmShareDenyWrite` with `fmShareDenyNone` for concurrent logging
- Removed the dependency on `jedi.inc`/`Defines.inc`, replaced with
  `{$IF}/{$IFEND}` blocks
- Imported from the original SourceForge trunk (Keith Wood, log4j-based,
  v1.2.12, 2009), with later fixes for Free Pascal and newer Delphi versions
  up to XE6 and 10 Seattle
