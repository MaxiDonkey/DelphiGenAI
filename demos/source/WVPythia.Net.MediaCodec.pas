unit WVPythia.Net.MediaCodec;

interface

uses
  System.SysUtils, System.Classes;

type
  TMediaCodec = record
  private
    /// <summary>
    /// Retrieves the MIME type of a remote resource using an HTTP HEAD request.
    /// </summary>
    class function GetMimeTypeFromURI(const Uri: string): string; static;

    /// <summary>
    /// Resolves the MIME type of a local file based on its extension.
    /// </summary>
    class function ResolveMimeType(const FilePath: string): string; static;

    /// <summary>
    /// Normalizes a MIME type by removing parameters and lower-casing it.
    /// </summary>
    class function NormalizeMimeType(const MimeType: string): string; static;

    /// <summary>
    /// Reads the beginning of a local file without loading it entirely in memory.
    /// </summary>
    class function TryReadFilePrefix(const FilePath: string; const MaxBytes: Integer;
      out Bytes: TBytes): Boolean; static;

    /// <summary>
    /// Checks whether a byte sequence starts with the specified prefix.
    /// </summary>
    class function BytesStartWith(const Bytes: TBytes;
      const Prefix: array of Byte): Boolean; static;

    /// <summary>
    /// Heuristically checks whether a byte sample is textual.
    /// </summary>
    class function BytesLookLikeText(const Bytes: TBytes): Boolean; static;

    /// <summary>
    /// Decodes a byte sample for lightweight textual format detection.
    /// </summary>
    class function TryDecodeTextPrefix(const Bytes: TBytes;
      out Text: string): Boolean; static;

    /// <summary>
    /// Detects a more specific textual MIME type from textual content when possible.
    /// </summary>
    class function DetectTextMimeTypeFromPrefix(const FilePath, FallbackMimeType,
      TextPrefix: string): string; static;

    /// <summary>
    /// Removes all CR and LF characters from a string.
    /// </summary>
    class function StripCrlf(const Value: string): string; static;

    /// <summary>
    /// Normalizes a Base64 string by optionally removing line breaks.
    /// </summary>
    class function NormalizeBase64(const Value: string; const CrLfDeletion: Boolean): string; static;

  public
    /// <summary>
    /// Encodes a file into a Base64 string.
    /// </summary>
    class function EncodeBase64(FilePath: string; const CrLfDeletion: Boolean = False) : string; overload; static;

    /// <summary>
    /// Encodes a text string into Base64 using the specified encoding.
    /// </summary>
    class function EncodeBase64(const Text: string; Encoding: TEncoding;
      const CrLfDeletion: Boolean = True): string; overload; static;

    /// <summary>
    /// Encodes a stream into a Base64 string.
    /// </summary>
    class function EncodeBase64(const Value: TStream; const CrLfDeletion: Boolean = True): string; overload; static;

    /// <summary>
    /// Encodes a byte array into a Base64 string.
    /// </summary>
    class function EncodeBase64(const ABytes: TBytes; const CrLfDeletion: Boolean = True): string; overload; static;

    /// <summary>
    /// Decodes a Base64 string into a text string using the specified encoding.
    /// </summary>
    /// <remarks>
    /// Do NOT use with binary files (images, pdf, etc.).
    /// </remarks>
    class function DecodeBase64ToString(const Base64: string;
      Encoding: TEncoding = nil): string; static;

    /// <summary>
    /// Decodes a Base64 string into a stream.
    /// </summary>
    class function DecodeBase64ToStream(const Base64: string;
      const AStream: TStream): Boolean; static;

    /// <summary>
    /// Decodes a Base64 string into a byte array.
    /// </summary>
    class function DecodeBase64ToBytes(const Base64: string): TBytes; static;

    /// <summary>
    /// Decodes a Base64 string and writes the result to a file.
    /// </summary>
    class function DecodeBase64ToFile(const Base64: string;
      const FilePath: string): Boolean; static;

    /// <summary>
    /// Attempts to decode a Base64 string into a text string.
    /// </summary>
    class function TryDecodeBase64ToString(const Base64: string;
      out Value: string; Encoding: TEncoding = nil): Boolean; static;

    /// <summary>
    /// Attempts to decode a Base64 string into a stream.
    /// </summary>
    class function TryDecodeBase64ToStream(const Base64: string;
      AStream: TStream): Boolean; static;

    /// <summary>
    /// Attempts to decode a Base64 string into a byte array.
    /// </summary>
    class function TryDecodeBase64ToBytes(const Base64: string;
      out Bytes: TBytes): Boolean; static;

    /// <summary>
    /// Attempts to decode a Base64 string and write the result to a file.
    /// </summary>
    class function TryDecodeBase64ToFile(const Base64: string;
      const FilePath: string): Boolean; static;

    {--- RFC 2397 }

    /// <summary>
    /// Encodes text as a Base64 data URI with the specified MIME type.
    /// </summary>
    /// <param name="Text">
    ///   Warning: "Text" must not be base64 encoded
    /// </param>
    /// <remarks>
    /// Text must represent textual content, not decoded binary data.
    /// </remarks>
    class function EncodeDataUri(const Text: string; const MimeType: string;
      Encoding: TEncoding; const CrLfDeletion: Boolean = True): string; overload; static;

    /// <summary>
    /// Encodes a byte array as a Base64 data URI with the specified MIME type.
    /// </summary>
    class function EncodeDataUri(const ABytes: TBytes; const MimeType: string;
      const CrLfDeletion: Boolean = True): string; overload; static;

    /// <summary>
    /// Encodes a stream as a Base64 data URI with the specified MIME type.
    /// </summary>
    class function EncodeDataUri(const Value: TStream; const MimeType: string;
      const CrLfDeletion: Boolean = True): string; overload; static;

    /// <summary>
    /// Encodes a file as a Base64 data URI with the specified MIME type.
    /// </summary>
    class function EncodeDataUri(const FilePath: string; const MimeType: string;
      const CrLfDeletion: Boolean = False): string; overload; static;

    /// <summary>
    /// Attempts to decode a data URI into a byte array.
    /// </summary>
    class function TryDecodeDataUriToBytes(const DataUri: string;
      out Bytes: TBytes; out MimeType: string): Boolean; static;

    /// <summary>
    /// Attempts to decode a data URI into a stream.
    /// </summary>
    class function TryDecodeDataUriToStream(const DataUri: string;
      AStream: TStream; out MimeType: string): Boolean; static;

    /// <summary>
    /// Attempts to decode a data URI into a text string.
    /// </summary>
    class function TryDecodeDataUriToString(const DataUri: string;
      out Value: string; out MimeType: string; Encoding: TEncoding): Boolean; static;

    /// <summary>
    /// Attempts to decode a data URI and write the result to a file.
    /// </summary>
    class function TryDecodeDataUriToFile(const DataUri: string;
      const FilePath: string; out MimeType: string): Boolean; static;

    /// <summary>
    /// Determines whether a string represents an HTTP or HTTPS URL.
    /// </summary>
    class function IsUri(const FilePath: string): Boolean; static;

    /// <summary>
    /// Gets the MIME type of a local file or remote URL.
    /// </summary>
    class function GetMimeType(const FileLocation: string): string; static;

    /// <summary>
    /// Determines whether a MIME type denotes textual content.
    /// </summary>
    class function IsTextualMimeType(const MimeType: string): Boolean; static;

    /// <summary>
    /// Resolves the MIME type of a local file only if its actual content is textual.
    /// </summary>
    class function TryResolveMimeTypeAsText(const FilePath: string;
      out MimeType: string): Boolean; static;

    /// <summary>
    /// Gets the size of a local file in bytes.
    /// </summary>
    class function GetFileSize(const FilePath: string): Int64; static;

    /// <summary>
    /// Attempts to resolve any supported location (file, URL, or data URI) into raw bytes.
    /// </summary>
    class function TryToBytes(const FileLocation: string;
      out Bytes: TBytes; out MimeType: string): Boolean; static;

    /// <summary>
    /// Attempts to convert a file, URL, or data URI into a Base64 data URI.
    /// </summary>
    class function TryToDataUri(const FileLocation: string;
      out DataUri: string; out MimeType: string): Boolean; static;

    /// <summary>
    /// Downloads a remote URL into a stream and returns its content type.
    /// </summary>
    class function TryUrlToStream(const AUrl: string; AStream: TStream; out AContentType: string): Boolean; static;

    /// <summary>
    /// Downloads a remote URL into a byte array and returns its content type.
    /// </summary>
    class function TryUrlToBytes(const AUrl: string;
      out Bytes: TBytes; out ContentType: string): Boolean; static;

    class function ToDataURI(const FileName: string): string; static;
  end;

