unit Demo.OpenAI.Helpers;

interface

uses
  System.SysUtils, System.StrUtils, System.IOUtils, System.JSON,
  WVPythia.Vendors.Services, WVPythia.JSON.SafeReader,
  WVPythia.JSON.SafeWriter,
  GenAI, GenAI.Types, GenAI.Helpers;

type
  TSkillItem = record
  public
    Id: string;
    Name: string;
    Version: string;
    class function Empty: TSkillItem; static; inline;
  end;

  TCustomSkill = record
  public
    ID: string;
    Name: string;
    class function Empty: TCustomSkill; static; inline;
  end;

  TSkillHelper = record
    class function ExtractCustomSkills(
      const SkillsJsonAsString: string): TArray<TCustomSkill>; static;

    class function TryToUpdateID(
      const SkillJsonAsString: string;
      const AName: string;
      const NewId: string;
      const ParamProc: TProc<string>): Boolean; static;
  end;

  TJSONArrayHelper = record
    class function ArrayOfStringToJSonArrayAsString(
      const Value: TArray<string>): string; static;
  end;

  TArrayUtils = record
    class function Merge(
      const T1, T2: TArray<string>): TArray<string>; static;
    class function ArrayRemoveDuplicates(
      const Value: TArray<string>): TArray<string>; static;
  end;

  TParamsGetter = record
    class function GetSkills(
      const AState: TStateBuffer): TArray<TSkillItem>; static;

    class function GetShellContainerFileIds(
      const AState: TStateBuffer): TArray<string>; static;

    class function GetMCPNames(
      const AState: TStateBuffer): TArray<string>; static;

    class function TryReadMCPCard(
      const Reader: TJsonReader;
      const X: string;
      out Content, Pat: string): Boolean; static;

    class function CheckFilename(
      const Filename, Folder: string): string; static;
  end;

  TStateChecking = record
    class function HasThinking(
      const AState: TStateBuffer): Boolean; static;

    class function HasEffort(
      const Effort: string): Boolean; static;

    class function HasTopP(
      const AState: TStateBuffer): Boolean; static;

    class function SupportsSamplingControls(
      const AState: TStateBuffer): Boolean; static;

    class function SummarizedThinking(
      const AState: TStateBuffer): Boolean; static;

    class function HasMCP(
      const AState: TStateBuffer): Boolean; static;

    class function HasSkills(
      const AState: TStateBuffer): Boolean; static;

    class function IsArchiveFile(
      const AFullPath: string): Boolean; static;

    class function HasAPIFileUsed(
      const AState: TStateBuffer): Boolean; static;

    class function HasStructuredOutput(
      const AState: TStateBuffer): Boolean; static;

    class function UsesPreviousResponseId(
      const AState: TStateBuffer): Boolean; static;
  end;

  TMessageContentBuilder = record
  private
    class procedure AppendImageBlock(
      const AFullPath: string;
      var ABlocks: TArray<TItemContent>); static;

    class procedure AppendDocumentBlock(
      const AFullPath: string;
      const AFileId: string;
      var ABlocks: TArray<TItemContent>); static;

    class procedure AppendTextBlock(
      const AText: string;
      var ABlocks: TArray<TItemContent>); static;
  public
    class function BuildContentBlocks(
      const AState: TStateBuffer): TArray<TItemContent>; static;
  end;

  TThinkingBuilder = record
  public
    class function TryGetOutputConfig(
      const AState: TStateBuffer;
      out Effort: string;
      const ParamProc: TProc): Boolean; static;

    class function TryGetThinkingConfigParam(
      const AState: TStateBuffer;
      const Effort: string;
      const ParamProc: TProc): Boolean; static;

    class function GetTReasoningConfig(
      const AState: TStateBuffer;
      const Effort: string): TReasoningParams; static;
  end;

  TStructuredOutputBuilder = record
  public
    class function TryGetTextConfigParam(
      const AState: TStateBuffer;
      const ParamProc: TProc): Boolean; static;

    class function GetTTextConfig(
      const AState: TStateBuffer): TTextJSONSchemaParams; static;
  end;

  TToolsBuilder = record
    class function TryToBuild(
      const AState: TStateBuffer;
      const ParamProc: TProc): Boolean; static;
  end;

  TRequestSettingsBuilder = record
  public
    class procedure ApplyMaxTokens(
      const AState: TStateBuffer;
      const ParamProc: TProc<Integer>;
      const ADefaultValue: Integer = 0); static;

    class function TryApplySystemPrompt(
      const AState: TStateBuffer;
      const ParamProc: TProc<string>): Boolean; static;

    class function TryApplyTemperature(
      const AState: TStateBuffer;
      const ParamProc: TProc<Double>): Boolean; static;

    class function TryApplyTopP(
      const AState: TStateBuffer;
      const ParamProc: TProc<Double>): Boolean; static;

    class procedure ApplyVendorSettings(
      const AState: TStateBuffer;
      const Params: TResponsesParams); static;

    class procedure Apply(
      const AState: TStateBuffer;
      const Params: TResponsesParams;
      const ADefaultMaxTokens: Integer = 0); static;
  end;

