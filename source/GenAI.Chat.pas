unit GenAI.Chat;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGenAI
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.SysUtils, System.Classes,
  GenAI.API, GenAI.API.Params,
  GenAI.Chat.Request, GenAI.ChatDTO, GenAI.Chat.Parallel,
  GenAI.Async.Support, GenAI.Async.Promise;

type
  /// <summary>
  /// Callback invoked for each streamed item returned by the chat completions endpoint.
  /// </summary>
  TStreamCallbackEvent<T: class, constructor> = reference to procedure(
    var Chunk: T; IsDone: Boolean; var Cancel: Boolean);

  /// <summary>
  /// Callback type used by chat streaming responses.
  /// </summary>
  TChatStreamCallbackEvent = TStreamCallbackEvent<TChat>;

  /// <summary>
  /// Manages asynchronous chat callBacks for a chat request using <c>TChat</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynChat</c> type extends the <c>TAsynParams&lt;TChat&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking chat operations and is specifically tailored for scenarios where multiple choices from a chat model are required.
  /// </remarks>
  TAsynChat = TAsynCallBack<TChat>;

  /// <summary>
  /// Represents a promise-based asynchronous callback for chat completion operations.
  /// </summary>
  /// <remarks>
  /// Alias of <c>TPromiseCallBack&lt;TChat&gt;</c>, this type allows you to await the result
  /// of a chat completion request and handle it as a <see cref="TChat"/> instance.
  /// </remarks>
  TPromiseChat = TPromiseCallBack<TChat>;

  /// <summary>
  /// Manages asynchronous streaming chat callBacks for a chat request using <c>TChat</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynChatStream</c> type extends the <c>TAsynStreamParams&lt;TChat&gt;</c> record to support the lifecycle of an asynchronous streaming chat operation.
  /// It provides callbacks for different stages, including when the operation starts, progresses with new data chunks, completes successfully, or encounters an error.
  /// This structure is ideal for handling scenarios where the chat response is streamed incrementally, providing real-time updates to the user interface.
  /// </remarks>
  TAsynChatStream = TAsynStreamCallBack<TChat>;

  /// <summary>
  /// Represents a promise-based asynchronous callback for streaming chat completion operations.
  /// </summary>
  /// <remarks>
  /// Alias of <c>TPromiseStreamCallBack&lt;TChat&gt;</c>, this type provides a <see cref="TChat"/> stream
  /// that can be awaited, delivering partial <see cref="TChat"/> updates as they arrive.
  /// </remarks>
  TPromiseChatStream = TPromiseStreamCallBack<TChat>;

  /// <summary>
  /// Represents an asynchronous callback structure for retrieving chat messages.
  /// </summary>
  /// <remarks>
  /// Use this callback type to handle the lifecycle events (start, success, error, and cancellation)
  /// when fetching <see cref="TChatMessages"/> instances asynchronously.
  /// </remarks>
  TAsynChatMessages = TAsynCallBack<TChatMessages>;

  /// <summary>
  /// Represents a promise-based asynchronous callback for retrieving chat messages.
  /// </summary>
  /// <remarks>
  /// Alias of <c>TPromiseCallBack&lt;TChatMessages&gt;</c>, this type allows you to await the result
  /// of fetching messages for a stored chat completion, delivering a <see cref="TChatMessages"/> instance.
  /// </remarks>
  TPromiseChatMessages = TPromiseCallBack<TChatMessages>;

  /// <summary>
  /// Represents an asynchronous callback structure for retrieving chat completion results.
  /// </summary>
  /// <remarks>
  /// Use this callback type to handle the lifecycle events (start, success, error, and cancellation)
  /// when fetching <see cref="TChatCompletion"/> instances asynchronously.
  /// </remarks>
  TAsynChatCompletion = TAsynCallBack<TChatCompletion>;

  /// <summary>
  /// Represents a promise-based asynchronous callback for listing chat completion results.
  /// </summary>
  /// <remarks>
  /// Alias of <c>TPromiseCallBack&lt;TChatCompletion&gt;</c>, this type allows you to await the
  /// result of a paginated chat completions request and receive it as a <see cref="TChatCompletion"/> instance.
  /// </remarks>
  TPromiseChatCompletion = TPromiseCallBack<TChatCompletion>;

  /// <summary>
  /// Represents an asynchronous callback structure for deleting a chat completion.
  /// </summary>
  /// <remarks>
  /// Use this callback type to handle the lifecycle events (start, success, error, and cancellation)
  /// when performing an asynchronous delete operation for a <see cref="TChatDelete"/> instance.
  /// </remarks>
  TAsynChatDelete = TAsynCallBack<TChatDelete>;

  /// <summary>
  /// Represents a promise-based asynchronous callback for deleting a chat completion.
  /// </summary>
  /// <remarks>
  /// Alias of <c>TPromiseCallBack&lt;TChatDelete&gt;</c>, this type allows you to await
  /// the result of a chat completion deletion request and receive a <see cref="TChatDelete"/>
  /// instance indicating whether the deletion was successful.
  /// </remarks>
  TPromiseChatDelete = TPromiseCallBack<TChatDelete>;

  TAbstractSupport = class(TGenAIRoute)
  protected
    function Create(const ParamProc: TProc<TChatParams>): TChat; virtual; abstract;

    function CreateStream(const ParamProc: TProc<TChatParams>;
      const Event: TStreamCallbackEvent<TChat>): Boolean; virtual; abstract;

    function GetCompletion(const CompletionID: string): TChat; virtual; abstract;

    function GetMessages(const CompletionID: string): TChatMessages; overload; virtual; abstract;

    function GetMessages(const CompletionID: string;
      const ParamProc: TProc<TUrlChatParams>): TChatMessages; overload; virtual; abstract;

    function List(const ParamProc: TProc<TUrlChatListParams>): TChatCompletion; virtual; abstract;

    function Update(const CompletionID: string;
      const ParamProc: TProc<TChatUpdateParams>): TChat; virtual; abstract;

    function Delete(const CompletionID: string): TChatDelete; virtual; abstract;
  end;

  TAsynchronousSupport = class(TAbstractSupport)
  public
    procedure AsynCreate(const ParamProc: TProc<TChatParams>;
      const CallBacks: TFunc<TAsynChat>);

    procedure AsynCreateStream(const ParamProc: TProc<TChatParams>;
      const CallBacks: TFunc<TAsynChatStream>);

    procedure AsynGetCompletion(const CompletionID: string;
      const CallBacks: TFunc<TAsynChat>);

    procedure AsynGetMessages(const CompletionID: string;
      const CallBacks: TFunc<TAsynChatMessages>); overload;

    procedure AsynGetMessages(const CompletionID: string;
      const ParamProc: TProc<TUrlChatParams>;
      const CallBacks: TFunc<TAsynChatMessages>); overload;

    procedure AsynList(const ParamProc: TProc<TUrlChatListParams>;
      const CallBacks: TFunc<TAsynChatCompletion>);

    procedure AsynUpdate(const CompletionID: string;
      const ParamProc: TProc<TChatUpdateParams>;
      const CallBacks: TFunc<TAsynChat>);

    procedure AsynDelete(const CompletionID: string; const CallBacks: TFunc<TAsynChatDelete>);
  end;

  TChatRoute = class(TAsynchronousSupport)
  public
    /// <summary>
    /// Asynchronously creates a chat completion and returns a promise that resolves to the resulting <see cref="TChat"/>.
    /// </summary>
    /// <param name="ParamProc">
    /// Procedure used to configure the parameters of the chat request.
    /// </param>
    /// <param name="CallBacks">
    /// Optional factory returning a <see cref="TPromiseChat"/> instance with lifecycle callbacks.
    /// </param>
    /// <returns>
    /// A <see cref="TPromise{TChat}"/> that is fulfilled with the resulting chat completion
    /// or rejected with an exception if an error occurs.
    /// </returns>
    function AsyncAwaitCreate(const ParamProc: TProc<TChatParams>;
      const CallBacks: TFunc<TPromiseChat> = nil): TPromise<TChat>;

    /// <summary>
    /// Asynchronously creates a streamed chat completion and returns a promise
    /// that resolves to the full concatenated response as a string.
    /// </summary>
    /// <param name="ParamProc">
    /// Procedure used to configure the parameters of the chat streaming request.
    /// </param>
    /// <param name="CallBacks">
    /// Function returning a <see cref="TPromiseChatStream"/> with optional lifecycle
    /// callbacks for handling streaming events. This parameter is mandatory.
    /// </param>
    /// <returns>
    /// A <see cref="TPromise{string}"/> that resolves with the full streamed response text
    /// or is rejected with an exception if an error or cancellation occurs.
    /// </returns>
    function AsyncAwaitCreateStream(const ParamProc: TProc<TChatParams>;
      const CallBacks: TFunc<TPromiseChatStream>): TPromise<string>;

    /// <summary>
    /// Asynchronously retrieves a stored chat completion and returns a promise
    /// that resolves to a <see cref="TChat"/> instance.
    /// </summary>
    /// <param name="CompletionID">
    /// The unique identifier of the stored chat completion to retrieve.
    /// </param>
    /// <param name="CallBacks">
    /// Optional function returning a <see cref="TPromiseChat"/> that provides lifecycle
    /// callbacks for the asynchronous operation.
    /// </param>
    /// <returns>
    /// A <see cref="TPromise{TChat}"/> that resolves with the retrieved chat completion
    /// or is rejected with an exception if the operation fails.
    /// </returns>
    function AsyncAwaitGetCompletion(const CompletionID: string;
      const CallBacks: TFunc<TPromiseChat> = nil): TPromise<TChat>;

    /// <summary>
    /// Asynchronously retrieves the messages of a stored chat completion and returns a promise
    /// that resolves to a <see cref="TChatMessages"/> instance.
    /// </summary>
    /// <param name="CompletionID">
    /// The unique identifier of the stored chat completion whose messages are to be retrieved.
    /// </param>
    /// <param name="CallBacks">
    /// Optional function returning a <see cref="TPromiseChatMessages"/> instance that provides
    /// lifecycle callbacks for the asynchronous operation.
    /// </param>
    /// <returns>
    /// A <see cref="TPromise{TChatMessages}"/> that resolves with the retrieved messages or
    /// is rejected with an exception if the operation fails.
    /// </returns>
    function AsyncAwaitGetMessages(const CompletionID: string;
      const CallBacks: TFunc<TPromiseChatMessages> = nil): TPromise<TChatMessages>; overload;

    /// <summary>
    /// Asynchronously retrieves the messages of a stored chat completion using custom query parameters
    /// and returns a promise that resolves to a <see cref="TChatMessages"/> instance.
    /// </summary>
    /// <param name="CompletionID">
    /// The unique identifier of the stored chat completion whose messages are to be retrieved.
    /// </param>
    /// <param name="ParamProc">
    /// Procedure used to configure <see cref="TUrlChatParams"/> for custom query options such as
    /// pagination (<c>Limit</c>, <c>After</c>), sorting, or message filtering.
    /// </param>
    /// <param name="CallBacks">
    /// Optional function returning a <see cref="TPromiseChatMessages"/> instance that defines
    /// lifecycle callbacks for the asynchronous operation.
    /// </param>
    /// <returns>
    /// A <see cref="TPromise{TChatMessages}"/> that resolves with the retrieved messages or
    /// is rejected with an exception if the operation fails.
    /// </returns>
    function AsyncAwaitGetMessages(const CompletionID: string;
      const ParamProc: TProc<TUrlChatParams>;
      const CallBacks: TFunc<TPromiseChatMessages> = nil): TPromise<TChatMessages>; overload;

    /// <summary>
    /// Asynchronously retrieves a paginated list of stored chat completions and returns a promise
    /// that resolves to a <see cref="TChatCompletion"/> instance.
    /// </summary>
    /// <param name="ParamProc">
    /// Procedure used to configure <see cref="TUrlChatListParams"/>, allowing pagination
    /// (<c>Limit</c>, <c>After</c>), filtering by metadata or model, and sort order.
    /// </param>
    /// <param name="CallBacks">
    /// Optional function returning a <see cref="TPromiseChatCompletion"/> that provides lifecycle
    /// callbacks for the asynchronous operation.
    /// </param>
    /// <returns>
    /// A <see cref="TPromise{TChatCompletion}"/> that resolves with the retrieved list of chat
    /// completions or is rejected with an exception if the operation fails.
    /// </returns>
    function AsyncAwaitList(const ParamProc: TProc<TUrlChatListParams>;
      const CallBacks: TFunc<TPromiseChatCompletion> = nil): TPromise<TChatCompletion>;

    /// <summary>
    /// Asynchronously updates a stored chat completion and returns a promise
    /// that resolves to the updated <see cref="TChat"/> instance.
    /// </summary>
    /// <param name="CompletionID">
    /// The unique identifier of the stored chat completion to update.
    /// </param>
    /// <param name="ParamProc">
    /// Procedure used to configure the <see cref="TChatUpdateParams"/> for the update request,
    /// typically to modify metadata.
    /// </param>
    /// <param name="CallBacks">
    /// Optional function returning a <see cref="TPromiseChat"/> that provides lifecycle callback
    /// handlers for the asynchronous operation.
    /// </param>
    /// <returns>
    /// A <see cref="TPromise{TChat}"/> that resolves with the updated chat completion
    /// or is rejected with an exception if the update fails.
    /// </returns>
    function AsyncAwaitUpdate(const CompletionID: string;
      const ParamProc: TProc<TChatUpdateParams>;
      const CallBacks: TFunc<TPromiseChat> = nil): TPromise<TChat>;

    /// <summary>
    /// Asynchronously deletes a stored chat completion and returns a promise
    /// that resolves to a <see cref="TChatDelete"/> instance indicating the result.
    /// </summary>
    /// <param name="CompletionID">
    /// The unique identifier of the stored chat completion to delete.
    /// </param>
    /// <param name="CallBacks">
    /// Optional function returning a <see cref="TPromiseChatDelete"/> providing lifecycle
    /// callbacks for the asynchronous operation.
    /// </param>
    /// <returns>
    /// A <see cref="TPromise{TChatDelete}"/> that resolves with the deletion result or is
    /// rejected with an exception if the operation fails.
    /// </returns>
    function AsyncAwaitDelete(const CompletionID: string;
      const CallBacks: TFunc<TPromiseChatDelete> = nil): TPromise<TChatDelete>;

    /// <summary>
    /// Synchronously creates a chat completion, directly returning the chat completion
    /// object upon completion.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure that allows setting parameters for the chat completion request.
    /// </param>
    /// <returns>
    /// A TChat object containing the completion response from the model.
    /// </returns>
    function Create(const ParamProc: TProc<TChatParams>): TChat; override;

    /// <summary>
    /// Initiates a synchronous stream of chat completions, allowing for real-time interaction
    /// and updates via a provided event handler.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure that allows setting parameters for the chat completion request.
    /// </param>
    /// <param name="Event">
    /// An event handler that processes the streamed chat completion data.
    /// </param>
    /// <returns>
    /// Returns True if the streaming session is initiated successfully, otherwise False.
    /// </returns>
    function CreateStream(const ParamProc: TProc<TChatParams>;
      const Event: TStreamCallbackEvent<TChat>): Boolean; override;

    /// <summary>
    /// Retrieves a stored chat completion by its unique identifier.
    /// </summary>
    /// <param name="CompletionID">
    /// The identifier of the chat completion to retrieve.
    /// </param>
    /// <returns>
    /// A <see cref="TChat"/> instance containing the retrieved completion data.
    /// </returns>
    /// <remarks>
    /// Only completions that were created with storage enabled (Store = True) can be fetched.
    /// An exception is raised if the specified CompletionID does not exist or access is denied.
    /// </remarks>
    function GetCompletion(const CompletionID: string): TChat; override;

    /// <summary>
    /// Retrieves the messages of a stored chat completion.
    /// </summary>
    /// <param name="CompletionID">
    /// The identifier of the chat completion whose messages to retrieve.
    /// </param>
    /// <returns>
    /// A <see cref="TChatMessages"/> instance containing the list of messages.
    /// </returns>
    /// <remarks>
    /// Only messages from completions created with storage enabled (Store = True) will be returned.
    /// An exception is raised if the CompletionID does not exist or access is denied.
    /// </remarks>
    function GetMessages(const CompletionID: string): TChatMessages; overload; override;

    /// <summary>
    /// Retrieves the messages of a stored chat completion with custom query parameters.
    /// </summary>
    /// <param name="CompletionID">
    /// The identifier of the chat completion whose messages to retrieve.
    /// </param>
    /// <param name="ParamProc">
    /// A procedure to configure <see cref="TUrlChatParams"/> for pagination, filtering, and ordering.
    /// </param>
    /// <returns>
    /// A <see cref="TChatMessages"/> instance containing the list of messages.
    /// </returns>
    /// <remarks>
    /// Only messages from completions created with storage enabled (Store = True) will be returned.
    /// Use <c>ParamProc</c> to set parameters such as <c>After</c>, <c>Limit</c>, and <c>Order</c>.
    /// An exception is raised if the specified CompletionID does not exist or access is denied.
    /// </remarks>
    function GetMessages(const CompletionID: string;
      const ParamProc: TProc<TUrlChatParams>): TChatMessages; overload; override;

    /// <summary>
    /// Retrieves a paginated list of stored chat completions.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure to configure <see cref="TUrlChatListParams"/> for pagination, metadata filtering, model filtering, and sort order.
    /// </param>
    /// <returns>
    /// A <see cref="TChatCompletion"/> instance containing the list of chat completions and pagination cursors.
    /// </returns>
    /// <remarks>
    /// Only completions that were created with storage enabled (Store = True) will be included.
    /// Use <c>ParamProc</c> to set options such as <c>After</c>, <c>Limit</c>, <c>Metadata</c>, <c>Model</c>, and <c>Order</c>.
    /// An exception is raised if access is denied.
    /// </remarks>
    function List(const ParamProc: TProc<TUrlChatListParams>): TChatCompletion; override;

    /// <summary>
    /// Updates metadata of a stored chat completion.
    /// </summary>
    /// <param name="CompletionID">
    /// The identifier of the chat completion to update.
    /// </param>
    /// <param name="ParamProc">
    /// A procedure to configure <see cref="TChatUpdateParams"/> for metadata modifications.
    /// </param>
    /// <returns>
    /// A <see cref="TChat"/> instance containing the updated chat completion.
    /// </returns>
    /// <remarks>
    /// Only completions created with storage enabled (Store = True) can be modified.
    /// Currently, only metadata updates are supported. An exception is raised if the
    /// specified CompletionID does not exist or access is denied.
    /// </remarks>
    function Update(const CompletionID: string;
      const ParamProc: TProc<TChatUpdateParams>): TChat; override;

    /// <summary>
    /// Deletes a stored chat completion.
    /// </summary>
    /// <param name="CompletionID">
    /// The identifier of the chat completion to delete.
    /// </param>
    /// <returns>
    /// A <see cref="TChatDelete"/> instance indicating whether the deletion was successful.
    /// </returns>
    /// <remarks>
    /// Only completions created with storage enabled (<c>Store = True</c>) can be deleted.
    /// An exception is raised if the specified <paramref name="CompletionID"/> does not exist or access is denied.
    /// </remarks>
    function Delete(const CompletionID: string): TChatDelete; override;

    /// <summary>
    /// Initiates parallel processing of chat prompts by creating multiple chat completions
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
    procedure CreateParallel(const ParamProc: TProc<TBundleParams>;
      const CallBacks: TFunc<TAsynBundleList>);
  end;

