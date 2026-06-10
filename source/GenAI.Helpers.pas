unit GenAI.Helpers;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGenAI
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

{$REGION 'Dev note'}

(*
      Fluent helpers to compose Responses payloads (multi-turn context).

      This unit is a thin, ergonomic layer on top of GenAI.Responses.InputParams.
      It mirrors -- region by region and name by name -- the design of
      Anthropic.Helpers, so that a user can switch from one SDK to the other
      while keeping the same vocabulary:

        Generation, ...Parts, User/Assistant/Developer/System, AddText/AddImage,
        CreateXxx, ToolChoice, ...

      It is intentionally NOT exhaustive: only the most common and useful blocks
      are surfaced. Anything else stays accessible through the raw SDK.
*)

{$ENDREGION}

uses
  System.SysUtils, System.Classes, System.JSON,
  GenAI.API.Params, GenAI.Types, GenAI.API.ArrayBuilder,
  GenAI.Responses.InputParams, GenAI.Functions.Core;

type

{$REGION 'Content'}

  TContentHelper = record helper for TContent
    function AddText(const AText: string): TContent;
  end;

  TContentManager = record
    class function Text(const Value: string): TItemContent; static;
    class function Image(const PathOrUrl: string; const Detail: string = 'auto'): TItemContent; static;
    class function &File(const FilePath: string): TItemContent; static;
    class function Audio(const AudioPath: string): TItemContent; static;
  end;

{$ENDREGION}

{$REGION 'Output content'}

  TAnnotations = TArrayBuilder<TOutputNotation>;

  TAnnotationsHelper = record helper for TAnnotations
    function AddAnnotation(const Value: TOutputNotation): TAnnotations;
  end;

  TAnnotationManager = record
    class function CreateFileCitation: TOutputNotation; static;
    class function CreateFilePath: TOutputNotation; static;
    class function CreateUrlCitation: TOutputNotation; static;
  end;

  TOutputContent = TArrayBuilder<TOutputMessageContent>;

  TOutputContentHelper = record helper for TOutputContent
    function AddOutputContent(const Value: TOutputMessageContent): TOutputContent;
  end;

  TOutputContentManager = record
    class function CreateOutputText: TOutputMessageContent; static;
    class function CreateRefusal: TOutputMessageContent; static;
  end;

{$ENDREGION}

{$REGION 'Messages & Payload'}

  TPayload = record
    class function User(const Value: string): TInputMessage; overload; static;
    class function User(const Value: TContent): TInputMessage; overload; static;
    class function Developer(const Value: string): TInputMessage; static;
    class function System(const Value: string): TInputMessage; static;

    class function Assistant(const Text: string): TItemOutputMessage; overload; static;
    class function Assistant(const Text, Id: string): TItemOutputMessage; overload; static;
    class function Assistant(const Value: TOutputContent): TItemOutputMessage; overload; static;
  end;

  TInputItems = TArrayBuilder<TInputListItem>;

  TInputItemsHelper = record helper for TInputItems
    function User(const Value: string): TInputItems; overload;
    function User(const Value: TContent): TInputItems; overload;
    function Developer(const Value: string): TInputItems;
    function System(const Value: string): TInputItems;

    function Assistant(const Text: string): TInputItems; overload;
    function Assistant(const Text, Id: string): TInputItems; overload;
    function Assistant(const Value: TOutputContent): TInputItems; overload;
    function AddItem(const Value: TInputListItem): TInputItems;
  end;

{$ENDREGION}

{$REGION 'File search results'}

  TFileSearchResults = TArrayBuilder<TFileSearchToolCallResult>;

  TFileSearchResultsHelper = record helper for TFileSearchResults
    function AddResult(const Value: TFileSearchToolCallResult): TFileSearchResults; overload;
  end;

{$ENDREGION}

{$REGION 'Replay sub-parts (object arrays)'}

  TReasoningSummary = TArrayBuilder<TReasoningTextContent>;

  TReasoningSummaryHelper = record helper for TReasoningSummary
    function AddText(const Value: string): TReasoningSummary; overload;
    function AddText(const Value: TReasoningTextContent): TReasoningSummary; overload;
  end;

  TFunctionOutputs = TArrayBuilder<TFunctionOutput>;

  TFunctionOutputsHelper = record helper for TFunctionOutputs
    function AddOutput(const Value: TFunctionOutput): TFunctionOutputs;
  end;

  TCodeOutputs = TArrayBuilder<TCodeInterpreterOutputs>;

  TCodeOutputsHelper = record helper for TCodeOutputs
    function AddOutput(const Value: TCodeInterpreterOutputs): TCodeOutputs;
  end;

  TShellCallOutputs = TArrayBuilder<TShellCallOutputContentParams>;

  TShellCallOutputsHelper = record helper for TShellCallOutputs
    function AddOutput(const Value: TShellCallOutputContentParams): TShellCallOutputs;
  end;

  TMCPToolList = TArrayBuilder<TMCPTools>;

  TMCPToolListHelper = record helper for TMCPToolList
    function AddTool(const Value: TMCPTools): TMCPToolList; overload;
  end;

  TDragPath = TArrayBuilder<TComputerDragPoint>;

  TDragPathHelper = record helper for TDragPath
    function AddPoint(const Value: TComputerDragPoint): TDragPath; overload;
  end;

  TPendingSafetyChecks = TArrayBuilder<TPendingSafetyCheck>;

  TPendingSafetyChecksHelper = record helper for TPendingSafetyChecks
    function AddCheck(const Value: TPendingSafetyCheck): TPendingSafetyChecks; overload;
  end;

  TAcknowledgedSafetyChecks = TArrayBuilder<TAcknowledgedSafetyCheckParams>;

  TAcknowledgedSafetyChecksHelper = record helper for TAcknowledgedSafetyChecks
    function AddCheck(const Value: TAcknowledgedSafetyCheckParams): TAcknowledgedSafetyChecks; overload;
  end;

  TComputerActionManager = record
    class function Click(const X, Y: Integer; const Button: string = 'left'): TComputerClick; static;
    class function DoubleClick(const X, Y: Integer): TComputerDoubleClick; static;
    class function Drag: TComputerDrag; static;
    class function KeyPress(const Keys: TArray<string>): TComputerKeyPressed; static;
    class function Move(const X, Y: Integer): TComputerMove; static;
    class function Screenshot: TComputerScreenshot; static;
    class function Scroll(const X, Y, ScrollX, ScrollY: Integer): TComputerScroll; static;
    class function TypeText(const Text: string): TComputerType; static;
    class function Wait: TComputerWait; static;

    class function CreateDragPoint(const X, Y: Integer): TComputerDragPoint; static;
    class function CreatePendingSafetyCheck: TPendingSafetyCheck; static;
    class function CreateAcknowledgedSafetyCheck: TAcknowledgedSafetyCheckParams; static;
  end;

