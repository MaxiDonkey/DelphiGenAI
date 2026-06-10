unit GenAI.Video;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGenAI
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.SysUtils, System.Classes, System.Threading, System.JSON, System.Net.Mime,
  System.NetEncoding,
  REST.Json.Types, REST.JsonReflect,
  GenAI.API.Params, GenAI.API, GenAI.Types, GenAI.Async.Params, GenAI.Async.Support,
  GenAI.Async.Promise;

type
  TVideoParams = class(TMultipartFormData)
    constructor Create; reintroduce;

    /// <summary>
    /// Text prompt that describes the video to generate.
    /// </summary>
    function Prompt(const Value: string): TVideoParams;

    /// <summary>
    /// Optional image reference that guides generation.
    /// </summary>
    function InputReference(const Value: string): TVideoParams; overload;

    /// <summary>
    /// Optional image reference that guides generation.
    /// </summary>
    function InputReference(const Value: TStream; const FilePath: string): TVideoParams; overload;

    /// <summary>
    /// The video generation model to use. Defaults to sora-2.
    /// </summary>
    function Model(const Value: string): TVideoParams;

    /// <summary>
    /// Clip duration in seconds. Defaults to 4 seconds.
    /// </summary>
    function Seconds(const Value: string): TVideoParams;

    /// <summary>
    /// Output resolution formatted as width x height. Defaults to 720x1280.
    /// </summary>
    function Size(const Value: string): TVideoParams;
  end;

  TRemixParams = class(TJSONParam)
    /// <summary>
    /// Updated text prompt that directs the remix generation.
    /// </summary>
    function Prompt(const Value: string): TRemixParams;
  end;

  TUrlVideoParams = class(TUrlParam)
    /// <summary>
    /// Identifier for the last item from the previous pagination request
    /// </summary>
    function After(const Value: string): TUrlVideoParams;

    /// <summary>
    /// Number of items to retrieve
    /// </summary>
    function Limit(const Value: integer): TUrlVideoParams;

    /// <summary>
    /// Sort order of results by timestamp. Use asc for ascending order or desc for descending order.
    /// </summary>
    function Order(const Value: string = 'asc'): TUrlVideoParams;
  end;

  TVideoError = class
  private
    FCode    : string;
    FMessage : string;
  public
    property Code: string read FCode write FCode;
    property Message: string read FMessage write FMessage;
  end;

  TVideoJob = class(TJSONFingerprint)
  private
    [JsonNameAttribute('completed_at')]
    FCompletedAt              : Int64;
    [JsonNameAttribute('created_at')]
    FCreatedAt                : Int64;
    FError                    : TVideoError;
    [JsonNameAttribute('expires_at')]
    FExpiresAt                : Int64;
    FId                       : string;
    FModel                    : string;
    FObject                   : string;
    FProgress                 : Int64;
    [JsonNameAttribute('remixed_from_video_id')]
    FRemixedFromVideoId       : string;
    FSeconds                  : string;
    FSize                     : string;
    FStatus                   : string;
  public
    /// <summary>
    /// Unix timestamp (seconds) for when the job completed, if finished.
    /// </summary>
    property CompletedAt: Int64 read FCompletedAt write FCompletedAt;

    /// <summary>
    /// Unix timestamp (seconds) for when the job was created.
    /// </summary>
    property CreatedAt: Int64 read FCreatedAt write FCreatedAt;

    /// <summary>
    /// Error payload that explains why generation failed, if applicable.
    /// </summary>
    property Error: TVideoError read FError write FError;

    /// <summary>
    /// Unix timestamp (seconds) for when the downloadable assets expire, if set.
    /// </summary>
    property ExpiresAt: Int64 read FExpiresAt write FExpiresAt;

    /// <summary>
    /// Unique identifier for the video job.
    /// </summary>
    property Id: string read FId write FId;

    /// <summary>
    /// The video generation model that produced the job.
    /// </summary>
    property Model: string read FModel write FModel;

    /// <summary>
    /// The object type, which is always video.
    /// </summary>
    property &Object: string read FObject write FObject;

    /// <summary>
    /// Approximate completion percentage for the generation task.
    /// </summary>
    property Progress: Int64 read FProgress write FProgress;

    /// <summary>
    /// Identifier of the source video if this video is a remix.
    /// </summary>
    property RemixedFromVideoId: string read FRemixedFromVideoId write FRemixedFromVideoId;

    /// <summary>
    /// Duration of the generated clip in seconds.
    /// </summary>
    property Seconds: string read FSeconds write FSeconds;

    /// <summary>
    /// The resolution of the generated video.
    /// </summary>
    property Size: string read FSize write FSize;

    /// <summary>
    /// Current lifecycle status of the video job.
    /// </summary>
    property Status: string read FStatus write FStatus;
    destructor Destroy; override;
  end;

  TVideoJobList = class(TJSONFingerprint)
  private
    FData: TArray<TVideoJob>;
    FObject                   : string;
    [JsonNameAttribute('first_id')]
    FFirstId                  : string;
    [JsonNameAttribute('has_more')]
    FHasMore                  : Boolean;
    [JsonNameAttribute('last_id')]
    FLastId                   : string;
  public
    property Data: TArray<TVideoJob> read FData write FData;
    property &Object: string read FObject write FObject;
    property FirstId: string read FFirstId write FFirstId;
    property HasMore: Boolean read FHasMore write FHasMore;
    property LastId: string read FLastId write FLastId;
    destructor Destroy; override;
  end;

  /// <summary>
  /// Represents a downloaded video payload returned by the API.
  /// </summary>
  /// <remarks>
  /// <para>
  /// The <c>Data</c> property stores the video content as a Base64-encoded string.
  /// Use <see cref="SaveToFile"/> to decode and persist the video to disk as an MP4 (or any
  /// binary format provided by the API).
  /// </para>
  /// <para>
  /// This class is a lightweight container meant to integrate with asynchronous flows:
  /// obtain an instance from the download route, then call <c>SaveToFile</c> when you are
  /// ready to write the file.
  /// </para>
  /// </remarks>
  TVideoDownloaded = class
  private
    FData: string;
  public
    /// <summary>
    /// Base64-encoded binary content of the downloaded video.
    /// </summary>
    /// <remarks>
    /// The string contains the raw bytes encoded with Base64. It is not JSON.
    /// Decoding and persistence are handled by <see cref="SaveToFile"/>.
    /// </remarks>
    property Data: string read FData write FData;

    /// <summary>
    /// Decodes <see cref="Data"/> from Base64 and writes the resulting bytes to
    /// the specified file path.
    /// </summary>
    /// <param name="FileName">
    /// Full path (including file name and extension) where the video will be saved.
    /// </param>
    /// <remarks>
    /// <para>
    /// The method overwrites the target file if it already exists. It expects
    /// <see cref="Data"/> to be non-empty and contain valid Base64; otherwise an error is raised.
    /// </para>
    /// <para>
    /// The output format (e.g., <c>.mp4</c>) should match the content delivered by the API.
    /// </para>
    /// </remarks>
    procedure SaveToFile(const FileName: string);
  end;

  /// <summary>
  /// Asynchronous callback wrapper for operations that return a <c>TVideoJob</c> result.
  /// </summary>
  /// <remarks>
  /// <para>
  /// Alias of <c>TAsynCallBack&lt;TVideoJob&gt;</c>. Exposes the framework’s event-driven async lifecycle
  /// for video-job requests (e.g., create, remix, retrieve, delete), enabling non-blocking execution
  /// with dispatcher-safe notifications.
  /// </para>
  /// <para>
  /// Typical handlers include <c>OnStart</c> (invoked when the request begins), <c>OnSuccess</c>
  /// (delivering the resolved <c>TVideoJob</c>), and <c>OnError</c> (propagating failures).
  /// </para>
  /// <para>
  /// The resulting <c>TVideoJob</c> inherits <c>TJSONFingerprint</c>, providing access to the raw API
  /// payload via <c>JSONResponse</c> alongside structured fields such as <c>Status</c>, <c>Progress</c>,
  /// <c>Model</c>, and timestamps.
  /// </para>
  /// <para>
  /// Use this alias with asynchronous route methods like <c>TVideoRoute.AsynCreate</c>,
  /// <c>TVideoRoute.AsynRemix</c>, <c>TVideoRoute.AsynRetrieve</c>, or <c>TVideoRoute.AsynDelete</c>
  /// to keep intent explicit and preserve strong typing of the callback payload.
  /// </para>
  /// </remarks>
  TAsynVideoJob = TAsynCallBack<TVideoJob>;

  /// <summary>
  /// Promise-style asynchronous wrapper for operations that return a <c>TVideoJob</c> result.
  /// </summary>
  /// <remarks>
  /// <para>
  /// Alias of <c>TPromiseCallBack&lt;TVideoJob&gt;</c>. Provides a promise-oriented async flow for
  /// video-job operations (e.g., create, remix, retrieve, delete), enabling structured chaining,
  /// continuation, and centralized error handling.
  /// </para>
  /// <para>
  /// Standard promise handlers include <c>OnStart</c> (triggered when the request begins),
  /// <c>OnSuccess</c> (resolve, invoked with the completed <c>TVideoJob</c>), and
  /// <c>OnError</c> (reject, invoked on failure).
  /// </para>
  /// <para>
  /// Use this alias with await-style route methods (e.g., <c>TVideoRoute.AsyncAwaitCreate</c>,
  /// <c>TVideoRoute.AsyncAwaitRemix</c>, <c>TVideoRoute.AsyncAwaitRetrieve</c>,
  /// <c>TVideoRoute.AsyncAwaitDelete</c>) to keep intent explicit while preserving strong typing of
  /// the promised payload.
  /// </para>
  /// <para>
  /// The resolved <c>TVideoJob</c> inherits <c>TJSONFingerprint</c>, exposing the raw API payload
  /// via <c>JSONResponse</c> in addition to structured fields such as <c>Status</c>, <c>Progress</c>,
  /// <c>Model</c>, and timestamps.
  /// </para>
  /// </remarks>
  TPromiseVideoJob = TPromiseCallBack<TVideoJob>;

  /// <summary>
  /// Asynchronous callback wrapper for operations that return a <c>TVideoJobList</c> result.
  /// </summary>
  /// <remarks>
  /// <para>
  /// Alias of <c>TAsynCallBack&lt;TVideoJobList&gt;</c>. Provides the framework’s event-driven asynchronous
  /// lifecycle for list operations on video jobs (e.g., enumeration, pagination, or library management),
  /// allowing non-blocking execution with dispatcher-safe notifications.
  /// </para>
  /// <para>
  /// Typical handlers include <c>OnStart</c> (invoked when the listing request begins),
  /// <c>OnSuccess</c> (delivering the resolved <c>TVideoJobList</c> payload), and
  /// <c>OnError</c> (triggered on failure or network error).
  /// </para>
  /// <para>
  /// Use this alias with asynchronous methods such as <c>TVideoRoute.AsynList</c> to keep the intent explicit
  /// and preserve strong typing of the callback payload.
  /// </para>
  /// <para>
  /// The resulting <c>TVideoJobList</c> inherits <c>TJSONFingerprint</c> and provides pagination
  /// metadata (<c>FirstId</c>, <c>LastId</c>, <c>HasMore</c>) along with a collection of <c>TVideoJob</c>
  /// instances accessible via the <c>Data</c> property.
  /// </para>
  /// </remarks>
  TAsynVideoJobList = TAsynCallBack<TVideoJobList>;

  /// <summary>
  /// Promise-style asynchronous wrapper for operations that return a <c>TVideoJobList</c> result.
  /// </summary>
  /// <remarks>
  /// <para>
  /// Alias of <c>TPromiseCallBack&lt;TVideoJobList&gt;</c>. Provides a promise-based asynchronous workflow
  /// for list operations on video jobs (such as pagination, enumeration, or batch retrieval), enabling
  /// structured chaining, continuation, and centralized error handling.
  /// </para>
  /// <para>
  /// Standard promise handlers include <c>OnStart</c> (triggered when the listing request begins),
  /// <c>OnSuccess</c> (resolve, invoked when the operation completes successfully with a
  /// <c>TVideoJobList</c> payload), and <c>OnError</c> (reject, invoked in case of network or
  /// server failure).
  /// </para>
  /// <para>
  /// Use this alias with await-style methods such as <c>TVideoRoute.AsyncAwaitList</c> to make the
  /// intent explicit while maintaining strong typing of the promised payload.
  /// </para>
  /// <para>
  /// The resolved <c>TVideoJobList</c> inherits <c>TJSONFingerprint</c> and includes pagination
  /// markers (<c>FirstId</c>, <c>LastId</c>, <c>HasMore</c>) along with a strongly typed array of
  /// <c>TVideoJob</c> instances available through the <c>Data</c> property.
  /// </para>
  /// </remarks>
  TPromiseVideoJobList = TPromiseCallBack<TVideoJobList>;

  /// <summary>
  /// Asynchronous callback wrapper for operations that return a <c>TVideoDownloaded</c> result.
  /// </summary>
  /// <remarks>
  /// <para>
  /// Alias of <c>TAsynCallBack&lt;TVideoDownloaded&gt;</c>. Provides an event-driven asynchronous
  /// lifecycle for video download operations, enabling non-blocking execution with thread-safe
  /// callbacks and UI-friendly notifications.
  /// </para>
  /// <para>
  /// Typical handlers include <c>OnStart</c> (triggered when the download begins),
  /// <c>OnSuccess</c> (invoked when the download completes successfully with a
  /// <c>TVideoDownloaded</c> payload), and <c>OnError</c> (triggered on failure or connection error).
  /// </para>
  /// <para>
  /// Use this alias with asynchronous methods such as <c>TVideoRoute.AsynDownload</c> to keep the
  /// intent explicit and maintain strong typing of the callback payload.
  /// </para>
  /// <para>
  TAsynVideoDownloaded = TAsynCallBack<TVideoDownloaded>;

  /// <summary>
  /// Promise-style asynchronous wrapper for operations that return a <c>TVideoDownloaded</c> result.
  /// </summary>
  /// <remarks>
  /// <para>
  /// Alias of <c>TPromiseCallBack&lt;TVideoDownloaded&gt;</c>. Provides a promise-based asynchronous
  /// workflow for video download operations, enabling structured chaining, continuation, and error
  /// handling in non-blocking execution flows.
  /// </para>
  /// <para>
  /// Standard promise handlers include <c>OnStart</c> (triggered when the download begins),
  /// <c>OnSuccess</c> (resolve, invoked when the operation completes successfully with a
  /// <c>TVideoDownloaded</c> payload), and <c>OnError</c> (reject, invoked in case of failure).
  /// </para>
  /// <para>
  /// Use this alias with await-style methods such as <c>TVideoRoute.AsyncAwaitDownload</c> to
  /// preserve strong typing of the result and maintain clear intent for asynchronous file retrieval.
  /// </para>
  /// <para>
  /// The resolved <c>TVideoDownloaded</c> instance contains a Base64-encoded representation of
  /// the binary video data accessible via the <c>Data</c> property. To persist the video on disk,
  /// call <see cref="TVideoDownloaded.SaveToFile"/> with the desired output path and file name.
  /// </para>
  /// </remarks>
  TPromiseVideoDownloaded = TPromiseCallBack<TVideoDownloaded>;

  TVideoRoute = class(TGenAIRoute)
    /// <summary>
    /// Asynchronously creates a new video-generation job and returns a <c>TPromise&lt;TVideoJob&gt;</c> handle.
    /// </summary>
    /// <param name="ParamProc">
    /// A configuration procedure that builds the multipart request via <c>TVideoParams</c>.
    /// Use it to set fields such as <c>Prompt</c>, <c>Model</c>, <c>Seconds</c>, <c>Size</c>, and
    /// optional <c>InputReference</c>.
    /// </param>
    /// <param name="CallBacks">
    /// (Optional) A factory that returns a <c>TPromiseVideoJob</c> instance, allowing you to attach
    /// promise lifecycle handlers (<c>OnStart</c>, <c>OnSuccess</c>, <c>OnError</c>).
    /// </param>
    /// <returns>
    /// A <c>TPromise&lt;TVideoJob&gt;</c> that resolves with the created job descriptor once the request completes.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • Performs a non-blocking POST to the <c>/videos</c> endpoint. The resolved <c>TVideoJob</c> contains identifiers,
    /// timestamps, model information, <c>Status</c>, and <c>Progress</c>. The raw API payload is available through
    /// <c>TJSONFingerprint.JSONResponse</c>.
    /// </para>
    /// <para>
    /// • Internally, wraps <c>TVideoRoute.AsynCreate</c> with <c>TAsyncAwaitHelper.WrapAsyncAwait</c> to provide a
    /// promise-based interface while preserving strong typing of the result.
    /// </para>
    /// </remarks>
    function AsyncAwaitCreate(const ParamProc: TProc<TVideoParams>;
      const CallBacks: TFunc<TPromiseVideoJob> = nil): TPromise<TVideoJob>;

    /// <summary>
    /// Asynchronously creates a remix of an existing video job and returns a <c>TPromise&lt;TVideoJob&gt;</c> handle.
    /// </summary>
    /// <param name="VideoId">
    /// The identifier of the source video to remix.
    /// </param>
    /// <param name="ParamProc">
    /// A configuration procedure that builds the JSON body via <c>TRemixParams</c>.
    /// Use it to set fields such as the updated <c>Prompt</c> that guides the remix.
    /// </param>
    /// <param name="CallBacks">
    /// (Optional) A factory that returns a <c>TPromiseVideoJob</c> instance, allowing you to attach
    /// promise lifecycle handlers (<c>OnStart</c>, <c>OnSuccess</c>, <c>OnError</c>).
    /// </param>
    /// <returns>
    /// A <c>TPromise&lt;TVideoJob&gt;</c> that resolves with the created remix job descriptor upon completion.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • Performs a non-blocking POST to <c>/videos/{video_id}/remix</c>. The resolved <c>TVideoJob</c> includes
    /// identifiers, timestamps, model details, <c>Status</c>, <c>Progress</c>, and the <c>RemixedFromVideoId</c> reference.
    /// The raw API payload is available through <c>TJSONFingerprint.JSONResponse</c>.
    /// </para>
    /// <para>
    /// • Internally, wraps <c>TVideoRoute.AsynRemix</c> with <c>TAsyncAwaitHelper.WrapAsyncAwait</c> to provide a
    /// promise-based interface while preserving strong typing of the result.
    /// </para>
    /// </remarks>
    function AsyncAwaitRemix(const VideoId: string;
      const ParamProc: TProc<TRemixParams>;
      const CallBacks: TFunc<TPromiseVideoJob> = nil): TPromise<TVideoJob>;

    /// <summary>
    /// Asynchronously deletes a video job and returns a <c>TPromise&lt;TVideoJob&gt;</c> handle.
    /// </summary>
    /// <param name="VideoId">
    /// The unique identifier of the video job to delete.
    /// </param>
    /// <param name="CallBacks">
    /// (Optional) A factory that returns a <c>TPromiseVideoJob</c> instance, allowing you to attach
    /// promise lifecycle handlers (<c>OnStart</c>, <c>OnSuccess</c>, <c>OnError</c>).
    /// </param>
    /// <returns>
    /// A <c>TPromise&lt;TVideoJob&gt;</c> that resolves once the deletion completes successfully.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • Performs a non-blocking DELETE request to the <c>/videos/{video_id}</c> endpoint.
    /// The resolved <c>TVideoJob</c> contains the metadata of the deleted job, including
    /// its <c>Id</c>, <c>Model</c>, and <c>Status</c>. The raw JSON response from the API
    /// is preserved in <c>TJSONFingerprint.JSONResponse</c>.
    /// </para>
    /// <para>
    /// • This method provides a promise-based asynchronous abstraction over
    /// <c>TVideoRoute.AsynDelete</c>, internally using <c>TAsyncAwaitHelper.WrapAsyncAwait</c>
    /// to ensure type safety and compatibility with Delphi’s asynchronous flow.
    /// </para>
    /// <para>
    /// • Use this in situations where you need to clean up previously generated video assets
    /// or manage video job lifecycle within an async/promise context.
    /// </para>
    /// </remarks>
    function AsyncAwaitDelete(const VideoId: string;
      const CallBacks: TFunc<TPromiseVideoJob> = nil): TPromise<TVideoJob>;

    /// <summary>
    /// Asynchronously retrieves a paginated list of video jobs and returns a <c>TPromise&lt;TVideoJobList&gt;</c> handle.
    /// </summary>
    /// <param name="ParamProc">
    /// A configuration procedure that builds the query string via <c>TUrlVideoParams</c>.
    /// Use it to set parameters such as <c>Limit</c>, <c>After</c>, and <c>Order</c> for pagination and sorting.
    /// </param>
    /// <param name="CallBacks">
    /// (Optional) A factory that returns a <c>TPromiseVideoJobList</c> instance, allowing you to attach
    /// promise lifecycle handlers (<c>OnStart</c>, <c>OnSuccess</c>, <c>OnError</c>).
    /// </param>
    /// <returns>
    /// A <c>TPromise&lt;TVideoJobList&gt;</c> that resolves with the full listing of video jobs once the request completes.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • Performs a non-blocking GET request to the <c>/videos</c> endpoint.
    /// The resolved <c>TVideoJobList</c> provides pagination metadata (<c>FirstId</c>, <c>LastId</c>, <c>HasMore</c>)
    /// and an ordered collection of <c>TVideoJob</c> instances accessible via the <c>Data</c> property.
    /// </para>
    /// <para>
    /// • Internally, wraps <c>TVideoRoute.AsynList</c> with <c>TAsyncAwaitHelper.WrapAsyncAwait</c> to provide a
    /// promise-based interface with strong typing and full async lifecycle support.
    /// </para>
    /// <para>
    /// • Use this method to asynchronously enumerate, paginate, or refresh the list of video jobs
    /// while maintaining non-blocking UI and structured asynchronous flow.
    /// </para>
    /// </remarks>
    function AsyncAwaitList(const ParamProc: TProc<TUrlVideoParams>;
      const CallBacks: TFunc<TPromiseVideoJobList> = nil): TPromise<TVideoJobList>;

    /// <summary>
    /// Asynchronously retrieves metadata for a specific video job and returns a <c>TPromise&lt;TVideoJob&gt;</c> handle.
    /// </summary>
    /// <param name="VideoId">
    /// The unique identifier of the video job to retrieve.
    /// </param>
    /// <param name="CallBacks">
    /// (Optional) A factory that returns a <c>TPromiseVideoJob</c> instance, allowing you to attach
    /// promise lifecycle handlers (<c>OnStart</c>, <c>OnSuccess</c>, <c>OnError</c>).
    /// </param>
    /// <returns>
    /// A <c>TPromise&lt;TVideoJob&gt;</c> that resolves with the retrieved job metadata once the request completes.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • Executes a non-blocking GET request to the <c>/videos/{video_id}</c> endpoint.
    /// The resolved <c>TVideoJob</c> contains detailed information about the job,
    /// including its <c>Id</c>, <c>Model</c>, <c>Status</c>, <c>Progress</c>, timestamps,
    /// and any error payloads from the API.
    /// </para>
    /// <para>
    /// • The raw API payload is accessible via <c>TJSONFingerprint.JSONResponse</c>,
    /// allowing low-level inspection or debugging of the response structure.
    /// </para>
    /// <para>
    /// • Internally, this method wraps <c>TVideoRoute.AsynRetrieve</c> with
    /// <c>TAsyncAwaitHelper.WrapAsyncAwait</c>, exposing a promise-based, strongly typed interface
    /// for seamless integration in asynchronous or reactive code flows.
    /// </para>
    /// <para>
    /// • Use this method to track generation status, poll for completion,
    /// or inspect result metadata without blocking the main thread.
    /// </para>
    /// </remarks>
    function AsyncAwaitRetrieve(const VideoId: string;
      const CallBacks: TFunc<TPromiseVideoJob> = nil): TPromise<TVideoJob>;

    /// <summary>
    /// Asynchronously downloads the generated video content and returns a <c>TPromise&lt;TVideoDownloaded&gt;</c> handle.
    /// </summary>
    /// <param name="VideoId">
    /// The unique identifier of the video to download.
    /// </param>
    /// <param name="CallBacks">
    /// (Optional) A factory that returns a <c>TPromiseVideoDownloaded</c> instance, allowing you to attach
    /// promise lifecycle handlers (<c>OnStart</c>, <c>OnSuccess</c>, <c>OnError</c>).
    /// </param>
    /// <returns>
    /// A <c>TPromise&lt;TVideoDownloaded&gt;</c> that resolves with the downloaded video payload once the request completes.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • Executes a non-blocking GET request to the <c>/videos/{video_id}/content</c> endpoint.
    /// The resolved <c>TVideoDownloaded</c> contains the video data encoded as Base64 in its <c>Data</c> property.
    /// Use <see cref="TVideoDownloaded.SaveToFile"/> to decode and persist the file to disk.
    /// </para>
    /// <para>
    /// • Internally, this method wraps <c>TVideoRoute.AsynDownload</c> with
    /// <c>TAsyncAwaitHelper.WrapAsyncAwait</c>, exposing a promise-based, strongly typed interface
    /// compatible with Delphi’s asynchronous programming model.
    /// </para>
    /// <para>
    /// • Use this method to asynchronously fetch and store generated video results
    /// without blocking the UI or main execution thread.
    /// </para>
    /// </remarks>
    function AsyncAwaitDownload(const VideoId: string;
      const CallBacks: TFunc<TPromiseVideoDownloaded> = nil): TPromise<TVideoDownloaded>;

    /// <summary>
    /// Creates a new video generation job and returns a <c>TVideoJob</c> representing its state.
    /// </summary>
    /// <param name="ParamProc">
    /// A configuration procedure used to populate the request body through a <c>TVideoParams</c> instance.
    /// Define generation parameters such as <c>Prompt</c>, <c>Model</c>, <c>Seconds</c>, and <c>Size</c>.
    /// </param>
    /// <returns>
    /// A <c>TVideoJob</c> containing metadata for the newly created video generation task.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • Sends a synchronous multipart <c>POST</c> request to the <c>/videos</c> endpoint.
    /// The <c>TVideoParams</c> object configured within <paramref name="ParamProc"/> defines
    /// the text prompt and optional input references that guide the generation process.
    /// </para>
    /// <para>
    /// • The returned <c>TVideoJob</c> provides full job metadata including its unique identifier,
    /// current status, selected model, duration, size, and creation timestamps.
    /// </para>
    /// <para>
    /// • The raw API JSON response is preserved in the <c>JSONResponse</c> property inherited
    /// from <c>TJSONFingerprint</c> for inspection and traceability.
    /// </para>
    /// <para>
    /// • Use this method for immediate job creation in a synchronous context. For non-blocking
    /// or UI-friendly asynchronous submission, refer to <c>AsyncAwaitCreate</c>.
    /// </para>
    /// </remarks>
    function Create(const ParamProc: TProc<TVideoParams>): TVideoJob;

    /// <summary>
    /// Creates a remix of an existing video and returns a <c>TVideoJob</c> describing the new generation task.
    /// </summary>
    /// <param name="VideoId">
    /// The unique identifier of the original video to remix.
    /// </param>
    /// <param name="ParamProc">
    /// A configuration procedure used to populate the JSON body via a <c>TRemixParams</c> instance,
    /// typically including an updated <c>Prompt</c> to guide the remix generation.
    /// </param>
    /// <returns>
    /// A <c>TVideoJob</c> object containing metadata for the newly created remix job.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • Sends a synchronous <c>POST</c> request to the <c>/videos/{video_id}/remix</c> endpoint.
    /// The request inherits context from the original video identified by <paramref name="VideoId"/>,
    /// and applies modifications defined in <paramref name="ParamProc"/>.
    /// </para>
    /// <para>
    /// • The returned <c>TVideoJob</c> includes information such as <c>Id</c>, <c>Status</c>,
    /// <c>Model</c>, <c>Progress</c>, and timestamps (<c>CreatedAt</c>, <c>CompletedAt</c>).
    /// The <c>RemixedFromVideoId</c> field references the original source video.
    /// </para>
    /// <para>
    /// • Use this method to create a new generation derived from a previous video’s output
    /// with altered text prompts or parameters, producing an updated or refined variation.
    /// </para>
    /// <para>
    /// • The full API response is retained in <c>TJSONFingerprint.JSONResponse</c>
    /// for debugging or audit purposes.
    /// </para>
    /// </remarks>
    function Remix(const VideoId: string; const ParamProc: TProc<TRemixParams>): TVideoJob;

    /// <summary>
    /// Deletes an existing video job and returns a <c>TVideoJob</c> representing the deletion result.
    /// </summary>
    /// <param name="VideoId">
    /// The unique identifier of the video to delete.
    /// </param>
    /// <returns>
    /// A <c>TVideoJob</c> containing metadata about the deleted video job, including its final state.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • Executes a synchronous <c>DELETE</c> request to the <c>/videos/{video_id}</c> endpoint.
    /// The request permanently removes the video job and its associated assets from the system.
    /// </para>
    /// <para>
    /// • The returned <c>TVideoJob</c> reflects the deleted resource’s final state, including
    /// its identifier, timestamps, and <c>Status</c> field, which typically indicates completion
    /// or deletion. If the deletion fails, an exception is raised with detailed error information.
    /// </para>
    /// <para>
    /// • This method performs the operation synchronously. For asynchronous deletion,
    /// refer to <c>AsyncAwaitDelete</c>, which provides a non-blocking equivalent with
    /// promise-style handling.
    /// </para>
    /// <para>
    /// • The raw API response is preserved in <c>TJSONFingerprint.JSONResponse</c>
    /// for debugging or inspection purposes.
    /// </para>
    /// </remarks>
    function Delete(const VideoId: string): TVideoJob;

    /// <summary>
    /// Retrieves a paginated list of video generation jobs and returns a <c>TVideoJobList</c> containing the results.
    /// </summary>
    /// <param name="ParamProc">
    /// A configuration procedure used to populate the query string via a <c>TUrlVideoParams</c> instance.
    /// Parameters can include pagination and sorting options such as <c>After</c>, <c>Limit</c>, and <c>Order</c>.
    /// </param>
    /// <returns>
    /// A <c>TVideoJobList</c> containing an array of <c>TVideoJob</c> entries that match the specified filters.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • Sends a synchronous <c>GET</c> request to the <c>/videos</c> endpoint.
    /// The <paramref name="ParamProc"/> procedure allows optional control over pagination and result ordering.
    /// </para>
    /// <para>
    /// • The returned <c>TVideoJobList</c> object encapsulates both metadata and data fields:
    /// it includes <c>Data</c> (the list of video jobs), <c>HasMore</c> (indicating if further pages exist),
    /// and pagination markers (<c>FirstId</c>, <c>LastId</c>).
    /// </para>
    /// <para>
    /// • Each element within <c>Data</c> is a <c>TVideoJob</c> providing information about individual generation jobs,
    /// including identifiers, model names, timestamps, and current processing states.
    /// </para>
    /// <para>
    /// • This method performs a synchronous call and should be used when immediate, blocking access to
    /// the job list is acceptable. For asynchronous retrieval, see <c>AsyncAwaitList</c>.
    /// </para>
    /// <para>
    /// • The complete API response is retained in <c>TJSONFingerprint.JSONResponse</c>
    /// for reference or inspection purposes.
    /// </para>
    /// </remarks>
    function List(const ParamProc: TProc<TUrlVideoParams>): TVideoJobList;

    /// <summary>
    /// Retrieves detailed information about a specific video generation job and returns a <c>TVideoJob</c> instance.
    /// </summary>
    /// <param name="VideoId">
    /// The unique identifier of the video job to retrieve.
    /// </param>
    /// <returns>
    /// A <c>TVideoJob</c> object containing detailed metadata and current status of the specified video job.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • Sends a synchronous <c>GET</c> request to the <c>/videos/{video_id}</c> endpoint.
    /// The request fetches the full job record for the video identified by <paramref name="VideoId"/>.
    /// </para>
    /// <para>
    /// • The returned <c>TVideoJob</c> includes fields such as <c>Id</c>, <c>Model</c>, <c>Status</c>,
    /// <c>Progress</c>, and timestamps (<c>CreatedAt</c>, <c>CompletedAt</c>, <c>ExpiresAt</c>).
    /// If the video was generated as a remix, the <c>RemixedFromVideoId</c> property references the source video.
    /// </para>
    /// <para>
    /// • Use this method to poll the current state of an ongoing or completed generation task,
    /// or to access metadata for later retrieval or download operations.
    /// </para>
    /// <para>
    /// • The full raw JSON response is preserved in the <c>JSONResponse</c> property inherited
    /// from <c>TJSONFingerprint</c> for transparency and debugging purposes.
    /// </para>
    /// <para>
    /// • For non-blocking asynchronous retrieval, use <c>AsyncAwaitRetrieve</c>.
    /// </para>
    /// </remarks>
    function Retrieve(const VideoId: string): TVideoJob;

    /// <summary>
    /// Downloads the binary content of a generated video and returns it as a <c>TVideoDownloaded</c> instance.
    /// </summary>
    /// <param name="VideoId">
    /// The unique identifier of the video to download.
    /// </param>
    /// <returns>
    /// A <c>TVideoDownloaded</c> object containing the Base64-encoded binary data of the requested video.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • Executes a synchronous <c>GET</c> request to the <c>/videos/{video_id}/content</c> endpoint.
    /// The video file is downloaded as binary data, which is then encoded into Base64 and stored
    /// in the <c>Data</c> property of the resulting <c>TVideoDownloaded</c> instance.
    /// </para>
    /// <para>
    /// • Use the <see cref="TVideoDownloaded.SaveToFile"/> method to decode and write the content
    /// to a file (for example, <c>.mp4</c>) on disk. If the request fails or returns an invalid
    /// payload, an exception is raised.
    /// </para>
    /// <para>
    /// • This method performs a blocking download and is intended for contexts where synchronous
    /// access is acceptable. For asynchronous, promise-based downloading, refer to
    /// <c>AsyncAwaitDownload</c>.
    /// </para>
    /// <para>
    /// • The download operation ensures correct binary handling and encoding, maintaining
    /// data integrity across the API transport layer.
    /// </para>
    /// </remarks>
    function Download(const VideoId: string): TVideoDownloaded;

    /// <summary>
    /// Asynchronously creates a new video generation job and triggers callback events during its lifecycle.
    /// </summary>
    /// <param name="ParamProc">
    /// A configuration procedure used to populate the multipart request body through a <c>TVideoParams</c> instance.
    /// Define generation parameters such as <c>Prompt</c>, <c>Model</c>, <c>Seconds</c>, and <c>Size</c>.
    /// </param>
    /// <param name="CallBacks">
    /// A factory function that returns a configured <c>TAsynVideoJob</c> instance.
    /// This instance defines event handlers such as <c>OnStart</c>, <c>OnSuccess</c>, and <c>OnError</c>.
    /// </param>
    /// <remarks>
    /// <para>
    /// • Sends an asynchronous multipart <c>POST</c> request to the <c>/videos</c> endpoint.
    /// The <paramref name="ParamProc"/> callback configures the generation parameters,
    /// while <paramref name="CallBacks"/> defines the asynchronous lifecycle behavior.
    /// </para>
    /// <para>
    /// • The resulting <c>TAsynVideoJob</c> provides non-blocking notifications.
    /// The <c>OnStart</c> event is triggered when the job submission begins.
    /// The <c>OnSuccess</c> event is invoked upon successful completion and delivers the resulting <c>TVideoJob</c>.
    /// The <c>OnError</c> event is fired if an exception or HTTP error occurs during the operation.
    /// </para>
    /// <para>
    /// • The operation executes on a background thread, allowing safe use within GUI applications
    /// or other asynchronous workflows without blocking the main thread.
    /// </para>
    /// <para>
    /// • The <c>TVideoJob</c> object returned in <c>OnSuccess</c> contains detailed information about the
    /// job, including <c>Id</c>, <c>Status</c>, <c>Progress</c>, and model metadata.
    /// The raw API payload is preserved in the <c>JSONResponse</c> property inherited from <c>TJSONFingerprint</c>.
    /// </para>
    /// <para>
    /// • Use this method when initiating a video generation task that should execute asynchronously
    /// with event-driven feedback rather than blocking execution.
    /// </para>
    /// </remarks>
    procedure AsynCreate(const ParamProc: TProc<TVideoParams>;
      const CallBacks: TFunc<TAsynVideoJob>);

    /// <summary>
    /// Asynchronously creates a remix of an existing video based on a new prompt or parameters.
    /// </summary>
    /// <param name="VideoId">
    /// The unique identifier of the source video to be remixed.
    /// </param>
    /// <param name="ParamProc">
    /// A configuration procedure used to define remix parameters through a <c>TRemixParams</c> instance.
    /// Typically, this includes updating the text prompt that guides the remix process.
    /// </param>
    /// <param name="CallBacks">
    /// A factory function returning a configured <c>TAsynVideoJob</c> instance,
    /// defining asynchronous lifecycle handlers such as <c>OnStart</c>, <c>OnSuccess</c>, and <c>OnError</c>.
    /// </param>
    /// <remarks>
    /// <para>
    /// • Sends an asynchronous <c>POST</c> request to the <c>/videos/{video_id}/remix</c> endpoint.
    /// The <paramref name="ParamProc"/> callback prepares the remix parameters,
    /// while <paramref name="CallBacks"/> defines how the asynchronous events are handled.
    /// </para>
    /// <para>
    /// • The resulting <c>TAsynVideoJob</c> provides event-driven feedback throughout the lifecycle.
    /// The <c>OnStart</c> event is triggered when the remix request begins.
    /// The <c>OnSuccess</c> event is invoked when the remix completes successfully and delivers a <c>TVideoJob</c> result.
    /// The <c>OnError</c> event is fired if the remix request fails or an exception occurs during execution.
    /// </para>
    /// <para>
    /// • The operation executes asynchronously on a background thread, ensuring that the main thread
    /// (for example, in GUI applications) remains responsive during long-running remix generation.
    /// </para>
    /// <para>
    /// • The <c>TVideoJob</c> object returned in <c>OnSuccess</c> contains job details such as
    /// <c>Id</c>, <c>Status</c>, <c>Progress</c>, and any associated model metadata.
    /// The raw API response is preserved within <c>JSONResponse</c> for diagnostic or logging purposes.
    /// </para>
    /// <para>
    /// • Use this method when initiating a video remix operation asynchronously, allowing event-driven
    /// progress and result handling rather than blocking the caller until completion.
    /// </para>
    /// </remarks>
    procedure AsynRemix(const VideoId: string; const ParamProc: TProc<TRemixParams>;
      const CallBacks: TFunc<TAsynVideoJob>);

    /// <summary>
    /// Asynchronously deletes a video generation job from the server and triggers callback events during the operation.
    /// </summary>
    /// <param name="VideoId">
    /// The unique identifier of the video job to delete.
    /// </param>
    /// <param name="CallBacks">
    /// A factory function returning a configured <c>TAsynVideoJob</c> instance,
    /// defining asynchronous lifecycle handlers such as <c>OnStart</c>, <c>OnSuccess</c>, and <c>OnError</c>.
    /// </param>
    /// <remarks>
    /// <para>
    /// • Sends an asynchronous <c>DELETE</c> request to the <c>/videos/{video_id}</c> endpoint.
    /// The <paramref name="CallBacks"/> argument provides an instance of <c>TAsynVideoJob</c>
    /// used to manage event-driven notifications for the asynchronous process.
    /// </para>
    /// <para>
    /// • The <c>OnStart</c> event is triggered when the delete request begins.
    /// The <c>OnSuccess</c> event is invoked upon successful completion and returns a <c>TVideoJob</c>
    /// representing the deleted job record as confirmed by the API.
    /// The <c>OnError</c> event is fired if an error or exception occurs during the delete operation.
    /// </para>
    /// <para>
    /// • This method executes on a background thread, making it suitable for GUI or service contexts
    /// where non-blocking behavior is required.
    /// It ensures that the main thread remains responsive while the delete operation completes asynchronously.
    /// </para>
    /// <para>
    /// • The resulting <c>TVideoJob</c> object contains metadata of the deleted video, such as its <c>Id</c>,
    /// <c>Status</c>, and timestamps (<c>CreatedAt</c>, <c>CompletedAt</c>).
    /// The raw API payload is preserved in the <c>JSONResponse</c> property inherited from <c>TJSONFingerprint</c>.
    /// </para>
    /// <para>
    /// • Use this method when performing deletions asynchronously with event-based progress reporting
    /// and error handling rather than blocking the caller until the request finishes.
    /// </para>
    /// </remarks>
    procedure AsynDelete(const VideoId: string;
      const CallBacks: TFunc<TAsynVideoJob>);

    /// <summary>
    /// Asynchronously retrieves a paginated list of video generation jobs and triggers callback events during the operation.
    /// </summary>
    /// <param name="ParamProc">
    /// A configuration procedure used to define query parameters through a <c>TUrlVideoParams</c> instance.
    /// Common parameters include pagination controls such as <c>After</c>, <c>Limit</c>, and sort order <c>Order</c>.
    /// </param>
    /// <param name="CallBacks">
    /// A factory function returning a configured <c>TAsynVideoJobList</c> instance,
    /// defining asynchronous lifecycle handlers such as <c>OnStart</c>, <c>OnSuccess</c>, and <c>OnError</c>.
    /// </param>
    /// <remarks>
    /// <para>
    /// • Sends an asynchronous <c>GET</c> request to the <c>/videos</c> endpoint.
    /// The <paramref name="ParamProc"/> callback allows the caller to define URL parameters
    /// controlling pagination and ordering, while <paramref name="CallBacks"/> provides
    /// an instance of <c>TAsynVideoJobList</c> for managing asynchronous events.
    /// </para>
    /// <para>
    /// • The <c>OnStart</c> event is triggered when the list retrieval begins.
    /// The <c>OnSuccess</c> event is invoked when the operation completes successfully,
    /// returning a <c>TVideoJobList</c> containing an array of <c>TVideoJob</c> records.
    /// The <c>OnError</c> event is fired if a network or API error occurs during the process.
    /// </para>
    /// <para>
    /// • The operation executes asynchronously on a background thread, ensuring that
    /// user interfaces or other main-thread logic remain responsive while the list request completes.
    /// </para>
    /// <para>
    /// • The resulting <c>TVideoJobList</c> object provides structured pagination metadata
    /// such as <c>FirstId</c>, <c>LastId</c>, <c>HasMore</c>, and an array of <c>TVideoJob</c>
    /// instances representing individual video generation jobs.
    /// </para>
    /// <para>
    /// • The raw API response is preserved in the <c>JSONResponse</c> property inherited
    /// from <c>TJSONFingerprint</c> for inspection or debugging.
    /// </para>
    /// <para>
    /// • Use this method to asynchronously enumerate video jobs with event-driven progress and error handling,
    /// avoiding blocking calls when working within interactive or multithreaded environments.
    /// </para>
    /// </remarks>
    procedure AsynList(const ParamProc: TProc<TUrlVideoParams>;
      const CallBacks: TFunc<TAsynVideoJobList>);

    /// <summary>
    /// Asynchronously retrieves detailed information about a specific video generation job and triggers callback events during the operation.
    /// </summary>
    /// <param name="VideoId">
    /// The unique identifier of the video job to retrieve.
    /// </param>
    /// <param name="CallBacks">
    /// A factory function returning a configured <c>TAsynVideoJob</c> instance,
    /// defining asynchronous lifecycle handlers such as <c>OnStart</c>, <c>OnSuccess</c>, and <c>OnError</c>.
    /// </param>
    /// <remarks>
    /// <para>
    /// • Sends an asynchronous <c>GET</c> request to the <c>/videos/{video_id}</c> endpoint.
    /// The <paramref name="CallBacks"/> argument provides a <c>TAsynVideoJob</c> object
    /// responsible for handling non-blocking lifecycle notifications.
    /// </para>
    /// <para>
    /// • The <c>OnStart</c> event is triggered when the request begins.
    /// The <c>OnSuccess</c> event is invoked when the operation completes successfully,
    /// delivering a <c>TVideoJob</c> instance with full job details such as <c>Id</c>, <c>Status</c>,
    /// <c>Progress</c>, <c>CreatedAt</c>, <c>CompletedAt</c>, and other metadata.
    /// The <c>OnError</c> event is fired if an exception or HTTP error occurs during retrieval.
    /// </para>
    /// <para>
    /// • This method executes asynchronously on a background thread, ensuring that the main application
    /// thread (for instance, in GUI environments) remains responsive during potentially long-running operations.
    /// </para>
    /// <para>
    /// • The <c>TVideoJob</c> object returned in <c>OnSuccess</c> preserves the full API payload in its
    /// <c>JSONResponse</c> property, inherited from <c>TJSONFingerprint</c>, allowing transparent access
    /// to raw JSON data for logging or debugging.
    /// </para>
    /// <para>
    /// • Use this method to asynchronously query the current state or metadata of a specific video job
    /// with event-driven feedback and error propagation, rather than blocking the caller.
    /// </para>
    /// </remarks>
    procedure AsynRetrieve(const VideoId: string;
      const CallBacks: TFunc<TAsynVideoJob>);

    /// <summary>
    /// Asynchronously downloads the binary content of a completed video job and triggers callback events during the operation.
    /// </summary>
    /// <param name="VideoId">
    /// The unique identifier of the completed video job to download.
    /// </param>
    /// <param name="CallBacks">
    /// A factory function returning a configured <c>TAsynVideoDownloaded</c> instance,
    /// defining asynchronous lifecycle handlers such as <c>OnStart</c>, <c>OnSuccess</c>, and <c>OnError</c>.
    /// </param>
    /// <remarks>
    /// <para>
    /// • Sends an asynchronous <c>GET</c> request to the <c>/videos/{video_id}/content</c> endpoint
    /// to fetch the final rendered video binary. The request automatically follows signed redirects
    /// to retrieve the actual MP4 file from OpenAI’s storage layer.
    /// </para>
    /// <para>
    /// • The <c>OnStart</c> event is triggered when the download begins.
    /// The <c>OnSuccess</c> event is fired upon successful completion and delivers a <c>TVideoDownloaded</c>
    /// instance containing the video data as a Base64-encoded string via its <c>Data</c> property.
    /// The <c>OnError</c> event is triggered if a connection, authorization, or API error occurs during the download.
    /// </para>
    /// <para>
    /// • The operation runs asynchronously on a background thread, keeping the main thread responsive.
    /// It is suitable for use in GUI, service, or multithreaded contexts where blocking the main process is undesirable.
    /// </para>
    /// <para>
    /// • Once the <c>OnSuccess</c> event is triggered, the caller can use the
    /// <see cref="TVideoDownloaded.SaveToFile"/> method to decode and save the retrieved video to disk.
    /// </para>
    /// <para>
    /// • The resulting <c>TVideoDownloaded</c> object encapsulates the Base64-encoded content of the binary file.
    /// It is a lightweight transport container used to facilitate non-blocking media transfers.
    /// </para>
    /// <para>
    /// • Use this method when you need to retrieve and store generated videos asynchronously,
    /// with full control over download progress, completion, and error handling through callback events.
    /// </para>
    /// </remarks>
    procedure AsynDownload(const VideoId: string;
      const CallBacks: TFunc<TAsynVideoDownloaded>);
  end;

