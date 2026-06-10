unit GenAI.API;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGenAI
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

{$REGION 'Dev note'}
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

    --- DESERIALIZATION ---
    The legacy JSON path-normalization has been removed, but the JSON shield
    mechanism is preserved (MetadataManager / MetadataAsObject): free-form fields listed
    in PROTECTED_FIELD cannot always be bound to a fixed class, so their nested JSON is
    shielded before object mapping. Deserialization is performed in two steps (see Parse):
    object mapping, then raw-JSON binding to every TJSONFingerprint followed by
    InternalFinalizeDeserialize.
  *)
{$ENDREGION}

uses
  System.SysUtils, System.Classes, System.Net.HttpClient, System.Net.URLClient,
  System.Net.Mime, System.JSON,
  GenAI.API.Params, GenAI.API.JSONShield, GenAI.Errors, GenAI.Exceptions,
  GenAI.HttpClientInterface, GenAI.HttpClientAPI, GenAI.Monitoring,
  GenAI.Api.JsonFingerprintBinder, GenAI.API.Streams;

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
    /// The OpenAI default base URL.
    /// </summary>
    URL_BASE = 'https://api.openai.com/v1';

    /// <summary>
    /// The Gemini (Google) default base URL.
    /// </summary>
    URL_BASE_GEMINI = 'https://generativelanguage.googleapis.com/v1beta/openai';

    /// <summary>
    /// The Clause (Anthropic) default base URL.
    /// </summary>
    URL_BASE_CLAUDE = 'https://api.anthropic.com/v1';

    /// <summary>
    /// The DeepSeek default base URL.
    /// </summary>
    /// <remarks>
    /// This constant defines the root endpoint used to build request URLs when targeting the
    /// DeepSeek API. It is combined with relative paths by <c>BuildUrl</c> to form the final
    /// request URL.
    /// <para>
    /// Default value: <c>https://api.deepseek.com</c>.
    /// </para>
    /// </remarks>
    URL_BASE_DEEPSEEK = 'https://api.deepseek.com';

    /// <summary>
    /// The Grok (xAI) default base URL.
    /// </summary>
    /// <remarks>
    /// This constant defines the root endpoint used to build request URLs when targeting the
    /// xAI API (Grok). It is combined with relative paths by <c>BuildUrl</c> to form the final
    /// request URL.
    /// <para>
    /// Default value: <c>https://api.x.ai/v1</c>.
    /// </para>
    /// </remarks>
    URL_BASE_GROK = 'https://api.x.ai/v1';
  strict private
    class var FLocalUrlBase: string;
  private
    FAPIKey: string;
    FBaseUrl: string;
    FOrganization: string;
    FCustomHeaders: TNetHeaders;
    FLMStudio: Boolean;
    procedure SetBaseUrl(const Value: string);
    procedure SetOrganization(const Value: string);
    procedure SetCustomHeaders(const Value: TNetHeaders);
    procedure SetAPIKey(const Value: string);
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
    /// Gets or sets the base URL for all API requests.
    /// </summary>
    /// <remarks>
    /// This value defines the root endpoint used to build request URLs
    /// (for example, <c>https://api.openai.com/v1</c>). It is combined with
    /// relative paths by <c>BuildUrl</c> to form the final request URL.
    /// </remarks>
    property BaseUrl: string read FBaseUrl write SetBaseUrl;

    /// <summary>
    /// The organization identifier used for the API.
    /// </summary>
    property Organization: string read FOrganization write SetOrganization;

    /// <summary>
    /// Custom headers to include in API requests.
    /// </summary>
    property CustomHeaders: TNetHeaders read FCustomHeaders write SetCustomHeaders;

    /// <summary>
    /// Gets or sets the base URL used when connecting to a local LM Studio server.
    /// </summary>
    /// <remarks>
    /// This value is shared across all API instances and is used whenever a
    /// <c>TGenAIAPI</c> instance is created with <c>LocalLMS = True</c>.
    /// By default, it points to <c>http://127.0.0.1:1234/v1</c>.
    /// </remarks>
    class property LocalUrlBase: string read FLocalUrlBase write FLocalUrlBase;
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

  protected
    /// <summary>
    /// Validates that the API settings required to issue requests are present.
    /// </summary>
    /// <remarks>
    /// This routine checks the configuration held by <see cref="TGenAIConfiguration"/> before performing
    /// an HTTP request. It is typically invoked by the underlying HTTP client implementation prior to
    /// sending a request.
    /// <para>
    /// Validation rule: <see cref="TGenAIConfiguration.APIKey"/> must be non-empty.
    /// </para>
    /// <para>
    /// Validation rule: <see cref="TGenAIConfiguration.BaseUrl"/> must be non-empty.
    /// </para>
    /// </remarks>
    /// <exception cref="GenAIExceptionAPI">
    /// Raised when a required setting is missing or empty (for example, an empty token or base URL).
    /// </exception>
    procedure VerifyApiSettings;

    function NewHttpClient: IHttpClientAPI; virtual;
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
  strict private
    class var FMetadataManager: ICustomFieldsPrepare;
    class var FMetadataAsObject: Boolean;
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
    /// Deserializes an HTTP response payload into a strongly typed Delphi object, or raises
    /// a structured exception when the response represents an API error.
    /// </summary>
    /// <typeparam name="T">
    /// The target type to deserialize into. Must be a class type with a parameterless constructor.
    /// </typeparam>
    /// <param name="Code">
    /// The HTTP status code returned by the server.
    /// </param>
    /// <param name="Payload">
    /// The original JSON payload associated with the request (for example, the request body).
    /// This value is propagated to <c>JSONPayload</c> when <typeparamref name="T"/> inherits
    /// from <c>TJSONFingerprint</c>.
    /// </param>
    /// <param name="ResponseText">
    /// The response body as a JSON string (success payload or error payload).
    /// </param>
    /// <param name="DisabledShield">
    /// When <c>True</c>, disables JSON shield preprocessing and performs a direct JSON-to-object
    /// conversion (see <c>Parse{T}</c>). When <c>False</c> (default), parsing follows the global
    /// shield configuration (<c>MetadataAsObject</c>/<c>MetadataManager</c>).
    /// </param>
    /// <returns>
    /// A deserialized instance of <typeparamref name="T"/> when <paramref name="Code"/> indicates success (2xx).
    /// <para>
    /// If <typeparamref name="T"/> inherits from <c>TJSONFingerprint</c>, the original JSON payload is
    /// normalized (formatted) and stored in <c>JSONResponse</c>, then propagated to nested fingerprint
    /// instances in the object graph.
    /// </para>
    /// </returns>
    /// <remarks>
    /// <para>
    /// Success path: for HTTP status codes in the range 200..299, this method maps
    /// <paramref name="ResponseText"/> into <typeparamref name="T"/> by calling <c>Parse{T}</c>.
    /// </para>
    /// <para>
    /// Error path: for any non-2xx code, this method delegates to <c>DeserializeErrorData</c>,
    /// which attempts to parse the API error payload and raises an appropriate <c>TGenAIException</c>
    /// subtype. This method does not return normally in that case.
    /// </para>
    /// <para>
    /// This method does not validate transport-level concerns (timeouts, connectivity). It only
    /// interprets the HTTP status code and JSON payload already obtained by the caller.
    /// </para>
    /// </remarks>
    /// <exception cref="TGenAIException">
    /// Raised when the server returns a structured error payload that can be parsed and mapped to a known error type.
    /// </exception>
    /// <exception cref="TGenAIAPIException">
    /// Raised when the server returns an error payload that is not parseable as a structured error object.
    /// </exception>
    /// <exception cref="TGenAIInvalidResponseError">
    /// Raised when the JSON success payload cannot be mapped to <typeparamref name="T"/> under the active
    /// parsing mode (for example JSON shield preprocessing requirements not satisfied).
    /// </exception>
    function Deserialize<T: class, constructor>(const Code: Int64;
      const Payload: string;
      const ResponseText: string;
      DisabledShield: Boolean = False): T;
  public
    class constructor Create;

    /// <summary>
    /// Gets or sets whether protected free-form fields are expected as JSON objects or arrays.
    /// </summary>
    /// <remarks>
    /// When set to <c>True</c>, deserialization expects the fields listed in <c>PROTECTED_FIELD</c>
    /// to be represented as proper JSON objects or arrays and mapped directly to the corresponding
    /// Delphi types.
    /// <para>
    /// When set to <c>False</c> (default), protected free-form fields are shielded through
    /// <see cref="MetadataManager"/> before the final object mapping occurs. This mode is intended
    /// for schemas that vary across response types and cannot be bound reliably to a single class.
    /// </para>
    /// <para>
    /// The property name is kept for compatibility with the earlier metadata-specific API surface.
    /// </para>
    /// <para>
    /// This setting is process-wide (static) and affects all calls that use <see cref="Parse{T}(string)"/> and
    /// <see cref="Deserialize{T}(Int64,string)"/> within this unit.
    /// </para>
    /// </remarks>
    class property MetadataAsObject: Boolean read FMetadataAsObject write FMetadataAsObject;

    /// <summary>
    /// Gets or sets the global JSON shield preprocessor used during deserialization.
    /// </summary>
    /// <remarks>
    /// This property holds an implementation of <c>ICustomFieldsPrepare</c> responsible for preparing and/or
    /// transforming JSON payloads before they are mapped to Delphi objects.
    /// <para>
    /// When <see cref="MetadataAsObject"/> is <c>False</c> (default), the deserializer invokes
    /// <c>MetadataManager.Convert(...)</c> to shield protected fields listed in <c>PROTECTED_FIELD</c>
    /// when they contain variable or untyped nested JSON structures.
    /// </para>
    /// <para>
    /// When <see cref="MetadataAsObject"/> is <c>True</c>, the shield preprocessor is typically not
    /// required because protected fields are expected to be represented as proper JSON objects or arrays
    /// and mapped directly to Delphi types.
    /// </para>
    /// <para>
    /// The property name is kept for compatibility with the earlier metadata-specific API surface.
    /// </para>
    /// <para>
    /// This setting is process-wide (static). Assigning a new manager affects all subsequent calls to
    /// <see cref="Parse{T}(string)"/> and <see cref="Deserialize{T}(Int64,string)"/> within this unit.
    /// </para>
    /// <para>
    /// If set to <c>nil</c>, and <see cref="MetadataAsObject"/> is <c>False</c>, deserialization may fail for
    /// responses that rely on JSON shield preprocessing.
    /// </para>
    /// </remarks>
    class property MetadataManager: ICustomFieldsPrepare read FMetadataManager write FMetadataManager;

    /// <summary>
    /// Parses a JSON payload and maps it to a strongly typed Delphi object, with optional
    /// JSON shield preprocessing and JSON fingerprint propagation.
    /// </summary>
    /// <typeparam name="T">
    /// The target type to deserialize into. Must be a class type with a parameterless constructor.
    /// </typeparam>
    /// <param name="Value">
    /// The JSON payload to parse and deserialize.
    /// </param>
    /// <param name="Payload">
    /// The original JSON payload associated with the request (for example, the request body).
    /// This value is propagated to <c>JSONPayload</c> when <typeparamref name="T"/> inherits
    /// from <c>TJSONFingerprint</c>.
    /// </param>
    /// <param name="DisabledShield">
    /// When <c>True</c>, bypasses the JSON shield preprocessing pipeline and performs a direct
    /// JSON-to-object conversion using <c>TJson.JsonToObject&lt;T&gt;</c>.
    /// When <c>False</c> (default), parsing behavior depends on the global shield configuration
    /// (<see cref="MetadataAsObject"/> / <see cref="MetadataManager"/>).
    /// </param>
    /// <returns>
    /// An instance of <typeparamref name="T"/> populated from <paramref name="Value"/>.
    /// <para>
    /// If <typeparamref name="T"/> inherits from <c>TJSONFingerprint</c>, the JSON payload is
    /// normalized (formatted) and stored in <c>JSONResponse</c>, then propagated to all nested
    /// <c>TJSONFingerprint</c> instances in the object graph.
    /// </para>
    /// <para>
    /// The provided <paramref name="Payload"/> is assigned to <c>JSONPayload</c> on the root
    /// fingerprint instance.
    /// </para>
    /// </returns>
    /// <remarks>
    /// <para>
    /// Parsing behavior follows these rules:
    /// </para>
    /// <para>
    /// If <paramref name="DisabledShield"/> is <c>True</c>, JSON shield handling is skipped and
    /// the JSON payload is deserialized directly.
    /// </para>
    /// <para>
    /// If <paramref name="DisabledShield"/> is <c>False</c> and <see cref="MetadataAsObject"/> is
    /// <c>True</c>, protected fields are expected to be valid JSON objects or arrays and are mapped
    /// directly to Delphi types.
    /// </para>
    /// <para>
    /// If <paramref name="DisabledShield"/> is <c>False</c> and <see cref="MetadataAsObject"/> is
    /// <c>False</c>, <see cref="MetadataManager"/> is used to shield the protected fields listed in
    /// <c>PROTECTED_FIELD</c> before deserialization. If <see cref="MetadataManager"/> is <c>nil</c>
    /// in this mode, deserialization fails.
    /// </para>
    /// <para>
    /// JSON fingerprint propagation is RTTI-based, cycle-safe, and applies only to fields
    /// (properties are not evaluated).
    /// </para>
    /// <para>
    /// This method is a pure deserialization utility. It does not interpret HTTP status codes
    /// and does not perform API error handling.
    /// </para>
    /// </remarks>
    /// <exception cref="TGenAIInvalidResponseError">
    /// Raised when JSON shield preprocessing is required but <see cref="MetadataManager"/> is <c>nil</c>,
    /// or when the JSON payload cannot be mapped to <typeparamref name="T"/> under the active mode.
    /// </exception>
    /// <exception cref="System.Exception">
    /// Raised when JSON parsing, shield conversion, or fingerprint post-processing fails.
    /// Any partially created instance is freed before the exception is re-raised.
    /// </exception>
    class function Parse<T: class, constructor>(const Value: string;
      const Payload: string;
      DisabledShield: Boolean = False): T; overload;

    /// <summary>
    /// Parses a JSON payload and maps it to a strongly typed Delphi object, with optional
    /// JSON shield preprocessing and JSON fingerprint propagation.
    /// </summary>
    /// <typeparam name="T">
    /// The target type to deserialize into. Must be a class type with a parameterless constructor.
    /// </typeparam>
    /// <param name="Value">
    /// The JSON payload to parse and deserialize.
    /// </param>
    /// <param name="DisabledShield">
    /// When <c>True</c>, bypasses the JSON shield preprocessing pipeline and performs a direct
    /// JSON-to-object conversion using <c>TJson.JsonToObject&lt;T&gt;</c>.
    /// When <c>False</c> (default), parsing behavior depends on the global shield configuration
    /// (<see cref="MetadataAsObject"/> / <see cref="MetadataManager"/>).
    /// </param>
    /// <returns>
    /// An instance of <typeparamref name="T"/> populated from <paramref name="Value"/>.
    /// <para>
    /// If <typeparamref name="T"/> inherits from <c>TJSONFingerprint</c>, the JSON payload is
    /// normalized (formatted) and stored in <c>JSONResponse</c>, then propagated to all nested
    /// <c>TJSONFingerprint</c> instances in the object graph.
    /// </para>
    /// <para>
    /// The request payload string associated with the operation is not available in this overload,
    /// so <c>JSONPayload</c> (if present) is left empty.
    /// </para>
    /// </returns>
    /// <remarks>
    /// <para>
    /// This overload is a convenience wrapper for <c>Parse&lt;T&gt;(Value, '', DisabledShield)</c>.
    /// </para>
    /// <para>
    /// This method is a pure deserialization utility. It does not interpret HTTP status codes
    /// and does not perform API error handling.
    /// </para>
    /// </remarks>
    /// <exception cref="TGenAIInvalidResponseError">
    /// Raised when JSON shield preprocessing is required but <see cref="MetadataManager"/> is <c>nil</c>,
    /// or when the JSON payload cannot be mapped to <typeparamref name="T"/> under the active mode.
    /// </exception>
    /// <exception cref="System.Exception">
    /// Raised when JSON parsing, shield conversion, or fingerprint post-processing fails.
    /// Any partially created instance is freed before the exception is re-raised.
    /// </exception>
    class function Parse<T: class, constructor>(const Value: string;
      DisabledShield: Boolean = False): T; overload;
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
    function MockJsonResponse(const FieldName: string; Response: TStream): string; overload;
    function MockJsonFile(const FieldName: string; Response: TStream): string;
  public
    /// <summary>
    /// Initializes a new instance of the <c>TGenAIAPI</c> class with an API key.
    /// </summary>
    /// <param name="AAPIKey">
    /// The API key used for authenticating requests to the GenAI API.
    /// </param>
    constructor Create(const LocalLMS: Boolean = False); overload;

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
    /// Issues a GET request to the specified API <paramref name="Endpoint"/> and returns
    /// the response body as raw bytes. This method is intended for binary assets
    /// (e.g., video/image files) and handles server-side redirects to short-lived
    /// signed URLs before reading the final content.
    /// </summary>
    /// <param name="Endpoint">
    /// The relative endpoint path (for example, <c>"videos/{id}/content"</c>).
    /// The full request URL is built using the configured base URL.
    /// </param>
    /// <returns>
    /// A <see cref="TBytes"/> buffer containing the binary contents of the final response.
    /// </returns>
    /// <remarks>
    /// <para>
    /// This method uses <c>IHttpClientAPI.GetFollowRedirect</c> to explicitly follow 3xx
    /// redirects and to control header propagation across hops. The initial request includes
    /// standard authentication headers; on redirected requests, the <c>Authorization</c>
    /// header may be omitted to accommodate signed download URLs.
    /// </para>
    /// <para>
    /// Only the body of the terminal (non-redirect) response is returned; intermediate
    /// redirect responses are ignored. The method expects a successful final HTTP status
    /// (typically 200) and non-empty content.
    /// </para>
    /// <para>
    /// Any custom headers configured on the API instance are reset after the request
    /// completes. Monitoring counters are updated on entry/exit.
    /// </para>
    /// </remarks>
    function GetBinary(const Endpoint: string): TBytes;

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
    /// A stream where the response will be written.
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
    /// Sends a POST request with parameters and streams the response into a locked memory stream.
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
    /// A locked memory stream where the response will be written.
    /// </param>
    /// <param name="Event">
    /// A callback procedure for handling received data during streaming.
    /// </param>
    /// <returns>
    /// A boolean value indicating whether the request was successful.
    /// </returns>
    /// <remarks>
    /// Use this overload for SSE or other incremental streams. The callback can call
    /// <c>Response.ExtractDelta(...)</c> to atomically retrieve only the bytes appended since
    /// the previous callback, then pass those bytes to <c>TSSEDecoder.Feed</c>.
    /// </remarks>
    function Post<TParams: TJSONParam>(const Endpoint: string; ParamProc: TProc<TParams>; Response: TLockedMemoryStream; Event: TReceiveDataCallback): Boolean; overload;

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

    /// <summary>
    /// Sends a POST request with multipart form data and streams the response.
    /// </summary>
    /// <typeparam name="TParams">
    /// The type of the multipart form data parameters object.
    /// </typeparam>
    /// <param name="Endpoint">
    /// The relative endpoint to send the POST request to.
    /// </param>
    /// <param name="ParamProc">
    /// A callback procedure to configure the multipart form data parameters.
    /// </param>
    /// <param name="Response">
    /// A stream where the response will be written.
    /// </param>
    /// <param name="Event">
    /// A callback procedure for handling received data during streaming.
    /// </param>
    /// <returns>
    /// A boolean value indicating whether the request was successful.
    /// </returns>
    function PostForm<TParams: TMultipartFormData, constructor>(const Endpoint: string; ParamProc: TProc<TParams>; Response: TStream; Event: TReceiveDataCallback): Boolean; overload;
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
    /// The GenAI API instance associated with this route.
    /// </summary>
    property API: TGenAIAPI read FAPI write SetAPI;

    /// <summary>
    /// Initializes a new instance of the <c>TGenAIRoute</c> class with the given API instance.
    /// </summary>
    /// <param name="AAPI">
    /// The <c>TGenAIAPI</c> instance to associate with the route.
    /// </param>
    constructor CreateRoute(AAPI: TGenAIAPI); reintroduce; virtual;
  end;

