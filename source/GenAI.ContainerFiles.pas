unit GenAI.ContainerFiles;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGenAI
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.SysUtils, System.Classes, System.JSON, System.Net.Mime,
  REST.Json.Types, REST.JsonReflect,
  GenAI.API.Params, GenAI.API, GenAI.Types, GenAI.Async.Params, GenAI.Async.Support,
  GenAI.Async.Promise, GenAI.TextCodec;

type
  TContainerFilesParams = class(TMultipartFormData)
    constructor Create; reintroduce;

    /// <summary>
    /// The File object (not file name) to be uploaded.
    /// </summary>
    function &File(const Value: string): TContainerFilesParams;

    /// <summary>
    /// Name of the file to create.
    /// </summary>
    function FileId(const Value: string): TContainerFilesParams;
  end;

  TUrlContainerFileParams = class(TUrlParam)
    /// <summary>
    /// A cursor for use in pagination. after is an object ID that defines your place in the list.
    /// For instance, if you make a list request and receive 100 objects, ending with obj_foo, your
    /// subsequent call can include after=obj_foo in order to fetch the next page of the list.
    /// </summary>
    function After(const Value: string): TUrlContainerFileParams;

    /// <summary>
    /// A limit on the number of objects to be returned. Limit can range between 1 and 100, and the
    /// default is 20.
    /// </summary>
    function Limit(const Value: Integer): TUrlContainerFileParams;

    /// <summary>
    /// Sort order by the created_at timestamp of the objects. asc for ascending order and desc for descending order.
    /// </summary>
    function Order(const Value: string = 'desc'): TUrlContainerFileParams;
  end;

  TContainerFile = class(TJSONFingerprint)
  private
    FBytes         : Int64;
    [JsonNameAttribute('container_id')]
    FContainerId   : string;
    [JsonNameAttribute('created_at')]
    FCreatedAt     : Int64;
    FId            : string;
    FObject        : string;
    FPath          : string;
    FSource        : string;
  public
    /// <summary>
    /// Size of the file in bytes.
    /// </summary>
    property Bytes: Int64 read FBytes write FBytes;

    /// <summary>
    /// The container this file belongs to.
    /// </summary>
    property ContainerId: string read FContainerId write FContainerId;

    /// <summary>
    /// Unix timestamp (in seconds) when the file was created.
    /// </summary>
    property CreatedAt: Int64 read FCreatedAt write FCreatedAt;

    /// <summary>
    /// Unique identifier for the file.
    /// </summary>
    property Id: string read FId write FId;

    /// <summary>
    /// The type of this object (container.file).
    /// </summary>
    property &Object: string read FObject write FObject;

    /// <summary>
    /// Path of the file in the container.
    /// </summary>
    property Path: string read FPath write FPath;

    /// <summary>
    /// Source of the file (e.g., user, assistant).
    /// </summary>
    property Source: string read FSource write FSource;
  end;

  TContainerFileList = class(TJSONFingerprint)
  private
    FData: TArray<TContainerFile>;
    FObject: string;
    [JsonNameAttribute('first_id')]
    FFirstId: string;
    [JsonNameAttribute('last_id')]
    FLastId: string;
    [JsonNameAttribute('has_more')]
    FHasMore: Boolean;
  public
    property Data: TArray<TContainerFile> read FData write FData;
    property &Object: string read FObject write FObject;
    property FirstId: string read FFirstId write FFirstId;
    property LastId: string read FLastId write FLastId;
    property HasMore: Boolean read FHasMore write FHasMore;
    destructor Destroy; override;
  end;

  TContainerFilesDelete = class(TJSONFingerprint)
  private
    FId      : string;
    FObject  : string;
    FDeleted : Boolean;
  public
    /// <summary>
    /// The ID of the container file to delete.
    /// </summary>
    property Id: string read FId write FId;

    /// <summary>
    /// Allways container.file.deleted
    /// </summary>
    property &Object: string read FObject write FObject;

    /// <summary>
    /// True if the container file has been deleted
    /// </summary>
    property Deleted: Boolean read FDeleted write FDeleted;
  end;

  TContainerFileContent = class
  private
    FData: string;
  public
    property Data: string read FData write FData;
    function AsString: string;
  end;

  /// <summary>
  /// Asynchronous callback wrapper for operations that return a <c>TContainerFile</c> result.
  /// </summary>
  /// <remarks>
  /// <para>
  /// Alias of <c>TAsynCallBack&lt;TContainerFile&gt;</c>. Exposes the framework’s event-driven async
  /// lifecycle for container file operations such as upload/create and retrieve, with dispatcher-safe notifications.
  /// </para>
  /// <para>
  /// Typical handlers include <c>OnStart</c> (invoked when the request begins), <c>OnSuccess</c>
  /// (delivering the resolved <c>TContainerFile</c>), and <c>OnError</c> (propagating failures).
  /// </para>
  /// <para>
  /// Use this alias with route methods like <c>TContainerFilesRoute.AsynCreate</c> and
  /// <c>TContainerFilesRoute.AsynRetrieve</c>. For list operations, prefer <c>TAsynContainerFileList</c>;
  /// for deletions, prefer <c>TAsynContainerFilesDelete</c>; and for content reads, prefer
  /// <c>TAsynContainerFileContent</c>.
  /// </para>
  /// <para>
  /// The resulting <c>TContainerFile</c> inherits <c>TJSONFingerprint</c> and surfaces fields including
  /// <c>Id</c>, <c>Object</c> (always <c>container.file</c>), <c>CreatedAt</c>, <c>Bytes</c>,
  /// <c>ContainerId</c>, <c>Path</c>, and <c>Source</c>, along with the raw API payload accessible through
  /// the <c>JSONResponse</c> property.
  /// </para>
  /// </remarks>
  TAsynContainerFile = TAsynCallBack<TContainerFile>;

  /// <summary>
  /// Promise-style asynchronous wrapper for operations that return a <c>TContainerFile</c> result.
  /// </summary>
  /// <remarks>
  /// <para>
  /// Alias of <c>TPromiseCallBack&lt;TContainerFile&gt;</c>. Provides a promise-based asynchronous workflow
  /// for container file operations such as upload/create, retrieve, or content access, allowing structured chaining,
  /// continuation, and centralized error handling in non-blocking execution flows.
  /// </para>
  /// <para>
  /// Standard promise handlers include <c>OnStart</c> (triggered when the request begins),
  /// <c>OnSuccess</c> (resolve, invoked with the completed <c>TContainerFile</c>), and
  /// <c>OnError</c> (reject, invoked in case of failure or connection error).
  /// </para>
  /// <para>
  /// Use this alias with await-style methods such as <c>TContainerFilesRoute.AsyncAwaitCreate</c>
  /// or <c>TContainerFilesRoute.AsyncAwaitRetrieve</c> to make the intent explicit while preserving
  /// strong typing of the promised payload.
  /// </para>
  /// <para>
  /// The resolved <c>TContainerFile</c> inherits <c>TJSONFingerprint</c> and provides fields such as
  /// <c>Id</c>, <c>Object</c> (always <c>container.file</c>), <c>CreatedAt</c>, <c>Bytes</c>,
  /// <c>ContainerId</c>, <c>Path</c>, and <c>Source</c>, with the complete API payload accessible through
  /// the <c>JSONResponse</c> property.
  /// </para>
  /// </remarks>
  TPromiseContainerFile = TPromiseCallBack<TContainerFile>;

  /// <summary>
  /// Asynchronous callback wrapper for operations that return a <c>TContainerFileList</c> result.
  /// </summary>
  /// <remarks>
  /// <para>
  /// Alias of <c>TAsynCallBack&lt;TContainerFileList&gt;</c>. Exposes the framework’s event-driven asynchronous
  /// lifecycle for list operations on container files (e.g., enumeration, pagination, or workspace inspection),
  /// enabling non-blocking execution with dispatcher-safe notifications.
  /// </para>
  /// <para>
  /// Typical handlers include <c>OnStart</c> (invoked when the listing request begins),
  /// <c>OnSuccess</c> (delivering the resolved <c>TContainerFileList</c> payload), and
  /// <c>OnError</c> (triggered on failure or network error).
  /// </para>
  /// <para>
  /// Use this alias with asynchronous methods such as <c>TContainerFilesRoute.AsynList</c> to make the
  /// intent explicit and preserve strong typing of the callback payload.
  /// </para>
  /// <para>
  /// The resulting <c>TContainerFileList</c> inherits <c>TJSONFingerprint</c> and provides pagination
  /// metadata (<c>FirstId</c>, <c>LastId</c>, <c>HasMore</c>) along with a strongly typed collection of
  /// <c>TContainerFile</c> instances accessible through the <c>Data</c> property.
  /// </para>
  /// </remarks>
  TAsynContainerFileList = TAsynCallBack<TContainerFileList>;

  /// <summary>
  /// Promise-style asynchronous wrapper for operations that return a <c>TContainerFileList</c> result.
  /// </summary>
  /// <remarks>
  /// <para>
  /// Alias of <c>TPromiseCallBack&lt;TContainerFileList&gt;</c>. Provides a promise-based asynchronous workflow
  /// for container file list operations (such as enumeration, pagination, or bulk retrieval), enabling structured
  /// chaining, continuation, and centralized error handling in non-blocking execution flows.
  /// </para>
  /// <para>
  /// Standard promise handlers include <c>OnStart</c> (triggered when the request begins),
  /// <c>OnSuccess</c> (resolve, invoked with the completed <c>TContainerFileList</c>), and
  /// <c>OnError</c> (reject, invoked in case of network or server failure).
  /// </para>
  /// <para>
  /// Use this alias with await-style methods such as <c>TContainerFilesRoute.AsyncAwaitList</c> to make the
  /// intent explicit while maintaining strong typing of the promised payload.
  /// </para>
  /// <para>
  /// The resolved <c>TContainerFileList</c> inherits <c>TJSONFingerprint</c> and includes pagination markers
  /// (<c>FirstId</c>, <c>LastId</c>, <c>HasMore</c>) along with a strongly typed array of <c>TContainerFile</c>
  /// instances accessible through the <c>Data</c> property.
  /// </para>
  /// </remarks>
  TPromiseContainerFileList = TPromiseCallBack<TContainerFileList>;

  /// <summary>
  /// Asynchronous callback wrapper for operations that return a <c>TContainerFilesDelete</c> result.
  /// </summary>
  /// <remarks>
  /// <para>
  /// Alias of <c>TAsynCallBack&lt;TContainerFilesDelete&gt;</c>. Exposes the framework’s event-driven asynchronous
  /// lifecycle for container file deletion operations, allowing non-blocking execution with dispatcher-safe and
  /// UI-friendly notifications.
  /// </para>
  /// <para>
  /// Typical handlers include <c>OnStart</c> (invoked when the deletion request begins),
  /// <c>OnSuccess</c> (delivering the resolved <c>TContainerFilesDelete</c> payload), and
  /// <c>OnError</c> (triggered on failure or network error).
  /// </para>
  /// <para>
  /// Use this alias with asynchronous methods such as <c>TContainerFilesRoute.AsynDelete</c> to make the intent
  /// explicit and preserve strong typing of the callback payload.
  /// </para>
  /// <para>
  /// The resulting <c>TContainerFilesDelete</c> inherits <c>TJSONFingerprint</c> and provides information about
  /// the deleted container file, including its <c>Id</c>, <c>Object</c> type (always <c>container.file.deleted</c>),
  /// and the <c>Deleted</c> flag confirming the deletion.
  /// </para>
  /// </remarks>
  TAsynContainerFilesDelete = TAsynCallBack<TContainerFilesDelete>;

  /// <summary>
  /// Promise-style asynchronous wrapper for operations that return a <c>TContainerFilesDelete</c> result.
  /// </summary>
  /// <remarks>
  /// <para>
  /// Alias of <c>TPromiseCallBack&lt;TContainerFilesDelete&gt;</c>. Provides a promise-based asynchronous workflow
  /// for container file deletion operations, enabling structured chaining, continuation, and centralized error
  /// handling in non-blocking execution flows.
  /// </para>
  /// <para>
  /// Standard promise handlers include <c>OnStart</c> (triggered when the deletion request begins),
  /// <c>OnSuccess</c> (resolve, invoked with the completed <c>TContainerFilesDelete</c>), and
  /// <c>OnError</c> (reject, invoked in case of failure or connection error).
  /// </para>
  /// <para>
  /// Use this alias with await-style methods such as <c>TContainerFilesRoute.AsyncAwaitDelete</c> to make the
  /// intent explicit while preserving strong typing of the promised payload.
  /// </para>
  /// <para>
  /// The resolved <c>TContainerFilesDelete</c> inherits <c>TJSONFingerprint</c> and provides details about
  /// the deleted container file, including its <c>Id</c>, <c>Object</c> type (always <c>container.file.deleted</c>),
  /// and the <c>Deleted</c> flag indicating successful deletion.
  /// </para>
  /// </remarks>
  TPromiseContainerFilesDelete = TPromiseCallBack<TContainerFilesDelete>;

  /// <summary>
  /// Asynchronous callback wrapper for operations that return a <c>TContainerFileContent</c> result.
  /// </summary>
  /// <remarks>
  /// <para>
  /// Alias of <c>TAsynCallBack&lt;TContainerFileContent&gt;</c>. Exposes the framework’s event-driven asynchronous
  /// lifecycle for container file content retrieval operations, enabling non-blocking data streaming and
  /// dispatcher-safe notifications.
  /// </para>
  /// <para>
  /// Typical handlers include <c>OnStart</c> (invoked when the content retrieval begins),
  /// <c>OnSuccess</c> (delivering the resolved <c>TContainerFileContent</c> payload), and
  /// <c>OnError</c> (triggered on failure, timeout, or network error).
  /// </para>
  /// <para>
  /// Use this alias with asynchronous methods such as <c>TContainerFilesRoute.AsynGetContent</c> to make the
  /// intent explicit and preserve strong typing of the callback payload.
  /// </para>
  /// <para>
  /// The resulting <c>TContainerFileContent</c> provides access to the file’s binary data encoded as Base64,
  /// available via the <c>Data</c> property, and includes helper methods such as <c>AsString</c> to obtain
  /// a decoded text representation of the file content.
  /// </para>
  /// </remarks>
  TAsynContainerFileContent = TAsynCallBack<TContainerFileContent>;

  /// <summary>
  /// Promise-style asynchronous wrapper for operations that return a <c>TContainerFileContent</c> result.
  /// </summary>
  /// <remarks>
  /// <para>
  /// Alias of <c>TPromiseCallBack&lt;TContainerFileContent&gt;</c>. Provides a promise-based asynchronous workflow
  /// for container file content retrieval operations, enabling structured chaining, continuation, and centralized
  /// error handling in non-blocking execution flows.
  /// </para>
  /// <para>
  /// Standard promise handlers include <c>OnStart</c> (triggered when the content retrieval begins),
  /// <c>OnSuccess</c> (resolve, invoked with the completed <c>TContainerFileContent</c>), and
  /// <c>OnError</c> (reject, invoked in case of network or decoding errors).
  /// </para>
  /// <para>
  /// Use this alias with await-style methods such as <c>TContainerFilesRoute.AsyncAwaitGetContent</c> to make the
  /// intent explicit while preserving strong typing of the promised payload.
  /// </para>
  /// <para>
  /// The resolved <c>TContainerFileContent</c> provides access to the retrieved file’s binary data encoded in Base64
  /// through the <c>Data</c> property and includes helper methods like <c>AsString</c> for convenient decoding to text.
  /// </para>
  /// </remarks>
  TPromiseContainerFileContent = TPromiseCallBack<TContainerFileContent>;

  TContainerFilesRoute = class(TGenAIRoute)
    /// <summary>
    /// Asynchronously uploads/creates a file in the specified container and returns a <c>TPromise&lt;TContainerFile&gt;</c> handle.
    /// </summary>
    /// <param name="ContainerId">
    /// The identifier of the container that will receive the file.
    /// </param>
    /// <param name="ParamProc">
    /// A configuration procedure that builds the multipart/form-data body via <c>TContainerFilesParams</c>.
    /// Use <c>.File(...)</c> to attach the raw file content, or <c>.FileId(...)</c> to reference an existing File object.
    /// </param>
    /// <param name="CallBacks">
    /// (Optional) A factory that returns a <c>TPromiseContainerFile</c> instance, allowing you to attach
    /// promise lifecycle handlers (<c>OnStart</c>, <c>OnSuccess</c>, <c>OnError</c>).
    /// </param>
    /// <returns>
    /// A <c>TPromise&lt;TContainerFile&gt;</c> that resolves with the created container-file descriptor once the upload completes.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • Performs a non-blocking <c>POST</c> to <c>/containers/{container_id}/files</c>, sending either a binary file part
    /// (via <c>.File</c>) or a referenced file id (via <c>.FileId</c>).
    /// </para>
    /// <para>
    /// • Internally wraps <c>TContainerFilesRoute.AsynCreate</c> with <c>TAsyncAwaitHelper.WrapAsyncAwait</c>,
    /// exposing a promise-based interface while preserving strong typing of the result.
    /// </para>
    /// <para>
    /// • The resolved <c>TContainerFile</c> includes fields such as <c>Id</c>, <c>Bytes</c>, <c>Path</c>, <c>CreatedAt</c>,
    /// <c>ContainerId</c>, and <c>Source</c>. The raw API payload is available via <c>TJSONFingerprint.JSONResponse</c>.
    /// </para>
    /// <para>
    /// • Use this method for non-blocking uploads with structured continuation and centralized error handling.
    /// For an event-driven alternative, use <c>AsynCreate</c>.
    /// </para>
    /// </remarks>
    function AsyncAwaitCreate(const ContainerId: string;
      const ParamProc: TProc<TContainerFilesParams>;
      const CallBacks: TFunc<TPromiseContainerFile> = nil): TPromise<TContainerFile>;

    /// <summary>
    /// Asynchronously lists files within the specified container and returns a <c>TPromise&lt;TContainerFileList&gt;</c> handle.
    /// </summary>
    /// <param name="ContainerId">
    /// The identifier of the container whose files should be listed.
    /// </param>
    /// <param name="ParamProc">
    /// A configuration procedure that builds the query string via <c>TUrlContainerFileParams</c>.
    /// Use <c>.After(...)</c> for cursor-based pagination, <c>.limit(...)</c> (1–100) to bound page size,
    /// and <c>.Order('asc'|'desc')</c> to sort by <c>created_at</c>.
    /// </param>
    /// <param name="CallBacks">
    /// (Optional) A factory that returns a <c>TPromiseContainerFileList</c> instance, allowing you to attach
    /// promise lifecycle handlers (<c>OnStart</c>, <c>OnSuccess</c>, <c>OnError</c>).
    /// </param>
    /// <returns>
    /// A <c>TPromise&lt;TContainerFileList&gt;</c> that resolves with the retrieved listing once the request completes.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • Performs a non-blocking <c>GET</c> to <c>/containers/{container_id}/files</c> using the provided pagination/sort parameters.
    /// </para>
    /// <para>
    /// • Internally wraps <c>TContainerFilesRoute.AsynList</c> with <c>TAsyncAwaitHelper.WrapAsyncAwait</c>,
    /// exposing a promise-based interface while preserving strong typing of the result.
    /// </para>
    /// <para>
    /// • The resolved <c>TContainerFileList</c> includes pagination metadata (<c>FirstId</c>, <c>LastId</c>, <c>HasMore</c>)
    /// and a typed array of <c>TContainerFile</c> entries in <c>Data</c>. The raw API payload is available via
    /// <c>TJSONFingerprint.JSONResponse</c>.
    /// </para>
    /// <para>
    /// • Use this method to enumerate container files without blocking the main thread. For an event-driven alternative,
    /// use <c>AsynList</c>.
    /// </para>
    /// </remarks>
    function AsyncAwaitList(const ContainerId: string;
      const ParamProc: TProc<TUrlContainerFileParams>;
      const CallBacks: TFunc<TPromiseContainerFileList> = nil): TPromise<TContainerFileList>;

    /// <summary>
    /// Asynchronously retrieves metadata for a specific container file and returns a <c>TPromise&lt;TContainerFile&gt;</c> handle.
    /// </summary>
    /// <param name="ContainerId">
    /// The identifier of the container that owns the file.
    /// </param>
    /// <param name="FileId">
    /// The identifier of the file to retrieve.
    /// </param>
    /// <param name="CallBacks">
    /// (Optional) A factory that returns a <c>TPromiseContainerFile</c> instance, allowing you to attach
    /// promise lifecycle handlers (<c>OnStart</c>, <c>OnSuccess</c>, <c>OnError</c>).
    /// </param>
    /// <returns>
    /// A <c>TPromise&lt;TContainerFile&gt;</c> that resolves with the file descriptor once the request completes.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • Performs a non-blocking <c>GET</c> to <c>/containers/{container_id}/files/{file_id}</c>, returning
    /// metadata only (not the binary content). To fetch the file bytes, use <c>AsyncAwaitGetContent</c>.
    /// </para>
    /// <para>
    /// • Internally wraps <c>TContainerFilesRoute.AsynRetrieve</c> with <c>TAsyncAwaitHelper.WrapAsyncAwait</c>,
    /// exposing a promise-based interface while preserving strong typing of the result.
    /// </para>
    /// <para>
    /// • The resolved <c>TContainerFile</c> includes fields such as <c>Id</c>, <c>Bytes</c>, <c>Path</c>,
    /// <c>CreatedAt</c>, <c>ContainerId</c>, <c>Source</c>, and <c>Object</c> (always <c>container.file</c>).
    /// The raw API payload is available via <c>TJSONFingerprint.JSONResponse</c>.
    /// </para>
    /// <para>
    /// • Use this method for non-blocking retrieval with structured continuation and centralized error handling.
    /// For an event-driven alternative, use <c>AsynRetrieve</c>.
    /// </para>
    /// </remarks>
    function AsyncAwaitRetrieve(const ContainerId: string;
      const FileId: string;
      const CallBacks: TFunc<TPromiseContainerFile> = nil): TPromise<TContainerFile>;

    /// <summary>
    /// Asynchronously retrieves the binary content of a specific file within a container and returns a <c>TPromise&lt;TContainerFileContent&gt;</c> handle.
    /// </summary>
    /// <param name="ContainerId">
    /// The identifier of the container that owns the file.
    /// </param>
    /// <param name="FileId">
    /// The identifier of the file whose content should be retrieved.
    /// </param>
    /// <param name="CallBacks">
    /// (Optional) A factory that returns a <c>TPromiseContainerFileContent</c> instance, allowing you to attach
    /// promise lifecycle handlers (<c>OnStart</c>, <c>OnSuccess</c>, <c>OnError</c>).
    /// </param>
    /// <returns>
    /// A <c>TPromise&lt;TContainerFileContent&gt;</c> that resolves with the Base64-encoded file content once the request completes.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • Performs a non-blocking <c>GET</c> request to <c>/containers/{container_id}/files/{file_id}/content</c>,
    /// downloading the binary data of the file stored in the specified container.
    /// </para>
    /// <para>
    /// • Internally wraps <c>TContainerFilesRoute.AsynGetContent</c> with <c>TAsyncAwaitHelper.WrapAsyncAwait</c>,
    /// providing a promise-based interface while preserving strong typing of the result.
    /// </para>
    /// <para>
    /// • The resolved <c>TContainerFileContent</c> exposes the Base64-encoded data through the <c>Data</c> property.
    /// Use <c>AsString</c> to decode text-based content directly into a UTF-8 string.
    /// </para>
    /// <para>
    /// • This method is ideal for non-blocking file downloads with structured continuation and centralized error handling.
    /// For an event-driven alternative, use <c>AsynGetContent</c>.
    /// </para>
    /// </remarks>
    function AsyncAwaitGetContent(const ContainerId: string;
      const FileId: string;
      const CallBacks: TFunc<TPromiseContainerFileContent> = nil): TPromise<TContainerFileContent>;

    /// <summary>
    /// Asynchronously deletes a specific file from a container and returns a <c>TPromise&lt;TContainerFilesDelete&gt;</c> handle.
    /// </summary>
    /// <param name="ContainerId">
    /// The identifier of the container that owns the file.
    /// </param>
    /// <param name="FileId">
    /// The identifier of the file to delete from the container.
    /// </param>
    /// <param name="CallBacks">
    /// (Optional) A factory that returns a <c>TPromiseContainerFilesDelete</c> instance, allowing you to attach
    /// promise lifecycle handlers (<c>OnStart</c>, <c>OnSuccess</c>, <c>OnError</c>).
    /// </param>
    /// <returns>
    /// A <c>TPromise&lt;TContainerFilesDelete&gt;</c> that resolves once the deletion request completes successfully.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • Performs a non-blocking <c>DELETE</c> request to <c>/containers/{container_id}/files/{file_id}</c>,
    /// permanently removing the specified file from the container.
    /// </para>
    /// <para>
    /// • Internally wraps <c>TContainerFilesRoute.AsynDelete</c> with <c>TAsyncAwaitHelper.WrapAsyncAwait</c>,
    /// exposing a promise-based interface while preserving strong typing of the result.
    /// </para>
    /// <para>
    /// • The resolved <c>TContainerFilesDelete</c> includes fields such as <c>Id</c>,
    /// <c>Object</c> (always <c>container.file.deleted</c>), and <c>Deleted</c> (set to <c>True</c> on success).
    /// The raw API payload is accessible via <c>TJSONFingerprint.JSONResponse</c>.
    /// </para>
    /// <para>
    /// • Use this method for non-blocking, asynchronous deletion of files with structured continuation
    /// and centralized error handling. For an event-driven alternative, use <c>AsynDelete</c>.
    /// </para>
    /// </remarks>
    function AsyncAwaitDelete(const ContainerId: string;
      const FileId: string;
      const CallBacks: TFunc<TPromiseContainerFilesDelete> = nil): TPromise<TContainerFilesDelete>;

    /// <summary>
    /// Uploads or creates a new file within the specified container and returns a <c>TContainerFile</c> descriptor.
    /// </summary>
    /// <param name="ContainerId">
    /// The identifier of the container in which the file will be created or uploaded.
    /// </param>
    /// <param name="ParamProc">
    /// A configuration procedure that builds the multipart/form-data request body through <c>TContainerFilesParams</c>.
    /// Use <c>.File(...)</c> to attach a local file for upload, or <c>.FileId(...)</c> to reference an existing file ID.
    /// </param>
    /// <returns>
    /// A <c>TContainerFile</c> object containing metadata and path information for the newly created file.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • Executes a synchronous <c>POST</c> request to the <c>/containers/{container_id}/files</c> endpoint.
    /// The <paramref name="ParamProc"/> callback defines the form data using a fluent <c>TContainerFilesParams</c> builder.
    /// </para>
    /// <para>
    /// • The returned <c>TContainerFile</c> includes metadata such as <c>Id</c>, <c>ContainerId</c>,
    /// <c>Bytes</c>, <c>Path</c>, <c>CreatedAt</c>, and <c>Source</c> (e.g., user or assistant).
    /// </para>
    /// <para>
    /// • The raw JSON payload from the API is stored in the <c>JSONResponse</c> property inherited
    /// from <c>TJSONFingerprint</c>, providing direct access to the underlying response structure.
    /// </para>
    /// <para>
    /// • This method is synchronous and blocks until the file upload or creation completes.
    /// For a non-blocking, asynchronous alternative, use <c>AsyncAwaitCreate</c> or <c>AsynCreate</c>.
    /// </para>
    /// </remarks>
    function Create(const ContainerId: string; const ParamProc: TProc<TContainerFilesParams>): TContainerFile;

    /// <summary>
    /// Retrieves a paginated list of files from the specified container and returns a <c>TContainerFileList</c> object.
    /// </summary>
    /// <param name="ContainerId">
    /// The identifier of the container whose files should be listed.
    /// </param>
    /// <param name="ParamProc">
    /// A configuration procedure that builds the query string through <c>TUrlContainerFileParams</c>.
    /// Use <c>.After(...)</c> for cursor-based pagination, <c>.limit(...)</c> (1–100) to control page size,
    /// and <c>.Order('asc'|'desc')</c> to sort by creation date.
    /// </param>
    /// <returns>
    /// A <c>TContainerFileList</c> object containing file metadata, pagination information, and a collection of <c>TContainerFile</c> entries.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • Executes a synchronous <c>GET</c> request to the <c>/containers/{container_id}/files</c> endpoint.
    /// The <paramref name="ParamProc"/> callback defines pagination and sorting options through a fluent
    /// <c>TUrlContainerFileParams</c> builder.
    /// </para>
    /// <para>
    /// • The returned <c>TContainerFileList</c> provides pagination metadata such as <c>FirstId</c>,
    /// <c>LastId</c>, and <c>HasMore</c>, along with an array of <c>TContainerFile</c> instances accessible
    /// through the <c>Data</c> property.
    /// </para>
    /// <para>
    /// • Each <c>TContainerFile</c> entry includes details such as <c>Id</c>, <c>ContainerId</c>,
    /// <c>Bytes</c>, <c>Path</c>, <c>Source</c>, and <c>CreatedAt</c>.
    /// </para>
    /// <para>
    /// • The raw API JSON payload is available via the <c>JSONResponse</c> property inherited from
    /// <c>TJSONFingerprint</c>, allowing low-level access for debugging or inspection.
    /// </para>
    /// <para>
    /// • This method performs a blocking request and should be used when synchronous listing is acceptable.
    /// For asynchronous or non-blocking file enumeration, use <c>AsyncAwaitList</c> or <c>AsynList</c>.
    /// </para>
    /// </remarks>
    function List(const ContainerId: string; const ParamProc: TProc<TUrlContainerFileParams>): TContainerFileList;

    /// <summary>
    /// Retrieves metadata for a specific file within a container and returns a <c>TContainerFile</c> descriptor.
    /// </summary>
    /// <param name="ContainerId">
    /// The identifier of the container that owns the file.
    /// </param>
    /// <param name="FileId">
    /// The unique identifier of the file to retrieve.
    /// </param>
    /// <returns>
    /// A <c>TContainerFile</c> object containing detailed metadata for the specified file.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • Executes a synchronous <c>GET</c> request to the <c>/containers/{container_id}/files/{file_id}</c> endpoint,
    /// returning metadata about the file but not its binary content.
    /// To download the file data itself, use <c>GetContent</c>.
    /// </para>
    /// <para>
    /// • The returned <c>TContainerFile</c> includes fields such as <c>Id</c>, <c>ContainerId</c>, <c>Bytes</c>,
    /// <c>Path</c>, <c>Source</c>, <c>Object</c> (always <c>container.file</c>), and <c>CreatedAt</c>.
    /// </para>
    /// <para>
    /// • The raw API JSON payload is preserved in the <c>JSONResponse</c> property inherited from
    /// <c>TJSONFingerprint</c>, allowing direct inspection or diagnostic tracing.
    /// </para>
    /// <para>
    /// • This method performs the operation synchronously and blocks until the metadata retrieval is complete.
    /// For asynchronous or non-blocking file retrieval, use <c>AsyncAwaitRetrieve</c> or <c>AsynRetrieve</c>.
    /// </para>
    /// </remarks>
    function Retrieve(const ContainerId: string; const FileId: string): TContainerFile;

    /// <summary>
    /// Retrieves the binary content of a specific file within a container and returns a <c>TContainerFileContent</c> object.
    /// </summary>
    /// <param name="ContainerId">
    /// The identifier of the container that owns the file.
    /// </param>
    /// <param name="FileId">
    /// The unique identifier of the file whose content should be retrieved.
    /// </param>
    /// <returns>
    /// A <c>TContainerFileContent</c> object containing the Base64-encoded binary data of the requested file.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • Executes a synchronous <c>GET</c> request to the <c>/containers/{container_id}/files/{file_id}/content</c> endpoint,
    /// downloading the full binary payload of the file stored in the specified container.
    /// </para>
    /// <para>
    /// • The returned <c>TContainerFileContent</c> exposes the Base64-encoded data via the <c>Data</c> property
    /// and provides the <c>AsString</c> helper method to decode UTF-8 text files directly into a string representation.
    /// </para>
    /// <para>
    /// • This method performs a blocking operation that retrieves the complete file content before returning.
    /// Use <c>AsyncAwaitGetContent</c> or <c>AsynGetContent</c> for a non-blocking asynchronous alternative.
    /// </para>
    /// <para>
    /// • In case of network or decoding errors, an exception is raised and the partially created result is released.
    /// </para>
    /// </remarks>
    function GetContent(const ContainerId: string; const FileId: string): TContainerFileContent;

    /// <summary>
    /// Deletes a specific file from a container and returns a <c>TContainerFilesDelete</c> object describing the result.
    /// </summary>
    /// <param name="ContainerId">
    /// The identifier of the container that owns the file.
    /// </param>
    /// <param name="FileId">
    /// The unique identifier of the file to delete from the container.
    /// </param>
    /// <returns>
    /// A <c>TContainerFilesDelete</c> object confirming the deletion status of the specified file.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • Executes a synchronous <c>DELETE</c> request to the <c>/containers/{container_id}/files/{file_id}</c> endpoint,
    /// permanently removing the file from the specified container.
    /// </para>
    /// <para>
    /// • The returned <c>TContainerFilesDelete</c> includes fields such as <c>Id</c>, <c>Object</c>
    /// (always <c>container.file.deleted</c>), and <c>Deleted</c> (set to <c>True</c> upon successful deletion).
    /// </para>
    /// <para>
    /// • The raw API JSON payload is preserved in the <c>JSONResponse</c> property inherited from
    /// <c>TJSONFingerprint</c>, providing access to the original response for diagnostics or logging.
    /// </para>
    /// <para>
    /// • This method performs a blocking delete operation and should be used in synchronous contexts only.
    /// For non-blocking or event-driven deletion, use <c>AsyncAwaitDelete</c> or <c>AsynDelete</c>.
    /// </para>
    /// </remarks>
    function Delete(const ContainerId: string; const FileId: string): TContainerFilesDelete;

    /// <summary>
    /// Asynchronously uploads or creates a new file within a container and triggers callback events during the operation lifecycle.
    /// </summary>
    /// <param name="ContainerId">
    /// The identifier of the container where the file will be created or uploaded.
    /// </param>
    /// <param name="ParamProc">
    /// A configuration procedure that builds the multipart/form-data body using <c>TContainerFilesParams</c>.
    /// Use <c>.File(...)</c> to attach a local file for upload, or <c>.FileId(...)</c> to reference an existing file by ID.
    /// </param>
    /// <param name="CallBacks">
    /// A factory function returning a configured <c>TAsynContainerFile</c> instance, allowing you to define
    /// asynchronous lifecycle event handlers such as <c>OnStart</c>, <c>OnSuccess</c>, and <c>OnError</c>.
    /// </param>
    /// <remarks>
    /// <para>
    /// • Executes an asynchronous <c>POST</c> request to the <c>/containers/{container_id}/files</c> endpoint.
    /// The <paramref name="ParamProc"/> builds the multipart form parameters, and the <paramref name="CallBacks"/> argument
    /// specifies the event handlers that respond to progress and completion states.
    /// </para>
    /// <para>
    /// • The <c>OnStart</c> event fires when the upload process begins.
    /// The <c>OnSuccess</c> event is triggered upon successful completion and delivers a resolved <c>TContainerFile</c> result.
    /// The <c>OnError</c> event fires if an exception or API error occurs during execution.
    /// </para>
    /// <para>
    /// • The <c>TContainerFile</c> returned on success includes fields such as <c>Id</c>, <c>ContainerId</c>,
    /// <c>Bytes</c>, <c>Path</c>, <c>Source</c>, and <c>CreatedAt</c>.
    /// The raw API JSON payload is preserved in the <c>JSONResponse</c> property inherited from <c>TJSONFingerprint</c>.
    /// </para>
    /// <para>
    /// • The operation runs asynchronously on a background thread, ensuring UI responsiveness and safe multithreading behavior.
    /// Use this method for event-driven workflows that require non-blocking file creation with progress and error feedback.
    /// </para>
    /// </remarks>
    procedure AsynCreate(const ContainerId: string;
      const ParamProc: TProc<TContainerFilesParams>;
      const CallBacks: TFunc<TAsynContainerFile>);

    /// <summary>
    /// Asynchronously retrieves a paginated list of files within a specific container and triggers callback events during the operation.
    /// </summary>
    /// <param name="ContainerId">
    /// The identifier of the container whose file list should be retrieved.
    /// </param>
    /// <param name="ParamProc">
    /// A configuration procedure that builds the query string via <c>TUrlContainerFileParams</c>.
    /// Use it to define pagination and sorting options such as <c>After</c>, <c>Limit</c>, and <c>Order</c>.
    /// </param>
    /// <param name="CallBacks">
    /// A factory function returning a configured <c>TAsynContainerFileList</c> instance,
    /// allowing you to define asynchronous lifecycle handlers such as <c>OnStart</c>, <c>OnSuccess</c>, and <c>OnError</c>.
    /// </param>
    /// <remarks>
    /// <para>
    /// • Performs an asynchronous <c>GET</c> request to the <c>/containers/{container_id}/files</c> endpoint.
    /// The <paramref name="ParamProc"/> defines pagination and ordering parameters, while
    /// <paramref name="CallBacks"/> provides the event-driven lifecycle behavior.
    /// </para>
    /// <para>
    /// • The <c>OnStart</c> event is triggered when the listing request begins.
    /// The <c>OnSuccess</c> event is invoked upon successful completion and delivers a <c>TContainerFileList</c> result.
    /// The <c>OnError</c> event is raised if a network, API, or deserialization error occurs.
    /// </para>
    /// <para>
    /// • The resulting <c>TContainerFileList</c> object includes pagination metadata (<c>FirstId</c>, <c>LastId</c>, <c>HasMore</c>)
    /// and a strongly typed array of <c>TContainerFile</c> entries accessible through the <c>Data</c> property.
    /// Each <c>TContainerFile</c> includes details such as <c>Id</c>, <c>ContainerId</c>, <c>Path</c>, <c>Bytes</c>, and <c>Source</c>.
    /// </para>
    /// <para>
    /// • The raw API JSON payload is preserved in the <c>JSONResponse</c> property inherited from <c>TJSONFingerprint</c>,
    /// providing access to the underlying response structure for debugging or inspection.
    /// </para>
    /// <para>
    /// • The operation runs asynchronously on a background thread, ensuring that the main thread remains responsive.
    /// Use this method to enumerate container files in an event-driven, non-blocking manner with centralized error handling.
    /// </para>
    /// </remarks>
    procedure AsynList(const ContainerId: string;
      const ParamProc: TProc<TUrlContainerFileParams>;
      const CallBacks: TFunc<TAsynContainerFileList>);

    /// <summary>
    /// Asynchronously retrieves metadata for a specific file within a container and triggers callback events during the operation lifecycle.
    /// </summary>
    /// <param name="ContainerId">
    /// The identifier of the container that owns the file.
    /// </param>
    /// <param name="FileId">
    /// The unique identifier of the file to retrieve.
    /// </param>
    /// <param name="CallBacks">
    /// A factory function returning a configured <c>TAsynContainerFile</c> instance,
    /// allowing you to define asynchronous lifecycle event handlers such as <c>OnStart</c>, <c>OnSuccess</c>, and <c>OnError</c>.
    /// </param>
    /// <remarks>
    /// <para>
    /// • Performs an asynchronous <c>GET</c> request to the <c>/containers/{container_id}/files/{file_id}</c> endpoint.
    /// The <paramref name="CallBacks"/> argument specifies the asynchronous event handlers that control the lifecycle of the operation.
    /// </para>
    /// <para>
    /// • The <c>OnStart</c> event is triggered when the retrieval process begins.
    /// The <c>OnSuccess</c> event is invoked upon successful completion and delivers a <c>TContainerFile</c> result containing the file’s metadata.
    /// The <c>OnError</c> event fires if a network, API, or server error occurs during the request.
    /// </para>
    /// <para>
    /// • The resulting <c>TContainerFile</c> object includes metadata fields such as <c>Id</c>, <c>ContainerId</c>,
    /// <c>Path</c>, <c>Bytes</c>, <c>CreatedAt</c>, <c>Source</c>, and <c>Object</c> (always <c>container.file</c>).
    /// </para>
    /// <para>
    /// • The raw API JSON payload is stored in the <c>JSONResponse</c> property inherited from <c>TJSONFingerprint</c>,
    /// providing direct access to the original API response for debugging or inspection.
    /// </para>
    /// <para>
    /// • The operation runs asynchronously on a background thread, keeping the main thread responsive in GUI or service environments.
    /// Use this method when you need non-blocking, event-driven retrieval of file metadata with structured error handling.
    /// </para>
    /// </remarks>
    procedure AsynRetrieve(const ContainerId: string;
      const FileId: string;
      const CallBacks: TFunc<TAsynContainerFile>);

    /// <summary>
    /// Asynchronously retrieves the binary content of a specific file within a container and triggers callback events during the operation lifecycle.
    /// </summary>
    /// <param name="ContainerId">
    /// The identifier of the container that owns the target file.
    /// </param>
    /// <param name="FileId">
    /// The unique identifier of the file whose content should be retrieved.
    /// </param>
    /// <param name="CallBacks">
    /// A factory function returning a configured <c>TAsynContainerFileContent</c> instance,
    /// allowing you to define asynchronous lifecycle handlers such as <c>OnStart</c>, <c>OnSuccess</c>, and <c>OnError</c>.
    /// </param>
    /// <remarks>
    /// <para>
    /// • Performs an asynchronous <c>GET</c> request to the <c>/containers/{container_id}/files/{file_id}/content</c> endpoint
    /// to retrieve the binary payload of the specified file.
    /// </para>
    /// <para>
    /// • The <c>OnStart</c> event is invoked when the download begins.
    /// The <c>OnSuccess</c> event is triggered upon successful completion and provides a <c>TContainerFileContent</c> result.
    /// The <c>OnError</c> event fires if a network, API, or decoding error occurs during the process.
    /// </para>
    /// <para>
    /// • The resulting <c>TContainerFileContent</c> object exposes the Base64-encoded file data through the <c>Data</c> property
    /// and provides an <c>AsString</c> helper method for decoding text-based content.
    /// </para>
    /// <para>
    /// • This operation runs asynchronously on a background thread, ensuring that the main thread remains responsive during data transfer.
    /// </para>
    /// <para>
    /// • Use this method when you need non-blocking, event-driven retrieval of file content with real-time error and completion handling.
    /// For a synchronous alternative, use <c>GetContent</c>.
    /// For a promise-based approach, use <c>AsyncAwaitGetContent</c>.
    /// </para>
    /// </remarks>
    procedure AsynGetContent(const ContainerId: string;
      const FileId: string;
      const CallBacks: TFunc<TAsynContainerFileContent>);

    /// <summary>
    /// Asynchronously deletes a specific file from a container and triggers callback events during the operation lifecycle.
    /// </summary>
    /// <param name="ContainerId">
    /// The identifier of the container that owns the file to be deleted.
    /// </param>
    /// <param name="FileId">
    /// The unique identifier of the file to delete.
    /// </param>
    /// <param name="CallBacks">
    /// A factory function returning a configured <c>TAsynContainerFilesDelete</c> instance,
    /// allowing you to define asynchronous lifecycle event handlers such as <c>OnStart</c>, <c>OnSuccess</c>, and <c>OnError</c>.
    /// </param>
    /// <remarks>
    /// <para>
    /// • Performs an asynchronous <c>DELETE</c> request to the <c>/containers/{container_id}/files/{file_id}</c> endpoint,
    /// permanently removing the specified file from the container.
    /// </para>
    /// <para>
    /// • The <c>OnStart</c> event is invoked when the deletion request begins.
    /// The <c>OnSuccess</c> event is triggered upon successful completion and delivers a <c>TContainerFilesDelete</c> result
    /// confirming the deletion.
    /// The <c>OnError</c> event fires if a network, API, or server error occurs during the request.
    /// </para>
    /// <para>
    /// • The resulting <c>TContainerFilesDelete</c> object includes details such as <c>Id</c>,
    /// <c>Object</c> (always <c>container.file.deleted</c>), and a <c>Deleted</c> flag set to <c>True</c>
    /// to confirm that the file was successfully removed.
    /// </para>
    /// <para>
    /// • The operation runs asynchronously on a background thread, ensuring that the main thread remains responsive
    /// (ideal for GUI or service-based applications that perform background deletions).
    /// </para>
    /// <para>
    /// • The raw API JSON payload is preserved in the <c>JSONResponse</c> property inherited from <c>TJSONFingerprint</c>,
    /// providing access to the original API response for diagnostics or logging purposes.
    /// </para>
    /// <para>
    /// • Use this method for non-blocking, event-driven file deletion with centralized error handling.
    /// For a synchronous equivalent, use <c>Delete</c>.
    /// For a promise-based alternative, use <c>AsyncAwaitDelete</c>.
    /// </para>
    /// </remarks>
    procedure AsynDelete(const ContainerId: string;
      const FileId: string;
      const CallBacks: TFunc<TAsynContainerFilesDelete>);
  end;