implementation

{ TVideoParams }

constructor TVideoParams.Create;
begin
  inherited Create(true);
end;

function TVideoParams.InputReference(const Value: string): TVideoParams;
begin
  AddFile('input_reference', Value);
  Result := Self;
end;

function TVideoParams.InputReference(const Value: TStream;
  const FilePath: string): TVideoParams;
begin
  {$IF RTLVersion > 35.0}
    AddStream('mask', Value, True, FilePath);
  {$ELSE}
    AddStream('mask', Value, FilePath);
  {$ENDIF}
  Result := Self;
end;

function TVideoParams.Model(const Value: string): TVideoParams;
begin
  AddField('model', Value);
  Result := Self;
end;

function TVideoParams.Prompt(const Value: string): TVideoParams;
begin
  AddField('prompt', Value);
  Result := Self;
end;

function TVideoParams.Seconds(const Value: string): TVideoParams;
begin
  AddField('seconds', Value);
  Result := Self;
end;

function TVideoParams.Size(const Value: string): TVideoParams;
begin
  AddField('size', Value);
  Result := Self;
end;

{ TVideoJob }

destructor TVideoJob.Destroy;
begin
  if Assigned(FError) then
    FError.Free;
  inherited;
end;

{ TVideoRoute }

function TVideoRoute.AsyncAwaitCreate(const ParamProc: TProc<TVideoParams>;
  const CallBacks: TFunc<TPromiseVideoJob>): TPromise<TVideoJob>;