implementation

uses
  System.StrUtils, REST.Json, GenAI.Net.MediaCodec, System.DateUtils,
  GenAI.API.JsonSafeReader;

{ TGenAIAPI }

constructor TGenAIAPI.Create(const LocalLMS: Boolean);
begin
  inherited Create;
  FLMStudio := LocalLMS;
  if FLMStudio then
    begin
      FBaseUrl := TGenAIAPI.LocalUrlBase;
    end
end;

function TGenAIAPI.Post<TParams>(const Endpoint: string; ParamProc: TProc<TParams>;
  Response: TStream; Event: TReceiveDataCallback): Boolean;
var
  Params: TParams;
begin
  Monitoring.Inc;
  Params := TParams.Create;
  try
    if Assigned(ParamProc) then
      ParamProc(Params);

    var Http := NewHttpClient;
    var Code := Http.Post(BuildUrl(Endpoint), Params.JSON, Response, BuildJsonHeaders, Event);

    case Code of
      200..299:
        Result := True;
      else
        begin
          Result := False;
          Response.Position := 0;
          var ErrBytes: TBytes;
          SetLength(ErrBytes, Response.Size);
          if Length(ErrBytes) > 0 then
            Response.ReadBuffer(ErrBytes[0], Length(ErrBytes));
          DeserializeErrorData(Code, TEncoding.UTF8.GetString(ErrBytes));
        end;
    end;
  finally
    Params.Free;
    ResetCustomHeader;
    Monitoring.Dec;
  end;
