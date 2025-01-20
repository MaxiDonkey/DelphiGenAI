unit GenAI.Chat.StreamingOpenAI;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGenAI
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.SysUtils, System.Classes, REST.Json, System.Net.HttpClient, GenAI.Chat.StreamingInterface,
  GenAI.API;

type
  TOpenAIStream<T: class, constructor> = class(TInterfacedObject, IStreamCallback)
  private
    FResponse: TStringStream;
    FLineFeedPosition: Integer;
    FEvent: TStreamCallbackEvent<T>;
    FParseFunc: TParserMethod<T>;
    function GetOnStream: TReceiveDataCallback;
  public
    constructor Create(AResponse: TStringStream; AEvent: TStreamCallbackEvent<T>; AParser: TParserMethod<T>);
    class function CreateInstance(AResponse: TStringStream; AEvent: TStreamCallbackEvent<T>; AParser: TParserMethod<T>): IStreamCallback;
  end;

implementation

{ TOpenAIStream<T> }

constructor TOpenAIStream<T>.Create(AResponse: TStringStream; AEvent: TStreamCallbackEvent<T>;
  AParser: TParserMethod<T>);
begin
  inherited Create;
  FResponse := AResponse;
  FLineFeedPosition := 0;
  FEvent := AEvent;
  FParseFunc := AParser;
end;

class function TOpenAIStream<T>.CreateInstance(AResponse: TStringStream;
  AEvent: TStreamCallbackEvent<T>; AParser: TParserMethod<T>): IStreamCallback;
begin
  Result := TOpenAIStream<T>.Create(AResponse, AEvent, AParser);
end;

function TOpenAIStream<T>.GetOnStream: TReceiveDataCallback;

{--- Refer to https://platform.openai.com/docs/api-reference/chat/streaming }

// The chat completion chunk object
// data: {"id":"chatcmpl-123","object":"chat.completion.chunk","created":1694268190,"model":"gpt-4o-mini", "system_fingerprint": "fp_44709d6fcb", "choices":[{"index":0,"delta":{"role":"assistant","content":""},"logprobs":null,"finish_reason":null}]}
// data: {"id":"chatcmpl-123","object":"chat.completion.chunk","created":1694268190,"model":"gpt-4o-mini", "system_fingerprint": "fp_44709d6fcb", "choices":[{"index":0,"delta":{"content":"Hello"},"logprobs":null,"finish_reason":null}]}
// ...

begin
  Result :=
    procedure (const Sender: TObject; AContentLength,
      AReadCount: Int64; var AAbort: Boolean)
    var
      ResponseBuffer: string;
      CurrentLine: string;
      IsDone: Boolean;
      ParsedData: string;
      Chunk: T;
      LineFeed: Integer;
    begin
      try
        try
          ResponseBuffer := FResponse.DataString;
        except
          on E: EEncodingError do
            Exit;
        end;

        LineFeed := ResponseBuffer.IndexOf(#10, FLineFeedPosition);
        while LineFeed >= 0 do
          begin
            CurrentLine := ResponseBuffer.Substring(FLineFeedPosition, LineFeed - FLineFeedPosition);
            FLineFeedPosition := LineFeed + 1;

            if CurrentLine.IsEmpty or CurrentLine.StartsWith(#10) then
              begin
                LineFeed := ResponseBuffer.IndexOf(#10, FLineFeedPosition);
                Continue;
              end;

            ParsedData := CurrentLine.Replace('data: ', '').Trim([' ', #13, #10]);
            IsDone := ParsedData.ToUpper = '[DONE]';

            Chunk := nil;
            if not IsDone then
              begin
                try
                  Chunk := FParseFunc(ParsedData);
                except
                  on E: Exception do
                  Chunk := nil;
                end;
              end;

            if Assigned(FEvent) then
              begin
                try
                  FEvent(Chunk, IsDone, AAbort);
                finally
                  Chunk.Free;
                end;
              end;

            if IsDone then
              Break;

            LineFeed := ResponseBuffer.IndexOf(#10, FLineFeedPosition);
        end;

        except
          on E: Exception do
            raise;
        end;
    end;
end;

end.
