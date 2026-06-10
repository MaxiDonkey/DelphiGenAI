unit GenAI.Completions;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGenAI
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.SysUtils, System.Classes, System.Threading, System.JSON, REST.Json.Types,
  REST.JsonReflect,
  GenAI.API.Params, GenAI.API, GenAI.Consts, GenAI.Types, GenAI.Async.Params,
  GenAI.Async.Support, GenAI.Async.Promise, GenAI.API.Streams,
  GenAI.API.SSEDecoder, GenAI.Chat, GenAI.ChatDTO;

type
  /// <summary>
  /// Represents parameters for generating text completions using a specified model.
  /// This class provides a fluent interface to set various parameters like model,
  /// prompt, maximum tokens, and more that influence the behavior of the completion
  /// generation process.
  /// </summary>
  /// <remarks>
  /// Instances of this class can be customized using its methods to set values for
  /// different parameters like echo, stop sequences, penalties, etc. Each method
  /// modifies the instance and returns the same modified instance, allowing for
  /// method chaining.
  /// </remarks>
  TCompletionParams = class(TJSONParam)
  public
    /// <summary>
    /// Sets the model identifier used for generating completions.
    /// </summary>
    /// <param name="Value">The identifier of the model to use.</param>
    /// <returns>The instance of <c>TCompletionParams</c> for chaining.</returns>
    function Model(const Value: string): TCompletionParams;

    /// <summary>
    /// Sets the initial input prompt for the model to generate text from.
    /// </summary>
    /// <param name="Value">The text prompt to use as input for the model.</param>
    /// <returns>The instance of <c>TCompletionParams</c> for chaining.</returns>
    function Prompt(const Value: string): TCompletionParams; overload;

    /// <summary>
    /// Sets multiple initial input prompts for the model to generate text from.
    /// </summary>
    /// <param name="Value">An array of text prompts to use as input for the model.</param>
    /// <returns>The instance of <c>TCompletionParams</c> for chaining.</returns>
    function Prompt(const Value: TArray<string>): TCompletionParams; overload;

    /// <summary>
    /// Sets the number of best completions to generate before choosing the final output.
    /// </summary>
    /// <param name="Value">The number of completions to generate.</param>
    /// <returns>The instance of <c>TCompletionParams</c> for chaining.</returns>
    function BestOf(const Value: Integer): TCompletionParams;

    /// <summary>
    /// Configures whether to include the original prompt in the response along with the completion.
    /// </summary>
    /// <param name="Value">True to include the prompt in the output, false otherwise.</param>
    /// <returns>The instance of <c>TCompletionParams</c> for chaining.</returns>
    function Echo(const Value: Boolean): TCompletionParams;

    /// <summary>
    /// Sets a penalty to discourage repetition of tokens based on their frequency in the generated text.
    /// </summary>
    /// <param name="Value">The penalty value; must be between -2.0 and 2.0.</param>
    /// <returns>The instance of <c>TCompletionParams</c> for chaining.</returns>
    function FrequencyPenalty(const Value: Double): TCompletionParams;

    /// <summary>
    /// Modifies the likelihood of specific tokens appearing in the completion.
    /// </summary>
    /// <param name="Value">A JSON object mapping token IDs to bias values.</param>
    /// <returns>The instance of <c>TCompletionParams</c> for chaining.</returns>
    function LogitBias(const Value: TJSONObject): TCompletionParams;

    /// <summary>
    /// Includes log probabilities of the most likely tokens in the response.
    /// </summary>
    /// <param name="Value">The number of top tokens to include probabilities for, up to 5.</param>
    /// <returns>The instance of <c>TCompletionParams</c> for chaining.</returns>
    function Logprobs(const Value: Integer): TCompletionParams;

    /// <summary>
    /// Sets the maximum number of tokens that the model can generate in the completion.
    /// </summary>
    /// <param name="Value">The maximum number of tokens to generate.</param>
    /// <returns>The instance of <c>TCompletionParams</c> for chaining.</returns>
    function MaxTokens(const Value: Integer): TCompletionParams;

    /// <summary>
    /// Sets how many completions to generate for each prompt.
    /// </summary>
    /// <param name="Value">The number of completions to generate.</param>
    /// <returns>The instance of <c>TCompletionParams</c> for chaining.</returns>
    function N(const Value: Integer): TCompletionParams;

    /// <summary>
    /// Sets a penalty to encourage the model to introduce new topics based on whether they appear in the text so far.
    /// </summary>
    /// <param name="Value">The penalty value; must be between -2.0 and 2.0.</param>
    /// <returns>The instance of <c>TCompletionParams</c> for chaining.</returns>
    function PresencePenalty(const Value: Double): TCompletionParams;

    /// <summary>
    /// Specifies a seed for deterministic generation. Repeated requests with the same seed and parameters should return the same result.
    /// </summary>
    /// <param name="Value">The seed value for deterministic generation.</param>
    /// <returns>The instance of <c>TCompletionParams</c> for chaining.</returns>
    function Seed(const Value: Integer): TCompletionParams;

    /// <summary>
    /// Sets the sequences where the model will stop generating further tokens.
    /// </summary>
    /// <param name="Value">The stop sequence or sequences to use.</param>
    /// <returns>The instance of <c>TCompletionParams</c> for chaining.</returns>
    function Stop(const Value: string): TCompletionParams; overload;

    /// <summary>
    /// Sets the sequences where the model will stop generating further tokens.
    /// </summary>
    /// <param name="Value">The stop sequence or sequences to use.</param>
    /// <returns>The instance of <c>TCompletionParams</c> for chaining.</returns>
    function Stop(const Value: TArray<string>): TCompletionParams; overload;

    /// <summary>
    /// Enables streaming of the completion generation process.
    /// </summary>
    /// <param name="Value">Set to true to stream back partial progress of completion generation.</param>
    /// <returns>The instance of <c>TCompletionParams</c> for chaining.</returns>
    function Stream(const Value: Boolean = True): TCompletionParams;

    /// <summary>
    /// Sets options for streaming responses, applicable only when streaming is enabled.
    /// </summary>
    /// <param name="Value">Boolean to determine if usage statistics should be included in the stream.</param>
    /// <returns>The instance of <c>TCompletionParams</c> for chaining.</returns>
    function StreamOptions(const Value: Boolean): TCompletionParams;

    /// <summary>
    /// Sets the suffix that comes after the completion of inserted text.
    /// </summary>
    /// <param name="Value">The suffix text to append to the completion.</param>
    /// <returns>The instance of <c>TCompletionParams</c> for chaining.</returns>
    function Suffix(const Value: string): TCompletionParams;

    /// <summary>
    /// Sets the sampling temperature for generating completions, influencing randomness.
    /// </summary>
    /// <param name="Value">The temperature value; must be between 0 and 2.</param>
    /// <returns>The instance of <c>TCompletionParams</c> for chaining.</returns>
    function Temperature(const Value: Double): TCompletionParams;

    /// <summary>
    /// Sets the nucleus sampling value, an alternative to sampling with temperature, to narrow down the token choices based on probability mass.
    /// </summary>
    /// <param name="Value">The top probability mass percentage to consider for token choices.</param>
    /// <returns>The instance of <c>TCompletionParams</c> for chaining.</returns>
    function TopP(const Value: Double): TCompletionParams;

    /// <summary>
    /// Identifies the user making the request, useful for monitoring and abuse prevention.
    /// </summary>
    /// <param name="Value">A unique identifier representing the end-user.</param>
    /// <returns>The instance of <c>TCompletionParams</c> for chaining.</returns>
    function User(const Value: string): TCompletionParams;
  end;

  /// <summary>
  /// Represents the log probabilities and associated metadata for tokens generated in a text completion.
  /// This class is part of the detailed response structure providing insights into the model's token generation process.
  /// </summary>
  TChoicesLogprobs = class
  private
    [JsonNameAttribute('text_offset')]
    FTextOffset: TArray<Int64>;
    [JsonNameAttribute('token_logprobs')]
    FTokenLogprobs: TArray<Double>;
    FTokens: TArray<string>;
  public
    /// <summary>
    /// Gets or sets the text offsets of tokens. Each offset corresponds to the position of the token in the original input text.
    /// </summary>
    property TextOffset: TArray<Int64> read FTextOffset write FTextOffset;

    /// <summary>
    /// Gets or sets the log probabilities of each token, providing a measure of how likely each token was to be generated next.
    /// </summary>
    property TokenLogprobs: TArray<Double> read FTokenLogprobs write FTokenLogprobs;

    /// <summary>
    /// Gets or sets the tokens that were generated by the model during the completion process.
    /// </summary>
    property Tokens: TArray<string> read FTokens write FTokens;
  end;

  /// <summary>
  /// Represents a single choice from the set of completions generated by the model.
  /// This class includes details about the text generated, the reasons for stopping,
  /// and probabilities associated with the tokens.
  /// </summary>
  TCompletionChoice = class
  private
    [JsonNameAttribute('finish_reason')]
    FFinishReason: string;
    FIndex: Int64;
    FLlogprobs: TChoicesLogprobs;
    FText: string;
  public
    /// <summary>
    /// Gets or sets the reason why the token generation was stopped, e.g., 'length', 'stop', or 'content_filter'.
    /// </summary>
    property FinishReason: string read FFinishReason write FFinishReason;

    /// <summary>
    /// Gets or sets the index of this choice among the other choices generated during the request.
    /// </summary>
    property Index: Int64 read FIndex write FIndex;

    /// <summary>
    /// Gets or sets the log probabilities of the tokens that make up this completion choice.
    /// </summary>
    property Llogprobs: TChoicesLogprobs read FLlogprobs write FLlogprobs;

    /// <summary>
    /// Gets or sets the text of the completion generated by the model.
    /// </summary>
    property Text: string read FText write FText;

    destructor Destroy; override;
  end;

  /// <summary>
  /// Represents the response from the completion API containing all generated choices,
  /// their details, and associated system information.
  /// This class extends TJSONFingerprint to include metadata about the API interaction.
  /// </summary>
  TCompletion = class(TJSONFingerprint)
  private
    FId: string;
    FChoices: TArray<TCompletionChoice>;
    FCreated: Int64;
    FModel: string;
    [JsonNameAttribute('system_fingerprint')]
    FSystemFingerprint: string;
    FObject: string;
    FUsage: TUsage;
  private
    function GetCreatedAsString: string;
    function GetCreated: Int64;
  public
    /// <summary>
    /// Gets or sets the unique identifier for the completion.
    /// </summary>
    property Id: string read FId write FId;

    /// <summary>
    /// Gets or sets the array of completion choices generated for the prompt.
    /// </summary>
    property Choices: TArray<TCompletionChoice> read FChoices write FChoices;

    /// <summary>
    /// Gets the timestamp of when the completion was created.
    /// </summary>
    property Created: Int64 read GetCreated;

    /// <summary>
    /// Gets the timestamp of when the completion was created as a string.
    /// </summary>
    property CreatedAsString: string read GetCreatedAsString;

    /// <summary>
    /// Gets or sets the model used to generate the completion.
    /// </summary>
    property Model: string read FModel write FModel;

    /// <summary>
    /// Gets or sets the system fingerprint that represents the backend configuration used for the completion.
    /// </summary>
    property SystemFingerprint: string read FSystemFingerprint write FSystemFingerprint;

    /// <summary>
    /// Gets or sets the object type, which is always 'text_completion'.
    /// </summary>
    property &Object: string read FObject write FObject;

    /// <summary>
    /// Gets or sets the usage statistics for the completion request, detailing token and compute usage.
    /// </summary>
    property Usage: TUsage read FUsage write FUsage;

    destructor Destroy; override;
  end;

  /// <summary>
  /// Manages asynchronous chat callBacks for a chat request using <c>TCompletion</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynCompletion</c> type extends the <c>TAsynParams&lt;TCompletion&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking chat operations and is specifically tailored for scenarios where multiple choices from a chat model are required.
  /// </remarks>
  TAsynCompletion = TAsynCallBack<TCompletion>;

  /// <summary>
  /// Manages asynchronous streaming chat callBacks for a chat request using <c>TCompletion</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynCompletionStream</c> type extends the <c>TAsynStreamParams&lt;TCompletion&gt;</c> record to support the lifecycle of an asynchronous streaming chat operation.
  /// It provides callbacks for different stages, including when the operation starts, progresses with new data chunks, completes successfully, or encounters an error.
  /// This structure is ideal for handling scenarios where the chat response is streamed incrementally, providing real-time updates to the user interface.
  /// </remarks>
  TAsynCompletionStream = TAsynStreamCallBack<TCompletion>;

  TPromiseCompletion = TPromiseCallBack<TCompletion>;

  TPromiseCompletionStream = TPromiseStreamCallBack<TCompletion>;

  TCompletionAbstractSupport = class(TGenAIRoute)
  protected
    function Create(const ParamProc: TProc<TCompletionParams>): TCompletion; virtual; abstract;

    function CreateStream(ParamProc: TProc<TCompletionParams>;
      Event: TStreamCallbackEvent<TCompletion>): Boolean; virtual; abstract;
  end;

  TCompletionAsynchronousSupport = class(TCompletionAbstractSupport)
  public
    procedure AsynCreate(const ParamProc: TProc<TCompletionParams>;
      CallBacks: TFunc<TAsynCompletion>);

    procedure AsynCreateStream(ParamProc: TProc<TCompletionParams>;
      CallBacks: TFunc<TAsynCompletionStream>);
  end;

  /// <summary>
  /// Manages the routes for creating and streaming completions using the OpenAI API.
  /// This class handles both synchronous and asynchronous operations to interact with the API
  /// for generating text completions.
  /// </summary>
  TCompletionRoute = class(TCompletionAsynchronousSupport)
  public
    /// <summary>
    /// Creates a text completion asynchronously and returns a promise for the result.
    /// </summary>
    function AsyncAwaitCreate(const ParamProc: TProc<TCompletionParams>;
      const CallBacks: TFunc<TPromiseCompletion> = nil): TPromise<TCompletion>;

    /// <summary>
    /// Creates a streamed text completion asynchronously and returns a promise for the accumulated text.
    /// </summary>
    function AsyncAwaitCreateStream(const ParamProc: TProc<TCompletionParams>;
      const CallBacks: TFunc<TPromiseCompletionStream>): TPromise<string>;

    /// <summary>
    /// Creates a completion synchronously and returns a TCompletion object containing the results
    /// and associated metadata.
    /// </summary>
    /// <param name="ParamProc">A procedure to configure the parameters for the completion request.</param>
    /// <returns>A TCompletion object populated with the API response.</returns>
    function Create(const ParamProc: TProc<TCompletionParams>): TCompletion; override;

    /// <summary>
    /// Initiates a streaming request for generating completions. This method is designed for real-time
    /// interactions where the response is incrementally provided as it is generated.
    /// </summary>
    /// <param name="ParamProc">A procedure to configure the parameters for the completion request.</param>
    /// <param name="Event">A callback event that is triggered as streaming data is received.</param>
    /// <returns>Boolean indicating if the streaming was initiated successfully.</returns>
    function CreateStream(ParamProc: TProc<TCompletionParams>; Event: TStreamCallbackEvent<TCompletion>): Boolean; override;
  end;

