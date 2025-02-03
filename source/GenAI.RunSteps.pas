unit GenAI.RunSteps;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGenAI
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.SysUtils, System.Classes, System.Threading, System.JSON, REST.Json.Types,
  REST.JsonReflect, System.Net.URLClient,
  GenAI.API.Params, GenAI.API, GenAI.Consts, GenAI.Types, GenAI.Async.Support,
  GenAI.API.Lists, GenAI.Assistants, GenAI.Runs;

type
  TRetrieveStepUrlParam = class(TUrlParam)
  public
    function Include(const Value: TArray<string>): TRetrieveStepUrlParam;
  end;

  TRunStepUrlParam = class(TUrlAdvancedParams)
  public
    function Include(const Value: TArray<string>): TRunStepUrlParam;
  end;

  TRunStepMessageCreation = class
  private
    [JsonNameAttribute('message_id')]
    FMessageId: string;
  public
    property MessageId: string read FMessageId write FMessageId;
  end;

  TOutputImage = class
  private
    [JsonNameAttribute('file_id')]
    FFileId: string;
  public
    property FileId: string read FFileId write FFileId;
  end;

  TCodeInterpreterOutput = class
  private
    FType: string;
    FLogs: string;
    FImage: TOutputImage;
  public
    property &Type: string read FType write FType;
    property Logs: string read FLogs write FLogs;
    property Image: TOutputImage read FImage write FImage;
    destructor Destroy; override;
  end;

  TRunStepCodeInterpreter = class
  private
    FInput: string;
    FOutputs: TArray<TCodeInterpreterOutput>;
  public
    property Input: string read FInput write FInput;
    property Outputs: TArray<TCodeInterpreterOutput> read FOutputs write FOutputs;
    destructor Destroy; override;
  end;

  TResultContent = class
  private
    FType: string;
    FText: string;
  public
    property &Type: string read FType write FType;
    property Text: string read FText write FText;
  end;

  TFileSearchResult = class
  private
    [JsonNameAttribute('file_id')]
    FFileId: string;
    [JsonNameAttribute('file_name')]
    FFileName: string;
    FScore: Double;
    FContent: TArray<TResultContent>;
  public
    property FileId: string read FFileId write FFileId;
    property FileName: string read FFileName write FFileName;
    property Score: Double read FScore write FScore;
    property Content: TArray<TResultContent> read FContent write FContent;
    destructor Destroy; override;
  end;

  TRunStepFileSearch = class
  private
    [JsonNameAttribute('ranking_options')]
    FRankingOptions: TRankingOptions;
    FResults: TArray<TFileSearchResult>;
  public
    property RankingOptions: TRankingOptions read FRankingOptions write FRankingOptions;
    property Results: TArray<TFileSearchResult> read FResults write FResults;
    destructor Destroy; override;
  end;

  TRunStepFunction = class
  private
    FName: string;
    FArguments: string;
    FOutput: string;
  public
    property Name: string read FName write FName;
    property Arguments: string read FArguments write FArguments;
    property Output: string read FOutput write FOutput;
  end;

  TRunStepToolCalls = class
  private
    FId: string;
    [JsonReflectAttribute(ctString, rtString, TAssistantsToolsTypeInterceptor)]
    FType: TAssistantsToolsType;
    [JsonNameAttribute('code_interpreter')]
    FCodeInterpreter: TRunStepCodeInterpreter;
    [JsonNameAttribute('file_search')]
    FFileSearch: TRunStepFileSearch;
    FFunction: TRunStepFunction;
  public
    property Id: string read FId write FId;
    property &Type: TAssistantsToolsType read FType write FType;
    property CodeInterpreter: TRunStepCodeInterpreter read FCodeInterpreter write FCodeInterpreter;
    property FileSearch: TRunStepFileSearch read FFileSearch write FFileSearch;
    property &Function: TRunStepFunction read FFunction write FFunction;
    destructor Destroy; override;
  end;

  TRunStepDetails = class
  private
    [JsonReflectAttribute(ctString, rtString, TRunStepTypeInterceptor)]
    FType: TRunStepType;
    [JsonNameAttribute('message_creation')]
    FMessageCreation: TRunStepMessageCreation;
    [JsonNameAttribute('tool_calls')]
    FToolCalls: TArray<TRunStepToolCalls>;
  public
    property &Type: TRunStepType read FType write FType;
    property MessageCreation: TRunStepMessageCreation read FMessageCreation write FMessageCreation;
    property ToolCalls: TArray<TRunStepToolCalls> read FToolCalls write FToolCalls;
    destructor Destroy; override;
  end;

  TRunStepTimestamp = class(TJSONFingerprint)
  protected
    function GetCreatedAtAsString: string; virtual; abstract;
    function GetExpiredAtAsString: string; virtual; abstract;
    function GetCancelledAtAsString: string; virtual; abstract;
    function GetFailedAtAsString: string; virtual; abstract;
    function GetCompletedAtAsString: string; virtual; abstract;
  public
    property CreatedAtAsString: string read GetCreatedAtAsString;
    property ExpiredAtAsString: string read GetExpiredAtAsString;
    property CancelledAtAsString: string read GetCancelledAtAsString;
    property FailedAtAsString: string read GetFailedAtAsString;
    property CompletedAtAsString: string read GetCompletedAtAsString;
  end;

  TRunStep = class(TRunStepTimestamp)
  private
    FId: string;
    FObject: string;
    [JsonNameAttribute('created_at')]
    FCreatedAt: Int64;
    [JsonNameAttribute('assistant_id')]
    FAssistantId: string;
    [JsonNameAttribute('thread_id')]
    FThreadId: string;
    [JsonNameAttribute('run_id')]
    FRunId: string;
    [JsonReflectAttribute(ctString, rtString, TRunStepTypeInterceptor)]
    FType: TRunStepType;
    [JsonReflectAttribute(ctString, rtString, TRunStatusInterceptor)]
    FStatus: TRunStatus;
    [JsonNameAttribute('step_details')]
    FStepDetails: TRunStepDetails;
    [JsonNameAttribute('last_error')]
    FLastError: TLastError;
    [JsonNameAttribute('expired_at')]
    FExpiredAt: Int64;
    [JsonNameAttribute('cancelled_at')]
    FCancelledAt: Int64;
    [JsonNameAttribute('failed_at')]
    FFailedAt: Int64;
    [JsonNameAttribute('completed_at')]
    FCompletedAt: Int64;
    FMetadata: string;
    FUsage: TRunUsage;
  protected
    function GetCreatedAtAsString: string; override;
    function GetExpiredAtAsString: string; override;
    function GetCancelledAtAsString: string; override;
    function GetFailedAtAsString: string; override;
    function GetCompletedAtAsString: string; override;
  public
    property Id: string read FId write FId;
    property &Object: string read FObject write FObject;
    property CreatedAt: Int64 read FCreatedAt write FCreatedAt;
    property AssistantId: string read FAssistantId write FAssistantId;
    property ThreadId: string read FThreadId write FThreadId;
    property RunId: string read FRunId write FRunId;
    property &Type: TRunStepType read FType write FType;
    property Status: TRunStatus read FStatus write FStatus;
    property StepDetails: TRunStepDetails read FStepDetails write FStepDetails;
    property LastError: TLastError read FLastError write FLastError;
    property ExpiredAt: Int64 read FExpiredAt write FExpiredAt;
    property CancelledAt: Int64 read FCancelledAt write FCancelledAt;
    property FailedAt: Int64 read FFailedAt write FFailedAt;
    property CompletedAt: Int64 read FCompletedAt write FCompletedAt;
    property Metadata: string read FMetadata write FMetadata;
    property Usage: TRunUsage read FUsage write FUsage;
    destructor Destroy; override;
  end;

  TRunSteps = TAdvancedList<TRunStep>;

  /// <summary>
  /// Manages asynchronous callBacks for a request using <c>TRunStep</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynRunStep</c> type extends the <c>TAsynParams&lt;TRunStep&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking operations.
  /// </remarks>
  TAsynRunStep = TAsynCallBack<TRunStep>;

  /// <summary>
  /// Manages asynchronous callBacks for a request using <c>TRunSteps</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynRunSteps</c> type extends the <c>TAsynParams&lt;TRunSteps&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking operations.
  /// </remarks>
  TAsynRunSteps = TAsynCallBack<TRunSteps>;

  TRunStepRoute = class(TGenAIRoute)
  protected
    procedure HeaderCustomize; override;
  public
    procedure AsynList(const ThreadId: string;
      const RunId: string;
      const CallBacks: TFunc<TAsynRunSteps>); overload;
    procedure AsynList(const ThreadId: string;
      const RunId: string;
      const ParamProc: TProc<TRunStepUrlParam>;
      const CallBacks: TFunc<TAsynRunSteps>); overload;
    procedure AsynRetrieve(const ThreadId: string;
      const RunId: string;
      const StepId: string;
      const CallBacks: TFunc<TAsynRunStep>); overload;
    procedure AsynRetrieve(const ThreadId: string;
      const RunId: string;
      const StepId: string;
      const ParamProc: TProc<TRetrieveStepUrlParam>;
      const CallBacks: TFunc<TAsynRunStep>); overload;

    function List(const ThreadId: string; const RunId: string): TRunSteps; overload;
    function List(const ThreadId: string; const RunId: string;
      const ParamProc: TProc<TRunStepUrlParam>): TRunSteps; overload;
    function Retrieve(const ThreadId: string; const RunId: string;
      const StepId: string): TRunStep; overload;
    function Retrieve(const ThreadId: string; const RunId: string;
      const StepId: string; const ParamProc: TProc<TRetrieveStepUrlParam>): TRunStep; overload;
  end;

