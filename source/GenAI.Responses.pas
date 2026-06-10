unit GenAI.Responses;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGenAI
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.SysUtils, System.Classes, System.Threading,
  GenAI.API.Params, GenAI.API, GenAI.Types,
  GenAI.Async.Params, GenAI.Async.Support, GenAI.Async.Promise, GenAI.Chat.Parallel,
  GenAI.Responses.InputParams, GenAI.Responses.InputItemList, GenAI.Responses.OutputParams,
  GenAI.Responses.Internal, GenAI.Responses.StreamCallbacks, GenAI.Responses.StreamEngine;

type
  TResponsesAbstractSupport = class(TGenAIRoute)
  protected
    function Create(ParamProc: TProc<TResponsesParams>): TResponse; virtual; abstract;
    function Compact(ParamProc: TProc<TResponseCompactParams>): TResponseCompaction; virtual; abstract;
    function CreateStream(ParamProc: TProc<TResponsesParams>; Event: TResponseEvent;
      const StreamEvents: IResponsesEventEngineManager = nil): Boolean; virtual; abstract;
    function Retrieve(const ResponseId: string): TResponse; overload; virtual; abstract;
    function Retrieve(const ResponseId: string; const ParamProc: TProc<TURLIncludeParams>): TResponse; overload; virtual; abstract;
    function Delete(const ResponseId: string): TResponseDelete; virtual; abstract;
    function List(const ResponseId: string): TResponses; overload; virtual; abstract;
    function List(const ResponseId: string; const ParamProc: TProc<TUrlResponseListParams>): TResponses; overload; virtual; abstract;
    function Cancel(const ResponseId: string): TResponse; virtual; abstract;
    procedure CreateParallel(ParamProc: TProc<TBundleParams>; const CallBacks: TFunc<TAsynBundleList>); virtual; abstract;
  end;

  TResponsesAsynchronousSupport = class(TResponsesAbstractSupport)
  public
    procedure AsynCreate(const ParamProc: TProc<TResponsesParams>;
      const CallBacks: TFunc<TAsynResponse>);
    procedure AsynCompact(const ParamProc: TProc<TResponseCompactParams>;
      const CallBacks: TFunc<TAsynResponseCompaction>);
    procedure AsynCreateStream(const ParamProc: TProc<TResponsesParams>;
      const CallBacks: TFunc<TAsynResponseStream>); overload;
    procedure AsynCreateStream(const ParamProc: TProc<TResponsesParams>;
      const CallBacks: TFunc<TAsynResponseStream>;
      const StreamEvents: IResponsesEventEngineManager); overload;
    procedure AsynRetrieve(const ResponseId: string;
      const CallBacks: TFunc<TAsynResponse>); overload;
    procedure AsynRetrieve(const ResponseId: string;
      const ParamProc: TProc<TURLIncludeParams>;
      const CallBacks: TFunc<TAsynResponse>); overload;
    procedure AsynDelete(const ResponseId: string;
      const CallBacks: TFunc<TAsynResponseDelete>);
    procedure AsynList(const ResponseId: string;
      const CallBacks: TFunc<TAsynResponses>); overload;
    procedure AsynList(const ResponseId: string;
      const ParamProc: TProc<TUrlResponseListParams>;
      const CallBacks: TFunc<TAsynResponses>); overload;
    procedure AsynCancel(const ResponseId: string;
      const CallBacks: TFunc<TAsynResponse>);
  end;

  TResponsesRoute = class(TResponsesAsynchronousSupport)
  public
    /// <summary>
    /// Asynchronously creates an AI response and returns a promise that resolves
    /// with the resulting output as a string upon successful completion, or rejects
    /// with an exception if the operation fails.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure that sets up the request parameters using a <c>TResponsesParams</c> instance.
    /// Use this to specify model, input, and other request options.
    /// </param>
    /// <param name="CallBacks">
    /// A function returning a <c>TPromiseResponse</c> instance, allowing you to
    /// define handlers for start, success, and error events. The <c>OnSuccess</c>
    /// handler should return a string which becomes the resolved value of the promise,
    /// and the <c>OnError</c> handler can provide or override error information.
    /// </param>
    /// <returns>
    /// A <c>TStringPromise</c> representing the asynchronous operation. The promise resolves
    /// to a string produced by your <c>OnSuccess</c> handler or rejects with an exception
    /// if an error occurs during the request.
    /// </returns>
    /// <remarks>
    /// This method initiates an asynchronous "responses" generation using the v1/responses
    /// endpoint. Use this approach when you want to chain further operations or
    /// handle the AI response in a modern, promise-based pattern. The operation executes the
    /// underlying network request without blocking the calling thread.
    /// </remarks>
    function AsyncAwaitCreate(const ParamProc: TProc<TResponsesParams>;
      const CallBacks: TFunc<TPromiseResponse> = nil): TPromise<TResponse>;

    /// <summary>
    /// Asynchronously compacts a Responses API context.
    /// </summary>
    function AsyncAwaitCompact(const ParamProc: TProc<TResponseCompactParams>;
      const CallBacks: TFunc<TPromiseResponseCompaction> = nil): TPromise<TResponseCompaction>;

    /// <summary>
    /// Asynchronously creates a streaming AI response using the “responses” endpoint and returns a promise
    /// that resolves with the completed stream event or rejects on error.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure that configures the streaming request parameters (model, input, and stream flag)
    /// via a <see cref="TResponsesParams"/> instance.
    /// </param>
    /// <param name="CallBacks">
    /// <para>- Returns a <see cref="TPromiseResponseStream"/> to handle lifecycle events.</para>
    /// <para>- OnStart is invoked when the stream is initiated.</para>
    /// <para>- OnProgress is invoked for each incoming <see cref="TResponseStream"/> chunk.</para>
    /// <para>- OnError is invoked if an error occurs during streaming.</para>
    /// <para>- OnDoCancel and OnCancellation manage cancellation logic.</para>
    /// </param>
    /// <returns>
    /// A <see cref="TPromise{TResponseStream}"/> that resolves with the final <see cref="TResponseStream"/>
    /// event when output_item_done is received, or rejects with an exception if the stream errors
    /// or is aborted.
    /// </returns>
    /// <remarks>
    /// This method wraps the non-blocking streaming endpoint in a promise-based pattern, allowing you to
    /// chain further operations and centralize error handling. Intermediate data arrives via your
    /// OnProgress callbacks, and the promise itself settles only once the stream completes or fails.
    /// </remarks>
    function AsyncAwaitCreateStream(const ParamProc: TProc<TResponsesParams>;
      const CallBacks: TFunc<TPromiseResponseStream>): TPromise<TResponseStream>; overload;

    /// <summary>
    /// Asynchronously creates a streaming AI response and resolves with the aggregated
    /// <see cref="TResponsesEventData"/> buffer once the stream completes.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure that configures the streaming request parameters via a <see cref="TResponsesParams"/> instance.
    /// </param>
    /// <param name="Callbacks">
    /// A function returning a <see cref="TPromiseResponseStream"/> used to observe the stream lifecycle
    /// (start, progress, error, cancellation) while the aggregated result is returned through the promise.
    /// </param>
    /// <param name="StreamEvents">
    /// The event engine manager that aggregates and dispatches the fine-grained streaming events to the
    /// per-event callbacks registered on its dispatcher.
    /// </param>
    /// <returns>
    /// A <see cref="TPromise{TResponsesEventData}"/> that resolves with the aggregated buffer when the
    /// stream completes, or rejects on error or cancellation.
    /// </returns>
    /// <remarks>
    /// This is the primary integration entry point: it mirrors the Anthropic
    /// <c>AsyncAwaitCreateStream(ParamProc, Callbacks, StreamEvents)</c> method. The buffer is aggregated
    /// in <c>OnProgress</c> and resolved in <c>OnSuccess</c>, while <c>StreamEvents</c> drives the granular
    /// per-event callbacks in the same order as the stream.
    /// </remarks>
    function AsyncAwaitCreateStream(const ParamProc: TProc<TResponsesParams>;
      const Callbacks: TFunc<TPromiseResponseStream>;
      const StreamEvents: IResponsesEventEngineManager): TPromise<TResponsesEventData>; overload;

    /// <summary>
    /// Asynchronously creates a streaming AI response driven by an event engine manager and resolves with
    /// the aggregated <see cref="TResponsesEventData"/> buffer once the stream completes.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure that configures the streaming request parameters via a <see cref="TResponsesParams"/> instance.
    /// </param>
    /// <param name="StreamEvents">
    /// The event engine manager that aggregates and dispatches the fine-grained streaming events to the
    /// per-event callbacks registered on its dispatcher.
    /// </param>
    /// <returns>
    /// A <see cref="TPromise{TResponsesEventData}"/> that resolves with the aggregated buffer when the
    /// stream completes, or rejects on error or cancellation.
    /// </returns>
    function AsyncAwaitCreateStream(const ParamProc: TProc<TResponsesParams>;
      const StreamEvents: IResponsesEventEngineManager): TPromise<TResponsesEventData>; overload;

    /// <summary>
    /// Asynchronously creates multiple AI responses in parallel, returning a promise that resolves when all responses are completed.
    /// </summary>
    /// <param name="ParamProc">
    /// <para>
    /// A procedure that configures the bundle parameters (such as model, prompts, reasoning effort, and any system instructions)
    /// for the parallel requests. Each prompt in the bundle will be sent as an individual AI request.
    /// </para>
    /// </param>
    /// <param name="CallBacks">
    /// <para>
    /// A function that returns a <see cref="TPromiseBundleList"/> instance to handle lifecycle events:
    /// </para>
    /// <para>
    /// - OnStart: invoked when the parallel operation begins.
    /// </para>
    /// <para>
    /// - OnSuccess: invoked when all individual AI responses in the bundle have completed successfully. The consolidated <c>TBundleList</c> is passed to this callback.
    /// </para>
    /// <para>
    /// - OnError: invoked if any individual task fails. Errors in one task do not prevent the remaining tasks from running to completion.
    /// </para>
    /// </param>
    /// <returns>
    /// <para>
    /// A <see cref="TStringPromise"/> that resolves to the string value returned by the OnSuccess callback when all parallel requests finish successfully,
    /// or rejects with an exception if an error occurs. The resolved string is whatever the OnSuccess handler returns.
    /// </para>
    /// </returns>
    /// <remarks>
    /// <para>
    /// This method takes a bundle of prompts and dispatches them concurrently in separate threads. Each prompt is processed using the same model
    /// and reasoning configuration defined in ParamProc. Results from each AI response are collected into a <c>TBundleList</c>,
    /// preserving the order of the prompts.
    /// </para>
    /// <para>
    /// Although individual failures trigger OnError, the other tasks will continue running. Use this method to efficiently generate
    /// multiple AI responses at once without blocking the calling thread.
    /// </para>
    /// </remarks>
    function AsyncAwaitCreateParallel(const ParamProc: TProc<TBundleParams>;
      const CallBacks: TFunc<TPromiseBundleList> = nil): TPromise<TBundleList>;

    /// <summary>
    /// Asynchronously retrieves a single AI response by its unique identifier.
    /// </summary>
    /// <param name="ResponseId">
    /// <para>
    /// The unique identifier of the AI response to retrieve.
    /// </para>
    /// </param>
    /// <param name="CallBacks">
    /// <para>
    /// A function that returns a <see cref="TPromiseResponse"/> instance to handle lifecycle events:
    /// </para>
    /// <para>
    /// - OnStart: invoked when the retrieval request is initiated.
    /// </para>
    /// <para>
    /// - OnSuccess: invoked when the response has been successfully retrieved. The <c>TResponse</c> object is passed to this callback.
    /// </para>
    /// <para>
    /// - OnError: invoked if the retrieval fails. The provided error message can be used or modified before throwing.
    /// </para>
    /// </param>
    /// <returns>
    /// <para>
    /// A <see cref="TPromise&lt;TResponse&gt;"/> that resolves to the retrieved <c>TResponse</c> object when the operation completes,
    /// or rejects with an exception if an error occurs during retrieval.
    /// </para>
    /// </returns>
    /// <remarks>
    /// <para>
    /// This method issues a non-blocking request to fetch a previously generated AI response. Use it when you need to retrieve
    /// the response details (such as content, usage, or tool call results) after it has been created.
    /// </para>
    /// <para>
    /// The caller can attach handlers for OnStart, OnSuccess, and OnError to manage UI updates or error handling. Upon successful
    /// completion, the promise returns the deserialized <c>TResponse</c> instance for further processing.
    /// </para>
    /// </remarks>
    function AsyncAwaitRetrieve(const ResponseId: string;
      const CallBacks: TFunc<TPromiseResponse> = nil): TPromise<TResponse>; overload;

    /// <summary>
    /// Asynchronously retrieves a single AI response by its unique identifier, with optional URL parameters.
    /// </summary>
    /// <param name="ResponseId">
    /// <para>
    /// The unique identifier of the AI response to retrieve.
    /// </para>
    /// </param>
    /// <param name="ParamProc">
    /// <para>
    /// A procedure that configures additional URL parameters using a <c>TURLIncludeParams</c> instance.
    /// This allows inclusion of extra fields such as file search results or input image URLs in the retrieved response.
    /// </para>
    /// </param>
    /// <param name="CallBacks">
    /// <para>
    /// A function that returns a <see cref="TPromiseResponse"/> instance to handle lifecycle events:
    /// </para>
    /// <para>
    /// - OnStart: invoked when the retrieval request is initiated.
    /// </para>
    /// <para>
    /// - OnSuccess: invoked when the response has been successfully retrieved. The <c>TResponse</c> object is passed to this callback.
    /// </para>
    /// <para>
    /// - OnError: invoked if the retrieval fails. The provided error message can be used or modified before throwing.
    /// </para>
    /// </param>
    /// <returns>
    /// <para>
    /// A <see cref="TPromise&lt;TResponse&gt;"/> that resolves to the retrieved <c>TResponse</c> object when the operation completes,
    /// or rejects with an exception if an error occurs during retrieval.
    /// </para>
    /// </returns>
    /// <remarks>
    /// <para>
    /// This overload allows for specifying URL query parameters, such as <c>include</c> fields, when fetching a previously generated AI response.
    /// Use <paramref name="ParamProc"/> to indicate which additional parts of the response should be included in the result.
    /// </para>
    /// <para>
    /// Callers can attach handlers for OnStart, OnSuccess, and OnError to manage UI updates or error handling. Upon successful
    /// completion, the promise returns the deserialized <c>TResponse</c> instance containing all requested fields.
    /// </para>
    /// </remarks>
    function AsyncAwaitRetrieve(const ResponseId: string;
      const ParamProc: TProc<TURLIncludeParams>;
      const CallBacks: TFunc<TPromiseResponse> = nil): TPromise<TResponse>; overload;

    /// <summary>
    /// Asynchronously deletes a single AI response by its unique identifier.
    /// </summary>
    /// <param name="ResponseId">
    /// <para>
    /// The unique identifier of the AI response to delete.
    /// </para>
    /// </param>
    /// <param name="CallBacks">
    /// <para>
    /// A function that returns a <see cref="TPromiseResponseDelete"/> instance to handle lifecycle events:
    /// </para>
    /// <para>
    /// - OnStart: invoked when the deletion request is initiated.
    /// </para>
    /// <para>
    /// - OnSuccess: invoked when the response has been successfully deleted. The <c>TResponseDelete</c> object is passed to this callback.
    /// </para>
    /// <para>
    /// - OnError: invoked if the deletion fails. The provided error message can be used or modified before rejecting.
    /// </para>
    /// </param>
    /// <returns>
    /// <para>
    /// A <see cref="TPromise&lt;TResponseDelete&gt;"/> that resolves to the deletion result (<c>TResponseDelete</c>) when the operation completes,
    /// or rejects with an exception if an error occurs during deletion.
    /// </para>
    /// </returns>
    /// <remarks>
    /// <para>
    /// This method issues a non-blocking request to delete a previously generated AI response. Use it when you need to
    /// remove the response from storage or API records.
    /// </para>
    /// <para>
    /// Callers can attach handlers for OnStart, OnSuccess, and OnError to perform UI updates or error handling. Upon successful
    /// completion, the promise returns a <c>TResponseDelete</c> instance indicating deletion status.
    /// </para>
    /// </remarks>
    function AsyncAwaitDelete(const ResponseId: string;
      const CallBacks: TFunc<TPromiseResponseDelete> = nil): TPromise<TResponseDelete>;

    /// <summary>
    /// Asynchronously lists the input items used to generate a specific AI response.
    /// </summary>
    /// <param name="ResponseId">
    /// <para>
    /// The unique identifier of the AI response whose input items are to be listed.
    /// </para>
    /// </param>
    /// <param name="CallBacks">
    /// <para>
    /// A function that returns a <see cref="TPromiseResponses"/> instance to handle lifecycle events:
    /// </para>
    /// <para>
    /// - OnStart: invoked when the listing request is initiated.
    /// </para>
    /// <para>
    /// - OnSuccess: invoked when the list of input items has been successfully retrieved. The <c>TResponses</c> object is passed to this callback.
    /// </para>
    /// <para>
    /// - OnError: invoked if the retrieval fails. The provided error message can be used or modified before rejecting.
    /// </para>
    /// </param>
    /// <returns>
    /// <para>
    /// A <see cref="TPromise&lt;TResponses&gt;"/> that resolves to the <c>TResponses</c> object containing the input items when the operation completes,
    /// or rejects with an exception if an error occurs during retrieval.
    /// </para>
    /// </returns>
    /// <remarks>
    /// <para>
    /// This method issues a non-blocking request to fetch all input items associated with the given AI response.
    /// Use it when you need to inspect the prompts, files, or other data that were sent to generate the response.
    /// </para>
    /// <para>
    /// Callers can attach handlers for <c>OnStart</c>, <c>OnSuccess</c>, and <c>OnError</c> to perform UI updates or error handling.
    /// Upon successful completion, the promise returns a <c>TResponses</c> instance for further processing.
    /// </para>
    /// </remarks>
    function AsyncAwaitList(const ResponseId: string;
      const CallBacks: TFunc<TPromiseResponses> = nil): TPromise<TResponses>; overload;

    /// <summary>
    /// Asynchronously lists the input items used to generate a specific AI response, with optional URL parameters.
    /// </summary>
    /// <param name="ResponseId">
    /// <para>
    /// The unique identifier of the AI response whose input items are to be listed.
    /// </para>
    /// </param>
    /// <param name="ParamProc">
    /// <para>
    /// A procedure that configures additional URL parameters using a <c>TUrlResponseListParams</c> instance.
    /// This allows specifying pagination (such as <c>Limit</c>, <c>After</c>, <c>Before</c>) or inclusion filters for the listing.
    /// </para>
    /// </param>
    /// <param name="CallBacks">
    /// <para>
    /// A function that returns a <see cref="TPromiseResponses"/> instance to handle lifecycle events:
    /// </para>
    /// <para>
    /// - OnStart: invoked when the listing request is initiated.
    /// </para>
    /// <para>
    /// - OnSuccess: invoked when the list of input items has been successfully retrieved. The <c>TResponses</c> object is passed to this callback.
    /// </para>
    /// <para>
    /// - OnError: invoked if the retrieval fails. The provided error message can be used or modified before rejecting.
    /// </para>
    /// </param>
    /// <returns>
    /// <para>
    /// A <see cref="TPromise&lt;TResponses&gt;"/> that resolves to the <c>TResponses</c> object containing the input items when the operation completes,
    /// or rejects with an exception if an error occurs during retrieval.
    /// </para>
    /// </returns>
    /// <remarks>
    /// <para>
    /// This overload allows specifying URL query parameters—such as pagination limits and ordering—when fetching the input items
    /// associated with the given AI response. Use <paramref name="ParamProc"/> to indicate which subset of items or which additional fields to include.
    /// </para>
    /// <para>
    /// Callers can attach handlers for <c>OnStart</c>, <c>OnSuccess</c>, and <c>OnError</c> to perform UI updates or error handling.
    /// Upon successful completion, the promise returns a <c>TResponses</c> instance for further processing.
    /// </para>
    /// </remarks>
    function AsyncAwaitList(const ResponseId: string;
      const ParamProc: TProc<TUrlResponseListParams>;
      const CallBacks: TFunc<TPromiseResponses> = nil): TPromise<TResponses>; overload;

    /// <summary>
    /// Asynchronously requests the cancellation of a background AI response and returns a promise
    /// that resolves when the server acknowledges the cancellation.
    /// </summary>
    /// <param name="ResponseId">
    /// The unique identifier of the AI response to cancel. Only responses created with
    /// <c>background = true</c> are eligible for cancellation.
    /// </param>
    /// <param name="CallBacks">
    /// A function returning a <see cref="TPromiseResponse"/> to handle lifecycle events:
    /// <para>- <c>OnStart</c>: triggered before sending the request.</para>
    /// <para>- <c>OnSuccess</c>: triggered when the server successfully processes the cancellation; receives the updated <c>TResponse</c>.</para>
    /// <para>- <c>OnError</c>: triggered if the cancellation request fails; can return a string to override the error message.</para>
    /// </param>
    /// <returns>
    /// A <see cref="TPromise{TResponse}"/> that resolves with the updated <c>TResponse</c> returned by the
    /// <c>/v1/responses/{response_id}/cancel</c> endpoint, or rejects with an exception if an error occurs.
    /// </returns>
    /// <remarks>
    /// This method sends a non-blocking cancellation request to the <c>responses/{id}/cancel</c> endpoint.
    /// If the response has already completed or is not eligible for cancellation, the promise will be rejected
    /// with the server's error message.
    /// </remarks>
    function AsyncAwaitCancel(const ResponseId: string;
      const CallBacks: TFunc<TPromiseResponse> = nil): TPromise<TResponse>;

    /// <summary>
    /// Synchronously creates a new AI response.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure to configure the request parameters using a TResponsesParams instance.
    /// </param>
    /// <returns>
    /// A TResponse object representing the newly created AI response.
    /// </returns>
    /// <remarks>
    /// Sends a blocking request to create an AI response and returns the result.
    ///
    /// <code>
    /// var
    ///   Response: TResponse;
    /// begin
    ///   Response := Client.Responses.Create(
    ///     procedure (Params: TResponsesParams)
    ///     begin
    ///       Params.Model('gpt-4.1-mini');
    ///       Params.Input('What is the difference between a mathematician and a physicist?');
    ///     end);
    ///   try
    ///     // Process the response
    ///   finally
    ///     Response.Free;
    ///   end;
    /// end;
    /// </code>
    /// </remarks>
    function Create(ParamProc: TProc<TResponsesParams>): TResponse; override;

    /// <summary>
    /// Compacts a Responses API context and returns the opaque items to replay.
    /// </summary>
    function Compact(ParamProc: TProc<TResponseCompactParams>): TResponseCompaction; override;

    /// <summary>
    /// Synchronously creates a streaming AI response.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure used to configure the streaming response parameters via a TResponsesParams instance.
    /// </param>
    /// <param name="Event">
    /// A callback (of type TResponseEvent) that is invoked as streaming data is received and when the stream completes.
    /// </param>
    /// <returns>
    /// True if the streaming response request was successfully initiated; otherwise, False.
    /// </returns>
    /// <remarks>
    /// This method sends a request to begin a streaming AI response and blocks until the initial response is accepted.
    /// Use it when you require immediate confirmation that the stream has been started. Stream data is handled via the specified callback.
    ///
    /// <code>
    /// var
    ///   StreamStarted: Boolean;
    /// begin
    ///   StreamStarted := Client.Responses.CreateStream(
    ///     procedure (Params: TResponsesParams)
    ///     begin
    ///       Params.Model('gpt-4.1-mini');
    ///       Params.Input('What is the difference between a mathematician and a physicist?');
    ///       Params.Stream;
    ///     end,
    ///     procedure (var Chat: TResponseStream; IsDone: Boolean; var Cancel: Boolean)
    ///     begin
    ///       if not IsDone then
    ///         // Process the intermediate streaming data
    ///       else
    ///         // Handle the completion of the stream
    ///     end);
    /// end;
    /// </code>
    /// </remarks>
    function CreateStream(ParamProc: TProc<TResponsesParams>; Event: TResponseEvent;
      const StreamEvents: IResponsesEventEngineManager = nil): Boolean; override;

    /// <summary>
    /// Synchronously retrieves an AI response by its ID.
    /// </summary>
    /// <param name="ResponseId">
    /// The unique identifier of the response to retrieve.
    /// </param>
    /// <returns>
    /// A TResponse object with the details of the requested AI response.
    /// </returns>
    /// <remarks>
    /// Fetches the specified response in a blocking manner.
    ///
    /// <code>
    /// var
    ///   Response: TResponse;
    /// begin
    ///   Response := Client.Responses.Retrieve('response_id_here');
    ///   try
    ///     // Work with the response data
    ///   finally
    ///     Response.Free;
    ///   end;
    /// end;
    /// </code>
    /// </remarks>
    function Retrieve(const ResponseId: string): TResponse; overload; override;

    /// <summary>
    /// Synchronously retrieves an AI response by its ID with additional URL parameters.
    /// </summary>
    /// <param name="ResponseId">
    /// The unique identifier of the response to retrieve.
    /// </param>
    /// <param name="ParamProc">
    /// A procedure to configure additional URL parameters using a TURLIncludeParams instance.
    /// </param>
    /// <returns>
    /// A TResponse object with the details of the requested AI response.
    /// </returns>
    /// <remarks>
    /// Retrieves the specified response with extra configuration in a blocking manner.
    ///
    /// <code>
    /// var
    ///   Response: TResponse;
    /// begin
    ///   Response := Client.Responses.Retrieve('response_id_here',
    ///     procedure (Params: TURLIncludeParams)
    ///     begin
    ///       Params.Include(['file_search_result', 'input_image_url']);
    ///     end);
    ///   try
    ///     // Process the response
    ///   finally
    ///     Response.Free;
    ///   end;
    /// end;
    /// </code>
    /// </remarks>
    function Retrieve(const ResponseId: string;
      const ParamProc: TProc<TURLIncludeParams>): TResponse; overload; override;

    /// <summary>
    /// Synchronously deletes an AI response by its ID.
    /// </summary>
    /// <param name="ResponseId">
    /// The unique identifier of the response to delete.
    /// </param>
    /// <returns>
    /// A TResponseDelete object indicating the result of the deletion.
    /// </returns>
    /// <remarks>
    /// Sends a blocking deletion request for the specified response.
    ///
    /// <code>
    /// var
    ///   DeleteResult: TResponseDelete;
    /// begin
    ///   DeleteResult := Client.Responses.Delete('response_id_here');
    ///   try
    ///     // Verify deletion status
    ///   finally
    ///     DeleteResult.Free;
    ///   end;
    /// end;
    /// </code>
    /// </remarks>
    function Delete(const ResponseId: string): TResponseDelete; override;

    /// <summary>
    /// Synchronously lists input items used to generate a specific AI response.
    /// </summary>
    /// <param name="ResponseId">
    /// The unique identifier of the AI response.
    /// </param>
    /// <returns>
    /// A TResponses object containing the list of input items.
    /// </returns>
    /// <remarks>
    /// Retrieves the list of input items in a blocking manner.
    ///
    /// <code>
    /// var
    ///   Responses: TResponses;
    /// begin
    ///   Responses := Client.Responses.List('response_id_here');
    ///   try
    ///     // Process the list of input items
    ///   finally
    ///     Responses.Free;
    ///   end;
    /// end;
    /// </code>
    /// </remarks>
    function List(const ResponseId: string): TResponses; overload; override;

    /// <summary>
    /// Synchronously lists input items used to generate a specific AI response with additional URL parameters.
    /// </summary>
    /// <param name="ResponseId">
    /// The unique identifier of the AI response.
    /// </param>
    /// <param name="ParamProc">
    /// A procedure to configure additional URL parameters using a TUrlResponseListParams instance.
    /// </param>
    /// <returns>
    /// A TResponses object containing the list of input items.
    /// </returns>
    /// <remarks>
    /// Retrieves the list of input items with extra configuration in a blocking manner.
    ///
    /// <code>
    /// var
    ///   Responses: TResponses;
    /// begin
    ///   Responses := Client.Responses.List('response_id_here',
    ///     procedure (Params: TUrlResponseListParams)
    ///     begin
    ///       Params.Limit(50);
    ///     end);
    ///   try
    ///     // Process the list of input items
    ///   finally
    ///     Responses.Free;
    ///   end;
    /// end;
    /// </code>
    /// </remarks>
    function List(const ResponseId: string;
      const ParamProc: TProc<TUrlResponseListParams>): TResponses; overload; override;

    /// <summary>
    /// Synchronously requests the cancellation of a background AI response and returns the updated response object.
    /// </summary>
    /// <param name="ResponseId">
    /// The unique identifier of the AI response to cancel. Only responses created with
    /// <c>background = true</c> are eligible for cancellation.
    /// </param>
    /// <returns>
    /// A <see cref="TResponse"/> instance containing the server’s acknowledgement and the updated state
    /// of the cancelled response.
    /// </returns>
    /// <remarks>
    /// This method issues a blocking HTTP POST request to the <c>/v1/responses/{response_id}/cancel</c> endpoint.
    /// If the response has already completed or is not eligible for cancellation, an exception will be raised
    /// with the error returned by the server.
    /// </remarks>
    function Cancel(const ResponseId: string): TResponse; override;

    /// <summary>
    /// Initiates parallel processing of "responses" prompts by creating multiple "responses"
    /// asynchronously, with results stored in a bundle and provided back to the callback function.
    /// This method allows for parallel processing of multiple prompts in an efficient manner,
    /// handling errors and successes for each chat completion.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure delegate that configures the parameters for the bundle. It is responsible
    /// for providing the necessary settings (such as model and reasoning effort) for the chat completions.
    /// </param>
    /// <param name="CallBacks">
    /// A function that returns an instance of TAsynBuffer, which manages the lifecycle of the
    /// asynchronous operation. The callbacks include handlers for start, error, and success events.
    /// </param>
    /// <remarks>
    /// The method allows for efficient parallel processing of multiple prompts by delegating
    /// individual tasks to separate threads. It handles the reasoning effort for specific models
    /// and ensures each task's result is properly bundled and communicated back to the caller.
    /// If an error occurs, the error handling callback will be triggered, and the rest of the tasks
    /// will continue processing. The success callback is triggered once all tasks are completed.
    /// </remarks>
    procedure CreateParallel(ParamProc: TProc<TBundleParams>; const CallBacks: TFunc<TAsynBundleList>); override;
  end;

