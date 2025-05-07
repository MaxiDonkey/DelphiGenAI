unit GenAI.Types;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGenAI
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.SysUtils, System.TypInfo, System.Variants, System.Rtti, GenAI.Consts,
  GenAI.API.Params;

{$SCOPEDENUMS ON}

type
  TIntegerOrNull = type Variant;

  TIntegerOrNullHelper = record Helper for TIntegerOrNull
    constructor Create(const Value: Variant);
    function isNull: Boolean;
    function ToInteger: Integer;
    function ToString: string;
  end;

  TInt64OrNull = type Variant;

  TInt64OrNullHelper = record Helper for TInt64OrNull
    constructor Create(const Value: Variant);
    function isNull: Boolean;
    function ToUtcDateString: string;
    function ToInteger: Int64;
    function ToString: string;
  end;

  TDoubleOrNull = type Variant;

  TDoubleOrNullHelper = record Helper for TDoubleOrNull
    constructor Create(const Value: Variant);
    function isNull: Boolean;
    function ToDouble: Double;
    function ToString: string;
  end;

  TBooleanOrNull = type Variant;

  TBooleanOrNullHelper = record Helper for TBooleanOrNull
    constructor Create(const Value: Variant);
    function isNull: Boolean;
    function ToBoolean: Boolean;
    function ToString: string;
  end;

  TStringOrNull = type Variant;

  TStringOrNullHelper = record Helper for TStringOrNull
    constructor Create(const Value: Variant);
    function isNull: Boolean;
    function ToString: string;
  end;

  TMetadataInterceptor = class(TJSONInterceptorStringToString)
  public
    procedure StringReverter(Data: TObject; Field: string; Arg: string); override;
  end;

  {$REGION 'GenAI.Batch.Interfaces'}

  /// <summary>
  /// Enumerates the supported relative URLs for OpenAI's batch processing API.
  /// </summary>
  /// <remarks>
  /// The <c>TBatchUrl</c> type defines the specific endpoints that can be used when constructing
  /// batch requests to OpenAI's API. Each enumeration value corresponds to a relative URL path
  /// for a particular API functionality.
  /// </remarks>
  TBatchUrl = (
    /// <summary>
    /// Represents the relative URL for the Chat Completions endpoint.
    /// </summary>
    chat_completions,
    /// <summary>
    /// Represents the relative URL for the Embeddings endpoint.
    /// </summary>
    embeddings
  );

  TBatchUrlHelper = record Helper for TBatchUrl
    constructor Create(const Value: string);
    function ToString: string;
  end;

  {$ENDREGION}

  {$REGION 'GenAI.Schema'}

  /// <summary>
  /// Type contains the list of OpenAPI data types as defined by :
  /// <para>
  /// - https://spec.openapis.org/oas/v3.0.3#data-types
  /// </para>
  /// </summary>
  TSchemaType = (
    /// <summary>
    /// Not specified, should not be used.
    /// </summary>
    unspecified,
    /// <summary>
    /// String type.
    /// </summary>
    &string,
    /// <summary>
    /// Number type.
    /// </summary>
    number,
    /// <summary>
    /// Integer type.
    /// </summary>
    &integer,
    /// <summary>
    /// Boolean type.
    /// </summary>
    &boolean,
    /// <summary>
    /// Array type.
    /// </summary>
    &array,
    /// <summary>
    /// Object type.
    /// </summary>
    &object
  );

  TSchemaTypeHelper = record Helper for TSchemaType
    constructor Create(const Value: string);
    function ToString: string;
  end;

  {$ENDREGION}

  {$REGION 'GenAI.Chat'}

  /// <summary>
  /// Specifies the roles used in the chat-based API to define the behavior
  /// and context of messages exchanged between the user and the model.
  /// </summary>
  /// <remarks>
  /// The roles help structure the conversation and guide the model's
  /// responses by assigning different functions to the participants.
  /// Each role has a specific purpose and impact on how the model interprets
  /// the input and generates the output.
  /// </remarks>
  TRole = (
    /// <summary>
    /// Represents the model's responses generated during the conversation.
    /// </summary>
    /// <remarks>
    /// The assistant role is used to define messages that provide answers,
    /// clarifications, or actions requested by the user.
    /// </remarks>
    assistant,
    /// <summary>
    /// Represents messages sent by the end user of the model.
    /// </summary>
    /// <remarks>
    /// The user role defines the primary input for the model, often containing
    /// questions, instructions, or other prompts to request information or perform tasks.
    /// </remarks>
    user,
    /// <summary>
    /// Represents instructions or configuration defined by the developer.
    /// </summary>
    /// <remarks>
    /// The developer role, formerly known as the system role, sets the overarching
    /// behavior and tone of the model. These instructions are prioritized and guide
    /// the model in interpreting and responding to user inputs.
    /// </remarks>
    developer,
    /// <summary>
    /// Represents the system-level instructions or metadata.
    /// </summary>
    /// <remarks>
    /// The system role is typically used to define the broader behavior and
    /// system-level rules for the chat interactions. It influences the entire
    /// conversation at a higher level.
    /// </remarks>
    system,
    /// <summary>
    /// Represents a tool or action within the context of the conversation.
    /// </summary>
    /// <remarks>
    /// The tool role indicates the invocation of external tools or systems
    /// to supplement the model's functionality. It is commonly used for
    /// retrieval, calculations, or integration with external APIs.
    /// </remarks>
    tool
  );

  TRoleHelper = record Helper for TRole
    constructor Create(const Value: string);
    function ToString: string;
  end;

  TRoleInterceptor = class(TJSONInterceptorStringToString)
    function StringConverter(Data: TObject; Field: string): string; override;
    procedure StringReverter(Data: TObject; Field: string; Arg: string); override;
  end;

  /// <summary>
  /// Specifies the audio formats available for input and output operations
  /// when using audio-related functionalities in the model.
  /// </summary>
  /// <remarks>
  /// The TAudioFormat enumeration defines the supported audio formats
  /// that can be used for audio input and output. Some formats are available
  /// for both input and output, while others are restricted to output only.
  /// </remarks>
  TAudioFormat = (
    /// <summary>
    /// Waveform Audio File Format (WAV).
    /// </summary>
    /// <remarks>
    /// This format is uncompressed and provides high-quality audio.
    /// It is supported for both input and output operations.
    /// </remarks>
    wav,
    /// <summary>
    /// MPEG Layer III Audio (MP3).
    /// </summary>
    /// <remarks>
    /// This is a compressed audio format widely used for its smaller file size
    /// while retaining acceptable quality. It is supported for both input and output operations.
    /// </remarks>
    mp3,
    /// <summary>
    /// Free Lossless Audio Codec (FLAC).
    /// </summary>
    /// <remarks>
    /// This is a lossless audio compression format that maintains
    /// the highest quality without loss of fidelity. It is supported only for output operations.
    /// </remarks>
    flac,
    /// <summary>
    /// Opus Audio Codec (OPUS).
    /// </summary>
    /// <remarks>
    /// A highly efficient codec designed for interactive speech and music transmission.
    /// It provides excellent audio quality at low bitrates. It is supported only for output operations.
    /// </remarks>
    opus,
    /// <summary>
    /// Pulse Code Modulation 16-bit (PCM16).
    /// </summary>
    /// <remarks>
    /// A raw, uncompressed audio format often used for high-quality audio
    /// processing. It is supported only for output operations.
    /// </remarks>
    pcm16
  );

  TAudioFormatHelper = record Helper for TAudioFormat
    constructor Create(const Value: string);
    function ToString: string;
    class function MimeTypeInput(const Value: string): TAudioFormat; static;
  end;

  /// <summary>
  /// Specifies the level of detail for images used in chat completion requests.
  /// </summary>
  /// <remarks>
  /// The TImageDetail enumeration defines the supported levels of detail for images
  /// provided as input in chat completions. Adjusting the detail level influences how
  /// much information is extracted or emphasized in the processing of the image.
  /// </remarks>
  TImageDetail = (
    /// <summary>
    /// Low - A lower level of image detail.
    /// </summary>
    /// <remarks>
    /// The low detail level processes images with reduced focus on finer details,
    /// resulting in faster processing times. This setting is suitable for simple
    /// images or scenarios where fine-grained information is not critical.
    /// </remarks>
    low,
    /// <summary>
    /// High - A higher level of image detail.
    /// </summary>
    /// <remarks>
    /// The high detail level processes images with greater attention to finer details,
    /// enabling more precise interpretation or generation. This setting is ideal for
    /// complex images or when accuracy and detail are important.
    /// </remarks>
    high,
    /// <summary>
    /// Auto - Automatically determines the level of image detail.
    /// </summary>
    /// <remarks>
    /// The auto setting allows the model to dynamically choose the appropriate level
    /// of detail based on the input image and context. This is the default option,
    /// balancing processing time and detail extraction.
    /// </remarks>
    auto
  );

  TImageDetailHelper = record Helper for TImageDetail
    constructor Create(const Value: string);
    function ToString: string;
  end;

  TImageDetailInterceptor = class(TJSONInterceptorStringToString)
    function StringConverter(Data: TObject; Field: string): string; override;
    procedure StringReverter(Data: TObject; Field: string; Arg: string); override;
  end;

  /// <summary>
  /// Specifies the level of reasoning effort used by the o1 series models during a completion request.
  /// </summary>
  /// <remarks>
  /// The TReasoningEffort enumeration defines the complexity and depth of reasoning the model applies
  /// to generate responses. The reasoning effort impacts both the latency and the number of reasoning tokens generated.
  /// </remarks>
  TReasoningEffort = (
    /// <summary>
    /// Low - Minimal reasoning effort.
    /// </summary>
    /// <remarks>
    /// This level of reasoning is suitable for straightforward tasks that require little to no complex thinking.
    /// It minimizes the number of reasoning tokens generated, resulting in faster responses and lower costs.
    /// </remarks>
    low,
    /// <summary>
    /// Medium - Moderate reasoning effort.
    /// </summary>
    /// <remarks>
    /// This level strikes a balance between speed and complexity. It is ideal for tasks that require some
    /// level of logical reasoning, such as basic coding, problem-solving, or general explanations.
    /// </remarks>
    medium,
    /// <summary>
    /// High - Advanced reasoning effort.
    /// </summary>
    /// <remarks>
    /// This level is designed for complex reasoning tasks, such as solving advanced mathematical problems,
    /// implementing intricate algorithms, or addressing challenging scientific questions.
    /// High reasoning effort generates more reasoning tokens and requires longer processing times,
    /// which may result in higher costs.
    /// </remarks>
    high
  );

  TReasoningEffortHelper = record Helper for TReasoningEffort
    constructor Create(const Value: string);
    function ToString: string;
  end;

  TReasoningEffortInterceptor = class(TJSONInterceptorStringToString)
    function StringConverter(Data: TObject; Field: string): string; override;
    procedure StringReverter(Data: TObject; Field: string; Arg: string); override;
  end;

  /// <summary>
  /// Specifies the supported input and output modalities for the GPT-4o-audio-preview model.
  /// </summary>
  /// <remarks>
  /// The TModalities enumeration defines the types of data that the model can process
  /// as input or generate as output. The current supported modalities are text and audio,
  /// which can be used in various combinations to create flexible interaction patterns.
  /// </remarks>
  TModalities = (
    /// <summary>
    /// Text - The model processes or generates text as input or output.
    /// </summary>
    /// <remarks>
    /// Text is the default modality for many tasks, allowing for both textual input
    /// prompts and output responses. It is often used in scenarios where precise
    /// communication or reasoning is required.
    /// </remarks>
    text,
    /// <summary>
    /// Audio - The model processes or generates audio as input or output.
    /// </summary>
    /// <remarks>
    /// Audio allows for spoken input to be transcribed into text or for generating
    /// speech output. This modality is ideal for voice-based applications,
    /// transcription tasks, or scenarios requiring audio responses.
    /// </remarks>
    audio
  );

  TModalitiesHelper = record Helper for TModalities
    constructor Create(const Value: string);
    function ToString: string;
  end;

  /// <summary>
  /// Specifies the available voice options for audio responses generated by the model.
  /// </summary>
  /// <remarks>
  /// The TChatVoice enumeration defines a set of expressive and natural-sounding
  /// voices that can be used to personalize the audio output. While most voices
  /// are recommended for high-quality and expressive output, some legacy voices
  /// are supported but may have reduced expressiveness.
  /// </remarks>
  TChatVoice = (
    /// <summary>
    /// Ash - A neutral and balanced voice suitable for a wide range of contexts.
    /// </summary>
    /// <remarks>
    /// Ash provides clear and steady speech output, making it ideal for general use.
    /// This voice maintains a professional and neutral tone.
    /// </remarks>
    ash,
    /// <summary>
    /// Ballad - A warm and melodious voice designed for expressive communication.
    /// </summary>
    /// <remarks>
    /// Ballad excels at creating engaging and emotional tones, often preferred for
    /// storytelling, customer support, or other contexts requiring a softer and friendlier style.
    /// </remarks>
    ballad,
    /// <summary>
    /// Coral - A vibrant and energetic voice designed to convey enthusiasm.
    /// </summary>
    /// <remarks>
    /// Coral is ideal for use cases that require a lively and dynamic tone,
    /// such as promotional content or upbeat messaging.
    /// </remarks>
    coral,
    /// <summary>
    /// Sage - A calm and soothing voice that emphasizes clarity and relaxation.
    /// </summary>
    /// <remarks>
    /// Sage is perfect for applications such as guided meditations, instructions,
    /// or any scenario that benefits from a tranquil and reassuring voice.
    /// </remarks>
    sage,
    /// <summary>
    /// Verse - A rich and articulate voice with a refined and formal tone.
    /// </summary>
    /// <remarks>
    /// Verse is well-suited for professional or educational use cases where
    /// precision and clarity are critical.
    /// </remarks>
    verse
  );

  TChatVoiceHelper = record Helper for TChatVoice
    constructor Create(const Value: string);
    function ToString: string;
  end;

  /// <summary>
  /// Specifies the behavior of the model regarding the use of tools during execution.
  /// </summary>
  /// <remarks>
  /// The TToolChoice enumeration defines how the model interacts with tools, such as functions,
  /// during the generation of responses. It allows you to control whether the model uses tools
  /// and how it decides to call them.
  /// </remarks>
  TToolChoice = (
    /// <summary>
    /// None - The model will not call any tools and will generate a direct message instead.
    /// </summary>
    /// <remarks>
    /// Use this option when you want the model to generate responses purely from its own reasoning
    /// and avoid any interaction with tools or external functions.
    /// This is the default behavior when no tools are present.
    /// </remarks>
    none,
    /// <summary>
    /// Auto - The model can decide whether to generate a message or call one or more tools.
    /// </summary>
    /// <remarks>
    /// This option provides the model with flexibility to determine the best course of action
    /// based on the input and available tools. It is the default behavior when tools are present.
    /// </remarks>
    auto,
    /// <summary>
    /// Required - The model must call one or more tools during execution.
    /// </summary>
    /// <remarks>
    /// Use this option when tool usage is mandatory for the task at hand. The model will
    /// strictly adhere to calling the tools specified and will not generate a direct message
    /// without doing so.
    /// </remarks>
    required);

  TToolChoiceHelper = record Helper for TToolChoice
    constructor Create(const Value: string);
    function ToString: string;
  end;

  /// <summary>
  /// Specifies the reasons why the model stopped generating tokens during a chat completion response.
  /// </summary>
  /// <remarks>
  /// The TFinishReason enumeration represents the various conditions under which the model concludes
  /// token generation. It provides insight into whether the stop was expected, due to a limitation, or
  /// triggered by a specific event.
  /// </remarks>
  TFinishReason = (
    /// <summary>
    /// Stop - The model reached a natural stop point or a specified stop sequence.
    /// </summary>
    /// <remarks>
    /// This is the most common reason for completion and indicates that the model
    /// has successfully generated a complete response as intended.
    /// </remarks>
    stop,
    /// <summary>
    /// Length - The model stopped because the maximum token limit was reached.
    /// </summary>
    /// <remarks>
    /// This occurs when the token count exceeds the maximum specified in the request.
    /// The response may be incomplete, and increasing the token limit could yield
    /// a more complete result.
    /// </remarks>
    length,
    /// <summary>
    /// Content_Filter - The model omitted content due to a flag triggered by content filters.
    /// </summary>
    /// <remarks>
    /// This reason indicates that the generated content was flagged as potentially
    /// violating safety or policy guidelines. The response may have been modified
    /// or truncated to comply with content standards.
    /// </remarks>
    content_filter,
    /// <summary>
    /// Tool_Calls - The model stopped because it invoked a tool or function.
    /// </summary>
    /// <remarks>
    /// This reason indicates that the model has delegated part of the task to an
    /// external tool or function. The tool or function may provide supplementary
    /// data or complete the response on behalf of the model.
    /// </remarks>
    tool_calls
  );

  TFinishReasonHelper = record Helper for TFinishReason
    constructor Create(const Value: string);
    function ToString: string;
  end;

  TFinishReasonInterceptor = class(TJSONInterceptorStringToString)
    function StringConverter(Data: TObject; Field: string): string; override;
    procedure StringReverter(Data: TObject; Field: string; Arg: string); override;
  end;

  /// <summary>
  /// Specifies the types of tools the model can call during execution.
  /// </summary>
  /// <remarks>
  /// The TToolCalls enumeration defines the supported types of tools that the model
  /// can invoke during the generation of responses. Currently, only the "function"
  /// tool type is supported, which allows the model to generate JSON inputs for specific functions.
  /// </remarks>
  TToolCalls = (
    /// <summary>
    /// Function - Represents a callable function tool.
    /// </summary>
    /// <remarks>
    /// The function type enables the model to interact with developer-defined functions by
    /// generating JSON inputs. Functions can be used to extend the model's capabilities,
    /// such as performing calculations, retrieving data, or triggering external processes.
    /// </remarks>
    tfunction
  );

  TToolCallsHelper = record Helper for TToolCalls
    constructor Create(const Value: string);
    function ToString: string;
  end;

  TToolCallsInterceptor = class(TJSONInterceptorStringToString)
    function StringConverter(Data: TObject; Field: string): string; override;
    procedure StringReverter(Data: TObject; Field: string; Arg: string); override;
  end;

  /// <summary>
  /// High level guidance for the amount of context window space to use for the search.
  /// </summary>
  TSearchWebOptions = (
    /// <summary>
    /// Least context, lowest cost, fastest response, but potentially lower answer quality.
    /// </summary>
    low,
    /// <summary>
    /// (default): Balanced context, cost, and latency.
    /// </summary>
    medium,
    /// <summary>
    /// Most comprehensive context, highest cost, slower response.
    /// </summary>
    high
  );

  TSearchWebOptionsHelper = record Helper for TSearchWebOptions
    constructor Create(const Value: string);
    function ToString: string;
  end;

  {$ENDREGION}

  {$REGION 'GenAI.Audio'}

  /// <summary>
  /// Specifies the available voices for generating audio in text-to-speech (TTS) operations.
  /// </summary>
  /// <remarks>
  /// The TAudioVoice enumeration defines a range of voices that can be used to personalize
  /// the audio output for text-to-speech generation. Each voice offers unique characteristics
  /// and is suited for different use cases.
  /// </remarks>
