unit GenAI.VoiceContents;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGenAI
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.SysUtils, System.Classes, System.Net.Mime, REST.Json.Types,
  GenAI.API.Params, GenAI.API, GenAI.Async.Support, GenAI.Async.Promise;

type
  TVoiceContentCreateParams = class(TMultipartFormData)
  public
    constructor Create; reintroduce;

    /// <summary>
    /// Adds the sample audio recording file used to create the custom voice.
    /// </summary>
    /// <param name="FileName">
    /// The path to the sample audio file.
    /// </param>
    /// <returns>
    /// Returns an instance of <see cref="TVoiceContentCreateParams"/> configured with the audio sample.
    /// </returns>
    function AudioSample(const FileName: string): TVoiceContentCreateParams; overload;

    /// <summary>
    /// Adds the sample audio recording stream used to create the custom voice.
    /// </summary>
    /// <param name="Stream">The stream containing the sample audio data.</param>
    /// <param name="FileName">The file name associated with the sample audio stream.</param>
    /// <returns>Returns an instance of <see cref="TVoiceContentCreateParams"/> configured with the audio sample stream.</returns>
    function AudioSample(const Stream: TStream; const FileName: string): TVoiceContentCreateParams; overload;

    /// <summary>
    /// Sets the consent recording identifier authorizing creation of the custom voice.
    /// </summary>
    /// <param name="Value">The consent recording identifier, such as <c>cons_1234</c>.</param>
    /// <returns>Returns an instance of <see cref="TVoiceContentCreateParams"/> configured with the specified consent.</returns>
    function Consent(const Value: string): TVoiceContentCreateParams;

    /// <summary>
    /// Sets the name of the custom voice to create.
    /// </summary>
    /// <param name="Value">The display name for the new custom voice.</param>
    /// <returns>Returns an instance of <see cref="TVoiceContentCreateParams"/> configured with the specified name.</returns>
    function Name(const Value: string): TVoiceContentCreateParams;
  end;

  TVoiceContent = class(TJSONFingerprint)
  private
    FId: string;
    [JsonNameAttribute('created_at')]
    FCreatedAt: Int64;
    FName: string;
    FObject: string;
  private
    function GetCreatedAt: Int64;
    function GetCreatedAtAsString: string;
  public
    /// <summary>
    /// The voice identifier, which can be referenced in audio output endpoints.
    /// </summary>
    property Id: string read FId write FId;

    /// <summary>
    /// The Unix timestamp in seconds for when the voice was created.
    /// </summary>
    property CreatedAt: Int64 read GetCreatedAt;

    /// <summary>
    /// The creation timestamp formatted as a string.
    /// </summary>
    property CreatedAtAsString: string read GetCreatedAtAsString;

    /// <summary>
    /// The name of the custom voice.
    /// </summary>
    property Name: string read FName write FName;

    /// <summary>
    /// The object type, which is always <c>audio.voice</c>.
    /// </summary>
    property &Object: string read FObject write FObject;
  end;

  /// <summary>
  /// Asynchronous callback record for custom voice creation.
  /// </summary>
  TAsynVoiceContent = TAsynCallBack<TVoiceContent>;

  /// <summary>
  /// Promise callback record for custom voice creation.
  /// </summary>
  TPromiseVoiceContent = TPromiseCallBack<TVoiceContent>;

  TVoiceContentsAbstractSupport = class(TGenAIRoute)
  protected
    function Create(const ParamProc: TProc<TVoiceContentCreateParams>): TVoiceContent; virtual; abstract;
  end;

  TVoiceContentsAsynchronousSupport = class(TVoiceContentsAbstractSupport)
  public
    procedure AsynCreate(const ParamProc: TProc<TVoiceContentCreateParams>; const CallBacks: TFunc<TAsynVoiceContent>);
  end;

  TVoiceContentsRoute = class(TVoiceContentsAsynchronousSupport)
  public
    /// <summary>
    /// Initiates an asynchronous custom voice creation request and returns a promise for the created voice.
    /// </summary>
    /// <param name="ParamProc">A procedure that configures the multipart payload for the custom voice.</param>
    /// <param name="CallBacks">Optional promise callbacks for start, success, and error handling.</param>
    /// <returns>A promise that resolves with the created custom voice.</returns>
    function AsyncAwaitCreate(const ParamProc: TProc<TVoiceContentCreateParams>;
      const CallBacks: TFunc<TPromiseVoiceContent> = nil): TPromise<TVoiceContent>;

    /// <summary>
    /// Creates a custom voice synchronously.
    /// </summary>
    /// <param name="ParamProc">A procedure that configures the custom voice creation payload.</param>
    /// <returns>Returns the created custom voice.</returns>
    function Create(const ParamProc: TProc<TVoiceContentCreateParams>): TVoiceContent; override;
  end;

implementation

uses
  System.DateUtils;

{ TVoiceContentCreateParams }

function TVoiceContentCreateParams.AudioSample(
  const FileName: string): TVoiceContentCreateParams;
begin
  AddFile('audio_sample', FileName);
  Result := Self;
end;

function TVoiceContentCreateParams.AudioSample(const Stream: TStream;
  const FileName: string): TVoiceContentCreateParams;
begin
  {$IF RTLVersion > 35.0}
    AddStream('audio_sample', Stream, True, FileName);
  {$ELSE}
    AddStream('audio_sample', Stream, FileName);
  {$ENDIF}
  Result := Self;
end;

function TVoiceContentCreateParams.Consent(
  const Value: string): TVoiceContentCreateParams;
begin
  AddField('consent', Value);
  Result := Self;
end;

constructor TVoiceContentCreateParams.Create;
begin
  inherited Create(True);
end;

function TVoiceContentCreateParams.Name(
  const Value: string): TVoiceContentCreateParams;
begin
  AddField('name', Value);
  Result := Self;
end;

{ TVoiceContent }

function TVoiceContent.GetCreatedAt: Int64;
begin
  Result := FCreatedAt;
end;

function TVoiceContent.GetCreatedAtAsString: string;
begin
  Result := DateToISO8601(UnixToDateTime(FCreatedAt, False), True);
end;

{ TVoiceContentsAsynchronousSupport }

procedure TVoiceContentsAsynchronousSupport.AsynCreate(
  const ParamProc: TProc<TVoiceContentCreateParams>;
  const CallBacks: TFunc<TAsynVoiceContent>);
begin
  with TAsynCallBackExec<TAsynVoiceContent, TVoiceContent>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TVoiceContent
      begin
        Result := Self.Create(ParamProc);
      end);
  finally
    Free;
  end;
end;

{ TVoiceContentsRoute }

function TVoiceContentsRoute.AsyncAwaitCreate(
  const ParamProc: TProc<TVoiceContentCreateParams>;
  const CallBacks: TFunc<TPromiseVoiceContent>): TPromise<TVoiceContent>;
begin
  Result := TAsyncAwaitHelper.WrapAsyncAwait<TVoiceContent>(
    procedure(const CallBackParams: TFunc<TAsynVoiceContent>)
    begin
      AsynCreate(ParamProc, CallBackParams);
    end,
    CallBacks);
end;

function TVoiceContentsRoute.Create(
  const ParamProc: TProc<TVoiceContentCreateParams>): TVoiceContent;
begin
  Result := API.PostForm<TVoiceContent, TVoiceContentCreateParams>('audio/voices', ParamProc);
end;

end.