implementation

uses
  System.StrUtils, GenAI.API.Streams, GenAI.API.SSEDecoder, GenAI.Consts;

{ TResponsesRoute }

function TResponsesRoute.AsyncAwaitCancel(const ResponseId: string;
  const CallBacks: TFunc<TPromiseResponse>): TPromise<TResponse>;
begin
  Result := TAsyncAwaitHelper.WrapAsyncAwait<TResponse>(
    procedure(const CallBackParams: TFunc<TAsynResponse>)
    begin
      ASynCancel(ResponseId, CallBackParams);
    end,
    CallBacks);
end;

function TResponsesRoute.AsyncAwaitCompact(
  const ParamProc: TProc<TResponseCompactParams>;
  const CallBacks: TFunc<TPromiseResponseCompaction>): TPromise<TResponseCompaction>;
begin
  Result := TAsyncAwaitHelper.WrapAsyncAwait<TResponseCompaction>(
    procedure(const CallBackParams: TFunc<TAsynResponseCompaction>)
    begin
      AsynCompact(ParamProc, CallBackParams);
    end,
    CallBacks);
end;

function TResponsesRoute.AsyncAwaitCreate(const ParamProc: TProc<TResponsesParams>;
  const CallBacks: TFunc<TPromiseResponse>): TPromise<TResponse>;
