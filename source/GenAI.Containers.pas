unit GenAI.Containers;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGenAI
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.SysUtils, System.Classes, System.JSON,
  REST.Json.Types, REST.JsonReflect,
  GenAI.API.Params, GenAI.API, GenAI.Types, GenAI.Async.Params, GenAI.Async.Support,
  GenAI.Async.Promise;

type
  TExpiresAfterParams = class(TJSONParam)
    /// <summary>
    /// Time anchor for the expiration time. Currently only 'last_active_at' is supported.
    /// </summary>
    function Anchor(const Value: string = 'last_active_at'): TExpiresAfterParams;

    /// <summary>
    /// The number of minutes after the anchor before the container expires.
    /// </summary>
    function Minutes(const Value: Integer): TExpiresAfterParams;

    class function New: TExpiresAfterParams; overload;
    class function New(const Minutes: Integer): TExpiresAfterParams; overload;
  end;

  /// <summary>
  /// Network policy parameters controlling the container's outbound network access.
  /// </summary>
  TContainerNetworkPolicyParams = class(TJSONParam)
    /// <summary>
    /// The type of network policy. One of 'disabled' or 'allowlist'.
    /// </summary>
    function &Type(const Value: string): TContainerNetworkPolicyParams;

    /// <summary>
    /// The list of outbound domains the container is allowed to reach (used with the 'allowlist' type).
    /// </summary>
    function AllowedDomains(const Value: TArray<string>): TContainerNetworkPolicyParams;

    /// <summary>
    /// Optional domain-scoped credentials. Each item is an object with 'domain', 'name' and 'value' fields.
    /// </summary>
    function DomainSecrets(const Value: TJSONArray): TContainerNetworkPolicyParams;

    class function New: TContainerNetworkPolicyParams;
  end;

  TContainerParams = class(TJSONParam)
    /// <summary>
    /// Name of the container to create.
    /// </summary>
    function Name(const Value: string): TContainerParams;

    /// <summary>
    /// Container expiration time in seconds relative to the 'anchor' time.
    /// </summary>
    function ExpiresAfter(const Value: TExpiresAfterParams): TContainerParams;

    /// <summary>
    /// IDs of files to copy to the container.
    /// </summary>
    function FileIds(const Value: TArray<string>): TContainerParams;

    /// <summary>
    /// Memory allocated to the container. One of '1g', '4g', '16g' or '64g'.
    /// </summary>
    function MemoryLimit(const Value: string): TContainerParams;

    /// <summary>
    /// Network policy controlling the container's outbound access.
    /// </summary>
    function NetworkPolicy(const Value: TContainerNetworkPolicyParams): TContainerParams;

    /// <summary>
    /// Skills to make available within the container. Each array item is either a skill reference
    /// (<c>{ "type": "skill_reference", "skill_id": ..., "version": ... }</c>) or an inline skill
    /// (<c>{ "type": "inline", "name": ..., "description": ..., "source": { "type": "base64", "media_type": ..., "data": ... } }</c>).
    /// </summary>
    function Skills(const Value: TJSONArray): TContainerParams;

    class function New: TContainerParams; overload;
    class function New(const Name: string): TContainerParams; overload;
  end;

  TUrlContainerParams = class(TUrlParam)
    /// <summary>
    /// A cursor for use in pagination. after is an object ID that defines your place in the list.
    /// For instance, if you make a list request and receive 100 objects, ending with obj_foo, your
    /// subsequent call can include after=obj_foo in order to fetch the next page of the list.
    /// </summary>
    function After(const Value: string): TUrlContainerParams;

    /// <summary>
    /// A limit on the number of objects to be returned. Limit can range between 1 and 100, and the
    /// default is 20.
    /// </summary>
    function limit(const Value: Integer): TUrlContainerParams;

    /// <summary>
    /// Sort order by the created_at timestamp of the objects. asc for ascending order and desc for descending order.
    /// </summary>
    function Order(const Value: string = 'desc'): TUrlContainerParams;
  end;

  TExpiresAfter = class
  private
    FAnchor  : string;
    FMinutes : Int64;
  public
    /// <summary>
    /// The reference point for the expiration.
    /// </summary>
    property Anchor: string read FAnchor write FAnchor;

    /// <summary>
    /// The number of minutes after the anchor before the container expires.
    /// </summary>
    property Minutes: Int64 read FMinutes write FMinutes;
  end;

  TContainerNetworkPolicy = class
  private
    FType: string;
    [JsonNameAttribute('allowed_domains')]
    FAllowedDomains: TArray<string>;
  public
    /// <summary>
    /// The type of network policy ('disabled' or 'allowlist').
    /// </summary>
    property &Type: string read FType write FType;

    /// <summary>
    /// The list of outbound domains the container is allowed to reach.
    /// </summary>
    property AllowedDomains: TArray<string> read FAllowedDomains write FAllowedDomains;
  end;

  TContainer = class(TJSONFingerprint)
  private
    [JsonNameAttribute('created_at')]
    FCreatedAt     : Int64;
    [JsonNameAttribute('expires_after')]
    FExpiresAfter  : TExpiresAfter;
    FId            : string;
    [JsonNameAttribute('last_active_at')]
    FLastActiveAt  : Int64;
    [JsonNameAttribute('memory_limit')]
    FMemoryLimit   : string;
    FName          : string;
    [JsonNameAttribute('network_policy')]
    FNetworkPolicy : TContainerNetworkPolicy;
    FObject        : string;
    FStatus        : string;
  public
    /// <summary>
    /// Unix timestamp (in seconds) when the container was created.
    /// </summary>
    property CreatedAt: Int64 read FCreatedAt write FCreatedAt;

    /// <summary>
    /// The container will expire after this time period. The anchor is the reference point
    /// for the expiration. The minutes is the number of minutes after the anchor before the
    /// container expires.
    /// </summary>
    property ExpiresAfter: TExpiresAfter read FExpiresAfter write FExpiresAfter;

    /// <summary>
    /// Unique identifier for the container.
    /// </summary>
    property Id: string read FId write FId;

    /// <summary>
    /// Unix timestamp (in seconds) when the container was last active.
    /// </summary>
    property LastActiveAt: Int64 read FLastActiveAt write FLastActiveAt;

    /// <summary>
    /// Memory allocated to the container (e.g., '1g', '4g', '16g', '64g').
    /// </summary>
    property MemoryLimit: string read FMemoryLimit write FMemoryLimit;

    /// <summary>
    /// Name of the container.
    /// </summary>
    property Name: string read FName write FName;

    /// <summary>
    /// Network policy controlling the container's outbound access.
    /// </summary>
    property NetworkPolicy: TContainerNetworkPolicy read FNetworkPolicy write FNetworkPolicy;

    /// <summary>
    /// The type of this object.
    /// </summary>
    property &Object: string read FObject write FObject;

    /// <summary>
    /// Status of the container (e.g., active, deleted).
    /// </summary>
    property Status: string read FStatus write FStatus;

    destructor Destroy; override;
  end;

  TContainerList = class(TJSONFingerprint)
  private
    FData: TArray<TContainer>;
    FObject: string;
    [JsonNameAttribute('first_id')]
    FFirstId: string;
    [JsonNameAttribute('last_id')]
    FLastId: string;
    [JsonNameAttribute('has_more')]
    FHasMore: Boolean;
  public
    property Data: TArray<TContainer> read FData write FData;
    property &Object: string read FObject write FObject;
    property FirstId: string read FFirstId write FFirstId;
    property LastId: string read FLastId write FLastId;
    property HasMore: Boolean read FHasMore write FHasMore;
    destructor Destroy; override;
  end;

  TContainersDelete = class(TJSONFingerprint)
  private
    FId      : string;
    FObject  : string;
    FDeleted : Boolean;
  public
    /// <summary>
    /// The ID of the container to delete.
    /// </summary>
    property Id: string read FId write FId;

    /// <summary>
    /// Allways container.deleted
    /// </summary>
    property &Object: string read FObject write FObject;

    /// <summary>
    /// True if the container has been deleted
    /// </summary>
    property Deleted: Boolean read FDeleted write FDeleted;
  end;

  /// <summary>
  /// Asynchronous callback wrapper for operations that return a <c>TContainer</c> result.
  /// </summary>
  /// <remarks>
  /// <para>
  /// • Alias of <c>TAsynCallBack&lt;TContainer&gt;</c>. Exposes the framework�s event-driven async
  /// lifecycle for container operations (create, list, retrieve, delete) with dispatcher-safe notifications.
  /// </para>
  /// <para>
  /// • Typical handlers include <c>OnStart</c> (invoked when the request begins), <c>OnSuccess</c>
  /// (delivering the resolved <c>TContainer</c>), and <c>OnError</c> (propagating failures).
  /// </para>
  /// <para>
  /// • Use this alias with route methods such as <c>TContainersRoute.AsynCreate</c>,
  /// <c>TContainersRoute.AsynRetrieve</c>, and <c>TContainersRoute.AsynDelete</c>. For list operations,
  /// prefer <c>TAsynContainerList</c>.
  /// </para>
  /// <para>
  /// • The resulting <c>TContainer</c> inherits <c>TJSONFingerprint</c> and surfaces fields including
  /// <c>Id</c>, <c>Name</c>, <c>Status</c>, <c>CreatedAt</c>, and <c>ExpiresAfter</c> (anchor/minutes).
  /// </para>
  /// </remarks>
  TAsynContainer = TAsynCallBack<TContainer>;

  /// <summary>
  /// Promise-style asynchronous wrapper for operations that return a <c>TContainer</c> result.
  /// </summary>
  /// <remarks>
  /// <para>
  /// • Alias of <c>TPromiseCallBack&lt;TContainer&gt;</c>. Provides a promise-based asynchronous workflow
  /// for container operations (create, retrieve, delete), enabling structured chaining, continuation,
  /// and centralized error handling in non-blocking flows.
  /// </para>
  /// <para>
  /// • Standard promise handlers include <c>OnStart</c> (triggered when the request begins),
  /// <c>OnSuccess</c> (resolve, invoked with the completed <c>TContainer</c>), and
  /// <c>OnError</c> (reject, invoked on failure).
  /// </para>
  /// <para>
  /// • Use this alias with await-style methods such as <c>TContainersRoute.AsyncAwaitCreate</c>,
  /// <c>TContainersRoute.AsyncAwaitRetrieve</c>, or <c>TContainersRoute.AsyncAwaitDelete</c> to keep
  /// intent explicit while preserving strong typing of the promised payload.
  /// </para>
  /// <para>
  /// • The resolved <c>TContainer</c> inherits <c>TJSONFingerprint</c> and exposes fields such as
  /// <c>Id</c>, <c>Name</c>, <c>Status</c>, <c>CreatedAt</c>, and <c>ExpiresAfter</c> (anchor/minutes),
  /// along with the raw API payload accessible through the <c>JSONResponse</c> property.
  /// </para>
  /// </remarks>
  TPromiseContainer = TPromiseCallBack<TContainer>;

  /// <summary>
  /// Asynchronous callback wrapper for operations that return a <c>TContainerList</c> result.
  /// </summary>
  /// <remarks>
  /// <para>
  /// • Alias of <c>TAsynCallBack&lt;TContainerList&gt;</c>. Exposes the framework�s event-driven asynchronous
  /// lifecycle for list operations on containers (e.g., enumeration, pagination, or workspace management),
  /// enabling non-blocking execution with dispatcher-safe notifications.
  /// </para>
  /// <para>
  /// • Typical handlers include <c>OnStart</c> (invoked when the listing request begins),
  /// <c>OnSuccess</c> (delivering the resolved <c>TContainerList</c> payload), and
  /// <c>OnError</c> (triggered on failure or network error).
  /// </para>
  /// <para>
  /// • Use this alias with asynchronous methods such as <c>TContainersRoute.AsynList</c> to keep intent explicit
  /// and preserve strong typing of the callback payload.
  /// </para>
  /// <para>
  /// • The resulting <c>TContainerList</c> inherits <c>TJSONFingerprint</c> and provides pagination
  /// metadata (<c>FirstId</c>, <c>LastId</c>, <c>HasMore</c>) along with a strongly typed collection of
  /// <c>TContainer</c> instances accessible through the <c>Data</c> property.
  /// </para>
  /// </remarks>
  TAsynContainerList = TAsynCallBack<TContainerList>;

  /// <summary>
  /// Promise-style asynchronous wrapper for operations that return a <c>TContainerList</c> result.
  /// </summary>
  /// <remarks>
  /// <para>
  /// • Alias of <c>TPromiseCallBack&lt;TContainerList&gt;</c>. Provides a promise-based asynchronous workflow
  /// for container list operations (such as pagination, enumeration, or bulk retrieval), enabling structured
  /// chaining, continuation, and centralized error handling in non-blocking flows.
  /// </para>
  /// <para>
  /// • Standard promise handlers include <c>OnStart</c> (triggered when the request begins),
  /// <c>OnSuccess</c> (resolve, invoked when the operation completes successfully with a
  /// <c>TContainerList</c> payload), and <c>OnError</c> (reject, invoked in case of network or
  /// server failure).
  /// </para>
  /// <para>
  /// • Use this alias with await-style methods such as <c>TContainersRoute.AsyncAwaitList</c> to make the
  /// intent explicit while maintaining strong typing of the promised payload.
  /// </para>
  /// <para>
  /// • The resolved <c>TContainerList</c> inherits <c>TJSONFingerprint</c> and includes pagination markers
  /// (<c>FirstId</c>, <c>LastId</c>, <c>HasMore</c>) along with a strongly typed array of <c>TContainer</c>
  /// instances accessible via the <c>Data</c> property.
  /// </para>
  /// </remarks>
  TPromiseContainerList = TPromiseCallBack<TContainerList>;

  /// <summary>
  /// Asynchronous callback wrapper for operations that return a <c>TContainersDelete</c> result.
  /// </summary>
  /// <remarks>
  /// <para>
  /// • Alias of <c>TAsynCallBack&lt;TContainersDelete&gt;</c>. Exposes the framework�s event-driven asynchronous
  /// lifecycle for container deletion operations, enabling non-blocking execution with dispatcher-safe and
  /// UI-friendly notifications.
  /// </para>
  /// <para>
  /// • Typical handlers include <c>OnStart</c> (invoked when the deletion request begins),
  /// <c>OnSuccess</c> (delivering the resolved <c>TContainersDelete</c> payload), and
  /// <c>OnError</c> (triggered on failure or connection error).
  /// </para>
  /// <para>
  /// • Use this alias with asynchronous methods such as <c>TContainersRoute.AsynDelete</c> to make the intent
  /// explicit and preserve strong typing of the callback payload.
  /// </para>
  /// <para>
  /// • The resulting <c>TContainersDelete</c> inherits <c>TJSONFingerprint</c> and provides information about
  /// the deleted container, including its <c>Id</c>, <c>Object</c> type (always <c>container.deleted</c>),
  /// and the <c>Deleted</c> flag confirming the deletion.
  /// </para>
  /// </remarks>
  TAsynContainersDelete = TAsynCallBack<TContainersDelete>;

  /// <summary>
  /// Promise-style asynchronous wrapper for operations that return a <c>TContainersDelete</c> result.
  /// </summary>
  /// <remarks>
  /// <para>
  /// • Alias of <c>TPromiseCallBack&lt;TContainersDelete&gt;</c>. Provides a promise-based asynchronous
  /// workflow for container deletion operations, enabling structured chaining, continuation,
  /// and centralized error handling in non-blocking execution flows.
  /// </para>
  /// <para>
  /// • Standard promise handlers include <c>OnStart</c> (triggered when the deletion request begins),
  /// <c>OnSuccess</c> (resolve, invoked with the completed <c>TContainersDelete</c>), and
  /// <c>OnError</c> (reject, invoked on failure).
  /// </para>
  /// <para>
  /// • Use this alias with await-style methods such as <c>TContainersRoute.AsyncAwaitDelete</c> to keep
  /// intent explicit while preserving strong typing of the promised payload.
  /// </para>
  /// <para>
  /// • The resolved <c>TContainersDelete</c> inherits <c>TJSONFingerprint</c> and provides information about
  /// the deleted container, including its <c>Id</c>, <c>Object</c> type (always <c>container.deleted</c>),
  /// and the <c>Deleted</c> flag indicating successful deletion.
  /// </para>
  /// </remarks>
  TPromiseContainersDelete = TPromiseCallBack<TContainersDelete>;

  TContainersAbstractSupport = class(TGenAIRoute)
  protected
    function Create(const ParamProc: TProc<TContainerParams>): TContainer; virtual; abstract;
    function List(const ParamProc: TProc<TUrlContainerParams>): TContainerList; virtual; abstract;
    function Retrieve(const ContainerId: string): TContainer; virtual; abstract;
    function Delete(const ContainerId: string): TContainersDelete; virtual; abstract;
  end;

  TContainersAsynchronousSupport = class(TContainersAbstractSupport)
  public
    procedure AsynCreate(const ParamProc: TProc<TContainerParams>; const CallBacks: TFunc<TAsynContainer>);
    procedure AsynList(const ParamProc: TProc<TUrlContainerParams>; const CallBacks: TFunc<TAsynContainerList>);
    procedure AsynRetrieve(const ContainerId: string; const CallBacks: TFunc<TAsynContainer>);
    procedure AsynDelete(const ContainerId: string; const CallBacks: TFunc<TAsynContainersDelete>);
  end;

  TContainersRoute = class(TContainersAsynchronousSupport)
    /// <summary>
    /// Asynchronously creates a new container and returns a <c>TPromise&lt;TContainer&gt;</c> handle.
    /// </summary>
    /// <param name="ParamProc">
    /// A configuration procedure that builds the JSON body via <c>TContainerParams</c>.
    /// Use it to set fields such as <c>Name</c>, optional <c>ExpiresAfter</c> (anchor/minutes),
    /// and optional <c>FileIds</c> to copy files into the container.
    /// </param>
    /// <param name="CallBacks">
    /// (Optional) A factory that returns a <c>TPromiseContainer</c> instance, allowing you to attach
    /// promise lifecycle handlers (<c>OnStart</c>, <c>OnSuccess</c>, <c>OnError</c>).
    /// </param>
    /// <returns>
    /// A <c>TPromise&lt;TContainer&gt;</c> that resolves with the created container descriptor once the request completes.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • Performs a non-blocking <c>POST</c> to the <c>/containers</c> endpoint. The resolved <c>TContainer</c>
    /// includes identifiers, <c>Name</c>, <c>Status</c>, <c>CreatedAt</c>, and <c>ExpiresAfter</c>.
    /// The raw API payload is available via <c>TJSONFingerprint.JSONResponse</c>.
    /// </para>
    /// <para>
    /// • Internally wraps <c>TContainersRoute.AsynCreate</c> with <c>TAsyncAwaitHelper.WrapAsyncAwait</c>,
    /// exposing a promise-based interface while preserving strong typing of the result.
    /// </para>
    /// <para>
    /// • Use this method when you need non-blocking container creation with structured continuation and
    /// centralized error handling. For an event-driven alternative, use <c>AsynCreate</c>.
    /// </para>
    /// </remarks>
    function AsyncAwaitCreate(const ParamProc: TProc<TContainerParams>;
      const CallBacks: TFunc<TPromiseContainer> = nil): TPromise<TContainer>;

    /// <summary>
    /// Asynchronously retrieves a paginated list of containers and returns a <c>TPromise&lt;TContainerList&gt;</c> handle.
    /// </summary>
    /// <param name="ParamProc">
    /// A configuration procedure that builds the query string via <c>TUrlContainerParams</c>.
    /// Use it to set pagination and sorting parameters such as <c>After</c>, <c>limit</c>, and <c>Order</c>.
    /// </param>
    /// <param name="CallBacks">
    /// (Optional) A factory that returns a <c>TPromiseContainerList</c> instance, allowing you to attach
    /// promise lifecycle handlers (<c>OnStart</c>, <c>OnSuccess</c>, <c>OnError</c>).
    /// </param>
    /// <returns>
    /// A <c>TPromise&lt;TContainerList&gt;</c> that resolves with the retrieved listing once the request completes.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • Performs a non-blocking <c>GET</c> request to the <c>/containers</c> endpoint.
    /// The resolved <c>TContainerList</c> provides pagination metadata (<c>FirstId</c>, <c>LastId</c>, <c>HasMore</c>)
    /// and a typed collection of <c>TContainer</c> instances via the <c>Data</c> property.
    /// The raw API payload is available through <c>TJSONFingerprint.JSONResponse</c>.
    /// </para>
    /// <para>
    /// • Internally wraps <c>TContainersRoute.AsynList</c> with <c>TAsyncAwaitHelper.WrapAsyncAwait</c>,
    /// exposing a promise-based interface while preserving strong typing of the result.
    /// </para>
    /// <para>
    /// • Use this method to enumerate, paginate, or refresh container listings without blocking the main thread.
    /// For an event-driven alternative, use <c>AsynList</c>.
    /// </para>
    /// </remarks>
    function AsyncAwaitList(const ParamProc: TProc<TUrlContainerParams>;
      const CallBacks: TFunc<TPromiseContainerList> = nil): TPromise<TContainerList>;

    /// <summary>
    /// Asynchronously retrieves detailed information about a specific container and returns a <c>TPromise&lt;TContainer&gt;</c> handle.
    /// </summary>
    /// <param name="ContainerId">
    /// The unique identifier of the container to retrieve.
    /// </param>
    /// <param name="CallBacks">
    /// (Optional) A factory that returns a <c>TPromiseContainer</c> instance, allowing you to attach
    /// promise lifecycle handlers (<c>OnStart</c>, <c>OnSuccess</c>, <c>OnError</c>).
    /// </param>
    /// <returns>
    /// A <c>TPromise&lt;TContainer&gt;</c> that resolves with the retrieved container metadata once the request completes.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • Executes a non-blocking <c>GET</c> request to the <c>/containers/{container_id}</c> endpoint.
    /// The resolved <c>TContainer</c> object includes fields such as <c>Id</c>, <c>Name</c>, <c>Status</c>,
    /// <c>CreatedAt</c>, and <c>ExpiresAfter</c> (anchor/minutes).
    /// The raw API payload is available through <c>TJSONFingerprint.JSONResponse</c>.
    /// </para>
    /// <para>
    /// • Internally wraps <c>TContainersRoute.AsynRetrieve</c> with <c>TAsyncAwaitHelper.WrapAsyncAwait</c>,
    /// providing a promise-based interface while preserving strong typing of the result.
    /// </para>
    /// <para>
    /// • Use this method to asynchronously query the current state or metadata of a specific container
    /// without blocking the main thread. For an event-driven alternative, use <c>AsynRetrieve</c>.
    /// </para>
    /// </remarks>
    function AsyncAwaitRetrieve(const ContainerId: string;
      const CallBacks: TFunc<TPromiseContainer> = nil): TPromise<TContainer>;

    /// <summary>
    /// Asynchronously deletes a container and returns a <c>TPromise&lt;TContainersDelete&gt;</c> handle.
    /// </summary>
    /// <param name="ContainerId">
    /// The unique identifier of the container to delete.
    /// </param>
    /// <param name="CallBacks">
    /// (Optional) A factory that returns a <c>TPromiseContainersDelete</c> instance, allowing you to attach
    /// promise lifecycle handlers (<c>OnStart</c>, <c>OnSuccess</c>, <c>OnError</c>).
    /// </param>
    /// <returns>
    /// A <c>TPromise&lt;TContainersDelete&gt;</c> that resolves once the deletion request completes successfully.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • Performs a non-blocking <c>DELETE</c> request to the <c>/containers/{container_id}</c> endpoint.
    /// The resolved <c>TContainersDelete</c> object provides information about the deleted resource,
    /// including its <c>Id</c>, <c>Object</c> type (always <c>container.deleted</c>), and the <c>Deleted</c> flag
    /// confirming successful deletion. The raw API payload is preserved in <c>TJSONFingerprint.JSONResponse</c>.
    /// </para>
    /// <para>
    /// • Internally wraps <c>TContainersRoute.AsynDelete</c> with <c>TAsyncAwaitHelper.WrapAsyncAwait</c>,
    /// providing a promise-based abstraction while maintaining strong typing of the result.
    /// </para>
    /// <para>
    /// • Use this method to asynchronously remove containers without blocking execution, while retaining
    /// centralized error handling and continuation support. For an event-driven alternative, use <c>AsynDelete</c>.
    /// </para>
    /// </remarks>
    function AsyncAwaitDelete(const ContainerId: string;
      const CallBacks: TFunc<TPromiseContainersDelete> = nil): TPromise<TContainersDelete>;

    /// <summary>
    /// Creates a new container and returns a <c>TContainer</c> instance representing the created resource.
    /// </summary>
    /// <param name="ParamProc">
    /// A configuration procedure used to populate the JSON body through a <c>TContainerParams</c> instance.
    /// Use it to define the container�s <c>Name</c>, optional <c>ExpiresAfter</c> settings
    /// (anchor and duration in minutes), and optionally attach existing files via <c>FileIds</c>.
    /// </param>
    /// <returns>
    /// A <c>TContainer</c> object containing metadata and identifiers for the newly created container.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • Executes a synchronous <c>POST</c> request to the <c>/containers</c> endpoint.
    /// The <paramref name="ParamProc"/> callback is used to define the JSON request parameters
    /// through a fluent <c>TContainerParams</c> builder.
    /// </para>
    /// <para>
    /// • The returned <c>TContainer</c> includes key properties such as <c>Id</c>, <c>Name</c>,
    /// <c>Status</c>, <c>CreatedAt</c>, and <c>ExpiresAfter</c> (anchor/minutes).
    /// </para>
    /// <para>
    /// • The raw API JSON payload is preserved in the <c>JSONResponse</c> property inherited
    /// from <c>TJSONFingerprint</c>, providing access to the original response structure for
    /// debugging or inspection.
    /// </para>
    /// <para>
    /// • This method performs the operation synchronously and blocks until the container is created.
    /// For non-blocking or UI-friendly asynchronous creation, use <c>AsyncAwaitCreate</c>.
    /// </para>
    /// </remarks>
    function Create(const ParamProc: TProc<TContainerParams>): TContainer; override;

    /// <summary>
    /// Retrieves a paginated list of containers and returns a <c>TContainerList</c> containing the results.
    /// </summary>
    /// <param name="ParamProc">
    /// A configuration procedure used to populate the query string through a <c>TUrlContainerParams</c> instance.
    /// Use it to define pagination and sorting options such as <c>After</c>, <c>limit</c>, and <c>Order</c>.
    /// </param>
    /// <returns>
    /// A <c>TContainerList</c> object containing metadata and an array of <c>TContainer</c> entries that match the specified query.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • Executes a synchronous <c>GET</c> request to the <c>/containers</c> endpoint.
    /// The <paramref name="ParamProc"/> callback allows fine-grained control of pagination
    /// and sorting through the fluent <c>TUrlContainerParams</c> builder.
    /// </para>
    /// <para>
    /// • The returned <c>TContainerList</c> includes pagination metadata such as <c>FirstId</c>, <c>LastId</c>,
    /// and <c>HasMore</c>, along with a strongly typed array of <c>TContainer</c> objects accessible via the <c>Data</c> property.
    /// </para>
    /// <para>
    /// • Each <c>TContainer</c> entry provides information such as <c>Id</c>, <c>Name</c>, <c>Status</c>,
    /// <c>CreatedAt</c>, and <c>ExpiresAfter</c> (anchor/minutes).
    /// </para>
    /// <para>
    /// • The raw API JSON payload is preserved in the <c>JSONResponse</c> property inherited
    /// from <c>TJSONFingerprint</c>, allowing low-level inspection of the API response.
    /// </para>
    /// <para>
    /// • This method performs a blocking request and should be used when synchronous access is acceptable.
    /// For a non-blocking alternative with promise-based or event-driven behavior, use <c>AsyncAwaitList</c> or <c>AsynList</c>.
    /// </para>
    /// </remarks>
    function List(const ParamProc: TProc<TUrlContainerParams>): TContainerList; override;

    /// <summary>
    /// Retrieves detailed information about a specific container and returns a <c>TContainer</c> instance.
    /// </summary>
    /// <param name="ContainerId">
    /// The unique identifier of the container to retrieve.
    /// </param>
    /// <returns>
    /// A <c>TContainer</c> object containing metadata and current state information for the specified container.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • Executes a synchronous <c>GET</c> request to the <c>/containers/{container_id}</c> endpoint.
    /// The request retrieves the full record of the container identified by <paramref name="ContainerId"/>.
    /// </para>
    /// <para>
    /// • The returned <c>TContainer</c> includes fields such as <c>Id</c>, <c>Name</c>, <c>Status</c>,
    /// <c>CreatedAt</c>, and <c>ExpiresAfter</c> (anchor/minutes). These values describe the container�s
    /// lifecycle, metadata, and expiration configuration.
    /// </para>
    /// <para>
    /// • The raw JSON response from the API is preserved in the <c>JSONResponse</c> property inherited
    /// from <c>TJSONFingerprint</c>, providing access to the original payload for logging or debugging.
    /// </para>
    /// <para>
    /// • This method performs the operation synchronously and blocks until completion.
    /// For a non-blocking, asynchronous equivalent with promise-based handling, use <c>AsyncAwaitRetrieve</c>.
    /// </para>
    /// </remarks>
    function Retrieve(const ContainerId: string): TContainer; override;

    /// <summary>
    /// Deletes an existing container and returns a <c>TContainersDelete</c> instance representing the deletion result.
    /// </summary>
    /// <param name="ContainerId">
    /// The unique identifier of the container to delete.
    /// </param>
    /// <returns>
    /// A <c>TContainersDelete</c> object confirming the deletion status and containing metadata of the deleted container.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • Executes a synchronous <c>DELETE</c> request to the <c>/containers/{container_id}</c> endpoint.
    /// The request permanently removes the specified container and its associated data from the system.
    /// </para>
    /// <para>
    /// • The returned <c>TContainersDelete</c> includes the deleted container�s <c>Id</c>,
    /// the <c>Object</c> type (always <c>container.deleted</c>), and a <c>Deleted</c> flag set to <c>True</c>
    /// to confirm successful removal.
    /// </para>
    /// <para>
    /// • The raw API JSON payload is preserved in the <c>JSONResponse</c> property inherited
    /// from <c>TJSONFingerprint</c>, allowing inspection or diagnostic tracing of the API response.
    /// </para>
    /// <para>
    /// • This method performs a blocking deletion and should be used in synchronous contexts.
    /// For non-blocking asynchronous deletion with promise-based or event-driven handling,
    /// use <c>AsyncAwaitDelete</c> or <c>AsynDelete</c>.
    /// </para>
    /// </remarks>
    function Delete(const ContainerId: string): TContainersDelete; override;
  end;

