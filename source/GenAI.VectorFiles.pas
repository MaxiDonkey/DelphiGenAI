unit GenAI.VectorFiles;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGenAI
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.SysUtils, System.Classes, System.Threading, System.JSON, REST.Json.Types,
  REST.JsonReflect, System.Net.URLClient,
  GenAI.API.Params, GenAI.API, GenAI.Consts, GenAI.Types, GenAI.Async.Support,
  GenAI.API.Lists, GenAI.API.Deletion, GenAI.Assistants, GenAI.Runs;

type
  /// <summary>
  /// Represents URL parameters for configuring requests related to vector store files in the OpenAI API.
  /// </summary>
  /// <remarks>
  /// The <c>TVectorStoreFilesUrlParams</c> class allows users to customize the URL query parameters
  /// when listing or filtering files associated with a specific vector store.
  /// This is useful when retrieving files with particular statuses or conditions.
  /// </remarks>
  TVectorStoreFilesUrlParams = class(TUrlAdvancedParams)
  public
    /// <summary>
    /// Filters the results of the vector store files request based on a given file status.
    /// </summary>
    /// <param name="Value">
    /// A string representing the file status to filter by. Supported values typically include
    /// statuses such as <c>in_progress</c>, <c>completed</c>, <c>failed</c>, or <c>cancelled</c>.
    /// </param>
    /// <returns>
    /// Returns the current instance of <c>TVectorStoreFilesUrlParams</c>, enabling method chaining.
    /// </returns>
    /// <remarks>
    /// This method is useful for narrowing down the results to only those files with a particular
    /// status within the vector store, improving query efficiency and clarity of results.
    /// </remarks>
    function Filter(const Value: string): TVectorStoreFilesUrlParams;
  end;

  /// <summary>
  /// Represents parameters for creating vector store files in the OpenAI API.
  /// </summary>
  /// <remarks>
  /// The <c>TVectorStoreFilesCreateParams</c> class allows users to specify key parameters such as
  /// the file ID and chunking strategy when adding a file to a vector store. These parameters
  /// determine how the file will be chunked and indexed within the vector store.
  /// </remarks>
  TVectorStoreFilesCreateParams = class(TJSONParam)
  public
    /// <summary>
    /// Specifies the ID of the file to be attached to the vector store.
    /// </summary>
    /// <param name="Value">
    /// A string representing the unique identifier of the file to be added to the vector store.
    /// </param>
    /// <returns>
    /// Returns the current instance of <c>TVectorStoreFilesCreateParams</c>, enabling method chaining.
    /// </returns>
    /// <remarks>
    /// This method is essential for indicating which file should be chunked and processed
    /// when creating a new vector store entry.
    /// </remarks>
    function FileId(const Value: string): TVectorStoreFilesCreateParams;
    /// <summary>
    /// Specifies the chunking strategy to be used when processing the file.
    /// </summary>
    /// <param name="Value">
    /// An instance of <c>TChunkingStrategyParams</c> that defines settings like maximum chunk size
    /// and token overlap for dividing the file into smaller chunks.
    /// </param>
    /// <returns>
    /// Returns the current instance of <c>TVectorStoreFilesCreateParams</c>, enabling method chaining.
    /// </returns>
    /// <remarks>
    /// The chunking strategy determines how the file is split for efficient searching and retrieval
    /// within the vector store. Users can define static or auto chunking depending on their use case.
    /// </remarks>
    function ChunkingStrategy(const Value: TChunkingStrategyParams): TVectorStoreFilesCreateParams;
  end;

  /// <summary>
  /// Represents the static chunking strategy settings for dividing files into chunks in the OpenAI API.
  /// </summary>
  /// <remarks>
  /// The <c>TChunkingStrategyStatic</c> class defines the static configuration for chunking a file
  /// into smaller, overlapping segments. This strategy is used when users want precise control over
  /// the size and overlap of the chunks.
  /// </remarks>
  TChunkingStrategyStatic = class
  private
    [JsonNameAttribute('max_chunk_size_tokens')]
    FMaxChunkSizeTokens: Int64;
    [JsonNameAttribute('chunk_overlap_tokens')]
    FChunkOverlapTokens: Int64;
  public
    /// <summary>
    /// Specifies the maximum number of tokens allowed in each chunk.
    /// </summary>
    /// <remarks>
    /// The default value is typically 800 tokens. The minimum value is 100, and the maximum
    /// value is 4096. This setting controls how large each chunk will be when splitting the file.
    /// </remarks>
    property MaxChunkSizeTokens: Int64 read FMaxChunkSizeTokens write FMaxChunkSizeTokens;
    /// <summary>
    /// Specifies the number of tokens that overlap between consecutive chunks.
    /// </summary>
    /// <remarks>
    /// The default value is 400 tokens. The overlap should not exceed half of
    /// <c>MaxChunkSizeTokens</c>. Overlapping tokens help preserve context between chunks
    /// and improve search accuracy within the vector store.
    /// </remarks>
    property ChunkOverlapTokens: Int64 read FChunkOverlapTokens write FChunkOverlapTokens;
  end;

  /// <summary>
  /// Represents the chunking strategy configuration used for splitting files into chunks in the OpenAI API.
  /// </summary>
  /// <remarks>
  /// The <c>TChunkingStrategy</c> class defines how files are divided into chunks for indexing in a vector store.
  /// It supports both static and dynamic chunking strategies, depending on the configuration.
  /// </remarks>
  TChunkingStrategy = class
  private
    FType: string;
    FStatic: TChunkingStrategyStatic;
  public
    /// <summary>
    /// Specifies the type of chunking strategy being used.
    /// </summary>
    /// <remarks>
    /// The value of this property typically indicates the strategy type, such as <c>static</c>
    /// or <c>auto</c>. This helps determine how the chunking process is handled.
    /// </remarks>
    property &Type: string read FType write FType;
    /// <summary>
    /// Specifies the static chunking configuration for the vector store file.
    /// </summary>
    /// <remarks>
    /// This property contains settings for static chunking, including the maximum chunk size
    /// and token overlap. It is used when the chunking strategy is explicitly defined as static.
    /// </remarks>
    property Static: TChunkingStrategyStatic read FStatic write FStatic;
    destructor Destroy; override;
  end;

  /// <summary>
  /// Represents a file attached to a vector store in the OpenAI API.
  /// </summary>
  /// <remarks>
  /// The <c>TVectorStoreFile</c> class encapsulates details about a file added to a vector store,
  /// including its ID, usage, creation timestamp, status, and chunking strategy. This information
  /// is used to monitor file processing and storage within the vector store.
  /// </remarks>
  TVectorStoreFile = class(TJSONFingerprint)
  private
    FId: string;
    FObject: string;
    [JsonNameAttribute('usage_bytes')]
    FUsageBytes: Int64;
    [JsonNameAttribute('created_at')]
    FCreatedAt: TInt64OrNull;
    [JsonNameAttribute('vector_store_id')]
    FVectorStoreId: string;
    [JsonReflectAttribute(ctString, rtString, TRunStatusInterceptor)]
    FStatus: TRunStatus;
    [JsonNameAttribute('last_error')]
    FLastError: TLastError;
    [JsonNameAttribute('chunking_strategy')]
    FChunkingStrategy: TChunkingStrategy;
  private
    function GetCreatedAt: Int64;
    function GetCreatedAtAsString: string;
  public
    /// <summary>
    /// Gets or sets the unique identifier of the vector store file.
    /// </summary>
    property Id: string read FId write FId;
    /// <summary>
    /// Gets or sets the object type, which is always <c>vector_store.file</c>.
    /// </summary>
    property &Object: string read FObject write FObject;
    /// <summary>
    /// Gets or sets the total usage of the file in bytes within the vector store.
    /// </summary>
    /// <remarks>
    /// This value represents the amount of storage the file consumes after being chunked and indexed.
    /// </remarks>
    property UsageBytes: Int64 read FUsageBytes write FUsageBytes;
    /// <summary>
    /// Gets or sets the Unix timestamp (in seconds) indicating when the file was added to the vector store.
    /// </summary>
    property CreatedAt: Int64 read GetCreatedAt;
    /// <summary>
    /// Gets the human-readable representation of the creation timestamp.
    /// </summary>
    property CreatedAtAsString: string read GetCreatedAtAsString;
    /// <summary>
    /// Gets or sets the identifier of the vector store that the file belongs to.
    /// </summary>
    property VectorStoreId: string read FVectorStoreId write FVectorStoreId;
    /// <summary>
    /// Gets or sets the current processing status of the vector store file.
    /// </summary>
    /// <remarks>
    /// The status can be one of the following: <c>in_progress</c>, <c>completed</c>, <c>failed</c>,
    /// or <c>cancelled</c>. This status helps in monitoring the file's processing progress.
    /// </remarks>
    property Status: TRunStatus read FStatus write FStatus;
    /// <summary>
    /// Gets or sets the details of the last error that occurred while processing the file.
    /// </summary>
    /// <remarks>
    /// This property contains information about any errors encountered during file processing.
    /// If no errors occurred, the value is <c>null</c>.
    /// </remarks>
    property LastError: TLastError read FLastError write FLastError;
    /// <summary>
    /// Gets or sets the chunking strategy used to split the file.
    /// </summary>
    /// <remarks>
    /// This property defines the settings used to divide the file into smaller, overlapping chunks
    /// for indexing and search efficiency within the vector store.
    /// </remarks>
    property ChunkingStrategy: TChunkingStrategy read FChunkingStrategy write FChunkingStrategy;
    destructor Destroy; override;
  end;

  /// <summary>
  /// Represents a list of files attached to a vector store in the OpenAI API.
  /// </summary>
  /// <remarks>
  /// The <c>TVectorStoreFiles</c> class is a collection of <c>TVectorStoreFile</c> objects,
  /// providing access to details about multiple files within a vector store. It supports
  /// iteration, allowing users to retrieve information about each file, such as its status,
  /// usage, and chunking strategy.
  /// </remarks>
  TVectorStoreFiles = TAdvancedList<TVectorStoreFile>;

  /// <summary>
  /// Manages asynchronous callBacks for a request using <c>TVectorStoreFile</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynVectorStoreFile</c> type extends the <c>TAsynParams&lt;TVectorStoreFile&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking operations.
  /// </remarks>
  TAsynVectorStoreFile = TAsynCallBack<TVectorStoreFile>;

  /// <summary>
  /// Manages asynchronous callBacks for a request using <c>TVectorStoreFiles</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynVectorStoreFiles</c> type extends the <c>TAsynParams&lt;TVectorStoreFiles&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking operations.
  /// </remarks>
  TAsynVectorStoreFiles = TAsynCallBack<TVectorStoreFiles>;

  /// <summary>
  /// Provides methods to manage files within a vector store using the OpenAI API.
  /// </summary>
  /// <remarks>
  /// The <c>TVectorStoreFilesRoute</c> class allows users to create, retrieve, list, and delete
  /// files associated with a vector store. It supports both synchronous and asynchronous
  /// operations, enabling flexible interaction with the API for managing file storage and processing.
  /// </remarks>
  TVectorStoreFilesRoute = class(TGenAIRoute)
  protected
    /// <summary>
    /// Customizes headers for API requests related to vector store files.
    /// </summary>
    procedure HeaderCustomize; override;
  public
    /// <summary>
    /// Asynchronously creates a new file in the specified vector store.
    /// </summary>
    /// <param name="VectorStoreId">
    /// The unique identifier of the vector store where the file will be added.
    /// </param>
    /// <param name="ParamProc">
    /// A procedure that configures the parameters for creating the file, such as the file ID
    /// and chunking strategy.
    /// </param>
    /// <param name="CallBacks">
    /// The callback functions to handle asynchronous execution and results.
    /// </param>
    procedure AsynCreate(const VectorStoreId: string; const ParamProc: TProc<TVectorStoreFilesCreateParams>;
      const CallBacks: TFunc<TAsynVectorStoreFile>);
    /// <summary>
    /// Asynchronously retrieves a list of files from a specified vector store.
    /// </summary>
    /// <param name="VectorStoreId">
    /// The unique identifier of the vector store from which to retrieve the files.
    /// </param>
    /// <param name="CallBacks">
    /// The callback functions to handle asynchronous execution and results.
    /// </param>
    procedure AsynList(const VectorStoreId: string;
      const CallBacks: TFunc<TAsynVectorStoreFiles>); overload;
    /// <summary>
    /// Asynchronously retrieves a filtered list of files from a specified vector store.
    /// </summary>
    /// <param name="VectorStoreId">
    /// The unique identifier of the vector store from which to retrieve the files.
    /// </param>
    /// <param name="ParamProc">
    /// A procedure to configure filtering parameters for the list request, such as file status.
    /// </param>
    /// <param name="CallBacks">
    /// The callback functions to handle asynchronous execution and results.
    /// </param>
    procedure AsynList(const VectorStoreId: string;
      const ParamProc: TProc<TVectorStoreFilesUrlParams>;
      const CallBacks: TFunc<TAsynVectorStoreFiles>); overload;
    /// <summary>
    /// Asynchronously retrieves details of a specific file within a vector store.
    /// </summary>
    /// <param name="VectorStoreId">
    /// The unique identifier of the vector store containing the file.
    /// </param>
    /// <param name="FileId">
    /// The unique identifier of the file to be retrieved.
    /// </param>
    /// <param name="CallBacks">
    /// The callback functions to handle asynchronous execution and results.
    /// </param>
    procedure AsynRetrieve(const VectorStoreId: string; const FileId: string;
      const CallBacks: TFunc<TAsynVectorStoreFile>);
    /// <summary>
    /// Asynchronously deletes a file from the specified vector store.
    /// </summary>
    /// <param name="VectorStoreId">
    /// The unique identifier of the vector store from which to delete the file.
    /// </param>
    /// <param name="FileId">
    /// The unique identifier of the file to be deleted.
    /// </param>
    /// <param name="CallBacks">
    /// The callback functions to handle asynchronous execution and results.
    /// </param>
    procedure AsynDelete(const VectorStoreId: string; const FileId: string;
      const CallBacks: TFunc<TAsynDeletion>);
    /// <summary>
    /// Synchronously creates a new file in the specified vector store.
    /// </summary>
    /// <param name="VectorStoreId">
    /// The unique identifier of the vector store where the file will be added.
    /// </param>
    /// <param name="ParamProc">
    /// A procedure that configures the parameters for creating the file, such as the file ID
    /// and chunking strategy.
    /// </param>
    /// <returns>
    /// A <c>TVectorStoreFile</c> object representing the created file.
    /// </returns>
    function Create(const VectorStoreId: string; const ParamProc: TProc<TVectorStoreFilesCreateParams>): TVectorStoreFile;
    /// <summary>
    /// Synchronously retrieves a list of files from a specified vector store.
    /// </summary>
    /// <param name="VectorStoreId">
    /// The unique identifier of the vector store from which to retrieve the files.
    /// </param>
    /// <returns>
    /// A <c>TVectorStoreFiles</c> list containing information about the files.
    /// </returns>
    function List(const VectorStoreId: string): TVectorStoreFiles; overload;
    /// <summary>
    /// Synchronously retrieves a filtered list of files from a specified vector store.
    /// </summary>
    /// <param name="VectorStoreId">
    /// The unique identifier of the vector store from which to retrieve the files.
    /// </param>
    /// <param name="ParamProc">
    /// A procedure to configure filtering parameters for the list request, such as file status.
    /// </param>
    /// <returns>
    /// A <c>TVectorStoreFiles</c> list containing information about the filtered files.
    /// </returns>
    function List(const VectorStoreId: string; const ParamProc: TProc<TVectorStoreFilesUrlParams>): TVectorStoreFiles; overload;
    /// <summary>
    /// Synchronously retrieves details of a specific file within a vector store.
    /// </summary>
    /// <param name="VectorStoreId">
    /// The unique identifier of the vector store containing the file.
    /// </param>
    /// <param name="FileId">
    /// The unique identifier of the file to be retrieved.
    /// </param>
    /// <returns>
    /// A <c>TVectorStoreFile</c> object containing the details of the specified file.
    /// </returns>
    function Retrieve(const VectorStoreId: string; const FileId: string): TVectorStoreFile;
    /// <summary>
    /// Synchronously deletes a file from the specified vector store.
    /// </summary>
    /// <param name="VectorStoreId">
    /// The unique identifier of the vector store from which to delete the file.
    /// </param>
    /// <param name="FileId">
    /// The unique identifier of the file to be deleted.
    /// </param>
    /// <returns>
    /// A <c>TDeletion</c> object indicating the status of the deletion.
    /// </returns>
    function Delete(const VectorStoreId: string; const FileId: string): TDeletion;
  end;