begin
  Result := TAsyncAwaitHelper.WrapAsyncAwait<TVideoJob>(
    procedure(const CallBackParams: TFunc<TAsynVideoJob>)
    begin
      Self.AsynCreate(ParamProc, CallBackParams);
    end,
    CallBacks);
end;

function TVideoRoute.AsyncAwaitDelete(const VideoId: string;
  const CallBacks: TFunc<TPromiseVideoJob>): TPromise<TVideoJob>;
begin
  Result := TAsyncAwaitHelper.WrapAsyncAwait<TVideoJob>(
    procedure(const CallBackParams: TFunc<TAsynVideoJob>)
    begin
      Self.AsynDelete(VideoId, CallBackParams);
    end,
    CallBacks);
end;

function TVideoRoute.AsyncAwaitDownload(const VideoId: string;
  const CallBacks: TFunc<TPromiseVideoDownloaded>): TPromise<TVideoDownloaded>;
begin
  Result := TAsyncAwaitHelper.WrapAsyncAwait<TVideoDownloaded>(
    procedure(const CallBackParams: TFunc<TAsynVideoDownloaded>)
    begin
      Self.AsynDownload(VideoId, CallBackParams);
    end,
    CallBacks);
end;

function TVideoRoute.AsyncAwaitList(const ParamProc: TProc<TUrlVideoParams>;
  const CallBacks: TFunc<TPromiseVideoJobList>): TPromise<TVideoJobList>;
