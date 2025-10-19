unit GenAI.HttpClientInterface;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGenAI
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.SysUtils, System.Classes, System.Net.HttpClient, System.Net.URLClient,
  System.JSON, System.Net.Mime;

type
  /// <summary>
  /// Interface for configuring HTTP client parameters such as timeouts and proxy settings.
  /// </summary>
  /// <remarks>
  /// This interface provides properties and methods to set and retrieve various HTTP client configurations,
  /// including send timeout, connection timeout, response timeout, and proxy settings.
  /// Implementers of this interface should ensure that these configurations are appropriately applied
  /// to the underlying HTTP client used for making web requests.
  /// </remarks>
  IHttpClientParam = interface
    ['{BCF51E39-B8CF-4706-90CC-FC93D07230BD}']
    /// <summary>
    /// Sets the send timeout for HTTP requests.
    /// </summary>
    /// <param name="Value">
    /// The timeout duration in milliseconds.
    /// </param>
    procedure SetSendTimeOut(const Value: Integer);

    /// <summary>
    /// Retrieves the send timeout value.
    /// </summary>
    /// <returns>
    /// The send timeout duration in milliseconds.
    /// </returns>
    function GetSendTimeOut: Integer;

    /// <summary>
    /// Retrieves the connection timeout value.
    /// </summary>
    /// <returns>
    /// The connection timeout duration in milliseconds.
    /// </returns>
    function GetConnectionTimeout: Integer;

    /// <summary>
    /// Sets the connection timeout for HTTP requests.
    /// </summary>
    /// <param name="Value">
    /// The timeout duration in milliseconds.
    /// </param>
    procedure SetConnectionTimeout(const Value: Integer);

    /// <summary>
    /// Retrieves the response timeout value.
    /// </summary>
    /// <returns>
    /// The response timeout duration in milliseconds.
    /// </returns>
    function GetResponseTimeout: Integer;

    /// <summary>
    /// Sets the response timeout for HTTP requests.
    /// </summary>
    /// <param name="Value">
    /// The timeout duration in milliseconds.
    /// </param>
    procedure SetResponseTimeout(const Value: Integer);

    /// <summary>
    /// Retrieves the current proxy settings.
    /// </summary>
    /// <returns>
    /// An instance of <c>TProxySettings</c> representing the proxy configuration.
    /// </returns>
    function GetProxySettings: TProxySettings;

    /// <summary>
    /// Sets the proxy settings for HTTP requests.
    /// </summary>
    /// <param name="Value">
    /// An instance of <c>TProxySettings</c> representing the desired proxy configuration.
    /// </param>
    procedure SetProxySettings(const Value: TProxySettings);

    /// <summary>
    /// The send timeout duration in milliseconds.
    /// </summary>
    /// <remarks>
    /// Defines how long the HTTP client will wait while sending a request before timing out.
    /// </remarks>
    property SendTimeOut: Integer read GetSendTimeOut write SetSendTimeOut;

    /// <summary>
    /// The connection timeout duration in milliseconds.
    /// </summary>
    /// <remarks>
    /// Defines how long the HTTP client will wait while establishing a connection before timing out.
    /// </remarks>
    property ConnectionTimeout: Integer read GetConnectionTimeout write SetConnectionTimeout;

    /// <summary>
    /// The response timeout duration in milliseconds.
    /// </summary>
    /// <remarks>
    /// Defines how long the HTTP client will wait for a response after a request has been sent before timing out.
    /// </remarks>
    property ResponseTimeout: Integer read GetResponseTimeout write SetResponseTimeout;

    /// <summary>
    /// The proxy settings for HTTP requests.
    /// </summary>
    /// <remarks>
    /// Configures the HTTP client to route requests through a specified proxy server.
    /// This is useful in environments where direct internet access is restricted.
    /// </remarks>
    property ProxySettings: TProxySettings read GetProxySettings write SetProxySettings;
  end;

  /// <summary>
  /// Interface for performing HTTP operations such as GET, POST, DELETE, and PATCH.
  /// </summary>
  /// <remarks>
  /// Extends <c>IHttpClientParam</c> to include methods for executing various HTTP requests,
  /// allowing for flexible and configurable API interactions.
  /// Implementers should provide concrete implementations for these methods to handle
  /// the specifics of making HTTP requests and processing responses.
  /// </remarks>
  IHttpClientAPI = interface(IHttpClientParam)
    ['{CEE0EB49-85AA-42EB-B147-0E3C3C09EA6D}']
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
    /// <param name="Path">
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
    function Delete(const Path: string; Response: TStringStream; const Headers: TNetHeaders): Integer;

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
    /// Sends an HTTP POST request with a JSON body to the specified URL and handles full streamed responses.
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
    function Patch(const URL: string; Body: TJSONObject; Response: TStringStream; const Headers: TNetHeaders): Integer;
  end;

implementation

end.
