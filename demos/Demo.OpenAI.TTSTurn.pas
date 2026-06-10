unit Demo.OpenAI.TTSTurn;

interface

uses
  WVPythia.Chat.Interfaces, WVPythia.Chat.ManagedFlow,
  WVPythia.Vendors.Services,
  GenAI;

type
  TOpenAITTSTurn = record
  public
    /// <summary>
    /// Executes one Pythia text-to-speech turn with the OpenAI speech API.
    /// </summary>
    class procedure Execute(
      const AClient: IGenAI;
      const ABrowser: IPythiaBrowser;
      AState: TStateBuffer;
      const AOnFinalize: TManagedItemFinalizeProc); static;
  end;

implementation

{$REGION 'Dev note'}
(*

  OpenAI text-to-speech turn for the pythia-openai FMX demo.

  This unit owns the audio-creation branch used by the demo for
  media.textToSpeech. It mirrors the non-streamed shape of
  Demo.OpenAI.ImageTurn: build one SDK request, emit one progress block, save
  the generated media into Pythia's media folder, and finalize the turn once
  the promise succeeds or fails.

  The request is intentionally built through the SDK parameter object shown in
  guides/Audio.md. The demo therefore stays close to the public SDK pattern:
    Client.Audio.AsyncAwaitSpeech(
      procedure(Params: TSpeechParams)
      begin
        Params.Model(...);
        Params.Input(...);
        Params.Voice(...);
        Params.ResponseFormat(...);
      end);

  Pythia supplies the selected speech model through TEXT_TO_SPEECH_INDEX. The
  turn still creates an audio artifact, but the model selector category remains
  "Text to speech" so the UI can expose it clearly to the user. The first demo
  pass keeps the other speech options fixed and mp3 output. It uses "verse"
  for the current gpt-4o speech models, and falls back to "fable" for the
  legacy tts-1 / tts-1-hd models because those models reject "verse".
  Custom cards can later be mapped by extending TOpenAITTSOptions without
  changing the service router.

  Generated audio is saved to ABrowser.GetMediaFolder and returned to Pythia as
  a https://app.local/media/... entry in AState.AudioResults.

*)
{$ENDREGION}

uses
  System.SysUtils, System.IOUtils, System.NetEncoding,
  WVPythia.Chat.Consts,
  Demo.OpenAI.DisplayBlocks, Demo.OpenAI.Finalize, Demo.OpenAI.Helpers;

type
  /// <summary>
  /// Holds the fixed speech options used by the first audio demo pass.
  /// </summary>
  TOpenAITTSOptions = record
  public const
    DEFAULT_VOICE = 'verse';
    LEGACY_TTS_VOICE = 'fable';
    DEFAULT_FORMAT = 'mp3';
  public
    Voice: string;
    ResponseFormat: string;

    class function DefaultVoiceForModel(
      const AModel: string): string; static;

    class function FromState(
      const AState: TStateBuffer): TOpenAITTSOptions; static;

    class function IsLegacyTTSModel(
      const AModel: string): Boolean; static;
  end;

  /// <summary>
  /// Resolves filenames and Pythia media URLs for generated audio attachments.
  /// </summary>
  TOpenAITTSFilenameResolver = record
  public
    class function ResolveLocalPath(
      const ABrowser: IPythiaBrowser): string; static;

    class function ToDisplaySource(
      const ALocalPath: string): string; static;
  end;

  /// <summary>
  /// Applies Pythia state to the SDK speech parameter builder.
  /// </summary>
  TOpenAITTSParamsBuilder = record
  public
    class procedure Apply(
      const AState: TStateBuffer;
      const Params: TSpeechParams); static;

    class function BuildRequestTrace(
      const AState: TStateBuffer): string; static;
  end;

  /// <summary>
  /// Emits the non-streamed progress block shown while OpenAI creates speech.
  /// </summary>
  TOpenAITTSProgressBlock = record
  private
    class function BuildText(
      const AState: TStateBuffer): string; static;
  public
    class procedure Emit(
      const ABrowser: IPythiaBrowser;
      const ABlocks: IOpenAIDisplayBlockAggregator;
      const AState: TStateBuffer); static;
  end;

  TOpenAITTSCompletionHandler = record
  public
    class function HandleSuccess(
      const Value: TSpeechResult;
      const ABrowser: IPythiaBrowser;
      var AState: TStateBuffer;
      const ABlocks: IOpenAIDisplayBlockAggregator;
      const AEmitGuard: IEmitGuard): TSpeechResult; static;
  end;

  TOpenAITTSErrorHandler = record
  public
    class procedure Handle(
      const E: Exception;
      const ABrowser: IPythiaBrowser;
      var AState: TStateBuffer;
      const ABlocks: IOpenAIDisplayBlockAggregator;
      const AEmitGuard: IEmitGuard); static;
  end;

