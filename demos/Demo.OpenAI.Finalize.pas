unit Demo.OpenAI.Finalize;

interface

uses
  System.SysUtils,
  GenAI,
  WVPythia.Chat.Interfaces, WVPythia.Chat.ManagedFlow, WVPythia.Vendors.Services;

type
  TFinalizeData = record
    Model: string;
    Response: string;
    Reasoning: string;
    JsonRequest: string;
    JsonResponse: string;
    FileResults: TArray<string>;
    ImageResults: TArray<string>;
    VideoResults: TArray<string>;
    AudioResult: TArray<string>;
    Error: Boolean;
    ErrorMessage: string;
    Blocks: IPythiaDisplayBlockSnapshot;

    class function FromState(
      AState: TStateBuffer;
      const ABlocks: IPythiaDisplayBlockSnapshot): TFinalizeData; overload; static;

    class function FromSuccess(
      const AValue: TResponsesEventData;
      const AState: TStateBuffer;
      const ABlocks: IPythiaDisplayBlockSnapshot): TFinalizeData; overload; static;

    class function FromException(
      const E: Exception;
      const AState: TStateBuffer;
      const ABlocks: IPythiaDisplayBlockSnapshot): TFinalizeData; overload; static;

    procedure Emit(const AOnFinalize: TManagedItemFinalizeProc);
  end;

  /// <summary>
  /// Ensures the managed finalize callback is emitted at most once.
  /// </summary>
  IEmitGuard = interface
    ['{F2C0A4D7-3E15-4C9A-9D6E-2A7E4D5B8F11}']
    procedure TryEmit(const Data: TFinalizeData);
  end;

  TEmitGuard = class(TInterfacedObject, IEmitGuard)
  private
    FEmitted: Boolean;
    FOnFinalize: TManagedItemFinalizeProc;
  public
    constructor Create(const AOnFinalize: TManagedItemFinalizeProc);
    procedure TryEmit(const Data: TFinalizeData);
  end;

implementation

{$REGION 'Dev note'}
(*

  Turn finalization for the pythia-openai FMX demo.

  TFinalizeData is the plain record that collects everything a completed
  Pythia turn must hand back to the managed-flow infrastructure (response
  text, reasoning, request/response JSON traces, media results, streamed
  display blocks, error state). Emit converts it into a
  TManagedItemLLMResult and dispatches it through the caller's finalize
  callback.

  IEmitGuard / TEmitGuard guarantee the finalize callback fires at most
  once, no matter how many completion paths (success, retrieval fallback,
  cancellation, exception) race to terminate the turn.

  The Responses streaming path uses all three constructors: canonical
  success, cancellation from the local stream buffer, and exception.

*)
{$ENDREGION}

uses
  WVPythia.ChatSession.Controller;

{ TEmitGuard }

constructor TEmitGuard.Create(const AOnFinalize: TManagedItemFinalizeProc);
begin
  inherited Create;
  FOnFinalize := AOnFinalize;
  FEmitted := False;
end;

procedure TEmitGuard.TryEmit(const Data: TFinalizeData);
begin
  if FEmitted then
    Exit;
  FEmitted := True;
  Data.Emit(FOnFinalize);
end;

{ TFinalizeData }

class function TFinalizeData.FromState(
  AState: TStateBuffer;
  const ABlocks: IPythiaDisplayBlockSnapshot): TFinalizeData;
begin
  {--- Rebuilds the final payload from the local stream buffer.
       This path is used when the request stops before a canonical success
       object is available, such as cancellation.
  }
  Result := Default(TFinalizeData);
  Result.Model := AState.Model;
  Result.Response := AState.TextBuffer;
  Result.Reasoning := AState.ThinkingBuffer;
  Result.JsonRequest := AState.JsonRequest;
  Result.JsonResponse := AState.JsonResponse;
  Result.FileResults := AState.FileResults;
  Result.ImageResults := AState.ImageResults;
  Result.VideoResults := AState.VideoResults;
  Result.AudioResult := AState.AudioResults;
  Result.Error := AState.Error;
  Result.ErrorMessage := AState.ErrorMessage;
  Result.Blocks := ABlocks;
