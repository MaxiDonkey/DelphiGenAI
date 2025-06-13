unit GenAI.Vector;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGenAI
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.SysUtils, System.Classes, System.Threading, System.JSON, REST.Json.Types,
  REST.JsonReflect, System.Net.URLClient,
  GenAI.API.Params, GenAI.API, GenAI.Consts, GenAI.Types, GenAI.Async.Support,
  GenAI.Async.Promise, GenAI.API.Lists, GenAI.API.Deletion, GenAI.Assistants;

type
  /// <summary>
  /// Represents URL parameters for configuring requests to manage vector stores in the OpenAI API.
  /// </summary>
  /// <remarks>
  /// The <c>TVectorStoreUrlParam</c> class is designed to facilitate customization of query parameters
  /// when interacting with the vector stores API, such as listing or filtering vector stores.
  /// It extends the base <c>TUrlAdvancedParams</c> class, inheriting functionality for parameter management.
  /// </remarks>
  TVectorStoreUrlParam = class(TUrlAdvancedParams);

  /// <summary>
  /// Represents parameters for specifying the expiration policy of a vector store in the OpenAI API.
  /// </summary>
  /// <remarks>
  /// The <c>TExpiresAfterParams</c> class is used to configure when a vector store should expire
  /// based on a specified anchor timestamp and the number of days after the anchor.
  /// This helps in automatically managing the lifecycle of vector stores.
  /// </remarks>
  TExpiresAfterParams = class(TJSONParam)
  public
    /// <summary>
    /// Specifies the anchor timestamp that determines when the expiration countdown starts.
    /// </summary>
    /// <param name="Value">
    /// A string representing the anchor, typically set to values like <c>last_active_at</c>.
    /// </param>
    /// <returns>
    /// Returns the current instance of <c>TExpiresAfterParams</c>, enabling method chaining.
    /// </returns>
    function Anchor(const Value: string): TExpiresAfterParams;

    /// <summary>
    /// Specifies the number of days after the anchor timestamp when the vector store should expire.
    /// </summary>
    /// <param name="Value">
    /// An integer representing the number of days to wait after the anchor time before expiration.
    /// </param>
    /// <returns>
    /// Returns the current instance of <c>TExpiresAfterParams</c>, enabling method chaining.
    /// </returns>
    function Days(const Value: Integer): TExpiresAfterParams;
  end;

  /// <summary>
  /// Represents the parameters required to create a new vector store in the OpenAI API.
  /// </summary>
  /// <remarks>
  /// The <c>TVectorStoreCreateParams</c> class provides methods for setting parameters such as file IDs,
  /// expiration policies, chunking strategies, and metadata. These parameters are used when making
  /// API requests to create a vector store that can be utilized by tools like file search.
  /// </remarks>
  TVectorStoreCreateParams = class(TJSONParam)
  public
    /// <summary>
    /// Specifies the file IDs to be included in the vector store.
    /// </summary>
    /// <param name="Value">
    /// A string containing one or more file IDs that the vector store should use for its creation.
    /// </param>
    /// <returns>
    /// Returns the current instance of <c>TVectorStoreCreateParams</c>, enabling method chaining.
    /// </returns>
    function FileIds(const Value: TArray<string>): TVectorStoreCreateParams;

    /// <summary>
    /// Sets the name of the vector store.
    /// </summary>
    /// <param name="Value">
    /// A string representing the desired name of the vector store.
    /// </param>
    /// <returns>
    /// Returns the current instance of <c>TVectorStoreCreateParams</c>, enabling method chaining.
    /// </returns>
    function Name(const Value: string): TVectorStoreCreateParams;

    /// <summary>
    /// Configures the expiration policy for the vector store.
    /// </summary>
    /// <param name="Value">
    /// An instance of <c>TExpiresAfterParams</c> specifying the expiration conditions,
    /// such as the anchor timestamp and number of days before expiration.
    /// </param>
    /// <returns>
    /// Returns the current instance of <c>TVectorStoreCreateParams</c>, enabling method chaining.
    /// </returns>
    function ExpiresAfter(const Value: TExpiresAfterParams): TVectorStoreCreateParams;

    /// <summary>
    /// Defines the chunking strategy to be used for processing the files in the vector store.
    /// </summary>
    /// <param name="Value">
    /// An instance of <c>TChunkingStrategyParams</c> specifying the chunk size and overlap settings.
    /// </param>
    /// <returns>
    /// Returns the current instance of <c>TVectorStoreCreateParams</c>, enabling method chaining.
    /// </returns>
    function ChunkingStrategy(const Value: TChunkingStrategyParams): TVectorStoreCreateParams;

    /// <summary>
    /// Attaches metadata to the vector store as a set of key-value pairs.
    /// </summary>
    /// <param name="Value">
    /// A <c>TJSONObject</c> containing metadata that provides additional information about the vector store.
    /// </param>
    /// <returns>
    /// Returns the current instance of <c>TVectorStoreCreateParams</c>, enabling method chaining.
    /// </returns>
    function Metadata(const Value: TJSONObject): TVectorStoreCreateParams;
  end;

  /// <summary>
  /// Represents the parameters required to update an existing vector store in the OpenAI API.
  /// </summary>
  /// <remarks>
  /// The <c>TVectorStoreUpdateParams</c> class provides methods for updating properties such as
  /// the vector store name, expiration policy, and metadata. These parameters are used when making
  /// API requests to modify an existing vector store.
  /// </remarks>
  TVectorStoreUpdateParams = class(TJSONParam)
  public
    /// <summary>
    /// Updates the name of the vector store.
    /// </summary>
    /// <param name="Value">
    /// A string representing the new name of the vector store.
    /// </param>
    /// <returns>
    /// Returns the current instance of <c>TVectorStoreUpdateParams</c>, enabling method chaining.
    /// </returns>
    function Name(const Value: string): TVectorStoreUpdateParams;

    /// <summary>
    /// Updates the expiration policy of the vector store.
    /// </summary>
    /// <param name="Value">
    /// An instance of <c>TExpiresAfterParams</c> specifying the new expiration conditions,
    /// including the anchor timestamp and number of days before expiration.
    /// </param>
    /// <returns>
    /// Returns the current instance of <c>TVectorStoreUpdateParams</c>, enabling method chaining.
    /// </returns>
    function ExpiresAfter(const Value: TExpiresAfterParams): TVectorStoreUpdateParams;

    /// <summary>
    /// Updates the metadata associated with the vector store.
    /// </summary>
    /// <param name="Value">
    /// A <c>TJSONObject</c> containing updated metadata represented as key-value pairs.
    /// This metadata can store additional structured information about the vector store.
    /// </param>
    /// <returns>
    /// Returns the current instance of <c>TVectorStoreUpdateParams</c>, enabling method chaining.
    /// </returns>
    function Metadata(const Value: TJSONObject): TVectorStoreUpdateParams;
  end;

  /// <summary>
  /// Represents the counts of files in various processing states within a vector store in the OpenAI API.
  /// </summary>
  /// <remarks>
  /// The <c>TVectorFileCounts</c> class provides detailed counts of files associated with a vector store,
  /// including files that are being processed, successfully completed, failed, or canceled.
  /// This helps monitor the status and progress of file processing in a vector store.
  /// </remarks>
  TVectorFileCounts = class
  private
    [JsonNameAttribute('in_progress')]
    FInProgress: Int64;
    FCompleted: Int64;
    FFailed: Int64;
    FCancelled: Int64;
    FTotal: Int64;
  public
    /// <summary>
    /// Gets or sets the number of files currently being processed in the vector store.
    /// </summary>
    property InProgress: Int64 read FInProgress write FInProgress;

    /// <summary>
    /// Gets or sets the number of files that have been successfully processed and completed.
    /// </summary>
    property Completed: Int64 read FCompleted write FCompleted;

    /// <summary>
    /// Gets or sets the number of files that failed during processing.
    /// </summary>
    property Failed: Int64 read FFailed write FFailed;

    /// <summary>
    /// Gets or sets the number of files whose processing was canceled.
    /// </summary>
    property Cancelled: Int64 read FCancelled write FCancelled;

    /// <summary>
    /// Gets or sets the total number of files associated with the vector store.
    /// </summary>
    property Total: Int64 read FTotal write FTotal;
  end;

  /// <summary>
  /// Represents the expiration policy for a vector store in the OpenAI API.
  /// </summary>
  /// <remarks>
  /// The <c>TExpiresAfter</c> class defines when a vector store will expire based on an anchor timestamp
  /// and the number of days after the anchor. This class is useful for managing the automatic cleanup
  /// or deactivation of vector stores.
  /// </remarks>
  TExpiresAfter = class
  private
    FAnchor: string;
    FDays: Int64;
  public
    /// <summary>
    /// Gets or sets the anchor timestamp that marks the starting point for expiration.
    /// </summary>
    /// <remarks>
    /// The anchor typically specifies the condition that triggers the expiration countdown,
    /// such as <c>last_active_at</c>.
    /// </remarks>
    property Anchor: string read FAnchor write FAnchor;

    /// <summary>
    /// Gets or sets the number of days after the anchor timestamp when the vector store should expire.
    /// </summary>
    /// <remarks>
    /// This value determines the time interval before the vector store expires.
    /// For example, if set to 30, the store will expire 30 days after the anchor date.
    /// </remarks>
    property Days: Int64 read FDays write FDays;
  end;

  TVectorStoreTimestamp = class(TJSONFingerprint)
  protected
    function GetCreatedAtAsString: string; virtual; abstract;
    function GetExpiresAtAsString: string; virtual; abstract;
    function GetLastActiveAtAsString: string; virtual; abstract;
  public
    property CreatedAtAsString: string read GetCreatedAtAsString;
    property ExpiresAtAsString: string read GetExpiresAtAsString;
    property LastActiveAtAsString: string read GetLastActiveAtAsString;
  end;

  /// <summary>
  /// Represents a vector store in the OpenAI API.
  /// </summary>
  /// <remarks>
  /// The <c>TVectorStore</c> class encapsulates the properties and status of a vector store,
  /// including its name, creation timestamp, expiration settings, file usage, and metadata.
  /// A vector store is used to store and retrieve processed files for use by tools such as file search.
  /// </remarks>
  TVectorStore = class(TVectorStoreTimestamp)
  private
    FId: string;
    FObject: string;
    [JsonNameAttribute('created_at')]
    FCreatedAt: TInt64OrNull;
    FName: TStringOrNull;
    [JsonNameAttribute('usage_bytes')]
    FUsageBytes: Int64;
    [JsonNameAttribute('file_counts')]
    FFileCounts: TVectorFileCounts;
    [JsonReflectAttribute(ctString, rtString, TRunStatusInterceptor)]
    FStatus: TRunStatus;
    [JsonNameAttribute('expires_after')]
    FExpiresAfter: TExpiresAfter;
    [JsonNameAttribute('expires_at')]
    FExpiresAt: TInt64OrNull;
    [JsonNameAttribute('last_active_at')]
    FLastActiveAt: TInt64OrNull;
    [JsonReflectAttribute(ctString, rtString, TMetadataInterceptor)]
    FMetadata: string;
  private
    function GetName: string;
    function GetCreatedAt: Int64;
    function GetExpiresAt: Int64;
    function GetLastActiveAt: Int64;
  protected
    function GetCreatedAtAsString: string; override;
    function GetExpiresAtAsString: string; override;
    function GetLastActiveAtAsString: string; override;
  public
    /// <summary>
    /// Gets or sets the unique identifier of the vector store.
    /// </summary>
    property Id: string read FId write FId;

    /// <summary>
    /// Gets or sets the object type, which is always <c>vector_store</c>.
    /// </summary>
    property &Object: string read FObject write FObject;

    /// <summary>
    /// Gets the Unix timestamp (in seconds) for when the vector store was created.
    /// </summary>
    /// <remarks>
    /// If is null then resturns 0
    /// </remarks>
    property CreatedAt: Int64 read GetCreatedAt;

    /// <summary>
    /// Gets the name of the vector store.
    /// </summary>
    property Name: string read GetName;

    /// <summary>
    /// Gets or sets the total number of bytes used by the files in the vector store.
    /// </summary>
    property UsageBytes: Int64 read FUsageBytes write FUsageBytes;

    /// <summary>
    /// Gets or sets the file count details, including the number of completed, failed, or in-progress files.
    /// </summary>
    property FileCounts: TVectorFileCounts read FFileCounts write FFileCounts;

    /// <summary>
    /// Gets or sets the status of the vector store, which can be <c>expired</c>, <c>in_progress</c>, or <c>completed</c>.
    /// </summary>
    property Status: TRunStatus read FStatus write FStatus;

    /// <summary>
    /// Gets or sets the expiration policy for the vector store.
    /// </summary>
    property ExpiresAfter: TExpiresAfter read FExpiresAfter write FExpiresAfter;

    /// <summary>
    /// Gets the Unix timestamp (in seconds) for when the vector store will expire.
    /// </summary>
    /// <remarks>
    /// If null then returns 0.
    /// </remarks>
    property ExpiresAt: Int64 read GetExpiresAt;

    /// <summary>
    /// Gets the Unix timestamp (in seconds) for when the vector store was last active.
    /// </summary>
    /// <remarks>
    /// If null then returns 0
    /// </remarks>
    property LastActiveAt: Int64 read GetLastActiveAt;

    /// <summary>
    /// Gets or sets metadata associated with the vector store, represented as key-value pairs.
    /// </summary>
    property Metadata: string read FMetadata write FMetadata;

    destructor Destroy; override;
  end;

  /// <summary>
  /// Represents a collection of vector stores in the OpenAI API.
  /// </summary>
  /// <remarks>
  /// The <c>TVectorStores</c> class is a list of <c>TVectorStore</c> objects, providing access to multiple
  /// vector stores. It allows iteration over the vector stores to retrieve details such as their status,
  /// usage, expiration policies, and metadata.
  /// </remarks>
  TVectorStores = TAdvancedList<TVectorStore>;

  /// <summary>
  /// Manages asynchronous callBacks for a request using <c>TVectorStore</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynVectorStore</c> type extends the <c>TAsynParams&lt;TVectorStore&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking operations.
  /// </remarks>
  TAsynVectorStore = TAsynCallBack<TVectorStore>;

  /// <summary>
  /// Represents a promise-based callback for asynchronous operations returning a <see cref="TVectorStore"/> instance.
  /// </summary>
  /// <remarks>
  /// Specializes <see cref="TPromiseCallBack{TVectorStore}"/> to streamline handling of vector store API responses.
  /// Use this type when you need a <c>TPromise</c> that resolves with a <c>TVectorStore</c>.
  /// </remarks>
  TPromiseVectorStore = TPromiseCallBack<TVectorStore>;

  /// <summary>
  /// Manages asynchronous callBacks for a request using <c>TVectorStores</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynVectorStores</c> type extends the <c>TAsynParams&lt;TVectorStores&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking operations.
  /// </remarks>
  TAsynVectorStores = TAsynCallBack<TVectorStores>;

  /// <summary>
  /// Represents a promise-based callback for asynchronous operations returning a <see cref="TVectorStores"/> collection.
  /// </summary>
  /// <remarks>
  /// Specializes <see cref="TPromiseCallBack{TVectorStores}"/> to streamline handling of vector store list API responses.
  /// Use this type when you need a <c>TPromise</c> that resolves with a <c>TVectorStores</c> instance.
  /// </remarks>
  TPromiseVectorStores = TPromiseCallBack<TVectorStores>;

  /// <summary>
  /// Provides methods to manage vector stores in the OpenAI API.
  /// </summary>
  /// <remarks>
  /// The <c>TVectorStoreRoute</c> class allows you to create, retrieve, update, list, and delete
  /// vector stores through various API endpoints. It supports both synchronous and asynchronous
  /// operations, making it flexible for different application needs.
  /// </remarks>
  TVectorStoreRoute = class(TGenAIRoute)
  protected
    /// <summary>
    /// Customizes headers for API requests related to vector stores.
    /// </summary>
    procedure HeaderCustomize; override;
  public
    /// <summary>
    /// Creates a new vector store asynchronously and returns a promise that resolves with the created <see cref="TVectorStore"/>.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure to configure the creation parameters via a <see cref="TVectorStoreCreateParams"/> instance.
    /// </param>
    /// <param name="CallBacks">
    /// An optional function providing <see cref="TPromiseVectorStore"/> callbacks for start, success, and error handling.
    /// </param>
    /// <returns>
    /// A <c>TPromise&lt;TVectorStore&gt;</c> that completes when the vector store creation succeeds or fails.
    /// </returns>
    /// <remarks>
    /// Internally wraps the <see cref="AsynCreate"/> method to enable awaiting the result within promise chains.
    /// If <c>CallBacks</c> is omitted, a default promise with only success and error resolution is used.
    /// </remarks>
    function AsyncAwaitCreate(const ParamProc: TProc<TVectorStoreCreateParams>;
      const CallBacks: TFunc<TPromiseVectorStore> = nil): TPromise<TVectorStore>;

    /// <summary>
    /// Retrieves a list of vector stores asynchronously and returns a promise that resolves with the result.
    /// </summary>
    /// <param name="CallBacks">
    /// An optional function providing <see cref="TPromiseVectorStores"/> callbacks for start, success, and error handling.
    /// </param>
    /// <returns>
    /// A <c>TPromise&lt;TVectorStores&gt;</c> that completes when the vector store list request succeeds or fails.
    /// </returns>
    /// <remarks>
    /// Wraps the <see cref="AsynList"/> method for use in promise-based workflows.
    /// If <c>CallBacks</c> is omitted, the promise will only handle resolution and rejection.
    /// </remarks>
    function AsyncAwaitList(const CallBacks: TFunc<TPromiseVectorStores> = nil): TPromise<TVectorStores>; overload;

    /// <summary>
    /// Retrieves a filtered list of vector stores asynchronously and returns a promise that resolves with the result.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure to configure URL parameters via a <see cref="TVectorStoreUrlParam"/> instance for filtering the list.
    /// </param>
    /// <param name="CallBacks">
    /// An optional function providing <see cref="TPromiseVectorStores"/> callbacks for start, success, and error handling.
    /// </param>
    /// <returns>
    /// A <c>TPromise&lt;TVectorStores&gt;</c> that completes when the filtered vector store list request succeeds or fails.
    /// </returns>
    /// <remarks>
    /// Internally wraps the <see cref="AsynList"/> method with parameter support to enable promise-based workflows.
    /// If <c>CallBacks</c> is omitted, the promise only handles resolution and rejection.
    /// </remarks>
    function AsyncAwaitList(const ParamProc: TProc<TVectorStoreUrlParam>;
      const CallBacks: TFunc<TPromiseVectorStores> = nil): TPromise<TVectorStores>; overload;

    /// <summary>
    /// Retrieves a specific vector store asynchronously and returns a promise that resolves with the retrieved <see cref="TVectorStore"/>.
    /// </summary>
    /// <param name="VectorStoreId">
    /// The unique identifier of the vector store to retrieve.
    /// </param>
    /// <param name="CallBacks">
    /// An optional function providing <see cref="TPromiseVectorStore"/> callbacks for start, success, and error handling.
    /// </param>
    /// <returns>
    /// A <c>TPromise&lt;TVectorStore&gt;</c> that completes when the vector store retrieval succeeds or fails.
    /// </returns>
    /// <remarks>
    /// Wraps the <see cref="AsynRetrieve"/> method to enable promise-based retrieval of vector store details.
    /// If <c>CallBacks</c> is omitted, the promise only handles resolution and rejection.
    /// </remarks>
    function AsyncAwaitRetrieve(const VectorStoreId: string;
      const CallBacks: TFunc<TPromiseVectorStore> = nil): TPromise<TVectorStore>;

    /// <summary>
    /// Updates an existing vector store asynchronously and returns a promise that resolves with the updated <see cref="TVectorStore"/>.
    /// </summary>
    /// <param name="VectorStoreId">
    /// The unique identifier of the vector store to update.
    /// </param>
    /// <param name="ParamProc">
    /// A procedure to configure update parameters via a <see cref="TVectorStoreUpdateParams"/> instance.
    /// </param>
    /// <param name="CallBacks">
    /// An optional function providing <see cref="TPromiseVectorStore"/> callbacks for start, success, and error handling.
    /// </param>
    /// <returns>
    /// A <c>TPromise&lt;TVectorStore&gt;</c> that completes when the update operation succeeds or fails.
    /// </returns>
    /// <remarks>
    /// Internally invokes <see cref="AsynUpdate"/> to perform the HTTP POST request with the specified parameters.
    /// If <c>CallBacks</c> is omitted, the promise will only manage resolution and rejection.
    /// </remarks>
    function AsyncAwaitUpdate(const VectorStoreId: string;
      const ParamProc: TProc<TVectorStoreUpdateParams>;
      const CallBacks: TFunc<TPromiseVectorStore> = nil): TPromise<TVectorStore>;

    /// <summary>
    /// Deletes a vector store asynchronously and returns a promise that resolves with the deletion result.
    /// </summary>
    /// <param name="VectorStoreId">
    /// The unique identifier of the vector store to delete.
    /// </param>
    /// <param name="CallBacks">
    /// An optional function providing <see cref="TPromiseDeletion"/> callbacks for start, success, and error handling.
    /// </param>
    /// <returns>
    /// A <c>TPromise&lt;TDeletion&gt;</c> that completes when the deletion request succeeds or fails.
    /// </returns>
    /// <remarks>
    /// Internally wraps the <see cref="AsynDelete"/> method to enable promise-based workflows for vector store removal.
    /// If <c>CallBacks</c> is omitted, the promise will handle only resolution and rejection.
    /// </remarks>
    function AsyncAwaitDelete(const VectorStoreId: string;
      const CallBacks: TFunc<TPromiseDeletion> = nil): TPromise<TDeletion>;

    /// <summary>
    /// Synchronously creates a new vector store.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure for configuring the parameters of the new vector store.
    /// </param>
    /// <returns>
    /// A <c>TVectorStore</c> object representing the created vector store.
    /// </returns>
    function Create(const ParamProc: TProc<TVectorStoreCreateParams>): TVectorStore;

    /// <summary>
    /// Synchronously retrieves a list of vector stores.
    /// </summary>
    /// <returns>
    /// A list of <c>TVectorStore</c> objects representing the vector stores.
    /// </returns>
    function List: TVectorStores; overload;

    /// <summary>
    /// Synchronously retrieves a filtered list of vector stores.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure for setting the filtering parameters for the list request.
    /// </param>
    /// <returns>
    /// A list of <c>TVectorStore</c> objects that match the specified criteria.
    /// </returns>
    function List(const ParamProc: TProc<TVectorStoreUrlParam>): TVectorStores; overload;

    /// <summary>
    /// Synchronously retrieves details of a specific vector store.
    /// </summary>
    /// <param name="VectorStoreId">
    /// The unique identifier of the vector store to retrieve.
    /// </param>
    /// <returns>
    /// A <c>TVectorStore</c> object containing the details of the specified vector store.
    /// </returns>
    function Retrieve(const VectorStoreId: string): TVectorStore;

    /// <summary>
    /// Synchronously updates an existing vector store.
    /// </summary>
    /// <param name="VectorStoreId">
    /// The unique identifier of the vector store to update.
    /// </param>
    /// <param name="ParamProc">
    /// A procedure for configuring the update parameters, such as name and expiration settings.
    /// </param>
    /// <returns>
    /// A <c>TVectorStore</c> object representing the updated vector store.
    /// </returns>
    function Update(const VectorStoreId: string;
      const ParamProc: TProc<TVectorStoreUpdateParams>): TVectorStore;

    /// <summary>
    /// Synchronously deletes a vector store.
    /// </summary>
    /// <param name="VectorStoreId">
    /// The unique identifier of the vector store to delete.
    /// </param>
    /// <returns>
    /// A <c>TDeletion</c> object indicating the status of the deletion.
    /// </returns>
    function Delete(const VectorStoreId: string): TDeletion;

    /// <summary>
    /// Asynchronously creates a new vector store.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure for setting the parameters for the vector store, such as file IDs and expiration policy.
    /// </param>
    /// <param name="CallBacks">
    /// The callback functions to handle asynchronous execution and results.
    /// </param>
    procedure AsynCreate(const ParamProc: TProc<TVectorStoreCreateParams>;
      const CallBacks: TFunc<TAsynVectorStore>);

    /// <summary>
    /// Asynchronously retrieves a list of vector stores.
    /// </summary>
    /// <param name="CallBacks">
    /// The callback functions to handle asynchronous execution and results.
    /// </param>
    procedure AsynList(const CallBacks: TFunc<TAsynVectorStores>); overload;

    /// <summary>
    /// Asynchronously retrieves a filtered list of vector stores.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure to configure filtering parameters for the vector store listing.
    /// </param>
    /// <param name="CallBacks">
    /// The callback functions to handle asynchronous execution and results.
    /// </param>
    procedure AsynList(const ParamProc: TProc<TVectorStoreUrlParam>;
      const CallBacks: TFunc<TAsynVectorStores>); overload;

    /// <summary>
    /// Asynchronously retrieves details of a specific vector store.
    /// </summary>
    /// <param name="VectorStoreId">
    /// The unique identifier of the vector store to retrieve.
    /// </param>
    /// <param name="CallBacks">
    /// The callback functions to handle asynchronous execution and results.
    /// </param>
    procedure AsynRetrieve(const VectorStoreId: string;
      const CallBacks: TFunc<TAsynVectorStore>);

    /// <summary>
    /// Asynchronously updates an existing vector store.
    /// </summary>
    /// <param name="VectorStoreId">
    /// The unique identifier of the vector store to update.
    /// </param>
    /// <param name="ParamProc">
    /// A procedure for setting the update parameters, such as name, expiration policy, or metadata.
    /// </param>
    /// <param name="CallBacks">
    /// The callback functions to handle asynchronous execution and results.
    /// </param>
    procedure AsynUpdate(const VectorStoreId: string;
      const ParamProc: TProc<TVectorStoreUpdateParams>;
      const CallBacks: TFunc<TAsynVectorStore>);

    /// <summary>
    /// Asynchronously deletes an existing vector store.
    /// </summary>
    /// <param name="VectorStoreId">
    /// The unique identifier of the vector store to delete.
    /// </param>
    /// <param name="CallBacks">
    /// The callback functions to handle asynchronous execution and results.
    /// </param>
    procedure AsynDelete(const VectorStoreId: string;
      const CallBacks: TFunc<TAsynDeletion>);
  end;