implementation

uses
  System.Net.Mime, System.NetEncoding, System.Net.HttpClient, System.Net.URLClient,
  System.IOUtils;

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
    class function StripWhitespaceAscii(const S: string): string; static;

    class procedure ParseHeader(const Header: string;
      out MimeType: string;
      out Charset: string;
      out IsBase64: Boolean); static;

    procedure Clear;
  public
    property MimeType: string read FMimeType;
    property Charset: string read FCharset;
    property IsBase64: Boolean read FIsBase64;
    property Bytes: TBytes read FBytes;

    class function TryDecode(const DataUri: string; out Decoder: TDataUriDecoded): Boolean; static;
  end;

{ TDataUriDecoded }

class function TDataUriDecoded.DefaultMimeType: string;
begin
  Result := 'text/plain';
end;

class function TDataUriDecoded.DefaultCharset: string;
begin
  Result := 'US-ASCII';
end;

procedure TDataUriDecoded.Clear;
begin
  FMimeType := EmptyStr;
  FCharset := EmptyStr;
  FIsBase64 := False;
  FBytes := nil;
end;

class function TDataUriDecoded.StartsWithDataPrefix(const Value: string): Boolean;
begin
  Result := (Value.Length >= 5) and SameText(Value.Substring(0, 5), 'data:');
