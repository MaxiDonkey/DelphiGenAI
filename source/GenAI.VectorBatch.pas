unit GenAI.VectorBatch;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGenAI
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.SysUtils, System.Classes, System.Threading, System.JSON, REST.Json.Types,
  REST.JsonReflect, System.Net.URLClient,
  GenAI.API.Params, GenAI.API, GenAI.Consts, GenAI.Types, GenAI.Async.Support,
  GenAI.API.Lists, GenAI.Assistants, GenAI.Runs, GenAI.Vector, GenAI.VectorFiles;

type
  /// <summary>
  /// Represents URL parameters for configuring requests related to file batches in a vector store using the OpenAI API.
  /// </summary>
  /// <remarks>
  /// This class extends <c>TVectorStoreFilesUrlParams</c> and provides the ability to customize the URL query parameters
  /// when listing or filtering batches of files associated with a specific vector store.
  /// It is useful for narrowing down results or retrieving batches with particular statuses.
  /// </remarks>
  TVectorStoreBatchUrlParams = TVectorStoreFilesUrlParams;

  /// <summary>
  /// Represents the parameters for creating file batches in a vector store using the OpenAI API.
  /// </summary>
  /// <remarks>
  /// This class extends <c>TVectorStoreFilesCreateParams</c> and allows users to define key parameters
  /// when creating a new batch of files in a vector store, including the file IDs and chunking strategy.
  /// These settings control how files are processed and chunked before being stored.
  /// </remarks>
  TVectorStoreBatchCreateParams = class(TJSONParam)
  public
    /// <summary>
    /// Specifies the ID of the file to be attached to the vector store.
    /// </summary>
    /// <param name="Value">
    /// A string representing the unique identifier of the file to be added to the vector store.
    /// </param>
    /// <returns>
    /// Returns the current instance of <c>TVectorStoreBatchCreateParams</c>, enabling method chaining.
    /// </returns>
    /// <remarks>
    /// This method is essential for indicating which file should be chunked and processed
    /// when creating a new vector store entry.
    /// </remarks>
    function FileId(const Value: TArray<string>): TVectorStoreBatchCreateParams;
    /// <summary>
    /// Specifies the chunking strategy to be used when processing the file.
    /// </summary>
    /// <param name="Value">
    /// An instance of <c>TChunkingStrategyParams</c> that defines settings like maximum chunk size
    /// and token overlap for dividing the file into smaller chunks.
    /// </param>
    /// <returns>
    /// Returns the current instance of <c>TVectorStoreBatchCreateParams</c>, enabling method chaining.
    /// </returns>
    /// <remarks>
    /// The chunking strategy determines how the file is split for efficient searching and retrieval
    /// within the vector store. Users can define static or auto chunking depending on their use case.
    /// </remarks>
    function ChunkingStrategy(const Value: TChunkingStrategyParams): TVectorStoreBatchCreateParams;
  end;

  /// <summary>
  /// Represents a batch of files attached to a vector store in the OpenAI API.
  /// </summary>
  /// <remarks>
  /// This class provides details about a file batch within a vector store, including its creation timestamp,
  /// status, and the number of files processed. It is used to monitor and manage the batch processing of files
  /// for indexing and retrieval in the vector store.
  /// </remarks>
  TVectorStoreBatch = class(TJSONFingerprint)
  private
    FId: string;
    FObject: string;
    [JsonNameAttribute('created_at')]
    FCreatedAt: TInt64OrNull;
    [JsonNameAttribute('vector_store_id')]
    FVectorStoreId: string;
    [JsonReflectAttribute(ctString, rtString, TRunStatusInterceptor)]
    FStatus: TRunStatus;
    [JsonNameAttribute('file_counts')]
    FFileCounts: TVectorFileCounts;
  private
    function GetCreatedAtAsString: string;
    function GetCreatedAt: Int64;
  public
    /// <summary>
    /// Gets or sets the unique identifier of the file batch.
    /// </summary>
    /// <remarks>
    /// This identifier can be used to reference the file batch in API requests such as retrieving
    /// or canceling the batch.
    /// </remarks>
    property Id: string read FId write FId;
    /// <summary>
    /// Gets or sets the object type, which is always <c>vector_store.file_batch</c>.
    /// </summary>
    property &Object: string read FObject write FObject;
    /// <summary>
    /// Gets Unix timestamp (in seconds) indicating when the file batch was created.
    /// </summary>
    property CreatedAt: Int64 read GetCreatedAt;
    /// <summary>
    /// Gets the human-readable representation of the creation timestamp.
    /// </summary>
    /// <remarks>
    /// This property converts the Unix timestamp into a readable date string to make it easier
    /// to understand when the batch was created.
    /// </remarks>
    property CreatedAtAsString: string read GetCreatedAtAsString;
    /// <summary>
    /// Gets or sets the identifier of the vector store to which this file batch belongs.
    /// </summary>
    property VectorStoreId: string read FVectorStoreId write FVectorStoreId;
    /// <summary>
    /// Gets or sets the current processing status of the file batch.
    /// </summary>
    /// <remarks>
    /// The status can be one of the following: <c>in_progress</c>, <c>completed</c>, <c>failed</c>,
    /// or <c>cancelled</c>. This status helps in monitoring the batch processing progress.
    /// </remarks>
    property Status: TRunStatus read FStatus write FStatus;
    /// <summary>
    /// Gets or sets the statistics of the files within the batch, including the counts of completed,
    /// failed, and in-progress files.
    /// </summary>
    property FileCounts: TVectorFileCounts read FFileCounts write FFileCounts;
    destructor Destroy; override;
  end;

  /// <summary>
  /// Represents a list of file batches attached to a vector store in the OpenAI API.
  /// </summary>
  /// <remarks>
  /// This class extends <c>TAdvancedList&lt;TVectorStoreBatch&gt;</c> and provides an iterable
  /// collection of file batches within a vector store. Each batch contains information such as
  /// its status, creation timestamp, and file counts.
  /// </remarks>
  TVectorStoreBatches = TAdvancedList<TVectorStoreBatch>;

  /// <summary>
  /// Manages asynchronous callBacks for a request using <c>TVectorStoreBatch</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynVectorStoreBatch</c> type extends the <c>TAsynParams&lt;TVectorStoreBatch&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking operations.
  /// </remarks>
  TAsynVectorStoreBatch = TAsynCallBack<TVectorStoreBatch>;

  /// <summary>
  /// Manages asynchronous callBacks for a request using <c>TVectorStoreBatches</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynVectorStoreBatches</c> type extends the <c>TAsynParams&lt;TVectorStoreBatches&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking operations.
  /// </remarks>
  TAsynVectorStoreBatches = TAsynCallBack<TVectorStoreBatches>;

  /// <summary>
  /// Provides methods to manage file batches within a vector store using the OpenAI API.
  /// </summary>
  /// <remarks>
  /// This class allows users to create, retrieve, cancel, and list file batches associated
  /// with a specific vector store. It supports both synchronous and asynchronous operations,
  /// enabling flexible interaction with the API for managing batch processing.
  /// </remarks>
  TVectorStoreBatchRoute = class(TGenAIRoute)
  protected
    /// <summary>
    /// Customizes headers for API requests related to vector store batches.
    /// </summary>
    procedure HeaderCustomize; override;
  public
    /// <summary>
    /// Asynchronously creates a new file batch in the specified vector store.
    /// </summary>
    /// <param name="VectorStoreId">
    /// The unique identifier of the vector store where the file batch will be created.
    /// </param>
    /// <param name="ParamProc">
    /// A procedure to configure the parameters for creating the batch, such as the list of file IDs
    /// and chunking strategy.
    /// </param>
    /// <param name="CallBacks">
    /// The callback functions to handle asynchronous execution and results.
    /// </param>
    procedure AsynCreate(const VectorStoreId: string;
      const ParamProc: TProc<TVectorStoreBatchCreateParams>;
      const CallBacks: TFunc<TAsynVectorStoreBatch>);
    /// <summary>
    /// Asynchronously retrieves details of a specific file batch within a vector store.
    /// </summary>
    /// <param name="VectorStoreId">
    /// The unique identifier of the vector store containing the batch.
    /// </param>
    /// <param name="BatchId">
    /// The unique identifier of the file batch to be retrieved.
    /// </param>
    /// <param name="CallBacks">
    /// The callback functions to handle asynchronous execution and results.
    /// </param>
    procedure AsynRetrieve(const VectorStoreId: string;
      const BatchId: string;
      const CallBacks: TFunc<TAsynVectorStoreBatch>);
    /// <summary>
    /// Asynchronously cancels a file batch that is currently being processed.
    /// </summary>
    /// <param name="VectorStoreId">
    /// The unique identifier of the vector store containing the batch.
    /// </param>
    /// <param name="BatchId">
    /// The unique identifier of the file batch to be canceled.
    /// </param>
    /// <param name="CallBacks">
    /// The callback functions to handle asynchronous execution and results.
    /// </param>
    /// <remarks>
    /// Cancelling a batch stops the processing of any files in progress as soon as possible.
    /// </remarks>
    procedure AsynCancel(const VectorStoreId: string;
      const BatchId: string;
      const CallBacks: TFunc<TAsynVectorStoreBatch>);
    /// <summary>
    /// Asynchronously lists all files within a specific batch of the vector store.
    /// </summary>
    /// <param name="VectorStoreId">
    /// The unique identifier of the vector store containing the file batch.
    /// </param>
    /// <param name="BatchId">
    /// The unique identifier of the file batch.
    /// </param>
    /// <param name="CallBacks">
    /// The callback functions to handle asynchronous execution and results.
    /// </param>
    procedure AsynList(const VectorStoreId: string;
      const BatchId: string;
      const CallBacks: TFunc<TAsynVectorStoreBatches>); overload;
    /// <summary>
    /// Asynchronously lists files in the specified file batch using filters and URL parameters.
    /// </summary>
    /// <param name="VectorStoreId">
    /// The unique identifier of the vector store containing the file batch.
    /// </param>
    /// <param name="BatchId">
    /// The unique identifier of the file batch.
    /// </param>
    /// <param name="ParamProc">
    /// A procedure to configure filters or pagination options for the file listing.
    /// </param>
    /// <param name="CallBacks">
    /// The callback functions to handle asynchronous execution and results.
    /// </param>
    procedure AsynList(const VectorStoreId: string;
      const BatchId: string;
      const ParamProc: TProc<TVectorStoreBatchUrlParams>;
      const CallBacks: TFunc<TAsynVectorStoreBatches>); overload;
    /// <summary>
    /// Synchronously creates a new file batch in the specified vector store.
    /// </summary>
    /// <param name="VectorStoreId">
    /// The unique identifier of the vector store where the file batch will be created.
    /// </param>
    /// <param name="ParamProc">
    /// A procedure to configure the parameters for creating the batch, such as file IDs
    /// and chunking strategy.
    /// </param>
    /// <returns>
    /// A <c>TVectorStoreBatch</c> object representing the created batch.
    /// </returns>
    function Create(const VectorStoreId: string; const ParamProc: TProc<TVectorStoreBatchCreateParams>): TVectorStoreBatch;
    /// <summary>
    /// Synchronously retrieves details of a specific file batch within a vector store.
    /// </summary>
    /// <param name="VectorStoreId">
    /// The unique identifier of the vector store containing the batch.
    /// </param>
    /// <param name="BatchId">
    /// The unique identifier of the file batch to be retrieved.
    /// </param>
    /// <returns>
    /// A <c>TVectorStoreBatch</c> object containing details about the specified batch.
    /// </returns>
    function Retrieve(const VectorStoreId: string; const BatchId: string): TVectorStoreBatch;
    /// <summary>
    /// Synchronously cancels a file batch that is currently being processed.
    /// </summary>
    /// <param name="VectorStoreId">
    /// The unique identifier of the vector store containing the batch.
    /// </param>
    /// <param name="BatchId">
    /// The unique identifier of the file batch to be canceled.
    /// </param>
    /// <returns>
    /// A <c>TVectorStoreBatch</c> object representing the batch after cancellation.
    /// </returns>
    function Cancel(const VectorStoreId: string; const BatchId: string): TVectorStoreBatch;
    /// <summary>
    /// Synchronously lists all files within a specific batch of the vector store.
    /// </summary>
    /// <param name="VectorStoreId">
    /// The unique identifier of the vector store containing the file batch.
    /// </param>
    /// <param name="BatchId">
    /// The unique identifier of the file batch.
    /// </param>
    /// <returns>
    /// A list of file batches as a <c>TVectorStoreBatches</c> object.
    /// </returns>
    function List(const VectorStoreId: string; const BatchId: string): TVectorStoreBatches; overload;
    /// <summary>
    /// Synchronously lists files in the specified file batch using filters and URL parameters.
    /// </summary>
    /// <param name="VectorStoreId">
    /// The unique identifier of the vector store containing the file batch.
    /// </param>
    /// <param name="BatchId">
    /// The unique identifier of the file batch.
    /// </param>
    /// <param name="ParamProc">
    /// A procedure to configure filters or pagination options for the file listing.
    /// </param>
    /// <returns>
    /// A list of file batches as a <c>TVectorStoreBatches</c> object.
    /// </returns>
    function List(const VectorStoreId: string; const BatchId: string;
      const ParamProc: TProc<TVectorStoreBatchUrlParams>): TVectorStoreBatches; overload;
  end;

