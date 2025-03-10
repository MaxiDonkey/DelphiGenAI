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
  /// <summary>
  /// Represents a streaming callback handler for OpenAI chat completions.
  /// </summary>
  /// <typeparam name="T">
  /// The type of the class that will be used to parse the streaming data.
  /// Must be a class with a parameterless constructor.
  /// </typeparam>
  TOpenAIStream<T: class, constructor> = class(TInterfacedObject, IStreamCallback)
  private
    FResponse: TStringStream;
    FLineFeedPosition: Integer;
    FEvent: TStreamCallbackEvent<T>;
    Parse: TParserMethod<T>;
    /// <summary>
    /// Gets the callback method that processes received streaming data.
    /// </summary>
    /// <returns>
    /// A <see cref="TReceiveDataCallback"/> delegate that handles the streaming data.
    /// </returns>
    function GetOnStream: TReceiveDataCallback;
  public
    /// <summary>
    /// Initializes a new instance of the <see cref="TOpenAIStream{T}"/> class.
    /// </summary>
    /// <param name="AResponse">
    /// A <see cref="TStringStream"/> that contains the streaming response data.
    /// </param>
    /// <param name="AEvent">
    /// A callback event that is triggered when a new chunk of data is received.
    /// </param>
    /// <param name="AParser">
    /// A method used to parse the incoming JSON data into an instance of type <typeparamref name="T"/>.
    /// </param>
    /// <exception cref="Exception">
    /// Thrown if the <paramref name="AParser"/> parameter is not assigned.
    /// </exception>
    constructor Create(AResponse: TStringStream; AEvent: TStreamCallbackEvent<T>; AParser: TParserMethod<T>);
    /// <summary>
    /// Creates a new instance of <see cref="TOpenAIStream{T}"/> and returns it as an <see cref="IStreamCallback"/>.
    /// </summary>
    /// <param name="AResponse">
    /// A <see cref="TStringStream"/> that contains the streaming response data.
    /// </param>
    /// <param name="AEvent">
    /// A callback event that is triggered when a new chunk of data is received.
    /// </param>
    /// <param name="AParser">
    /// A method used to parse the incoming JSON data into an instance of type <typeparamref name="T"/>.
    /// </param>
    /// <returns>
    /// An instance of <see cref="IStreamCallback"/> that handles the streaming data.
    /// </returns>
    /// <exception cref="Exception">
    /// Thrown if the <paramref name="AParser"/> parameter is not assigned.
    /// </exception>
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
  Parse := AParser;
end;

class function TOpenAIStream<T>.CreateInstance(AResponse: TStringStream;
  AEvent: TStreamCallbackEvent<T>; AParser: TParserMethod<T>): IStreamCallback;
begin
  if not Assigned(AParser) then
    raise Exception.Create('Streaming failed. A deserialization method is required.');
  Result := TOpenAIStream<T>.Create(AResponse, AEvent, AParser);
end;

function TOpenAIStream<T>.GetOnStream: TReceiveDataCallback;

{--- Refer to https://platform.openai.com/docs/api-reference/chat/streaming }

// The chat completion chunk object
// data: {"id":"chatcmpl-123","object":"chat.completion.chunk","created":1694268190,"model":"gpt-4o-mini", "system_fingerprint": "fp_44709d6fcb", "choices":[{"index":0,"delta":{"role":"assistant","content":""},"logprobs":null,"finish_reason":null}]}
// data: {"id":"chatcmpl-123","object":"chat.completion.chunk","created":1694268190,"model":"gpt-4o-mini", "system_fingerprint": "fp_44709d6fcb", "choices":[{"index":0,"delta":{"content":"Hello"},"logprobs":null,"finish_reason":null}]}
// ...
// data: [DONE]

begin
  Result :=
    procedure (const Sender: TObject; AContentLength,
      AReadCount: Int64; var AAbort: Boolean)
    var
      ResponseBuffer: string;
      CurrentLine: string;
      IsDone: Boolean;
      Data: string;
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

            Data := CurrentLine.Replace('data: ', '').Trim([' ', #13, #10]);
            IsDone := Data.ToUpper = '[DONE]';

            Chunk := nil;
            if not IsDone then
              begin
                try
                  Chunk := Parse(Data);
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
