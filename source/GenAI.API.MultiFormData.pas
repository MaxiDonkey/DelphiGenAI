unit GenAI.API.MultiFormData;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGenAI
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections,
  System.Net.Mime;

type
  TMultiFormDataParams = class(TMultipartFormData)
  private
    FStreams: TObjectList<TStream>;
  protected
    procedure AddFilePart(const FieldName, AbsPath, MultipartFileName: string); overload;
    procedure AddFilePart(const FieldName, AbsPath: string); overload;

    class function ToUrlPath(const Path: string): string; static;
    class function CommonRootDir(const Files: TArray<string>): string; static;
    class function RequireCommonRootDir(const Files: TArray<string>): string; static;
    class procedure RequireRootFile(const RootDir, FileName: string); static;

    procedure AddFilesAsDirectoryTree(const FieldName, RootDir: string;
      const Files: TArray<string>);
  public
    constructor Create; reintroduce;
    destructor Destroy; override;

    /// <summary>
    /// Adds multiple files to the multipart form payload
    /// </summary>
    /// <remarks>
    /// <para>
    /// - When <paramref name="RequireCommonDirectory"/> is <c>True</c>, all file paths in
    /// <paramref name="AFilePaths"/> must share a common root directory.
    /// </para>
    /// <para>
    /// - In this mode, files are sent using a directory-tree layout: the multipart
    /// <c>filename</c> attribute is computed relative to the common root directory
    /// (e.g. <c>my_folder/README.md</c>, <c>my_folder/scripts/tool.py</c>).
    /// </para>
    /// <para>
    /// - When <paramref name="RequireCommonDirectory"/> is <c>False</c>, files are added
    /// individually with their base file names only (flat layout), without preserving
    /// any directory structure.
    /// </para>
    /// <para>
    /// - This option is intended for APIs that require a directory tree representation.
    /// For most multipart uploads, this flag should be set to <c>False</c>.
    /// </para>
    /// </remarks>
    /// <param name="AField">
    /// Multipart form field name (e.g. <c>files[]</c>).
    /// </param>
    /// <param name="AFilePaths">
    /// Absolute or relative file paths to upload.
    /// </param>
    /// <param name="RequireCommonDirectory">
    /// If <c>True</c>, enforces a shared root directory and uploads files as a directory tree.
    /// If <c>False</c>, uploads files as a flat list.
    /// </param>
    procedure AddFiles(const AField: string; const AFilePaths: TArray<string>;
      RequireCommonDirectory: Boolean = False); overload;

    /// <summary>
    /// Adds multiple files to the multipart form payload using an explicit root directory
    /// to preserve a directory-tree layout.
    /// </summary>
    /// <remarks>
    /// <para>
    /// - This overload is intended for APIs that require the multipart <c>filename</c> attribute
    /// to represent a directory tree.
    /// </para>
    /// <para>
    /// - <paramref name="RootDir"/> is treated as the root of the uploaded tree. Each item in
    /// <paramref name="AFilePaths"/> must be located under <paramref name="RootDir"/>; otherwise
    /// an exception is raised.
    /// </para>
    /// <para>
    /// - The multipart <c>filename</c> attribute for each part is computed as:
    /// <c>&lt;TopName&gt;/&lt;RelativePathUnderRootDir&gt;</c>, where <c>TopName</c> is the last
    /// path segment of <paramref name="RootDir"/>, and <c>RelativePathUnderRootDir</c> is the
    /// file path relative to <paramref name="RootDir"/> with directory separators normalized
    /// to <c>'/'</c>.
    /// </para>
    /// <para>
    /// - This overload is useful for partial updates where the root directory is known and
    /// must be preserved in the uploaded paths.
    /// </para>
    /// <para>
    /// - When an empty array is provided, this method does nothing.
    /// </para>
    /// </remarks>
    /// <param name="AField">
    /// Multipart form field name (e.g. <c>files[]</c>).
    /// </param>
    /// <param name="RootDir">
    /// Root directory of the directory tree to upload. Must not be empty.
    /// </param>
    /// <param name="AFilePaths">
    /// Absolute file paths to upload. Each file must reside under <paramref name="RootDir"/>.
    /// </param>
    /// <exception cref="System.SysUtils.Exception">
    /// Raised when <paramref name="RootDir"/> is empty, or when a file in <paramref name="AFilePaths"/>
    /// is outside <paramref name="RootDir"/>.
    /// </exception>
    procedure AddFiles(const AField, RootDir: string; const AFilePaths: TArray<string>); overload;
  end;

