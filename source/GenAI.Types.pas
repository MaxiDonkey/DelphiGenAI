unit GenAI.Types;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGenAI
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.SysUtils, GenAI.API.Params, GenAI.Types.EnumWire;

{$SCOPEDENUMS ON}

type
  TStreamOptions = TJSONParam;

  TIncludeObfuscation = class(TStreamOptions)
    function IncludeObfuscation(const Value: Boolean): TIncludeObfuscation;
    class function New(const Value: Boolean = True): TIncludeObfuscation;
  end;

  TIncludeUsage = class(TStreamOptions)
    function IncludeUsage: TIncludeUsage;
    class function New: TIncludeUsage;
  end;

  {$REGION 'GenAI.Chat'}

  TRole = (
    assistant,
    user,
    developer,
    system,
    tool,
    unknown,
    critic,
    discriminator,
    sdk_unknown
  );

  TRoleHelper = record helper for TRole
    constructor Create(const Value: string);
    class function Parse(const Value: string): TRole; static;
    class function TryToParse(const Value: string; out Role: TRole): Boolean; static;
    function ToString: string;
  end;

  TRoleInterceptor = class(TJSONInterceptorStringToString)
    function StringConverter(Data: TObject; Field: string): string; override;
    procedure StringReverter(Data: TObject; Field: string; Arg: string); override;
  end;

  TAudioFormat = (
    wav,
    mp3,
    flac,
    opus,
    pcm16,
    sdk_unknown
  );

  TAudioFormatHelper = record helper for TAudioFormat
  const
    MimeMap: array[TAudioFormat] of string = (
      'audio/wav',
      'audio/mpeg',
      'audio/webm',
      'audio/opus',
      'audio/ogg',
      'sdk_unknown'
    );
  public
    constructor Create(const Value: string);
    class function Parse(const Value: string): TAudioFormat; static;
    class function TryToParse(const Value: string; out Format: TAudioFormat): Boolean; static;
    class function MimeTypeInput(const Value: string): TAudioFormat; static;
    function ToString: string;
  end;

  TImageDetail = (
    low,
    high,
    auto,
    sdk_unknown
  );

  TImageDetailHelper = record helper for TImageDetail
    constructor Create(const Value: string);
    class function Parse(const Value: string): TImageDetail; static;
    class function TryToParse(const Value: string; out Detail: TImageDetail): Boolean; static;
    function ToString: string;
  end;

  TImageDetailInterceptor = class(TJSONInterceptorStringToString)
    function StringConverter(Data: TObject; Field: string): string; override;
    procedure StringReverter(Data: TObject; Field: string; Arg: string); override;
  end;

  TReasoningEffort = (
    none,
    minimal,
    low,
    medium,
    high,
    xhigh,
    sdk_unknown
  );

  TReasoningEffortHelper = record helper for TReasoningEffort
    constructor Create(const Value: string);
    class function Parse(const Value: string): TReasoningEffort; static;
    class function TryToParse(const Value: string; out Effort: TReasoningEffort): Boolean; static;
    function ToString: string;
  end;

  TReasoningEffortInterceptor = class(TJSONInterceptorStringToString)
    function StringConverter(Data: TObject; Field: string): string; override;
    procedure StringReverter(Data: TObject; Field: string; Arg: string); override;
  end;

  TModalities = (
    text,
    audio,
    sdk_unknown
  );

  TModalitiesHelper = record helper for TModalities
    constructor Create(const Value: string);
    class function Parse(const Value: string): TModalities; static;
    class function TryToParse(const Value: string; out Modality: TModalities): Boolean; static;
    function ToString: string;
  end;

  TChatVoice = (
    ash,
    ballad,
    coral,
    sage,
    verse,
    sdk_unknown
  );

  TChatVoiceHelper = record helper for TChatVoice
    constructor Create(const Value: string);
    class function Parse(const Value: string): TChatVoice; static;
    class function TryToParse(const Value: string; out Voice: TChatVoice): Boolean; static;
    function ToString: string;
  end;

  TToolChoice = (
    none,
    auto,
    required,
    sdk_unknown
  );

  TToolChoiceHelper = record helper for TToolChoice
    constructor Create(const Value: string);
    class function Parse(const Value: string): TToolChoice; static;
    class function TryToParse(const Value: string; out Choice: TToolChoice): Boolean; static;
    function ToString: string;
  end;

  TFinishReason = (
    stop,
    length,
    content_filter,
    tool_calls,
    sdk_unknown
  );

  TFinishReasonHelper = record helper for TFinishReason
    constructor Create(const Value: string);
    class function Parse(const Value: string): TFinishReason; static;
    class function TryToParse(const Value: string; out Reason: TFinishReason): Boolean; static;
    function ToString: string;
  end;

  TFinishReasonInterceptor = class(TJSONInterceptorStringToString)
    function StringConverter(Data: TObject; Field: string): string; override;
    procedure StringReverter(Data: TObject; Field: string; Arg: string); override;
  end;

  TToolCalls = (
    &function,
    sdk_unknown
  );

  TToolCallsHelper = record helper for TToolCalls
  const
    Map: array[TToolCalls] of string = (
      'function',
      'sdk_unknown'
    );
  public
    constructor Create(const Value: string);
    class function Parse(const Value: string): TToolCalls; static;
    class function TryToParse(const Value: string; out ToolCall: TToolCalls): Boolean; static;
    function ToString: string;
  end;

  TToolCallsInterceptor = class(TJSONInterceptorStringToString)
    function StringConverter(Data: TObject; Field: string): string; override;
    procedure StringReverter(Data: TObject; Field: string; Arg: string); override;
  end;

  TSearchWebOptions = (
    low,
    medium,
    high,
    sdk_unknown
  );

  TSearchWebOptionsHelper = record helper for TSearchWebOptions
    constructor Create(const Value: string);
    class function Parse(const Value: string): TSearchWebOptions; static;
    class function TryToParse(const Value: string; out Option: TSearchWebOptions): Boolean; static;
    function ToString: string;
  end;

  TVerbosityType = (
    low,
    medium,
    high,
    sdk_unknown
  );

  TVerbosityTypeHelper = record helper for TVerbosityType
    constructor Create(const Value: string);
    class function Parse(const Value: string): TVerbosityType; static;
    class function TryToParse(const Value: string; out Verbosity: TVerbosityType): Boolean; static;
    function ToString: string;
  end;

  TVerbosityTypeInterceptor = class(TJSONInterceptorStringToString)
    function StringConverter(Data: TObject; Field: string): string; override;
    procedure StringReverter(Data: TObject; Field: string; Arg: string); override;
  end;

  {$ENDREGION}

  {$REGION 'GenAI.Audio'}

  /// <summary>
  /// Voices available for text-to-speech generation (audio/speech endpoint).
  /// </summary>
  TAudioVoice = (
    alloy,
    ash,
    coral,
    echo,
    fable,
    onyx,
    nova,
    sage,
    shimmer,
    ballad,
    cedar,
    marin,
    verse,
    sdk_unknown
  );

  TAudioVoiceHelper = record helper for TAudioVoice
    constructor Create(const Value: string);
    class function Parse(const Value: string): TAudioVoice; static;
    class function TryToParse(const Value: string; out Voice: TAudioVoice): Boolean; static;
    function ToString: string;
  end;

  /// <summary>
  /// Audio output formats supported by the speech generation endpoint.
  /// </summary>
  TSpeechFormat = (
    mp3,
    opus,
    aac,
    flac,
    wav,
    pcm,
    sdk_unknown
  );

  TSpeechFormatHelper = record helper for TSpeechFormat
    constructor Create(const Value: string);
    class function Parse(const Value: string): TSpeechFormat; static;
    class function TryToParse(const Value: string; out Format: TSpeechFormat): Boolean; static;
    function ToString: string;
  end;

  /// <summary>
  /// Streaming format used by the speech generation endpoint.
  /// </summary>
  TSpeechStreamFormat = (
    audio,
    sse,
    sdk_unknown
  );

  TSpeechStreamFormatHelper = record helper for TSpeechStreamFormat
    constructor Create(const Value: string);
    class function Parse(const Value: string): TSpeechStreamFormat; static;
    class function TryToParse(const Value: string; out Format: TSpeechStreamFormat): Boolean; static;
    function ToString: string;
  end;

  /// <summary>
  /// Output formats supported by the audio transcription/translation endpoints.
  /// </summary>
  TTranscriptionResponseFormat = (
    json,
    text,
    srt,
    verbose_json,
    vtt,
    diarized_json,
    sdk_unknown
  );

  TTranscriptionResponseFormatHelper = record helper for TTranscriptionResponseFormat
    constructor Create(const Value: string);
    class function Parse(const Value: string): TTranscriptionResponseFormat; static;
    class function TryToParse(const Value: string; out Format: TTranscriptionResponseFormat): Boolean; static;
    function ToString: string;
  end;

  /// <summary>
  /// Optional fields that can be included in transcription responses.
  /// </summary>
  TTranscriptionInclude = (
    logprobs,
    sdk_unknown
  );

  TTranscriptionIncludeHelper = record helper for TTranscriptionInclude
    constructor Create(const Value: string);
    class function Parse(const Value: string): TTranscriptionInclude; static;
    class function TryToParse(const Value: string; out Include: TTranscriptionInclude): Boolean; static;
    function ToString: string;
  end;

  /// <summary>
  /// Timestamp granularities requested for verbose transcription responses.
  /// </summary>
  TTimestampGranularity = (
    word,
    segment,
    sdk_unknown
  );

  TTimestampGranularityHelper = record helper for TTimestampGranularity
    constructor Create(const Value: string);
    class function Parse(const Value: string): TTimestampGranularity; static;
    class function TryToParse(const Value: string; out Granularity: TTimestampGranularity): Boolean; static;
    function ToString: string;
  end;

  /// <summary>
  /// Chunking strategy used by the transcription endpoint.
  /// </summary>
  TTranscriptionChunkingStrategyType = (
    auto,
    server_vad,
    sdk_unknown
  );

  TTranscriptionChunkingStrategyTypeHelper = record helper for TTranscriptionChunkingStrategyType
    constructor Create(const Value: string);
    class function Parse(const Value: string): TTranscriptionChunkingStrategyType; static;
    class function TryToParse(const Value: string; out ChunkingStrategy: TTranscriptionChunkingStrategyType): Boolean; static;
    function ToString: string;
  end;

  {$ENDREGION}

  {$REGION 'GenAI.Batch'}

  /// <summary>
  /// Relative endpoint URL targeted by a batch request.
  /// </summary>
  TBatchUrl = (
    chat_completions,
    embeddings,
    sdk_unknown
  );

  TBatchUrlHelper = record helper for TBatchUrl
  const
    Map: array[TBatchUrl] of string = (
      '/v1/chat/completions',
      '/v1/embeddings',
      'sdk_unknown'
    );
  public
    constructor Create(const Value: string);
    class function Parse(const Value: string): TBatchUrl; static;
    class function TryToParse(const Value: string; out Url: TBatchUrl): Boolean; static;
    function ToString: string;
  end;

  /// <summary>
  /// Lifecycle status of a batch operation.
  /// </summary>
  TBatchStatus = (
    validating,
    failed,
    in_progress,
    finalizing,
    completed,
    expired,
    cancelling,
    cancelled,
    sdk_unknown
  );

  TBatchStatusHelper = record helper for TBatchStatus
    constructor Create(const Value: string);
    class function Parse(const Value: string): TBatchStatus; static;
    class function TryToParse(const Value: string; out Status: TBatchStatus): Boolean; static;
    function ToString: string;
  end;

  TBatchStatusInterceptor = class(TJSONInterceptorStringToString)
    function StringConverter(Data: TObject; Field: string): string; override;
    procedure StringReverter(Data: TObject; Field: string; Arg: string); override;
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
    base64,
    sdk_unknown
  );

  TEncodingFormatHelper = record helper for TEncodingFormat
    constructor Create(const Value: string);
    class function Parse(const Value: string): TEncodingFormat; static;
    class function TryToParse(const Value: string; out Format: TEncodingFormat): Boolean; static;
    function ToString: string;
  end;

  {$ENDREGION}

  {$REGION 'GenAI.Files'}

  /// <summary>
  /// Defines the various use cases for uploaded files.
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
    assistants,
    /// <summary>
    /// Assistants_Output - Used for output files from the Assistants API.
    /// </summary>
    assistants_output,
    /// <summary>
    /// Batch - Used for input files for the Batch API.
    /// </summary>
    batch,
    /// <summary>
    /// Batch_Output - Used for output files generated by the Batch API.
    /// </summary>
    batch_output,
    /// <summary>
    /// Fine-Tune - Used for input files for fine-tuning models.
    /// </summary>
    finetune,
    /// <summary>
    /// Fine-Tune_Results - Used for results files generated from fine-tuning jobs.
    /// </summary>
    finetune_results,
    /// <summary>
    /// Vision - Used for image input files in vision-related tasks.
    /// </summary>
    vision,
    /// <summary>
    /// Used for eval data sets.
    /// </summary>
    evals,
    /// <summary>
    /// Flexible file type for any purpose.
    /// </summary>
    user_data,
    sdk_unknown
  );

  TFilesPurposeHelper = record helper for TFilesPurpose
  const
    Map: array[TFilesPurpose] of string = (
      'assistants',
      'assistants_output',
      'batch',
      'batch_output',
      'fine-tune',
      'fine-tune-results',
      'vision',
      'evals',
      'user_data',
      'sdk_unknown'
    );
  public
    constructor Create(const Value: string);
    class function Parse(const Value: string): TFilesPurpose; static;
    class function TryToParse(const Value: string; out Purpose: TFilesPurpose): Boolean; static;
    function ToString: string;
  end;

  TFilesPurposeInterceptor = class(TJSONInterceptorStringToString)
    function StringConverter(Data: TObject; Field: string): string; override;
    procedure StringReverter(Data: TObject; Field: string; Arg: string); override;
  end;

  {$ENDREGION}

  {$REGION 'GenAI.Vector'}

  TChunkingStrategyType = (
    auto,
    &static,
    sdk_unknown
  );

  TChunkingStrategyTypeHelper = record helper for TChunkingStrategyType
    constructor Create(const Value: string);
    class function Parse(const Value: string): TChunkingStrategyType; static;
    class function TryToParse(const Value: string; out StrategyType: TChunkingStrategyType): Boolean; static;
    function ToString: string;
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
    expired,
    sdk_unknown
  );

  TRunStatusHelper = record helper for TRunStatus
    constructor Create(const Value: string);
    class function Parse(const Value: string): TRunStatus; static;
    class function TryToParse(const Value: string; out Status: TRunStatus): Boolean; static;
    function ToString: string;
  end;

  TRunStatusInterceptor = class(TJSONInterceptorStringToString)
    function StringConverter(Data: TObject; Field: string): string; override;
    procedure StringReverter(Data: TObject; Field: string; Arg: string); override;
  end;

  {$ENDREGION}

  {$REGION 'GenAI.FineTuning'}

  /// <summary>
  /// Fine-tuning method type (supervised learning or Direct Preference Optimization).
  /// </summary>
  TJobMethodType = (
    supervised,
    dpo,
    sdk_unknown
  );

  TJobMethodTypeHelper = record helper for TJobMethodType
    constructor Create(const Value: string);
    class function Parse(const Value: string): TJobMethodType; static;
    class function TryToParse(const Value: string; out Method: TJobMethodType): Boolean; static;
    function ToString: string;
  end;

  TJobMethodTypeInterceptor = class(TJSONInterceptorStringToString)
    function StringConverter(Data: TObject; Field: string): string; override;
    procedure StringReverter(Data: TObject; Field: string; Arg: string); override;
  end;

  /// <summary>
  /// Lifecycle status of a fine-tuning job.
  /// </summary>
  TFineTunedStatus = (
    validating_files,
    queued,
    running,
    succeeded,
    failed,
    cancelled,
    sdk_unknown
  );

  TFineTunedStatusHelper = record helper for TFineTunedStatus
    constructor Create(const Value: string);
    class function Parse(const Value: string): TFineTunedStatus; static;
    class function TryToParse(const Value: string; out Status: TFineTunedStatus): Boolean; static;
    function ToString: string;
  end;

  TFineTunedStatusInterceptor = class(TJSONInterceptorStringToString)
    function StringConverter(Data: TObject; Field: string): string; override;
    procedure StringReverter(Data: TObject; Field: string; Arg: string); override;
  end;

  {$ENDREGION}

  {$REGION 'GenAI.Images'}

  /// <summary>
  /// Output format of the response for image generation requests (URL or base64 JSON).
  /// </summary>
  TResponseFormat = (
    url,
    b64_json,
    sdk_unknown
  );

  TResponseFormatHelper = record helper for TResponseFormat
    constructor Create(const Value: string);
    class function Parse(const Value: string): TResponseFormat; static;
    class function TryToParse(const Value: string; out Format: TResponseFormat): Boolean; static;
    function ToString: string;
  end;

  /// <summary>
  /// Supported dimensions for generated images.
  /// </summary>
  TImageSize = (
    r256x256,
    r512x512,
    r1024x1024,
    r1792x1024,
    r1024x1792,
    r1536x1024,
    r1024x1536,
    auto,
    sdk_unknown
  );

  TImageSizeHelper = record helper for TImageSize
  const
    Map: array[TImageSize] of string = (
      '256x256',
      '512x512',
      '1024x1024',
      '1792x1024',
      '1024x1792',
      '1536x1024',
      '1024x1536',
      'auto',
      'sdk_unknown'
    );
  public
    constructor Create(const Value: string);
    class function Parse(const Value: string): TImageSize; static;
    class function TryToParse(const Value: string; out Size: TImageSize): Boolean; static;
    function ToString: string;
  end;

  /// <summary>
  /// Visual style of the generated images (DALL-E 3 only).
  /// </summary>
  TImageStyle = (
    vivid,
    natural,
    sdk_unknown
  );

  TImageStyleHelper = record helper for TImageStyle
    constructor Create(const Value: string);
    class function Parse(const Value: string): TImageStyle; static;
    class function TryToParse(const Value: string; out Style: TImageStyle): Boolean; static;
    function ToString: string;
  end;

  /// <summary>
  /// Background transparency setting for generated images (gpt-image-1 only).
  /// </summary>
  TBackGroundType = (
    transparent,
    opaque,
    auto,
    sdk_unknown
  );

  TBackGroundTypeHelper = record helper for TBackGroundType
    constructor Create(const Value: string);
    class function Parse(const Value: string): TBackGroundType; static;
    class function TryToParse(const Value: string; out Background: TBackGroundType): Boolean; static;
    function ToString: string;
  end;

  /// <summary>
  /// Content-moderation level for generated images (gpt-image-1 only).
  /// </summary>
  TImageModerationType = (
    low,
    auto,
    sdk_unknown
  );

  TImageModerationTypeHelper = record helper for TImageModerationType
    constructor Create(const Value: string);
    class function Parse(const Value: string): TImageModerationType; static;
    class function TryToParse(const Value: string; out Moderation: TImageModerationType): Boolean; static;
    function ToString: string;
  end;

  /// <summary>
  /// Output file format for generated images (gpt-image-1 only).
  /// </summary>
  TOutputFormatType = (
    png,
    jpeg,
    webp,
    sdk_unknown
  );

  TOutputFormatTypeHelper = record helper for TOutputFormatType
    constructor Create(const Value: string);
    class function Parse(const Value: string): TOutputFormatType; static;
    class function TryToParse(const Value: string; out Format: TOutputFormatType): Boolean; static;
    function ToString: string;
  end;

  /// <summary>
  /// Quality setting for generated images.
  /// </summary>
  TImageQualityType = (
    high,
    medium,
    low,
    standard,
    hd,
    auto,
    sdk_unknown
  );

  TImageQualityTypeHelper = record helper for TImageQualityType
    constructor Create(const Value: string);
    class function Parse(const Value: string): TImageQualityType; static;
    class function TryToParse(const Value: string; out Quality: TImageQualityType): Boolean; static;
    function ToString: string;
  end;

  /// <summary>
  /// Controls how much effort the model will exert to match the style and features,
  /// especially facial features, of input images (gpt-image models only).
  /// </summary>
  TImageInputFidelity = (
    high,
    low,
    sdk_unknown
  );

  TImageInputFidelityHelper = record helper for TImageInputFidelity
    constructor Create(const Value: string);
    class function Parse(const Value: string): TImageInputFidelity; static;
    class function TryToParse(const Value: string; out Fidelity: TImageInputFidelity): Boolean; static;
    function ToString: string;
  end;

  {$ENDREGION}

  {$REGION 'GenAI.Moderation'}

  /// <summary>
  /// Moderation harm categories used to classify potentially harmful content.
  /// </summary>
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
    violenceGraphic,
    sdk_unknown
  );

  THarmCategoriesHelper = record helper for THarmCategories
  const
    Map: array[THarmCategories] of string = (
      'hate',
      'hate threatening',
      'harassment',
      'harassment threatening',
      'illicit',
      'illicit violent',
      'self harm',
      'self harm intent',
      'self harm instructions',
      'sexual',
      'sexual minors',
      'violence',
      'violence graphic',
      'sdk_unknown'
    );
  public
    constructor Create(const Value: string);
    class function Parse(const Value: string): THarmCategories; static;
    class function TryToParse(const Value: string; out Category: THarmCategories): Boolean; static;
    function ToString: string;
  end;

  {$ENDREGION}

  {$REGION 'GenAI.Schema'}

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
    &object,
    sdk_unknown
  );

  TSchemaTypeHelper = record Helper for TSchemaType
    constructor Create(const Value: string);
    class function Parse(const Value: string): TSchemaType; static;
    class function TryToParse(const Value: string; out SchemaType: TSchemaType): Boolean; static;
    function ToString: string;
  end;

  {$ENDREGION}

  {$REGION 'GenAI.Messages'}

  TMessageStatus = (
    in_progress,
    incomplete,
    completed,
    sdk_unknown
  );

  TMessageStatusHelper = record helper for TMessageStatus
  const
    Map: array[TMessageStatus] of string = (
      'in_progress',
      'incomplete',
      'completed',
      'sdk_unknown'
    );
  public
    constructor Create(const Value: string);
    class function Parse(const Value: string): TMessageStatus; static;
    class function TryToParse(const Value: string; out EnumValue: TMessageStatus): Boolean; static;
    function ToString: string;
  end;

  TMessageStatusInterceptor = class(TJSONInterceptorStringToString)
    function StringConverter(Data: TObject; Field: string): string; override;
    procedure StringReverter(Data: TObject; Field: string; Arg: string); override;
  end;

  {$ENDREGION}

  {$REGION 'GenAI.Responses'}

  TResponseFormatType = (
    auto,
    text,
    json_object,
    json_schema,
    sdk_unknown
  );

  TResponseFormatTypeHelper = record helper for TResponseFormatType
  const
    Map: array[TResponseFormatType] of string = (
      'auto',
      'text',
      'json_object',
      'json_schema',
      'sdk_unknown'
    );
  public
    constructor Create(const Value: string);
    class function Parse(const Value: string): TResponseFormatType; static;
    class function TryToParse(const Value: string; out EnumValue: TResponseFormatType): Boolean; static;
    function ToString: string;
  end;

  TResponseFormatTypeInterceptor = class(TJSONInterceptorStringToString)
    function StringConverter(Data: TObject; Field: string): string; override;
    procedure StringReverter(Data: TObject; Field: string; Arg: string); override;
  end;

  TOutputIncluding = (
    file_search_call_results,
    web_search_call_results,
    message_input_image_image_url,
    computer_call_output_output_image_url,
    reasoning_encrypted_content,
    code_interpreter_call_outputs,
    message_output_text_logprobs,
    web_search_call_action_sources,
    sdk_unknown
  );

  TOutputIncludingHelper = record helper for TOutputIncluding
  const
    Map: array[TOutputIncluding] of string = (
      'file_search_call.results',
      'web_search_call.results',
      'message.input_image.image_url',
      'computer_call_output.output.image_url',
      'reasoning.encrypted_content',
      'code_interpreter_call.outputs',
      'message.output_text.logprobs',
      'web_search_call.action.sources',
      'sdk_unknown'
    );
  public
    constructor Create(const Value: string);
    class function Parse(const Value: string): TOutputIncluding; static;
    class function TryToParse(const Value: string; out EnumValue: TOutputIncluding): Boolean; static;
    function ToString: string;
  end;

  TServiceTier = (
    auto,
    &default,
    flex,
    scale,
    priority,
    sdk_unknown
  );

  TServiceTierHelper = record helper for TServiceTier
    constructor Create(const Value: string);
    class function Parse(const Value: string): TServiceTier; static;
    class function TryToParse(const Value: string; out EnumValue: TServiceTier): Boolean; static;
    function ToString: string;
  end;

  TPromptCacheRetention = (
    in_memory,
    h24,
    sdk_unknown
  );

  TPromptCacheRetentionHelper = record helper for TPromptCacheRetention
  const
    Map: array[TPromptCacheRetention] of string = (
      'in_memory',
      '24h',
      'sdk_unknown'
    );
  public
    constructor Create(const Value: string);
    class function Parse(const Value: string): TPromptCacheRetention; static;
    class function TryToParse(const Value: string; out EnumValue: TPromptCacheRetention): Boolean; static;
    function ToString: string;
  end;

  TMCPConnectorType = (
    connector_dropbox,
    connector_gmail,
    connector_googlecalendar,
    connector_googledrive,
    connector_microsoftteams,
    connector_outlookcalendar,
    connector_outlookemail,
    connector_sharepoint,
    sdk_unknown
  );

  TMCPConnectorTypeHelper = record helper for TMCPConnectorType
    constructor Create(const Value: string);
    class function Parse(const Value: string): TMCPConnectorType; static;
    class function TryToParse(const Value: string; out EnumValue: TMCPConnectorType): Boolean; static;
    function ToString: string;
  end;

  TImageGenActionType = (
    generate,
    edit,
    auto,
    sdk_unknown
  );

  TImageGenActionTypeHelper = record helper for TImageGenActionType
    constructor Create(const Value: string);
    class function Parse(const Value: string): TImageGenActionType; static;
    class function TryToParse(const Value: string; out EnumValue: TImageGenActionType): Boolean; static;
    function ToString: string;
  end;

  TToolSearchExecution = (
    server,
    client,
    sdk_unknown
  );

  TToolSearchExecutionHelper = record helper for TToolSearchExecution
    constructor Create(const Value: string);
    class function Parse(const Value: string): TToolSearchExecution; static;
    class function TryToParse(const Value: string; out EnumValue: TToolSearchExecution): Boolean; static;
    function ToString: string;
  end;

  TAllowedToolsMode = (
    auto,
    required,
    sdk_unknown
  );

  TAllowedToolsModeHelper = record helper for TAllowedToolsMode
    constructor Create(const Value: string);
    class function Parse(const Value: string): TAllowedToolsMode; static;
    class function TryToParse(const Value: string; out EnumValue: TAllowedToolsMode): Boolean; static;
    function ToString: string;
  end;

  TContainerMemoryLimit = (
    g1,
    g4,
    g16,
    g64,
    sdk_unknown
  );

  TContainerMemoryLimitHelper = record helper for TContainerMemoryLimit
  const
    Map: array[TContainerMemoryLimit] of string = (
      '1g',
      '4g',
      '16g',
      '64g',
      'sdk_unknown'
    );
  public
    constructor Create(const Value: string);
    class function Parse(const Value: string): TContainerMemoryLimit; static;
    class function TryToParse(const Value: string; out EnumValue: TContainerMemoryLimit): Boolean; static;
    function ToString: string;
  end;

  TReasoningGenerateSummary = (
    auto,
    concise,
    detailed,
    sdk_unknown
  );

  TReasoningGenerateSummaryHelper = record helper for TReasoningGenerateSummary
  const
    Map: array[TReasoningGenerateSummary] of string = (
      'auto',
      'concise',
      'detailed',
      'sdk_unknown'
    );
  public
    constructor Create(const Value: string);
    class function Parse(const Value: string): TReasoningGenerateSummary; static;
    class function TryToParse(const Value: string; out EnumValue: TReasoningGenerateSummary): Boolean; static;
    function ToString: string;
  end;

  TFidelityType = (
    low,
    high,
    sdk_unknown
  );

  TFidelityTypeHelper = record helper for TFidelityType
  const
    Map: array[TFidelityType] of string = (
      'low',
      'high',
      'sdk_unknown'
    );
  public
    constructor Create(const Value: string);
    class function Parse(const Value: string): TFidelityType; static;
    class function TryToParse(const Value: string; out EnumValue: TFidelityType): Boolean; static;
    function ToString: string;
  end;

  TToolParamsFormatType = (
    text,
    grammar,
    sdk_unknown
  );

  TToolParamsFormatTypeHelper = record helper for TToolParamsFormatType
  const
    Map: array[TToolParamsFormatType] of string = (
      'text',
      'grammar',
      'sdk_unknown'
    );
  public
    constructor Create(const Value: string);
    class function Parse(const Value: string): TToolParamsFormatType; static;
    class function TryToParse(const Value: string; out EnumValue: TToolParamsFormatType): Boolean; static;
    function ToString: string;
  end;

  TSyntaxFormatType = (
    lark,
    regex,
    sdk_unknown
  );

  TSyntaxFormatTypeHelper = record helper for TSyntaxFormatType
  const
    Map: array[TSyntaxFormatType] of string = (
      'lark',
      'regex',
      'sdk_unknown'
    );
  public
    constructor Create(const Value: string);
    class function Parse(const Value: string): TSyntaxFormatType; static;
    class function TryToParse(const Value: string; out EnumValue: TSyntaxFormatType): Boolean; static;
    function ToString: string;
  end;

  TInputItemType = (
    input_text,
    input_image,
    input_file,
    input_audio,
    sdk_unknown
  );

  TInputItemTypeHelper = record helper for TInputItemType
  const
    Map: array[TInputItemType] of string = (
      'input_text',
      'input_image',
      'input_file',
      'input_audio',
      'sdk_unknown'
    );
  public
    constructor Create(const Value: string);
    class function Parse(const Value: string): TInputItemType; static;
    class function TryToParse(const Value: string; out EnumValue: TInputItemType): Boolean; static;
    function ToString: string;
  end;

  TFileSearchToolCallType = (
    in_progress,
    searching,
    incomplete,
    failed,
    sdk_unknown
  );

  TFileSearchToolCallTypeHelper = record helper for TFileSearchToolCallType
  const
    Map: array[TFileSearchToolCallType] of string = (
      'in_progress',
      'searching',
      'incomplete',
      'failed',
      'sdk_unknown'
    );
  public
    constructor Create(const Value: string);
    class function Parse(const Value: string): TFileSearchToolCallType; static;
    class function TryToParse(const Value: string; out EnumValue: TFileSearchToolCallType): Boolean; static;
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
    forward,
    sdk_unknown
  );

  TMouseButtonHelper = record helper for TMouseButton
  const
    Map: array[TMouseButton] of string = (
      'left',
      'right',
      'wheel',
      'back',
      'forward',
      'sdk_unknown'
    );
  public
    constructor Create(const Value: string);
    class function Parse(const Value: string): TMouseButton; static;
    class function TryToParse(const Value: string; out EnumValue: TMouseButton): Boolean; static;
    function ToString: string;
  end;

  TMouseButtonInterceptor = class(TJSONInterceptorStringToString)
    function StringConverter(Data: TObject; Field: string): string; override;
    procedure StringReverter(Data: TObject; Field: string; Arg: string); override;
  end;

  TResponseOption = (
    text,
    json_schema,
    json_object,
    sdk_unknown
  );

  TResponseOptionHelper = record helper for TResponseOption
  const
    Map: array[TResponseOption] of string = (
      'text',
      'json_schema',
      'json_object',
      'sdk_unknown'
    );
  public
    constructor Create(const Value: string);
    class function Parse(const Value: string): TResponseOption; static;
    class function TryToParse(const Value: string; out EnumValue: TResponseOption): Boolean; static;
    function ToString: string;
  end;

  THostedTooltype = (
    file_search,
    web_search_preview,
    computer_use_preview,
    code_interpreter,
    mcp,
    image_generation,
    sdk_unknown
  );

  THostedTooltypeHelper = record helper for THostedTooltype
  const
    Map: array[THostedTooltype] of string = (
      'file_search',
      'web_search_preview',
      'computer_use_preview',
      'code_interpreter',
      'mcp',
      'image_generation',
      'sdk_unknown'
    );
  public
    constructor Create(const Value: string);
    class function Parse(const Value: string): THostedTooltype; static;
    class function TryToParse(const Value: string; out EnumValue: THostedTooltype): Boolean; static;
    function ToString: string;
  end;

  TComparisonFilterType = (
    eq,
    ne,
    gt,
    gte,
    lt,
    lte,
    sdk_unknown
  );

  TComparisonFilterTypeHelper = record helper for TComparisonFilterType
  const
    Map: array[TComparisonFilterType] of string = (
      'eq',
      'ne',
      'gt',
      'gte',
      'lt',
      'lte',
      'sdk_unknown'
    );
  public
    constructor Create(const Value: string);
    class function Parse(const Value: string): TComparisonFilterType; static;
    class function TryToParse(const Value: string; out EnumValue: TComparisonFilterType): Boolean; static;
    class function ToOperator(const Value: string): TComparisonFilterType; static;
    function ToString: string;
  end;

  TCompoundFilterType = (
    &and,
    &or,
    sdk_unknown
  );

  TCompoundFilterTypeHelper = record helper for TCompoundFilterType
  const
    Map: array[TCompoundFilterType] of string = (
      'and',
      'or',
      'sdk_unknown'
    );
  public
    constructor Create(const Value: string);
    class function Parse(const Value: string): TCompoundFilterType; static;
    class function TryToParse(const Value: string; out EnumValue: TCompoundFilterType): Boolean; static;
    function ToString: string;
  end;

  TWebSearchType = (
    web_search,
    web_search_2025_08_26,
    sdk_unknown
  );

  TWebSearchTypeHelper = record helper for TWebSearchType
  const
    Map: array[TWebSearchType] of string = (
      'web_search',
      'web_search_2025_08_26',
      'sdk_unknown'
    );
  public
    constructor Create(const Value: string);
    class function Parse(const Value: string): TWebSearchType; static;
    class function TryToParse(const Value: string; out EnumValue: TWebSearchType): Boolean; static;
    function ToString: string;
  end;

  TWebSearchPreviewType = (
    web_search_preview,
    web_search_preview_2025_03_11,
    sdk_unknown
  );

  TWebSearchPreviewTypeHelper = record helper for TWebSearchPreviewType
  const
    Map: array[TWebSearchPreviewType] of string = (
      'web_search_preview',
      'web_search_preview_2025_03_11',
      'sdk_unknown'
    );
  public
    constructor Create(const Value: string);
    class function Parse(const Value: string): TWebSearchPreviewType; static;
    class function TryToParse(const Value: string; out EnumValue: TWebSearchPreviewType): Boolean; static;
    function ToString: string;
  end;

  TResponseTruncationType = (
    auto,
    disabled,
    sdk_unknown
  );

  TResponseTruncationTypeHelper = record helper for TResponseTruncationType
  const
    Map: array[TResponseTruncationType] of string = (
      'auto',
      'disabled',
      'sdk_unknown'
    );
  public
    constructor Create(const Value: string);
    class function Parse(const Value: string): TResponseTruncationType; static;
    class function TryToParse(const Value: string; out EnumValue: TResponseTruncationType): Boolean; static;
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
    function_call_output,
    image_generation_call,
    code_interpreter_call,
    local_shell_call,
    local_shell_call_output,
    mcp_call,
    mcp_list_tools,
    mcp_approval_request,
    mcp_approval_response,
    custom_tool_call,
    custom_tool_call_output,
    tool_search_call,
    tool_search_output,
    compaction,
    shell_call,
    shell_call_output,
    apply_patch_call,
    apply_patch_call_output,
    sdk_unknown
  );

  TResponseTypesHelper = record helper for TResponseTypes
  const
    Map: array[TResponseTypes] of string = (
      'message',
      'file_search_call',
      'function_call',
      'web_search_call',
      'computer_call',
      'reasoning',
      'computer_call_output',
      'function_call_output',
      'image_generation_call',
      'code_interpreter_call',
      'local_shell_call',
      'local_shell_call_output',
      'mcp_call',
      'mcp_list_tools',
      'mcp_approval_request',
      'mcp_approval_response',
      'custom_tool_call',
      'custom_tool_call_output',
      'tool_search_call',
      'tool_search_output',
      'compaction',
      'shell_call',
      'shell_call_output',
      'apply_patch_call',
      'apply_patch_call_output',
      'sdk_unknown'
    );
  public
    constructor Create(const Value: string);
    class function Parse(const Value: string): TResponseTypes; static;
    class function TryToParse(const Value: string; out EnumValue: TResponseTypes): Boolean; static;
    function ToString: string;
  end;

  TResponseTypesInterceptor = class(TJSONInterceptorStringToString)
    function StringConverter(Data: TObject; Field: string): string; override;
    procedure StringReverter(Data: TObject; Field: string; Arg: string); override;
  end;

  TResponseContentType = (
    output_text,
    refusal,
    summary_text,
    sdk_unknown
  );

  TResponseContentTypeHelper = record helper for TResponseContentType
  const
    Map: array[TResponseContentType] of string = (
      'output_text',
      'refusal',
      'summary_text',
      'sdk_unknown'
    );
  public
    constructor Create(const Value: string);
    class function Parse(const Value: string): TResponseContentType; static;
    class function TryToParse(const Value: string; out EnumValue: TResponseContentType): Boolean; static;
    function ToString: string;
  end;

  TResponseContentTypeInterceptor = class(TJSONInterceptorStringToString)
    function StringConverter(Data: TObject; Field: string): string; override;
    procedure StringReverter(Data: TObject; Field: string; Arg: string); override;
  end;

  TResponseAnnotationType = (
    file_citation,
    url_citation,
    file_path,
    container_file_citation,
    sdk_unknown
  );

  TResponseAnnotationTypeHelper = record helper for TResponseAnnotationType
  const
    Map: array[TResponseAnnotationType] of string = (
      'file_citation',
      'url_citation',
      'file_path',
      'container_file_citation',
      'sdk_unknown'
    );
  public
    constructor Create(const Value: string);
    class function Parse(const Value: string): TResponseAnnotationType; static;
    class function TryToParse(const Value: string; out EnumValue: TResponseAnnotationType): Boolean; static;
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
    wait,
    sdk_unknown
  );

  TResponseComputerTypeHelper = record helper for TResponseComputerType
  const
    Map: array[TResponseComputerType] of string = (
      'click',
      'double_click',
      'drag',
      'keypress',
      'move',
      'screenshot',
      'scroll',
      'type',
      'wait',
      'sdk_unknown'
    );
  public
    constructor Create(const Value: string);
    class function Parse(const Value: string): TResponseComputerType; static;
    class function TryToParse(const Value: string; out EnumValue: TResponseComputerType): Boolean; static;
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
    failed,
    sdk_unknown
  );

  TResponseStatusHelper = record helper for TResponseStatus
  const
    Map: array[TResponseStatus] of string = (
      'in_progress',
      'incomplete',
      'completed',
      'failed',
      'sdk_unknown'
    );
  public
    constructor Create(const Value: string);
    class function Parse(const Value: string): TResponseStatus; static;
    class function TryToParse(const Value: string; out EnumValue: TResponseStatus): Boolean; static;
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
    web_search_preview_2025_03_11,
    mcp,
    code_interpreter,
    image_generation,
    local_shell,
    web_search_2025_08_26,
    web_search,
    custom,
    shell,
    apply_patch,
    tool_search,
    namespace,
    sdk_unknown
  );

  TResponseToolsTypeHelper = record helper for TResponseToolsType
  const
    Map: array[TResponseToolsType] of string = (
      'file_search',
      'function',
      'computer_use_preview',
      'web_search_preview',
      'web_search_preview_2025_03_11',
      'mcp',
      'code_interpreter',
      'image_generation',
      'local_shell',
      'web_search_2025_08_26',
      'web_search',
      'custom',
      'shell',
      'apply_patch',
      'tool_search',
      'namespace',
      'sdk_unknown'
    );
  public
    constructor Create(const Value: string);
    class function Parse(const Value: string): TResponseToolsType; static;
    class function TryToParse(const Value: string; out EnumValue: TResponseToolsType): Boolean; static;
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
    &or,
    sdk_unknown
  );

  TResponseToolsFilterTypeHelper = record helper for TResponseToolsFilterType
  const
    Map: array[TResponseToolsFilterType] of string = (
      'eq',
      'ne',
      'gt',
      'gte',
      'lt',
      'lte',
      'and',
      'or',
      'sdk_unknown'
    );
  public
    constructor Create(const Value: string);
    class function Parse(const Value: string): TResponseToolsFilterType; static;
    class function TryToParse(const Value: string; out EnumValue: TResponseToolsFilterType): Boolean; static;
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
    refusal,
    sdk_unknown
  );

  TResponseItemContentTypeHelper = record helper for TResponseItemContentType
  const
    Map: array[TResponseItemContentType] of string = (
      'input_text',
      'input_image',
      'input_file',
      'output_text',
      'refusal',
      'sdk_unknown'
    );
  public
    constructor Create(const Value: string);
    class function Parse(const Value: string): TResponseItemContentType; static;
    class function TryToParse(const Value: string; out EnumValue: TResponseItemContentType): Boolean; static;
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
    reasoning_summary_part_added,
    reasoning_summary_part_done,
    reasoning_summary_text_delta,
    reasoning_summary_text_done,
    reasoning_text_delta,
    reasoning_text_done,
    image_generation_call_completed,
    image_generation_call_generating,
    image_generation_call_in_progress,
    image_generation_call_partial_image,
    mcp_call_arguments_delta,
    mcp_call_arguments_done,
    mcp_call_completed,
    mcp_call_failed,
    mcp_call_in_progress,
    mcp_list_tools_completed,
    mcp_list_tools_failed,
    mcp_list_tools_in_progress,
    code_interpreter_call_in_progress,
    code_interpreter_call_interpreting,
    code_interpreter_call_completed,
    code_interpreter_call_code_delta,
    code_interpreter_call_code_done,
    output_text_annotation_added,
    queued,
    custom_tool_call_input_delta,
    custom_tool_call_input_done,
    error,
    sdk_unknown
  );

  TResponseStreamTypeHelper = record helper for TResponseStreamType
  const
    Map: array[TResponseStreamType] of string = (
      'response.created',
      'response.in_progress',
      'response.completed',
      'response.failed',
      'response.incomplete',
      'response.output_item.added',
      'response.output_item.done',
      'response.content_part.added',
      'response.content_part.done',
      'response.output_text.delta',
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
      'response.reasoning_text.delta',
      'response.reasoning_text.done',
      'response.image_generation_call.completed',
      'response.image_generation_call.generating',
      'response.image_generation_call.in_progress',
      'response.image_generation_call.partial_image',
      'response.mcp_call_arguments.delta',
      'response.mcp_call_arguments.done',
      'response.mcp_call.completed',
      'response.mcp_call.failed',
      'response.mcp_call.in_progress',
      'response.mcp_list_tools.completed',
      'response.mcp_list_tools.failed',
      'response.mcp_list_tools.in_progress',
      'response.code_interpreter_call.in_progress',
      'response.code_interpreter_call.interpreting',
      'response.code_interpreter_call.completed',
      'response.code_interpreter_call_code.delta',
      'response.code_interpreter_call_code.done',
      'response.output_text.annotation.added',
      'response.queued',
      'response.custom_tool_call_input.delta',
      'response.custom_tool_call_input.done',
      'error',
      'sdk_unknown'
    );
  public
    constructor Create(const Value: string);
    class function Parse(const Value: string): TResponseStreamType; static;
    class function TryToParse(const Value: string; out EnumValue: TResponseStreamType): Boolean; static;
    function ToString: string;
  end;

  TResponseStreamTypeInterceptor = class(TJSONInterceptorStringToString)
    function StringConverter(Data: TObject; Field: string): string; override;
    procedure StringReverter(Data: TObject; Field: string; Arg: string); override;
  end;

  {$ENDREGION}

  {$REGION 'GenAI.Gemini.Extra_body'}

  TThinkingLevelType = (
    THINKING_LEVEL_UNSPECIFIED,
    LOW,
    HIGH,
    sdk_unknown
  );

  TThinkingLevelTypeHelper = record Helper for TThinkingLevelType
    constructor Create(const Value: string);
    class function Parse(const Value: string): TThinkingLevelType; static;
    class function TryToParse(const Value: string; out ThinkingLevelType: TThinkingLevelType): Boolean; static;
    function ToString: string;
  end;

  {$ENDREGION}

  {$REGION 'GenAI.Gemini.Extra_body'}

  {$SCOPEDENUMS OFF}

  /// <summary>
  /// Discriminates the three kinds of tool calls the model can emit while
  /// streaming a response: a standard function call, a custom tool call or
  /// an MCP tool call. Mirrors the role played by <c>BlockType</c> in the
  /// Anthropic <c>TToolCallSnapshot</c>.
  /// </summary>
  TToolCallKind = (
    tcFunction,
    tcCustom,
    tcMcp
  );

  /// <summary>
  /// Discriminates the server-side tool activities that produce results or
  /// status while streaming: web search, file search, code interpreter,
  /// image generation, MCP tool listing and shell execution.
  /// </summary>
  TToolResultKind = (
    trWebSearch,
    trFileSearch,
    trCodeInterpreter,
    trImageGeneration,
    trMcpListTools,
    trShell
  );

  /// <summary>
  /// The kind of content block currently being streamed. Provides the same
  /// semantics as the Anthropic <c>TContentBlockType</c> exposed by
  /// <c>TEventData.CurrentBlockType</c>, adapted to the responses event model.
  /// </summary>
  TResponsesBlockType = (
    rbtNone,
    rbtText,
    rbtRefusal,
    rbtReasoning,
    rbtReasoningSummary,
    rbtToolUse,
    rbtToolResult
  );

  {$SCOPEDENUMS ON}

  {$ENDREGION}

  TMetadataInterceptor = class(TJSONInterceptorStringToString)
  public
    procedure StringReverter(Data: TObject; Field: string; Arg: string); override;
  end;

