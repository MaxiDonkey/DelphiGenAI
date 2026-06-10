unit WVPythia.Chat.DisplayBlocks;

interface

uses
  System.SysUtils, System.Generics.Collections,
  WVPythia.Chat.Interfaces, WVPythia.ChatSession.Controller;

type
  {--- Vendor-neutral live accumulator for the display blocks persisted by
       Pythia. Vendors should translate their own stream events into these
       operations instead of exposing vendor snapshots to Pythia. }
  IPythiaDisplayBlockAggregator = interface(IPythiaDisplayBlockSnapshot)
    ['{7318E843-5D1B-4C20-B371-69BDB8C1AF60}']
    procedure AppendAssistantDelta(const Delta: string);
    procedure AppendReasoningDelta(const Delta: string);
    procedure AppendToolResultDelta(const Delta: string);
    procedure AppendToolUse(const Title: string); overload;
    procedure AppendToolUse(const ToolUseId, Title: string); overload;
    procedure AppendToolResult(const Text: string); overload;
    procedure AppendToolResult(const ToolUseId, Text: string;
      const IsError: Boolean = False); overload;
    procedure AppendStatus(const Title: string); overload;
    procedure AppendStatus(const Title, Text: string); overload;
    procedure AppendAssistantText(const Text: string);
    procedure MarkToolError(const ToolUseId: string);
    procedure CloseCurrent;
    function CloneAll: TArray<TChatDisplayBlock>;
    function IsEmpty: Boolean;
  end;

  TPythiaDisplayBlockAggregator = class(
    TInterfacedObject, IPythiaDisplayBlockAggregator)
  private
    FBlocks: TArray<TChatDisplayBlock>;
    FCurrent: TChatDisplayBlock;
    FCurrentToolEntry: TChatDisplayBlock;
    FToolEntriesById: TDictionary<string, TChatDisplayBlock>;

    function StartBlock(const Kind: string): TChatDisplayBlock;
    procedure EnsureKind(const Kind: string);
    function FindToolEntry(
      const ToolUseId: string;
      out Block: TChatDisplayBlock): Boolean;
  public
    constructor Create;
    destructor Destroy; override;

    procedure AppendAssistantDelta(const Delta: string);
    procedure AppendReasoningDelta(const Delta: string);
    procedure AppendToolResultDelta(const Delta: string);
    procedure AppendToolUse(const Title: string); overload;
    procedure AppendToolUse(const ToolUseId, Title: string); overload;
    procedure AppendToolResult(const Text: string); overload;
    procedure AppendToolResult(const ToolUseId, Text: string;
      const IsError: Boolean = False); overload;
    procedure AppendStatus(const Title: string); overload;
    procedure AppendStatus(const Title, Text: string); overload;
    procedure AppendAssistantText(const Text: string);
    procedure MarkToolError(const ToolUseId: string);
    procedure CloseCurrent;
    function CloneAll: TArray<TChatDisplayBlock>;
    function CloneDisplayBlocks: TArray<TChatDisplayBlock>;
    function IsEmpty: Boolean;
  end;

implementation

uses
  WVPythia.Chat.Consts;

{ TPythiaDisplayBlockAggregator }

constructor TPythiaDisplayBlockAggregator.Create;
begin
  inherited Create;
  FToolEntriesById := TDictionary<string, TChatDisplayBlock>.Create;
end;

destructor TPythiaDisplayBlockAggregator.Destroy;
begin
  FToolEntriesById.Free;
  FreeChatDisplayBlocks(FBlocks);
  inherited;
end;

function TPythiaDisplayBlockAggregator.StartBlock(
  const Kind: string): TChatDisplayBlock;
begin
  Result := TChatDisplayBlock.Create;
  Result.Kind := Kind;
  FBlocks := FBlocks + [Result];
  FCurrent := Result;
end;

procedure TPythiaDisplayBlockAggregator.EnsureKind(const Kind: string);
begin
  {--- Merge consecutive same-kind deltas into a single block; switch
       otherwise. }
  if not Assigned(FCurrent) or not SameText(FCurrent.Kind, Kind) then
    StartBlock(Kind);
end;

function TPythiaDisplayBlockAggregator.FindToolEntry(
  const ToolUseId: string;
  out Block: TChatDisplayBlock): Boolean;
begin
  Block := nil;
  var Key := ToolUseId.Trim;
  Result :=
    (not Key.IsEmpty) and
    Assigned(FToolEntriesById) and
    FToolEntriesById.TryGetValue(Key, Block) and
    Assigned(Block);
end;

procedure TPythiaDisplayBlockAggregator.AppendAssistantDelta(
  const Delta: string);
begin
  if Delta.IsEmpty then
    Exit;

  EnsureKind(DISPLAY_BLOCK_KIND_ASSISTANT);
  FCurrent.Text := FCurrent.Text + Delta;
end;

procedure TPythiaDisplayBlockAggregator.AppendAssistantText(
  const Text: string);
begin
  if Text.IsEmpty then
    Exit;

  EnsureKind(DISPLAY_BLOCK_KIND_ASSISTANT);
  FCurrent.Text := FCurrent.Text + Text;