type
  TAudioVoice = (
    /// <summary>
    /// Alloy - A basic and straightforward voice with minimal expressiveness.
    /// </summary>
    /// <remarks>
    /// Alloy is suitable for simple applications or when a neutral tone is sufficient.
    /// It is less expressive compared to the more advanced voices.
    /// </remarks>
    alloy,
    /// <summary>
    /// Ash - A versatile and balanced voice suitable for general purposes.
    /// </summary>
    /// <remarks>
    /// Ash provides a clear and steady tone, making it ideal for professional or
    /// everyday applications where clarity is important.
    /// </remarks>
    ash,
    /// <summary>
    /// Coral - A vibrant and expressive voice designed for energetic and engaging output.
    /// </summary>
    /// <remarks>
    /// Coral is perfect for scenarios where enthusiasm and energy are required,
    /// such as marketing or promotional audio content.
    /// </remarks>
    coral,
    /// <summary>
    /// Echo - A basic voice with minimal expressiveness, primarily for legacy support.
    /// </summary>
    /// <remarks>
    /// Echo may be used for simple or experimental applications, but it lacks
    /// the natural tone and advanced features of more expressive voices.
    /// </remarks>
    echo,
    /// <summary>
    /// Fable - A rich and storytelling-oriented voice with a warm and engaging tone.
    /// </summary>
    /// <remarks>
    /// Fable is ideal for use cases such as audiobooks, narrations, and other
    /// storytelling contexts where a captivating voice is essential.
    /// </remarks>
    fable,
    /// <summary>
    /// Onyx - A deep and authoritative voice with a commanding tone.
    /// </summary>
    /// <remarks>
    /// Onyx is well-suited for formal announcements, educational content, or any
    /// scenario requiring a strong and confident presence.
    /// </remarks>
    onyx,
    /// <summary>
    /// Nova - A bright and uplifting voice with a modern and youthful feel.
    /// </summary>
    /// <remarks>
    /// Nova is perfect for dynamic and contemporary use cases, such as product
    /// demos, explainer videos, or engaging digital content.
    /// </remarks>
    nova,
    /// <summary>
    /// Sage - A calm and soothing voice that emphasizes clarity and relaxation.
    /// </summary>
    /// <remarks>
    /// Sage is particularly effective for guided meditations, instructions, or
    /// any scenario requiring a tranquil and reassuring voice.
    /// </remarks>
    sage,
    /// <summary>
    /// Shimmer - A playful and expressive voice with a whimsical tone.
    /// </summary>
    /// <remarks>
    /// Shimmer is ideal for creative and imaginative contexts, such as children’s
    /// stories, games, or other lighthearted applications.
    /// </remarks>
    shimmer
  );

  TAudioVoiceHelper = record Helper for TAudioVoice
    constructor Create(const Value: string);
    function ToString: string;
  end;

  /// <summary>
  /// Specifies the audio formats available for speech output in text-to-speech (TTS) operations.
  /// </summary>
  /// <remarks>
  /// The TSpeechFormat enumeration defines the supported audio file formats for speech generation.
  /// Each format has unique characteristics that make it suitable for specific use cases, such as
  /// compatibility, compression, or audio quality.
  /// </remarks>
  TSpeechFormat = (
    /// <summary>
    /// MP3 - MPEG Layer III Audio.
    /// </summary>
    /// <remarks>
    /// A widely used compressed audio format known for its small file size and good quality.
    /// MP3 is compatible with almost all devices and applications, making it a versatile choice.
    /// </remarks>
    mp3,
    /// <summary>
    /// Opus - Opus Audio Codec.
    /// </summary>
    /// <remarks>
    /// A highly efficient audio codec optimized for interactive speech and music transmission.
    /// Opus provides excellent quality at low bitrates and is ideal for streaming or bandwidth-constrained applications.
    /// </remarks>
    opus,
    /// <summary>
    /// AAC - Advanced Audio Codec.
    /// </summary>
    /// <remarks>
    /// A compressed audio format offering better quality than MP3 at similar bitrates.
    /// AAC is widely used in modern devices and is commonly found in streaming services and mobile applications.
    /// </remarks>
    aac,
    /// <summary>
    /// FLAC - Free Lossless Audio Codec.
    /// </summary>
    /// <remarks>
    /// A lossless compression format that preserves audio quality without sacrificing any fidelity.
    /// FLAC is suitable for high-quality audio applications where accuracy and detail are critical.
    /// </remarks>
    flac,
    /// <summary>
    /// WAV - Waveform Audio File Format.
    /// </summary>
    /// <remarks>
    /// An uncompressed audio format that offers the highest quality.
    /// WAV is commonly used in professional audio editing, mastering, and archival purposes due to its raw data fidelity.
    /// </remarks>
    wav,
    /// <summary>
    /// PCM - Pulse Code Modulation.
    /// </summary>
    /// <remarks>
    /// A raw, uncompressed audio format that directly represents sound waveforms.
    /// PCM is often used in professional audio systems and processing where raw, high-quality audio data is needed.
    /// </remarks>
    pcm
  );

  TSpeechFormatHelper = record Helper for TSpeechFormat
    constructor Create(const Value: string);
    function ToString: string;
  end;

  /// <summary>
  /// Specifies the available output formats for transcription responses.
  /// </summary>
  /// <remarks>
  /// The TTranscriptionResponseFormat enumeration defines the formats in which
  /// the transcription results can be returned. Different formats are suited for
  /// various use cases, such as simple text outputs, detailed JSON structures,
  /// or subtitle files for video applications.
  /// </remarks>
  TTranscriptionResponseFormat = (
    /// <summary>
    /// JSON - A structured format containing transcription data in JSON.
    /// </summary>
    /// <remarks>
    /// This format provides a detailed and structured output, making it suitable
    /// for programmatic parsing and integration with systems that require data
    /// in JSON format.
    /// </remarks>
    json,
    /// <summary>
    /// Text - A plain text format containing only the transcription.
    /// </summary>
    /// <remarks>
    /// This format outputs the transcription as a simple text string, ideal for
    /// scenarios where minimal formatting and simplicity are required.
    /// </remarks>
    text,
    /// <summary>
    /// SRT - SubRip Subtitle format for captions.
    /// </summary>
    /// <remarks>
    /// This format generates subtitles with timestamps in the widely used SRT
    /// format, which can be easily used for video captioning or subtitling.
    /// </remarks>
    srt,
    /// <summary>
    /// Verbose_JSON - A detailed JSON format with timestamps and additional metadata.
    /// </summary>
    /// <remarks>
    /// This format provides comprehensive transcription details, including word-level
    /// or segment-level timestamps (if enabled). It is ideal for applications requiring
    /// granular control or analysis of transcription data.
    /// </remarks>
    verbose_json,
    /// <summary>
    /// VTT - Web Video Text Tracks format for captions.
    /// </summary>
    /// <remarks>
    /// This format outputs captions in the VTT format, which is compatible with
    /// web-based video players and other applications requiring timed captions.
    /// </remarks>
    vtt
  );

  TTranscriptionResponseFormatHelper = record Helper for TTranscriptionResponseFormat
    constructor Create(const Value: string);
    function ToString: string;
  end;

  {$ENDREGION}

  {$REGION 'GenAI.Embeddings'}

  /// <summary>
  /// Specifies the available encoding formats for embeddings in the API response.
  /// </summary>
  /// <remarks>
  /// The TEncodingFormat enumeration defines the formats in which the embedding vectors
  /// can be returned. Each format serves different purposes depending on the use case,
  /// such as numerical computation or compact representation.
  /// </remarks>
  TEncodingFormat = (
    /// <summary>
    /// Float - The embeddings are returned as an array of floating-point numbers.
    /// </summary>
    /// <remarks>
    /// This format provides the embeddings as precise numerical data, suitable for
    /// direct computation, mathematical operations, or integration into machine
    /// learning pipelines. It is the default and most commonly used format.
    /// </remarks>
    float,
    /// <summary>
    /// Base64 - The embeddings are returned as a base64-encoded string.
    /// </summary>
    /// <remarks>
    /// This format provides the embeddings as a compact base64-encoded string,
    /// which is ideal for storage or transmission where raw numerical data
    /// is not practical. The base64 format can be decoded to retrieve the original
    /// floating-point array if needed.
    /// </remarks>
    base64
  );

  TEncodingFormatHelper = record Helper for TEncodingFormat
    constructor Create(const Value: string);
    function ToString: string;
  end;

  {$ENDREGION}

  {$REGION 'GenAI.Moderation'}

  THarmCategories = (
    hate,
    hateThreatening,
    harassment,
    harassmentThreatening,
    illicit,
    illicitViolent,
    selfHarm,
    selfHarmIntent,
    selfHarmInstructions,
    sexual,
    sexualMinors,
    violence,
    violenceGraphic
  );

  THarmCategoriesHelper = record Helper for THarmCategories
    function ToString: string;
    class function Create(const Value: string): TEncodingFormat; static;
  end;

  {$ENDREGION}

  {$REGION 'GenAI.Images'}

  /// <summary>
  /// Specifies the format of the response for image generation requests.
  /// </summary>
  /// <remarks>
  /// The TResponseFormat enumeration defines the output format for images generated by the API.
  /// Depending on the use case, the images can be returned as a URL pointing to the generated image
  /// or as a base64-encoded JSON string.
  /// </remarks>
  TResponseFormat = (
    /// <summary>
    /// URL - The generated image is returned as a URL.
    /// </summary>
    /// <remarks>
    /// This is the default format for responses. The API returns a URL pointing to the
    /// generated image, which can be accessed directly via a browser or used in applications.
    /// This format is ideal for immediate use or display of the image.
    /// </remarks>
    url,
    /// <summary>
    /// B64_JSON - The generated image is returned as a base64-encoded JSON string.
    /// </summary>
    /// <remarks>
    /// This format provides the image content encoded as a base64 string within a JSON object.
    /// It is suitable for scenarios where the image needs to be embedded directly in another
    /// application, stored inline, or transmitted without relying on external URLs.
    /// </remarks>
    b64_json
  );

  TResponseFormatHelper = record Helper for TResponseFormat
    constructor Create(const Value: string);
    function ToString: string;
  end;

  /// <summary>
  /// Specifies the size of the images generated by the API.
  /// </summary>
  /// <remarks>
  /// The TImageSize enumeration defines the supported dimensions for generated images.
  /// The available sizes depend on the specific model being used (e.g., DALL-E 2 or DALL-E 3).
  /// Choosing the appropriate size affects the resolution and level of detail in the output image.
  /// </remarks>
  TImageSize = (
    /// <summary>
    /// 256x256 - A small square image with dimensions 256x256 pixels.
    /// </summary>
    /// <remarks>
    /// This size is suitable for low-resolution requirements or scenarios where small,
    /// compact images are needed, such as thumbnails or icons. Supported in DALL-E 2.
    /// </remarks>
    r256x256,
    /// <summary>
    /// 512x512 - A medium square image with dimensions 512x512 pixels.
    /// </summary>
    /// <remarks>
    /// This size provides a balance between resolution and file size, making it useful
    /// for general-purpose applications or when moderate detail is sufficient. Supported in DALL-E 2.
    /// </remarks>
    r512x512,
    /// <summary>
    /// 1024x1024 - A high-resolution square image with dimensions 1024x1024 pixels.
    /// </summary>
    /// <remarks>
    /// This is the default size for image generation and is suitable for scenarios
    /// requiring high detail and clarity. Supported in both DALL-E 2 and DALL-E 3.
    /// </remarks>
    r1024x1024,
    /// <summary>
    /// 1792x1024 - A wide rectangular image with dimensions 1792x1024 pixels.
    /// </summary>
    /// <remarks>
    /// This size is designed for applications requiring a landscape-oriented image
    /// with higher resolution and detail. Supported in DALL-E 3.
    /// </remarks>
    r1792x1024,
    /// <summary>
    /// 1024x1792 - A tall rectangular image with dimensions 1024x1792 pixels.
    /// </summary>
    /// <remarks>
    /// This size is ideal for portrait-oriented applications, such as posters,
    /// banners, or artwork. Supported in DALL-E 3.
    /// </remarks>
    r1024x1792,
    /// <summary>
    /// landscape
    /// </summary>
    /// <remarks>
    /// Only for gpt-image-1
    /// </remarks>
    r1536x1024,
    /// <summary>
    /// portrait
    /// </summary>
    /// <remarks>
    /// Only for gpt-image-1
    /// </remarks>
    r1024x1536
  );

  TImageSizeHelper = record Helper for TImageSize
    constructor Create(const Value: string);
    function ToString: string;
  end;

  /// <summary>
  /// Specifies the style of the images generated by the API.
  /// </summary>
  /// <remarks>
  /// The TImageStyle enumeration defines the visual style of the generated images.
  /// Each style influences the appearance and artistic qualities of the output,
  /// allowing developers to customize the aesthetic based on their needs.
  /// This parameter is only supported for DALL-E 3 models.
  /// </remarks>
  TImageStyle = (
    /// <summary>
    /// Vivid - A hyper-real and dramatic visual style.
    /// </summary>
    /// <remarks>
    /// The vivid style generates images with striking, vibrant colors and
    /// high contrast. This style is ideal for creating bold and visually impactful
    /// artwork or content that demands attention.
    /// </remarks>
    vivid,
    /// <summary>
    /// Natural - A realistic and less hyper-realistic visual style.
    /// </summary>
    /// <remarks>
    /// The natural style focuses on producing images with a more subdued,
    /// lifelike appearance. This style is well-suited for applications requiring
    /// realistic representations, such as illustrations or content with a professional tone.
    /// </remarks>
    natural
  );

  TImageStyleHelper = record Helper for TImageStyle
    constructor Create(const Value: string);
    function ToString: string;
  end;

  TBackGroundType = (
    transparent,
    opaque,
    auto
  );

  TBackGroundTypeHelper = record Helper for TBackGroundType
    constructor Create(const Value: string);
    function ToString: string;
  end;

  TImageModerationType = (
    low,
    auto
  );

  TImageModerationTypeHelper = record Helper for TImageModerationType
    constructor Create(const Value: string);
    function ToString: string;
  end;

  TOutputFormatType = (
    png,
    jpeg,
    webp
  );

  TOutputFormatTypeHelper = record Helper for TOutputFormatType
    constructor Create(const Value: string);
    function ToString: string;
  end;

  TImageQualityType = (
    /// <summary>
    /// Only for gpt-image-1
    /// </summary>
    high,
    /// <summary>
    /// Only for gpt-image-1
    /// </summary>
    medium,
    /// <summary>
    /// Only for gpt-image-1
    /// </summary>
    low,
    /// <summary>
    /// Only for dall-e-2
    /// </summary>
    standard,
    /// <summary>
    /// Defaults to auto
    /// </summary>
    auto
  );

  TImageQualityTypeHelper = record Helper for TImageQualityType
    constructor Create(const Value: string);
    function ToString: string;
  end;

  {$ENDREGION}

  {$REGION 'GenAI.Files'}

  /// <summary>
  /// Specifies the intended purpose of a file uploaded to the OpenAI API.
  /// </summary>
  /// <remarks>
  /// The TFilesPurpose enumeration defines the various use cases for uploaded files.
  /// Each purpose aligns with a specific functionality or endpoint within the API,
  /// such as fine-tuning, batch processing, or providing input for assistants.
  /// </remarks>
  TFilesPurpose = (
    /// <summary>
    /// Assistants - Used for input files for Assistants and Message API.
    /// </summary>
    /// <remarks>
    /// Files uploaded with this purpose are intended to serve as input for the
    /// Assistants API, which supports various modalities such as text, images,
    /// and audio. Examples include text prompts or image files.
    /// </remarks>
    assistants,
    /// <summary>
    /// Assistants_Output - Used for output files from the Assistants API.
    /// </summary>
    /// <remarks>
    /// This purpose is used for storing output files generated by the Assistants API.
    /// Examples include transcription results or image generation results.
    /// </remarks>
    assistants_output,
    /// <summary>
    /// Batch - Used for input files for the Batch API.
    /// </summary>
    /// <remarks>
    /// Files uploaded with this purpose are meant for batch processing tasks.
    /// These files typically contain .jsonl formatted data for tasks requiring
    /// bulk processing.
    /// </remarks>
    batch,
    /// <summary>
    /// Batch_Output - Used for output files generated by the Batch API.
    /// </summary>
    /// <remarks>
    /// This purpose is used to store results from batch processing tasks, such as
    /// processed outputs from bulk data uploads.
    /// </remarks>
    batch_output,
    /// <summary>
    /// Fine-Tune - Used for input files for fine-tuning models.
    /// </summary>
    /// <remarks>
    /// Files uploaded with this purpose must be in .jsonl format and meet
    /// specific requirements for fine-tuning models. These files provide
    /// the training data for creating customized models.
    /// </remarks>
    finetune,
    /// <summary>
    /// Fine-Tune_Results - Used for results files generated from fine-tuning jobs.
    /// </summary>
    /// <remarks>
    /// This purpose is used for files containing the output of fine-tuning processes,
    /// such as evaluation results or metrics derived from the training process.
    /// </remarks>
    finetune_results,
    /// <summary>
    /// Vision - Used for image input files in vision-related tasks.
    /// </summary>
    /// <remarks>
    /// Files uploaded with this purpose are intended for vision tasks supported
    /// by the Assistants API, such as image analysis or processing.
    /// </remarks>
    vision,
    /// <summary>
    /// Used for eval data sets
    /// </summary>
    evals,
    /// <summary>
    /// Flexible file type for any purpose
    /// </summary>
    user_data
  );

  TFilesPurposeHelper = record Helper for TFilesPurpose
    constructor Create(const Value: string);
    function ToString: string;
  end;

  TFilesPurposeInterceptor = class(TJSONInterceptorStringToString)
    function StringConverter(Data: TObject; Field: string): string; override;
    procedure StringReverter(Data: TObject; Field: string; Arg: string); override;
  end;

  {$ENDREGION}

  {$REGION 'GenAI.Batch'}

  /// <summary>
  /// Enumerates the possible statuses of a batch operation, describing each stage
  /// from validation to completion or cancellation.
  /// </summary>
  TBatchStatus = (
    /// <summary>
    /// The input file is being validated before the batch can begin.
    /// This is the initial stage where inputs are checked for correctness.
    /// </summary>
    validating,
    /// <summary>
    /// The input file has failed the validation process.
    /// This status indicates an error in the input data that prevents the batch from proceeding.
    /// </summary>
    failed,
    /// <summary>
    /// The input file was successfully validated and the batch is currently being run.
    /// Processing of the batch data is underway.
    /// </summary>
    in_progress,
    /// <summary>
    /// The batch has completed and the results are being prepared.
    /// This stage signifies that the main processing is done but the output is not yet finalized.
    /// </summary>
    finalizing,
    /// <summary>
    /// The batch has been completed and the results are ready.
    /// Indicates that all processing has concluded successfully and the outputs are available for use.
    /// </summary>
    completed,
    /// <summary>
    /// The batch was not able to be completed within the 24-hour time window.
    /// This status is used when the processing time exceeds the maximum allowed duration.
    /// </summary>
    expired,
    /// <summary>
    /// The batch is being cancelled (may take up to 10 minutes).
    /// During this time, the system is terminating any ongoing operations related to the batch.
    /// </summary>
    cancelling,
    /// <summary>
    /// The batch was cancelled.
    /// This final status confirms that the batch has been successfully stopped before completion.
    /// </summary>
    cancelled
  );

  TBatchStatusHelper = record Helper for TBatchStatus
    constructor Create(const Value: string);
    function ToString: string;
  end;

  TBatchStatusInterceptor = class(TJSONInterceptorStringToString)
    function StringConverter(Data: TObject; Field: string): string; override;
    procedure StringReverter(Data: TObject; Field: string; Arg: string); override;
  end;

  {$ENDREGION}

  {$REGION 'GenAI.FineTuning'}

  TJobMethodType = (
    supervised,
    dpo
  );

  TJobMethodTypeHHelper = record Helper for TJobMethodType
    constructor Create(const Value: string);
    function ToString: string;
  end;

  TJobMethodTypeInterceptor = class(TJSONInterceptorStringToString)
    function StringConverter(Data: TObject; Field: string): string; override;
    procedure StringReverter(Data: TObject; Field: string; Arg: string); override;
  end;

  TFineTunedStatus = (
    validating_files,
    queued,
    running,
    succeeded,
    failed,
    cancelled
  );

  TFineTunedStatusHelper = record Helper for TFineTunedStatus
    constructor Create(const Value: string);
    function ToString: string;
  end;

  TFineTunedStatusInterceptor = class(TJSONInterceptorStringToString)
    function StringConverter(Data: TObject; Field: string): string; override;
    procedure StringReverter(Data: TObject; Field: string; Arg: string); override;
  end;

  {$ENDREGION}

  {$REGION 'GenAI.Assistants'}

  TAssistantsToolsType = (
    code_interpreter,
    file_search,
    &function
  );

  TAssistantsToolsTypeHelper = record Helper for TAssistantsToolsType
    constructor Create(const Value: string);
    function ToString: string;
  end;

  TAssistantsToolsTypeInterceptor = class(TJSONInterceptorStringToString)
    function StringConverter(Data: TObject; Field: string): string; override;
    procedure StringReverter(Data: TObject; Field: string; Arg: string); override;
  end;

  TChunkingStrategyType = (
    auto,
    &static
  );

  TChunkingStrategyTypeHelper = record Helper for TChunkingStrategyType
    constructor Create(const Value: string);
    function ToString: string;
  end;

  TResponseFormatType = (
    auto,
    text,
    json_object,
    json_schema
  );

  TResponseFormatTypeHelper = record Helper for TResponseFormatType
    constructor Create(const Value: string);
    function ToString: string;
  end;

  TResponseFormatTypeInterceptor = class(TJSONInterceptorStringToString)
    function StringConverter(Data: TObject; Field: string): string; override;
    procedure StringReverter(Data: TObject; Field: string; Arg: string); override;
  end;

  {$ENDREGION}

  {$REGION 'GenAI.Assistants'}

  TThreadsContentType = (
    text,
    image_url,
    image_file
  );

  TThreadsContentTypeHelper = record Helper for TThreadsContentType
    constructor Create(const Value: string);
    function ToString: string;
  end;

  {$ENDREGION}

  {$REGION 'GenAI.Messages'}

  TMessageStatus = (
    in_progress,
    incomplete,
    completed
  );

  TMessageStatusHelper = record Helper for TMessageStatus
    constructor Create(const Value: string);
    function ToString: string;
  end;

  TMessageStatusInterceptor = class(TJSONInterceptorStringToString)
    function StringConverter(Data: TObject; Field: string): string; override;
    procedure StringReverter(Data: TObject; Field: string; Arg: string); override;
  end;

  {$ENDREGION}

  {$REGION 'GenAI.Runs'}

  TTruncationStrategyType = (
    auto,
    last_messages
  );

  TTruncationStrategyTypeHelper = record Helper for TTruncationStrategyType
    constructor Create(const Value: string);
    function ToString: string;
  end;

  TTruncationStrategyTypeInterceptor = class(TJSONInterceptorStringToString)
    function StringConverter(Data: TObject; Field: string): string; override;
    procedure StringReverter(Data: TObject; Field: string; Arg: string); override;
  end;

  TRunStatus = (
    queued,
    in_progress,
    requires_action,
    cancelling,
    cancelled,
    failed,
    completed,
    incomplete,
    expired
  );

  TRunStatusHelper = record Helper for TRunStatus
    constructor Create(const Value: string);
    function ToString: string;
  end;

  TRunStatusInterceptor = class(TJSONInterceptorStringToString)
    function StringConverter(Data: TObject; Field: string): string; override;
    procedure StringReverter(Data: TObject; Field: string; Arg: string); override;
  end;

  {$ENDREGION}

  {$REGION 'GenAI.RunSteps'}

  TRunStepType = (
    message_creation,
    tool_calls
  );

  TRunStepTypeHelper = record Helper for TRunStepType
    constructor Create(const Value: string);
    function ToString: string;
  end;

  TRunStepTypeInterceptor = class(TJSONInterceptorStringToString)
    function StringConverter(Data: TObject; Field: string): string; override;
    procedure StringReverter(Data: TObject; Field: string; Arg: string); override;
  end;

  {$ENDREGION}

  {$REGION 'GenAI.Responses'}

  TOutputIncluding = (
    file_search_result,
    input_image_url,
    computer_call_image_url
  );

  TOutputIncludingHelper = record Helper for TOutputIncluding
    constructor Create(const Value: string);
    function ToString: string;
  end;

  TReasoningGenerateSummary = (
    concise,
    detailed
  );

  TReasoningGenerateSummaryHelper = record Helper for TReasoningGenerateSummary
    constructor Create(const Value: string);
    function ToString: string;
  end;

  TInputItemType = (
    input_text,
    input_image,
    input_file
  );

  TInputItemTypeHelper = record Helper for TInputItemType
    constructor Create(const Value: string);
    function ToString: string;
  end;

  TFileSearchToolCallType = (
    in_progress,
    searching,
    incomplete,
    failed
  );

  TFileSearchToolCallTypeHelper = record Helper for TFileSearchToolCallType
    constructor Create(const Value: string);
    function ToString: string;
  end;

  TFileSearchToolCallTypeInterceptor = class(TJSONInterceptorStringToString)
    function StringConverter(Data: TObject; Field: string): string; override;
    procedure StringReverter(Data: TObject; Field: string; Arg: string); override;
  end;

  TMouseButton = (
    left,
    right,
    wheel,
    back,
    forward
  );

  TMouseButtonHelper = record Helper for TMouseButton
    constructor Create(const Value: string);
    function ToString: string;
  end;

  TMouseButtonInterceptor = class(TJSONInterceptorStringToString)
    function StringConverter(Data: TObject; Field: string): string; override;
    procedure StringReverter(Data: TObject; Field: string; Arg: string); override;
  end;

  TResponseOption = (
    text,
    json_schema,
    json_object
  );

  TResponseOptionHelper = record Helper for TResponseOption
    constructor Create(const Value: string);
    function ToString: string;
  end;

  THostedTooltype = (
    file_search,
    web_search_preview,
    computer_use_preview
  );

  THostedTooltypeHelper = record Helper for THostedTooltype
    constructor Create(const Value: string);
    function ToString: string;
  end;

  TComparisonFilterType = (
    eq,
    ne,
    gt,
    gte,
    lt,
    lte
  );

  TComparisonFilterTypeHelper = record Helper for TComparisonFilterType
    constructor Create(const Value: string);
    function ToString: string;
    class function ToOperator(const Value: string): TComparisonFilterType; static;
  end;

  TCompoundFilterType = (
    &and,
    &or
  );

  TCompoundFilterTypeHelper = record Helper for TCompoundFilterType
    constructor Create(const Value: string);
    function ToString: string;
  end;

  TWebSearchType = (
    web_search_preview,
    web_search_preview_2025_03_11
  );

  TWebSearchTypeHelper = record Helper for TWebSearchType
    constructor Create(const Value: string);
    function ToString: string;
  end;

  TResponseTruncationType = (
    auto,
    disabled
  );

  TResponseTruncationTypeHelper = record Helper for TResponseTruncationType
    constructor Create(const Value: string);
    function ToString: string;
  end;

  TResponseTypes = (
    message,
    file_search_call,
    function_call,
    web_search_call,
    computer_call,
    reasoning,
    computer_call_output,
    function_call_output
  );

  TResponseTypesHelper = record Helper for TResponseTypes
    constructor Create(const Value: string);
    function ToString: string;
  end;

  TResponseTypesInterceptor = class(TJSONInterceptorStringToString)
    function StringConverter(Data: TObject; Field: string): string; override;
    procedure StringReverter(Data: TObject; Field: string; Arg: string); override;
  end;

  TResponseContentType = (
    output_text,
    refusal,
    summary_text
  );

  TResponseContentTypeHelper = record Helper for TResponseContentType
    constructor Create(const Value: string);
    function ToString: string;
  end;

  TResponseContentTypeInterceptor = class(TJSONInterceptorStringToString)
    function StringConverter(Data: TObject; Field: string): string; override;
    procedure StringReverter(Data: TObject; Field: string; Arg: string); override;
  end;

  TResponseAnnotationType = (
    file_citation,
    url_citation,
    file_path
  );

  TResponseAnnotationTypeHelper = record Helper for TResponseAnnotationType
    constructor Create(const Value: string);
    function ToString: string;
  end;

  TResponseAnnotationTypeInterceptor = class(TJSONInterceptorStringToString)
    function StringConverter(Data: TObject; Field: string): string; override;
    procedure StringReverter(Data: TObject; Field: string; Arg: string); override;
  end;

  TResponseComputerType = (
    click,
    double_click,
    drag,
    keypress,
    move,
    screenshot,
    scroll,
    &type,
    wait
  );

  TResponseComputerTypeHelper = record Helper for TResponseComputerType
    constructor Create(const Value: string);
    function ToString: string;
  end;

  TResponseComputerTypeInterceptor = class(TJSONInterceptorStringToString)
    function StringConverter(Data: TObject; Field: string): string; override;
    procedure StringReverter(Data: TObject; Field: string; Arg: string); override;
  end;

  TResponseStatus = (
    in_progress,
    incomplete,
    completed,
    failed
  );

  TResponseStatusHelper = record Helper for TResponseStatus
    constructor Create(const Value: string);
    function ToString: string;
  end;

  TResponseStatusInterceptor = class(TJSONInterceptorStringToString)
    function StringConverter(Data: TObject; Field: string): string; override;
    procedure StringReverter(Data: TObject; Field: string; Arg: string); override;
  end;

  TResponseToolsType = (
    file_search,
    &function,
    computer_use_preview,
    web_search_preview,
    web_search_preview_2025_03_11
  );

  TResponseToolsTypeHelper = record Helper for TResponseToolsType
    constructor Create(const Value: string);
    function ToString: string;
  end;

  TResponseToolsTypeInterceptor = class(TJSONInterceptorStringToString)
    function StringConverter(Data: TObject; Field: string): string; override;
    procedure StringReverter(Data: TObject; Field: string; Arg: string); override;
  end;

  TResponseToolsFilterType = (
    eq,
    ne,
    gt,
    gte,
    lt,
    lte,
    &and,
    &or
  );

  TResponseToolsFilterTypeHelper = record Helper for TResponseToolsFilterType
    constructor Create(const Value: string);
    function ToString: string;
  end;

  TResponseToolsFilterTypeInterceptor = class(TJSONInterceptorStringToString)
    function StringConverter(Data: TObject; Field: string): string; override;
    procedure StringReverter(Data: TObject; Field: string; Arg: string); override;
  end;

  TResponseItemContentType = (
    input_text,
    input_image,
    input_file,
    output_text,
    refusal
  );

  TResponseItemContentTypeHelper = record Helper for TResponseItemContentType
    constructor Create(const Value: string);
    function ToString: string;
  end;

  TResponseItemContentTypeInterceptor = class(TJSONInterceptorStringToString)
    function StringConverter(Data: TObject; Field: string): string; override;
    procedure StringReverter(Data: TObject; Field: string; Arg: string); override;
  end;

  TResponseStreamType = (
    created,
    in_progress,
    completed,
    failed,
    incomplete,
    output_item_added,
    output_item_done,
    content_part_added,
    content_part_done,
    output_text_delta,
    output_text_annotation_added,
    output_text_done,
    refusal_delta,
    refusal_done,
    function_call_arguments_delta,
    function_call_arguments_done,
    file_search_call_in_progress,
    file_search_call_searching,
    file_search_call_completed,
    web_search_call_in_progress,
    web_search_call_searching,
    web_search_call_completed,

    reasoning_summary_part_add,
    reasoning_summary_part_done,
    reasoning_summary_text_delta,
    reasoning_summary_text_done,

    error
  );

  TResponseStreamTypeHelper = record Helper for TResponseStreamType
    constructor Create(const Value: string);
    function ToString: string;
  end;

  TResponseStreamTypeInterceptor = class(TJSONInterceptorStringToString)
    function StringConverter(Data: TObject; Field: string): string; override;
    procedure StringReverter(Data: TObject; Field: string; Arg: string); override;
  end;

  {$ENDREGION}