{$ENDREGION}

{$REGION 'Context (multi-turn decoration)'}

  TContextManager = record
    class function CreateOutputMessage: TItemOutputMessage; static;
    class function CreateFunctionCall: TFunctionToolCall; static;
    class function CreateFunctionCallOutput: TFunctionToolCalloutput; static;
    class function CreateCustomToolCallOutput: TCustomToolCallOutput; static;
    class function CreateReasoning: TReasoningObject; static;
    class function CreateReasoningText(const Value: string): TReasoningTextContent; static;
    class function CreateItemReference(const Id: string): TInputItemReference; static;
    class function CreateFileSearchResult: TFileSearchToolCallResult; static;
    class function CreateFileSearchCall: TFileSearchToolCall; static;
    class function CreateLocalShellAction(const Command: string): TLocalShellCallAction; static;
    class function CreateLocalShellCall: TLocalShellCall; static;
    class function CreateLocalShellCallOutput: TLocalShellCallOutput; static;
    class function CreateShellCallAction(const Commands: TArray<string>): TShellCallActionParams; static;
    class function CreateShellCall: TShellCallParams; static;
    class function CreateApplyPatchOperation: TApplyPatchOperationParams; static;
    class function CreateApplyPatchCall: TApplyPatchCallParams; static;
    class function CreateToolSearchCall: TToolSearchCallParams; static;
    class function CreateCompactionItem(const Id, EncryptedContent: string): TCompactionItemParams; static;
    class function CreateShellCallOutput: TShellCallOutputParams; static;
    class function CreateShellCallOutputContent: TShellCallOutputContentParams; static;
    class function CreateShellExitOutcome(const ExitCode: Int64): TShellCallOutputOutcomeParams; static;
    class function CreateShellTimeoutOutcome: TShellCallOutputOutcomeParams; static;
    class function CreateApplyPatchCallOutput: TApplyPatchCallOutputParams; static;
    class function CreateToolSearchOutput: TToolSearchOutputParams; static;
    class function CreateCodeInterpreterCall: TCodeInterpreterToolCall; static;
    class function CreateMCPCall: TMCPToolCall; static;
    class function CreateMCPTool: TMCPTools; static;
    class function CreateMCPListTools: TMCPListTools; static;
    class function CreateMCPApprovalRequest: TMCPApprovalRequest; static;
    class function CreateMCPApprovalResponse: TMCPApprovalResponse; static;
    class function CreateImageGenerationCall: TImageGeneration; static;
    class function CreateComputerCall: TComputerToolCall; static;
    class function CreateComputerScreenshot(const ImageUrl: string): TComputerToolCallOutputObject; static;
    class function CreateComputerCallOutput: TComputerToolCallOutput; static;
    class function CreateFunctionOutputText: TFunctionInputText; static;
    class function CreateFunctionOutputImage: TFunctionInputImage; static;
    class function CreateFunctionOutputFile: TFunctionInputFile; static;
    class function CreateCodeLogs: TCodeInterpreterOutputLogs; static;
    class function CreateCodeImage: TCodeInterpreterOutputImage; static;
  end;

{$ENDREGION}

