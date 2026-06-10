unit FMX.WVPythia.OpenDialog;

interface

uses
  System.SysUtils, System.Classes, System.IOUtils, System.UITypes,
  FMX.Forms, FMX.Dialogs;

type
  TOpenDialogHelper = record
  strict private
    FOpenDialog: TOpenDialog;
    class function ResolveInitialDir(const S: string): string; static;
  public
    class function Use(ADialog: TOpenDialog): TOpenDialogHelper; static;
    class function Create(ADialog: TOpenDialog): TOpenDialogHelper; static; inline;

    function Filter(const S: string): TOpenDialogHelper; inline;
    function FilterIndex(const Index: Integer): TOpenDialogHelper; inline;
    function DefautExt(const S: string): TOpenDialogHelper; inline;
    function DefaultExt(const S: string): TOpenDialogHelper; inline;
    function InitialDir(const S: string): TOpenDialogHelper; inline;
    function Execute(var FileName: string; Multi: Boolean = False): Boolean; overload;
    function Execute(Multi: Boolean = False): string; overload;

    property Dialog: TOpenDialog read FOpenDialog;
  end;

  TFolderDialogHelper = record
  strict private
    FDialog: TObject;
    FTitle: string;
    FInitialDir: string;

    class function ResolveInitialDir(const S: string): string; static;
  public
    class function Use(ADialog: TObject): TFolderDialogHelper; static;
    class function Create(ADialog: TObject): TFolderDialogHelper; static; inline;

    function Title(const S: string): TFolderDialogHelper; inline;
    function InitialDir(const S: string): TFolderDialogHelper; inline;

    function Execute(var FolderName: string): Boolean; overload;
    function Execute: string; overload;

    property Dialog: TObject read FDialog;
  end;

implementation

{ TOpenDialogHelper }

class function TOpenDialogHelper.Create(ADialog: TOpenDialog): TOpenDialogHelper;
begin
  Result := Use(ADialog);
end;

function TOpenDialogHelper.DefaultExt(const S: string): TOpenDialogHelper;
begin
  FOpenDialog.DefaultExt := S;
  Result := Self;
end;

function TOpenDialogHelper.DefautExt(const S: string): TOpenDialogHelper;
begin
  Result := DefaultExt(S);
end;

function TOpenDialogHelper.Execute(Multi: Boolean): string;
begin
  if Multi then
    FOpenDialog.Options := FOpenDialog.Options + [TOpenOption.ofAllowMultiSelect]
  else
    FOpenDialog.Options := FOpenDialog.Options - [TOpenOption.ofAllowMultiSelect];

  if FOpenDialog.Execute then
  begin
    if Multi then
      Result := FOpenDialog.Files.Text.Trim
    else
      Result := FOpenDialog.FileName;
  end
  else
    Result := ':none';
end;

function TOpenDialogHelper.Execute(var FileName: string; Multi: Boolean): Boolean;
begin
  if Multi then
    FOpenDialog.Options := FOpenDialog.Options + [TOpenOption.ofAllowMultiSelect]
  else
    FOpenDialog.Options := FOpenDialog.Options - [TOpenOption.ofAllowMultiSelect];

  Result := FOpenDialog.Execute;
  if Result then
  begin
    if Multi then
      FileName := FOpenDialog.Files.Text.Trim
    else
      FileName := FOpenDialog.FileName;
  end;
end;

function TOpenDialogHelper.Filter(const S: string): TOpenDialogHelper;
begin
  FOpenDialog.Filter := S;
  Result := Self;
end;

function TOpenDialogHelper.FilterIndex(const Index: Integer): TOpenDialogHelper;
begin
  FOpenDialog.FilterIndex := Index;
  Result := Self;
end;

function TOpenDialogHelper.InitialDir(const S: string): TOpenDialogHelper;
begin
  FOpenDialog.InitialDir := ResolveInitialDir(S);
  Result := Self;
end;

class function TOpenDialogHelper.ResolveInitialDir(const S: string): string;
var
  BaseDir: string;
begin
  if S.IsEmpty then
    Exit('');

  if (S = '..') or S.StartsWith('..' + PathDelim) then
  begin
    BaseDir := TPath.GetDirectoryName(ParamStr(0));
    Exit(TPath.GetFullPath(TPath.Combine(BaseDir, S)));
  end;

  if TDirectory.Exists(S) then
    Exit(TPath.GetFullPath(S));

  if TFile.Exists(S) then
    Exit(TPath.GetDirectoryName(TPath.GetFullPath(S)));

  if TPath.HasExtension(S) then
    Result := TPath.GetDirectoryName(TPath.GetFullPath(S))
  else
    Result := TPath.GetFullPath(S);
end;

class function TOpenDialogHelper.Use(ADialog: TOpenDialog): TOpenDialogHelper;
begin
  Result := Default(TOpenDialogHelper);

  if Assigned(ADialog) then
    Result.FOpenDialog := ADialog
  else
    Result.FOpenDialog := TOpenDialog.Create(Application);
end;

{ TFolderDialogHelper }

class function TFolderDialogHelper.Create(ADialog: TObject): TFolderDialogHelper;
begin
  Result := Use(ADialog);
end;

function TFolderDialogHelper.Execute: string;
begin
  Result := ':none';

  var FolderName := FInitialDir;
  if Execute(FolderName) then
    Result := FolderName;
end;

function TFolderDialogHelper.Execute(var FolderName: string): Boolean;
var
  Caption: string;
  Root: string;
  Directory: string;
begin
  Caption := FTitle;
  if Caption.IsEmpty then
    Caption := 'Sélectionner un dossier';

  if FInitialDir.IsEmpty then
    Root := ResolveInitialDir(FolderName)
  else
    Root := FInitialDir;

  Directory := Root;

  // FMX.Dialogs.SelectDirectory impose Root et Directory comme variables distinctes.
  Result := SelectDirectory(Caption, Root, Directory);

  if Result then
    FolderName := Directory;
end;

function TFolderDialogHelper.InitialDir(const S: string): TFolderDialogHelper;
begin
  FInitialDir := ResolveInitialDir(S);
  Result := Self;
end;

class function TFolderDialogHelper.ResolveInitialDir(const S: string): string;
var
  BaseDir: string;
begin
  if S.IsEmpty then
    Exit('');

  if (S = '..') or S.StartsWith('..' + PathDelim) then
  begin
    BaseDir := TPath.GetDirectoryName(ParamStr(0));
    Exit(TPath.GetFullPath(TPath.Combine(BaseDir, S)));
  end;

  if TDirectory.Exists(S) then
    Exit(TPath.GetFullPath(S));

  if TFile.Exists(S) then
    Exit(TPath.GetDirectoryName(TPath.GetFullPath(S)));

  if TPath.HasExtension(S) then
    Result := TPath.GetDirectoryName(TPath.GetFullPath(S))
  else
    Result := TPath.GetFullPath(S);
end;

function TFolderDialogHelper.Title(const S: string): TFolderDialogHelper;
begin
  FTitle := S;
  Result := Self;
end;

class function TFolderDialogHelper.Use(ADialog: TObject): TFolderDialogHelper;
begin
  Result := Default(TFolderDialogHelper);
  Result.FDialog := ADialog;
end;

end.