end;

procedure TPythiaDisplayBlockAggregator.AppendReasoningDelta(
  const Delta: string);
begin
  if Delta.IsEmpty then
    Exit;

  EnsureKind(DISPLAY_BLOCK_KIND_REASONING);
  FCurrent.Text := FCurrent.Text + Delta;
end;

procedure TPythiaDisplayBlockAggregator.AppendToolResultDelta(
  const Delta: string);
begin
  if Delta.IsEmpty then
    Exit;

  {--- Stream the result text into the current tool entry. Fall back to a
       standalone output block when a vendor sends output without a prior tool
       use event. }
  if not Assigned(FCurrentToolEntry) then
    begin
      FCurrentToolEntry := StartBlock(DISPLAY_BLOCK_KIND_TOOL_OUTPUT);
      FCurrent := FCurrentToolEntry;
    end;

  FCurrentToolEntry.Text := FCurrentToolEntry.Text + Delta;
  FCurrent := FCurrentToolEntry;
end;

procedure TPythiaDisplayBlockAggregator.AppendToolUse(const Title: string);
begin
  AppendToolUse('', Title);
end;

procedure TPythiaDisplayBlockAggregator.AppendToolUse(
  const ToolUseId, Title: string);
begin
  {--- Opens a tool block. The matching tool result is merged into this block
       so one persisted entry carries both the tool identity and its output. }
  var Block := StartBlock(DISPLAY_BLOCK_KIND_TOOL_STATUS);
  Block.Title := Title;
  FCurrentToolEntry := Block;

  var Key := ToolUseId.Trim;
  if not Key.IsEmpty then
    FToolEntriesById.AddOrSetValue(Key, Block);
end;

procedure TPythiaDisplayBlockAggregator.AppendToolResult(const Text: string);
begin
  {--- Merge the output into the open tool entry, then close the pairing.
       Fall back to a standalone output block when no tool use preceded it. }
  if Assigned(FCurrentToolEntry) then
    begin
      if not Text.IsEmpty then
        FCurrentToolEntry.Text := FCurrentToolEntry.Text + Text;
      FCurrentToolEntry := nil;
      FCurrent := nil;
    end
  else
  if not Text.IsEmpty then
    begin
      var Block := StartBlock(DISPLAY_BLOCK_KIND_TOOL_OUTPUT);
      Block.Text := Text;
    end;
end;

procedure TPythiaDisplayBlockAggregator.AppendToolResult(
  const ToolUseId, Text: string;
  const IsError: Boolean);
var
  Block: TChatDisplayBlock;
begin
  var Output := Text;

  if FindToolEntry(ToolUseId, Block) then
    begin
      if IsError then
        Block.Kind := DISPLAY_BLOCK_KIND_TOOL_ERROR;

      if not Output.IsEmpty then
        Block.Text := Block.Text + Output;

      if FCurrentToolEntry = Block then
        FCurrentToolEntry := nil;

      FCurrent := Block;
      Exit;
    end;

  if IsError and Output.IsEmpty then
    Output := 'Tool call failed.';

  if not Output.IsEmpty then
    begin
      Block := StartBlock(DISPLAY_BLOCK_KIND_TOOL_OUTPUT);
      if IsError then
        Block.Kind := DISPLAY_BLOCK_KIND_TOOL_ERROR;
      Block.Text := Output;
    end;
end;

procedure TPythiaDisplayBlockAggregator.MarkToolError(
  const ToolUseId: string);
var
  Block: TChatDisplayBlock;
begin
  if FindToolEntry(ToolUseId, Block) then
    Block.Kind := DISPLAY_BLOCK_KIND_TOOL_ERROR
  else
  if Assigned(FCurrentToolEntry) then
    FCurrentToolEntry.Kind := DISPLAY_BLOCK_KIND_TOOL_ERROR;
end;

procedure TPythiaDisplayBlockAggregator.AppendStatus(const Title: string);
begin
  AppendStatus(Title, '');
end;

procedure TPythiaDisplayBlockAggregator.AppendStatus(
  const Title, Text: string);
begin
  {--- Standalone informational status block. No result pairing is kept. }
  var Block := StartBlock(DISPLAY_BLOCK_KIND_TOOL_STATUS);
  Block.Title := Title;
  Block.Text := Text;
  FCurrentToolEntry := nil;
end;

procedure TPythiaDisplayBlockAggregator.CloseCurrent;
begin
  FCurrent := nil;
  FCurrentToolEntry := nil;
end;

function TPythiaDisplayBlockAggregator.CloneAll: TArray<TChatDisplayBlock>;
begin
  Result := CloneChatDisplayBlocks(FBlocks);
end;

function TPythiaDisplayBlockAggregator.CloneDisplayBlocks:
  TArray<TChatDisplayBlock>;
begin
  Result := CloneAll;
end;

function TPythiaDisplayBlockAggregator.IsEmpty: Boolean;
begin
  Result := Length(FBlocks) = 0;
end;

end.
