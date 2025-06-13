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
  GenAI.Responses.Internal;

type
  /// <summary>
  /// Provides methods to create, retrieve, delete, and list AI responses.
  /// </summary>
  /// <remarks>
  /// TResponsesRoute is a subclass of TGenAIRoute and implements both synchronous and asynchronous
  /// operations for interacting with the “responses” endpoint of the API. It also supports
  /// overloads that allow additional parameter configuration.
  /// </remarks>
  TResponsesRoute = class(TInternalResponseRoute)
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
      const CallBacks: TFunc<TPromiseResponseStream>): TPromise<TResponseStream>;

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
    function CreateStream(ParamProc: TProc<TResponsesParams>; Event: TResponseEvent): Boolean; override;

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
    function Retrieve(const ResponseId: string): TResponse; overload;

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
      const ParamProc: TProc<TURLIncludeParams>): TResponse; overload;

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
    function Delete(const ResponseId: string): TResponseDelete;

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
    function List(const ResponseId: string): TResponses; overload;

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
      const ParamProc: TProc<TUrlResponseListParams>): TResponses; overload;

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
    procedure CreateParallel(ParamProc: TProc<TBundleParams>; const CallBacks: TFunc<TAsynBundleList>);   /// <summary>
    /// Asynchronously creates a new AI response.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure to configure the request parameters using a TResponsesParams instance.
    /// </param>
    /// <param name="CallBacks">
    /// A callback function that returns a TAsynResponse instance, used to handle start, success, and error events.
    /// </param>
    /// <remarks>
    /// Sends a non-blocking request to create an AI response.
    ///
    /// <code>
    /// Client.Responses.AsynCreate(
    ///   procedure (Params: TResponsesParams)
    ///   begin
    ///     Params.Model('gpt-4.1-mini');
    ///     Params.Input('What is the difference between a mathematician and a physicist?');
    ///   end,
    ///   function : TAsynResponse
    ///   begin
    ///     Result.Sender := Self;
    ///     Result.OnStart := procedure(Sender: TObject)
    ///       begin
    ///         // Initialization code
    ///       end;
    ///     Result.OnSuccess := procedure(Sender: TObject; Value: TResponse)
    ///       begin
    ///         // Process the created response
    ///       end;
    ///     Result.OnError := procedure(Sender: TObject; const ErrorMsg: string)
    ///       begin
    ///         // Handle any errors
    ///       end;
    ///   end);
    /// </code>
    /// </remarks>
    procedure AsynCreate(const ParamProc: TProc<TResponsesParams>;
      const CallBacks: TFunc<TAsynResponse>);

    /// <summary>
    /// Asynchronously creates a streamed AI response.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure to configure the request parameters using a TResponsesParams instance.
    /// </param>
    /// <param name="Event">
    /// A callback of type TResponseEvent that is invoked repeatedly as streaming data is received.
    /// </param>
    /// <returns>
    /// True if the streaming response request was successfully initiated.
    /// </returns>
    /// <remarks>
    /// Initiates a streaming request to receive incremental output from the AI.
    ///
    /// <code>
    ///   Client.Responses.AsynCreateStream(
    ///      procedure (Params: TResponsesParams)
    ///      begin
    ///        Params.Model('gpt-4.1-mini');
    ///        Params.Input('What is the difference between a mathematician and a physicist?');
    ///        Params.Stream;
    ///      end,
    ///      function : TAsynResponseStream
    ///      begin
    ///        Result.Sender := Self;
    ///        Result.OnStart := StartCallback;
    ///        Result.OnProgress := ProgressCallback;
    ///        Result.OnError := ErrorCallback;
    ///        Result.OnDoCancel := CancelCallback;
    ///        Result.OnCancellation := CancellationCallback;
    ///      end)
    /// </code>
    /// </remarks>
    procedure AsynCreateStream(const ParamProc: TProc<TResponsesParams>;
      const CallBacks: TFunc<TAsynResponseStream>);

    /// <summary>
    /// Asynchronously retrieves an AI response identified by its ID.
    /// </summary>
    /// <param name="ResponseId">
    /// The unique identifier of the response to retrieve.
    /// </param>
    /// <param name="CallBacks">
    /// A callback function that returns a TAsynResponse instance to handle the retrieval process.
    /// </param>
    /// <remarks>
    /// Retrieves the specified response asynchronously.
    ///
    /// <code>
    /// Client.Responses.AsynRetrieve('response_id_here',
    ///   function : TAsynResponse
    ///   begin
    ///     Result.Sender := Self;
    ///     Result.OnStart := StartCallback;
    ///     Result.OnSuccess := SuccessCallback;
    ///     Result.OnError := ErrorCallback;
    ///   end);
    /// </code>
    /// </remarks>
    procedure AsynRetrieve(const ResponseId: string;
      const CallBacks: TFunc<TAsynResponse>); overload;

    /// <summary>
    /// Asynchronously retrieves an AI response by its ID with additional URL parameters.
    /// </summary>
    /// <param name="ResponseId">
    /// The unique identifier of the response to retrieve.
    /// </param>
    /// <param name="ParamProc">
    /// A procedure to configure additional URL parameters using a TURLIncludeParams instance.
    /// </param>
    /// <param name="CallBacks">
    /// A callback function that returns a TAsynResponse instance to handle the retrieval process.
    /// </param>
    /// <remarks>
    /// Retrieves the specified response asynchronously with extra URL configuration.
    ///
    /// <code>
    /// Client.Responses.AsynRetrieve('response_id_here',
    ///   procedure(Params: TURLIncludeParams)
    ///   begin
    ///     Params.Include(['file_search_result', 'input_image_url']);
    ///   end,
    ///   function : TAsynResponse
    ///   begin
    ///     Result.Sender := Self;
    ///     Result.OnStart := StartCallback;
    ///     Result.OnSuccess := SuccessCallback;
    ///     Result.OnError := ErrorCallback;
    ///   end);
    /// </code>
    /// </remarks>
    procedure AsynRetrieve(const ResponseId: string;
      const ParamProc: TProc<TURLIncludeParams>;
      const CallBacks: TFunc<TAsynResponse>); overload;

    /// <summary>
    /// Asynchronously deletes an AI response identified by its ID.
    /// </summary>
    /// <param name="ResponseId">
    /// The unique identifier of the response to delete.
    /// </param>
    /// <param name="CallBacks">
    /// A callback function that returns a TAsynResponseDelete instance to handle deletion events.
    /// </param>
    /// <remarks>
    /// Sends a non-blocking deletion request for the specified response.
    ///
    /// <code>
    /// Client.Responses.AsynDelete('response_id_here',
    ///   function : TAsynResponseDelete
    ///   begin
    ///     Result.Sender := Self;
    ///     Result.OnStart := StartCallback;
    ///     Result.OnSuccess := SuccessCallback;
    ///     Result.OnError := ErrorCallback;
    ///   end);
    /// </code>
    /// </remarks>
    procedure AsynDelete(const ResponseId: string;
      const CallBacks: TFunc<TAsynResponseDelete>);

    /// <summary>
    /// Asynchronously lists the input items used to generate a specific AI response.
    /// </summary>
    /// <param name="ResponseId">
    /// The unique identifier of the response.
    /// </param>
    /// <param name="CallBacks">
    /// A callback function that returns a TAsynResponses instance to handle the listing process.
    /// </param>
    /// <remarks>
    /// Retrieves the input items associated with the given response asynchronously.
    ///
    /// <code>
    /// Client.Responses.AsynList('response_id_here',
    ///   function : TAsynResponses
    ///   begin
    ///     Result.Sender := Self;
    ///     Result.OnStart := StartCallback;
    ///     Result.OnSuccess := SuccessCallback;
    ///     Result.OnError := ErrorCallback;
    ///   end);
    /// </code>
    /// </remarks>
    procedure AsynList(const ResponseId: string;
      const CallBacks: TFunc<TAsynResponses>); overload;

    /// <summary>
    /// Asynchronously lists the input items used to generate a specific AI response with additional URL parameters.
    /// </summary>
    /// <param name="ResponseId">
    /// The unique identifier of the response.
    /// </param>
    /// <param name="ParamProc">
    /// A procedure to configure additional URL parameters using a TUrlResponseListParams instance.
    /// </param>
    /// <param name="CallBacks">
    /// A callback function that returns a TAsynResponses instance to handle the listing process.
    /// </param>
    /// <remarks>
    /// Retrieves the list of input items asynchronously with extra configuration.
    ///
    /// <code>
    /// Client.Responses.AsynList('response_id_here',
    ///   procedure (Params: TUrlResponseListParams)
    ///   begin
    ///     Params.Limit(15);
    ///   end,
    ///   function : TAsynResponses
    ///   begin
    ///     Result.Sender := Self;
    ///     Result.OnStart := StartCallback;
    ///     Result.OnSuccess := SuccessCallback;
    ///     Result.OnError := ErrorCallback;
    ///   end);
    /// </code>
    /// </remarks>
    procedure AsynList(const ResponseId: string;
      const ParamProc: TProc<TUrlResponseListParams>;
      const CallBacks: TFunc<TAsynResponses>); overload;
  end;

