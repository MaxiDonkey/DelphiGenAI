unit Demo.OpenAI.TextTurn;

interface

uses
  System.JSON,
  WVPythia.Chat.Interfaces, WVPythia.Chat.ManagedFlow,
  WVPythia.Vendors.Services,
  GenAI,
  Demo.OpenAI.AsyncUtils, Demo.OpenAI.Context;

type
  TOpenAITextTurn = record
  public
    /// <summary>
    /// Executes one Pythia text-generation turn with the OpenAI Responses API.
    /// </summary>
    class procedure Execute(
      const AClient: IGenAI;
      const ABrowser: IPythiaBrowser;
      const AContext: IContext;
      const AClientUtils: IOpenAIClientUtils;
      AState: TStateBuffer;
      const AOnFinalize: TManagedItemFinalizeProc); static;
  end;

implementation

{$REGION 'Dev note'}
(*

  OpenAI text turn for the pythia-openai FMX demo.

  This unit owns the TEXT_GENERATION_INDEX route selected by
  Demo.OpenAI.Services. It demonstrates the Responses API streaming path:
  build one TResponsesParams payload from the Pythia state, start
  Responses.AsyncAwaitCreateStream, map stream callbacks to the WebView, and
  finalize the Pythia turn once the async promise completes or fails.

  Conversation history is delegated to Demo.OpenAI.Context. That helper decides
  whether the current request should be chained with previous_response_id or
  rebuilt from the local Pythia session. TextTurn only applies the returned
  input items to the SDK params and records the JSON request for the demo trace.

  Streaming has two layers:
    - typed callbacks update Pythia as deltas, tool calls and tool results
      arrive;
    - TTracingResponsesEventEngineManager wraps the SDK event engine to keep
      raw response JSON, tool detail payloads and container-file references for
      the final persisted turn.

  Tool rendering is intentionally centralized in Demo.OpenAI.DisplayBlocks.
  TextTurn only registers starts, stops and details so the same final assistant
  item can be rendered both live and after the chat session is reloaded.

  Container files are discovered from streamed JSON and then downloaded after
  completion into the Pythia media folder. Temporary input files uploaded for
  the request are cleaned up after success, failure or cancellation.

  Cancellation and error paths are guarded by TOpenAIStreamCallbackGate and
  TEmitGuard. The gate prevents late stream callbacks from writing into the UI
  after the user cancels, while the emit guard ensures AOnFinalize is invoked
  only once.

*)
{$ENDREGION}

uses
  System.SysUtils, System.IOUtils, System.Classes, System.Threading,
  System.Generics.Collections,
  WVPythia.Chat.Consts, WVPythia.Chat.DecisionDlg, WVPythia.Strs,
  WVPythia.TextFile.Helper, WVPythia.JSON.SafeReader,
  WVPythia.JSON.SafeWriter,
  GenAI.Types, GenAI.Helpers, GenAI.Async.Promise,
  Demo.OpenAI.Agent.Cards, Demo.OpenAI.Agent.LocalApply,
  Demo.OpenAI.Agent.ProjectReview, Demo.OpenAI.Agent.TurnDisplay,
  Demo.OpenAI.DisplayBlocks, Demo.OpenAI.Finalize, Demo.OpenAI.Helpers,
  Demo.OpenAI.JsonResponse.Helper;

const
  ABORTED_INDICATOR = 'aborted';

