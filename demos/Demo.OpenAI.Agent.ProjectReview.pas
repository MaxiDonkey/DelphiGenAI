unit Demo.OpenAI.Agent.ProjectReview;

interface

uses
  WVPythia.Vendors.Services, WVPythia.Chat.Interfaces,
  WVPythia.Chat.DisplayBlocks,
  GenAI, GenAI.Types, GenAI.Async.Promise,
  Demo.OpenAI.Agent.Cards;

type
  TOpenAIProjectReviewContext = record
  public
    Prompt: string;
    FileIds: TArray<string>;
    RelativePaths: TArray<string>;
  end;

  TOpenAIProjectReviewPrompt = record
  private
    class function FirstSubAgent(
      const Def: TOpenAIAgentCardDefinition): TOpenAIAgentDef; static;

    class function LocalRelativePath(
      const RootFolder, FullPath: string): string; static;

    class function BuildPrompt(
      const UserText, RootFolder: string;
      const Inspector: TOpenAIAgentDef;
      const RelativePaths, FileIds: TArray<string>;
      const SupervisedReport: string = ''): string; static;

    class function BuildPromptForCard(
      const UserText, RootFolder: string;
      const Def: TOpenAIAgentCardDefinition;
      const Inspector: TOpenAIAgentDef;
      const RelativePaths, FileIds: TArray<string>;
      const SupervisedReport: string = ''): string; static;

    class function BuildCodePatchPrompt(
      const UserText, RootFolder: string;
      const Def: TOpenAIAgentCardDefinition;
      const RelativePaths, FileIds: TArray<string>;
      const IncludeLocalApply: Boolean): string; static;

    class function BuildSafeCodePatchPrompt(
      const UserText, RootFolder: string;
      const Def: TOpenAIAgentCardDefinition;
      const RelativePaths, FileIds: TArray<string>): string; static;

    class function BuildSandboxToLocalCodeEditPrompt(
      const UserText, RootFolder: string;
      const Def: TOpenAIAgentCardDefinition;
      const RelativePaths, FileIds: TArray<string>): string; static;

    class function HasEnabledProjectToolPolicy(
      const Inspector: TOpenAIAgentDef;
      const Policy: string): Boolean; static;

    class procedure EnsureAlwaysAllowProjectTools(
      const Inspector: TOpenAIAgentDef); static;

    class procedure EnsureAlwaysAskProjectTools(
      const Inspector: TOpenAIAgentDef); static;

  public
    class function PrepareAsync(
      const Client: IGenAI;
      const Browser: IPythiaBrowser;
      const Blocks: IPythiaDisplayBlockAggregator;
      const State: TStateBuffer;
      const Def: TOpenAIAgentCardDefinition): TPromise<TOpenAIProjectReviewContext>; static;
  end;

implementation

{$REGION 'Dev note'}
(*

  OpenAI project-agent orchestration for the pythia-openai FMX demo.

  This unit deliberately keeps the project-review agent flow outside the
  regular Responses text-turn plumbing. The goal is pedagogical: show how the
  same demo need covered by Anthropic managed agents is expressed with OpenAI
  Responses, code_interpreter files, and demo-side coordination.

  Responsibilities kept here:

    - select and upload a bounded project workspace to the OpenAI sandbox;
    - build the agent prompts from the OpenAI agent-card definition;
    - expose the project-tool steps as Pythia display blocks;
    - enforce the "agents edit only the sandbox copy" boundary;
    - return local edits only as a manifest and unified diff for later
      confirmation by Pythia.

  This unit must not adapt Pythia or the GenAI SDK to the demo. If a lower
  layer lacks a capability, the demo has to compose the existing contracts
  here or stop with an explicit reason.

*)
{$ENDREGION}

uses
  System.SysUtils, System.StrUtils, System.Classes, System.IOUtils,
  System.Threading,
  WVPythia.Chat.DecisionDlg, WVPythia.TextFile.Helper,
  GenAI.Files,
  Demo.OpenAI.Agent.TurnDisplay, Demo.OpenAI.Strs;

const
  MAX_REVIEW_FILES = 40;
  MAX_INSPECTED_FILES = 12;
  MAX_CANDIDATE_FILES = 200;
  UPLOADED_FILE_EXPIRES_AFTER_SECONDS = 3600;

