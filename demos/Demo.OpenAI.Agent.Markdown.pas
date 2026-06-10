unit Demo.OpenAI.Agent.Markdown;

interface

uses
  System.SysUtils,
  Demo.OpenAI.Agent.Cards;

type
  TOpenAIAgentMarkdownReader = record
  public
    class function TryReadFile(
      const FileName, CardId, EnvelopeVersion: string;
      out Def: TOpenAIAgentCardDefinition): Boolean; static;
  end;

implementation

{$REGION 'Dev note'}
(*

  Markdown-defined OpenAI agent-card parsing for the pythia-openai FMX demo.

  Some demo cards keep the executable agent definition in an external Markdown
  file instead of embedding every instruction in the JSON card envelope. This
  unit converts that pedagogical format back into the same
  TOpenAIAgentCardDefinition record used by JSON-defined cards.

  The parser is intentionally small and demo-scoped:

    - read a constrained YAML-like frontmatter block;
    - extract coordinator and sub-agent instructions from named sections;
    - keep Markdown authoring readable for examples 4 and 5;
    - avoid introducing a generic YAML or Markdown dependency just for this
      teaching format.

  It complements Demo.OpenAI.Agent.Cards but does not replace it. The JSON
  reader owns the card envelope and dispatches to this unit only when a card
  references an external Markdown definition.

*)
{$ENDREGION}

uses
  System.Classes, System.IOUtils,
  WVPythia.TextFile.Helper;

type
  TOpenAIYamlMini = record
  private
    class function SplitLines(const Text: string): TArray<string>; static;
    class function IndentOf(const Line: string): Integer; static;
    class function IsBlank(const Line: string): Boolean; static;
    class function IsListItem(const Line: string): Boolean; static;
    class function Unquote(const Value: string): string; static;
    class function SplitKeyValue(
      const Text: string;
      out Key, Value: string): Boolean; static;
    class function LineHasKey(const Line, Key: string): Boolean; static;
    class function BlockEnd(
      const Lines: TArray<string>;
      const StartIndex, MaxIndex, Indent: Integer): Integer; static;
    class function FindBlock(
      const Lines: TArray<string>;
      const StartIndex, EndIndex, Indent: Integer;
      const Key: string;
      out BlockStart, BlockFinish: Integer): Boolean; static;
    class function ReadScalar(
      const Lines: TArray<string>;
      const StartIndex, EndIndex, Indent: Integer;
      const Key: string;
      const Default: string = ''): string; static;
    class function ParseBool(
      const Value: string;
      const Default: Boolean): Boolean; static;
    class function ParseKind(
      const Value: string): TOpenAIAgentCardKind; static;
    class function ParseToolList(
      const Lines: TArray<string>;
      const StartIndex, EndIndex, Indent: Integer;
      const Key: string): TArray<TOpenAIAgentToolDef>; static;
    class function ParseTools(
      const Lines: TArray<string>;
      const StartIndex, EndIndex, Indent: Integer): TOpenAIAgentToolsDef; static;
  public
    class function ExtractFrontmatterAndBody(
      const Markdown: string;
      out Frontmatter, Body: string): Boolean; static;
    class function ParseDefinition(
      const Markdown, CardId: string;
      out Def: TOpenAIAgentCardDefinition): Boolean; static;
  end;

  TOpenAIMarkdownSections = record
  private
    class function JoinTrimmed(
      const Lines: TArray<string>;
      const FirstIndex, LastIndex: Integer): string; static;
  public
    class function ExtractHeading(
      const Body, Heading: string): string; static;
    class function Coordinator(const Body: string): string; static;
    class function Subagent(
      const Body, Ref, Name: string): string; static;
  end;

{ TOpenAIYamlMini }

