unit GenAI.API;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGenAI
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

(*
  --- NOTE ---
  The  GenAI.HttpClientInterface  unit  defines  an  IHttpClientAPI  interface, which
  allows  for decoupling  the specific implementation  of  the HTTP  client used  for
  web requests. This introduces  an abstraction  that  enhances flexibility, improves
  testability, and simplifies code maintenance.

  The IHttpClientAPI interface  ensures that  client code can interact  with  the web
  without  being  dependent  on a specific class, thus  facilitating  the replacement
  or modification  of the  underlying  HTTP implementation  details without impacting
  the rest  of  the application. It also  enables  easy mocking  during unit testing,
  offering the ability to test  HTTP request behaviors in an isolated  and controlled
  manner.

  This approach adheres to the SOLID principles of dependency inversion, contributing
  to a robust, modular, and adaptable software architecture.
*)

interface

uses
  System.SysUtils, System.Classes, System.Net.HttpClient, System.Net.URLClient,
  System.Net.Mime, System.JSON, GenAI.API.Params, GenAI.API.Utils, GenAI.Errors,
  GenAI.Exceptions, GenAI.HttpClientInterface, GenAI.HttpClientAPI, GenAI.Monitoring;

type
  /// <summary>
  /// Represents a delegate function for parsing a response string into a strongly-typed object.
  /// </summary>
  /// <typeparam name="T">
  /// The type of the object to be returned by the parser function.
  /// This type must be a class with a parameterless constructor.
  /// </typeparam>
  /// <param name="ResponseText">
  /// A string containing the API response data to be parsed.
  /// </param>
  /// <returns>
  /// An instance of type <c>T</c> created from the parsed <c>ResponseText</c>.
  /// </returns>
  /// <remarks>
  /// The delegate provides a flexible mechanism for converting API response strings
  /// (usually in JSON format) into strongly-typed objects. It is commonly used for
  /// deserialization processes in HTTP client operations.
  /// </remarks>
  TParserMethod<T: class, constructor> = reference to function(const ResponseText: string): T;

  /// <summary>
  /// Represents the configuration settings for the GenAI API.
  /// </summary>
  /// <remarks>
  /// This class provides properties and methods to manage the API key, base URL,
  /// organization identifier, and custom headers for communicating with the GenAI API.
  /// It also includes utility methods for building headers and endpoint URLs.
  /// </remarks>
  TGenAIConfiguration = class
  const
    /// <summary>
    /// The default base URL for the GenAI API.
    /// </summary>
    URL_BASE = 'https://api.openai.com/v1';
  private
    FAPIKey: string;
    FBaseUrl: string;
    FOrganization: string;
    FCustomHeaders: TNetHeaders;
    procedure SetBaseUrl(const Value: string);
    procedure SetOrganization(const Value: string);
    procedure SetCustomHeaders(const Value: TNetHeaders);
    procedure SetAPIKey(const Value: string);
    procedure VerifyApiSettings;
    procedure ResetCustomHeader;
  protected
    /// <summary>
    /// Retrieves the headers required for API requests.
    /// </summary>
    /// <returns>
    /// A list of headers including authorization and optional organization information.
    /// </returns>
    function BuildHeaders: TNetHeaders; virtual;
    /// <summary>
    /// Builds headers specific to JSON-based API requests.
    /// </summary>
    /// <returns>
    /// A list of headers including JSON content-type and authorization details.
    /// </returns>
    function BuildJsonHeaders: TNetHeaders; virtual;
    /// <summary>
    /// Constructs the full URL for a specific API endpoint.
    /// </summary>
    /// <param name="Endpoint">
    /// The relative endpoint path (e.g. "models").
    /// </param>
    /// <returns>
    /// The full URL including the base URL and endpoint.
    /// </returns>
    function BuildUrl(const Endpoint: string): string; overload; virtual;
    /// <summary>
    /// Constructs the full URL for a specific API endpoint.
    /// </summary>
    /// <param name="Endpoint">
    /// The relative endpoint path (e.g. "models").
    /// </param>
    /// <param name="Parameters">
    /// e.g. "?param1=val1&param2=val2...."
    /// </param>
    /// <returns>
    /// The full URL including the base URL and endpoint.
    /// </returns>
    function BuildUrl(const Endpoint, Parameters: string): string; overload; virtual;
  public
    constructor Create; overload;
    /// <summary>
    /// The API key used for authentication.
    /// </summary>
    property APIKey: string read FAPIKey write SetAPIKey;
    /// <summary>
    /// The base URL for API requests.
    /// </summary>
    property BaseUrl: string read FBaseUrl write SetBaseUrl;
    /// <summary>
    /// The organization identifier used for the API.
    /// </summary>
    property Organization: string read FOrganization write SetOrganization;
    /// <summary>
    /// Custom headers to include in API requests.
    /// </summary>
    property CustomHeaders: TNetHeaders read FCustomHeaders write SetCustomHeaders;
  end;

  /// <summary>
  /// Handles HTTP requests and responses for the GenAI API.
  /// </summary>
  /// <remarks>
  /// This class extends <c>TGenAIConfiguration</c> and provides a mechanism to
  /// manage HTTP client interactions for the API, including configuration and request execution.
  /// </remarks>
  TApiHttpHandler = class(TGenAIConfiguration)
  private
    /// <summary>
    /// The HTTP client interface used for making API calls.
    /// </summary>
    FHttpClient: IHttpClientAPI;
  public
    constructor Create;
    /// <summary>
    /// The HTTP client used to send requests to the API.
    /// </summary>
    /// <value>
    /// An instance of a class implementing <c>IHttpClientAPI</c>.
    /// </value>
    property HttpClient: IHttpClientAPI read FHttpClient write FHttpClient;
  end;

  /// <summary>
  /// Manages and processes errors from the GenAI API responses.
  /// </summary>
  /// <remarks>
  /// This class extends <c>TApiHttpHandler</c> and provides error-handling capabilities
  /// by parsing error data and raising appropriate exceptions.
  /// </remarks>
  TApiDeserializer = class(TApiHttpHandler)
  class var Metadata: ICustomFieldsPrepare;
  protected
    /// <summary>
    /// Parses the error data from the API response.
    /// </summary>
    /// <param name="Code">
    /// The HTTP status code returned by the API.
    /// </param>
    /// <param name="ResponseText">
    /// The response body containing error details.
    /// </param>
    /// <exception cref="GenAIAPIException">
    /// Raised if the error response cannot be parsed or contains invalid data.
    /// </exception>
    procedure DeserializeErrorData(const Code: Int64; const ResponseText: string); virtual;
    /// <summary>
    /// Raises an exception corresponding to the API error code.
    /// </summary>
    /// <param name="Code">
    /// The HTTP status code returned by the API.
    /// </param>
    /// <param name="Error">
    /// The deserialized error object containing error details.
    /// </param>
    procedure RaiseError(Code: Int64; Error: TErrorCore); virtual;
    /// <summary>
    /// Deserializes the API response into a strongly typed object.
    /// </summary>
    /// <param name="T">
    /// The type of the object to deserialize into. It must be a class with a parameterless constructor.
    /// </param>
    /// <param name="Code">
    /// The HTTP status code of the API response.
    /// </param>
    /// <param name="ResponseText">
    /// The response body as a JSON string.
    /// </param>
    /// <returns>
    /// A deserialized object of type <c>T</c>.
    /// </returns>
    /// <exception cref="GenAIInvalidResponseError">
    /// Raised if the response is non-compliant or deserialization fails.
    /// </exception>
    function Deserialize<T: class, constructor>(const Code: Int64; const ResponseText: string): T;
  public
    class constructor Create;
    /// <summary>
    /// Deserializes the API response into a strongly typed object.
    /// </summary>
    /// <param name="T">
    /// The type of the object to deserialize into. It must be a class with a parameterless constructor.
    /// </param>
    /// <param name="ResponseText">
    /// The response body as a JSON string.
    /// </param>
    /// <returns>
    /// A deserialized object of type <c>T</c>.
    /// </returns>
    /// <exception cref="GenAIInvalidResponseError">
    /// Raised if the response is non-compliant or deserialization fails.
    /// </exception>
    class function Parse<T: class, constructor>(const Value: string): T;
  end;

  /// <summary>
  /// Provides a high-level interface for interacting with the GenAI API.
  /// </summary>
  /// <remarks>
  /// This class extends <c>TApiDeserializer</c> and includes methods for making HTTP requests to
  /// the GenAI API. It supports various HTTP methods, including GET, POST, PATCH, and DELETE,
  /// as well as handling file uploads and downloads. The API key and other configuration settings
  /// are inherited from the <c>TGenAIConfiguration</c> class.
  /// </remarks>
  TGenAIAPI = class(TApiDeserializer)
  private
    function MockJsonResponse(const FieldName: string; Response: TStringStream): string; overload;
    function MockJsonFile(const FieldName: string; Response: TStringStream): string;
  public
    /// <summary>
    /// Initializes a new instance of the <c>TGenAIAPI</c> class with an API key.
    /// </summary>
    /// <param name="AAPIKey">
    /// The API key used for authenticating requests to the GenAI API.
    /// </param>
    constructor Create(const AAPIKey: string); overload;
    /// <summary>
    /// Sends a GET request to the specified API endpoint and returns a strongly typed object.
    /// </summary>
    /// <typeparam name="TResult">
    /// The type of the response object to deserialize into.
    /// </typeparam>
    /// <param name="Endpoint">
    /// The relative endpoint to send the GET request to (e.g., "models").
    /// </param>
    /// <returns>
    /// A deserialized object of type <c>TResult</c> containing the API response.
    /// </returns>
    /// <exception cref="GenAIInvalidResponseError">
    /// Raised if the response cannot be deserialized or is non-compliant.
    /// </exception>
    function Get<TResult: class, constructor>(const Endpoint: string): TResult; overload;
    /// <summary>
    /// Sends a GET request with parameters and returns a strongly typed object.
    /// </summary>
    /// <typeparam name="TResult">
    /// The type of the response object to deserialize into.
    /// </typeparam>
    /// <typeparam name="TParams">
    /// The type of the parameters object for the request.
    /// </typeparam>
    /// <param name="Endpoint">
    /// The relative endpoint to send the GET request to.
    /// </param>
    /// <param name="ParamProc">
    /// A callback procedure to configure the request parameters.
    /// </param>
    /// <returns>
    /// A deserialized object of type <c>TResult</c> containing the API response.
    /// </returns>
    /// <exception cref="GenAIInvalidResponseError">
    /// Raised if the response cannot be deserialized or is non-compliant.
    /// </exception>
    function Get<TResult: class, constructor; TParams: TUrlParam>(const Endpoint: string; ParamProc: TProc<TParams>): TResult; overload;
    /// <summary>
    /// Sends a GET request to retrieve a file from the specified API endpoint.
    /// </summary>
    /// <param name="Endpoint">
    /// The relative endpoint to send the GET request to.
    /// </param>
    /// <param name="Response">
    /// A stream where the file data will be written.
    /// </param>
    /// <returns>
    /// The HTTP status code of the API response.
    /// </returns>
    function GetFile(const Endpoint: string; Response: TStream): Integer; overload;
    /// <summary>
    /// Sends a GET request to retrieve a file and deserializes it into a strongly typed object.
    /// <para>
    /// - The result data is encoded in Base64 format.
    /// </para>
    /// </summary>
    /// <typeparam name="TResult">
    /// The type of the object to deserialize into.
    /// </typeparam>
    /// <param name="Endpoint">
    /// The relative endpoint to send the GET request to.
    /// </param>
    /// <param name="JSONFieldName">
    /// The name of the JSON field containing the file data.
    /// </param>
    /// <returns>
    /// A deserialized object of type <c>TResult</c> containing the file data.
    /// </returns>
    function GetFile<TResult: class, constructor>(const Endpoint: string; const JSONFieldName: string = 'data'): TResult; overload;
    /// <summary>
    /// Sends a DELETE request to the specified API endpoint and returns a strongly typed object.
    /// </summary>
    /// <typeparam name="TResult">
    /// The type of the response object to deserialize into.
    /// </typeparam>
    /// <param name="Endpoint">
    /// The relative endpoint to send the DELETE request to.
    /// </param>
    /// <returns>
    /// A deserialized object of type <c>TResult</c> containing the API response.
    /// </returns>
    function Delete<TResult: class, constructor>(const Endpoint: string): TResult; overload;
    /// <summary>
    /// Sends a POST request with parameters and streams the response.
    /// </summary>
    /// <typeparam name="TParams">
    /// The type of the parameters object for the request.
    /// </typeparam>
    /// <param name="Endpoint">
    /// The relative endpoint to send the POST request to.
    /// </param>
    /// <param name="ParamProc">
    /// A callback procedure to configure the request parameters.
    /// </param>
    /// <param name="Response">
    /// A string stream where the response will be written.
    /// </param>
    /// <param name="Event">
    /// A callback procedure for handling the received data during streaming.
    /// </param>
    /// <returns>
    /// A boolean value indicating whether the request was successful.
    /// </returns>
    /// <exception cref="GenAIInvalidResponseError">
    /// Raised if the response cannot be deserialized or is non-compliant.
    /// </exception>
    function Post<TParams: TJSONParam>(const Endpoint: string; ParamProc: TProc<TParams>; Response: TStringStream; Event: TReceiveDataCallback): Boolean; overload;
    /// <summary>
    /// Sends a POST request with parameters and streams the response.
    /// </summary>
    /// <typeparam name="TParams">
    /// The type of the parameters object for the request.
    /// </typeparam>
    /// <param name="Endpoint">
    /// The relative endpoint to send the POST request to.
    /// </param>
    /// <param name="ParamProc">
    /// A callback procedure to configure the request parameters.
    /// </param>
    /// <param name="Response">
    /// A string stream where the response will be written.
    /// </param>
    /// <param name="Event">
    /// A callback procedure for handling the received data during streaming.
    /// </param>
    /// <returns>
    /// A boolean value indicating whether the request was successful.
    /// </returns>
    /// <exception cref="GenAIInvalidResponseError">
    /// Raised if the response cannot be deserialized or is non-compliant.
    /// </exception>
    function Post<TParams: TJSONParam>(const Endpoint: string; ParamProc: TProc<TParams>; Response: TStream; Event: TReceiveDataCallback): Boolean; overload;
    /// <summary>
    /// Sends a POST request with parameters and returns a strongly typed object.
    /// </summary>
    /// <typeparam name="TResult">
    /// The type of the response object to deserialize into.
    /// </typeparam>
    /// <typeparam name="TParams">
    /// The type of the parameters object for the request.
    /// </typeparam>
    /// <param name="Endpoint">
    /// The relative endpoint to send the POST request to.
    /// </param>
    /// <param name="ParamProc">
    /// A callback procedure to configure the request parameters.
    /// </param>
    /// <param name="RawByteFieldName">
    /// An optional field name to encode raw byte data into.
    /// </param>
    /// <returns>
    /// A deserialized object of type <c>TResult</c> containing the API response.
    /// </returns>
    /// <exception cref="GenAIInvalidResponseError">
    /// Raised if the response cannot be deserialized or is non-compliant.
    /// </exception>
    function Post<TResult: class, constructor; TParams: TJSONParam>(const Endpoint: string; ParamProc: TProc<TParams>; const RawByteFieldName: string = ''): TResult; overload;
    /// <summary>
    /// Sends a POST request to the specified API endpoint.
    /// </summary>
    /// <typeparam name="TResult">
    /// The type of the response object to deserialize into.
    /// </typeparam>
    /// <param name="Endpoint">
    /// The relative endpoint to send the POST request to.
    /// </param>
    /// <returns>
    /// A deserialized object of type <c>TResult</c> containing the API response.
    /// </returns>
    function Post<TResult: class, constructor>(const Endpoint: string): TResult; overload;
    /// <summary>
    /// Sends a PATCH request with parameters and returns a strongly typed object.
    /// </summary>
    /// <typeparam name="TResult">
    /// The type of the response object to deserialize into.
    /// </typeparam>
    /// <typeparam name="TParams">
    /// The type of the parameters object for the request.
    /// </typeparam>
    /// <param name="Endpoint">
    /// The relative endpoint to send the PATCH request to.
    /// </param>
    /// <param name="ParamProc">
    /// A callback procedure to configure the request parameters.
    /// </param>
    /// <returns>
    /// A deserialized object of type <c>TResult</c> containing the API response.
    /// </returns>
    function Patch<TResult: class, constructor; TParams: TJSONParam>(const Endpoint: string; ParamProc: TProc<TParams>): TResult; overload;
    /// <summary>
    /// Sends a POST request with multipart form data and returns a strongly typed object.
    /// </summary>
    /// <typeparam name="TResult">
    /// The type of the response object to deserialize into.
    /// </typeparam>
    /// <typeparam name="TParams">
    /// The type of the multipart form data parameters object.
    /// </typeparam>
    /// <param name="Endpoint">
    /// The relative endpoint to send the POST request to.
    /// </param>
    /// <param name="ParamProc">
    /// A callback procedure to configure the multipart form data parameters.
    /// </param>
    /// <returns>
    /// A deserialized object of type <c>TResult</c> containing the API response.
    /// </returns>
    /// <exception cref="GenAIInvalidResponseError">
    /// Raised if the response cannot be deserialized or is non-compliant.
    /// </exception>
    function PostForm<TResult: class, constructor; TParams: TMultipartFormData, constructor>(const Endpoint: string; ParamProc: TProc<TParams>): TResult; overload;
  end;

  /// <summary>
  /// Represents a specific route or logical grouping for the GenAI API.
  /// </summary>
  /// <remarks>
  /// This class allows associating a <c>TGenAIAPI</c> instance with specific routes or
  /// endpoints, providing an organized way to manage API functionality.
  /// </remarks>
  TGenAIRoute = class
  private
    /// <summary>
    /// The GenAI API instance associated with this route.
    /// </summary>
    FAPI: TGenAIAPI;
    procedure SetAPI(const Value: TGenAIAPI);
  protected
    procedure HeaderCustomize; virtual;
  public
    /// <summary>
    /// Initializes a new instance of the <c>TGenAIRoute</c> class with the given API instance.
    /// </summary>
    /// <param name="AAPI">
    /// The <c>TGenAIAPI</c> instance to associate with the route.
    /// </param>
    property API: TGenAIAPI read FAPI write SetAPI;
    /// <summary>
    /// The GenAI API instance associated with this route.
    /// </summary>
    constructor CreateRoute(AAPI: TGenAIAPI); reintroduce; virtual;
  end;