implementation

uses
  System.DateUtils;

function CompletionUnixToUtc(const Value: Int64): string;
begin
  if Value <= 0 then
    Exit(EmptyStr);
  Result := FormatDateTime('yyyy-mm-dd"T"hh:nn:ss"Z"', UnixToDateTime(Value, True));
end;

{ TCompletionParams }

function TCompletionParams.BestOf(const Value: Integer): TCompletionParams;
begin
  Result := TCompletionParams(Add('best_of', Value));
end;

function TCompletionParams.Echo(const Value: Boolean): TCompletionParams;
begin
  Result := TCompletionParams(Add('echo', Value));
end;

function TCompletionParams.FrequencyPenalty(
  const Value: Double): TCompletionParams;
begin
  Result := TCompletionParams(Add('frequency_penalty', Value));
end;

function TCompletionParams.LogitBias(
  const Value: TJSONObject): TCompletionParams;
begin
  Result := TCompletionParams(Add('logit_bias', Value));
end;

function TCompletionParams.Logprobs(const Value: Integer): TCompletionParams;
begin
  Result := TCompletionParams(Add('logprobs', Value));
end;

function TCompletionParams.MaxTokens(const Value: Integer): TCompletionParams;
begin
  Result := TCompletionParams(Add('max_tokens', Value));
