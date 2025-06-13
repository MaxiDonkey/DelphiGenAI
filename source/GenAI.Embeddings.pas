unit GenAI.Embeddings;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGenAI
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.SysUtils, System.Classes, System.Threading, REST.Json.Types,
  GenAI.API.Params, GenAI.API, GenAI.Types, GenAI.Async.Support, GenAI.Async.Promise;

type
  /// <summary>
  /// Represents the parameters required to create embeddings using the OpenAI API.
  /// </summary>
  /// <remarks>
  /// This class provides methods to specify different parameters for generating embeddings.
  /// The input can be a single string or an array of strings. You can also specify the model,
  /// encoding format, dimensions, and a user identifier. These parameters are used to configure
  /// the request to the OpenAI API to obtain embeddings that can be consumed by machine learning
  /// models and algorithms.
  /// </remarks>
  TEmbeddingsParams = class(TJSONParam)
  public
    /// <summary>
    /// Sets the input text for the embedding.
    /// </summary>
    /// <param name="Value">The text to embed, encoded as a string.</param>
    /// <returns>The instance of TEmbeddingsParams for method chaining.</returns>
    function Input(const Value: string): TEmbeddingsParams; overload;

    /// <summary>
    /// Sets the input text for the embedding as an array of strings.
    /// </summary>
    /// <param name="Value">The array of texts to embed.</param>
    /// <returns>The instance of TEmbeddingsParams for method chaining.</returns>
    function Input(const Value: TArray<string>): TEmbeddingsParams; overload;

    /// <summary>
    /// Specifies the model ID to be used for generating embeddings.
    /// </summary>
    /// <param name="Value">The model ID as a string.</param>
    /// <returns>The instance of TEmbeddingsParams for method chaining.</returns>
    function Model(const Value: string): TEmbeddingsParams;

    /// <summary>
    /// Sets the encoding format of the embedding output.
    /// </summary>
    /// <param name="Value">The encoding format, either as TEncodingFormat enum or string.</param>
    /// <returns>The instance of TEmbeddingsParams for method chaining.</returns>
    function EncodingFormat(const Value: TEncodingFormat): TEmbeddingsParams; overload;

    /// <summary>
    /// Sets the encoding format of the embedding output.
    /// </summary>
    /// <param name="Value">The encoding format, either as TEncodingFormat enum or string.</param>
    /// <returns>The instance of TEmbeddingsParams for method chaining.</returns>
    function EncodingFormat(const Value: string): TEmbeddingsParams; overload;

    /// <summary>
    /// Sets the number of dimensions for the embedding output.
    /// </summary>
    /// <param name="Value">The number of dimensions as an integer.</param>
    /// <returns>The instance of TEmbeddingsParams for method chaining.</returns>
    function Dimensions(const Value: Integer): TEmbeddingsParams;

    /// <summary>
    /// Specifies a unique identifier for the end-user, aiding in monitoring and abuse detection.
    /// </summary>
    /// <param name="Value">The user identifier as a string.</param>
    /// <returns>The instance of TEmbeddingsParams for method chaining.</returns>
    function User(const Value: string): TEmbeddingsParams;
  end;

  /// <summary>
  /// Represents a single embedding vector returned by the OpenAI API.
  /// </summary>
  /// <remarks>
  /// This class encapsulates the details of an embedding, including its index in the list of returned embeddings,
  /// the embedding vector itself, and the object type. It inherits from TJSONFingerprint to utilize JSON serialization
  /// capabilities.
  /// </remarks>
  TEmbedding = class(TJSONFingerprint)
  private
    FIndex: Int64;
    FEmbedding: TArray<Double>;
    FObject: string;
  public
    /// <summary>
    /// Gets or sets the index of the embedding in the list.
    /// </summary>
    /// <value>
    /// The index as an Int64.
    /// </value>
    property Index: Int64 read FIndex write FIndex;

    /// <summary>
    /// Gets or sets the embedding vector.
    /// </summary>
    /// <value>
    /// The embedding vector as an array of doubles.
    /// </value>
    property Embedding: TArray<Double> read FEmbedding write FEmbedding;

    /// <summary>
    /// Gets or sets the object type.
    /// </summary>
    /// <value>
    /// The object type as a string.
    /// </value>
    property &Object: string read FObject write FObject;
  end;

  /// <summary>
  /// Represents a collection of embedding vectors returned by the OpenAI API.
  /// </summary>
  /// <remarks>
  /// This class holds a list of TEmbedding objects, each representing an individual embedding vector.
  /// It includes methods for managing the lifecycle of these objects, including destruction. The class
  /// also inherits from TJSONFingerprint to leverage JSON serialization capabilities.
  /// </remarks>
  TEmbeddings = class(TJSONFingerprint)
  private
    FObject: string;
    FData: TArray<TEmbedding>;
  public
    /// <summary>
    /// Gets or sets the type of the object, always set to 'list'.
    /// </summary>
    /// <value>
    /// The object type as a string.
    /// </value>
    property &Object: string read FObject write FObject;

    /// <summary>
    /// Gets or sets the data array containing the embeddings.
    /// </summary>
    /// <value>
    /// An array of TEmbedding objects.
    /// </value>
    property Data: TArray<TEmbedding> read FData write FData;

    /// <summary>
    /// Destroys the instance of TEmbeddings and frees its contained embeddings.
    /// </summary>
    destructor Destroy; override;
  end;

  /// <summary>
  /// Manages asynchronous callBacks for a request using <c>TEmbeddings</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynEmbeddings</c> type extends the <c>TAsynParams&lt;TEmbeddings&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking operations.
  /// </remarks>
  TAsynEmbeddings = TAsynCallBack<TEmbeddings>;

  /// <summary>
  /// Represents a promise-based callback for asynchronous operations returning a <see cref="TEmbeddings"/> instance.
  /// </summary>
  /// <remarks>
  /// Specializes <see cref="TPromiseCallBack{TEmbeddings}"/> to streamline handling of embeddings API responses.
  /// Use this type when you need a <c>TPromise</c> that resolves with a <c>TEmbeddings</c> result.
  /// </remarks>
  TPromiseEmbeddings = TPromiseCallBack<TEmbeddings>;

  /// <summary>
  /// Provides routes for creating embeddings via the OpenAI API.
  /// </summary>
  /// <remarks>
  /// This class offers methods to asynchronously or synchronously create embeddings based on the parameters
  /// provided by the caller. It utilizes TGenAIRoute as a base to inherit API communication capabilities.
  /// </remarks>
  TEmbeddingsRoute = class(TGenAIRoute)
    /// <summary>
    /// Asynchronously creates embeddings and returns a promise that resolves with the result.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure to configure the embedding parameters using a <see cref="TEmbeddingsParams"/> instance.
    /// </param>
    /// <param name="CallBacks">
    /// An optional function providing <see cref="TPromiseEmbeddings"/> callbacks for start, success, and error handling.
    /// </param>
    /// <returns>
    /// A <c>TPromise&lt;TEmbeddings&gt;</c> that completes when the embedding creation succeeds or fails.
    /// </returns>
    /// <remarks>
    /// Internally wraps the <see cref="AsynCreate"/> method to enable awaiting the result within promise chains.
    /// If <c>CallBacks</c> is omitted, the returned promise will only handle resolution and rejection.
    /// </remarks>
    function AsyncAwaitCreate(const ParamProc: TProc<TEmbeddingsParams>;
      const CallBacks: TFunc<TPromiseEmbeddings> = nil): TPromise<TEmbeddings>;

    /// <summary>
    /// Synchronously creates embeddings based on the provided parameters.
    /// </summary>
    /// <param name="ParamProc">A procedure that configures the parameters necessary for the embeddings request.</param>
    /// <returns>
    /// An instance of TEmbeddings containing the results from the API call.
    /// </returns>
    /// <remarks>
    /// This method sends a synchronous request to the OpenAI API to generate embeddings based on the parameters
    /// specified by ParamProc. The response is returned directly to the caller.
    /// </remarks>
    function Create(const ParamProc: TProc<TEmbeddingsParams>): TEmbeddings;

    /// <summary>
    /// Asynchronously creates embeddings based on the provided parameters.
    /// </summary>
    /// <param name="ParamProc">A procedure that configures the parameters necessary for the embeddings request.</param>
    /// <param name="CallBacks">A callback function to handle the response asynchronously, which accepts a TAsynEmbeddings object.</param>
    /// <remarks>
    /// This method prepares and sends an asynchronous request to the OpenAI API to generate embeddings.
    /// The results are processed in the callback provided by the caller.
    /// </remarks>
    procedure AsynCreate(const ParamProc: TProc<TEmbeddingsParams>; const CallBacks: TFunc<TAsynEmbeddings>);

  end;

