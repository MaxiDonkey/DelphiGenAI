unit GenAI.Responses.StreamEngine;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGenAI
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

{$REGION 'Dev note'}

(*
      Streaming event engine for the v1/responses endpoint. Modeled on
      Anthropic.Chat.StreamEngine: an IResponsesEventEngineManager drives the
      aggregation buffer (TResponsesEventData) and forwards each event to the
      IResponsesEventDispatcher.

      Unlike the Anthropic engine there is no per-event handler chain: the
      responses stream is already self-describing (each chunk is a fully typed
      TResponseStream with a known EventType), so a single Aggregate + Dispatch
      pass is enough and keeps the routing flat.
*)

{$ENDREGION}

uses
  System.SysUtils, System.Classes,
  GenAI.Types, GenAI.Responses.OutputParams, GenAI.Responses.StreamCallbacks;

type
  IResponsesEventEngineManager = interface
    ['{6F2C8A14-9B53-4D7E-A1C0-7E5B2F9D4A38}']
    function AggregateStreamEvents(const Chunk: TResponseStream;
      var Buffer: TResponsesEventData): Boolean;
    function GetStreamEventDispatcher: IResponsesEventDispatcher;
  end;

  TResponsesEventEngineManagerFactory = class
    class function CreateInstance(
      const CallBacks: TFunc<TResponseStreamEventCallBack> = nil): IResponsesEventEngineManager;
  end;

  TResponsesEventEngineManager = class(TInterfacedObject, IResponsesEventEngineManager)
  private
    FDispatcher: IResponsesEventDispatcher;
  public
    constructor Create(const ADispatcher: IResponsesEventDispatcher = nil);
    function AggregateStreamEvents(const Chunk: TResponseStream;
      var Buffer: TResponsesEventData): Boolean;
    function GetStreamEventDispatcher: IResponsesEventDispatcher;
  end;

implementation

{ TResponsesEventEngineManagerFactory }

class function TResponsesEventEngineManagerFactory.CreateInstance(
  const CallBacks: TFunc<TResponseStreamEventCallBack>): IResponsesEventEngineManager;
begin
  Result := TResponsesEventEngineManager.Create(
    TResponsesEventDispatcher.Create(CallBacks));
end;

{ TResponsesEventEngineManager }

constructor TResponsesEventEngineManager.Create(
  const ADispatcher: IResponsesEventDispatcher);
begin
  inherited Create;
  FDispatcher := ADispatcher;
end;

function TResponsesEventEngineManager.AggregateStreamEvents(
  const Chunk: TResponseStream; var Buffer: TResponsesEventData): Boolean;
var
  CanContinue: Boolean;
begin
  if not Assigned(Chunk) then
    Exit(True);

  {--- Reset the buffer on the first event of a stream so a reused manager
       does not carry stale state between turns. }
  if Chunk.EventType = TResponseStreamType.created then
    Buffer := TResponsesEventData.Empty;

  CanContinue := True;
  Buffer.Aggregate(Chunk,
    procedure
    begin
      CanContinue := False;
    end);

  if Assigned(FDispatcher) then
    FDispatcher.DispatchEvent(Chunk.EventType, Buffer);

  Result := CanContinue;
end;

function TResponsesEventEngineManager.GetStreamEventDispatcher: IResponsesEventDispatcher;
begin
  Result := FDispatcher;
end;

end.