end;

function TCompletionParams.Model(const Value: string): TCompletionParams;
begin
  Result := TCompletionParams(Add('model', Value));
end;

function TCompletionParams.N(const Value: Integer): TCompletionParams;
begin
  Result := TCompletionParams(Add('n', Value));
end;

function TCompletionParams.Prompt(const Value: string): TCompletionParams;
begin
  Result := TCompletionParams(Add('prompt', Value));
end;

function TCompletionParams.PresencePenalty(
  const Value: Double): TCompletionParams;
begin
  Result := TCompletionParams(Add('presence_penalty', Value));
end;

function TCompletionParams.Prompt(
  const Value: TArray<string>): TCompletionParams;
begin
  Result := TCompletionParams(Add('prompt', Value));
end;

function TCompletionParams.Seed(const Value: Integer): TCompletionParams;
begin
  Result := TCompletionParams(Add('seed', Value));
end;

function TCompletionParams.Stop(const Value: TArray<string>): TCompletionParams;
begin
  Result := TCompletionParams(Add('stop', Value));
end;

function TCompletionParams.Stop(const Value: string): TCompletionParams;
begin
  Result := TCompletionParams(Add('stop', Value));
end;

function TCompletionParams.Stream(const Value: Boolean): TCompletionParams;
begin
  Result := TCompletionParams(Add('stream', Value));