implementation

uses
  System.Threading,
  GenAI.Async.Params, GenAI.API.SSEDecoder, GenAI.API.Streams,
  GenAI.Consts;

{ TAsynchronousSupport }

function TChatRoute.AsyncAwaitCreate(const ParamProc: TProc<TChatParams>;
  const CallBacks: TFunc<TPromiseChat>): TPromise<TChat>;
begin
  Result := TAsyncAwaitHelper.WrapAsyncAwait<TChat>(
    procedure(const CallBackParams: TFunc<TAsynChat>)
    begin
      AsynCreate(ParamProc, CallBackParams);
    end,
    CallBacks);
end;

function TChatRoute.AsyncAwaitCreateStream(const ParamProc: TProc<TChatParams>;
  const CallBacks: TFunc<TPromiseChatStream>): TPromise<string>;
begin
  Result := TPromise<string>.Create(
    procedure(Resolve: TProc<string>; Reject: TProc<Exception>)
    var
      Buffer: string;
      CallBackParams: IUseParams<TPromiseChatStream>;
      PromiseCallbacks: TPromiseChatStream;
    begin
      CallBackParams := TUseParamsFactory<TPromiseChatStream>.CreateInstance(CallBacks);
      PromiseCallbacks := CallBackParams.Param;

      AsynCreateStream(ParamProc,
        function : TAsynChatStream
        begin
          Result.Sender := PromiseCallbacks.Sender;

          Result.OnStart := PromiseCallbacks.OnStart;

          Result.OnProgress :=
            procedure (Sender: TObject; Event: TChat)
            begin
              if Assigned(PromiseCallbacks.OnProgress) then
                PromiseCallbacks.OnProgress(Sender, Event);
              try
                if Assigned(Event) and (Length(Event.Choices) > 0) and
                   Assigned(Event.Choices[0]) and Assigned(Event.Choices[0].Delta) then
                  Buffer := Buffer + Event.Choices[0].Delta.Content;
              except
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
              if Assigned(PromiseCallbacks.OnError) then
                Error := PromiseCallbacks.OnError(Sender, Error);
              Reject(Exception.Create(Error));
            end;

          Result.OnDoCancel :=
            function : Boolean
            begin
              if Assigned(PromiseCallbacks.OnDoCancel) then
                Result := PromiseCallbacks.OnDoCancel()
              else
                Result := False;
            end;

          Result.OnCancellation :=
            procedure (Sender: TObject)
            begin
              var Error := 'aborted';
              if Assigned(PromiseCallbacks.OnCancellation) then
                Error := PromiseCallbacks.OnCancellation(Sender);
              Reject(Exception.Create(Error));
            end;
        end);
    end);