var
  MetadataAsObject: Boolean = False;

implementation

uses
  System.StrUtils, REST.Json, GenAI.NetEncoding.Base64, System.DateUtils;

{TGenAIAPI}

constructor TGenAIAPI.Create(const AAPIKey: string);
begin
  Create;
  APIKey := AAPIKey;
end;

function TGenAIAPI.Post<TParams>(const Endpoint: string;
  ParamProc: TProc<TParams>; Response: TStream;
  Event: TReceiveDataCallback): Boolean;
var
  Params: TParams;
begin
  Monitoring.Inc;
  Params := TParams.Create;
  try
    if Assigned(ParamProc) then
      ParamProc(Params);
    var Code := HttpClient.Post(BuildUrl(Endpoint), Params.JSON, Response, BuildJsonHeaders, Event);
    Result := (Code > 200) and (Code < 299);
    case Code of
      200..299:
        Result := True;
      else
        begin
          Response.Position := 0;
          var ErrBytes: TBytes;
          SetLength(ErrBytes, Response.Size);
          Response.ReadBuffer(ErrBytes, Length(ErrBytes));
          DeserializeErrorData(Code, TEncoding.UTF8.GetString(ErrBytes));
        end;
    end;
  finally
    Params.Free;
    ResetCustomHeader;
    Monitoring.Dec;
  end;