implementation

{$REGION 'Dev note'}
(*

  Shared OpenAI request helpers for the pythia-openai FMX demo.

  This unit is the adapter layer between the generic Pythia state buffer and
  OpenAI Responses parameter objects. It deliberately mirrors the vocabulary
  of Demo.Anthropic.Helpers where the two APIs expose the same responsibility,
  while keeping OpenAI-only mechanics explicit:
    - prompt attachments become Responses input_* content items;
    - reasoning.effort is independent from structured text output;
    - system prompts become Responses instructions;
    - vendor settings map to Responses background, parallel_tool_calls and
      store fields.

  The helpers intentionally stay stateless. Conversation reconstruction,
  previous_response_id lookup, MCP/skill tool construction and long-running
  workflow ownership belong in Demo.OpenAI.Context or Demo.OpenAI.Services.

*)
{$ENDREGION}

uses
  System.Generics.Collections, System.Generics.Defaults;

{ TSkillItem }

class function TSkillItem.Empty: TSkillItem;
begin
  Result := Default(TSkillItem);
end;

{ TCustomSkill }

class function TCustomSkill.Empty: TCustomSkill;
begin
  Result := Default(TCustomSkill);
end;

{ TSkillHelper }

class function TSkillHelper.ExtractCustomSkills(
  const SkillsJsonAsString: string): TArray<TCustomSkill>;
begin
  SetLength(Result, 0);

  var Reader := TJsonReader.Parse(SkillsJsonAsString);
  if not Reader.IsValid then
    Exit;

  var Count := Reader.Count('cards');

  for var index := 0 to Count - 1 do
    begin
      var Path := Format('cards[%d]', [index]);

      if not SameText(Reader.AsString(Path + '.content'), 'custom') then
        Continue;

      var ID := Reader.AsString(Path + '.id');
      var Name := Reader.AsString(Path + '.name');

      if ID.IsEmpty or Name.IsEmpty then
        Continue;

      var SkillIndex := Length(Result);
      SetLength(Result, SkillIndex + 1);

      Result[SkillIndex].ID := ID;
      Result[SkillIndex].Name := Name;
    end;
end;

class function TSkillHelper.TryToUpdateID(
  const SkillJsonAsString, AName, NewId: string;
  const ParamProc: TProc<string>): Boolean;
var
  Writer: TJsonWriter;
begin
  Result := False;

  if AName.IsEmpty or NewId.IsEmpty then
    Exit;

  var Reader := TJsonReader.Parse(SkillJsonAsString);
  if not Reader.IsValid then
    Exit;

  var CardCount := Reader.Count('cards');

  for var index := 0 to CardCount - 1 do
    begin
      var CardPath := Format('cards[%d]', [index]);

      if not SameText(Reader.AsString(CardPath + '.content'), 'custom') then
        Continue;

      if not SameText(Reader.AsString(CardPath + '.name'), AName) then
        Continue;

      Writer := TJsonWriter.Parse(SkillJsonAsString);

      Result := Writer.SetString(CardPath + '.id', NewId);
      Break;
    end;

  if Result and Assigned(ParamProc) then
    ParamProc(Writer.Format());
end;

{ TMessageContentBuilder }

class procedure TMessageContentBuilder.AppendImageBlock(
  const AFullPath: string;
  var ABlocks: TArray<TItemContent>);
begin
  ABlocks := ABlocks + [
    Generation.Content.Image(AFullPath)
  ];
end;

class procedure TMessageContentBuilder.AppendDocumentBlock(
  const AFullPath, AFileId: string;
  var ABlocks: TArray<TItemContent>);
begin
  if not AFileId.Trim.IsEmpty then
    begin
      ABlocks := ABlocks + [
        TItemContent.NewFile.FileId(AFileId)
      ];
      Exit;
    end;

  ABlocks := ABlocks + [
    Generation.Content.&File(AFullPath)
  ];
end;

class procedure TMessageContentBuilder.AppendTextBlock(
  const AText: string;
  var ABlocks: TArray<TItemContent>);
begin
  ABlocks := ABlocks + [
    Generation.Content.Text(AText)
  ];
