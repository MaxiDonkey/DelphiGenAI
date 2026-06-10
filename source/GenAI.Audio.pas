unit GenAI.Audio;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGenAI
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.SysUtils, System.Classes, System.Threading, System.Net.Mime, System.JSON,
  System.Generics.Collections,
  REST.Json.Types,
  GenAI.API.Params, GenAI.API, GenAI.Types, GenAI.Async.Support, GenAI.Async.Promise,
  GenAI.Audio.Stream;

type
  TSpeechVoiceParams = class(TJSONParam)
  public
    /// <summary>
    /// Creates a custom voice payload initialized with a voice identifier.
    /// </summary>
    /// <param name="Value">The custom voice identifier, such as <c>voice_...</c>.</param>
    /// <returns>Returns a <see cref="TSpeechVoiceParams"/> instance configured with the specified voice id.</returns>
    class function New(const Value: string): TSpeechVoiceParams;

    /// <summary>
    /// Sets the custom voice identifier to use for speech synthesis.
    /// </summary>
    /// <param name="Value">The custom voice identifier, such as <c>voice_...</c>.</param>
    /// <returns>Returns an instance of <see cref="TSpeechVoiceParams"/> configured with the specified id.</returns>
    function Id(const Value: string): TSpeechVoiceParams;
  end;

  TSpeechParams = class(TJSONParam)
  public
    /// <summary>
    /// Sets the model to be used for speech generation.
    /// </summary>
    /// <param name="Value">The model identifier, such as 'tts-1' or 'tts-1-hd'.</param>
    /// <returns>Returns an instance of <see cref="TSpeechParams"/> configured with the specified model.</returns>
    function Model(const Value: string): TSpeechParams;

    /// <summary>
    /// Sets the text to be converted into speech.
    /// </summary>
    /// <param name="Value">The text string, maximum length of 4096 characters.</param>
    /// <returns>Returns an instance of <see cref="TSpeechParams"/> configured with the specified input text.</returns>
    function Input(const Value: string): TSpeechParams;

    /// <summary>
    /// Sets the voice to be used for speech synthesis.
    /// </summary>
    /// <param name="Value">The name of the voice to use, e.g., 'alloy', 'ash', etc.</param>
    /// <returns>Returns an instance of <see cref="TSpeechParams"/> configured with the specified voice.</returns>
    function Voice(const Value: TAudioVoice): TSpeechParams; overload;

    /// <summary>
    /// Sets the voice to be used for speech synthesis.
    /// </summary>
    /// <param name="Value">A value of <see cref="TAudioVoice"/> representing the voice to use.</param>
    /// <returns>Returns an instance of <see cref="TSpeechParams"/> configured with the specified voice.</returns>
    function Voice(const Value: string): TSpeechParams; overload;

    /// <summary>
    /// Sets a custom voice object to be used for speech synthesis.
    /// </summary>
    /// <param name="Value">A custom voice payload containing a voice identifier.</param>
    /// <returns>Returns an instance of <see cref="TSpeechParams"/> configured with the specified custom voice.</returns>
    function Voice(const Value: TSpeechVoiceParams): TSpeechParams; overload;

    /// <summary>
    /// Sets a custom voice identifier to be used for speech synthesis.
    /// </summary>
    /// <param name="Value">The custom voice identifier, such as <c>voice_...</c>.</param>
    /// <returns>Returns an instance of <see cref="TSpeechParams"/> configured with the specified custom voice id.</returns>
    function VoiceId(const Value: string): TSpeechParams;

    /// <summary>
    /// Provides instructions that control the voice style for compatible speech models.
    /// </summary>
    /// <param name="Value">Natural-language instructions for the generated voice.</param>
    /// <returns>Returns an instance of <see cref="TSpeechParams"/> configured with the specified instructions.</returns>
    function Instructions(const Value: string): TSpeechParams;

    /// <summary>
    /// Sets the response format of the audio output.
    /// </summary>
    /// <param name="Value">The desired audio format, such as 'mp3', 'wav', etc.</param>
    /// <returns>Returns an instance of <see cref="TSpeechParams"/> configured with the specified response format.</returns>
    function ResponseFormat(const Value: TSpeechFormat): TSpeechParams; overload;

    /// <summary>
    /// Sets the response format of the audio output.
    /// </summary>
    /// <param name="Value">A value of <see cref="TSpeechFormat"/> specifying the desired audio format.</param>
    /// <returns>Returns an instance of <see cref="TSpeechParams"/> configured with the specified response format.</returns>
    function ResponseFormat(const Value: string): TSpeechParams; overload;

    /// <summary>
    /// Sets the streaming format for the speech response.
    /// </summary>
    /// <param name="Value">A value of <see cref="TSpeechStreamFormat"/> specifying how the stream is returned.</param>
    /// <returns>Returns an instance of <see cref="TSpeechParams"/> configured with the specified stream format.</returns>
    function StreamFormat(const Value: TSpeechStreamFormat): TSpeechParams; overload;

    /// <summary>
    /// Sets the streaming format for the speech response.
    /// </summary>
    /// <param name="Value">The stream format, such as <c>audio</c> or <c>sse</c>.</param>
    /// <returns>Returns an instance of <see cref="TSpeechParams"/> configured with the specified stream format.</returns>
    function StreamFormat(const Value: string): TSpeechParams; overload;

    /// <summary>
    /// Sets the speed of the generated speech.
    /// </summary>
    /// <param name="Value">The speed multiplier for the speech, ranging from 0.25 to 4.0.</param>
    /// <returns>Returns an instance of <see cref="TSpeechParams"/> configured with the specified speed.</returns>
    function Speed(const Value: Double): TSpeechParams;
  end;

  TSpeechResult = class(TJSONFingerprint)
  private
    FFileName: string;
    FData: string;
  public
    /// <summary>
    /// Retrieves the generated audio content as a stream.
    /// </summary>
    /// <returns>A <see cref="TStream"/> that contains the generated audio data.</returns>
    /// <exception cref="Exception">Raises an exception if the data conversion fails.</exception>
    function GetStream: TStream;

    /// <summary>
    /// Saves the generated image to the specified file path.
    /// </summary>
    /// <param name="FileName">
    /// A string specifying the file path where the image will be saved.
    /// </param>
    /// <param name="RaiseError">
    /// A boolean value indicating whether to raise an exception if the <c>FileName</c> is empty.
    /// <para>
    /// - If set to <c>True</c>, an exception will be raised for an empty file path.
    /// </para>
    /// <para>
    /// - If set to <c>False</c>, the method will exit silently without saving.
    /// </para>
    /// </param>
    /// <remarks>
    /// This method saves the base64-encoded image content to the specified file. Ensure that
    /// the <c>FileName</c> parameter is valid if <c>RaiseError</c> is set to <c>True</c>.
    /// If the <c>FileName</c> is empty and <c>RaiseError</c> is <c>False</c>, the method
    /// will terminate without performing any operation.
    /// </remarks>
    procedure SaveToFile(const FileName: string; const RaiseError: Boolean = True);

    /// <summary>
    /// Contains the base64-encoded string of the audio data.
    /// </summary>
    /// <remarks>
    /// Direct access to the raw audio data in base64 format, allowing further manipulation or processing if required.
    /// </remarks>
    property Data: string read FData write FData;

    /// <summary>
    /// The name of the file where the audio is saved if the SaveToFile method is used.
    /// </summary>
    /// <remarks>
    /// This property can be used to retrieve or set the filename used in the SaveToFile operation.
    /// </remarks>
    property FileName: string read FFileName write FFileName;
  end;

  TTranscriptionServerVadParams = class(TJSONParam)
  public
    /// <summary>
    /// Creates server-side voice activity detection parameters.
    /// </summary>
    /// <returns>Returns a new <see cref="TTranscriptionServerVadParams"/> instance.</returns>
    class function New: TTranscriptionServerVadParams;

    /// <summary>
    /// Sets the amount of audio to include before detected speech.
    /// </summary>
    /// <param name="Value">The prefix padding in milliseconds.</param>
    /// <returns>Returns an instance configured with the specified prefix padding.</returns>
    function PrefixPaddingMs(const Value: Integer): TTranscriptionServerVadParams;

    /// <summary>
    /// Sets the silence duration used to detect the end of a speech segment.
    /// </summary>
    /// <param name="Value">The silence duration in milliseconds.</param>
    /// <returns>Returns an instance configured with the specified silence duration.</returns>
    function SilenceDurationMs(const Value: Integer): TTranscriptionServerVadParams;

    /// <summary>
    /// Sets the voice activity detection threshold.
    /// </summary>
    /// <param name="Value">The server VAD threshold.</param>
    /// <returns>Returns an instance configured with the specified threshold.</returns>
    function Threshold(const Value: Double): TTranscriptionServerVadParams;
  end;

  TTranscriptionChunkingStrategyParams = class(TJSONParam)
  public
    /// <summary>
    /// Creates a chunking strategy payload initialized with a type.
    /// </summary>
    /// <param name="Value">The chunking strategy type.</param>
    /// <returns>Returns a new <see cref="TTranscriptionChunkingStrategyParams"/> instance.</returns>
    class function New(const Value: TTranscriptionChunkingStrategyType): TTranscriptionChunkingStrategyParams; overload;

    /// <summary>
    /// Creates a chunking strategy payload initialized with a type.
    /// </summary>
    /// <param name="Value">The chunking strategy type name.</param>
    /// <returns>Returns a new <see cref="TTranscriptionChunkingStrategyParams"/> instance.</returns>
    class function New(const Value: string): TTranscriptionChunkingStrategyParams; overload;

    /// <summary>
    /// Sets the chunking strategy type.
    /// </summary>
    /// <param name="Value">The chunking strategy type.</param>
    /// <returns>Returns an instance configured with the specified type.</returns>
    function &Type(const Value: TTranscriptionChunkingStrategyType): TTranscriptionChunkingStrategyParams; overload;

    /// <summary>
    /// Sets the chunking strategy type.
    /// </summary>
    /// <param name="Value">The chunking strategy type name.</param>
    /// <returns>Returns an instance configured with the specified type.</returns>
    function &Type(const Value: string): TTranscriptionChunkingStrategyParams; overload;

    /// <summary>
    /// Sets the server-side VAD options for the chunking strategy.
    /// </summary>
    /// <param name="Value">The server VAD parameter payload.</param>
    /// <returns>Returns an instance configured with the specified server VAD options.</returns>
    function ServerVad(const Value: TTranscriptionServerVadParams): TTranscriptionChunkingStrategyParams;
  end;

  TTranscriptionParams = class(TMultipartFormData)
  public
    constructor Create; reintroduce;

    /// <summary>
    /// Adds an audio file from the specified file path to the transcription request.
    /// </summary>
    /// <param name="FileName">The path to the audio file to be transcribed.</param>
    /// <returns>Returns an instance of <see cref="TTranscriptionParams"/> with the specified file included.</returns>
    function &File(const FileName: string): TTranscriptionParams; overload;

    /// <summary>
    /// Adds an audio file from a stream to the transcription request.
    /// </summary>
    /// <param name="Stream">The stream containing the audio file data.</param>
    /// <param name="FileName">The name of the file represented by the stream.</param>
    /// <returns>Returns an instance of <see cref="TTranscriptionParams"/> with the specified file stream included.</returns>
    function &File(const Stream: TStream; const FileName: string): TTranscriptionParams; overload;

    /// <summary>
    /// Sets the model to be used for transcription.
    /// </summary>
    /// <param name="Value">The model identifier, such as 'whisper-1'.</param>
    /// <returns>Returns an instance of <see cref="TTranscriptionParams"/> configured with the specified model.</returns>
    function Model(const Value: string): TTranscriptionParams;

    /// <summary>
    /// Optionally sets the language of the input audio.
    /// </summary>
    /// <param name="Value">The ISO-639-1 language code, such as 'en' for English.</param>
    /// <returns>Returns an instance of <see cref="TTranscriptionParams"/> configured with the specified language.</returns>
    function Language(const Value: string): TTranscriptionParams;

    /// <summary>
    /// Optionally sets a guiding prompt for the transcription.
    /// </summary>
    /// <param name="Value">The text to guide the model's style or to continue a previous audio segment.</param>
    /// <returns>Returns an instance of <see cref="TTranscriptionParams"/> configured with the specified prompt.</returns>
    function Prompt(const Value: string): TTranscriptionParams;

    /// <summary>
    /// Sets the chunking strategy used to process the audio.
    /// </summary>
    /// <param name="Value">The chunking strategy type.</param>
    /// <returns>Returns an instance of <see cref="TTranscriptionParams"/> configured with the specified chunking strategy.</returns>
    function ChunkingStrategy(const Value: TTranscriptionChunkingStrategyType): TTranscriptionParams; overload;

    /// <summary>
    /// Sets the chunking strategy used to process the audio.
    /// </summary>
    /// <param name="Value">The chunking strategy type name.</param>
    /// <returns>Returns an instance of <see cref="TTranscriptionParams"/> configured with the specified chunking strategy.</returns>
    function ChunkingStrategy(const Value: string): TTranscriptionParams; overload;

    /// <summary>
    /// Sets the chunking strategy used to process the audio.
    /// </summary>
    /// <param name="Value">The chunking strategy payload.</param>
    /// <returns>Returns an instance of <see cref="TTranscriptionParams"/> configured with the specified chunking strategy.</returns>
    function ChunkingStrategy(const Value: TTranscriptionChunkingStrategyParams): TTranscriptionParams; overload;

    /// <summary>
    /// Adds an optional field to include in the transcription response.
    /// </summary>
    /// <param name="Value">The optional response field to include.</param>
    /// <returns>Returns an instance of <see cref="TTranscriptionParams"/> configured with the specified include option.</returns>
    function Include(const Value: TTranscriptionInclude): TTranscriptionParams; overload;

    /// <summary>
    /// Adds an optional field to include in the transcription response.
    /// </summary>
    /// <param name="Value">The optional response field name to include.</param>
    /// <returns>Returns an instance of <see cref="TTranscriptionParams"/> configured with the specified include option.</returns>
    function Include(const Value: string): TTranscriptionParams; overload;

    /// <summary>
    /// Adds optional fields to include in the transcription response.
    /// </summary>
    /// <param name="Value">The optional response field names to include.</param>
    /// <returns>Returns an instance of <see cref="TTranscriptionParams"/> configured with the specified include options.</returns>
    function Include(const Value: TArray<string>): TTranscriptionParams; overload;

    /// <summary>
    /// Adds optional fields to include in the transcription response.
    /// </summary>
    /// <param name="Value">The optional response fields to include.</param>
    /// <returns>Returns an instance of <see cref="TTranscriptionParams"/> configured with the specified include options.</returns>
    function Include(const Value: TArray<TTranscriptionInclude>): TTranscriptionParams; overload;

    /// <summary>
    /// Requests token log probabilities in the transcription response.
    /// </summary>
    /// <returns>Returns an instance of <see cref="TTranscriptionParams"/> configured to include log probabilities.</returns>
    function IncludeLogprobs: TTranscriptionParams;

    /// <summary>
    /// Adds speaker names to use when diarizing the transcription.
    /// </summary>
    /// <param name="Value">The known speaker names.</param>
    /// <returns>Returns an instance of <see cref="TTranscriptionParams"/> configured with the specified speaker names.</returns>
    function KnownSpeakerNames(const Value: TArray<string>): TTranscriptionParams;

    /// <summary>
    /// Adds a known speaker reference audio file to use when diarizing the transcription.
    /// </summary>
    /// <param name="FileName">The known speaker reference audio file.</param>
    /// <returns>Returns an instance of <see cref="TTranscriptionParams"/> configured with the specified speaker reference.</returns>
    function KnownSpeakerReference(const FileName: string): TTranscriptionParams; overload;

    /// <summary>
    /// Adds a known speaker reference audio stream to use when diarizing the transcription.
    /// </summary>
    /// <param name="Stream">The stream containing the speaker reference audio.</param>
    /// <param name="FileName">The name of the file represented by the stream.</param>
    /// <returns>Returns an instance of <see cref="TTranscriptionParams"/> configured with the specified speaker reference.</returns>
    function KnownSpeakerReference(const Stream: TStream; const FileName: string): TTranscriptionParams; overload;

    /// <summary>
    /// Adds known speaker reference audio files to use when diarizing the transcription.
    /// </summary>
    /// <param name="Value">The known speaker reference audio files.</param>
    /// <returns>Returns an instance of <see cref="TTranscriptionParams"/> configured with the specified speaker references.</returns>
    function KnownSpeakerReferences(const Value: TArray<string>): TTranscriptionParams;

    /// <summary>
    /// Sets the format of the transcription output.
    /// </summary>
    /// <param name="Value">The desired output format, such as 'json', 'text', or 'srt'.</param>
    /// <returns>Returns an instance of <see cref="TTranscriptionParams"/> configured with the specified response format.</returns>
    function ResponseFormat(const Value: TTranscriptionResponseFormat): TTranscriptionParams; overload;

    /// <summary>
    /// Sets the format of the transcription output.
    /// </summary>
    /// <param name="Value">A value of <see cref="TTranscriptionResponseFormat"/> specifying the desired output format.</param>
    /// <returns>Returns an instance of <see cref="TTranscriptionParams"/> configured with the specified response format.</returns>
    function ResponseFormat(const Value: string): TTranscriptionParams; overload;

    /// <summary>
    /// Sets the response format to diarized JSON.
    /// </summary>
    /// <returns>Returns an instance of <see cref="TTranscriptionParams"/> configured for diarized JSON.</returns>
    function DiarizedJson: TTranscriptionParams;

    /// <summary>
    /// Adds a timestamp granularity to request in verbose transcription responses.
    /// </summary>
    /// <param name="Value">The timestamp granularity to request.</param>
    /// <returns>Returns an instance of <see cref="TTranscriptionParams"/> configured with the specified granularity.</returns>
    function TimestampGranularity(const Value: TTimestampGranularity): TTranscriptionParams; overload;

    /// <summary>
    /// Adds a timestamp granularity to request in verbose transcription responses.
    /// </summary>
    /// <param name="Value">The timestamp granularity name to request.</param>
    /// <returns>Returns an instance of <see cref="TTranscriptionParams"/> configured with the specified granularity.</returns>
    function TimestampGranularity(const Value: string): TTranscriptionParams; overload;

    /// <summary>
    /// Adds timestamp granularities to request in verbose transcription responses.
    /// </summary>
    /// <param name="Value">The timestamp granularity names to request.</param>
    /// <returns>Returns an instance of <see cref="TTranscriptionParams"/> configured with the specified granularities.</returns>
    function TimestampGranularities(const Value: TArray<string>): TTranscriptionParams; overload;

    /// <summary>
    /// Adds timestamp granularities to request in verbose transcription responses.
    /// </summary>
    /// <param name="Value">The timestamp granularities to request.</param>
    /// <returns>Returns an instance of <see cref="TTranscriptionParams"/> configured with the specified granularities.</returns>
    function TimestampGranularities(const Value: TArray<TTimestampGranularity>): TTranscriptionParams; overload;

    /// <summary>
    /// Enables or disables streaming events for the transcription request.
    /// </summary>
    /// <param name="Value">When <c>True</c>, the API returns transcription events incrementally.</param>
    /// <returns>Returns an instance of <see cref="TTranscriptionParams"/> configured with the specified streaming flag.</returns>
    function Stream(const Value: Boolean = True): TTranscriptionParams;

    /// <summary>
    /// Optionally sets the transcription temperature to control the randomness of the output.
    /// </summary>
    /// <param name="Value">A value between 0 and 1, where higher values result in more randomness.</param>
    /// <returns>Returns an instance of <see cref="TTranscriptionParams"/> configured with the specified temperature.</returns>
    function Temperature(const Value: Double): TTranscriptionParams;
  end;

  TTranscriptionWord = class
  private
    FWord: string;
    FStart: Double;
    FEnd: Double;
  public
    /// <summary>
    /// The transcribed word.
    /// </summary>
    /// <remarks>
    /// This property holds the text of the word as it was recognized in the audio.
    /// </remarks>
    property Word: string read FWord write FWord;

    /// <summary>
    /// The start time of the word in the audio stream, measured in seconds.
    /// </summary>
    /// <remarks>
    /// This property indicates when the word starts in the audio.
    /// </remarks>
    property Start: Double read FStart write FStart;

    /// <summary>
    /// The end time of the word in the audio stream, measured in seconds.
    /// </summary>
    /// <remarks>
    /// This property indicates when the word ends in the audio.
    /// </remarks>
    property &End: Double read FEnd write FEnd;
  end;

  TTranscriptionSegment = class
  private
    FId: Int64;
    FSeek: Int64;
    FStart: Double;
    FEnd: Double;
    FText: string;
    FTokens: TArray<Int64>;
    FTemperature: Double;
    [JsonNameAttribute('avg_logprob')]
    FAvgLogprob: Double;
    [JsonNameAttribute('compression_ratio')]
    FCompressionRatio: Double;
    [JsonNameAttribute('no_speech_prob')]
    FNoSpeechProb: Double;
  public
    /// <summary>
    /// Unique identifier for the segment.
    /// </summary>
    property Id: Int64 read FId write FId;

    /// <summary>
    /// Seek position in the original audio data.
    /// </summary>
    /// <remarks>
    /// This property could be used to directly access the specific part of the audio corresponding to this segment.
    /// </remarks>
    property Seek: Int64 read FSeek write FSeek;

    /// <summary>
    /// The start time of the segment in the audio stream, measured in seconds.
    /// </summary>
    property Start: Double read FStart write FStart;

    /// <summary>
    /// The end time of the segment in the audio stream, measured in seconds.
    /// </summary>
    property &End: Double read FEnd write FEnd;

    /// <summary>
    /// The text of the transcribed segment.
    /// </summary>
    property Text: string read FText write FText;

    /// <summary>
    /// An array of token identifiers associated with the segment.
    /// </summary>
    property Tokens: TArray<Int64> read FTokens write FTokens;

    /// <summary>
    /// The transcription model's confidence measure for this segment.
    /// </summary>
    property Temperature: Double read FTemperature write FTemperature;

    /// <summary>
    /// The average log probability of the segment, indicating model confidence.
    /// </summary>
    property AvgLogprob: Double read FAvgLogprob write FAvgLogprob;

    /// <summary>
    /// The ratio indicating how much the segment has been compressed from the original audio.
    /// </summary>
    property CompressionRatio: Double read FCompressionRatio write FCompressionRatio;

    /// <summary>
    /// Probability that the segment does not contain speech.
    /// </summary>
    property NoSpeechProb: Double read FNoSpeechProb write FNoSpeechProb;
  end;

  TTranscriptionDiarizedSegment = class
  private
    FId: string;
    FStart: Double;
    FEnd: Double;
    FSpeaker: string;
    FText: string;
    FType: string;
  public
    /// <summary>
    /// Unique identifier for the diarized segment.
    /// </summary>
    property Id: string read FId write FId;

    /// <summary>
    /// The start time of the segment in the audio stream, measured in seconds.
    /// </summary>
    property Start: Double read FStart write FStart;

    /// <summary>
    /// The end time of the segment in the audio stream, measured in seconds.
    /// </summary>
    property &End: Double read FEnd write FEnd;

    /// <summary>
    /// Speaker label associated with the segment.
    /// </summary>
    property Speaker: string read FSpeaker write FSpeaker;

    /// <summary>
    /// The text of the diarized segment.
    /// </summary>
    property Text: string read FText write FText;

    /// <summary>
    /// The event or segment type returned by the API.
    /// </summary>
    property &Type: string read FType write FType;
  end;

  TTranscriptionLogprob = class
  private
    FToken: string;
    FBytes: TArray<Integer>;
    FLogprob: Double;
  public
    /// <summary>
    /// The token associated with this log probability entry.
    /// </summary>
    property Token: string read FToken write FToken;

    /// <summary>
    /// The UTF-8 bytes associated with the token.
    /// </summary>
    property Bytes: TArray<Integer> read FBytes write FBytes;

    /// <summary>
    /// The log probability of the token.
    /// </summary>
    property Logprob: Double read FLogprob write FLogprob;
  end;

  TTranscriptionInputTokenDetails = class
  private
    [JsonNameAttribute('audio_tokens')]
    FAudioTokens: Int64;
    [JsonNameAttribute('text_tokens')]
    FTextTokens: Int64;
  public
    /// <summary>
    /// Number of audio tokens billed for the request.
    /// </summary>
    property AudioTokens: Int64 read FAudioTokens write FAudioTokens;

    /// <summary>
    /// Number of text tokens billed for the request.
    /// </summary>
    property TextTokens: Int64 read FTextTokens write FTextTokens;
  end;

  TTranscriptionUsage = class
  private
    FType: string;
    [JsonNameAttribute('input_tokens')]
    FInputTokens: Int64;
    [JsonNameAttribute('output_tokens')]
    FOutputTokens: Int64;
    [JsonNameAttribute('total_tokens')]
    FTotalTokens: Int64;
    [JsonNameAttribute('input_token_details')]
    FInputTokenDetails: TTranscriptionInputTokenDetails;
    FSeconds: Double;
  public
    /// <summary>
    /// Releases nested usage details.
    /// </summary>
    destructor Destroy; override;

    /// <summary>
    /// The usage variant type, such as <c>tokens</c> or <c>duration</c>.
    /// </summary>
    property &Type: string read FType write FType;

    /// <summary>
    /// Number of input tokens billed for this request.
    /// </summary>
    property InputTokens: Int64 read FInputTokens write FInputTokens;

    /// <summary>
    /// Number of output tokens generated.
    /// </summary>
    property OutputTokens: Int64 read FOutputTokens write FOutputTokens;

    /// <summary>
    /// Total number of tokens used.
    /// </summary>
    property TotalTokens: Int64 read FTotalTokens write FTotalTokens;

    /// <summary>
    /// Details about the input tokens billed for this request.
    /// </summary>
    property InputTokenDetails: TTranscriptionInputTokenDetails read FInputTokenDetails write FInputTokenDetails;

    /// <summary>
    /// Duration of the input audio in seconds for duration-billed models.
    /// </summary>
    property Seconds: Double read FSeconds write FSeconds;
  end;

  TTranscription = class(TJSONFingerprint)
  private
    FLanguage: string;
    [JSONMarshalled(False)]
    FDuration: string;
    [JSONMarshalled(False)]
    FDurationSeconds: Double;
    FText: string;
    FTask: string;
    FWords: TArray<TTranscriptionWord>;
    [JSONMarshalled(False)]
    FSegments: TArray<TTranscriptionSegment>;
    [JSONMarshalled(False)]
    FDiarizedSegments: TArray<TTranscriptionDiarizedSegment>;
    [JSONMarshalled(False)]
    FLogprobs: TArray<TTranscriptionLogprob>;
    [JSONMarshalled(False)]
    FUsage: TTranscriptionUsage;
  protected
    /// <summary>
    /// Rebuilds response fields that can have multiple shapes depending on the response format.
    /// </summary>
    procedure ContentUpdate; override;

    /// <summary>
    /// Finalizes deserialization after the raw JSON response has been attached.
    /// </summary>
    procedure AfterDeserialize; override;
  public
    /// <summary>
    /// The language of the audio that was transcribed.
    /// </summary>
    /// <remarks>
    /// This property indicates the ISO-639-1 language code of the transcribed audio,
    /// such as 'en' for English.
    /// </remarks>
    property Language: string read FLanguage write FLanguage;

    /// <summary>
    /// The duration of the audio that was transcribed, typically expressed in seconds or a time format.
    /// </summary>
    /// <remarks>
    /// This property provides the length of the audio clip that was processed,
    /// which is useful for synchronizing the transcription with the audio playback.
    /// </remarks>
    property Duration: string read FDuration write FDuration;

    /// <summary>
    /// The duration of the audio that was transcribed, measured in seconds.
    /// </summary>
    property DurationSeconds: Double read FDurationSeconds write FDurationSeconds;

    /// <summary>
    /// The complete transcribed text of the audio file.
    /// </summary>
    /// <remarks>
    /// This property contains the entire textual output generated from the audio transcription,
    /// providing a comprehensive view of the spoken content.
    /// </remarks>
    property Text: string read FText write FText;

    /// <summary>
    /// The task that was run for diarized transcription responses.
    /// </summary>
    property Task: string read FTask write FTask;

    /// <summary>
    /// A collection of words extracted from the transcription, each associated with specific timestamps.
    /// </summary>
    /// <remarks>
    /// This array of <see cref="TTranscriptionWord"/> objects offers detailed timing for each word in the transcription,
    /// allowing for fine-grained analysis and synchronization with the audio.
    /// </remarks>
    property Words: TArray<TTranscriptionWord> read FWords write FWords;

    /// <summary>
    /// A collection of segments from the transcription, each providing detailed information about a portion of the text.
    /// </summary>
    /// <remarks>
    /// This array of <see cref="TTranscriptionSegment"/> objects details various segments of the transcription,
    /// including their timing, text, and model confidence metrics. It is particularly useful for segmenting the transcription
    /// into logical units for easier processing and analysis.
    /// </remarks>
    property Segments: TArray<TTranscriptionSegment> read FSegments write FSegments;

    /// <summary>
    /// Speaker-annotated transcript segments returned by diarized JSON responses.
    /// </summary>
    property DiarizedSegments: TArray<TTranscriptionDiarizedSegment> read FDiarizedSegments write FDiarizedSegments;

    /// <summary>
    /// Token log probabilities returned when requested through the include parameter.
    /// </summary>
    property Logprobs: TArray<TTranscriptionLogprob> read FLogprobs write FLogprobs;

    /// <summary>
    /// Token or duration usage statistics for the transcription request.
    /// </summary>
    property Usage: TTranscriptionUsage read FUsage write FUsage;

    /// <summary>
    /// Destructor for TTranscription, ensures proper cleanup of resources.
    /// </summary>
    /// <remarks>
    /// This destructor is overridden to ensure that any resources, particularly the dynamically allocated
    /// word and segment objects, are properly freed when an instance of TTranscription is destroyed.
    /// </remarks>
    destructor Destroy; override;
  end;

  TTranslationParams = class(TMultipartFormData)
  public
    constructor Create; reintroduce;

    /// <summary>
    /// Adds an audio file from the specified file path to the translation request.
    /// </summary>
    /// <param name="FileName">The path to the audio file to be translated.</param>
    /// <returns>Returns an instance of <see cref="TTranslationParams"/> with the specified file included.</returns>
    function &File(const FileName: string): TTranslationParams; overload;

    /// <summary>
    /// Adds an audio file from a stream to the translation request.
    /// </summary>
    /// <param name="Stream">The stream containing the audio file data.</param>
    /// <param name="FileName">The name of the file represented by the stream.</param>
    /// <returns>Returns an instance of <see cref="TTranslationParams"/> with the specified file stream included.</returns>
    function &File(const Stream: TStream; const FileName: string): TTranslationParams; overload;

    /// <summary>
    /// Sets the model to be used for translation.
    /// </summary>
    /// <param name="Value">The model identifier, such as 'whisper-1'.</param>
    /// <returns>Returns an instance of <see cref="TTranslationParams"/> configured with the specified model.</returns>
    function Model(const Value: string): TTranslationParams;

    /// <summary>
    /// Optionally sets a guiding prompt for the translation.
    /// </summary>
    /// <param name="Value">The text to guide the model's style or to continue a previous audio segment in English.</param>
    /// <returns>Returns an instance of <see cref="TTranslationParams"/> configured with the specified prompt.</returns>
    function Prompt(const Value: string): TTranslationParams;

    /// <summary>
    /// Sets the format of the translation output.
    /// </summary>
    /// <param name="Value">The desired output format, such as 'json', 'text', or 'srt'.</param>
    /// <returns>Returns an instance of <see cref="TTranslationParams"/> configured with the specified response format.</returns>
    function ResponseFormat(const Value: TTranscriptionResponseFormat): TTranslationParams; overload;

    /// <summary>
    /// Sets the format of the translation output.
    /// </summary>
    /// <param name="Value">A value of <see cref="TTranscriptionResponseFormat"/> specifying the desired response format.</param>
    /// <returns>Returns an instance of <see cref="TTranslationParams"/> configured with the specified response format.</returns>
    function ResponseFormat(const Value: string): TTranslationParams; overload;

    /// <summary>
    /// Optionally sets the translation temperature to control the randomness of the output.
    /// </summary>
    /// <param name="Value">A value between 0 and 1, where higher values result in more randomness.</param>
    /// <returns>Returns an instance of <see cref="TTranslationParams"/> configured with the specified temperature.</returns>
    function Temperature(const Value: Double): TTranslationParams;
  end;

  TTranslation = class(TJSONFingerprint)
  private
    FLanguage: string;
    FDuration: Double;
    FText: string;
    FSegments: TArray<TTranscriptionSegment>;
  public
    /// <summary>
    /// The language of the output translation.
    /// </summary>
    property Language: string read FLanguage write FLanguage;

    /// <summary>
    /// The duration of the input audio in seconds.
    /// </summary>
    property Duration: Double read FDuration write FDuration;

    /// <summary>
    /// The translated text from the audio file.
    /// </summary>
    /// <remarks>
    /// This property contains the textual output generated from the audio translation,
    /// providing the English translation of the spoken content.
    /// </remarks>
    property Text: string read FText write FText;

    /// <summary>
    /// Segments of the translated text and their corresponding details.
    /// </summary>
    property Segments: TArray<TTranscriptionSegment> read FSegments write FSegments;

    /// <summary>
    /// Destructor for TTranslation, ensures segment resources are released.
    /// </summary>
    destructor Destroy; override;
  end;

  /// <summary>
  /// Manages asynchronous callBacks for a request using <c>TSpeechResult</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynSpeechResult</c> type extends the <c>TAsynParams&lt;TSpeechResult&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking operations.
  /// </remarks>
  TAsynSpeechResult = TAsynCallBack<TSpeechResult>;

  /// <summary>
  /// Defines a promise-based callback for asynchronous speech synthesis operations,
  /// resolving with a <see cref="TSpeechResult"/>.
  /// </summary>
  /// <remarks>
  /// Specializes <see cref="TPromiseCallBack{TSpeechResult}"/> to streamline
  /// handling of OpenAI audio speech results. Use this type when you need a
  /// <c>TPromise</c> that completes with a <see cref="TSpeechResult"/>,
  /// or reports an error if the request fails.
  /// </remarks>
  TPromiseSpeechResult = TPromiseCallBack<TSpeechResult>;

  /// <summary>
  /// Manages asynchronous callBacks for a request using <c>TTranscription</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynTranscription</c> type extends the <c>TAsynParams&lt;TTranscription&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking operations.
  /// </remarks>
  TAsynTranscription = TAsynCallBack<TTranscription>;

  /// <summary>
  /// Defines a promise-based callback for asynchronous audio transcription operations,
  /// resolving with a <see cref="TTranscription"/>.
  /// </summary>
  /// <remarks>
  /// Specializes <see cref="TPromiseCallBack{TTranscription}"/> to streamline
  /// handling of OpenAI audio transcription results. Use this type when you need a
  /// <c>TPromise</c> that completes with a <see cref="TTranscription"/>,
  /// or reports an error if the request fails.
  /// </remarks>
  TPromiseTranscription = TPromiseCallBack<TTranscription>;

  /// <summary>
  /// Manages asynchronous callBacks for a request using <c>TTranslation</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynTranslation</c> type extends the <c>TAsynParams&lt;TTranslation&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking operations.
  /// </remarks>
  TAsynTranslation = TAsynCallBack<TTranslation>;

  /// <summary>
  /// Defines a promise-based callback for asynchronous audio translation operations,
  /// resolving with a <see cref="TTranslation"/>.
  /// </summary>
  /// <remarks>
  /// Specializes <see cref="TPromiseCallBack{TTranslation}"/> to streamline
  /// handling of OpenAI audio translation results. Use this type when you need a
  /// <c>TPromise</c> that completes with a <see cref="TTranslation"/>,
  /// or reports an error if the request fails.
  /// </remarks>
  TPromiseTranslation = TPromiseCallBack<TTranslation>;

  TAudioAbstractSupport = class(TGenAIRoute)
  protected
    function Speech(const ParamProc: TProc<TSpeechParams>): TSpeechResult; virtual; abstract;
    function SpeechStream(const ParamProc: TProc<TSpeechParams>; const Event: TSpeechStreamEvent): Boolean; virtual; abstract;
    function Transcription(const ParamProc: TProc<TTranscriptionParams>): TTranscription; virtual; abstract;
    function TranscriptionStream(const ParamProc: TProc<TTranscriptionParams>; const Event: TTranscriptionStreamEvent): Boolean; virtual; abstract;
    function TranslatingIntoEnglish(const ParamProc: TProc<TTranslationParams>): TTranslation; virtual; abstract;
  end;

  TAudioAsynchronousSupport = class(TAudioAbstractSupport)
  public
    procedure AsynSpeech(const ParamProc: TProc<TSpeechParams>; const CallBacks: TFunc<TAsynSpeechResult>);
    procedure AsynSpeechStream(const ParamProc: TProc<TSpeechParams>; const CallBacks: TFunc<TAsynSpeechStream>);
    procedure AsynTranscription(const ParamProc: TProc<TTranscriptionParams>; const CallBacks: TFunc<TAsynTranscription>);
    procedure AsynTranscriptionStream(const ParamProc: TProc<TTranscriptionParams>; const CallBacks: TFunc<TAsynTranscriptionStream>);
    procedure AsynTranslatingIntoEnglish(const ParamProc: TProc<TTranslationParams>; const CallBacks: TFunc<TAsynTranslation>);
  end;

  TAudioRoute = class(TAudioAsynchronousSupport)
  public
    /// <summary>
    /// Initiates an asynchronous speech synthesis request and returns a promise that resolves with the generated speech result.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure to configure the speech synthesis parameters via a <see cref="TSpeechParams"/> instance.
    /// </param>
    /// <param name="CallBacks">
    /// An optional function providing <see cref="TPromiseSpeechResult"/> callbacks for start, success, and error handling.
    /// </param>
    /// <returns>
    /// A <c>TPromise&lt;TSpeechResult&gt;</c> that completes when the speech request succeeds or fails.
    /// </returns>
    /// <remarks>
    /// Internally wraps <see cref="AsynSpeech"/> using <see cref="TAsyncAwaitHelper.WrapAsyncAwait{TSpeechResult}"/>,
    /// enabling seamless promise-based workflows for audio speech operations.
    /// </remarks>
    function AsyncAwaitSpeech(const ParamProc: TProc<TSpeechParams>;
      const CallBacks: TFunc<TPromiseSpeechResult> = nil): TPromise<TSpeechResult>;

    /// <summary>
    /// Initiates an asynchronous streamed speech request and returns the aggregated audio stream result.
    /// </summary>
    function AsyncAwaitSpeechStream(const ParamProc: TProc<TSpeechParams>;
      const CallBacks: TFunc<TPromiseSpeechStream>): TPromise<TSpeechStreamResult>;

    /// <summary>
    /// Initiates an asynchronous audio transcription request and returns a promise that resolves with the transcription result.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure to configure the transcription parameters via a <see cref="TTranscriptionParams"/> instance.
    /// </param>
    /// <param name="CallBacks">
    /// An optional function providing <see cref="TPromiseTranscription"/> callbacks for start, success, and error handling.
    /// </param>
    /// <returns>
    /// A <c>TPromise&lt;TTranscription&gt;</c> that completes when the transcription request succeeds or fails.
    /// </returns>
    /// <remarks>
    /// Internally wraps <see cref="AsynTranscription"/> using <see cref="TAsyncAwaitHelper.WrapAsyncAwait{TTranscription}"/>,
    /// enabling seamless promise-based workflows for audio transcription operations.
    /// </remarks>
    function AsyncAwaitTranscription(const ParamProc: TProc<TTranscriptionParams>;
      const CallBacks: TFunc<TPromiseTranscription> = nil): TPromise<TTranscription>;

    /// <summary>
    /// Initiates an asynchronous streamed transcription request and returns the aggregated transcription stream result.
    /// </summary>
    function AsyncAwaitTranscriptionStream(const ParamProc: TProc<TTranscriptionParams>;
      const CallBacks: TFunc<TPromiseTranscriptionStream>): TPromise<TTranscriptionStreamResult>;

    /// <summary>
    /// Initiates an asynchronous audio translation into English request and returns a promise that resolves with the translation result.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure to configure the translation parameters via a <see cref="TTranslationParams"/> instance.
    /// </param>
    /// <param name="CallBacks">
    /// A function providing <see cref="TPromiseTranslation"/> callbacks for start, success, and error handling.
    /// </param>
    /// <returns>
    /// A <c>TPromise&lt;TTranslation&gt;</c> that completes when the translation request succeeds or fails.
    /// </returns>
    /// <remarks>
    /// Internally wraps <see cref="AsynTranslatingIntoEnglish"/> using <see cref="TAsyncAwaitHelper.WrapAsyncAwait{TTranslation}"/>,
    /// enabling seamless promise-based workflows for audio translation operations.
    /// </remarks>
    function AsyncAwaitTranslatingIntoEnglish(const ParamProc: TProc<TTranslationParams>;
      const CallBacks: TFunc<TPromiseTranslation>): TPromise<TTranslation>;

    /// <summary>
    /// Synchronously generates speech from text using the specified parameters.
    /// </summary>
    /// <param name="ParamProc">A procedure that accepts a TSpeechParams instance to set the parameters for the speech request.</param>
    /// <returns>Returns an instance of TSpeechResult containing the generated speech.</returns>
    /// <remarks>
    /// This method allows for synchronous speech synthesis, suitable for situations where immediate response from the API is required.
    /// </remarks>
    function Speech(const ParamProc: TProc<TSpeechParams>): TSpeechResult; override;

    /// <summary>
    /// Streams generated speech chunks as they are received from the API.
    /// </summary>
    function SpeechStream(const ParamProc: TProc<TSpeechParams>; const Event: TSpeechStreamEvent): Boolean; override;

    /// <summary>
    /// Synchronously transcribes audio into text using the specified parameters.
    /// </summary>
    /// <param name="ParamProc">A procedure that accepts a TTranscriptionParams instance to set the parameters for the transcription request.</param>
    /// <returns>Returns an instance of TTranscription containing the transcription details.</returns>
    /// <remarks>
    /// This method allows for synchronous audio transcription, appropriate for applications requiring immediate text output from audio.
    /// </remarks>
    function Transcription(const ParamProc: TProc<TTranscriptionParams>): TTranscription; override;

    /// <summary>
    /// Streams transcription events as they are received from the API.
    /// </summary>
    function TranscriptionStream(const ParamProc: TProc<TTranscriptionParams>; const Event: TTranscriptionStreamEvent): Boolean; override;

    /// <summary>
    /// Synchronously translates audio into English using the specified parameters.
    /// </summary>
    /// <param name="ParamProc">A procedure that accepts a TTranslationParams instance to set the parameters for the translation request.</param>
    /// <returns>Returns an instance of TTranslation containing the translated text.</returns>
    /// <remarks>
    /// This method allows for synchronous audio translation, ideal for scenarios where an immediate textual translation is needed.
    /// </remarks>
    function TranslatingIntoEnglish(const ParamProc: TProc<TTranslationParams>): TTranslation; override;
  end;