end;

function TGenAIAPI.Post<TResult, TParams>(const Endpoint: string; ParamProc: TProc<TParams>;
  const RawByteFieldName: string): TResult;
begin
  Monitoring.Inc;
  var Response := TStringStream.Create('', TEncoding.UTF8);
  var Params := TParams.Create;
  try
    if Assigned(ParamProc) then
      ParamProc(Params);
    var Code := HttpClient.Post(BuildUrl(Endpoint), Params.JSON, Response, BuildJsonHeaders, nil);
    case Code of
      200..299:
        begin
          if RawByteFieldName.IsEmpty then
            Result := Deserialize<TResult>(Code, Response.DataString) else
            {--- When a raw byte file is sent as the sole response }
            Result := Deserialize<TResult>(Code, MockJsonResponse(RawByteFieldName, Response));
        end;
      else
        Result := Deserialize<TResult>(Code, Response.DataString)
    end;
  finally
    Params.Free;
    Response.Free;
    ResetCustomHeader;
    Monitoring.Dec;
  end;
end;

function TGenAIAPI.Post<TParams>(const Endpoint: string; ParamProc: TProc<TParams>; Response: TStringStream; Event: TReceiveDataCallback): Boolean;
begin
  Monitoring.Inc;
  var Params := TParams.Create;
  try
    if Assigned(ParamProc) then
      ParamProc(Params);
    var Code := HttpClient.Post(BuildUrl(Endpoint), Params.JSON, Response, BuildJsonHeaders, Event);
    case Code of
      200..299:
        Result := True;
    else
      begin
        Result := False;
        var Recieved := TStringStream.Create;
        try
          Response.Position := 0;
          Recieved.LoadFromStream(Response);
          DeserializeErrorData(Code, Recieved.DataString);
        finally
          Recieved.Free;
        end;
      end;
    end;
  finally
    Params.Free;
    ResetCustomHeader;
    Monitoring.Dec;
  end;