implementation

{ TVectorStoreBatch }

destructor TVectorStoreBatch.Destroy;
begin
  if Assigned(FFileCounts) then
    FFileCounts.Free;
  inherited;
end;

function TVectorStoreBatch.GetCreatedAt: Int64;
begin
  Result := TInt64OrNull(FCreatedAt).ToInteger;
end;

function TVectorStoreBatch.GetCreatedAtAsString: string;
begin
  Result := TInt64OrNull(FCreatedAt).ToUtcDateString;
end;

{ TVectorStoreBatchRoute }

procedure TVectorStoreBatchRoute.AsynCancel(const VectorStoreId,
  BatchId: string; const CallBacks: TFunc<TAsynVectorStoreBatch>);
begin
  with TAsynCallBackExec<TAsynVectorStoreBatch, TVectorStoreBatch>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TVectorStoreBatch
      begin
        Result := Self.Cancel(VectorStoreId, BatchId);
      end);
  finally
    Free;
  end;
end;

procedure TVectorStoreBatchRoute.AsynCreate(const VectorStoreId: string;
  const ParamProc: TProc<TVectorStoreBatchCreateParams>;
  const CallBacks: TFunc<TAsynVectorStoreBatch>);
begin
  with TAsynCallBackExec<TAsynVectorStoreBatch, TVectorStoreBatch>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TVectorStoreBatch
      begin
        Result := Self.Create(VectorStoreId, ParamProc);
      end);
  finally
    Free;
  end;