implementation

{ TVectorStoreFilesCreateParams }

function TVectorStoreFilesCreateParams.ChunkingStrategy(
  const Value: TChunkingStrategyParams): TVectorStoreFilesCreateParams;
begin
  Result := TVectorStoreFilesCreateParams(Add('chunking_strategy', Value.Detach));
end;

function TVectorStoreFilesCreateParams.FileId(
  const Value: string): TVectorStoreFilesCreateParams;
begin
  Result := TVectorStoreFilesCreateParams(Add('file_id', Value));
end;

{ TVectorStoreFile }

destructor TVectorStoreFile.Destroy;
begin
  if Assigned(FLastError) then
    FLastError.Free;
  if Assigned(FChunkingStrategy) then
    FChunkingStrategy.Free;
  inherited;
end;

function TVectorStoreFile.GetCreatedAt: Int64;
begin
  Result := TInt64OrNull(FCreatedAt).ToInteger;
end;

function TVectorStoreFile.GetCreatedAtAsString: string;
begin
  Result := TInt64OrNull(FCreatedAt).ToUtcDateString;
end;

{ TChunkingStrategy }

destructor TChunkingStrategy.Destroy;
begin
  if Assigned(FStatic) then
    FStatic.Free;
  inherited;
end;

{ TVectorStoreFilesRoute }