type
  IOpenAIProjectReviewUploadContext = interface
    ['{C2B36C1E-9227-4AC1-9B17-8BF9B0200866}']
    procedure DispatchAt(Index: Integer);
    procedure CompleteOne(
      Index: Integer;
      const FileId, RelativePath: string);
    procedure RejectWith(const Message: string);
  end;

  TOpenAIProjectReviewUploadContext = class(
    TInterfacedObject, IOpenAIProjectReviewUploadContext)
  private
    FClient: IGenAI;
    FBrowser: IPythiaBrowser;
    FBlocks: IPythiaDisplayBlockAggregator;
    FDisplay: TOpenAIAgentTurnDisplay;
    FRootFolder: string;
    FUserText: string;
    FDef: TOpenAIAgentCardDefinition;
    FInspector: TOpenAIAgentDef;
    FFiles: TArray<string>;
    FResult: TOpenAIProjectReviewContext;
    FResolve: TProc<TOpenAIProjectReviewContext>;
    FReject: TProc<Exception>;
    FSettled: Boolean;

    procedure ReleaseReferences;
    procedure DisplayStatus(const Text: string);
    procedure DisplayToolOutput(const Title, Text: string);
    procedure ResolveIfDone;
    function IsSafeCodePatch: Boolean;
    function IsSandboxToLocalCodeEdit: Boolean;
    function UsesSupervisedPolicy: Boolean;
  public
    constructor Create(
      const Client: IGenAI;
      const Browser: IPythiaBrowser;
      const Blocks: IPythiaDisplayBlockAggregator;
      const RootFolder, UserText: string;
      const Def: TOpenAIAgentCardDefinition;
      const Inspector: TOpenAIAgentDef;
      const Files: TArray<string>;
      const Resolve: TProc<TOpenAIProjectReviewContext>;
      const Reject: TProc<Exception>);

    procedure DispatchAt(Index: Integer);
    procedure CompleteOne(
      Index: Integer;
      const FileId, RelativePath: string);
    procedure RejectWith(const Message: string);
  end;

  TOpenAIProjectSupervisedExplorer = record
  private const
    MAX_SUPERVISED_READS = 3;
    MAX_SUPERVISED_GREP_RESULTS = 20;
    MAX_SUPERVISED_FILE_CHARS = 6000;
  private
    class function ConfirmToolCall(
      const Browser: IPythiaBrowser;
      const Display: TOpenAIAgentTurnDisplay;
      const AgentName, ToolName, Details: string): Boolean; static;

    class function GrepFiles(
      const RootFolder: string;
      const Files: TArray<string>;
      const Keyword: string): string; static;

    class function ReadFilePreview(
      const FullPath: string): string; static;

    class function SelectReadFiles(
      const Files: TArray<string>): TArray<string>; static;

    class function FileScore(
      const FullPath: string): Integer; static;
  public
    class function Execute(
      const Browser: IPythiaBrowser;
      const Blocks: IPythiaDisplayBlockAggregator;
      const RootFolder: string;
      const Inspector: TOpenAIAgentDef;
      const Files: TArray<string>): string; static;
  end;

  TOpenAIProjectFiles = record
  private
    class procedure Enumerate(
      const Folder: string;
      var Files: TArray<string>); static;

    class function IsIgnoredDirectory(
      const DirectoryName: string): Boolean; static;

    class function IsReviewableFile(
      const FullPath: string): Boolean; static;
  public
    class function ListReviewable(
      const RootFolder: string): TArray<string>; static;
  end;

{ TOpenAIProjectFiles }

class procedure TOpenAIProjectFiles.Enumerate(
  const Folder: string;
  var Files: TArray<string>);
begin
  if Length(Files) >= MAX_CANDIDATE_FILES then
    Exit;

  var DirectoryNames := TStringList.Create;
  try
    for var DirectoryName in TDirectory.GetDirectories(Folder) do
      if not IsIgnoredDirectory(TPath.GetFileName(DirectoryName)) then
        DirectoryNames.Add(DirectoryName);

    DirectoryNames.Sort;

    for var index := 0 to DirectoryNames.Count - 1 do
      begin
        Enumerate(DirectoryNames[index], Files);
        if Length(Files) >= MAX_CANDIDATE_FILES then
          Exit;
      end;
  finally
    DirectoryNames.Free;
  end;

  var FileNames := TStringList.Create;
  try
    for var FileName in TDirectory.GetFiles(Folder) do
      if IsReviewableFile(FileName) then
        FileNames.Add(FileName);

    FileNames.Sort;

    for var index := 0 to FileNames.Count - 1 do
      begin
        Files := Files + [FileNames[index]];
        if Length(Files) >= MAX_CANDIDATE_FILES then
          Exit;
      end;
  finally
    FileNames.Free;
  end;
end;

class function TOpenAIProjectFiles.IsIgnoredDirectory(
  const DirectoryName: string): Boolean;
begin
  Result :=
    SameText(DirectoryName, '.git') or
    SameText(DirectoryName, '.svn') or
    SameText(DirectoryName, '.hg') or
    SameText(DirectoryName, '.idea') or
    SameText(DirectoryName, '.vs') or
    SameText(DirectoryName, '.vscode') or
    SameText(DirectoryName, '__pycache__') or
    SameText(DirectoryName, 'node_modules') or
    SameText(DirectoryName, 'packages') or
    SameText(DirectoryName, 'bin') or
    SameText(DirectoryName, 'obj') or
    SameText(DirectoryName, 'debug') or
    SameText(DirectoryName, 'release') or
    SameText(DirectoryName, 'win32') or
    SameText(DirectoryName, 'win64');
end;

class function TOpenAIProjectFiles.IsReviewableFile(
  const FullPath: string): Boolean;
begin
  var Ext := TPath.GetExtension(FullPath).ToLowerInvariant;

  Result :=
    (Ext = '.pas') or
    (Ext = '.dpr') or
    (Ext = '.dpk') or
    (Ext = '.inc') or
    (Ext = '.dfm') or
    (Ext = '.fmx') or
    (Ext = '.js') or
    (Ext = '.ts') or
    (Ext = '.tsx') or
    (Ext = '.json') or
    (Ext = '.md') or
    (Ext = '.xml') or
    (Ext = '.yml') or
    (Ext = '.yaml') or
    (Ext = '.ini') or
    (Ext = '.css') or
    (Ext = '.html') or
    (Ext = '.py') or
    (Ext = '.cs') or
    (Ext = '.java');
end;

class function TOpenAIProjectFiles.ListReviewable(
  const RootFolder: string): TArray<string>;
begin
  Result := [];
  Enumerate(RootFolder, Result);

  if Length(Result) > MAX_REVIEW_FILES then
    SetLength(Result, MAX_REVIEW_FILES);
end;

{ TOpenAIProjectReviewPrompt }

