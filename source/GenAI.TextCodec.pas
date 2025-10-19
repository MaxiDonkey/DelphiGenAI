unit GenAI.TextCodec;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGenAI
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.SysUtils, System.Classes, System.NetEncoding;

type
  TTextCodec = record
  public
    class function DetectEncoding(const Bytes: TBytes): TEncoding; static;
    class function BomOffset(const Bytes: TBytes; const Enc: TEncoding): Integer; static;
    class function BytesToString(const Bytes: TBytes): string; static;
    class function SafeBase64ToString(const Base64Data: string): string; static;
    class function EncodeBytesToString(const Bytes: TBytes): string; static;
  end;

implementation

class function TTextCodec.DetectEncoding(const Bytes: TBytes): TEncoding;
begin
  if (Length(Bytes) >= 3) and (Bytes[0]=$EF) and (Bytes[1]=$BB) and (Bytes[2]=$BF) then
    Exit(TEncoding.UTF8);

  {--- UTF-16 LE }
  if (Length(Bytes) >= 2) and (Bytes[0]=$FF) and (Bytes[1]=$FE) then
    Exit(TEncoding.Unicode);

  {--- UTF-16 BE }
  if (Length(Bytes) >= 2) and (Bytes[0]=$FE) and (Bytes[1]=$FF) then
    Exit(TEncoding.BigEndianUnicode);

  Result := TEncoding.UTF8;
end;

class function TTextCodec.EncodeBytesToString(const Bytes: TBytes): string;
begin
  Result := TNetEncoding.Base64.EncodeBytesToString(Bytes);
end;

class function TTextCodec.SafeBase64ToString(const Base64Data: string): string;
begin
  if Base64Data.IsEmpty then
    Exit('');

  try
    var Bytes := TNetEncoding.Base64.DecodeStringToBytes(Base64Data);
    Result := BytesToString(Bytes);
  except
    on E: EConvertError do
      raise Exception.CreateFmt(
        'Invalid Base64 content (TTextCodec.SafeBase64ToString): %s',
        [E.Message]
      );
  end;
end;

class function TTextCodec.BomOffset(const Bytes: TBytes; const Enc: TEncoding): Integer;
begin
  Result := 0;

  if (Enc=TEncoding.UTF8) and (Length(Bytes)>=3) and (Bytes[0]=$EF) and (Bytes[1]=$BB) and (Bytes[2]=$BF) then
    Exit(3);

  if (Enc=TEncoding.Unicode) and (Length(Bytes)>=2) and (Bytes[0]=$FF) and (Bytes[1]=$FE) then
    Exit(2);

  if (Enc=TEncoding.BigEndianUnicode) and (Length(Bytes)>=2) and (Bytes[0]=$FE) and (Bytes[1]=$FF) then
    Exit(2);
end;

class function TTextCodec.BytesToString(const Bytes: TBytes): string;
begin
  if Length(Bytes)=0 then
    Exit('');

  var Enc := DetectEncoding(Bytes);
  var Off := BomOffset(Bytes, Enc);
  Result := Enc.GetString(Bytes, Off, Length(Bytes)-Off);
end;

end.