end;

class function TDataUriDecoded.StripWhitespaceAscii(const S: string): string;
begin
  {--- Base64 may tolerate CR/LF; remove common ASCII whitespace. }
  var StringBuilder := TStringBuilder.Create(S.Length);

  try
    for var i := 1 to S.Length do
      begin
        var C := S[i];

        case C of
          #9, #10, #13, ' ':
            Continue;
        else
          StringBuilder.Append(C);
        end;

      end;
    Result := StringBuilder.ToString;
  finally
    StringBuilder.Free;
  end;
end;

class function TDataUriDecoded.HexNibble(const C: Char; out ByteValue: Byte): Boolean;
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

class function TDataUriDecoded.TryPercentDecodeToBytes(const Value: string; out Bytes: TBytes): Boolean;
var
  hi, lo: Byte;
begin
  Bytes := nil;

  {--- RFC2397 (non-base64): payload is a sequence of potentially %HH-encoded bytes.
       Bytes are generated DIRECTLY, without going through string->encoding. }
  SetLength(Bytes, Value.Length);
  var Count := 0;
  var Index := 1;

  while Index <= Value.Length do
    begin
      var ch := Value[Index];

      if ch = '%' then
        begin
          if (Index + 2 > Value.Length) then
            begin
              Bytes := nil;
              Exit(False);
            end;

          if not HexNibble(Value[Index + 1], hi) then
            begin
              Bytes := nil;
              Exit(False);
            end;

          if not HexNibble(Value[Index + 2], lo) then
            begin
              Bytes := nil;
              Exit(False);
            end;

          Bytes[Count] := Byte((hi shl 4) or lo);
          Inc(Count);
          Inc(Index, 3);
          Continue;
        end;

      {--- RFC2397 non-base64: non-escaped characters must be US-ASCII. }
      if Ord(ch) > $FF then
        begin
          Bytes := nil;
          Exit(False);
        end;

      Bytes[Count] := Byte(Ord(ch) and $FF);
      Inc(Count);
      Inc(Index);
    end;

  SetLength(Bytes, Count);
  Result := True;
end;

class procedure TDataUriDecoded.ParseHeader(const Header: string;
  out MimeType: string;
  out Charset: string;
  out IsBase64: Boolean);