begin
  Result := TAsyncAwaitHelper.WrapAsyncAwait<TResponse>(
    procedure(const CallBackParams: TFunc<TAsynResponse>)
    begin
      AsynCreate(ParamProc, CallBackParams);
    end,
    CallBacks);
end;

function TResponsesRoute.AsyncAwaitCreateParallel(
  const ParamProc: TProc<TBundleParams>;
  const CallBacks: TFunc<TPromiseBundleList>): TPromise<TBundleList>;
begin
  Result := TAsyncAwaitHelper.WrapAsyncAwait<TBundleList>(
    procedure(const CallBackParams: TFunc<TAsynBundleList>)
    begin
      CreateParallel(ParamProc, CallBackParams);
    end,
    CallBacks);
end;

function TResponsesRoute.AsyncAwaitCreateStream(
  const ParamProc: TProc<TResponsesParams>;
  const CallBacks: TFunc<TPromiseResponseStream>): TPromise<TResponseStream>;
begin
  Result := TPromise<TResponseStream>.Create(
    procedure(Resolve: TProc<TResponseStream>; Reject: TProc<Exception>)
    begin
      AsynCreateStream(ParamProc,
        function : TAsynResponseStream
        begin
          Result.Sender := CallBacks.Sender;

          Result.OnStart := CallBacks.OnStart;

          Result.OnProgress :=
            procedure (Sender: TObject; Event: TResponseStream)
            begin
              if Assigned(CallBacks.OnProgress) then
                CallBacks.OnProgress(Sender, Event);
              {--- Manage events error or failed }
              if (Event.&Type = TResponseStreamType.error) or
                 (Event.&Type = TResponseStreamType.failed) then
                begin
                  var ErrorCode := Event.Code;
                  var ErrorMessage := Event.Message;
                  if Assigned(Event.Response) and Assigned(Event.Response.Error) then
                    begin
                      ErrorCode := Event.Response.Error.Code;
                      ErrorMessage := Event.Response.Error.Message;
                    end;
                  Reject(Exception.Create(Format('(%s) %s', [ErrorCode, ErrorMessage])));
                end;

              {--- Last event recieved }
              if Event.&Type = TResponseStreamType.completed then
                begin
                  Resolve(TApiDeserializer.Parse<TResponseStream>(Event.JSONResponse));
                end;
            end;

          Result.OnError :=
            procedure (Sender: TObject; Error: string)
            begin
              if Assigned(CallBacks.OnError) then
                Error := CallBacks.OnError(Sender, Error);
              Reject(Exception.Create(Error));
            end;

          Result.OnDoCancel :=
            function : Boolean
            begin
              if Assigned(CallBacks.OnDoCancel) then
                Result := CallBacks.OnDoCancel()
              else
                Result := False;
            end;

          Result.OnCancellation :=
            procedure (Sender: TObject)
            begin
              var Error := 'aborted';
              if Assigned(CallBacks.OnCancellation) then
                Error := CallBacks.OnCancellation(Sender);
              Reject(Exception.Create(Error));
            end;
        end);
    end);