procedure TVectorStoreFilesRoute.AsynCreate(const VectorStoreId: string;
  const ParamProc: TProc<TVectorStoreFilesCreateParams>;
  const CallBacks: TFunc<TAsynVectorStoreFile>);
begin
  with TAsynCallBackExec<TAsynVectorStoreFile, TVectorStoreFile>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TVectorStoreFile
      begin
        Result := Self.Create(VectorStoreId, ParamProc);
      end);
  finally
    Free;
  end;
end;

procedure TVectorStoreFilesRoute.AsynDelete(const VectorStoreId, FileId: string;
  const CallBacks: TFunc<TAsynDeletion>);
begin
  with TAsynCallBackExec<TAsynDeletion, TDeletion>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TDeletion
      begin
        Result := Self.Delete(VectorStoreId, FileId);
      end);
  finally
    Free;
  end;
end;

procedure TVectorStoreFilesRoute.AsynList(const VectorStoreId: string;
  const CallBacks: TFunc<TAsynVectorStoreFiles>);
begin
  with TAsynCallBackExec<TAsynVectorStoreFiles, TVectorStoreFiles>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TVectorStoreFiles
      begin
        Result := Self.List(VectorStoreId);
      end);
  finally
    Free;
  end;
end;

procedure TVectorStoreFilesRoute.AsynList(const VectorStoreId: string;
  const ParamProc: TProc<TVectorStoreFilesUrlParams>;
  const CallBacks: TFunc<TAsynVectorStoreFiles>);