begin
  Result := TAsyncAwaitHelper.WrapAsyncAwait<TVideoJobList>(
    procedure(const CallBackParams: TFunc<TAsynVideoJobList>)
    begin
      Self.AsynList(ParamProc, CallBackParams);
    end,
    CallBacks);
end;

function TVideoRoute.AsyncAwaitRemix(const VideoId: string;
  const ParamProc: TProc<TRemixParams>;
  const CallBacks: TFunc<TPromiseVideoJob>): TPromise<TVideoJob>;
begin
  Result := TAsyncAwaitHelper.WrapAsyncAwait<TVideoJob>(
    procedure(const CallBackParams: TFunc<TAsynVideoJob>)
    begin
      Self.AsynRemix(VideoId, ParamProc, CallBackParams);
    end,
    CallBacks);
end;

function TVideoRoute.AsyncAwaitRetrieve(const VideoId: string;
  const CallBacks: TFunc<TPromiseVideoJob>): TPromise<TVideoJob>;
begin
  Result := TAsyncAwaitHelper.WrapAsyncAwait<TVideoJob>(
    procedure(const CallBackParams: TFunc<TAsynVideoJob>)
    begin
      Self.AsynRetrieve(VideoId, CallBackParams);
    end,
    CallBacks);
end;

procedure TVideoRoute.AsynCreate(const ParamProc: TProc<TVideoParams>;
  const CallBacks: TFunc<TAsynVideoJob>);