end;

function TGenAIAPI.Post<TParams>(const Endpoint: string; ParamProc: TProc<TParams>;
  Response: TLockedMemoryStream; Event: TReceiveDataCallback): Boolean;
begin
  Result := Post<TParams>(Endpoint, ParamProc, TStream(Response), Event);
end;

function TGenAIAPI.Post<TResult, TParams>(const Endpoint: string; ParamProc: TProc<TParams>;
  const RawByteFieldName: string): TResult;
var
  JSONPayload: string;
begin
  Monitoring.Inc;
  var Response := TStringStream.Create('', TEncoding.UTF8);
  var Params := TParams.Create;
  try
    if Assigned(ParamProc) then
      ParamProc(Params);
    JSONPayload := Params.ToJsonString;

    var Http := NewHttpClient;
    var Code := Http.Post(BuildUrl(Endpoint), Params.JSON, Response, BuildJsonHeaders, nil);

    case Code of
      200..299:
        begin
          if RawByteFieldName.IsEmpty then
            Result := Deserialize<TResult>(Code, JSONPayload, Response.DataString)
          else
            {--- When a raw byte file is returned as the sole response: the synthetic JSON is clean,
                 so JSON shield pre-processing is disabled. }
            Result := Deserialize<TResult>(Code, JSONPayload, MockJsonResponse(RawByteFieldName, Response), True);
        end;
      else
        Result := Deserialize<TResult>(Code, JSONPayload, Response.DataString)
    end;
  finally
    Params.Free;
    Response.Free;
    ResetCustomHeader;
    Monitoring.Dec;
  end;
