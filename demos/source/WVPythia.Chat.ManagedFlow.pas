unit WVPythia.Chat.ManagedFlow;

interface

uses
  System.SysUtils, REST.Json.Types,
  WVPythia.ChatSession.Controller;

type
  {--- Classes pour la désérialisation JSON renvoyé par le panneau de configuration }

  TCoreSystemPrompt = class
  private
    FSystemPrompt: string;
    FEnabled: Boolean;
  public
    property SystemPrompt: string read FSystemPrompt write FSystemPrompt;
    property Enabled: Boolean read FEnabled write FEnabled;
  end;

  TCoreMaxTokens = class
  private
    FMaxToken: Int64;
    FEnabled: Boolean;
  public
    property MaxToken: Int64 read FMaxToken write FMaxToken;
    property Enabled: Boolean read FEnabled write FEnabled;
  end;

  TCoreStopString = class
  private
    FStopString: TArray<string>;
    FEnabled: Boolean;
  public
    property StopString: TArray<string> read FStopString write FStopString;
    property Enabled: Boolean read FEnabled write FEnabled;
  end;

  TCoreSettings = class
  private
    FTemperature: Double;
    FMaxToken: TCoreMaxTokens;
    FStopString: TCoreStopString;
  public
    property Temperature: Double read FTemperature write FTemperature;
    property MaxToken: TCoreMaxTokens read FMaxToken write FMaxToken;
    property StopString: TCoreStopString read FStopString write FStopString;

    destructor Destroy; override;
  end;

  TCoreTopK = class
  private
    FTopK: Int64;
    FEnabled: Boolean;
  public
    property TopK: Int64 read FTopK write FTopK;
    property Enabled: Boolean read FEnabled write FEnabled;
  end;

  TCorePresencePenalty = class
  private
    FPresencePenalty: Double;
    FEnabled: Boolean;
  public
    property PresencePenalty: Double read FPresencePenalty write FPresencePenalty;
    property Enabled: Boolean read FEnabled write FEnabled;
  end;

  TCoreTopP = class
  private
    FTopP: Double;
    FEnabled: Boolean;
  public
    property TopP: Double read FTopP write FTopP;
    property Enabled: Boolean read FEnabled write FEnabled;
  end;

  TCoreSeed = class
  private
    FSeed: Int64;
    FEnabled: Boolean;
  public
    property Seed: Int64 read FSeed write FSeed;
    property Enabled: Boolean read FEnabled write FEnabled;
  end;

  TCoreSampling = class
  private
    FTopK: TCoreTopK;
    FPresencePenalty: TCorePresencePenalty;
    FTopP: TCoreTopP;
    FSeed: TCoreSeed;
  public
    property TopK: TCoreTopK read FTopK write FTopK;
    property PresencePenalty: TCorePresencePenalty read FPresencePenalty write FPresencePenalty;
    property TopP: TCoreTopP read FTopP write FTopP;
    property Seed: TCoreSeed read FSeed write FSeed;

    destructor Destroy; override;
  end;

  TCoreStructuredOutput = class
  private
    FJsonSchema: string;
    FEnabled: Boolean;
  public
    property JsonSchema: string read FJsonSchema write FJsonSchema;
    property Enabled: Boolean read FEnabled write FEnabled;
  end;

  TCoreVendorSettings = class
  private
    FParallelToolCalls: Boolean;
    FBackgroundResponse: Boolean;
    FUsingPreviousId: Boolean;
    FStore: Boolean;
  public
    property ParallelToolCalls: Boolean read FParallelToolCalls write FParallelToolCalls;
    property BackgroundResponse: Boolean read FBackgroundResponse write FBackgroundResponse;
    property UsingPreviousId: Boolean read FUsingPreviousId write FUsingPreviousId;
    property Store: Boolean read FStore write FStore;
  end;

  TCoreParamsState = class
  private
    FSystemPrompt: TCoreSystemPrompt;
    FSettings: TCoreSettings;
    FSampling: TCoreSampling;
    FStructuredOutput: TCoreStructuredOutput;
    FVendorSettings: TCoreVendorSettings;
  public
    property SystemPrompt: TCoreSystemPrompt read FSystemPrompt write FSystemPrompt;
    property Settings: TCoreSettings read FSettings write FSettings;
    property Sampling: TCoreSampling read FSampling write FSampling;
    property StructuredOutput: TCoreStructuredOutput read FStructuredOutput write FStructuredOutput;
    property VendorSettings: TCoreVendorSettings read FVendorSettings write FVendorSettings;

    destructor Destroy; override;
  end;

  {--- Classes pour la désérialisation JSON renvoyé par la gestion des modèles  }

  TModelCategoryItem = class
  private
    FId: string;
    FLabel: string;
    FFeatureLabels: TArray<string>;
    FModel: string;
    [JsonNameAttribute('visible')]
    FEnabled: Boolean;
  public
    property Id: string read FId write FId;
    property &Label: string read FLabel write FLabel;
    property FeatureLabels: TArray<string> read FFeatureLabels write FFeatureLabels;
    property Model: string read FModel write FModel;
    property Enabled: Boolean read FEnabled write FEnabled;
  end;

  TModels = class
  private
    FCategories: TArray<TModelCategoryItem>;
  public
    property Categories: TArray<TModelCategoryItem> read FCategories write FCategories;

    destructor Destroy; override;
  end;


  {--- Classes pour la désérialisation JSON renvoyé par la bulle de saisie  }

  TListItems = class
  private
    FId: string;
    FName: string;
  public
    property Id: string read FId write FId;
    property Name: string read FName write FName;
  end;

  TMediaItem = class
  private
    FName: string;
    FFullPath: string;
    FFileId: string;
  public
    property Name: string read FName write FName;
    property FullPath: string read FFullPath write FFullPath;
    property FileId: string read FFileId write FFileId;
  end;

  TProjectState = class
  private
    FDisplayName: string;
    FFullPath: string;
  public
    property DisplayName: string read FDisplayName write FDisplayName;
    property FullPath: string read FFullPath write FFullPath;
  end;

  TIntegration = class
  private
    FFunction: TArray<TListItems>;
    FMcp: TArray<TListItems>;
    FJsSandbox: TArray<TListItems>;
    FSkills: TArray<TListItems>;
    FAgents: TArray<TListItems>;
  public
    property &Function: TArray<TListItems> read FFunction write FFunction;
    property Mcp: TArray<TListItems> read FMcp write FMcp;
    property JsSandbox: TArray<TListItems> read FJsSandbox write FJsSandbox;
    property Skills: TArray<TListItems> read FSkills write FSkills;
    property Agents: TArray<TListItems> read FAgents write FAgents;

    destructor Destroy; override;
  end;

  TMedia = class
  private
    FCreateImage: Boolean;
    FCreateVideo: Boolean;
    FCreateAudio: Boolean;
    FSpeechToText: TArray<TMediaItem>;
    FTextToSpeech: Boolean;
  public
    property CreateImage: Boolean read FCreateImage write FCreateImage;
    property CreateVideo: Boolean read FCreateVideo write FCreateVideo;
    property CreateAudio: Boolean read FCreateAudio write FCreateAudio;
    property SpeechToText: TArray<TMediaItem> read FSpeechToText write FSpeechToText;
    property TextToSpeech: Boolean read FTextToSpeech write FTextToSpeech;

    destructor Destroy; override;
  end;

  TInputPromptState = class
  private
    FText: string;
    FEndpoint: string;
    FThinking: string;
    FDeepResearch: Boolean;
    FWebSearch: Boolean;
    FProject: TProjectState;
    FFiles: TArray<TMediaItem>;
    FImages: TArray<TMediaItem>;
    FKnowledgeSearch: TArray<TMediaItem>;
    FIntegration: TIntegration;
    FCustom: TArray<TListItems>;
    FMedia: TMedia;
    FRequestParams: TCoreParamsState;
    FModels: TModels;
    FSource: string;
    FJsonRequest: string;
    FJsonResponse: string;
    FError: Boolean;
    FErrorMessage: string;
  public
    property Text: string read FText write FText;
    property Endpoint: string read FEndpoint write FEndpoint;
    property Thinking: string read FThinking write FThinking;
    property DeepResearch: Boolean read FDeepResearch write FDeepResearch;
    property WebSearch: Boolean read FWebSearch write FWebSearch;
    property Project: TProjectState read FProject write FProject;
    property Files: TArray<TMediaItem> read FFiles write FFiles;
    property Images: TArray<TMediaItem> read FImages write FImages;
    property KnowledgeSearch: TArray<TMediaItem> read FKnowledgeSearch write FKnowledgeSearch;
    property Integration: TIntegration read FIntegration write FIntegration;
    property Custom: TArray<TListItems> read FCustom write FCustom;
    property Media: TMedia read FMedia write FMedia;
    property RequestParams: TCoreParamsState read FRequestParams write FRequestParams;
    property Models: TModels read FModels write FModels;
    property Source: string read FSource write FSource;
    property JsonRequest: string read FJsonRequest write FJsonRequest;
    property JsonResponse: string read FJsonResponse write FJsonResponse;

    property Error: Boolean read FError write FError;
    property ErrorMessage: string read FErrorMessage write FErrorMessage;

    function ToImageSources(const Value: TArray<TMediaItem>): TArray<string>;
    function ToFilePaths(const Value: TArray<TMediaItem>): TArray<string>;

    destructor Destroy; override;
  end;

  TManagedItemLLMResult = class
  private
    FModel: string;
    FPromptJson: string;
    FResponse: string;
    FReasoning: string;
    FResponseJson: string;
    FFiles: TArray<string>;
    FImages: TArray<string>;
    FAudios: TArray<string>;
    FVideos: TArray<string>;
    FDisplayBlocks: TArray<TChatDisplayBlock>;
    FError: Boolean;
    FErrorMessage: string;
  private
    class function Normalize(const AValues: TArray<string>): TArray<string>; static;
    procedure SetDisplayBlocks(const Value: TArray<TChatDisplayBlock>);
    procedure SetModel(const Value: string);
  public
    class function New: TManagedItemLLMResult; static;

    function UsedModel(const AValue: string): TManagedItemLLMResult;
    function Response(const AValue: string): TManagedItemLLMResult;
    function PromptJson(const AValue: string): TManagedItemLLMResult;
    function Reasoning(const AValue: string): TManagedItemLLMResult;
    function ResponseJson(const AValue: string): TManagedItemLLMResult;
    function Error(const AValue: Boolean): TManagedItemLLMResult;
    function ErrorMessage(const AValue: string): TManagedItemLLMResult;

    function FileResults(const AValues: TArray<string>): TManagedItemLLMResult;
    function ImageResults(const AValues: TArray<string>): TManagedItemLLMResult;
    function AudioResults(const AValues: TArray<string>): TManagedItemLLMResult;
    function VideoResults(const AValues: TArray<string>): TManagedItemLLMResult;
    function DisplayBlockResults(
      const AValues: TArray<TChatDisplayBlock>): TManagedItemLLMResult;

    function IsEmpty: Boolean;
    procedure Clear;

    property Model: string read FModel write SetModel;
    property JsonPrompt: string read FPromptJson;
    property TextReasoning: string read FReasoning;
    property TextResponse: string read FResponse;
    property JsonResponse: string read FResponseJson;
    property FileList: TArray<string> read FFiles;
    property ImageList: TArray<string> read FImages;
    property AudioList: TArray<string> read FAudios;
    property VideoList: TArray<string> read FVideos;
    property DisplayBlocks: TArray<TChatDisplayBlock>
      read FDisplayBlocks write SetDisplayBlocks;

    function HasError: Boolean;
    function AcquireError: string;
    destructor Destroy; override;
  end;

  TManagedItemFinalizeProc = reference to procedure(
    const AResult: TManagedItemLLMResult);