implementation

uses
  GenAI.API.JSONShield;

procedure RaiseUnknownEnumValue(const Value, TypeName: string);
begin
  raise EEnumWireError.CreateFmt(
    'Unknown enum wire value "%s" for %s',
    [Value, TypeName]);
end;

{ TRoleHelper }

constructor TRoleHelper.Create(const Value: string);
begin
  Self := Parse(Value);
end;

class function TRoleHelper.Parse(const Value: string): TRole;
begin
  if not TryToParse(Value, Result) then
    RaiseUnknownEnumValue(Value, 'TRole');
end;

class function TRoleHelper.TryToParse(const Value: string; out Role: TRole): Boolean;
begin
  Result := TEnumWire.TryToParse<TRole>(Value, Role);
  if not Result then
    Role := TRole.sdk_unknown;
end;

function TRoleHelper.ToString: string;
begin
  Result := TEnumWire.ToString<TRole>(Self);
end;

{ TRoleInterceptor }

function TRoleInterceptor.StringConverter(Data: TObject; Field: string): string;
begin
  Result := GetMemberValue<TRole>(Data, Field).ToString;
end;

procedure TRoleInterceptor.StringReverter(Data: TObject; Field: string; Arg: string);
var
  Role: TRole;
begin
  TRole.TryToParse(Arg, Role);
  SetMemberValue<TRole>(Data, Field, Role);
