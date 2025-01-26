unit GenAI.Types;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGenAI
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.SysUtils, System.TypInfo, System.Rtti, GenAI.Consts, GenAI.API.Params;

{$SCOPEDENUMS ON}

type

  TMetadataInterceptor = class(TJSONInterceptorStringToString)
  public
    procedure StringReverter(Data: TObject; Field: string; Arg: string); override;
  end;

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
    r1024x1792
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
    vision
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

implementation

uses
  System.StrUtils;

type
  TEnumValueRecovery = class
    class function TypeRetrieve<T>(const Value: string; const References: TArray<string>): T;
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
            ['256x256', '512x512', '1024x1024', '1792x1024', '1024x1792']);
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
             'fine-tune', 'fine-tune-results', 'vision']);
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

end.
