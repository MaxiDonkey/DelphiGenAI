unit GenAI.Responses.StreamCallbacks;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGenAI
      Visit the Github repository for the documentation and use examples

      Streaming aggregation DTO and event dispatcher for the v1/responses
      endpoint. Modeled on Anthropic.Chat.StreamCallbacks so the two SDKs
      share the same shape (TEventData / snapshots / dispatcher) and can be
      maintained together.

 ------------------------------------------------------------------------------}

interface

{$REGION 'Dev note'}

(*
      Streaming aggregation DTO and event dispatcher for the v1/responses
      endpoint. Modeled on Anthropic.Chat.StreamCallbacks so the two SDKs
      share the same shape (TEventData / snapshots / dispatcher) and can be
      maintained together.
*)

{$ENDREGION}

uses
  System.SysUtils, System.Classes,
  GenAI.Types, GenAI.Responses.OutputParams;

type
  /// <summary>
  /// Snapshot of a tool invocation streamed by the server (function_call /
  /// custom_tool_call / mcp_call). The <c>InputJson</c> is built up
  /// incrementally from the matching *_arguments_delta / *_input_delta events.
  /// </summary>
  TToolCallSnapshot = record
    Index: Int64;
    Kind: TToolCallKind;
    ToolId: string;
    ToolName: string;
    InputJson: string;
    Stopped: Boolean;

    class function New(
      const AIndex: Int64;
      const AKind: TToolCallKind;
      const AToolId, AToolName: string): TToolCallSnapshot; static;
  end;

  /// <summary>
  /// Snapshot of a server-side tool activity streamed by the server (web /
  /// file search, code interpreter, image generation, MCP list tools). The
  /// <c>Text</c> is built up incrementally where the activity emits text
  /// (e.g. code_interpreter_call_code_delta).
  /// </summary>
  TToolResultSnapshot = record
    Index: Int64;
    Kind: TToolResultKind;
    ToolUseId: string;
    Text: string;
    IsError: Boolean;
    Stopped: Boolean;

    class function New(
      const AIndex: Int64;
      const AKind: TToolResultKind;
      const AToolUseId: string): TToolResultSnapshot; static;
  end;

  /// <summary>
  /// Mutable, value-typed aggregation buffer consumed across streaming turns
  /// of a v1/responses call. It accumulates assistant text, reasoning,
  /// reasoning summary, refusal, tool-call arguments and tool-result text,
  /// and exposes the last delta of each nature for incremental rendering.
  /// </summary>
  /// <remarks>
  /// The public surface intentionally mirrors the Anthropic <c>TEventData</c>
  /// record (Text / Thought / AssistantText / Last*Delta / ToolCalls /
  /// ToolResults / CurrentBlockType / CurrentBlockIndex), so an application
  /// already integrated against the Anthropic SDK can be ported with minimal
  /// changes. Responses-specific additions are <c>ReasoningSummary</c>,
  /// <c>Refusal</c>, <c>Arguments</c>, <c>Code</c>, <c>Message</c>,
  /// <c>Param</c> and <c>PartialImageB64</c>.
  /// </remarks>
  TResponsesEventData = record
  strict private
    class var FIndex: Integer;
  private
    FDelta: string;
    FId: string;
    FModel: string;
    FStatus: string;
    FRawJson: string;
    FSequenceNumber: Int64;

    FText: string;
    FAssistantText: string;
    FThought: string;
    FReasoningSummary: string;
    FRefusal: string;
    FArguments: string;

    FCode: string;
    FMessage: string;
    FParam: string;
    FPartialImageB64: string;

    FLastAssistantDelta: string;
    FLastReasoningDelta: string;
    FLastReasoningSummaryDelta: string;
    FLastToolInputDelta: string;
    FLastToolResultDelta: string;

    FCurrentBlockType: TResponsesBlockType;
    FCurrentBlockIndex: Int64;
    FBlockTypeKnown: Boolean;

    FToolCalls: TArray<TToolCallSnapshot>;
    FToolResults: TArray<TToolResultSnapshot>;
    FOpenToolCall: Integer;
    FOpenToolResult: Integer;

    procedure OpenToolCall(const AKind: TToolCallKind;
      const AIndex: Int64; const AId, AName: string);
    procedure AppendToolCallInput(const APartial: string);
    procedure StopToolCall;

    procedure OpenToolResult(const AKind: TToolResultKind;
      const AIndex: Int64; const AId: string);
    procedure AppendToolResultText(const AText: string);
    procedure StopToolResult(const AIsError: Boolean = False);

    procedure SetBlock(const ABlockType: TResponsesBlockType; const AIndex: Int64);
  public
    class function Empty: TResponsesEventData; static;

    /// <summary>
    /// Folds a single streamed event into the buffer. <c>ErrorProc</c>, when
    /// assigned, is invoked when the event carries a server error so the
    /// caller can reject a promise / abort the session.
    /// </summary>
    function Aggregate(const AChunk: TResponseStream;
      const ErrorProc: TProc = nil): TResponsesEventData;

    property Delta: string read FDelta write FDelta;
    property Id: string read FId write FId;
    property Model: string read FModel write FModel;
    property Status: string read FStatus write FStatus;
    property RawJson: string read FRawJson write FRawJson;
    property SequenceNumber: Int64 read FSequenceNumber write FSequenceNumber;

    property Text: string read FText write FText;
    property AssistantText: string read FAssistantText write FAssistantText;
    property Thought: string read FThought write FThought;
    property ReasoningSummary: string read FReasoningSummary write FReasoningSummary;
    property Refusal: string read FRefusal write FRefusal;
    property Arguments: string read FArguments write FArguments;

    property Code: string read FCode write FCode;
    property Message: string read FMessage write FMessage;
    property Param: string read FParam write FParam;
    property PartialImageB64: string read FPartialImageB64 write FPartialImageB64;

    property LastAssistantDelta: string read FLastAssistantDelta;
    property LastReasoningDelta: string read FLastReasoningDelta;
    property LastReasoningSummaryDelta: string read FLastReasoningSummaryDelta;
    property LastToolInputDelta: string read FLastToolInputDelta;
    property LastToolResultDelta: string read FLastToolResultDelta;

    property BlockTypeKnown: Boolean read FBlockTypeKnown;
    property CurrentBlockType: TResponsesBlockType read FCurrentBlockType;
    property CurrentBlockIndex: Int64 read FCurrentBlockIndex;

    property ToolCalls: TArray<TToolCallSnapshot> read FToolCalls;
    property ToolResults: TArray<TToolResultSnapshot> read FToolResults;

    class property Index: Integer read FIndex write FIndex;
  end;

  /// <summary>
  /// Record of opt-in callbacks, one per v1/responses streaming event, plus
  /// the cancellation/error trio (<c>OnError</c>, <c>OnDoCancel</c>,
  /// <c>OnCancellation</c>) required to drive a mid-response abort.
  /// </summary>
  /// <remarks>
  /// All event callbacks share the uniform signature
  /// <c>TProc&lt;TObject, TResponsesEventData&gt;</c>: the aggregated buffer
  /// carries every per-event scalar (Delta, Arguments, Code, snapshots, ...),
  /// so a single dispatch path serves all events. Any callback left nil is a
  /// no-op, so consumers wire only the events they care about.
  /// </remarks>
  TResponseStreamEventCallBack = record
  private
    FSender: TObject;

    FOnError: TProc<TObject, TResponsesEventData>;
    FOnCancellation: TProc<TObject>;
    FOnDoCancel: TFunc<Boolean>;

    FOnCreated: TProc<TObject, TResponsesEventData>;
    FOnInProgress: TProc<TObject, TResponsesEventData>;
    FOnCompleted: TProc<TObject, TResponsesEventData>;
    FOnFailed: TProc<TObject, TResponsesEventData>;
    FOnIncomplete: TProc<TObject, TResponsesEventData>;
    FOnOutputItemAdded: TProc<TObject, TResponsesEventData>;
    FOnOutputItemDone: TProc<TObject, TResponsesEventData>;
    FOnContentPartAdded: TProc<TObject, TResponsesEventData>;
    FOnContentPartDone: TProc<TObject, TResponsesEventData>;
    FOnOutputTextDelta: TProc<TObject, TResponsesEventData>;
    FOnOutputTextDone: TProc<TObject, TResponsesEventData>;
    FOnRefusalDelta: TProc<TObject, TResponsesEventData>;
    FOnRefusalDone: TProc<TObject, TResponsesEventData>;
    FOnFunctionCallArgumentsDelta: TProc<TObject, TResponsesEventData>;
    FOnFunctionCallArgumentsDone: TProc<TObject, TResponsesEventData>;
    FOnFileSearchCallInProgress: TProc<TObject, TResponsesEventData>;
    FOnFileSearchCallSearching: TProc<TObject, TResponsesEventData>;
    FOnFileSearchCallCompleted: TProc<TObject, TResponsesEventData>;
    FOnWebSearchCallInProgress: TProc<TObject, TResponsesEventData>;
    FOnWebSearchCallSearching: TProc<TObject, TResponsesEventData>;
    FOnWebSearchCallCompleted: TProc<TObject, TResponsesEventData>;
    FOnReasoningSummaryPartAdded: TProc<TObject, TResponsesEventData>;
    FOnReasoningSummaryPartDone: TProc<TObject, TResponsesEventData>;
    FOnReasoningSummaryTextDelta: TProc<TObject, TResponsesEventData>;
    FOnReasoningSummaryTextDone: TProc<TObject, TResponsesEventData>;
    FOnReasoningTextDelta: TProc<TObject, TResponsesEventData>;
    FOnReasoningTextDone: TProc<TObject, TResponsesEventData>;
    FOnImageGenerationCallCompleted: TProc<TObject, TResponsesEventData>;
    FOnImageGenerationCallGenerating: TProc<TObject, TResponsesEventData>;
    FOnImageGenerationCallInProgress: TProc<TObject, TResponsesEventData>;
    FOnImageGenerationCallPartialImage: TProc<TObject, TResponsesEventData>;
    FOnMcpCallArgumentsDelta: TProc<TObject, TResponsesEventData>;
    FOnMcpCallArgumentsDone: TProc<TObject, TResponsesEventData>;
    FOnMcpCallCompleted: TProc<TObject, TResponsesEventData>;
    FOnMcpCallFailed: TProc<TObject, TResponsesEventData>;
    FOnMcpCallInProgress: TProc<TObject, TResponsesEventData>;
    FOnMcpListToolsCompleted: TProc<TObject, TResponsesEventData>;
    FOnMcpListToolsFailed: TProc<TObject, TResponsesEventData>;
    FOnMcpListToolsInProgress: TProc<TObject, TResponsesEventData>;
    FOnCodeInterpreterCallInProgress: TProc<TObject, TResponsesEventData>;
    FOnCodeInterpreterCallInterpreting: TProc<TObject, TResponsesEventData>;
    FOnCodeInterpreterCallCompleted: TProc<TObject, TResponsesEventData>;
    FOnCodeInterpreterCallCodeDelta: TProc<TObject, TResponsesEventData>;
    FOnCodeInterpreterCallCodeDone: TProc<TObject, TResponsesEventData>;
    FOnOutputTextAnnotationAdded: TProc<TObject, TResponsesEventData>;
    FOnQueued: TProc<TObject, TResponsesEventData>;
    FOnCustomToolCallInputDelta: TProc<TObject, TResponsesEventData>;
    FOnCustomToolCallInputDone: TProc<TObject, TResponsesEventData>;
  public
    property Sender: TObject read FSender write FSender;

    property OnError: TProc<TObject, TResponsesEventData> read FOnError write FOnError;
    property OnCancellation: TProc<TObject> read FOnCancellation write FOnCancellation;
    property OnDoCancel: TFunc<Boolean> read FOnDoCancel write FOnDoCancel;

    property OnCreated: TProc<TObject, TResponsesEventData> read FOnCreated write FOnCreated;
    property OnInProgress: TProc<TObject, TResponsesEventData> read FOnInProgress write FOnInProgress;
    property OnCompleted: TProc<TObject, TResponsesEventData> read FOnCompleted write FOnCompleted;
    property OnFailed: TProc<TObject, TResponsesEventData> read FOnFailed write FOnFailed;
    property OnIncomplete: TProc<TObject, TResponsesEventData> read FOnIncomplete write FOnIncomplete;
    property OnOutputItemAdded: TProc<TObject, TResponsesEventData> read FOnOutputItemAdded write FOnOutputItemAdded;
    property OnOutputItemDone: TProc<TObject, TResponsesEventData> read FOnOutputItemDone write FOnOutputItemDone;
    property OnContentPartAdded: TProc<TObject, TResponsesEventData> read FOnContentPartAdded write FOnContentPartAdded;
    property OnContentPartDone: TProc<TObject, TResponsesEventData> read FOnContentPartDone write FOnContentPartDone;
    property OnOutputTextDelta: TProc<TObject, TResponsesEventData> read FOnOutputTextDelta write FOnOutputTextDelta;
    property OnOutputTextDone: TProc<TObject, TResponsesEventData> read FOnOutputTextDone write FOnOutputTextDone;
    property OnRefusalDelta: TProc<TObject, TResponsesEventData> read FOnRefusalDelta write FOnRefusalDelta;
    property OnRefusalDone: TProc<TObject, TResponsesEventData> read FOnRefusalDone write FOnRefusalDone;
    property OnFunctionCallArgumentsDelta: TProc<TObject, TResponsesEventData> read FOnFunctionCallArgumentsDelta write FOnFunctionCallArgumentsDelta;
    property OnFunctionCallArgumentsDone: TProc<TObject, TResponsesEventData> read FOnFunctionCallArgumentsDone write FOnFunctionCallArgumentsDone;
    property OnFileSearchCallInProgress: TProc<TObject, TResponsesEventData> read FOnFileSearchCallInProgress write FOnFileSearchCallInProgress;
    property OnFileSearchCallSearching: TProc<TObject, TResponsesEventData> read FOnFileSearchCallSearching write FOnFileSearchCallSearching;
    property OnFileSearchCallCompleted: TProc<TObject, TResponsesEventData> read FOnFileSearchCallCompleted write FOnFileSearchCallCompleted;
    property OnWebSearchCallInProgress: TProc<TObject, TResponsesEventData> read FOnWebSearchCallInProgress write FOnWebSearchCallInProgress;
    property OnWebSearchCallSearching: TProc<TObject, TResponsesEventData> read FOnWebSearchCallSearching write FOnWebSearchCallSearching;
    property OnWebSearchCallCompleted: TProc<TObject, TResponsesEventData> read FOnWebSearchCallCompleted write FOnWebSearchCallCompleted;
    property OnReasoningSummaryPartAdded: TProc<TObject, TResponsesEventData> read FOnReasoningSummaryPartAdded write FOnReasoningSummaryPartAdded;
    property OnReasoningSummaryPartDone: TProc<TObject, TResponsesEventData> read FOnReasoningSummaryPartDone write FOnReasoningSummaryPartDone;
    property OnReasoningSummaryTextDelta: TProc<TObject, TResponsesEventData> read FOnReasoningSummaryTextDelta write FOnReasoningSummaryTextDelta;
    property OnReasoningSummaryTextDone: TProc<TObject, TResponsesEventData> read FOnReasoningSummaryTextDone write FOnReasoningSummaryTextDone;
    property OnReasoningTextDelta: TProc<TObject, TResponsesEventData> read FOnReasoningTextDelta write FOnReasoningTextDelta;
    property OnReasoningTextDone: TProc<TObject, TResponsesEventData> read FOnReasoningTextDone write FOnReasoningTextDone;
    property OnImageGenerationCallCompleted: TProc<TObject, TResponsesEventData> read FOnImageGenerationCallCompleted write FOnImageGenerationCallCompleted;
    property OnImageGenerationCallGenerating: TProc<TObject, TResponsesEventData> read FOnImageGenerationCallGenerating write FOnImageGenerationCallGenerating;
    property OnImageGenerationCallInProgress: TProc<TObject, TResponsesEventData> read FOnImageGenerationCallInProgress write FOnImageGenerationCallInProgress;
    property OnImageGenerationCallPartialImage: TProc<TObject, TResponsesEventData> read FOnImageGenerationCallPartialImage write FOnImageGenerationCallPartialImage;
    property OnMcpCallArgumentsDelta: TProc<TObject, TResponsesEventData> read FOnMcpCallArgumentsDelta write FOnMcpCallArgumentsDelta;
    property OnMcpCallArgumentsDone: TProc<TObject, TResponsesEventData> read FOnMcpCallArgumentsDone write FOnMcpCallArgumentsDone;
    property OnMcpCallCompleted: TProc<TObject, TResponsesEventData> read FOnMcpCallCompleted write FOnMcpCallCompleted;
    property OnMcpCallFailed: TProc<TObject, TResponsesEventData> read FOnMcpCallFailed write FOnMcpCallFailed;
    property OnMcpCallInProgress: TProc<TObject, TResponsesEventData> read FOnMcpCallInProgress write FOnMcpCallInProgress;
    property OnMcpListToolsCompleted: TProc<TObject, TResponsesEventData> read FOnMcpListToolsCompleted write FOnMcpListToolsCompleted;
    property OnMcpListToolsFailed: TProc<TObject, TResponsesEventData> read FOnMcpListToolsFailed write FOnMcpListToolsFailed;
    property OnMcpListToolsInProgress: TProc<TObject, TResponsesEventData> read FOnMcpListToolsInProgress write FOnMcpListToolsInProgress;
    property OnCodeInterpreterCallInProgress: TProc<TObject, TResponsesEventData> read FOnCodeInterpreterCallInProgress write FOnCodeInterpreterCallInProgress;
    property OnCodeInterpreterCallInterpreting: TProc<TObject, TResponsesEventData> read FOnCodeInterpreterCallInterpreting write FOnCodeInterpreterCallInterpreting;
    property OnCodeInterpreterCallCompleted: TProc<TObject, TResponsesEventData> read FOnCodeInterpreterCallCompleted write FOnCodeInterpreterCallCompleted;
    property OnCodeInterpreterCallCodeDelta: TProc<TObject, TResponsesEventData> read FOnCodeInterpreterCallCodeDelta write FOnCodeInterpreterCallCodeDelta;
    property OnCodeInterpreterCallCodeDone: TProc<TObject, TResponsesEventData> read FOnCodeInterpreterCallCodeDone write FOnCodeInterpreterCallCodeDone;
    property OnOutputTextAnnotationAdded: TProc<TObject, TResponsesEventData> read FOnOutputTextAnnotationAdded write FOnOutputTextAnnotationAdded;
    property OnQueued: TProc<TObject, TResponsesEventData> read FOnQueued write FOnQueued;
    property OnCustomToolCallInputDelta: TProc<TObject, TResponsesEventData> read FOnCustomToolCallInputDelta write FOnCustomToolCallInputDelta;
    property OnCustomToolCallInputDone: TProc<TObject, TResponsesEventData> read FOnCustomToolCallInputDone write FOnCustomToolCallInputDone;
  end;

  IResponsesEventDispatcher = interface
    ['{B0A7C4E2-3D5F-4A1B-9C6E-2F8D7A1B3C45}']
    function GetCallBacks: TResponseStreamEventCallBack;
    procedure DispatchEvent(EventType: TResponseStreamType; const Buffer: TResponsesEventData);
    property CallBacks: TResponseStreamEventCallBack read GetCallBacks;
  end;

  TResponsesEventDispatcher = class(TInterfacedObject, IResponsesEventDispatcher)
  private
    FCallBacks: TResponseStreamEventCallBack;
    procedure Invoke(const Proc: TProc<TObject, TResponsesEventData>;
      const Buffer: TResponsesEventData);
  public
    constructor Create(const CallBacks: TFunc<TResponseStreamEventCallBack> = nil);
    function GetCallBacks: TResponseStreamEventCallBack;
    procedure DispatchEvent(EventType: TResponseStreamType; const Buffer: TResponsesEventData);
  end;