end;

procedure TVectorStoreBatchRoute.AsynList(const VectorStoreId, BatchId: string;
  const ParamProc: TProc<TVectorStoreBatchUrlParams>;
  const CallBacks: TFunc<TAsynVectorStoreBatches>);
begin
  with TAsynCallBackExec<TAsynVectorStoreBatches, TVectorStoreBatches>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TVectorStoreBatches
      begin
        Result := Self.List(VectorStoreId, BatchId, ParamProc);
      end);
  finally
    Free;
  end;
end;

procedure TVectorStoreBatchRoute.AsynList(const VectorStoreId, BatchId: string;
  const CallBacks: TFunc<TAsynVectorStoreBatches>);
begin
  with TAsynCallBackExec<TAsynVectorStoreBatches, TVectorStoreBatches>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TVectorStoreBatches
      begin
        Result := Self.List(VectorStoreId, BatchId);
      end);
  finally
    Free;
  end;
end;

procedure TVectorStoreBatchRoute.AsynRetrieve(const VectorStoreId,
  BatchId: string; const CallBacks: TFunc<TAsynVectorStoreBatch>);
begin
  with TAsynCallBackExec<TAsynVectorStoreBatch, TVectorStoreBatch>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TVectorStoreBatch
      begin
        Result := Self.Retrieve(VectorStoreId, BatchId);
      end);
  finally
    Free;
  end;