end;

function TGenAIAPI.Post<TParams>(const Endpoint: string; ParamProc: TProc<TParams>;
  Response: TStringStream; Event: TReceiveDataCallback): Boolean;
begin
  Monitoring.Inc;
  var Params := TParams.Create;
  try
    if Assigned(ParamProc) then
      ParamProc(Params);

    var Http := NewHttpClient;
    var Code := Http.Post(BuildUrl(Endpoint), Params.JSON, Response, BuildJsonHeaders, Event);

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
    var Http := NewHttpClient;
    var Code := Http.Post(BuildUrl(Endpoint), Response, BuildHeaders);
    Result := Deserialize<TResult>(Code, '', Response.DataString);
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
    var Http := NewHttpClient;
    var Code := Http.Delete(BuildUrl(Endpoint), Response, BuildHeaders);
    Result := Deserialize<TResult>(Code, '', Response.DataString);
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

    var Http := NewHttpClient;
    var Code := Http.Post(BuildUrl(Endpoint), Params, Response, BuildHeaders);
    Result := Deserialize<TResult>(Code, '', Response.DataString);
  finally
    Params.Free;
    Response.Free;
    ResetCustomHeader;
    Monitoring.Dec;
  end;
end;

function TGenAIAPI.PostForm<TParams>(const Endpoint: string;
  ParamProc: TProc<TParams>; Response: TStream;
  Event: TReceiveDataCallback): Boolean;