type
  /// <summary>
  /// Keeps streamed tool details until the matching tool result is displayed.
  /// </summary>
  IOpenAIToolDetails = interface
    ['{2BB58B6C-8591-4027-AEC7-E2E0A18586A0}']
    procedure Add(const ToolUseId, Detail: string);
    function TryTake(const ToolUseId: string; out Detail: string): Boolean;
  end;

  TOpenAIToolDetails = class(TInterfacedObject, IOpenAIToolDetails)
  private
    FValues: TDictionary<string, string>;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Add(const ToolUseId, Detail: string);
    function TryTake(const ToolUseId: string; out Detail: string): Boolean;
  end;

  /// <summary>
  /// Stops late stream callbacks from updating Pythia after cancellation.
  /// </summary>
  IOpenAIStreamCallbackGate = interface
    ['{B1DF4B9E-E041-4C85-9B36-5831B0F921A3}']
    procedure Stop;
    function CanContinue(const StopRequested: Boolean = False): Boolean;
  end;

  TOpenAIStreamCallbackGate = class(
    TInterfacedObject, IOpenAIStreamCallbackGate)
  private
    FStopped: Boolean;
  public
    procedure Stop;
    function CanContinue(const StopRequested: Boolean = False): Boolean;
  end;

  /// <summary>
  /// Identifies one file created in an OpenAI container during a Responses run.
  /// </summary>
  TOpenAIContainerFileRef = record
  public
    ContainerId: string;
    FileId: string;
    Filename: string;

    class function New(
      const AContainerId, AFileId, AFilename: string): TOpenAIContainerFileRef; static;
    function IsValid: Boolean;
  end;

  TOpenAITextTurnState = class;

  /// <summary>
  /// Shared mutable state captured safely by asynchronous stream callbacks.
  /// </summary>
  IOpenAITextTurnState = interface
    ['{B06CE7CD-29AE-4B1E-A583-1C9B2FF69269}']
    function Data: TOpenAITextTurnState;
  end;

  TOpenAITextTurnState = class(TInterfacedObject, IOpenAITextTurnState)
  public
    Value: TStateBuffer;
    OutputFiles: TArray<TOpenAIContainerFileRef>;
    ContainerIdsSeen: TArray<string>;

    constructor Create(const AState: TStateBuffer);
    function Data: TOpenAITextTurnState;
  end;

  /// <summary>
  /// Discovers and normalizes OpenAI container files produced by tools.
  /// </summary>
  TOpenAIContainerFiles = record
  public
    class procedure AddContainerId(
      var ContainerIds: TArray<string>;
      const ContainerId: string); static;

    class function AddFileRef(
      var Files: TArray<TOpenAIContainerFileRef>;
      const ContainerId, FileId, Filename: string): Boolean; static;

    class procedure CaptureRefsFromJson(
      const Json: string;
      const OnContainerId: TProc<string>;
      const OnContainerFile: TProc<string, string, string>); static;

    class function DiscoverOutputFiles(
      const Client: IGenAI;
      const ContainerIds: TArray<string>): TArray<TOpenAIContainerFileRef>; static;

    class function LastPathSegment(
      const Value: string): string; static;
  private
    class function IsContainerId(const Value: string): Boolean; static;
    class function IsSkillArtifactName(const Value: string): Boolean; static;
  end;

  /// <summary>
  /// Reads container and file references from raw streamed response JSON using
  /// Pythia's safe JSON reader.
  /// </summary>
  TOpenAIContainerJsonRefsReader = record
  private
    FReader: TJsonReader;
    FOnContainerId: TProc<string>;
    FOnContainerFile: TProc<string, string, string>;

    class function ChildPath(
      const Parent, Child: string): string; static;

    class function IndexedPath(
      const Parent: string;
      const Index: Integer): string; static;

    procedure CaptureContainerFileAt(
      const Path: string);

    procedure CaptureContainerIdAt(
      const Path: string);

    procedure Walk(
      const Path: string);
  public
    class procedure Execute(
      const Json: string;
      const OnContainerId: TProc<string>;
      const OnContainerFile: TProc<string, string, string>); static;
  end;

  /// <summary>
  /// Decorates the SDK stream event engine with demo tracing hooks.
  /// </summary>
  TTracingResponsesEventEngineManager = class(TInterfacedObject, IResponsesEventEngineManager)
  private
    FInner: IResponsesEventEngineManager;
    FOnRawJson: TProc<string>;
    FOnContainerId: TProc<string>;
    FOnContainerFile: TProc<string, string, string>;
    FOnToolDetail: TProc<string, string>;
  public
    constructor Create(
      const AInner: IResponsesEventEngineManager;
      const AOnRawJson: TProc<string>;
      const AOnContainerId: TProc<string>;
      const AOnContainerFile: TProc<string, string, string>;
      const AOnToolDetail: TProc<string, string>);

    function AggregateStreamEvents(
      const Chunk: TResponseStream;
      var Buffer: TResponsesEventData): Boolean;

    function GetStreamEventDispatcher: IResponsesEventDispatcher;
  end;

  /// <summary>
  /// Converts the Pythia prompt state into SDK Responses parameters.
  /// </summary>
  TOpenAITextPayloadBuilder = record
  private
    class function ResolvedProjectReview(
      const AContext: TOpenAIProjectReviewContext):
      TPromise<TOpenAIProjectReviewContext>; static;
    class function RejectedProjectReview(
      const AMessage: string):
      TPromise<TOpenAIProjectReviewContext>; static;

    class procedure ApplyAgentGenerationSettings(
      const AState: TStateBuffer;
      const Params: TResponsesParams); static;

    class function PrepareAgentProjectReview(
      const AClient: IGenAI;
      const ABrowser: IPythiaBrowser;
      const Blocks: IOpenAIDisplayBlockAggregator;
      State: TStateBuffer): TPromise<TOpenAIProjectReviewContext>; static;

    class procedure DisplaySingleAgentPreparation(
      const ABrowser: IPythiaBrowser;
      const Blocks: IOpenAIDisplayBlockAggregator;
      State: TStateBuffer); static;

    class function BuildAgentPayload(
      const ABrowser: IPythiaBrowser;
      const AContext: IContext;
      const ProjectReview: TOpenAIProjectReviewContext;
      State: TStateBuffer): TResponsesParamsProc; static;

    class function BuildAgentTools(
      const ToolsDef: TOpenAIAgentToolsDef;
      const CodeInterpreterFileIds: TArray<string>): string; static;

    class function HasHostedAgentTool(
      const ToolsDef: TOpenAIAgentToolsDef;
      const ToolName: string): Boolean; static;

    class function HasFileSearchTool(
      const AContext: IContext;
      const AState: TStateBuffer): Boolean; static;

    class function LoadAgentCard(
      const ABrowser: IPythiaBrowser;
      const AState: TStateBuffer): TOpenAIAgentCardDefinition; static;

    class procedure OutputConfigBuilder(
      const AState: TStateBuffer;
      const Params: TResponsesParams); static;

    class procedure ThinkingBuilder(
      const AState: TStateBuffer;
      out Effort: string;
      const Params: TResponsesParams); static;

    class procedure ToolsBuilder(
      const ABrowser: IPythiaBrowser;
      const AContext: IContext;
      const AState: TStateBuffer;
      const Params: TResponsesParams); static;

    class function BuildPayload(
      const ABrowser: IPythiaBrowser;
      const AContext: IContext;
      const ProjectReview: TOpenAIProjectReviewContext;
      State: TStateBuffer): TResponsesParamsProc; static;
  public
    class function BuildAndCheck(
      const ABrowser: IPythiaBrowser;
      const AContext: IContext;
      const ProjectReview: TOpenAIProjectReviewContext;
      State: TStateBuffer;
      out JsonPayloadAsString: string): TResponsesParamsProc; static;
  end;

  /// <summary>
  /// Deletes temporary OpenAI input files uploaded for the current turn.
  /// </summary>
  TOpenAITextInputFiles = record
  public
    class procedure Cleanup(
      const AClientUtils: IOpenAIClientUtils;
      const State: TStateBuffer); static;
  end;

  /// <summary>
  /// Downloads assistant-created container files into the Pythia media folder.
  /// </summary>
  TOpenAITextOutputFiles = record
  public
    class procedure FireDownloads(
      const ABrowser: IPythiaBrowser;
      const AClientUtils: IOpenAIClientUtils;
      const ContainerIds, IDs: TArray<string>;
      const Filenames: TArray<string>); static;

    class function ResolveDownloadFilenames(
      const ABrowser: IPythiaBrowser;
      const Names: TArray<string>;
      const State: TStateBuffer): TArray<string>; static;
  end;

  /// <summary>
  /// Maps exceptions and cancellation into a finalized Pythia assistant item.
  /// </summary>
  TOpenAITextErrorHandler = record
  public
    class procedure Handle(
      const E: Exception;
      const ABrowser: IPythiaBrowser;
      var State: TStateBuffer;
      const Blocks: IOpenAIDisplayBlockAggregator;
      const EmitGuard: IEmitGuard); static;
  end;

  /// <summary>
  /// Mirrors OpenAI tool stream events into the demo display blocks.
  /// </summary>
  TOpenAITextToolEvents = record
  public
    class procedure FlushDetails(
      const Browser: IPythiaBrowser;
      const Blocks: IOpenAIDisplayBlockAggregator;
      const Buffer: TResponsesEventData;
      const ToolDetails: IOpenAIToolDetails;
      const DisplayInBrowser: Boolean); static;

    class procedure OpenLastResult(
      const Browser: IPythiaBrowser;
      const Blocks: IOpenAIDisplayBlockAggregator;
      const Buffer: TResponsesEventData); static;

    class procedure RegisterLastCall(
      const Browser: IPythiaBrowser;
      const Blocks: IOpenAIDisplayBlockAggregator;
      const Buffer: TResponsesEventData); static;

    class procedure StopLastResult(
      const Browser: IPythiaBrowser;
      const Blocks: IOpenAIDisplayBlockAggregator;
      const Buffer: TResponsesEventData;
      const ForceError: Boolean); static;
  end;

  /// <summary>
  /// Completes the streamed turn, downloads output files and emits final data.
  /// </summary>
  TOpenAITextCompletionHandler = record
  public
    class procedure HandleSuccess(
      const Value: TResponsesEventData;
      const AClient: IGenAI;
      const ABrowser: IPythiaBrowser;
      const AClientUtils: IOpenAIClientUtils;
      var State: TStateBuffer;
      var OutputFiles: TArray<TOpenAIContainerFileRef>;
      const ContainerIdsSeen: TArray<string>;
      const ToolDetails: IOpenAIToolDetails;
      const Blocks: IOpenAIDisplayBlockAggregator;
      const EmitGuard: IEmitGuard); static;
  end;

  /// <summary>
  /// Offers the Card 5 local patch confirmation when the final assistant text
  /// contains the explicit manifest and unified diff markers.
  /// </summary>
  TOpenAITextLocalApply = record
  private
    class procedure FinalStatus(
      const Display: TOpenAIAgentTurnDisplay;
      const Title, Detail: string); static;
    class function ResponseText(
      const Value: TResponsesEventData;
      const State: TStateBuffer): string; static;
  public
    class function ShouldOffer(const State: TStateBuffer): Boolean; static;
    class procedure OfferIfPresent(
      const ABrowser: IPythiaBrowser;
      const Blocks: IOpenAIDisplayBlockAggregator;
      const Value: TResponsesEventData;
      const State: TStateBuffer); static;
  end;

  /// <summary>
  /// Creates the typed Responses callbacks and the tracing decorator.
  /// </summary>
  TOpenAITextCallbacks = record
  public
    class function Create(
      const ABrowser: IPythiaBrowser;
      const TurnState: IOpenAITextTurnState;
      const StreamGate: IOpenAIStreamCallbackGate;
      const Blocks: IOpenAIDisplayBlockAggregator;
      const ToolDetails: IOpenAIToolDetails): IResponsesEventEngineManager; static;

    class function Trace(
      const Inner: IResponsesEventEngineManager;
      const ABrowser: IPythiaBrowser;
      const TurnState: IOpenAITextTurnState;
      const StreamGate: IOpenAIStreamCallbackGate;
      const ToolDetails: IOpenAIToolDetails): IResponsesEventEngineManager; static;
  end;

{ TOpenAIToolDetails }

procedure TOpenAIToolDetails.Add(const ToolUseId, Detail: string);
begin
  var Key := ToolUseId.Trim;
  if Key.IsEmpty or Detail.Trim.IsEmpty then
    Exit;

  TMonitor.Enter(FValues);
  try
    FValues.AddOrSetValue(Key, Detail);
  finally
    TMonitor.Exit(FValues);
  end;
end;

constructor TOpenAIToolDetails.Create;
begin
  inherited Create;
  FValues := TDictionary<string, string>.Create;
end;

destructor TOpenAIToolDetails.Destroy;
begin
  FValues.Free;
  inherited;
end;

function TOpenAIToolDetails.TryTake(
  const ToolUseId: string;
  out Detail: string): Boolean;
begin
  Detail := '';

  TMonitor.Enter(FValues);
  try
    Result := FValues.TryGetValue(ToolUseId.Trim, Detail);
    if Result then
      FValues.Remove(ToolUseId.Trim);
  finally
    TMonitor.Exit(FValues);
  end;
end;

{ TOpenAIStreamCallbackGate }

function TOpenAIStreamCallbackGate.CanContinue(
  const StopRequested: Boolean): Boolean;
begin
  TMonitor.Enter(Self);
  try
    if StopRequested then
      FStopped := True;

    Result := not FStopped;
  finally
    TMonitor.Exit(Self);
  end;
end;

procedure TOpenAIStreamCallbackGate.Stop;
begin
  TMonitor.Enter(Self);
  try
    FStopped := True;
  finally
    TMonitor.Exit(Self);
  end;
end;

{ TOpenAIContainerFileRef }

function TOpenAIContainerFileRef.IsValid: Boolean;
begin
  Result :=
    ContainerId.Trim.ToLowerInvariant.StartsWith('cntr_') and
    FileId.Trim.ToLowerInvariant.StartsWith('cfile_');
end;

class function TOpenAIContainerFileRef.New(
  const AContainerId, AFileId, AFilename: string): TOpenAIContainerFileRef;
begin
  Result := Default(TOpenAIContainerFileRef);
  Result.ContainerId := AContainerId.Trim;
  Result.FileId := AFileId.Trim;
  Result.Filename := AFilename.Trim;
end;

{ TOpenAITextTurnState }

constructor TOpenAITextTurnState.Create(const AState: TStateBuffer);
begin
  inherited Create;
  Value := AState;
  OutputFiles := [];
  ContainerIdsSeen := [];
end;