implementation

{ TVectorStoreCreateParams }

function TVectorStoreCreateParams.ChunkingStrategy(
  const Value: TChunkingStrategyParams): TVectorStoreCreateParams;
begin
  Result := TVectorStoreCreateParams(Add('chunking_strategy', Value.Detach));
end;

function TVectorStoreCreateParams.ExpiresAfter(
  const Value: TExpiresAfterParams): TVectorStoreCreateParams;
begin
  Result := TVectorStoreCreateParams(Add('expires_after', Value.Detach));
end;

function TVectorStoreCreateParams.FileIds(const Value: TArray<string>): TVectorStoreCreateParams;
begin
  Result := TVectorStoreCreateParams(Add('file_ids', Value));
end;

function TVectorStoreCreateParams.Metadata(
  const Value: TJSONObject): TVectorStoreCreateParams;
begin
  Result := TVectorStoreCreateParams(Add('metadata', Value));
end;

function TVectorStoreCreateParams.Name(const Value: string): TVectorStoreCreateParams;
begin
  Result := TVectorStoreCreateParams(Add('name', Value));
end;

{ TExpiresAfterParams }

function TExpiresAfterParams.Anchor(const Value: string): TExpiresAfterParams;
begin
  Result := TExpiresAfterParams(Add('anchor', Value));