class function TOpenAIProjectReviewPrompt.PrepareAsync(
  const Client: IGenAI;
  const Browser: IPythiaBrowser;
  const Blocks: IPythiaDisplayBlockAggregator;
  const State: TStateBuffer;
  const Def: TOpenAIAgentCardDefinition): TPromise<TOpenAIProjectReviewContext>;
begin
  Result := TPromise<TOpenAIProjectReviewContext>.Create(
    procedure(
      Resolve: TProc<TOpenAIProjectReviewContext>;
      Reject: TProc<Exception>)
    begin
      try
        var Empty := Default(TOpenAIProjectReviewContext);
        Empty.Prompt := State.Text;

        if Def.Kind <> oackMultiagent then
          begin
            Resolve(Empty);
            Exit;
          end;

        if not SameText(Def.Runtime.Orchestration, 'delphi_sequential') then
          raise Exception.CreateFmt(
            'Unsupported OpenAI agent orchestration: %s',
            [Def.Runtime.Orchestration]);

        if Def.Runtime.Workspace.RequiresSelectedProject and
           State.Project.FullPath.Trim.IsEmpty then
          raise Exception.Create(
            'This OpenAI agent needs a selected project folder. Select a ' +
            'project with the Project button before starting the agent.');

        var RootFolder := State.Project.FullPath.Trim;
        if RootFolder.IsEmpty then
          begin
            Resolve(Empty);
            Exit;
          end;

        RootFolder := TPath.GetFullPath(RootFolder);
        if not TDirectory.Exists(RootFolder) then
          raise Exception.Create(
            'The selected project folder does not exist: ' + RootFolder);

        var Inspector := FirstSubAgent(Def);

        var Files := TOpenAIProjectFiles.ListReviewable(RootFolder);
        if Length(Files) = 0 then
          raise Exception.Create(
            'The selected project folder contains no reviewable source file: ' +
            RootFolder);

        if HasEnabledProjectToolPolicy(Inspector, 'always_ask') then
          begin
            EnsureAlwaysAskProjectTools(Inspector);

            var Display := TOpenAIAgentTurnDisplay.Create(Browser, Blocks);
            try
              Display.AssistantText('Starting supervised exploration...');
              Display.Status('Provisioning OpenAI code_interpreter files');
            finally
              Display.Free;
            end;

            var CapturedBrowser := Browser;
            var CapturedBlocks := Blocks;
            var CapturedRootFolder := RootFolder;
            var CapturedUserText := State.Text;
            var CapturedInspector := Inspector;
            var CapturedFiles := Files;
            var UploadResolve: TProc<TOpenAIProjectReviewContext> :=
              procedure(UploadedContext: TOpenAIProjectReviewContext)
              begin
                var PreparedContext := UploadedContext;

                TTask.Run(
                  procedure
                  begin
                    try
                      var SupervisedReport :=
                        TOpenAIProjectSupervisedExplorer.Execute(
                          CapturedBrowser,
                          CapturedBlocks,
                          CapturedRootFolder,
                          CapturedInspector,
                          CapturedFiles);

                      PreparedContext.Prompt :=
                        TOpenAIProjectReviewPrompt.BuildPrompt(
                          CapturedUserText,
                          CapturedRootFolder,
                          CapturedInspector,
                          PreparedContext.RelativePaths,
                          PreparedContext.FileIds,
                          SupervisedReport);

                      Resolve(PreparedContext);
                    except
                      on E: Exception do
                        Reject(Exception.Create(E.Message));
                    end;
                  end);
              end;

            var Ctx: IOpenAIProjectReviewUploadContext :=
              TOpenAIProjectReviewUploadContext.Create(
                Client,
                Browser,
                Blocks,
                RootFolder,
                State.Text,
                Def,
                Inspector,
                Files,
                UploadResolve,
                Reject);
            Ctx.DispatchAt(0);
            Exit;
          end;

        EnsureAlwaysAllowProjectTools(Inspector);

        var Ctx: IOpenAIProjectReviewUploadContext :=
          TOpenAIProjectReviewUploadContext.Create(
            Client,
            Browser,
            Blocks,
            RootFolder,
            State.Text,
            Def,
            Inspector,
            Files,
            Resolve,
            Reject);
        Ctx.DispatchAt(0);
      except
        on E: Exception do
          Reject(Exception.Create(E.Message));
      end;
    end);
end;

class function TOpenAIProjectReviewPrompt.BuildPrompt(
  const UserText, RootFolder: string;
  const Inspector: TOpenAIAgentDef;
  const RelativePaths, FileIds: TArray<string>;
  const SupervisedReport: string): string;