implementation

{ TToolCallSnapshot }

class function TToolCallSnapshot.New(const AIndex: Int64;
  const AKind: TToolCallKind; const AToolId, AToolName: string): TToolCallSnapshot;
begin
  Result := Default(TToolCallSnapshot);
  Result.Index := AIndex;
  Result.Kind := AKind;
  Result.ToolId := AToolId;
  Result.ToolName := AToolName;
end;

{ TToolResultSnapshot }

class function TToolResultSnapshot.New(const AIndex: Int64;
  const AKind: TToolResultKind; const AToolUseId: string): TToolResultSnapshot;
begin
  Result := Default(TToolResultSnapshot);
  Result.Index := AIndex;
  Result.Kind := AKind;
  Result.ToolUseId := AToolUseId;
end;

{ TResponsesEventData }

class function TResponsesEventData.Empty: TResponsesEventData;
begin
  Result := Default(TResponsesEventData);
  Result.FOpenToolCall := -1;
  Result.FOpenToolResult := -1;
  Result.FCurrentBlockType := TResponsesBlockType.rbtNone;
  FIndex := 0;
end;

procedure TResponsesEventData.SetBlock(const ABlockType: TResponsesBlockType;
  const AIndex: Int64);
begin
  FBlockTypeKnown := True;
  FCurrentBlockType := ABlockType;
  FCurrentBlockIndex := AIndex;
  FIndex := AIndex;
