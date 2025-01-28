unit GenAI.Batch.Interfaces;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGenAI
      Visit the Github repository for the documentation and use examples

--------------------------------------------------------------------------------}

(*
  --- NOTE ---
   This unit provides the  <c>IBatchJSONBuilder</c>  interface, designed to construct a batch
   body for submission to OpenAI's batch processing API. The interface methods enable you to:

    - Generate  a JSONL file  from a text file  containing JSON strings (one per line), where
      each line is used as the <c>Body</c> parameter in a batch request.
    - Build the JSONL from an array of JSON objects, assigning each object to the <c>Body</c>
      parameter of a request.


   Depending  on  the  specified  URL, <c>IBatchJSONBuilder</c>  produces  the JSONL lines as
   follows:

    - For /v1/chat/completions:
       {
        "custom_id": "request-n",
        "method": "POST",
        "url": "/v1/chat/completions",
        "body":
         {"model": "gpt-4o-mini",
          "messages": [
              {"role": "system",
               "content": "You are a helpful assistant."
              }
              {"role": "user", "content": "What is 2+2?"
              }
           ]}
       }

    - For /v1/embeddings:
        {
         "custom_id": "request-p",
         "method": "POST",
         "url": "/v1/embeddings",
         "body": {
           "input": "I hate computers....",
           "model": "text-embedding-3-large",
           "encoding_format": "float"
          }
         }
*)

interface

uses
  System.SysUtils, REST.Json.Types, REST.JsonReflect, GenAI.Types;

