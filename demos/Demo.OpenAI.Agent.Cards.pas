unit Demo.OpenAI.Agent.Cards;

interface

uses
  System.SysUtils, System.JSON,
  WVPythia.JSON.SafeReader;

type
  TOpenAIAgentCardKind = (oackUnknown, oackSingle, oackMultiagent);

  TOpenAIAgentToolDef = record
    Name: string;
    Enabled: Boolean;
    Policy: string;
  end;

  TOpenAIAgentToolsDef = record
    Hosted: TArray<TOpenAIAgentToolDef>;
    Project: TArray<TOpenAIAgentToolDef>;
  end;

  TOpenAIAgentWorkspaceDef = record
    RequiresSelectedProject: Boolean;
    Mode: string;
  end;

  TOpenAIAgentRuntimeDef = record
    Orchestration: string;
    Store: Boolean;
    ParallelToolCalls: Boolean;
    MaxToolCalls: Integer;
    Workspace: TOpenAIAgentWorkspaceDef;
  end;

  TOpenAIAgentDef = record
    Ref: string;
    Name: string;
    Model: string;
    Instructions: string;
    Tools: TOpenAIAgentToolsDef;
  end;

  TOpenAIAgentSessionDef = record
    Title: string;
  end;

  TOpenAIAgentCardDefinition = record
    Valid: Boolean;
    CardId: string;
    Version: string;
    Schema: string;
    Kind: TOpenAIAgentCardKind;
    Runtime: TOpenAIAgentRuntimeDef;
    Agent: TOpenAIAgentDef;
    SubAgents: TArray<TOpenAIAgentDef>;
    Coordinator: TOpenAIAgentDef;
    Session: TOpenAIAgentSessionDef;
  end;

  TOpenAIAgentCardReader = record
  private
    class function ParseKind(const Value: string): TOpenAIAgentCardKind; static;
    class function FindCardContent(
      const Cards: TJsonReader;
      const CardId: string): string; static;
    class function FindCardVersion(
      const Cards: TJsonReader;
      const CardId: string): string; static;
    class function FindCardMarkdownPath(
      const Cards: TJsonReader;
      const CardId: string): string; static;
    class function ParseTools(
      const Reader: TJsonReader): TOpenAIAgentToolsDef; static;
    class function ParseToolArray(
      const Reader: TJsonReader;
      const Path: string): TArray<TOpenAIAgentToolDef>; static;
    class function ParseAgent(
      const Reader: TJsonReader): TOpenAIAgentDef; static;
    class function ParseSubAgents(
      const Reader: TJsonReader): TArray<TOpenAIAgentDef>; static;
    class function TryReadContent(
      const ContentJson, CardId, EnvelopeVersion: string;
      out Def: TOpenAIAgentCardDefinition): Boolean; static;
  public
    class function TryRead(
      const CardsJson, CardId: string;
      out Def: TOpenAIAgentCardDefinition): Boolean; overload; static;
    class function TryRead(
      const CardsJson, CardId, CardsFolder: string;
      out Def: TOpenAIAgentCardDefinition): Boolean; overload; static;

    class function TryGetCardLabel(
      const CardsJson, CardId: string;
      out Name: string): Boolean; static;
  end;

implementation

{$REGION 'Dev note'}
(*

  OpenAI agent-card definition parsing for the pythia-openai FMX demo.

  This reader keeps the OpenAI card shape explicit instead of reusing
  Anthropic's managed-agent reader, because the vendors do not share the same
  agent execution model. Inline cards can describe either a single Responses
  agent or a demo-orchestrated multi-agent topology.

  Card envelope:

    { "id","name","commentaire","badge","content": "<escaped JSON>" }

  content payload:

    {
      "schema": "pythia.openai.agent-card.v1",
      "version": "...",
      "kind": "single" | "multiagent",
      "runtime": { "orchestration","responses": { ... } },
      "agent": { "ref","name","model","instructions","tools" },
      "subagents": [ { "ref","name","model","instructions","tools" } ],
      "coordinator": { "ref","name","model","instructions","tools" },
      "session": { "title" }
    }

*)
{$ENDREGION}

uses
  System.IOUtils,
  Demo.OpenAI.Agent.Markdown;

{ TOpenAIAgentCardReader }

class function TOpenAIAgentCardReader.FindCardContent(
  const Cards: TJsonReader;
  const CardId: string): string;
