unit Demo.OpenAI.ImageTurn;

interface

uses
  WVPythia.Chat.Interfaces, WVPythia.Chat.ManagedFlow,
  WVPythia.Vendors.Services,
  GenAI;

type
  TOpenAIImageTurn = record
  public
    /// <summary>
    /// Executes one Pythia image turn with the OpenAI Images API.
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

  OpenAI image turn for the pythia-openai FMX demo.

  This unit owns the media.createImage branch routed by Demo.OpenAI.Services.
  It keeps the image flow separate from the Responses streaming flow because
  the payload, SDK entry points and callbacks are different. Text turns stream
  events through Demo.OpenAI.TextTurn; image turns call the Images API promise,
  emit one progress block, save the generated media, then finalize the Pythia
  turn once through TEmitGuard.

  There are two SDK paths:
    - no input image: Images.AsyncAwaitCreate, backed by /images/generations;
    - at least one input image: Images.AsyncAwaitEdit, backed by /images/edits.
  Input images come from the current Pythia prompt attachments and, for
  image-to-image continuity, from the last generated assistant image that can
  be resolved back to a local media file.

  The prompt policy is intentionally conservative for a demo. A pure image
  creation turn sends the current user request only. Conversation context is
  appended only when an input image exists, so a previous text/vision turn does
  not steer a new creation by leaking descriptions or inline Data URI payloads.
  Source lists are compacted to file names and inline media data is ignored.

  Pythia custom cards map to image options: quality, size/orientation and
  transparent background when the selected image model supports it. The
  JsonRequest trace mirrors the SDK parameter builder enough for debugging
  without exposing binary media content in the display block.

  Generated images are saved to ABrowser.GetMediaFolder and returned to Pythia
  as https://app.local/media/... entries in AState.ImageResults.

*)
{$ENDREGION}

uses
  System.SysUtils, System.StrUtils, System.IOUtils, System.NetEncoding,
  WVPythia.Chat.Consts,
  WVPythia.ChatSession.Controller,
  Demo.OpenAI.DisplayBlocks, Demo.OpenAI.Finalize, Demo.OpenAI.Helpers;