implementation

{ TContainerParams }

function TContainerParams.ExpiresAfter(
  const Value: TExpiresAfterParams): TContainerParams;
begin
  Result := TContainerParams(Add('expires_after', Value.Detach));
end;

function TContainerParams.FileIds(
  const Value: TArray<string>): TContainerParams;
begin
  Result := TContainerParams(Add('file_ids', Value));
end;

function TContainerParams.MemoryLimit(const Value: string): TContainerParams;
begin
  Result := TContainerParams(Add('memory_limit', Value));
end;

function TContainerParams.NetworkPolicy(
  const Value: TContainerNetworkPolicyParams): TContainerParams;
begin
  Result := TContainerParams(Add('network_policy', Value.Detach));
end;

function TContainerParams.Skills(const Value: TJSONArray): TContainerParams;
begin
  Result := TContainerParams(Add('skills', Value));
end;

function TContainerParams.Name(
  const Value: string): TContainerParams;
begin
  Result := TContainerParams(Add('name', Value));
end;

class function TContainerParams.New(
  const Name: string): TContainerParams;
begin
  Result := TContainerParams.New
    .Name(Name);
end;

class function TContainerParams.New: TContainerParams;
begin
  Result := TContainerParams.Create;
end;

{ TExpiresAfterParams }

function TExpiresAfterParams.Anchor(const Value: string): TExpiresAfterParams;
begin
  Result := TExpiresAfterParams(Add('anchor', Value));
