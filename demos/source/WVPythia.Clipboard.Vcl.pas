unit WVPythia.Clipboard.Vcl;

interface

uses
  WVPythia.Chat.Interfaces;

type
  TVclClipboardReader = class(TInterfacedObject, IClipboardReader)
  public
    function IsAvailable: Boolean;

    function TryGetText(out AText: TClipboardTextData): Boolean;
    function TrySaveImageToTempPng(out AFileName: string): Boolean;
    function TryGetFiles(out AFiles: TArray<string>): Boolean;
  end;

implementation

uses
  Winapi.Windows, Winapi.ShellAPI,
  System.SysUtils, System.IOUtils,
  Vcl.Clipbrd, Vcl.Graphics, Vcl.Imaging.pngimage,
  WVPythia.TextFile.Helper;

const
  ClipboardTextInlineLimit =  12000;
  ClipboardTempFolderName = 'PythiaClipboard';
  PastedTextFileName = 'Pasted-Text.txt';
  PastedImageFileName = 'Pasted-Image.png';

function NewGuidFileToken: string;
var
  Guid: TGUID;
begin
  if CreateGUID(Guid) <> 0 then
    raise Exception.Create('Unable to create GUID');

  Result := GUIDToString(Guid);
  Result := StringReplace(Result, '{', '', [rfReplaceAll]);
  Result := StringReplace(Result, '}', '', [rfReplaceAll]);
  Result := StringReplace(Result, '-', '', [rfReplaceAll]);
end;

function NewTempClipboardFolder: string;
begin
  Result := TPath.Combine(
    TPath.Combine(TPath.GetTempPath, ClipboardTempFolderName),
    NewGuidFileToken
  );

  ForceDirectories(Result);
end;

function NewTempTextFileName: string;
begin
  Result := TPath.Combine(NewTempClipboardFolder, PastedTextFileName);
end;

function NewTempImageFileName: string;
begin
  Result := TPath.Combine(NewTempClipboardFolder, PastedImageFileName);
end;

function TVclClipboardReader.IsAvailable: Boolean;
begin
  Result := True;
end;

function TVclClipboardReader.TryGetText(out AText: TClipboardTextData): Boolean;
begin
  AText.Kind := ctkInline;
  AText.Text := '';
  AText.FileName := '';
  Result := False;

  try
    if not Clipboard.HasFormat(CF_UNICODETEXT) then
      Exit;

    var AsText := Clipboard.AsText;

    if AsText.IsEmpty then
      Exit;

    if Length(AsText) <= ClipboardTextInlineLimit then
      begin
        AText.Kind := ctkInline;
        AText.Text := AsText;
        AText.FileName := '';
        Result := True;

        Exit;
      end;

    AText.Kind := ctkTempFile;
    AText.Text := '';
    AText.FileName := NewTempTextFileName;

    TFileIOHelper.SaveToFile(AText.FileName, AsText);

    Result :=
      TFile.Exists(AText.FileName) and
      (TFile.GetSize(AText.FileName) > 0);

    if not Result then
      begin
        AText.Text := '';
        AText.FileName := '';
      end;
  except
    AText.Kind := ctkInline;
    AText.Text := '';
    AText.FileName := '';
    Result := False;
  end;
end;

function TVclClipboardReader.TrySaveImageToTempPng(out AFileName: string): Boolean;
begin
  AFileName := '';
  Result := False;

  try
    if not (
      Clipboard.HasFormat(CF_BITMAP) or
      Clipboard.HasFormat(CF_DIB) or
      Clipboard.HasFormat(CF_DIBV5)
    ) then
      Exit;

    AFileName := NewTempImageFileName;

    var Bitmap := TBitmap.Create;
    try
      Bitmap.Assign(Clipboard);

      var Png := TPngImage.Create;
      try
        Png.Assign(Bitmap);
        Png.SaveToFile(AFileName);
      finally
        Png.Free;
      end;
    finally
      Bitmap.Free;
    end;

    Result :=
      TFile.Exists(AFileName) and
      (TFile.GetSize(AFileName) > 0);

    if not Result then
      AFileName := '';
  except
    AFileName := '';
    Result := False;
  end;
end;

function TVclClipboardReader.TryGetFiles(out AFiles: TArray<string>): Boolean;
var
  DropHandle: HDROP;
  Count: UINT;
  I: UINT;
  Len: UINT;
  Buffer: string;
begin
  AFiles := nil;
  Result := False;

  try
    if not Clipboard.HasFormat(CF_HDROP) then
      Exit;

    DropHandle := Clipboard.GetAsHandle(CF_HDROP);
    if DropHandle = 0 then
      Exit;

    Count := DragQueryFile(DropHandle, $FFFFFFFF, nil, 0);
    if Count = 0 then
      Exit;

    SetLength(AFiles, Count);

    for I := 0 to Count - 1 do
      begin
        Len := DragQueryFile(DropHandle, I, nil, 0);

        SetLength(Buffer, Len + 1);
        DragQueryFile(DropHandle, I, PChar(Buffer), Len + 1);
        SetLength(Buffer, Len);

        AFiles[I] := Buffer;
      end;

    Result := True;
  except
    AFiles := nil;
    Result := False;
  end;
end;

end.