type
  /// <summary>
  /// Reads the image-related custom cards selected in Pythia's prompt UI.
  /// </summary>
  TOpenAIImageOptions = record
  private const
    CARD_BACKGROUND = 'image-creation-background';
    CARD_BACKGROUND_NAME = 'transparent background';
    CARD_QUALITY_HIGH = 'image-creation-quality-high';
    CARD_QUALITY_HIGH_NAME = 'image high quality';
    CARD_FULL_SIZE = 'image-creation-full-size';
    CARD_FULL_SIZE_NAME = 'full size';
    CARD_PORTRAIT = 'image-creation-portrait-orientation';
    CARD_PORTRAIT_NAME = 'portrait orientation';
    CARD_LANDSCAPE = 'image-creation-landscape-orientation';
    CARD_LANDSCAPE_NAME = 'landscape orientation';
  private
    class function HasCustomCard(
      const AState: TStateBuffer;
      const AId: string;
      const AName: string): Boolean; static;
  public
    TransparentBackground: Boolean;
    HighQuality: Boolean;
    FullSize: Boolean;
    Portrait: Boolean;
    Landscape: Boolean;

    class function FromState(
      const AState: TStateBuffer): TOpenAIImageOptions; static;

    function Quality: string;
    function Size: string;
  end;

  /// <summary>
  /// Resolves filenames and Pythia media URLs for generated image attachments.
  /// </summary>
  TOpenAIImageFilenameResolver = record
  public
    class function ResolveLocalPath(
      const ABrowser: IPythiaBrowser;
      const AIndex: Integer): string; static;

    class function ToDisplaySource(
      const ALocalPath: string): string; static;
  end;

  /// <summary>
  /// Applies Pythia state to the SDK image parameter builders.
  /// </summary>
  TOpenAIImageParamsBuilder = record
  public
    class procedure ApplyCreate(
      const AState: TStateBuffer;
      const APrompt: string;
      const Params: TImageCreateParams); static;

    class procedure ApplyEdit(
      const AState: TStateBuffer;
      const APrompt: string;
      const AInputImages: TArray<string>;
      const Params: TImageEditParams); static;

    class procedure ApplyCreateSize(
      const Params: TImageCreateParams;
      const ASize: string); static;

    class procedure ApplyEditSize(
      const Params: TImageEditParams;
      const ASize: string); static;

    class function SupportsBackground(
      const AState: TStateBuffer): Boolean; static;

    class function BuildRequestTrace(
      const AState: TStateBuffer;
      const APrompt: string;
      const AInputImages: TArray<string>): string; static;

    class function BuildMultipartRequestTrace(
      const AState: TStateBuffer;
      const APrompt: string;
      const AInputImages: TArray<string>): string; static;
  end;

  /// <summary>
  /// Builds the image prompt while keeping conversation context deliberately
  /// narrow enough for a readable demo.
  /// </summary>
  TOpenAIImagePromptBuilder = record
  private const
    MAX_PROMPT_LENGTH = 30000;
    MAX_CONTEXT_TEXT_LENGTH = 2000;
  private
    class procedure AppendLine(
      var ATarget: string;
      const ALine: string); static;

    class procedure AppendSources(
      var ATarget: string;
      const ATitle: string;
      const ASources: TArray<string>); static;

    class function CleanSource(
      const AValue: string): string; static;

    class function BuildConversationContext(
      const ABrowser: IPythiaBrowser): string; static;

    class function CleanConversationText(
      const AValue: string): string; static;

    class function TrimPrompt(
      const AValue: string): string; static;
  public
    class function Build(
      const ABrowser: IPythiaBrowser;
      const AState: TStateBuffer;
      const AInputImages: TArray<string>): string; static;
  end;

  /// <summary>
  /// Collects the local input images that switch the turn from create to edit.
  /// </summary>
  TOpenAIImageSourceResolver = record
  private
    class procedure AddUniqueExisting(
      var AValues: TArray<string>;
      const APath: string); static;

    class function TryResolveLocalSource(
      const ABrowser: IPythiaBrowser;
      const ASource: string): string; static;

    class function LastResponseImage(
      const ABrowser: IPythiaBrowser): string; static;
  public
    class function InputImages(
      const ABrowser: IPythiaBrowser;
      const AState: TStateBuffer): TArray<string>; static;
  end;

  /// <summary>
  /// Emits the non-streamed progress block shown while OpenAI creates the image.
  /// </summary>
  TOpenAIImageProgressBlock = record
  private
    class procedure AddConstraint(
      var AValues: TArray<string>;
      const AValue: string); static;

    class function BuildConstraints(
      const AState: TStateBuffer): TArray<string>; static;

    class function BuildText(
      const AState: TStateBuffer): string; static;

    class function Title(
      const AInputImages: TArray<string>): string; static;
  public
    class procedure Emit(
      const ABrowser: IPythiaBrowser;
      const ABlocks: IOpenAIDisplayBlockAggregator;
      const AState: TStateBuffer;
      const AInputImages: TArray<string>); static;
  end;

  TOpenAIImageCompletionHandler = record
  public
    class function HandleSuccess(
      const Value: TGeneratedImages;
      const ABrowser: IPythiaBrowser;
      var AState: TStateBuffer;
      const ABlocks: IOpenAIDisplayBlockAggregator;
      const AEmitGuard: IEmitGuard): TGeneratedImages; static;
  end;

  TOpenAIImageErrorHandler = record
  public
    class procedure Handle(
      const E: Exception;
      const ABrowser: IPythiaBrowser;
      var AState: TStateBuffer;
      const ABlocks: IOpenAIDisplayBlockAggregator;
      const AEmitGuard: IEmitGuard); static;
  end;

{ TOpenAIImageOptions }

class function TOpenAIImageOptions.FromState(
  const AState: TStateBuffer): TOpenAIImageOptions;