end;

class function TMessageContentBuilder.BuildContentBlocks(
  const AState: TStateBuffer): TArray<TItemContent>;
begin
  Result := [];

  for var Item in AState.Images do
    AppendImageBlock(Item.FullPath, Result);

  var ShellOnlyFileNames := '';
  for var Item in AState.Files do
    begin
      if TStateChecking.HasSkills(AState) and
         TStateChecking.IsArchiveFile(Item.FullPath) and
         not Item.FileId.Trim.IsEmpty then
        begin
          if ShellOnlyFileNames.IsEmpty then
            ShellOnlyFileNames := TPath.GetFileName(Item.FullPath)
          else
            ShellOnlyFileNames := ShellOnlyFileNames + ', ' + TPath.GetFileName(Item.FullPath);
          Continue;
        end;

      AppendDocumentBlock(Item.FullPath, Item.FileId, Result);
    end;

  {--- KnowledgeSearch files are intentionally not appended as prompt files.
       They belong to the file-search/vector-store workflow. }

  if not ShellOnlyFileNames.IsEmpty then
    AppendTextBlock(
      'Attached archive file(s) available in the shell container: ' +
      ShellOnlyFileNames,
      Result);

  AppendTextBlock(AState.Text, Result);
end;

{ TThinkingBuilder }

class function TThinkingBuilder.GetTReasoningConfig(
  const AState: TStateBuffer;
  const Effort: string): TReasoningParams;
begin
  Result := nil;

  if not TStateChecking.HasEffort(Effort) then
    Exit;

  Result := TReasoningParams.New
    .Effort(Effort);

  if TStateChecking.SummarizedThinking(AState) then
    Result.Summary('detailed')
  else
    Result.Summary('auto')
end;

class function TThinkingBuilder.TryGetOutputConfig(
  const AState: TStateBuffer;
  out Effort: string;
  const ParamProc: TProc): Boolean;
begin
  Effort := AState.Thinking;
  Result := TStateChecking.HasEffort(Effort);

  if Result and Assigned(ParamProc) then
    ParamProc();
end;

class function TThinkingBuilder.TryGetThinkingConfigParam(
  const AState: TStateBuffer;
  const Effort: string;
  const ParamProc: TProc): Boolean;
begin
  Result := TStateChecking.HasEffort(Effort);

  if Result and Assigned(ParamProc) then
    ParamProc();
end;

{ TStructuredOutputBuilder }

class function TStructuredOutputBuilder.GetTTextConfig(
  const AState: TStateBuffer): TTextJSONSchemaParams;
begin
  Result := nil;

  if not TStateChecking.HasStructuredOutput(AState) then
    Exit;

  Result := TTextJSONSchemaParams.New
    .Name('pythia_response')
    .Schema(AState.CoreParamsState.StructuredOutput.Value)
    .Strict(True);
end;

class function TStructuredOutputBuilder.TryGetTextConfigParam(
  const AState: TStateBuffer;
  const ParamProc: TProc): Boolean;
begin
  Result := TStateChecking.HasStructuredOutput(AState);

  if Result and Assigned(ParamProc) then
    ParamProc();
end;

{ TToolsBuilder }

class function TToolsBuilder.TryToBuild(
  const AState: TStateBuffer;
  const ParamProc: TProc): Boolean;
begin
  Result :=
    AState.WebSearch or
    TStateChecking.HasMCP(AState) or
    TStateChecking.HasSkills(AState) or
    (Length(AState.KnowledgeSearch) > 0);

  if Result and Assigned(ParamProc) then
    ParamProc();
end;

{ TRequestSettingsBuilder }

class procedure TRequestSettingsBuilder.Apply(
  const AState: TStateBuffer;
  const Params: TResponsesParams;
  const ADefaultMaxTokens: Integer);
begin
  ApplyMaxTokens(AState,
    procedure(Value: Integer)
    begin
      Params.MaxOutputTokens(Value);
    end,
    ADefaultMaxTokens);

  TryApplySystemPrompt(AState,
    procedure(Value: string)
    begin
      Params.Instructions(Value);
    end);

  TryApplyTemperature(AState,
    procedure(Value: Double)
    begin
      Params.Temperature(Value);
    end);

  TryApplyTopP(AState,
    procedure(Value: Double)
    begin
      Params.TopP(Value);
    end);

  ApplyVendorSettings(AState, Params);
end;

class procedure TRequestSettingsBuilder.ApplyMaxTokens(
  const AState: TStateBuffer;
  const ParamProc: TProc<Integer>;
  const ADefaultValue: Integer);
var
  Value: Integer;
