unit WVPythia.Clipboard.Fmx;

interface

uses
  WVPythia.Chat.Interfaces;

type
  TFmxClipboardReader = class(TInterfacedObject, IClipboardReader)
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
  FMX.Platform, FMX.Clipboard, FMX.Surfaces, FMX.Graphics,
  WVPythia.TextFile.Helper;

const
  ClipboardTextInlineLimit = 12000;
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

function TFmxClipboardReader.IsAvailable: Boolean;
var
  ClipboardService: IFMXExtendedClipboardService;
begin
  Result :=
    TPlatformServices.Current.SupportsPlatformService(
      IFMXExtendedClipboardService,
      ClipboardService
    );
end;

function TFmxClipboardReader.TryGetText(out AText: TClipboardTextData): Boolean;
var
  ClipboardService: IFMXExtendedClipboardService;
begin
  AText.Kind := ctkInline;
  AText.Text := '';
  AText.FileName := '';
  Result := False;

  try
    if not TPlatformServices.Current.SupportsPlatformService(
      IFMXExtendedClipboardService,
      ClipboardService
    ) then
      Exit;

    if not ClipboardService.HasText then
      Exit;

    var AsText := ClipboardService.GetText;

    if AsText = '' then
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

function TFmxClipboardReader.TrySaveImageToTempPng(out AFileName: string): Boolean;
var
  ClipboardService: IFMXExtendedClipboardService;
begin
  AFileName := '';
  Result := False;

  try
    if not TPlatformServices.Current.SupportsPlatformService(
      IFMXExtendedClipboardService,
      ClipboardService
    ) then
      Exit;

    if not ClipboardService.HasImage then
      Exit;

    var Surface := ClipboardService.GetImage;
    if Surface = nil then
      Exit;

    try
      AFileName := NewTempImageFileName;

      Result := TBitmapCodecManager.SaveToFile(AFileName, Surface);

      if Result then
      begin
        Result :=
          TFile.Exists(AFileName) and
          (TFile.GetSize(AFileName) > 0);
      end;

      if not Result then
        AFileName := '';
    finally
      Surface.Free;
    end;
  except
    AFileName := '';
    Result := False;
  end;
end;

function TFmxClipboardReader.TryGetFiles(out AFiles: TArray<string>): Boolean;
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
    if not OpenClipboard(0) then
      Exit;

    try
      if not IsClipboardFormatAvailable(CF_HDROP) then
        Exit;

      DropHandle := GetClipboardData(CF_HDROP);
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
    finally
      CloseClipboard;
    end;
  except
    AFiles := nil;
    Result := False;
  end;
end;

end.