implementation

uses
  System.IOUtils;

{ TMultiFormDataParams }

procedure TMultiFormDataParams.AddFilePart(const FieldName, AbsPath: string);
begin
  AddFile(FieldName, AbsPath);
end;

procedure TMultiFormDataParams.AddFiles(const AField: string;
  const AFilePaths: TArray<string>; RequireCommonDirectory: Boolean);
begin
  if Length(AFilePaths) = 0 then
    Exit;

  if RequireCommonDirectory then
    begin
      var Root := RequireCommonRootDir(AFilePaths);
      AddFilesAsDirectoryTree(AField, Root, AFilePaths);
    end
  else
    begin
      for var Item in AFilePaths do
        AddFilePart(AField, Item);
    end;
end;

procedure TMultiFormDataParams.AddFiles(const AField, RootDir: string;
  const AFilePaths: TArray<string>);
begin
  if Length(AFilePaths) = 0 then
    Exit;

  if RootDir.IsEmpty then
    raise Exception.Create('RootDir cannot be empty.');

  AddFilesAsDirectoryTree(AField, RootDir, AFilePaths);
end;

procedure TMultiFormDataParams.AddFilesAsDirectoryTree(const FieldName,
  RootDir: string; const Files: TArray<string>);
begin
  if Length(Files) = 0 then
    Exit;

  var Root := ExcludeTrailingPathDelimiter(RootDir);
  if Root.IsEmpty then
    raise Exception.Create('RootDir cannot be empty.');

  var TopName := ExtractFileName(Root);

  for var Item in Files do
    begin
      if not Item.StartsWith(Root + PathDelim, True) and
         not SameText(Item, Root) then
        raise Exception.Create('File is outside RootDir: ' + Item);

      var Rel := Item.Substring(Length(Root) + 1);
      Rel := ToUrlPath(Rel);
      AddFilePart(FieldName, Item, TopName + '/' + Rel);
    end;
end;

procedure TMultiFormDataParams.AddFilePart(const FieldName, AbsPath,
  MultipartFileName: string);
var
  S: TStream;
begin
  S := TFileStream.Create(AbsPath, fmOpenRead or fmShareDenyWrite);
  FStreams.Add(S);

  {$IF RTLVersion > 35.0}
  AddStream(FieldName, S, False, MultipartFileName);
  {$ELSE}
  AddStream(FieldName, S, MultipartFileName);
  {$ENDIF}
end;

class function TMultiFormDataParams.CommonRootDir(
  const Files: TArray<string>): string;
begin
  if Length(Files) = 0 then
    Exit('');

  var Root := ExcludeTrailingPathDelimiter(ExtractFileDir(Files[0]));

  while not Root.IsEmpty do
    begin
      var Ok := True;

      for var Abs in Files do
        if not Abs.StartsWith(Root + PathDelim, True) and
           not SameText(Abs, Root) then
          begin
            Ok := False;
            Break;
          end;

      if Ok then
        Exit(Root);

      Root := ExcludeTrailingPathDelimiter(ExtractFileDir(Root));
    end;

  Result := '';
end;

constructor TMultiFormDataParams.Create;
begin
  inherited Create(True);
  FStreams := TObjectList<TStream>.Create(True);
end;

destructor TMultiFormDataParams.Destroy;
begin
  FStreams.Free;
  inherited;
end;

class function TMultiFormDataParams.RequireCommonRootDir(
  const Files: TArray<string>): string;
begin
  Result := CommonRootDir(Files);
  if Result.IsEmpty then
    raise Exception.Create('Unable to determine a common root directory.');
end;

class procedure TMultiFormDataParams.RequireRootFile(const RootDir,
  FileName: string);
begin
  if not System.IOUtils.TFile.Exists(System.IOUtils.TPath.Combine(RootDir, FileName)) then
    raise Exception.Create(Format('%s is required at the root of the directory.', [FileName]));
end;

class function TMultiFormDataParams.ToUrlPath(const Path: string): string;
begin
  Result := Path.Replace('\', '/');
end;

end.