{$REGION 'Tools'}

  TTools = TArrayBuilder<TResponseToolParams>;

  TToolsHelper = record helper for TTools
    function AddFunction: TTools; overload;
    function AddFunction(const Value: IFunctionCore): TTools; overload;
    function AddFunction(const Value: TResponseFunctionParams): TTools; overload;
    function AddFileSearch(const VectorStoreIds: TArray<string>): TTools; overload;
    function AddFileSearch(const Value: TResponseFileSearchParams): TTools; overload;
    function AddWebSearch: TTools; overload;
    function AddWebSearch(const Value: TResponseWebSearchParams): TTools; overload;
    function AddCodeInterpreter: TTools;
    function AddImageGeneration: TTools;
    function AddMCP(const ServerLabel, ServerUrl: string): TTools; overload;
    function AddMCP(const Value: TResponseMCPToolParams): TTools; overload;
    function AddCustom(const Name: string; const Description: string = ''): TTools; overload;
    function AddCustom(const Value: TCustomToolParams): TTools; overload;
    function AddShell(const Environment: TShellEnvironmentParams): TTools; overload;
    function AddShell(const Value: TFunctionShellToolParams): TTools; overload;
    function AddApplyPatch: TTools; overload;
    function AddApplyPatch(const Value: TApplyPatchToolParams): TTools; overload;
    function AddToolSearch: TTools; overload;
    function AddToolSearch(const Value: TToolSearchToolParams): TTools; overload;
    function AddNamespace(const Value: TNamespaceToolParams): TTools;

    function AddTool(const Value: TResponseToolParams): TTools;
  end;

  TToolManager = record
    class function CreateFunction: TResponseFunctionParams; overload; static;
    class function CreateFunction(const Value: IFunctionCore): TResponseFunctionParams; overload; static;

    class function CreateFileSearch: TResponseFileSearchParams; static;
    class function CreateWebSearch: TResponseWebSearchParams; static;
    class function CreateWebSearchPreview: TWebSearchPreviewParams; static;
    class function CreateComputerUse: TResponseComputerUseParams; static;
    class function CreateCodeInterpreter: TResponseCodeInterpreterParams; static;
    class function CreateImageGeneration: TResponseImageGenerationParams; static;
    class function CreateMCP: TResponseMCPToolParams; static;
    class function CreateCustom: TCustomToolParams; static;
    class function CreateLocalShell: TLocalShellToolParams; static;
    class function CreateShell: TFunctionShellToolParams; static;
    class function CreateApplyPatch: TApplyPatchToolParams; static;
    class function CreateToolSearch: TToolSearchToolParams; static;
    class function CreateNamespace: TNamespaceToolParams; static;
  end;

{$ENDREGION}

{$REGION 'Tool choice'}

  TToolChoiceManager = record
    class function Auto: TToolChoice; static;
    class function None: TToolChoice; static;
    class function Required: TToolChoice; static;

    class function Hosted(const HostedType: string): THostedToolParams; static;
    class function Func(const Name: string): TFunctionToolParams; static;
    class function MCP(const ServerLabel, Name: string): TMCPToolParams; static;
    class function Custom(const Name: string): TCustomToolChoiceParams; static;
    class function AllowedTools: TAllowedToolsChoiceParams; static;
  end;

{$ENDREGION}

{$REGION 'Shell environment & skills'}

  TLocalSkills = TArrayBuilder<TLocalSkillParams>;

  TLocalSkillsHelper = record helper for TLocalSkills
    function AddSkill(const Value: TLocalSkillParams): TLocalSkills; overload;
  end;

  TContainerSkills = TArrayBuilder<TContainerSkillParams>;

  TContainerSkillsHelper = record helper for TContainerSkills
    function AddSkill(const Value: TContainerSkillParams): TContainerSkills;
  end;

  TShellManager = record
    class function CreateLocalSkill: TLocalSkillParams; static;
    class function CreateSkillReference: TSkillReferenceParams; static;
    class function CreateInlineSkill: TInlineSkillParams; static;
    class function CreateLocalEnvironment: TShellLocalEnvironmentParams; static;
    class function CreateContainerAuto: TShellContainerAutoParams; static;
    class function CreateContainerReference(const ContainerId: string): TShellContainerReferenceParams; static;
  end;

{$ENDREGION}

  TGenerationManager = record
  private
    class var FContentManager: TContentManager;
    class var FOutputContentManager: TOutputContentManager;
    class var FAnnotationManager: TAnnotationManager;
    class var FContextManager: TContextManager;
    class var FPayload: TPayload;
    class var FToolManager: TToolManager;
    class var FToolChoiceManager: TToolChoiceManager;
    class var FComputerActionManager: TComputerActionManager;
    class var FShellManager: TShellManager;
    class function Empty: TGenerationManager; static; inline;
  public
    /// <summary>
    /// Returns a new, empty content builder.
    /// </summary>
    class function ContentParts: TContent; static;

    /// <summary>
    /// Returns a new, empty assistant output-content builder
    /// (<c>output_text</c> / <c>refusal</c> blocks).
    /// </summary>
    class function OutputContentParts: TOutputContent; static;

    /// <summary>
    /// Returns a new, empty annotations (citations) builder.
    /// </summary>
    class function AnnotationParts: TAnnotations; static;

    /// <summary>
    /// Returns a new, empty file-search-results builder.
    /// </summary>
    class function FileSearchResultParts: TFileSearchResults; static;

    /// <summary>
    /// Returns a new, empty reasoning-summary builder.
    /// </summary>
    class function ReasoningSummaryParts: TReasoningSummary; static;

    /// <summary>
    /// Returns a new, empty function/custom tool output-content builder.
    /// </summary>
    class function FunctionOutputParts: TFunctionOutputs; static;

    /// <summary>
    /// Returns a new, empty code-interpreter outputs builder.
    /// </summary>
    class function CodeInterpreterOutputParts: TCodeOutputs; static;

    /// <summary>
    /// Returns a new, empty shell-call outputs builder.
    /// </summary>
    class function ShellCallOutputParts: TShellCallOutputs; static;

    /// <summary>
    /// Returns a new, empty MCP tool-list builder.
    /// </summary>
    class function MCPToolListParts: TMCPToolList; static;

    /// <summary>
    /// Returns a new, empty computer drag-path builder.
    /// </summary>
    class function DragPathParts: TDragPath; static;

    /// <summary>
    /// Returns a new, empty pending-safety-checks builder.
    /// </summary>
    class function PendingSafetyCheckParts: TPendingSafetyChecks; static;

    /// <summary>
    /// Returns a new, empty acknowledged-safety-checks builder.
    /// </summary>
    class function AcknowledgedSafetyCheckParts: TAcknowledgedSafetyChecks; static;

    /// <summary>
    /// Returns a new, empty input-items (messages) builder.
    /// </summary>
    class function MessageParts: TInputItems; static;

    /// <summary>
    /// Returns a new, empty tools builder.
    /// </summary>
    class function ToolParts: TTools; static;

    /// <summary>
    /// Returns a new, empty local-skills builder (for a <c>local</c> shell environment).
    /// </summary>
    class function LocalSkillParts: TLocalSkills; static;

    /// <summary>
    /// Returns a new, empty container-skills builder (for a <c>container_auto</c> shell environment).
    /// </summary>
    class function ContainerSkillParts: TContainerSkills; static;

    /// <summary>
    /// Creates a plain-text output format configuration.
    /// </summary>
    class function CreateText: TTextFormatTextPrams; static;

    /// <summary>
    /// Creates a JSON-schema (structured outputs) format configuration.
    /// </summary>
    class function CreateJSONSchema: TTextJSONSchemaParams; static;

    /// <summary>
    /// Creates a JSON-object format configuration.
    /// </summary>
    class function CreateJSONObject: TTextJSONObjectParams; static;

    /// <summary>
    /// Creates a reasoning configuration.
    /// </summary>
    class function CreateReasoning: TReasoningParams; static;

    /// <summary>
    /// Creates a prompt-template reference.
    /// </summary>
    class function CreatePrompt: TPromptParams; static;

    /// <summary>
    /// Creates a context-management configuration. Currently this configures compaction.
    /// </summary>
    class function CreateContextManagement: TContextManagementParams; static;

    class property Content: TContentManager read FContentManager;
    class property Output: TOutputContentManager read FOutputContentManager;
    class property Annotation: TAnnotationManager read FAnnotationManager;
    class property Context: TContextManager read FContextManager;
    class property Payload: TPayload read FPayload;
    class property Tool: TToolManager read FToolManager;
    class property ToolChoice: TToolChoiceManager read FToolChoiceManager;
    class property Computer: TComputerActionManager read FComputerActionManager;
    class property Shell: TShellManager read FShellManager;
  end;