begin
  with TAsynCallBackExec<TAsynVectorStoreFiles, TVectorStoreFiles>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TVectorStoreFiles
      begin
        Result := Self.List(VectorStoreId, ParamProc);
      end);
  finally
    Free;
  end;
end;

procedure TVectorStoreFilesRoute.AsynRetrieve(const VectorStoreId,
  FileId: string; const CallBacks: TFunc<TAsynVectorStoreFile>);
begin
  with TAsynCallBackExec<TAsynVectorStoreFile, TVectorStoreFile>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TVectorStoreFile
      begin
        Result := Self.Retrieve(VectorStoreId, FileId);
      end);
  finally
    Free;
  end;
end;

function TVectorStoreFilesRoute.Create(const VectorStoreId: string;
  const ParamProc: TProc<TVectorStoreFilesCreateParams>): TVectorStoreFile;
begin
  HeaderCustomize;
  Result := API.Post<TVectorStoreFile, TVectorStoreFilesCreateParams>('vector_stores/' + VectorStoreId + '/files', ParamProc);
end;

function TVectorStoreFilesRoute.Delete(const VectorStoreId,
  FileId: string): TDeletion;
begin
  HeaderCustomize;
  Result := API.Delete<TDeletion>('vector_stores/' + VectorStoreId + '/files/' + FileId);