class function TOpenAIYamlMini.SplitLines(const Text: string): TArray<string>;
begin
  var Normalized := Text.Replace(#13#10, #10).Replace(#13, #10);
  Normalized := Normalized.Replace(#10, sLineBreak);

  var Lines := TStringList.Create;
  try
    Lines.Text := Normalized;
    SetLength(Result, Lines.Count);
    for var index := 0 to Lines.Count - 1 do
      Result[index] := Lines[index];
  finally
    Lines.Free;
  end;
end;

class function TOpenAIYamlMini.IndentOf(const Line: string): Integer;
begin
  Result := 0;
  while (Result < Line.Length) and (Line[Result + 1] = ' ') do
    Inc(Result);
end;

class function TOpenAIYamlMini.IsBlank(const Line: string): Boolean;
begin
  Result := Line.Trim.IsEmpty;
end;

class function TOpenAIYamlMini.IsListItem(const Line: string): Boolean;
begin
  Result := Line.TrimLeft.StartsWith('- ');
end;

class function TOpenAIYamlMini.Unquote(const Value: string): string;
begin
  Result := Value.Trim;
  if Result.Length < 2 then
    Exit;

  if ((Result[1] = '"') and (Result[Result.Length] = '"')) or
     ((Result[1] = '''') and (Result[Result.Length] = '''')) then
    Result := Result.Substring(1, Result.Length - 2);

  Result := Result.Replace('\"', '"');
end;

class function TOpenAIYamlMini.SplitKeyValue(
  const Text: string;
  out Key, Value: string): Boolean;
begin
  Key := '';
  Value := '';

  var P := Text.IndexOf(':');
  if P < 0 then
    Exit(False);

  Key := Text.Substring(0, P).Trim;
  Value := Unquote(Text.Substring(P + 1));
  Result := not Key.IsEmpty;
end;

class function TOpenAIYamlMini.LineHasKey(
  const Line, Key: string): Boolean;
var
  K, V: string;
begin
  Result := SplitKeyValue(Line.Trim, K, V) and SameText(K, Key);
end;

class function TOpenAIYamlMini.BlockEnd(
  const Lines: TArray<string>;
  const StartIndex, MaxIndex, Indent: Integer): Integer;
begin
  Result := MaxIndex;
  for var index := StartIndex + 1 to MaxIndex do
    if (not IsBlank(Lines[index])) and (IndentOf(Lines[index]) <= Indent) then
      Exit(index - 1);
end;

class function TOpenAIYamlMini.FindBlock(
  const Lines: TArray<string>;
  const StartIndex, EndIndex, Indent: Integer;
  const Key: string;
  out BlockStart, BlockFinish: Integer): Boolean;
begin
  Result := False;
  BlockStart := -1;
  BlockFinish := -1;

  for var index := StartIndex to EndIndex do
    if (IndentOf(Lines[index]) = Indent) and LineHasKey(Lines[index], Key) then
      begin
        BlockStart := index;
        BlockFinish := BlockEnd(Lines, index, EndIndex, Indent);
        Exit(True);
      end;
end;

class function TOpenAIYamlMini.ReadScalar(
  const Lines: TArray<string>;
  const StartIndex, EndIndex, Indent: Integer;
  const Key, Default: string): string;
begin
  for var index := StartIndex to EndIndex do
    if (IndentOf(Lines[index]) = Indent) and LineHasKey(Lines[index], Key) then
      begin
        var K, V: string;
        SplitKeyValue(Lines[index].Trim, K, V);
        Exit(V);
      end;

  Result := Default;
end;

class function TOpenAIYamlMini.ParseBool(
  const Value: string;
  const Default: Boolean): Boolean;
begin
  if SameText(Value, 'true') then
    Exit(True);

  if SameText(Value, 'false') then
    Exit(False);

  Result := Default;
end;

class function TOpenAIYamlMini.ParseKind(
  const Value: string): TOpenAIAgentCardKind;
begin
  if SameText(Value, 'single') then
    Exit(oackSingle);

  if SameText(Value, 'multiagent') then
    Exit(oackMultiagent);

  Result := oackUnknown;
end;

class function TOpenAIYamlMini.ParseToolList(
  const Lines: TArray<string>;
  const StartIndex, EndIndex, Indent: Integer;
  const Key: string): TArray<TOpenAIAgentToolDef>;
begin
  Result := [];

  var ToolsStart, ToolsEnd: Integer;
  if not FindBlock(Lines, StartIndex, EndIndex, Indent, Key,
    ToolsStart, ToolsEnd) then
    Exit;

  var I := ToolsStart + 1;
  while I <= ToolsEnd do
    begin
      if (IndentOf(Lines[I]) = Indent + 2) and IsListItem(Lines[I]) then
        begin
          var ItemStart := I;
          var ItemEnd := ToolsEnd;
          for var J := I + 1 to ToolsEnd do
            if (IndentOf(Lines[J]) = Indent + 2) and IsListItem(Lines[J]) then
              begin
                ItemEnd := J - 1;
                Break;
              end;

          var Tool := Default(TOpenAIAgentToolDef);
          var First := Lines[I].TrimLeft.Substring(2).Trim;
          if not First.IsEmpty then
            begin
              var K, V: string;
              if SplitKeyValue(First, K, V) and SameText(K, 'name') then
                Tool.Name := V;
            end;

          Tool.Name := ReadScalar(
            Lines, ItemStart + 1, ItemEnd, Indent + 4, 'name', Tool.Name);
          Tool.Enabled := ParseBool(
            ReadScalar(Lines, ItemStart + 1, ItemEnd, Indent + 4,
              'enabled', 'false'), False);
          Tool.Policy := ReadScalar(
            Lines, ItemStart + 1, ItemEnd, Indent + 4, 'policy');

          if not Tool.Name.Trim.IsEmpty then
            Result := Result + [Tool];

          I := ItemEnd + 1;
        end
      else
        Inc(I);
    end;
end;

class function TOpenAIYamlMini.ParseTools(
  const Lines: TArray<string>;
  const StartIndex, EndIndex, Indent: Integer): TOpenAIAgentToolsDef;
begin
  Result := Default(TOpenAIAgentToolsDef);

  var ToolsStart, ToolsEnd: Integer;
  if not FindBlock(Lines, StartIndex, EndIndex, Indent, 'tools',
    ToolsStart, ToolsEnd) then
    Exit;

  Result.Hosted := ParseToolList(
    Lines, ToolsStart + 1, ToolsEnd, Indent + 2, 'hosted');
  Result.Project := ParseToolList(
    Lines, ToolsStart + 1, ToolsEnd, Indent + 2, 'project');
end;

class function TOpenAIYamlMini.ExtractFrontmatterAndBody(
  const Markdown: string;
  out Frontmatter, Body: string): Boolean;
begin
  Frontmatter := '';
  Body := '';
  Result := False;

  var Lines := SplitLines(Markdown);
  if (Length(Lines) < 3) or (Lines[0].Trim <> '---') then
    Exit;

  var EndIndex := -1;
  for var I := 1 to High(Lines) do
    if Lines[I].Trim = '---' then
      begin
        EndIndex := I;
        Break;
      end;

  if EndIndex < 0 then
    Exit;

  var Fm := TStringList.Create;
  var Bd := TStringList.Create;
  try
    for var index := 1 to EndIndex - 1 do
      Fm.Add(Lines[index]);

    for var index := EndIndex + 1 to High(Lines) do
      Bd.Add(Lines[index]);

    Frontmatter := Fm.Text.Trim;
    Body := Bd.Text.Trim;
    Result := not Frontmatter.IsEmpty;
  finally
    Fm.Free;
    Bd.Free;
  end;
end;

class function TOpenAIYamlMini.ParseDefinition(
  const Markdown, CardId: string;
  out Def: TOpenAIAgentCardDefinition): Boolean;
begin
  Def := Default(TOpenAIAgentCardDefinition);
  Result := False;

  var Frontmatter, Body: string;
  if not ExtractFrontmatterAndBody(Markdown, Frontmatter, Body) then
    Exit;

  var Lines := SplitLines(Frontmatter);
  if Length(Lines) = 0 then
    Exit;

  var RootEnd := High(Lines);
  Def.CardId := CardId.Trim;
  if Def.CardId.IsEmpty then
    Def.CardId := ReadScalar(Lines, 0, RootEnd, 0, 'id');
  if Def.CardId.IsEmpty then
    Exit;

  Def.Version := ReadScalar(Lines, 0, RootEnd, 0, 'version', '0.0.0-dev');
  Def.Schema := ReadScalar(
    Lines, 0, RootEnd, 0, 'schema', 'pythia.openai.agent-card.v1');
  if not SameText(Def.Schema, 'pythia.openai.agent-card.v1') then
    Exit;

  Def.Kind := ParseKind(ReadScalar(Lines, 0, RootEnd, 0, 'kind'));
  if Def.Kind = oackUnknown then
    Exit;

  var RuntimeStart, RuntimeEnd: Integer;
  if FindBlock(Lines, 0, RootEnd, 0, 'runtime', RuntimeStart, RuntimeEnd) then
    begin
      Def.Runtime.Orchestration :=
        ReadScalar(Lines, RuntimeStart + 1, RuntimeEnd, 2, 'orchestration');

      var ResponsesStart, ResponsesEnd: Integer;
      if FindBlock(Lines, RuntimeStart + 1, RuntimeEnd, 2, 'responses',
        ResponsesStart, ResponsesEnd) then
        begin
          Def.Runtime.Store := ParseBool(
            ReadScalar(Lines, ResponsesStart + 1, ResponsesEnd, 4,
              'store', 'true'), True);
          Def.Runtime.ParallelToolCalls := ParseBool(
            ReadScalar(Lines, ResponsesStart + 1, ResponsesEnd, 4,
              'parallel_tool_calls', 'true'), True);
          Def.Runtime.MaxToolCalls := StrToIntDef(
            ReadScalar(Lines, ResponsesStart + 1, ResponsesEnd, 4,
              'max_tool_calls', '0'), 0);
        end;

      var WorkspaceStart, WorkspaceEnd: Integer;
      if FindBlock(Lines, RuntimeStart + 1, RuntimeEnd, 2, 'workspace',
        WorkspaceStart, WorkspaceEnd) then
        begin
          Def.Runtime.Workspace.RequiresSelectedProject := ParseBool(
            ReadScalar(Lines, WorkspaceStart + 1, WorkspaceEnd, 4,
              'requires_selected_project', 'false'), False);
          Def.Runtime.Workspace.Mode :=
            ReadScalar(Lines, WorkspaceStart + 1, WorkspaceEnd, 4, 'mode');
        end;
    end;

  var SessionStart, SessionEnd: Integer;
  if FindBlock(Lines, 0, RootEnd, 0, 'session', SessionStart, SessionEnd) then
    Def.Session.Title := ReadScalar(
      Lines, SessionStart + 1, SessionEnd, 2, 'title');

  case Def.Kind of
    oackSingle:
      begin
        var AgentStart, AgentEnd: Integer;
        if FindBlock(Lines, 0, RootEnd, 0, 'agent', AgentStart, AgentEnd) then
          begin
            Def.Agent.Ref := ReadScalar(
              Lines, AgentStart + 1, AgentEnd, 2, 'ref');
            Def.Agent.Name := ReadScalar(
              Lines, AgentStart + 1, AgentEnd, 2, 'name',
              ReadScalar(Lines, 0, RootEnd, 0, 'name'));
            Def.Agent.Model := ReadScalar(
              Lines, AgentStart + 1, AgentEnd, 2, 'model');
            Def.Agent.Tools := ParseTools(
              Lines, AgentStart + 1, AgentEnd, 2);
            Def.Agent.Instructions :=
              TOpenAIMarkdownSections.ExtractHeading(Body, 'Agent');
            if Def.Agent.Instructions.Trim.IsEmpty then
              Def.Agent.Instructions := Body.Trim;
          end;
      end;

    oackMultiagent:
      begin
        var CoordStart, CoordEnd: Integer;
        if FindBlock(Lines, 0, RootEnd, 0, 'coordinator',
          CoordStart, CoordEnd) then
          begin
            Def.Coordinator.Ref := ReadScalar(
              Lines, CoordStart + 1, CoordEnd, 2, 'ref');
            Def.Coordinator.Name := ReadScalar(
              Lines, CoordStart + 1, CoordEnd, 2, 'name');
            Def.Coordinator.Model := ReadScalar(
              Lines, CoordStart + 1, CoordEnd, 2, 'model');
            Def.Coordinator.Tools := ParseTools(
              Lines, CoordStart + 1, CoordEnd, 2);
            Def.Coordinator.Instructions :=
              TOpenAIMarkdownSections.Coordinator(Body);
          end;

        var SubsStart, SubsEnd: Integer;
        if FindBlock(Lines, 0, RootEnd, 0, 'subagents', SubsStart, SubsEnd) then
          begin
            var I := SubsStart + 1;
            while I <= SubsEnd do
              begin
                if (IndentOf(Lines[I]) = 2) and IsListItem(Lines[I]) then
                  begin
                    var ItemStart := I;
                    var ItemEnd := SubsEnd;
                    for var J := I + 1 to SubsEnd do
                      if (IndentOf(Lines[J]) = 2) and IsListItem(Lines[J]) then
                        begin
                          ItemEnd := J - 1;
                          Break;
                        end;

                    var Sub := Default(TOpenAIAgentDef);
                    var First := Lines[I].TrimLeft.Substring(2).Trim;
                    if not First.IsEmpty then
                      begin
                        var K, V: string;
                        if SplitKeyValue(First, K, V) and SameText(K, 'ref') then
                          Sub.Ref := V;
                      end;

                    Sub.Ref := ReadScalar(
                      Lines, ItemStart + 1, ItemEnd, 4, 'ref', Sub.Ref);
                    Sub.Name := ReadScalar(
                      Lines, ItemStart + 1, ItemEnd, 4, 'name');
                    Sub.Model := ReadScalar(
                      Lines, ItemStart + 1, ItemEnd, 4, 'model');
                    Sub.Tools := ParseTools(
                      Lines, ItemStart + 1, ItemEnd, 4);
                    Sub.Instructions :=
                      TOpenAIMarkdownSections.Subagent(Body, Sub.Ref, Sub.Name);

                    if not Sub.Ref.Trim.IsEmpty then
                      Def.SubAgents := Def.SubAgents + [Sub];

                    I := ItemEnd + 1;
                  end
                else
                  Inc(I);
              end;
          end;
      end;
  end;

  Def.Valid := True;
  Result := True;
end;

{ TOpenAIMarkdownSections }

class function TOpenAIMarkdownSections.JoinTrimmed(
  const Lines: TArray<string>;
  const FirstIndex, LastIndex: Integer): string;
begin
  var SL := TStringList.Create;
  try
    for var index := FirstIndex to LastIndex do
      SL.Add(Lines[index]);

    Result := SL.Text.Trim;
  finally
    SL.Free;
  end;
end;

class function TOpenAIMarkdownSections.ExtractHeading(
  const Body, Heading: string): string;
begin
  Result := '';

  var Lines := TOpenAIYamlMini.SplitLines(Body);
  var Wanted := '# ' + Heading.Trim;
  var StartIndex := -1;

  for var index := 0 to High(Lines) do
    if SameText(Lines[index].Trim, Wanted) then
      begin
        StartIndex := index;
        Break;
      end;

  if StartIndex < 0 then
    Exit;

  var EndIndex := High(Lines);
  for var index := StartIndex + 1 to High(Lines) do
    if Lines[index].Trim.StartsWith('# ') then
      begin
        EndIndex := index - 1;
        Break;
      end;

  Result := JoinTrimmed(Lines, StartIndex + 1, EndIndex);
end;

class function TOpenAIMarkdownSections.Coordinator(
  const Body: string): string;
begin
  Result := ExtractHeading(Body, 'Coordinator');
end;

class function TOpenAIMarkdownSections.Subagent(
  const Body, Ref, Name: string): string;
begin
  Result := '';

  if not Ref.Trim.IsEmpty then
    Result := ExtractHeading(Body, 'Subagent: ' + Ref.Trim);

  if Result.Trim.IsEmpty and not Name.Trim.IsEmpty then
    Result := ExtractHeading(Body, 'Subagent: ' + Name.Trim);
end;

{ TOpenAIAgentMarkdownReader }

class function TOpenAIAgentMarkdownReader.TryReadFile(
  const FileName, CardId, EnvelopeVersion: string;
  out Def: TOpenAIAgentCardDefinition): Boolean;
begin
  Def := Default(TOpenAIAgentCardDefinition);
  Result := False;

  if FileName.Trim.IsEmpty or not TFile.Exists(FileName) then
    Exit;

  var Markdown := TFileIOHelper.LoadFromFile(FileName);
  Result := TOpenAIYamlMini.ParseDefinition(Markdown, CardId, Def);
  if not Result then
    Exit;

  if EnvelopeVersion.Trim.IsEmpty then
    Exit;

  if SameText(Def.Version, '0.0.0-dev') then
    Def.Version := EnvelopeVersion.Trim
  else
  if not SameText(Def.Version, EnvelopeVersion.Trim) then
    begin
      Def := Default(TOpenAIAgentCardDefinition);
      Result := False;
    end;
end;

end.
