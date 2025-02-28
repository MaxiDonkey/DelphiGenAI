unit GenAI.Chat.Parallel;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections, System.SyncObjs, System.Threading,
  GenAI.Types, GenAI.Parallel.Params, GenAI.Async.Support;

type
  TBundleItem = class
  private
    FIndex: Integer;
    FFinishIndex: Integer;
    FPrompt: string;
    FResponse: string;
    FChat: TObject;
  public
    property Index: Integer read FIndex write FIndex;
    property FinishIndex: Integer read FFinishIndex write FFinishIndex;
    property Prompt: string read FPrompt write FPrompt;
    property Response: string read FResponse write FResponse;
    property Chat: TObject read FChat write FChat;
    destructor Destroy; override;
  end;

  TBundleList = class
  private
    FItems: TObjectList<TBundleItem>;
  public
    constructor Create;
    destructor Destroy; override;
    function Add(const AIndex: Integer): TBundleItem;
    function Item(const AIndex: Integer): TBundleItem;
    function Count: Integer;
    property Items: TObjectList<TBundleItem> read FItems write FItems;
  end;

  TAsynBuffer = TAsynCallBack<TBundleList>;

  TTaskHelper = class
  public
    class procedure ContinueWith(const Task: ITask; const NextAction: TProc; const TimeOut: Cardinal = 120000);
  end;

  TBundleParams = class(TParameters)
  public
    function Prompts(const Value: TArray<string>): TBundleParams;
    function Model(const Value: string): TBundleParams;
    function ReasoningEffort(const Value: TReasoningEffort): TBundleParams;
    constructor Create;
  end;

implementation

{ TBundleList }

function TBundleList.Add(const AIndex: Integer): TBundleItem;
begin
  Result := TBundleItem.Create;
  Result.Index := AIndex;
  FItems.Add(Result);
end;

function TBundleList.Count: Integer;
begin
  Result := FItems.Count;
end;

constructor TBundleList.Create;
begin
  inherited Create;
  FItems := TObjectList<TBundleItem>.Create(True);
end;

destructor TBundleList.Destroy;
begin
  FItems.Free;
  inherited;
end;

function TBundleList.Item(const AIndex: Integer): TBundleItem;
begin
  if (AIndex < 0) or (AIndex > Pred(Count)) then
    raise Exception.Create('Index out of bounds');
  Result := FItems.Items[AIndex];
end;

{ TTaskHelper }

class procedure TTaskHelper.ContinueWith(const Task: ITask;
  const NextAction: TProc; const TimeOut: Cardinal);
begin
  TTask.Run(
    procedure
    begin
      {--- Wait for the task to complete within TimeOut ms }
      Task.Wait(TimeOut);

      {--- Execute the sequence in the main thread }
      TThread.Queue(nil,
        procedure
        begin
          NextAction();
        end);
    end);
end;

{ TBundleParams }

constructor TBundleParams.Create;
begin
  inherited Create;
  Model('gpt-4o-mini');
  ReasoningEffort(TReasoningEffort.medium);
end;

function TBundleParams.Model(const Value: string): TBundleParams;
begin
  Result := TBundleParams(Add('model', Value));
end;

function TBundleParams.Prompts(const Value: TArray<string>): TBundleParams;
begin
  Result := TBundleParams(Add('prompts', Value));
end;

function TBundleParams.ReasoningEffort(
  const Value: TReasoningEffort): TBundleParams;
begin
  Result := TBundleParams(Add('reasoningEffort', Value.ToString));
end;

{ TBundleItem }

destructor TBundleItem.Destroy;
begin
  if Assigned(FChat) then
    FChat.Free;
  inherited;
end;

end.
