unit GenAI.NetEncoding.DataURI;

interface

uses
  System.SysUtils, System.Classes, System.StrUtils,
  GenAI.NetEncoding.Base64;

type
  TDataURI = record
  public
    /// <summary>
    /// Creates a data URI string from a raw byte array and a specified MIME type.
    /// The byte array is base64-encoded and embedded directly into the resulting URI.
    /// Useful for embedding binary data (images, audio, etc.) inline without requiring
    /// external file references.
    /// </summary>
    /// <param name="Data">
    /// The raw bytes to encode into the data URI.
    /// </param>
    /// <param name="MimeType">
    /// The MIME type of the data (e.g., "image/png", "audio/mp3").
    /// </param>
    /// <returns>
    /// A fully-formed data URI using base64 encoding.
    /// </returns>
    class function Create(const Data: TBytes; const MimeType: string): string; overload; static;

    /// <summary>
    /// Creates a data URI string from the contents of a stream and a specified MIME type.
    /// The stream’s data is read, base64-encoded, and embedded directly into the resulting URI.
    /// This is useful for embedding binary content (such as images, audio, or arbitrary files)
    /// inline without relying on external file paths or URLs.
    /// </summary>
    /// <param name="S">
    /// The stream containing the raw data to encode. The stream is read from its current position
    /// until the end.
    /// </param>
    /// <param name="MimeType">
    /// The MIME type of the data (e.g., "image/jpeg", "application/pdf").
    /// </param>
    /// <returns>
    /// A complete data URI string with base64-encoded content.
    /// </returns>
    class function Create(S: TStream; const MimeType: string): string; overload; static;

    /// <summary>
    /// Creates a data URI from a text value.
    /// By default, text is encoded as UTF-8 and embedded as base64, with an explicit charset.
    /// </summary>
    /// <param name="Text">Textual content.</param>
    /// <param name="MimeType">Text MIME type. Defaults to "text/plain".</param>
    /// <param name="Encoding">
    /// Optional encoding (defaults to UTF-8 when nil). The encoding name is exposed via charset=...
    /// </param>
    /// <param name="IncludeBOM">
    /// When True, prepends the encoding preamble (BOM) if any.
    /// </param>
    class function CreateText(const Text: string;
      const MimeType: string = 'text/plain';
      Encoding: TEncoding = nil;
      IncludeBOM: Boolean = False): string; static;
  end;

implementation

{ TDataURI }

class function TDataURI.Create(const Data: TBytes; const MimeType: string): string;
begin
  Result := Format('data:%s;base64,%s', [MimeType.ToLower, BytesToBase64(Data)]);
end;

class function TDataURI.Create(S: TStream; const MimeType: string): string;
begin
  Result := Format('data:%s;base64,%s', [MimeType.ToLower, EncodeBase64(S)]);
end;

class function TDataURI.CreateText(const Text: string; const MimeType: string;
  Encoding: TEncoding; IncludeBOM: Boolean): string;
var
  Enc: TEncoding;
  Data, Bom: TBytes;
  Charset: string;
begin
  Enc := Encoding;
  if Enc = nil then
    Enc := TEncoding.UTF8;

  Data := Enc.GetBytes(Text);

  if IncludeBOM then
    begin
      Bom := Enc.GetPreamble;
      if Length(Bom) > 0 then
        Data := Bom + Data;
    end;

  {--- RTL-portable charset name for data URI }
  Charset := Enc.MimeName;
  if Charset.IsEmpty then
    Charset := 'utf-8';

  Result := Format('data:%s;charset=%s;base64,%s',
    [MimeType.ToLower, Charset.ToLower, BytesToBase64(Data)]);
end;


end.