begin
  if AState.CoreParamsState.Settings.MaxToken.Enabled then
    Value := AState.CoreParamsState.Settings.MaxToken.Value
  else
    begin
      {--- max_output_tokens is optional for Responses. Do not impose the
           Anthropic demo's 1000-token fallback: reasoning tokens also consume
           this budget and can leave no room for the assistant answer. }
      if ADefaultValue <= 0 then
        Exit;
      Value := ADefaultValue;
    end;

  if Assigned(ParamProc) then
    ParamProc(Value);
end;

class procedure TRequestSettingsBuilder.ApplyVendorSettings(
  const AState: TStateBuffer;
  const Params: TResponsesParams);
begin
  var VendorSettings := AState.CoreParamsState.VendorSettings;
  var Store := VendorSettings.Store or VendorSettings.UsingPreviousId;

  Params
    .ParallelToolCalls(VendorSettings.ParallelToolCalls)
    .Background(VendorSettings.BackgroundResponse)
    .Store(Store);
end;

class function TRequestSettingsBuilder.TryApplySystemPrompt(
  const AState: TStateBuffer;
  const ParamProc: TProc<string>): Boolean;
begin
  var SystemPrompt := AState.CoreParamsState.SystemPrompt;

  Result := SystemPrompt.Enabled and not SystemPrompt.Value.Trim.IsEmpty;

  if Result and Assigned(ParamProc) then
    ParamProc(SystemPrompt.Value);
end;

class function TRequestSettingsBuilder.TryApplyTemperature(
  const AState: TStateBuffer;
  const ParamProc: TProc<Double>): Boolean;
begin
  if not TStateChecking.SupportsSamplingControls(AState) then
    Exit(False);

  if TStateChecking.HasTopP(AState) then
    Exit(False);

  var Temperature := AState.CoreParamsState.Settings.Temperature;

  Result := Temperature.Enabled;
  if Result and Assigned(ParamProc) then
    ParamProc(Temperature.Value);
end;

class function TRequestSettingsBuilder.TryApplyTopP(
  const AState: TStateBuffer;
  const ParamProc: TProc<Double>): Boolean;
begin
  if not TStateChecking.SupportsSamplingControls(AState) then
    Exit(False);

  var TopP := AState.CoreParamsState.Sampling.TopP;

  Result := TopP.Enabled;
  if Result and Assigned(ParamProc) then
    ParamProc(TopP.Value);
end;

{ TStateChecking }

class function TStateChecking.HasAPIFileUsed(
  const AState: TStateBuffer): Boolean;
begin
  for var Item in AState.Files do
    if not Item.FileId.IsEmpty then
      Exit(True);

  Result := False;
end;

class function TStateChecking.HasEffort(const Effort: string): Boolean;
begin
  {--- Unlike Anthropic thinking, Responses reasoning.effort accepts "none".
       Keep it in the payload so models whose default effort is higher do not
       silently reason when the user explicitly disabled that behavior. }
  Result := not Effort.Trim.IsEmpty;
end;

class function TStateChecking.HasMCP(
  const AState: TStateBuffer): Boolean;
begin
  Result := Length(AState.Integration.Mcp) > 0;
end;

class function TStateChecking.HasSkills(
  const AState: TStateBuffer): Boolean;
begin
  Result := Length(AState.Integration.Skills) > 0;
end;

class function TStateChecking.IsArchiveFile(
  const AFullPath: string): Boolean;
begin
  var Ext := TPath.GetExtension(AFullPath).ToLowerInvariant;

  Result :=
    (Ext = '.zip') or
    (Ext = '.tar') or
    (Ext = '.tgz') or
    (Ext = '.gz');
end;

class function TStateChecking.HasStructuredOutput(
  const AState: TStateBuffer): Boolean;
begin
  var StructuredOutput := AState.CoreParamsState.StructuredOutput;

  Result := StructuredOutput.Enabled
    and not StructuredOutput.Value.Trim.IsEmpty;
end;

class function TStateChecking.HasThinking(
  const AState: TStateBuffer): Boolean;
begin
  Result := HasEffort(AState.Thinking)
    and not SameText(AState.Thinking, 'none');
end;

class function TStateChecking.HasTopP(
  const AState: TStateBuffer): Boolean;
begin
  Result := AState.CoreParamsState.Sampling.TopP.Enabled;
end;

class function TStateChecking.SupportsSamplingControls(
  const AState: TStateBuffer): Boolean;
begin
  {--- GPT-5 reasoning requests reject sampling controls. GPT-5.5 also uses a
       medium reasoning baseline, so omit these fields for every GPT-5.5
       request, including the explicit "none" mode. }
  Result :=
    not StartsText('gpt-5.5', AState.Model) and
    not HasThinking(AState);