end;

procedure TResponsesEventData.OpenToolCall(const AKind: TToolCallKind;
  const AIndex: Int64; const AId, AName: string);
begin
  FToolCalls := FToolCalls + [TToolCallSnapshot.New(AIndex, AKind, AId, AName)];
  FOpenToolCall := High(FToolCalls);
end;

procedure TResponsesEventData.AppendToolCallInput(const APartial: string);
begin
  if (FOpenToolCall >= 0) and (FOpenToolCall <= High(FToolCalls)) then
    FToolCalls[FOpenToolCall].InputJson := FToolCalls[FOpenToolCall].InputJson + APartial;
end;

procedure TResponsesEventData.StopToolCall;
begin
  if (FOpenToolCall >= 0) and (FOpenToolCall <= High(FToolCalls)) then
    FToolCalls[FOpenToolCall].Stopped := True;
  FOpenToolCall := -1;
end;

procedure TResponsesEventData.OpenToolResult(const AKind: TToolResultKind;
  const AIndex: Int64; const AId: string);
begin
  FToolResults := FToolResults + [TToolResultSnapshot.New(AIndex, AKind, AId)];
  FOpenToolResult := High(FToolResults);
end;

procedure TResponsesEventData.AppendToolResultText(const AText: string);
begin
  if (FOpenToolResult >= 0) and (FOpenToolResult <= High(FToolResults)) then
    FToolResults[FOpenToolResult].Text := FToolResults[FOpenToolResult].Text + AText;