begin
  var Builder := TStringBuilder.Create;
  try
    Builder.AppendLine('User request:');
    Builder.AppendLine(UserText);
    Builder.AppendLine;
    Builder.AppendLine('OpenAI demo orchestration:');
    Builder.AppendLine(
      'Pythia selected a local project folder, uploaded its reviewable files ' +
      'to OpenAI Files, and attached those files to a code_interpreter ' +
      'container for this Responses request.');
    Builder.AppendLine(
      'Use the code_interpreter tool to list the mounted files and inspect ' +
      'the uploaded project files before writing the final review.');
    Builder.AppendLine(
      'If the sandbox exposes only simple file names, use the uploaded file ' +
      'map below to cite the original project-relative paths.');
    Builder.AppendLine(
      'Do not write, modify, create, or delete files. The project review is ' +
      'read-only.');

    if not SupervisedReport.Trim.IsEmpty then
      begin
        Builder.AppendLine(
          'For this always_ask card, Pythia asked the operator before each ' +
          'local project exploration step. The transcript below summarizes ' +
          'what the supervised explorer was allowed to inspect before this ' +
          'Responses request.');
        Builder.AppendLine(
          'Use the attached code_interpreter files as the authoritative ' +
          'source, and use the supervised transcript as navigation/context.');
      end;

    Builder.AppendLine;
    Builder.AppendLine('Sub-agent instructions:');
    Builder.AppendLine(Inspector.Instructions);
    Builder.AppendLine;
    Builder.AppendLine('Project root: ' + RootFolder);
    Builder.AppendLine('Inspector: ' + Inspector.Name);
    Builder.AppendLine(
      Format('Files uploaded: %d. Inspect at most %d files in detail.', [
        Length(FileIds),
        MAX_INSPECTED_FILES]));
    Builder.AppendLine;
    Builder.AppendLine('Uploaded file map:');

    for var Index := 0 to High(FileIds) do
      Builder.AppendLine(
        Format('- %s => %s', [FileIds[Index], RelativePaths[Index]]));

    if not SupervisedReport.Trim.IsEmpty then
      begin
        Builder.AppendLine;
        Builder.AppendLine('Supervised exploration transcript:');
        Builder.AppendLine(SupervisedReport.Trim);
      end;

    Builder.AppendLine;
    Builder.AppendLine('Final answer format:');
    Builder.AppendLine('- Findings');
    Builder.AppendLine('- Severity');
    Builder.AppendLine('- Recommendations');

    Result := Builder.ToString;
  finally
    Builder.Free;
  end;
end;

class function TOpenAIProjectReviewPrompt.BuildPromptForCard(
  const UserText, RootFolder: string;
  const Def: TOpenAIAgentCardDefinition;
  const Inspector: TOpenAIAgentDef;
  const RelativePaths, FileIds: TArray<string>;
  const SupervisedReport: string): string;
begin
  if SameText(Def.CardId, 'openai-safe-code-patch') then
    Exit(BuildSafeCodePatchPrompt(
      UserText,
      RootFolder,
      Def,
      RelativePaths,
      FileIds));

  if SameText(Def.CardId, 'openai-sandbox-to-local-code-edit') then
    Exit(BuildSandboxToLocalCodeEditPrompt(
      UserText,
      RootFolder,
      Def,
      RelativePaths,
      FileIds));

  Result := BuildPrompt(
    UserText,
    RootFolder,
    Inspector,
    RelativePaths,
    FileIds,
    SupervisedReport);
end;

class function TOpenAIProjectReviewPrompt.BuildCodePatchPrompt(
  const UserText, RootFolder: string;
  const Def: TOpenAIAgentCardDefinition;
  const RelativePaths, FileIds: TArray<string>;
  const IncludeLocalApply: Boolean): string;
begin
  var Builder := TStringBuilder.Create;
  try
    Builder.AppendLine('User request:');
    Builder.AppendLine(UserText);
    Builder.AppendLine;
    Builder.AppendLine('OpenAI demo orchestration:');
    Builder.AppendLine(
      'Pythia selected a local project folder, uploaded its reviewable files ' +
      'to OpenAI Files, and attached those files to a code_interpreter ' +
      'container for this Responses request.');
    if IncludeLocalApply then
      Builder.AppendLine(
        'This is the local-apply variant of the safe patch workflow. It must ' +
        'behave like the safe patch card, then add a machine-readable local ' +
        'apply manifest so Pythia can ask before touching the selected folder.')
    else
      Builder.AppendLine(
        'This is a safe patch proposal workflow. You may inspect uploaded ' +
        'files with code_interpreter, but you must not write, create, edit, ' +
        'delete, or save any file.');
    Builder.AppendLine(
      'Your task is to simulate the card topology in one OpenAI Responses ' +
      'turn: Code Locator finds the relevant area, Patch Author drafts a ' +
      'minimal unified diff, and the Coordinator reviews the proposal before ' +
      'returning the final answer.');
    if IncludeLocalApply then
      Builder.AppendLine(
        'The only extra behavior compared with the safe patch card is that ' +
        'the final answer must also include the local apply manifest. The ' +
        'agent must never claim that the selected local folder was modified; ' +
        'Pythia applies the diff locally only after confirmation.');
    Builder.AppendLine(
      'If the sandbox exposes only simple file names, use the uploaded file ' +
      'map below to cite local project-relative paths in the diff headers.');
    Builder.AppendLine;
    Builder.AppendLine('Selected project root: ' + RootFolder);
    Builder.AppendLine(
      Format('Files uploaded: %d. Keep inspection focused and minimal.', [
        Length(FileIds)]));
    Builder.AppendLine;
    Builder.AppendLine('Uploaded file map:');

    for var Index := 0 to High(FileIds) do
      Builder.AppendLine(
        Format('- %s => %s', [FileIds[Index], RelativePaths[Index]]));

    Builder.AppendLine;
    Builder.AppendLine('Coordinator instructions:');
    Builder.AppendLine(Def.Coordinator.Instructions);

    for var Agent in Def.SubAgents do
      begin
        Builder.AppendLine;
        Builder.AppendLine(
          Format('Sub-agent instructions (%s / %s):', [
            Agent.Ref,
            Agent.Name]));
        Builder.AppendLine(Agent.Instructions);
      end;

    Builder.AppendLine;
    Builder.AppendLine('Required workflow for this OpenAI demo run:');
    Builder.AppendLine(
      '- First, inspect the uploaded files to locate the relevant file and ' +
      'code area.');
    Builder.AppendLine(
      '- Then, choose the smallest safe patch scope.');
    Builder.AppendLine(
      '- Then, draft a standard unified diff using local relative paths in ' +
      'the --- and +++ headers.');
    Builder.AppendLine(
      '- Finally, review that the diff is narrow and does not imply that ' +
      'Pythia modified the local disk.');
    Builder.AppendLine;
    Builder.AppendLine('Final answer format:');
    Builder.AppendLine('Patch Summary');
    Builder.AppendLine('- Files affected: ...');
    Builder.AppendLine('- Intent: ...');
    Builder.AppendLine;
    if IncludeLocalApply then
      begin
        Builder.AppendLine('Local Apply Manifest');
        Builder.AppendLine('PYTHIA_LOCAL_APPLY_MANIFEST_BEGIN');
        Builder.AppendLine('```text');
        Builder.AppendLine('root_hint=openai-code-interpreter:/project');
        Builder.AppendLine('files=1');
        Builder.AppendLine('file[0].sandbox_path=openai-code-interpreter:/project/path/to/file');
        Builder.AppendLine('file[0].local_relative_path=path/to/file');
        Builder.AppendLine('file[0].change_type=modify');
        Builder.AppendLine('file[0].requires_user_confirmation=true');
        Builder.AppendLine('```');
        Builder.AppendLine('PYTHIA_LOCAL_APPLY_MANIFEST_END');
        Builder.AppendLine;
      end;
    Builder.AppendLine('Unified Diff');
    Builder.AppendLine('PYTHIA_UNIFIED_DIFF_BEGIN');
    Builder.AppendLine('```diff');
    Builder.AppendLine('--- path/to/file');
    Builder.AppendLine('+++ path/to/file');
    Builder.AppendLine('@@');
    Builder.AppendLine('- old line');
    Builder.AppendLine('+ new line');
    Builder.AppendLine('```');
    Builder.AppendLine('PYTHIA_UNIFIED_DIFF_END');
    Builder.AppendLine;
    Builder.AppendLine('Validation Notes');
    Builder.AppendLine('- Why this patch is narrow: ...');
    Builder.AppendLine('- Suggested test or manual check: ...');
    Builder.AppendLine;
    Builder.AppendLine(
      'If no safe patch can be anchored to concrete existing lines, say so ' +
      'clearly and do not invent a diff.');

    Result := Builder.ToString;
  finally
    Builder.Free;
  end;
