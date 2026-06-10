unit Demo.OpenAI.DisplayBlocks;

interface

{$REGION 'Dev note'}
(*

  OpenAI display block adapter for the pythia-openai FMX demo.

  Pythia persists and renders conversation output through vendor-neutral display
  blocks. This unit keeps the OpenAI-specific stream vocabulary out of the
  generic Pythia aggregator by translating OpenAI response snapshots into:
    - stable tool titles;
    - tool status/result lifecycle updates;
    - compact human-readable details for hosted and MCP tool activity.

  TOpenAIDisplayBlockAggregator is intentionally a thin adapter over
  TPythiaDisplayBlockAggregator. It only consumes OpenAI stream snapshots and
  delegates the durable block model to the shared Pythia implementation.

  Tool details are built from two sources:
    - typed SDK output items when the final response object is available;
    - raw output_item.done JSON when streaming exposes richer tool payloads
      before the typed response has been materialized.

  The text builders deliberately emit display-oriented summaries rather than
  replay payloads. File search results, web search actions and MCP tool lists
  are trimmed and normalized for the chat UI, while the original OpenAI JSON
  remains owned by the service/context layers.

  Tool names belong to block titles. Detail text should not repeat titles such
  as "File search", otherwise the live stream and the persisted session reload
  display duplicate labels.

*)
{$ENDREGION}

uses
  System.SysUtils, System.JSON,
  GenAI, GenAI.Types,
  WVPythia.Chat.DisplayBlocks, WVPythia.JSON.SafeReader;

type
  /// <summary>
  /// OpenAI adapter over the vendor-neutral Pythia display block
  /// aggregator. Only the methods that consume OpenAI stream snapshots
  /// stay here.
  /// </summary>
  IOpenAIDisplayBlockAggregator = interface(IPythiaDisplayBlockAggregator)
    ['{4FD13E85-8D8E-4E0C-9A17-D6F9197FB35D}']
    procedure RegisterToolUseStop(const Snapshot: TToolCallSnapshot;
      const DisplayTitle: string);
    procedure RegisterToolResultStop(const Snapshot: TToolResultSnapshot);
  end;

  TOpenAIDisplayBlockAggregator = class(
    TPythiaDisplayBlockAggregator, IOpenAIDisplayBlockAggregator)
  public
    procedure RegisterToolUseStop(const Snapshot: TToolCallSnapshot;
      const DisplayTitle: string);
    procedure RegisterToolResultStop(const Snapshot: TToolResultSnapshot);
  end;

  TToolDisplayTitle = record
  public
    class function FromToolCall(const Snapshot: TToolCallSnapshot): string; static;
    class function FromToolResultKind(const Value: TToolResultKind): string; static;
  end;

  TToolDisplayDetail = record
  public
    class function FromOutputItem(
      const Item: TResponseOutput;
      out ToolUseId: string): string; static;
    class function FromOutputItemDoneJson(
      const Json: string;
      out ToolUseId: string): string; static;
  end;

implementation