begin
  Monitoring.Inc;
  var Params := TParams.Create;
  try
    if Assigned(ParamProc) then
      ParamProc(Params);

    var Http := NewHttpClient;
    var Code := Http.Post(BuildUrl(Endpoint), Params, Response, BuildHeaders, Event);

    case Code of
      200..299:
        Result := True;
    else
      begin
        Result := False;
        Response.Position := 0;
        var ErrBytes: TBytes;
        SetLength(ErrBytes, Response.Size);
        if Length(ErrBytes) > 0 then
          Response.ReadBuffer(ErrBytes[0], Length(ErrBytes));
        DeserializeErrorData(Code, TEncoding.UTF8.GetString(ErrBytes));
      end;
    end;
  finally
    Params.Free;
    ResetCustomHeader;
    Monitoring.Dec;
  end;
end;

function TGenAIAPI.Get<TResult, TParams>(const Endpoint: string; ParamProc: TProc<TParams>): TResult;
begin
  Monitoring.Inc;
  var Response := TStringStream.Create('', TEncoding.UTF8);
  var Params := TParams.Create;
  try
    if Assigned(ParamProc) then
      ParamProc(Params);

    var Http := NewHttpClient;
    var Code := Http.Get(BuildUrl(Endpoint, Params.Value), Response, BuildHeaders);
    Result := Deserialize<TResult>(Code, '', Response.DataString);
  finally
    Response.Free;
    Params.Free;
    ResetCustomHeader;
    Monitoring.Dec;
  end;