begin
  Result := Default(TOpenAIImageOptions);
  Result.TransparentBackground := HasCustomCard(
    AState,
    CARD_BACKGROUND,
    CARD_BACKGROUND_NAME);

  Result.HighQuality := HasCustomCard(
    AState,
    CARD_QUALITY_HIGH,
    CARD_QUALITY_HIGH_NAME);

  Result.FullSize := HasCustomCard(
    AState,
    CARD_FULL_SIZE,
    CARD_FULL_SIZE_NAME);

  Result.Portrait := HasCustomCard(
    AState,
    CARD_PORTRAIT,
    CARD_PORTRAIT_NAME);

  Result.Landscape := HasCustomCard(
    AState,
    CARD_LANDSCAPE,
    CARD_LANDSCAPE_NAME);
end;

class function TOpenAIImageOptions.HasCustomCard(
  const AState: TStateBuffer;
  const AId,
  AName: string): Boolean;
begin
  Result := False;
  for var Item in AState.Custom do
    if SameText(Item.Id, AId) or SameText(Item.Name, AName) then
      Exit(True);
end;

function TOpenAIImageOptions.Quality: string;
begin
  if HighQuality then
    Result := 'high'
  else
    Result := 'auto';
end;

function TOpenAIImageOptions.Size: string;
begin
  if Portrait = Landscape then
    begin
      if FullSize then
        Result := '2048x2048'
      else
        Result := 'auto';
      Exit;
    end;

  if Portrait then
    begin
      if FullSize then
        Result := '1152x2048'
      else
        Result := '1024x1536';
      Exit;
    end;

  if FullSize then
    Result := '2048x1152'
  else
    Result := '1536x1024';
end;

{ TOpenAIImageFilenameResolver }

class function TOpenAIImageFilenameResolver.ResolveLocalPath(
  const ABrowser: IPythiaBrowser;
  const AIndex: Integer): string;
begin
  var MediaFolder := ABrowser.GetMediaFolder;
  if not TDirectory.Exists(MediaFolder) then
    TDirectory.CreateDirectory(MediaFolder);

  var Candidate := Format(
    'OpenAI_Image_%s_%d.png',
    [FormatDateTime('yyyymmdd_hhnnss', Now), AIndex + 1]);

  Result := TParamsGetter.CheckFilename(Candidate, MediaFolder);
end;

class function TOpenAIImageFilenameResolver.ToDisplaySource(
  const ALocalPath: string): string;
begin
  var EncodedName :=
    TNetEncoding.URL.Encode(TPath.GetFileName(ALocalPath)).Replace('+', '%20');

  Result := Format(
    'https://app.local/media/%s',
    [EncodedName]);
end;

{ TOpenAIImageParamsBuilder }

class procedure TOpenAIImageParamsBuilder.ApplyCreate(
  const AState: TStateBuffer;
  const APrompt: string;
  const Params: TImageCreateParams);
begin
  var Options := TOpenAIImageOptions.FromState(AState);

  Params
    .Model(AState.Model)
    .Prompt(APrompt)
    .N(1)
    .OutputFormat('png')
    .Quality(Options.Quality);

  if Options.TransparentBackground and SupportsBackground(AState) then
    Params.BackGround('transparent');

  ApplyCreateSize(Params, Options.Size);
end;

class procedure TOpenAIImageParamsBuilder.ApplyEdit(
  const AState: TStateBuffer;
  const APrompt: string;
  const AInputImages: TArray<string>;
  const Params: TImageEditParams);
begin
  var Options := TOpenAIImageOptions.FromState(AState);

  Params
    .Model(AState.Model)
    .Prompt(APrompt)
    .N(1)
    .OutputFormat('png')
    .Quality(Options.Quality);

  if Options.TransparentBackground and SupportsBackground(AState) then
    Params.BackGround('transparent');

  ApplyEditSize(Params, Options.Size);

  if Length(AInputImages) = 1 then
    Params.Image(AInputImages[0])
  else
    Params.Image(AInputImages);
end;

class procedure TOpenAIImageParamsBuilder.ApplyCreateSize(
  const Params: TImageCreateParams;
  const ASize: string);
begin
  if (ASize = '2048x2048') or
     (ASize = '2048x1152') or
     (ASize = '1152x2048') then
    Params.Add('size', ASize)
  else
    Params.Size(ASize);