end;

function TGenAIAPI.Post<TResult>(const Endpoint: string): TResult;
begin
  Monitoring.Inc;
  var Response := TStringStream.Create('', TEncoding.UTF8);
  try
    var Code := HttpClient.Post(BuildUrl(Endpoint), Response, BuildHeaders);
    Result := Deserialize<TResult>(Code, Response.DataString);
  finally
    Response.Free;
    ResetCustomHeader;
    Monitoring.Dec;
  end;
end;

function TGenAIAPI.Delete<TResult>(const Endpoint: string): TResult;
begin
  Monitoring.Inc;
  var Response := TStringStream.Create('', TEncoding.UTF8);
  try
    var Code := HttpClient.Delete(BuildUrl(Endpoint), Response, BuildHeaders);
    Result := Deserialize<TResult>(Code, Response.DataString);
  finally
    Response.Free;
    ResetCustomHeader;
    Monitoring.Dec;
  end;
end;

function TGenAIAPI.PostForm<TResult, TParams>(const Endpoint: string; ParamProc: TProc<TParams>): TResult;
begin
  Monitoring.Inc;
  var Response := TStringStream.Create('', TEncoding.UTF8);
  var Params := TParams.Create;
  try
    if Assigned(ParamProc) then
      ParamProc(Params);
    var Code := HttpClient.Post(BuildUrl(Endpoint), Params, Response, BuildHeaders);
    Result := Deserialize<TResult>(Code, Response.DataString);
  finally
    Params.Free;
    Response.Free;
    ResetCustomHeader;
    Monitoring.Dec;
  end;