type
  TFileSearchDisplayResult = record
    FileId: string;
    Filename: string;
    Score: Double;
    Text: string;
    Attributes: string;
  end;

  TToolDisplayTextBuilder = record
  public
    class procedure AppendLine(
      var Text: string;
      const Line: string); static;

    class procedure AppendStringArray(
      var Text: string;
      const Title: string;
      const Values: TArray<string>); static;

    class function TrimForDisplay(
      const Value: string;
      const MaxLength: Integer = 500): string; static;

    class function NormalizeActionType(
      const Value: string): string; static;
  end;

  TTypedToolDisplayDetailBuilder = record
  private
    class procedure AppendWebSources(
      var Text: string;
      const Sources: TArray<TSearchActionSource>); static;

    class procedure AppendFileSearchResults(
      var Text: string;
      const Results: TArray<TFileSearchResult>); static;

  public
    class procedure AppendFileSearch(
      var Text: string;
      const Queries: TArray<string>;
      const Results: TArray<TFileSearchResult>); static;

    class procedure AppendMcpTools(
      var Text: string;
      const Tools: TArray<TMCPListTool>); static;

    class procedure AppendWebAction(
      var Text: string;
      const Action: TAction); static;

    class procedure AppendShellCall(
      var Text: string;
      const Action: TResponseShellAction); static;

    class procedure AppendShellOutput(
      var Text: string;
      const Outputs: TArray<TResponseShellOutput>); static;
  end;

  TJsonToolDisplayDetailBuilder = record
  private
    class procedure AppendStringArray(
      var Text: string;
      const Title: string;
      const Reader: TJsonReader;
      const Path: string); static;

    class procedure AppendWebSources(
      var Text: string;
      const Reader: TJsonReader;
      const Path: string); static;

    class function ReadFileSearchResult(
      const Reader: TJsonReader;
      const Path: string): TFileSearchDisplayResult; static;

    class procedure AppendFileSearchResults(
      var Text: string;
      const Reader: TJsonReader;
      const Path: string); static;

  public
    class procedure AppendFileSearch(
      var Text: string;
      const Reader: TJsonReader;
      const ItemPath: string); static;

    class procedure AppendMcpTools(
      var Text: string;
      const Reader: TJsonReader;
      const Path: string); static;

    class procedure AppendWebAction(
      var Text: string;
      const Reader: TJsonReader;
      const Path: string); static;

    class procedure AppendShellCall(
      var Text: string;
      const Reader: TJsonReader;
      const Path: string); static;

    class procedure AppendShellOutput(
      var Text: string;
      const Reader: TJsonReader;
      const Path: string); static;
  end;

{ TToolDisplayTextBuilder }

class procedure TToolDisplayTextBuilder.AppendLine(
  var Text: string;
  const Line: string);
begin
  if Line.Trim.IsEmpty then
    Exit;

  if not Text.IsEmpty then
    Text := Text + sLineBreak;

  Text := Text + Line;
end;

class procedure TToolDisplayTextBuilder.AppendStringArray(
  var Text: string;
  const Title: string;
  const Values: TArray<string>);
begin
  if Length(Values) = 0 then
    Exit;

  TToolDisplayTextBuilder.AppendLine(Text, Title + ':');
  for var Value in Values do
    TToolDisplayTextBuilder.AppendLine(Text, '- ' + Value);
end;

class function TToolDisplayTextBuilder.TrimForDisplay(
  const Value: string;
  const MaxLength: Integer): string;
begin
  Result := Value.Trim;
  if (MaxLength <= 0) or (Result.Length <= MaxLength) then
    Exit;

  Result := Result.Substring(0, MaxLength).Trim + '...';
end;

class function TToolDisplayTextBuilder.NormalizeActionType(
  const Value: string): string;
begin
  Result := Value.Trim;
  if SameText(Result, 'open_page') then
    Result := 'open page'
  else
  if SameText(Result, 'find_in_page') then
    Result := 'find in page';
end;

{ TTypedToolDisplayDetailBuilder }

class procedure TTypedToolDisplayDetailBuilder.AppendWebSources(
  var Text: string;
  const Sources: TArray<TSearchActionSource>);
begin
  if Length(Sources) = 0 then
    Exit;

  TToolDisplayTextBuilder.AppendLine(Text, 'Sources:');
  for var Source in Sources do
    if Assigned(Source) and not Source.Url.Trim.IsEmpty then
      TToolDisplayTextBuilder.AppendLine(Text, '- ' + Source.Url.Trim);
end;

class procedure TTypedToolDisplayDetailBuilder.AppendFileSearch(
  var Text: string;
  const Queries: TArray<string>;
  const Results: TArray<TFileSearchResult>);
begin
  TToolDisplayTextBuilder.AppendStringArray(Text, 'Queries', Queries);
  TTypedToolDisplayDetailBuilder.AppendFileSearchResults(Text, Results);
end;

class procedure TTypedToolDisplayDetailBuilder.AppendFileSearchResults(
  var Text: string;
  const Results: TArray<TFileSearchResult>);