end;

function TResponsesRoute.AsyncAwaitCreateStream(
  const ParamProc: TProc<TResponsesParams>;
  const Callbacks: TFunc<TPromiseResponseStream>;
  const StreamEvents: IResponsesEventEngineManager): TPromise<TResponsesEventData>;
begin
  Result := TPromise<TResponsesEventData>.Create(
    procedure(Resolve: TProc<TResponsesEventData>; Reject: TProc<Exception>)
    begin
      var Buffer := TResponsesEventData.Empty;

      AsynCreateStream(ParamProc,
        function : TAsynResponseStream
        begin
          if Assigned(Callbacks) then
            Result.Sender := Callbacks.Sender;

          if Assigned(Callbacks) and Assigned(Callbacks.OnStart) then
            Result.OnStart := Callbacks.OnStart;

          Result.OnProgress :=
            procedure (Sender: TObject; Event: TResponseStream)
            begin
              try
                Buffer.Aggregate(Event,
                  procedure
                  begin
                    var ErrMsg := EmptyStr;
                    if Assigned(Event) and Assigned(Event.Response) and
                       Assigned(Event.Response.Error) then
                      ErrMsg := Format('(%s) %s',
                        [Event.Response.Error.Code, Event.Response.Error.Message])
                    else
                    if Assigned(Event) then
                      ErrMsg := Format('(%s) %s', [Event.Code, Event.Message]);

                    if Assigned(Callbacks) and Assigned(Callbacks.OnError) then
                      ErrMsg := Callbacks.OnError(Sender, ErrMsg);
                    Reject(Exception.Create(ErrMsg));
                  end);

                if Assigned(Callbacks) and Assigned(Callbacks.OnProgress) then
                  Callbacks.OnProgress(Sender, Event);
              except
                on E: Exception do
                  Reject(Exception.Create(E.Message));
              end;
            end;

          Result.OnSuccess :=
            procedure (Sender: TObject)
            begin
              Resolve(Buffer);
            end;

          Result.OnError :=
            procedure (Sender: TObject; Error: string)
            begin
              if Assigned(Callbacks) and Assigned(Callbacks.OnError) then
                Error := Callbacks.OnError(Sender, Error);
              Reject(Exception.Create(Error));
            end;

          Result.OnDoCancel :=
            function : Boolean
            begin
              if Assigned(Callbacks) and Assigned(Callbacks.OnDoCancel) then
                Result := Callbacks.OnDoCancel()
              else
                Result := False;
            end;

          Result.OnCancellation :=
            procedure (Sender: TObject)
            begin
              var Error := 'aborted';
              if Assigned(Callbacks) and Assigned(Callbacks.OnCancellation) then
                begin
                  var CallbackError := Callbacks.OnCancellation(Sender);
                  if not CallbackError.IsEmpty then
                    Error := CallbackError;
                end;
              Reject(Exception.Create(Error));
            end;
        end,
        StreamEvents);
    end);