end;

class function TStateChecking.SummarizedThinking(
  const AState: TStateBuffer): Boolean;
begin
  Result := False;

  if not HasThinking(AState) or not StartsText('gpt-5', AState.Model) then
    Exit;

  {--- Request a visible reasoning summary only when the matching custom card
       is active in the current prompt. }
  for var Item in AState.Custom do
    if SameText(Item.Name, 'summarized') then
      Exit(True);
end;

class function TStateChecking.UsesPreviousResponseId(
  const AState: TStateBuffer): Boolean;
begin
  Result := AState.CoreParamsState.VendorSettings.UsingPreviousId;
end;

{ TParamsGetter }

class function TParamsGetter.CheckFilename(
  const Filename, Folder: string): string;
begin
  var Candidate := TPath.GetFileName(Filename);
  var BaseName := TPath.GetFileNameWithoutExtension(Candidate);
  var Ext := TPath.GetExtension(Candidate);
  var Index := 1;

  while Length(TDirectory.GetFiles(Folder, Candidate)) > 0 do
    begin
      Candidate := Format('%s (%d)%s', [BaseName, Index, Ext]);
      Inc(Index);
    end;

  Result := TPath.Combine(Folder, Candidate);
end;

class function TParamsGetter.GetMCPNames(
  const AState: TStateBuffer): TArray<string>;
begin
  SetLength(Result, Length(AState.Integration.Mcp));
  for var index := Low(AState.Integration.Mcp) to High(AState.Integration.Mcp) do
    Result[index] := AState.Integration.Mcp[index].Name;
end;

class function TParamsGetter.GetSkills(
  const AState: TStateBuffer): TArray<TSkillItem>;
begin
  SetLength(Result, Length(AState.Integration.Skills));

  var Index := 0;
  for var Item in AState.Integration.Skills do
    begin
      Result[Index] := TSkillItem.Empty;
      Result[Index].Id := Item.Id;
      Result[Index].Name := Item.Name;
      Result[Index].Version := 'latest';
      Inc(Index);
    end;
end;

class function TParamsGetter.GetShellContainerFileIds(
  const AState: TStateBuffer): TArray<string>;
begin
  Result := [];

  for var Item in AState.Files do
    begin
      var FileId := Item.FileId.Trim;

      if FileId.IsEmpty then
        Continue;

      if not TStateChecking.IsArchiveFile(Item.FullPath) then
        Continue;

      Result := Result + [FileId];
    end;

  Result := TArrayUtils.ArrayRemoveDuplicates(Result);
end;

class function TParamsGetter.TryReadMCPCard(
  const Reader: TJsonReader;
  const X: string;
  out Content, Pat: string): Boolean;
begin
  Content := '';
  Pat := '';

  for var index := 0 to Reader.Count('cards') - 1 do
    begin
      var CardPath := 'cards[' + index.ToString + ']';

      if SameText(X, Reader.AsString(CardPath + '.id')) or
         SameText(X, Reader.AsString(CardPath + '.name')) then
        begin
          Content := Reader.AsString(CardPath + '.content');
          Pat := Reader.AsString(CardPath + '.pat');
          Exit(True);
        end;
    end;

  Result := False;
end;

{ TJSONArrayHelper }

class function TJSONArrayHelper.ArrayOfStringToJSonArrayAsString(
  const Value: TArray<string>): string;
begin
  var Writer := TJsonWriter.NewArray;
  for var Item in Value do
    if not Writer.AppendJson('', Item) then
      raise Exception.CreateFmt('Invalid JSON array item:#10%s', [Item]);

  Result := Writer.ToJson;
end;

{ TArrayUtils }

class function TArrayUtils.ArrayRemoveDuplicates(
  const Value: TArray<string>): TArray<string>;
begin
  var List := TList<string>.Create(TIStringComparer.Ordinal);
  try
    for var Item in Value do
      if not List.Contains(Item) then
        List.Add(Item);

    Result := List.ToArray;
  finally
    List.Free;
  end;
end;

class function TArrayUtils.Merge(
  const T1, T2: TArray<string>): TArray<string>;
begin
  Result := Copy(T1);
  var Count := Length(Result);

  for var Item2 in T2 do
    begin
      var Found := False;

      for var Item1 in T1 do
        if SameText(Item1, Item2) then
          begin
            Found := True;
            Break;
          end;

      if Found then
        Continue;

      SetLength(Result, Count + 1);
      Result[Count] := Item2;
      Inc(Count);
    end;
end;

end.