implementation

uses
  WVPythia.Net.MediaCodec;

{ TManagedItemLLMResult }

destructor TManagedItemLLMResult.Destroy;
begin
  Clear;
  inherited;
end;

procedure TManagedItemLLMResult.Clear;
begin
  FResponse := '';
  FResponseJson := '';
  FFiles := nil;
  FImages := nil;
  FAudios := nil;
  FVideos := nil;
  FreeChatDisplayBlocks(FDisplayBlocks);
end;

function TManagedItemLLMResult.DisplayBlockResults(
  const AValues: TArray<TChatDisplayBlock>): TManagedItemLLMResult;
begin
  SetDisplayBlocks(AValues);
  Result := Self;
end;

function TManagedItemLLMResult.Error(
  const AValue: Boolean): TManagedItemLLMResult;
begin
  FError := AValue;
  Result := Self;
end;

function TManagedItemLLMResult.ErrorMessage(
  const AValue: string): TManagedItemLLMResult;
begin
  FErrorMessage := AValue.Trim;
  Result := Self;
end;

function TManagedItemLLMResult.Reasoning(
  const AValue: string): TManagedItemLLMResult;
begin
  FReasoning := AValue.Trim;
  Result := Self;
end;

function TManagedItemLLMResult.Response(
  const AValue: string): TManagedItemLLMResult;
