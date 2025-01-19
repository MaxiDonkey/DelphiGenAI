unit GenAI.Httpx;

interface

uses
  System.SysUtils, System.Classes, System.Net.URLClient, System.Net.HttpClient,
  System.Net.HttpClientComponent, System.NetEncoding;

type
  /// <summary>
  /// THttpx provides utility methods for handling HTTP-related tasks such as
  /// downloading data, encoding it in Base64, and retrieving MIME types.
  /// </summary>
  THttpx = class
    /// <summary>
    /// Converts the content of a stream into a byte array.
    /// </summary>
    /// <param name="AStream">
    /// The input stream to convert.
    /// </param>
    /// <returns>
    /// A byte array containing the data from the input stream.
    /// </returns>
    /// <exception cref="Exception">
    /// Raises an exception if the input stream is null.
    /// </exception>
    class function StreamToBytes(AStream: TStream): TBytes;
    /// <summary>
    /// Loads data from the specified URL, encodes it in Base64, and retrieves its MIME type.
    /// </summary>
    /// <param name="Url">
    /// The URL to fetch the data from.
    /// </param>
    /// <param name="MimeType">
    /// Outputs the MIME type of the data retrieved from the URL.
    /// </param>
    /// <returns>
    /// A Base64-encoded string representing the data fetched from the URL.
    /// </returns>
    class function LoadDataToBase64(const Url: string; var MimeType: string): string; overload;
    /// <summary>
    /// Loads data from the specified URL, encodes it in Base64.
    /// </summary>
    /// <param name="Url">
    /// The URL to fetch the data from.
    /// </param>
    /// <returns>
    /// A Base64-encoded string representing the data fetched from the URL.
    /// </returns>
    class function LoadDataToBase64(const Url: string): string; overload;
    /// <summary>
    /// Retrieves the MIME type of the content at the specified URL.
    /// </summary>
    /// <param name="Url">
    /// The URL of the content to inspect.
    /// </param>
    /// <returns>
    /// A string representing the MIME type of the content at the URL.
    /// </returns>
    class function GetMimeType(const Url: string): string;
    /// <summary>
    /// Validates the accessibility of a specified URL by performing an HTTP HEAD request.
    /// </summary>
    /// <param name="Url">
    /// The URL to validate.
    /// </param>
    /// <exception cref="Exception">
    /// Raises an exception if the URL is not accessible or the server responds with a non-success status code.
    /// </exception>
    /// <remarks>
    /// This method checks the HTTP status code returned by the server for the given URL.
    /// If the status code indicates an error (e.g., 4xx or 5xx), an exception is raised.
    /// If the status code indicates success (e.g., 200-299), no exception is thrown.
    /// </remarks>
    class procedure UrlCheck(const Url: string);
  end;

implementation

{ THttpx }

class function THttpx.GetMimeType(const Url: string): string;
begin
  var HttpClient := THTTPClient.Create;
  try
    Result := (HttpClient.Head(Url) as IHTTPResponse).MimeType.ToLower;
  finally
    HttpClient.Free;
  end;
end;

class function THttpx.LoadDataToBase64(const Url: string; var MimeType: string): string;
begin
  MimeType := GetMimeType(Url);
  Result := LoadDataToBase64(Url);
end;

class function THttpx.LoadDataToBase64(const Url: string): string;
begin
  var HttpClient := THTTPClient.Create;
  try
    var Response: IHTTPResponse := HttpClient.Get(Url);
    var DataBytes := StreamToBytes(Response.ContentStream);
    {$IF RTLVersion >= 35.0}
    Result := TNetEncoding.Base64String.EncodeBytesToString(DataBytes);
    {$ELSE}
    Result := TNetEncoding.Base64.EncodeBytesToString(ImageBytes);
    {$ENDIF}
  finally
    HttpClient.Free;
  end;
end;

class function THttpx.StreamToBytes(AStream: TStream): TBytes;
var
  LBytesStream: TBytesStream;
begin
  if not Assigned(AStream) then
    raise Exception.Create('StreamToBytes error: stream is null');

  LBytesStream := TBytesStream.Create;
  try
    AStream.Position := 0;
    LBytesStream.CopyFrom(AStream, AStream.Size);
    Result := LBytesStream.Bytes;
    SetLength(Result, LBytesStream.Size);
  finally
    LBytesStream.Free;
  end;
end;

class procedure THttpx.UrlCheck(const Url: string);
begin
  var HttpClient := THTTPClient.Create;
  try
    case (HttpClient.Head(Url) as IHTTPResponse).StatusCode of
      200..299: ;
      else
        raise Exception.CreateFmt('Address not found or inaccessible : %s', [Url]);
    end;
  finally
    HttpClient.Free;
  end;
end;

end.