begin
  if Length(Results) = 0 then
    begin
      TToolDisplayTextBuilder.AppendLine(Text, 'No file search results.');
      Exit;
    end;

  TToolDisplayTextBuilder.AppendLine(
    Text,
    Format('Results: %d', [Length(Results)]));

  for var index := 0 to High(Results) do
    begin
      var Item := Results[index];
      if not Assigned(Item) then
        Continue;

      var Header := Format('- Result %d', [index + 1]);
      if not Item.Filename.Trim.IsEmpty then
        Header := Header + ': ' + Item.Filename.Trim;

      TToolDisplayTextBuilder.AppendLine(Text, Header);

      if not Item.FileId.Trim.IsEmpty then
        TToolDisplayTextBuilder.AppendLine(Text, '  File ID: ' + Item.FileId.Trim);

      TToolDisplayTextBuilder.AppendLine(
        Text,
        Format('  Score: %.4f', [Item.Score]));

      var RetrievedText := TToolDisplayTextBuilder.TrimForDisplay(Item.Text);
      if not RetrievedText.IsEmpty then
        TToolDisplayTextBuilder.AppendLine(Text, '  Text: ' + RetrievedText);

      if not Item.Attributes.Trim.IsEmpty then
        TToolDisplayTextBuilder.AppendLine(
          Text,
          '  Attributes: ' + Item.Attributes.Trim);
    end;
end;

class procedure TTypedToolDisplayDetailBuilder.AppendMcpTools(
  var Text: string;
  const Tools: TArray<TMCPListTool>);
begin
  if Length(Tools) = 0 then
    begin
      TToolDisplayTextBuilder.AppendLine(Text, 'No MCP tools discovered.');
      Exit;
    end;

  TToolDisplayTextBuilder.AppendLine(
    Text,
    Format('Discovered MCP tools: %d', [Length(Tools)]));

  for var Tool in Tools do
    begin
      if not Assigned(Tool) then
        Continue;

      if not Tool.Name.Trim.IsEmpty then
        TToolDisplayTextBuilder.AppendLine(Text, '- ' + Tool.Name.Trim);

      if not Tool.Description.Trim.IsEmpty then
        TToolDisplayTextBuilder.AppendLine(
          Text,
          '  ' + Tool.Description.Trim);
    end;
end;

class procedure TTypedToolDisplayDetailBuilder.AppendWebAction(
  var Text: string;
  const Action: TAction);
begin
  if not Assigned(Action) then
    Exit;

  var ActionType :=
    TToolDisplayTextBuilder.NormalizeActionType(Action.&Type);

  if not ActionType.IsEmpty then
    TToolDisplayTextBuilder.AppendLine(Text, 'Action: ' + ActionType);

  if not Action.Query.Trim.IsEmpty then
    TToolDisplayTextBuilder.AppendLine(Text, 'Query: ' + Action.Query.Trim);

  if not Action.Url.Trim.IsEmpty then
    TToolDisplayTextBuilder.AppendLine(Text, 'URL: ' + Action.Url.Trim);

  if not Action.Pattern.Trim.IsEmpty then
    TToolDisplayTextBuilder.AppendLine(Text, 'Pattern: ' + Action.Pattern.Trim);

  TTypedToolDisplayDetailBuilder.AppendWebSources(Text, Action.Sources);
end;

class procedure TTypedToolDisplayDetailBuilder.AppendShellCall(
  var Text: string;
  const Action: TResponseShellAction);
begin
  if not Assigned(Action) then
    Exit;

  TToolDisplayTextBuilder.AppendStringArray(Text, 'Commands', Action.Commands);
end;

class procedure TTypedToolDisplayDetailBuilder.AppendShellOutput(
  var Text: string;
  const Outputs: TArray<TResponseShellOutput>);
begin
  for var Item in Outputs do
    begin
      if not Assigned(Item) then
        Continue;

      if Assigned(Item.Outcome) then
        begin
          var Outcome := Item.Outcome.&Type.Trim;
          if not Outcome.IsEmpty and (Item.Outcome.ExitCode <> 0) then
            Outcome := Format('%s (%d)', [Outcome, Item.Outcome.ExitCode]);
          TToolDisplayTextBuilder.AppendLine(Text, 'Outcome: ' + Outcome);
        end;

      if not Item.Stdout.Trim.IsEmpty then
        TToolDisplayTextBuilder.AppendLine(
          Text,
          'stdout: ' + TToolDisplayTextBuilder.TrimForDisplay(Item.Stdout));

      if not Item.Stderr.Trim.IsEmpty then
        TToolDisplayTextBuilder.AppendLine(
          Text,
          'stderr: ' + TToolDisplayTextBuilder.TrimForDisplay(Item.Stderr));
    end;
end;

{ TJsonToolDisplayDetailBuilder }