begin
  with TAsynCallBackExec<TAsynVideoJob, TVideoJob>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TVideoJob
      begin
        Result := Self.Create(ParamProc);
      end);
  finally
    Free;
  end;
end;

procedure TVideoRoute.AsynDelete(const VideoId: string;
  const CallBacks: TFunc<TAsynVideoJob>);
begin
  with TAsynCallBackExec<TAsynVideoJob, TVideoJob>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TVideoJob
      begin
        Result := Self.Delete(VideoId);
      end);
  finally
    Free;
  end;
end;

procedure TVideoRoute.AsynDownload(const VideoId: string;
  const CallBacks: TFunc<TAsynVideoDownloaded>);
begin
  with TAsynCallBackExec<TAsynVideoDownloaded, TVideoDownloaded>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TVideoDownloaded
      begin
        Result := Self.Download(VideoId);
      end);
  finally
    Free;
  end;
end;

procedure TVideoRoute.AsynList(const ParamProc: TProc<TUrlVideoParams>;
  const CallBacks: TFunc<TAsynVideoJobList>);
begin
  with TAsynCallBackExec<TAsynVideoJobList, TVideoJobList>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TVideoJobList
      begin
        Result := Self.List(ParamProc);
      end);
  finally
    Free;
  end;
end;

procedure TVideoRoute.AsynRemix(const VideoId: string;
  const ParamProc: TProc<TRemixParams>; const CallBacks: TFunc<TAsynVideoJob>);