end;

class procedure TOpenAIImageParamsBuilder.ApplyEditSize(
  const Params: TImageEditParams;
  const ASize: string);
begin
  if (ASize = '2048x2048') or
     (ASize = '2048x1152') or
     (ASize = '1152x2048') then
    Params.AddField('size', ASize)
  else
    Params.Size(ASize);
end;

class function TOpenAIImageParamsBuilder.SupportsBackground(
  const AState: TStateBuffer): Boolean;
begin
  Result := SameText(AState.Model, 'gpt-image-1.5');
end;

class function TOpenAIImageParamsBuilder.BuildMultipartRequestTrace(
  const AState: TStateBuffer;
  const APrompt: string;
  const AInputImages: TArray<string>): string;
begin
  var Params := TImageEditParams.Create;
  try
    ApplyEdit(AState, APrompt, AInputImages, Params);
  finally
    Params.Free;
  end;

  var Options := TOpenAIImageOptions.FromState(AState);
  Result :=
    'POST images/edits' + sLineBreak +
    'Content-Type: multipart/form-data' + sLineBreak +
    sLineBreak +
    'model=' + AState.Model + sLineBreak +
    'prompt=' + APrompt + sLineBreak +
    'n=1' + sLineBreak +
    'output_format=png' + sLineBreak +
    'quality=' + Options.Quality + sLineBreak +
    'size=' + Options.Size;

  if Options.TransparentBackground and SupportsBackground(AState) then
    Result := Result + sLineBreak + 'background=transparent';

  for var Index := 0 to High(AInputImages) do
    if Length(AInputImages) = 1 then
      Result := Result + sLineBreak + 'image=' + AInputImages[Index]
    else
      Result := Result + sLineBreak + 'image[]=' + AInputImages[Index];
end;

class function TOpenAIImageParamsBuilder.BuildRequestTrace(
  const AState: TStateBuffer;
  const APrompt: string;
  const AInputImages: TArray<string>): string;
begin
  if Length(AInputImages) > 0 then
    Exit(BuildMultipartRequestTrace(AState, APrompt, AInputImages));

  var Params := TImageCreateParams.Create;
  try
    ApplyCreate(AState, APrompt, Params);
    Result := Params.ToFormat;
  finally
    Params.Free;
  end;
end;

{ TOpenAIImagePromptBuilder }

class procedure TOpenAIImagePromptBuilder.AppendLine(
  var ATarget: string;
  const ALine: string);
begin
  if ALine.Trim.IsEmpty then
    Exit;

  if not ATarget.IsEmpty then
    ATarget := ATarget + sLineBreak;

  ATarget := ATarget + ALine.Trim;
end;

class procedure TOpenAIImagePromptBuilder.AppendSources(
  var ATarget: string;
  const ATitle: string;
  const ASources: TArray<string>);
begin
  if Length(ASources) = 0 then
    Exit;

  var Values: TArray<string> := [];
  for var Source in ASources do
    begin
      var Cleaned := CleanSource(Source);
      if not Cleaned.IsEmpty then
        Values := Values + [Cleaned];
    end;

  if Length(Values) = 0 then
    Exit;

  AppendLine(ATarget, ATitle + ': ' + string.Join(', ', Values));
end;

class function TOpenAIImagePromptBuilder.CleanSource(
  const AValue: string): string;