end;

{ TAudioFormatHelper }

constructor TAudioFormatHelper.Create(const Value: string);
begin
  Self := Parse(Value);
end;

class function TAudioFormatHelper.Parse(const Value: string): TAudioFormat;
begin
  if not TryToParse(Value, Result) then
    RaiseUnknownEnumValue(Value, 'TAudioFormat');
end;

class function TAudioFormatHelper.TryToParse(const Value: string; out Format: TAudioFormat): Boolean;
begin
  Result := TEnumWire.TryToParse<TAudioFormat>(Value, Format);
  if not Result then
    Format := TAudioFormat.sdk_unknown;
end;

class function TAudioFormatHelper.MimeTypeInput(const Value: string): TAudioFormat;
begin
  Result := TEnumWire.Parse<TAudioFormat>(Value, MimeMap);
end;

function TAudioFormatHelper.ToString: string;
begin
  Result := TEnumWire.ToString<TAudioFormat>(Self);
end;

{ TImageDetailHelper }

constructor TImageDetailHelper.Create(const Value: string);
begin
  Self := Parse(Value);
end;

class function TImageDetailHelper.Parse(const Value: string): TImageDetail;
begin
  if not TryToParse(Value, Result) then
    RaiseUnknownEnumValue(Value, 'TImageDetail');