class procedure TJsonToolDisplayDetailBuilder.AppendStringArray(
  var Text: string;
  const Title: string;
  const Reader: TJsonReader;
  const Path: string);
begin
  TToolDisplayTextBuilder.AppendStringArray(
    Text,
    Title,
    Reader.ArrayStrings(Path));
end;

class procedure TJsonToolDisplayDetailBuilder.AppendWebSources(
  var Text: string;
  const Reader: TJsonReader;
  const Path: string);
begin
  TToolDisplayTextBuilder.AppendStringArray(
    Text,
    'Sources',
    Reader.ArrayFieldStrings(Path, 'url'));
end;

class procedure TJsonToolDisplayDetailBuilder.AppendFileSearch(
  var Text: string;
  const Reader: TJsonReader;
  const ItemPath: string);
begin
  TJsonToolDisplayDetailBuilder.AppendStringArray(
    Text,
    'Queries',
    Reader,
    ItemPath + '.queries');

  TJsonToolDisplayDetailBuilder.AppendFileSearchResults(
    Text,
    Reader,
    ItemPath + '.results');
end;

class procedure TJsonToolDisplayDetailBuilder.AppendFileSearchResults(
  var Text: string;
  const Reader: TJsonReader;
  const Path: string);
begin
  var Count := Reader.Count(Path);
  if Count = 0 then
    begin
      TToolDisplayTextBuilder.AppendLine(Text, 'No file search results.');
      Exit;
    end;

  TToolDisplayTextBuilder.AppendLine(
    Text,
    Format('Results: %d', [Count]));

  for var index := 0 to Count - 1 do
    begin
      var Item := ReadFileSearchResult(
        Reader,
        Format('%s[%d]', [Path, index]));

      var Header := Format('- Result %d', [index + 1]);
      if not Item.Filename.Trim.IsEmpty then
        Header := Header + ': ' + Item.Filename.Trim;

      TToolDisplayTextBuilder.AppendLine(Text, Header);

      if not Item.FileId.Trim.IsEmpty then
        TToolDisplayTextBuilder.AppendLine(Text, '  File ID: ' + Item.FileId.Trim);

      TToolDisplayTextBuilder.AppendLine(
        Text,
        Format('  Score: %.4f', [Item.Score]));

      var RetrievedText := TToolDisplayTextBuilder.TrimForDisplay(Item.Text);
      if not RetrievedText.IsEmpty then
        TToolDisplayTextBuilder.AppendLine(Text, '  Text: ' + RetrievedText);

      if not Item.Attributes.Trim.IsEmpty then
        TToolDisplayTextBuilder.AppendLine(
          Text,
          '  Attributes: ' + Item.Attributes.Trim);
    end;
end;

class function TJsonToolDisplayDetailBuilder.ReadFileSearchResult(
  const Reader: TJsonReader;
  const Path: string): TFileSearchDisplayResult;
begin
  Result := Default(TFileSearchDisplayResult);
  Result.FileId := Reader.AsString(Path + '.file_id').Trim;
  Result.Filename := Reader.AsString(Path + '.filename').Trim;
  Result.Score := Reader.AsDouble(Path + '.score');
  Result.Text := Reader.AsString(Path + '.text').Trim;
  Result.Attributes := Reader.AsString(Path + '.attributes').Trim;
  if Result.Attributes.IsEmpty and Reader.IsObjectNode(Path + '.attributes') then
    Result.Attributes := Reader.ObjectText(Path + '.attributes').Trim;
end;

class procedure TJsonToolDisplayDetailBuilder.AppendMcpTools(
  var Text: string;
  const Reader: TJsonReader;
  const Path: string);
begin
  var Count := Reader.Count(Path);
  if Count = 0 then
    begin
      TToolDisplayTextBuilder.AppendLine(Text, 'No MCP tools discovered.');
      Exit;
    end;

  TToolDisplayTextBuilder.AppendLine(
    Text,
    Format('Discovered MCP tools: %d', [Count]));

  for var index := 0 to Count - 1 do
    begin
      var Name := Reader.AsString(Format('%s[%d].name', [Path, index]));
      var Description := Reader.AsString(
        Format('%s[%d].description', [Path, index]));

      if not Name.Trim.IsEmpty then
        TToolDisplayTextBuilder.AppendLine(Text, '- ' + Name.Trim);

      if not Description.Trim.IsEmpty then
        TToolDisplayTextBuilder.AppendLine(Text, '  ' + Description.Trim);
    end;