end;

function TResponsesRoute.AsyncAwaitCreateStream(
  const ParamProc: TProc<TResponsesParams>;
  const StreamEvents: IResponsesEventEngineManager): TPromise<TResponsesEventData>;
begin
  Result := AsyncAwaitCreateStream(ParamProc, nil, StreamEvents);
end;

function TResponsesRoute.AsyncAwaitDelete(const ResponseId: string;
  const CallBacks: TFunc<TPromiseResponseDelete>): TPromise<TResponseDelete>;
begin
  Result := TAsyncAwaitHelper.WrapAsyncAwait<TResponseDelete>(
    procedure(const CallBackParams: TFunc<TAsynResponseDelete>)
    begin
      ASynDelete(ResponseId, CallBackParams);
    end,
    CallBacks);
end;

function TResponsesRoute.AsyncAwaitList(const ResponseId: string;
  const CallBacks: TFunc<TPromiseResponses>): TPromise<TResponses>;
begin
  Result := TAsyncAwaitHelper.WrapAsyncAwait<TResponses>(
    procedure(const CallBackParams: TFunc<TAsynResponses>)
    begin
      AsynList(ResponseId, CallBackParams);
    end,
    CallBacks);
end;

function TResponsesRoute.AsyncAwaitList(const ResponseId: string;
  const ParamProc: TProc<TUrlResponseListParams>;
  const CallBacks: TFunc<TPromiseResponses>): TPromise<TResponses>;