end;

function TChatRoute.AsyncAwaitDelete(const CompletionID: string;
  const CallBacks: TFunc<TPromiseChatDelete>): TPromise<TChatDelete>;
begin
  Result := TAsyncAwaitHelper.WrapAsyncAwait<TChatDelete>(
    procedure(const CallBackParams: TFunc<TAsynChatDelete>)
    begin
      AsynDelete(CompletionID, CallBackParams);
    end,
    CallBacks);
end;

function TChatRoute.AsyncAwaitGetCompletion(const CompletionID: string;
  const CallBacks: TFunc<TPromiseChat>): TPromise<TChat>;
begin
  Result := TAsyncAwaitHelper.WrapAsyncAwait<TChat>(
    procedure(const CallBackParams: TFunc<TAsynChat>)
    begin
      AsynGetCompletion(CompletionID, CallBackParams);
    end,
    CallBacks);
end;

function TChatRoute.AsyncAwaitGetMessages(const CompletionID: string;
  const CallBacks: TFunc<TPromiseChatMessages>): TPromise<TChatMessages>;
begin
  Result := TAsyncAwaitHelper.WrapAsyncAwait<TChatMessages>(
    procedure(const CallBackParams: TFunc<TAsynChatMessages>)
    begin
      AsynGetMessages(CompletionID, CallBackParams);
    end,
    CallBacks);