end;

function TCompletionParams.StreamOptions(
  const Value: Boolean): TCompletionParams;
begin
  Result := TCompletionParams(Add('stream_options', TJSONObject.Create.AddPair('include_usage', Value)));
end;

function TCompletionParams.Suffix(const Value: string): TCompletionParams;
begin
  Result := TCompletionParams(Add('suffix', Value));
end;

function TCompletionParams.Temperature(const Value: Double): TCompletionParams;
begin
  Result := TCompletionParams(Add('temperature', Value));
end;

function TCompletionParams.TopP(const Value: Double): TCompletionParams;
begin
  Result := TCompletionParams(Add('top_p', Value));
end;

function TCompletionParams.User(const Value: string): TCompletionParams;
begin
  Result := TCompletionParams(Add('user', Value));
end;

{ TCompletionChoice }

destructor TCompletionChoice.Destroy;
begin
  if Assigned(FLlogprobs) then
    FLlogprobs.Free;
  inherited;
end;

{ TCompletion }

destructor TCompletion.Destroy;
begin
  for var Item in FChoices do
    Item.Free;
  if Assigned(FUsage) then
    FUsage.Free;
  inherited;
end;

function TCompletion.GetCreated: Int64;
begin
  Result := FCreated;
end;

function TCompletion.GetCreatedAsString: string;
begin
  Result := CompletionUnixToUtc(FCreated);
