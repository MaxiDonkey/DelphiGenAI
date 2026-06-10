unit WVPythia.Capabilities.Manager;

interface

uses
  System.SysUtils, System.JSON, WVPythia.JSON.SafeReader;

type
  TFunctionsType = (
    fEndpoint,
    fEndpointChatCompletion,
    fEndpointChatResponse,
    fEndpointMessage,
    fEndpointGenerateContent,
    fEndpointInteractions,
    fEndpointConversation,
    fWebSearch,
    fThinking,
    fFiles,
    fVision,
    fDeepResearch,
    fKnowledgeSearch,
    fIntegration,
    fIntegrationFunction,
    fIntegrationMcp,
    fIntegrationSkills,
    fIntegrationAgents,
    fThinkingLow,
    fThinkingMedium,
    fThinkingHigh,
    fMedia,
    fMediaCreateImage,
    fMediaCreateVideo,
    fMediaCreateAudio,
    fMediaSpeechToText,
    fMediaTextToSpeech,
    fCustom,
    fSystemPrompt,
    fModel,
    fProject
  );

  ICapabilities = interface
    ['{57A7EC32-C878-4AF8-80D4-61B4509A47EB}']
    function Endpoint(const Value: Boolean): ICapabilities;
    function EndpointChatCompletion(const Value: Boolean): ICapabilities;
    function EndpointChatResponse(const Value: Boolean): ICapabilities;
    function EndpointMessage(const Value: Boolean): ICapabilities;
    function EndpointGenerateContent(const Value: Boolean): ICapabilities;
    function EndpointInteractions(const Value: Boolean): ICapabilities;
    function EndpointConversation(const Value: Boolean): ICapabilities;

    function WebSearch(const Value: Boolean): ICapabilities;
    function Thinking(const Value: Boolean): ICapabilities;
    function Files(const Value: Boolean): ICapabilities;
    function Vision(const Value: Boolean): ICapabilities;
    function DeepResearch(const Value: Boolean): ICapabilities;
    function KnowledgeSearch(const Value: Boolean): ICapabilities;
    function Integration(const Value: Boolean): ICapabilities;

    function IntegrationFunction(const Value: Boolean): ICapabilities;
    function IntegrationMcp(const Value: Boolean): ICapabilities;
    function IntegrationSkills(const Value: Boolean): ICapabilities;
    function IntegrationAgents(const Value: Boolean): ICapabilities;

    function Media(const Value: Boolean): ICapabilities;
    function MediaCreateImage(const Value: Boolean): ICapabilities;
    function MediaCreateVideo(const Value: Boolean): ICapabilities;
    function MediaCreateAudio(const Value: Boolean): ICapabilities;
    function MediaSpeechToText(const Value: Boolean): ICapabilities;
    function MediaTextToSpeech(const Value: Boolean): ICapabilities;

    function ThinkingLow(const Value: Boolean): ICapabilities;
    function ThinkingMedium(const Value: Boolean): ICapabilities;
    function ThinkingHigh(const Value: Boolean): ICapabilities;

    function Custom(const Value: Boolean): ICapabilities;

    function SystemPrompt(const Value: Boolean): ICapabilities;
    function Model(const Value: Boolean): ICapabilities;
    function Project(const Value: Boolean): ICapabilities;

    procedure Reset;
    function ToJSON: string;
    function Value(const Kind: TFunctionsType): string;
    function Update: ICapabilities;
  end;

  TCapabilities = class(TInterfacedObject, ICapabilities)
  private
    FFilename: string;
    FValues: array[TFunctionsType] of Boolean;
    FUpdateFunc: TFunc<Boolean>;
    procedure Initialize;
    procedure SetUpdateProc(const Value: TFunc<Boolean>);
    procedure SetFilename(const Value: string);
  protected
    procedure LoadFromFile(const Filename: string);
  public
    function Endpoint(const Value: Boolean): ICapabilities;
    function EndpointChatCompletion(const Value: Boolean): ICapabilities;
    function EndpointChatResponse(const Value: Boolean): ICapabilities;
    function EndpointMessage(const Value: Boolean): ICapabilities;
    function EndpointGenerateContent(const Value: Boolean): ICapabilities;
    function EndpointInteractions(const Value: Boolean): ICapabilities;
    function EndpointConversation(const Value: Boolean): ICapabilities;

    function WebSearch(const Value: Boolean): ICapabilities;
    function Thinking(const Value: Boolean): ICapabilities;
    function Files(const Value: Boolean): ICapabilities;
    function Vision(const Value: Boolean): ICapabilities;
    function DeepResearch(const Value: Boolean): ICapabilities;
    function KnowledgeSearch(const Value: Boolean): ICapabilities;
    function Integration(const Value: Boolean): ICapabilities;

    function IntegrationFunction(const Value: Boolean): ICapabilities;
    function IntegrationMcp(const Value: Boolean): ICapabilities;
    function IntegrationSkills(const Value: Boolean): ICapabilities;
    function IntegrationAgents(const Value: Boolean): ICapabilities;

    function Media(const Value: Boolean): ICapabilities;
    function MediaCreateImage(const Value: Boolean): ICapabilities;
    function MediaCreateVideo(const Value: Boolean): ICapabilities;
    function MediaCreateAudio(const Value: Boolean): ICapabilities;
    function MediaSpeechToText(const Value: Boolean): ICapabilities;
    function MediaTextToSpeech(const Value: Boolean): ICapabilities;

    function ThinkingLow(const Value: Boolean): ICapabilities;
    function ThinkingMedium(const Value: Boolean): ICapabilities;
    function ThinkingHigh(const Value: Boolean): ICapabilities;

    function Custom(const Value: Boolean): ICapabilities;

    function SystemPrompt(const Value: Boolean): ICapabilities;
    function Model(const Value: Boolean): ICapabilities;
    function Project(const Value: Boolean): ICapabilities;

    function ToJSON: string;
    function Value(const Kind: TFunctionsType): string;
    function Update: ICapabilities;
    procedure Reset;

    constructor Create(
      const FileName: string;
      const ParamFunc: TFunc<boolean>);

    class function CreateInstance(
      const FileName: string;
      const ParamFunc: TFunc<boolean>): ICapabilities;
  end;

