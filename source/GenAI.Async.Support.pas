unit GenAI.Async.Support;

{-------------------------------------------------------------------------------

      Unit containing  records for managing  asynchronous events related to
      chat requests.

      The  GenAI.Chat.AsyncEvents  unit  provides  definitions for the
      TAsyncParams<T>  and  TAsynStreamParams<T>  records, which  are  used
      to  handle  the lifecycle  of asynchronous chat operations, including
      starting, progressing, succeeding, and handling errors.
      These records enable non-blocking operations for chat functionalities
      and can be reused across multiple modules.

      This  unit  depends  on GenAI.Async.Params  for parameter  management.
      The IUseParams<T>  and  TUseParamsFactory<T>  interfaces  and  classes
      from  GenAI.Params.Core  are  utilized  to  create and manage the
      parameter  instances  for  asynchronous  operations.

        Github repository :  https://github.com/MaxiDonkey/DelphiGenAI
        Visit the Github repository for the documentation and use examples

-------------------------------------------------------------------------------}

interface

uses
  System.SysUtils, system.Classes, System.Threading, GenAI.Async.Params;

type
  /// <summary>
  /// Record used to handle asynchronous request events.
  /// </summary>
  /// <remarks>
  /// <c>TAsynCallBack</c> manages the lifecycle of an asynchronous request.
  /// It provides callbacks for different stages of the request, such as start, successful completion, or error.
  /// </remarks>
  TAsynCallBack<T> = record
  private
    FSender: TObject;
    FOnStart: TProc<TObject>;
    FOnSuccess: TProc<TObject, T>;
    FOnError: TProc<TObject, string>;
  public
    /// <summary>
    /// Object representing the sender of the asynchronous operation.
    /// </summary>
    /// <remarks>
    /// The <c>Sender</c> property is used to identify or store a reference to the object that initiated the request.
    /// This can be useful for providing context in the callback procedures.
    /// </remarks>
    property Sender: TObject read FSender write FSender;
    /// <summary>
    /// Event triggered at the start of the asynchronous request.
    /// </summary>
    /// <remarks>
    /// The <c>OnStart</c> event is called when the request begins.
    /// It can be used to initialize any required state or display a loading indicator to the user.
    /// <code>
    /// OnStart :=
    ///    procedure (Sender: TObject)
    ///    begin
    ///      // Code executed at the start of the request
    ///    end;
    /// </code>
    /// </remarks>
    property OnStart: TProc<TObject> read FOnStart write FOnStart;
    /// <summary>
    /// Event triggered at the end of the asynchronous request.
    /// </summary>
    /// <param name="Sender">
    /// Object that initiated the request, generally used for context.
    /// </param>
    /// <param name="Result">
    /// The result of type <c>T</c> returned at the end of the request.
    /// This event is used to process the final result of the asynchronous operation.
    /// </param>
    /// <remarks>
    /// The <c>OnSuccess</c> event is invoked when the process completes successfully.
    /// It can be used to perform final actions based on the received result.
    /// <code>
    /// OnSuccess :=
    ///    procedure (Sender: TObject; Result: T)
    ///    begin
    ///      // Code executed at the end of the request with the obtained result
    ///    end;
    /// </code>
    /// </remarks>
    property OnSuccess: TProc<TObject, T> read FOnSuccess write FOnSuccess;
    /// <summary>
    /// Event triggered when an error occurs during the asynchronous request.
    /// </summary>
    /// <param name="Sender">
    /// Object that initiated the request, generally used for context.
    /// </param>
    /// <param name="ErrorMessage">
    /// The error message received, which can be logged or displayed to the user.
    /// </param>
    /// <remarks>
    /// The <c>OnError</c> event is called when an error occurs during the asynchronous operation.
    /// It can be used to handle failures, display error messages, or perform any necessary cleanup actions.
    /// <code>
    /// OnError :=
    ///    procedure (Sender: TObject; ErrorMessage: string)
    ///    begin
    ///      // Code executed when an error occurs during the request
    ///    end;
    /// </code>
    /// </remarks>
    property OnError: TProc<TObject, string> read FOnError write FOnError;
  end;

  TPromiseCallBack<T> = record
  private
    FSender: TObject;
    FOnStart: TProc<TObject>;
    FOnSuccess: TFunc<TObject, T, string>;
    FOnError: TFunc<TObject, string, string>;
  public
    /// <summary>
    /// Object representing the sender of the asynchronous operation.
    /// </summary>
    /// <remarks>
    /// The <c>Sender</c> property is used to identify or store a reference to the object that initiated the request.
    /// This can be useful for providing context in the callback procedures.
    /// </remarks>
    property Sender: TObject read FSender write FSender;
    /// <summary>
    /// Event triggered at the start of the asynchronous request.
    /// </summary>
    /// <remarks>
    /// The <c>OnStart</c> event is called when the request begins.
    /// It can be used to initialize any required state or display a loading indicator to the user.
    /// <code>
    /// OnStart :=
    ///    procedure (Sender: TObject)
    ///    begin
    ///      // Code executed at the start of the request
    ///    end;
    /// </code>
    /// </remarks>
    property OnStart: TProc<TObject> read FOnStart write FOnStart;
    /// <summary>
    /// Event triggered at the end of the asynchronous request.
    /// </summary>
    /// <param name="Sender">
    /// Object that initiated the request, generally used for context.
    /// </param>
    /// <param name="Result">
    /// The result of type <c>T</c> returned at the end of the request.
    /// This event is used to process the final result of the asynchronous operation.
    /// </param>
    /// <remarks>
    /// The <c>OnSuccess</c> event is invoked when the process completes successfully.
    /// It can be used to perform final actions based on the received result.
    /// <code>
    /// OnSuccess :=
    ///    function (Sender: TObject; Result: T): string
    ///    begin
    ///      // Code executed at the end of the request with the obtained result
    ///      Result := String_builded_from_Result;
    ///    end;
    /// </code>
    /// </remarks>
    property OnSuccess: TFunc<TObject, T, string> read FOnSuccess write FOnSuccess;
    /// <summary>
    /// Event triggered when an error occurs during the asynchronous request.
    /// </summary>
    /// <param name="Sender">
    /// Object that initiated the request, generally used for context.
    /// </param>
    /// <param name="ErrorMessage">
    /// The error message received, which can be logged or displayed to the user.
    /// </param>
    /// <remarks>
    /// The <c>OnError</c> event is called when an error occurs during the asynchronous operation.
    /// It can be used to handle failures, display error messages, or perform any necessary cleanup actions.
    /// <code>
    /// OnError :=
    ///    function (Sender: TObject; ErrorMessage: string) : string
    ///    begin
    ///      // Code executed when an error occurs during the request
    ///      Result := String_from_error;
    ///    end;
    /// </code>
    /// </remarks>
    property OnError: TFunc<TObject, string, string> read FOnError write FOnError;
  end;

  /// <summary>
  /// Class used to manage asynchronous execution with callback events.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynCallBackExec&lt;T, U&gt;</c> class allows you to execute asynchronous operations with specified callbacks for start, completion, and error events.
  /// It encapsulates the asynchronous execution logic, handling thread management and exception handling, providing an easy way to manage the lifecycle of an asynchronous request.
  /// </remarks>
  TAsynCallBackExec<T; U: class> = class
  private
    FUse: IUseParams<T>;
    FSender: TObject;
    FOnStart: TProc<TObject>;
    FOnSuccess: TProc<TObject, U>;
    FOnError: TProc<TObject, string>;
  public
    /// <summary>
    /// Gets the <c>IUseParams&lt;T&gt;</c> interface instance used by this class.
    /// </summary>
    /// <value>
    /// An instance of <c>IUseParams&lt;T&gt;</c> that provides parameter management functionality.
    /// </value>
    property Use: IUseParams<T> read FUse;
    /// <summary>
    /// The object representing the sender of the asynchronous operation.
    /// </summary>
    /// <value>
    /// An instance of <c>TObject</c> identifying the originator of the operation.
    /// </value>
    /// <remarks>
    /// This property can be set to identify the object that initiated the asynchronous operation, which is useful in callback methods.
    /// </remarks>
    property Sender: TObject read FSender write FSender;
    /// <summary>
    /// Event triggered when the asynchronous operation starts.
    /// </summary>
    /// <value>
    /// A procedure of type <c>TProc&lt;TObject&gt;</c> to handle any setup or UI updates when the operation begins.
    /// </value>
    /// <remarks>
    /// Assign a procedure to this event to perform actions at the start of the asynchronous operation.
    /// <code>
    /// OnStart :=
    ///    procedure (Sender: TObject)
    ///    begin
    ///      // Code executed at the start of the request
    ///    end;
    /// </code>
    /// </remarks>
    property OnStart: TProc<TObject> read FOnStart write FOnStart;
    /// <summary>
    /// Event triggered when the asynchronous operation completes successfully.
    /// </summary>
    /// <value>
    /// A procedure of type <c>TProc&lt;TObject, U&gt;</c> to handle the result of the operation.
    /// </value>
    /// <remarks>
    /// Assign a procedure to this event to process the result returned by the operation.
    /// <code>
    /// OnSuccess :=
    ///    procedure (Sender: TObject; Result: T)
    ///    begin
    ///      // Code executed at the end of the request with the obtained result
    ///    end;
    /// </code>
    /// </remarks>
    property OnSuccess: TProc<TObject, U> read FOnSuccess write FOnSuccess;
    /// <summary>
    /// Event triggered when an error occurs during the asynchronous operation.
    /// </summary>
    /// <value>
    /// A procedure of type <c>TProc&lt;TObject, string&gt;</c> to handle exceptions or errors.
    /// </value>
    /// <remarks>
    /// Assign a procedure to this event to handle any exceptions or errors that occur during execution.
    /// <code>
    /// OnError :=
    ///    procedure (Sender: TObject; ErrorMessage: string)
    ///    begin
    ///      // Code executed when an error occurs during the request
    ///    end;
    /// </code>
    /// </remarks>
    property OnError: TProc<TObject, string> read FOnError write FOnError;
    /// <summary>
    /// Executes the specified function asynchronously.
    /// </summary>
    /// <param name="Value">
    /// A function of type <c>TFunc&lt;U&gt;</c> representing the operation to execute asynchronously.
    /// </param>
    /// <remarks>
    /// This method creates and starts an asynchronous task that executes the provided function.
    /// It invokes the <c>OnStart</c> event before execution, the <c>OnSuccess</c> event upon successful completion, and the <c>OnError</c> event if an exception occurs during execution.
    /// </remarks>
    procedure Run(Value: TFunc<U>);
    /// <summary>
    /// Initializes a new instance of the <c>TAsynCallBackExec&lt;T, U&gt;</c> class with the specified parameter function.
    /// </summary>
    /// <param name="Value">
    /// A function of type <c>TFunc&lt;T&gt;</c> used to create an instance of <c>IUseParams&lt;T&gt;</c>.
    /// </param>
    /// <remarks>
    /// The constructor initializes the internal <c>IUseParams&lt;T&gt;</c> interface using the provided function.
    /// </remarks>
    constructor Create(const Value: TFunc<T>);
  end;

  /// <summary>
  /// Record used to manage asynchronous events for a streaming chat request.
  /// </summary>
  /// <remarks>
  /// <c>TAsynChatStreamParams</c> allows you to handle the lifecycle of a chat request in streaming mode.
  /// It provides callbacks for different stages such as when the request starts, progresses, succeeds, encounters an error, or needs to be canceled.
  /// </remarks>
  TAsynStreamCallBack<T> = record
  private
    FSender: TObject;
    FOnStart: TProc<TObject>;
    FOnSuccess: TProc<TObject>;
    FOnProgress: TProc<TObject, T>;
    FOnError: TProc<TObject, string>;
    FOnCancellation: TProc<TObject>;
    FOnDoCancel: TFunc<Boolean>;
  public
    /// <summary>
    /// The object representing the sender of the asynchronous operation.
    /// </summary>
    /// <remarks>
    /// The <c>Sender</c> property is used to identify or store a reference to the object that initiated the chat request,
    /// which can be useful for context within the callback procedures.
    /// </remarks>
    property Sender: TObject read FSender write FSender;
    /// <summary>
    /// Event triggered when the asynchronous chat request starts.
    /// </summary>
    /// <param name="Sender">
    /// The object that initiated the request, typically used for context.
    /// </param>
    /// <param name="Chat">
    /// The <c>TChat</c> object representing the current response chunk received from the model.
    /// This event can be used to update the user interface as new tokens are streamed in.
    /// </param>
    /// <remarks>
    /// The <c>OnStart</c> event is called when the chat request begins. It can be used to set up any initial state or display a loading indicator to the user.
    /// <code>
    /// OnStart :=
    ///    procedure (Sender: TObject)
    ///    begin
    ///      // code when chat request begin
    ///    end;
    /// </code>
    /// </remarks>
    property OnStart: TProc<TObject> read FOnStart write FOnStart;
    /// <summary>
    /// Event triggered when the asynchronous Data request completes successfully.
    /// </summary>
    /// <param name="Sender">
    /// The object that initiated the request, typically used for context.
    /// </param>
    /// <param name="Data">
    /// The <c>TChat</c> object representing the current response chunk received from the model.
    /// This event can be used to update the user interface as new tokens are streamed in.
    /// </param>
    /// <remarks>
    /// The <c>OnSuccess</c> event is invoked when the streaming process finishes successfully.
    /// It does not provide additional data, as the result is expected to have been handled progressively via the <c>OnProgress</c> event.
    /// <code>
    /// OnSuccess :=
    ///    procedure (Sender: TObject; Data: T)
    ///    begin
    ///      // code when the streaming process finishes successfully
    ///    end;
    /// </code>
    /// </remarks>
    property OnSuccess: TProc<TObject> read FOnSuccess write FOnSuccess;
    /// <summary>
    /// Event triggered to handle progress during the streaming Data request.
    /// </summary>
    /// <param name="Sender">
    /// The object that initiated the request, typically used for context.
    /// </param>
    /// <param name="Data">
    /// The <c>TChat</c> object representing the current response chunk received from the model.
    /// This event can be used to update the user interface as new tokens are streamed in.
    /// </param>
    /// <remarks>
    /// The <c>OnProgress</c> event is fired every time a new chunk of data is received during the streaming process.
    /// This allows the application to handle the response progressively as it is generated by the model.
    /// <code>
    /// OnProgress :=
    ///    procedure (Sender: TObject; Data: T)
    ///    begin
    ///      // code to handle the response progressively
    ///    end;
    /// </code>
    /// </remarks>
    property OnProgress: TProc<TObject, T> read FOnProgress write FOnProgress;
    /// <summary>
    /// Event triggered when an error occurs during the asynchronous request.
    /// </summary>
    /// <param name="Sender">
    /// The object that initiated the request, typically used for context.
    /// </param>
    /// <param name="ErrorMessage">
    /// The error message received, which can be logged or displayed to the user.
    /// </param>
    /// <remarks>
    /// The <c>OnError</c> event is called when an error occurs during the streaming process.
    /// This can be used to handle failures, show error messages, or perform any necessary clean-up actions.
    /// <code>
    /// OnError :=
    ///    procedure (Sender: TObject; message: string)
    ///    begin
    ///      // code to handle an error occurs during the streaming process
    ///    end;
    /// </code>
    /// </remarks>
    property OnError: TProc<TObject, string> read FOnError write FOnError;
    /// <summary>
    /// Event triggered when the asynchronous request has been canceled.
    /// </summary>
    /// <remarks>
    /// The <c>OnCancellation</c> event is fired when the chat request is canceled by the user or the application.
    /// This can be used to perform clean-up operations or notify the user that the request has been terminated.
    /// <code>
    /// OnCancellation :=
    ///    procedure (Sender: TObject)
    ///    begin
    ///      // code to handle chat request cancellation
    ///    end;
    /// </code>
    /// </remarks>
    property OnCancellation: TProc<TObject> read FOnCancellation write FOnCancellation;
    /// <summary>
    /// Function called to determine if the asynchronous chat request should be canceled.
    /// </summary>
    /// <returns>
    /// A <c>Boolean</c> value indicating whether the request should be canceled (<c>True</c>) or allowed to continue (<c>False</c>).
    /// </returns>
    /// <remarks>
    /// The <c>OnDoCancel</c> function is periodically invoked to check whether the user or application has requested to cancel the chat request.
    /// If the function returns <c>True</c>, the streaming process will be aborted.
    /// <code>
    /// OnDoCancel :=
    ///    function : Boolean
    ///    begin
    ///      Result := ... // True to stop the streaming process
    ///    end;
    /// </code>
    /// </remarks>
    property OnDoCancel: TFunc<Boolean> read FOnDoCancel write FOnDoCancel;
  end;

  TPromiseStreamCallBack<T> = record
  private
    FSender: TObject;
    FOnStart: TProc<TObject>;
    FOnSuccess: TFunc<TObject, string>;
    FOnProgress: TProc<TObject, T>;
    FOnError: TFunc<TObject, string, string>;
    FOnCancellation: TFunc<TObject, string>;
    FOnDoCancel: TFunc<Boolean>;
  public
    /// <summary>
    /// The object representing the sender of the asynchronous operation.
    /// </summary>
    /// <remarks>
    /// The <c>Sender</c> property is used to identify or store a reference to the object that initiated the chat request,
    /// which can be useful for context within the callback procedures.
    /// </remarks>
    property Sender: TObject read FSender write FSender;
    /// <summary>
    /// Event triggered when the asynchronous chat request starts.
    /// </summary>
    /// <param name="Sender">
    /// The object that initiated the request, typically used for context.
    /// </param>
    /// <param name="Chat">
    /// The <c>TChat</c> object representing the current response chunk received from the model.
    /// This event can be used to update the user interface as new tokens are streamed in.
    /// </param>
    /// <remarks>
    /// The <c>OnStart</c> event is called when the chat request begins. It can be used to set up any initial state or display a loading indicator to the user.
    /// <code>
    /// OnStart :=
    ///    procedure (Sender: TObject)
    ///    begin
    ///      // code when chat request begin
    ///    end;
    /// </code>
    /// </remarks>
    property OnStart: TProc<TObject> read FOnStart write FOnStart;
    /// <summary>
    /// Event triggered when the asynchronous Data request completes successfully.
    /// </summary>
    /// <param name="Sender">
    /// The object that initiated the request, typically used for context.
    /// </param>
    /// <remarks>
    /// The <c>OnSuccess</c> event is invoked when the streaming process finishes successfully.
    /// It does not provide additional data, as the result is expected to have been handled progressively via the <c>OnProgress</c> event.
    /// <code>
    /// OnSuccess :=
    ///    function (Sender: TObject): string
    ///    begin
    ///      // code when the streaming process finishes successfully
    ///      Result := String_builded_from_Data;
    ///    end;
    /// </code>
    /// </remarks>
    property OnSuccess: TFunc<TObject, string> read FOnSuccess write FOnSuccess;
    /// <summary>
    /// Event triggered to handle progress during the streaming Data request.
    /// </summary>
    /// <param name="Sender">
    /// The object that initiated the request, typically used for context.
    /// </param>
    /// <param name="Data">
    /// The <c>T</c> object representing the current response chunk received from the model.
    /// This event can be used to update the user interface as new tokens are streamed in.
    /// </param>
    /// <remarks>
    /// The <c>OnProgress</c> event is fired every time a new chunk of data is received during the streaming process.
    /// This allows the application to handle the response progressively as it is generated by the model.
    /// <code>
    /// OnProgress :=
    ///    procedure (Sender: TObject; Data: T)
    ///    begin
    ///      // code to handle the response progressively
    ///    end;
    /// </code>
    /// </remarks>
    property OnProgress: TProc<TObject, T> read FOnProgress write FOnProgress;
    /// <summary>
    /// Event triggered when an error occurs during the asynchronous streamed request.
    /// </summary>
    /// <param name="Sender">
    /// The object that initiated the request, typically used for context.
    /// </param>
    /// <param name="ErrorMessage">
    /// The error message received, which can be logged or displayed to the user.
    /// </param>
    /// <remarks>
    /// The <c>OnError</c> event is called when an error occurs during the streaming process.
    /// This can be used to handle failures, show error messages, or perform any necessary clean-up actions.
    /// <code>
    /// OnError :=
    ///    function (Sender: TObject; message: string): string
    ///    begin
    ///      // code to handle an error occurs during the streaming process
    ///      Result := String_builded_from_message;
    ///    end;
    /// </code>
    /// </remarks>
    property OnError: TFunc<TObject, string, string> read FOnError write FOnError;
    /// <summary>
    /// Event triggered when the asynchronous request has been canceled.
    /// </summary>
    /// <remarks>
    /// The <c>OnCancellation</c> event is fired when the chat request is canceled by the user or the application.
    /// This can be used to perform clean-up operations or notify the user that the request has been terminated.
    /// <code>
    /// OnCancellation :=
    ///    function (Sender: TObject): string
    ///    begin
    ///      // code to handle chat request cancellation
    ///      Result := 'aborted'; or other string message
    ///    end;
    /// </code>
    /// </remarks>
    property OnCancellation: TFunc<TObject, string> read FOnCancellation write FOnCancellation;
    /// <summary>
    /// Function called to determine if the asynchronous chat request should be canceled.
    /// </summary>
    /// <returns>
    /// A <c>Boolean</c> value indicating whether the request should be canceled (<c>True</c>) or allowed to continue (<c>False</c>).
    /// </returns>
    /// <remarks>
    /// The <c>OnDoCancel</c> function is periodically invoked to check whether the user or application has requested to cancel the chat request.
    /// If the function returns <c>True</c>, the streaming process will be aborted.
    /// <code>
    /// OnDoCancel :=
    ///    function : Boolean
    ///    begin
    ///      Result := ... // True to stop the streaming process
    ///    end;
    /// </code>
    /// </remarks>
    property OnDoCancel: TFunc<Boolean> read FOnDoCancel write FOnDoCancel;
  end;