end;

function TExpiresAfterParams.Days(const Value: Integer): TExpiresAfterParams;
begin
  Result := TExpiresAfterParams(Add('days', Value));
end;

{ TVectorStore }

destructor TVectorStore.Destroy;
begin
  if Assigned(FFileCounts) then
    FFileCounts.Free;
  if Assigned(FExpiresAfter) then
    FExpiresAfter.Free;
  inherited;
end;

function TVectorStore.GetCreatedAt: Int64;
begin
  Result := TInt64OrNull(FCreatedAt).ToInteger;
end;

function TVectorStore.GetCreatedAtAsString: string;
begin
  Result := TInt64OrNull(FCreatedAt).ToUtcDateString;
end;

function TVectorStore.GetExpiresAt: Int64;
begin
  Result := TInt64OrNull(FExpiresAt).ToInteger;
end;

function TVectorStore.GetExpiresAtAsString: string;
begin
  Result := TInt64OrNull(FExpiresAt).ToUtcDateString;
end;

function TVectorStore.GetLastActiveAt: Int64;
begin
  Result := TInt64OrNull(FLastActiveAt).ToInteger;
end;

function TVectorStore.GetLastActiveAtAsString: string;
begin
  Result := TInt64OrNull(FLastActiveAt).ToUtcDateString;