implementation

uses
  GenAI.NetEncoding.Base64, GenAI.API.JsonSafeReader, GenAI.Async.Params,
  GenAI.API.Streams, GenAI.API.SSEDecoder;

type
  TAudioJsonReader = record
    class function IntegerArrayOf(const Value: TJSONValue): TArray<Integer>; static;
    class function Int64ArrayOf(const Value: TJSONValue): TArray<Int64>; static;
  end;

class function TAudioJsonReader.IntegerArrayOf(
  const Value: TJSONValue): TArray<Integer>;
begin
  Result := [];
  if not (Value is TJSONArray) then
    Exit;

  var Items := TJSONArray(Value);
  for var Index := 0 to Items.Count - 1 do
    Result := Result + [StrToIntDef(Items.Items[Index].Value, 0)];
end;

class function TAudioJsonReader.Int64ArrayOf(
  const Value: TJSONValue): TArray<Int64>;
begin
  Result := [];
  if not (Value is TJSONArray) then
    Exit;

  var Items := TJSONArray(Value);
  for var Index := 0 to Items.Count - 1 do
    Result := Result + [StrToInt64Def(Items.Items[Index].Value, 0)];
end;

{ TSpeechVoiceParams }

function TSpeechVoiceParams.Id(const Value: string): TSpeechVoiceParams;
begin
  Result := TSpeechVoiceParams(Add('id', Value));