begin
  Result := AValue.Trim;
  if Result.IsEmpty then
    Exit;

  if ContainsText(Result, 'data:') or ContainsText(Result, ';base64,') then
    Exit('');

  var QueryIndex := Result.IndexOf('?');
  if QueryIndex >= 0 then
    Result := Result.Substring(0, QueryIndex);

  Result := Result.Replace('\', '/');
  var SlashIndex := Result.LastIndexOf('/');
  if SlashIndex >= 0 then
    Result := Result.Substring(SlashIndex + 1);

  Result := TNetEncoding.URL.Decode(Result).Trim;
  if Result.IsEmpty then
    Exit;

  Result := TPath.GetFileName(Result);
end;

class function TOpenAIImagePromptBuilder.BuildConversationContext(
  const ABrowser: IPythiaBrowser): string;
begin
  Result := '';

  if not Assigned(ABrowser) or
     not Assigned(ABrowser.PersistentChat) or
     not Assigned(ABrowser.PersistentChat.CurrentChat) then
    Exit;

  for var Turn in ABrowser.PersistentChat.CurrentChat.Data do
    begin
      if not Assigned(Turn) then
        Continue;

      if Turn.Prompt.Trim.IsEmpty or Turn.Response.Trim.IsEmpty then
        Continue;

      AppendLine(Result, 'User: ' + CleanConversationText(Turn.Prompt));
      AppendSources(Result, 'User images', Turn.PromptImages);
      AppendLine(Result, 'Assistant: ' + CleanConversationText(Turn.Response));
      AppendSources(Result, 'Assistant images', Turn.ReponseImages);
      AppendLine(Result, '');
    end;
end;

class function TOpenAIImagePromptBuilder.CleanConversationText(
  const AValue: string): string;
begin
  Result := AValue.Trim;
  if Result.IsEmpty then
    Exit;

  if ContainsText(Result, 'data:image/') or ContainsText(Result, ';base64,') then
    Exit('[inline media data omitted]');

  if Result.Length > MAX_CONTEXT_TEXT_LENGTH then
    Exit('[long prior turn omitted]');
end;

class function TOpenAIImagePromptBuilder.TrimPrompt(
  const AValue: string): string;
begin
  Result := AValue.Trim;
  if Result.Length <= MAX_PROMPT_LENGTH then
    Exit;

  Result :=
    Result.Substring(0, MAX_PROMPT_LENGTH).Trim + sLineBreak +
    '[Earlier conversation context truncated.]';
end;

class function TOpenAIImagePromptBuilder.Build(
  const ABrowser: IPythiaBrowser;
  const AState: TStateBuffer;
  const AInputImages: TArray<string>): string;
begin
  Result := 'Current image request:' + sLineBreak + AState.Text.Trim;

  if (Length(AInputImages) > 0) and
     (not TStateChecking.UsesPreviousResponseId(AState)) then
    begin
      var Context := BuildConversationContext(ABrowser);
      if not Context.Trim.IsEmpty then
        Result :=
          Result + sLineBreak + sLineBreak +
          'Conversation context:' + sLineBreak +
          Context.Trim;
    end;

  if Length(AInputImages) > 0 then
    Result :=
      Result + sLineBreak + sLineBreak +
      'Use the attached image input(s) as visual context when relevant. ' +
      'The latest generated image is included to preserve visual continuity.';

  Result := TrimPrompt(Result);
end;

{ TOpenAIImageSourceResolver }

class procedure TOpenAIImageSourceResolver.AddUniqueExisting(
  var AValues: TArray<string>;
  const APath: string);
begin
  var Path := APath.Trim;
  if Path.IsEmpty or not TFile.Exists(Path) then
    Exit;

  for var Item in AValues do
    if SameText(Item, Path) then
      Exit;

  AValues := AValues + [Path];
end;

class function TOpenAIImageSourceResolver.TryResolveLocalSource(
  const ABrowser: IPythiaBrowser;
  const ASource: string): string;
begin
  Result := '';

  var Source := ASource.Trim;
  if Source.IsEmpty then
    Exit;

  if TFile.Exists(Source) then
    Exit(Source);

  if not Source.ToLowerInvariant.StartsWith('https://app.local/media/') then
    Exit;

  var Name := Source;
  var QueryIndex := Name.IndexOf('?');
  if QueryIndex >= 0 then
    Name := Name.Substring(0, QueryIndex);

  Name := Name.Replace('\', '/');
  var SlashIndex := Name.LastIndexOf('/');
  if SlashIndex >= 0 then
    Name := Name.Substring(SlashIndex + 1);

  Name := TNetEncoding.URL.Decode(Name);
  if Name.Trim.IsEmpty then
    Exit;

  Result := TPath.Combine(ABrowser.GetMediaFolder, TPath.GetFileName(Name));
  if not TFile.Exists(Result) then
    Result := '';
end;

class function TOpenAIImageSourceResolver.LastResponseImage(
  const ABrowser: IPythiaBrowser): string;
begin
  Result := '';

  if not Assigned(ABrowser) or
     not Assigned(ABrowser.PersistentChat) or
     not Assigned(ABrowser.PersistentChat.CurrentChat) then
    Exit;

  var Turns := ABrowser.PersistentChat.CurrentChat.Data;
  for var index := High(Turns) downto Low(Turns) do
    begin
      var Turn := Turns[index];
      if not Assigned(Turn) then
        Continue;

      for var ItemIndex := High(Turn.ReponseImages) downto Low(Turn.ReponseImages) do
        begin
          Result := TryResolveLocalSource(ABrowser, Turn.ReponseImages[ItemIndex]);
          if not Result.IsEmpty then
            Exit;
        end;
    end;
end;

class function TOpenAIImageSourceResolver.InputImages(
  const ABrowser: IPythiaBrowser;
  const AState: TStateBuffer): TArray<string>;
begin
  Result := [];

  for var Item in AState.Images do
    AddUniqueExisting(
      Result,
      TryResolveLocalSource(ABrowser, Item.FullPath));

  AddUniqueExisting(Result, LastResponseImage(ABrowser));
end;

{ TOpenAIImageProgressBlock }

class procedure TOpenAIImageProgressBlock.AddConstraint(
  var AValues: TArray<string>;
  const AValue: string);
begin
  var Value := AValue.Trim;
  if Value.IsEmpty then
    Exit;

  AValues := AValues + [Value];
end;

class function TOpenAIImageProgressBlock.BuildConstraints(
  const AState: TStateBuffer): TArray<string>;
begin
  Result := [];

  var Options := TOpenAIImageOptions.FromState(AState);
  if Options.HighQuality then
    AddConstraint(Result, 'image high quality');

  if Options.FullSize then
    AddConstraint(Result, 'full size');

  if Options.Portrait then
    AddConstraint(Result, 'portrait orientation');

  if Options.Landscape then
    AddConstraint(Result, 'landscape orientation');

  if Options.TransparentBackground then
    begin
      if TOpenAIImageParamsBuilder.SupportsBackground(AState) then
        AddConstraint(Result, 'transparent background')
      else
        AddConstraint(
          Result,
          Format(
            'transparent background ignored: %s does not support it',
            [AState.Model]));
    end;

  AddConstraint(Result, 'quality: ' + Options.Quality);
  AddConstraint(Result, 'size: ' + Options.Size);
end;

class function TOpenAIImageProgressBlock.BuildText(
  const AState: TStateBuffer): string;
begin
  Result := 'Creation constraints:';

  for var Constraint in BuildConstraints(AState) do
    Result := Result + sLineBreak + '- ' + Constraint;

  Result :=
    Result + sLineBreak + sLineBreak +
    'Prompt:' + sLineBreak +
    AState.Text.Trim;
end;

class procedure TOpenAIImageProgressBlock.Emit(
  const ABrowser: IPythiaBrowser;
  const ABlocks: IOpenAIDisplayBlockAggregator;
  const AState: TStateBuffer;
  const AInputImages: TArray<string>);
begin
  var BlockTitle := Title(AInputImages);
  var BlockText := BuildText(AState);

  ABlocks.AppendStatus(BlockTitle, BlockText);
  ABrowser.DisplayToolOutput(BlockTitle, BlockText, False);
end;

class function TOpenAIImageProgressBlock.Title(
  const AInputImages: TArray<string>): string;
begin
  if Length(AInputImages) > 0 then
    Result := 'Image edit'
  else
    Result := 'Image creation';
end;

{ TOpenAIImageCompletionHandler }

class function TOpenAIImageCompletionHandler.HandleSuccess(
  const Value: TGeneratedImages;
  const ABrowser: IPythiaBrowser;
  var AState: TStateBuffer;
  const ABlocks: IOpenAIDisplayBlockAggregator;
  const AEmitGuard: IEmitGuard): TGeneratedImages;
begin
  Result := Value;
  AState.JsonResponse := Value.JSONResponse;

  var FirstImageName := '';

  for var index := Low(Value.Data) to High(Value.Data) do
    begin
      var Filename := TOpenAIImageFilenameResolver.ResolveLocalPath(
        ABrowser, index);
      Value.Data[index].SaveToFile(Filename);
      AState.ImageResults := AState.ImageResults + [
        TOpenAIImageFilenameResolver.ToDisplaySource(Filename)];

      if FirstImageName.IsEmpty then
        FirstImageName := TPath.GetFileName(Filename);
    end;

  if Length(AState.ImageResults) = 0 then
    raise Exception.Create('OpenAI image generation returned no image.');

  var Message := Format('Image generated: %s', [FirstImageName]);
  AState.AddStreamedText(Message);
  ABlocks.AppendAssistantText(Message);

  AEmitGuard.TryEmit(TFinalizeData.FromState(AState, ABlocks));
end;

{ TOpenAIImageErrorHandler }

class procedure TOpenAIImageErrorHandler.Handle(
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

{ TOpenAIImageTurn }

class procedure TOpenAIImageTurn.Execute(
  const AClient: IGenAI;
  const ABrowser: IPythiaBrowser;
  AState: TStateBuffer;
  const AOnFinalize: TManagedItemFinalizeProc);
begin
  var Blocks: IOpenAIDisplayBlockAggregator :=
    TOpenAIDisplayBlockAggregator.Create;
  var EmitGuard: IEmitGuard := TEmitGuard.Create(AOnFinalize);

  try
    {--- The image category model is supplied by Pythia with each prompt state. }
    AState.Model := AState.Models.Items[IMAGE_GENERATION_INDEX].Model;

    {--- Any resolved input image switches the request from creation to edit.
         This keeps image-to-image continuity available while pure creation
         stays driven by the current user prompt only.
    }
    var InputImages := TOpenAIImageSourceResolver.InputImages(ABrowser, AState);
    var Prompt := TOpenAIImagePromptBuilder.Build(
      ABrowser,
      AState,
      InputImages);
    AState.JsonRequest := TOpenAIImageParamsBuilder.BuildRequestTrace(
      AState,
      Prompt,
      InputImages);
    TOpenAIImageProgressBlock.Emit(
      ABrowser,
      Blocks,
      AState,
      InputImages);

    if Length(InputImages) > 0 then
      begin
        var Promise := AClient.Images.AsyncAwaitEdit(
          procedure(Params: TImageEditParams)
          begin
            TOpenAIImageParamsBuilder.ApplyEdit(
              AState,
              Prompt,
              InputImages,
              Params);
          end);

        Promise
          .&Then<TGeneratedImages>(
            function(Value: TGeneratedImages): TGeneratedImages
            begin
              Result := TOpenAIImageCompletionHandler.HandleSuccess(
                Value,
                ABrowser,
                AState,
                Blocks,
                EmitGuard);
            end)
          .&Catch(
            procedure(E: Exception)
            begin
              TOpenAIImageErrorHandler.Handle(
                E, ABrowser, AState, Blocks, EmitGuard);
            end);
      end
    else
      begin
        var Promise := AClient.Images.AsyncAwaitCreate(
          procedure(Params: TImageCreateParams)
          begin
            TOpenAIImageParamsBuilder.ApplyCreate(AState, Prompt, Params);
          end);

        Promise
          .&Then<TGeneratedImages>(
            function(Value: TGeneratedImages): TGeneratedImages
            begin
              Result := TOpenAIImageCompletionHandler.HandleSuccess(
                Value,
                ABrowser,
                AState,
                Blocks,
                EmitGuard);
            end)
          .&Catch(
            procedure(E: Exception)
            begin
              TOpenAIImageErrorHandler.Handle(
                E, ABrowser, AState, Blocks, EmitGuard);
            end);
      end;
  except
    on E: Exception do
      TOpenAIImageErrorHandler.Handle(E, ABrowser, AState, Blocks, EmitGuard);
  end;
end;

end.
