unit GenAI.Chat.StreamingInterface;

interface

uses
  System.Net.HttpClient;

type
  TStreamCallbackEvent<T: class, constructor> = reference to procedure(var Chunk: T; IsDone: Boolean; var Cancel: Boolean);

  IStreamCallback = interface
    ['{4F5F8B0D-0A08-4C47-8675-48F8D055F504}']
    function GetOnStream: TReceiveDataCallback;
    property OnStream: TReceiveDataCallback read GetOnStream;
  end;

implementation

end.