end;

class function TSpeechVoiceParams.New(const Value: string): TSpeechVoiceParams;
begin
  Result := TSpeechVoiceParams.Create;
  Result.Id(Value);
end;

{ TSpeechParams }

function TSpeechParams.Instructions(const Value: string): TSpeechParams;
begin
  Result := TSpeechParams(Add('instructions', Value));
end;

function TSpeechParams.Input(const Value: string): TSpeechParams;
begin
  Result := TSpeechParams(Add('input', Value));
end;

function TSpeechParams.Model(const Value: string): TSpeechParams;
begin
  Result := TSpeechParams(Add('model', Value));
end;

function TSpeechParams.ResponseFormat(const Value: string): TSpeechParams;
begin
  Result := ResponseFormat(TSpeechFormat.Parse(Value));
end;

function TSpeechParams.ResponseFormat(
  const Value: TSpeechFormat): TSpeechParams;
begin
  Result := TSpeechParams(Add('response_format', Value.ToString));
end;

function TSpeechParams.Speed(const Value: Double): TSpeechParams;
begin
  Result := TSpeechParams(Add('speed', Value));
end;

function TSpeechParams.StreamFormat(
  const Value: TSpeechStreamFormat): TSpeechParams;
begin
  Result := TSpeechParams(Add('stream_format', Value.ToString));