end;

procedure TResponsesEventData.StopToolResult(const AIsError: Boolean);
begin
  if (FOpenToolResult >= 0) and (FOpenToolResult <= High(FToolResults)) then
    begin
      FToolResults[FOpenToolResult].Stopped := True;
      if AIsError then
        FToolResults[FOpenToolResult].IsError := True;
    end;
  FOpenToolResult := -1;
end;

function TResponsesEventData.Aggregate(const AChunk: TResponseStream;
  const ErrorProc: TProc): TResponsesEventData;
begin
  if not Assigned(AChunk) then
    Exit(Self);

  FRawJson := FRawJson + AChunk.JSONResponse;
  FSequenceNumber := AChunk.SequenceNumber;
  FDelta := AChunk.Delta;

  case AChunk.EventType of
    TResponseStreamType.created,
    TResponseStreamType.in_progress,
    TResponseStreamType.queued:
      begin
        FStatus := AChunk.EventType.ToString;
        if Assigned(AChunk.Response) then
          begin
            FId := AChunk.Response.Id;
            FModel := AChunk.Response.Model;
          end;
      end;

    TResponseStreamType.completed,
    TResponseStreamType.incomplete:
      begin
        FStatus := AChunk.EventType.ToString;
        if Assigned(AChunk.Response) then
          begin
            FId := AChunk.Response.Id;
            FModel := AChunk.Response.Model;
          end;
      end;

    TResponseStreamType.failed:
      begin
        FStatus := AChunk.EventType.ToString;
        if Assigned(AChunk.Response) then
          begin
            FId := AChunk.Response.Id;
            FModel := AChunk.Response.Model;
            if Assigned(AChunk.Response.Error) then
              begin
                FCode := AChunk.Response.Error.Code;
                FMessage := AChunk.Response.Error.Message;
              end;
          end;
        if Assigned(ErrorProc) then
          ErrorProc();
      end;

    TResponseStreamType.output_item_added:
      begin
        if Assigned(AChunk.Item) then
          case AChunk.Item.&Type of
            TResponseTypes.function_call:
              begin
                OpenToolCall(tcFunction, AChunk.OutputIndex, AChunk.Item.Id, AChunk.Item.Name);
                SetBlock(rbtToolUse, AChunk.OutputIndex);
              end;
            TResponseTypes.custom_tool_call:
              begin
                OpenToolCall(tcCustom, AChunk.OutputIndex, AChunk.Item.Id, AChunk.Item.Name);
                SetBlock(rbtToolUse, AChunk.OutputIndex);
              end;
            TResponseTypes.mcp_call:
              begin
                OpenToolCall(tcMcp, AChunk.OutputIndex, AChunk.Item.Id, AChunk.Item.Name);
                SetBlock(rbtToolUse, AChunk.OutputIndex);
              end;
            TResponseTypes.web_search_call:
              begin
                OpenToolResult(trWebSearch, AChunk.OutputIndex, AChunk.Item.Id);
                SetBlock(rbtToolResult, AChunk.OutputIndex);
              end;
            TResponseTypes.file_search_call:
              begin
                OpenToolResult(trFileSearch, AChunk.OutputIndex, AChunk.Item.Id);
                SetBlock(rbtToolResult, AChunk.OutputIndex);
              end;
            TResponseTypes.code_interpreter_call:
              begin
                OpenToolResult(trCodeInterpreter, AChunk.OutputIndex, AChunk.Item.Id);
                SetBlock(rbtToolResult, AChunk.OutputIndex);
              end;
            TResponseTypes.image_generation_call:
              begin
                OpenToolResult(trImageGeneration, AChunk.OutputIndex, AChunk.Item.Id);
                SetBlock(rbtToolResult, AChunk.OutputIndex);
              end;
            TResponseTypes.mcp_list_tools:
              begin
                OpenToolResult(trMcpListTools, AChunk.OutputIndex, AChunk.Item.Id);
                SetBlock(rbtToolResult, AChunk.OutputIndex);
              end;
            TResponseTypes.shell_call,
            TResponseTypes.local_shell_call:
              begin
                var ToolUseId := AChunk.Item.CallId.Trim;
                if ToolUseId.IsEmpty then
                  ToolUseId := AChunk.Item.Id;

                OpenToolResult(trShell, AChunk.OutputIndex, ToolUseId);
                SetBlock(rbtToolResult, AChunk.OutputIndex);
              end;
            TResponseTypes.shell_call_output,
            TResponseTypes.local_shell_call_output:
              begin
                var ToolUseId := AChunk.Item.CallId.Trim;
                if ToolUseId.IsEmpty then
                  ToolUseId := AChunk.Item.Id;

                OpenToolResult(trShell, AChunk.OutputIndex, ToolUseId);
                SetBlock(rbtToolResult, AChunk.OutputIndex);
              end;
            TResponseTypes.reasoning:
              SetBlock(rbtReasoning, AChunk.OutputIndex);
          else
            SetBlock(rbtText, AChunk.OutputIndex);
          end;
      end;

    TResponseStreamType.output_item_done:
      begin
        StopToolCall;
        StopToolResult;
      end;

    TResponseStreamType.content_part_added:
      SetBlock(rbtText, AChunk.OutputIndex);

    TResponseStreamType.content_part_done:
      ;

    TResponseStreamType.output_text_delta:
      begin
        FText := FText + AChunk.Delta;
        FAssistantText := FAssistantText + AChunk.Delta;
        FLastAssistantDelta := AChunk.Delta;
        SetBlock(rbtText, AChunk.OutputIndex);
      end;

    TResponseStreamType.output_text_done:
      ;

    TResponseStreamType.refusal_delta:
      begin
        FRefusal := FRefusal + AChunk.Delta;
        SetBlock(rbtRefusal, AChunk.OutputIndex);
      end;

    TResponseStreamType.refusal_done:
      if not AChunk.Refusal.IsEmpty then
        FRefusal := AChunk.Refusal;

    TResponseStreamType.function_call_arguments_delta,
    TResponseStreamType.custom_tool_call_input_delta,
    TResponseStreamType.mcp_call_arguments_delta:
      begin
        FArguments := FArguments + AChunk.Delta;
        FLastToolInputDelta := AChunk.Delta;
        AppendToolCallInput(AChunk.Delta);
        SetBlock(rbtToolUse, FCurrentBlockIndex);
      end;

    TResponseStreamType.function_call_arguments_done:
      begin
        if not AChunk.Arguments.IsEmpty then
          FArguments := AChunk.Arguments;
        StopToolCall;
      end;

    TResponseStreamType.custom_tool_call_input_done:
      begin
        if not AChunk.Input.IsEmpty then
          FArguments := AChunk.Input;
        StopToolCall;
      end;

    TResponseStreamType.mcp_call_arguments_done:
      begin
        if not AChunk.Arguments.IsEmpty then
          FArguments := AChunk.Arguments;
        StopToolCall;
      end;

    TResponseStreamType.reasoning_text_delta:
      begin
        FThought := FThought + AChunk.Delta;
        FLastReasoningDelta := AChunk.Delta;
        SetBlock(rbtReasoning, AChunk.OutputIndex);
      end;

    TResponseStreamType.reasoning_text_done:
      ;

    TResponseStreamType.reasoning_summary_text_delta:
      begin
        FReasoningSummary := FReasoningSummary + AChunk.Delta;
        FLastReasoningSummaryDelta := AChunk.Delta;
        SetBlock(rbtReasoningSummary, FCurrentBlockIndex);
      end;

    TResponseStreamType.reasoning_summary_text_done,
    TResponseStreamType.reasoning_summary_part_added,
    TResponseStreamType.reasoning_summary_part_done:
      ;

    TResponseStreamType.code_interpreter_call_code_delta:
      begin
        FLastToolResultDelta := AChunk.Delta;
        AppendToolResultText(AChunk.Delta);
      end;

    TResponseStreamType.code_interpreter_call_code_done:
      if not AChunk.Code.IsEmpty then
        AppendToolResultText(AChunk.Code);

    TResponseStreamType.code_interpreter_call_completed,
    TResponseStreamType.web_search_call_completed,
    TResponseStreamType.file_search_call_completed,
    TResponseStreamType.image_generation_call_completed,
    TResponseStreamType.mcp_list_tools_completed:
      StopToolResult;

    TResponseStreamType.mcp_list_tools_failed:
      begin
        FCode := AChunk.Code;
        FMessage := AChunk.Message;
        StopToolResult(True);
      end;

    TResponseStreamType.image_generation_call_partial_image:
      FPartialImageB64 := AChunk.PartialImageB64;

    TResponseStreamType.mcp_call_failed:
      begin
        FCode := AChunk.Code;
        FMessage := AChunk.Message;
        StopToolCall;
      end;

    TResponseStreamType.error:
      begin
        FCode := AChunk.Code;
        FMessage := AChunk.Message;
        FParam := AChunk.Param;
        if Assigned(ErrorProc) then
          ErrorProc();
      end;
  end;

  Result := Self;