function TOpenAITextTurnState.Data: TOpenAITextTurnState;
begin
  Result := Self;
end;

{ TOpenAIContainerFiles }

class procedure TOpenAIContainerFiles.AddContainerId(
  var ContainerIds: TArray<string>;
  const ContainerId: string);
begin
  var Id := ContainerId.Trim;
  if not IsContainerId(Id) then
    Exit;

  for var Existing in ContainerIds do
    if SameText(Existing, Id) then
      Exit;

  ContainerIds := ContainerIds + [Id];
end;

class function TOpenAIContainerFiles.AddFileRef(
  var Files: TArray<TOpenAIContainerFileRef>;
  const ContainerId, FileId, Filename: string): Boolean;
begin
  Result := False;

  var Item := TOpenAIContainerFileRef.New(ContainerId, FileId, Filename);
  if not Item.IsValid then
    Exit;

  for var index := Low(Files) to High(Files) do
    if SameText(Files[index].ContainerId, Item.ContainerId) and
       SameText(Files[index].FileId, Item.FileId) then
      begin
        if Files[index].Filename.Trim.IsEmpty and not Item.Filename.Trim.IsEmpty then
          Files[index].Filename := Item.Filename;
        Exit;
      end;

  Files := Files + [Item];
  Result := True;
end;

class procedure TOpenAIContainerFiles.CaptureRefsFromJson(
  const Json: string;
  const OnContainerId: TProc<string>;
  const OnContainerFile: TProc<string, string, string>);
begin
  TOpenAIContainerJsonRefsReader.Execute(
    Json,
    OnContainerId,
    OnContainerFile);
end;

{ TOpenAIContainerJsonRefsReader }

class function TOpenAIContainerJsonRefsReader.ChildPath(
  const Parent, Child: string): string;
begin
  if Parent.Trim.IsEmpty then
    Exit(Child);

  Result := Parent + '.' + Child;
end;

class function TOpenAIContainerJsonRefsReader.IndexedPath(
  const Parent: string;
  const Index: Integer): string;
begin
  Result := Format('%s[%d]', [Parent, Index]);
end;

procedure TOpenAIContainerJsonRefsReader.CaptureContainerIdAt(
  const Path: string);
begin
  if not FReader.IsStringNode(Path) then
    Exit;

  var ContainerId := FReader.AsString(Path).Trim;
  if Assigned(FOnContainerId) and
     TOpenAIContainerFiles.IsContainerId(ContainerId) then
    FOnContainerId(ContainerId);
end;

procedure TOpenAIContainerJsonRefsReader.CaptureContainerFileAt(
  const Path: string);
begin
  if not Path.Trim.IsEmpty and not FReader.IsObjectNode(Path) then
    Exit;

  var ContainerId := FReader.AsString(ChildPath(Path, 'container_id')).Trim;
  if Assigned(FOnContainerId) and
     TOpenAIContainerFiles.IsContainerId(ContainerId) then
    FOnContainerId(ContainerId);

  if not Assigned(FOnContainerFile) then
    Exit;

  var FileId := FReader.AsString(ChildPath(Path, 'file_id')).Trim;
  if FileId.IsEmpty then
    FileId := FReader.AsString(ChildPath(Path, 'id')).Trim;

  var Filename := FReader.AsString(ChildPath(Path, 'filename')).Trim;
  if Filename.IsEmpty then
    Filename := FReader.AsString(ChildPath(Path, 'path')).Trim;
  if Filename.IsEmpty then
    Filename := FReader.AsString(ChildPath(Path, 'name')).Trim;

  var ContainerFile := TOpenAIContainerFileRef.New(
    ContainerId,
    FileId,
    TOpenAIContainerFiles.LastPathSegment(Filename));
  if ContainerFile.IsValid then
    FOnContainerFile(
      ContainerFile.ContainerId,
      ContainerFile.FileId,
      ContainerFile.Filename);
end;

class procedure TOpenAIContainerJsonRefsReader.Execute(
  const Json: string;
  const OnContainerId: TProc<string>;
  const OnContainerFile: TProc<string, string, string>);
begin
  if Json.Trim.IsEmpty then
    Exit;

  var Reader := Default(TOpenAIContainerJsonRefsReader);
  Reader.FReader := TJsonReader.Parse(Json);
  Reader.FOnContainerId := OnContainerId;
  Reader.FOnContainerFile := OnContainerFile;

  if Reader.FReader.IsValid then
    Reader.Walk('');
end;

procedure TOpenAIContainerJsonRefsReader.Walk(
  const Path: string);
begin
  CaptureContainerIdAt(Path);

  if Path.Trim.IsEmpty then
    begin
      CaptureContainerFileAt(Path);

      for var FieldName in FReader.ObjectFieldNames do
        Walk(ChildPath(Path, FieldName));

      Exit;
    end;

  if FReader.IsObjectNode(Path) then
    begin
      CaptureContainerFileAt(Path);

      for var FieldName in FReader.ObjectFieldNames(Path) do
        Walk(ChildPath(Path, FieldName));

      Exit;
    end;

  if FReader.IsArrayNode(Path) then
    begin
      for var index := 0 to FReader.Count(Path) - 1 do
        Walk(IndexedPath(Path, index));
      Exit;
    end;
end;

class function TOpenAIContainerFiles.DiscoverOutputFiles(
  const Client: IGenAI;
  const ContainerIds: TArray<string>): TArray<TOpenAIContainerFileRef>;
begin
  Result := [];

  for var ContainerId in ContainerIds do
    begin
      var Files := Client.ContainerFiles.List(
        ContainerId,
        procedure(Params: TUrlContainerFileParams)
        begin
          Params.Limit(100).Order('desc');
        end);
      try
        if not Assigned(Files) then
          Continue;

        for var Item in Files.Data do
          begin
            if not Assigned(Item) then
              Continue;

            var Name := LastPathSegment(Item.Path);
            if Name.IsEmpty then
              Name := LastPathSegment(Item.Id);

            if SameText(Item.Source, 'user') then
              Continue;

            if not IsSkillArtifactName(Name) then
              Continue;

            AddFileRef(
              Result,
              ContainerId,
              Item.Id,
              Name);
          end;
      finally
        Files.Free;
      end;
    end;
end;

class function TOpenAIContainerFiles.IsContainerId(const Value: string): Boolean;
begin
  Result := Value.Trim.ToLowerInvariant.StartsWith('cntr_');
end;

class function TOpenAIContainerFiles.IsSkillArtifactName(
  const Value: string): Boolean;
begin
  var Name := LastPathSegment(Value).Trim;
  var Ext := TPath.GetExtension(Name).ToLowerInvariant;
  Result :=
    SameText(Name, 'dependencies.json') or
    SameText(Name, 'uses-graph.mmd') or
    SameText(Name, 'uses-graph.dot') or
    SameText(Name, 'report.md') or
    SameText(Name, 'uses-graph.svg') or
    (Ext = '.json') or
    (Ext = '.mmd') or
    (Ext = '.dot') or
    (Ext = '.md') or
    (Ext = '.svg');
end;

class function TOpenAIContainerFiles.LastPathSegment(
  const Value: string): string;
