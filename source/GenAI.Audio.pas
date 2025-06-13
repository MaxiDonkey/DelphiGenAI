unit GenAI.Audio;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGenAI
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.SysUtils, System.Classes, System.Threading, REST.Json.Types, System.Net.Mime,
  GenAI.API.Params, GenAI.API, GenAI.Types, GenAI.Async.Support, GenAI.Async.Promise;

type
  /// <summary>
  /// Represents the parameters required to generate speech from text using the OpenAI API.
  /// </summary>
  /// <remarks>
  /// This class encapsulates the settings that can be configured for the speech synthesis request,
  /// including the model to use, the text input, the voice type, the response format, and the speed of speech.
  /// </remarks>
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
    /// Sets the speed of the generated speech.
    /// </summary>
    /// <param name="Value">The speed multiplier for the speech, ranging from 0.25 to 4.0.</param>
    /// <returns>Returns an instance of <see cref="TSpeechParams"/> configured with the specified speed.</returns>
    function Speed(const Value: Double): TSpeechParams;
  end;

  /// <summary>
  /// Represents the result of a speech synthesis request.
  /// </summary>
  /// <remarks>
  /// This class handles the response from the OpenAI API after a speech generation request,
  /// providing methods to access the generated audio content either as a stream or by saving it to a file.
  /// </remarks>
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

  /// <summary>
  /// Represents the parameters required for transcribing audio into text using the OpenAI API.
  /// </summary>
  /// <remarks>
  /// This class encapsulates the settings that can be configured for the audio transcription request,
  /// such as the audio file, model to use, language of the audio, optional prompt, response format, and transcription temperature.
  /// </remarks>
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
    /// Optionally sets the transcription temperature to control the randomness of the output.
    /// </summary>
    /// <param name="Value">A value between 0 and 1, where higher values result in more randomness.</param>
    /// <returns>Returns an instance of <see cref="TTranscriptionParams"/> configured with the specified temperature.</returns>
    function Temperature(const Value: Double): TTranscriptionParams;
  end;

  /// <summary>
  /// Represents a single word from the transcription result with its corresponding timestamps.
  /// </summary>
  /// <remarks>
  /// This class provides detailed information about the timing of each word in the transcribed text,
  /// including the start and end times, which are useful for applications requiring precise synchronization
  /// between the audio and its transcription.
  /// </remarks>
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

  /// <summary>
  /// Represents a segment of the transcription, providing details such as segment text and its corresponding timing.
  /// </summary>
  /// <remarks>
  /// This class details each segment of the transcribed audio, offering a deeper level of granularity for applications
  /// that need to break down the transcription into smaller pieces for analysis or display.
  /// </remarks>
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

  /// <summary>
  /// Represents the full transcription result returned by the OpenAI audio transcription API.
  /// </summary>
  /// <remarks>
  /// This class encapsulates the complete transcription of an audio file, including the language,
  /// duration, and detailed segments and words with their corresponding timestamps.
  /// It serves as a comprehensive container for all the transcription details necessary for further processing
  /// or analysis in applications.
  /// </remarks>
  TTranscription = class(TJSONFingerprint)
  private
    FLanguage: string;
    FDuration: string;
    FText: string;
    FWords: TArray<TTranscriptionWord>;
    FSegments: TArray<TTranscriptionSegment>;
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
    /// The complete transcribed text of the audio file.
    /// </summary>
    /// <remarks>
    /// This property contains the entire textual output generated from the audio transcription,
    /// providing a comprehensive view of the spoken content.
    /// </remarks>
    property Text: string read FText write FText;

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
    /// Destructor for TTranscription, ensures proper cleanup of resources.
    /// </summary>
    /// <remarks>
    /// This destructor is overridden to ensure that any resources, particularly the dynamically allocated
    /// word and segment objects, are properly freed when an instance of TTranscription is destroyed.
    /// </remarks>
    destructor Destroy; override;
  end;

  /// <summary>
  /// Represents the parameters required for translating audio into English using the OpenAI API.
  /// </summary>
  /// <remarks>
  /// This class encapsulates settings for audio translation requests, including the audio file,
  /// the translation model, optional guiding prompt, response format, and translation temperature.
  /// </remarks>
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
    function ResponseFormat(const Value: TTranscriptionResponseFormat): TTranslationParams;

    /// <summary>
    /// Optionally sets the translation temperature to control the randomness of the output.
    /// </summary>
    /// <param name="Value">A value between 0 and 1, where higher values result in more randomness.</param>
    /// <returns>Returns an instance of <see cref="TTranslationParams"/> configured with the specified temperature.</returns>
    function Temperature(const Value: Double): TTranslationParams;
  end;

  /// <summary>
  /// Represents the translation result returned by the OpenAI audio translation API.
  /// </summary>
  /// <remarks>
  /// This class encapsulates the result of translating audio into English, containing the translated text.
  /// It is used to provide a straightforward interface to access the textual translation of spoken content.
  /// </remarks>
  TTranslation = class(TJSONFingerprint)
  private
    FText: string;
  public
    /// <summary>
    /// The translated text from the audio file.
    /// </summary>
    /// <remarks>
    /// This property contains the textual output generated from the audio translation,
    /// providing the English translation of the spoken content.
    /// </remarks>
    property Text: string read FText write FText;
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

  /// <summary>
  /// Provides routes to handle audio-related requests including speech generation, transcription, and translation.
  /// </summary>
  /// <remarks>
  /// This class offers a set of methods to interact with OpenAI's API for generating speech from text,
  /// transcribing audio into text, and translating audio into English. It supports both synchronous and asynchronous
  /// operations to accommodate different application needs.
  /// </remarks>
  TAudioRoute = class(TGenAIRoute)
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
    function Speech(const ParamProc: TProc<TSpeechParams>): TSpeechResult;

    /// <summary>
    /// Synchronously transcribes audio into text using the specified parameters.
    /// </summary>
    /// <param name="ParamProc">A procedure that accepts a TTranscriptionParams instance to set the parameters for the transcription request.</param>
    /// <returns>Returns an instance of TTranscription containing the transcription details.</returns>
    /// <remarks>
    /// This method allows for synchronous audio transcription, appropriate for applications requiring immediate text output from audio.
    /// </remarks>
    function Transcription(const ParamProc: TProc<TTranscriptionParams>): TTranscription;

    /// <summary>
    /// Synchronously translates audio into English using the specified parameters.
    /// </summary>
    /// <param name="ParamProc">A procedure that accepts a TTranslationParams instance to set the parameters for the translation request.</param>
    /// <returns>Returns an instance of TTranslation containing the translated text.</returns>
    /// <remarks>
    /// This method allows for synchronous audio translation, ideal for scenarios where an immediate textual translation is needed.
    /// </remarks>
    function TranslatingIntoEnglish(const ParamProc: TProc<TTranslationParams>): TTranslation;

     /// <summary>
    /// Asynchronously generates speech from text using the specified parameters.
    /// </summary>
    /// <param name="ParamProc">A procedure that accepts a TSpeechParams instance to set the parameters for the speech request.</param>
    /// <param name="CallBacks">A function that returns a callback mechanism for handling the result.</param>
    /// <remarks>
    /// This method provides asynchronous handling of speech synthesis, allowing the application to remain responsive
    /// while processing large or multiple speech synthesis requests.
    /// </remarks>
    procedure AsynSpeech(const ParamProc: TProc<TSpeechParams>; const CallBacks: TFunc<TAsynSpeechResult>);

    /// <summary>
    /// Asynchronously transcribes audio into text using the specified parameters.
    /// </summary>
    /// <param name="ParamProc">A procedure that accepts a TTranscriptionParams instance to set the parameters for the transcription request.</param>
    /// <param name="CallBacks">A function that returns a callback mechanism for handling the transcription result.</param>
    /// <remarks>
    /// This method provides asynchronous handling of audio transcription, which is useful for applications that need
    /// to process audio files or streams without blocking the main application thread.
    /// </remarks>
    procedure AsynTranscription(const ParamProc: TProc<TTranscriptionParams>; const CallBacks: TFunc<TAsynTranscription>);

    /// <summary>
    /// Asynchronously translates audio into English using the specified parameters.
    /// </summary>
    /// <param name="ParamProc">A procedure that accepts a TTranslationParams instance to set the parameters for the translation request.</param>
    /// <param name="CallBacks">A function that returns a callback mechanism for handling the translation result.</param>
    /// <remarks>
    /// This method provides asynchronous handling of audio translation, facilitating the processing of non-English audio
    /// into English text without interrupting the user interface.
    /// </remarks>
    procedure AsynTranslatingIntoEnglish(const ParamProc: TProc<TTranslationParams>; const CallBacks: TFunc<TAsynTranslation>);
  end;

