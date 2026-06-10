unit Demo.OpenAI.STTTurn;

interface

uses
  WVPythia.Chat.Interfaces, WVPythia.Chat.ManagedFlow,
  WVPythia.Vendors.Services,
  GenAI;

type
  TOpenAISTTTurn = record
  public
    /// <summary>
    /// Executes one Pythia speech-to-text turn with the OpenAI transcription API.
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

  OpenAI speech-to-text turn for the pythia-openai FMX demo.

  This unit owns the media.speechToText branch routed by Demo.OpenAI.Services.
  It follows the same non-streamed shape as Demo.OpenAI.TTSTurn: resolve the
  local media attachments, build SDK requests, emit one progress block, and
  finalize the Pythia turn once every transcription promise has completed.

  The request is intentionally built through the SDK parameter object:
    Client.Audio.AsyncAwaitTranscription(
      procedure(Params: TTranscriptionParams)
      begin
        Params.Model(...);
        Params.&File(...);
        Params.ResponseFormat('json');
        Params.Prompt(...);
      end);

  Pythia supplies the selected transcription model through
  SPEECH_TO_TEXT_INDEX. The demo accepts one or more attached .mp3 or .wav
  files. Every file is sent through its own AsyncAwaitTranscription call, so
  independent audio files can be transcribed in parallel while still producing
  one Pythia conversation turn. A non-empty prompt is forwarded as the optional
  transcription prompt for each request, which lets the user guide vocabulary
  or context without changing the conversation router.

  The transcription text is returned as the assistant text for the turn. No
  additional file is produced.

*)
{$ENDREGION}

uses
  System.SysUtils, System.IOUtils,
  WVPythia.Chat.Consts,
  Demo.OpenAI.DisplayBlocks, Demo.OpenAI.Finalize;

type
  /// <summary>
  /// Holds the fixed transcription options used by the first STT demo pass.
  /// </summary>
  TOpenAISTTOptions = record
  public const
    DEFAULT_RESPONSE_FORMAT = 'json';
  public
    ResponseFormat: string;

    class function FromState(
      const AState: TStateBuffer): TOpenAISTTOptions; static;
  end;

  /// <summary>
  /// Resolves the local mp3 or wav attachments used as transcription input.
  /// </summary>
  TOpenAISTTAudioSourceResolver = record
  private
    class function IsSupportedAudioFile(
      const AFullPath: string): Boolean; static;
    class procedure AddUnique(
      var AAudioFiles: TArray<string>;
      const AFullPath: string); static;
  public
    class function Resolve(
      const AState: TStateBuffer): TArray<string>; static;
  end;

  /// <summary>
  /// Applies Pythia state to the SDK transcription parameter builder.
  /// </summary>
  TOpenAISTTParamsBuilder = record
  public
    class procedure Apply(
      const AState: TStateBuffer;
      const AAudioFile: string;
      const Params: TTranscriptionParams); static;

    class function BuildRequestTrace(
      const AState: TStateBuffer;
      const AAudioFiles: TArray<string>): string; static;
  end;

  /// <summary>
  /// Emits the non-streamed progress block shown while OpenAI transcribes audio.
  /// </summary>
  TOpenAISTTProgressBlock = record
  private
    class function BuildText(
      const AState: TStateBuffer;
      const AAudioFiles: TArray<string>): string; static;
  public
    class procedure Emit(
      const ABrowser: IPythiaBrowser;
      const ABlocks: IOpenAIDisplayBlockAggregator;
      const AState: TStateBuffer;
      const AAudioFiles: TArray<string>); static;
  end;

  TOpenAISTTFileResult = record
    FileName: string;
    Transcript: string;
    JsonResponse: string;
    ErrorMessage: string;
    Completed: Boolean;
  end;

  IOpenAISTTBatchCoordinator = interface
    ['{C5F90C2F-8CF5-4571-A469-70D741D89722}']
    function HandleSuccess(
      const AIndex: Integer;
      const Value: TTranscription): TTranscription;
    procedure HandleFailure(
      const AIndex: Integer;
      const E: Exception);
  end;

  TOpenAISTTBatchCoordinator = class(
    TInterfacedObject, IOpenAISTTBatchCoordinator)
  private
    FBrowser: IPythiaBrowser;
    FBlocks: IOpenAIDisplayBlockAggregator;
    FEmitGuard: IEmitGuard;
    FState: TStateBuffer;
    FResults: TArray<TOpenAISTTFileResult>;
    FCompletedCount: Integer;
    FLiveOutputStarted: Boolean;

    function Count: Integer;
    function MultipleFiles: Boolean;
    function FormatTranscript(
      const AIndex: Integer;
      const AText: string): string;
    function BuildFinalText: string;
    function BuildJsonResponse: string;
    procedure RegisterCompletion(
      const AIndex: Integer;
      const ATranscript: string;
      const AJsonResponse: string;
      const AErrorMessage: string);
    procedure FinalizeIfComplete;
  public
    constructor Create(
      const ABrowser: IPythiaBrowser;
      const AState: TStateBuffer;
      const AAudioFiles: TArray<string>;
      const ABlocks: IOpenAIDisplayBlockAggregator;
      const AEmitGuard: IEmitGuard);

    function HandleSuccess(
      const AIndex: Integer;
      const Value: TTranscription): TTranscription;
    procedure HandleFailure(
      const AIndex: Integer;
      const E: Exception);
  end;

  TOpenAISTTRequest = record
  public
    class procedure Start(
      const AClient: IGenAI;
      const AState: TStateBuffer;
      const AIndex: Integer;
      const AAudioFile: string;
      const ACoordinator: IOpenAISTTBatchCoordinator); static;
  end;

  TOpenAISTTErrorHandler = record
  public
    class procedure Handle(
      const E: Exception;
      const ABrowser: IPythiaBrowser;
      var AState: TStateBuffer;
      const ABlocks: IOpenAIDisplayBlockAggregator;
      const AEmitGuard: IEmitGuard); static;
  end;