begin
  Result := TAsyncAwaitHelper.WrapAsyncAwait<TResponses>(
    procedure(const CallBackParams: TFunc<TAsynResponses>)
    begin
      AsynList(ResponseId, ParamProc, CallBackParams);
    end,
    CallBacks);
end;

function TResponsesRoute.AsyncAwaitRetrieve(const ResponseId: string;
  const ParamProc: TProc<TURLIncludeParams>;
  const CallBacks: TFunc<TPromiseResponse>): TPromise<TResponse>;
begin
  Result := TAsyncAwaitHelper.WrapAsyncAwait<TResponse>(
    procedure(const CallBackParams: TFunc<TAsynResponse>)
    begin
      AsynRetrieve(ResponseId, ParamProc, CallBackParams);
    end,
    CallBacks);
end;

function TResponsesRoute.AsyncAwaitRetrieve(const ResponseId: string;
  const CallBacks: TFunc<TPromiseResponse>): TPromise<TResponse>;
begin
  Result := TAsyncAwaitHelper.WrapAsyncAwait<TResponse>(
    procedure(const CallBackParams: TFunc<TAsynResponse>)
    begin
      AsynRetrieve(ResponseId, CallBackParams);
    end,
    CallBacks);
end;

{ TResponsesAsynchronousSupport }

procedure TResponsesAsynchronousSupport.AsynCancel(const ResponseId: string;
  const CallBacks: TFunc<TAsynResponse>);
begin
  with TAsynCallBackExec<TAsynResponse, TResponse>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TResponse
      begin
        Result := Self.Cancel(ResponseId);
      end);
  finally
    Free;
  end;
end;

procedure TResponsesAsynchronousSupport.AsynCompact(
  const ParamProc: TProc<TResponseCompactParams>;
  const CallBacks: TFunc<TAsynResponseCompaction>);
begin
  with TAsynCallBackExec<TAsynResponseCompaction, TResponseCompaction>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TResponseCompaction
      begin
        Result := Self.Compact(ParamProc);
      end);
  finally
    Free;
  end;
end;

procedure TResponsesAsynchronousSupport.AsynCreate(const ParamProc: TProc<TResponsesParams>;
  const CallBacks: TFunc<TAsynResponse>);
begin
  with TAsynCallBackExec<TAsynResponse, TResponse>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TResponse
      begin
        Result := Self.Create(ParamProc);
      end);
  finally
    Free;
  end;
end;

procedure TResponsesAsynchronousSupport.AsynCreateStream(const ParamProc: TProc<TResponsesParams>;
  const CallBacks: TFunc<TAsynResponseStream>);
begin
  AsynCreateStream(ParamProc, CallBacks, nil);
end;

procedure TResponsesAsynchronousSupport.AsynCreateStream(const ParamProc: TProc<TResponsesParams>;
  const CallBacks: TFunc<TAsynResponseStream>;
  const StreamEvents: IResponsesEventEngineManager);
var
  Sender: TObject;
