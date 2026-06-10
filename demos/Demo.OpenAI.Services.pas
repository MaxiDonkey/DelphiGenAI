unit Demo.OpenAI.Services;

interface

uses
  WVPythia.Chat.Interfaces, WVPythia.Chat.ManagedFlow,
  WVPythia.Vendors.Services, WVPythia.Types,
  GenAI,
  Demo.OpenAI.Context, Demo.OpenAI.AsyncUtils;

const
  OPENAI_RESPONSE_TIMEOUT = 30 * 60 * 1000;

type
  TOpenAIServices = class(TInterfacedObject, IVendorServices)
  const
    API_KEY_NAME = 'openai';
  private
    FClient: IGenAI;
    FBrowser: IPythiaBrowser;
    FContext: IContext;
    FClientUtils: IOpenAIClientUtils;

    procedure ChatSessionRename(ID, Value: string);

    procedure AfterSessionReloaded(ChatId: string);

    procedure SkillCustomRegister;

  public
    constructor Create(const ABrowser: IPythiaBrowser; const AContext: IContext);

    /// <summary>
    /// Refreshes the OpenAI API key used by the demo service.
    /// </summary>
    procedure UpdateApiKey;

    /// <summary>
    /// Starts the asynchronous OpenAI chat stream for the current Pythia turn.
    /// </summary>
    procedure AsyncAwaitStreamChat(
      const AState: TInputPromptState;
      const AOnFinalize: TManagedItemFinalizeProc);
  end;

var
  OpenAIVendor: IVendorServices;

implementation

{$REGION 'Dev note'}
(*

  OpenAI vendor service bridge for the pythia-openai FMX demo.

  This unit is the IVendorServices implementation registered by the demo. It
  owns the OpenAI client, receives Pythia turns, and routes each turn to the
  OpenAI demo unit that owns the matching execution path.

  There are two conversation-history paths:
    - when UsingPreviousId is enabled, the service chains the request with
      previous_response_id and storage is enabled by the request settings;
    - otherwise Demo.OpenAI.Context rebuilds the local Responses input items
      from the persisted Pythia session. For stateless turns, encrypted
      reasoning content is requested so replay remains possible.

  The service stays intentionally small. Demo.OpenAI.TextTurn owns the
  Responses streaming path, including payload construction, callbacks, tool
  display blocks, container-file downloads and guarded finalization.
  Demo.OpenAI.TextTurn also consumes the card-driven OpenAI agent examples so
  they keep the same asynchronous Responses stream, tracing and finalization.
  Demo.OpenAI.ImageTurn owns image creation and image-edit turns.
  Demo.OpenAI.TTSTurn owns audio-creation turns used for text-to-speech.
  Demo.OpenAI.STTTurn owns speech-to-text turns for attached audio files.

*)
{$ENDREGION}

uses
  System.SysUtils,
  WVPythia.TextFile.Helper,
  Demo.OpenAI.Helpers, Demo.OpenAI.Upload, Demo.OpenAI.VectorFileStore,
  Demo.OpenAI.ImageTurn, Demo.OpenAI.STTTurn, Demo.OpenAI.TTSTurn,
  Demo.OpenAI.TextTurn;

type
  {--- Vendor implementation of the Pythia IAudioTranscriptionService contract.
       Pythia produces the microphone capture file (vendor-agnostic) and calls
       SubmitForTranscription; this service only performs the OpenAI
       speech-to-text step and reports the recognized text (or an error) back
       through the completion callback. The transcription promise resolves on
       the main thread, so the callback is delivered on the UI thread as
       required by the contract. }
  TOpenAITranscriptionService = class(TInterfacedObject, IAudioTranscriptionService)
  private
    FUtils: IOpenAIClientUtils;
  public
    constructor Create(const AUtils: IOpenAIClientUtils);
    procedure SubmitForTranscription(const AAudioFilePath: string;
      const AOnComplete: TAudioTranscriptionCompleteProc = nil);
  end;

{ TOpenAITranscriptionService }

constructor TOpenAITranscriptionService.Create(const AUtils: IOpenAIClientUtils);
begin
  inherited Create;
  FUtils := AUtils;
end;

procedure TOpenAITranscriptionService.SubmitForTranscription(
  const AAudioFilePath: string;
  const AOnComplete: TAudioTranscriptionCompleteProc);
begin
  var OnComplete := AOnComplete;

  try
    FUtils.AsyncTranscribe(AAudioFilePath)
      .&Then(
        procedure (Value: TTranscription)
        begin
          if Assigned(OnComplete) then
            OnComplete(TAudioTranscriptionResult.Ok(Value.Text));
        end)
      .&Catch(
        procedure (E: Exception)
        begin
          if Assigned(OnComplete) then
            OnComplete(TAudioTranscriptionResult.Fail(E.Message));
        end);
  except
    on E: Exception do
      if Assigned(OnComplete) then
        OnComplete(TAudioTranscriptionResult.Fail(E.Message));
  end;
end;

{ TOpenAIServices }