implementation

uses
  WVPythia.TextFile.Helper;

const
  CAPABILITIES_PATTERN =
    '{' +
      '"type":"setCapabilities",' +
      '"endpoint":%s,' +
      '"endpointChatCompletion":%s,' +
      '"endpointChatResponse":%s,' +
      '"endpointMessage":%s,' +
      '"endpointGenerateContent":%s,' +
      '"endpointInteractions":%s,' +
      '"endpointConversation":%s,' +

      '"webSearch":%s,' +
      '"thinking":%s,' +
      '"files":%s,' +
      '"knowledgeSearch":%s,' +
      '"vision":%s,' +
      '"deepResearch":%s,' +
      '"integration":%s,' +

      '"integrationFunction":%s,' +
      '"integrationMcp":%s,' +
      '"integrationSkills":%s,' +
      '"integrationAgents":%s,' +

      '"thinkingLow":%s,' +
      '"thinkingMedium":%s,' +
      '"thinkingHigh":%s,' +

      '"media":%s,' +
      '"mediaCreateImage":%s,' +
      '"mediaCreateVideo":%s,' +
      '"mediaCreateAudio":%s,' +
      '"mediaSpeechToText":%s,' +
      '"mediaTextToSpeech":%s,' +

      '"custom":%s,' +

      '"systemPrompt":%s,' +
      '"model":%s,' +
      '"project":%s' +
    '}';

{ TCapabilities }

constructor TCapabilities.Create(const FileName: string;
  const ParamFunc: TFunc<boolean>);
begin
  inherited Create;
  SetUpdateProc(ParamFunc);
  Initialize;
  SetFilename(FileName);
end;

class function TCapabilities.CreateInstance(const FileName: string;
  const ParamFunc: TFunc<boolean>): ICapabilities;
begin
  if not Assigned(ParamFunc) then
    raise Exception.Create('Update method needed');

  Result := TCapabilities.Create(Filename, ParamFunc);
end;

function TCapabilities.Custom(const Value: Boolean): ICapabilities;
begin
  FValues[fCustom] := Value;
  Result := Self;
end;

function TCapabilities.DeepResearch(const Value: Boolean): ICapabilities;
begin
  FValues[fDeepResearch] := Value;
  Result := Self;
end;

function TCapabilities.Endpoint(const Value: Boolean): ICapabilities;
begin
  FValues[fEndpoint] := Value;
  Result := Self;
end;

function TCapabilities.EndpointChatCompletion(
  const Value: Boolean): ICapabilities;
begin
  FValues[fEndpointChatCompletion] := Value;
  Result := Self;
end;

function TCapabilities.EndpointChatResponse(
  const Value: Boolean): ICapabilities;
begin
  FValues[fEndpointChatResponse] := Value;
  Result := Self;
end;

function TCapabilities.EndpointConversation(
  const Value: Boolean): ICapabilities;
begin
  FValues[fEndpointConversation] := Value;
  Result := Self;
end;

function TCapabilities.EndpointGenerateContent(
  const Value: Boolean): ICapabilities;
begin
  FValues[fEndpointGenerateContent] := Value;
  Result := Self;
end;

function TCapabilities.EndpointInteractions(
  const Value: Boolean): ICapabilities;
begin
  FValues[fEndpointInteractions] := Value;
  Result := Self;
end;