end;

function TVectorStore.GetName: string;
begin
  Result := TStringOrNull(FName).ToString;
end;

{ TVectorStoreRoute }

function TVectorStoreRoute.AsyncAwaitCreate(
  const ParamProc: TProc<TVectorStoreCreateParams>;
  const CallBacks: TFunc<TPromiseVectorStore>): TPromise<TVectorStore>;
begin
  Result := TAsyncAwaitHelper.WrapAsyncAwait<TVectorStore>(
    procedure(const CallBackParams: TFunc<TAsynVectorStore>)
    begin
      AsynCreate(ParamProc, CallBackParams);
    end,
    CallBacks);
end;

function TVectorStoreRoute.AsyncAwaitDelete(const VectorStoreId: string;
  const CallBacks: TFunc<TPromiseDeletion>): TPromise<TDeletion>;
begin
  Result := TAsyncAwaitHelper.WrapAsyncAwait<TDeletion>(
    procedure(const CallBackParams: TFunc<TAsynDeletion>)
    begin
      AsynDelete(VectorStoreId, CallBackParams);
    end,
    CallBacks);
end;

function TVectorStoreRoute.AsyncAwaitList(
  const ParamProc: TProc<TVectorStoreUrlParam>;
  const CallBacks: TFunc<TPromiseVectorStores>): TPromise<TVectorStores>;