implementation

{ TContainerFilesParams }

constructor TContainerFilesParams.Create;
begin
  inherited Create(true);
end;

function TContainerFilesParams.&File(
  const Value: string): TContainerFilesParams;
begin
  AddFile('file', Value);
  Result := Self;
end;

function TContainerFilesParams.FileId(
  const Value: string): TContainerFilesParams;
begin
  AddField('file_id', Value);
  Result := Self;
end;

{ TContainerFilesRoute }

function TContainerFilesRoute.AsyncAwaitCreate(const ContainerId: string;
  const ParamProc: TProc<TContainerFilesParams>;
  const CallBacks: TFunc<TPromiseContainerFile>): TPromise<TContainerFile>;
begin
  Result := TAsyncAwaitHelper.WrapAsyncAwait<TContainerFile>(
    procedure(const CallBackParams: TFunc<TAsynContainerFile>)
    begin
      Self.AsynCreate(ContainerId, ParamProc, CallBackParams);
    end,
    CallBacks);
end;

function TContainerFilesRoute.AsyncAwaitDelete(const ContainerId,
  FileId: string;
  const CallBacks: TFunc<TPromiseContainerFilesDelete>): TPromise<TContainerFilesDelete>;
begin
  Result := TAsyncAwaitHelper.WrapAsyncAwait<TContainerFilesDelete>(
    procedure(const CallBackParams: TFunc<TAsynContainerFilesDelete>)
    begin
      Self.AsynDelete(ContainerId, FileId, CallBackParams);
    end,
    CallBacks);