begin
  {--- Defaults RFC2397 }
  MimeType := DefaultMimeType;
  Charset := DefaultCharset;
  IsBase64 := False;

  if Header.Trim.IsEmpty then
    Exit;

  var Parts := Header.Split([';']);

  {--- The first segment could be the media type (type/subtype). }
  var First := Parts[0].Trim;
  if (First <> '') and (First.IndexOf('/') > 0) then
    MimeType := First;

  {--- Iterate over all parameters }
  for var i := 0 to High(Parts) do
    begin
      var P := Parts[i].Trim;
      if P.IsEmpty then
        Continue;

      var LowerP := P.ToLower;

      if SameText(P, 'base64') then
        begin
          IsBase64 := True;
          Continue;
        end;

      if LowerP.StartsWith('charset=') then
        begin
          Charset := P.Substring(Length('charset=')).Trim;

          {--- Remove optional quotes }
          Charset := Charset.Trim(['"', '''']);
          Continue;
        end;

      {--- Other parameters are ignored (name=, boundary=, etc.) }
    end;
end;

class function TDataUriDecoded.TryDecode(const DataUri: string; out Decoder: TDataUriDecoded): Boolean;
begin
  Decoder.Clear;

  var Buffer := DataUri.Trim;
  if not StartsWithDataPrefix(Buffer) then
    Exit(False);

  var CommaPos := Buffer.IndexOf(',');
  if CommaPos < 0 then
    Exit(False);

  {--- Data: is 5 characters; the header is between data: and the comma (excluded)
       -> Header may be empty }
  var Header := Buffer.Substring(5, CommaPos - 5);

  {--- Do not trim: binary / percent-encoded / base64 content }
  var Payload := Buffer.Substring(CommaPos + 1);

  ParseHeader(Header, Decoder.FMimeType, Decoder.FCharset, Decoder.FIsBase64);

  try
    if Decoder.FIsBase64 then
      begin
        {--- Base64 -> bytes }
        var Clean := StripWhitespaceAscii(Payload);
        Decoder.FBytes := TNetEncoding.Base64.DecodeStringToBytes(Clean);
        Exit(True);
      end
    else
      begin
        {--- RFC2397 non-base64 -> percent-decode -> bytes }
        Exit(TryPercentDecodeToBytes(Payload, Decoder.FBytes));
      end;
  except
    Decoder.Clear;
    Exit(False);
  end;
end;

{ TMediaCodec  }

class function TMediaCodec.BytesLookLikeText(const Bytes: TBytes): Boolean;
var
  I: Integer;
  B: Byte;
  ZeroCount: Integer;
  OddZeroCount: Integer;
  EvenZeroCount: Integer;
  ControlCount: Integer;
begin
  if Length(Bytes) = 0 then
    Exit(True);

  if BytesStartWith(Bytes, [$EF, $BB, $BF]) or
     BytesStartWith(Bytes, [$FF, $FE]) or
     BytesStartWith(Bytes, [$FE, $FF]) then
    Exit(True);

  ZeroCount := 0;
  OddZeroCount := 0;
  EvenZeroCount := 0;
  ControlCount := 0;

  for I := 0 to High(Bytes) do
  begin
    B := Bytes[I];

    if B = 0 then
    begin
      Inc(ZeroCount);

      if Odd(I) then
        Inc(OddZeroCount)
      else
        Inc(EvenZeroCount);

      Continue;
    end;

    if (B < 32) and
       not ((B = 9) or (B = 10) or (B = 12) or (B = 13) or (B = 26)) then
      Inc(ControlCount);
  end;

  // UTF-16 without BOM: many zero bytes on the same byte lane.
  if (Length(Bytes) >= 8) and
     ((OddZeroCount > Length(Bytes) div 4) or
      (EvenZeroCount > Length(Bytes) div 4)) then
    Exit(True);

  // Other NUL bytes are a strong binary signal.
  if ZeroCount > 0 then
    Exit(False);

  // Accept normal text controls: tab, LF, FF, CR, EOF marker.
  Result := (ControlCount * 100) <= (Length(Bytes) * 5);
end;

class function TMediaCodec.BytesStartWith(const Bytes: TBytes;
  const Prefix: array of Byte): Boolean;
var
  I: Integer;
begin
  if Length(Bytes) < Length(Prefix) then
    Exit(False);

  for I := 0 to High(Prefix) do
    if Bytes[I] <> Prefix[I] then
      Exit(False);

  Result := True;
end;

class function TMediaCodec.DetectTextMimeTypeFromPrefix(const FilePath,
  FallbackMimeType, TextPrefix: string): string;
var
  S: string;
  Lower: string;
  Ext: string;
begin
  Result := NormalizeMimeType(FallbackMimeType);

  if IsTextualMimeType(Result) then
    Exit;

  S := TextPrefix.TrimLeft;

  if S.IsEmpty then
    Exit('text/plain');

  if S[1] = #$FEFF then
    S := S.Substring(1).TrimLeft;

  Lower := S.ToLower;
  Ext := LowerCase(ExtractFileExt(FilePath));

  if Lower.StartsWith('<!doctype html') or
     Lower.StartsWith('<html') or
     Lower.StartsWith('<html ') then
    Exit('text/html');

  if Lower.StartsWith('<?xml') then
    Exit('application/xml');

  if ((Ext = '.xml') or (Ext = '.xsd') or (Ext = '.xsl') or
      (Ext = '.xslt') or (Ext = '.svg')) and
     Lower.StartsWith('<') and Lower.Contains('>') then
    Exit('application/xml');

  if ((Ext = '.json') or (Ext = '.map')) and
     (Lower.StartsWith('{') or Lower.StartsWith('[')) then
    Exit('application/json');

  if ((Ext = '.htm') or (Ext = '.html')) and
     Lower.StartsWith('<') and Lower.Contains('>') then
    Exit('text/html');

  if ((Ext = '.dot') or (Ext = '.gv')) and
     (Lower.StartsWith('digraph ') or
      Lower.StartsWith('digraph{') or
      Lower.StartsWith('graph ') or
      Lower.StartsWith('graph{') or
      Lower.StartsWith('strict digraph ') or
      Lower.StartsWith('strict digraph{') or
      Lower.StartsWith('strict graph ') or
      Lower.StartsWith('strict graph{')) then
    Exit('text/vnd.graphviz');

  Result := 'text/plain';
end;

class function TMediaCodec.DecodeBase64ToBytes(
  const Base64: string): TBytes;
begin
  var Buffer := StripCrlf(Base64);

  Result := TNetEncoding.Base64.DecodeStringToBytes(Buffer);
end;

class function TMediaCodec.DecodeBase64ToFile(const Base64,
  FilePath: string): Boolean;
begin
  Result := False;

  if FilePath.Trim.IsEmpty then
    Exit;

  try
    var Bytes := DecodeBase64ToBytes(Base64);
    TFile.WriteAllBytes(FilePath, Bytes);
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

  var Bytes := DecodeBase64ToBytes(Base64);
  Result := Encoding.GetString(Bytes);
end;

class function TMediaCodec.EncodeBase64(const ABytes: TBytes;
  const CrLfDeletion: Boolean): string;
begin
  Result := TNetEncoding.Base64.EncodeBytesToString(ABytes);

  Result := NormalizeBase64(Result, CrLfDeletion);
end;

class function TMediaCodec.EncodeBase64(const Text: string;
  Encoding: TEncoding;
  const CrLfDeletion: Boolean): string;
begin
  if Encoding = nil then
    Encoding := TEncoding.UTF8;

  Result := EncodeBase64(Encoding.GetBytes(Text), CrLfDeletion);
end;

class function TMediaCodec.EncodeBase64(const Value: TStream;
  const CrLfDeletion: Boolean): string;
var
  Bytes: TBytes;
begin
  if Value = nil then
    Exit(EmptyStr);

  var SavedPos := Value.Position;
  try
    Value.Position := 0;

    var Length := Value.Size - Value.Position;
    if Length <= 0 then
      Exit(EmptyStr);

    SetLength(Bytes, Length);
    Value.ReadBuffer(Bytes[0], Length);

    Result := EncodeBase64(Bytes, CrLfDeletion);
  finally
    Value.Position := SavedPos;
  end;
end;

class function TMediaCodec.EncodeBase64(FilePath: string;
  const CrLfDeletion: Boolean): string;
begin
  if not FileExists(FilePath) then
    raise Exception.CreateFmt('File not found : %s', [FilePath]);

  var Stream := TMemoryStream.Create;
  var StreamOutput := TStringStream.Create('', TEncoding.UTF8);

  try
    Stream.LoadFromFile(FilePath);
    Stream.Position := 0;

    {$IF RTLVersion >= 35.0}
    TNetEncoding.Base64String.Encode(Stream, StreamOutput);
    {$ELSE}
    TNetEncoding.Base64.Encode(Stream, StreamOutput);
    {$ENDIF}

    Result := NormalizeBase64(StreamOutput.DataString, CrLfDeletion);

  finally
    Stream.Free;
    StreamOutput.Free;
  end;
end;

class function TMediaCodec.EncodeDataUri(const Value: TStream;
  const MimeType: string; const CrLfDeletion: Boolean): string;
begin
  if MimeType.Trim.IsEmpty then
    raise Exception.Create('MimeType is empty');

  Result := 'data:' + MimeType.Trim + ';base64,' + EncodeBase64(Value, CrLfDeletion);
end;

class function TMediaCodec.EncodeDataUri(const ABytes: TBytes;
  const MimeType: string; const CrLfDeletion: Boolean): string;
begin
  if MimeType.Trim.IsEmpty then
    raise Exception.Create('MimeType is empty');

  Result := 'data:' + MimeType.Trim + ';base64,' + EncodeBase64(ABytes, CrLfDeletion);
end;

class function TMediaCodec.EncodeDataUri(const Text, MimeType: string;
  Encoding: TEncoding; const CrLfDeletion: Boolean): string;
begin
  if MimeType.Trim.IsEmpty then
    raise Exception.Create('MimeType is empty');

  if Encoding = nil then
    Encoding := TEncoding.UTF8;

  Result := 'data:' + MimeType.Trim + ';base64,' + EncodeBase64(Text, Encoding, CrLfDeletion);
end;

class function TMediaCodec.EncodeDataUri(const FilePath, MimeType: string;
  const CrLfDeletion: Boolean): string;
begin
  if MimeType.Trim.IsEmpty then
    raise Exception.Create('MimeType is empty');

  Result := 'data:' + MimeType.Trim + ';base64,' + EncodeBase64(FilePath, CrLfDeletion);
end;

class function TMediaCodec.GetFileSize(const FilePath: string): Int64;
begin
  Result := TFile.GetSize(FilePath);
end;

class function TMediaCodec.GetMimeType(const FileLocation: string): string;
begin
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
        Result := Response.HeaderValue['Content-Type'];
    except
      Result := EmptyStr;
    end;
  finally
    Client.Free;
  end;
end;

class function TMediaCodec.IsTextualMimeType(const MimeType: string): Boolean;
var
  M: string;
begin
  M := NormalizeMimeType(MimeType);

  if M.IsEmpty then
    Exit(False);

  if M.StartsWith('text/') then
    Exit(True);

  if M.EndsWith('+xml') or
     M.EndsWith('+json') or
     M.EndsWith('+yaml') then
    Exit(True);

  Result :=
    SameText(M, 'application/xml') or
    SameText(M, 'application/json') or
    SameText(M, 'application/yaml') or
    SameText(M, 'application/x-yaml') or
    SameText(M, 'application/javascript') or
    SameText(M, 'application/ecmascript') or
    SameText(M, 'application/x-javascript') or
    SameText(M, 'application/x-www-form-urlencoded') or
    SameText(M, 'application/sql') or
    SameText(M, 'application/graphql') or
    SameText(M, 'application/toml') or
    SameText(M, 'application/x-toml') or
    SameText(M, 'application/rtf') or
    SameText(M, 'application/vnd.chipnuts.karaoke-mmd');
end;

class function TMediaCodec.IsUri(const FilePath: string): Boolean;
begin
  var Lower := FilePath.ToLower;
  Result := Lower.StartsWith('http://') or
            Lower.StartsWith('https://');
end;

class function TMediaCodec.NormalizeBase64(const Value: string;
  const CrLfDeletion: Boolean): string;
begin
  if CrLfDeletion then
    Exit(StripCrlf(Value));

  Result := Value;
end;

class function TMediaCodec.NormalizeMimeType(const MimeType: string): string;
var
  P: Integer;
begin
  Result := MimeType.Trim;

  P := Pos(';', Result);
  if P > 0 then
    Result := Copy(Result, 1, P - 1).Trim;

  Result := Result.ToLower;
end;

class function TMediaCodec.TryDecodeTextPrefix(const Bytes: TBytes;
  out Text: string): Boolean;
begin
  Text := EmptyStr;

  try
    if Length(Bytes) = 0 then
      Exit(True);

    if BytesStartWith(Bytes, [$EF, $BB, $BF]) then
      Text := TEncoding.UTF8.GetString(Bytes, 3, Length(Bytes) - 3)
    else if BytesStartWith(Bytes, [$FF, $FE]) then
      Text := TEncoding.Unicode.GetString(Bytes, 2, Length(Bytes) - 2)
    else if BytesStartWith(Bytes, [$FE, $FF]) then
      Text := TEncoding.BigEndianUnicode.GetString(Bytes, 2, Length(Bytes) - 2)
    else
      Text := TEncoding.UTF8.GetString(Bytes);

    Result := True;
  except
    Text := EmptyStr;
    Result := False;
  end;
end;

class function TMediaCodec.TryReadFilePrefix(const FilePath: string;
  const MaxBytes: Integer; out Bytes: TBytes): Boolean;
var
  Stream: TFileStream;
  Count: Integer;
begin
  Result := False;
  Bytes := nil;

  if (MaxBytes <= 0) or not TFile.Exists(FilePath) then
    Exit;

  try
    Stream := TFileStream.Create(FilePath, fmOpenRead or fmShareDenyNone);
    try
      if Stream.Size <= 0 then
      begin
        Bytes := nil;
        Exit(True);
      end;

      if Stream.Size > MaxBytes then
        Count := MaxBytes
      else
        Count := Integer(Stream.Size);

      SetLength(Bytes, Count);

      if Count > 0 then
        Stream.ReadBuffer(Bytes[0], Count);

      Result := True;
    finally
      Stream.Free;
    end;
  except
    Bytes := nil;
    Result := False;
  end;
end;

class function TMediaCodec.TryResolveMimeTypeAsText(const FilePath: string;
  out MimeType: string): Boolean;
const
  TextProbeMaxBytes = 64 * 1024;
var
  Bytes: TBytes;
  TextPrefix: string;
  ResolvedMimeType: string;
begin
  Result := False;
  MimeType := EmptyStr;

  if not TFile.Exists(FilePath) then
    Exit;

  ResolvedMimeType := NormalizeMimeType(ResolveMimeType(FilePath));

  if not TryReadFilePrefix(FilePath, TextProbeMaxBytes, Bytes) then
    Exit;

  if not BytesLookLikeText(Bytes) then
    Exit;

  if not TryDecodeTextPrefix(Bytes, TextPrefix) then
    Exit;

  MimeType := DetectTextMimeTypeFromPrefix(FilePath, ResolvedMimeType, TextPrefix);
  Result := IsTextualMimeType(MimeType);
end;

class function TMediaCodec.ResolveMimeType(
  const FilePath: string): string;
var
  LKind: TMimeTypes.TKind;
begin
  if not FileExists(FilePath) then
    raise Exception.CreateFmt('File not found: %s', [FilePath]);

  TMimeTypes.Default.GetFileInfo(FilePath, Result, LKind);
end;

class function TMediaCodec.StripCrlf(const Value: string): string;
begin
  Result := Value.Replace(#13, '').Replace(#10, '');
end;

class function TMediaCodec.ToDataURI(const FileName: string): string;
begin
  var MimeType := TMediaCodec.GetMimeType(FileName);
  Result := TMediaCodec.EncodeDataUri(FileName, MimeType);
end;

class function TMediaCodec.TryDecodeBase64ToBytes(const Base64: string;
  out Bytes: TBytes): Boolean;
begin
  Bytes := nil;

  try
    var Clean := StripCrlf(Base64);
    Bytes := TNetEncoding.Base64.DecodeStringToBytes(Clean);
    Result := True;
  except
    Bytes := nil;
    Result := False;
  end;
end;

class function TMediaCodec.TryDecodeBase64ToFile(const Base64,
  FilePath: string): Boolean;
var
  Bytes: TBytes;
begin
  Result := False;

  if FilePath.Trim.IsEmpty then
    Exit;

  if not TryDecodeBase64ToBytes(Base64, Bytes) then
    Exit;

  try
    TFile.WriteAllBytes(FilePath, Bytes);
    Result := True;
  except
    Result := False;
  end;
end;

class function TMediaCodec.TryDecodeBase64ToStream(const Base64: string;
  AStream: TStream): Boolean;
var
  Bytes: TBytes;
begin
  Result := False;

  if AStream = nil then
    Exit;

  AStream.Size := 0;
  AStream.Position := 0;

  if not TryDecodeBase64ToBytes(Base64, Bytes) then
    Exit;

  try
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

class function TMediaCodec.TryDecodeBase64ToString(const Base64: string;
  out Value: string; Encoding: TEncoding): Boolean;
var
  Bytes: TBytes;
begin
  Result := False;
  Value := EmptyStr;

  if Encoding = nil then
    Encoding := TEncoding.UTF8;

  if not TryDecodeBase64ToBytes(Base64, Bytes) then
    Exit;

  try
    Value := Encoding.GetString(Bytes);
    Result := True;
  except
    Value := EmptyStr;
    Result := False;
  end;
end;

class function TMediaCodec.TryDecodeDataUriToBytes(const DataUri: string;
  out Bytes: TBytes; out MimeType: string): Boolean;
var
  Decoder: TDataUriDecoded;
begin
  Bytes := nil;
  MimeType := EmptyStr;

  Result := TDataUriDecoded.TryDecode(DataUri, Decoder);
  if Result then
    begin
      Bytes := Decoder.Bytes;
      MimeType := Decoder.MimeType;
    end;
end;

class function TMediaCodec.TryDecodeDataUriToFile(
  const DataUri, FilePath: string; out MimeType: string): Boolean;
var
  Decoder: TDataUriDecoded;
begin
  MimeType := EmptyStr;

  if FilePath.Trim.IsEmpty then
    Exit(False);

  Result := TDataUriDecoded.TryDecode(DataUri, Decoder);
  if not Result then
    Exit(False);

  try
    TFile.WriteAllBytes(FilePath, Decoder.Bytes);
    MimeType := Decoder.MimeType;
    Result := True;
  except
    MimeType := EmptyStr;
    Result := False;
  end;
end;

class function TMediaCodec.TryDecodeDataUriToStream(const DataUri: string;
  AStream: TStream; out MimeType: string): Boolean;
var
  Decoder: TDataUriDecoded;
begin
  MimeType := EmptyStr;

  if AStream = nil then
    Exit(False);

  AStream.Size := 0;
  AStream.Position := 0;

  Result := TDataUriDecoded.TryDecode(DataUri, Decoder);
  if not Result then
    Exit(False);

  try
    if Length(Decoder.Bytes) > 0 then
      AStream.WriteBuffer(Decoder.Bytes[0], Length(Decoder.Bytes));
    AStream.Position := 0;
    MimeType := Decoder.MimeType;
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
var
  Decoder: TDataUriDecoded;
  LocalEncoding: TEncoding;
begin
  Value := EmptyStr;
  MimeType := EmptyStr;

  if Encoding = nil then
    Encoding := TEncoding.UTF8;

  if not TDataUriDecoded.TryDecode(DataUri, Decoder) then
    Exit(False);

  {--- Encoding selection: use the Data URI charset if available, otherwise fall back }
  LocalEncoding := nil;
  if not Decoder.Charset.Trim.IsEmpty then
    begin
      try
        {--- Important: GetEncoding(...) may allocate   it must be freed if it is not a singleton }
        LocalEncoding := TEncoding.GetEncoding(Decoder.Charset);
      except
        LocalEncoding := nil;
      end;
    end;

  if LocalEncoding = nil then
    begin
      LocalEncoding := Encoding;
      try
        Value := LocalEncoding.GetString(Decoder.Bytes);
        MimeType := Decoder.MimeType;
        Exit(True);
      except
        Value := EmptyStr;
        MimeType := EmptyStr;
        Exit(False);
      end;
    end;

  {--- LocalEncoding was created via GetEncoding. It must be freed. }
  try
    try
      Value := LocalEncoding.GetString(Decoder.Bytes);
      MimeType := Decoder.MimeType;
      Result := True;
    except
      Value := EmptyStr;
      MimeType := EmptyStr;
      Result := False;
    end;
  finally
    LocalEncoding.Free;
  end;
end;

class function TMediaCodec.TryToBytes(const FileLocation: string;
  out Bytes: TBytes; out MimeType: string): Boolean;
begin
  Bytes := nil;
  MimeType := EmptyStr;

  var Location := FileLocation.Trim;
  if Location.IsEmpty then
    Exit(False);

  if (Location.Length >= 5) and SameText(Location.Substring(0, 5), 'data:') then
    Exit(TryDecodeDataUriToBytes(Location, Bytes, MimeType));

  if IsUri(Location) then
    begin
      var Stream := TMemoryStream.Create;
      try
        if not TryUrlToStream(Location, Stream, MimeType) then
          Exit(False);

        SetLength(Bytes, Stream.Size);
        if Stream.Size > 0 then
          begin
            Stream.Position := 0;
            Stream.ReadBuffer(Bytes[0], Stream.Size);
          end;

        Exit(True);
      finally
        Stream.Free;
      end;
    end;

  if not TFile.Exists(Location) then
    Exit(False);

  Bytes := TFile.ReadAllBytes(Location);
  try
    MimeType := ResolveMimeType(Location);
  except
    MimeType := EmptyStr;
  end;

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

  if (Location.Length >= 5) and SameText(Location.Substring(0, 5), 'data:') then
    begin
      {--- Already a data URI: validate + extract mimetype }
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

  try
    MimeType := ResolveMimeType(Location);
  except
    MimeType := EmptyStr;
  end;

  if MimeType.Trim.IsEmpty then
    Exit(False);

  DataUri := EncodeDataUri(Location, MimeType, False);
  Result := True;
end;

class function TMediaCodec.TryUrlToBytes(const AUrl: string;
  out Bytes: TBytes; out ContentType: string): Boolean;
begin
  Bytes := nil;
  ContentType := EmptyStr;

  var Url := AUrl.Trim;
  if Url.IsEmpty then
    Exit(False);

  var Stream := TMemoryStream.Create;
  try
    Result := TryUrlToStream(Url, Stream, ContentType);
    if not Result then
      Exit(False);

    SetLength(Bytes, Stream.Size);
    if Stream.Size > 0 then
      begin
        Stream.Position := 0;
        Stream.ReadBuffer(Bytes[0], Stream.Size);
      end;

    Result := True;
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
          AContentType := Response.HeaderValue['Content-Type']
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