end;

{ TResponsesEventDispatcher }

constructor TResponsesEventDispatcher.Create(
  const CallBacks: TFunc<TResponseStreamEventCallBack>);
begin
  inherited Create;
  if Assigned(CallBacks) then
    FCallBacks := CallBacks()
  else
    FCallBacks := Default(TResponseStreamEventCallBack);
end;

function TResponsesEventDispatcher.GetCallBacks: TResponseStreamEventCallBack;
begin
  Result := FCallBacks;
end;

procedure TResponsesEventDispatcher.Invoke(
  const Proc: TProc<TObject, TResponsesEventData>;
  const Buffer: TResponsesEventData);
var
  LocalSender: TObject;
  LocalProc: TProc<TObject, TResponsesEventData>;
begin
  LocalProc := Proc;
  if not Assigned(LocalProc) then
    Exit;

  LocalSender := FCallBacks.Sender;
  if not Assigned(LocalSender) then
    LocalSender := Self;

  if TThread.Current.ThreadID = MainThreadID then
    LocalProc(LocalSender, Buffer)
  else
    TThread.Synchronize(nil,
      procedure
      begin
        LocalProc(LocalSender, Buffer);
      end);
end;

procedure TResponsesEventDispatcher.DispatchEvent(EventType: TResponseStreamType;
  const Buffer: TResponsesEventData);