end;

function TContainerFilesRoute.AsyncAwaitGetContent(const ContainerId,
  FileId: string;
  const CallBacks: TFunc<TPromiseContainerFileContent>): TPromise<TContainerFileContent>;
begin
  Result := TAsyncAwaitHelper.WrapAsyncAwait<TContainerFileContent>(
    procedure(const CallBackParams: TFunc<TAsynContainerFileContent>)
    begin
      Self.AsynGetContent(ContainerId, FileId, CallBackParams);
    end,
    CallBacks);
end;

function TContainerFilesRoute.AsyncAwaitList(const ContainerId: string;
  const ParamProc: TProc<TUrlContainerFileParams>;
  const CallBacks: TFunc<TPromiseContainerFileList>): TPromise<TContainerFileList>;
begin
  Result := TAsyncAwaitHelper.WrapAsyncAwait<TContainerFileList>(
    procedure(const CallBackParams: TFunc<TAsynContainerFileList>)
    begin
      Self.AsynList(ContainerId, ParamProc, CallBackParams);
    end,
    CallBacks);
end;

function TContainerFilesRoute.AsyncAwaitRetrieve(const ContainerId,
  FileId: string;
  const CallBacks: TFunc<TPromiseContainerFile>): TPromise<TContainerFile>;
begin
  Result := TAsyncAwaitHelper.WrapAsyncAwait<TContainerFile>(
    procedure(const CallBackParams: TFunc<TAsynContainerFile>)
    begin
      Self.AsynRetrieve(ContainerId, FileId, CallBackParams);
    end,
    CallBacks);