end;

class function TImageDetailHelper.TryToParse(const Value: string; out Detail: TImageDetail): Boolean;
begin
  Result := TEnumWire.TryToParse<TImageDetail>(Value, Detail);
  if not Result then
    Detail := TImageDetail.sdk_unknown;
end;

function TImageDetailHelper.ToString: string;
begin
  Result := TEnumWire.ToString<TImageDetail>(Self);
end;

{ TImageDetailInterceptor }

function TImageDetailInterceptor.StringConverter(Data: TObject; Field: string): string;
begin
  Result := GetMemberValue<TImageDetail>(Data, Field).ToString;
end;

procedure TImageDetailInterceptor.StringReverter(Data: TObject; Field: string; Arg: string);
var
  Detail: TImageDetail;
begin
  TImageDetail.TryToParse(Arg, Detail);
  SetMemberValue<TImageDetail>(Data, Field, Detail);
end;

{ TReasoningEffortHelper }

constructor TReasoningEffortHelper.Create(const Value: string);
begin
  Self := Parse(Value);
end;

class function TReasoningEffortHelper.Parse(const Value: string): TReasoningEffort;
begin
  if not TryToParse(Value, Result) then
    RaiseUnknownEnumValue(Value, 'TReasoningEffort');
end;

class function TReasoningEffortHelper.TryToParse(const Value: string; out Effort: TReasoningEffort): Boolean;
begin
  Result := TEnumWire.TryToParse<TReasoningEffort>(Value, Effort);
  if not Result then
    Effort := TReasoningEffort.sdk_unknown;
end;

function TReasoningEffortHelper.ToString: string;
begin
  Result := TEnumWire.ToString<TReasoningEffort>(Self);
end;

{ TReasoningEffortInterceptor }

function TReasoningEffortInterceptor.StringConverter(Data: TObject; Field: string): string;
begin
  Result := GetMemberValue<TReasoningEffort>(Data, Field).ToString;
end;

procedure TReasoningEffortInterceptor.StringReverter(Data: TObject; Field: string; Arg: string);
var
  Effort: TReasoningEffort;
begin
  TReasoningEffort.TryToParse(Arg, Effort);
  SetMemberValue<TReasoningEffort>(Data, Field, Effort);
end;

{ TModalitiesHelper }

constructor TModalitiesHelper.Create(const Value: string);
begin
  Self := Parse(Value);
end;

class function TModalitiesHelper.Parse(const Value: string): TModalities;
begin
  if not TryToParse(Value, Result) then
    RaiseUnknownEnumValue(Value, 'TModalities');
end;

class function TModalitiesHelper.TryToParse(const Value: string; out Modality: TModalities): Boolean;
begin
  Result := TEnumWire.TryToParse<TModalities>(Value, Modality);
  if not Result then
    Modality := TModalities.sdk_unknown;
end;

function TModalitiesHelper.ToString: string;
begin
  Result := TEnumWire.ToString<TModalities>(Self);
end;

{ TChatVoiceHelper }

constructor TChatVoiceHelper.Create(const Value: string);
begin
  Self := Parse(Value);
end;

class function TChatVoiceHelper.Parse(const Value: string): TChatVoice;
begin
  if not TryToParse(Value, Result) then
    RaiseUnknownEnumValue(Value, 'TChatVoice');
end;

class function TChatVoiceHelper.TryToParse(const Value: string; out Voice: TChatVoice): Boolean;
begin
  Result := TEnumWire.TryToParse<TChatVoice>(Value, Voice);
  if not Result then
    Voice := TChatVoice.sdk_unknown;
end;

function TChatVoiceHelper.ToString: string;
begin
  Result := TEnumWire.ToString<TChatVoice>(Self);
end;

{ TAudioVoiceHelper }

constructor TAudioVoiceHelper.Create(const Value: string);
begin
  Self := Parse(Value);
end;

class function TAudioVoiceHelper.Parse(const Value: string): TAudioVoice;
begin
  if not TryToParse(Value, Result) then
    RaiseUnknownEnumValue(Value, 'TAudioVoice');
end;

class function TAudioVoiceHelper.TryToParse(const Value: string; out Voice: TAudioVoice): Boolean;
begin
  Result := TEnumWire.TryToParse<TAudioVoice>(Value, Voice);
  if not Result then
    Voice := TAudioVoice.sdk_unknown;
end;

function TAudioVoiceHelper.ToString: string;
begin
  Result := TEnumWire.ToString<TAudioVoice>(Self);
end;

{ TSpeechFormatHelper }

constructor TSpeechFormatHelper.Create(const Value: string);
begin
  Self := Parse(Value);
end;

class function TSpeechFormatHelper.Parse(const Value: string): TSpeechFormat;
begin
  if not TryToParse(Value, Result) then
    RaiseUnknownEnumValue(Value, 'TSpeechFormat');
end;

class function TSpeechFormatHelper.TryToParse(const Value: string; out Format: TSpeechFormat): Boolean;
begin
  Result := TEnumWire.TryToParse<TSpeechFormat>(Value, Format);
  if not Result then
    Format := TSpeechFormat.sdk_unknown;
end;

function TSpeechFormatHelper.ToString: string;
begin
  Result := TEnumWire.ToString<TSpeechFormat>(Self);
end;

{ TSpeechStreamFormatHelper }

constructor TSpeechStreamFormatHelper.Create(const Value: string);
begin
  Self := Parse(Value);
end;

class function TSpeechStreamFormatHelper.Parse(
  const Value: string): TSpeechStreamFormat;
begin
  if not TryToParse(Value, Result) then
    RaiseUnknownEnumValue(Value, 'TSpeechStreamFormat');
end;

class function TSpeechStreamFormatHelper.TryToParse(const Value: string;
  out Format: TSpeechStreamFormat): Boolean;
begin
  Result := TEnumWire.TryToParse<TSpeechStreamFormat>(Value, Format);
  if not Result then
    Format := TSpeechStreamFormat.sdk_unknown;
end;

function TSpeechStreamFormatHelper.ToString: string;
begin
  Result := TEnumWire.ToString<TSpeechStreamFormat>(Self);
end;

{ TTranscriptionResponseFormatHelper }

constructor TTranscriptionResponseFormatHelper.Create(const Value: string);
begin
  Self := Parse(Value);
end;

class function TTranscriptionResponseFormatHelper.Parse(const Value: string): TTranscriptionResponseFormat;
begin
  if not TryToParse(Value, Result) then
    RaiseUnknownEnumValue(Value, 'TTranscriptionResponseFormat');
end;

class function TTranscriptionResponseFormatHelper.TryToParse(const Value: string; out Format: TTranscriptionResponseFormat): Boolean;
begin
  Result := TEnumWire.TryToParse<TTranscriptionResponseFormat>(Value, Format);
  if not Result then
    Format := TTranscriptionResponseFormat.sdk_unknown;
end;

function TTranscriptionResponseFormatHelper.ToString: string;
begin
  Result := TEnumWire.ToString<TTranscriptionResponseFormat>(Self);
end;

{ TTranscriptionIncludeHelper }

constructor TTranscriptionIncludeHelper.Create(const Value: string);
begin
  Self := Parse(Value);
end;

class function TTranscriptionIncludeHelper.Parse(
  const Value: string): TTranscriptionInclude;
begin
  if not TryToParse(Value, Result) then
    RaiseUnknownEnumValue(Value, 'TTranscriptionInclude');
end;

class function TTranscriptionIncludeHelper.TryToParse(const Value: string;
  out Include: TTranscriptionInclude): Boolean;
begin
  Result := TEnumWire.TryToParse<TTranscriptionInclude>(Value, Include);
  if not Result then
    Include := TTranscriptionInclude.sdk_unknown;
end;

function TTranscriptionIncludeHelper.ToString: string;
begin
  Result := TEnumWire.ToString<TTranscriptionInclude>(Self);
end;

{ TTimestampGranularityHelper }

constructor TTimestampGranularityHelper.Create(const Value: string);
begin
  Self := Parse(Value);
end;

class function TTimestampGranularityHelper.Parse(
  const Value: string): TTimestampGranularity;
begin
  if not TryToParse(Value, Result) then
    RaiseUnknownEnumValue(Value, 'TTimestampGranularity');
end;

class function TTimestampGranularityHelper.TryToParse(const Value: string;
  out Granularity: TTimestampGranularity): Boolean;
begin
  Result := TEnumWire.TryToParse<TTimestampGranularity>(Value, Granularity);
  if not Result then
    Granularity := TTimestampGranularity.sdk_unknown;
end;

function TTimestampGranularityHelper.ToString: string;
begin
  Result := TEnumWire.ToString<TTimestampGranularity>(Self);
end;

{ TTranscriptionChunkingStrategyTypeHelper }

constructor TTranscriptionChunkingStrategyTypeHelper.Create(
  const Value: string);