{ TOpenAITTSOptions }

class function TOpenAITTSOptions.DefaultVoiceForModel(
  const AModel: string): string;
begin
  if IsLegacyTTSModel(AModel) then
    Exit(LEGACY_TTS_VOICE);

  Result := DEFAULT_VOICE;
end;

class function TOpenAITTSOptions.FromState(
  const AState: TStateBuffer): TOpenAITTSOptions;
begin
  Result := Default(TOpenAITTSOptions);
  Result.Voice := DefaultVoiceForModel(AState.Model);
  Result.ResponseFormat := DEFAULT_FORMAT;
end;

class function TOpenAITTSOptions.IsLegacyTTSModel(
  const AModel: string): Boolean;
begin
  Result :=
    SameText(AModel.Trim, 'tts-1') or
    SameText(AModel.Trim, 'tts-1-hd');
end;

{ TOpenAITTSFilenameResolver }

class function TOpenAITTSFilenameResolver.ResolveLocalPath(
  const ABrowser: IPythiaBrowser): string;
begin
  var MediaFolder := ABrowser.GetMediaFolder;
  if not TDirectory.Exists(MediaFolder) then
    TDirectory.CreateDirectory(MediaFolder);

  var Candidate := Format(
    'OpenAI_Audio_%s.mp3',
    [FormatDateTime('yyyymmdd_hhnnss', Now)]);

  Result := TParamsGetter.CheckFilename(Candidate, MediaFolder);
end;

class function TOpenAITTSFilenameResolver.ToDisplaySource(
  const ALocalPath: string): string;
begin
  var EncodedName :=
    TNetEncoding.URL.Encode(TPath.GetFileName(ALocalPath)).Replace('+', '%20');

  Result := Format(
    'https://app.local/media/%s',
    [EncodedName]);
end;

{ TOpenAITTSParamsBuilder }

class procedure TOpenAITTSParamsBuilder.Apply(
  const AState: TStateBuffer;
  const Params: TSpeechParams);
begin
  var Options := TOpenAITTSOptions.FromState(AState);

  if AState.Model.Trim.IsEmpty then
    raise Exception.Create('Text to speech requires a selected model.');

  if AState.Text.Trim.IsEmpty then
    raise Exception.Create('Text to speech requires non-empty input text.');

  Params
    .Model(AState.Model)
    .Input(AState.Text.Trim)
    .Voice(Options.Voice)
    .ResponseFormat(Options.ResponseFormat);
end;

class function TOpenAITTSParamsBuilder.BuildRequestTrace(
  const AState: TStateBuffer): string;
begin
  var Params := TSpeechParams.Create;
  try
    Apply(AState, Params);
    Result := Params.ToFormat;
  finally
    Params.Free;
  end;
end;

{ TOpenAITTSProgressBlock }

class function TOpenAITTSProgressBlock.BuildText(
  const AState: TStateBuffer): string;
begin
  var Options := TOpenAITTSOptions.FromState(AState);

  Result :=
    'Creation constraints:' + sLineBreak +
    '- voice: ' + Options.Voice + sLineBreak +
    '- format: ' + Options.ResponseFormat + sLineBreak +
    sLineBreak +
    'Prompt:' + sLineBreak +
    AState.Text.Trim;
end;