end;

function TExpiresAfterParams.Minutes(const Value: Integer): TExpiresAfterParams;
begin
  Result := TExpiresAfterParams(Add('minutes', Value));
end;

class function TExpiresAfterParams.New(
  const Minutes: Integer): TExpiresAfterParams;
begin
  Result := TExpiresAfterParams.New
    .Anchor()
    .Minutes(Minutes);
end;

class function TExpiresAfterParams.New: TExpiresAfterParams;
begin
  Result := TExpiresAfterParams.Create;
end;

{ TContainerNetworkPolicyParams }

function TContainerNetworkPolicyParams.&Type(
  const Value: string): TContainerNetworkPolicyParams;
begin
  Result := TContainerNetworkPolicyParams(Add('type', Value));
end;

function TContainerNetworkPolicyParams.AllowedDomains(
  const Value: TArray<string>): TContainerNetworkPolicyParams;
begin
  Result := TContainerNetworkPolicyParams(Add('allowed_domains', Value));
end;

function TContainerNetworkPolicyParams.DomainSecrets(
  const Value: TJSONArray): TContainerNetworkPolicyParams;
begin
  Result := TContainerNetworkPolicyParams(Add('domain_secrets', Value));
end;

class function TContainerNetworkPolicyParams.New: TContainerNetworkPolicyParams;
begin
  Result := TContainerNetworkPolicyParams.Create;