end;

class function TFinalizeData.FromSuccess(
  const AValue: TResponsesEventData;
  const AState: TStateBuffer;
  const ABlocks: IPythiaDisplayBlockSnapshot): TFinalizeData;
begin
  {--- On success, text and reasoning come from the SDK terminal event, while
       request/response JSON traces remain sourced from the local state buffer
       accumulated during the stream.
  }
  Result := Default(TFinalizeData);
  Result.Model := AState.Model;
  Result.Response := AValue.AssistantText;
  if Result.Response.IsEmpty then
    Result.Response := AState.TextBuffer;
  Result.Reasoning := AValue.Thought;
  Result.JsonRequest := AState.JsonRequest;
  Result.JsonResponse := AState.JsonResponse;
  Result.FileResults := AState.FileResults;
  Result.ImageResults := AState.ImageResults;
  Result.VideoResults := AState.VideoResults;
  Result.AudioResult := AState.AudioResults;
  Result.Error := AState.Error;
  Result.ErrorMessage := AState.ErrorMessage;
  Result.Blocks := ABlocks;
end;

class function TFinalizeData.FromException(
  const E: Exception;
  const AState: TStateBuffer;
  const ABlocks: IPythiaDisplayBlockSnapshot): TFinalizeData;
begin
  {--- Persist the failure together with any text already streamed.
       The live UI reports the exception through the error channel, but the chat
       history is rebuilt later from Response only; without appending the message
       here, reopening the session would hide why this turn stopped.
  }
  Result := Default(TFinalizeData);
  Result.Model := AState.Model;
  if AState.TextBuffer.Trim.IsEmpty then
    Result.Response := E.Message
  else
    Result.Response := AState.TextBuffer + '<br><br>' + E.Message;
  Result.Reasoning := '';
  Result.JsonRequest := AState.JsonRequest;
  Result.JsonResponse := AState.JsonResponse;
  Result.FileResults := AState.FileResults;
  Result.ImageResults := AState.ImageResults;
  Result.VideoResults := AState.VideoResults;
  Result.AudioResult := AState.AudioResults;
  Result.Error := AState.Error;
  Result.ErrorMessage := AState.ErrorMessage;
  Result.Blocks := ABlocks;
end;

procedure TFinalizeData.Emit(const AOnFinalize: TManagedItemFinalizeProc);
var
  BlockClones: TArray<TChatDisplayBlock>;
begin
  {--- Converts the plain record into the managed result object expected by the
       surrounding flow infrastructure, then dispatches it through the caller's
       finalize callback if one was provided.
  }
  if not Assigned(AOnFinalize) then
    Exit;

  {--- Hand a cloned snapshot of the streamed blocks to the result builder;
       TManagedItemLLMResult.SetDisplayBlocks clones again into its own
       storage, so the local copies must be freed before returning. }
  BlockClones := nil;
  if Assigned(Blocks) then
    BlockClones := Blocks.CloneDisplayBlocks;

  var ResponseFlow := TManagedItemLLMResult.New;
  try
    ResponseFlow
      .UsedModel(Model)
      .Response(Response)
      .Reasoning(Reasoning)
      .PromptJson(JsonRequest)
      .ResponseJson(JsonResponse)
      .FileResults(FileResults)
      .ImageResults(ImageResults)
      .VideoResults(VideoResults)
      .AudioResults(AudioResult)
      .DisplayBlockResults(BlockClones)
      .Error(Error)
      .ErrorMessage(ErrorMessage);

    AOnFinalize(ResponseFlow);
  finally
    FreeChatDisplayBlocks(BlockClones);
    ResponseFlow.Free;
  end;
end;

end.
