unit GenAI.Chat.StreamingCallback;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGenAI
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.SysUtils, System.Classes, REST.Json, System.Net.HttpClient, GenAI.Chat.StreamingInterface,
  GenAI.API;

type
  TStreamCallback<T: class, constructor> = class(TInterfacedObject, IStreamCallback)
  private
    FResponse: TStringStream;
    FLineFeedPosition: Integer;
    FEvent: TStreamCallbackEvent<T>;
    FParser: TParserMethod<T>;
    function GetOnStream: TReceiveDataCallback;
  public
    constructor Create(AResponse: TStringStream; AEvent: TStreamCallbackEvent<T>; AParser: TParserMethod<T>);
    class function CreateInstance(AResponse: TStringStream; AEvent: TStreamCallbackEvent<T>; AParser: TParserMethod<T>): IStreamCallback;
  end;

implementation

{ TStreamCallback<T> }

constructor TStreamCallback<T>.Create(AResponse: TStringStream; AEvent: TStreamCallbackEvent<T>;
  AParser: TParserMethod<T>);
begin
  inherited Create;
  FResponse := AResponse;
  FLineFeedPosition := 0;
  FEvent := AEvent;
  FParser := AParser;
end;

class function TStreamCallback<T>.CreateInstance(AResponse: TStringStream;
  AEvent: TStreamCallbackEvent<T>; AParser: TParserMethod<T>): IStreamCallback;
begin
  Result := TStreamCallback<T>.Create(AResponse, AEvent, AParser);
end;

function TStreamCallback<T>.GetOnStream: TReceiveDataCallback;
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
                  Chunk := FParser(ParsedData);
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