end;

{ TContainer }

destructor TContainer.Destroy;
begin
  if Assigned(FExpiresAfter) then
    FExpiresAfter.Free;
  if Assigned(FNetworkPolicy) then
    FNetworkPolicy.Free;
  inherited;
end;

{ TContainersRoute }

function TContainersRoute.AsyncAwaitCreate(
  const ParamProc: TProc<TContainerParams>;
  const CallBacks: TFunc<TPromiseContainer>): TPromise<TContainer>;
begin
  Result := TAsyncAwaitHelper.WrapAsyncAwait<TContainer>(
    procedure(const CallBackParams: TFunc<TAsynContainer>)
    begin
      Self.AsynCreate(ParamProc, CallBackParams);
    end,
    CallBacks);
end;

function TContainersRoute.AsyncAwaitDelete(const ContainerId: string;
  const CallBacks: TFunc<TPromiseContainersDelete>): TPromise<TContainersDelete>;
begin
  Result := TAsyncAwaitHelper.WrapAsyncAwait<TContainersDelete>(
    procedure(const CallBackParams: TFunc<TAsynContainersDelete>)
    begin
      Self.AsynDelete(ContainerId, CallBackParams);
    end,
    CallBacks);
end;

function TContainersRoute.AsyncAwaitList(
  const ParamProc: TProc<TUrlContainerParams>;
  const CallBacks: TFunc<TPromiseContainerList>): TPromise<TContainerList>;