end;

function TChatRoute.AsyncAwaitGetMessages(const CompletionID: string;
  const ParamProc: TProc<TUrlChatParams>;
  const CallBacks: TFunc<TPromiseChatMessages>): TPromise<TChatMessages>;
begin
  Result := TAsyncAwaitHelper.WrapAsyncAwait<TChatMessages>(
    procedure(const CallBackParams: TFunc<TAsynChatMessages>)
    begin
      AsynGetMessages(CompletionID, ParamProc, CallBackParams);
    end,
    CallBacks);
end;

function TChatRoute.AsyncAwaitList(const ParamProc: TProc<TUrlChatListParams>;
  const CallBacks: TFunc<TPromiseChatCompletion>): TPromise<TChatCompletion>;
begin
  Result := TAsyncAwaitHelper.WrapAsyncAwait<TChatCompletion>(
    procedure(const CallBackParams: TFunc<TAsynChatCompletion>)
    begin
      AsynList(ParamProc, CallBackParams);
    end,
    CallBacks);
end;

function TChatRoute.AsyncAwaitUpdate(const CompletionID: string;
  const ParamProc: TProc<TChatUpdateParams>;
  const CallBacks: TFunc<TPromiseChat>): TPromise<TChat>;
begin
  Result := TAsyncAwaitHelper.WrapAsyncAwait<TChat>(
    procedure(const CallBackParams: TFunc<TAsynChat>)
    begin
      AsynUpdate(CompletionID, ParamProc, CallBackParams);
    end,
    CallBacks);