implementation

{ TRetrieveStepUrlParam }

function TRetrieveStepUrlParam.Include(
  const Value: TArray<string>): TRetrieveStepUrlParam;
begin
  Result := TRetrieveStepUrlParam(Add('include', Value));
end;

{ TRunStepUrlParam }

function TRunStepUrlParam.Include(
  const Value: TArray<string>): TRunStepUrlParam;
begin
  Result := TRunStepUrlParam(Add('include', Value));
end;

{ TRunStep }

destructor TRunStep.Destroy;
begin
  if Assigned(FStepDetails) then
    FStepDetails.Free;
  if Assigned(FLastError) then
    FLastError.Free;
  if Assigned(FUsage) then
    FUsage.Free;
  inherited;
end;

function TRunStep.GetCancelledAtAsString: string;
begin
  Result := TimestampToString(CancelledAt, UTCtimestamp);
end;

function TRunStep.GetCompletedAtAsString: string;
begin
  Result := TimestampToString(CompletedAt, UTCtimestamp);
end;

function TRunStep.GetCreatedAtAsString: string;
begin
  Result := TimestampToString(CreatedAt, UTCtimestamp);
end;

function TRunStep.GetExpiredAtAsString: string;
begin
  Result := TimestampToString(ExpiredAt, UTCtimestamp);