begin
  Self := Parse(Value);
end;

class function TTranscriptionChunkingStrategyTypeHelper.Parse(
  const Value: string): TTranscriptionChunkingStrategyType;
begin
  if not TryToParse(Value, Result) then
    RaiseUnknownEnumValue(Value, 'TTranscriptionChunkingStrategyType');
end;

class function TTranscriptionChunkingStrategyTypeHelper.TryToParse(
  const Value: string;
  out ChunkingStrategy: TTranscriptionChunkingStrategyType): Boolean;
begin
  Result := TEnumWire.TryToParse<TTranscriptionChunkingStrategyType>(Value, ChunkingStrategy);
  if not Result then
    ChunkingStrategy := TTranscriptionChunkingStrategyType.sdk_unknown;
end;

function TTranscriptionChunkingStrategyTypeHelper.ToString: string;
begin
  Result := TEnumWire.ToString<TTranscriptionChunkingStrategyType>(Self);
end;

{ TBatchUrlHelper }

constructor TBatchUrlHelper.Create(const Value: string);
begin
  Self := Parse(Value);
end;

class function TBatchUrlHelper.Parse(const Value: string): TBatchUrl;
begin
  if not TryToParse(Value, Result) then
    RaiseUnknownEnumValue(Value, 'TBatchUrl');
end;

class function TBatchUrlHelper.TryToParse(const Value: string; out Url: TBatchUrl): Boolean;
begin
  Result := TEnumWire.TryToParse<TBatchUrl>(Value, Map, Url);
  if not Result then
    Url := TBatchUrl.sdk_unknown;
end;

function TBatchUrlHelper.ToString: string;
begin
  Result := Map[Self];
end;

{ TBatchStatusHelper }

constructor TBatchStatusHelper.Create(const Value: string);
begin
  Self := Parse(Value);
end;

class function TBatchStatusHelper.Parse(const Value: string): TBatchStatus;
begin
  if not TryToParse(Value, Result) then
    RaiseUnknownEnumValue(Value, 'TBatchStatus');
end;

class function TBatchStatusHelper.TryToParse(const Value: string; out Status: TBatchStatus): Boolean;
begin
  Result := TEnumWire.TryToParse<TBatchStatus>(Value, Status);
  if not Result then
    Status := TBatchStatus.sdk_unknown;
end;

function TBatchStatusHelper.ToString: string;
begin
  Result := TEnumWire.ToString<TBatchStatus>(Self);
end;

{ TBatchStatusInterceptor }

function TBatchStatusInterceptor.StringConverter(Data: TObject; Field: string): string;
begin
  Result := GetMemberValue<TBatchStatus>(Data, Field).ToString;
end;

procedure TBatchStatusInterceptor.StringReverter(Data: TObject; Field: string; Arg: string);
var
  Status: TBatchStatus;
begin
  TBatchStatus.TryToParse(Arg, Status);
  SetMemberValue<TBatchStatus>(Data, Field, Status);
end;

{ TEncodingFormatHelper }

constructor TEncodingFormatHelper.Create(const Value: string);
begin
  Self := Parse(Value);
end;

class function TEncodingFormatHelper.Parse(const Value: string): TEncodingFormat;
begin
  if not TryToParse(Value, Result) then
    RaiseUnknownEnumValue(Value, 'TEncodingFormat');
end;

class function TEncodingFormatHelper.TryToParse(const Value: string; out Format: TEncodingFormat): Boolean;
begin
  Result := TEnumWire.TryToParse<TEncodingFormat>(Value, Format);
  if not Result then
    Format := TEncodingFormat.sdk_unknown;
end;

function TEncodingFormatHelper.ToString: string;
begin
  Result := TEnumWire.ToString<TEncodingFormat>(Self);
end;

{ TFilesPurposeHelper }

constructor TFilesPurposeHelper.Create(const Value: string);
begin
  Self := Parse(Value);
end;

class function TFilesPurposeHelper.Parse(const Value: string): TFilesPurpose;
begin
  if not TryToParse(Value, Result) then
    RaiseUnknownEnumValue(Value, 'TFilesPurpose');
end;

class function TFilesPurposeHelper.TryToParse(const Value: string; out Purpose: TFilesPurpose): Boolean;
begin
  Result := TEnumWire.TryToParse<TFilesPurpose>(Value, Map, Purpose);
  if not Result then
    Purpose := TFilesPurpose.sdk_unknown;
end;

function TFilesPurposeHelper.ToString: string;
begin
  Result := Map[Self];
end;

{ TFilesPurposeInterceptor }

function TFilesPurposeInterceptor.StringConverter(Data: TObject; Field: string): string;
begin
  Result := GetMemberValue<TFilesPurpose>(Data, Field).ToString;
end;

procedure TFilesPurposeInterceptor.StringReverter(Data: TObject; Field: string; Arg: string);
var
  Purpose: TFilesPurpose;
begin
  TFilesPurpose.TryToParse(Arg, Purpose);
  SetMemberValue<TFilesPurpose>(Data, Field, Purpose);
end;

{ TChunkingStrategyTypeHelper }

constructor TChunkingStrategyTypeHelper.Create(const Value: string);
begin
  Self := Parse(Value);
end;

class function TChunkingStrategyTypeHelper.Parse(
  const Value: string): TChunkingStrategyType;
begin
  if not TryToParse(Value, Result) then
    RaiseUnknownEnumValue(Value, 'TChunkingStrategyType');
end;

class function TChunkingStrategyTypeHelper.TryToParse(const Value: string;
  out StrategyType: TChunkingStrategyType): Boolean;
begin
  Result := TEnumWire.TryToParse<TChunkingStrategyType>(Value, StrategyType);
  if not Result then
    StrategyType := TChunkingStrategyType.sdk_unknown;
end;

function TChunkingStrategyTypeHelper.ToString: string;
begin
  Result := TEnumWire.ToString<TChunkingStrategyType>(Self);
end;

{ TRunStatusHelper }

constructor TRunStatusHelper.Create(const Value: string);
begin
  Self := Parse(Value);
end;

class function TRunStatusHelper.Parse(const Value: string): TRunStatus;
begin
  if not TryToParse(Value, Result) then
    RaiseUnknownEnumValue(Value, 'TRunStatus');
end;

class function TRunStatusHelper.TryToParse(const Value: string;
  out Status: TRunStatus): Boolean;
begin
  Result := TEnumWire.TryToParse<TRunStatus>(Value, Status);
  if not Result then
    Status := TRunStatus.sdk_unknown;
end;

function TRunStatusHelper.ToString: string;
begin
  Result := TEnumWire.ToString<TRunStatus>(Self);
end;

{ TRunStatusInterceptor }

function TRunStatusInterceptor.StringConverter(Data: TObject; Field: string): string;
begin
  Result := GetMemberValue<TRunStatus>(Data, Field).ToString;
end;

procedure TRunStatusInterceptor.StringReverter(Data: TObject; Field: string; Arg: string);
var
  Status: TRunStatus;
begin
  TRunStatus.TryToParse(Arg, Status);
  SetMemberValue<TRunStatus>(Data, Field, Status);
end;

{ TJobMethodTypeHelper }

constructor TJobMethodTypeHelper.Create(const Value: string);
begin
  Self := Parse(Value);
end;

class function TJobMethodTypeHelper.Parse(const Value: string): TJobMethodType;
begin
  if not TryToParse(Value, Result) then
    RaiseUnknownEnumValue(Value, 'TJobMethodType');
end;

class function TJobMethodTypeHelper.TryToParse(const Value: string; out Method: TJobMethodType): Boolean;
begin
  Result := TEnumWire.TryToParse<TJobMethodType>(Value, Method);
  if not Result then
    Method := TJobMethodType.sdk_unknown;
end;

function TJobMethodTypeHelper.ToString: string;
begin
  Result := TEnumWire.ToString<TJobMethodType>(Self);
end;

{ TJobMethodTypeInterceptor }

function TJobMethodTypeInterceptor.StringConverter(Data: TObject; Field: string): string;
begin
  Result := GetMemberValue<TJobMethodType>(Data, Field).ToString;
end;

procedure TJobMethodTypeInterceptor.StringReverter(Data: TObject; Field: string; Arg: string);
var
  Method: TJobMethodType;
begin
  TJobMethodType.TryToParse(Arg, Method);
  SetMemberValue<TJobMethodType>(Data, Field, Method);
end;

{ TFineTunedStatusHelper }

constructor TFineTunedStatusHelper.Create(const Value: string);
begin
  Self := Parse(Value);
end;

class function TFineTunedStatusHelper.Parse(const Value: string): TFineTunedStatus;
begin
  if not TryToParse(Value, Result) then
    RaiseUnknownEnumValue(Value, 'TFineTunedStatus');
end;

class function TFineTunedStatusHelper.TryToParse(const Value: string; out Status: TFineTunedStatus): Boolean;
begin
  Result := TEnumWire.TryToParse<TFineTunedStatus>(Value, Status);
  if not Result then
    Status := TFineTunedStatus.sdk_unknown;
end;

function TFineTunedStatusHelper.ToString: string;
begin
  Result := TEnumWire.ToString<TFineTunedStatus>(Self);
end;

{ TFineTunedStatusInterceptor }

function TFineTunedStatusInterceptor.StringConverter(Data: TObject; Field: string): string;
begin
  Result := GetMemberValue<TFineTunedStatus>(Data, Field).ToString;
end;

procedure TFineTunedStatusInterceptor.StringReverter(Data: TObject; Field: string; Arg: string);
var
  Status: TFineTunedStatus;
begin
  TFineTunedStatus.TryToParse(Arg, Status);
  SetMemberValue<TFineTunedStatus>(Data, Field, Status);
end;

{ TResponseFormatHelper }

constructor TResponseFormatHelper.Create(const Value: string);
begin
  Self := Parse(Value);
end;

class function TResponseFormatHelper.Parse(const Value: string): TResponseFormat;
begin
  if not TryToParse(Value, Result) then
    RaiseUnknownEnumValue(Value, 'TResponseFormat');
end;

class function TResponseFormatHelper.TryToParse(const Value: string; out Format: TResponseFormat): Boolean;
begin
  Result := TEnumWire.TryToParse<TResponseFormat>(Value, Format);
  if not Result then
    Format := TResponseFormat.sdk_unknown;
end;

function TResponseFormatHelper.ToString: string;
begin
  Result := TEnumWire.ToString<TResponseFormat>(Self);
end;

{ TImageSizeHelper }

constructor TImageSizeHelper.Create(const Value: string);
begin
  Self := Parse(Value);
end;

class function TImageSizeHelper.Parse(const Value: string): TImageSize;
begin
  if not TryToParse(Value, Result) then
    RaiseUnknownEnumValue(Value, 'TImageSize');
end;

class function TImageSizeHelper.TryToParse(const Value: string; out Size: TImageSize): Boolean;
begin
  Result := TEnumWire.TryToParse<TImageSize>(Value, Map, Size);
  if not Result then
    Size := TImageSize.sdk_unknown;
end;

function TImageSizeHelper.ToString: string;
begin
  Result := Map[Self];
end;

{ TImageStyleHelper }

constructor TImageStyleHelper.Create(const Value: string);
begin
  Self := Parse(Value);
end;

class function TImageStyleHelper.Parse(const Value: string): TImageStyle;
begin
  if not TryToParse(Value, Result) then
    RaiseUnknownEnumValue(Value, 'TImageStyle');
end;

class function TImageStyleHelper.TryToParse(const Value: string; out Style: TImageStyle): Boolean;
begin
  Result := TEnumWire.TryToParse<TImageStyle>(Value, Style);
  if not Result then
    Style := TImageStyle.sdk_unknown;
end;

function TImageStyleHelper.ToString: string;
begin
  Result := TEnumWire.ToString<TImageStyle>(Self);
end;

{ TBackGroundTypeHelper }

constructor TBackGroundTypeHelper.Create(const Value: string);
begin
  Self := Parse(Value);
end;

class function TBackGroundTypeHelper.Parse(const Value: string): TBackGroundType;
begin
  if not TryToParse(Value, Result) then
    RaiseUnknownEnumValue(Value, 'TBackGroundType');
end;

class function TBackGroundTypeHelper.TryToParse(const Value: string; out Background: TBackGroundType): Boolean;
begin
  Result := TEnumWire.TryToParse<TBackGroundType>(Value, Background);
  if not Result then
    Background := TBackGroundType.sdk_unknown;
end;

function TBackGroundTypeHelper.ToString: string;
begin
  Result := TEnumWire.ToString<TBackGroundType>(Self);
end;

{ TImageModerationTypeHelper }

constructor TImageModerationTypeHelper.Create(const Value: string);
begin
  Self := Parse(Value);
end;

class function TImageModerationTypeHelper.Parse(const Value: string): TImageModerationType;
begin
  if not TryToParse(Value, Result) then
    RaiseUnknownEnumValue(Value, 'TImageModerationType');
end;

class function TImageModerationTypeHelper.TryToParse(const Value: string; out Moderation: TImageModerationType): Boolean;
begin
  Result := TEnumWire.TryToParse<TImageModerationType>(Value, Moderation);
  if not Result then
    Moderation := TImageModerationType.sdk_unknown;
end;

function TImageModerationTypeHelper.ToString: string;
begin
  Result := TEnumWire.ToString<TImageModerationType>(Self);
end;

{ TOutputFormatTypeHelper }

constructor TOutputFormatTypeHelper.Create(const Value: string);
begin
  Self := Parse(Value);
end;

class function TOutputFormatTypeHelper.Parse(const Value: string): TOutputFormatType;
begin
  if not TryToParse(Value, Result) then
    RaiseUnknownEnumValue(Value, 'TOutputFormatType');
end;

class function TOutputFormatTypeHelper.TryToParse(const Value: string; out Format: TOutputFormatType): Boolean;
begin
  Result := TEnumWire.TryToParse<TOutputFormatType>(Value, Format);
  if not Result then
    Format := TOutputFormatType.sdk_unknown;
end;

function TOutputFormatTypeHelper.ToString: string;
begin
  Result := TEnumWire.ToString<TOutputFormatType>(Self);
end;

{ TImageQualityTypeHelper }

constructor TImageQualityTypeHelper.Create(const Value: string);
begin
  Self := Parse(Value);
end;

class function TImageQualityTypeHelper.Parse(const Value: string): TImageQualityType;
begin
  if not TryToParse(Value, Result) then
    RaiseUnknownEnumValue(Value, 'TImageQualityType');
end;