end;

function TVectorStoreBatchRoute.Cancel(const VectorStoreId,
  BatchId: string): TVectorStoreBatch;
begin
  HeaderCustomize;
  Result := API.Post<TVectorStoreBatch>('vector_stores/' + VectorStoreId + '/file_batches/' + BatchId + '/cancel');
end;

function TVectorStoreBatchRoute.Create(const VectorStoreId: string;
  const ParamProc: TProc<TVectorStoreBatchCreateParams>): TVectorStoreBatch;
begin
  HeaderCustomize;
  Result := API.Post<TVectorStoreBatch, TVectorStoreBatchCreateParams>('vector_stores/' + VectorStoreId + '/file_batches', ParamProc);
end;

procedure TVectorStoreBatchRoute.HeaderCustomize;
begin
  inherited;
  API.CustomHeaders := [TNetHeader.Create('OpenAI-Beta', 'assistants=v2')];
end;

function TVectorStoreBatchRoute.List(const VectorStoreId, BatchId: string;
  const ParamProc: TProc<TVectorStoreBatchUrlParams>): TVectorStoreBatches;
begin
  HeaderCustomize;
  Result := API.Get<TVectorStoreBatches, TVectorStoreBatchUrlParams>('vector_stores/' + VectorStoreId + '/file_batches/' + BatchId + '/files', ParamProc);
end;

function TVectorStoreBatchRoute.List(const VectorStoreId,
  BatchId: string): TVectorStoreBatches;
begin
  HeaderCustomize;
  Result := API.Get<TVectorStoreBatches>('vector_stores/' + VectorStoreId + '/file_batches/' + BatchId + '/files');
end;

function TVectorStoreBatchRoute.Retrieve(const VectorStoreId,
  BatchId: string): TVectorStoreBatch;
begin
  HeaderCustomize;
  Result := API.Get<TVectorStoreBatch>('vector_stores/' + VectorStoreId + '/file_batches/' + BatchId);
end;

{ TVectorStoreBatchCreateParams }

function TVectorStoreBatchCreateParams.ChunkingStrategy(
  const Value: TChunkingStrategyParams): TVectorStoreBatchCreateParams;
begin
  Result := TVectorStoreBatchCreateParams(Add('chunking_strategy', Value.Detach));
end;

function TVectorStoreBatchCreateParams.FileId(
  const Value: TArray<string>): TVectorStoreBatchCreateParams;
begin
  Result := TVectorStoreBatchCreateParams(Add('file_ids', Value));
end;

end.
