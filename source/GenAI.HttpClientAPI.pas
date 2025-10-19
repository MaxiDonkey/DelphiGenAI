unit GenAI.HttpClientAPI;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGenAI
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.SysUtils, System.Classes, System.Net.HttpClient, System.Net.URLClient,
  System.Net.Mime, System.JSON, System.NetConsts, GenAI.API.Params, GenAI.HttpClientInterface;

type
  /// <summary>
  /// Provides an implementation of the <c>IHttpClientAPI</c> interface using Delphi's <c>THTTPClient</c>.
  /// </summary>
  /// <remarks>
  /// This class facilitates making HTTP requests such as GET, POST, DELETE, and PATCH
  /// by wrapping Delphi's <c>THTTPClient</c> and adhering to the <c>IHttpClientAPI</c> interface.
  /// It supports setting timeouts, proxy configurations, and handling response callbacks.
  /// </remarks>
  THttpClientAPI = class(TInterfacedObject, IHttpClientAPI)
  private
    FHttpClient: THttpClient;
    FCheckSettingsProc: TProc;
    procedure SetSendTimeOut(const Value: Integer);
    function GetSendTimeOut: Integer;
    function GetConnectionTimeout: Integer;
    procedure SetConnectionTimeout(const Value: Integer);
    function GetResponseTimeout: Integer;
    procedure SetResponseTimeout(const Value: Integer);
    function GetProxySettings: TProxySettings;
    procedure SetProxySettings(const Value: TProxySettings);
    procedure CheckAPISettings; virtual;
  public
    /// <summary>
    /// Sends an HTTP GET request to the specified URL.
    /// </summary>
    /// <param name="URL">
    /// The endpoint URL to send the GET request to.
    /// </param>
    /// <param name="Response">
    /// A string stream to capture the response content.
    /// </param>
    /// <param name="Headers">
    /// A list of HTTP headers to include in the request.
    /// </param>
    /// <returns>
    /// The HTTP status code returned by the server.
    /// </returns>
    function Get(const URL: string; Response: TStringStream; const Headers: TNetHeaders): Integer; overload;

    /// <summary>
    /// Sends an HTTP GET request to the specified URL.
    /// </summary>
    /// <param name="URL">
    /// The endpoint URL to send the GET request to.
    /// </param>
    /// <param name="Response">
    /// A stream to capture the binary response content.
    /// </param>
    /// <param name="Headers">
    /// A list of HTTP headers to include in the request.
    /// </param>
    /// <returns>
    /// The HTTP status code returned by the server.
    /// </returns>
    function Get(const URL: string; const Response: TStream; const Headers: TNetHeaders): Integer; overload;

    /// <summary>
    /// Executes an HTTP GET request that explicitly follows 3xx redirects and streams the
    /// final response body into <paramref name="Response"/>. This method is designed for
    /// endpoints returning a redirect to a temporary or signed URL, where the
    /// <c>Authorization</c> header must optionally be removed on redirected requests.
    /// </summary>
    /// <param name="URL">
    /// The initial request URL. If the server returns a redirect (301, 302, 303, 307, or 308),
    /// the method resolves and follows the <c>Location</c> header.
    /// </param>
    /// <param name="Response">
    /// Destination stream that receives the body of the final response. The stream is cleared
    /// and reset before each request. The caller is responsible for managing the stream lifetime.
    /// </param>
    /// <param name="Headers">
    /// HTTP headers included in the initial request (for example, <c>Authorization</c> or
    /// organization identifiers). If <paramref name="DropAuthorizationOnRedirect"/> is <c>True</c>,
    /// the <c>Authorization</c> header is removed from redirected requests.
    /// </param>
    /// <param name="DropAuthorizationOnRedirect">
    /// When <c>True</c> (default), removes the <c>Authorization</c> header for redirected requests.
    /// This prevents authentication errors when the redirect target is a temporary signed URL.
    /// </param>
    /// <param name="MaxRedirects">
    /// Maximum number of redirects to follow before aborting the operation. The default is 5.
    /// </param>
    /// <returns>
    /// The HTTP status code of the final response (for example, 200 on success).
    /// </returns>
    /// <remarks>
    /// <para>
    /// The HTTP client’s automatic redirect handling is disabled to allow explicit control of
    /// header propagation. Redirects are followed manually until a non-redirect status is received
    /// or the limit defined by <paramref name="MaxRedirects"/> is reached.
    /// </para>
    /// <para>
    /// Only the body of the final response is written into <paramref name="Response"/>.
    /// Intermediate redirect responses are ignored.
    /// </para>
    /// <para>
    /// Typical use case: downloading binary content (e.g., MP4 video or image files)
    /// from an API that issues a 302 redirect to a signed short-lived URL.
    /// </para>
    /// </remarks>
    function GetFollowRedirect(const URL: string; const Response: TStream; const Headers: TNetHeaders;
      const DropAuthorizationOnRedirect: Boolean = True;
      const MaxRedirects: Integer = 5): Integer;

    /// <summary>
    /// Sends an HTTP DELETE request to the specified URL.
    /// </summary>
    /// <param name="URL">
    /// The endpoint URL to send the DELETE request to.
    /// </param>
    /// <param name="Response">
    /// A string stream to capture the response content.
    /// </param>
    /// <param name="Headers">
    /// A list of HTTP headers to include in the request.
    /// </param>
    /// <returns>
    /// The HTTP status code returned by the server.
    /// </returns>
    function Delete(const URL: string; Response: TStringStream; const Headers: TNetHeaders): Integer;

    /// <summary>
    /// Sends an HTTP POST request to the specified URL.
    /// </summary>
    /// <param name="URL">
    /// The endpoint URL to send the POST request to.
    /// </param>
    /// <param name="Response">
    /// A string stream to capture the response content.
    /// </param>
    /// <param name="Headers">
    /// A list of HTTP headers to include in the request.
    /// </param>
    /// <returns>
    /// The HTTP status code returned by the server.
    /// </returns>
    function Post(const URL: string; Response: TStringStream; const Headers: TNetHeaders): Integer; overload;

    /// <summary>
    /// Sends an HTTP POST request with multipart form data to the specified URL.
    /// </summary>
    /// <param name="URL">
    /// The endpoint URL to send the POST request to.
    /// </param>
    /// <param name="Body">
    /// The multipart form data to include in the POST request.
    /// </param>
    /// <param name="Response">
    /// A string stream to capture the response content.
    /// </param>
    /// <param name="Headers">
    /// A list of HTTP headers to include in the request.
    /// </param>
    /// <returns>
    /// The HTTP status code returned by the server.
    /// </returns>
    function Post(const URL: string; Body: TMultipartFormData; Response: TStringStream; const Headers: TNetHeaders): Integer; overload;

    /// <summary>
    /// Sends an HTTP POST request with a JSON body to the specified URL and handles streamed responses.
    /// </summary>
    /// <param name="URL">
    /// The endpoint URL to send the POST request to.
    /// </param>
    /// <param name="Body">
    /// The JSON object to include in the POST request body.
    /// </param>
    /// <param name="Response">
    /// A string stream to capture the response content.
    /// </param>
    /// <param name="Headers">
    /// A list of HTTP headers to include in the request.
    /// </param>
    /// <param name="OnReceiveData">
    /// A callback procedure to handle data as it is received during the streaming process.
    /// </param>
    /// <returns>
    /// The HTTP status code returned by the server.
    /// </returns>
    function Post(const URL: string; Body: TJSONObject; Response: TStringStream; const Headers: TNetHeaders; OnReceiveData: TReceiveDataCallback): Integer; overload;

    /// <summary>
    /// Sends an HTTP POST request with a JSON body to the specified URL and handles a full streamed responses.
    /// </summary>
    /// <param name="URL">
    /// The endpoint URL to send the POST request to.
    /// </param>
    /// <param name="Body">
    /// The JSON object to include in the POST request body.
    /// </param>
    /// <param name="Response">
    /// A string stream to capture the response content.
    /// </param>
    /// <param name="Headers">
    /// A list of HTTP headers to include in the request.
    /// </param>
    /// <param name="OnReceiveData">
    /// A callback procedure to handle data as it is received during the streaming process.
    /// </param>
    /// <returns>
    /// The HTTP status code returned by the server.
    /// </returns>
    function Post(const URL: string; Body: TJSONObject; Response: TStream; const Headers: TNetHeaders; OnReceiveData: TReceiveDataCallback): Integer; overload;

    /// <summary>
    /// Sends an HTTP PATCH request with a JSON body to the specified URL.
    /// </summary>
    /// <param name="URL">
    /// The endpoint URL to send the PATCH request to.
    /// </param>
    /// <param name="Body">
    /// The JSON object to include in the PATCH request body.
    /// </param>
    /// <param name="Response">
    /// A string stream to capture the response content.
    /// </param>
    /// <param name="Headers">
    /// A list of HTTP headers to include in the request.
    /// </param>
    /// <returns>
    /// The HTTP status code returned by the server.
    /// </returns>
    function Patch(const URL: string; Body: TJSONObject; Response: TStringStream; const Headers: TNetHeaders): Integer; overload;

    /// <summary>
    /// Initializes a new instance of the <c>THttpClientAPI</c> class.
    /// </summary>
    /// <param name="CheckProc">
    /// A callback procedure to verify API settings before each request.
    /// </param>
    constructor Create(const CheckProc: TProc);

   /// <summary>
    /// Creates and returns an instance of <c>IHttpClientAPI</c>.
    /// </summary>
    /// <param name="CheckProc">
    /// A callback procedure to verify API settings before each request.
    /// </param>
    /// <returns>
    /// An instance implementing the <c>IHttpClientAPI</c> interface.
    /// </returns>
    class function CreateInstance(const CheckProc: TProc): IHttpClientAPI;

    destructor Destroy; override;
  end;