class function TImageQualityTypeHelper.TryToParse(const Value: string; out Quality: TImageQualityType): Boolean;
begin
  Result := TEnumWire.TryToParse<TImageQualityType>(Value, Quality);
  if not Result then
    Quality := TImageQualityType.sdk_unknown;
end;

function TImageQualityTypeHelper.ToString: string;
begin
  Result := TEnumWire.ToString<TImageQualityType>(Self);
end;

{ TImageInputFidelityHelper }

constructor TImageInputFidelityHelper.Create(const Value: string);
begin
  Self := Parse(Value);
end;

class function TImageInputFidelityHelper.Parse(const Value: string): TImageInputFidelity;
begin
  if not TryToParse(Value, Result) then
    RaiseUnknownEnumValue(Value, 'TImageInputFidelity');
end;

class function TImageInputFidelityHelper.TryToParse(const Value: string; out Fidelity: TImageInputFidelity): Boolean;
begin
  Result := TEnumWire.TryToParse<TImageInputFidelity>(Value, Fidelity);
  if not Result then
    Fidelity := TImageInputFidelity.sdk_unknown;
end;

function TImageInputFidelityHelper.ToString: string;
begin
  Result := TEnumWire.ToString<TImageInputFidelity>(Self);
end;

{ THarmCategoriesHelper }

constructor THarmCategoriesHelper.Create(const Value: string);
begin
  Self := Parse(Value);
end;

class function THarmCategoriesHelper.Parse(const Value: string): THarmCategories;
begin
  if not TryToParse(Value, Result) then
    RaiseUnknownEnumValue(Value, 'THarmCategories');
end;

class function THarmCategoriesHelper.TryToParse(const Value: string; out Category: THarmCategories): Boolean;
begin
  Result := TEnumWire.TryToParse<THarmCategories>(Value, Map, Category);
  if not Result then
    Category := THarmCategories.sdk_unknown;
end;

function THarmCategoriesHelper.ToString: string;
begin
  Result := Map[Self];
end;

{ TToolChoiceHelper }

constructor TToolChoiceHelper.Create(const Value: string);
begin
  Self := Parse(Value);
end;

class function TToolChoiceHelper.Parse(const Value: string): TToolChoice;
begin
  if not TryToParse(Value, Result) then
    RaiseUnknownEnumValue(Value, 'TToolChoice');
end;

class function TToolChoiceHelper.TryToParse(const Value: string; out Choice: TToolChoice): Boolean;
begin
  Result := TEnumWire.TryToParse<TToolChoice>(Value, Choice);
  if not Result then
    Choice := TToolChoice.sdk_unknown;
end;

function TToolChoiceHelper.ToString: string;
begin
  Result := TEnumWire.ToString<TToolChoice>(Self);
end;

{ TFinishReasonHelper }

constructor TFinishReasonHelper.Create(const Value: string);
begin
  Self := Parse(Value);
end;

class function TFinishReasonHelper.Parse(const Value: string): TFinishReason;
begin
  if not TryToParse(Value, Result) then
    RaiseUnknownEnumValue(Value, 'TFinishReason');
end;

class function TFinishReasonHelper.TryToParse(const Value: string; out Reason: TFinishReason): Boolean;
begin
  Result := TEnumWire.TryToParse<TFinishReason>(Value, Reason);
  if not Result then
    Reason := TFinishReason.sdk_unknown;
end;

function TFinishReasonHelper.ToString: string;
begin
  Result := TEnumWire.ToString<TFinishReason>(Self);
end;

{ TFinishReasonInterceptor }

function TFinishReasonInterceptor.StringConverter(Data: TObject; Field: string): string;
begin
  Result := GetMemberValue<TFinishReason>(Data, Field).ToString;
end;

procedure TFinishReasonInterceptor.StringReverter(Data: TObject; Field: string; Arg: string);
var
  Reason: TFinishReason;
begin
  TFinishReason.TryToParse(Arg, Reason);
  SetMemberValue<TFinishReason>(Data, Field, Reason);
end;

{ TToolCallsHelper }

constructor TToolCallsHelper.Create(const Value: string);
begin
  Self := Parse(Value);
end;

class function TToolCallsHelper.Parse(const Value: string): TToolCalls;
begin
  if not TryToParse(Value, Result) then
    RaiseUnknownEnumValue(Value, 'TToolCalls');
end;

class function TToolCallsHelper.TryToParse(const Value: string; out ToolCall: TToolCalls): Boolean;
begin
  Result := TEnumWire.TryToParse<TToolCalls>(Value, Map, ToolCall);
  if not Result then
    ToolCall := TToolCalls.sdk_unknown;
end;

function TToolCallsHelper.ToString: string;
begin
  Result := Map[Self];
end;

{ TToolCallsInterceptor }

function TToolCallsInterceptor.StringConverter(Data: TObject; Field: string): string;
begin
  Result := GetMemberValue<TToolCalls>(Data, Field).ToString;
end;

procedure TToolCallsInterceptor.StringReverter(Data: TObject; Field: string; Arg: string);
var
  ToolCall: TToolCalls;
begin
  TToolCalls.TryToParse(Arg, ToolCall);
  SetMemberValue<TToolCalls>(Data, Field, ToolCall);
end;

{ TSearchWebOptionsHelper }

constructor TSearchWebOptionsHelper.Create(const Value: string);
begin
  Self := Parse(Value);
end;

class function TSearchWebOptionsHelper.Parse(const Value: string): TSearchWebOptions;
begin
  if not TryToParse(Value, Result) then
    RaiseUnknownEnumValue(Value, 'TSearchWebOptions');
end;

class function TSearchWebOptionsHelper.TryToParse(const Value: string; out Option: TSearchWebOptions): Boolean;
begin
  Result := TEnumWire.TryToParse<TSearchWebOptions>(Value, Option);
  if not Result then
    Option := TSearchWebOptions.sdk_unknown;
end;

function TSearchWebOptionsHelper.ToString: string;
begin
  Result := TEnumWire.ToString<TSearchWebOptions>(Self);
end;

{ TVerbosityTypeHelper }

constructor TVerbosityTypeHelper.Create(const Value: string);
begin
  Self := Parse(Value);
end;

class function TVerbosityTypeHelper.Parse(const Value: string): TVerbosityType;
begin
  if not TryToParse(Value, Result) then
    RaiseUnknownEnumValue(Value, 'TVerbosityType');
end;

class function TVerbosityTypeHelper.TryToParse(const Value: string; out Verbosity: TVerbosityType): Boolean;
begin
  Result := TEnumWire.TryToParse<TVerbosityType>(Value, Verbosity);
  if not Result then
    Verbosity := TVerbosityType.sdk_unknown;
end;

function TVerbosityTypeHelper.ToString: string;
begin
  Result := TEnumWire.ToString<TVerbosityType>(Self);
end;

{ TVerbosityTypeInterceptor }

function TVerbosityTypeInterceptor.StringConverter(Data: TObject; Field: string): string;
begin
  Result := GetMemberValue<TVerbosityType>(Data, Field).ToString;
end;

procedure TVerbosityTypeInterceptor.StringReverter(Data: TObject; Field: string; Arg: string);
var
  Verbosity: TVerbosityType;
begin
  TVerbosityType.TryToParse(Arg, Verbosity);
  SetMemberValue<TVerbosityType>(Data, Field, Verbosity);
end;

{ TSchemaTypeHelper }

constructor TSchemaTypeHelper.Create(const Value: string);
begin
  Self := Parse(Value);
end;

class function TSchemaTypeHelper.Parse(const Value: string): TSchemaType;
begin
  if not TryToParse(Value, Result) then
    RaiseUnknownEnumValue(Value, 'TSchemaType');
end;

function TSchemaTypeHelper.ToString: string;
begin
  Result := TEnumWire.ToString<TSchemaType>(Self);
end;

class function TSchemaTypeHelper.TryToParse(const Value: string;
  out SchemaType: TSchemaType): Boolean;
begin
  Result := TEnumWire.TryToParse<TSchemaType>(Value, SchemaType);
  if not Result then
    SchemaType := TSchemaType.sdk_unknown;
end;

{$REGION 'GenAI.Messages'}

{ TMessageStatusHelper }

constructor TMessageStatusHelper.Create(const Value: string);
begin
  Self := Parse(Value);
end;

class function TMessageStatusHelper.Parse(const Value: string): TMessageStatus;
begin
  if not TryToParse(Value, Result) then
    RaiseUnknownEnumValue(Value, 'TMessageStatus');
end;

class function TMessageStatusHelper.TryToParse(const Value: string;
  out EnumValue: TMessageStatus): Boolean;
begin
  Result := TEnumWire.TryToParse<TMessageStatus>(Value, Map, EnumValue);
  if not Result then
    EnumValue := TMessageStatus.sdk_unknown;
end;

function TMessageStatusHelper.ToString: string;
begin
  Result := Map[Self];
end;

{ TMessageStatusInterceptor }

function TMessageStatusInterceptor.StringConverter(Data: TObject; Field: string): string;
begin
  Result := GetMemberValue<TMessageStatus>(Data, Field).ToString;
end;

procedure TMessageStatusInterceptor.StringReverter(Data: TObject; Field: string; Arg: string);
var
  EnumValue: TMessageStatus;
begin
  TMessageStatus.TryToParse(Arg, EnumValue);
  SetMemberValue<TMessageStatus>(Data, Field, EnumValue);
end;

{$ENDREGION}

{$REGION 'GenAI.Responses'}

{ TResponseFormatTypeHelper }

constructor TResponseFormatTypeHelper.Create(const Value: string);
begin
  Self := Parse(Value);
end;

class function TResponseFormatTypeHelper.Parse(const Value: string): TResponseFormatType;
begin
  if not TryToParse(Value, Result) then
    RaiseUnknownEnumValue(Value, 'TResponseFormatType');
end;

class function TResponseFormatTypeHelper.TryToParse(const Value: string;
  out EnumValue: TResponseFormatType): Boolean;
begin
  Result := TEnumWire.TryToParse<TResponseFormatType>(Value, Map, EnumValue);
  if not Result then
    EnumValue := TResponseFormatType.sdk_unknown;
end;

function TResponseFormatTypeHelper.ToString: string;
begin
  Result := Map[Self];
end;

{ TResponseFormatTypeInterceptor }

function TResponseFormatTypeInterceptor.StringConverter(Data: TObject; Field: string): string;
begin
  Result := GetMemberValue<TResponseFormatType>(Data, Field).ToString;
end;

procedure TResponseFormatTypeInterceptor.StringReverter(Data: TObject; Field: string; Arg: string);
var
  EnumValue: TResponseFormatType;
begin
  TResponseFormatType.TryToParse(Arg, EnumValue);
  SetMemberValue<TResponseFormatType>(Data, Field, EnumValue);
end;

{ TOutputIncludingHelper }

constructor TOutputIncludingHelper.Create(const Value: string);
begin
  Self := Parse(Value);
end;

class function TOutputIncludingHelper.Parse(const Value: string): TOutputIncluding;
begin
  if not TryToParse(Value, Result) then
    RaiseUnknownEnumValue(Value, 'TOutputIncluding');
end;

class function TOutputIncludingHelper.TryToParse(const Value: string;
  out EnumValue: TOutputIncluding): Boolean;
begin
  Result := TEnumWire.TryToParse<TOutputIncluding>(Value, Map, EnumValue);
  if not Result then
    EnumValue := TOutputIncluding.sdk_unknown;
end;

function TOutputIncludingHelper.ToString: string;
begin
  Result := Map[Self];
end;

{ TServiceTierHelper }

constructor TServiceTierHelper.Create(const Value: string);
begin
  Self := Parse(Value);
end;

class function TServiceTierHelper.Parse(const Value: string): TServiceTier;
begin
  if not TryToParse(Value, Result) then
    RaiseUnknownEnumValue(Value, 'TServiceTier');
end;

class function TServiceTierHelper.TryToParse(const Value: string; out EnumValue: TServiceTier): Boolean;
begin
  Result := TEnumWire.TryToParse<TServiceTier>(Value, EnumValue);
  if not Result then
    EnumValue := TServiceTier.sdk_unknown;
end;

function TServiceTierHelper.ToString: string;
begin
  Result := TEnumWire.ToString<TServiceTier>(Self);
end;

{ TPromptCacheRetentionHelper }

constructor TPromptCacheRetentionHelper.Create(const Value: string);
begin
  Self := Parse(Value);
end;

class function TPromptCacheRetentionHelper.Parse(const Value: string): TPromptCacheRetention;
begin
  if not TryToParse(Value, Result) then
    RaiseUnknownEnumValue(Value, 'TPromptCacheRetention');
end;

class function TPromptCacheRetentionHelper.TryToParse(const Value: string; out EnumValue: TPromptCacheRetention): Boolean;
begin
  Result := TEnumWire.TryToParse<TPromptCacheRetention>(Value, Map, EnumValue);
  if not Result then
    EnumValue := TPromptCacheRetention.sdk_unknown;
end;

function TPromptCacheRetentionHelper.ToString: string;
begin
  Result := Map[Self];
end;

{ TMCPConnectorTypeHelper }

constructor TMCPConnectorTypeHelper.Create(const Value: string);
begin
  Self := Parse(Value);
end;

class function TMCPConnectorTypeHelper.Parse(const Value: string): TMCPConnectorType;
begin
  if not TryToParse(Value, Result) then
    RaiseUnknownEnumValue(Value, 'TMCPConnectorType');
end;

class function TMCPConnectorTypeHelper.TryToParse(const Value: string; out EnumValue: TMCPConnectorType): Boolean;
begin
  Result := TEnumWire.TryToParse<TMCPConnectorType>(Value, EnumValue);
  if not Result then
    EnumValue := TMCPConnectorType.sdk_unknown;
end;

function TMCPConnectorTypeHelper.ToString: string;
begin
  Result := TEnumWire.ToString<TMCPConnectorType>(Self);
end;

{ TImageGenActionTypeHelper }

constructor TImageGenActionTypeHelper.Create(const Value: string);
begin
  Self := Parse(Value);
end;

class function TImageGenActionTypeHelper.Parse(const Value: string): TImageGenActionType;
begin
  if not TryToParse(Value, Result) then
    RaiseUnknownEnumValue(Value, 'TImageGenActionType');
end;

class function TImageGenActionTypeHelper.TryToParse(const Value: string; out EnumValue: TImageGenActionType): Boolean;
begin
  Result := TEnumWire.TryToParse<TImageGenActionType>(Value, EnumValue);
  if not Result then
    EnumValue := TImageGenActionType.sdk_unknown;
