unit Log4DFilterTests;

interface

uses
  {$IFDEF FPC}
  fpcunit, testregistry,
  {$ELSE}
  TestFramework,
  {$ENDIF}
  Log4D;

type

  { TLogFilterTests }

  TLogFilterTests = class(TTestCase)
  private
    FLogger: TLogLogger;
    function MakeEvent(const LogLevel: TLogLevel; const Message: string): TLogEvent;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestDenyAllFilterAlwaysDenies;
    procedure TestLevelMatchFilterAccepts;
    procedure TestLevelMatchFilterIsNeutralOnMismatch;
    procedure TestLevelMatchFilterCanDeny;
    procedure TestLevelRangeFilterAcceptsWithinRange;
    procedure TestLevelRangeFilterIsNeutralOutsideRange;
    procedure TestStringFilterAcceptsOnSubstring;
    procedure TestStringFilterIsNeutralWithoutMatch;
    procedure TestStringFilterIsCaseSensitiveByDefault;
    procedure TestStringFilterIgnoreCase;
  end;

implementation

{ TLogFilterTests }

procedure TLogFilterTests.SetUp;
begin
  FLogger := TLogLogger.Create('test.filter.logger');
end;

procedure TLogFilterTests.TearDown;
begin
  FLogger.Free;
end;

function TLogFilterTests.MakeEvent(const LogLevel: TLogLevel;
  const Message: string): TLogEvent;
begin
  Result := TLogEvent.Create(FLogger, LogLevel, Message, nil);
end;

procedure TLogFilterTests.TestDenyAllFilterAlwaysDenies;
var
  Filter: TLogDenyAllFilter;
  Event: TLogEvent;
begin
  Filter := TLogDenyAllFilter.Create;
  Event  := MakeEvent(Fatal, 'msg');
  try
    CheckTrue(fdDeny = Filter.Decide(Event));
  finally
    Event.Free;
    Filter.Free;
  end;
end;

procedure TLogFilterTests.TestLevelMatchFilterAccepts;
var
  Filter: TLogLevelMatchFilter;
  Event: TLogEvent;
begin
  Filter := TLogLevelMatchFilter.Create(Warn);
  Event  := MakeEvent(Warn, 'msg');
  try
    CheckTrue(fdAccept = Filter.Decide(Event));
  finally
    Event.Free;
    Filter.Free;
  end;
end;

procedure TLogFilterTests.TestLevelMatchFilterIsNeutralOnMismatch;
var
  Filter: TLogLevelMatchFilter;
  Event: TLogEvent;
begin
  Filter := TLogLevelMatchFilter.Create(Warn);
  Event  := MakeEvent(Info, 'msg');
  try
    CheckTrue(fdNeutral = Filter.Decide(Event));
  finally
    Event.Free;
    Filter.Free;
  end;
end;

procedure TLogFilterTests.TestLevelMatchFilterCanDeny;
var
  Filter: TLogLevelMatchFilter;
  Event: TLogEvent;
begin
  Filter := TLogLevelMatchFilter.Create(Warn, False);
  Event  := MakeEvent(Warn, 'msg');
  try
    CheckTrue(fdDeny = Filter.Decide(Event));
  finally
    Event.Free;
    Filter.Free;
  end;
end;

procedure TLogFilterTests.TestLevelRangeFilterAcceptsWithinRange;
var
  Filter: TLogLevelRangeFilter;
  Event: TLogEvent;
begin
  Filter := TLogLevelRangeFilter.Create(Fatal, Warn);
  Event  := MakeEvent(Error, 'msg');
  try
    CheckTrue(fdAccept = Filter.Decide(Event));
  finally
    Event.Free;
    Filter.Free;
  end;
end;

procedure TLogFilterTests.TestLevelRangeFilterIsNeutralOutsideRange;
var
  Filter: TLogLevelRangeFilter;
  Event: TLogEvent;
begin
  Filter := TLogLevelRangeFilter.Create(Fatal, Warn);
  Event  := MakeEvent(Info, 'msg');
  try
    CheckTrue(fdNeutral = Filter.Decide(Event));
  finally
    Event.Free;
    Filter.Free;
  end;
end;

procedure TLogFilterTests.TestStringFilterAcceptsOnSubstring;
var
  Filter: TLogStringFilter;
  Event: TLogEvent;
begin
  Filter := TLogStringFilter.Create('needle');
  Event  := MakeEvent(Info, 'a needle in a haystack');
  try
    CheckTrue(fdAccept = Filter.Decide(Event));
  finally
    Event.Free;
    Filter.Free;
  end;
end;

procedure TLogFilterTests.TestStringFilterIsNeutralWithoutMatch;
var
  Filter: TLogStringFilter;
  Event: TLogEvent;
begin
  Filter := TLogStringFilter.Create('needle');
  Event  := MakeEvent(Info, 'nothing to see here');
  try
    CheckTrue(fdNeutral = Filter.Decide(Event));
  finally
    Event.Free;
    Filter.Free;
  end;
end;

procedure TLogFilterTests.TestStringFilterIsCaseSensitiveByDefault;
var
  Filter: TLogStringFilter;
  Event: TLogEvent;
begin
  Filter := TLogStringFilter.Create('Needle');
  Event  := MakeEvent(Info, 'a needle in a haystack');
  try
    CheckTrue(fdNeutral = Filter.Decide(Event));
  finally
    Event.Free;
    Filter.Free;
  end;
end;

procedure TLogFilterTests.TestStringFilterIgnoreCase;
var
  Filter: TLogStringFilter;
  Event: TLogEvent;
begin
  Filter := TLogStringFilter.Create('Needle', True);
  Event  := MakeEvent(Info, 'a needle in a haystack');
  try
    CheckTrue(fdAccept = Filter.Decide(Event));
  finally
    Event.Free;
    Filter.Free;
  end;
end;

initialization
  RegisterTest(TLogFilterTests);

end.