end;

function TSpeechParams.StreamFormat(const Value: string): TSpeechParams;
begin
  Result := StreamFormat(TSpeechStreamFormat.Parse(Value));
end;

function TSpeechParams.Voice(const Value: string): TSpeechParams;
begin
  Result := Voice(TAudioVoice.Parse(Value));
end;

function TSpeechParams.Voice(const Value: TAudioVoice): TSpeechParams;
begin
  Result := TSpeechParams(Add('voice', Value.ToString));
end;

function TSpeechParams.Voice(const Value: TSpeechVoiceParams): TSpeechParams;
begin
  Result := TSpeechParams(Add('voice', Value.Detach));
end;

function TSpeechParams.VoiceId(const Value: string): TSpeechParams;
begin
  Result := Voice(TSpeechVoiceParams.New(Value));
end;

{ TAudioRoute }

function TAudioRoute.AsyncAwaitSpeech(const ParamProc: TProc<TSpeechParams>;
  const CallBacks: TFunc<TPromiseSpeechResult>): TPromise<TSpeechResult>;
begin
  Result := TAsyncAwaitHelper.WrapAsyncAwait<TSpeechResult>(
    procedure(const CallBackParams: TFunc<TAsynSpeechResult>)
    begin
      AsynSpeech(ParamProc, CallBackParams);
    end,
    CallBacks);