function TimestampToDateTime(const Value: Int64; const UTC: Boolean = False): TDateTime;
function TimestampToString(const Value: Int64; const UTC: Boolean = False): string;

var UtcTimestamp: Boolean = True;

implementation

uses
  System.StrUtils, System.DateUtils;

type
  TEnumValueRecovery = class
    class function TypeRetrieve<T>(const Value: string; const References: TArray<string>): T;
  end;

function TimestampToDateTime(const Value: Int64; const UTC: Boolean): TDateTime;
begin
  Result := UnixToDateTime(Value, UTC);
end;

 function TimestampToString(const Value: Int64; const UTC: Boolean): string;
begin
  {--- null date before 01/01/1970 }
  if Value <= 0 then
    Result := 'null' else
    Result := DateTimeToStr(TimestampToDateTime(Value, UTC))
end;

{ TEnumValueRecovery }

class function TEnumValueRecovery.TypeRetrieve<T>(const Value: string;
  const References: TArray<string>): T;
var
  pInfo: PTypeInfo;
begin
  pInfo := TypeInfo(T);
  if pInfo.Kind <> tkEnumeration then
    raise Exception.Create('TRecovery.TypeRetrieve<T>: T is not an enumerated type');

  var index := IndexStr(Value.ToLower, References);
  if index = -1 then
    raise Exception.CreateFmt('%s : Unable to retrieve enum value.', [Value]);

  Move(index, Result, SizeOf(Result));