begin
  Result := '';

  var Total := Cards.Count('cards');
  for var index := 0 to Total - 1 do
    if SameText(Cards.AsString(Format('cards[%d].id', [index])), CardId) then
      begin
        Result := Cards.ExtractSubJson(Format('cards[%d].content', [index]));
        Exit;
      end;
end;

class function TOpenAIAgentCardReader.FindCardVersion(
  const Cards: TJsonReader;
  const CardId: string): string;
begin
  Result := '';

  var Total := Cards.Count('cards');
  for var index := 0 to Total - 1 do
    if SameText(Cards.AsString(Format('cards[%d].id', [index])), CardId) then
      begin
        Result := Cards.AsString(Format('cards[%d].version', [index]));
        Exit;
      end;
end;

class function TOpenAIAgentCardReader.FindCardMarkdownPath(
  const Cards: TJsonReader;
  const CardId: string): string;
begin
  Result := '';

  var Total := Cards.Count('cards');
  for var index := 0 to Total - 1 do
    if SameText(Cards.AsString(Format('cards[%d].id', [index])), CardId) then
      begin
        Result := Cards.AsString(Format('cards[%d].md_path', [index]));
        Exit;
      end;
end;

class function TOpenAIAgentCardReader.ParseKind(
  const Value: string): TOpenAIAgentCardKind;
begin
  if SameText(Value, 'single') then
    Exit(oackSingle);

  if SameText(Value, 'multiagent') then
    Exit(oackMultiagent);

  Result := oackUnknown;
end;

class function TOpenAIAgentCardReader.ParseToolArray(
  const Reader: TJsonReader;
  const Path: string): TArray<TOpenAIAgentToolDef>;
begin
  Result := [];

  if not Reader.IsValid then
    Exit;

  var Total := Reader.Count(Path);
  for var index := 0 to Total - 1 do
    begin
      var Tool := Default(TOpenAIAgentToolDef);
      Tool.Name := Reader.AsString(Format('%s[%d].name', [Path, index]));
      Tool.Enabled := Reader.AsBoolean(Format('%s[%d].enabled', [Path, index]), False);
      Tool.Policy := Reader.AsString(Format('%s[%d].policy', [Path, index]));

      if not Tool.Name.Trim.IsEmpty then
        Result := Result + [Tool];
    end;
end;

class function TOpenAIAgentCardReader.ParseTools(
  const Reader: TJsonReader): TOpenAIAgentToolsDef;
begin
  Result := Default(TOpenAIAgentToolsDef);

  if not Reader.IsValid then
    Exit;

  Result.Hosted := ParseToolArray(Reader, 'hosted');
  Result.Project := ParseToolArray(Reader, 'project');
end;

class function TOpenAIAgentCardReader.ParseAgent(
  const Reader: TJsonReader): TOpenAIAgentDef;
begin
  Result := Default(TOpenAIAgentDef);

  if not Reader.IsValid then
    Exit;

  Result.Ref := Reader.AsString('ref');
  Result.Name := Reader.AsString('name');
  Result.Model := Reader.AsString('model');
  Result.Instructions := Reader.AsString('instructions');
  Result.Tools := ParseTools(TJsonReader.Parse(Reader.ExtractSubJson('tools')));
end;

class function TOpenAIAgentCardReader.ParseSubAgents(
  const Reader: TJsonReader): TArray<TOpenAIAgentDef>;
begin
  Result := [];

  if not Reader.IsValid then
    Exit;

  for var index := 0 to Reader.Count('subagents') - 1 do
    begin
      var Agent := ParseAgent(
        TJsonReader.Parse(Reader.ExtractSubJson(Format('subagents[%d]', [index]))));

      if not Agent.Instructions.Trim.IsEmpty then
        Result := Result + [Agent];
    end;
end;

class function TOpenAIAgentCardReader.TryGetCardLabel(
  const CardsJson, CardId: string;
  out Name: string): Boolean;
begin
  Result := False;
  Name := '';

  if CardsJson.Trim.IsEmpty or CardId.Trim.IsEmpty then
    Exit;

  var Cards := TJsonReader.Parse(CardsJson);
  if not Cards.IsValid then
    Exit;

  var Total := Cards.Count('cards');
  for var index := 0 to Total - 1 do
    if SameText(Cards.AsString(Format('cards[%d].id', [index])), CardId) then
      begin
        Name := Cards.AsString(Format('cards[%d].name', [index]));
        Result := not Name.Trim.IsEmpty;
        Exit;
      end;