end;

function TAudioRoute.AsyncAwaitSpeechStream(const ParamProc: TProc<TSpeechParams>;
  const CallBacks: TFunc<TPromiseSpeechStream>): TPromise<TSpeechStreamResult>;
begin
  Result := TPromise<TSpeechStreamResult>.Create(
    procedure(Resolve: TProc<TSpeechStreamResult>; Reject: TProc<Exception>)
    var
      Buffer: TSpeechStreamResult;
      PromiseCallbacks: TPromiseSpeechStream;
    begin
      Buffer := TSpeechStreamResult.Empty;
      var CallBackParams := TUseParamsFactory<TPromiseSpeechStream>.CreateInstance(CallBacks);
      PromiseCallbacks := CallBackParams.Param;

      AsynSpeechStream(ParamProc,
        function: TAsynSpeechStream
        begin
          Result.Sender := PromiseCallbacks.Sender;
          Result.OnStart := PromiseCallbacks.OnStart;

          Result.OnProgress :=
            procedure(Sender: TObject; Chunk: TSpeechStreamChunk)
            begin
              Buffer.Aggregate(Chunk);
              if Assigned(PromiseCallbacks.OnProgress) then
                PromiseCallbacks.OnProgress(Sender, Chunk);
            end;

          Result.OnSuccess :=
            procedure(Sender: TObject)
            begin
              Resolve(Buffer);
            end;

          Result.OnError :=
            procedure(Sender: TObject; Error: string)
            begin
              if Assigned(PromiseCallbacks.OnError) then
                Error := PromiseCallbacks.OnError(Sender, Error);
              Reject(Exception.Create(Error));
            end;

          Result.OnDoCancel :=
            function: Boolean
            begin
              if Assigned(PromiseCallbacks.OnDoCancel) then
                Result := PromiseCallbacks.OnDoCancel()
              else
                Result := False;
            end;

          Result.OnCancellation :=
            procedure(Sender: TObject)
            begin
              var Error := 'aborted';
              if Assigned(PromiseCallbacks.OnCancellation) then
                Error := PromiseCallbacks.OnCancellation(Sender);
              Reject(Exception.Create(Error));
            end;
        end);
    end);
end;

function TAudioRoute.AsyncAwaitTranscription(
  const ParamProc: TProc<TTranscriptionParams>;
  const CallBacks: TFunc<TPromiseTranscription>): TPromise<TTranscription>;
begin
  Result := TAsyncAwaitHelper.WrapAsyncAwait<TTranscription>(
    procedure(const CallBackParams: TFunc<TAsynTranscription>)
    begin
      AsynTranscription(ParamProc, CallBackParams);
    end,
    CallBacks);
end;

function TAudioRoute.AsyncAwaitTranscriptionStream(
  const ParamProc: TProc<TTranscriptionParams>;
  const CallBacks: TFunc<TPromiseTranscriptionStream>): TPromise<TTranscriptionStreamResult>;