end;

{ TRoleHelper }

constructor TRoleHelper.Create(const Value: string);
begin
  Self := TEnumValueRecovery.TypeRetrieve<TRole>(Value,
            ['assistant', 'user', 'developer', 'system', 'tool']);
end;

function TRoleHelper.ToString: string;
begin
  case Self of
    TRole.assistant:
      Exit('assistant');
    TRole.user:
      Exit('user');
    TRole.developer:
      Exit('developer');
    TRole.system:
      Exit('system');
    TRole.tool:
      Exit('tool');
  end;
end;

{ TAudioFormatHelper }

constructor TAudioFormatHelper.Create(const Value: string);
begin
  Self := TEnumValueRecovery.TypeRetrieve<TAudioFormat>(Value,
            ['wav', 'mp3', 'flac', 'opus', 'pcm16']);
end;

class function TAudioFormatHelper.MimeTypeInput(
  const Value: string): TAudioFormat;
begin
  Result := TEnumValueRecovery.TypeRetrieve<TAudioFormat>(Value, AudioTypeAccepted);
end;

function TAudioFormatHelper.ToString: string;
begin
  case Self of
    TAudioFormat.wav:
      Exit('wav');
    TAudioFormat.mp3:
      Exit('mp3');
    TAudioFormat.flac:
      Exit('flac');
    TAudioFormat.opus:
      Exit('opus');
    TAudioFormat.pcm16:
      Exit('pcm16');
  end;
end;

{ TImageDetailHelper }

constructor TImageDetailHelper.Create(const Value: string);
begin
  Self := TEnumValueRecovery.TypeRetrieve<TImageDetail>(Value, ['low', 'high', 'auto']);
end;

function TImageDetailHelper.ToString: string;
begin
  case Self of
    TImageDetail.low:
      Exit('low');
    TImageDetail.high:
      Exit('high');
    TImageDetail.auto:
      Exit('auto');
  end;
