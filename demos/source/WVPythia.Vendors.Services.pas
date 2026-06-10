unit WVPythia.Vendors.Services;

interface

uses
  System.SysUtils,
  WVPythia.Chat.ManagedFlow, WVPythia.Strs;

type
  IVendorServices = interface
    ['{E7464431-EB15-4121-ADB4-76C40F1A9BEE}']
    procedure AsyncAwaitStreamChat(
      const AState: TInputPromptState;
      const AOnFinalize: TManagedItemFinalizeProc);
    procedure UpdateApiKey;

  end;

  TOptionalParam<T> = record
  public
    Value: T;
    Enabled: Boolean;

    class function Create(
      const AValue: T;
      const AEnabled: Boolean = True): TOptionalParam<T>; static; inline;
  end;

  TCoreSettingsData = record
  public
    Temperature: TOptionalParam<Double>;
    MaxToken: TOptionalParam<Int64>;
    StopString: TOptionalParam<TArray<string>>;

    class function FromCore(const AValue: TCoreSettings): TCoreSettingsData; static;
  end;

  TCoreSamplingData = record
  public
    TopK: TOptionalParam<Int64>;
    PresencePenalty: TOptionalParam<Double>;
    TopP: TOptionalParam<Double>;
    Seed: TOptionalParam<Int64>;

    class function FromCore(const AValue: TCoreSampling): TCoreSamplingData; static;
  end;

  TCoreVendorSettingsData = record
  public
    ParallelToolCalls: Boolean;
    BackgroundResponse: Boolean;
    UsingPreviousId: Boolean;
    Store: Boolean;

    class function FromCore(
      const AValue: TCoreVendorSettings): TCoreVendorSettingsData; static;
  end;

  TCoreParamsData = record
  public
    SystemPrompt: TOptionalParam<string>;
    Settings: TCoreSettingsData;
    Sampling: TCoreSamplingData;
    StructuredOutput: TOptionalParam<string>;
    VendorSettings: TCoreVendorSettingsData;

    class function FromCore(const AValue: TCoreParamsState): TCoreParamsData; static;
    class operator Implicit(const AValue: TCoreParamsState): TCoreParamsData;
  end;

  TListItemData = record
  public
    Id: string;
    Name: string;

    class function FromClass(const AValue: TListItems): TListItemData; static;
    class function FromArray(const AValues: TArray<TListItems>): TArray<TListItemData>; static;
    class operator Implicit(const AValue: TListItems): TListItemData;
  end;

  TMediaItemData = record
  public
    Name: string;
    FullPath: string;
    FileId: string;

    class function FromClass(const AValue: TMediaItem): TMediaItemData; static;
    class function FromArray(const AValues: TArray<TMediaItem>): TArray<TMediaItemData>; static;
    class operator Implicit(const AValue: TMediaItem): TMediaItemData;
  end;

  TProjectData = record
  public
    DisplayName: string;
    FullPath: string;

    class function FromClass(const AValue: TProjectState): TProjectData; static;
    class operator Implicit(const AValue: TProjectState): TProjectData;
  end;

  TIntegrationData = record
  public
    &Function: TArray<TListItemData>;
    Mcp: TArray<TListItemData>;
    JsSandbox: TArray<TListItemData>;
    Skills: TArray<TListItemData>;
    Agents: TArray<TListItemData>;

    class function FromClass(const AValue: TIntegration): TIntegrationData; static;
    class operator Implicit(const AValue: TIntegration): TIntegrationData;
  end;

  TMediaData = record
  public
    CreateImage: Boolean;
    CreateVideo: Boolean;
    CreateAudio: Boolean;
    SpeechToText: TArray<TMediaItemData>;
    TextToSpeech: Boolean;

    class function FromClass(const AValue: TMedia): TMediaData; static;
    class operator Implicit(const AValue: TMedia): TMediaData;
  end;

  TModelCategoryItemData = record
  public
    Id: string;
    &Label: string;
    FeatureLabels: TArray<string>;
    Model: string;
    Enabled: Boolean;

    class function FromClass(
      const AValue: TModelCategoryItem): TModelCategoryItemData; static;
    class function FromArray(
      const AValues: TArray<TModelCategoryItem>): TArray<TModelCategoryItemData>; static;
    class operator Implicit(
      const AValue: TModelCategoryItem): TModelCategoryItemData;
  end;

  TModelsData = record
  public
    Items: TArray<TModelCategoryItemData>;

    class function FromClass(const AValue: TModels): TModelsData; static;
    class operator Implicit(const AValue: TModels): TModelsData;
  end;

  TStateBuffer = record
  public
    Source: string;
    TextBuffer: string;
    ThinkingBuffer: string;
    JsonRequest: string;
    JsonResponse: string;
    Error: Boolean;
    ErrorMessage: string;

    Model: string;

    Text: string;
    Endpoint: string;
    Thinking: string;
    DeepResearch: Boolean;
    WebSearch: Boolean;
    Project: TProjectData;

    Files: TArray<TMediaItemData>;
    Images: TArray<TMediaItemData>;
    KnowledgeSearch: TArray<TMediaItemData>;

    Integration: TIntegrationData;
    Custom: TArray<TListItemData>;
    Media: TMediaData;
    Models: TModelsData;
    CoreParamsState: TCoreParamsData;

    //Results
    ImageToDownload: Boolean;  //not with Anthropic
    AudioToDownload: Boolean;  //not with Anthropic
    VideoToDownload: Boolean;  //not with Anthropic
    FileResults: TArray<string>;
    ImageResults: TArray<string>;
    AudioResults: TArray<string>;
    VideoResults: TArray<string>;

    {--- File ids harvested live from the streamed tool-result blocks
         (e.g. bash_code_execution_tool_result). Populated through
         AddOutputFileId from the vendor service's OnProgress handler,
         so the post-stream finalize path doesn't have to re-parse the
         raw JSON to discover what needs to be downloaded. }
    OutputFileIds: TArray<string>;

    procedure AddStreamedText(const Value: string);
    procedure AddStreamedThinking(const Value: string);
    procedure AddJsonResponse(const Value: string);
    procedure AddOutputFileId(const Value: string);

    class function FromState(const AState: TInputPromptState): TStateBuffer; static;
    class operator Implicit(const AState: TInputPromptState): TStateBuffer;
  end;