end;

procedure TAsynchronousSupport.AsynCreate(const ParamProc: TProc<TChatParams>;
  const CallBacks: TFunc<TAsynChat>);
begin
  with TAsynCallBackExec<TAsynChat, TChat>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TChat
      begin
        Result := Self.Create(ParamProc);
      end);
  finally
    Free;
  end;
end;

procedure TAsynchronousSupport.AsynCreateStream(const ParamProc: TProc<TChatParams>;
  const CallBacks: TFunc<TAsynChatStream>);
begin
  var CallBackParams := TUseParamsFactory<TAsynChatStream>.CreateInstance(CallBacks);

  var Sender := CallBackParams.Param.Sender;
  var OnStart := CallBackParams.Param.OnStart;
  var OnSuccess := CallBackParams.Param.OnSuccess;
  var OnProgress := CallBackParams.Param.OnProgress;
  var OnError := CallBackParams.Param.OnError;
  var OnCancellation := CallBackParams.Param.OnCancellation;
  var OnDoCancel := CallBackParams.Param.OnDoCancel;
  var CancelTag := 0;

  var Task: ITask := TTask.Create(
          procedure()
          begin
            {--- Pass the instance of the current class in case no value was specified. }
            if not Assigned(Sender) then
              Sender := Self;

            {--- Trigger OnStart callback }
            if Assigned(OnStart) then
              TThread.Queue(nil,
                procedure
                begin
                  OnStart(Sender);
                end);
            try
              var Stop := False;

              {--- Processing }
              CreateStream(ParamProc,
                procedure (var Chat: TChat; IsDone: Boolean; var Cancel: Boolean)
                begin
                  {--- Check that the process has not been canceled }
                  if Assigned(OnDoCancel) and (CancelTag = 0) then
                    TThread.Queue(nil,
                        procedure
                        begin
                          Stop := OnDoCancel();
                          if Stop then
                            Inc(CancelTag);
                        end);
                  if Stop then
                    begin
                      {--- Trigger when processus was stopped }
                      if (CancelTag = 1) and Assigned(OnCancellation) then
                        TThread.Queue(nil,
                        procedure
                        begin
                          OnCancellation(Sender);
                        end);
                      Inc(CancelTag);
                      Cancel := True;
                      Exit;
                    end;
                  if not IsDone and Assigned(Chat) then
                    begin
                      var LocalChat := Chat;
                      Chat := nil;

                      {--- Triggered when processus is progressing }
                      if Assigned(OnProgress) then
                        TThread.Synchronize(TThread.Current,
                        procedure
                        begin
                          try
                            OnProgress(Sender, LocalChat);
                          finally
                            {--- Makes sure to release the instance containing the data obtained
                                 following processing}
                            LocalChat.Free;
                          end;
                        end)
                     else
                       LocalChat.Free;
                    end
                  else
                  if IsDone then
                    begin
                      {--- Trigger OnEnd callback when the process is done }
                      if Assigned(OnSuccess) then
                        TThread.Queue(nil,
                        procedure
                        begin
                          OnSuccess(Sender);
                        end);
                    end;
                end);
            except
              on E: Exception do
                begin
                  var Error := AcquireExceptionObject;
                  try
                    var ErrorMsg := (Error as Exception).Message;

                    {--- Trigger OnError callback if the process has failed }
                    if Assigned(OnError) then
                      TThread.Queue(nil,
                      procedure
                      begin
                        OnError(Sender, ErrorMsg);
                      end);
                  finally
                    {--- Ensures that the instance of the caught exception is released}
                    Error.Free;
                  end;
                end;
            end;
          end);
  Task.Start;