end;

class function TOpenAIProjectReviewPrompt.BuildSafeCodePatchPrompt(
  const UserText, RootFolder: string;
  const Def: TOpenAIAgentCardDefinition;
  const RelativePaths, FileIds: TArray<string>): string;
begin
  Result := BuildCodePatchPrompt(
    UserText,
    RootFolder,
    Def,
    RelativePaths,
    FileIds,
    False);
end;

class function TOpenAIProjectReviewPrompt.BuildSandboxToLocalCodeEditPrompt(
  const UserText, RootFolder: string;
  const Def: TOpenAIAgentCardDefinition;
  const RelativePaths, FileIds: TArray<string>): string;
begin
  Result := BuildCodePatchPrompt(
    UserText,
    RootFolder,
    Def,
    RelativePaths,
    FileIds,
    True);
end;

class function TOpenAIProjectReviewPrompt.HasEnabledProjectToolPolicy(
  const Inspector: TOpenAIAgentDef;
  const Policy: string): Boolean;
begin
  Result := False;

  for var Tool in Inspector.Tools.Project do
    if Tool.Enabled and SameText(Tool.Policy, Policy) then
      Exit(True);
end;

class procedure TOpenAIProjectReviewPrompt.EnsureAlwaysAskProjectTools(
  const Inspector: TOpenAIAgentDef);
begin
  for var Tool in Inspector.Tools.Project do
    if Tool.Enabled and not SameText(Tool.Policy, 'always_ask') then
      raise Exception.CreateFmt(
        'Unsupported mixed OpenAI project tool policy for this demo step: %s/%s',
        [Tool.Name, Tool.Policy]);
end;

class procedure TOpenAIProjectReviewPrompt.EnsureAlwaysAllowProjectTools(
  const Inspector: TOpenAIAgentDef);
begin
  for var Tool in Inspector.Tools.Project do
    if Tool.Enabled and not SameText(Tool.Policy, 'always_allow') then
      raise Exception.CreateFmt(
        'Unsupported OpenAI project tool policy for this demo step: %s/%s',
        [Tool.Name, Tool.Policy]);
end;

class function TOpenAIProjectReviewPrompt.FirstSubAgent(
  const Def: TOpenAIAgentCardDefinition): TOpenAIAgentDef;
begin
  Result := Default(TOpenAIAgentDef);

  if Length(Def.SubAgents) > 0 then
    Result := Def.SubAgents[0];

  if Result.Name.Trim.IsEmpty then
    Result.Name := Result.Ref.Trim;

  if Result.Name.Trim.IsEmpty then
    Result.Name := 'Code Inspector';
end;

{ TOpenAIProjectSupervisedExplorer }

class function TOpenAIProjectSupervisedExplorer.ConfirmToolCall(
  const Browser: IPythiaBrowser;
  const Display: TOpenAIAgentTurnDisplay;
  const AgentName, ToolName, Details: string): Boolean;