function Generation: TGenerationManager;

implementation

function Generation: TGenerationManager;
begin
  Result := TGenerationManager.Empty;
end;

{ TContentHelper }

function TContentHelper.AddText(const AText: string): TContent;
begin
  Result := Self.AddPrompt(AText);
end;

{ TContentManager }

class function TContentManager.Text(const Value: string): TItemContent;
begin
  Result := TItemContent.NewText.Text(Value);
end;

class function TContentManager.Image(const PathOrUrl, Detail: string): TItemContent;
begin
  Result := TItemContent.NewImage(PathOrUrl, Detail);
end;

class function TContentManager.&File(const FilePath: string): TItemContent;
begin
  Result := TItemContent.NewFileData(FilePath);
end;

class function TContentManager.Audio(const AudioPath: string): TItemContent;
begin
  Result := TItemContent.NewAudio(AudioPath);
end;

{ TAnnotationManager }

class function TAnnotationManager.CreateFileCitation: TOutputNotation;
begin
  Result := TOutputNotation.NewFileCitation;
end;

class function TAnnotationManager.CreateFilePath: TOutputNotation;
begin
  Result := TOutputNotation.NewFilePath;
end;

class function TAnnotationManager.CreateUrlCitation: TOutputNotation;
begin
  Result := TOutputNotation.NewUrlCitation;
end;

{ TAnnotationsHelper }

function TAnnotationsHelper.AddAnnotation(const Value: TOutputNotation): TAnnotations;
begin
  Result := Self.Add(Value);
end;

{ TOutputContentManager }

class function TOutputContentManager.CreateOutputText: TOutputMessageContent;
begin
  Result := TOutputMessageContent.NewOutputText;
end;

class function TOutputContentManager.CreateRefusal: TOutputMessageContent;
begin
  Result := TOutputMessageContent.NewRefusal;
end;

{ TOutputContentHelper }

function TOutputContentHelper.AddOutputContent(const Value: TOutputMessageContent): TOutputContent;
begin
  Result := Self.Add(Value);
end;

{ TFileSearchResultsHelper }

function TFileSearchResultsHelper.AddResult(const Value: TFileSearchToolCallResult): TFileSearchResults;
begin
  Result := Self.Add(Value);
end;

{ TReasoningSummaryHelper }

function TReasoningSummaryHelper.AddText(const Value: string): TReasoningSummary;
begin
  Result := Self.Add(TContextManager.CreateReasoningText(Value));
end;

function TReasoningSummaryHelper.AddText(const Value: TReasoningTextContent): TReasoningSummary;
begin
  Result := Self.Add(Value);
end;

{ TFunctionOutputsHelper }

function TFunctionOutputsHelper.AddOutput(const Value: TFunctionOutput): TFunctionOutputs;
begin
  Result := Self.Add(Value);
end;

{ TCodeOutputsHelper }

function TCodeOutputsHelper.AddOutput(const Value: TCodeInterpreterOutputs): TCodeOutputs;
begin
  Result := Self.Add(Value);
end;

{ TShellCallOutputsHelper }

function TShellCallOutputsHelper.AddOutput(
  const Value: TShellCallOutputContentParams): TShellCallOutputs;
begin
  Result := Self.Add(Value);
end;

{ TMCPToolListHelper }

function TMCPToolListHelper.AddTool(const Value: TMCPTools): TMCPToolList;
begin
  Result := Self.Add(Value);
end;

{ TDragPathHelper }