{ TOpenAISTTOptions }

class function TOpenAISTTOptions.FromState(
  const AState: TStateBuffer): TOpenAISTTOptions;
begin
  Result := Default(TOpenAISTTOptions);
  Result.ResponseFormat := DEFAULT_RESPONSE_FORMAT;
end;

{ TOpenAISTTAudioSourceResolver }

class function TOpenAISTTAudioSourceResolver.IsSupportedAudioFile(
  const AFullPath: string): Boolean;
begin
  var Ext := TPath.GetExtension(AFullPath).ToLowerInvariant;

  Result :=
    ((Ext = '.mp3') or (Ext = '.wav')) and
    TFile.Exists(AFullPath);
end;

class procedure TOpenAISTTAudioSourceResolver.AddUnique(
  var AAudioFiles: TArray<string>;
  const AFullPath: string);
begin
  var Path := AFullPath.Trim;
  if Path.IsEmpty then
    Exit;

  for var Existing in AAudioFiles do
    if SameText(Existing, Path) then
      Exit;

  AAudioFiles := AAudioFiles + [Path];
end;

class function TOpenAISTTAudioSourceResolver.Resolve(
  const AState: TStateBuffer): TArray<string>;
begin
  Result := [];

  for var Item in AState.Media.SpeechToText do
    if IsSupportedAudioFile(Item.FullPath) then
      AddUnique(Result, Item.FullPath);

  if Length(Result) = 0 then
    raise Exception.Create(
      'Speech to text requires one attached .mp3 or .wav audio file.');
end;

{ TOpenAISTTParamsBuilder }

class procedure TOpenAISTTParamsBuilder.Apply(
  const AState: TStateBuffer;
  const AAudioFile: string;
  const Params: TTranscriptionParams);
begin
  var Options := TOpenAISTTOptions.FromState(AState);

  Params
    .Model(AState.Model)
    .&File(AAudioFile)
    .ResponseFormat(Options.ResponseFormat);

  if not AState.Text.Trim.IsEmpty then
    Params.Prompt(AState.Text.Trim);
end;

class function TOpenAISTTParamsBuilder.BuildRequestTrace(
  const AState: TStateBuffer;
  const AAudioFiles: TArray<string>): string;
begin
  var Options := TOpenAISTTOptions.FromState(AState);

  Result :=
    'POST audio/transcriptions' + sLineBreak +
    'model=' + AState.Model + sLineBreak +
    'response_format=' + Options.ResponseFormat;

  for var AudioFile in AAudioFiles do
    Result := Result + sLineBreak + 'file=' + AudioFile;

  if not AState.Text.Trim.IsEmpty then
    Result := Result + sLineBreak + 'prompt=' + AState.Text.Trim;
end;

{ TOpenAISTTProgressBlock }

class function TOpenAISTTProgressBlock.BuildText(
  const AState: TStateBuffer;
  const AAudioFiles: TArray<string>): string;