implementation

{ TOptionalParam<T> }

class function TOptionalParam<T>.Create(
  const AValue: T;
  const AEnabled: Boolean): TOptionalParam<T>;
begin
  Result.Value := AValue;
  Result.Enabled := AEnabled;
end;

{ TCoreSettingsData }

class function TCoreSettingsData.FromCore(
  const AValue: TCoreSettings): TCoreSettingsData;
begin
  Result := Default(TCoreSettingsData);

  if AValue = nil then
    Exit;

  Result.Temperature := TOptionalParam<Double>.Create(
    AValue.Temperature,
    True
  );

  if AValue.MaxToken <> nil then
    Result.MaxToken := TOptionalParam<Int64>.Create(
      AValue.MaxToken.MaxToken,
      AValue.MaxToken.Enabled
    );

  if AValue.StopString <> nil then
    Result.StopString := TOptionalParam<TArray<string>>.Create(
      AValue.StopString.StopString,
      AValue.StopString.Enabled
    );
end;

{ TCoreSamplingData }

class function TCoreSamplingData.FromCore(
  const AValue: TCoreSampling): TCoreSamplingData;
begin
  Result := Default(TCoreSamplingData);

  if AValue = nil then
    Exit;

  if AValue.TopK <> nil then
    Result.TopK := TOptionalParam<Int64>.Create(
      AValue.TopK.TopK,
      AValue.TopK.Enabled
    );

  if AValue.PresencePenalty <> nil then
    Result.PresencePenalty := TOptionalParam<Double>.Create(
      AValue.PresencePenalty.PresencePenalty,
      AValue.PresencePenalty.Enabled
    );

  if AValue.TopP <> nil then
    Result.TopP := TOptionalParam<Double>.Create(
      AValue.TopP.TopP,
      AValue.TopP.Enabled
    );

  if AValue.Seed <> nil then
    Result.Seed := TOptionalParam<Int64>.Create(
      AValue.Seed.Seed,
      AValue.Seed.Enabled
    );
