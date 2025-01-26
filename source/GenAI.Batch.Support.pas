unit GenAI.Batch.Support;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGenAI
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.SysUtils, System.Classes, System.Threading, System.JSON, REST.Json.Types,
  REST.JsonReflect, GenAI.API;

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
  /// Implements the <see cref="IJSONLReader{T}"/> interface for reading and deserializing
  /// JSONL (JSON Lines) input into a strongly typed array of batch output objects.
  /// </summary>
  /// <typeparam name="T">
  /// The type of the response body object to be deserialized. Must be a class with a parameterless constructor.
  /// </typeparam>
  TJSONLReader<T: class, constructor> = class(TInterfacedObject, IJSONLReader<T>)
  private
    FInput: string;
    function Input(const Value: string): TJSONLReader<T>;
    function Output: TArray<TBatchOutput<T>>;
  public
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
    /// <summary>
    /// Creates an instance of the <see cref="TJSONLReader{T}"/> class.
    /// </summary>
    /// <returns>
    /// An instance of <see cref="IJSONLReader{T}"/> for processing JSONL input.
    /// </returns>
    class function CreateInstance: IJSONLReader<T>;
  end;

implementation

{ TBatchOutput }

destructor TBatchOutput<T>.Destroy;
begin
  if Assigned(FResponse) then
    FResponse.Free;
  if Assigned(FError) then
    FError.Free;
  inherited;
end;

{ TBatchResponse }

destructor TBatchResponse<T>.Destroy;
begin
  if Assigned(FBody) then
    FBody.Free;
  inherited;
end;

{ TJSONLReader }

class function TJSONLReader<T>.CreateInstance: IJSONLReader<T>;
begin
  Result := TJSONLReader<T>.Create;
end;

function TJSONLReader<T>.Deserialize(const Value: string): TArray<TBatchOutput<T>>;
begin
  Result := Input(Value).Output;
end;

function TJSONLReader<T>.Input(const Value: string): TJSONLReader<T>;
begin
  FInput := Value;
  Result := Self;
end;

function TJSONLReader<T>.Output: TArray<TBatchOutput<T>>;
var
  Line: string;
begin
  var FStringReader := TStringReader.Create(FInput);
  try
    repeat
      Line := FStringReader.ReadLine;
      if not Line.Trim.IsEmpty then
        begin
          Result := Result + [TApiDeserializer.Parse<TBatchOutput<T>>(Line)];
        end;
    until Line.Trim.IsEmpty;
  finally
    FStringReader.Free;
  end;
end;

end.