begin
  Result := TPromise<TTranscriptionStreamResult>.Create(
    procedure(Resolve: TProc<TTranscriptionStreamResult>; Reject: TProc<Exception>)
    var
      Buffer: TTranscriptionStreamResult;
      PromiseCallbacks: TPromiseTranscriptionStream;
    begin
      Buffer := TTranscriptionStreamResult.Empty;
      var CallBackParams := TUseParamsFactory<TPromiseTranscriptionStream>.CreateInstance(CallBacks);
      PromiseCallbacks := CallBackParams.Param;

      AsynTranscriptionStream(ParamProc,
        function: TAsynTranscriptionStream
        begin
          Result.Sender := PromiseCallbacks.Sender;
          Result.OnStart := PromiseCallbacks.OnStart;

          Result.OnProgress :=
            procedure(Sender: TObject; Event: TTranscriptionStream)
            begin
              Buffer.Aggregate(Event);
              if Assigned(PromiseCallbacks.OnProgress) then
                PromiseCallbacks.OnProgress(Sender, Event);

              if Assigned(Event) and Event.IsError then
                Reject(Exception.Create(Format('(%s) %s', [Event.Code, Event.Message])));
            end;

          Result.OnSuccess :=
            procedure(Sender: TObject)
            begin
              Resolve(Buffer);
            end;

          Result.OnError :=
            procedure(Sender: TObject; Error: string)
            begin
              if Assigned(PromiseCallbacks.OnError) then
                Error := PromiseCallbacks.OnError(Sender, Error);
              Reject(Exception.Create(Error));
            end;

          Result.OnDoCancel :=
            function: Boolean
            begin
              if Assigned(PromiseCallbacks.OnDoCancel) then
                Result := PromiseCallbacks.OnDoCancel()
              else
                Result := False;
            end;

          Result.OnCancellation :=
            procedure(Sender: TObject)
            begin
              var Error := 'aborted';
              if Assigned(PromiseCallbacks.OnCancellation) then
                Error := PromiseCallbacks.OnCancellation(Sender);
              Reject(Exception.Create(Error));
            end;
        end);
    end);
end;

function TAudioRoute.AsyncAwaitTranslatingIntoEnglish(
  const ParamProc: TProc<TTranslationParams>;
  const CallBacks: TFunc<TPromiseTranslation>): TPromise<TTranslation>;
begin
  Result := TAsyncAwaitHelper.WrapAsyncAwait<TTranslation>(
    procedure(const CallBackParams: TFunc<TAsynTranslation>)
    begin
      AsynTranslatingIntoEnglish(ParamProc, CallBackParams);
    end,
    CallBacks);
end;

{ TAudioAsynchronousSupport }

procedure TAudioAsynchronousSupport.AsynSpeech(const ParamProc: TProc<TSpeechParams>;
  const CallBacks: TFunc<TAsynSpeechResult>);
begin
  with TAsynCallBackExec<TAsynSpeechResult, TSpeechResult>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TSpeechResult
      begin
        Result := Self.Speech(ParamProc);
      end);
  finally
    Free;
  end;
end;

procedure TAudioAsynchronousSupport.AsynSpeechStream(
  const ParamProc: TProc<TSpeechParams>;
  const CallBacks: TFunc<TAsynSpeechStream>);
begin
  var CallBackParams := TUseParamsFactory<TAsynSpeechStream>.CreateInstance(CallBacks);

  var Sender := CallBackParams.Param.Sender;
  var OnStart := CallBackParams.Param.OnStart;
  var OnSuccess := CallBackParams.Param.OnSuccess;
  var OnProgress := CallBackParams.Param.OnProgress;
  var OnError := CallBackParams.Param.OnError;
  var OnCancellation := CallBackParams.Param.OnCancellation;
  var OnDoCancel := CallBackParams.Param.OnDoCancel;
  var CancelTag := 0;

  var Task: ITask := TTask.Create(
    procedure()
    begin
      if not Assigned(Sender) then
        Sender := Self;

      if Assigned(OnStart) then
        TThread.Queue(nil,
          procedure
          begin
            OnStart(Sender);
          end);
      try
        var Stop := False;

        SpeechStream(ParamProc,
          procedure(var Chunk: TSpeechStreamChunk; IsDone: Boolean; var Cancel: Boolean)
          begin
            if Assigned(OnDoCancel) and (CancelTag = 0) then
              TThread.Queue(nil,
                procedure
                begin
                  Stop := OnDoCancel();
                  if Stop then
                    Inc(CancelTag);
                end);

            if Stop then
              begin
                if (CancelTag = 1) and Assigned(OnCancellation) then
                  TThread.Queue(nil,
                    procedure
                    begin
                      OnCancellation(Sender);
                    end);
                Inc(CancelTag);
                Cancel := True;
                Exit;
              end;

            if Assigned(Chunk) then
              begin
                var LocalChunk := Chunk;
                Chunk := nil;

                if Assigned(OnProgress) then
                  TThread.Synchronize(TThread.Current,
                    procedure
                    begin
                      try
                        OnProgress(Sender, LocalChunk);
                      finally
                        LocalChunk.Free;
                      end;
                    end)
                else
                  LocalChunk.Free;
              end
            else
            if IsDone then
              begin
                if Assigned(OnSuccess) then
                  TThread.Queue(nil,
                    procedure
                    begin
                      OnSuccess(Sender);
                    end);
              end;
          end);
      except
        on E: Exception do
          begin
            var Error := AcquireExceptionObject;
            try
              var ErrorMsg := (Error as Exception).Message;
              if Assigned(OnError) then
                TThread.Queue(nil,
                  procedure
                  begin
                    OnError(Sender, ErrorMsg);
                  end);
            finally
              Error.Free;
            end;
          end;
      end;
    end);
  Task.Start;
end;

procedure TAudioAsynchronousSupport.AsynTranscription(const ParamProc: TProc<TTranscriptionParams>;
  const CallBacks: TFunc<TAsynTranscription>);
begin
  with TAsynCallBackExec<TAsynTranscription, TTranscription>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TTranscription
      begin
        Result := Self.Transcription(ParamProc);
      end);
  finally
    Free;
  end;
end;

procedure TAudioAsynchronousSupport.AsynTranscriptionStream(
  const ParamProc: TProc<TTranscriptionParams>;
  const CallBacks: TFunc<TAsynTranscriptionStream>);
begin
  var CallBackParams := TUseParamsFactory<TAsynTranscriptionStream>.CreateInstance(CallBacks);

  var Sender := CallBackParams.Param.Sender;
  var OnStart := CallBackParams.Param.OnStart;
  var OnSuccess := CallBackParams.Param.OnSuccess;
  var OnProgress := CallBackParams.Param.OnProgress;
  var OnError := CallBackParams.Param.OnError;
  var OnCancellation := CallBackParams.Param.OnCancellation;
  var OnDoCancel := CallBackParams.Param.OnDoCancel;
  var CancelTag := 0;

  var Task: ITask := TTask.Create(
    procedure()
    begin
      if not Assigned(Sender) then
        Sender := Self;

      if Assigned(OnStart) then
        TThread.Queue(nil,
          procedure
          begin
            OnStart(Sender);
          end);
      try
        var Stop := False;

        TranscriptionStream(ParamProc,
          procedure(var Event: TTranscriptionStream; IsDone: Boolean; var Cancel: Boolean)
          begin
            if Assigned(OnDoCancel) and (CancelTag = 0) then
              TThread.Queue(nil,
                procedure
                begin
                  Stop := OnDoCancel();
                  if Stop then
                    Inc(CancelTag);
                end);

            if Stop then
              begin
                if (CancelTag = 1) and Assigned(OnCancellation) then
                  TThread.Queue(nil,
                    procedure
                    begin
                      OnCancellation(Sender);
                    end);
                Inc(CancelTag);
                Cancel := True;
                Exit;
              end;

            if Assigned(Event) then
              begin
                var LocalEvent := Event;
                Event := nil;

                if Assigned(OnProgress) then
                  TThread.Synchronize(TThread.Current,
                    procedure
                    begin
                      try
                        OnProgress(Sender, LocalEvent);
                      finally
                        LocalEvent.Free;
                      end;
                    end)
                else
                  LocalEvent.Free;
              end
            else
            if IsDone then
              begin
                if Assigned(OnSuccess) then
                  TThread.Queue(nil,
                    procedure
                    begin
                      OnSuccess(Sender);
                    end);
              end;
          end);
      except
        on E: Exception do
          begin
            var Error := AcquireExceptionObject;
            try
              var ErrorMsg := (Error as Exception).Message;
              if Assigned(OnError) then
                TThread.Queue(nil,
                  procedure
                  begin
                    OnError(Sender, ErrorMsg);
                  end);
            finally
              Error.Free;
            end;
          end;
      end;
    end);
  Task.Start;
end;

procedure TAudioAsynchronousSupport.AsynTranslatingIntoEnglish(
  const ParamProc: TProc<TTranslationParams>;
  const CallBacks: TFunc<TAsynTranslation>);
begin
  with TAsynCallBackExec<TAsynTranslation, TTranslation>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TTranslation
      begin
        Result := Self.TranslatingIntoEnglish(ParamProc);
      end);
  finally
    Free;
  end;
end;

function TAudioRoute.Speech(
  const ParamProc: TProc<TSpeechParams>): TSpeechResult;
begin
  Result := API.Post<TSpeechResult, TSpeechParams>('audio/speech', ParamProc, 'Data');
end;

function TAudioRoute.SpeechStream(const ParamProc: TProc<TSpeechParams>;
  const Event: TSpeechStreamEvent): Boolean;
var
  Response: TLockedMemoryStream;
  RetPos: Int64;
  Decoder: TSSEDecoder;
  DoneSent: Boolean;
  AbortFlag: Boolean;
  StreamFormat: TSpeechStreamFormat;