begin
  if not Assigned(Browser) or not Assigned(Display) then
    raise Exception.Create('Pythia browser is not available for confirmation.');

  var Key := 'confirm:' + ToolName + ':' + TGUID.NewGuid.ToString;
  var Title := 'Tool confirmation - ' + ToolName;

  Display.ToolUse(Key, Title, False);

  var DialogContent := Format(
    '**The OpenAI demo agent is requesting permission to use:**' + sLineBreak +
    sLineBreak +
    '### %s' + sLineBreak +
    sLineBreak +
    '```text' + sLineBreak +
    'Agent: %s' + sLineBreak +
    'Tool: %s' + sLineBreak +
    sLineBreak +
    '%s' + sLineBreak +
    '```',
    [ToolName, AgentName, ToolName, Details.Trim]);

  var DialogRequest := TWebDecisionDlgRequest.Markdown(
    S_DEMO_TOOL_CONFIRMATION_TITLE,
    DialogContent,
    [
      TWebDecisionDlgButton.Create(
        'allow',
        S_DEMO_TOOL_ALLOW,
        wdrDefault),
      TWebDecisionDlgButton.Create(
        'deny',
        S_DEMO_TOOL_DENY,
        wdrCancel)
    ]);
  DialogRequest.FooterText := S_DEMO_TOOL_ALLOW_CALL;

  var Decision := Browser.WebDecisionDlg(DialogRequest);
  Result := Decision.Success and SameText(Decision.ChoiceId, 'allow');

  if Result then
    Display.ToolResultStatus(Key, Title, 'Allowed by operator.')
  else
    Display.ToolResultStatus(Key, Title, 'Denied by operator.');
end;

class function TOpenAIProjectSupervisedExplorer.Execute(
  const Browser: IPythiaBrowser;
  const Blocks: IPythiaDisplayBlockAggregator;
  const RootFolder: string;
  const Inspector: TOpenAIAgentDef;
  const Files: TArray<string>): string;
begin
  Result := '';

  var Display := TOpenAIAgentTurnDisplay.Create(Browser, Blocks);
  var Report := TStringBuilder.Create;
  try
    Display.Status('Selected project folder', RootFolder);
    Display.Status('Starting supervised project exploration');

    Report.AppendLine('Budget: one glob, up to three read calls, at most one grep.');
    Report.AppendLine;

    Display.AssistantText('Let me inspect the selected project structure.');

    var GlobDetails :=
      'root: ' + RootFolder + sLineBreak +
      'pattern: reviewable source files' + sLineBreak +
      'budget: one glob';

    if not ConfirmToolCall(Browser, Display, Inspector.Name, 'glob', GlobDetails) then
      begin
        Report.AppendLine('glob: denied by operator.');
        Result := Report.ToString;
        Exit;
      end;

    var FileList := TStringBuilder.Create;
    try
      for var FullPath in Files do
        FileList.AppendLine(
          TOpenAIProjectReviewPrompt.LocalRelativePath(RootFolder, FullPath));

      var GlobKey := 'tool:glob:' + TGUID.NewGuid.ToString;
      Display.ToolUse(GlobKey, 'glob');
      Display.ToolResult(GlobKey, 'glob', FileList.ToString);

      Report.AppendLine('glob: allowed.');
      Report.AppendLine(FileList.ToString);
    finally
      FileList.Free;
    end;

    var StopRequested := False;
    var ReadFiles := SelectReadFiles(Files);
    if Length(ReadFiles) > 0 then
      Display.AssistantText('Let me read key files to prepare the review:');

    for var FullPath in ReadFiles do
      begin
        var Relative := TOpenAIProjectReviewPrompt.LocalRelativePath(
          RootFolder,
          FullPath);
        var ReadDetails :=
          'path: ' + Relative + sLineBreak +
          Format('budget: up to %d read calls', [MAX_SUPERVISED_READS]);

        if not ConfirmToolCall(Browser, Display, Inspector.Name, 'read', ReadDetails) then
          begin
            Report.AppendLine('read ' + Relative + ': denied by operator.');
            StopRequested := True;
            Break;
          end;

        var Preview := ReadFilePreview(FullPath);
        var ReadTitle := 'read ' + Relative;
        var ReadKey := 'tool:read:' + TGUID.NewGuid.ToString;
        Display.ToolUse(ReadKey, ReadTitle);
        Display.ToolResult(ReadKey, ReadTitle, Preview);

        Report.AppendLine('--- read: ' + Relative + ' ---');
        Report.AppendLine(Preview);
        Report.AppendLine;
      end;

    if not StopRequested then
      begin
        var Keyword := 'TODO';
        Display.AssistantText(
          'Let me run one targeted search before the final review:');

        var GrepDetails :=
          'keyword: ' + Keyword + sLineBreak +
          'scope: reviewable source files' + sLineBreak +
          'budget: at most one grep';

        if ConfirmToolCall(Browser, Display, Inspector.Name, 'grep', GrepDetails) then
          begin
            var GrepResult := GrepFiles(RootFolder, Files, Keyword);
            var GrepTitle := 'grep ' + Keyword;
            var GrepKey := 'tool:grep:' + TGUID.NewGuid.ToString;
            Display.ToolUse(GrepKey, GrepTitle);
            Display.ToolResult(GrepKey, GrepTitle, GrepResult);
            Report.AppendLine('--- grep: ' + Keyword + ' ---');
            Report.AppendLine(GrepResult);
          end
        else
          Report.AppendLine('grep ' + Keyword + ': denied by operator.');
      end;

    Result := Report.ToString;
  finally
    Report.Free;
    Display.Free;
  end;
end;

class function TOpenAIProjectSupervisedExplorer.FileScore(
  const FullPath: string): Integer;
begin
  var Name := TPath.GetFileName(FullPath).ToLowerInvariant;
  var Ext := TPath.GetExtension(FullPath).ToLowerInvariant;

  Result := 0;
  if Ext = '.dpr' then
    Inc(Result, 100);
  if SameText(Name, 'main.pas') then
    Inc(Result, 90);
  if Name.Contains('service') then
    Inc(Result, 60);
  if Name.Contains('turn') then
    Inc(Result, 50);
  if Name.Contains('context') then
    Inc(Result, 40);
  if Name.Contains('agent') then
    Inc(Result, 30);
  if Ext = '.pas' then
    Inc(Result, 10);