end;

procedure TContainerFilesRoute.AsynCreate(const ContainerId: string;
  const ParamProc: TProc<TContainerFilesParams>;
  const CallBacks: TFunc<TAsynContainerFile>);
begin
  with TAsynCallBackExec<TAsynContainerFile, TContainerFile>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TContainerFile
      begin
        Result := Self.Create(ContainerId, ParamProc);
      end);
  finally
    Free;
  end;
end;

procedure TContainerFilesRoute.AsynDelete(const ContainerId, FileId: string;
  const CallBacks: TFunc<TAsynContainerFilesDelete>);
begin
  with TAsynCallBackExec<TAsynContainerFilesDelete, TContainerFilesDelete>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TContainerFilesDelete
      begin
        Result := Self.Delete(ContainerId, FileId);
      end);
  finally
    Free;
  end;
end;

procedure TContainerFilesRoute.AsynGetContent(const ContainerId, FileId: string;
  const CallBacks: TFunc<TAsynContainerFileContent>);
begin
  with TAsynCallBackExec<TAsynContainerFileContent, TContainerFileContent>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TContainerFileContent
      begin
        Result := Self.GetContent(ContainerId, FileId);
      end);
  finally
    Free;
  end;
end;

procedure TContainerFilesRoute.AsynList(const ContainerId: string;
  const ParamProc: TProc<TUrlContainerFileParams>;
  const CallBacks: TFunc<TAsynContainerFileList>);