begin
  Response := TLockedMemoryStream.Create;
  try
    RetPos := 0;
    DoneSent := False;
    AbortFlag := False;
    StreamFormat := TSpeechStreamFormat.audio;

    var EmitDone :=
      procedure(var AAbort: Boolean)
      var
        Chunk: TSpeechStreamChunk;
      begin
        if DoneSent then
          Exit;

        DoneSent := True;
        Chunk := nil;
        if Assigned(Event) then
          Event(Chunk, True, AAbort);
      end;

    Decoder := TSSEDecoder.Create(
      procedure(const EventName, Data: string; var AAbort: Boolean)
      var
        Chunk: TSpeechStreamChunk;
        Payload: string;
      begin
        Chunk := nil;
        Payload := Data;

        if AAbort or DoneSent then
          Exit;

        if Payload.Trim.IsEmpty then
          Exit;

        if SameText(Payload.Trim, '[DONE]') then
          begin
            EmitDone(AAbort);
            Exit;
          end;

        try
          Chunk := TSpeechStreamChunk.Create(EventName, Payload);
          if Assigned(Event) then
            Event(Chunk, False, AAbort);
        finally
          Chunk.Free;
        end;
      end
    );

    var Drain :=
      procedure(var Abort: Boolean)
      var
        Bytes: TBytes;
        Snap: Int64;
      begin
        Snap := RetPos;
        try
          while Response.ExtractDelta(RetPos, Bytes) do
            begin
              if Length(Bytes) = 0 then
                Continue;

              if StreamFormat = TSpeechStreamFormat.sse then
                Decoder.Feed(Bytes, Abort)
              else
                begin
                  var Chunk := TSpeechStreamChunk.Create(Bytes);
                  try
                    if Assigned(Event) then
                      Event(Chunk, False, Abort);
                  finally
                    Chunk.Free;
                  end;
                end;

              if Abort then
                Exit;
            end;
        except
          RetPos := Snap;
          raise;
        end;
      end;

    try
      Result := API.Post<TSpeechParams>(
        'audio/speech',
        procedure(Params: TSpeechParams)
        begin
          if Assigned(ParamProc) then
            ParamProc(Params);

          var Reader := TJsonReader.Parse(Params.ToJsonString);
          if Reader.IsValid then
            begin
              var Value := Reader.AsString('stream_format');
              if not Value.IsEmpty then
                begin
                  var ParsedFormat: TSpeechStreamFormat;
                  if TSpeechStreamFormat.TryToParse(Value, ParsedFormat) then
                    StreamFormat := ParsedFormat;
                end;
            end;
        end,
        Response,
        procedure(const Sender: TObject; AContentLength: Int64; AReadCount: Int64; var AAbort: Boolean)
        begin
          if DoneSent then
            begin
              AAbort := True;
              Exit;
            end;

          Drain(AAbort);

          if AAbort then
            AbortFlag := True;
        end
      );
    finally
      if not DoneSent and not AbortFlag then
        begin
          Drain(AbortFlag);
          if StreamFormat = TSpeechStreamFormat.sse then
            Decoder.Flush(AbortFlag);
        end;

      if not DoneSent and not AbortFlag then
        EmitDone(AbortFlag);

      Decoder.Free;
      Drain := nil;
      EmitDone := nil;
    end;
  finally
    Response.Free;
  end;
end;

function TAudioRoute.Transcription(
  const ParamProc: TProc<TTranscriptionParams>): TTranscription;
begin
  Result := API.PostForm<TTranscription, TTranscriptionParams>('audio/transcriptions', ParamProc);
end;

function TAudioRoute.TranscriptionStream(
  const ParamProc: TProc<TTranscriptionParams>;
  const Event: TTranscriptionStreamEvent): Boolean;
var
  Response: TLockedMemoryStream;
  RetPos: Int64;
  Decoder: TSSEDecoder;
  DoneSent: Boolean;
  AbortFlag: Boolean;
begin
  Response := TLockedMemoryStream.Create;
  try
    RetPos := 0;
    DoneSent := False;
    AbortFlag := False;

    var EmitDone :=
      procedure(var AAbort: Boolean)
      var
        Content: TTranscriptionStream;
      begin
        if DoneSent then
          Exit;

        DoneSent := True;
        Content := nil;
        if Assigned(Event) then
          Event(Content, True, AAbort);
      end;

    Decoder := TSSEDecoder.Create(
      procedure(const Data: string; var AAbort: Boolean)
      var
        Line: string;
        Content: TTranscriptionStream;
        IsTerminal: Boolean;
      begin
        Content := nil;

        if AAbort or DoneSent then
          Exit;

        Line := Data.Trim;
        if Line.IsEmpty then
          Exit;

        if SameText(Line, '[DONE]') then
          begin
            EmitDone(AAbort);
            Exit;
          end;

        try
          try
            Content := TApiDeserializer.Parse<TTranscriptionStream>(Line);
          except
            Content := nil;
          end;

          if Assigned(Content) then
            begin
              IsTerminal := Content.IsDone or Content.IsError;

              if Assigned(Event) then
                Event(Content, IsTerminal, AAbort);

              if Content.IsError and not AAbort then
                AAbort := True
              else
              if Content.IsDone and not AAbort then
                EmitDone(AAbort);
            end;
        finally
          Content.Free;
        end;
      end
    );

    var Drain :=
      procedure(var Abort: Boolean)
      var
        Bytes: TBytes;
        Snap: Int64;
      begin
        Snap := RetPos;
        try
          while Response.ExtractDelta(RetPos, Bytes) do
            begin
              if Length(Bytes) = 0 then
                Continue;

              Decoder.Feed(Bytes, Abort);

              if Abort then
                Exit;
            end;
        except
          RetPos := Snap;
          raise;
        end;
      end;

    try
      Result := API.PostForm<TTranscriptionParams>(
        'audio/transcriptions',
        procedure(Params: TTranscriptionParams)
        begin
          if Assigned(ParamProc) then
            ParamProc(Params);
          Params.Stream(True);
        end,
        Response,
        procedure(const Sender: TObject; AContentLength: Int64; AReadCount: Int64; var AAbort: Boolean)
        begin
          if DoneSent then
            begin
              AAbort := True;
              Exit;
            end;

          Drain(AAbort);

          if AAbort then
            AbortFlag := True;
        end
      );
    finally
      if not DoneSent and not AbortFlag then
        begin
          Drain(AbortFlag);
          Decoder.Flush(AbortFlag);
        end;

      if not DoneSent and not AbortFlag then
        EmitDone(AbortFlag);

      Decoder.Free;
      Drain := nil;
      EmitDone := nil;
    end;
  finally
    Response.Free;
  end;
end;

function TAudioRoute.TranslatingIntoEnglish(
  const ParamProc: TProc<TTranslationParams>): TTranslation;
begin
  Result := API.PostForm<TTranslation, TTranslationParams>('audio/translations', ParamProc);
end;

{ TSpeechResult }

function TSpeechResult.GetStream: TStream;
begin
  {--- Create a memory stream to write the decoded content. }
  Result := TMemoryStream.Create;
  try
    {--- Convert the base-64 string directly into the memory stream. }
    DecodeBase64ToStream(Data, Result)
  except
    Result.Free;
    raise;
  end;
end;

procedure TSpeechResult.SaveToFile(const FileName: string; const RaiseError: Boolean);
begin
  case RaiseError of
    True :
      if FileName.Trim.IsEmpty then
        raise Exception.Create('File record aborted. SaveToFile requires a filename.');
    else
      if FileName.Trim.IsEmpty then
        Exit;
  end;

  try
    Self.FFileName := FileName;
    {--- Perform the decoding operation and save it into the file specified by the FileName parameter. }
    DecodeBase64ToFile(Data, FileName)
  except
    raise;
  end;
end;

{ TTranscriptionServerVadParams }

class function TTranscriptionServerVadParams.New: TTranscriptionServerVadParams;
begin
  Result := TTranscriptionServerVadParams.Create;
end;

function TTranscriptionServerVadParams.PrefixPaddingMs(
  const Value: Integer): TTranscriptionServerVadParams;
begin
  Result := TTranscriptionServerVadParams(Add('prefix_padding_ms', Value));
end;

function TTranscriptionServerVadParams.SilenceDurationMs(
  const Value: Integer): TTranscriptionServerVadParams;
begin
  Result := TTranscriptionServerVadParams(Add('silence_duration_ms', Value));
end;

function TTranscriptionServerVadParams.Threshold(
  const Value: Double): TTranscriptionServerVadParams;
begin
  Result := TTranscriptionServerVadParams(Add('threshold', Value));
end;

{ TTranscriptionChunkingStrategyParams }

class function TTranscriptionChunkingStrategyParams.New(
  const Value: string): TTranscriptionChunkingStrategyParams;
begin
  Result := TTranscriptionChunkingStrategyParams.Create;
  Result.&Type(Value);
end;

class function TTranscriptionChunkingStrategyParams.New(
  const Value: TTranscriptionChunkingStrategyType): TTranscriptionChunkingStrategyParams;
begin
  Result := TTranscriptionChunkingStrategyParams.Create;
  Result.&Type(Value);
end;

function TTranscriptionChunkingStrategyParams.ServerVad(
  const Value: TTranscriptionServerVadParams): TTranscriptionChunkingStrategyParams;
begin
  Result := TTranscriptionChunkingStrategyParams(Add('server_vad', Value.Detach));
end;

function TTranscriptionChunkingStrategyParams.&Type(
  const Value: string): TTranscriptionChunkingStrategyParams;
begin
  Result := &Type(TTranscriptionChunkingStrategyType.Parse(Value));
end;

function TTranscriptionChunkingStrategyParams.&Type(
  const Value: TTranscriptionChunkingStrategyType): TTranscriptionChunkingStrategyParams;
begin
  Result := TTranscriptionChunkingStrategyParams(Add('type', Value.ToString));
end;

{ TTranscriptionParams }

function TTranscriptionParams.&File(
  const FileName: string): TTranscriptionParams;
begin
  AddFile('file', FileName);
  Result := Self;
end;

function TTranscriptionParams.ChunkingStrategy(
  const Value: string): TTranscriptionParams;
begin
  Result := ChunkingStrategy(TTranscriptionChunkingStrategyType.Parse(Value));
end;

function TTranscriptionParams.ChunkingStrategy(
  const Value: TTranscriptionChunkingStrategyParams): TTranscriptionParams;
begin
  AddField('chunking_strategy', Value.ToJsonString(True));
  Result := Self;
end;

function TTranscriptionParams.ChunkingStrategy(
  const Value: TTranscriptionChunkingStrategyType): TTranscriptionParams;
begin
  AddField('chunking_strategy', Value.ToString);
  Result := Self;
end;

function TTranscriptionParams.DiarizedJson: TTranscriptionParams;
begin
  Result := ResponseFormat(TTranscriptionResponseFormat.diarized_json);
end;

function TTranscriptionParams.Model(const Value: string): TTranscriptionParams;
begin
  AddField('model', Value);
  Result := Self;
end;

function TTranscriptionParams.Prompt(const Value: string): TTranscriptionParams;
begin
  AddField('prompt', Value);
  Result := Self;
end;

function TTranscriptionParams.Include(
  const Value: TArray<string>): TTranscriptionParams;