begin
  Result := TAsyncAwaitHelper.WrapAsyncAwait<TContainerList>(
    procedure(const CallBackParams: TFunc<TAsynContainerList>)
    begin
      Self.AsynList(ParamProc, CallBackParams);
    end,
    CallBacks);
end;

function TContainersRoute.AsyncAwaitRetrieve(const ContainerId: string;
  const CallBacks: TFunc<TPromiseContainer>): TPromise<TContainer>;
begin
  Result := TAsyncAwaitHelper.WrapAsyncAwait<TContainer>(
    procedure(const CallBackParams: TFunc<TAsynContainer>)
    begin
      Self.AsynRetrieve(ContainerId, CallBackParams);
    end,
    CallBacks);
end;

{ TContainersAsynchronousSupport }

procedure TContainersAsynchronousSupport.AsynCreate(const ParamProc: TProc<TContainerParams>;
  const CallBacks: TFunc<TAsynContainer>);
begin
  with TAsynCallBackExec<TAsynContainer, TContainer>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TContainer
      begin
        Result := Self.Create(ParamProc);
      end);
  finally
    Free;
  end;
end;

procedure TContainersAsynchronousSupport.AsynDelete(const ContainerId: string;
  const CallBacks: TFunc<TAsynContainersDelete>);
begin
  with TAsynCallBackExec<TAsynContainersDelete, TContainersDelete>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TContainersDelete
      begin
        Result := Self.Delete(ContainerId);
      end);
  finally
    Free;
  end;