implementation

{ THttpClientAPI }

procedure THttpClientAPI.CheckAPISettings;
begin
  if Assigned(FCheckSettingsProc) then
    FCheckSettingsProc;
end;

constructor THttpClientAPI.Create(const CheckProc: TProc);
begin
  inherited Create;
  FHttpClient := THTTPClient.Create;
  FHttpClient.AcceptCharSet := 'utf-8';
  FCheckSettingsProc := CheckProc;
end;

class function THttpClientAPI.CreateInstance(
  const CheckProc: TProc): IHttpClientAPI;
begin
  Result := THttpClientAPI.Create(CheckProc);
end;

function THttpClientAPI.Delete(const URL: string;
  Response: TStringStream; const Headers: TNetHeaders): Integer;
begin
  CheckAPISettings;
  Result := FHttpClient.Delete(URL, Response, Headers).StatusCode;
end;

destructor THttpClientAPI.Destroy;
begin
  FHttpClient.Free;
  inherited;
end;

function THttpClientAPI.Get(const URL: string; const Response: TStream;
  const Headers: TNetHeaders): Integer;
begin
  CheckAPISettings;
  Result := FHttpClient.Get(URL, Response, Headers).StatusCode;
end;

function THttpClientAPI.GetConnectionTimeout: Integer;
begin
  Result := FHttpClient.ConnectionTimeout;