procedure TOpenAIServices.AfterSessionReloaded(ChatId: string);
begin
  {--- OpenAI agent examples are stateless for the first demo pass. }
end;

procedure TOpenAIServices.AsyncAwaitStreamChat(const AState: TInputPromptState;
  const AOnFinalize: TManagedItemFinalizeProc);
begin
  if not Assigned(AState) or not Assigned(AOnFinalize) then
    Exit;

  var State := TStateBuffer.FromState(AState);

  if State.Media.CreateImage then
    begin
      TOpenAIImageTurn.Execute(FClient, FBrowser, State, AOnFinalize);
      Exit;
    end;

  if Length(State.Media.SpeechToText) > 0 then
    begin
      TOpenAISTTTurn.Execute(FClient, FBrowser, State, AOnFinalize);
      Exit;
    end;

  if State.Media.TextToSpeech then
    begin
      TOpenAITTSTurn.Execute(FClient, FBrowser, State, AOnFinalize);
      Exit;
    end;

  TOpenAITextTurn.Execute(
    FClient,
    FBrowser,
    FContext,
    FClientUtils,
    State,
    AOnFinalize);
end;

procedure TOpenAIServices.ChatSessionRename(ID, Value: string);
begin
  FClientUtils.ASyncSessionRename(ID, Value);
end;

constructor TOpenAIServices.Create(const ABrowser: IPythiaBrowser;
  const AContext: IContext);
var
  OpenAI_key: string;
begin
  {--- The service is built around three collaborators: the browser-facing UI
       abstraction, the OpenAI SDK client used for remote execution, and an
       injected IContext that owns the conversation-history projection used to
       seed the messages array sent on each request.
  }
  FBrowser := ABrowser;
  FContext := AContext;

  {--- Require the user to enter an API key when none is configured. }
  if not FBrowser.ApiKeySecretStore.ReadSecret(API_KEY_NAME, OpenAI_key) then
      FBrowser.TryHandleAsCommand(Format('/api-key new %s', [API_KEY_NAME]));

  FClient := TGenAIFactory.CreateInstance(OpenAI_key);

  {---- Set response delay for 30 minutes. }
  FClient.HttpClient.ResponseTimeout := OPENAI_RESPONSE_TIMEOUT;

  {--- Set up OpenAI helper tasks: async renaming, downloads and skills. }
  FClientUtils := TOpenAIClientUtils.Create(FClient, FBrowser);

  {--- Register (or resolve) the user-defined OpenAI custom skills declared in
       the local skill-cards file, so they exist server-side and can be
       referenced by the Responses flow. }
  SkillCustomRegister;

  {--- Set up the automatic session renaming feature. }
  FBrowser.OnChatSessionAutoRename := ChatSessionRename;

  {--- Agent examples currently do not restore provider-side session state. }
  FBrowser.OnAfterSessionReloaded := AfterSessionReloaded;

  {--- File upload service: transfers files attached in the compose box to the
       OpenAI Files API asynchronously and exposes their file_id, so the chat
       payload can reference them instead of inlining the raw content. }
  FBrowser.FileUploadService :=
    TDownloadService.Create(FBrowser as IPythiaBrowser, FClient);

  {--- Knowledge indexing service: runs the multi-stage pipeline (upload ->
       ingest -> embed -> ready) that vectorizes knowledge files into a vector
       store, referenced at submit time for retrieval (file_search). }
  FBrowser.KnowledgeIndexingService :=
    TOpenAIKnowledgeIndexingService.Create(FBrowser as IPythiaBrowser, FClient);

  {--- Enables the microphone button: Pythia toggles the browser-side recorder
       and routes the captured audio file here for OpenAI transcription, then
       injects the recognized text into the input bubble. }
  FBrowser.AudioTranscriptionService :=
    TOpenAITranscriptionService.Create(FClientUtils);

  {--- Reveal the microphone button in the input bubble only when a
       transcription service is actually wired, so audio capture is offered to
       the user only when it can be processed end to end. }
  if Assigned(FBrowser.AudioTranscriptionService) then
    FBrowser.EnabledButtons := FBrowser.EnabledButtons + [ebMicrophone];
end;

procedure TOpenAIServices.SkillCustomRegister;
begin
  var SkillCardsFileName := FBrowser.GetSkillCardsFileName;
  if not FileExists(SkillCardsFileName) then
    Exit;

  var SkillJsonAsString := TFileIOHelper.LoadFromFile(SkillCardsFileName);
  var Skills := TSkillHelper.ExtractCustomSkills(SkillJsonAsString);

  for var Item in Skills do
    FClientUtils.CustomSkillRegister(Item.ID, Item.Name);
end;

procedure TOpenAIServices.UpdateApiKey;
var
  OpenAI_key: string;
begin
  if not FBrowser.ApiKeySecretStore.ReadSecret(API_KEY_NAME, OpenAI_key) then
    begin
      FClient.APIKey := '';
      Exit;
    end;

  FClient.APIKey := OpenAI_key;
  FBrowser.DisplaySuccess('OpenAI client is up to date.');
end;

end.