begin
  case EventType of
    TResponseStreamType.created:                          Invoke(FCallBacks.FOnCreated, Buffer);
    TResponseStreamType.in_progress:                      Invoke(FCallBacks.FOnInProgress, Buffer);
    TResponseStreamType.completed:                        Invoke(FCallBacks.FOnCompleted, Buffer);
    TResponseStreamType.failed:                           Invoke(FCallBacks.FOnFailed, Buffer);
    TResponseStreamType.incomplete:                       Invoke(FCallBacks.FOnIncomplete, Buffer);
    TResponseStreamType.output_item_added:                Invoke(FCallBacks.FOnOutputItemAdded, Buffer);
    TResponseStreamType.output_item_done:                 Invoke(FCallBacks.FOnOutputItemDone, Buffer);
    TResponseStreamType.content_part_added:               Invoke(FCallBacks.FOnContentPartAdded, Buffer);
    TResponseStreamType.content_part_done:                Invoke(FCallBacks.FOnContentPartDone, Buffer);
    TResponseStreamType.output_text_delta:                Invoke(FCallBacks.FOnOutputTextDelta, Buffer);
    TResponseStreamType.output_text_done:                 Invoke(FCallBacks.FOnOutputTextDone, Buffer);
    TResponseStreamType.refusal_delta:                    Invoke(FCallBacks.FOnRefusalDelta, Buffer);
    TResponseStreamType.refusal_done:                     Invoke(FCallBacks.FOnRefusalDone, Buffer);
    TResponseStreamType.function_call_arguments_delta:    Invoke(FCallBacks.FOnFunctionCallArgumentsDelta, Buffer);
    TResponseStreamType.function_call_arguments_done:     Invoke(FCallBacks.FOnFunctionCallArgumentsDone, Buffer);
    TResponseStreamType.file_search_call_in_progress:     Invoke(FCallBacks.FOnFileSearchCallInProgress, Buffer);
    TResponseStreamType.file_search_call_searching:       Invoke(FCallBacks.FOnFileSearchCallSearching, Buffer);
    TResponseStreamType.file_search_call_completed:        Invoke(FCallBacks.FOnFileSearchCallCompleted, Buffer);
    TResponseStreamType.web_search_call_in_progress:      Invoke(FCallBacks.FOnWebSearchCallInProgress, Buffer);
    TResponseStreamType.web_search_call_searching:        Invoke(FCallBacks.FOnWebSearchCallSearching, Buffer);
    TResponseStreamType.web_search_call_completed:         Invoke(FCallBacks.FOnWebSearchCallCompleted, Buffer);
    TResponseStreamType.reasoning_summary_part_added:     Invoke(FCallBacks.FOnReasoningSummaryPartAdded, Buffer);
    TResponseStreamType.reasoning_summary_part_done:      Invoke(FCallBacks.FOnReasoningSummaryPartDone, Buffer);
    TResponseStreamType.reasoning_summary_text_delta:     Invoke(FCallBacks.FOnReasoningSummaryTextDelta, Buffer);
    TResponseStreamType.reasoning_summary_text_done:      Invoke(FCallBacks.FOnReasoningSummaryTextDone, Buffer);
    TResponseStreamType.reasoning_text_delta:             Invoke(FCallBacks.FOnReasoningTextDelta, Buffer);
    TResponseStreamType.reasoning_text_done:              Invoke(FCallBacks.FOnReasoningTextDone, Buffer);
    TResponseStreamType.image_generation_call_completed:  Invoke(FCallBacks.FOnImageGenerationCallCompleted, Buffer);
    TResponseStreamType.image_generation_call_generating: Invoke(FCallBacks.FOnImageGenerationCallGenerating, Buffer);
    TResponseStreamType.image_generation_call_in_progress:Invoke(FCallBacks.FOnImageGenerationCallInProgress, Buffer);
    TResponseStreamType.image_generation_call_partial_image: Invoke(FCallBacks.FOnImageGenerationCallPartialImage, Buffer);
    TResponseStreamType.mcp_call_arguments_delta:         Invoke(FCallBacks.FOnMcpCallArgumentsDelta, Buffer);
    TResponseStreamType.mcp_call_arguments_done:          Invoke(FCallBacks.FOnMcpCallArgumentsDone, Buffer);
    TResponseStreamType.mcp_call_completed:               Invoke(FCallBacks.FOnMcpCallCompleted, Buffer);
    TResponseStreamType.mcp_call_failed:                  Invoke(FCallBacks.FOnMcpCallFailed, Buffer);
    TResponseStreamType.mcp_call_in_progress:             Invoke(FCallBacks.FOnMcpCallInProgress, Buffer);
    TResponseStreamType.mcp_list_tools_completed:         Invoke(FCallBacks.FOnMcpListToolsCompleted, Buffer);
    TResponseStreamType.mcp_list_tools_failed:            Invoke(FCallBacks.FOnMcpListToolsFailed, Buffer);
    TResponseStreamType.mcp_list_tools_in_progress:       Invoke(FCallBacks.FOnMcpListToolsInProgress, Buffer);
    TResponseStreamType.code_interpreter_call_in_progress:Invoke(FCallBacks.FOnCodeInterpreterCallInProgress, Buffer);
    TResponseStreamType.code_interpreter_call_interpreting:Invoke(FCallBacks.FOnCodeInterpreterCallInterpreting, Buffer);
    TResponseStreamType.code_interpreter_call_completed:  Invoke(FCallBacks.FOnCodeInterpreterCallCompleted, Buffer);
    TResponseStreamType.code_interpreter_call_code_delta: Invoke(FCallBacks.FOnCodeInterpreterCallCodeDelta, Buffer);
    TResponseStreamType.code_interpreter_call_code_done:  Invoke(FCallBacks.FOnCodeInterpreterCallCodeDone, Buffer);
    TResponseStreamType.output_text_annotation_added:     Invoke(FCallBacks.FOnOutputTextAnnotationAdded, Buffer);
    TResponseStreamType.queued:                           Invoke(FCallBacks.FOnQueued, Buffer);
    TResponseStreamType.custom_tool_call_input_delta:     Invoke(FCallBacks.FOnCustomToolCallInputDelta, Buffer);
    TResponseStreamType.custom_tool_call_input_done:      Invoke(FCallBacks.FOnCustomToolCallInputDone, Buffer);
    TResponseStreamType.error:                            Invoke(FCallBacks.FOnError, Buffer);
  end;
end;

end.