begin
  with TAsynCallBackExec<TAsynContainerFileList, TContainerFileList>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TContainerFileList
      begin
        Result := Self.List(ContainerId, ParamProc);
      end);
  finally
    Free;
  end;
end;

procedure TContainerFilesRoute.AsynRetrieve(const ContainerId, FileId: string;
  const CallBacks: TFunc<TAsynContainerFile>);
begin
  with TAsynCallBackExec<TAsynContainerFile, TContainerFile>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TContainerFile
      begin
        Result := Self.Retrieve(ContainerId, FileId);
      end);
  finally
    Free;
  end;
end;

function TContainerFilesRoute.Create(const ContainerId: string;
  const ParamProc: TProc<TContainerFilesParams>): TContainerFile;
begin
  Result := API.PostForm<TContainerFile, TContainerFilesParams>(
    Format('containers/%s/files', [ContainerId]),
    ParamProc);
end;

function TContainerFilesRoute.Delete(const ContainerId,
  FileId: string): TContainerFilesDelete;
begin
  Result := API.Delete<TContainerFilesDelete>(
    Format('containers/%s/files/%s', [ContainerId, FileId]));
end;

function TContainerFilesRoute.GetContent(const ContainerId,
  FileId: string): TContainerFileContent;
begin
  try
    Result := TContainerFileContent.Create;
    var Bytes := API.GetBinary(Format('containers/%s/files/%s/content', [ContainerId, FileId]));
    Result.Data := TTextCodec.EncodeBytesToString(Bytes);
  except
    FreeAndNil(Result);
    raise;
  end;