end;

class function TOpenAIAgentCardReader.TryRead(
  const CardsJson, CardId: string;
  out Def: TOpenAIAgentCardDefinition): Boolean;
begin
  Result := TryRead(CardsJson, CardId, '', Def);
end;

class function TOpenAIAgentCardReader.TryRead(
  const CardsJson, CardId, CardsFolder: string;
  out Def: TOpenAIAgentCardDefinition): Boolean;
begin
  Def := Default(TOpenAIAgentCardDefinition);
  Result := False;

  if CardsJson.Trim.IsEmpty or CardId.Trim.IsEmpty then
    Exit;

  var Cards := TJsonReader.Parse(CardsJson);
  if not Cards.IsValid then
    Exit;

  var EnvelopeVersion := FindCardVersion(Cards, CardId);

  var ContentJson := FindCardContent(Cards, CardId);
  if not ContentJson.Trim.IsEmpty then
    Exit(TryReadContent(ContentJson, CardId, EnvelopeVersion, Def));

  var MarkdownPath := FindCardMarkdownPath(Cards, CardId).Trim;
  if MarkdownPath.IsEmpty then
    Exit;

  if not TPath.IsPathRooted(MarkdownPath) and not CardsFolder.Trim.IsEmpty then
    MarkdownPath := TPath.GetFullPath(TPath.Combine(CardsFolder, MarkdownPath));

  Result := TOpenAIAgentMarkdownReader.TryReadFile(
    MarkdownPath,
    CardId,
    EnvelopeVersion,
    Def);
end;

class function TOpenAIAgentCardReader.TryReadContent(
  const ContentJson, CardId, EnvelopeVersion: string;
  out Def: TOpenAIAgentCardDefinition): Boolean;
begin
  Def := Default(TOpenAIAgentCardDefinition);
  Result := False;

  if ContentJson.Trim.IsEmpty or CardId.Trim.IsEmpty then
    Exit;

  var Content := TJsonReader.Parse(ContentJson);
  if not Content.IsValid then
    Exit;

  Def.CardId := CardId;
  Def.Version := EnvelopeVersion.Trim;
  var ContentVersion := Content.AsString('version').Trim;
  if Def.Version.IsEmpty then
    Def.Version := ContentVersion
  else
  if (not ContentVersion.IsEmpty) and
     (not SameText(Def.Version, ContentVersion)) then
    Exit;

  Def.Schema := Content.AsString('schema');
  if not SameText(Def.Schema, 'pythia.openai.agent-card.v1') then
    Exit;

  Def.Kind := ParseKind(Content.AsString('kind'));
  if Def.Kind = oackUnknown then
    Exit;

  Def.Runtime.Orchestration := Content.AsString('runtime.orchestration');
  Def.Runtime.Store := Content.AsBoolean('runtime.responses.store', True);
  Def.Runtime.ParallelToolCalls :=
    Content.AsBoolean('runtime.responses.parallel_tool_calls', True);
  Def.Runtime.MaxToolCalls :=
    Content.AsInteger('runtime.responses.max_tool_calls', 0);
  Def.Runtime.Workspace.RequiresSelectedProject :=
    Content.AsBoolean('runtime.workspace.requires_selected_project', False);
  Def.Runtime.Workspace.Mode := Content.AsString('runtime.workspace.mode');

  case Def.Kind of
    oackSingle:
      begin
        if Content.IsObjectNode('agent') then
          Def.Agent := ParseAgent(TJsonReader.Parse(Content.ExtractSubJson('agent')));

        if Def.Agent.Instructions.Trim.IsEmpty then
          Exit;

        if Def.Agent.Model.Trim.IsEmpty then
          Exit;
      end;

    oackMultiagent:
      begin
        Def.SubAgents := ParseSubAgents(Content);

        if Content.IsObjectNode('coordinator') then
          Def.Coordinator := ParseAgent(
            TJsonReader.Parse(Content.ExtractSubJson('coordinator')));

        if Length(Def.SubAgents) = 0 then
          Exit;

        if Def.Coordinator.Instructions.Trim.IsEmpty then
          Exit;

        if Def.Coordinator.Model.Trim.IsEmpty then
          Exit;
      end;
  end;

  if Content.IsObjectNode('session') then
    Def.Session.Title := Content.AsString('session.title');

  Def.Valid := True;
  Result := True;
end;

end.