end;

{ TCoreVendorSettingsData }

class function TCoreVendorSettingsData.FromCore(
  const AValue: TCoreVendorSettings): TCoreVendorSettingsData;
begin
  Result := Default(TCoreVendorSettingsData);

  if AValue = nil then
    Exit;

  Result.ParallelToolCalls := AValue.ParallelToolCalls;
  Result.BackgroundResponse := AValue.BackgroundResponse;
  Result.UsingPreviousId := AValue.UsingPreviousId;
  Result.Store := AValue.Store;
end;

{ TCoreParamsData }

class function TCoreParamsData.FromCore(
  const AValue: TCoreParamsState): TCoreParamsData;
begin
  Result := Default(TCoreParamsData);

  if AValue = nil then
    Exit;

  if AValue.SystemPrompt <> nil then
    Result.SystemPrompt := TOptionalParam<string>.Create(
      AValue.SystemPrompt.SystemPrompt,
      AValue.SystemPrompt.Enabled
    );

  Result.Settings := TCoreSettingsData.FromCore(AValue.Settings);
  Result.Sampling := TCoreSamplingData.FromCore(AValue.Sampling);

  if AValue.StructuredOutput <> nil then
    Result.StructuredOutput := TOptionalParam<string>.Create(
      AValue.StructuredOutput.JsonSchema,
      AValue.StructuredOutput.Enabled
    );

  Result.VendorSettings := TCoreVendorSettingsData.FromCore(AValue.VendorSettings);
end;

class operator TCoreParamsData.Implicit(
  const AValue: TCoreParamsState): TCoreParamsData;
begin
  Result := FromCore(AValue);
end;

class function TListItemData.FromClass(const AValue: TListItems): TListItemData;
begin
  Result := Default(TListItemData);
  if AValue = nil then
    Exit;

  Result.Id := AValue.Id;
  Result.Name := AValue.Name;
end;

class function TListItemData.FromArray(
  const AValues: TArray<TListItems>): TArray<TListItemData>;
begin
  SetLength(Result, Length(AValues));
  for var I := 0 to High(AValues) do
    Result[I] := FromClass(AValues[I]);
end;

class operator TListItemData.Implicit(const AValue: TListItems): TListItemData;
begin
  Result := FromClass(AValue);
end;

class function TMediaItemData.FromClass(const AValue: TMediaItem): TMediaItemData;
begin
  Result := Default(TMediaItemData);
  if AValue = nil then
    Exit;

  Result.Name := AValue.Name;
  Result.FullPath := AValue.FullPath;
  Result.FileId := AValue.FileId;
end;

class function TMediaItemData.FromArray(
  const AValues: TArray<TMediaItem>): TArray<TMediaItemData>;
begin
  SetLength(Result, Length(AValues));
  for var I := 0 to High(AValues) do
    Result[I] := FromClass(AValues[I]);
end;

class operator TMediaItemData.Implicit(const AValue: TMediaItem): TMediaItemData;
begin
  Result := FromClass(AValue);
end;

class function TProjectData.FromClass(const AValue: TProjectState): TProjectData;
begin
  Result := Default(TProjectData);
  if AValue = nil then
    Exit;

  Result.DisplayName := AValue.DisplayName;
  Result.FullPath := AValue.FullPath;
end;

class operator TProjectData.Implicit(const AValue: TProjectState): TProjectData;
begin
  Result := FromClass(AValue);
end;

class function TIntegrationData.FromClass(const AValue: TIntegration): TIntegrationData;
begin
  Result := Default(TIntegrationData);
  if AValue = nil then
    Exit;

  Result.&Function := TListItemData.FromArray(AValue.&Function);
  Result.Mcp := TListItemData.FromArray(AValue.Mcp);
  Result.JsSandbox := TListItemData.FromArray(AValue.JsSandbox);
  Result.Skills := TListItemData.FromArray(AValue.Skills);
  Result.Agents := TListItemData.FromArray(AValue.Agents);
end;

class operator TIntegrationData.Implicit(const AValue: TIntegration): TIntegrationData;
begin
  Result := FromClass(AValue);
end;