end;

{ TCompletionAbstractSupport }

{ TCompletionAsynchronousSupport }

procedure TCompletionAsynchronousSupport.AsynCreate(const ParamProc: TProc<TCompletionParams>;
  CallBacks: TFunc<TAsynCompletion>);
begin
  with TAsynCallBackExec<TAsynCompletion, TCompletion>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TCompletion
      begin
        Result := Self.Create(ParamProc);
      end);
  finally
    Free;
  end;
end;

procedure TCompletionAsynchronousSupport.AsynCreateStream(ParamProc: TProc<TCompletionParams>;
  CallBacks: TFunc<TAsynCompletionStream>);
begin
  var CallBackParams := TUseParamsFactory<TAsynCompletionStream>.CreateInstance(CallBacks);

  var Sender := CallBackParams.Param.Sender;
  var OnStart := CallBackParams.Param.OnStart;
  var OnSuccess := CallBackParams.Param.OnSuccess;
  var OnProgress := CallBackParams.Param.OnProgress;
  var OnError := CallBackParams.Param.OnError;
  var OnCancellation := CallBackParams.Param.OnCancellation;
  var OnDoCancel := CallBackParams.Param.OnDoCancel;

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
                procedure (var Data: TCompletion; IsDone: Boolean; var Cancel: Boolean)
                begin
                  {--- Check that the process has not been canceled }
                  if Assigned(OnDoCancel) then
                    TThread.Queue(nil,
                        procedure
                        begin
                          Stop := OnDoCancel();
                        end);
                  if Stop then
                    begin
                      {--- Trigger when processus was stopped }
                      if Assigned(OnCancellation) then
                        TThread.Queue(nil,
                        procedure
                        begin
                          OnCancellation(Sender)
                        end);
                      Cancel := True;
                      Exit;
                    end;
                  if not IsDone and Assigned(Data) then
                    begin
                      var LocalData := Data;
                      Data := nil;

                      {--- Triggered when processus is progressing }
                      if Assigned(OnProgress) then
                        TThread.Synchronize(TThread.Current,
                        procedure
                        begin
                          try
                            OnProgress(Sender, LocalData);
                          finally
                            {--- Makes sure to release the instance containing the data obtained
                                 following processing}
                            LocalData.Free;
                          end;
                        end)
                     else
                       LocalData.Free;
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