function TDragPathHelper.AddPoint(const Value: TComputerDragPoint): TDragPath;
begin
  Result := Self.Add(Value);
end;

{ TPendingSafetyChecksHelper }

function TPendingSafetyChecksHelper.AddCheck(const Value: TPendingSafetyCheck): TPendingSafetyChecks;
begin
  Result := Self.Add(Value);
end;

{ TAcknowledgedSafetyChecksHelper }

function TAcknowledgedSafetyChecksHelper.AddCheck(const Value: TAcknowledgedSafetyCheckParams): TAcknowledgedSafetyChecks;
begin
  Result := Self.Add(Value);
end;

{ TComputerActionManager }

class function TComputerActionManager.Click(const X, Y: Integer; const Button: string): TComputerClick;
begin
  Result := TComputerClick.New.Button(Button).X(X).Y(Y);
end;

class function TComputerActionManager.DoubleClick(const X, Y: Integer): TComputerDoubleClick;
begin
  Result := TComputerDoubleClick.New.X(X).Y(Y);
end;

class function TComputerActionManager.Drag: TComputerDrag;
begin
  Result := TComputerDrag.New;
end;

class function TComputerActionManager.KeyPress(const Keys: TArray<string>): TComputerKeyPressed;
begin
  Result := TComputerKeyPressed.New.Keys(Keys);
end;

class function TComputerActionManager.Move(const X, Y: Integer): TComputerMove;
begin
  Result := TComputerMove.New.X(X).Y(Y);
end;

class function TComputerActionManager.Screenshot: TComputerScreenshot;
begin
  Result := TComputerScreenshot.New;
end;

class function TComputerActionManager.Scroll(const X, Y, ScrollX, ScrollY: Integer): TComputerScroll;
begin
  Result := TComputerScroll.New.X(X).Y(Y).ScrollX(ScrollX).ScrollY(ScrollY);
end;

class function TComputerActionManager.TypeText(const Text: string): TComputerType;
begin
  Result := TComputerType.New.Text(Text);
end;

class function TComputerActionManager.Wait: TComputerWait;
begin
  Result := TComputerWait.New;
end;

class function TComputerActionManager.CreateDragPoint(const X, Y: Integer): TComputerDragPoint;
begin
  Result := TComputerDragPoint.New(X, Y);
end;

class function TComputerActionManager.CreatePendingSafetyCheck: TPendingSafetyCheck;
begin
  Result := TPendingSafetyCheck.Create;
end;

class function TComputerActionManager.CreateAcknowledgedSafetyCheck: TAcknowledgedSafetyCheckParams;
begin
  Result := TAcknowledgedSafetyCheckParams.New;
end;

{ TPayload }

class function TPayload.User(const Value: string): TInputMessage;
begin
  Result := TInputMessage.New.Role('user').Content(Value);
end;

class function TPayload.User(const Value: TContent): TInputMessage;
begin
  Result := TInputMessage.New.Role('user').Content(Value);
end;

class function TPayload.Assistant(const Text: string): TItemOutputMessage;
begin
  Result := TItemOutputMessage.New
    .Content([TOutputContentManager.CreateOutputText.Text(Text)]);
end;

class function TPayload.Assistant(const Text, Id: string): TItemOutputMessage;
begin
  Result := TItemOutputMessage.New
    .Id(Id)
    .Content([TOutputContentManager.CreateOutputText.Text(Text)]);
end;

class function TPayload.Assistant(const Value: TOutputContent): TItemOutputMessage;
begin
  Result := TItemOutputMessage.New.Content(Value);
end;

class function TPayload.Developer(const Value: string): TInputMessage;
begin
  Result := TInputMessage.New.Role('developer').Content(Value);
end;

class function TPayload.System(const Value: string): TInputMessage;
begin
  Result := TInputMessage.New.Role('system').Content(Value);
end;

{ TInputItemsHelper }

function TInputItemsHelper.User(const Value: string): TInputItems;
begin
  Result := Self.Add(TPayload.User(Value));
end;

function TInputItemsHelper.User(const Value: TContent): TInputItems;
begin
  Result := Self.Add(TPayload.User(Value));
end;

function TInputItemsHelper.Developer(const Value: string): TInputItems;
begin
  Result := Self.Add(TPayload.Developer(Value));
end;

function TInputItemsHelper.System(const Value: string): TInputItems;
begin
  Result := Self.Add(TPayload.System(Value));
end;

function TInputItemsHelper.Assistant(const Text: string): TInputItems;
begin
  Result := Self.Add(TPayload.Assistant(Text));
end;

function TInputItemsHelper.Assistant(const Text, Id: string): TInputItems;
begin
  Result := Self.Add(TPayload.Assistant(Text, Id));
end;

function TInputItemsHelper.Assistant(const Value: TOutputContent): TInputItems;
begin
  Result := Self.Add(TPayload.Assistant(Value));
end;

function TInputItemsHelper.AddItem(const Value: TInputListItem): TInputItems;
begin
  Result := Self.Add(Value);
end;

{ TContextManager }

class function TContextManager.CreateOutputMessage: TItemOutputMessage;
begin
  Result := TItemOutputMessage.New;
end;

class function TContextManager.CreateFunctionCall: TFunctionToolCall;
begin
  Result := TFunctionToolCall.New;
end;

class function TContextManager.CreateFunctionCallOutput: TFunctionToolCalloutput;
begin
  Result := TFunctionToolCalloutput.New;
end;

class function TContextManager.CreateCustomToolCallOutput: TCustomToolCallOutput;
begin
  Result := TCustomToolCallOutput.New;