class procedure TOpenAITTSProgressBlock.Emit(
  const ABrowser: IPythiaBrowser;
  const ABlocks: IOpenAIDisplayBlockAggregator;
  const AState: TStateBuffer);
begin
  var BlockTitle := 'Text to speech';
  var BlockText := BuildText(AState);

  ABlocks.AppendStatus(BlockTitle, BlockText);
  ABrowser.DisplayToolOutput(BlockTitle, BlockText, False);
end;

{ TOpenAITTSCompletionHandler }

class function TOpenAITTSCompletionHandler.HandleSuccess(
  const Value: TSpeechResult;
  const ABrowser: IPythiaBrowser;
  var AState: TStateBuffer;
  const ABlocks: IOpenAIDisplayBlockAggregator;
  const AEmitGuard: IEmitGuard): TSpeechResult;
begin
  Result := Value;
  AState.JsonResponse := Value.JSONResponse;

  if Value.Data.Trim.IsEmpty then
    raise Exception.Create('Speech generation returned no audio data.');

  var Filename := TOpenAITTSFilenameResolver.ResolveLocalPath(ABrowser);
  Value.SaveToFile(Filename);
  AState.AudioResults := AState.AudioResults + [
    TOpenAITTSFilenameResolver.ToDisplaySource(Filename)];

  var Message := Format(
    'Audio generated: %s',
    [TPath.GetFileName(Filename)]);
  AState.AddStreamedText(Message);
  ABlocks.AppendAssistantText(Message);
  ABrowser.DisplayStream(Message, '', False);

  AEmitGuard.TryEmit(TFinalizeData.FromState(AState, ABlocks));
end;

{ TOpenAITTSErrorHandler }

class procedure TOpenAITTSErrorHandler.Handle(
  const E: Exception;
  const ABrowser: IPythiaBrowser;
  var AState: TStateBuffer;
  const ABlocks: IOpenAIDisplayBlockAggregator;
  const AEmitGuard: IEmitGuard);
begin
  AState.Error := True;
  AState.ErrorMessage := E.Message;

  ABrowser.DisplayError(E.Message);
  ABlocks.AppendAssistantText(E.Message);
  ABrowser.DisplayStream(E.Message, '', False);
  AEmitGuard.TryEmit(TFinalizeData.FromException(E, AState, ABlocks));
end;

{ TOpenAITTSTurn }

class procedure TOpenAITTSTurn.Execute(
  const AClient: IGenAI;
  const ABrowser: IPythiaBrowser;
  AState: TStateBuffer;
  const AOnFinalize: TManagedItemFinalizeProc);
begin
  var Blocks: IOpenAIDisplayBlockAggregator :=
    TOpenAIDisplayBlockAggregator.Create;
  var EmitGuard: IEmitGuard := TEmitGuard.Create(AOnFinalize);

  try
    {--- Text-to-speech creates an audio artifact, but its model comes from
         the dedicated Text to speech model selector category. }
    AState.Model := AState.Models.Items[TEXT_TO_SPEECH_INDEX].Model;
    AState.JsonRequest := TOpenAITTSParamsBuilder.BuildRequestTrace(AState);

    TOpenAITTSProgressBlock.Emit(ABrowser, Blocks, AState);

    var Promise := AClient.Audio.AsyncAwaitSpeech(
      procedure(Params: TSpeechParams)
      begin
        TOpenAITTSParamsBuilder.Apply(AState, Params);
      end);

    Promise
      .&Then<TSpeechResult>(
        function(Value: TSpeechResult): TSpeechResult
        begin
          Result := TOpenAITTSCompletionHandler.HandleSuccess(
            Value,
            ABrowser,
            AState,
            Blocks,
            EmitGuard);
        end)
      .&Catch(
        procedure(E: Exception)
        begin
          TOpenAITTSErrorHandler.Handle(
            E, ABrowser, AState, Blocks, EmitGuard);
        end);
  except
    on E: Exception do
      TOpenAITTSErrorHandler.Handle(E, ABrowser, AState, Blocks, EmitGuard);
  end;
end;

end.