end;

function THttpClientAPI.GetFollowRedirect(const URL: string;
  const Response: TStream; const Headers: TNetHeaders;
  const DropAuthorizationOnRedirect: Boolean;
  const MaxRedirects: Integer): Integer;
const
  REDIRECT_CODES: array[0..4] of Integer = (301, 302, 303, 307, 308);

  function IsRedirect(Code: Integer): Boolean;
  var
    I: Integer;
  begin
    for I := Low(REDIRECT_CODES) to High(REDIRECT_CODES) do
      if Code = REDIRECT_CODES[I] then
        Exit(True);
    Result := False;
  end;

var
  LResponse: IHTTPResponse;
  HNoAuth: TNetHeaders;
begin
  CheckAPISettings;

  {--- IMPORTANT: We disable automatic client redirects, we want to control the 302 to be able
                  to remove Authorization later. }
  FHttpClient.HandleRedirects := False;

  var NextUrl := URL;
  var Redirects := 0;

  while True do
    begin
      {--- reset the destination stream for each attempt }
      Response.Size := 0;
      Response.Position := 0;

      {--- Initial request with headers (Authorization, Organization, etc.) }
      LResponse := FHttpClient.Get(NextUrl, Response, Headers);
      var Code := LResponse.StatusCode;

      if IsRedirect(Code) then
        begin
          Inc(Redirects);
          if Redirects > MaxRedirects then
            raise Exception.Create('Too many redirects');

          NextUrl := LResponse.HeaderValue['Location'];
          if NextUrl = '' then
            raise Exception.Create('Redirect without Location header');

          {--- Tracking on signed URL }
          Response.Size := 0;
          Response.Position := 0;

          if DropAuthorizationOnRedirect then
            begin
              {--- Remove Authorization from headers }
              SetLength(HNoAuth, Length(Headers));
              for var I := 0 to High(Headers) do
                HNoAuth[I] := Headers[I];

              for var I := High(HNoAuth) downto 0 do
                if SameText(HNoAuth[I].Name, 'Authorization') then
                  begin
                    {--- Delete entry }
                    HNoAuth[I] := HNoAuth[High(HNoAuth)];
                    SetLength(HNoAuth, Length(HNoAuth) - 1);
                  end;

              LResponse := FHttpClient.Get(NextUrl, Response, HNoAuth);
            end
          else
            begin
              {--- we return the headers as is }
              LResponse := FHttpClient.Get(NextUrl, Response, Headers);
            end;

          Code := LResponse.StatusCode;

          {--- Some stacks return multiple redirs in a chain }
          if IsRedirect(Code) then
            Continue;

          Result := Code;
          Exit;
        end;

      Result := Code;
      Exit;
    end;