function TCapabilities.EndpointMessage(const Value: Boolean): ICapabilities;
begin
  FValues[fEndpointMessage] := Value;
  Result := Self;
end;

function TCapabilities.Files(const Value: Boolean): ICapabilities;
begin
  FValues[fFiles] := Value;
  Result := Self;
end;

function TCapabilities.IntegrationFunction(const Value: Boolean): ICapabilities;
begin
  FValues[fIntegrationFunction] := Value;
  Result := Self;
end;

procedure TCapabilities.Initialize;
begin
  FValues[fEndpoint] := True;
  FValues[fEndpointChatCompletion] := True;
  FValues[fEndpointChatResponse] := True;
  FValues[fEndpointMessage] := True;
  FValues[fEndpointGenerateContent] := True;
  FValues[fEndpointInteractions] := True;
  FValues[fEndpointConversation] := True;

  FValues[fWebSearch] := True;
  FValues[fThinking] := True;
  FValues[fFiles] := True;
  FValues[fVision] := True;
  FValues[fDeepResearch] := True;
  FValues[fKnowledgeSearch] := True;
  FValues[fIntegration] := True;

  FValues[fIntegrationFunction] := True;
  FValues[fIntegrationMcp] := True;
  FValues[fIntegrationSkills] := True;
  FValues[fIntegrationAgents] := True;

  FValues[fThinkingLow] := True;
  FValues[fThinkingMedium] := True;
  FValues[fThinkingHigh] := True;

  FValues[fMedia] := True;
  FValues[fMediaCreateImage] := True;
  FValues[fMediaCreateVideo] := True;
  FValues[fMediaCreateAudio] := True;
  FValues[fMediaSpeechToText] := True;
  FValues[fMediaTextToSpeech] := True;

  FValues[fCustom] := True;

  FValues[fSystemPrompt] := True;
  FValues[fModel] := True;
  FValues[fProject] := True;
end;

function TCapabilities.Integration(const Value: Boolean): ICapabilities;
begin
  FValues[fIntegration] := Value;
  Result := Self;
end;

function TCapabilities.IntegrationAgents(const Value: Boolean): ICapabilities;
begin
  FValues[fIntegrationAgents] := Value;
  Result := Self;
end;

function TCapabilities.IntegrationMcp(const Value: Boolean): ICapabilities;
begin
  FValues[fIntegrationMcp] := Value;
  Result := Self;
end;

function TCapabilities.IntegrationSkills(const Value: Boolean): ICapabilities;
begin
  FValues[fIntegrationSkills] := Value;
  Result := Self;
end;

function TCapabilities.KnowledgeSearch(const Value: Boolean): ICapabilities;
begin
  FValues[fKnowledgeSearch] := Value;
  Result := Self;
end;

procedure TCapabilities.LoadFromFile(const Filename: string);
begin
  if not FileExists(Filename) then
    Exit;

  var Content := TFileIOHelper.LoadFromFile(Filename);
  var Reader := TJsonReader.Parse(Content);

  if not Reader.IsValid then
    Exit;

  Endpoint(Reader.AsBoolean('endpoint'));
  Endpoint(Reader.AsBoolean('endpoint'));
  EndpointChatCompletion(Reader.AsBoolean('endpointChatCompletion'));
  EndpointChatResponse(Reader.AsBoolean('endpointChatResponse'));
  EndpointMessage(Reader.AsBoolean('endpointMessage'));
  EndpointGenerateContent(Reader.AsBoolean('endpointGenerateContent'));
  EndpointInteractions(Reader.AsBoolean('endpointInteractions'));
  EndpointConversation(Reader.AsBoolean('endpointConversation'));

  WebSearch(Reader.AsBoolean('webSearch'));
  Thinking(Reader.AsBoolean('thinking'));
  Files(Reader.AsBoolean('files'));
  KnowledgeSearch(Reader.AsBoolean('knowledgeSearch'));
  Vision(Reader.AsBoolean('vision'));
  DeepResearch(Reader.AsBoolean('deepResearch'));

  Integration(Reader.AsBoolean('integration'));
  IntegrationFunction(Reader.AsBoolean('integrationFunction'));
  IntegrationMcp(Reader.AsBoolean('integrationMcp'));
  IntegrationSkills(Reader.AsBoolean('integrationSkills'));
  IntegrationAgents(Reader.AsBoolean('integrationAgents'));

  ThinkingLow(Reader.AsBoolean('thinkingLow'));
  ThinkingMedium(Reader.AsBoolean('thinkingMedium'));
  ThinkingHigh(Reader.AsBoolean('thinkingHigh'));

  Media(Reader.AsBoolean('media'));
  MediaCreateImage(Reader.AsBoolean('mediaCreateImage'));
  MediaCreateVideo(Reader.AsBoolean('mediaCreateVideo'));
  MediaCreateAudio(Reader.AsBoolean('mediaCreateAudio'));
  MediaSpeechToText(Reader.AsBoolean('mediaSpeechToText'));
  MediaTextToSpeech(Reader.AsBoolean('mediaTextToSpeech'));

  Custom(Reader.AsBoolean('custom'));
  SystemPrompt(Reader.AsBoolean('systemPrompt'));
  Model(Reader.AsBoolean('model'));
  Project(Reader.AsBoolean('project', True));