begin
  Result := Value.Trim.Replace('\', '/');
  var Index := Result.LastIndexOf('/');
  if Index >= 0 then
    Result := Result.Substring(Index + 1);
end;

{ TTracingResponsesEventEngineManager }

constructor TTracingResponsesEventEngineManager.Create(
  const AInner: IResponsesEventEngineManager;
  const AOnRawJson: TProc<string>;
  const AOnContainerId: TProc<string>;
  const AOnContainerFile: TProc<string, string, string>;
  const AOnToolDetail: TProc<string, string>);
begin
  inherited Create;
  FInner := AInner;
  FOnRawJson := AOnRawJson;
  FOnContainerId := AOnContainerId;
  FOnContainerFile := AOnContainerFile;
  FOnToolDetail := AOnToolDetail;
end;

function TTracingResponsesEventEngineManager.AggregateStreamEvents(
  const Chunk: TResponseStream;
  var Buffer: TResponsesEventData): Boolean;
begin
  if Assigned(Chunk) then
    begin
      if Assigned(FOnRawJson) and not Chunk.JSONResponse.Trim.IsEmpty then
        FOnRawJson(Chunk.JSONResponse);

      if not Chunk.JSONResponse.Trim.IsEmpty then
        TOpenAIContainerFiles.CaptureRefsFromJson(
          Chunk.JSONResponse,
          FOnContainerId,
          FOnContainerFile);

      if (Chunk.EventType = TResponseStreamType.output_item_done) and
         Assigned(FOnToolDetail) then
        begin
          var ToolUseId := '';
          var Detail := '';

          if not Chunk.JSONResponse.Trim.IsEmpty then
            Detail := TToolDisplayDetail.FromOutputItemDoneJson(
              Chunk.JSONResponse,
              ToolUseId);

          if Detail.IsEmpty then
            Detail := TToolDisplayDetail.FromOutputItem(
              Chunk.Item,
              ToolUseId);

          if not Detail.IsEmpty then
            FOnToolDetail(ToolUseId, Detail);
        end;

      if (Chunk.EventType = TResponseStreamType.output_text_annotation_added) and
         Assigned(Chunk.Annotation) and
         Assigned(FOnContainerFile) then
      begin
          var ContainerFile := TOpenAIContainerFileRef.New(
            Chunk.Annotation.ContainerId,
            Chunk.Annotation.FileId,
            Chunk.Annotation.Filename);

          if ContainerFile.IsValid then
            FOnContainerFile(
              ContainerFile.ContainerId,
              ContainerFile.FileId,
              ContainerFile.Filename);
      end;
    end;

  Result := FInner.AggregateStreamEvents(Chunk, Buffer);
end;

function TTracingResponsesEventEngineManager.GetStreamEventDispatcher:
  IResponsesEventDispatcher;
begin
  Result := FInner.GetStreamEventDispatcher;
end;

{ TOpenAITextPayloadBuilder }

class function TOpenAITextPayloadBuilder.ResolvedProjectReview(
  const AContext: TOpenAIProjectReviewContext):
  TPromise<TOpenAIProjectReviewContext>;
begin
  Result := TPromise<TOpenAIProjectReviewContext>.Create(
    procedure(
      Resolve: TProc<TOpenAIProjectReviewContext>;
      Reject: TProc<Exception>)
    begin
      TThread.ForceQueue(nil,
        procedure
        begin
          Resolve(AContext);
        end);
    end);
end;

class function TOpenAITextPayloadBuilder.RejectedProjectReview(
  const AMessage: string): TPromise<TOpenAIProjectReviewContext>;
begin
  Result := TPromise<TOpenAIProjectReviewContext>.Create(
    procedure(
      Resolve: TProc<TOpenAIProjectReviewContext>;
      Reject: TProc<Exception>)
    begin
      TThread.ForceQueue(nil,
        procedure
        begin
          Reject(Exception.Create(AMessage));
        end);
    end);
end;

class procedure TOpenAITextPayloadBuilder.ApplyAgentGenerationSettings(
  const AState: TStateBuffer;
  const Params: TResponsesParams);
begin
  TRequestSettingsBuilder.ApplyMaxTokens(AState,
    procedure(Value: Integer)
    begin
      Params.MaxOutputTokens(Value);
    end);

  TRequestSettingsBuilder.TryApplyTemperature(AState,
    procedure(Value: Double)
    begin
      Params.Temperature(Value);
    end);

  TRequestSettingsBuilder.TryApplyTopP(AState,
    procedure(Value: Double)
    begin
      Params.TopP(Value);
    end);
end;

class function TOpenAITextPayloadBuilder.PrepareAgentProjectReview(
  const AClient: IGenAI;
  const ABrowser: IPythiaBrowser;
  const Blocks: IOpenAIDisplayBlockAggregator;
  State: TStateBuffer): TPromise<TOpenAIProjectReviewContext>;
begin
  var Empty := Default(TOpenAIProjectReviewContext);
  Empty.Prompt := State.Text;

  if Length(State.Integration.Agents) = 0 then
    Exit(ResolvedProjectReview(Empty));

  var Def: TOpenAIAgentCardDefinition;
  try
    Def := LoadAgentCard(ABrowser, State);
  except
    on E: Exception do
      Exit(RejectedProjectReview(E.Message));
  end;

  if Def.Kind <> oackMultiagent then
    Exit(ResolvedProjectReview(Empty));

  Result := TPromise<TOpenAIProjectReviewContext>.Create(
    procedure(
      Resolve: TProc<TOpenAIProjectReviewContext>;
      Reject: TProc<Exception>)
    begin
      try
        TOpenAIProjectReviewPrompt.PrepareAsync(
          AClient,
          ABrowser,
          Blocks,
          State,
          Def)
          .&Then(
            procedure(Context: TOpenAIProjectReviewContext)
            begin
              Resolve(Context);
            end)
          .&Catch(
            procedure(E: Exception)
            begin
              Reject(Exception.Create(E.Message));
            end);
      except
        on E: Exception do
          Reject(Exception.Create(E.Message));
      end;
    end);
end;

class procedure TOpenAITextPayloadBuilder.DisplaySingleAgentPreparation(
  const ABrowser: IPythiaBrowser;
  const Blocks: IOpenAIDisplayBlockAggregator;
  State: TStateBuffer);
begin
  if Length(State.Integration.Agents) = 0 then
    Exit;

  var Def := LoadAgentCard(ABrowser, State);
  if Def.Kind <> oackSingle then
    Exit;

  var AgentName := Def.Agent.Name.Trim;
  if AgentName.IsEmpty then
    AgentName := 'OpenAI agent';

  var Display := TOpenAIAgentTurnDisplay.Create(ABrowser, Blocks);
  try
    Display.AssistantText('Starting OpenAI agent...');
    Display.Status('Agent selected', AgentName);

    if HasHostedAgentTool(Def.Agent.Tools, 'web_search') then
      Display.AssistantText(
        'Let me search the web for current sources before drafting the answer.');
  finally
    Display.Free;
  end;
end;

class function TOpenAITextPayloadBuilder.BuildAndCheck(
  const ABrowser: IPythiaBrowser;
  const AContext: IContext;
  const ProjectReview: TOpenAIProjectReviewContext;
  State: TStateBuffer;
  out JsonPayloadAsString: string): TResponsesParamsProc;
begin
  var JsonPayload := TResponsesParams.Create;
  try
    var Payload := BuildPayload(ABrowser, AContext, ProjectReview, State);
    Payload(JsonPayload);
    JsonPayloadAsString := JsonPayload.ToFormat;
    Result := BuildPayload(ABrowser, AContext, ProjectReview, State);
  finally
    JsonPayload.Free;
  end;
end;

class function TOpenAITextPayloadBuilder.BuildAgentPayload(
  const ABrowser: IPythiaBrowser;
  const AContext: IContext;
  const ProjectReview: TOpenAIProjectReviewContext;
  State: TStateBuffer): TResponsesParamsProc;
var
  Effort: string;
begin
  var Def := LoadAgentCard(ABrowser, State);
  var PayloadState := State;

  var Agent := Def.Agent;
  if Def.Kind = oackMultiagent then
    begin
      PayloadState.Text := ProjectReview.Prompt;
      Agent := Def.Coordinator;
    end;

  var Model := State.Model.Trim;
  if Model.IsEmpty then
    Model := Agent.Model.Trim;

  var Instructions := Agent.Instructions;
  var Tools := BuildAgentTools(Agent.Tools, ProjectReview.FileIds);
  var ForceCodeInterpreter := Length(ProjectReview.FileIds) > 0;
  var IncludeWebSearchSources := HasHostedAgentTool(Agent.Tools, 'web_search');
  var Store :=
    Def.Runtime.Store or TStateChecking.UsesPreviousResponseId(PayloadState);
  var ParallelToolCalls := Def.Runtime.ParallelToolCalls;
  var MaxToolCalls := Def.Runtime.MaxToolCalls;
  var CurrentContent :=
    Demo.OpenAI.Helpers.TMessageContentBuilder.BuildContentBlocks(PayloadState);
  var Messages := AContext.BuildMessages(PayloadState, CurrentContent);

  Result :=
    procedure(Params: TResponsesParams)
    begin
      Params
        .Model(Model)
        .Instructions(Instructions)
        .Input(Messages)
        .Store(Store)
        .ParallelToolCalls(ParallelToolCalls)
        .Stream;

      if MaxToolCalls > 0 then
        Params.MaxToolCalls(MaxToolCalls);

      if not Tools.Trim.IsEmpty then
        Params.Tools(Tools);

      if ForceCodeInterpreter then
        Params.ToolChoice(Generation.ToolChoice.Hosted('code_interpreter'));

      var Includes: TArray<TOutputIncluding> := [];

      if IncludeWebSearchSources then
        Includes := Includes + [
          TOutputIncluding.web_search_call_action_sources
        ];

      if not TStateChecking.UsesPreviousResponseId(PayloadState) and not Store then
        Includes := Includes + [
          TOutputIncluding.reasoning_encrypted_content
        ];

      if Length(Includes) > 0 then
        Params.Include(Includes);

      if Assigned(AContext) and
         AContext.ShouldUsePreviousResponseId(PayloadState) then
        Params.PreviousResponseId(AContext.LastResponseId);

      ApplyAgentGenerationSettings(PayloadState, Params);
      ThinkingBuilder(PayloadState, Effort, Params);
      OutputConfigBuilder(PayloadState, Params);
    end;
end;

class function TOpenAITextPayloadBuilder.BuildAgentTools(
  const ToolsDef: TOpenAIAgentToolsDef;
  const CodeInterpreterFileIds: TArray<string>): string;
begin
  Result := '';

  var Contents: TArray<string> := [];

  if Length(CodeInterpreterFileIds) > 0 then
    begin
      var EmptyFileIds: TArray<string> := [];
      var Container := TCodeInterpreterContainerAutoParams.New(EmptyFileIds)
        .FileIds(CodeInterpreterFileIds);

      Contents := Contents + [
        TResponseCodeInterpreterParams.New
          .Container(Container)
          .ToJsonString(True)
      ];
    end;

  for var Tool in ToolsDef.Hosted do
    begin
      if not Tool.Enabled then
        Continue;

      if SameText(Tool.Name, 'web_search') then
        begin
          var WebSearch := TJsonWriter.NewObject;
          if not WebSearch.SetString('type', 'web_search') then
            raise Exception.Create('Unable to build the web search tool JSON.');

          Contents := Contents + [WebSearch.ToJson];
        end;
    end;

  if Length(Contents) > 0 then
    Result := TJSONArrayHelper.ArrayOfStringToJSonArrayAsString(Contents);
end;

class function TOpenAITextPayloadBuilder.BuildPayload(
  const ABrowser: IPythiaBrowser;
  const AContext: IContext;
  const ProjectReview: TOpenAIProjectReviewContext;
  State: TStateBuffer): TResponsesParamsProc;
var
  Effort: string;
begin
  if Length(State.Integration.Agents) > 0 then
    Exit(BuildAgentPayload(ABrowser, AContext, ProjectReview, State));

  var CurrentContent :=
    Demo.OpenAI.Helpers.TMessageContentBuilder.BuildContentBlocks(State);
  var Messages := AContext.BuildMessages(State, CurrentContent);

  Result :=
    procedure(Params: TResponsesParams)
    begin
      Params
        .Model(State.Model)
        .Input(Messages)
        .Stream;

      var Includes: TArray<TOutputIncluding> := [];

      if State.WebSearch then
        Includes := Includes + [
          TOutputIncluding.web_search_call_action_sources
        ];

      if HasFileSearchTool(AContext, State) then
        Includes := Includes + [
          TOutputIncluding.file_search_call_results
        ];

      if not TStateChecking.UsesPreviousResponseId(State) and
         not State.CoreParamsState.VendorSettings.Store then
        Includes := Includes + [
          TOutputIncluding.reasoning_encrypted_content
        ];

      if Length(Includes) > 0 then
        Params.Include(Includes);

      if Assigned(AContext) and AContext.ShouldUsePreviousResponseId(State) then
        Params.PreviousResponseId(AContext.LastResponseId);

      TRequestSettingsBuilder.Apply(State, Params);
      ToolsBuilder(ABrowser, AContext, State, Params);
      ThinkingBuilder(State, Effort, Params);
      OutputConfigBuilder(State, Params);
    end;
end;

class function TOpenAITextPayloadBuilder.HasHostedAgentTool(
  const ToolsDef: TOpenAIAgentToolsDef;
  const ToolName: string): Boolean;
begin
  for var Tool in ToolsDef.Hosted do
    if Tool.Enabled and SameText(Tool.Name, ToolName) then
      Exit(True);

  Result := False;
end;

class function TOpenAITextPayloadBuilder.HasFileSearchTool(
  const AContext: IContext;
  const AState: TStateBuffer): Boolean;
begin
  for var Item in AState.KnowledgeSearch do
    if not Item.FileId.Trim.IsEmpty then
      Exit(True);

  if Assigned(AContext) and
     not AContext.ShouldUsePreviousResponseId(AState) and
     (Length(AContext.HistoricalVectorStoreIds) > 0) then
    Exit(True);

  Result := False;
end;

class function TOpenAITextPayloadBuilder.LoadAgentCard(
  const ABrowser: IPythiaBrowser;
  const AState: TStateBuffer): TOpenAIAgentCardDefinition;
begin
  Result := Default(TOpenAIAgentCardDefinition);

  if Length(AState.Integration.Agents) = 0 then
    raise Exception.Create('No OpenAI agent card is selected for this turn.');

  var CardsFile := ABrowser.GetAgentCardsFileName;
  if not FileExists(CardsFile) then
    raise Exception.Create('Agent cards file not found: ' + CardsFile);

  var CardsJson := TFileIOHelper.LoadFromFile(CardsFile);
  var CardId := AState.Integration.Agents[0].Id;

  if not TOpenAIAgentCardReader.TryRead(
    CardsJson,
    CardId,
    TPath.GetDirectoryName(CardsFile),
    Result) then
    raise Exception.CreateFmt(
      'OpenAI agent card not found or unsupported: %s',
      [CardId]);
end;

class procedure TOpenAITextPayloadBuilder.OutputConfigBuilder(
  const AState: TStateBuffer;
  const Params: TResponsesParams);
begin
  TStructuredOutputBuilder.TryGetTextConfigParam(AState,
    procedure
    begin
      Params.Text(
        TResponseOption.json_schema,
        TStructuredOutputBuilder.GetTTextConfig(AState));
    end);
end;

class procedure TOpenAITextPayloadBuilder.ThinkingBuilder(
  const AState: TStateBuffer;
  out Effort: string;
  const Params: TResponsesParams);
var
  LocalEffort: string;
begin
  TThinkingBuilder.TryGetOutputConfig(AState, LocalEffort,
    procedure
    begin
      Params.Reasoning(
        TThinkingBuilder.GetTReasoningConfig(AState, LocalEffort));
    end);

  Effort := LocalEffort;
end;

class procedure TOpenAITextPayloadBuilder.ToolsBuilder(
  const ABrowser: IPythiaBrowser;
  const AContext: IContext;
  const AState: TStateBuffer;
  const Params: TResponsesParams);
var
  Content: string;
  Pat: string;
begin
  var UsePreviousResponseId :=
    Assigned(AContext) and AContext.ShouldUsePreviousResponseId(AState);

  var HistoricalVectorStoreIds: TArray<string> := [];
  if Assigned(AContext) and not UsePreviousResponseId then
    HistoricalVectorStoreIds := AContext.HistoricalVectorStoreIds;

  var CurrentVectorStoreIds: TArray<string> := [];

  for var Item in AState.KnowledgeSearch do
    if not Item.FileId.Trim.IsEmpty then
      CurrentVectorStoreIds := CurrentVectorStoreIds + [Item.FileId.Trim];

  var VectorStoreIds: TArray<string> :=
    HistoricalVectorStoreIds + CurrentVectorStoreIds;
  VectorStoreIds := TArrayUtils.ArrayRemoveDuplicates(VectorStoreIds);

  if not (
    AState.WebSearch or
    TStateChecking.HasMCP(AState) or
    TStateChecking.HasSkills(AState) or
    (Length(VectorStoreIds) > 0)) then
    Exit;

  var Contents: TArray<string> := [];

  if AState.WebSearch then
    begin
      var WebSearch := TJsonWriter.NewObject;
      if not WebSearch.SetString('type', 'web_search') then
        raise Exception.Create('Unable to build the web search tool JSON.');

      Contents := Contents + [WebSearch.ToJson];
    end;

  if Length(VectorStoreIds) > 0 then
    Contents := Contents + [
      file_search(VectorStoreIds).ToJsonString(True)
    ];

  if TStateChecking.HasMCP(AState) and
     FileExists(ABrowser.GetMcpCardsFileName) then
    begin
      var MCPJsonAsString :=
        TFileIOHelper.LoadFromFile(ABrowser.GetMcpCardsFileName);
      var Reader := TJsonReader.Parse(MCPJsonAsString);

      for var Item in AState.Integration.Mcp do
        begin
          if not TParamsGetter.TryReadMCPCard(
            Reader, Item.Name, Content, Pat) then
            Continue;

          if SameText(Item.Name, 'github') and not Pat.Trim.IsEmpty then
            Content := Format(Content, [Pat]);

          var CheckContent := TJsonReader.Parse(Content);
          if not CheckContent.IsValid then
            raise Exception.CreateFmt('invalid JSON:#10%s', [Content]);

          Contents := Contents + [Content];
        end;
    end;

  if TStateChecking.HasSkills(AState) then
    begin
      var SkillRefs: TArray<TContainerSkillParams> := [];

      for var Item in TParamsGetter.GetSkills(AState) do
        begin
          var SkillId := Item.Id.Trim;
          if SkillId.IsEmpty then
            Continue;

          SkillRefs := SkillRefs + [
            Generation.Shell.CreateSkillReference
              .SkillId(SkillId)
              .Version(Item.Version)
          ];
        end;

      if Length(SkillRefs) > 0 then
        begin
          var ShellFileIds := TParamsGetter.GetShellContainerFileIds(AState);
          var Container := Generation.Shell.CreateContainerAuto
            .Skills(SkillRefs);

          if Length(ShellFileIds) > 0 then
            Container.FileIds(ShellFileIds);

          Contents := Contents + [
            Generation.Tool.CreateShell
              .Environment(Container)
              .ToJsonString(True)
          ];
        end;
    end;

  if Length(Contents) > 0 then
    Params.Tools(
      TJSONArrayHelper.ArrayOfStringToJSonArrayAsString(Contents));

  if (Length(VectorStoreIds) > 0) and not TStateChecking.HasSkills(AState) then
    Params.ToolChoice(Generation.ToolChoice.Hosted('file_search'));
end;

{ TOpenAITextInputFiles }

class procedure TOpenAITextInputFiles.Cleanup(
  const AClientUtils: IOpenAIClientUtils;
  const State: TStateBuffer);
begin
  var FileIds: TArray<string> := [];

  for var Item in State.Files do
    if not Item.FileId.Trim.IsEmpty then
      FileIds := FileIds + [Item.FileId.Trim];

  if Length(FileIds) > 0 then
    AClientUtils.AsyncDeleteAllFire(FileIds);
end;

{ TOpenAITextOutputFiles }

class procedure TOpenAITextOutputFiles.FireDownloads(
  const ABrowser: IPythiaBrowser;
  const AClientUtils: IOpenAIClientUtils;
  const ContainerIds, IDs: TArray<string>;
  const Filenames: TArray<string>);
begin
  try
    for var index := Low(IDs) to High(IDs) do
      AClientUtils.AsyncDownloadContainerFileAs(
        ContainerIds[index],
        IDs[index],
        Filenames[index]);
  except
    on E: Exception do
      ABrowser.DisplayError(Format('Container file download dispatch failed: %s (%s)',
        [E.Message, E.ClassName]));
  end;
end;

class function TOpenAITextOutputFiles.ResolveDownloadFilenames(
  const ABrowser: IPythiaBrowser;
  const Names: TArray<string>;
  const State: TStateBuffer): TArray<string>;
begin
  var MediaFolder := ABrowser.GetMediaFolder;
  if not TDirectory.Exists(MediaFolder) then
    TDirectory.CreateDirectory(MediaFolder);

  SetLength(Result, Length(Names));
  for var index := Low(Names) to High(Names) do
    begin
      var Candidate := Names[index].Trim;
      if Candidate.IsEmpty then
        Candidate := 'File_Result.unknown';

      Result[index] := TParamsGetter.CheckFilename(Candidate, MediaFolder);
    end;
end;

{ TOpenAITextErrorHandler }

class procedure TOpenAITextErrorHandler.Handle(
  const E: Exception;
  const ABrowser: IPythiaBrowser;
  var State: TStateBuffer;
  const Blocks: IOpenAIDisplayBlockAggregator;
  const EmitGuard: IEmitGuard);
begin
  if not E.Message.ToLowerInvariant.StartsWith(ABORTED_INDICATOR) then
    begin
      State.Error := True;
      State.ErrorMessage := E.Message;
      EmitGuard.TryEmit(TFinalizeData.FromException(E, State, Blocks));
      Exit;
    end;

  var MessageContent := S_ABORTED;
  State.AddStreamedText(MessageContent);

  if Assigned(Blocks) then
    Blocks.AppendAssistantText(MessageContent);

  ABrowser.DisplayStream(MessageContent, '', False);
  EmitGuard.TryEmit(TFinalizeData.FromState(State, Blocks));
end;

{ TOpenAITextToolEvents }

class procedure TOpenAITextToolEvents.FlushDetails(
  const Browser: IPythiaBrowser;
  const Blocks: IOpenAIDisplayBlockAggregator;
  const Buffer: TResponsesEventData;
  const ToolDetails: IOpenAIToolDetails;
  const DisplayInBrowser: Boolean);
begin
  for var Snapshot in Buffer.ToolResults do
    begin
      var Detail := '';
      if not ToolDetails.TryTake(Snapshot.ToolUseId, Detail) then
        Continue;

      Blocks.AppendToolResult(Snapshot.ToolUseId, Detail);

      if DisplayInBrowser then
        Browser.DisplayToolOutputStream(Detail, False);
    end;
end;

class procedure TOpenAITextToolEvents.OpenLastResult(
  const Browser: IPythiaBrowser;
  const Blocks: IOpenAIDisplayBlockAggregator;
  const Buffer: TResponsesEventData);
begin
  if Length(Buffer.ToolResults) = 0 then
    Exit;

  var Snapshot := Buffer.ToolResults[High(Buffer.ToolResults)];
  var Title := TToolDisplayTitle.FromToolResultKind(Snapshot.Kind);
  Blocks.AppendToolUse(Snapshot.ToolUseId, Title);
  Browser.DisplayToolOutputStart(Title, False);
end;

class procedure TOpenAITextToolEvents.RegisterLastCall(
  const Browser: IPythiaBrowser;
  const Blocks: IOpenAIDisplayBlockAggregator;
  const Buffer: TResponsesEventData);
begin
  if Length(Buffer.ToolCalls) = 0 then
    Exit;

  var Snapshot := Buffer.ToolCalls[High(Buffer.ToolCalls)];
  var Title := TToolDisplayTitle.FromToolCall(Snapshot);
  Blocks.RegisterToolUseStop(Snapshot, Title);

  if Snapshot.InputJson.Trim.IsEmpty then
    Browser.DisplayToolStatus(Title, False)
  else
    begin
      Browser.DisplayToolOutputStart(Title, False);
      Browser.DisplayToolOutputStream(Snapshot.InputJson.Trim, False);
    end;
end;

class procedure TOpenAITextToolEvents.StopLastResult(
  const Browser: IPythiaBrowser;
  const Blocks: IOpenAIDisplayBlockAggregator;
  const Buffer: TResponsesEventData;
  const ForceError: Boolean);
begin
  if Length(Buffer.ToolResults) = 0 then
    Exit;

  var Snapshot := Buffer.ToolResults[High(Buffer.ToolResults)];
  if ForceError then
    Snapshot.IsError := True;

  Blocks.RegisterToolResultStop(Snapshot);

  if Snapshot.IsError then
    Browser.DisplayToolError(
      TToolDisplayTitle.FromToolResultKind(Snapshot.Kind),
      Buffer.Message,
      False);
end;

{ TOpenAITextLocalApply }

class procedure TOpenAITextLocalApply.FinalStatus(
  const Display: TOpenAIAgentTurnDisplay;
  const Title, Detail: string);
begin
  if not Assigned(Display) then
    Exit;

  if Detail.Trim.IsEmpty then
    begin
      Display.Status(Title);
      Exit;
    end;

  var ToolUseId := 'local-apply:' + TGUID.NewGuid.ToString;
  Display.ToolUse(ToolUseId, Title);
  Display.ToolResult(ToolUseId, Title, Detail);
end;

class function TOpenAITextLocalApply.ShouldOffer(
  const State: TStateBuffer): Boolean;
begin
  Result :=
    (not State.Project.FullPath.Trim.IsEmpty) and
    (Length(State.Integration.Agents) > 0) and
    SameText(
      State.Integration.Agents[0].Id,
      'openai-sandbox-to-local-code-edit');
end;

class function TOpenAITextLocalApply.ResponseText(
  const Value: TResponsesEventData;
  const State: TStateBuffer): string;
begin
  Result := Value.AssistantText;
  if Result.Trim.IsEmpty then
    Result := State.TextBuffer;
end;

class procedure TOpenAITextLocalApply.OfferIfPresent(
  const ABrowser: IPythiaBrowser;
  const Blocks: IOpenAIDisplayBlockAggregator;
  const Value: TResponsesEventData;
  const State: TStateBuffer);
begin
  if not ShouldOffer(State) then
    Exit;

  var Plan: TOpenAILocalApplyPlan;
  var ExtractError := '';
  if not TOpenAILocalApply.TryExtract(ResponseText(Value, State), Plan, ExtractError) then
    begin
      if not ExtractError.Trim.IsEmpty then
        begin
          var Display := TOpenAIAgentTurnDisplay.Create(ABrowser, Blocks);
          try
            FinalStatus(
              Display,
              'Local patch proposal ignored',
              ExtractError);
          finally
            Display.Free;
          end;
        end;
      Exit;
    end;

  var Display := TOpenAIAgentTurnDisplay.Create(ABrowser, Blocks);
  try
    Display.Status('Local patch detected');

    var DialogRequest := TWebDecisionDlgRequest.Markdown(
      'Apply sandbox patch locally?',
      TOpenAILocalApply.PreviewMarkdown(Plan),
      [
        TWebDecisionDlgButton.Create(
          'apply',
          'Apply locally',
          wdrDefault),
        TWebDecisionDlgButton.Create(
          'skip',
          'Skip',
          wdrCancel)
      ]);
    DialogRequest.FooterText :=
      'The OpenAI sandbox has already been processed. This step applies the returned diff to the selected local folder.';

    var Decision := ABrowser.WebDecisionDlg(DialogRequest);
    if not (Decision.Success and SameText(Decision.ChoiceId, 'apply')) then
      begin
        FinalStatus(
          Display,
          'Local patch skipped',
          'The sandbox change was not applied to the selected local folder.');
        Exit;
      end;

    var Detail := '';
    if TOpenAILocalApply.TryApply(Plan, State.Project.FullPath, Detail) then
      begin
        FinalStatus(Display, 'Local patch applied', Detail);
      end
    else
      begin
        FinalStatus(Display, 'Local patch failed', Detail);
        ABrowser.DisplayError(Detail);
      end;
  finally
    Display.Free;
  end;
end;

{ TOpenAITextCompletionHandler }

class procedure TOpenAITextCompletionHandler.HandleSuccess(
  const Value: TResponsesEventData;
  const AClient: IGenAI;
  const ABrowser: IPythiaBrowser;
  const AClientUtils: IOpenAIClientUtils;
  var State: TStateBuffer;
  var OutputFiles: TArray<TOpenAIContainerFileRef>;
  const ContainerIdsSeen: TArray<string>;
  const ToolDetails: IOpenAIToolDetails;
  const Blocks: IOpenAIDisplayBlockAggregator;
  const EmitGuard: IEmitGuard);
begin
  State.JsonResponse :=
    TOpenAIJsonResponseHelper.NormalizeJsonResponse(State.JsonResponse);
  TOpenAITextToolEvents.FlushDetails(ABrowser, Blocks, Value, ToolDetails, False);
  TOpenAITextInputFiles.Cleanup(AClientUtils, State);

  if SameText(Value.Status, TResponseStreamType.incomplete.ToString) then
    begin
      var Error := Exception.Create(
        'OpenAI response incomplete. Increase max output tokens or disable the explicit limit.');
      try
        TOpenAITextErrorHandler.Handle(Error, ABrowser, State, Blocks, EmitGuard);
      finally
        Error.Free;
      end;
      Exit;
    end;

  try
    for var Item in TOpenAIContainerFiles.DiscoverOutputFiles(AClient, ContainerIdsSeen) do
      if TOpenAIContainerFiles.AddFileRef(
        OutputFiles,
        Item.ContainerId,
        Item.FileId,
        Item.Filename) then
        State.AddOutputFileId(Item.FileId);
  except
    on E: Exception do
      ABrowser.DisplayError(
        Format('Container file discovery failed: %s (%s)',
          [E.Message, E.ClassName]));
  end;

  if Length(OutputFiles) = 0 then
    begin
      if TOpenAITextLocalApply.ShouldOffer(State) then
        begin
          var CapturedValue := Value;
          var CapturedState := State;
          TTask.Run(
            procedure
            begin
              try
                TOpenAITextLocalApply.OfferIfPresent(
                  ABrowser,
                  Blocks,
                  CapturedValue,
                  CapturedState);
              except
                on E: Exception do
                  begin
                    var ErrorMessage := E.Message;
                    TThread.Queue(nil,
                      procedure
                      begin
                        ABrowser.DisplayError(ErrorMessage);
                      end);
                  end;
              end;

              TThread.Queue(nil,
                procedure
                begin
                  EmitGuard.TryEmit(TFinalizeData.FromSuccess(
                    CapturedValue,
                    CapturedState,
                    Blocks));
                end);
            end);
          Exit;
        end;

      EmitGuard.TryEmit(TFinalizeData.FromSuccess(Value, State, Blocks));
      Exit;
    end;

  var ContainerIds: TArray<string> := [];
  var IDs: TArray<string> := [];
  var Names: TArray<string> := [];
  for var Item in OutputFiles do
    begin
      ContainerIds := ContainerIds + [Item.ContainerId];
      IDs := IDs + [Item.FileId];
      Names := Names + [Item.Filename];
    end;

  try
    State.FileResults := TOpenAITextOutputFiles.ResolveDownloadFilenames(
      ABrowser,
      Names,
      State);

    if TOpenAITextLocalApply.ShouldOffer(State) then
      begin
        var CapturedValue := Value;
        var CapturedState := State;
        var CapturedContainerIds := ContainerIds;
        var CapturedIDs := IDs;

        TTask.Run(
          procedure
          begin
            try
              TOpenAITextLocalApply.OfferIfPresent(
                ABrowser,
                Blocks,
                CapturedValue,
                CapturedState);
            except
              on E: Exception do
                begin
                  var ErrorMessage := E.Message;
                  TThread.Queue(nil,
                    procedure
                    begin
                      ABrowser.DisplayError(ErrorMessage);
                    end);
                end;
            end;

            TThread.Queue(nil,
              procedure
              begin
                EmitGuard.TryEmit(TFinalizeData.FromSuccess(
                  CapturedValue,
                  CapturedState,
                  Blocks));
                TOpenAITextOutputFiles.FireDownloads(
                  ABrowser,
                  AClientUtils,
                  CapturedContainerIds,
                  CapturedIDs,
                  CapturedState.FileResults);
              end);
          end);
        Exit;
      end;

    EmitGuard.TryEmit(TFinalizeData.FromSuccess(Value, State, Blocks));
    TOpenAITextOutputFiles.FireDownloads(
      ABrowser,
      AClientUtils,
      ContainerIds,
      IDs,
      State.FileResults);
  except
    on E: Exception do
      begin
        ABrowser.DisplayError(
          Format('Container file resolution failed: %s (%s)',
            [E.Message, E.ClassName]));
        EmitGuard.TryEmit(TFinalizeData.FromSuccess(Value, State, Blocks));
      end;
  end;
end;

{ TOpenAITextCallbacks }

class function TOpenAITextCallbacks.Create(
  const ABrowser: IPythiaBrowser;
  const TurnState: IOpenAITextTurnState;
  const StreamGate: IOpenAIStreamCallbackGate;
  const Blocks: IOpenAIDisplayBlockAggregator;
  const ToolDetails: IOpenAIToolDetails): IResponsesEventEngineManager;
begin
  Result := TResponsesEventEngineManagerFactory.CreateInstance(
    function: TResponseStreamEventCallBack
    begin
      Result := Default(TResponseStreamEventCallBack);
      Result.Sender := nil;

      Result.OnOutputTextDelta :=
        procedure(Sender: TObject; Buffer: TResponsesEventData)
        begin
          if not StreamGate.CanContinue(ABrowser.Escape) then
            Exit;

          var Data := TurnState.Data;
          Data.Value.AddStreamedText(Buffer.LastAssistantDelta);
          Blocks.AppendAssistantDelta(Buffer.LastAssistantDelta);
          ABrowser.DisplayStream(Buffer.LastAssistantDelta, '', False);
        end;

      Result.OnRefusalDelta :=
        procedure(Sender: TObject; Buffer: TResponsesEventData)
        begin
          if not StreamGate.CanContinue(ABrowser.Escape) then
            Exit;

          var Data := TurnState.Data;
          Data.Value.AddStreamedText(Buffer.Delta);
          Blocks.AppendAssistantDelta(Buffer.Delta);
          ABrowser.DisplayStream(Buffer.Delta, '', False);
        end;

      Result.OnReasoningTextDelta :=
        procedure(Sender: TObject; Buffer: TResponsesEventData)
        begin
          if not StreamGate.CanContinue(ABrowser.Escape) then
            Exit;

          var Data := TurnState.Data;
          Data.Value.AddStreamedThinking(Buffer.LastReasoningDelta);
          Blocks.AppendReasoningDelta(Buffer.LastReasoningDelta);
          ABrowser.DisplayStream('', Buffer.LastReasoningDelta, False);
        end;

      Result.OnReasoningSummaryTextDelta :=
        procedure(Sender: TObject; Buffer: TResponsesEventData)
        begin
          if not StreamGate.CanContinue(ABrowser.Escape) then
            Exit;

          var Data := TurnState.Data;
          Data.Value.AddStreamedThinking(Buffer.LastReasoningSummaryDelta);
          Blocks.AppendReasoningDelta(Buffer.LastReasoningSummaryDelta);
          ABrowser.DisplayStream('', Buffer.LastReasoningSummaryDelta, False);
        end;

      Result.OnFunctionCallArgumentsDone :=
        procedure(Sender: TObject; Buffer: TResponsesEventData)
        begin
          if not StreamGate.CanContinue(ABrowser.Escape) then
            Exit;

          TOpenAITextToolEvents.RegisterLastCall(ABrowser, Blocks, Buffer);
        end;

      Result.OnCustomToolCallInputDone :=
        procedure(Sender: TObject; Buffer: TResponsesEventData)
        begin
          if not StreamGate.CanContinue(ABrowser.Escape) then
            Exit;

          TOpenAITextToolEvents.RegisterLastCall(ABrowser, Blocks, Buffer);
        end;

      Result.OnMcpCallArgumentsDone :=
        procedure(Sender: TObject; Buffer: TResponsesEventData)
        begin
          if not StreamGate.CanContinue(ABrowser.Escape) then
            Exit;

          TOpenAITextToolEvents.RegisterLastCall(ABrowser, Blocks, Buffer);
        end;

      Result.OnOutputItemAdded :=
        procedure(Sender: TObject; Buffer: TResponsesEventData)
        begin
          if not StreamGate.CanContinue(ABrowser.Escape) then
            Exit;

//          if Buffer.CurrentBlockType = rbtToolResult then
            TOpenAITextToolEvents.OpenLastResult(ABrowser, Blocks, Buffer);
        end;

      Result.OnCodeInterpreterCallCodeDelta :=
        procedure(Sender: TObject; Buffer: TResponsesEventData)
        begin
          if not StreamGate.CanContinue(ABrowser.Escape) then
            Exit;

          if Buffer.LastToolResultDelta.IsEmpty then
            Exit;

          Blocks.AppendToolResultDelta(Buffer.LastToolResultDelta);
          ABrowser.DisplayToolOutputStream(Buffer.LastToolResultDelta, False);
        end;

      Result.OnCodeInterpreterCallCompleted :=
        procedure(Sender: TObject; Buffer: TResponsesEventData)
        begin
          if not StreamGate.CanContinue(ABrowser.Escape) then
            Exit;

          TOpenAITextToolEvents.StopLastResult(ABrowser, Blocks, Buffer, False);
        end;

      Result.OnWebSearchCallCompleted :=
        procedure(Sender: TObject; Buffer: TResponsesEventData)
        begin
          if not StreamGate.CanContinue(ABrowser.Escape) then
            Exit;

          TOpenAITextToolEvents.StopLastResult(ABrowser, Blocks, Buffer, False);
        end;

      Result.OnFileSearchCallCompleted :=
        procedure(Sender: TObject; Buffer: TResponsesEventData)
        begin
          if not StreamGate.CanContinue(ABrowser.Escape) then
            Exit;

          TOpenAITextToolEvents.StopLastResult(ABrowser, Blocks, Buffer, False);
        end;

      Result.OnImageGenerationCallCompleted :=
        procedure(Sender: TObject; Buffer: TResponsesEventData)
        begin
          if not StreamGate.CanContinue(ABrowser.Escape) then
            Exit;

          TOpenAITextToolEvents.StopLastResult(ABrowser, Blocks, Buffer, False);
        end;

      Result.OnMcpListToolsCompleted :=
        procedure(Sender: TObject; Buffer: TResponsesEventData)
        begin
          if not StreamGate.CanContinue(ABrowser.Escape) then
            Exit;

          TOpenAITextToolEvents.StopLastResult(ABrowser, Blocks, Buffer, False);
        end;

      Result.OnMcpListToolsFailed :=
        procedure(Sender: TObject; Buffer: TResponsesEventData)
        begin
          if not StreamGate.CanContinue(ABrowser.Escape) then
            Exit;

          TOpenAITextToolEvents.StopLastResult(ABrowser, Blocks, Buffer, True);
        end;

      Result.OnOutputItemDone :=
        procedure(Sender: TObject; Buffer: TResponsesEventData)
        begin
          if not StreamGate.CanContinue(ABrowser.Escape) then
            Exit;

          TOpenAITextToolEvents.FlushDetails(
            ABrowser,
            Blocks,
            Buffer,
            ToolDetails,
            True);
          Blocks.CloseCurrent;
        end;

      Result.OnDoCancel :=
        function: Boolean
        begin
          Result := not StreamGate.CanContinue(ABrowser.Escape);
        end;

      Result.OnCancellation :=
        procedure(Sender: TObject)
        begin
          StreamGate.Stop;
          Blocks.CloseCurrent;
        end;

      Result.OnError :=
        procedure(Sender: TObject; Buffer: TResponsesEventData)
        begin
          StreamGate.Stop;
          ABrowser.ReasoningHide;
        end;
    end);
end;

class function TOpenAITextCallbacks.Trace(
  const Inner: IResponsesEventEngineManager;
  const ABrowser: IPythiaBrowser;
  const TurnState: IOpenAITextTurnState;
  const StreamGate: IOpenAIStreamCallbackGate;
  const ToolDetails: IOpenAIToolDetails): IResponsesEventEngineManager;
begin
  Result := TTracingResponsesEventEngineManager.Create(
    Inner,
    procedure(Json: string)
    begin
      if not StreamGate.CanContinue(ABrowser.Escape) then
        Exit;

      var Data := TurnState.Data;
      Data.Value.AddJsonResponse(Json);
    end,
    procedure(ContainerId: string)
    begin
      if not StreamGate.CanContinue(ABrowser.Escape) then
        Exit;

      var Data := TurnState.Data;
      TOpenAIContainerFiles.AddContainerId(
        Data.ContainerIdsSeen,
        ContainerId);
    end,
    procedure(ContainerId, FileId, Filename: string)
    begin
      if not StreamGate.CanContinue(ABrowser.Escape) then
        Exit;

      var Data := TurnState.Data;
      TOpenAIContainerFiles.AddContainerId(
        Data.ContainerIdsSeen,
        ContainerId);
      if TOpenAIContainerFiles.AddFileRef(
        Data.OutputFiles,
        ContainerId,
        FileId,
        Filename) then
        Data.Value.AddOutputFileId(FileId);
    end,
    procedure(ToolUseId, Detail: string)
    begin
      if not StreamGate.CanContinue(ABrowser.Escape) then
        Exit;

      ToolDetails.Add(ToolUseId, Detail);
    end);
end;

{ TOpenAITextTurn }

class procedure TOpenAITextTurn.Execute(
  const AClient: IGenAI;
  const ABrowser: IPythiaBrowser;
  const AContext: IContext;
  const AClientUtils: IOpenAIClientUtils;
  AState: TStateBuffer;
  const AOnFinalize: TManagedItemFinalizeProc);
var
  JsonPayloadAsString: string;
  StartPreparedTurn: TProc<TOpenAIProjectReviewContext>;
begin
  var TurnState: IOpenAITextTurnState := TOpenAITextTurnState.Create(AState);
  var Data := TurnState.Data;
  var ToolDetails: IOpenAIToolDetails := TOpenAIToolDetails.Create;
  var StreamGate: IOpenAIStreamCallbackGate := TOpenAIStreamCallbackGate.Create;
  var Blocks: IOpenAIDisplayBlockAggregator :=
    TOpenAIDisplayBlockAggregator.Create;
  var EmitGuard: IEmitGuard := TEmitGuard.Create(AOnFinalize);

  {--- The text category model is supplied by Pythia with each prompt state. }
  Data.Value.Model := Data.Value.Models.Items[TEXT_GENERATION_INDEX].Model;

  StartPreparedTurn :=
    procedure(ProjectReview: TOpenAIProjectReviewContext)
    var
      Payload: TResponsesParamsProc;
    begin
      {--- Build the SDK payload after the optional agent preparation so
           payload errors can still be persisted in the finalized Pythia item.
      }
      try
        Payload := TOpenAITextPayloadBuilder.BuildAndCheck(
          ABrowser,
          AContext,
          ProjectReview,
          Data.Value,
          JsonPayloadAsString);
        Data.Value.JsonRequest := JsonPayloadAsString;
      except
        on E: Exception do
          begin
            Data.Value.JsonRequest := JsonPayloadAsString;
            TOpenAITextErrorHandler.Handle(
              E,
              ABrowser,
              Data.Value,
              Blocks,
              EmitGuard);
            Exit;
          end;
      end;

      TOpenAITextPayloadBuilder.DisplaySingleAgentPreparation(
        ABrowser,
        Blocks,
        Data.Value);

      {--- Typed callbacks update the live UI; the tracing decorator captures
           raw JSON, tool details and generated-file references for the final
           turn.
      }
      var TypedEventCallbacks := TOpenAITextCallbacks.Create(
        ABrowser,
        TurnState,
        StreamGate,
        Blocks,
        ToolDetails);

      var EventCallbacks := TOpenAITextCallbacks.Trace(
        TypedEventCallbacks,
        ABrowser,
        TurnState,
        StreamGate,
        ToolDetails);

      {--- Responses streaming is asynchronous: success, cancellation and
           failures all pass through guarded finalization.
      }
      try
        AClient.Responses.AsyncAwaitCreateStream(Payload, EventCallbacks)
        .&Then(
          procedure(Value: TResponsesEventData)
          begin
            var Data := TurnState.Data;
            StreamGate.Stop;
            TOpenAITextCompletionHandler.HandleSuccess(
              Value,
              AClient,
              ABrowser,
              AClientUtils,
              Data.Value,
              Data.OutputFiles,
              Data.ContainerIdsSeen,
              ToolDetails,
              Blocks,
              EmitGuard);
          end)
        .&Catch(
          procedure(E: Exception)
          begin
            var Data := TurnState.Data;
            StreamGate.Stop;
            TOpenAITextInputFiles.Cleanup(AClientUtils, Data.Value);
            TOpenAITextErrorHandler.Handle(
              E,
              ABrowser,
              Data.Value,
              Blocks,
              EmitGuard);
          end);
      except
        on E: Exception do
          begin
            StreamGate.Stop;
            TOpenAITextInputFiles.Cleanup(AClientUtils, Data.Value);
            TOpenAITextErrorHandler.Handle(
              E,
              ABrowser,
              Data.Value,
              Blocks,
              EmitGuard);
          end;
      end;
    end;

  TOpenAITextPayloadBuilder.PrepareAgentProjectReview(
    AClient,
    ABrowser,
    Blocks,
    Data.Value)
    .&Then(
      procedure(ProjectReview: TOpenAIProjectReviewContext)
      begin
        var Starter := StartPreparedTurn;
        StartPreparedTurn := nil;
        if Assigned(Starter) then
          Starter(ProjectReview);
      end)
    .&Catch(
      procedure(E: Exception)
      begin
        StartPreparedTurn := nil;
        Data.Value.JsonRequest := JsonPayloadAsString;
        TOpenAITextErrorHandler.Handle(
          E,
          ABrowser,
          Data.Value,
          Blocks,
          EmitGuard);
      end);
end;

end.