end;

{ TImageDetailInterceptor }

function TImageDetailInterceptor.StringConverter(Data: TObject;
  Field: string): string;
begin
  Result := RTTI.GetType(Data.ClassType).GetField(Field).GetValue(Data).AsType<TImageDetail>.ToString;
end;

procedure TImageDetailInterceptor.StringReverter(Data: TObject; Field,
  Arg: string);
begin
  RTTI.GetType(Data.ClassType).GetField(Field).SetValue(Data, TValue.From(TImageDetail.Create(Arg)));
end;

{ TReasoningEffortHelper }

constructor TReasoningEffortHelper.Create(const Value: string);
begin
  Self := TEnumValueRecovery.TypeRetrieve<TReasoningEffort>(Value, ['low', 'medium', 'high']);
end;

function TReasoningEffortHelper.ToString: string;
begin
  case Self of
    TReasoningEffort.low:
      Exit('low');
    TReasoningEffort.medium:
      Exit('medium');
    TReasoningEffort.high:
      Exit('high');
  end;
end;

{ TReasoningEffortInterceptor }

function TReasoningEffortInterceptor.StringConverter(Data: TObject;
  Field: string): string;
begin
  Result := RTTI.GetType(Data.ClassType).GetField(Field).GetValue(Data).AsType<TReasoningEffort>.ToString;
end;

procedure TReasoningEffortInterceptor.StringReverter(Data: TObject; Field,
  Arg: string);
begin
  RTTI.GetType(Data.ClassType).GetField(Field).SetValue(Data, TValue.From(TReasoningEffort.Create(Arg)));
end;

{ TModalitiesHelper }

constructor TModalitiesHelper.Create(const Value: string);
begin
  Self := TEnumValueRecovery.TypeRetrieve<TModalities>(Value, ['text', 'audio']);
end;

function TModalitiesHelper.ToString: string;
begin
  case Self of
    TModalities.text:
      Exit('text');
    TModalities.audio:
      Exit('audio');
  end;
end;

{ TChatVoiceHelper }

constructor TChatVoiceHelper.Create(const Value: string);
begin
  Self := TEnumValueRecovery.TypeRetrieve<TChatVoice>(Value,
            ['ash', 'ballad', 'coral', 'sage', 'verse']);
end;

function TChatVoiceHelper.ToString: string;
begin
  case Self of
    TChatVoice.ash:
      Exit('ash');
    TChatVoice.ballad:
      Exit('ballad');
    TChatVoice.coral:
      Exit('coral');
    TChatVoice.sage:
      Exit('sage');
    TChatVoice.verse:
      Exit('verse');
  end;
end;

{ TToolChoiceHelper }

constructor TToolChoiceHelper.Create(const Value: string);
begin
  Self := TEnumValueRecovery.TypeRetrieve<TToolChoice>(Value, ['none', 'auto', 'required']);
end;

function TToolChoiceHelper.ToString: string;
begin
  case Self of
    TToolChoice.none:
      Exit('none');
    TToolChoice.auto:
      Exit('auto');
    TToolChoice.required:
      Exit('required');
  end;
end;

{ TFinishReasonHelper }

constructor TFinishReasonHelper.Create(const Value: string);
begin
  Self := TEnumValueRecovery.TypeRetrieve<TFinishReason>(Value,
            ['stop', 'length', 'content_filter', 'tool_calls']);
end;

function TFinishReasonHelper.ToString: string;
begin
  case Self of
    TFinishReason.stop:
      Exit('stop');
    TFinishReason.length:
      Exit('length');
    TFinishReason.content_filter:
      Exit('content_filter');
    TFinishReason.tool_calls:
      Exit('tool_calls');
  end;
end;

{ TFinishReasonInterceptor }

function TFinishReasonInterceptor.StringConverter(Data: TObject;
  Field: string): string;
begin
  Result := RTTI.GetType(Data.ClassType).GetField(Field).GetValue(Data).AsType<TFinishReason>.ToString;
end;

procedure TFinishReasonInterceptor.StringReverter(Data: TObject; Field,
  Arg: string);
begin
  RTTI.GetType(Data.ClassType).GetField(Field).SetValue(Data, TValue.From(TFinishReason.Create(Arg)));
end;

{ TRoleInterceptor }

function TRoleInterceptor.StringConverter(Data: TObject; Field: string): string;
begin
  Result := RTTI.GetType(Data.ClassType).GetField(Field).GetValue(Data).AsType<TRole>.ToString;
end;

procedure TRoleInterceptor.StringReverter(Data: TObject; Field, Arg: string);
begin
  RTTI.GetType(Data.ClassType).GetField(Field).SetValue(Data, TValue.From(TRole.Create(Arg)));
end;

{ TToolCallsHelper }

constructor TToolCallsHelper.Create(const Value: string);
begin
  Self := TEnumValueRecovery.TypeRetrieve<TToolCalls>(Value, ['function']);
end;

function TToolCallsHelper.ToString: string;
begin
  case Self of
    TToolCalls.tfunction:
      Exit('function');
  end;
end;

{ TToolCallsInterceptor }

function TToolCallsInterceptor.StringConverter(Data: TObject;
  Field: string): string;
begin
  Result := RTTI.GetType(Data.ClassType).GetField(Field).GetValue(Data).AsType<TToolCalls>.ToString;
end;

procedure TToolCallsInterceptor.StringReverter(Data: TObject; Field,
  Arg: string);
begin
  RTTI.GetType(Data.ClassType).GetField(Field).SetValue(Data, TValue.From(TToolCalls.Create(Arg)));
end;

{ TAudioVoiceHelper }

constructor TAudioVoiceHelper.Create(const Value: string);
begin
  Self := TEnumValueRecovery.TypeRetrieve<TAudioVoice>(Value,
    ['alloy', 'ash', 'coral', 'echo', 'fable', 'onyx', 'nova', 'sage', 'shimmer']);
end;

function TAudioVoiceHelper.ToString: string;
begin
  case self of
    TAudioVoice.alloy:
      Exit('alloy');
    TAudioVoice.ash:
      Exit('ash');
    TAudioVoice.coral:
      Exit('coral');
    TAudioVoice.echo:
      Exit('echo');
    TAudioVoice.fable:
      Exit('fable');
    TAudioVoice.onyx:
      Exit('onyx');
    TAudioVoice.nova:
      Exit('nova');
    TAudioVoice.sage:
      Exit('sage');
    TAudioVoice.shimmer:
      Exit('shimmer');
  end;
end;

{ TSpeechFormatHelper }

constructor TSpeechFormatHelper.Create(const Value: string);
begin
  Self := TEnumValueRecovery.TypeRetrieve<TSpeechFormat>(Value,
            ['mp3', 'opus', 'aac', 'flac', 'wav', 'pcm']);
end;

function TSpeechFormatHelper.ToString: string;
begin
  case self of
    TSpeechFormat.mp3:
      Exit('mp3');
    TSpeechFormat.opus:
      Exit('opus');
    TSpeechFormat.aac:
      Exit('aac');
    TSpeechFormat.flac:
      Exit('flac');
    TSpeechFormat.wav:
      Exit('wav');
    TSpeechFormat.pcm:
      Exit('pcm');
  end;
end;

{ TTranscriptionResponseFormatHelper }

constructor TTranscriptionResponseFormatHelper.Create(const Value: string);
begin
  Self := TEnumValueRecovery.TypeRetrieve<TTranscriptionResponseFormat>(Value,
            ['json', 'text', 'srt', 'verbose_json', 'vtt']);
end;

function TTranscriptionResponseFormatHelper.ToString: string;
begin
  case Self of
    TTranscriptionResponseFormat.json:
      Exit('json');
    TTranscriptionResponseFormat.text:
      Exit('text');
    TTranscriptionResponseFormat.srt:
      Exit('srt');
    TTranscriptionResponseFormat.verbose_json:
      Exit('verbose_json');
    TTranscriptionResponseFormat.vtt:
      Exit('vtt');
  end;
end;

{ TEncodingFormatHelper }

constructor TEncodingFormatHelper.Create(const Value: string);
begin
  Self := TEnumValueRecovery.TypeRetrieve<TEncodingFormat>(Value, ['float', 'base64']);
end;

function TEncodingFormatHelper.ToString: string;
begin
  case Self of
    TEncodingFormat.float:
      Exit('float');
    TEncodingFormat.base64:
      Exit('base64');
  end;
end;

{ THarmCategoriesHelper }

class function THarmCategoriesHelper.Create(
  const Value: string): TEncodingFormat;
begin
  Result := TEnumValueRecovery.TypeRetrieve<TEncodingFormat>(Value,
    ['hate', 'hate threatening', 'harassment', 'harassment threatening',
     'illicit', 'illicit violent', 'self harm', 'self harm intent',
     'self harm instructions', 'sexual', 'sexual minors', 'violence',
     'violence graphic'
    ]);
end;

function THarmCategoriesHelper.ToString: string;
begin
  case Self of
    THarmCategories.hate:
      Exit('hate');
    THarmCategories.hateThreatening:
      Exit('hate threatening');
    THarmCategories.harassment:
      Exit('harassment');
    THarmCategories.harassmentThreatening:
      Exit('harassment threatening');
    THarmCategories.illicit:
      Exit('illicit');
    THarmCategories.illicitViolent:
      Exit('illicit violent');
    THarmCategories.selfHarm:
      Exit('self harm');
    THarmCategories.selfHarmIntent:
      Exit('self harm intent');
    THarmCategories.selfHarmInstructions:
      Exit('self harm instructions');
    THarmCategories.sexual:
      Exit('sexual');
    THarmCategories.sexualMinors:
      Exit('sexual minors');
    THarmCategories.violence:
      Exit('violence');
    THarmCategories.violenceGraphic:
      Exit('violence graphic');
  end;
end;

{ TResponseFormatHelper }

constructor TResponseFormatHelper.Create(const Value: string);
begin
  Self := TEnumValueRecovery.TypeRetrieve<TResponseFormat>(Value, ['url', 'b64_json']);
end;

function TResponseFormatHelper.ToString: string;
begin
  case Self of
    TResponseFormat.url:
      Exit('url');
    TResponseFormat.b64_json:
      Exit('b64_json');
  end;
end;

{ TImageSizeHelper }

constructor TImageSizeHelper.Create(const Value: string);
begin
  Self := TEnumValueRecovery.TypeRetrieve<TImageSize>(Value,
            ['256x256', '512x512', '1024x1024', '1792x1024', '1024x1792',
             '1536x1024', '1024x1536']);
end;

function TImageSizeHelper.ToString: string;
begin
  case Self of
    TImageSize.r256x256:
      Exit('256x256');
    TImageSize.r512x512:
      Exit('512x512');
    TImageSize.r1024x1024:
      Exit('1024x1024');
    TImageSize.r1792x1024:
      Exit('1792x1024');
    TImageSize.r1024x1792:
      Exit('1024x1792');
    TImageSize.r1536x1024:
      Exit('1536x1024');
    TImageSize.r1024x1536:
      Exit('1024x1536');
  end;
end;

{ TImageStyleHelper }

constructor TImageStyleHelper.Create(const Value: string);
begin
  Self := TEnumValueRecovery.TypeRetrieve<TImageStyle>(Value, ['vivid', 'natural']);
end;

function TImageStyleHelper.ToString: string;
begin
  case Self of
    TImageStyle.vivid:
      Exit('vivid');
    TImageStyle.natural:
      Exit('natural');
  end;
end;

{ TFilesPurposeHelper }

constructor TFilesPurposeHelper.Create(const Value: string);
begin
  Self := TEnumValueRecovery.TypeRetrieve<TFilesPurpose>(Value,
            ['assistants', 'assistants_output', 'batch', 'batch_output',
             'fine-tune', 'fine-tune-results', 'vision', 'evals', 'user_data']);
end;

function TFilesPurposeHelper.ToString: string;
begin
  case Self of
    TFilesPurpose.assistants:
      Exit('assistants');
    TFilesPurpose.assistants_output:
      Exit('assistants_output');
    TFilesPurpose.batch:
      Exit('batch');
    TFilesPurpose.batch_output:
      Exit('batch_output');
    TFilesPurpose.finetune:
      Exit('fine-tune');
    TFilesPurpose.finetune_results:
      Exit('fine-tune-results');
    TFilesPurpose.vision:
      Exit('vision');
    TFilesPurpose.evals:
      Exit('evals');
    TFilesPurpose.user_data:
      Exit('user_data')
  end;
end;

{ TFilesPurposeInterceptor }

function TFilesPurposeInterceptor.StringConverter(Data: TObject;
  Field: string): string;
begin
  Result := RTTI.GetType(Data.ClassType).GetField(Field).GetValue(Data).AsType<TFilesPurpose>.ToString;
end;

procedure TFilesPurposeInterceptor.StringReverter(Data: TObject; Field,
  Arg: string);
begin
  RTTI.GetType(Data.ClassType).GetField(Field).SetValue(Data, TValue.From(TFilesPurpose.Create(Arg)));
end;

{ TMetadataInterceptor }

procedure TMetadataInterceptor.StringReverter(Data: TObject; Field,
  Arg: string);