class function TMediaData.FromClass(const AValue: TMedia): TMediaData;
begin
  Result := Default(TMediaData);
  if AValue = nil then
    Exit;

  Result.CreateImage := AValue.CreateImage;
  Result.CreateVideo := AValue.CreateVideo;
  Result.CreateAudio := AValue.CreateAudio;
  Result.SpeechToText := TMediaItemData.FromArray(AValue.SpeechToText);
  Result.TextToSpeech := AValue.TextToSpeech;
end;

class operator TMediaData.Implicit(const AValue: TMedia): TMediaData;
begin
  Result := FromClass(AValue);
end;

class function TModelCategoryItemData.FromClass(
  const AValue: TModelCategoryItem): TModelCategoryItemData;
begin
  Result := Default(TModelCategoryItemData);
  if AValue = nil then
    Exit;

  Result.Id := AValue.Id;
  Result.&Label := AValue.&Label;
  Result.FeatureLabels := AValue.FeatureLabels;
  Result.Model := AValue.Model;
  Result.Enabled := AValue.Enabled;
end;

class function TModelCategoryItemData.FromArray(
  const AValues: TArray<TModelCategoryItem>): TArray<TModelCategoryItemData>;
begin
  SetLength(Result, Length(AValues));
  for var I := 0 to High(AValues) do
    Result[I] := FromClass(AValues[I]);
end;

class operator TModelCategoryItemData.Implicit(
  const AValue: TModelCategoryItem): TModelCategoryItemData;
begin
  Result := FromClass(AValue);
end;

class function TModelsData.FromClass(const AValue: TModels): TModelsData;
begin
  Result := Default(TModelsData);
  if AValue = nil then
    Exit;

  Result.Items := TModelCategoryItemData.FromArray(AValue.Categories);
end;

class operator TModelsData.Implicit(const AValue: TModels): TModelsData;
begin
  Result := FromClass(AValue);
end;

procedure TStateBuffer.AddJsonResponse(const Value: string);
begin
  if JsonResponse.IsEmpty then
    JsonResponse := Value
  else
    JsonResponse := JsonResponse + #10 + Value;
end;

procedure TStateBuffer.AddOutputFileId(const Value: string);
begin
  var Id := Value.Trim;
  if Id.IsEmpty then
    Exit;

  for var Existing in OutputFileIds do
    if SameText(Existing, Id) then
      Exit;

  OutputFileIds := OutputFileIds + [Id];
end;

procedure TStateBuffer.AddStreamedText(const Value: string);
begin
  TextBuffer := TextBuffer + Value;
end;

procedure TStateBuffer.AddStreamedThinking(const Value: string);
begin
  ThinkingBuffer := ThinkingBuffer + Value;
end;

class function TStateBuffer.FromState(const AState: TInputPromptState): TStateBuffer;
begin
  Result := Default(TStateBuffer);
  if AState = nil then
    Exit;

  Result.Error := False;
  Result.ErrorMessage := '';

  Result.Source := AState.Source;
  Result.Text := AState.Text;
  Result.Endpoint := AState.Endpoint;
  Result.Thinking := AState.Thinking;
  Result.DeepResearch := AState.DeepResearch;
  Result.WebSearch := AState.WebSearch;
  Result.Project := TProjectData.FromClass(AState.Project);

  Result.Files := TMediaItemData.FromArray(AState.Files);
  Result.Images := TMediaItemData.FromArray(AState.Images);
  Result.KnowledgeSearch := TMediaItemData.FromArray(AState.KnowledgeSearch);

  Result.Integration := TIntegrationData.FromClass(AState.Integration);
  Result.Custom := TListItemData.FromArray(AState.Custom);
  Result.Media := TMediaData.FromClass(AState.Media);
  Result.Models := TModelsData.FromClass(AState.Models);
  Result.CoreParamsState := TCoreParamsData.FromCore(AState.RequestParams);

  Result.JsonRequest := AState.JsonRequest;
  Result.JsonResponse := AState.JsonResponse;
end;

class operator TStateBuffer.Implicit(const AState: TInputPromptState): TStateBuffer;
begin
  Result := FromState(AState);
end;

end.
