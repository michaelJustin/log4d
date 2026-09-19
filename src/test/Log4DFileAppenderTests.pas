unit Log4DFileAppenderTests;

interface

uses
  {$IFDEF FPC}
  fpcunit, testregistry,
  {$ELSE}
  TestFramework,
  {$ENDIF}
  Log4D;

type

  { TLogFileAppenderTests }

  TLogFileAppenderTests = class(TTestCase)
  private
    FLogger: TLogLogger;
    FTestDir: string;
    FLogFile: string;
    function ReadFileContent(const FileName: string): string;
    procedure WriteFileContent(const FileName, Content: string);
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestAppendingCreatesTheFile;
    procedure TestFileNameProperty;
    procedure TestAppendKeepsExistingContent;
    procedure TestNoAppendTruncatesExistingContent;
    procedure TestCreatesMissingDirectory;
  end;

implementation

uses
  SysUtils, Classes;

{ TLogFileAppenderTests }

var
  TestDirCounter: Integer;

procedure TLogFileAppenderTests.SetUp;
begin
  Inc(TestDirCounter);
  FLogger  := TLogLogger.Create('test.fileappender.logger');
  FTestDir := IncludeTrailingPathDelimiter(GetTempDir) +
    'log4d-test-' + IntToStr(TestDirCounter) + '-' + IntToStr(Random(MaxInt));
  ForceDirectories(FTestDir);
  FLogFile := IncludeTrailingPathDelimiter(FTestDir) + 'test.log';
end;

procedure TLogFileAppenderTests.TearDown;
begin
  FLogger.Free;
  if FileExists(FLogFile) then
    DeleteFile(FLogFile);
  if DirectoryExists(FTestDir) then
    RemoveDir(FTestDir);
end;

function TLogFileAppenderTests.ReadFileContent(const FileName: string): string;
var
  Stream: TFileStream;
begin
  Stream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyNone);
  try
    SetLength(Result, Stream.Size);
    if Stream.Size > 0 then
      Stream.ReadBuffer(Result[1], Stream.Size);
  finally
    Stream.Free;
  end;
end;

procedure TLogFileAppenderTests.WriteFileContent(const FileName, Content: string);
var
  Stream: TFileStream;
begin
  Stream := TFileStream.Create(FileName, fmCreate);
  try
    if Length(Content) > 0 then
      Stream.WriteBuffer(Content[1], Length(Content));
  finally
    Stream.Free;
  end;
end;

procedure TLogFileAppenderTests.TestAppendingCreatesTheFile;
var
  Appender: TLogFileAppender;
  Event: TLogEvent;
begin
  Appender := TLogFileAppender.Create('test-file-appender', FLogFile,
    TLogSimpleLayout.Create);
  try
    Event := TLogEvent.Create(FLogger, Info, 'hello file', nil);
    try
      Appender.Append(Event);
    finally
      Event.Free;
    end;
  finally
    Appender.Free;
  end;
  CheckTrue(FileExists(FLogFile), 'log file should have been created');
  CheckTrue(Pos('hello file', ReadFileContent(FLogFile)) > 0,
    'log file should contain the appended message');
end;

procedure TLogFileAppenderTests.TestFileNameProperty;
var
  Appender: TLogFileAppender;
begin
  Appender := TLogFileAppender.Create('test-file-appender', FLogFile,
    TLogSimpleLayout.Create);
  try
    CheckEquals(FLogFile, Appender.FileName);
  finally
    Appender.Free;
  end;
end;

procedure TLogFileAppenderTests.TestAppendKeepsExistingContent;
var
  Appender: TLogFileAppender;
  Event: TLogEvent;
begin
  WriteFileContent(FLogFile, 'PREVIOUS-LINE'#13#10);
  Appender := TLogFileAppender.Create('test-file-appender', FLogFile,
    TLogSimpleLayout.Create, True { Append });
  try
    Event := TLogEvent.Create(FLogger, Info, 'new line', nil);
    try
      Appender.Append(Event);
    finally
      Event.Free;
    end;
  finally
    Appender.Free;
  end;
  CheckTrue(Pos('PREVIOUS-LINE', ReadFileContent(FLogFile)) > 0,
    'previous content should still be present when appending');
end;

procedure TLogFileAppenderTests.TestNoAppendTruncatesExistingContent;
var
  Appender: TLogFileAppender;
  Event: TLogEvent;
begin
  WriteFileContent(FLogFile, 'PREVIOUS-LINE'#13#10);
  Appender := TLogFileAppender.Create('test-file-appender', FLogFile,
    TLogSimpleLayout.Create, False { Append });
  try
    Event := TLogEvent.Create(FLogger, Info, 'new line', nil);
    try
      Appender.Append(Event);
    finally
      Event.Free;
    end;
  finally
    Appender.Free;
  end;
  CheckEquals(0, Pos('PREVIOUS-LINE', ReadFileContent(FLogFile)),
    'previous content should be gone when not appending');
end;

procedure TLogFileAppenderTests.TestCreatesMissingDirectory;
var
  NestedFile: string;
  Appender: TLogFileAppender;
begin
  NestedFile := IncludeTrailingPathDelimiter(FTestDir) + 'nested' +
    PathDelim + 'test.log';
  Appender := TLogFileAppender.Create('test-file-appender', NestedFile,
    TLogSimpleLayout.Create);
  try
    CheckTrue(FileExists(NestedFile), 'appender should create missing directories');
  finally
    Appender.Free;
  end;
  DeleteFile(NestedFile);
  RemoveDir(ExtractFileDir(NestedFile));
end;

initialization
  RegisterTest(TLogFileAppenderTests);

end.
