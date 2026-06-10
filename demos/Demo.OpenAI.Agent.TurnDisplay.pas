unit Demo.OpenAI.Agent.TurnDisplay;

interface

uses
  System.Classes,
  WVPythia.Chat.Interfaces, WVPythia.Chat.DisplayBlocks;

type
  TOpenAIAgentTurnDisplay = class
  private
    FBrowser: IPythiaBrowser;
    FBlocks: IPythiaDisplayBlockAggregator;

    procedure Sync(const AsynProc: TThreadProcedure);
  public
    constructor Create(
      const Browser: IPythiaBrowser;
      const Blocks: IPythiaDisplayBlockAggregator);

    procedure AssistantText(
      const Text: string;
      const CloseBlock: Boolean = True);
    procedure Status(const Title: string); overload;
    procedure Status(const Title, Detail: string); overload;
    procedure ToolUse(
      const Key, Title: string;
      const NotifyBrowser: Boolean = True);
    procedure ToolResult(
      const Key, Title, Output: string;
      const IsError: Boolean = False);
    procedure ToolResultStatus(
      const Key, Title, Output: string);
  end;

implementation

{$REGION 'Dev note'}
(*

  Agent-turn display adapter for the pythia-openai FMX demo.

  OpenAI agent examples can emit demo-side progress before and around the
  actual Responses stream: workspace upload, supervised project tools,
  confirmation decisions, and local-apply outcomes. This small adapter keeps
  those pedagogical steps in one display vocabulary.

  Every method updates two surfaces when available:

    - the live WebView chat UI through IPythiaBrowser;
    - the Pythia display-block aggregator so the same steps are persisted and
      replayed when a session is reloaded.

  ToolUse and ToolResult should be preferred for anything that must reload as
  a complete tool block. Status is intended for lightweight milestones.

*)
{$ENDREGION}

uses
  Winapi.Windows,
  System.SysUtils;

{ TOpenAIAgentTurnDisplay }

constructor TOpenAIAgentTurnDisplay.Create(
  const Browser: IPythiaBrowser;
  const Blocks: IPythiaDisplayBlockAggregator);
begin
  inherited Create;
  FBrowser := Browser;
  FBlocks := Blocks;
end;

procedure TOpenAIAgentTurnDisplay.Sync(const AsynProc: TThreadProcedure);
begin
  if not Assigned(FBrowser) or not Assigned(AsynProc) then
    Exit;

  if GetCurrentThreadId = MainThreadID then
    AsynProc()
  else
    TThread.Synchronize(nil, AsynProc);
end;

procedure TOpenAIAgentTurnDisplay.AssistantText(
  const Text: string;
  const CloseBlock: Boolean);
begin
  if Text.Trim.IsEmpty then
    Exit;

  if Assigned(FBlocks) then
    begin
      FBlocks.AppendAssistantDelta(Text);
      if CloseBlock then
        FBlocks.CloseCurrent;
    end;

  Sync(
    procedure
    begin
      FBrowser.DisplayStream(Text + sLineBreak + sLineBreak, '', False);
    end);
end;

procedure TOpenAIAgentTurnDisplay.Status(const Title: string);
begin
  Status(Title, '');
end;

procedure TOpenAIAgentTurnDisplay.Status(
  const Title, Detail: string);
begin
  if Assigned(FBlocks) then
    FBlocks.AppendStatus(Title, Detail);

  Sync(
    procedure
    begin
      FBrowser.DisplayToolStatus(Title, False);
      if not Detail.Trim.IsEmpty then
        FBrowser.DisplayToolOutputStream(Detail + sLineBreak, False);
    end);
end;

procedure TOpenAIAgentTurnDisplay.ToolUse(
  const Key, Title: string;
  const NotifyBrowser: Boolean);
begin
  if Assigned(FBlocks) then
    FBlocks.AppendToolUse(Key, Title);

  if not NotifyBrowser then
    Exit;

  Sync(
    procedure
    begin
      FBrowser.DisplayToolStatus(Title, False);
    end);
end;

procedure TOpenAIAgentTurnDisplay.ToolResult(
  const Key, Title, Output: string;
  const IsError: Boolean);
begin
  if Assigned(FBlocks) then
    begin
      FBlocks.AppendToolResult(Key, Output, IsError);
      FBlocks.CloseCurrent;
    end;

  if Output.Trim.IsEmpty then
    Exit;

  Sync(
    procedure
    begin
      if IsError then
        FBrowser.DisplayToolError(Title, Output, False)
      else
        FBrowser.DisplayToolOutputStream(Output + sLineBreak, False);
    end);
end;

procedure TOpenAIAgentTurnDisplay.ToolResultStatus(
  const Key, Title, Output: string);
begin
  if Assigned(FBlocks) then
    begin
      FBlocks.AppendToolResult(Key, Output, False);
      FBlocks.CloseCurrent;
    end;

  Sync(
    procedure
    begin
      FBrowser.DisplayToolStatus(Title, False);
      if not Output.Trim.IsEmpty then
        FBrowser.DisplayToolOutputStream(Output + sLineBreak, False);
    end);
end;

end.