implementation

uses
  GenAI.NetEncoding.Base64;

{ TSpeechParams }

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
  Result := TSpeechParams(Add('response_format', TSpeechFormat.Create(Value).ToString));
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

function TSpeechParams.Voice(const Value: string): TSpeechParams;
begin
  Result := TSpeechParams(Add('voice', TAudioVoice.Create(Value).ToString));
end;

function TSpeechParams.Voice(const Value: TAudioVoice): TSpeechParams;
begin
  Result := TSpeechParams(Add('voice', Value.ToString));
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

procedure TAudioRoute.AsynSpeech(const ParamProc: TProc<TSpeechParams>;
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

procedure TAudioRoute.AsynTranscription(const ParamProc: TProc<TTranscriptionParams>;
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

procedure TAudioRoute.AsynTranslatingIntoEnglish(
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

function TAudioRoute.Transcription(
  const ParamProc: TProc<TTranscriptionParams>): TTranscription;
begin
  Result := API.PostForm<TTranscription, TTranscriptionParams>('audio/transcriptions', ParamProc);
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

{ TTranscriptionParams }

function TTranscriptionParams.&File(
  const FileName: string): TTranscriptionParams;
begin
  AddFile('file', FileName);
  Result := Self;
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

function TTranscriptionParams.ResponseFormat(
  const Value: string): TTranscriptionParams;
begin
  AddField('response_format', TTranscriptionResponseFormat.Create(Value).ToString);
  Result := Self;
end;

function TTranscriptionParams.ResponseFormat(
  const Value: TTranscriptionResponseFormat): TTranscriptionParams;
begin
  AddField('response_format', Value.ToString);
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

{ TTranscription }

destructor TTranscription.Destroy;
begin
  for var Item in FWords do
    Item.Free;
  for var Item in FSegments do
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

end.