begin
  Arg := Format('{%s}', [Trim(Arg.Replace('`', '"').Replace(#10, ''))]);
  while Arg.Contains(', ') do Arg := Arg.Replace(', ', ',');
  RTTI.GetType(Data.ClassType).GetField(Field).SetValue(Data, Arg.Replace(',', ', '));
end;

{ TBatchStatusHelper }

constructor TBatchStatusHelper.Create(const Value: string);
begin
  Self := TEnumValueRecovery.TypeRetrieve<TBatchStatus>(Value,
            ['validating', 'failed', 'in_progress', 'finalizing',
             'completed', 'expired', 'cancelling', 'cancelled']);
end;

function TBatchStatusHelper.ToString: string;
begin
  case Self of
    TBatchStatus.validating:
      Exit('validating');
    TBatchStatus.failed:
      Exit('failed');
    TBatchStatus.in_progress:
      Exit('in_progress');
    TBatchStatus.finalizing:
      Exit('finalizing');
    TBatchStatus.completed:
      Exit('completed');
    TBatchStatus.expired:
      Exit('expired');
    TBatchStatus.cancelling:
      Exit('cancelling');
    TBatchStatus.cancelled:
      Exit('cancelled');
  end;
end;

{ TBatchStatusInterceptor }

function TBatchStatusInterceptor.StringConverter(Data: TObject;
  Field: string): string;
begin
  Result := RTTI.GetType(Data.ClassType).GetField(Field).GetValue(Data).AsType<TBatchStatus>.ToString;
end;

procedure TBatchStatusInterceptor.StringReverter(Data: TObject; Field,
  Arg: string);
begin
  RTTI.GetType(Data.ClassType).GetField(Field).SetValue(Data, TValue.From(TBatchStatus.Create(Arg)));
end;

{ TBatchUrlHelper }

constructor TBatchUrlHelper.Create(const Value: string);
begin
  Self := TEnumValueRecovery.TypeRetrieve<TBatchUrl>(Value,
            ['/v1/chat/completions', '/v1/embeddings']);
end;

function TBatchUrlHelper.ToString: string;
begin
  case Self of
    TBatchUrl.chat_completions:
      Exit('/v1/chat/completions');
    TBatchUrl.embeddings:
      Exit('/v1/embeddings');
  end;
end;

{ TSchemaTypeHelper }

constructor TSchemaTypeHelper.Create(const Value: string);
begin
  Self := TEnumValueRecovery.TypeRetrieve<TSchemaType>(Value,
            ['unspecified', 'string', 'number', 'integer',
             'boolean', 'array', 'object']);
end;

function TSchemaTypeHelper.ToString: string;
begin
  case self of
    TSchemaType.unspecified:
      Exit('unspecified');
    TSchemaType.string:
      Exit('string');
    TSchemaType.number:
      Exit('number');
    TSchemaType.integer:
      Exit('integer');
    TSchemaType.boolean:
      Exit('boolean');
    TSchemaType.array:
      Exit('array');
    TSchemaType.object:
      Exit('object');
  end;
end;

{ TJobMethodTypeHHelper }

constructor TJobMethodTypeHHelper.Create(const Value: string);
begin
  Self := TEnumValueRecovery.TypeRetrieve<TJobMethodType>(Value, ['supervised', 'dpo']);
end;

function TJobMethodTypeHHelper.ToString: string;
begin
  case self of
    TJobMethodType.supervised:
      Exit('supervised');
    TJobMethodType.dpo:
      Exit('dpo');
  end;
end;

{ TJobMethodTypeInterceptor }

function TJobMethodTypeInterceptor.StringConverter(Data: TObject;
  Field: string): string;
begin
  Result := RTTI.GetType(Data.ClassType).GetField(Field).GetValue(Data).AsType<TJobMethodType>.ToString;
end;

procedure TJobMethodTypeInterceptor.StringReverter(Data: TObject; Field,
  Arg: string);
begin
  RTTI.GetType(Data.ClassType).GetField(Field).SetValue(Data, TValue.From(TJobMethodType.Create(Arg)));
end;

{ TFineTunedStatusHelper }

constructor TFineTunedStatusHelper.Create(const Value: string);
begin
  Self := TEnumValueRecovery.TypeRetrieve<TFineTunedStatus>(Value,
            ['validating_files', 'queued', 'running', 'succeeded',
             'failed', 'cancelled']);
end;

function TFineTunedStatusHelper.ToString: string;
begin
  case self of
    TFineTunedStatus.validating_files:
      Exit('validating_files');
    TFineTunedStatus.queued:
      Exit('queued');
    TFineTunedStatus.running:
      Exit('running');
    TFineTunedStatus.succeeded:
      Exit('succeeded');
    TFineTunedStatus.failed:
      Exit('failed');
    TFineTunedStatus.cancelled:
      Exit('cancelled');
  end;
end;

{ TFineTunedStatusInterceptor }

function TFineTunedStatusInterceptor.StringConverter(Data: TObject;
  Field: string): string;
begin
  Result := RTTI.GetType(Data.ClassType).GetField(Field).GetValue(Data).AsType<TFineTunedStatus>.ToString;
end;

procedure TFineTunedStatusInterceptor.StringReverter(Data: TObject; Field,
  Arg: string);
begin
  RTTI.GetType(Data.ClassType).GetField(Field).SetValue(Data, TValue.From(TFineTunedStatus.Create(Arg)));
end;

{ TAssistantsToolsTypeHelper }

constructor TAssistantsToolsTypeHelper.Create(const Value: string);
begin
  Self := TEnumValueRecovery.TypeRetrieve<TAssistantsToolsType>(Value,
            ['code_interpreter', 'file_search', 'function']);
end;

function TAssistantsToolsTypeHelper.ToString: string;
begin
  case self of
    TAssistantsToolsType.code_interpreter:
      Exit('code_interpreter');
    TAssistantsToolsType.file_search:
      Exit('file_search');
    TAssistantsToolsType.function:
      Exit('function');
  end;
end;

{ TAssistantsToolsTypeInterceptor }

function TAssistantsToolsTypeInterceptor.StringConverter(Data: TObject;
  Field: string): string;
begin
  Result := RTTI.GetType(Data.ClassType).GetField(Field).GetValue(Data).AsType<TAssistantsToolsType>.ToString;
end;

procedure TAssistantsToolsTypeInterceptor.StringReverter(Data: TObject; Field,
  Arg: string);
begin
  RTTI.GetType(Data.ClassType).GetField(Field).SetValue(Data, TValue.From(TAssistantsToolsType.Create(Arg)));
end;

{ TChunkingStrategyTypeHelper }

constructor TChunkingStrategyTypeHelper.Create(const Value: string);
begin
  Self := TEnumValueRecovery.TypeRetrieve<TChunkingStrategyType>(Value, ['auto', 'static']);
end;

function TChunkingStrategyTypeHelper.ToString: string;
begin
  case self of
    TChunkingStrategyType.auto:
      Exit('auto');
    TChunkingStrategyType.static:
      Exit('static');
  end;
end;

{ TResponseFormatTypeHelper }

constructor TResponseFormatTypeHelper.Create(const Value: string);
begin
  Self := TEnumValueRecovery.TypeRetrieve<TResponseFormatType>(Value,
            ['auto', 'text', 'json_object', 'json_schema']);
end;

function TResponseFormatTypeHelper.ToString: string;
begin
  case self of
    TResponseFormatType.auto:
      Exit('auto');
    TResponseFormatType.text:
      Exit('text');
    TResponseFormatType.json_object:
      Exit('json_object');
    TResponseFormatType.json_schema:
      Exit('json_schema');
  end;
end;

{ TResponseFormatTypeInterceptor }

function TResponseFormatTypeInterceptor.StringConverter(Data: TObject;
  Field: string): string;
begin
  Result := RTTI.GetType(Data.ClassType).GetField(Field).GetValue(Data).AsType<TResponseFormatType>.ToString;
end;

procedure TResponseFormatTypeInterceptor.StringReverter(Data: TObject; Field,
  Arg: string);
begin
  RTTI.GetType(Data.ClassType).GetField(Field).SetValue(Data, TValue.From(TResponseFormatType.Create(Arg)));
end;

{ TThreadsContentTypeHelper }

constructor TThreadsContentTypeHelper.Create(const Value: string);
begin
  Self := TEnumValueRecovery.TypeRetrieve<TThreadsContentType>(Value,
            ['text', 'image_url', 'image_file']);
end;

function TThreadsContentTypeHelper.ToString: string;
begin
  case self of
    TThreadsContentType.text:
      Exit('text');
    TThreadsContentType.image_url:
      Exit('image_url');
    TThreadsContentType.image_file:
      Exit('image_file');
  end;
end;

{ TMessageStatusHelper }

constructor TMessageStatusHelper.Create(const Value: string);
begin
  Self := TEnumValueRecovery.TypeRetrieve<TMessageStatus>(Value,
            ['in_progress', 'incomplete', 'completed']);
end;

function TMessageStatusHelper.ToString: string;
begin
  case self of
    TMessageStatus.in_progress:
      Exit('in_progress');
    TMessageStatus.incomplete:
      Exit('incomplete');
    TMessageStatus.completed:
      Exit('completed');
  end;
end;

{ TMessageStatusInterceptor }

function TMessageStatusInterceptor.StringConverter(Data: TObject;
  Field: string): string;
begin
  Result := RTTI.GetType(Data.ClassType).GetField(Field).GetValue(Data).AsType<TMessageStatus>.ToString;
end;

procedure TMessageStatusInterceptor.StringReverter(Data: TObject; Field,
  Arg: string);
begin
  RTTI.GetType(Data.ClassType).GetField(Field).SetValue(Data, TValue.From(TMessageStatus.Create(Arg)));
end;

{ TTruncationStrategyTypeHelper }

constructor TTruncationStrategyTypeHelper.Create(const Value: string);
begin
  Self := TEnumValueRecovery.TypeRetrieve<TTruncationStrategyType>(Value,
            ['auto', 'last_messages']);
end;

function TTruncationStrategyTypeHelper.ToString: string;
begin
  case self of
    TTruncationStrategyType.auto:
      Exit('auto');
    TTruncationStrategyType.last_messages:
      Exit('last_messages');
  end;
end;

{ TTruncationStrategyTypeInterceptor }

function TTruncationStrategyTypeInterceptor.StringConverter(Data: TObject;
  Field: string): string;
begin
  Result := RTTI.GetType(Data.ClassType).GetField(Field).GetValue(Data).AsType<TTruncationStrategyType>.ToString;
end;

procedure TTruncationStrategyTypeInterceptor.StringReverter(Data: TObject;
  Field, Arg: string);
begin
  RTTI.GetType(Data.ClassType).GetField(Field).SetValue(Data, TValue.From(TTruncationStrategyType.Create(Arg)));
end;

{ TRunStatusHelper }

constructor TRunStatusHelper.Create(const Value: string);
begin
  Self := TEnumValueRecovery.TypeRetrieve<TRunStatus>(Value,
            ['queued', 'in_progress', 'requires_action', 'cancelling',
             'cancelled', 'failed', 'completed', 'incomplete',
             'expired']);
end;

function TRunStatusHelper.ToString: string;
begin
  case self of
    TRunStatus.queued:
      Exit('queued');
    TRunStatus.in_progress:
      Exit('in_progress');
    TRunStatus.requires_action:
      Exit('requires_action');
    TRunStatus.cancelling:
      Exit('cancelling');
    TRunStatus.cancelled:
      Exit('cancelled');
    TRunStatus.failed:
      Exit('failed');
    TRunStatus.completed:
      Exit('completed');
    TRunStatus.incomplete:
      Exit('incomplete');
    TRunStatus.expired:
      Exit('expired');
  end;
end;

{ TRunStatusInterceptor }

function TRunStatusInterceptor.StringConverter(Data: TObject;
  Field: string): string;
begin
  Result := RTTI.GetType(Data.ClassType).GetField(Field).GetValue(Data).AsType<TRunStatus>.ToString;
end;

procedure TRunStatusInterceptor.StringReverter(Data: TObject; Field,
  Arg: string);
begin
  RTTI.GetType(Data.ClassType).GetField(Field).SetValue(Data, TValue.From(TRunStatus.Create(Arg)));
end;

{ TRunStepTypeHelper }

constructor TRunStepTypeHelper.Create(const Value: string);
begin
  Self := TEnumValueRecovery.TypeRetrieve<TRunStepType>(Value,
            ['message_creation', 'tool_calls']);
end;

function TRunStepTypeHelper.ToString: string;
begin
  case self of
    TRunStepType.message_creation:
      Exit('message_creation');
    TRunStepType.tool_calls:
      Exit('tool_calls');
  end;
end;

{ TRunStepTypeInterceptor }

function TRunStepTypeInterceptor.StringConverter(Data: TObject;
  Field: string): string;
begin
  Result := RTTI.GetType(Data.ClassType).GetField(Field).GetValue(Data).AsType<TRunStepType>.ToString;
end;

procedure TRunStepTypeInterceptor.StringReverter(Data: TObject; Field,
  Arg: string);
begin
  RTTI.GetType(Data.ClassType).GetField(Field).SetValue(Data, TValue.From(TRunStepType.Create(Arg)));
end;

{ TStringOrNullHelper }

constructor TStringOrNullHelper.Create(const Value: Variant);
begin
  Self := Value;
end;

function TStringOrNullHelper.isNull: Boolean;
begin
  case VarType(Self) of
    varString,
    varUString,
    varAny:
      Exit(False);
    else
      Exit(True);
  end;
end;

function TStringOrNullHelper.ToString: string;
begin
  if Self.isNull then
    Result := 'null' else
    Result := VarToStr(Self);
end;

{ TIntegerOrNullHelper }

constructor TIntegerOrNullHelper.Create(const Value: Variant);
begin
  Self := Value;
end;

function TIntegerOrNullHelper.isNull: Boolean;
begin
  case VarType(Self) of
    varSmallint,
    varInteger,
    varShortInt,
    varByte,
    varWord,
    varUInt32:
      Exit(False);
    else
      Exit(True);
  end;
end;

function TIntegerOrNullHelper.ToInteger: Integer;
begin
  if Self.isNull then
    Result := 0 else
    Result := VarAsType(Self, varInteger);
end;

function TIntegerOrNullHelper.ToString: string;
begin
  if Self.isNull then
    Result := 'null' else
    Result := Self.ToInteger.ToString;
end;

{ TInt64OrNullHelper }

constructor TInt64OrNullHelper.Create(const Value: Variant);
begin
  Self := Value;
end;

function TInt64OrNullHelper.isNull: Boolean;
begin
  case VarType(Self) of
    varSmallint,
    varInteger,
    varInt64,
    varShortInt,
    varByte,
    varWord,
    varUInt32,
    varUInt64:
      Exit(False);
    else
      Exit(True);
  end;
end;

function TInt64OrNullHelper.ToInteger: Int64;
begin
  if Self.isNull then
    Result := 0 else
    Result := VarAsType(Self, varInt64);
end;

function TInt64OrNullHelper.ToString: string;
begin
  if Self.isNull then
    Result := 'null' else
    Result := Self.ToInteger.ToString;
end;

function TInt64OrNullHelper.ToUtcDateString: string;
begin
  Result := TimestampToString(Self.ToInteger, UtcTimestamp);
end;

{ TDoubleOrNullHelper }

constructor TDoubleOrNullHelper.Create(const Value: Variant);
begin
  Self := Value;
end;

function TDoubleOrNullHelper.isNull: Boolean;
begin
  case VarType(Self) of
    varSmallint,
    varInteger,
    varInt64,
    varSingle,
    varDouble,
    varCurrency,
    varShortInt,
    varByte,
    varWord,
    varUInt32,
    varUInt64:
      Exit(False);
    else
      Exit(True);
  end;
end;

function TDoubleOrNullHelper.ToDouble: Double;
begin
  if Self.isNull then
    Result := 0 else
    Result := VarAsType(Self, varDouble);
end;

function TDoubleOrNullHelper.ToString: string;
begin
  if Self.isNull then
    Result := 'null' else
    Result := Self.ToDouble.ToString;
end;

{ TBooleanOrNullHelper }

constructor TBooleanOrNullHelper.Create(const Value: Variant);
begin
  Self := Value;
end;

function TBooleanOrNullHelper.isNull: Boolean;
begin
  case VarType(Self) of
    varBoolean:
      Exit(False);
    varByte,
    varShortInt:
      Exit(not ((Self = 0) or (Self = 1) or (Self = -1)));
    else
      Exit(True);
  end;
end;

function TBooleanOrNullHelper.ToBoolean: Boolean;
begin
  if Self.isNull then
    Result := False else
    Result := VarAsType(Self, varBoolean);
end;

function TBooleanOrNullHelper.ToString: string;
begin
  if Self.isNull then
    Result := 'null' else
    Result := BoolToStr(Self.ToBoolean, True);
end;

{ TSearchWebOptionsHelper }

constructor TSearchWebOptionsHelper.Create(const Value: string);
begin
  Self := TEnumValueRecovery.TypeRetrieve<TSearchWebOptions>(Value,
            ['low', 'medium', 'high']);
end;

function TSearchWebOptionsHelper.ToString: string;
begin
  case Self of
    TSearchWebOptions.low:
      Exit('low');
    TSearchWebOptions.medium:
      Exit('medium');
    TSearchWebOptions.high:
      Exit('high');
  end;
end;

{ TOutputIncludingHelper }

constructor TOutputIncludingHelper.Create(const Value: string);
begin
  Self := TEnumValueRecovery.TypeRetrieve<TOutputIncluding>(Value,
            ['file_search_call.results',
             'message.input_image.image_url',
             'computer_call_output.output.image_url']);
end;

function TOutputIncludingHelper.ToString: string;
begin
  case self of
    TOutputIncluding.file_search_result:
      Exit('file_search_call.results');
    TOutputIncluding.input_image_url:
      Exit('message.input_image.image_url');
    TOutputIncluding.computer_call_image_url:
      Exit('computer_call_output.output.image_url');
  end;
end;

{ TReasoningGenerateSummaryHelper }

constructor TReasoningGenerateSummaryHelper.Create(const Value: string);
begin
  Self := TEnumValueRecovery.TypeRetrieve<TReasoningGenerateSummary>(Value,
            ['concise', 'detailed']);
end;

function TReasoningGenerateSummaryHelper.ToString: string;
begin
  case self of
    TReasoningGenerateSummary.concise:
      Exit('concise');
    TReasoningGenerateSummary.detailed:
      Exit('detailed');
  end;
end;

{ TInputItemTypeHelper }

constructor TInputItemTypeHelper.Create(const Value: string);
begin
  Self := TEnumValueRecovery.TypeRetrieve<TInputItemType>(Value,
            ['input_text', 'input_image', 'input_file']);
end;

function TInputItemTypeHelper.ToString: string;
begin
  case self of
    TInputItemType.input_text:
      Exit('input_text');
    TInputItemType.input_image:
      Exit('input_image');
    TInputItemType.input_file:
      Exit('input_file');
  end;
end;

{ TFileSearchToolCallTypeHelper }

constructor TFileSearchToolCallTypeHelper.Create(const Value: string);
begin
  Self := TEnumValueRecovery.TypeRetrieve<TFileSearchToolCallType>(Value,
            ['in_progress', 'searching', 'incomplete', 'failed']);
end;

function TFileSearchToolCallTypeHelper.ToString: string;
begin
  case Self of
    TFileSearchToolCallType.in_progress:
      Exit('in_progress');
    TFileSearchToolCallType.searching:
      Exit('searching');
    TFileSearchToolCallType.incomplete:
      Exit('incomplete');
    TFileSearchToolCallType.failed:
      Exit('failed');
  end;
end;

{ TFileSearchToolCallTypeInterceptor }

function TFileSearchToolCallTypeInterceptor.StringConverter(Data: TObject;
  Field: string): string;
begin
  Result := RTTI.GetType(Data.ClassType).GetField(Field).GetValue(Data).AsType<TFileSearchToolCallType>.ToString;
end;

procedure TFileSearchToolCallTypeInterceptor.StringReverter(Data: TObject;
  Field, Arg: string);
begin
  RTTI.GetType(Data.ClassType).GetField(Field).SetValue(Data, TValue.From(TFileSearchToolCallType.Create(Arg)));
end;

{ TMouseButtonHelper }

constructor TMouseButtonHelper.Create(const Value: string);
begin
  Self := TEnumValueRecovery.TypeRetrieve<TMouseButton>(Value,
            ['left', 'right', 'wheel', 'back', 'forward']);
end;

function TMouseButtonHelper.ToString: string;
begin
  case self of
    TMouseButton.left:
      Exit('left');
    TMouseButton.right:
      Exit('right');
    TMouseButton.wheel:
      Exit('wheel');
    TMouseButton.back:
      Exit('back');
    TMouseButton.forward:
      Exit('forward');
  end;
end;

{ TMouseButtonInterceptor }

function TMouseButtonInterceptor.StringConverter(Data: TObject;
  Field: string): string;
begin
  Result := RTTI.GetType(Data.ClassType).GetField(Field).GetValue(Data).AsType<TMouseButton>.ToString;
end;

procedure TMouseButtonInterceptor.StringReverter(Data: TObject; Field,
  Arg: string);
begin
  RTTI.GetType(Data.ClassType).GetField(Field).SetValue(Data, TValue.From(TMouseButton.Create(Arg)));
end;

{ TResponseOptionHelper }

constructor TResponseOptionHelper.Create(const Value: string);
begin
  Self := TEnumValueRecovery.TypeRetrieve<TResponseOption>(Value,
            ['text', 'json_schema', 'json_object']);
end;

function TResponseOptionHelper.ToString: string;
begin
  case self of
    TResponseOption.text:
      Exit('text');
    TResponseOption.json_schema:
      Exit('json_schema');
    TResponseOption.json_object:
      Exit('json_object');
  end;
end;

{ THostedTooltypeHelper }

constructor THostedTooltypeHelper.Create(const Value: string);
begin
  Self := TEnumValueRecovery.TypeRetrieve<THostedTooltype>(Value,
            ['file_search', 'web_search_preview', 'computer_use_preview']);
end;

function THostedTooltypeHelper.ToString: string;
begin
  case self of
    THostedTooltype.file_search:
      Exit('file_search');
    THostedTooltype.web_search_preview:
      Exit('web_search_preview');
    THostedTooltype.computer_use_preview:
      Exit('computer_use_preview');
  end;
end;

{ TComparisonFilterTypeHelper }

constructor TComparisonFilterTypeHelper.Create(const Value: string);
begin
  Self := TEnumValueRecovery.TypeRetrieve<TComparisonFilterType>(Value,
            ['eq', 'ne', 'gt', 'gte', 'lt', 'lte']);
end;

class function TComparisonFilterTypeHelper.ToOperator(
  const Value: string): TComparisonFilterType;
begin
  Result := TEnumValueRecovery.TypeRetrieve<TComparisonFilterType>(Value,
            ['equals', 'notEqual'.ToLower, 'greaterThan'.ToLower,
             'greaterThanOrEqual'.ToLower, 'lessThan'.ToLower, 'lessThanOrEqual'.ToLower]);
end;

function TComparisonFilterTypeHelper.ToString: string;
begin
  case self of
    TComparisonFilterType.eq:
      Exit('eq');
    TComparisonFilterType.ne:
      Exit('ne');
    TComparisonFilterType.gt:
      Exit('gt');
    TComparisonFilterType.gte:
      Exit('gte');
    TComparisonFilterType.lt:
      Exit('lt');
    TComparisonFilterType.lte:
      Exit('lte');
  end;
end;

{ TCompoundFilterTypeHelper }

constructor TCompoundFilterTypeHelper.Create(const Value: string);
begin
  Self := TEnumValueRecovery.TypeRetrieve<TCompoundFilterType>(Value,
            ['and', 'or']);
end;

function TCompoundFilterTypeHelper.ToString: string;
begin
  case self of
    TCompoundFilterType.and:
      Exit('and');
    TCompoundFilterType.or:
      Exit('or');
  end;
end;

{ TWebSearchTypeHelper }

constructor TWebSearchTypeHelper.Create(const Value: string);
begin
  Self := TEnumValueRecovery.TypeRetrieve<TWebSearchType>(Value,
            ['web_search_preview', 'web_search_preview_2025_03_11']);
end;

function TWebSearchTypeHelper.ToString: string;
begin
  case self of
    TWebSearchType.web_search_preview:
      Exit('web_search_preview');
    TWebSearchType.web_search_preview_2025_03_11:
      Exit('web_search_preview_2025_03_11');
  end;
end;

{ TResponseTruncationTypeHelper }

constructor TResponseTruncationTypeHelper.Create(const Value: string);
begin
  Self := TEnumValueRecovery.TypeRetrieve<TResponseTruncationType>(Value,
            ['auto', 'disabled']);
end;

function TResponseTruncationTypeHelper.ToString: string;
begin
  case self of
    TResponseTruncationType.auto:
      Exit('auto');
    TResponseTruncationType.disabled:
      Exit('disabled');
  end;
end;

{ TResponseTypesHelper }

constructor TResponseTypesHelper.Create(const Value: string);
begin
  Self := TEnumValueRecovery.TypeRetrieve<TResponseTypes>(Value,
            ['message', 'file_search_call', 'function_call', 'web_search_call',
             'computer_call', 'reasoning', 'computer_call_output', 'function_call_output']);
end;

function TResponseTypesHelper.ToString: string;
begin
  case self of
    TResponseTypes.message:
      Exit('message');
    TResponseTypes.file_search_call:
      Exit('file_search_call');
    TResponseTypes.function_call:
      Exit('function_call');
    TResponseTypes.web_search_call:
      Exit('web_search_call');
    TResponseTypes.computer_call:
      Exit('computer_call');
    TResponseTypes.reasoning:
      Exit('reasoning');
    TResponseTypes.computer_call_output:
      Exit('computer_call_outpu');
    TResponseTypes.function_call_output:
      Exit('function_call_output');
  end;
end;

{ TResponseTypesInterceptor }

function TResponseTypesInterceptor.StringConverter(Data: TObject;
  Field: string): string;
begin
  Result := RTTI.GetType(Data.ClassType).GetField(Field).GetValue(Data).AsType<TResponseTypes>.ToString;
end;

procedure TResponseTypesInterceptor.StringReverter(Data: TObject; Field,
  Arg: string);
begin
  RTTI.GetType(Data.ClassType).GetField(Field).SetValue(Data, TValue.From(TResponseTypes.Create(Arg)));
end;

{ TResponseContentTypeHelper }

constructor TResponseContentTypeHelper.Create(const Value: string);
begin
  Self := TEnumValueRecovery.TypeRetrieve<TResponseContentType>(Value,
            ['output_text', 'refusal', 'summary_text']);
end;

function TResponseContentTypeHelper.ToString: string;
begin
  case Self of
    TResponseContentType.output_text:
      Exit('output_text');
    TResponseContentType.refusal:
      Exit('refusal');
    TResponseContentType.summary_text:
      Exit('summary_text');
  end;
end;

{ TResponseContentTypeInterceptor }

function TResponseContentTypeInterceptor.StringConverter(Data: TObject;
  Field: string): string;
begin
  Result := RTTI.GetType(Data.ClassType).GetField(Field).GetValue(Data).AsType<TResponseContentType>.ToString;
end;

procedure TResponseContentTypeInterceptor.StringReverter(Data: TObject; Field,
  Arg: string);
begin
  RTTI.GetType(Data.ClassType).GetField(Field).SetValue(Data, TValue.From(TResponseContentType.Create(Arg)));
end;

{ TResponseAnnotationTypeHelper }

constructor TResponseAnnotationTypeHelper.Create(const Value: string);
begin
  Self := TEnumValueRecovery.TypeRetrieve<TResponseAnnotationType>(Value,
            ['file_citation', 'url_citation', 'file_path']);
end;

function TResponseAnnotationTypeHelper.ToString: string;
begin
  case self of
    TResponseAnnotationType.file_citation:
      Exit('file_citation');
    TResponseAnnotationType.url_citation:
      Exit('url_citation');
    TResponseAnnotationType.file_path:
      Exit('file_path');
  end;
end;

{ TResponseAnnotationTypeInterceptor }

function TResponseAnnotationTypeInterceptor.StringConverter(Data: TObject;
  Field: string): string;
begin
  Result := RTTI.GetType(Data.ClassType).GetField(Field).GetValue(Data).AsType<TResponseAnnotationType>.ToString;
end;

procedure TResponseAnnotationTypeInterceptor.StringReverter(Data: TObject;
  Field, Arg: string);
begin
  RTTI.GetType(Data.ClassType).GetField(Field).SetValue(Data, TValue.From(TResponseAnnotationType.Create(Arg)));
end;

{ TResponseComputerTypeHelper }

constructor TResponseComputerTypeHelper.Create(const Value: string);
begin
  Self := TEnumValueRecovery.TypeRetrieve<TResponseComputerType>(Value,
            ['click', 'double_click', 'drag',
             'keypress', 'move', 'screenshot',
             'scroll', 'type', 'wait']);
end;

function TResponseComputerTypeHelper.ToString: string;
begin
  case self of
    TResponseComputerType.click:
      Exit('click');
    TResponseComputerType.double_click:
      Exit('double_click');
    TResponseComputerType.drag:
      Exit('drag');
    TResponseComputerType.keypress:
      Exit('keypress');
    TResponseComputerType.move:
      Exit('move');
    TResponseComputerType.screenshot:
      Exit('screenshot');
    TResponseComputerType.scroll:
      Exit('scroll');
    TResponseComputerType.type:
      Exit('type');
    TResponseComputerType.wait:
      Exit('wait');
  end;
end;

{ TResponseComputerTypeInterceptor }

function TResponseComputerTypeInterceptor.StringConverter(Data: TObject;
  Field: string): string;
begin
  Result := RTTI.GetType(Data.ClassType).GetField(Field).GetValue(Data).AsType<TResponseComputerType>.ToString;
end;

procedure TResponseComputerTypeInterceptor.StringReverter(Data: TObject; Field,
  Arg: string);
begin
  RTTI.GetType(Data.ClassType).GetField(Field).SetValue(Data, TValue.From(TResponseComputerType.Create(Arg)));
end;

{ TResponseStatusHelper }

constructor TResponseStatusHelper.Create(const Value: string);
begin
  Self := TEnumValueRecovery.TypeRetrieve<TResponseStatus>(Value,
            ['in_progress', 'incomplete', 'completed', 'failed']);
end;

function TResponseStatusHelper.ToString: string;
begin
  case self of
    TResponseStatus.in_progress:
      Exit('in_progress');
    TResponseStatus.incomplete:
      Exit('incomplete');
    TResponseStatus.completed:
      Exit('completed');
    TResponseStatus.failed:
      Exit('failed');
  end;
end;

{ TResponseStatusInterceptor }

function TResponseStatusInterceptor.StringConverter(Data: TObject;
  Field: string): string;
begin
  Result := RTTI.GetType(Data.ClassType).GetField(Field).GetValue(Data).AsType<TResponseStatus>.ToString;
end;

procedure TResponseStatusInterceptor.StringReverter(Data: TObject; Field,
  Arg: string);
begin
  RTTI.GetType(Data.ClassType).GetField(Field).SetValue(Data, TValue.From(TResponseStatus.Create(Arg)));
end;

{ TResponseToolsTypeHelper }

constructor TResponseToolsTypeHelper.Create(const Value: string);
begin
  Self := TEnumValueRecovery.TypeRetrieve<TResponseToolsType>(Value,
            ['file_search', 'function', 'computer_use_preview', 'web_search_preview',
             'web_search_preview_2025_03_11']);
end;

function TResponseToolsTypeHelper.ToString: string;
begin
  case self of
    TResponseToolsType.file_search:
      Exit('file_search');
    TResponseToolsType.function:
      Exit('function');
    TResponseToolsType.computer_use_preview:
      Exit('computer_use_preview');
    TResponseToolsType.web_search_preview:
      Exit('web_search_preview');
    TResponseToolsType.web_search_preview_2025_03_11:
      Exit('web_search_preview_2025_03_11');
  end;
end;

{ TResponseToolsTypeInterceptor }

function TResponseToolsTypeInterceptor.StringConverter(Data: TObject;
  Field: string): string;
begin
  Result := RTTI.GetType(Data.ClassType).GetField(Field).GetValue(Data).AsType<TResponseToolsType>.ToString;
end;

procedure TResponseToolsTypeInterceptor.StringReverter(Data: TObject; Field,
  Arg: string);
begin
  RTTI.GetType(Data.ClassType).GetField(Field).SetValue(Data, TValue.From(TResponseToolsType.Create(Arg)));
end;

{ TResponseToolsFilterTypeHelper }

constructor TResponseToolsFilterTypeHelper.Create(const Value: string);
begin
  Self := TEnumValueRecovery.TypeRetrieve<TResponseToolsFilterType>(Value,
            ['eq', 'ne', 'gt', 'gte',
             'lt', 'lte', 'and', 'or']);
end;

function TResponseToolsFilterTypeHelper.ToString: string;
begin
  case self of
    TResponseToolsFilterType.eq:
      Exit('eq');
    TResponseToolsFilterType.ne:
      Exit('ne');
    TResponseToolsFilterType.gt:
      Exit('gt');
    TResponseToolsFilterType.gte:
      Exit('gte');
    TResponseToolsFilterType.lt:
      Exit('lt');
    TResponseToolsFilterType.lte:
      Exit('lte');
    TResponseToolsFilterType.and:
      Exit('and');
    TResponseToolsFilterType.or:
      Exit('or');
  end;
end;

{ TResponseToolsFilterTypeInterceptor }

function TResponseToolsFilterTypeInterceptor.StringConverter(Data: TObject;
  Field: string): string;
begin
  Result := RTTI.GetType(Data.ClassType).GetField(Field).GetValue(Data).AsType<TResponseToolsFilterType>.ToString;
end;

procedure TResponseToolsFilterTypeInterceptor.StringReverter(Data: TObject;
  Field, Arg: string);
begin
  RTTI.GetType(Data.ClassType).GetField(Field).SetValue(Data, TValue.From(TResponseToolsFilterType.Create(Arg)));
end;

{ TResponseItemContentTypeHelper }

constructor TResponseItemContentTypeHelper.Create(const Value: string);
begin
  Self := TEnumValueRecovery.TypeRetrieve<TResponseItemContentType>(Value,
            ['input_text', 'input_image', 'input_file', 'output_text', 'refusal']);
end;

function TResponseItemContentTypeHelper.ToString: string;
begin
  case self of
    TResponseItemContentType.input_text:
      Exit('input_text');
    TResponseItemContentType.input_image:
      Exit('input_image');
    TResponseItemContentType.input_file:
      Exit('input_file');
    TResponseItemContentType.output_text:
      Exit('output_text');
    TResponseItemContentType.refusal:
      Exit('refusal');
  end;
end;

{ TResponseItemContentTypeInterceptor }

function TResponseItemContentTypeInterceptor.StringConverter(Data: TObject;
  Field: string): string;
begin
  Result := RTTI.GetType(Data.ClassType).GetField(Field).GetValue(Data).AsType<TResponseItemContentType>.ToString;
end;

procedure TResponseItemContentTypeInterceptor.StringReverter(Data: TObject;
  Field, Arg: string);
begin
  RTTI.GetType(Data.ClassType).GetField(Field).SetValue(Data, TValue.From(TResponseItemContentType.Create(Arg)));
end;

{ TResponseStreamTypeHelper }

constructor TResponseStreamTypeHelper.Create(const Value: string);
begin
  Self := TEnumValueRecovery.TypeRetrieve<TResponseStreamType>(Value,
            [ 'response.created',
              'response.in_progress',
              'response.completed',
              'response.failed',
              'response.incomplete',
              'response.output_item.added',
              'response.output_item.done',
              'response.content_part.added',
              'response.content_part.done',
              'response.output_text.delta',
              'response.output_text.annotation.added',
              'response.output_text.done',
              'response.refusal.delta',
              'response.refusal.done',
              'response.function_call_arguments.delta',
              'response.function_call_arguments.done',
              'response.file_search_call.in_progress',
              'response.file_search_call.searching',
              'response.file_search_call.completed',
              'response.web_search_call.in_progress',
              'response.web_search_call.searching',
              'response.web_search_call.completed',
              'response.reasoning_summary_part.added',
              'response.reasoning_summary_part.done',
              'response.reasoning_summary_text.delta',
              'response.reasoning_summary_text.done',
              'error'
            ]);
end;

function TResponseStreamTypeHelper.ToString: string;
begin
  case self of
    TResponseStreamType.created:
      Exit('response.created');
    TResponseStreamType.in_progress:
      Exit('response.in_progress');
    TResponseStreamType.completed:
      Exit('response.completed');
    TResponseStreamType.failed:
      Exit('response.failed');
    TResponseStreamType.incomplete:
      Exit('response.incomplete');
    TResponseStreamType.output_item_added:
      Exit('response.output_item.added');
    TResponseStreamType.output_item_done:
      Exit('response.output_item.done');
    TResponseStreamType.content_part_added:
      Exit('response.content_part.added');
    TResponseStreamType.content_part_done:
      Exit('response.content_part.done');
    TResponseStreamType.output_text_delta:
      Exit('response.output_text.delta');
    TResponseStreamType.output_text_annotation_added:
      Exit('response.output_text.annotation.added');
    TResponseStreamType.output_text_done:
      Exit('response.output_text.done');
    TResponseStreamType.refusal_delta:
      Exit('response.refusal.delta');
    TResponseStreamType.refusal_done:
      Exit('response.refusal.done');
    TResponseStreamType.function_call_arguments_delta:
      Exit('response.function_call_arguments.delta');
    TResponseStreamType.function_call_arguments_done:
      Exit('response.function_call_arguments.done');
    TResponseStreamType.file_search_call_in_progress:
      Exit('response.file_search_call.in_progress');
    TResponseStreamType.file_search_call_searching:
      Exit('response.file_search_call.searching');
    TResponseStreamType.file_search_call_completed:
      Exit('response.file_search_call.completed');
    TResponseStreamType.web_search_call_in_progress:
      Exit('response.web_search_call.in_progress');
    TResponseStreamType.web_search_call_searching:
      Exit('response.web_search_call.searching');
    TResponseStreamType.web_search_call_completed:
      Exit('response.web_search_call.completed');

    TResponseStreamType.reasoning_summary_part_add:
      Exit('response.reasoning_summary_part.added');
    TResponseStreamType.reasoning_summary_part_done:
      Exit('response.reasoning_summary_part.done');
    TResponseStreamType.reasoning_summary_text_delta:
      Exit('response.reasoning_summary_text.delta');
    TResponseStreamType.reasoning_summary_text_done:
      Exit('response.reasoning_summary_text.done');


    TResponseStreamType.error:
      Exit('error');
  end;
end;

{ TResponseStreamTypeInterceptor }

function TResponseStreamTypeInterceptor.StringConverter(Data: TObject;
  Field: string): string;
begin
  Result := RTTI.GetType(Data.ClassType).GetField(Field).GetValue(Data).AsType<TResponseStreamType>.ToString;
end;

procedure TResponseStreamTypeInterceptor.StringReverter(Data: TObject; Field,
  Arg: string);
begin
  RTTI.GetType(Data.ClassType).GetField(Field).SetValue(Data, TValue.From(TResponseStreamType.Create(Arg)));
end;

{ TBackGroundTypeHelper }

constructor TBackGroundTypeHelper.Create(const Value: string);
begin
  Self := TEnumValueRecovery.TypeRetrieve<TBackGroundType>(Value,
            ['transparent', 'opaque', 'auto']);
end;

function TBackGroundTypeHelper.ToString: string;
begin
  case self of
    TBackGroundType.transparent:
      Exit('transparent');
    TBackGroundType.opaque:
      Exit('opaque');
    TBackGroundType.auto:
      Exit('auto');
  end;
end;

{ TImageModerationTypeHelper }

constructor TImageModerationTypeHelper.Create(const Value: string);
begin
  Self := TEnumValueRecovery.TypeRetrieve<TImageModerationType>(Value,
            ['low', 'auto']);
end;

function TImageModerationTypeHelper.ToString: string;
begin
  case self of
    TImageModerationType.low:
      Exit('low');
    TImageModerationType.auto:
      Exit('auto');
  end;
end;

{ TOutputFormatTypeHelper }

constructor TOutputFormatTypeHelper.Create(const Value: string);
begin
  Self := TEnumValueRecovery.TypeRetrieve<TOutputFormatType>(Value,
            ['png', 'jpeg', 'webp']);
end;

function TOutputFormatTypeHelper.ToString: string;
begin
  case self of
    TOutputFormatType.png:
      Exit('png');
    TOutputFormatType.jpeg:
      Exit('jpeg');
    TOutputFormatType.webp:
      Exit('webp');
  end;
end;

{ TImageQualityTypeHelper }

constructor TImageQualityTypeHelper.Create(const Value: string);
begin
  Self := TEnumValueRecovery.TypeRetrieve<TImageQualityType>(Value,
            ['high', 'medium', 'low', 'standard', 'auto']);
end;

function TImageQualityTypeHelper.ToString: string;
begin
  case self of
    TImageQualityType.high:
      Exit('high');
    TImageQualityType.medium:
      Exit('medium');
    TImageQualityType.low:
      Exit('low');
    TImageQualityType.standard:
      Exit('standard');
    TImageQualityType.auto:
      Exit('auto');
  end;
end;

end.