begin
  var Options := TOpenAISTTOptions.FromState(AState);

  Result :=
    'Transcription constraints:' + sLineBreak +
    '- files: ' + Length(AAudioFiles).ToString + sLineBreak +
    '- format: ' + Options.ResponseFormat;

  for var AudioFile in AAudioFiles do
    Result := Result + sLineBreak + '- file: ' + TPath.GetFileName(AudioFile);

  if not AState.Text.Trim.IsEmpty then
    Result :=
      Result + sLineBreak +
      sLineBreak +
      'Prompt:' + sLineBreak +
      AState.Text.Trim;
end;

class procedure TOpenAISTTProgressBlock.Emit(
  const ABrowser: IPythiaBrowser;
  const ABlocks: IOpenAIDisplayBlockAggregator;
  const AState: TStateBuffer;
  const AAudioFiles: TArray<string>);
begin
  var BlockTitle := 'Speech to text';
  var BlockText := BuildText(AState, AAudioFiles);

  ABlocks.AppendStatus(BlockTitle, BlockText);
  ABrowser.DisplayToolOutput(BlockTitle, BlockText, False);
end;

{ TOpenAISTTBatchCoordinator }

constructor TOpenAISTTBatchCoordinator.Create(
  const ABrowser: IPythiaBrowser;
  const AState: TStateBuffer;
  const AAudioFiles: TArray<string>;
  const ABlocks: IOpenAIDisplayBlockAggregator;
  const AEmitGuard: IEmitGuard);
begin
  inherited Create;
  FBrowser := ABrowser;
  FState := AState;
  FBlocks := ABlocks;
  FEmitGuard := AEmitGuard;
  FCompletedCount := 0;
  FLiveOutputStarted := False;

  SetLength(FResults, Length(AAudioFiles));
  for var Index := 0 to High(AAudioFiles) do
    FResults[Index].FileName := TPath.GetFileName(AAudioFiles[Index]);
end;

function TOpenAISTTBatchCoordinator.Count: Integer;
begin
  Result := Length(FResults);
end;

function TOpenAISTTBatchCoordinator.MultipleFiles: Boolean;
begin
  Result := Count > 1;
end;

function TOpenAISTTBatchCoordinator.FormatTranscript(
  const AIndex: Integer;
  const AText: string): string;
begin
  Result := AText.Trim;

  if MultipleFiles then
    Result := FResults[AIndex].FileName + ':' + sLineBreak + Result;
end;

function TOpenAISTTBatchCoordinator.BuildFinalText: string;
begin
  Result := '';

  for var Index := 0 to High(FResults) do
    begin
      var Text := FResults[Index].Transcript.Trim;
      if Text.IsEmpty then
        Text := FResults[Index].ErrorMessage.Trim;

      if Text.IsEmpty then
        Continue;

      if not Result.IsEmpty then
        Result := Result + sLineBreak + sLineBreak;

      Result := Result + FormatTranscript(Index, Text);
    end;
end;

function TOpenAISTTBatchCoordinator.BuildJsonResponse: string;
begin
  Result := '';

  if (not MultipleFiles) and (Length(FResults) = 1) then
    begin
      Result := FResults[0].JsonResponse.Trim;
      if Result.IsEmpty then
        Result := FResults[0].ErrorMessage.Trim;
      Exit;
    end;

  for var Index := 0 to High(FResults) do
    begin
      var Text := FResults[Index].JsonResponse.Trim;
      if Text.IsEmpty then
        Text := FResults[Index].ErrorMessage.Trim;

      if Text.IsEmpty then
        Continue;

      if not Result.IsEmpty then
        Result := Result + sLineBreak + sLineBreak;

      Result :=
        Result +
        'file=' + FResults[Index].FileName + sLineBreak +
        Text;
    end;
end;

procedure TOpenAISTTBatchCoordinator.RegisterCompletion(
  const AIndex: Integer;
  const ATranscript: string;
  const AJsonResponse: string;
  const AErrorMessage: string);
begin
  if (AIndex < 0) or (AIndex > High(FResults)) then
    Exit;

  if FResults[AIndex].Completed then
    Exit;

  FResults[AIndex].Transcript := ATranscript.Trim;
  FResults[AIndex].JsonResponse := AJsonResponse.Trim;
  FResults[AIndex].ErrorMessage := AErrorMessage.Trim;
  FResults[AIndex].Completed := True;
  Inc(FCompletedCount);
end;

procedure TOpenAISTTBatchCoordinator.FinalizeIfComplete;
begin
  if FCompletedCount < Count then
    Exit;

  var FinalText := BuildFinalText;
  if FinalText.Trim.IsEmpty then
    FinalText := 'No transcription text returned.';

  FState.JsonResponse := BuildJsonResponse;
  FState.AddStreamedText(FinalText);
  FBlocks.AppendAssistantText(FinalText);

  FEmitGuard.TryEmit(TFinalizeData.FromState(FState, FBlocks));