end;

function TGenAIAPI.Get<TResult, TParams>(const Endpoint: string;
  ParamProc: TProc<TParams>): TResult;
begin
  Monitoring.Inc;
  var Response := TStringStream.Create('', TEncoding.UTF8);
  var Params := TParams.Create;
  try
    if Assigned(ParamProc) then
      ParamProc(Params);
    var Code := HttpClient.Get(BuildUrl(Endpoint, Params.Value), Response, BuildHeaders);
    Result := Deserialize<TResult>(Code, Response.DataString);
  finally
    Response.Free;
    Params.Free;
    ResetCustomHeader;
    Monitoring.Dec;
  end;
end;

function TGenAIAPI.Get<TResult>(const Endpoint: string): TResult;
begin
  Monitoring.Inc;
  var Response := TStringStream.Create('', TEncoding.UTF8);
  try
    var Code := HttpClient.Get(BuildUrl(Endpoint), Response, BuildHeaders);
    Result := Deserialize<TResult>(Code, Response.DataString);
  finally
    Response.Free;
    ResetCustomHeader;
    Monitoring.Dec;
  end;
end;

function TGenAIAPI.GetFile<TResult>(const Endpoint: string; const JSONFieldName: string):TResult;
begin
  Monitoring.Inc;
  var Stream := TStringStream.Create;
  try
    var Code := GetFile(Endpoint, Stream);
    Result := Deserialize<TResult>(Code, MockJsonFile(JSONFieldName, Stream));
  finally
    Stream.Free;
    ResetCustomHeader;
    Monitoring.Dec;
  end;
