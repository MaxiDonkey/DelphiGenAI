unit GenAI.Messages;

interface

uses
  System.SysUtils, System.Classes, System.Threading, System.JSON, REST.Json.Types,
  REST.JsonReflect, System.Net.URLClient,
  GenAI.API.Params, GenAI.API, GenAI.Consts, GenAI.Types, GenAI.Async.Support,
  GenAI.Assistants, GenAI.Threads;

type
  TMessages = class
  private
    FId: string;
    [JsonNameAttribute('created_at')]
    FCreatedAt: Int64;
    FObject: string;
  public
    property Id: string read FId write FId;
    property CreatedAt: Int64 read FCreatedAt write FCreatedAt;
    property &Object: string read FObject write FObject;


  end;

  TMessagesRoute = class(TGenAIRoute)
    function Create(const ThreadId: string; const ParamProc: TProc<TThreadsMessageParams>): TMessages;
  end;

implementation

{ TMessagesRoute }

function TMessagesRoute.Create(const ThreadId: string;
  const ParamProc: TProc<TThreadsMessageParams>): TMessages;
begin
  Result := API.Post<TMessages, TThreadsMessageParams>('threads/' + ThreadId + '/messages', ParamProc);
end;

end.