implementation

{ TEmbeddingsParams }

function TEmbeddingsParams.Input(const Value: string): TEmbeddingsParams;
begin
  Result := TEmbeddingsParams(Add('input', Value));
end;

function TEmbeddingsParams.Dimensions(const Value: Integer): TEmbeddingsParams;
begin
  Result := TEmbeddingsParams(Add('dimensions', Value));
end;

function TEmbeddingsParams.EncodingFormat(
  const Value: TEncodingFormat): TEmbeddingsParams;
begin
  Result := TEmbeddingsParams(Add('encoding_format', Value.ToString));
end;

function TEmbeddingsParams.EncodingFormat(
  const Value: string): TEmbeddingsParams;
begin
  Result := TEmbeddingsParams(Add('encoding_format', TEncodingFormat.Create(Value).ToString));
end;

function TEmbeddingsParams.Input(
  const Value: TArray<string>): TEmbeddingsParams;
begin
  Result := TEmbeddingsParams(Add('input', Value));
end;

function TEmbeddingsParams.Model(const Value: string): TEmbeddingsParams;
begin
  Result := TEmbeddingsParams(Add('model', Value));
end;

function TEmbeddingsParams.User(const Value: string): TEmbeddingsParams;
begin
  Result := TEmbeddingsParams(Add('user', Value));
end;

{ TEmbeddings }

destructor TEmbeddings.Destroy;
begin
  for var Item in FData do
    Item.Free;
  inherited;
end;

{ TEmbeddingsRoute }

function TEmbeddingsRoute.AsyncAwaitCreate(
  const ParamProc: TProc<TEmbeddingsParams>;
  const CallBacks: TFunc<TPromiseEmbeddings>): TPromise<TEmbeddings>;
begin
  Result := TAsyncAwaitHelper.WrapAsyncAwait<TEmbeddings>(
    procedure(const CallBackParams: TFunc<TAsynEmbeddings>)
    begin
      AsynCreate(ParamProc, CallBackParams);
    end,
    CallBacks);
end;

procedure TEmbeddingsRoute.AsynCreate(const ParamProc: TProc<TEmbeddingsParams>;
  const CallBacks: TFunc<TAsynEmbeddings>);
begin
  with TAsynCallBackExec<TAsynEmbeddings, TEmbeddings>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TEmbeddings
      begin
        Result := Self.Create(ParamProc);
      end);
  finally
    Free;
  end;
end;

function TEmbeddingsRoute.Create(
  const ParamProc: TProc<TEmbeddingsParams>): TEmbeddings;
begin
  Result := API.Post<TEmbeddings, TEmbeddingsParams>('embeddings', ParamProc);
end;

end.