begin
  FResponse := AValue.Trim;
  Result := Self;
end;

function TManagedItemLLMResult.ResponseJson(
  const AValue: string): TManagedItemLLMResult;
begin
  FResponseJson := AValue.Trim;
  Result := Self;
end;

function TManagedItemLLMResult.FileResults(
  const AValues: TArray<string>): TManagedItemLLMResult;
begin
  FFiles := Normalize(AValues);
  Result := Self;
end;

function TManagedItemLLMResult.HasError: Boolean;
begin
  Result := FError;
end;

function TManagedItemLLMResult.ImageResults(
  const AValues: TArray<string>): TManagedItemLLMResult;
begin
  FImages := Normalize(AValues);
  Result := Self;
end;

function TManagedItemLLMResult.AcquireError: string;
begin
  Result := FErrorMessage;
end;

function TManagedItemLLMResult.AudioResults(
  const AValues: TArray<string>): TManagedItemLLMResult;
begin
  FAudios := Normalize(AValues);
  Result := Self;
end;

function TManagedItemLLMResult.VideoResults(
  const AValues: TArray<string>): TManagedItemLLMResult;
begin
  FVideos := Normalize(AValues);
  Result := Self;
end;

function TManagedItemLLMResult.IsEmpty: Boolean;
begin
  Result :=
    FResponse.IsEmpty and
    FResponseJson.IsEmpty and
    (Length(FFiles) = 0) and
    (Length(FImages) = 0) and
    (Length(FAudios) = 0) and
    (Length(FVideos) = 0) and
    (Length(FDisplayBlocks) = 0);