type
  /// <summary>
  /// Represents a generic response object for batch processing, capable of holding a status code,
  /// request ID, and a response body of a specified type.
  /// </summary>
  /// <typeparam name="T">
  /// The type of the response body object. Must be a class with a parameterless constructor.
  /// </typeparam>
  TBatchResponse<T: class, constructor> = class
  private
    [JsonNameAttribute('status_code')]
    FStatusCode: Int64;
    [JsonNameAttribute('request_id')]
    FRequestId: string;
    FBody: T;
  public
    /// <summary>
    /// Gets or sets the status code of the response.
    /// </summary>
    property StatusCode: Int64 read FStatusCode write FStatusCode;
    /// <summary>
    /// Gets or sets the unique identifier for the API request.
    /// </summary>
    property RequestId: string read FRequestId write FRequestId;
    /// <summary>
    /// Gets or sets the body of the response. The type of the body is specified by the generic type parameter <typeparamref name="T"/>.
    /// </summary>
    property Body: T read FBody write FBody;
    destructor Destroy; override;
  end;

  /// <summary>
  /// Represents an error object for batch responses, providing detailed information
  /// about the error, including a machine-readable code and a human-readable message.
  /// </summary>
  TBatchResponseError = class
  private
    FCode: string;
    FMessage: string;
  public
    /// <summary>
    /// Gets or sets the machine-readable error code that identifies the type of error.
    /// </summary>
    property Code: string read FCode write FCode;
    /// <summary>
    /// Gets or sets the human-readable error message that describes the error in detail.
    /// </summary>
    property Message: string read FMessage write FMessage;
  end;

  /// <summary>
  /// Represents the output of a single batch request, including an identifier,
  /// an optional custom identifier, the response, and any associated errors.
  /// </summary>
  /// <typeparam name="T">
  /// The type of the response body object. Must be a class with a parameterless constructor.
  /// </typeparam>
  TBatchOutput<T: class, constructor> = class
  private
    FId: string;
    [JsonNameAttribute('custom_id')]
    FCustomId: string;
    FResponse: TBatchResponse<T>;
    FError: TBatchResponseError;
  public
    /// <summary>
    /// Gets or sets the unique identifier for the batch output.
    /// </summary>
    property Id: string read FId write FId;
    /// <summary>
    /// Gets or sets a developer-provided custom identifier to match outputs to inputs.
    /// </summary>
    property CustomId: string read FCustomId write FCustomId;
    /// <summary>
    /// Gets or sets the response object of the batch request.
    /// This contains the status, request ID, and response body.
    /// </summary>
    property Response: TBatchResponse<T> read FResponse write FResponse;
    /// <summary>
    /// Gets or sets the error object containing details of any error that occurred during the batch request.
    /// </summary>
    property Error: TBatchResponseError read FError write FError;
    destructor Destroy; override;
  end;

  /// <summary>
  /// Represents an interface for reading and deserializing JSONL (JSON Lines) input into
  /// a strongly typed array of batch output objects.
  /// </summary>
  /// <typeparam name="T">
  /// The type of the response body object to be deserialized. Must be a class with a parameterless constructor.
  /// </typeparam>
  IJSONLReader<T: class, constructor> = interface
    ['{A156F579-606F-4B01-B6CA-B11CA6770AC6}']
    /// <summary>
    /// Deserializes a JSONL-formatted string into an array of <typeparamref name="TBatchOutput{T}"/> objects.
    /// </summary>
    /// <param name="Value">
    /// The JSONL-formatted input string to be deserialized.
    /// </param>
    /// <returns>
    /// An array of deserialized <typeparamref name="TBatchOutput{T}"/> objects.
    /// </returns>
    function Deserialize(const Value: string): TArray<TBatchOutput<T>>;
  end;

  /// <summary>
  ///  The <c>IBatchJSONBuilder</c> interface defines the methods to create and manage
  ///  JSON batch requests. It can generate a batch string from single or multiple input
  ///  values, as well as write the generated batch data directly to a file.
  /// </summary>
  IBatchJSONBuilder = interface
    ['{35CDFC80-3BC4-4D3F-9908-6489493425B8}']
    /// <summary>
    ///  Generates a JSON batch string by taking a single string value and converting
    ///  it into a batch request to the specified <see cref="TBatchUrl"/>.
    /// </summary>
    /// <param name="Value">
    ///  The string content to be converted into a JSON request body.
    /// </param>
    /// <param name="Url">
    ///  The <see cref="TBatchUrl"/> object representing the destination URL where
    ///  the batch request will be sent.
    /// </param>
    /// <returns>
    ///  A JSON string that includes the request method ("POST"), the provided URL, and the content.
    /// </returns>
    function GenerateBatchString(const Value: string; const Url: TBatchUrl): string; overload;
    /// <summary>
    ///  Generates a JSON batch string by taking a single string value and converting
    ///  it into a batch request to the specified URL string.
    /// </summary>
    /// <param name="Value">
    ///  The string content to be converted into a JSON request body.
    /// </param>
    /// <param name="Url">
    ///  The string containing the destination URL where the batch request will be sent.
    /// </param>
    /// <returns>
    ///  A JSON string that includes the request method ("POST"), the provided URL, and the content.
    /// </returns>
    function GenerateBatchString(const Value: string; const Url: string): string; overload;
    /// <summary>
    ///  Generates a JSON batch string by taking an array of string values and converting
    ///  them into individual batch requests to the specified <see cref="TBatchUrl"/>.
    /// </summary>
    /// <param name="Value">
    ///  An array of string values, each to be included as a separate item in the JSON batch.
    /// </param>
    /// <param name="Url">
    ///  The <see cref="TBatchUrl"/> object representing the destination URL where
    ///  the batch requests will be sent.
    /// </param>
    /// <returns>
    ///  A JSON string containing multiple request objects, each mapped to a single item in the array.
    /// </returns>
    function GenerateBatchString(const Value: TArray<string>; const Url: TBatchUrl): string; overload;
    /// <summary>
    ///  Generates a JSON batch string by taking an array of string values and converting
    ///  them into individual batch requests to the specified URL string.
    /// </summary>
    /// <param name="Value">
    ///  An array of string values, each to be included as a separate item in the JSON batch.
    /// </param>
    /// <param name="Url">
    ///  The string containing the destination URL where the batch requests will be sent.
    /// </param>
    /// <returns>
    ///  A JSON string containing multiple request objects, each mapped to a single item in the array.
    /// </returns>
    function GenerateBatchString(const Value: TArray<string>; const Url: string): string; overload;
    /// <summary>
    ///  Reads the content from a specified source file, generates a JSON batch string,
    ///  and writes the output to a destination file. Each line in the source file
    ///  is treated as a separate request body.
    /// </summary>
    /// <param name="Source">
    ///  The file path of the source file that contains the input content.
    /// </param>
    /// <param name="Destination">
    ///  The file path where the generated JSON batch string will be saved.
    /// </param>
    /// <param name="Url">
    ///  The <see cref="TBatchUrl"/> object representing the destination URL where
    ///  the batch requests will be sent.
    /// </param>
    /// <returns>
    ///  The file path of the newly created batch file (identical to the <c>Destination</c>).
    /// </returns>
    function WriteBatchToFile(const Source, Destination: string; const Url: TBatchUrl): string; overload;
    /// <summary>
    ///  Reads the content from a specified source file, generates a JSON batch string,
    ///  and writes the output to a destination file. Each line in the source file
    ///  is treated as a separate request body.
    /// </summary>
    /// <param name="Source">
    ///  The file path of the source file that contains the input content.
    /// </param>
    /// <param name="Destination">
    ///  The file path where the generated JSON batch string will be saved.
    /// </param>
    /// <param name="Url">
    ///  The string containing the destination URL where the batch requests will be sent.
    /// </param>
    /// <returns>
    ///  The file path of the newly created batch file (identical to the <c>Destination</c>).
    /// </returns>
    function WriteBatchToFile(const Source, Destination: string; const Url: string): string; overload;
    /// <summary>
    ///  Takes an array of string values, generates a JSON batch string by treating each
    ///  string as a separate request body, and saves the result to the specified
    ///  destination file.
    /// </summary>
    /// <param name="Value">
    ///  An array of string values, each to be included as a separate item in the JSON batch.
    /// </param>
    /// <param name="Destination">
    ///  The file path where the generated JSON batch string will be saved.
    /// </param>
    /// <param name="Url">
    ///  The <see cref="TBatchUrl"/> object representing the destination URL where
    ///  the batch requests will be sent.
    /// </param>
    /// <returns>
    ///  The file path of the newly created batch file (identical to the <c>Destination</c>).
    /// </returns>
    function WriteBatchToFile(const Value: TArray<string>; const Destination: string; const Url: TBatchUrl): string; overload;
    /// <summary>
    ///  Takes an array of string values, generates a JSON batch string by treating each
    ///  string as a separate request body, and saves the result to the specified
    ///  destination file.
    /// </summary>
    /// <param name="Value">
    ///  An array of string values, each to be included as a separate item in the JSON batch.
    /// </param>
    /// <param name="Destination">
    ///  The file path where the generated JSON batch string will be saved.
    /// </param>
    /// <param name="Url">
    ///  The string containing the destination URL where the batch requests will be sent.
    /// </param>
    /// <returns>
    ///  The file path of the newly created batch file (identical to the <c>Destination</c>).
    /// </returns>
    function WriteBatchToFile(const Value: TArray<string>; const Destination: string; const Url: string): string; overload;
  end;

implementation

{ TBatchResponse }

destructor TBatchResponse<T>.Destroy;
begin
  if Assigned(FBody) then
    FBody.Free;
  inherited;
end;

{ TBatchOutput }

destructor TBatchOutput<T>.Destroy;
begin
  if Assigned(FResponse) then
    FResponse.Free;
  if Assigned(FError) then
    FError.Free;
  inherited;
end;

end.