end;

class function TContextManager.CreateReasoning: TReasoningObject;
begin
  Result := TReasoningObject.New;
end;

class function TContextManager.CreateReasoningText(const Value: string): TReasoningTextContent;
begin
  Result := TReasoningTextContent.New.Text(Value);
end;

class function TContextManager.CreateItemReference(const Id: string): TInputItemReference;
begin
  Result := TInputItemReference.New(Id);
end;

class function TContextManager.CreateFileSearchResult: TFileSearchToolCallResult;
begin
  Result := TFileSearchToolCallResult.New;
end;

class function TContextManager.CreateFileSearchCall: TFileSearchToolCall;
begin
  Result := TFileSearchToolCall.New;
end;

class function TContextManager.CreateLocalShellAction(const Command: string): TLocalShellCallAction;
begin
  Result := TLocalShellCallAction.New.Command(Command);
end;

class function TContextManager.CreateLocalShellCall: TLocalShellCall;
begin
  Result := TLocalShellCall.New;
end;

class function TContextManager.CreateLocalShellCallOutput: TLocalShellCallOutput;
begin
  Result := TLocalShellCallOutput.New;
end;

class function TContextManager.CreateShellCallAction(
  const Commands: TArray<string>): TShellCallActionParams;
begin
  Result := TShellCallActionParams.New.Commands(Commands);
end;

class function TContextManager.CreateShellCall: TShellCallParams;
begin
  Result := TShellCallParams.New;
end;

class function TContextManager.CreateApplyPatchOperation: TApplyPatchOperationParams;
begin
  Result := TApplyPatchOperationParams.New;
end;

class function TContextManager.CreateApplyPatchCall: TApplyPatchCallParams;
begin
  Result := TApplyPatchCallParams.New;
end;

class function TContextManager.CreateToolSearchCall: TToolSearchCallParams;
begin
  Result := TToolSearchCallParams.New;
end;

class function TContextManager.CreateCompactionItem(
  const Id, EncryptedContent: string): TCompactionItemParams;
begin
  Result := TCompactionItemParams.New.Id(Id).EncryptedContent(EncryptedContent);
end;

class function TContextManager.CreateShellCallOutput: TShellCallOutputParams;
begin
  Result := TShellCallOutputParams.New;
end;

class function TContextManager.CreateShellCallOutputContent: TShellCallOutputContentParams;
begin
  Result := TShellCallOutputContentParams.New;
end;

class function TContextManager.CreateShellExitOutcome(
  const ExitCode: Int64): TShellCallOutputOutcomeParams;
begin
  Result := TShellCallOutputOutcomeParams.NewExit(ExitCode);
end;

class function TContextManager.CreateShellTimeoutOutcome: TShellCallOutputOutcomeParams;
begin
  Result := TShellCallOutputOutcomeParams.NewTimeout;
end;

class function TContextManager.CreateApplyPatchCallOutput: TApplyPatchCallOutputParams;
begin
  Result := TApplyPatchCallOutputParams.New;
end;

class function TContextManager.CreateToolSearchOutput: TToolSearchOutputParams;
begin
  Result := TToolSearchOutputParams.New;
end;

class function TContextManager.CreateCodeInterpreterCall: TCodeInterpreterToolCall;
begin
  Result := TCodeInterpreterToolCall.New;
end;

class function TContextManager.CreateMCPCall: TMCPToolCall;
begin
  Result := TMCPToolCall.New;
end;

class function TContextManager.CreateMCPTool: TMCPTools;
begin
  Result := TMCPTools.New;
end;

class function TContextManager.CreateMCPListTools: TMCPListTools;
begin
  Result := TMCPListTools.New;
end;

class function TContextManager.CreateMCPApprovalRequest: TMCPApprovalRequest;
begin
  Result := TMCPApprovalRequest.New;
end;

class function TContextManager.CreateMCPApprovalResponse: TMCPApprovalResponse;
begin
  Result := TMCPApprovalResponse.New;
end;

class function TContextManager.CreateImageGenerationCall: TImageGeneration;
begin
  Result := TImageGeneration.New;
end;

class function TContextManager.CreateComputerCall: TComputerToolCall;
begin
  Result := TComputerToolCall.New;
end;

class function TContextManager.CreateComputerScreenshot(const ImageUrl: string): TComputerToolCallOutputObject;
begin
  Result := TComputerToolCallOutputObject.New.ImageUrl(ImageUrl);
end;

class function TContextManager.CreateComputerCallOutput: TComputerToolCallOutput;
begin
  Result := TComputerToolCallOutput.New;
end;

class function TContextManager.CreateFunctionOutputText: TFunctionInputText;
begin
  Result := TFunctionInputText.New;
end;

class function TContextManager.CreateFunctionOutputImage: TFunctionInputImage;
begin
  Result := TFunctionInputImage.New;
end;

class function TContextManager.CreateFunctionOutputFile: TFunctionInputFile;
begin
  Result := TFunctionInputFile.New;
end;

class function TContextManager.CreateCodeLogs: TCodeInterpreterOutputLogs;
begin
  Result := TCodeInterpreterOutputLogs.New;
end;

class function TContextManager.CreateCodeImage: TCodeInterpreterOutputImage;
begin
  Result := TCodeInterpreterOutputImage.New;
end;

{ TToolManager }

class function TToolManager.CreateFunction: TResponseFunctionParams;
begin
  Result := TResponseFunctionParams.New;
end;

class function TToolManager.CreateFunction(const Value: IFunctionCore): TResponseFunctionParams;
begin
  Result := TResponseFunctionParams.New(Value);
