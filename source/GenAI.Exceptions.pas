unit GenAI.Exceptions;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGenAI
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.SysUtils, System.Classes, System.Net.HttpClient, System.Net.URLClient,
  System.Net.Mime, System.JSON, GenAI.Errors;

type
  /// <summary>
  /// The <c>TGenAIException</c> class represents a base exception for the GenAI library.
  /// It is designed to handle error codes and messages returned by the GenAI API or other internal errors.
  /// </summary>
  /// <remarks>
  /// This class is a foundation for more specific exception classes in the GenAI library.
  /// It provides additional properties and methods to facilitate detailed error handling.
  /// </remarks>
  TGenAIException = class(Exception)
  private
    FCode: Int64;
    FErrorMessage: string;
    FParam: string;
  public
    /// <summary>
    /// Creates an instance of the <c>TGenAIException</c> class with an error code and a <c>TErrorCore</c> object.
    /// </summary>
    /// <param name="ACode">
    /// The error code associated with the exception.
    /// </param>
    /// <param name="AError">
    /// A <c>TErrorCore</c> object containing details of the error.
    /// </param>
    /// <remarks>
    /// This constructor initializes the exception with a code, error message, and optional parameter
    /// from the <c>TErrorCore</c> object.
    /// </remarks>
    constructor Create(const ACode: Int64; const AError: TErrorCore); reintroduce; overload;
    /// <summary>
    /// Creates an instance of the <c>TGenAIException</c> class with an error code and a custom error message.
    /// </summary>
    /// <param name="ACode">
    /// The error code associated with the exception.
    /// </param>
    /// <param name="Value">
    /// A custom error message describing the issue.
    /// </param>
    /// <remarks>
    /// This constructor initializes the exception with a code and a custom error message.
    /// </remarks>
    constructor Create(const ACode: Int64; const Value: string); reintroduce; overload;
    /// <summary>
    /// Formats the error message with the code and description.
    /// </summary>
    /// <returns>
    /// A formatted string in the format: "error {Code}: {ErrorMessage}".
    /// </returns>
    /// <remarks>
    /// Use this method to obtain a user-friendly error description for logging or debugging purposes.
    /// </remarks>
    function FormatErrorMessage: string;
    /// <summary>
    /// The error code associated with the exception.
    /// </summary>
    /// <value>
    /// An <c>Int64</c> representing the error code.
    /// </value>
    property Code: Int64 read FCode write FCode;
    /// <summary>
    /// The detailed error message describing the issue.
    /// </summary>
    /// <value>
    /// A <c>string</c> containing the error message.
    /// </value>
    property ErrorMessage: string read FErrorMessage write FErrorMessage;
    /// <summary>
    /// An optional parameter related to the error, providing additional context.
    /// </summary>
    /// <value>
    /// A <c>string</c> containing the parameter, or an empty string if no parameter is provided.
    /// </value>
    property Param: string read FParam write FParam;
  end;

  /// <summary>
  /// The <c>TGenAIAPIException</c> class represents a generic API-related exception.
  /// It is thrown when there is an issue with the API configuration or request process,
  /// such as a missing API token, invalid base URL, or other configuration errors.
  /// This class serves as a base for more specific API exceptions.
  /// </summary>
  TGenAIAPIException = class(Exception);

  /// <summary>
  /// Invalid Authentication or the requesting API key is not correct or your account is not part of an
  /// organization.
  /// </summary>
  /// <remarks>
  /// Ensure the API key used is correct, clear your browser cache, or generate a new one.
  /// </remarks>
  TGenAIAuthError = class(TGenAIException);

  /// <summary>
  /// Country, region, or territory not supported.
  /// </summary>
  /// <remarks>
  /// Refer to Supported countries and territories.
  /// https://platform.GenAI.com/docs/supported-countries
  /// </remarks>
  TGenAICountryNotSupportedError = class(TGenAIException);

  /// <summary>
  /// A <c>TGenAIRateLimitError</c> indicates that you have hit your assigned rate limit.
  /// This means that you have sent too many tokens or requests in a given period of time,
  /// and our services have temporarily blocked you from sending more.
  /// </summary>
  /// <remarks>
  /// Pace your requests. Read the Rate limit guide.
  /// https://platform.GenAI.com/docs/guides/rate-limits
  /// </remarks>
  TGenAIRateLimitError = class(TGenAIException);

  /// <summary>
  /// The server had an error while processing your request.
  /// </summary>
  /// <remarks>
  /// Retry your request after a brief wait and contact us if the issue persists. Check the status page.
  /// https://status.GenAI.com/
  /// </remarks>
  TGenAIServerError = class(TGenAIException);

  /// <summary>
  /// The engine is currently overloaded, please try again later.
  /// </summary>
  /// <remarks>
  /// Please retry your requests after a brief wait.
  /// </remarks>
  TGenAIEngineOverloadedError = class(TGenAIException);

  /// <summary>
  /// An <c>TGenAIInvalidResponseError</c> error occurs when the API response is either empty or not in the expected format.
  /// This error indicates that the API did not return a valid response that can be processed, possibly due to a server-side issue,
  /// a malformed request, or unexpected input data.
  /// </summary>
  TGenAIInvalidResponseError = class(TGenAIException);

implementation

{ TGenAIException }

constructor TGenAIException.Create(const ACode: Int64; const AError: TErrorCore);
begin
  var Error := (AError as TError).Error;
  Code := ACode;
  ErrorMessage := Error.Message;
  Param := Error.Param;
  inherited Create(FormatErrorMessage);
end;

constructor TGenAIException.Create(const ACode: Int64; const Value: string);
begin
  Code := ACode;
  ErrorMessage := Value;
  Param := EmptyStr;
  inherited Create(FormatErrorMessage);
end;

function TGenAIException.FormatErrorMessage: string;
begin
  Result := Format('error %d: %s', [Code, ErrorMessage]);
end;

end.