end;

class procedure TJsonToolDisplayDetailBuilder.AppendWebAction(
  var Text: string;
  const Reader: TJsonReader;
  const Path: string);
begin
  var ActionType := TToolDisplayTextBuilder.NormalizeActionType(
    Reader.AsString(Path + '.type'));

  if not ActionType.IsEmpty then
    TToolDisplayTextBuilder.AppendLine(Text, 'Action: ' + ActionType);

  var Query := Reader.AsString(Path + '.query');
  if not Query.Trim.IsEmpty then
    TToolDisplayTextBuilder.AppendLine(Text, 'Query: ' + Query.Trim);

  TJsonToolDisplayDetailBuilder.AppendStringArray(
    Text,
    'Queries',
    Reader,
    Path + '.queries');

  TJsonToolDisplayDetailBuilder.AppendStringArray(
    Text,
    'Domains',
    Reader,
    Path + '.domains');

  var Url := Reader.AsString(Path + '.url');
  if not Url.Trim.IsEmpty then
    TToolDisplayTextBuilder.AppendLine(Text, 'URL: ' + Url.Trim);

  var Pattern := Reader.AsString(Path + '.pattern');
  if not Pattern.Trim.IsEmpty then
    TToolDisplayTextBuilder.AppendLine(Text, 'Pattern: ' + Pattern.Trim);

  TJsonToolDisplayDetailBuilder.AppendWebSources(
    Text,
    Reader,
    Path + '.sources');
end;

class procedure TJsonToolDisplayDetailBuilder.AppendShellCall(
  var Text: string;
  const Reader: TJsonReader;
  const Path: string);
begin
  AppendStringArray(Text, 'Commands', Reader, Path + '.commands');
end;

class procedure TJsonToolDisplayDetailBuilder.AppendShellOutput(
  var Text: string;
  const Reader: TJsonReader;
  const Path: string);
begin
  if Reader.IsStringNode(Path) then
    begin
      var Output := Reader.AsString(Path).Trim;
      if not Output.IsEmpty then
        TToolDisplayTextBuilder.AppendLine(
          Text,
          'output: ' + TToolDisplayTextBuilder.TrimForDisplay(Output));
      Exit;
    end;

  for var I := 0 to Reader.Count(Path) - 1 do
    begin
      var BasePath := Format('%s[%d]', [Path, I]);
      var Outcome := Reader.AsString(BasePath + '.outcome.type').Trim;
      var ExitCode := Reader.AsInteger(BasePath + '.outcome.exit_code');
      if not Outcome.IsEmpty then
        begin
          if ExitCode <> 0 then
            Outcome := Format('%s (%d)', [Outcome, ExitCode]);
          TToolDisplayTextBuilder.AppendLine(Text, 'Outcome: ' + Outcome);
        end;

      var Stdout := Reader.AsString(BasePath + '.stdout').Trim;
      if not Stdout.IsEmpty then
        TToolDisplayTextBuilder.AppendLine(
          Text,
          'stdout: ' + TToolDisplayTextBuilder.TrimForDisplay(Stdout));

      var Stderr := Reader.AsString(BasePath + '.stderr').Trim;
      if not Stderr.IsEmpty then
        TToolDisplayTextBuilder.AppendLine(
          Text,
          'stderr: ' + TToolDisplayTextBuilder.TrimForDisplay(Stderr));
    end;
end;

{ TOpenAIDisplayBlockAggregator }

procedure TOpenAIDisplayBlockAggregator.RegisterToolUseStop(
  const Snapshot: TToolCallSnapshot;
  const DisplayTitle: string);
begin
  var Title := DisplayTitle.Trim;
  if Title.IsEmpty then
    Title := Snapshot.ToolName.Trim;
  if Title.IsEmpty then
    Title := 'Tool call';

  AppendToolUse(Snapshot.ToolId, Title);

  if not Snapshot.InputJson.Trim.IsEmpty then
    AppendToolResultDelta(Snapshot.InputJson.Trim);
end;

procedure TOpenAIDisplayBlockAggregator.RegisterToolResultStop(
  const Snapshot: TToolResultSnapshot);