end;

function TImageGenActionTypeHelper.ToString: string;
begin
  Result := TEnumWire.ToString<TImageGenActionType>(Self);
end;

{ TToolSearchExecutionHelper }

constructor TToolSearchExecutionHelper.Create(const Value: string);
begin
  Self := Parse(Value);
end;

class function TToolSearchExecutionHelper.Parse(const Value: string): TToolSearchExecution;
begin
  if not TryToParse(Value, Result) then
    RaiseUnknownEnumValue(Value, 'TToolSearchExecution');
end;

class function TToolSearchExecutionHelper.TryToParse(const Value: string; out EnumValue: TToolSearchExecution): Boolean;
begin
  Result := TEnumWire.TryToParse<TToolSearchExecution>(Value, EnumValue);
  if not Result then
    EnumValue := TToolSearchExecution.sdk_unknown;
end;

function TToolSearchExecutionHelper.ToString: string;
begin
  Result := TEnumWire.ToString<TToolSearchExecution>(Self);
end;

{ TAllowedToolsModeHelper }

constructor TAllowedToolsModeHelper.Create(const Value: string);
begin
  Self := Parse(Value);
end;

class function TAllowedToolsModeHelper.Parse(const Value: string): TAllowedToolsMode;
begin
  if not TryToParse(Value, Result) then
    RaiseUnknownEnumValue(Value, 'TAllowedToolsMode');
end;

class function TAllowedToolsModeHelper.TryToParse(const Value: string; out EnumValue: TAllowedToolsMode): Boolean;
begin
  Result := TEnumWire.TryToParse<TAllowedToolsMode>(Value, EnumValue);
  if not Result then
    EnumValue := TAllowedToolsMode.sdk_unknown;
end;

function TAllowedToolsModeHelper.ToString: string;
begin
  Result := TEnumWire.ToString<TAllowedToolsMode>(Self);
end;

{ TContainerMemoryLimitHelper }

constructor TContainerMemoryLimitHelper.Create(const Value: string);
begin
  Self := Parse(Value);
end;

class function TContainerMemoryLimitHelper.Parse(const Value: string): TContainerMemoryLimit;
begin
  if not TryToParse(Value, Result) then
    RaiseUnknownEnumValue(Value, 'TContainerMemoryLimit');
end;

class function TContainerMemoryLimitHelper.TryToParse(const Value: string; out EnumValue: TContainerMemoryLimit): Boolean;
begin
  Result := TEnumWire.TryToParse<TContainerMemoryLimit>(Value, Map, EnumValue);
  if not Result then
    EnumValue := TContainerMemoryLimit.sdk_unknown;
end;

function TContainerMemoryLimitHelper.ToString: string;
begin
  Result := Map[Self];
end;

{ TReasoningGenerateSummaryHelper }

constructor TReasoningGenerateSummaryHelper.Create(const Value: string);
begin
  Self := Parse(Value);
end;

class function TReasoningGenerateSummaryHelper.Parse(const Value: string): TReasoningGenerateSummary;
begin
  if not TryToParse(Value, Result) then
    RaiseUnknownEnumValue(Value, 'TReasoningGenerateSummary');
end;

class function TReasoningGenerateSummaryHelper.TryToParse(const Value: string;
  out EnumValue: TReasoningGenerateSummary): Boolean;
begin
  Result := TEnumWire.TryToParse<TReasoningGenerateSummary>(Value, Map, EnumValue);
  if not Result then
    EnumValue := TReasoningGenerateSummary.sdk_unknown;
end;

function TReasoningGenerateSummaryHelper.ToString: string;
begin
  Result := Map[Self];
end;

{ TFidelityTypeHelper }

constructor TFidelityTypeHelper.Create(const Value: string);
begin
  Self := Parse(Value);
end;

class function TFidelityTypeHelper.Parse(const Value: string): TFidelityType;
begin
  if not TryToParse(Value, Result) then
    RaiseUnknownEnumValue(Value, 'TFidelityType');
end;

class function TFidelityTypeHelper.TryToParse(const Value: string;
  out EnumValue: TFidelityType): Boolean;
begin
  Result := TEnumWire.TryToParse<TFidelityType>(Value, Map, EnumValue);
  if not Result then
    EnumValue := TFidelityType.sdk_unknown;
end;

function TFidelityTypeHelper.ToString: string;
begin
  Result := Map[Self];
end;

{ TToolParamsFormatTypeHelper }

constructor TToolParamsFormatTypeHelper.Create(const Value: string);
begin
  Self := Parse(Value);
end;

class function TToolParamsFormatTypeHelper.Parse(const Value: string): TToolParamsFormatType;
begin
  if not TryToParse(Value, Result) then
    RaiseUnknownEnumValue(Value, 'TToolParamsFormatType');
end;

class function TToolParamsFormatTypeHelper.TryToParse(const Value: string;
  out EnumValue: TToolParamsFormatType): Boolean;
begin
  Result := TEnumWire.TryToParse<TToolParamsFormatType>(Value, Map, EnumValue);
  if not Result then
    EnumValue := TToolParamsFormatType.sdk_unknown;
end;

function TToolParamsFormatTypeHelper.ToString: string;
begin
  Result := Map[Self];
end;

{ TSyntaxFormatTypeHelper }

constructor TSyntaxFormatTypeHelper.Create(const Value: string);
begin
  Self := Parse(Value);
end;

class function TSyntaxFormatTypeHelper.Parse(const Value: string): TSyntaxFormatType;
begin
  if not TryToParse(Value, Result) then
    RaiseUnknownEnumValue(Value, 'TSyntaxFormatType');
end;

class function TSyntaxFormatTypeHelper.TryToParse(const Value: string;
  out EnumValue: TSyntaxFormatType): Boolean;
begin
  Result := TEnumWire.TryToParse<TSyntaxFormatType>(Value, Map, EnumValue);
  if not Result then
    EnumValue := TSyntaxFormatType.sdk_unknown;
end;

function TSyntaxFormatTypeHelper.ToString: string;
begin
  Result := Map[Self];
end;

{ TInputItemTypeHelper }

constructor TInputItemTypeHelper.Create(const Value: string);
begin
  Self := Parse(Value);
end;

class function TInputItemTypeHelper.Parse(const Value: string): TInputItemType;
begin
  if not TryToParse(Value, Result) then
    RaiseUnknownEnumValue(Value, 'TInputItemType');
end;

class function TInputItemTypeHelper.TryToParse(const Value: string;
  out EnumValue: TInputItemType): Boolean;
begin
  Result := TEnumWire.TryToParse<TInputItemType>(Value, Map, EnumValue);
  if not Result then
    EnumValue := TInputItemType.sdk_unknown;
end;

function TInputItemTypeHelper.ToString: string;
begin
  Result := Map[Self];
end;

{ TFileSearchToolCallTypeHelper }

constructor TFileSearchToolCallTypeHelper.Create(const Value: string);
begin
  Self := Parse(Value);
end;

class function TFileSearchToolCallTypeHelper.Parse(const Value: string): TFileSearchToolCallType;
begin
  if not TryToParse(Value, Result) then
    RaiseUnknownEnumValue(Value, 'TFileSearchToolCallType');
end;

class function TFileSearchToolCallTypeHelper.TryToParse(const Value: string;
  out EnumValue: TFileSearchToolCallType): Boolean;
begin
  Result := TEnumWire.TryToParse<TFileSearchToolCallType>(Value, Map, EnumValue);
  if not Result then
    EnumValue := TFileSearchToolCallType.sdk_unknown;
end;

function TFileSearchToolCallTypeHelper.ToString: string;
begin
  Result := Map[Self];
end;

{ TFileSearchToolCallTypeInterceptor }

function TFileSearchToolCallTypeInterceptor.StringConverter(Data: TObject; Field: string): string;
begin
  Result := GetMemberValue<TFileSearchToolCallType>(Data, Field).ToString;
end;

procedure TFileSearchToolCallTypeInterceptor.StringReverter(Data: TObject; Field: string; Arg: string);
var
  EnumValue: TFileSearchToolCallType;
begin
  TFileSearchToolCallType.TryToParse(Arg, EnumValue);
  SetMemberValue<TFileSearchToolCallType>(Data, Field, EnumValue);
end;

{ TMouseButtonHelper }

constructor TMouseButtonHelper.Create(const Value: string);
begin
  Self := Parse(Value);
end;

class function TMouseButtonHelper.Parse(const Value: string): TMouseButton;
begin
  if not TryToParse(Value, Result) then
    RaiseUnknownEnumValue(Value, 'TMouseButton');
end;

class function TMouseButtonHelper.TryToParse(const Value: string;
  out EnumValue: TMouseButton): Boolean;
begin
  Result := TEnumWire.TryToParse<TMouseButton>(Value, Map, EnumValue);
  if not Result then
    EnumValue := TMouseButton.sdk_unknown;
end;

function TMouseButtonHelper.ToString: string;
begin
  Result := Map[Self];
end;

{ TMouseButtonInterceptor }

function TMouseButtonInterceptor.StringConverter(Data: TObject; Field: string): string;
begin
  Result := GetMemberValue<TMouseButton>(Data, Field).ToString;
end;

procedure TMouseButtonInterceptor.StringReverter(Data: TObject; Field: string; Arg: string);
var
  EnumValue: TMouseButton;
begin
  TMouseButton.TryToParse(Arg, EnumValue);
  SetMemberValue<TMouseButton>(Data, Field, EnumValue);
end;

{ TResponseOptionHelper }

constructor TResponseOptionHelper.Create(const Value: string);
begin
  Self := Parse(Value);
end;

class function TResponseOptionHelper.Parse(const Value: string): TResponseOption;
begin
  if not TryToParse(Value, Result) then
    RaiseUnknownEnumValue(Value, 'TResponseOption');
end;

class function TResponseOptionHelper.TryToParse(const Value: string;
  out EnumValue: TResponseOption): Boolean;
begin
  Result := TEnumWire.TryToParse<TResponseOption>(Value, Map, EnumValue);
  if not Result then
    EnumValue := TResponseOption.sdk_unknown;
end;

function TResponseOptionHelper.ToString: string;
begin
  Result := Map[Self];
end;

{ THostedTooltypeHelper }

constructor THostedTooltypeHelper.Create(const Value: string);
begin
  Self := Parse(Value);
end;

class function THostedTooltypeHelper.Parse(const Value: string): THostedTooltype;
begin
  if not TryToParse(Value, Result) then
    RaiseUnknownEnumValue(Value, 'THostedTooltype');
end;

class function THostedTooltypeHelper.TryToParse(const Value: string;
  out EnumValue: THostedTooltype): Boolean;
begin
  Result := TEnumWire.TryToParse<THostedTooltype>(Value, Map, EnumValue);
  if not Result then
    EnumValue := THostedTooltype.sdk_unknown;
end;

function THostedTooltypeHelper.ToString: string;
begin
  Result := Map[Self];
end;

{ TComparisonFilterTypeHelper }

constructor TComparisonFilterTypeHelper.Create(const Value: string);
begin
  Self := Parse(Value);
end;

class function TComparisonFilterTypeHelper.Parse(const Value: string): TComparisonFilterType;
begin
  if not TryToParse(Value, Result) then
    RaiseUnknownEnumValue(Value, 'TComparisonFilterType');
end;

class function TComparisonFilterTypeHelper.TryToParse(const Value: string;
  out EnumValue: TComparisonFilterType): Boolean;
begin
  Result := TEnumWire.TryToParse<TComparisonFilterType>(Value, Map, EnumValue);
  if not Result then
    EnumValue := TComparisonFilterType.sdk_unknown;
end;

class function TComparisonFilterTypeHelper.ToOperator(
  const Value: string): TComparisonFilterType;
begin
  Result := Parse(Value);
end;

function TComparisonFilterTypeHelper.ToString: string;
begin
  Result := Map[Self];
end;

{ TCompoundFilterTypeHelper }

constructor TCompoundFilterTypeHelper.Create(const Value: string);
begin
  Self := Parse(Value);
end;

class function TCompoundFilterTypeHelper.Parse(const Value: string): TCompoundFilterType;
begin
  if not TryToParse(Value, Result) then
    RaiseUnknownEnumValue(Value, 'TCompoundFilterType');
end;

class function TCompoundFilterTypeHelper.TryToParse(const Value: string;
  out EnumValue: TCompoundFilterType): Boolean;
begin
  Result := TEnumWire.TryToParse<TCompoundFilterType>(Value, Map, EnumValue);
  if not Result then
    EnumValue := TCompoundFilterType.sdk_unknown;
end;

function TCompoundFilterTypeHelper.ToString: string;
begin
  Result := Map[Self];
end;

{ TWebSearchTypeHelper }

constructor TWebSearchTypeHelper.Create(const Value: string);
begin
  Self := Parse(Value);
end;

class function TWebSearchTypeHelper.Parse(const Value: string): TWebSearchType;
begin
  if not TryToParse(Value, Result) then
    RaiseUnknownEnumValue(Value, 'TWebSearchType');
end;

class function TWebSearchTypeHelper.TryToParse(const Value: string;
  out EnumValue: TWebSearchType): Boolean;
begin
  Result := TEnumWire.TryToParse<TWebSearchType>(Value, Map, EnumValue);
  if not Result then
    EnumValue := TWebSearchType.sdk_unknown;
end;

function TWebSearchTypeHelper.ToString: string;
begin
  Result := Map[Self];
end;

{ TWebSearchPreviewTypeHelper }

constructor TWebSearchPreviewTypeHelper.Create(const Value: string);
begin
  Self := Parse(Value);
end;

class function TWebSearchPreviewTypeHelper.Parse(const Value: string): TWebSearchPreviewType;
begin
  if not TryToParse(Value, Result) then
    RaiseUnknownEnumValue(Value, 'TWebSearchPreviewType');
end;

class function TWebSearchPreviewTypeHelper.TryToParse(const Value: string;
  out EnumValue: TWebSearchPreviewType): Boolean;
begin
  Result := TEnumWire.TryToParse<TWebSearchPreviewType>(Value, Map, EnumValue);
  if not Result then
    EnumValue := TWebSearchPreviewType.sdk_unknown;
end;

function TWebSearchPreviewTypeHelper.ToString: string;
begin
  Result := Map[Self];
end;

{ TResponseTruncationTypeHelper }

constructor TResponseTruncationTypeHelper.Create(const Value: string);
begin
  Self := Parse(Value);
end;

