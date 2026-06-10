unit GenAI.Net.MediaCodec;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGenAI
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.SysUtils, System.Classes;

type
  TUriCodec = record
  public
    /// <summary>
    /// Extracts the file name from the path component of a URI.
    /// </summary>
    class function ExtractURIFileName(const Uri: string): string; static;
  end;

  TMediaCodec = record
  private
    class function GetMimeTypeFromURI(const Uri: string): string; static;
    class function ResolveMimeType(const FilePath: string): string; static;
    class function NormalizeMimeType(const MimeType: string): string; static;
    class function StripCrlf(const Value: string): string; static;
  public
    class function IsUri(const Value: string): Boolean; static;
    class function IsDataUri(const Value: string): Boolean; static;

    class function NormalizeBase64(const Value: string;
      const CrLfDeletion: Boolean = True): string; static;

    class function EncodeBase64(const FilePath: string;
      const CrLfDeletion: Boolean = False): string; overload; static;
    class function EncodeBase64(const Text: string; Encoding: TEncoding;
      const CrLfDeletion: Boolean = True): string; overload; static;
    class function EncodeBase64(const Value: TStream;
      const CrLfDeletion: Boolean = True): string; overload; static;
    class function EncodeBase64(const ABytes: TBytes;
      const CrLfDeletion: Boolean = True): string; overload; static;

    class function DecodeBase64ToString(const Base64: string;
      Encoding: TEncoding = nil): string; static;
    class function DecodeBase64ToBytes(const Base64: string): TBytes; static;
    class function DecodeBase64ToStream(const Base64: string;
      const AStream: TStream): Boolean; static;
    class function DecodeBase64ToFile(const Base64: string;
      const FilePath: string): Boolean; static;

    class function TryDecodeBase64ToString(const Base64: string;
      out Value: string; Encoding: TEncoding = nil): Boolean; static;
    class function TryDecodeBase64ToBytes(const Base64: string;
      out Bytes: TBytes): Boolean; static;
    class function TryDecodeBase64ToStream(const Base64: string;
      AStream: TStream): Boolean; static;
    class function TryDecodeBase64ToFile(const Base64: string;
      const FilePath: string): Boolean; static;

    class function EncodeDataUri(const FilePath: string; const MimeType: string;
      const CrLfDeletion: Boolean = False): string; overload; static;
    class function EncodeDataUri(const Text: string; const MimeType: string;
      Encoding: TEncoding; const CrLfDeletion: Boolean = True): string; overload; static;
    class function EncodeDataUri(const Value: TStream; const MimeType: string;
      const CrLfDeletion: Boolean = True): string; overload; static;
    class function EncodeDataUri(const ABytes: TBytes; const MimeType: string;
      const CrLfDeletion: Boolean = True): string; overload; static;

    class function TryDecodeDataUriToBytes(const DataUri: string;
      out Bytes: TBytes; out MimeType: string): Boolean; static;
    class function TryDecodeDataUriToStream(const DataUri: string;
      AStream: TStream; out MimeType: string): Boolean; static;
    class function TryDecodeDataUriToString(const DataUri: string;
      out Value: string; out MimeType: string; Encoding: TEncoding = nil): Boolean; static;
    class function TryDecodeDataUriToFile(const DataUri: string;
      const FilePath: string; out MimeType: string): Boolean; static;
    class function TryGetDataUriMimeType(const Value: string;
      out MimeType: string): Boolean; static;

    class function GetMimeType(const FileLocation: string): string; static;
    class function GetFileSize(const FilePath: string): Int64; static;

    class function TryToBytes(const FileLocation: string;
      out Bytes: TBytes; out MimeType: string): Boolean; static;
    class function TryToDataUri(const FileLocation: string;
      out DataUri: string; out MimeType: string): Boolean; static;

    class function TryUrlToBytes(const AUrl: string;
      out Bytes: TBytes; out ContentType: string): Boolean; static;
    class function TryUrlToStream(const AUrl: string; AStream: TStream;
      out AContentType: string): Boolean; static;
  end;

implementation

uses
  System.Net.Mime, System.NetEncoding, System.Net.HttpClient, System.Net.URLClient,
  System.IOUtils, System.StrUtils, GenAI.Consts;