end;

function TContainerFilesRoute.List(const ContainerId: string;
  const ParamProc: TProc<TUrlContainerFileParams>): TContainerFileList;
begin
  Result := API.Get<TContainerFileList, TUrlContainerFileParams>(
    Format('containers/%s/files', [ContainerId]),
    ParamProc);
end;

function TContainerFilesRoute.Retrieve(const ContainerId,
  FileId: string): TContainerFile;
begin
  Result := API.Get<TContainerFile>(
    Format('containers/%s/files/%s', [ContainerId, FileId]));
end;

{ TUrlContainerFileParams }

function TUrlContainerFileParams.After(
  const Value: string): TUrlContainerFileParams;
begin
  Result := TUrlContainerFileParams(Add('after', Value));
end;

function TUrlContainerFileParams.Limit(
  const Value: Integer): TUrlContainerFileParams;
begin
  Result := TUrlContainerFileParams(Add('limit', Value));
end;

function TUrlContainerFileParams.Order(
  const Value: string): TUrlContainerFileParams;
begin
  Result := TUrlContainerFileParams(Add('order', Value));
end;

{ TContainerFileList }

destructor TContainerFileList.Destroy;
begin
  for var Item in FData do
    Item.Free;
  inherited;
end;

{ TContainerFileContent }

function TContainerFileContent.AsString: string;
begin
  Result := TTextCodec.SafeBase64ToString(FData);
end;

end.
