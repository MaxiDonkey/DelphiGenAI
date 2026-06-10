unit VCL.WVPythia.OpenDialog;

interface

{$REGION 'Dev notes : Helper.OpenDialog.VCL'}

(*
A. Returns a boolean with True if successful.

  1. Only one file is returned

      var FileName := 'D:\2026-developpement\OpenAI_File_Search\logos\GeminiLogo.png';
      var Ok :=
              TOpenDialogHelper.Use(nil)
                .Filter('Network Graphics (*.png)|*.png')
                .InitialDir(ExtractFileDir(FileName))
                .Execute(FileName);
      if Ok then
        ShowMessage(FileName);

  2. Multiple files can be returned - Multiple selection.

      var FileName := 'D:\2026-developpement\OpenAI_File_Search\logos\GeminiLogo.png';
      var Ok :=
              TOpenDialogHelper.Use(nil)
                .Filter('Network Graphics (*.png)|*.png')
                .InitialDir(ExtractFileDir(FileName))  <--- is placed in the file folder
                .Execute(FileName, True);
      if Ok then
          for var Item in FileName.Split([#10]) do
              ShowMessage(Item);

B. Returns a string and ':none' on abort. Don't test if the file exists.

   1. A single file returned or the string ':none'

      var FileName := 'D:\2026-developpement\OpenAI_File_Search\logos\GeminiLogo.png';
      var FileName1 := TOpenDialogHelper.Use(nil)
                .Filter('Network Graphics (*.png)|*.png')
                .InitialDir(ExtractFileDir(FileName))
                .Execute;
      if FileExists(FileName1) then
        ShowMessage(FileName1);

   2. Returns multiple files or the string ':none'

      var FileName := 'D:\2026-developpement\OpenAI_File_Search\logos\GeminiLogo.png';
      var FileName1 := TOpenDialogHelper.Use(nil)
              .Filter('Network Graphics (*.png)|*.png')
              .InitialDir(ExtractFileDir(FileName))
              .Execute(True);

      for var Item in FileName1.Split([#10]) do
        if FileExists(Item) then
           ShowMessage(Item);

C. Folder selection. Returns a boolean with True if successful.

      var FolderName := 'D:\2026-developpement\OpenAI_File_Search';
      var Ok :=
              TFolderDialogHelper.Use(nil)
                .Title('Sélectionner un dossier')
                .InitialDir(FolderName)
                .Execute(FolderName);
      if Ok then
        ShowMessage(FolderName);

D. Folder selection. Returns a string and ':none' on abort.

      var FolderName :=
              TFolderDialogHelper.Use(nil)
                .Title('Sélectionner un dossier')
                .InitialDir('D:\2026-developpement\OpenAI_File_Search')
                .Execute;
      if TDirectory.Exists(FolderName) then
        ShowMessage(FolderName);
*)

{$ENDREGION}

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes, System.IOUtils,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtDlgs,
  Vcl.Themes;

type
  TOpenDialogHelper = record
  strict private
    FOpenDialog: TOpenDialog;
  public
    class function Use(ADialog: TOpenDialog): TOpenDialogHelper; static;

    function Filter(const S: string): TOpenDialogHelper;
    function FilterIndex(const Index: Integer): TOpenDialogHelper;
    function DefautExt(const S: string): TOpenDialogHelper;
    function InitialDir(const S: string): TOpenDialogHelper;

    function Execute(var FileName: string; Multi: Boolean = False): Boolean; overload;
    function Execute(Multi: Boolean = False): string; overload;

    property Dialog: TOpenDialog read FOpenDialog;
  end;

  TFolderDialogHelper = record
  strict private
    FFolderDialog: TFileOpenDialog;
  public
    class function Use(ADialog: TFileOpenDialog): TFolderDialogHelper; static;

    function Title(const S: string): TFolderDialogHelper;
    function InitialDir(const S: string): TFolderDialogHelper;

    function Execute(var FolderName: string): Boolean; overload;
    function Execute: string; overload;

    property Dialog: TFileOpenDialog read FFolderDialog;
  end;

implementation

function NormalizedInitialDir(const S: string): string;
begin
  Result := S.Trim;

  if Result.IsEmpty then
    Exit;

  if Result.StartsWith('..\') then
    Result := TPath.GetFullPath(TPath.Combine(TPath.GetDirectoryName(ParamStr(0)), Result))
  else if TDirectory.Exists(Result) then
    Result := TPath.GetFullPath(Result)
  else
    Result := TPath.GetDirectoryName(Result);
end;

{ TOpenDialogHelper }

function TOpenDialogHelper.DefautExt(const S: string): TOpenDialogHelper;
begin
  FOpenDialog.DefaultExt := S;
  Result := Self;
end;

function TOpenDialogHelper.Execute(Multi: Boolean): string;
begin
  var SavedHooks := TStyleManager.SystemHooks;
  try
    TStyleManager.SystemHooks := SavedHooks - [shDialogs];

    if Multi then
      FOpenDialog.Options := FOpenDialog.Options + [ofAllowMultiSelect]
    else
      FOpenDialog.Options := FOpenDialog.Options - [ofAllowMultiSelect];

    if FOpenDialog.Execute then
      begin
        if Multi then
          Result := FOpenDialog.Files.Text.Trim
        else
          Result := FOpenDialog.FileName;
      end
    else
      Result := ':none';
  finally
//    FOpenDialog.Free;
    TStyleManager.SystemHooks := SavedHooks;
  end;
end;

function TOpenDialogHelper.Execute(var FileName: string; Multi: Boolean): Boolean;
begin
  var SavedHooks := TStyleManager.SystemHooks;
  try
    TStyleManager.SystemHooks := SavedHooks - [shDialogs];

    if Multi then
      FOpenDialog.Options := FOpenDialog.Options + [ofAllowMultiSelect]
    else
      FOpenDialog.Options := FOpenDialog.Options - [ofAllowMultiSelect];

    Result := FOpenDialog.Execute;

    if Result then
      begin
        if Multi then
          FileName := FOpenDialog.Files.Text.Trim
        else
          FileName := FOpenDialog.FileName;
      end;
  finally
//    FOpenDialog.Free;
    TStyleManager.SystemHooks := SavedHooks;
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
  FOpenDialog.InitialDir := NormalizedInitialDir(S);
  Result := Self;
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

function TFolderDialogHelper.Execute: string;
begin
  var SavedHooks := TStyleManager.SystemHooks;
  try
    TStyleManager.SystemHooks := SavedHooks - [shDialogs];

    FFolderDialog.Options :=
      FFolderDialog.Options
      + [fdoPickFolders, fdoForceFileSystem, fdoPathMustExist]
      - [fdoAllowMultiSelect];

    if FFolderDialog.Execute then
      Result := FFolderDialog.FileName
    else
      Result := ':none';
  finally
//    FFolderDialog.Free;
    TStyleManager.SystemHooks := SavedHooks;
  end;
end;

function TFolderDialogHelper.Execute(var FolderName: string): Boolean;
begin
  var SavedHooks := TStyleManager.SystemHooks;
  try
    TStyleManager.SystemHooks := SavedHooks - [shDialogs];

    FFolderDialog.Options :=
      FFolderDialog.Options
      + [fdoPickFolders, fdoForceFileSystem, fdoPathMustExist]
      - [fdoAllowMultiSelect];

    Result := FFolderDialog.Execute;

    if Result then
      FolderName := FFolderDialog.FileName;
  finally
//    FFolderDialog.Free;
    TStyleManager.SystemHooks := SavedHooks;
  end;
end;

function TFolderDialogHelper.InitialDir(const S: string): TFolderDialogHelper;
var
  Path: string;
begin
  Path := NormalizedInitialDir(S);

  if not Path.IsEmpty then
    begin
      FFolderDialog.DefaultFolder := Path;
      FFolderDialog.FileName := Path;
    end;

  Result := Self;
end;

function TFolderDialogHelper.Title(const S: string): TFolderDialogHelper;
begin
  FFolderDialog.Title := S;
  Result := Self;
end;

class function TFolderDialogHelper.Use(ADialog: TFileOpenDialog): TFolderDialogHelper;
begin
  Result := Default(TFolderDialogHelper);

  if Assigned(ADialog) then
    Result.FFolderDialog := ADialog
  else
    Result.FFolderDialog := TFileOpenDialog.Create(Application);
end;

end.