type
  TDataUriDecoded = record
  private
    FMimeType: string;
    FCharset: string;
    FIsBase64: Boolean;
    FBytes: TBytes;

    class function DefaultMimeType: string; static; inline;
    class function DefaultCharset: string; static; inline;
    class function StartsWithDataPrefix(const Value: string): Boolean; static; inline;
    class function HexNibble(const C: Char; out ByteValue: Byte): Boolean; static; inline;
    class function TryPercentDecodeToBytes(const Value: string; out Bytes: TBytes): Boolean; static;
    class function StripWhitespaceAscii(const Value: string): string; static;
    class procedure ParseHeader(const Header: string;
      out MimeType: string; out Charset: string; out IsBase64: Boolean); static;

    procedure Clear;
  public
    property MimeType: string read FMimeType;
    property Charset: string read FCharset;
    property IsBase64: Boolean read FIsBase64;
    property Bytes: TBytes read FBytes;

    class function TryDecode(const DataUri: string; out Decoder: TDataUriDecoded): Boolean; static;
  end;

{ TUriCodec }

class function TUriCodec.ExtractURIFileName(const Uri: string): string;
begin
  if Uri.Trim.IsEmpty then
    Exit(EmptyStr);

  Result := ExtractFileName(TURI.Create(Uri).Path).TrimLeft(['/']);
end;

{ TDataUriDecoded }

procedure TDataUriDecoded.Clear;
begin
  FMimeType := EmptyStr;
  FCharset := EmptyStr;
  FIsBase64 := False;
  FBytes := nil;
end;

class function TDataUriDecoded.DefaultCharset: string;
begin
  Result := 'US-ASCII';
end;

class function TDataUriDecoded.DefaultMimeType: string;
begin
  Result := 'text/plain';
end;

class function TDataUriDecoded.HexNibble(const C: Char;
  out ByteValue: Byte): Boolean;
begin
  Result := True;
  case C of
    '0'..'9': ByteValue := Byte(Ord(C) - Ord('0'));
    'a'..'f': ByteValue := Byte(Ord(C) - Ord('a') + 10);
    'A'..'F': ByteValue := Byte(Ord(C) - Ord('A') + 10);
  else
    ByteValue := 0;
    Result := False;
  end;
end;

class procedure TDataUriDecoded.ParseHeader(const Header: string;
  out MimeType, Charset: string; out IsBase64: Boolean);