{ TCompletionRoute }

function TCompletionRoute.AsyncAwaitCreate(
  const ParamProc: TProc<TCompletionParams>;
  const CallBacks: TFunc<TPromiseCompletion>): TPromise<TCompletion>;
begin
  Result := TAsyncAwaitHelper.WrapAsyncAwait<TCompletion>(
    procedure(const CallBackParams: TFunc<TAsynCompletion>)
    begin
      AsynCreate(ParamProc, CallBackParams);
    end,
    CallBacks);
end;

function TCompletionRoute.AsyncAwaitCreateStream(
  const ParamProc: TProc<TCompletionParams>;
  const CallBacks: TFunc<TPromiseCompletionStream>): TPromise<string>;
begin
  Result := TPromise<string>.Create(
    procedure(Resolve: TProc<string>; Reject: TProc<Exception>)
    var
      Buffer: string;
      CallBackParams: IUseParams<TPromiseCompletionStream>;
      PromiseCallbacks: TPromiseCompletionStream;
    begin
      CallBackParams := TUseParamsFactory<TPromiseCompletionStream>.CreateInstance(CallBacks);
      PromiseCallbacks := CallBackParams.Param;

      AsynCreateStream(ParamProc,
        function: TAsynCompletionStream
        begin
          Result.Sender := PromiseCallbacks.Sender;
          Result.OnStart := PromiseCallbacks.OnStart;

          Result.OnProgress :=
            procedure(Sender: TObject; Event: TCompletion)
            begin
              if Assigned(PromiseCallbacks.OnProgress) then
                PromiseCallbacks.OnProgress(Sender, Event);
              try
                if Assigned(Event) and (Length(Event.Choices) > 0) and Assigned(Event.Choices[0]) then
                  Buffer := Buffer + Event.Choices[0].Text;
              except
              end;
            end;

          Result.OnSuccess :=
            procedure(Sender: TObject)
            begin
              Resolve(Buffer);
            end;

          Result.OnError :=
            procedure(Sender: TObject; Error: string)
            begin
              if Assigned(PromiseCallbacks.OnError) then
                Error := PromiseCallbacks.OnError(Sender, Error);
              Reject(Exception.Create(Error));
            end;

          Result.OnDoCancel :=
            function: Boolean
            begin
              if Assigned(PromiseCallbacks.OnDoCancel) then
                Result := PromiseCallbacks.OnDoCancel()
              else
                Result := False;
            end;

          Result.OnCancellation :=
            procedure(Sender: TObject)
            begin
              var Error := 'aborted';
              if Assigned(PromiseCallbacks.OnCancellation) then
                Error := PromiseCallbacks.OnCancellation(Sender);
              Reject(Exception.Create(Error));
            end;
        end);
    end);
end;

function TCompletionRoute.Create(
  const ParamProc: TProc<TCompletionParams>): TCompletion;
begin
  Result := API.Post<TCompletion, TCompletionParams>('completions', ParamProc);
end;

function TCompletionRoute.CreateStream(ParamProc: TProc<TCompletionParams>;
  Event: TStreamCallbackEvent<TCompletion>): Boolean;
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
        Content: TCompletion;
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
        Content: TCompletion;
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
            Content := TApiDeserializer.Parse<TCompletion>(Line);
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
      Result := API.Post<TCompletionParams>(
        'completions',
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

end.