begin
  Result := TAsyncAwaitHelper.WrapAsyncAwait<TVectorStores>(
    procedure(const CallBackParams: TFunc<TAsynVectorStores>)
    begin
      ASynList(ParamProc, CallBackParams);
    end,
    CallBacks);
end;

function TVectorStoreRoute.AsyncAwaitList(
  const CallBacks: TFunc<TPromiseVectorStores>): TPromise<TVectorStores>;
begin
  Result := TAsyncAwaitHelper.WrapAsyncAwait<TVectorStores>(
    procedure(const CallBackParams: TFunc<TAsynVectorStores>)
    begin
      ASynList(CallBackParams);
    end,
    CallBacks);
end;

function TVectorStoreRoute.AsyncAwaitRetrieve(const VectorStoreId: string;
  const CallBacks: TFunc<TPromiseVectorStore>): TPromise<TVectorStore>;
begin
  Result := TAsyncAwaitHelper.WrapAsyncAwait<TVectorStore>(
    procedure(const CallBackParams: TFunc<TAsynVectorStore>)
    begin
      AsynRetrieve(VectorStoreId, CallBackParams);
    end,
    CallBacks);
end;

function TVectorStoreRoute.AsyncAwaitUpdate(const VectorStoreId: string;
  const ParamProc: TProc<TVectorStoreUpdateParams>;
  const CallBacks: TFunc<TPromiseVectorStore>): TPromise<TVectorStore>;