end;

procedure TAsynchronousSupport.AsynDelete(const CompletionID: string;
  const CallBacks: TFunc<TAsynChatDelete>);
begin
  with TAsynCallBackExec<TAsynChatDelete, TChatDelete>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TChatDelete
      begin
        Result := Self.Delete(CompletionID);
      end);
  finally
    Free;
  end;
end;

procedure TAsynchronousSupport.AsynGetCompletion(const CompletionID: string;
  const CallBacks: TFunc<TAsynChat>);
begin
  with TAsynCallBackExec<TAsynChat, TChat>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TChat
      begin
        Result := Self.GetCompletion(CompletionID);
      end);
  finally
    Free;
  end;
end;

procedure TAsynchronousSupport.AsynGetMessages(const CompletionID: string;
  const CallBacks: TFunc<TAsynChatMessages>);
begin
  with TAsynCallBackExec<TAsynChatMessages, TChatMessages>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TChatMessages
      begin
        Result := Self.GetMessages(CompletionID);
      end);
  finally
    Free;
  end;
end;

procedure TAsynchronousSupport.AsynGetMessages(const CompletionID: string;
  const ParamProc: TProc<TUrlChatParams>;
  const CallBacks: TFunc<TAsynChatMessages>);
begin
  with TAsynCallBackExec<TAsynChatMessages, TChatMessages>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TChatMessages
      begin
        Result := Self.GetMessages(CompletionID, ParamProc);
      end);
  finally
    Free;
  end;