begin
  for var Item in Value do
    Include(Item);
  Result := Self;
end;

function TTranscriptionParams.Include(
  const Value: TArray<TTranscriptionInclude>): TTranscriptionParams;
begin
  for var Item in Value do
    Include(Item);
  Result := Self;
end;

function TTranscriptionParams.Include(
  const Value: string): TTranscriptionParams;
begin
  AddField('include[]', Value);
  Result := Self;
end;

function TTranscriptionParams.Include(
  const Value: TTranscriptionInclude): TTranscriptionParams;
begin
  Result := Include(Value.ToString);
end;

function TTranscriptionParams.IncludeLogprobs: TTranscriptionParams;
begin
  Result := Include(TTranscriptionInclude.logprobs);
end;

function TTranscriptionParams.KnownSpeakerNames(
  const Value: TArray<string>): TTranscriptionParams;
begin
  for var Item in Value do
    AddField('known_speaker_names[]', Item);
  Result := Self;
end;

function TTranscriptionParams.KnownSpeakerReference(
  const FileName: string): TTranscriptionParams;
begin
  AddFile('known_speaker_references[]', FileName);
  Result := Self;
end;

function TTranscriptionParams.KnownSpeakerReference(const Stream: TStream;
  const FileName: string): TTranscriptionParams;
begin
  {$IF RTLVersion > 35.0}
    AddStream('known_speaker_references[]', Stream, True, FileName);
  {$ELSE}
    AddStream('known_speaker_references[]', Stream, FileName);
  {$ENDIF}
  Result := Self;
end;

function TTranscriptionParams.KnownSpeakerReferences(
  const Value: TArray<string>): TTranscriptionParams;
begin
  for var Item in Value do
    KnownSpeakerReference(Item);
  Result := Self;
end;

function TTranscriptionParams.ResponseFormat(
  const Value: string): TTranscriptionParams;
begin
  Result := ResponseFormat(TTranscriptionResponseFormat.Parse(Value));
end;

function TTranscriptionParams.ResponseFormat(
  const Value: TTranscriptionResponseFormat): TTranscriptionParams;
begin
  AddField('response_format', Value.ToString);
  Result := Self;
end;

function TTranscriptionParams.TimestampGranularities(
  const Value: TArray<string>): TTranscriptionParams;
begin
  for var Item in Value do
    TimestampGranularity(Item);
  Result := Self;
end;

function TTranscriptionParams.TimestampGranularities(
  const Value: TArray<TTimestampGranularity>): TTranscriptionParams;
begin
  for var Item in Value do
    TimestampGranularity(Item);
  Result := Self;
end;

function TTranscriptionParams.TimestampGranularity(
  const Value: string): TTranscriptionParams;
begin
  Result := TimestampGranularity(TTimestampGranularity.Parse(Value));
end;

function TTranscriptionParams.TimestampGranularity(
  const Value: TTimestampGranularity): TTranscriptionParams;
begin
  AddField('timestamp_granularities[]', Value.ToString);
  Result := Self;
end;

function TTranscriptionParams.Stream(const Value: Boolean): TTranscriptionParams;
begin
  case Value of
    True:
      AddField('stream', 'true');
    False:
      AddField('stream', 'false');
  end;
  Result := Self;
end;

function TTranscriptionParams.Temperature(
  const Value: Double): TTranscriptionParams;
begin
  AddField('temperature', Value.ToString);
  Result := Self;
end;

constructor TTranscriptionParams.Create;
begin
  inherited Create(True);
end;

function TTranscriptionParams.&File(const Stream: TStream;
  const FileName: string): TTranscriptionParams;
begin
  {$IF RTLVersion > 35.0}
    AddStream('file', Stream, True, FileName);
  {$ELSE}
    AddStream('file', Stream, FileName);
  {$ENDIF}
  Result := Self;
end;

function TTranscriptionParams.Language(
  const Value: string): TTranscriptionParams;
begin
  AddField('language', Value);
  Result := Self;
end;

{ TTranscriptionUsage }

destructor TTranscriptionUsage.Destroy;
begin
  FInputTokenDetails.Free;
  inherited;
end;

{ TTranscription }

procedure TTranscription.AfterDeserialize;
begin
  inherited;
  ContentUpdate;
end;

procedure TTranscription.ContentUpdate;
begin
  inherited;

  if JSONResponse.Trim.IsEmpty then
    Exit;

  var Reader := TJsonReader.Parse(JSONResponse);
  if not Reader.IsValid then
    Exit;

  FDuration := Reader.AsString('duration');
  FDurationSeconds := Reader.AsDouble('duration');
  FTask := Reader.AsString('task');

  FUsage.Free;
  FUsage := nil;
  if Reader.IsObjectNode('usage') then
    begin
      FUsage := TTranscriptionUsage.Create;
      FUsage.&Type := Reader.AsString('usage.type');
      FUsage.InputTokens := Reader.AsInt64('usage.input_tokens');
      FUsage.OutputTokens := Reader.AsInt64('usage.output_tokens');
      FUsage.TotalTokens := Reader.AsInt64('usage.total_tokens');
      FUsage.Seconds := Reader.AsDouble('usage.seconds');

      if Reader.IsObjectNode('usage.input_token_details') then
        begin
          FUsage.InputTokenDetails := TTranscriptionInputTokenDetails.Create;
          FUsage.InputTokenDetails.AudioTokens := Reader.AsInt64('usage.input_token_details.audio_tokens');
          FUsage.InputTokenDetails.TextTokens := Reader.AsInt64('usage.input_token_details.text_tokens');
        end;
    end;

  for var Item in FLogprobs do
    Item.Free;
  FLogprobs := [];
  if Reader.Value('logprobs') is TJSONArray then
    begin
      var LogprobsArray := TJSONArray(Reader.Value('logprobs'));
      for var Index := 0 to LogprobsArray.Count - 1 do
        if LogprobsArray.Items[Index] is TJSONObject then
          begin
            var LogprobObj := TJSONObject(LogprobsArray.Items[Index]);
            var Logprob := TTranscriptionLogprob.Create;
            Logprob.Token := LogprobObj.GetPathString('token');
            Logprob.Bytes := TAudioJsonReader.IntegerArrayOf(LogprobObj.GetPathValue('bytes'));
            Logprob.Logprob := LogprobObj.GetPathDouble('logprob');
            FLogprobs := FLogprobs + [Logprob];
          end;
    end;

  for var Item in FSegments do
    Item.Free;
  FSegments := [];
  for var Item in FDiarizedSegments do
    Item.Free;
  FDiarizedSegments := [];

  if Reader.Value('segments') is TJSONArray then
    begin
      var SegmentsArray := TJSONArray(Reader.Value('segments'));
      for var Index := 0 to SegmentsArray.Count - 1 do
        if SegmentsArray.Items[Index] is TJSONObject then
          begin
            var SegmentObj := TJSONObject(SegmentsArray.Items[Index]);

            if Assigned(SegmentObj.GetPathValue('speaker')) or
               SameText(SegmentObj.GetPathString('type'), 'transcript.text.segment') then
              begin
                var Segment := TTranscriptionDiarizedSegment.Create;
                Segment.Id := SegmentObj.GetPathString('id');
                Segment.Start := SegmentObj.GetPathDouble('start');
                Segment.&End := SegmentObj.GetPathDouble('end');
                Segment.Speaker := SegmentObj.GetPathString('speaker');
                Segment.Text := SegmentObj.GetPathString('text');
                Segment.&Type := SegmentObj.GetPathString('type');
                FDiarizedSegments := FDiarizedSegments + [Segment];
              end
            else
              begin
                var Segment := TTranscriptionSegment.Create;
                Segment.Id := SegmentObj.GetPathInt64('id');
                Segment.Seek := SegmentObj.GetPathInt64('seek');
                Segment.Start := SegmentObj.GetPathDouble('start');
                Segment.&End := SegmentObj.GetPathDouble('end');
                Segment.Text := SegmentObj.GetPathString('text');
                Segment.Tokens := TAudioJsonReader.Int64ArrayOf(SegmentObj.GetPathValue('tokens'));
                Segment.Temperature := SegmentObj.GetPathDouble('temperature');
                Segment.AvgLogprob := SegmentObj.GetPathDouble('avg_logprob');
                Segment.CompressionRatio := SegmentObj.GetPathDouble('compression_ratio');
                Segment.NoSpeechProb := SegmentObj.GetPathDouble('no_speech_prob');
                FSegments := FSegments + [Segment];
              end;
          end;
    end;
end;

destructor TTranscription.Destroy;
begin
  FUsage.Free;
  for var Item in FLogprobs do
    Item.Free;
  for var Item in FWords do
    Item.Free;
  for var Item in FSegments do
    Item.Free;
  for var Item in FDiarizedSegments do
    Item.Free;
  inherited;
end;

{ TTranslationParams }

function TTranslationParams.&File(const FileName: string): TTranslationParams;
begin
  AddFile('file', FileName);
  Result := Self;
end;

constructor TTranslationParams.Create;
begin
  inherited Create(True);
end;

function TTranslationParams.&File(const Stream: TStream;
  const FileName: string): TTranslationParams;
begin
  {$IF RTLVersion > 35.0}
    AddStream('file', Stream, True, FileName);
  {$ELSE}
    AddStream('file', Stream, FileName);
  {$ENDIF}
  Result := Self;
end;

function TTranslationParams.Model(const Value: string): TTranslationParams;
begin
  AddField('model', Value);
  Result := Self;
end;

function TTranslationParams.Prompt(const Value: string): TTranslationParams;
begin
  AddField('prompt', Value);
  Result := Self;
end;

function TTranslationParams.ResponseFormat(
  const Value: string): TTranslationParams;
begin
  Result := ResponseFormat(TTranscriptionResponseFormat.Parse(Value));
end;

function TTranslationParams.ResponseFormat(
  const Value: TTranscriptionResponseFormat): TTranslationParams;
begin
  AddField('response_format', Value.ToString);
  Result := Self;
end;

function TTranslationParams.Temperature(
  const Value: Double): TTranslationParams;
begin
  AddField('temperature', Value.ToString);
  Result := Self;
end;

{ TTranslation }

destructor TTranslation.Destroy;
begin
  for var Item in FSegments do
    Item.Free;
  inherited;
end;

end.