implementation

{ TAsynCallBackExec<T, U> }

constructor TAsynCallBackExec<T, U>.Create(const Value: TFunc<T>);
begin
  inherited Create;
  FUse := TUseParamsFactory<T>.CreateInstance(Value);
end;

procedure TAsynCallBackExec<T, U>.Run(Value: TFunc<U>);
begin
  {--- Assign callback values to internal variables for asynchrony to work properly }
  var InternalSender := Sender;
  var InternalOnStart := OnStart;
  var InternalOnSuccess := OnSuccess;
  var InternalOnError := OnError;

  var Task: ITask := TTask.Create(
          procedure()
          begin
            try
              {--- Pass the instance of the current class in case no value was specified. }
              if not Assigned(InternalSender) then
                InternalSender := Self;

              {--- Trigger OnStart callback }
              if Assigned(InternalOnStart) then
                TThread.Queue(nil,
                  procedure
                  begin
                    InternalOnStart(InternalSender);
                  end);

              {--- Processing }
              var Result := Value();

              {--- Trigger OnEnd callback when the process is done }
              TThread.Queue(nil,
                  procedure
                  begin
                    try
                      if Assigned(InternalOnSuccess) then
                        InternalOnSuccess(InternalSender, Result);
                    finally
                      {--- Makes sure to release the instance containing the data obtained
                           following processing}
                      if Assigned(Result) then
                        Result.Free;
                    end;
                  end);

            except
              on E: Exception do
                begin
                  var Error := AcquireExceptionObject;
                  try
                    var ErrorMsg := (Error as Exception).Message;

                    {--- Trigger OnError callback if the process has failed }
                    if Assigned(InternalOnError) then
                      TThread.Queue(nil,
                      procedure
                      begin
                        InternalOnError(InternalSender, ErrorMsg);
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

end.