begin
  Result := TAsyncAwaitHelper.WrapAsyncAwait<TVectorStore>(
    procedure(const CallBackParams: TFunc<TAsynVectorStore>)
    begin
      AsynUpdate(VectorStoreId, ParamProc, CallBackParams);
    end,
    CallBacks);
end;

procedure TVectorStoreRoute.AsynCreate(
  const ParamProc: TProc<TVectorStoreCreateParams>;
  const CallBacks: TFunc<TAsynVectorStore>);
begin
  with TAsynCallBackExec<TAsynVectorStore, TVectorStore>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TVectorStore
      begin
        Result := Self.Create(ParamProc);
      end);
  finally
    Free;
  end;
end;

procedure TVectorStoreRoute.AsynDelete(const VectorStoreId: string;
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
        Result := Self.Delete(VectorStoreId);
      end);
  finally
    Free;
  end;
end;

procedure TVectorStoreRoute.AsynList(const CallBacks: TFunc<TAsynVectorStores>);
begin
  with TAsynCallBackExec<TAsynVectorStores, TVectorStores>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TVectorStores
      begin
        Result := Self.List;
      end);
  finally
    Free;
  end;
end;

procedure TVectorStoreRoute.AsynList(
  const ParamProc: TProc<TVectorStoreUrlParam>;
  const CallBacks: TFunc<TAsynVectorStores>);