class function TResponseTruncationTypeHelper.Parse(const Value: string): TResponseTruncationType;
begin
  if not TryToParse(Value, Result) then
    RaiseUnknownEnumValue(Value, 'TResponseTruncationType');
end;

class function TResponseTruncationTypeHelper.TryToParse(const Value: string;
  out EnumValue: TResponseTruncationType): Boolean;
begin
  Result := TEnumWire.TryToParse<TResponseTruncationType>(Value, Map, EnumValue);
  if not Result then
    EnumValue := TResponseTruncationType.sdk_unknown;
end;

function TResponseTruncationTypeHelper.ToString: string;
begin
  Result := Map[Self];
end;

{ TResponseTypesHelper }

constructor TResponseTypesHelper.Create(const Value: string);
begin
  Self := Parse(Value);
end;

class function TResponseTypesHelper.Parse(const Value: string): TResponseTypes;
begin
  if not TryToParse(Value, Result) then
    RaiseUnknownEnumValue(Value, 'TResponseTypes');
end;

class function TResponseTypesHelper.TryToParse(const Value: string;
  out EnumValue: TResponseTypes): Boolean;
begin
  Result := TEnumWire.TryToParse<TResponseTypes>(Value, Map, EnumValue);
  if not Result then
    EnumValue := TResponseTypes.sdk_unknown;
end;

function TResponseTypesHelper.ToString: string;
begin
  Result := Map[Self];
end;

{ TResponseTypesInterceptor }

function TResponseTypesInterceptor.StringConverter(Data: TObject; Field: string): string;
begin
  Result := GetMemberValue<TResponseTypes>(Data, Field).ToString;
end;

procedure TResponseTypesInterceptor.StringReverter(Data: TObject; Field: string; Arg: string);
var
  EnumValue: TResponseTypes;
begin
  TResponseTypes.TryToParse(Arg, EnumValue);
  SetMemberValue<TResponseTypes>(Data, Field, EnumValue);
end;

{ TResponseContentTypeHelper }

constructor TResponseContentTypeHelper.Create(const Value: string);
begin
  Self := Parse(Value);
end;

class function TResponseContentTypeHelper.Parse(const Value: string): TResponseContentType;
begin
  if not TryToParse(Value, Result) then
    RaiseUnknownEnumValue(Value, 'TResponseContentType');
end;

class function TResponseContentTypeHelper.TryToParse(const Value: string;
  out EnumValue: TResponseContentType): Boolean;
begin
  Result := TEnumWire.TryToParse<TResponseContentType>(Value, Map, EnumValue);
  if not Result then
    EnumValue := TResponseContentType.sdk_unknown;
end;

function TResponseContentTypeHelper.ToString: string;
begin
  Result := Map[Self];
end;

{ TResponseContentTypeInterceptor }

function TResponseContentTypeInterceptor.StringConverter(Data: TObject; Field: string): string;
begin
  Result := GetMemberValue<TResponseContentType>(Data, Field).ToString;
end;

procedure TResponseContentTypeInterceptor.StringReverter(Data: TObject; Field: string; Arg: string);
var
  EnumValue: TResponseContentType;
begin
  TResponseContentType.TryToParse(Arg, EnumValue);
  SetMemberValue<TResponseContentType>(Data, Field, EnumValue);
end;

{ TResponseAnnotationTypeHelper }

constructor TResponseAnnotationTypeHelper.Create(const Value: string);
begin
  Self := Parse(Value);
end;

class function TResponseAnnotationTypeHelper.Parse(const Value: string): TResponseAnnotationType;
begin
  if not TryToParse(Value, Result) then
    RaiseUnknownEnumValue(Value, 'TResponseAnnotationType');
end;

class function TResponseAnnotationTypeHelper.TryToParse(const Value: string;
  out EnumValue: TResponseAnnotationType): Boolean;
begin
  Result := TEnumWire.TryToParse<TResponseAnnotationType>(Value, Map, EnumValue);
  if not Result then
    EnumValue := TResponseAnnotationType.sdk_unknown;
end;

function TResponseAnnotationTypeHelper.ToString: string;
begin
  Result := Map[Self];
end;

{ TResponseAnnotationTypeInterceptor }

function TResponseAnnotationTypeInterceptor.StringConverter(Data: TObject; Field: string): string;
begin
  Result := GetMemberValue<TResponseAnnotationType>(Data, Field).ToString;
end;

procedure TResponseAnnotationTypeInterceptor.StringReverter(Data: TObject; Field: string; Arg: string);
var
  EnumValue: TResponseAnnotationType;
begin
  TResponseAnnotationType.TryToParse(Arg, EnumValue);
  SetMemberValue<TResponseAnnotationType>(Data, Field, EnumValue);
end;

{ TResponseComputerTypeHelper }

constructor TResponseComputerTypeHelper.Create(const Value: string);
begin
  Self := Parse(Value);
end;

class function TResponseComputerTypeHelper.Parse(const Value: string): TResponseComputerType;
begin
  if not TryToParse(Value, Result) then
    RaiseUnknownEnumValue(Value, 'TResponseComputerType');
end;

class function TResponseComputerTypeHelper.TryToParse(const Value: string;
  out EnumValue: TResponseComputerType): Boolean;
begin
  Result := TEnumWire.TryToParse<TResponseComputerType>(Value, Map, EnumValue);
  if not Result then
    EnumValue := TResponseComputerType.sdk_unknown;
end;

function TResponseComputerTypeHelper.ToString: string;
begin
  Result := Map[Self];
end;

{ TResponseComputerTypeInterceptor }

function TResponseComputerTypeInterceptor.StringConverter(Data: TObject; Field: string): string;
begin
  Result := GetMemberValue<TResponseComputerType>(Data, Field).ToString;
end;

procedure TResponseComputerTypeInterceptor.StringReverter(Data: TObject; Field: string; Arg: string);
var
  EnumValue: TResponseComputerType;
begin
  TResponseComputerType.TryToParse(Arg, EnumValue);
  SetMemberValue<TResponseComputerType>(Data, Field, EnumValue);
end;

{ TResponseStatusHelper }

constructor TResponseStatusHelper.Create(const Value: string);
begin
  Self := Parse(Value);
end;

class function TResponseStatusHelper.Parse(const Value: string): TResponseStatus;
begin
  if not TryToParse(Value, Result) then
    RaiseUnknownEnumValue(Value, 'TResponseStatus');
end;

class function TResponseStatusHelper.TryToParse(const Value: string;
  out EnumValue: TResponseStatus): Boolean;
begin
  Result := TEnumWire.TryToParse<TResponseStatus>(Value, Map, EnumValue);
  if not Result then
    EnumValue := TResponseStatus.sdk_unknown;
end;

function TResponseStatusHelper.ToString: string;
begin
  Result := Map[Self];
end;

{ TResponseStatusInterceptor }

function TResponseStatusInterceptor.StringConverter(Data: TObject; Field: string): string;
begin
  Result := GetMemberValue<TResponseStatus>(Data, Field).ToString;
end;

procedure TResponseStatusInterceptor.StringReverter(Data: TObject; Field: string; Arg: string);
var
  EnumValue: TResponseStatus;
begin
  TResponseStatus.TryToParse(Arg, EnumValue);
  SetMemberValue<TResponseStatus>(Data, Field, EnumValue);
end;

{ TResponseToolsTypeHelper }

constructor TResponseToolsTypeHelper.Create(const Value: string);
begin
  Self := Parse(Value);
end;

class function TResponseToolsTypeHelper.Parse(const Value: string): TResponseToolsType;
begin
  if not TryToParse(Value, Result) then
    RaiseUnknownEnumValue(Value, 'TResponseToolsType');
end;

class function TResponseToolsTypeHelper.TryToParse(const Value: string;
  out EnumValue: TResponseToolsType): Boolean;
begin
  Result := TEnumWire.TryToParse<TResponseToolsType>(Value, Map, EnumValue);
  if not Result then
    EnumValue := TResponseToolsType.sdk_unknown;
end;

function TResponseToolsTypeHelper.ToString: string;
begin
  Result := Map[Self];
end;

{ TResponseToolsTypeInterceptor }

function TResponseToolsTypeInterceptor.StringConverter(Data: TObject; Field: string): string;
begin
  Result := GetMemberValue<TResponseToolsType>(Data, Field).ToString;
end;

procedure TResponseToolsTypeInterceptor.StringReverter(Data: TObject; Field: string; Arg: string);
var
  EnumValue: TResponseToolsType;
begin
  TResponseToolsType.TryToParse(Arg, EnumValue);
  SetMemberValue<TResponseToolsType>(Data, Field, EnumValue);
end;

{ TResponseToolsFilterTypeHelper }

constructor TResponseToolsFilterTypeHelper.Create(const Value: string);
begin
  Self := Parse(Value);
end;

class function TResponseToolsFilterTypeHelper.Parse(const Value: string): TResponseToolsFilterType;
begin
  if not TryToParse(Value, Result) then
    RaiseUnknownEnumValue(Value, 'TResponseToolsFilterType');
end;

class function TResponseToolsFilterTypeHelper.TryToParse(const Value: string;
  out EnumValue: TResponseToolsFilterType): Boolean;
begin
  Result := TEnumWire.TryToParse<TResponseToolsFilterType>(Value, Map, EnumValue);
  if not Result then
    EnumValue := TResponseToolsFilterType.sdk_unknown;
end;

function TResponseToolsFilterTypeHelper.ToString: string;
begin
  Result := Map[Self];
end;

{ TResponseToolsFilterTypeInterceptor }

function TResponseToolsFilterTypeInterceptor.StringConverter(Data: TObject; Field: string): string;
begin
  Result := GetMemberValue<TResponseToolsFilterType>(Data, Field).ToString;
end;

procedure TResponseToolsFilterTypeInterceptor.StringReverter(Data: TObject; Field: string; Arg: string);
var
  EnumValue: TResponseToolsFilterType;
begin
  TResponseToolsFilterType.TryToParse(Arg, EnumValue);
  SetMemberValue<TResponseToolsFilterType>(Data, Field, EnumValue);
end;

{ TResponseItemContentTypeHelper }

constructor TResponseItemContentTypeHelper.Create(const Value: string);
begin
  Self := Parse(Value);
end;

class function TResponseItemContentTypeHelper.Parse(const Value: string): TResponseItemContentType;
begin
  if not TryToParse(Value, Result) then
    RaiseUnknownEnumValue(Value, 'TResponseItemContentType');
end;

class function TResponseItemContentTypeHelper.TryToParse(const Value: string;
  out EnumValue: TResponseItemContentType): Boolean;
begin
  Result := TEnumWire.TryToParse<TResponseItemContentType>(Value, Map, EnumValue);
  if not Result then
    EnumValue := TResponseItemContentType.sdk_unknown;
end;

function TResponseItemContentTypeHelper.ToString: string;
begin
  Result := Map[Self];
end;

{ TResponseItemContentTypeInterceptor }

function TResponseItemContentTypeInterceptor.StringConverter(Data: TObject; Field: string): string;
begin
  Result := GetMemberValue<TResponseItemContentType>(Data, Field).ToString;
end;

procedure TResponseItemContentTypeInterceptor.StringReverter(Data: TObject; Field: string; Arg: string);
var
  EnumValue: TResponseItemContentType;
begin
  TResponseItemContentType.TryToParse(Arg, EnumValue);
  SetMemberValue<TResponseItemContentType>(Data, Field, EnumValue);
end;

{ TResponseStreamTypeHelper }

constructor TResponseStreamTypeHelper.Create(const Value: string);
begin
  Self := Parse(Value);
end;

class function TResponseStreamTypeHelper.Parse(const Value: string): TResponseStreamType;
begin
  if not TryToParse(Value, Result) then
    RaiseUnknownEnumValue(Value, 'TResponseStreamType');
end;

class function TResponseStreamTypeHelper.TryToParse(const Value: string;
  out EnumValue: TResponseStreamType): Boolean;
begin
  Result := TEnumWire.TryToParse<TResponseStreamType>(Value, Map, EnumValue);
  if not Result then
    EnumValue := TResponseStreamType.sdk_unknown;
end;

function TResponseStreamTypeHelper.ToString: string;
begin
  Result := Map[Self];
end;

{ TResponseStreamTypeInterceptor }

function TResponseStreamTypeInterceptor.StringConverter(Data: TObject; Field: string): string;
begin
  Result := GetMemberValue<TResponseStreamType>(Data, Field).ToString;
end;

procedure TResponseStreamTypeInterceptor.StringReverter(Data: TObject; Field: string; Arg: string);
var
  EnumValue: TResponseStreamType;
begin
  TResponseStreamType.TryToParse(Arg, EnumValue);
  SetMemberValue<TResponseStreamType>(Data, Field, EnumValue);
end;

{$ENDREGION}

{ TThinkingLevelTypeHelper }

constructor TThinkingLevelTypeHelper.Create(const Value: string);
begin
  Self := Parse(Value);
end;

class function TThinkingLevelTypeHelper.Parse(
  const Value: string): TThinkingLevelType;
begin
  if not TryToParse(Value, Result) then
    RaiseUnknownEnumValue(Value, 'TThinkingLevelType');
end;

function TThinkingLevelTypeHelper.ToString: string;
begin
  Result := TEnumWire.ToString<TThinkingLevelType>(Self);
end;

class function TThinkingLevelTypeHelper.TryToParse(const Value: string;
  out ThinkingLevelType: TThinkingLevelType): Boolean;
begin
  Result := TEnumWire.TryToParse<TThinkingLevelType>(Value, ThinkingLevelType);
  if not Result then
    ThinkingLevelType := TThinkingLevelType.sdk_unknown;
end;












{ TIncludeObfuscation }

function TIncludeObfuscation.IncludeObfuscation(
  const Value: Boolean): TIncludeObfuscation;
begin
  Result := TIncludeObfuscation(Add('include_obfuscation', Value));
end;

class function TIncludeObfuscation.New(
  const Value: Boolean): TIncludeObfuscation;
begin
  Result := TIncludeObfuscation.Create.IncludeObfuscation(Value);
end;

{ TIncludeUsage }

function TIncludeUsage.IncludeUsage: TIncludeUsage;
begin
  Result := TIncludeUsage(Add('include_usage', True));
end;

class function TIncludeUsage.New: TIncludeUsage;
begin
  Result := TIncludeUsage.Create.IncludeUsage;
end;

{ TMetadataInterceptor }

procedure TMetadataInterceptor.StringReverter(Data: TObject; Field,
  Arg: string);
begin
  SetMemberValue<string>(Data, Field, TJsonPolyUnshield.Restore(Arg));
end;

end.