end;

function TGenAIAPI.GetBinary(const Endpoint: string): TBytes;
var
  Url: string;
  MemoryStream: TMemoryStream;
  Code: Integer;
begin
  Monitoring.Inc;
  try
    Url := BuildUrl(Endpoint);
    MemoryStream := TMemoryStream.Create;
    try
      var Http := NewHttpClient;
      Code := Http.GetFollowRedirect(Url, MemoryStream, BuildHeaders);

      if Code <> 200 then
        raise Exception.CreateFmt('Download failed: %d', [Code]);

      if MemoryStream.Size = 0 then
        raise Exception.Create('Empty binary content');

      SetLength(Result, MemoryStream.Size);
      MemoryStream.Position := 0;
      MemoryStream.ReadBuffer(Result[0], MemoryStream.Size);
    finally
      MemoryStream.Free;
      ResetCustomHeader;
    end;
  finally
    Monitoring.Dec;
  end;
end;

function TGenAIAPI.Get<TResult>(const Endpoint: string): TResult;
begin
  Monitoring.Inc;
  var Response := TStringStream.Create('', TEncoding.UTF8);
  try
    var Http := NewHttpClient;
    var Code := Http.Get(BuildUrl(Endpoint), Response, BuildHeaders);
    Result := Deserialize<TResult>(Code, '', Response.DataString);
  finally
    Response.Free;
    ResetCustomHeader;
    Monitoring.Dec;
  end;