end;

function TCapabilities.Media(const Value: Boolean): ICapabilities;
begin
  FValues[fMedia] := Value;
  Result := Self;
end;

function TCapabilities.MediaCreateAudio(const Value: Boolean): ICapabilities;
begin
  FValues[fMediaCreateAudio] := Value;
  Result := Self;
end;

function TCapabilities.MediaCreateImage(const Value: Boolean): ICapabilities;
begin
  FValues[fMediaCreateImage] := Value;
  Result := Self;
end;

function TCapabilities.MediaCreateVideo(const Value: Boolean): ICapabilities;
begin
  FValues[fMediaCreateVideo] := Value;
  Result := Self;
end;

function TCapabilities.MediaSpeechToText(const Value: Boolean): ICapabilities;
begin
  FValues[fMediaSpeechToText] := Value;
  Result := Self;
end;

function TCapabilities.MediaTextToSpeech(const Value: Boolean): ICapabilities;
begin
  FValues[fMediaTextToSpeech] := Value;
  Result := Self;
end;

function TCapabilities.Model(const Value: Boolean): ICapabilities;
begin
  FValues[fModel] := Value;
  Result := Self;
end;

function TCapabilities.Project(const Value: Boolean): ICapabilities;
begin
  FValues[fProject] := Value;
  Result := Self;
end;

procedure TCapabilities.Reset;
begin
  Initialize;
end;

procedure TCapabilities.SetFilename(const Value: string);
begin
  FFilename := Value.Trim;

  if not FFilename.IsEmpty then
    LoadFromFile(FFilename);
end;

procedure TCapabilities.SetUpdateProc(const Value: TFunc<Boolean>);
begin
  FUpdateFunc := Value;
end;

function TCapabilities.SystemPrompt(const Value: Boolean): ICapabilities;
begin
  FValues[fSystemPrompt] := Value;
  Result := Self;
end;

function TCapabilities.Thinking(const Value: Boolean): ICapabilities;
begin
  FValues[fThinking] := Value;
  Result := Self;
end;

function TCapabilities.ThinkingHigh(const Value: Boolean): ICapabilities;
begin
  FValues[fThinkingHigh] := Value;
  Result := Self;
end;

function TCapabilities.ThinkingLow(const Value: Boolean): ICapabilities;
begin
  FValues[fThinkingLow] := Value;
  Result := Self;
end;

function TCapabilities.ThinkingMedium(const Value: Boolean): ICapabilities;
begin
  FValues[fThinkingMedium] := Value;
  Result := Self;
end;

function TCapabilities.ToJSON: string;
begin
  Result :=
    Format(
      CAPABILITIES_PATTERN,
      [
        Value(fEndpoint),
        Value(fEndpointChatCompletion),
        Value(fEndpointChatResponse),
        Value(fEndpointMessage),
        Value(fEndpointGenerateContent),
        Value(fEndpointInteractions),
        Value(fEndpointConversation),

        Value(fWebSearch),
        Value(fThinking),
        Value(fFiles),
        Value(fKnowledgeSearch),
        Value(fVision),
        Value(fDeepResearch),
        Value(fIntegration),

        Value(fIntegrationFunction),
        Value(fIntegrationMcp),
        Value(fIntegrationSkills),
        Value(fIntegrationAgents),

        Value(fThinkingLow),
        Value(fThinkingMedium),
        Value(fThinkingHigh),

        Value(fMedia),
        Value(fMediaCreateImage),
        Value(fMediaCreateVideo),
        Value(fMediaCreateAudio),
        Value(fMediaSpeechToText),
        Value(fMediaTextToSpeech),

        Value(fCustom),

        Value(fSystemPrompt),
        Value(fModel),
        Value(fProject)
      ]
    );
end;

function TCapabilities.Update: ICapabilities;
begin
  if Assigned(FUpdateFunc) then
    FUpdateFunc();
  Result := Self;
end;

function TCapabilities.Value(const Kind: TFunctionsType): string;
begin
  if FValues[Kind] then
    Exit('true');

  Result := 'false';
end;

function TCapabilities.Vision(const Value: Boolean): ICapabilities;
begin
  FValues[fVision] := Value;
  Result := Self;
end;

function TCapabilities.WebSearch(const Value: Boolean): ICapabilities;
begin
  FValues[fWebSearch] := Value;
  Result := Self;
end;

end.