begin
  var CallBackParams := TUseParamsFactory<TAsynResponseStream>.CreateInstance(CallBacks);

  var OnStart := CallBackParams.Param.OnStart;
  var OnSuccess := CallBackParams.Param.OnSuccess;
  var OnProgress := CallBackParams.Param.OnProgress;
  var OnError := CallBackParams.Param.OnError;
  var CancelTag := 0;

  {--- Cancellation sources: the dispatcher callbacks (event mode) and the
       session callbacks (promise/async mode). They are CHAINED, not
       overridden: this lets a consumer abort mid-response via the engine
       while the promise pivot is still rejected (cancellation handled as an
       error -> &Catch). }
  var SessionSender := CallBackParams.Param.Sender;
  var SessionOnCancellation := CallBackParams.Param.OnCancellation;
  var SessionOnDoCancel := CallBackParams.Param.OnDoCancel;

  var DispSender: TObject := nil;
  var DispOnCancellation: TProc<TObject> := nil;
  var DispOnDoCancel: TFunc<Boolean> := nil;
  if Assigned(StreamEvents) then
    begin
      DispSender := StreamEvents.GetStreamEventDispatcher.CallBacks.Sender;
      DispOnCancellation := StreamEvents.GetStreamEventDispatcher.CallBacks.OnCancellation;
      DispOnDoCancel := StreamEvents.GetStreamEventDispatcher.CallBacks.OnDoCancel;
    end;

  if Assigned(DispSender) then
    Sender := DispSender
  else
    Sender := SessionSender;

  var Task: ITask := TTask.Create(
    procedure()
    begin
      if not Assigned(Sender) then
        Sender := Self;

      if Assigned(OnStart) then
        TThread.Queue(nil,
          procedure
          begin
            OnStart(Sender);
          end);
      try
        var Stop := False;

        CreateStream(ParamProc,
          procedure(var Response: TResponseStream; IsDone: Boolean; var Cancel: Boolean)
          begin
            if not Stop and
               (Assigned(DispOnDoCancel) or Assigned(SessionOnDoCancel)) then
              TThread.Queue(nil,
                procedure
                begin
                  Stop := False;
                  if Assigned(DispOnDoCancel) then
                    Stop := DispOnDoCancel();
                  if (not Stop) and Assigned(SessionOnDoCancel) then
                    Stop := SessionOnDoCancel();
                end);
            if Stop then
              begin
                if (CancelTag = 0) and
                   (Assigned(DispOnCancellation) or
                    Assigned(SessionOnCancellation)) then
                  TThread.Queue(nil,
                    procedure
                    begin
                      if Assigned(DispOnCancellation) then
                        DispOnCancellation(Sender);
                      if Assigned(SessionOnCancellation) then
                        SessionOnCancellation(Sender);
                    end);
                Inc(CancelTag);
                Cancel := True;
                Exit;
              end;

            if Assigned(Response) then
              begin
                var LocalResponse := Response;
                Response := nil;

                if Assigned(OnProgress) then
                  TThread.Synchronize(TThread.Current,
                    procedure
                    begin
                      try
                        OnProgress(Sender, LocalResponse);
                      finally
                        LocalResponse.Free;
                      end;
                    end)
                else
                  LocalResponse.Free;
              end
            else if IsDone then
              begin
                if Assigned(OnSuccess) then
                  TThread.Queue(nil,
                    procedure
                    begin
                      OnSuccess(Sender);
                    end);
              end;
          end,
          StreamEvents);
      except
        on E: Exception do
          begin
            var Error := AcquireExceptionObject;
            try
              var ErrorMsg := (Error as Exception).Message;
              if Assigned(OnError) then
                TThread.Queue(nil,
                  procedure
                  begin
                    OnError(Sender, ErrorMsg);
                  end);
            finally
              Error.Free;
            end;
          end;
      end;
    end);
  Task.Start;
end;
procedure TResponsesAsynchronousSupport.AsynDelete(const ResponseId: string;
  const CallBacks: TFunc<TAsynResponseDelete>);
begin
  with TAsynCallBackExec<TAsynResponseDelete, TResponseDelete>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TResponseDelete
      begin
        Result := Self.Delete(ResponseId);
      end);
  finally
    Free;
  end;
end;

procedure TResponsesAsynchronousSupport.AsynList(const ResponseId: string;
  const ParamProc: TProc<TUrlResponseListParams>;
  const CallBacks: TFunc<TAsynResponses>);
begin
  with TAsynCallBackExec<TAsynResponses, TResponses>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TResponses
      begin
        Result := Self.List(ResponseId, ParamProc);
      end);
  finally
    Free;
  end;
end;

procedure TResponsesAsynchronousSupport.AsynList(const ResponseId: string;
  const CallBacks: TFunc<TAsynResponses>);
begin
  with TAsynCallBackExec<TAsynResponses, TResponses>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TResponses
      begin
        Result := Self.List(ResponseId);
      end);
  finally
    Free;
  end;
end;

procedure TResponsesAsynchronousSupport.AsynRetrieve(const ResponseId: string;
  const ParamProc: TProc<TURLIncludeParams>;
  const CallBacks: TFunc<TAsynResponse>);
begin
  with TAsynCallBackExec<TAsynResponse, TResponse>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TResponse
      begin
        Result := Self.Retrieve(ResponseId, ParamProc);
      end);
  finally
    Free;
  end;
end;

procedure TResponsesAsynchronousSupport.AsynRetrieve(const ResponseId: string;
  const CallBacks: TFunc<TAsynResponse>);
begin
  with TAsynCallBackExec<TAsynResponse, TResponse>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TResponse
      begin
        Result := Self.Retrieve(ResponseId);
      end);
  finally
    Free;
  end;
end;

{ TResponsesRoute }

function TResponsesRoute.Cancel(const ResponseId: string): TResponse;
begin
  Result := API.Post<TResponse>('responses/' + ResponseId + '/cancel');
end;

function TResponsesRoute.Compact(
  ParamProc: TProc<TResponseCompactParams>): TResponseCompaction;
begin
  Result := API.Post<TResponseCompaction, TResponseCompactParams>('responses/compact', ParamProc);
end;

function TResponsesRoute.Create(ParamProc: TProc<TResponsesParams>): TResponse;
begin
  Result := API.Post<TResponse, TResponsesParams>('responses', ParamProc);
end;

procedure TResponsesRoute.CreateParallel(ParamProc: TProc<TBundleParams>;
  const CallBacks: TFunc<TAsynBundleList>);
var
  Tasks: TArray<ITask>;
  BundleParams: TBundleParams;
  ReasoningEffort: string;