end;

procedure TVectorStoreFilesRoute.HeaderCustomize;
begin
  inherited;
  API.CustomHeaders := [TNetHeader.Create('OpenAI-Beta', 'assistants=v2')];
end;

function TVectorStoreFilesRoute.List(
  const VectorStoreId: string): TVectorStoreFiles;
begin
  HeaderCustomize;
  Result := API.Get<TVectorStoreFiles>('vector_stores/' + VectorStoreId + '/files');
end;

function TVectorStoreFilesRoute.List(const VectorStoreId: string;
  const ParamProc: TProc<TVectorStoreFilesUrlParams>): TVectorStoreFiles;
begin
  HeaderCustomize;
  Result := API.Get<TVectorStoreFiles, TVectorStoreFilesUrlParams>('vector_stores/' + VectorStoreId + '/files', ParamProc);
end;

function TVectorStoreFilesRoute.Retrieve(const VectorStoreId,
  FileId: string): TVectorStoreFile;
begin
  HeaderCustomize;
  Result := API.Get<TVectorStoreFile>('vector_stores/' + VectorStoreId + '/files/' + FileId);
end;

{ TVectorStoreFilesUrlParams }

function TVectorStoreFilesUrlParams.Filter(
  const Value: string): TVectorStoreFilesUrlParams;
begin
  Result := TVectorStoreFilesUrlParams(Add('filter', Value));
end;

end.