end;

class function TOpenAIProjectSupervisedExplorer.GrepFiles(
  const RootFolder: string;
  const Files: TArray<string>;
  const Keyword: string): string;
begin
  var Builder := TStringBuilder.Create;
  try
    var Count := 0;
    for var FullPath in Files do
      begin
        if Count >= MAX_SUPERVISED_GREP_RESULTS then
          Break;

        var Text := '';
        try
          Text := TFileIOHelper.LoadFromFile(FullPath);
        except
          Continue;
        end;

        var Lines := TStringList.Create;
        try
          Lines.Text := Text;
          for var index := 0 to Lines.Count - 1 do
            begin
              if Count >= MAX_SUPERVISED_GREP_RESULTS then
                Break;

              if ContainsText(Lines[index], Keyword) then
                begin
                  Builder.AppendLine(Format(
                    '%s:%d: %s',
                    [
                      TOpenAIProjectReviewPrompt.LocalRelativePath(
                        RootFolder,
                        FullPath),
                      index + 1,
                      Lines[index].Trim
                    ]));
                  Inc(Count);
                end;
            end;
        finally
          Lines.Free;
        end;
      end;

    if Count = 0 then
      Builder.AppendLine('No match.');

    Result := Builder.ToString;
  finally
    Builder.Free;
  end;
end;

class function TOpenAIProjectSupervisedExplorer.ReadFilePreview(
  const FullPath: string): string;
begin
  try
    Result := TFileIOHelper.LoadFromFile(FullPath);
    if Result.Length > MAX_SUPERVISED_FILE_CHARS then
      Result := Copy(Result, 1, MAX_SUPERVISED_FILE_CHARS) +
        sLineBreak + '[truncated]';
  except
    on E: Exception do
      Result := '[unable to read file: ' + E.Message + ']';
  end;
end;

class function TOpenAIProjectSupervisedExplorer.SelectReadFiles(
  const Files: TArray<string>): TArray<string>;
begin
  Result := [];

  var Ranked := TStringList.Create;
  try
    for var FullPath in Files do
      Ranked.Add(Format('%.4d|%s', [1000 - FileScore(FullPath), FullPath]));

    Ranked.Sort;

    for var index := 0 to Ranked.Count - 1 do
      begin
        if Length(Result) >= MAX_SUPERVISED_READS then
          Break;

        var Item := Ranked[index];
        var PipeAt := Item.IndexOf('|');
        if PipeAt >= 0 then
          Result := Result + [Item.Substring(PipeAt + 1)];
      end;
  finally
    Ranked.Free;
  end;
end;

{ TOpenAIProjectReviewUploadContext }

constructor TOpenAIProjectReviewUploadContext.Create(
  const Client: IGenAI;
  const Browser: IPythiaBrowser;
  const Blocks: IPythiaDisplayBlockAggregator;
  const RootFolder, UserText: string;
  const Def: TOpenAIAgentCardDefinition;
  const Inspector: TOpenAIAgentDef;
  const Files: TArray<string>;
  const Resolve: TProc<TOpenAIProjectReviewContext>;
  const Reject: TProc<Exception>);
begin
  inherited Create;

  if not Assigned(Client) then
    raise Exception.Create('OpenAI client is not available for project upload.');

  FClient := Client;
  FBrowser := Browser;
  FBlocks := Blocks;
  FRootFolder := RootFolder;
  FUserText := UserText;
  FDef := Def;
  FInspector := Inspector;
  FFiles := Files;
  FResolve := Resolve;
  FReject := Reject;
  FResult := Default(TOpenAIProjectReviewContext);
  FDisplay := TOpenAIAgentTurnDisplay.Create(FBrowser, FBlocks);
end;

procedure TOpenAIProjectReviewUploadContext.DisplayStatus(const Text: string);
begin
  if Assigned(FDisplay) then
    FDisplay.Status(Text);
end;

procedure TOpenAIProjectReviewUploadContext.DisplayToolOutput(
  const Title, Text: string);
begin
  if not Assigned(FDisplay) then
    Exit;

  var Key := 'upload:' + TGUID.NewGuid.ToString;
  FDisplay.ToolUse(Key, Title);
  FDisplay.ToolResult(Key, Title, Text);
end;

function TOpenAIProjectReviewUploadContext.UsesSupervisedPolicy: Boolean;
begin
  Result := TOpenAIProjectReviewPrompt.HasEnabledProjectToolPolicy(
    FInspector,
    'always_ask');
end;

function TOpenAIProjectReviewUploadContext.IsSafeCodePatch: Boolean;
begin
  Result := SameText(FDef.CardId, 'openai-safe-code-patch');
end;

function TOpenAIProjectReviewUploadContext.IsSandboxToLocalCodeEdit: Boolean;
begin
  Result := SameText(FDef.CardId, 'openai-sandbox-to-local-code-edit');
end;

procedure TOpenAIProjectReviewUploadContext.CompleteOne(
  Index: Integer;
  const FileId, RelativePath: string);
begin
  if FSettled then
    Exit;

  FResult.FileIds := FResult.FileIds + [FileId];
  FResult.RelativePaths := FResult.RelativePaths + [RelativePath];

  DispatchAt(Index + 1);
end;

procedure TOpenAIProjectReviewUploadContext.DispatchAt(Index: Integer);
var
  Ctx: IOpenAIProjectReviewUploadContext;
  FullPath: string;
  Relative: string;