end;

function TRunStep.GetFailedAtAsString: string;
begin
  Result := TimestampToString(FailedAt, UTCtimestamp);
end;

{ TRunStepDetails }

destructor TRunStepDetails.Destroy;
begin
  if Assigned(FMessageCreation) then
    FMessageCreation.Free;
  for var Item in FToolCalls do
    Item.Free;
  inherited;
end;

{ TRunStepToolCalls }

destructor TRunStepToolCalls.Destroy;
begin
  if Assigned(FCodeInterpreter) then
    FCodeInterpreter.Free;
  if Assigned(FFileSearch) then
    FFileSearch.Free;
  if Assigned(FFunction) then
    FFunction.Free;
  inherited;
end;

{ TRunStepCodeInterpreter }

destructor TRunStepCodeInterpreter.Destroy;
begin
  for var Item in FOutputs do
    Item.Free;
  inherited;
end;

{ TCodeInterpreterOutput }

destructor TCodeInterpreterOutput.Destroy;
begin
  if Assigned(FImage) then
    FImage.Free;
  inherited;
end;

{ TRunStepFileSearch }

destructor TRunStepFileSearch.Destroy;
begin
  if Assigned(FRankingOptions) then
    FRankingOptions.Free;
  for var Item in FResults do
    Item.Free;
  inherited;