end;

function TGenAIAPI.GetFile(const Endpoint: string; Response: TStream): Integer;
begin
  var Headers := BuildHeaders;
  try
    Result := HttpClient.Get(BuildUrl(Endpoint), Response, Headers);
    case Result of
      200..299:
         {success};
      else
        begin
          var Recieved := TStringStream.Create;
          try
            Response.Position := 0;
            Recieved.LoadFromStream(Response);
            DeserializeErrorData(Result, Recieved.DataString);
          finally
            Recieved.Free;
          end;
        end;
    end;
  finally
    ResetCustomHeader;
  end;
end;

function TGenAIAPI.MockJsonFile(const FieldName: string;
  Response: TStringStream): string;
begin
  Response.Position := 0;
  var Data := TStringStream.Create(BytesToString(Response.Bytes).TrimRight([#0]));
  try
    Result := Format('{"%s":"%s"}', [FieldName, EncodeBase64(Data)]);
  finally
    Data.Free;
  end;
end;

function TGenAIAPI.MockJsonResponse(const FieldName: string;
  Response: TStringStream): string;
begin
  Result := Format('{"%s":"%s"}', [FieldName, BytesToBase64(Response.Bytes)]);
end;

function TGenAIAPI.Patch<TResult, TParams>(const Endpoint: string;
  ParamProc: TProc<TParams>): TResult;
begin
  Monitoring.Inc;
  var Response := TStringStream.Create('', TEncoding.UTF8);
  var Params := TParams.Create;
  try
    if Assigned(ParamProc) then
      ParamProc(Params);
    var Code := HttpClient.Patch(BuildUrl(Endpoint), Params.JSON, Response, BuildJsonHeaders);
    Result := Deserialize<TResult>(Code, Response.DataString);
  finally
    Params.Free;
    Response.Free;
    ResetCustomHeader;
    Monitoring.Dec;
  end;
end;

{ TGenAIRoute }

constructor TGenAIRoute.CreateRoute(AAPI: TGenAIAPI);
begin
  inherited Create;
  FAPI := AAPI;
end;

procedure TGenAIRoute.HeaderCustomize;
begin

end;

procedure TGenAIRoute.SetAPI(const Value: TGenAIAPI);
begin
  FAPI := Value;
end;

{ TGenAIConfiguration }

procedure TGenAIConfiguration.VerifyApiSettings;
begin
  if FAPIKey.IsEmpty or FBaseUrl.IsEmpty then
    raise TGenAIAPIException.Create('Invalid API key or base URL.');
end;

function TGenAIConfiguration.BuildUrl(const Endpoint: string): string;
begin
  Result := FBaseUrl.TrimRight(['/']) + '/' + Endpoint.TrimLeft(['/']);
end;

function TGenAIConfiguration.BuildUrl(const Endpoint,
  Parameters: string): string;
begin
  Result := BuildUrl(EndPoint) + Parameters;
end;

constructor TGenAIConfiguration.Create;
begin
  inherited;
  FAPIKey := EmptyStr;
  FBaseUrl := URL_BASE;
end;

procedure TGenAIConfiguration.ResetCustomHeader;
begin
  CustomHeaders := [];
end;

function TGenAIConfiguration.BuildHeaders: TNetHeaders;
begin
  Result := [TNetHeader.Create('Authorization', 'Bearer ' + FAPIKey)];
  if not FOrganization.IsEmpty then
    Result := Result + [TNetHeader.Create('OpenAI-Organization', FOrganization)];
  Result := Result + FCustomHeaders;
end;

function TGenAIConfiguration.BuildJsonHeaders: TNetHeaders;
begin
  Result := BuildHeaders +
    [TNetHeader.Create('Content-Type', 'application/json')] +
    [TNetHeader.Create('Accept', 'application/json')];
end;

procedure TGenAIConfiguration.SetAPIKey(const Value: string);
begin
  FAPIKey := Value;
end;

procedure TGenAIConfiguration.SetBaseUrl(const Value: string);
begin
  FBaseUrl := Value;
end;

procedure TGenAIConfiguration.SetCustomHeaders(const Value: TNetHeaders);
begin
  FCustomHeaders := Value;
end;

procedure TGenAIConfiguration.SetOrganization(const Value: string);
begin
  FOrganization := Value;
end;

{ TApiDeserializer }

class constructor TApiDeserializer.Create;
begin
  Metadata := TDeserializationPrepare.CreateInstance;
end;

function TApiDeserializer.Deserialize<T>(const Code: Int64;
  const ResponseText: string): T;
begin
  Result := nil;
  case Code of
    200..299:
      try
        Result := Parse<T>(ResponseText);
      except
        Result := nil;
      end;
    else
      DeserializeErrorData(Code, ResponseText);
  end;
  if not Assigned(Result) then
    raise TGenAIInvalidResponseError.Create(Code, 'Non-compliant response');
end;

procedure TApiDeserializer.DeserializeErrorData(const Code: Int64;
  const ResponseText: string);
var
  Error: TError;
begin
  Error := nil;
  try
    try
      Error := TJson.JsonToObject<TError>(ResponseText);
    except
      Error := nil;
    end;
    if Assigned(Error) then
      RaiseError(Code, Error)
    else
      raise TGenAIAPIException.CreateFmt(
        'Server returned error code %d but response was not parseable: %s', [Code, ResponseText]);
  finally
    if Assigned(Error) then
      Error.Free;
  end;
end;

class function TApiDeserializer.Parse<T>(const Value: string): T;
begin
  {--- NOTE
    - If Metadata are to be treated  as objects, a dedicated  TMetadata class is required, containing
    all the properties corresponding to the specified JSON fields.

    - However, if Metadata are  not treated  as objects, they will be temporarily handled as a string
    and subsequently converted back into a valid JSON string during the deserialization process using
    the Revert method of the interceptor.

    By default, Metadata are  treated as strings rather  than objects to handle  cases where multiple
    classes to be deserialized may contain variable data structures.
    Refer to the global variable MetadataAsObject. }
  case MetadataAsObject of
    True:
      Result := TJson.JsonToObject<T>(Value);
    else
      Result := TJson.JsonToObject<T>(Metadata.Convert(Value));
  end;

  {--- Add JSON response if class inherits from TJSONFingerprint class. }
  if Assigned(Result) and T.InheritsFrom(TJSONFingerprint) then
    begin
      var JSONValue := TJSONObject.ParseJSONValue(Value);
      try
        (Result as TJSONFingerprint).JSONResponse := JSONValue.Format();
      finally
        JSONValue.Free;
      end;
    end;
end;

procedure TApiDeserializer.RaiseError(Code: Int64; Error: TErrorCore);
begin
  case Code of
    401:
      raise TGenAIAuthError.Create(Code, Error);
    403:
      raise TGenAICountryNotSupportedError.Create(Code, Error);
    429:
      raise TGenAIRateLimitError.Create(Code, Error);
    500:
      raise TGenAIServerError.Create(Code, Error);
    503:
      raise TGenAIEngineOverloadedError.Create(Code, Error);
  else
    raise TGenAIException.Create(Code, Error);
  end;
end;

{ TApiHttpHandler }

constructor TApiHttpHandler.Create;
begin
  inherited Create;
  FHttpClient := THttpClientAPI.CreateInstance(VerifyApiSettings);
end;

end.