begin
  with TAsynCallBackExec<TAsynVectorStores, TVectorStores>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TVectorStores
      begin
        Result := Self.List(ParamProc);
      end);
  finally
    Free;
  end;
end;

procedure TVectorStoreRoute.AsynRetrieve(const VectorStoreId: string;
  const CallBacks: TFunc<TAsynVectorStore>);
begin
  with TAsynCallBackExec<TAsynVectorStore, TVectorStore>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TVectorStore
      begin
        Result := Self.Retrieve(VectorStoreId);
      end);
  finally
    Free;
  end;
end;

procedure TVectorStoreRoute.AsynUpdate(const VectorStoreId: string;
  const ParamProc: TProc<TVectorStoreUpdateParams>;
  const CallBacks: TFunc<TAsynVectorStore>);
begin
  with TAsynCallBackExec<TAsynVectorStore, TVectorStore>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TVectorStore
      begin
        Result := Self.Update(VectorStoreId, ParamProc);
      end);
  finally
    Free;
  end;
end;

function TVectorStoreRoute.Create(
  const ParamProc: TProc<TVectorStoreCreateParams>): TVectorStore;
begin
  HeaderCustomize;
  Result := API.Post<TVectorStore, TVectorStoreCreateParams>('vector_stores', ParamProc);