begin
  with TAsynCallBackExec<TAsynVideoJob, TVideoJob>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TVideoJob
      begin
        Result := Self.Remix(VideoId, ParamProc);
      end);
  finally
    Free;
  end;
end;

procedure TVideoRoute.AsynRetrieve(const VideoId: string;
  const CallBacks: TFunc<TAsynVideoJob>);
begin
  with TAsynCallBackExec<TAsynVideoJob, TVideoJob>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TVideoJob
      begin
        Result := Self.Retrieve(VideoId);
      end);
  finally
    Free;
  end;
end;

function TVideoRoute.Create(const ParamProc: TProc<TVideoParams>): TVideoJob;
begin
  Result := API.PostForm<TVideoJob, TVideoParams>('videos', ParamProc);
end;

function TVideoRoute.Delete(const VideoId: string): TVideoJob;
begin
  Result := API.Delete<TVideoJob>('videos/' + VideoId);
end;

function TVideoRoute.Download(const VideoId: string): TVideoDownloaded;
var
  Bytes: TBytes;
begin
  try
    Result := TVideoDownloaded.Create;
    Bytes := API.GetBinary('videos/' + VideoId + '/content');
    Result.Data := TNetEncoding.Base64.EncodeBytesToString(Bytes);
  except
    FreeAndNil(Result);
    raise;
  end;