end;

{ TFileSearchResult }

destructor TFileSearchResult.Destroy;
begin
  for var Item in FContent do
    Item.Free;
  inherited;
end;

{ TRunStepRoute }

procedure TRunStepRoute.AsynList(const ThreadId, RunId: string;
  const CallBacks: TFunc<TAsynRunSteps>);
begin
  with TAsynCallBackExec<TAsynRunSteps, TRunSteps>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TRunSteps
      begin
        Result := Self.List(ThreadId, RunId);
      end);
  finally
    Free;
  end;
end;

procedure TRunStepRoute.AsynList(const ThreadId, RunId: string;
  const ParamProc: TProc<TRunStepUrlParam>;
  const CallBacks: TFunc<TAsynRunSteps>);
begin
  with TAsynCallBackExec<TAsynRunSteps, TRunSteps>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TRunSteps
      begin
        Result := Self.List(ThreadId, RunId, ParamProc);
      end);
  finally
    Free;
  end;
end;

procedure TRunStepRoute.AsynRetrieve(const ThreadId, RunId, StepId: string;
  const ParamProc: TProc<TRetrieveStepUrlParam>;
  const CallBacks: TFunc<TAsynRunStep>);
begin
  with TAsynCallBackExec<TAsynRunStep, TRunStep>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TRunStep
      begin
        Result := Self.Retrieve(ThreadId, RunId, StepId, ParamProc);
      end);
  finally
    Free;
  end;
end;

procedure TRunStepRoute.AsynRetrieve(const ThreadId, RunId, StepId: string;
  const CallBacks: TFunc<TAsynRunStep>);
begin
  with TAsynCallBackExec<TAsynRunStep, TRunStep>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TRunStep
      begin
        Result := Self.Retrieve(ThreadId, RunId, StepId);
      end);
  finally
    Free;
  end;
end;

procedure TRunStepRoute.HeaderCustomize;
begin
  inherited;
  API.CustomHeaders := [TNetHeader.Create('OpenAI-Beta', 'assistants=v2')];
end;

function TRunStepRoute.List(const ThreadId, RunId: string;
  const ParamProc: TProc<TRunStepUrlParam>): TRunSteps;
begin
  HeaderCustomize;
  Result := API.Get<TRunSteps, TRunStepUrlParam>('threads/' + ThreadId + '/runs/' + RunId + '/steps', ParamProc);
end;

function TRunStepRoute.List(const ThreadId, RunId: string): TRunSteps;
begin
  HeaderCustomize;
  Result := API.Get<TRunSteps>('threads/' + ThreadId + '/runs/' + RunId + '/steps');
end;

function TRunStepRoute.Retrieve(const ThreadId, RunId,
  StepId: string): TRunStep;
begin
  HeaderCustomize;
  Result := API.Get<TRunStep>('threads/' + ThreadId + '/runs/' + RunId + '/steps/' + StepId);
end;

function TRunStepRoute.Retrieve(const ThreadId, RunId, StepId: string;
  const ParamProc: TProc<TRetrieveStepUrlParam>): TRunStep;
begin
  HeaderCustomize;
  Result := API.Get<TRunStep, TRetrieveStepUrlParam>('threads/' + ThreadId + '/runs/' + RunId + '/steps/' + StepId, ParamProc);
end;

end.