end;

function TGenAIAPI.GetFile<TResult>(const Endpoint: string; const JSONFieldName: string): TResult;
begin
  Monitoring.Inc;
  var Stream := TMemoryStream.Create;
  try
    var Code := GetFile(Endpoint, Stream);
    {--- The synthetic base64 JSON is clean: disable JSON shield pre-processing. }
    Result := Deserialize<TResult>(Code, '', MockJsonFile(JSONFieldName, Stream), True);
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
    var Http := NewHttpClient;
    Result := Http.Get(BuildUrl(Endpoint), Response, Headers);
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

function TGenAIAPI.MockJsonFile(const FieldName: string; Response: TStream): string;
begin
  Response.Position := 0;
  Result := Format('{"%s":"%s"}', [FieldName, TMediaCodec.EncodeBase64(Response)]);
end;

function TGenAIAPI.MockJsonResponse(const FieldName: string; Response: TStream): string;
begin
  Response.Position := 0;
  Result := Format('{"%s":"%s"}', [FieldName, TMediaCodec.EncodeBase64(Response)]);
end;

function TGenAIAPI.Patch<TResult, TParams>(const Endpoint: string; ParamProc: TProc<TParams>): TResult;
begin
  Monitoring.Inc;
  var Response := TStringStream.Create('', TEncoding.UTF8);
  var Params := TParams.Create;
  try
    if Assigned(ParamProc) then
      ParamProc(Params);

    var Http := NewHttpClient;
    var Code := Http.Patch(BuildUrl(Endpoint), Params.JSON, Response, BuildJsonHeaders);
    Result := Deserialize<TResult>(Code, '', Response.DataString);
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

function TGenAIConfiguration.BuildUrl(const Endpoint: string): string;
begin
  Result := FBaseUrl.TrimRight(['/']) + '/' + Endpoint.TrimLeft(['/']);
end;

function TGenAIConfiguration.BuildUrl(const Endpoint, Parameters: string): string;
begin
  Result := BuildUrl(Endpoint) + Parameters;
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
  if FLMStudio then
    begin
      Exit(FCustomHeaders);
    end;

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
  {--- JSON shield mechanism preserved: free-form fields are pre-processed as strings by default. }
  FMetadataManager := TDeserializationPrepare.CreateInstance;
  FMetadataAsObject := False;