begin
  BundleParams := TBundleParams.Create;
  try
    if not Assigned(ParamProc) then
      raise Exception.Create('The lambda can''t be null');

    ParamProc(BundleParams);
    var Bundle := TBundleList.Create;
    var Ranking := 0;
    var ErrorExists := False;
    var Prompts := BundleParams.GetPrompt;
    var Counter := Length(Prompts);

    if IsReasoningModel(BundleParams.GetModel) then
      ReasoningEffort := BundleParams.GetReasoningEffort
    else
      ReasoningEffort := EmptyStr;

    if Assigned(CallBacks.OnStart) then
      CallBacks.OnStart(CallBacks.Sender);

    SetLength(Tasks, Length(Prompts));
    for var index := 0 to Pred(Length(Prompts)) do
      begin
        Tasks[index] := TTask.Run(
          procedure
          begin
            var Buffer := Bundle.Add(index + 1);
            Buffer.Prompt := Prompts[index];
            try
              var Response := Create(
                procedure(Params: TResponsesParams)
                begin
                  Params.Model(BundleParams.GetModel);

                  if not ReasoningEffort.IsEmpty then
                    Params.Reasoning(TReasoningParams.New.Effort(ReasoningEffort));

                  Params.Instructions(BundleParams.GetSystem);
                  Params.Input(Buffer.Prompt);

                  if not BundleParams.GetSearchSize.IsEmpty then
                    begin
                      var SearchWeb := TResponseWebSearchParams.New.SearchContextSize(BundleParams.GetSearchSize);

                      if not BundleParams.GetCity.IsEmpty or
                         not BundleParams.GetCountry.IsEmpty then
                        begin
                          var Locate := TResponseUserLocationParams.New;

                          if not BundleParams.GetCity.IsEmpty then
                            Locate.City(BundleParams.GetCity);

                          if not BundleParams.GetCountry.IsEmpty then
                            Locate.Country(BundleParams.GetCountry);

                          SearchWeb.UserLocation(Locate);
                        end;

                      Params.Tools([SearchWeb]);
                    end;

                  Params.Store(False);
                end);
              Inc(Ranking);
              Buffer.FinishIndex := Ranking;

              for var Item in Response.Output do
                for var SubItem in Item.Content do
                  Buffer.Response := Buffer.Response + SubItem.Text + #10;

              Buffer.Chat := Response;
            except
              on E: Exception do
                begin
                  var Error := AcquireExceptionObject;
                  ErrorExists := True;
                  try
                    var ErrorMsg := (Error as Exception).Message;
                    if Assigned(CallBacks.OnError) then
                      TThread.Queue(nil,
                        procedure
                        begin
                          CallBacks.OnError(CallBacks.Sender, ErrorMsg);
                        end);
                  finally
                    Error.Free;
                  end;
                end;
            end;
          end);

        if ErrorExists then
          Continue;

        TTaskHelper.ContinueWith(Tasks[Index],
          procedure
          begin
            Dec(Counter);
            if Counter = 0 then
              begin
                try
                  if not ErrorExists and Assigned(CallBacks.OnSuccess) then
                    CallBacks.OnSuccess(CallBacks.Sender, Bundle);
                finally
                  Bundle.Free;
                end;
              end;
          end);
        Sleep(30);
      end;
  finally
    BundleParams.Free;
  end;
end;
function TResponsesRoute.CreateStream(ParamProc: TProc<TResponsesParams>;
  Event: TResponseEvent; const StreamEvents: IResponsesEventEngineManager): Boolean;
var
  Response: TLockedMemoryStream;
  RetPos: Int64;
  Decoder: TSSEDecoder;
  DoneSent: Boolean;
  AbortFlag: Boolean;
  Buffer: TResponsesEventData;
begin
  Buffer := TResponsesEventData.Empty;
  Response := TLockedMemoryStream.Create;
  try
    RetPos := 0;
    DoneSent := False;
    AbortFlag := False;

    var EmitDone :=
      procedure(var AAbort: Boolean)
      var
        Content: TResponseStream;
      begin
        if DoneSent then
          Exit;

        DoneSent := True;
        Content := nil;
        if Assigned(Event) then
          Event(Content, True, AAbort);
      end;

    Decoder := TSSEDecoder.Create(
      procedure(const Data: string; var AAbort: Boolean)
      var
        Line: string;
        Content: TResponseStream;
        CurrentType: TResponseStreamType;
        IsTerminal: Boolean;
      begin
        Content := nil;

        if AAbort or DoneSent then
          Exit;

        Line := Data.Trim;
        if Line.IsEmpty then
          Exit;

        if SameText(Line, '[DONE]') then
          begin
            EmitDone(AAbort);
            Exit;
          end;

        try
          try
            Content := TApiDeserializer.Parse<TResponseStream>(Line);
          except
            Content := nil;
          end;

          if Assigned(Content) then
            begin
              CurrentType := Content.EventType;
              if CurrentType = TResponseStreamType.sdk_unknown then
                CurrentType := Content.&Type;

              IsTerminal :=
                (CurrentType = TResponseStreamType.completed) or
                (CurrentType = TResponseStreamType.failed) or
                (CurrentType = TResponseStreamType.incomplete) or
                (CurrentType = TResponseStreamType.error);

              {--- Event mode: aggregate into the buffer and dispatch the
                   granular per-event callbacks before the session callback. }
              if Assigned(StreamEvents) then
                StreamEvents.AggregateStreamEvents(Content, Buffer);

              if Assigned(Event) then
                Event(Content, IsTerminal, AAbort);

              if IsTerminal and not AAbort then
                EmitDone(AAbort);
            end;
        finally
          Content.Free;
        end;
      end
    );

    var Drain :=
      procedure(var Abort: Boolean)
      var
        Bytes: TBytes;
        Snap: Int64;
      begin
        Snap := RetPos;
        try
          while Response.ExtractDelta(RetPos, Bytes) do
            begin
              if Length(Bytes) = 0 then
                Continue;

              Decoder.Feed(Bytes, Abort);

              if Abort then
                Exit;
            end;
        except
          RetPos := Snap;
          raise;
        end;
      end;

    try
      Result := API.Post<TResponsesParams>(
        'responses',
        ParamProc,
        Response,
        procedure(const Sender: TObject; AContentLength: Int64; AReadCount: Int64; var AAbort: Boolean)
        begin
          if DoneSent then
            begin
              AAbort := True;
              Exit;
            end;

          Drain(AAbort);

          if AAbort then
            AbortFlag := True;
        end
      );
    finally
      if not DoneSent and not AbortFlag then
        begin
          Drain(AbortFlag);
          Decoder.Flush(AbortFlag);
        end;

      if not DoneSent and not AbortFlag then
        EmitDone(AbortFlag);

      Decoder.Free;
      Drain := nil;
      EmitDone := nil;
    end;
  finally
    Response.Free;
  end;
end;

function TResponsesRoute.Delete(const ResponseId: string): TResponseDelete;
begin
  Result := API.Delete<TResponseDelete>('responses/' + ResponseId);
end;

function TResponsesRoute.List(const ResponseId: string;
  const ParamProc: TProc<TUrlResponseListParams>): TResponses;
begin
  Result := API.Get<TResponses, TUrlResponseListParams>('responses/' + ResponseId + '/input_items', ParamProc);
end;

function TResponsesRoute.List(const ResponseId: string): TResponses;
begin
  Result := API.Get<TResponses>('responses/' + ResponseId + '/input_items');
end;

function TResponsesRoute.Retrieve(const ResponseId: string;
  const ParamProc: TProc<TURLIncludeParams>): TResponse;
begin
  Result := API.Get<TResponse, TURLIncludeParams>('responses/' + ResponseID, ParamProc);
end;

function TResponsesRoute.Retrieve(const ResponseId: string): TResponse;
begin
  Result := API.Get<TResponse>('responses/' + ResponseID);
end;

end.