end;

class function TToolManager.CreateFileSearch: TResponseFileSearchParams;
begin
  Result := TResponseFileSearchParams.New;
end;

class function TToolManager.CreateWebSearch: TResponseWebSearchParams;
begin
  Result := TResponseWebSearchParams.New;
end;

class function TToolManager.CreateWebSearchPreview: TWebSearchPreviewParams;
begin
  Result := TWebSearchPreviewParams.New;
end;

class function TToolManager.CreateComputerUse: TResponseComputerUseParams;
begin
  Result := TResponseComputerUseParams.New;
end;

class function TToolManager.CreateCodeInterpreter: TResponseCodeInterpreterParams;
begin
  Result := TResponseCodeInterpreterParams.New;
end;

class function TToolManager.CreateImageGeneration: TResponseImageGenerationParams;
begin
  Result := TResponseImageGenerationParams.New;
end;

class function TToolManager.CreateMCP: TResponseMCPToolParams;
begin
  Result := TResponseMCPToolParams.New;
end;

class function TToolManager.CreateCustom: TCustomToolParams;
begin
  Result := TCustomToolParams.New;
end;

class function TToolManager.CreateLocalShell: TLocalShellToolParams;
begin
  Result := TLocalShellToolParams.New;
end;

class function TToolManager.CreateShell: TFunctionShellToolParams;
begin
  Result := TFunctionShellToolParams.New;
end;

class function TToolManager.CreateApplyPatch: TApplyPatchToolParams;
begin
  Result := TApplyPatchToolParams.New;
end;

class function TToolManager.CreateToolSearch: TToolSearchToolParams;
begin
  Result := TToolSearchToolParams.New;
end;

class function TToolManager.CreateNamespace: TNamespaceToolParams;
begin
  Result := TNamespaceToolParams.New;
end;

{ TToolsHelper }

function TToolsHelper.AddFunction: TTools;
begin
  Result := Self.Add(TToolManager.CreateFunction);
end;

function TToolsHelper.AddFunction(const Value: IFunctionCore): TTools;
begin
  Result := Self.Add(TToolManager.CreateFunction(Value));
end;

function TToolsHelper.AddFunction(const Value: TResponseFunctionParams): TTools;
begin
  Result := Self.Add(Value);
end;

function TToolsHelper.AddFileSearch(const VectorStoreIds: TArray<string>): TTools;
begin
  Result := Self.Add(TToolManager.CreateFileSearch.VectorStoreIds(VectorStoreIds));
end;

function TToolsHelper.AddFileSearch(const Value: TResponseFileSearchParams): TTools;
begin
  Result := Self.Add(Value);
end;

function TToolsHelper.AddWebSearch: TTools;
begin
  Result := Self.Add(TToolManager.CreateWebSearch);
end;

function TToolsHelper.AddWebSearch(const Value: TResponseWebSearchParams): TTools;
begin
  Result := Self.Add(Value);
end;

function TToolsHelper.AddCodeInterpreter: TTools;
begin
  Result := Self.Add(TToolManager.CreateCodeInterpreter);
end;

function TToolsHelper.AddImageGeneration: TTools;
begin
  Result := Self.Add(TToolManager.CreateImageGeneration);
end;

function TToolsHelper.AddMCP(const ServerLabel, ServerUrl: string): TTools;
begin
  Result := Self.Add(
    TToolManager.CreateMCP
      .ServerLabel(ServerLabel)
      .ServerUrl(ServerUrl));
end;

function TToolsHelper.AddMCP(const Value: TResponseMCPToolParams): TTools;
begin
  Result := Self.Add(Value);
end;

function TToolsHelper.AddCustom(const Name, Description: string): TTools;
begin
  var Tool := TToolManager.CreateCustom.Name(Name);
  if not Description.IsEmpty then
    Tool.Description(Description);
  Result := Self.Add(Tool);
end;

function TToolsHelper.AddCustom(const Value: TCustomToolParams): TTools;
begin
  Result := Self.Add(Value);
end;

function TToolsHelper.AddShell(const Environment: TShellEnvironmentParams): TTools;
begin
  Result := Self.Add(TToolManager.CreateShell.Environment(Environment));
end;

function TToolsHelper.AddShell(const Value: TFunctionShellToolParams): TTools;
begin
  Result := Self.Add(Value);
end;

function TToolsHelper.AddApplyPatch: TTools;
begin
  Result := Self.Add(TToolManager.CreateApplyPatch);
end;

function TToolsHelper.AddApplyPatch(const Value: TApplyPatchToolParams): TTools;
begin
  Result := Self.Add(Value);
end;

function TToolsHelper.AddToolSearch(const Value: TToolSearchToolParams): TTools;
begin
  Result := Self.Add(Value);
end;

function TToolsHelper.AddToolSearch: TTools;
begin
  Result := Self.Add(TToolManager.CreateToolSearch);
end;

function TToolsHelper.AddNamespace(const Value: TNamespaceToolParams): TTools;
begin
  Result := Self.Add(Value);
end;

function TToolsHelper.AddTool(const Value: TResponseToolParams): TTools;
begin
  Result := Self.Add(Value);
end;

{ TToolChoiceManager }

class function TToolChoiceManager.Auto: TToolChoice;
begin
  Result := TToolChoice.auto;
end;

class function TToolChoiceManager.None: TToolChoice;
begin
  Result := TToolChoice.none;
end;

class function TToolChoiceManager.Required: TToolChoice;
begin
  Result := TToolChoice.required;
end;