end;

function TVectorStoreRoute.Delete(
  const VectorStoreId: string): TDeletion;
begin
  HeaderCustomize;
  Result := API.Delete<TDeletion>('vector_stores/' + VectorStoreId);
end;

procedure TVectorStoreRoute.HeaderCustomize;
begin
  inherited;
  API.CustomHeaders := [TNetHeader.Create('OpenAI-Beta', 'assistants=v2')];
end;

function TVectorStoreRoute.List: TVectorStores;
begin
  HeaderCustomize;
  Result := API.Get<TVectorStores>('vector_stores');
end;

function TVectorStoreRoute.List(
  const ParamProc: TProc<TVectorStoreUrlParam>): TVectorStores;
begin
  HeaderCustomize;
  Result := API.Get<TVectorStores, TVectorStoreUrlParam>('vector_stores', ParamProc);
end;

function TVectorStoreRoute.Retrieve(const VectorStoreId: string): TVectorStore;
begin
  HeaderCustomize;
  Result := API.Get<TVectorStore>('vector_stores/' + VectorStoreId);
end;

function TVectorStoreRoute.Update(const VectorStoreId: string;
  const ParamProc: TProc<TVectorStoreUpdateParams>): TVectorStore;
begin
  HeaderCustomize;
  Result := API.Post<TVectorStore, TVectorStoreUpdateParams>('vector_stores/' + VectorStoreId, ParamProc);
end;

{ TVectorStoreUpdateParams }

function TVectorStoreUpdateParams.ExpiresAfter(
  const Value: TExpiresAfterParams): TVectorStoreUpdateParams;
begin
  Result := TVectorStoreUpdateParams(Add('expires_after', Value.Detach));
end;

function TVectorStoreUpdateParams.Metadata(
  const Value: TJSONObject): TVectorStoreUpdateParams;
begin
  Result := TVectorStoreUpdateParams(Add('metadata', Value));
end;

function TVectorStoreUpdateParams.Name(
  const Value: string): TVectorStoreUpdateParams;
begin
  Result := TVectorStoreUpdateParams(Add('name', Value));
end;

end.