end;

function THttpClientAPI.GetProxySettings: TProxySettings;
begin
  Result := FHttpClient.ProxySettings;
end;

function THttpClientAPI.GetResponseTimeout: Integer;
begin
  Result := FHttpClient.ResponseTimeout;
end;

function THttpClientAPI.GetSendTimeOut: Integer;
begin
  Result := FHttpClient.SendTimeout;
end;

function THttpClientAPI.Get(const URL: string;
  Response: TStringStream; const Headers: TNetHeaders): Integer;
begin
  CheckAPISettings;
  Result := FHttpClient.Get(URL, Response, Headers).StatusCode;
end;

function THttpClientAPI.Patch(const URL: string; Body: TJSONObject;
  Response: TStringStream; const Headers: TNetHeaders): Integer;
begin
  CheckAPISettings;
  var Stream := TStringStream.Create;
  try
    Stream.WriteString(Body.ToJSON);
    Stream.Position := 0;
    Result := FHttpClient.Patch(URL, Stream, Response, Headers).StatusCode;
  finally
    Stream.Free;
  end;
end;

function THttpClientAPI.Post(const URL: string; Body: TJSONObject;
  Response: TStringStream; const Headers: TNetHeaders;
  OnReceiveData: TReceiveDataCallback): Integer;
begin
  CheckAPISettings;
  var Stream := TStringStream.Create;
  FHttpClient.ReceiveDataCallBack := OnReceiveData;
  try
    Stream.WriteString(Body.ToJSON);
    Stream.Position := 0;
    Result := FHttpClient.Post(URL, Stream, Response, Headers).StatusCode;
  finally
    FHttpClient.ReceiveDataCallBack := nil;
    Stream.Free;
  end;
end;

procedure THttpClientAPI.SetConnectionTimeout(const Value: Integer);
begin
  FHttpClient.ConnectionTimeout := Value;
end;

procedure THttpClientAPI.SetProxySettings(const Value: TProxySettings);
begin
  FHttpClient.ProxySettings := Value;
end;

procedure THttpClientAPI.SetResponseTimeout(const Value: Integer);
begin
  FHttpClient.ResponseTimeout := Value;
end;

procedure THttpClientAPI.SetSendTimeOut(const Value: Integer);
begin
  FHttpClient.SendTimeout := Value;
end;

function THttpClientAPI.Post(const URL: string; Body: TMultipartFormData;
  Response: TStringStream; const Headers: TNetHeaders): Integer;
begin
  CheckAPISettings;
  Result := FHttpClient.Post(URL, Body, Response, Headers).StatusCode;
end;

function THttpClientAPI.Post(const URL: string; Response: TStringStream;
  const Headers: TNetHeaders): Integer;
begin
  CheckAPISettings;
  var Stream: TStringStream := nil;
  Result := FHttpClient.Post(URL, Stream, Response, Headers).StatusCode;
end;

function THttpClientAPI.Post(const URL: string; Body: TJSONObject;
  Response: TStream; const Headers: TNetHeaders;
  OnReceiveData: TReceiveDataCallback): Integer;
begin
  CheckAPISettings;

  {--- Query always encoded in explicit UTF-8 }
  var Bytes := TEncoding.UTF8.GetBytes(Body.ToJSON);
  var Req   := TMemoryStream.Create;
  Req.WriteBuffer(Bytes, Length(Bytes));
  Req.Position := 0;

  FHttpClient.ReceiveDataCallback := OnReceiveData;
  try
    Result := FHttpClient.Post(URL, Req, Response, Headers).StatusCode;
  finally
    FHttpClient.ReceiveDataCallback := nil;
    Req.Free;
  end;
end;

end.