end;

procedure TContainersAsynchronousSupport.AsynList(const ParamProc: TProc<TUrlContainerParams>;
  const CallBacks: TFunc<TAsynContainerList>);
begin
  with TAsynCallBackExec<TAsynContainerList, TContainerList>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TContainerList
      begin
        Result := Self.List(ParamProc);
      end);
  finally
    Free;
  end;
end;

procedure TContainersAsynchronousSupport.AsynRetrieve(const ContainerId: string;
  const CallBacks: TFunc<TAsynContainer>);
begin
  with TAsynCallBackExec<TAsynContainer, TContainer>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TContainer
      begin
        Result := Self.Retrieve(ContainerId);
      end);
  finally
    Free;
  end;
end;

function TContainersRoute.Create(
  const ParamProc: TProc<TContainerParams>): TContainer;
begin
  Result := API.Post<TContainer, TContainerParams>('containers', ParamProc);
end;

function TContainersRoute.Delete(const ContainerId: string): TContainersDelete;
begin
  Result := API.Delete<TContainersDelete>('containers/' + ContainerId);
end;

function TContainersRoute.List(
  const ParamProc: TProc<TUrlContainerParams>): TContainerList;
begin
  Result := API.Get<TContainerList, TUrlContainerParams>('containers', ParamProc);
end;

function TContainersRoute.Retrieve(const ContainerId: string): TContainer;
begin
  Result := API.Get<TContainer>('containers/' + ContainerId);
end;

{ TUrlContainerParams }

function TUrlContainerParams.After(const Value: string): TUrlContainerParams;
begin
  Result := TUrlContainerParams(Add('after', Value));
end;

function TUrlContainerParams.limit(const Value: Integer): TUrlContainerParams;
begin
  Result := TUrlContainerParams(Add('limit', Value));
end;

function TUrlContainerParams.Order(const Value: string): TUrlContainerParams;
begin
  Result := TUrlContainerParams(Add('order', Value));
end;

{ TContainerList }

destructor TContainerList.Destroy;
begin
  for var Item in FData do
    Item.Free;
  inherited;
end;

end.