end;

function TApiDeserializer.Deserialize<T>(const Code: Int64; const Payload, ResponseText: string;
  DisabledShield: Boolean): T;
begin
  Result := nil;
  case Code of
    200..299:
      try
        Result := Parse<T>(ResponseText, Payload, DisabledShield);
      except
        on E: Exception do
          raise TGenAIInvalidResponseError.Create(Code,
            Format('Non-compliant response: %s (%s)', [E.Message, E.ClassName]));
      end;
    else
      DeserializeErrorData(Code, ResponseText);
  end;
  if not Assigned(Result) then
    raise TGenAIInvalidResponseError.Create(Code, 'Non-compliant response');
end;

procedure TApiDeserializer.DeserializeErrorData(const Code: Int64; const ResponseText: string);
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

class function TApiDeserializer.Parse<T>(const Value: string; DisabledShield: Boolean): T;
begin
  Result := Parse<T>(Value, '', DisabledShield);
end;

class function TApiDeserializer.Parse<T>(const Value, Payload: string; DisabledShield: Boolean): T;
{$REGION 'Dev note'}
  (*
    Two-step (double) deserialization:

    Step 1 - Map the payload to the object graph. Unless DisabledShield is True (direct parse) or
             MetadataAsObject is True (protected fields expected as proper objects/arrays),
             free-form fields are shielded as strings by MetadataManager.Convert before
             TJson.JsonToObject.

    Step 2 - If T is a TJSONFingerprint, the formatted raw JSON is stored on JSONResponse and bound
             to every fingerprint in the graph via TJSONFingerprintBinder.Bind. Then JSONPayload is
             set and InternalFinalizeDeserialize runs the per-DTO post-processing (AfterDeserialize),
             where each object can re-parse its own JSONResponse to rebuild polymorphic / streaming
             content that RTTI cannot resolve. Formatting is best-effort and falls back to the raw
             vendor payload without breaking the deserialization flow.

    Exception safety: on any failure after allocation, the partially created instance is freed before
    re-raising, to avoid leaks.
  *)
{$ENDREGION}
var
  Obj: TObject;
begin
  Result := Default(T);
  try
    if DisabledShield then
      Result := TJson.JsonToObject<T>(Value)
    else
      case FMetadataAsObject of
        True:
          Result := TJson.JsonToObject<T>(Value);
      else
        begin
          if FMetadataManager = nil then
            raise TGenAIInvalidResponseError.Create(0,
              'MetadataManager is nil while MetadataAsObject = False');
          Result := TJson.JsonToObject<T>(FMetadataManager.Convert(Value));
        end;
      end;

    {--- Two-step finalization for fingerprint classes. }
    if Assigned(Result) and (Result is TJSONFingerprint) then
      begin
        var Formatted := Value;
        try
          var Reader := TJsonReader.Parse(Value);
          if Reader.IsValid then
            Formatted := Reader.Format();
        except
          Formatted := Value;
        end;

        (Result as TJSONFingerprint).JSONResponse := Formatted;
        TJSONFingerprintBinder.Bind(Result, Formatted);

        (Result as TJSONFingerprint).JSONPayload := Payload;
        (Result as TJSONFingerprint).InternalFinalizeDeserialize;
      end;
  except
    Obj := TObject(Result);
    if Obj <> nil then
      Obj.Free;
    raise;
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

function TApiHttpHandler.NewHttpClient: IHttpClientAPI;
begin
  Result := THttpClientAPI.CreateInstance(VerifyApiSettings);

  if Assigned(FHttpClient) then
    begin
      Result.SendTimeOut        := FHttpClient.SendTimeOut;
      Result.ConnectionTimeout  := FHttpClient.ConnectionTimeout;
      Result.ResponseTimeout    := FHttpClient.ResponseTimeout;
      Result.ProxySettings      := FHttpClient.ProxySettings;
    end;
end;

procedure TApiHttpHandler.VerifyApiSettings;
begin
  if FLMStudio then
    begin
      if FBaseUrl.IsEmpty then
        raise TGenAIAPIException.Create('Invalid LM Studio base URL.');
      Exit;
    end;

  if FAPIKey.IsEmpty or FBaseUrl.IsEmpty then
    raise TGenAIAPIException.Create('Invalid API key or base URL.');
end;

initialization
  TGenAIAPI.LocalUrlBase := 'http://127.0.0.1:1234/v1';
end.