end;

function TVideoRoute.List(const ParamProc: TProc<TUrlVideoParams>): TVideoJobList;
begin
  Result := API.Get<TVideoJobList, TUrlVideoParams>('videos', ParamProc);
end;

function TVideoRoute.Remix(const VideoId: string;
  const ParamProc: TProc<TRemixParams>): TVideoJob;
begin
  Result := API.Post<TVideoJob, TRemixParams>('videos/' + VideoId + '/remix', ParamProc);
end;

function TVideoRoute.Retrieve(const VideoId: string): TVideoJob;
begin
  Result := API.Get<TVideoJob>('videos/' + VideoId);
end;

{ TUrlVideoParams }

function TUrlVideoParams.After(const Value: string): TUrlVideoParams;
begin
  Result := TUrlVideoParams(Add('after', Value));
end;

function TUrlVideoParams.Limit(const Value: integer): TUrlVideoParams;
begin
  Result := TUrlVideoParams(Add('limit', Value));
end;

function TUrlVideoParams.Order(const Value: string): TUrlVideoParams;
begin
  Result := TUrlVideoParams(Add('order', Value));
end;

{ TVideoJobList }

destructor TVideoJobList.Destroy;
begin
  for var Item in FData do
    Item.Free;
  inherited;
end;

{ TRemixParams }

function TRemixParams.Prompt(const Value: string): TRemixParams;
begin
  Result := TRemixParams(Add('prompt', Value));
end;

{ TVideoDownloaded }

procedure TVideoDownloaded.SaveToFile(const FileName: string);
var
  Bytes: TBytes;
  FS: TFileStream;
begin
  if FData.IsEmpty then
    raise Exception.Create('No data to save');
  Bytes := TNetEncoding.Base64.DecodeStringToBytes(FData);
  FS := TFileStream.Create(FileName, fmCreate or fmShareDenyWrite);
  try
    FS.WriteBuffer(Bytes, Length(Bytes));
  finally
    FS.Free;
  end;
end;

end.