end;

procedure TManagedItemLLMResult.SetDisplayBlocks(
  const Value: TArray<TChatDisplayBlock>);
begin
  FreeChatDisplayBlocks(FDisplayBlocks);
  FDisplayBlocks := CloneChatDisplayBlocks(Value);
end;

procedure TManagedItemLLMResult.SetModel(
  const Value: string);
begin
  FModel := Value.Trim;
end;

function TManagedItemLLMResult.UsedModel(
  const AValue: string): TManagedItemLLMResult;
begin
  FModel := AValue.Trim;
  Result := Self;
end;

class function TManagedItemLLMResult.New: TManagedItemLLMResult;
begin
  Result := TManagedItemLLMResult.Create;
end;

class function TManagedItemLLMResult.Normalize(
  const AValues: TArray<string>): TArray<string>;
begin
  SetLength(Result, 0);
  var Count := 0;

  for var I := 0 to High(AValues) do
    begin
      var S := AValues[I].Trim;
      if S.IsEmpty then
        Continue;

      SetLength(Result, Count + 1);
      Result[Count] := S;
      Inc(Count);
    end;
end;

function TManagedItemLLMResult.PromptJson(
  const AValue: string): TManagedItemLLMResult;
begin
  FPromptJson := AValue.Trim;
  Result := Self;
end;

{ TInputPromptState }

destructor TInputPromptState.Destroy;
begin
  for var Item in FFiles do
    Item.Free;
  for var Item in FImages do
    Item.Free;
  for var Item in FKnowledgeSearch do
    Item.Free;
  if Assigned(FProject) then
    FProject.Free;
  if Assigned(FIntegration) then
    FIntegration.Free;
  for var Item in FCustom do
    Item.Free;
  if Assigned(FMedia) then
    FMedia.Free;
  if Assigned(FRequestParams) then
    FRequestParams.Free;
  if Assigned(FModels) then
    FModels.Free;
  inherited;
end;

function TInputPromptState.ToFilePaths(
  const Value: TArray<TMediaItem>): TArray<string>;
begin
  SetLength(Result, Length(Value));
  for var I := Low(Value) to High(Value) do
    Result[i] := Value[i].FullPath;
end;

function TInputPromptState.ToImageSources(
  const Value: TArray<TMediaItem>): TArray<string>;
begin
  SetLength(Result, Length(Value));
  for var I := Low(Value) to High(Value) do
    if Value[I].FullPath.IsEmpty then
      Result[I] := ''
    else if not Value[I].FullPath.ToLower.StartsWith('https://app.local') then
      Result[I] := TMediaCodec.ToDataURI(Value[I].FullPath)
    else
      Result[I] := Value[I].FullPath;
end;

{ TIntegration }

destructor TIntegration.Destroy;
begin
  for var Item in FFunction do
    Item.Free;
  for var Item in FMcp do
    Item.Free;
  for var Item in FJsSandbox do
    Item.Free;
  for var Item in FSkills do
    Item.Free;
  for var Item in FAgents do
    Item.Free;
  inherited;
end;

{ TMedia }

destructor TMedia.Destroy;
begin
  for var Item in FSpeechToText do
    Item.Free;
  inherited;
end;

{ TCoreParamsState }

destructor TCoreParamsState.Destroy;
begin
  if Assigned(FSystemPrompt) then
    FSystemPrompt.Free;
  if Assigned(FSettings) then
    FSettings.Free;
  if Assigned(FSampling) then
    FSampling.Free;
  if Assigned(FStructuredOutput) then
    FStructuredOutput.Free;
  if Assigned(FVendorSettings) then
    FVendorSettings.Free;
  inherited;
end;

{ TCoreSettings }

destructor TCoreSettings.Destroy;
begin
  if Assigned(FMaxToken) then
    FMaxToken.Free;
  if Assigned(FStopString) then
    FStopString.Free;
  inherited;
end;

{ TCoreSampling }

destructor TCoreSampling.Destroy;
begin
  if Assigned(FTopK) then
    FTopK.Free;
  if Assigned(FPresencePenalty) then
    FPresencePenalty.Free;
  if Assigned(FTopP) then
    FTopP.Free;
  if Assigned(FSeed) then
    FSeed.Free;
  inherited;
end;

{ TModels }

destructor TModels.Destroy;
begin
  for var Item in FCategories do
    Item.Free;
  inherited;
end;

end.