begin
  if Snapshot.IsError then
    MarkToolError(Snapshot.ToolUseId);

  CloseCurrent;
end;

{ TToolDisplayDetail }

class function TToolDisplayDetail.FromOutputItem(
  const Item: TResponseOutput;
  out ToolUseId: string): string;
begin
  Result := '';
  ToolUseId := '';

  if not Assigned(Item) then
    Exit;

  ToolUseId := Item.Id.Trim;
  if not Item.CallId.Trim.IsEmpty then
    ToolUseId := Item.CallId.Trim;

  case Item.&Type of
    TResponseTypes.file_search_call:
      TTypedToolDisplayDetailBuilder.AppendFileSearch(
        Result,
        Item.Queries,
        Item.Results);

    TResponseTypes.web_search_call:
      TTypedToolDisplayDetailBuilder.AppendWebAction(Result, Item.Action);

    TResponseTypes.mcp_list_tools:
      TTypedToolDisplayDetailBuilder.AppendMcpTools(Result, Item.Tools);

    TResponseTypes.shell_call,
    TResponseTypes.local_shell_call:
      TTypedToolDisplayDetailBuilder.AppendShellCall(Result, Item.ShellAction);

    TResponseTypes.shell_call_output,
    TResponseTypes.local_shell_call_output:
      begin
        if not Item.Output.Trim.IsEmpty then
          TToolDisplayTextBuilder.AppendLine(
            Result,
            'output: ' + TToolDisplayTextBuilder.TrimForDisplay(Item.Output));

        TTypedToolDisplayDetailBuilder.AppendShellOutput(Result, Item.ShellOutput);
      end;
  end;
end;

class function TToolDisplayDetail.FromOutputItemDoneJson(
  const Json: string;
  out ToolUseId: string): string;
begin
  Result := '';
  ToolUseId := '';

  var Reader := TJsonReader.Parse(Json);
  if not Reader.IsValid then
    Exit;

  ToolUseId := Reader.AsString('item.call_id').Trim;
  if ToolUseId.IsEmpty then
    ToolUseId := Reader.AsString('item.id').Trim;

  var ItemType := Reader.AsString('item.type');
  if SameText(ItemType, 'shell_call') or SameText(ItemType, 'local_shell_call') then
    begin
      TJsonToolDisplayDetailBuilder.AppendShellCall(
        Result,
        Reader,
        'item.action');

      Exit;
    end;

  if SameText(ItemType, 'shell_call_output') or SameText(ItemType, 'local_shell_call_output') then
    begin
      TJsonToolDisplayDetailBuilder.AppendShellOutput(
        Result,
        Reader,
        'item.output');

      Exit;
    end;

  if SameText(ItemType, 'file_search_call') then
    begin
      TJsonToolDisplayDetailBuilder.AppendFileSearch(
        Result,
        Reader,
        'item');

      Exit;
    end;

  if SameText(ItemType, 'mcp_list_tools') then
    begin
      TJsonToolDisplayDetailBuilder.AppendMcpTools(
        Result,
        Reader,
        'item.tools');

      Exit;
    end;

  if not SameText(ItemType, 'web_search_call') then
    Exit;

  TJsonToolDisplayDetailBuilder.AppendWebAction(
    Result,
    Reader,
    'item.action');
end;

{ TToolDisplayTitle }

class function TToolDisplayTitle.FromToolCall(
  const Snapshot: TToolCallSnapshot): string;
begin
  Result := Snapshot.ToolName.Trim;
  if not Result.IsEmpty then
    Exit;

  case Snapshot.Kind of
    tcFunction:
      Result := 'Function call';

    tcCustom:
      Result := 'Custom tool';

    tcMcp:
      Result := 'MCP tool';
  else
    Result := 'Tool call';
  end;
end;

class function TToolDisplayTitle.FromToolResultKind(
  const Value: TToolResultKind): string;
begin
  case Value of
    trWebSearch:
      Result := 'Web search';

    trFileSearch:
      Result := 'File search';

    trCodeInterpreter:
      Result := 'Code interpreter';

    trImageGeneration:
      Result := 'Image generation';

    trMcpListTools:
      Result := 'MCP tool discovery';

    trShell:
      Result := 'Shell command';
  else
    Result := 'Tool activity';
  end;
end;

end.