end;

function TOpenAISTTBatchCoordinator.HandleSuccess(
  const AIndex: Integer;
  const Value: TTranscription): TTranscription;
begin
  Result := Value;

  var Transcript := Value.Text.Trim;
  if Transcript.IsEmpty then
    Transcript := 'No transcription text returned.';

  RegisterCompletion(AIndex, Transcript, Value.JSONResponse, '');

  var LiveText := FormatTranscript(AIndex, Transcript);
  if FLiveOutputStarted then
    LiveText := sLineBreak + sLineBreak + LiveText;
  FLiveOutputStarted := True;

  FBrowser.DisplayStream(LiveText, '', False);
  FinalizeIfComplete;
end;

procedure TOpenAISTTBatchCoordinator.HandleFailure(
  const AIndex: Integer;
  const E: Exception);
begin
  FState.Error := True;
  if FState.ErrorMessage.Trim.IsEmpty then
    FState.ErrorMessage := E.Message
  else
    FState.ErrorMessage := FState.ErrorMessage + sLineBreak + E.Message;

  RegisterCompletion(AIndex, '', '', E.Message);

  var LiveText := FormatTranscript(AIndex, E.Message);
  if FLiveOutputStarted then
    LiveText := sLineBreak + sLineBreak + LiveText;
  FLiveOutputStarted := True;

  FBrowser.DisplayError(E.Message);
  FBrowser.DisplayStream(LiveText, '', False);
  FinalizeIfComplete;
end;

{ TOpenAISTTRequest }

class procedure TOpenAISTTRequest.Start(
  const AClient: IGenAI;
  const AState: TStateBuffer;
  const AIndex: Integer;
  const AAudioFile: string;
  const ACoordinator: IOpenAISTTBatchCoordinator);
begin
  try
    var Promise := AClient.Audio.AsyncAwaitTranscription(
      procedure(Params: TTranscriptionParams)
      begin
        TOpenAISTTParamsBuilder.Apply(AState, AAudioFile, Params);
      end);

    Promise
      .&Then<TTranscription>(
        function(Value: TTranscription): TTranscription
        begin
          Result := ACoordinator.HandleSuccess(AIndex, Value);
        end)
      .&Catch(
        procedure(E: Exception)
        begin
          ACoordinator.HandleFailure(AIndex, E);
        end);
  except
    on E: Exception do
      ACoordinator.HandleFailure(AIndex, E);
  end;
end;

{ TOpenAISTTErrorHandler }

class procedure TOpenAISTTErrorHandler.Handle(
  const E: Exception;
  const ABrowser: IPythiaBrowser;
  var AState: TStateBuffer;
  const ABlocks: IOpenAIDisplayBlockAggregator;
  const AEmitGuard: IEmitGuard);
begin
  AState.Error := True;
  AState.ErrorMessage := E.Message;

  ABrowser.DisplayError(E.Message);
  AEmitGuard.TryEmit(TFinalizeData.FromException(E, AState, ABlocks));
end;

{ TOpenAISTTTurn }

class procedure TOpenAISTTTurn.Execute(
  const AClient: IGenAI;
  const ABrowser: IPythiaBrowser;
  AState: TStateBuffer;
  const AOnFinalize: TManagedItemFinalizeProc);
begin
  var Blocks: IOpenAIDisplayBlockAggregator :=
    TOpenAIDisplayBlockAggregator.Create;
  var EmitGuard: IEmitGuard := TEmitGuard.Create(AOnFinalize);

  try
    AState.Model := AState.Models.Items[SPEECH_TO_TEXT_INDEX].Model;

    var AudioFiles := TOpenAISTTAudioSourceResolver.Resolve(AState);
    AState.JsonRequest := TOpenAISTTParamsBuilder.BuildRequestTrace(
      AState,
      AudioFiles);

    TOpenAISTTProgressBlock.Emit(ABrowser, Blocks, AState, AudioFiles);

    var Coordinator: IOpenAISTTBatchCoordinator :=
      TOpenAISTTBatchCoordinator.Create(
        ABrowser,
        AState,
        AudioFiles,
        Blocks,
        EmitGuard);

    for var Index := 0 to High(AudioFiles) do
      TOpenAISTTRequest.Start(
        AClient,
        AState,
        Index,
        AudioFiles[Index],
        Coordinator);
  except
    on E: Exception do
      TOpenAISTTErrorHandler.Handle(E, ABrowser, AState, Blocks, EmitGuard);
  end;
end;

end.
