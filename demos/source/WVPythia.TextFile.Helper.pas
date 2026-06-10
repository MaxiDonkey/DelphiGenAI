unit WVPythia.TextFile.Helper;

interface

uses
  System.SysUtils, System.Classes, System.IOUtils;

type
  TFileIOHelper = record
    class function LoadFromFile(const FileName: string): string; static;
    class procedure SaveToFile(
      const Filename, Content: string;
      const WriteBOM: Boolean = True); static;

    class function GetFileNames(
      const DirectoryName: string;
      const SearchPattern: string = '*.*';
      const Recursive: Boolean = False): TArray<string>; static;
    class function RemoveExtensions(
      const FileNames: TArray<string>): TArray<string>; static;
    class function RemoveExtensionsAsJsonstring(
      const FileNames: TArray<string>): TArray<string>; static;
  end;

implementation

{ TFileIOHelper }

class function TFileIOHelper.GetFileNames(const DirectoryName,
  SearchPattern: string; const Recursive: Boolean): TArray<string>;
var
  SearchOption: TSearchOption;
begin
  if not TDirectory.Exists(DirectoryName) then
    raise Exception.CreateFmt('Directory not found: %s', [DirectoryName]);

  if Recursive then
    SearchOption := TSearchOption.soAllDirectories
  else
    SearchOption := TSearchOption.soTopDirectoryOnly;

  var Files := TDirectory.GetFiles(DirectoryName, SearchPattern, SearchOption);

  SetLength(Result, Length(Files));
  for var I := 0 to High(Files) do
    Result[I] := TPath.GetFileName(Files[I]);
end;

class function TFileIOHelper.LoadFromFile(const FileName: string): string;
begin
  if TFile.Exists(FileName) then
    Exit(TFile.ReadAllText(FileName, TEncoding.UTF8));

  raise Exception.CreateFmt('The template file was not found : %s', [FileName]);
end;

class function TFileIOHelper.RemoveExtensions(
  const FileNames: TArray<string>): TArray<string>;
begin
  SetLength(Result, Length(FileNames));
  for var I := 0 to High(FileNames) do
    Result[I] := TPath.GetFileNameWithoutExtension(FileNames[I]);
end;

class function TFileIOHelper.RemoveExtensionsAsJsonstring(
  const FileNames: TArray<string>): TArray<string>;
begin
  SetLength(Result, Length(FileNames));
  for var I := 0 to High(FileNames) do
    Result[I] := '"' + TPath.GetFileNameWithoutExtension(FileNames[I]) + '"';
end;

class procedure TFileIOHelper.SaveToFile(
  const Filename, Content: string;
  const WriteBOM: Boolean);
begin
  var FullPath := TPath.GetDirectoryName(FileName);
  if (FullPath <> '') and not TDirectory.Exists(FullPath) then
    TDirectory.CreateDirectory(FullPath);

  var Utf8Encoding := TUTF8Encoding.Create(WriteBOM);
  try
    TFile.WriteAllText(FileName, Content, Utf8Encoding);
  finally
    Utf8Encoding.Free;
  end;
end;

end.