class function TToolChoiceManager.Hosted(const HostedType: string): THostedToolParams;
begin
  Result := THostedToolParams.New(HostedType);
end;

class function TToolChoiceManager.Func(const Name: string): TFunctionToolParams;
begin
  Result := TFunctionToolParams.New.Name(Name);
end;

class function TToolChoiceManager.MCP(const ServerLabel, Name: string): TMCPToolParams;
begin
  Result := TMCPToolParams.New.ServerLabel(ServerLabel).Name(Name);
end;

class function TToolChoiceManager.Custom(const Name: string): TCustomToolChoiceParams;
begin
  Result := TCustomToolChoiceParams.Create.&Type().Name(Name);
end;

class function TToolChoiceManager.AllowedTools: TAllowedToolsChoiceParams;
begin
  Result := TAllowedToolsChoiceParams.New;
end;

{ TLocalSkillsHelper }

function TLocalSkillsHelper.AddSkill(const Value: TLocalSkillParams): TLocalSkills;
begin
  Result := Self.Add(Value);
end;

{ TContainerSkillsHelper }

function TContainerSkillsHelper.AddSkill(const Value: TContainerSkillParams): TContainerSkills;
begin
  Result := Self.Add(Value);
end;

{ TShellManager }

class function TShellManager.CreateLocalSkill: TLocalSkillParams;
begin
  Result := TLocalSkillParams.New;
end;

class function TShellManager.CreateSkillReference: TSkillReferenceParams;
begin
  Result := TSkillReferenceParams.New;
end;

class function TShellManager.CreateInlineSkill: TInlineSkillParams;
begin
  Result := TInlineSkillParams.New;
end;

class function TShellManager.CreateLocalEnvironment: TShellLocalEnvironmentParams;
begin
  Result := TShellLocalEnvironmentParams.New;
end;

class function TShellManager.CreateContainerAuto: TShellContainerAutoParams;
begin
  Result := TShellContainerAutoParams.New;
end;

class function TShellManager.CreateContainerReference(
  const ContainerId: string): TShellContainerReferenceParams;
begin
  Result := TShellContainerReferenceParams.New.ContainerId(ContainerId);
end;

{ TGenerationManager }

class function TGenerationManager.Empty: TGenerationManager;
begin
  Result := Default(TGenerationManager);
  FContentManager := Default(TContentManager);
  FOutputContentManager := Default(TOutputContentManager);
  FAnnotationManager := Default(TAnnotationManager);
  FContextManager := Default(TContextManager);
  FPayload := Default(TPayload);
  FToolManager := Default(TToolManager);
  FToolChoiceManager := Default(TToolChoiceManager);
  FComputerActionManager := Default(TComputerActionManager);
  FShellManager := Default(TShellManager);
end;

class function TGenerationManager.ContentParts: TContent;
begin
  Result := TContent.Create();
end;

class function TGenerationManager.OutputContentParts: TOutputContent;
begin
  Result := TOutputContent.Create();
end;

class function TGenerationManager.AnnotationParts: TAnnotations;
begin
  Result := TAnnotations.Create();
end;

class function TGenerationManager.FileSearchResultParts: TFileSearchResults;
begin
  Result := TFileSearchResults.Create();
end;

class function TGenerationManager.ReasoningSummaryParts: TReasoningSummary;
begin
  Result := TReasoningSummary.Create();
end;

class function TGenerationManager.FunctionOutputParts: TFunctionOutputs;
begin
  Result := TFunctionOutputs.Create();
end;

class function TGenerationManager.CodeInterpreterOutputParts: TCodeOutputs;
begin
  Result := TCodeOutputs.Create();
end;

class function TGenerationManager.ShellCallOutputParts: TShellCallOutputs;
begin
  Result := TShellCallOutputs.Create();
end;

class function TGenerationManager.MCPToolListParts: TMCPToolList;
begin
  Result := TMCPToolList.Create();
end;

class function TGenerationManager.DragPathParts: TDragPath;
begin
  Result := TDragPath.Create();
end;

class function TGenerationManager.PendingSafetyCheckParts: TPendingSafetyChecks;
begin
  Result := TPendingSafetyChecks.Create();
end;

class function TGenerationManager.AcknowledgedSafetyCheckParts: TAcknowledgedSafetyChecks;
begin
  Result := TAcknowledgedSafetyChecks.Create();
end;

class function TGenerationManager.MessageParts: TInputItems;
begin
  Result := TInputItems.Create();
end;

class function TGenerationManager.ToolParts: TTools;
begin
  Result := TTools.Create();
end;

class function TGenerationManager.LocalSkillParts: TLocalSkills;
begin
  Result := TLocalSkills.Create();
end;

class function TGenerationManager.ContainerSkillParts: TContainerSkills;
begin
  Result := TContainerSkills.Create();
end;

class function TGenerationManager.CreateText: TTextFormatTextPrams;
begin
  Result := TTextFormatTextPrams.New;
end;

class function TGenerationManager.CreateJSONSchema: TTextJSONSchemaParams;
begin
  Result := TTextJSONSchemaParams.New;
end;

class function TGenerationManager.CreateJSONObject: TTextJSONObjectParams;
begin
  Result := TTextJSONObjectParams.New;
end;

class function TGenerationManager.CreateReasoning: TReasoningParams;
begin
  Result := TReasoningParams.New;
end;

class function TGenerationManager.CreatePrompt: TPromptParams;
begin
  Result := TPromptParams.New;
end;

class function TGenerationManager.CreateContextManagement: TContextManagementParams;
begin
  Result := TContextManagementParams.New;
end;

end.