end;

procedure TAsynchronousSupport.AsynList(const ParamProc: TProc<TUrlChatListParams>;
  const CallBacks: TFunc<TAsynChatCompletion>);
begin
  with TAsynCallBackExec<TAsynChatCompletion, TChatCompletion>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TChatCompletion
      begin
        Result := Self.List(ParamProc);
      end);
  finally
    Free;
  end;
end;

procedure TAsynchronousSupport.AsynUpdate(const CompletionID: string;
  const ParamProc: TProc<TChatUpdateParams>;
  const CallBacks: TFunc<TAsynChat>);
begin
  with TAsynCallBackExec<TAsynChat, TChat>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TChat
      begin
        Result := Self.Update(CompletionID, ParamProc);
      end);
  finally
    Free;
  end;
end;

{ TChatRoute }

function TChatRoute.Create(const ParamProc: TProc<TChatParams>): TChat;
begin
  Result := API.Post<TChat, TChatParams>('chat/completions', ParamProc);
end;

procedure TChatRoute.CreateParallel(const ParamProc: TProc<TBundleParams>;
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

    var CallBackParams := TUseParamsFactory<TAsynBundleList>.CreateInstance(CallBacks);
    var Sender := CallBackParams.Param.Sender;
    var OnStart := CallBackParams.Param.OnStart;
    var OnSuccess := CallBackParams.Param.OnSuccess;
    var OnError := CallBackParams.Param.OnError;

    if not Assigned(Sender) then
      Sender := Self;

    var Bundle := TBundleList.Create;
    var Ranking := 0;
    var ErrorExists := False;
    var Prompts := BundleParams.GetPrompt;
    var Counter := Length(Prompts);

    {--- Set the reasoning effort if necessary }
    if IsReasoningModel(BundleParams.GetModel) then
      ReasoningEffort := BundleParams.GetReasoningEffort
    else
      ReasoningEffort := EmptyStr;

    if Assigned(OnStart) then
      OnStart(Sender);

    if Counter = 0 then
      begin
        try
          if Assigned(OnSuccess) then
            OnSuccess(Sender, Bundle);
        finally
          Bundle.Free;
        end;
        Exit;
      end;

    SetLength(Tasks, Length(Prompts));
    for var Index := 0 to Pred(Length(Prompts)) do
      begin
        var PromptIndex := Index;
        Tasks[PromptIndex] := TTask.Run(
          procedure
          begin
            var Buffer := Bundle.Add(PromptIndex + 1);
            Buffer.Prompt := Prompts[PromptIndex];
            try
              var Chat := Create(
                procedure (Params: TChatParams)
                begin
                  {--- Set the model for the process }
                  Params.Model(BundleParams.GetModel);

                  {--- If reasoning model then set de reasoning parameters }
                  if not ReasoningEffort.IsEmpty then
                    Params.ReasoningEffort(ReasoningEffort);

                  {--- Set the current prompt and developer message }
                  Params.Messages([
                    TMessagePayload.Developer(BundleParams.GetSystem),
                    TMessagePayload.User(Buffer.Prompt)
                  ]);

                  {--- Set the web search parameters if necessary }
                  if not BundleParams.GetSearchSize.IsEmpty then
                    begin
                      {---- Set the location if necessary }
                      if not BundleParams.GetCity.IsEmpty or
                         not BundleParams.GetCountry.IsEmpty then
                        begin
                          var Locate := TUserLocationApproximate.Create;

                          {--- Process for the city location }
                          if not BundleParams.GetCity.IsEmpty then
                            Locate.City(BundleParams.GetCity);

                            {--- Process for the country location }
                          if not BundleParams.GetCountry.IsEmpty then
                            Locate.Country(BundleParams.GetCountry);

                          {--- Set the web search options }
                          Params.WebSearchOptions(BundleParams.GetSearchSize, Locate);
                        end
                      else
                        begin
                          {--- Set the web search options }
                          Params.WebSearchOptions(BundleParams.GetSearchSize);
                        end;
                    end;
                end);

              TMonitor.Enter(Bundle);
              try
                Inc(Ranking);
                Buffer.FinishIndex := Ranking;
              finally
                TMonitor.Exit(Bundle);
              end;

              Buffer.Response := Chat.Choices[0].Message.Content;
              Buffer.Chat := Chat;
            except
              on E: Exception do
                begin
                  {--- Catch the exception }
                  var Error := AcquireExceptionObject;
                  ErrorExists := True;
                  try
                    var ErrorMsg := (Error as Exception).Message;
                    {--- Trigger OnError callback if the process has failed }
                    if Assigned(OnError) then
                      TThread.Queue(nil,
                      procedure
                      begin
                        OnError(Sender, ErrorMsg);
                      end);
                  finally
                    {--- Ensures that the instance of the caught exception is released}
                    Error.Free;
                  end;
                end;
            end;
          end);

        if ErrorExists then
          Continue;

        {--- TTask.WaitForAll is not used due to a memory leak in TLightweightEvent/TCompleteEventsWrapper.
             See report RSP-12462 and RSP-25999. }
        TTaskHelper.ContinueWith(Tasks[PromptIndex],
          procedure
          begin
            Dec(Counter);
            if Counter = 0 then
              begin
                try
                  if not ErrorExists and Assigned(OnSuccess) then
                    OnSuccess(Sender, Bundle);
                finally
                  Bundle.Free;
                end;
              end;
          end);
        {--- Need a delay, otherwise the process runs only with the first task. }
        Sleep(30);
      end;
  finally
    BundleParams.Free;
  end;
end;

function TChatRoute.CreateStream(const ParamProc: TProc<TChatParams>;
  const Event: TStreamCallbackEvent<TChat>): Boolean;
var
  Response: TLockedMemoryStream;
  RetPos: Int64;
  Decoder: TSSEDecoder;
  DoneSent: Boolean;
  AbortFlag: Boolean;

begin
  Response := TLockedMemoryStream.Create;
  try
    RetPos := 0;
    DoneSent := False;
    AbortFlag := False;

    var EmitDone :=
      procedure(var AAbort: Boolean)
      var
        Content: TChat;
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
        Content: TChat;
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
            Content := TApiDeserializer.Parse<TChat>(Line);
          except
            Content := nil;
          end;

          if Assigned(Event) and Assigned(Content) then
            Event(Content, False, AAbort);
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
      Result := API.Post<TChatParams>(
        'chat/completions',
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

function TChatRoute.Delete(const CompletionID: string): TChatDelete;
begin
  Result := API.Delete<TChatDelete>('chat/completions/' + CompletionID);
end;

function TChatRoute.GetCompletion(const CompletionID: string): TChat;
begin
  Result := API.Get<TChat>('chat/completions/' + CompletionID);
end;

function TChatRoute.GetMessages(const CompletionID: string;
  const ParamProc: TProc<TUrlChatParams>): TChatMessages;
begin
  Result := API.Get<TChatMessages, TUrlChatParams>('chat/completions/' + CompletionID + '/messages', ParamProc);
end;

function TChatRoute.GetMessages(const CompletionID: string): TChatMessages;
begin
  Result := API.Get<TChatMessages>('chat/completions/' + CompletionID + '/messages');
end;

function TChatRoute.List(const ParamProc: TProc<TUrlChatListParams>): TChatCompletion;
begin
  Result := API.Get<TChatCompletion, TUrlChatListParams>('chat/completions', ParamProc);
end;

function TChatRoute.Update(const CompletionID: string;
  const ParamProc: TProc<TChatUpdateParams>): TChat;
begin
  Result := API.Post<TChat, TChatUpdateParams>('chat/completions/' + CompletionID, ParamProc);
end;

end.
