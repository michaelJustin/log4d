*** Begin Patch
*** Update File: src/main/Log4D.pas
@@
   protected
     procedure SetOption(const Name, Value: string); override;
     procedure SetLogFile(const Name: string); virtual;
     procedure CloseLogFile; virtual;
@@
 procedure TLogFileAppender.SetLogFile(const Name: string);
 var
   strPath: string;
   f: TextFile;
 {$IFNDEF LINUX}
   h: THandle;
 {$ENDIF}
 begin
-  CloseLogFile;
-  FFileName := Name;
-  if FAppend and FileExists(FFileName) then
-  begin
-    // append to existing file
-    // use fmShareDenyNone for concurrent logging possibility
-    FStream := TFileStream.Create(FFileName, fmOpenReadWrite or fmShareDenyNone);
-    FStream.Seek(0, soFromEnd);
-  end
-  else
-  begin
-    // Ensure target directory exists
-    strPath := ExtractFileDir(FFileName);
-    if (strPath <> '') and not DirectoryExists(strPath) then
-      ForceDirectories(strPath);
-
-    {$IFNDEF LINUX}
-    // Use Windows CreateFile to create the file with explicit sharing flags.
-    // This avoids SysUtils.FileCreate ignoring sharing flags on some runtimes.
-    h := CreateFile(PChar(FFileName),
-      GENERIC_READ or GENERIC_WRITE,
-      FILE_SHARE_READ or FILE_SHARE_WRITE,
-      nil,
-      CREATE_NEW,
-      FILE_ATTRIBUTE_NORMAL,
-      0);
-    if h = INVALID_HANDLE_VALUE then
-    begin
-      // If the file already exists due to a race, continue; otherwise raise.
-      if GetLastError <> ERROR_FILE_EXISTS then
-        raise ELogException.CreateFmt('Unable to create log file %s. Error: %d', [FFileName, GetLastError]);
-    end
-    else
-      CloseHandle(h);
-    {$ELSE}
-    // Fallback for non-Windows platforms: create the file using AssignFile/ReWrite
-    AssignFile(f, FFileName);
-    try
-      ReWrite(f);
-    finally
-      CloseFile(f);
-    end;
-    {$ENDIF}
-
-    // now open the file using TFileStream with desired sharing mode
-    FStream := TFileStream.Create(FFileName, fmOpenReadWrite or fmShareDenyNone);
-  end;
-  WriteHeader;
+  CloseLogFile;
+  FFileName := Name;
+
+  if FAppend and FileExists(FFileName) then
+  begin
+    // append to existing file
+    FStream := TFileStream.Create(FFileName, fmOpenReadWrite or fmShareDenyNone);
+    FStream.Seek(0, soFromEnd);
+  end
+  else
+  begin
+    // Ensure target directory exists
+    strPath := ExtractFileDir(FFileName);
+    if (strPath <> '') and not DirectoryExists(strPath) then
+      ForceDirectories(strPath);
+
+    {$IFNDEF LINUX}
+    // Use Windows CreateFile to create the file with explicit sharing flags so
+    // the subsequent TFileStream open will respect sharing semantics.
+    h := CreateFile(PChar(FFileName),
+      GENERIC_READ or GENERIC_WRITE,
+      FILE_SHARE_READ or FILE_SHARE_WRITE,
+      nil,
+      CREATE_NEW,
+      FILE_ATTRIBUTE_NORMAL,
+      0);
+    if h = INVALID_HANDLE_VALUE then
+    begin
+      // If the file already exists due to a race, continue; otherwise raise.
+      if GetLastError <> ERROR_FILE_EXISTS then
+        raise ELogException.CreateFmt('Unable to create log file %s. Error: %d', [FFileName, GetLastError]);
+    end
+    else
+      CloseHandle(h);
+    {$ELSE}
+    // Fallback for non-Windows platforms: create the file using AssignFile/ReWrite
+    AssignFile(f, FFileName);
+    try
+      ReWrite(f);
+    finally
+      CloseFile(f);
+    end;
+    {$ENDIF}
+
+    // now open the file using TFileStream with desired sharing mode
+    FStream := TFileStream.Create(FFileName, fmOpenReadWrite or fmShareDenyNone);
+  end;
+
+  WriteHeader;
 end;
*** End Patch