begin
  if FSettled then
    Exit;

  if Index = 0 then
    begin
      if Assigned(FDisplay) then
        begin
          if not UsesSupervisedPolicy then
            begin
              if IsSafeCodePatch then
                FDisplay.AssistantText('Starting safe code patch proposal...')
              else
              if IsSandboxToLocalCodeEdit then
                FDisplay.AssistantText('Starting sandbox-to-local code edit...')
              else
                FDisplay.AssistantText('Starting local project review...');
            end;

          FDisplay.Status('Selected project folder', FRootFolder);
          FDisplay.Status(
            'Reviewable project files found',
            Format('%d', [Length(FFiles)]));

          if not UsesSupervisedPolicy then
            begin
              if IsSafeCodePatch then
                FDisplay.AssistantText(
                  'Let me upload the selected project files so code_interpreter can inspect them without editing your disk.')
              else
              if IsSandboxToLocalCodeEdit then
                FDisplay.AssistantText(
                  'Let me upload the selected project files as a controlled workspace copy for code_interpreter.')
              else
                FDisplay.AssistantText(
                  'Let me upload the selected project files for code_interpreter analysis.');
            end;

          FDisplay.Status(
            'Uploading project files',
            Format('0/%d', [Length(FFiles)]));
        end;
    end;

  if Index > High(FFiles) then
    begin
      ResolveIfDone;
      Exit;
    end;

  FullPath := FFiles[Index];
  Relative := TOpenAIProjectReviewPrompt.LocalRelativePath(
    FRootFolder,
    FullPath);

  DisplayToolOutput(
    Format('Uploading project file (%d/%d)', [
      Index + 1,
      Length(FFiles)]),
    Relative + sLineBreak);

  Ctx := Self;

  try
    FClient.Files.AsyncAwaitUpload(
        procedure (Params: TFileUploadParams)
        begin
          Params
            .&File(FullPath)
            .Purpose(TFilesPurpose.user_data)
            .ExpiresAfter(UPLOADED_FILE_EXPIRES_AFTER_SECONDS);
        end)
      .&Then(
        procedure (Value: GenAI.TFile)
        begin
          try
            Ctx.CompleteOne(Index, Value.Id, Relative);
          except
            on E: Exception do
              Ctx.RejectWith(
                Format('Project file upload completion failed (%s): %s',
                  [Relative, E.Message]));
          end;
        end)
      .&Catch(
        procedure (E: Exception)
        begin
          Ctx.RejectWith(
            Format('Project file upload failed (%s): %s',
              [Relative, E.Message]));
        end);
  except
    on E: Exception do
      RejectWith(
        Format('Project file upload dispatch failed (%s): %s',
          [Relative, E.Message]));
  end;
end;

procedure TOpenAIProjectReviewUploadContext.RejectWith(
  const Message: string);
var
  Reject: TProc<Exception>;
begin
  if FSettled then
    Exit;

  FSettled := True;
  Reject := FReject;

  DisplayStatus(Message);

  ReleaseReferences;

  if Assigned(Reject) then
    Reject(Exception.Create(Message));
end;

procedure TOpenAIProjectReviewUploadContext.ReleaseReferences;
begin
  FClient := nil;
  FBrowser := nil;
  FBlocks := nil;
  FreeAndNil(FDisplay);
  FRootFolder := '';
  FUserText := '';
  FDef := Default(TOpenAIAgentCardDefinition);
  FInspector := Default(TOpenAIAgentDef);
  FFiles := nil;
  FResult.Prompt := '';
  FResult.FileIds := nil;
  FResult.RelativePaths := nil;
  FResolve := nil;
  FReject := nil;
end;

procedure TOpenAIProjectReviewUploadContext.ResolveIfDone;
var
  Context: TOpenAIProjectReviewContext;
  Resolve: TProc<TOpenAIProjectReviewContext>;
begin
  if FSettled then
    Exit;

  FSettled := True;

  FResult.Prompt := TOpenAIProjectReviewPrompt.BuildPromptForCard(
    FUserText,
    FRootFolder,
    FDef,
    FInspector,
    FResult.RelativePaths,
    FResult.FileIds,
    '');

  if Assigned(FDisplay) then
    begin
      if not UsesSupervisedPolicy then
        begin
          if IsSafeCodePatch then
            FDisplay.AssistantText(
              'The project files are uploaded. I will now locate the patch area, draft a diff, and review it before returning it.')
          else
          if IsSandboxToLocalCodeEdit then
            FDisplay.AssistantText(
              'The controlled workspace copy is ready. I will now locate the change, prepare the diff, and return the local apply blocks.')
          else
            FDisplay.AssistantText(
              'The project files are uploaded. I will now ask code_interpreter to inspect them.');
        end;

      FDisplay.Status(
        'OpenAI code_interpreter files ready',
        Format('%d/%d', [Length(FResult.FileIds), Length(FFiles)]));
    end;

  Context := FResult;
  Resolve := FResolve;
  ReleaseReferences;

  if Assigned(Resolve) then
    Resolve(Context);
end;

class function TOpenAIProjectReviewPrompt.LocalRelativePath(
  const RootFolder, FullPath: string): string;
begin
  var Root := IncludeTrailingPathDelimiter(TPath.GetFullPath(RootFolder));
  var Path := TPath.GetFullPath(FullPath);

  if StartsText(Root, Path) then
    Result := Copy(Path, Length(Root) + 1, MaxInt)
  else
    Result := Path;

  Result := Result.Replace('\', '/');
end;

end.