implementation

uses
  System.StrUtils;

{ TResponsesRoute }

function TResponsesRoute.AsyncAwaitCreate(const ParamProc: TProc<TResponsesParams>;
  const CallBacks: TFunc<TPromiseResponse>): TPromise<TResponse>;
begin
  Result := TAsyncAwaitHelper.WrapAsyncAwait<TResponse>(
    procedure(const CallBackParams: TFunc<TAsynResponse>)
    begin
      InternalAsynCreate(ParamProc, CallBackParams);
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
      InternalCreateParallel(ParamProc, CallBackParams);
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
      InternalAsynCreateStream(ParamProc,
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
                  Reject(Exception.Create(Format('(%s) %s', [Event.Code, Event.Message])));
                end;

              {--- Last event recieved }
              if Event.&Type = TResponseStreamType.completed then
                begin
                  Resolve(Event);
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

procedure TResponsesRoute.AsynCreate(const ParamProc: TProc<TResponsesParams>;
  const CallBacks: TFunc<TAsynResponse>);
begin
  InternalAsynCreate(ParamProc, CallBacks);
end;

procedure TResponsesRoute.AsynCreateStream(const ParamProc: TProc<TResponsesParams>;
  const CallBacks: TFunc<TAsynResponseStream>);
begin
  InternalAsynCreateStream(ParamProc, CallBacks);
end;

procedure TResponsesRoute.AsynDelete(const ResponseId: string;
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

procedure TResponsesRoute.AsynList(const ResponseId: string;
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

procedure TResponsesRoute.AsynList(const ResponseId: string;
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

procedure TResponsesRoute.AsynRetrieve(const ResponseId: string;
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

procedure TResponsesRoute.AsynRetrieve(const ResponseId: string;
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

function TResponsesRoute.Create(ParamProc: TProc<TResponsesParams>): TResponse;
begin
  Result := API.Post<TResponse, TResponsesParams>('responses', ParamProc);
end;

procedure TResponsesRoute.CreateParallel(ParamProc: TProc<TBundleParams>;
  const CallBacks: TFunc<TAsynBundleList>);
begin
  InternalCreateParallel(ParamProc, CallBacks);
end;

function TResponsesRoute.Retrieve(const ResponseId: string): TResponse;
begin
  Result := API.Get<TResponse>('responses/' + ResponseID);
end;

function TResponsesRoute.CreateStream(ParamProc: TProc<TResponsesParams>;
  Event: TResponseEvent): Boolean;
begin
  Result := InternalCreateStream(ParamProc, Event);
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

end.