begin
  MimeType := DefaultMimeType;
  Charset := DefaultCharset;
  IsBase64 := False;

  if Header.Trim.IsEmpty then
    Exit;

  var Parts := Header.Split([';']);
  var First := Parts[0].Trim;

  if (not First.IsEmpty) and (First.IndexOf('/') > 0) then
    MimeType := First.ToLower;

  for var I := 0 to High(Parts) do
    begin
      var Part := Parts[I].Trim;
      if Part.IsEmpty then
        Continue;

      if SameText(Part, 'base64') then
        begin
          IsBase64 := True;
          Continue;
        end;

      if Part.ToLower.StartsWith('charset=') then
        begin
          Charset := Part.Substring(Length('charset=')).Trim;
          Charset := Charset.Trim(['"', '''']);
        end;
    end;
end;

class function TDataUriDecoded.StartsWithDataPrefix(
  const Value: string): Boolean;
begin
  Result := (Value.Length >= 5) and SameText(Value.Substring(0, 5), 'data:');
end;

class function TDataUriDecoded.StripWhitespaceAscii(
  const Value: string): string;
begin
  var Builder := TStringBuilder.Create(Value.Length);
  try
    for var I := 1 to Value.Length do
      case Value[I] of
        #9, #10, #13, ' ':
          Continue;
      else
        Builder.Append(Value[I]);
      end;

    Result := Builder.ToString;
  finally
    Builder.Free;
  end;
end;

class function TDataUriDecoded.TryDecode(const DataUri: string;
  out Decoder: TDataUriDecoded): Boolean;
begin
  Decoder.Clear;

  var Buffer := DataUri.Trim;
  if not StartsWithDataPrefix(Buffer) then
    Exit(False);

  var CommaPos := Buffer.IndexOf(',');
  if CommaPos < 0 then
    Exit(False);

  var Header := Buffer.Substring(5, CommaPos - 5);
  var Payload := Buffer.Substring(CommaPos + 1);

  ParseHeader(Header, Decoder.FMimeType, Decoder.FCharset, Decoder.FIsBase64);

  try
    if Decoder.FIsBase64 then
      Decoder.FBytes := TNetEncoding.Base64.DecodeStringToBytes(
        StripWhitespaceAscii(Payload))
    else
      if not TryPercentDecodeToBytes(Payload, Decoder.FBytes) then
        Exit(False);

    Result := True;
  except
    Decoder.Clear;
    Result := False;
  end;
end;

class function TDataUriDecoded.TryPercentDecodeToBytes(const Value: string;
  out Bytes: TBytes): Boolean;
begin
  Bytes := nil;
  SetLength(Bytes, Value.Length);

  var Count := 0;
  var Index := 1;

  while Index <= Value.Length do
    begin
      var Ch := Value[Index];

      if Ch = '%' then
        begin
          if Index + 2 > Value.Length then
            begin
              Bytes := nil;
              Exit(False);
            end;

          var Hi, Lo: Byte;
          if not HexNibble(Value[Index + 1], Hi) or
             not HexNibble(Value[Index + 2], Lo) then
            begin
              Bytes := nil;
              Exit(False);
            end;

          Bytes[Count] := Byte((Hi shl 4) or Lo);
          Inc(Count);
          Inc(Index, 3);
          Continue;
        end;

      if Ord(Ch) > $FF then
        begin
          Bytes := nil;
          Exit(False);
        end;

      Bytes[Count] := Byte(Ord(Ch) and $FF);
      Inc(Count);
      Inc(Index);
    end;

  SetLength(Bytes, Count);
  Result := True;
end;

{ TMediaCodec }

class function TMediaCodec.DecodeBase64ToBytes(const Base64: string): TBytes;
begin
  Result := TNetEncoding.Base64.DecodeStringToBytes(NormalizeBase64(Base64, True));
end;

class function TMediaCodec.DecodeBase64ToFile(const Base64,
  FilePath: string): Boolean;
begin
  Result := False;

  if FilePath.Trim.IsEmpty then
    Exit;

  try
    TFile.WriteAllBytes(FilePath, DecodeBase64ToBytes(Base64));
    Result := True;
  except
    Result := False;
  end;
end;

class function TMediaCodec.DecodeBase64ToStream(const Base64: string;
  const AStream: TStream): Boolean;
begin
  Result := False;

  if AStream = nil then
    Exit;

  try
    AStream.Size := 0;
    AStream.Position := 0;

    var Bytes := DecodeBase64ToBytes(Base64);
    if Length(Bytes) > 0 then
      AStream.WriteBuffer(Bytes[0], Length(Bytes));

    AStream.Position := 0;
    Result := True;
  except
    AStream.Size := 0;
    AStream.Position := 0;
    Result := False;
  end;
end;

class function TMediaCodec.DecodeBase64ToString(const Base64: string;
  Encoding: TEncoding): string;
begin
  if Encoding = nil then
    Encoding := TEncoding.UTF8;

  Result := Encoding.GetString(DecodeBase64ToBytes(Base64));
end;

class function TMediaCodec.EncodeBase64(const ABytes: TBytes;
  const CrLfDeletion: Boolean): string;
begin
  Result := TNetEncoding.Base64.EncodeBytesToString(ABytes);
  Result := NormalizeBase64(Result, CrLfDeletion);
end;

class function TMediaCodec.EncodeBase64(const Text: string;
  Encoding: TEncoding; const CrLfDeletion: Boolean): string;
begin
  if Encoding = nil then
    Encoding := TEncoding.UTF8;

  Result := EncodeBase64(Encoding.GetBytes(Text), CrLfDeletion);
end;

class function TMediaCodec.EncodeBase64(const Value: TStream;
  const CrLfDeletion: Boolean): string;
begin
  if Value = nil then
    Exit(EmptyStr);

  var SavedPos := Value.Position;
  try
    var Length := Value.Size - Value.Position;
    if Length <= 0 then
      Exit(EmptyStr);

    var Bytes: TBytes;
    SetLength(Bytes, Length);
    Value.ReadBuffer(Bytes[0], Length);

    Result := EncodeBase64(Bytes, CrLfDeletion);
  finally
    Value.Position := SavedPos;
  end;
end;

class function TMediaCodec.EncodeBase64(const FilePath: string;
  const CrLfDeletion: Boolean): string;
begin
  if not TFile.Exists(FilePath) then
    raise Exception.CreateFmt('File not found: %s', [FilePath]);

  var Stream := TFileStream.Create(FilePath, fmOpenRead or fmShareDenyWrite);
  try
    Result := EncodeBase64(Stream, CrLfDeletion);
  finally
    Stream.Free;
  end;
end;

class function TMediaCodec.EncodeDataUri(const ABytes: TBytes;
  const MimeType: string; const CrLfDeletion: Boolean): string;
begin
  var MediaType := NormalizeMimeType(MimeType);
  if MediaType.IsEmpty then
    raise Exception.Create('MimeType is empty');

  Result := 'data:' + MediaType + ';base64,' + EncodeBase64(ABytes, CrLfDeletion);
end;

class function TMediaCodec.EncodeDataUri(const Value: TStream;
  const MimeType: string; const CrLfDeletion: Boolean): string;
begin
  var MediaType := NormalizeMimeType(MimeType);
  if MediaType.IsEmpty then
    raise Exception.Create('MimeType is empty');

  Result := 'data:' + MediaType + ';base64,' + EncodeBase64(Value, CrLfDeletion);
end;

class function TMediaCodec.EncodeDataUri(const Text, MimeType: string;
  Encoding: TEncoding; const CrLfDeletion: Boolean): string;
begin
  var MediaType := NormalizeMimeType(MimeType);
  if MediaType.IsEmpty then
    raise Exception.Create('MimeType is empty');

  if Encoding = nil then
    Encoding := TEncoding.UTF8;

  Result := 'data:' + MediaType + ';base64,' +
    EncodeBase64(Text, Encoding, CrLfDeletion);
end;

class function TMediaCodec.EncodeDataUri(const FilePath, MimeType: string;
  const CrLfDeletion: Boolean): string;
begin
  var MediaType := NormalizeMimeType(MimeType);
  if MediaType.IsEmpty then
    raise Exception.Create('MimeType is empty');

  Result := 'data:' + MediaType + ';base64,' +
    EncodeBase64(FilePath, CrLfDeletion);
end;

class function TMediaCodec.GetFileSize(const FilePath: string): Int64;
begin
  Result := TFile.GetSize(FilePath);
end;

class function TMediaCodec.GetMimeType(const FileLocation: string): string;
begin
  if TryGetDataUriMimeType(FileLocation, Result) then
    Exit;

  if IsUri(FileLocation) then
    Result := GetMimeTypeFromURI(FileLocation)
  else
    Result := ResolveMimeType(FileLocation);
end;

class function TMediaCodec.GetMimeTypeFromURI(const Uri: string): string;
begin
  Result := EmptyStr;

  var Client := THTTPClient.Create;
  try
    try
      var Response := Client.Head(Uri);
      if Response <> nil then
        Result := NormalizeMimeType(Response.HeaderValue['Content-Type']);
    except
      Result := EmptyStr;
    end;
  finally
    Client.Free;
  end;
end;

class function TMediaCodec.IsDataUri(const Value: string): Boolean;
begin
  Result := Value.Trim.StartsWith('data:', True);
end;

class function TMediaCodec.IsUri(const Value: string): Boolean;
begin
  var Lower := Value.Trim.ToLower;
  Result := Lower.StartsWith('http://') or Lower.StartsWith('https://');
end;

class function TMediaCodec.NormalizeBase64(const Value: string;
  const CrLfDeletion: Boolean): string;
begin
  if CrLfDeletion then
    Exit(StripCrlf(Value));

  Result := Value;
end;

class function TMediaCodec.NormalizeMimeType(const MimeType: string): string;
begin
  Result := MimeType.Trim.ToLower;

  var PosParam := Result.IndexOf(';');
  if PosParam >= 0 then
    Result := Result.Substring(0, PosParam).Trim;

  if Result = 'audio/x-wav' then
    Result := 'audio/wav';
end;

class function TMediaCodec.ResolveMimeType(const FilePath: string): string;
begin
  if not TFile.Exists(FilePath) then
    raise Exception.CreateFmt('File not found: %s', [FilePath]);

  var Kind: TMimeTypes.TKind;
  TMimeTypes.Default.GetFileInfo(FilePath, Result, Kind);
  Result := NormalizeMimeType(Result);
end;

class function TMediaCodec.StripCrlf(const Value: string): string;
begin
  Result := Value.Replace(#13, '').Replace(#10, '');
end;

class function TMediaCodec.TryDecodeBase64ToBytes(const Base64: string;
  out Bytes: TBytes): Boolean;
begin
  Bytes := nil;

  try
    Bytes := DecodeBase64ToBytes(Base64);
    Result := True;
  except
    Bytes := nil;
    Result := False;
  end;
end;

class function TMediaCodec.TryDecodeBase64ToFile(const Base64,
  FilePath: string): Boolean;
begin
  Result := DecodeBase64ToFile(Base64, FilePath);
end;

class function TMediaCodec.TryDecodeBase64ToStream(const Base64: string;
  AStream: TStream): Boolean;
begin
  Result := DecodeBase64ToStream(Base64, AStream);
end;

class function TMediaCodec.TryDecodeBase64ToString(const Base64: string;
  out Value: string; Encoding: TEncoding): Boolean;
begin
  Value := EmptyStr;

  try
    Value := DecodeBase64ToString(Base64, Encoding);
    Result := True;
  except
    Value := EmptyStr;
    Result := False;
  end;
end;

class function TMediaCodec.TryDecodeDataUriToBytes(const DataUri: string;
  out Bytes: TBytes; out MimeType: string): Boolean;
begin
  Bytes := nil;
  MimeType := EmptyStr;

  var Decoder: TDataUriDecoded;
  Result := TDataUriDecoded.TryDecode(DataUri, Decoder);
  if Result then
    begin
      Bytes := Decoder.Bytes;
      MimeType := Decoder.MimeType;
    end;
end;

class function TMediaCodec.TryDecodeDataUriToFile(const DataUri,
  FilePath: string; out MimeType: string): Boolean;
begin
  MimeType := EmptyStr;

  if FilePath.Trim.IsEmpty then
    Exit(False);

  var Bytes: TBytes;
  if not TryDecodeDataUriToBytes(DataUri, Bytes, MimeType) then
    Exit(False);

  try
    TFile.WriteAllBytes(FilePath, Bytes);
    Result := True;
  except
    MimeType := EmptyStr;
    Result := False;
  end;
end;

class function TMediaCodec.TryDecodeDataUriToStream(const DataUri: string;
  AStream: TStream; out MimeType: string): Boolean;
begin
  MimeType := EmptyStr;

  if AStream = nil then
    Exit(False);

  AStream.Size := 0;
  AStream.Position := 0;

  var Bytes: TBytes;
  if not TryDecodeDataUriToBytes(DataUri, Bytes, MimeType) then
    Exit(False);

  try
    if Length(Bytes) > 0 then
      AStream.WriteBuffer(Bytes[0], Length(Bytes));
    AStream.Position := 0;
    Result := True;
  except
    AStream.Size := 0;
    AStream.Position := 0;
    MimeType := EmptyStr;
    Result := False;
  end;
end;

class function TMediaCodec.TryDecodeDataUriToString(const DataUri: string;
  out Value, MimeType: string; Encoding: TEncoding): Boolean;
begin
  Value := EmptyStr;
  MimeType := EmptyStr;

  if Encoding = nil then
    Encoding := TEncoding.UTF8;

  var Decoder: TDataUriDecoded;
  if not TDataUriDecoded.TryDecode(DataUri, Decoder) then
    Exit(False);

  var LocalEncoding: TEncoding := nil;
  if not Decoder.Charset.Trim.IsEmpty then
    try
      LocalEncoding := TEncoding.GetEncoding(Decoder.Charset);
    except
      LocalEncoding := nil;
    end;

  if LocalEncoding = nil then
    LocalEncoding := Encoding;

  try
    Value := LocalEncoding.GetString(Decoder.Bytes);
    MimeType := Decoder.MimeType;
    Result := True;
  except
    Value := EmptyStr;
    MimeType := EmptyStr;
    Result := False;
  end;

  if (LocalEncoding <> nil) and (LocalEncoding <> Encoding) then
    LocalEncoding.Free;
end;

class function TMediaCodec.TryGetDataUriMimeType(const Value: string;
  out MimeType: string): Boolean;
begin
  MimeType := EmptyStr;

  var Buffer := Value.Trim;
  if not IsDataUri(Buffer) then
    Exit(False);

  var CommaPos := Buffer.IndexOf(',');
  if CommaPos < 0 then
    Exit(False);

  var Header := Buffer.Substring(5, CommaPos - 5);
  if Header.Trim.IsEmpty then
    begin
      MimeType := 'text/plain';
      Exit(True);
    end;

  var Parts := Header.Split([';']);
  var First := Parts[0].Trim;

  if (not First.IsEmpty) and (First.IndexOf('/') > 0) then
    MimeType := NormalizeMimeType(First)
  else
    MimeType := 'text/plain';

  Result := not MimeType.IsEmpty;
end;

class function TMediaCodec.TryToBytes(const FileLocation: string;
  out Bytes: TBytes; out MimeType: string): Boolean;
begin
  Bytes := nil;
  MimeType := EmptyStr;

  var Location := FileLocation.Trim;
  if Location.IsEmpty then
    Exit(False);

  if IsDataUri(Location) then
    Exit(TryDecodeDataUriToBytes(Location, Bytes, MimeType));

  if IsUri(Location) then
    Exit(TryUrlToBytes(Location, Bytes, MimeType));

  if not TFile.Exists(Location) then
    Exit(False);

  Bytes := TFile.ReadAllBytes(Location);
  MimeType := ResolveMimeType(Location);
  Result := True;
end;

class function TMediaCodec.TryToDataUri(const FileLocation: string;
  out DataUri, MimeType: string): Boolean;
begin
  DataUri := EmptyStr;
  MimeType := EmptyStr;

  var Location := FileLocation.Trim;
  if Location.IsEmpty then
    Exit(False);

  if IsDataUri(Location) then
    begin
      var Bytes: TBytes;
      if not TryDecodeDataUriToBytes(Location, Bytes, MimeType) then
        Exit(False);

      DataUri := Location;
      Exit(True);
    end;

  if IsUri(Location) then
    begin
      var Stream := TMemoryStream.Create;
      try
        if not TryUrlToStream(Location, Stream, MimeType) then
          Exit(False);

        DataUri := EncodeDataUri(Stream, MimeType, True);
        Exit(True);
      finally
        Stream.Free;
      end;
    end;

  if not TFile.Exists(Location) then
    Exit(False);

  MimeType := ResolveMimeType(Location);
  DataUri := EncodeDataUri(Location, MimeType, False);
  Result := True;
end;

class function TMediaCodec.TryUrlToBytes(const AUrl: string;
  out Bytes: TBytes; out ContentType: string): Boolean;
begin
  Bytes := nil;
  ContentType := EmptyStr;

  var Stream := TMemoryStream.Create;
  try
    Result := TryUrlToStream(AUrl, Stream, ContentType);
    if not Result then
      Exit(False);

    SetLength(Bytes, Stream.Size);
    if Stream.Size > 0 then
      begin
        Stream.Position := 0;
        Stream.ReadBuffer(Bytes[0], Stream.Size);
      end;
  finally
    Stream.Free;
  end;
end;

class function TMediaCodec.TryUrlToStream(const AUrl: string;
  AStream: TStream; out AContentType: string): Boolean;
begin
  AContentType := EmptyStr;

  if AStream = nil then
    Exit(False);

  AStream.Size := 0;
  AStream.Position := 0;

  var Client := THTTPClient.Create;
  try
    try
      var Response := Client.Get(AUrl, AStream);
      Result := (Response <> nil) and (Response.StatusCode div 100 = 2);

      if Result then
        AContentType := NormalizeMimeType(Response.HeaderValue['Content-Type'])
      else
        AStream.Size := 0;
    except
      AStream.Size := 0;
      Result := False;
    end;
  finally
    AStream.Position := 0;
    Client.Free;
  end;
end;









end.
