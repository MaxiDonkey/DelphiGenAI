unit GenAI.Responses.ImageHelper;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGenAI
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.SysUtils, System.Classes, GenAI.Httpx, GenAI.NetEncoding.Base64, System.IOUtils;

type
  TImageHelper = record
  private
    FImageB64: string;
    FFileName: string;
  public
    constructor Create(const AImageB64: string);
    function GetStream: TStream;
    function SaveAs(const FileName: string; const RaiseError: Boolean = True): TImageHelper;
    function SaveAsBase64(const FileName: string; const RaiseError: Boolean = True): TImageHelper;
    function LoadFromBase64(const FileName: string): TImageHelper;
    function FileName: string;
  end;

implementation

{ TImageHelper }

constructor TImageHelper.Create(const AImageB64: string);
begin
  Self.FImageB64 := AImageB64;
end;

function TImageHelper.FileName: string;
begin
  Result := FFileName;
end;

function TImageHelper.GetStream: TStream;
begin
  {--- Create a memory stream to write the decoded content. }
  Result := TMemoryStream.Create;
  try
    if not FImageB64.IsEmpty then
      {--- Convert the base-64 string directly into the memory stream. }
      DecodeBase64ToStream(FImageB64, Result)
  except
    Result.Free;
    raise;
  end;
end;

function TImageHelper.LoadFromBase64(const FileName: string): TImageHelper;
begin
  if not FileExists(FileName) then
    raise Exception.CreateFmt('%s: sile not found', [FileName]);

  Self.FFileName := FileName;
  Self.FImageB64 := GenAI.NetEncoding.Base64.LoadAsBase64(FileName);
end;

function TImageHelper.SaveAs(const FileName: string;
  const RaiseError: Boolean): TImageHelper;
begin
  case RaiseError of
    True :
      if FileName.Trim.IsEmpty then
        raise Exception.Create('File record aborted. SaveToFile requires a filename.');
    else
      if FileName.Trim.IsEmpty then
        Exit(Self);
  end;

  var FullPath := TPath.GetDirectoryName(FileName);
  if not FullPath.isEmpty and not TDirectory.Exists(FullPath) then
    TDirectory.CreateDirectory(FullPath);

  try
    Self.FFileName := FileName;
    {--- Perform the decoding operation and save it into the file specified by the FileName parameter. }
    DecodeBase64ToFile(FImageB64, FileName);
    Result := Self;
  except
    raise;
  end;
end;

function TImageHelper.SaveAsBase64(const FileName: string;
  const RaiseError: Boolean): TImageHelper;
begin
  case RaiseError of
    True :
      if FileName.Trim.IsEmpty then
        raise Exception.Create('File record aborted. SaveToFile requires a filename.');
    else
      if FileName.Trim.IsEmpty then
        Exit(Self);
  end;

  Self.FFileName := FileName;
  GenAI.NetEncoding.Base64.SaveAsBase64(FFileName, FImageB64);
  Result := Self;
end;

end.
