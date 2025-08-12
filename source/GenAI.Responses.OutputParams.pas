unit GenAI.Responses.OutputParams;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGenAI
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.SysUtils, System.Classes, System.JSON, REST.Json.Types,
  REST.JsonReflect, REST.Json,
  GenAI.API.Params, GenAI.API, GenAI.Consts, GenAI.Schema, GenAI.Types,
  GenAI.Async.Params, GenAI.Async.Support, GenAI.Functions.Core,
  GenAI.Responses.InputParams, GenAI.Responses.InputItemList,
  GenAI.Responses.ImageHelper;

type
  TTopLogProb = class
  private
    FBytes   : TArray<double>;
    FLogprob : Double;
    FToken   : string;
  public
    property Bytes: TArray<double> read FBytes write FBytes;
    property Logprob: Double read FLogprob write FLogprob;
    property Token: string read FToken write FToken;
  end;

  TLogProb = class
  private
    FBytes       : TArray<double>;
    FLogprob     : Double;
    FToken       : string;
    [JsonNameAttribute('top_logprobs')]
    FTopLogprobs : TArray<TTopLogProb>;
  public
    property Bytes: TArray<double> read FBytes write FBytes;
    property Logprob: Double read FLogprob write FLogprob;
    property Token: string read FToken write FToken;
    property TopLogprobs: TArray<TTopLogProb> read FTopLogprobs write FTopLogprobs;
    destructor Destroy; override;
  end;

  TResponseError = class
  private
    FCode    : string;
    FMessage : string;
  public
    /// <summary>
    /// The error code for the response.
    /// </summary>
    property Code: string read FCode write FCode;

    /// <summary>
    /// A human-readable description of the error.
    /// </summary>
    property Message: string read FMessage write FMessage;
  end;

  TResponseIncompleteDetails = class
  private
    FReason : string;
  public
    /// <summary>
    /// The reason why the response is incomplete.
    /// </summary>
    property Reason: string read FReason write FReason;
  end;

  TResponseMessageContentCommon = class
  private
    [JsonReflectAttribute(ctString, rtString, TResponseContentTypeInterceptor)]
    FType : TResponseContentType;
  public
    /// <summary>
    /// The type of the output text. One of output_text or refusal
    /// </summary>
    property &Type: TResponseContentType read FType write FType;
  end;

  TResponseMessageContent = class(TResponseMessageContentCommon)
  private
    FAnnotations : TArray<TResponseMessageAnnotation>;
    FText        : string;
    FLogprobs: TArray<TLogProb>;
  public
    /// <summary>
    /// The annotations of the text output.
    /// </summary>
    property Annotations: TArray<TResponseMessageAnnotation> read FAnnotations write FAnnotations;

    /// <summary>
    /// The text output from the model.
    /// </summary>
    property Text: string read FText write FText;

    /// <summary>
    /// The log probabilities of the tokens in the delta.
    /// </summary>
    property Logprobs: TArray<TLogProb> read FLogprobs write FLogprobs;

    destructor Destroy; override;
  end;

  TResponseMessageRefusal = class(TResponseMessageContent)
  private
    FRefusal : string;
  public
    /// <summary>
    /// The refusal explanationfrom the model.
    /// </summary>
    property Refusal: string read FRefusal write FRefusal;
  end;

  {$REGION 'Dev note'}
  {--- This class is made up of the following classes:
     TResponseMessageContentCommon,
     TResponseMessageContent,
     TResponseMessageRefusal }
  {$ENDREGION}
  TResponseContent = class(TResponseMessageRefusal);

  TResponseReasoningSummary = class
  private
    FText : string;
    FType : string;
  public
    /// <summary>
    /// A short summary of the reasoning used by the model when generating the response.
    /// </summary>
    property Text: string read FText write FText;

    /// <summary>
    /// The type of the object. Always summary_text.
    /// </summary>
    property &Type: string read FType write FType;
  end;

  TResponseReasoning = class
  private
    [JsonReflectAttribute(ctString, rtString, TReasoningEffortInterceptor)]
    FEffort  : TReasoningEffort;
    FSummary : string;
  public
    /// <summary>
    /// o-series models only
    /// </summary>
    /// <remarks>
    /// Constrains effort on reasoning for reasoning models. Currently supported values are low, medium, and high.
    /// Reducing reasoning effort can result in faster responses and fewer tokens used on reasoning in a response.
    /// </remarks>
    property Effort: TReasoningEffort read FEffort write FEffort;

    /// <summary>
    /// A summary of the reasoning performed by the model. This can be useful for debugging and understanding
    /// the model's reasoning process. One of auto, concise, or detailed.
    /// </summary>
    property Summary: string read FSummary write FSummary;
  end;

  TResponseRankingOptions = class
  private
    [JsonNameAttribute('score_threshold')]
    FScoreThreshold : Double;
    FRanker         : string;
  public
    /// <summary>
    /// The ranker to use for the file search.
    /// </summary>
    property Ranker: string read FRanker write FRanker;

    /// <summary>
    /// The score threshold for the file search, a number between 0 and 1. Numbers closer to 1 will attempt to return
    /// only the most relevant results, but may return fewer results.
    /// </summary>
    property ScoreThreshold: Double read FScoreThreshold write FScoreThreshold;
  end;

  TResponseFileSearchFiltersCommon = class
  private
    [JsonReflectAttribute(ctString, rtString, TResponseToolsFilterTypeInterceptor)]
    FType : TResponseToolsFilterType;
  public
    /// <summary>
    /// Specifies the comparison operator or the type of operation
    /// </summary>
    property &Type: TResponseToolsFilterType read FType write FType;
  end;

  TResponseFileSearchFiltersComparaison = class(TResponseFileSearchFiltersCommon)
  private
    FKey   : string;
    FValue : Variant;
  public
    /// <summary>
    /// The key to compare against the value.
    /// </summary>
    property Key: string read FKey write FKey;

    /// <summary>
    /// The value to compare against the attribute key; supports string, number, or boolean types.
    /// </summary>
    property Value: Variant read FValue write FValue;
  end;

  TResponseFileSearchFiltersCompound = class(TResponseFileSearchFiltersComparaison)
  private
    FFilters : TArray<TResponseFileSearchFiltersCompound>;
  public
    /// <summary>
    /// Array of filters to combine. Items can be ComparisonFilter or CompoundFilter.
    /// </summary>
    property Filters: TArray<TResponseFileSearchFiltersCompound> read FFilters write FFilters;

    destructor Destroy; override;
  end;

  {$REGION 'Dev note'}
  {--- This class is made up of the following classes:
    TResponseFileSearchFiltersCommon,
    TResponseFileSearchFiltersComparaison,
    TResponseFileSearchFiltersCompound }
  {$ENDREGION}
  TResponseFileSearchFilters = class(TResponseFileSearchFiltersCompound);

  TResponseWebSearchLocation = class
  private
    FType     : string;
    FCity     : string;
    FCountry  : string;
    FRegion   : string;
    FTimezone : string;
  public
    /// <summary>
    /// The type of location approximation. Always approximate.
    /// </summary>
    property &Type: string read FType write FType;

    /// <summary>
    /// Free text input for the city of the user, e.g. San Francisco.
    /// </summary>
    property City: string read FCity write FCity;

    /// <summary>
    /// The two-letter ISO country code of the user, e.g. US. https://en.wikipedia.org/wiki/ISO_3166-1
    /// </summary>
    property Country: string read FCountry write FCountry;

    /// <summary>
    /// Free text input for the region of the user, e.g. California.
    /// </summary>
    property Region: string read FRegion write FRegion;

    /// <summary>
    /// The IANA timezone of the user, e.g. America/Los_Angeles. https://timeapi.io/documentation/iana-timezones
    /// </summary>
    property Timezone: string read FTimezone write FTimezone;
  end;

  {$REGION 'Dev note'}
(******************************************************************************

  TResponseOutput :
  ================

  To enable optimal automatic deserialization, you need to set up a hierarchy
  of successive classes. However, this does make the code heavier if you want
  to maintain the wrapper’s overall architectural principles.

*******************************************************************************)
  {$ENDREGION}

  TResponseOutputCommon = class
  private
    [JsonReflectAttribute(ctString, rtString, TResponseTypesInterceptor)]
    FType   : TResponseTypes;
    FId     : string;
    FStatus : string;
  public
    /// <summary>
    /// The unique ID of the output message.
    /// </summary>
    property Id: string read FId write FId;

    /// <summary>
    /// The status of the message. One of in_progress, completed, incomplete (or failed)
    /// </summary>
    property Status: string read FStatus write FStatus;

    /// <summary>
    /// The type of the output message
    /// </summary>
    property &Type: TResponseTypes read FType write FType;
  end;

  TResponseOutputMessage = class(TResponseOutputCommon)
  private
    [JsonReflectAttribute(ctString, rtString, TRoleInterceptor)]
    FRole    : TRole;
    FContent : TArray<TResponseContent>;
  public
    /// <summary>
    /// The content of the output message.
    /// </summary>
    property Content: TArray<TResponseContent> read FContent write FContent;

    /// <summary>
    /// The role of the output message. Always assistant.
    /// </summary>
    property Role: TRole read FRole write FRole;

    destructor Destroy; override;
  end;

  TResponseOutputFileSearch = class(TResponseOutputMessage)
  private
    FQueries : TArray<string>;
    FResults : TArray<TFileSearchResult>;
  public
    /// <summary>
    /// The queries used to search for files.
    /// </summary>
    property Queries: TArray<string> read FQueries write FQueries;

    /// <summary>
    /// The results of the file search tool call.
    /// </summary>
    property Results: TArray<TFileSearchResult> read FResults write FResults;

    destructor Destroy; override;
  end;

  TResponseOutputFunction = class(TResponseOutputFileSearch)
  private
    [JsonNameAttribute('call_id')]
    FCallId    : string;
    FArguments : string;
    FName      : string;
  public
    /// <summary>
    /// A JSON string of the arguments to pass to the function.
    /// </summary>
    property Arguments: string read FArguments write FArguments;

    /// <summary>
    /// The unique ID of the function tool call generated by the model.
    /// </summary>
    property CallId: string read FCallId write FCallId;

    /// <summary>
    /// The name of the function to run.
    /// </summary>
    property Name: string read FName write FName;
  end;

  TResponseOutputWebSearch = class(TResponseOutputFunction)
  private
    FAction : TAction;
  public
    /// <summary>
    /// Action to execute on computer
    /// </summary>
    property Action: TAction read FAction write FAction;

    destructor Destroy; override;
  end;

  TResponseOutputComputer = class(TResponseOutputWebSearch)
  private
    [JsonNameAttribute('pending_safety_checks')]
    FPendingSafetyChecks : TArray<TPendingSafetyChecks>;
  public
    /// <summary>
    /// The pending safety checks for the computer call.
    /// </summary>
    property PendingSafetyChecks: TArray<TPendingSafetyChecks> read FPendingSafetyChecks write FPendingSafetyChecks;

    destructor Destroy; override;
  end;

  TResponseOutputReasoning = class(TResponseOutputComputer)
  private
    [JsonNameAttribute('encrypted_content')]
    FEncryptedContent : string;
    FSummary          : TArray<TResponseReasoningSummary>;
  public
    /// <summary>
    /// Reasoning text contents.
    /// </summary>
    property Summary: TArray<TResponseReasoningSummary> read FSummary write FSummary;

    /// <summary>
    /// The encrypted content of the reasoning item - populated when a response is generated with
    /// reasoning.encrypted_content in the include parameter.
    /// </summary>
    property EncryptedContent: string read FEncryptedContent write FEncryptedContent;

    destructor Destroy; override;
  end;

  TResponseOutputImageGeneration = class(TResponseOutputReasoning)
  private
    FResult : string;
  public
    function GetStream: TStream;

    procedure SaveToFile(const FileName: string);

    /// <summary>
    /// The generated image encoded in base64.
    /// </summary>
    property Result: string read FResult write FResult;
  end;

  TResponseCodeInterpreterOutput = class
  private
    FType : string;
    FLogs : string;
    FUrl  : string;
  public
    property &Type: string read FType write FType;
    property Logs: string read FLogs write FLogs;
    property Url: string read FUrl write FUrl;
  end;

  TResponseOutputCodeInterpreter = class(TResponseOutputImageGeneration)
  private
    [JsonNameAttribute('container_id')]
    FContainerId : string;
    FCode        : string;
    FOutputs     : TArray<TResponseCodeInterpreterOutput>;
  public
    /// <summary>
    /// The code to run.
    /// </summary>
    property Code: string read FCode write FCode;

    /// <summary>
    /// The ID of the container used to run the code.
    /// </summary>
    property ContainerId: string read FContainerId write FContainerId;

    /// <summary>
    /// The outputs generated by the code interpreter, such as logs or images. Can be null if no outputs are available.
    /// </summary>
    property Outputs: TArray<TResponseCodeInterpreterOutput> read FOutputs write FOutputs;

    destructor Destroy; override;
  end;

  TResponseOutputLocalShell = class(TResponseOutputCodeInterpreter)
  end;

  TResponseOutputMCPTool = class(TResponseOutputLocalShell)
  private
    [JsonNameAttribute('server_label')]
    FServerLabel : string;
    FError       : string;
    FOutput      : string;
  public
    /// <summary>
    /// The label of the MCP server running the tool.
    /// </summary>
    property ServerLabel: string read FServerLabel write FServerLabel;

    /// <summary>
    /// The error from the tool call, if any.
    /// </summary>
    property Error: string read FError write FError;

    /// <summary>
    /// The output from the tool call.
    /// </summary>
    property Output: string read FOutput write FOutput;
  end;

  TResponseOutputMCPList = class(TResponseOutputMCPTool)
  private
    FTools : TArray<TMCPListTool>;
  public
    property Tools: TArray<TMCPListTool> read FTools write FTools;

    destructor Destroy; override;
  end;

  TResponseMCPApproval = class(TResponseOutputMCPList)
  end;

  TResponseCustomTool = class(TResponseMCPApproval)
  private
    FInput : string;
  public
    /// <summary>
    /// The input for the custom tool call generated by the model.
    /// </summary>
    property Input: string read FInput write FInput;
  end;

  {$REGION 'Dev note'}
  {--- This class is made up of the following classes:
    TResponseOutputCommon,
    TResponseOutputMessage,
    TResponseOutputFileSearch,
    TResponseOutputFunction,
    TResponseOutputWebSearch,
    TResponseOutputComputer,
    TResponseOutputReasoning,
    TResponseOutputImageGeneration,
    TResponseOutputCodeInterpreter,
    TResponseOutputLocalShell,
    TResponseOutputMCPTool,
    TResponseOutputMCPList,
    TResponseMCPApproval
  }
  {$ENDREGION}
  TResponseOutput = class(TResponseCustomTool);

(* End Output classes ....................................................... *)

  TResponseTextFormatCommon = class
  private
    [JsonReflectAttribute(ctString, rtString, TResponseFormatTypeInterceptor)]
    FType : TResponseFormatType;
  public
    /// <summary>
    /// The type of response format being defined. One of text, json_schema, json_object
    /// </summary>
    property &Type: TResponseFormatType read FType write FType;
  end;

  TResponseFormatText = class(TResponseTextFormatCommon)
  end;

  TResponseFormatJSONObject = class(TResponseFormatText)
  end;

  TResponseFormatJSONSchema = class(TResponseFormatJSONObject)
  private
    [JsonReflectAttribute(ctString, rtString, TMetadataInterceptor)]
    FSchema      : string;
    FName        : string;
    FDescription : string;
    FStrict      : Boolean;
  public
    /// <summary>
    /// The name of the response format. Must be a-z, A-Z, 0-9, or contain underscores and dashes, with a maximum
    /// length of 64.
    /// </summary>
    property Name: string read FName write FName;

    /// <summary>
    /// The schema for the response format, described as a JSON Schema object.
    /// </summary>
    /// <remarks>
    /// Learn how to build JSON schemas https://json-schema.org/.
    /// </remarks>
    property Schema: string read FSchema write FSchema;

    /// <summary>
    /// A description of what the response format is for, used by the model to determine how to respond in the format.
    /// </summary>
    property Description: string read FDescription write FDescription;

    /// <summary>
    /// Whether to enable strict schema adherence when generating the output. If set to true, the model will always
    /// follow the exact schema defined in the schema field. Only a subset of JSON Schema is supported when strict
    /// is true.
    /// </summary>
    /// <remarks>
    /// To learn more, read the Structured Outputs guide https://platform.openai.com/docs/guides/structured-outputs
    /// </remarks>
    property Strict: Boolean read FStrict write FStrict;
  end;

  {$REGION 'Dev note'}
  {--- This class is made up of the following classes:
    TResponseTextFormatCommon,
    TResponseFormatText,
    TResponseFormatJSONObject,
    TResponseFormatJSONSchema }
  {$ENDREGION}
  TResponseTextFormat = class(TResponseFormatJSONSchema);

  TResponseText = class
  private
    [JsonReflectAttribute(ctString, rtString, TVerbosityTypeInterceptor)]
    FVerbosity : TVerbosityType;
    FFormat    : TResponseTextFormat;
  public
    /// <summary>
    /// An object specifying the format that the model must output.
    /// </summary>
    property Format: TResponseTextFormat read FFormat write FFormat;

    /// <summary>
    /// Constrains the verbosity of the model's response. Lower values will result in more concise responses,
    /// while higher values will result in more verbose responses. Currently supported values are low, medium,
    /// and high.
    /// </summary>
    property Verbosity: TVerbosityType read FVerbosity write FVerbosity;

    destructor Destroy; override;
  end;

  TResponseToolCommon = class
  private
    [JsonReflectAttribute(ctString, rtString, TResponseToolsTypeInterceptor)]
    FType : TResponseToolsType;
  public
    /// <summary>
    /// The type of the tool
    /// </summary>
    property &Type: TResponseToolsType read FType write FType;
  end;

  TResponseToolFileSearch = class(TResponseToolCommon)
  private
    [JsonNameAttribute('vector_store_ids')]
    FVectorStoreIds : TArray<string>;
    FFilters        : TResponseFileSearchFilters;
    [JsonNameAttribute('max_num_results')]
    FMaxNumResults  : Int64;
    [JsonNameAttribute('ranking_options')]
    FRankingOptions : TResponseRankingOptions;
  public
    /// <summary>
    /// The IDs of the vector stores to search.
    /// </summary>
    property VectorStoreIds: TArray<string> read FVectorStoreIds write FVectorStoreIds;

    /// <summary>
    /// A filter to apply based on file attributes.
    /// </summary>
    property Filters: TResponseFileSearchFilters read FFilters write FFilters;

    /// <summary>
    /// The maximum number of results to return. This number should be between 1 and 50 inclusive.
    /// </summary>
    property MaxNumResults: Int64 read FMaxNumResults write FMaxNumResults;

    /// <summary>
    /// Ranking options for search.
    /// </summary>
    property RankingOptions: TResponseRankingOptions read FRankingOptions write FRankingOptions;

    destructor Destroy; override;
  end;

  TResponseToolFunction = class(TResponseToolFileSearch)
  private
    [JsonReflectAttribute(ctString, rtString, TMetadataInterceptor)]
    FParameters  : string;
    FName        : string;
    FStrict      : Boolean;
    FDescription : string;
  public
    /// <summary>
    /// The name of the function to call.
    /// </summary>
    property Name: string read FName write FName;

    /// <summary>
    /// A JSON schema object describing the parameters of the function.
    /// </summary>
    property Parameters: string read FParameters write FParameters;

    /// <summary>
    /// Whether to enforce strict parameter validation. Default true.
    /// </summary>
    property Strict: Boolean read FStrict write FStrict;

    /// <summary>
    /// A description of the function. Used by the model to determine whether or not to call the function.
    /// </summary>
    property Description: string read FDescription write FDescription;
  end;

  TResponseToolComputerUse = class(TResponseToolFunction)
  private
    [JsonNameAttribute('display_height')]
    FDisplayHeight : Int64;
    [JsonNameAttribute('display_width')]
    FDisplayWidth  : Int64;
    FEnvironment   : string;
  public
    /// <summary>
    /// The height of the computer display.
    /// </summary>
    property DisplayHeight: Int64 read FDisplayHeight write FDisplayHeight;

    /// <summary>
    /// The width of the computer display.
    /// </summary>
    property DisplayWidth: Int64 read FDisplayWidth write FDisplayWidth;

    /// <summary>
    /// The type of computer environment to control.
    /// </summary>
    property Environment: string read FEnvironment write FEnvironment;
  end;

  TResponseToolWebSearch = class(TResponseToolComputerUse)
  private
    [JsonReflectAttribute(ctString, rtString, TReasoningEffortInterceptor)]
    [JsonNameAttribute('search_context_size')]
    FSearchContextSize : TReasoningEffort;
    [JsonNameAttribute('user_location')]
    FUserLocation      : TResponseWebSearchLocation;
  public
    /// <summary>
    /// High level guidance for the amount of context window space to use for the search. One of low, medium, or high.
    /// medium is the default.
    /// </summary>
    property SearchContextSize: TReasoningEffort read FSearchContextSize write FSearchContextSize;

    /// <summary>
    /// Approximate location parameters for the search.
    /// </summary>
    property UserLocation: TResponseWebSearchLocation read FUserLocation write FUserLocation;

    destructor Destroy; override;
  end;

  TResponseMCPTool = class(TResponseToolWebSearch)
  private
    [JsonNameAttribute('server_label')]
    FServerLabel : string;
    [JsonNameAttribute('server_url')]
    FServerUrl   : string;
    FHeaders     : string;
  public
    /// <summary>
    /// A label for this MCP server, used to identify it in tool calls.
    /// </summary>
    property ServerLabel: string read FServerLabel write FServerLabel;

    /// <summary>
    /// The URL for the MCP server.
    /// </summary>
    property ServerUrl: string read FServerUrl write FServerUrl;

    /// <summary>
    /// Optional HTTP headers to send to the MCP server. Use for authentication or other purposes.
    /// </summary>
    property Headers: string read FHeaders write FHeaders;
  end;

  TResponseCodeInterpreter = class(TResponseMCPTool)
  end;

  TInputImageMask = class
  private
    [JsonNameAttribute('file_id')]
    FFileId   : string;
    [JsonNameAttribute('image_url')]
    FImageUrl : string;
  public
    /// <summary>
    /// File ID for the mask image.
    /// </summary>
    property FileId: string read FFileId write FFileId;

    /// <summary>
    /// Base64-encoded mask image.
    /// </summary>
    property ImageUrl: string read FImageUrl write FImageUrl;
  end;

  TResponseImageGenerationTool = class(TResponseCodeInterpreter)
  private
    FBackground        : string;
    [JsonNameAttribute('input_image_mask')]
    FInputImageMask    : TInputImageMask;
    FModel             : string;
    FModeration        : string;
    [JsonNameAttribute('output_compression')]
    FOutputCompression : Int64;
    [JsonNameAttribute('output_format')]
    FOutputFormat      : string;
    [JsonNameAttribute('partial_images')]
    FPartialImages     : Int64;
    FQuality           : string;
    FSize              : string;
  public
    /// <summary>
    /// Background type for the generated image. One of transparent, opaque, or auto. Default: auto.
    /// </summary>
    property Background: string read FBackground write FBackground;

    /// <summary>
    /// Optional mask for inpainting. Contains image_url (string, optional) and file_id (string, optional).
    /// </summary>
    property InputImageMask: TInputImageMask read FInputImageMask write FInputImageMask;

    /// <summary>
    /// The image generation model to use. Default: gpt-image-1.
    /// </summary>
    property Model: string read FModel write FModel;

    /// <summary>
    /// Moderation level for the generated image. Default: auto.
    /// </summary>
    property Moderation: string read FModeration write FModeration;

    /// <summary>
    /// Compression level for the output image. Default: 100.
    /// </summary>
    property OutputCompression: Int64 read FOutputCompression write FOutputCompression;

    /// <summary>
    /// The output format of the generated image. One of png, webp, or jpeg. Default: png.
    /// </summary>
    property OutputFormat: string read FOutputFormat write FOutputFormat;

    /// <summary>
    /// Number of partial images to generate in streaming mode, from 0 (default value) to 3.
    /// </summary>
    property PartialImages: Int64 read FPartialImages write FPartialImages;

    /// <summary>
    /// The quality of the generated image. One of low, medium, high, or auto. Default: auto.
    /// </summary>
    property Quality: string read FQuality write FQuality;

    /// <summary>
    /// The size of the generated image. One of 1024x1024, 1024x1536, 1536x1024, or auto. Default: auto.
    /// </summary>
    property Size: string read FSize write FSize;

    destructor Destroy; override;
  end;

  TResponseLocalShellTool = class(TResponseImageGenerationTool)
  end;

  {$REGION 'Dev note'}
  {--- This class is made up of the following classes:
    TResponseToolCommon,
    TResponseToolFileSearch,
    TResponseToolFunction,
    TResponseToolComputerUse,
    TResponseToolWebSearch,
    TResponseMCPTool,
    TResponseCodeInterpreter,
    TResponseImageGenerationTool,
    TResponseLocalShellTool}
  {$ENDREGION}
  TResponseTool = class(TResponseLocalShellTool);

  TInputTokensDetails = class
  private
    [JsonNameAttribute('cached_tokens')]
    FCachedTokens : Int64;
  public
    /// <summary>
    /// The number of tokens that were retrieved from the cache.
    /// </summary>
    /// <remarks>
    /// More on prompt caching. https://platform.openai.com/docs/guides/prompt-caching
    /// </remarks>
    property CachedTokens: Int64 read FCachedTokens write FCachedTokens;
  end;

  TOutputTokensDetails = class
  private
    [JsonNameAttribute('reasoning_tokens')]
    FReasoningTokens : Int64;
  public
    /// <summary>
    /// The number of reasoning tokens.
    /// </summary>
    property ReasoningTokens: Int64 read FReasoningTokens write FReasoningTokens;
  end;

  TResponseUsage = class
  private
    [JsonNameAttribute('input_tokens')]
    FInputTokens        : Int64;
    [JsonNameAttribute('input_tokens_details')]
    FInputTokensDetails : TInputTokensDetails;
    [JsonNameAttribute('output_tokens')]
    FOutputTokens       : Int64;
    [JsonNameAttribute('output_tokens_details')]
    FOutputTokensDetails: TOutputTokensDetails;
    [JsonNameAttribute('total_tokens')]
    FTotalTokens        : Int64;
  public
    /// <summary>
    /// The number of input tokens.
    /// </summary>
    property InputTokens: Int64 read FInputTokens write FInputTokens;

    /// <summary>
    /// A detailed breakdown of the input tokens.
    /// </summary>
    property InputTokensDetails: TInputTokensDetails read FInputTokensDetails write FInputTokensDetails;

    /// <summary>
    /// The number of output tokens.
    /// </summary>
    property OutputTokens: Int64 read FOutputTokens write FOutputTokens;

    /// <summary>
    /// A detailed breakdown of the output tokens.
    /// </summary>
    property OutputTokensDetails: TOutputTokensDetails read FOutputTokensDetails write FOutputTokensDetails;

    /// <summary>
    /// The total number of tokens used.
    /// </summary>
    property TotalTokens: Int64 read FTotalTokens write FTotalTokens;

    destructor Destroy; override;
  end;

  TPrompt = class
  private
    [JsonReflectAttribute(ctString, rtString, TMetadataInterceptor)]
    FVariables : string;
    FId        : string;
    FVersion   : string;
  public
    /// <summary>
    /// The unique identifier of the prompt template to use.
    /// </summary>
    property Id: string read FId write FId;

    /// <summary>
    /// Optional map of values to substitute in for variables in your prompt. The substitution values can
    /// either be strings, or other Response input types like images or files.
    /// </summary>
    property Variables: string read FVariables write FVariables;

    /// <summary>
    /// Optional version of the prompt template.
    /// </summary>
    property Version: string read FVersion write FVersion;
  end;

  TDragPath = class
  private
    FX : Int64;
    FY : Int64;
  public
    property X: Int64 read FX write FX;
    property Y: Int64 read FY write FY;
  end;

  TInstructionsAnnotation = class
  private
    FType       : string;
    //File citation
    [JsonNameAttribute('file_id')]
    FFileId     : string;
    FFilename   : string;
    FIndex      : Int64;
    //File citation
    [JsonNameAttribute('end_index')]
    FEndIndex   : Int64;
    [JsonNameAttribute('start_index')]
    FStartIndex : Int64;
    FTitle      : string;
    FUrl        : string;
    //Container file citation
    [JsonNameAttribute('container_id')]
    FContainerId : string;
    //File path
  public
    property &Type: string read FType write FType;

    /// <summary>
    /// The ID of the file.
    /// </summary>
    property FileId: string read FFileId write FFileId;

    /// <summary>
    /// The filename of the file cited.
    /// </summary>
    property Filename: string read FFilename write FFilename;

    /// <summary>
    /// The index of the file in the list of files.
    /// </summary>
    property Index: Int64 read FIndex write FIndex;

    /// <summary>
    /// The index of the last character of the URL citation in the message.
    /// </summary>
    property EndIndex: Int64 read FEndIndex write FEndIndex;

    /// <summary>
    /// The index of the first character of the URL citation in the message.
    /// </summary>
    property StartIndex: Int64 read FStartIndex write FStartIndex;

    /// <summary>
    /// The title of the web resource.
    /// </summary>
    property Title: string read FTitle write FTitle;

    /// <summary>
    /// The URL of the web resource.
    /// </summary>
    property Url: string read FUrl write FUrl;

    /// <summary>
    /// The ID of the container file.
    /// </summary>
    property ContainerId: string read FContainerId write FContainerId;
  end;

  TInstructionsResults = class
  private
    [JsonReflectAttribute(ctString, rtString, TMetadataInterceptor)]
    FAttributes : string;
    [JsonNameAttribute('file_id')]
    FFileId     : string;
    FFilename   : string;
    FScore      : Double;
    FText       : string;
  public
    /// <summary>
    /// Set of 16 key-value pairs that can be attached to an object. This can be useful for storing additional
    /// information about the object in a structured format, and querying for objects via API or the dashboard.
    /// Keys are strings with a maximum length of 64 characters. Values are strings with a maximum length of
    /// 512 characters, booleans, or numbers.
    /// </summary>
    property Attributes: string read FAttributes write FAttributes;

    /// <summary>
    /// The unique ID of the file.
    /// </summary>
    property FileId: string read FFileId write FFileId;

    /// <summary>
    /// The name of the file.
    /// </summary>
    property Filename: string read FFilename write FFilename;

    /// <summary>
    /// The relevance score of the file - a value between 0 and 1.
    /// </summary>
    property Score: Double read FScore write FScore;

    /// <summary>
    /// The text that was retrieved from the file.
    /// </summary>
    property Text: string read FText write FText;
  end;

  TInstructionsOutput = class
  private
    FType     : string;
    FText     : string;
    [JsonNameAttribute('file_id')]
    FFileId   : string;
    [JsonNameAttribute('image_url')]
    FImageUrl : string;
  public
    property &Type: string read FType write FType;

    /// <summary>
    /// A JSON string of the output of the function tool call.
    /// </summary>
    property Text: string read FText write FText;

    /// <summary>
    /// The identifier of an uploaded file that contains the screenshot.
    /// </summary>
    property FileId: string read FFileId write FFileId;

    /// <summary>
    /// The URL of the screenshot image.
    /// </summary>
    property ImageUrl: string read FImageUrl write FImageUrl;
  end;

  TInstructionsSafetyChecks = class
  private
    FCode    : string;
    FId      : string;
    FMessage : string;
  public
    property Code: string read FCode write FCode;
    property Id: string read FId write FId;
    property Message: string read FMessage write FMessage;
  end;

  TInstructionsAction = class
  private
    FType             : string;
    //Search action
    FQuery            : string;
    //Open page action
    FUrl              : string;
    //Find action
    FPattern          : string;
    //Local shell call
    FCommand          : TArray<string>;
    [JsonReflectAttribute(ctString, rtString, TMetadataInterceptor)]
    FEnv              : string;
    [JsonNameAttribute('timeout_ms')]
    FTimeoutMs        : Int64;
    FUser             : string;
    [JsonNameAttribute('working_directory')]
    FWorkingDirectory : string;
    //Click
    FButton           : string;
    FX                : Int64;
    FY                : Int64;
    //DoubleClick : done
    //Drag
    FDrag             : TArray<TDragPath>;
    //KeyPress
    FKeys             : TArray<string>;
    //Move : Done
    //Screenshot : Done
    //Scroll
    [JsonNameAttribute('scroll_x')]
    FScrollX          : Int64;
    [JsonNameAttribute('scroll_y')]
    FScrollY          : Int64;
    //Type
    FText             : string;
    //Wait : Done
  public
    property &Type: string read FType write FType;

    /// <summary>
    /// The search query.
    /// </summary>
    property Query: string read FQuery write FQuery;

    /// <summary>
    /// The URL opened by the model or the URL of the page searched for the pattern.
    /// </summary>
    property Url: string read FUrl write FUrl;

    /// <summary>
    /// The pattern or text to search for within the page.
    /// </summary>
    property Pattern: string read FPattern write FPattern;

    /// <summary>
    /// The command to run.
    /// </summary>
    property Command: TArray<string> read FCommand write FCommand;

    /// <summary>
    /// Environment variables to set for the command.
    /// </summary>
    property Env: string read FEnv write FEnv;

    /// <summary>
    /// Optional timeout in milliseconds for the command.
    /// </summary>
    property TimeoutMs: Int64 read FTimeoutMs write FTimeoutMs;

    /// <summary>
    /// Optional user to run the command as.
    /// </summary>
    property User: string read FUser write FUser;

    /// <summary>
    /// Optional working directory to run the command in.
    /// </summary>
    property WorkingDirectory: string read FWorkingDirectory write FWorkingDirectory;

    /// <summary>
    /// Indicates which mouse button was pressed during the click. One of left, right, wheel, back, or forward.
    /// </summary>
    property Button: string read FButton write FButton;

    /// <summary>
    /// The x-coordinate
    /// </summary>
    property X: Int64 read FX write FX;

    /// <summary>
    /// The y-coordinate
    /// </summary>
    property Y: Int64 read FY write FY;

    /// <summary>
    /// An array of coordinates representing the path of the drag action. Coordinates will appear as an array of objects
    /// </summary>
    property Drag: TArray<TDragPath> read FDrag write FDrag;

    /// <summary>
    /// The combination of keys the model is requesting to be pressed. This is an array of strings, each representing a key.
    /// </summary>
    property Keys: TArray<string> read FKeys write FKeys;

    /// <summary>
    /// The horizontal scroll distance.
    /// </summary>
    property ScrollX: Int64 read FScrollX write FScrollX;

    /// <summary>
    /// The vertical scroll distance.
    /// </summary>
    property ScrollY: Int64 read FScrollY write FScrollY;

    /// <summary>
    /// The text to type.
    /// </summary>
    property Text: string read FText write FText;

    destructor Destroy; override;
  end;

  TInstructionsReasoningSummary = class
  private
    FType : string;
    FText : string;
  public
    property &Type: string read FType write FType;
    property Text: string read FText write FText;
  end;

  TInstructionsOutputs = class
  private
    FType : string;
    FLogs : string;
    FUrl  : string;
  public
    property &Type: string read FType write FType;

    /// <summary>
    /// The logs output from the code interpreter.
    /// </summary>
    property Logs: string read FLogs write FLogs;

    /// <summary>
    /// The URL of the image output from the code interpreter.
    /// </summary>
    property Url: string read FUrl write FUrl;
  end;

  TInstructionsTools = class
  private
    [JsonReflectAttribute(ctString, rtString, TMetadataInterceptor)]
    [JsonNameAttribute('input_schema')]
    FInputSchema : string;
    FName        : string;
    FDescription : string;
  public
    /// <summary>
    /// The JSON schema describing the tool's input.
    /// </summary>
    property InputSchema: string read FInputSchema write FInputSchema;

    /// <summary>
    /// The name of the tool.
    /// </summary>
    property Name: string read FName write FName;

    /// <summary>
    /// The description of the tool.
    /// </summary>
    property Description: string read FDescription write FDescription;
  end;

  TInstructionsContentInputMessage = class
  private
    FType        : string;
    FText        : string;
    // Input image
    FDetail      : string;
    [JsonNameAttribute('file_id')]
    FFileId      : string;
    [JsonNameAttribute('image_url')]
    FImageUrl    : string;
    // Input file
    [JsonNameAttribute('file_data')]
    FFileData    : string;
    [JsonNameAttribute('file_url')]
    FFileUrl     : string;
    FFilename    : string;
    //Output message : Output text
    FAnnotations : TArray<TInstructionsAnnotation>;
    FLogprobs    : TArray<TLogProb>;
    //Output message : Refusal
    FRefusal     : string;
  public
    property &Type: string read FType write FType;

    /// <summary>
    /// The text input to the model.
    /// </summary>
    property Text: string read FText write FText;

    /// <summary>
    /// The detail level of the image to be sent to the model. One of high, low, or auto. Defaults to auto.
    /// </summary>
    property Detail: string read FDetail write FDetail;

    /// <summary>
    /// The ID of the file to be sent to the model.
    /// </summary>
    property FileId: string read FFileId write FFileId;

    /// <summary>
    /// The URL of the image to be sent to the model. A fully qualified URL or base64 encoded image in a data URL.
    /// </summary>
    property ImageUrl: string read FImageUrl write FImageUrl;

    /// <summary>
    /// The content of the file to be sent to the model.
    /// </summary>
    property FileData: string read FFileData write FFileData;

    /// <summary>
    /// The URL of the file to be sent to the model.
    /// </summary>
    property FileUrl: string read FFileUrl write FFileUrl;

    /// <summary>
    /// The name of the file to be sent to the model.
    /// </summary>
    property Filename: string read FFilename write FFilename;

    /// <summary>
    /// The annotations of the text output.
    /// </summary>
    property Annotations: TArray<TInstructionsAnnotation> read FAnnotations write FAnnotations;

    /// <summary>
    /// logprobs object
    /// </summary>
    property Logprobs: TArray<TLogProb> read FLogprobs write FLogprobs;

    /// <summary>
    /// The refusal explanation from the model.
    /// </summary>
    property Refusal: string read FRefusal write FRefusal;

    destructor Destroy; override;
  end;

  TInstructionsContent = class(TInstructionsContentInputMessage);

  TInstructionsCommon = class
  private
    [JsonReflectAttribute(ctString, rtString, TRoleInterceptor)]
    FRole                     : TRole;
    FType                     : string;
    FStatus                   : string;
    //Output message
    FId                       : string;
    //File search tool call
    FQueries                  : TArray<string>;
    FResults                  : TArray<TInstructionsResults>;
    //Computer tool call
    [JsonNameAttribute('pending_safety_checks')]
    FPendingSafetyChecks      : TArray<TInstructionsSafetyChecks>;
    //Computer tool call output
    [JsonNameAttribute('acknowledged_safety_checks')]
    FAcknowledgedSafetyChecks : TArray<TInstructionsSafetyChecks>;
    //Web search tool call
    FAction                   : TInstructionsAction;
    //Function tool call
    FArguments                : string;
    [JsonNameAttribute('call_id')]
    FCallId                   : string;
    FName                     : string;
    //Function tool call output
    FOutput                   : TInstructionsOutput;
    //Reasoning
    FSummary                  : TArray<TInstructionsReasoningSummary>;
    [JsonNameAttribute('encrypted_content')]
    FEncryptedContent         : string;
    //Image generation call
    FResult                   : string;
    //Code interpreter tool call
    FCode                     : string;
    [JsonNameAttribute('container_id')]
    FContainerId              : string;
    FOutputs                  : TArray<TInstructionsOutputs>;
    //Local shell call : Done
    //Local shell call output : Done
    //MCP list tools
    [JsonNameAttribute('server_label')]
    FServerLabel              : string;
    FTools                    : TArray<TInstructionsTools>;
    FError                    : string;
    //MCP approval request : Done
    //MCP approval response
    [JsonNameAttribute('approval_request_id')]
    FApprovalRequestId        : string;
    FApprove                  : Boolean;
    FReason                   : string;
    //MCP tool call : Done
    //Custom tool call output : Done
    //Custom tool call output
    FInput                    : string;
  public
    property &Type: string read FType write FType;

    /// <summary>
    /// The role of the message input. One of user, assistant, system, or developer.
    /// </summary>
    property Role: TRole read FRole write FRole;

    /// <summary>
    /// The status of item. One of in_progress, completed, or incomplete. Populated when items are returned via API.
    /// </summary>
    property Status: string read FStatus write FStatus;

    /// <summary>
    /// <para>
    /// - The unique ID of the output message.
    /// </para>
    /// <para>
    /// - The ID of the item to reference.
    /// </para>
    /// <para>
    /// - The unique ID of the custom tool call (output) in the OpenAI platform.
    /// </para>
    /// <para>
    /// - The unique ID of the tool call.
    /// </para>
    /// <para>
    /// - The unique ID of the approval response
    /// </para>
    /// <para>
    /// - The unique ID of the approval request.
    /// </para>
    /// <para>
    /// -The unique ID of the mcp list.
    /// </para>
    /// <para>
    /// - The unique ID of the local shell tool call generated by the model.
    /// </para>
    /// <para>
    /// - The unique ID of the local shell call.
    /// </para>
    /// <para>
    /// -The unique ID of the code interpreter tool call.
    /// </para>
    /// <para>
    /// - The unique ID of the image generation call.
    /// </para>
    /// <para>
    /// - The unique identifier of the reasoning content.
    /// </para>
    /// <para>
    /// - The unique ID of the function tool call output. Populated when this item is returned via API.
    /// </para>
    /// <para>
    /// - The unique ID of the function tool call.
    /// </para>
    /// <para>
    /// - The unique ID of the web search tool call.
    /// </para>
    /// <para>
    /// - The ID of the computer tool call output.
    /// </para>
    /// <para>
    /// - The unique ID of the computer call.
    /// </para>
    /// <para>
    /// - The unique ID of the file search tool call.
    /// </para>
    /// <para>
    /// -
    /// </para>
    /// </summary>
    property Id: string read FId write FId;

    /// <summary>
    /// The queries used to search for files.
    /// </summary>
    property Queries: TArray<string> read FQueries write FQueries;

    /// <summary>
    /// The results of the file search tool call.
    /// </summary>
    property Results: TArray<TInstructionsResults> read FResults write FResults;

    /// <summary>
    /// <para>
    /// - Computer action (click, doubleclick, drag ...
    /// </para>
    /// <para>
    /// - An object describing the specific action taken in this web search call. Includes details on how
    /// the model used the web (search, open_page, find).
    /// </para>
    /// <para>
    /// - Execute a shell command on the server.
    /// </para>
    /// </summary>
    property Action: TInstructionsAction read FAction write FAction;

    /// <summary>
    /// The pending safety checks for the computer call.
    /// </summary>
    property PendingSafetyChecks: TArray<TInstructionsSafetyChecks> read FPendingSafetyChecks write FPendingSafetyChecks;

    /// <summary>
    /// The safety checks reported by the API that have been acknowledged by the developer.
    /// </summary>
    property AcknowledgedSafetyChecks: TArray<TInstructionsSafetyChecks> read FAcknowledgedSafetyChecks write FAcknowledgedSafetyChecks;

    /// <summary>
    /// <para>
    /// - A JSON string of the arguments passed to the tool.
    /// </para>
    /// <para>
    /// - A JSON string of the arguments to pass to the function.
    /// </para>
    /// </summary>
    property Arguments: string read FArguments write FArguments;

    /// <summary>
    /// <para>
    /// - An identifier used when responding to the tool call with output.
    /// </para>
    /// <para>
    /// - The ID of the computer tool call that produced the output.
    /// </para>
    /// <para>
    /// - The unique ID of the function tool call generated by the model.
    /// </para>
    /// <para>
    /// - The unique ID of the local shell tool call generated by the model.
    /// </para>
    /// <para>
    /// - The call ID, used to map this custom tool call output to a custom tool call.
    /// </para>
    /// <para>
    /// - An identifier used to map this custom tool call to a tool call output.
    /// </para>
    /// </summary>
    property CallId: string read FCallId write FCallId;

    /// <summary>
    /// <para>
    /// - The name of the custom tool being called.
    /// </para>
    /// <para>
    /// - The name of the tool that was run.
    /// </para>
    /// <para>
    /// - The name of the tool to run.
    /// </para>
    /// <para>
    /// - The name of the function to run.
    /// </para>
    /// </summary>
    property Name: string read FName write FName;

    /// <summary>
    /// <para>
    /// - A computer screenshot image used with the computer use tool.
    /// </para>
    /// <para>
    /// - A JSON string of the output of the function tool call.
    /// </para>
    /// <para>
    /// - The output from the custom tool call generated by your code.
    /// </para>
    /// </summary>
    property Output: TInstructionsOutput read FOutput write FOutput;

    /// <summary>
    /// Reasoning summary content.
    /// </summary>
    property Summary: TArray<TInstructionsReasoningSummary> read FSummary write FSummary;

    /// <summary>
    /// The encrypted content of the reasoning item - populated when a response is generated with
    /// reasoning.encrypted_content in the include parameter.
    /// </summary>
    property EncryptedContent: string read FEncryptedContent write FEncryptedContent;

    /// <summary>
    /// The generated image encoded in base64.
    /// </summary>
    property Result: string read FResult write FResult;

    /// <summary>
    /// The code to run, or null if not available.
    /// </summary>
    property Code: string read FCode write FCode;

    /// <summary>
    /// The ID of the container used to run the code.
    /// </summary>
    property ContainerId: string read FContainerId write FContainerId;

    /// <summary>
    /// The outputs generated by the code interpreter, such as logs or images. Can be null if no outputs are available.
    /// </summary>
    property Outputs: TArray<TInstructionsOutputs> read FOutputs write FOutputs;

    /// <summary>
    /// The label of the MCP server.
    /// </summary>
    property ServerLabel: string read FServerLabel write FServerLabel;

    /// <summary>
    /// The tools available on the server.
    /// </summary>
    property Tools: TArray<TInstructionsTools> read FTools write FTools;

    /// <summary>
    /// Error message if the server could not list tools.
    /// </summary>
    property Error: string read FError write FError;

    /// <summary>
    /// The ID of the approval request being answered.
    /// </summary>
    property ApprovalRequestId: string read FApprovalRequestId write FApprovalRequestId;

    /// <summary>
    /// Whether the request was approved.
    /// </summary>
    property Approve: Boolean read FApprove write FApprove;

    /// <summary>
    /// Optional reason for the decision.
    /// </summary>
    property Reason: string read FReason write FReason;

    /// <summary>
    /// The input for the custom tool call generated by the model.
    /// </summary>
    property Input: string read FInput write FInput;

    destructor Destroy; override;
  end;

  TInputOutputMessage = class(TInstructionsCommon)
  private
    FContent : TArray<TInstructionsContent>;
  public
    property Content: TArray<TInstructionsContent> read FContent write FContent;
    destructor Destroy; override;
  end;

  TInstructions = class(TInputOutputMessage);

  TResponse = class(TJSONFingerprint)
  private
    FBackground               : Boolean;
    [JsonNameAttribute('created_at')]
    FCreatedAt                : TInt64OrNull;
    FError                    : TResponseError;
    FId                       : string;
    [JsonNameAttribute('incomplete_details')]
    FIncompleteDetails        : TResponseIncompleteDetails;
    FInstructions             : TArray<TInstructions>;
    [JsonNameAttribute('max_output_tokens')]
    FMaxOutputTokens          : Int64;
    [JsonNameAttribute('max_tool_calls')]
    FMaxToolCalls             : Int64;
    [JsonReflectAttribute(ctString, rtString, TMetadataInterceptor)]
    FMetadata                 : string;
    FModel                    : string;
    FObject                   : string;
    FOutput                   : TArray<TResponseOutput>;
    [JsonNameAttribute('parallel_tool_calls')]
    FParallelToolCalls        : Boolean;
    [JsonNameAttribute('previous_response_id')]
    FPreviousResponseId       : string;
    FPrompt                   : TPrompt;
    [JsonNameAttribute('prompt_cache_key')]
    FPromptCacheKey           : string;
    FReasoning                : TResponseReasoning;
    [JsonNameAttribute('safety_identifier')]
    FSafetyIdentifier         : string;
    [JsonNameAttribute('service_tier')]
    FServiceTier              : string;
    [JsonReflectAttribute(ctString, rtString, TResponseStatusInterceptor)]
    FStatus                   : TResponseStatus;
    FTemperature              : Double;
    FText                     : TResponseText;
    {--- tool_choice string or object :
          - polymorphic deserialization cannot be directly achieved
          - Access to field contents from JSONResponse string possible}
    FTools                    : TArray<TResponseTool>;
    [JsonNameAttribute('top_logprobs')]
    FTopLogprobs              : Int64;
    [JsonNameAttribute('top_p')]
    FTopP                     : Double;
    FTruncation               : string;
    FUsage                    : TResponseUsage;
    FUser                     : string;
  protected
    function GetCreatedAtAsString: string;
  public
    /// <summary>
    /// Whether to run the model response in the background.
    /// </summary>
    property Background: Boolean read FBackground write FBackground;

    /// <summary>
    /// Unix timestamp (in seconds) of when this Response was created.
    /// </summary>
    property CreatedAt: TInt64OrNull read FCreatedAt write FCreatedAt;

    /// <summary>
    /// Unix timestamp as string of when this Response was created.
    /// </summary>
    property CreatedAtAsString: string read GetCreatedAtAsString;

    /// <summary>
    /// An error object returned when the model fails to generate a Response.
    /// </summary>
    property Error: TResponseError read FError write FError;

    /// <summary>
    /// Unique identifier for this Response.
    /// </summary>
    property Id: string read FId write FId;

    /// <summary>
    /// Details about why the response is incomplete.
    /// </summary>
    property IncompleteDetails: TResponseIncompleteDetails read FIncompleteDetails write FIncompleteDetails;

    /// <summary>
    /// Inserts a system (or developer) message as the first item in the model's context.
    /// </summary>
    /// <remarks>
    /// When using along with previous_response_id, the instructions from a previous response will not be carried over
    /// to the next response. This makes it simple to swap out system (or developer) messages in new responses.
    /// </remarks>
    property Instructions: TArray<TInstructions> read FInstructions write FInstructions;

    /// <summary>
    /// An upper bound for the number of tokens that can be generated for a response, including visible output tokens
    /// and reasoning tokens.
    /// </summary>
    property MaxOutputTokens: Int64 read FMaxOutputTokens write FMaxOutputTokens;

    /// <summary>
    /// The maximum number of total calls to built-in tools that can be processed in a response. This
    /// maximum number applies across all built-in tool calls, not per individual tool. Any further
    /// attempts to call a tool by the model will be ignored.
    /// </summary>
    property MaxToolCalls: Int64 read FMaxToolCalls write FMaxToolCalls;

    /// <summary>
    /// Set of 16 key-value pairs that can be attached to an object. This can be useful for storing additional information
    /// about the object in a structured format, and querying for objects via API or the dashboard.
    /// </summary>
    /// <remarks>
    /// Keys are strings with a maximum length of 64 characters. Values are strings with a maximum length of 512 characters.
    /// </remarks>
    property Metadata: string read FMetadata write FMetadata;

    /// <summary>
    /// Model ID used to generate the response, like gpt-4o or o3. OpenAI offers a wide range of models with different
    /// capabilities, performance characteristics, and price points.
    /// </summary>
    property Model: string read FModel write FModel;

    /// <summary>
    /// The object type of this resource - always set to response.
    /// </summary>
    property &Object: string read FObject write FObject;

    /// <summary>
    /// An array of content items generated by the model.
    /// <para>
    /// - The length and order of items in the output array is dependent on the model's response.
    /// </para>
    /// <para>
    /// - Rather than accessing the first item in the output array and assuming it's an assistant message with the content
    /// generated by the model, you might consider using the output_text property where supported in SDKs.
    /// </para>
    /// </summary>
    property Output: TArray<TResponseOutput> read FOutput write FOutput;

    /// <summary>
    /// Whether to allow the model to run tool calls in parallel.
    /// </summary>
    property ParallelToolCalls: Boolean read FParallelToolCalls write FParallelToolCalls;

    /// <summary>
    /// The unique ID of the previous response to the model. Use this to create multi-turn conversations.
    /// Learn more about conversation state.
    /// </summary>
    property PreviousResponseId: string read FPreviousResponseId write FPreviousResponseId;

    /// <summary>
    /// Reference to a prompt template and its variables.
    /// </summary>
    property Prompt: TPrompt read FPrompt write FPrompt;

    /// <summary>
    /// Used by OpenAI to cache responses for similar requests to optimize your cache hit rates. Replaces the user field.
    /// </summary>
    property PromptCacheKey: string read FPromptCacheKey write FPromptCacheKey;

    /// <summary>
    /// o-series models only
    /// </summary>
    property Reasoning: TResponseReasoning read FReasoning write FReasoning;

    /// <summary>
    /// A stable identifier used to help detect users of your application that may be violating OpenAI's usage policies.
    /// The IDs should be a string that uniquely identifies each user. We recommend hashing their username or email
    /// address, in order to avoid sending us any identifying information.
    /// </summary>
    property SafetyIdentifier: string read FSafetyIdentifier write FSafetyIdentifier;

    /// <summary>
    /// Specifies the latency tier to use for processing the request. This parameter is relevant for customers
    /// subscribed to the scale tier service:
    /// <para>
    /// - If set to 'auto', and the Project is Scale tier enabled, the system will utilize scale tier credits
    /// until they are exhausted.
    /// </para>
    /// <para>
    /// - If set to 'auto', and the Project is not Scale tier enabled, the request will be processed using the
    /// default service tier with a lower uptime SLA and no latency guarentee.
    /// </para>
    /// <para>
    /// - If set to 'default', the request will be processed using the default service tier with a lower uptime
    /// SLA and no latency guarentee.
    /// </para>
    /// <para>
    /// - If set to 'flex', the request will be processed with the Flex Processing service tier. Learn more.
    /// </para>
    /// <para>
    /// - When not set, the default behavior is 'auto'.
    /// </para>
    /// When this parameter is set, the response body will include the service_tier utilized.
    /// </summary>
    property ServiceTier: string read FServiceTier write FServiceTier;

    /// <summary>
    /// The status of the response generation. One of completed, failed, in_progress, or incomplete.
    /// </summary>
    property Status: TResponseStatus read FStatus write FStatus;

    /// <summary>
    /// What sampling temperature to use, between 0 and 2. Higher values like 0.8 will make the output more random,
    /// while lower values like 0.2 will make it more focused and deterministic. We generally recommend altering this
    /// or top_p but not both.
    /// </summary>
    property Temperature: Double read FTemperature write FTemperature;

    /// <summary>
    /// Configuration options for a text response from the model. Can be plain text or structured JSON data. Learn more:
    /// <para>
    /// - Text inputs and outputs https://platform.openai.com/docs/guides/text
    /// </para>
    /// <para>
    /// - Structured Outputs https://platform.openai.com/docs/guides/structured-outputs
    /// </para>
    /// </summary>
    property Text: TResponseText read FText write FText;

    /// <summary>
    /// An array of tools the model may call while generating a response. You can specify which tool to use by setting the
    /// tool_choice parameter.
    /// </summary>
    /// <remarks>
    /// The two categories of tools you can provide the model are:
    /// <para>
    /// - Built-in tools: Tools that are provided by OpenAI that extend the model's capabilities, like web search or file
    /// search. Learn more about built-in tools.
    /// </para>
    /// <para>
    /// - Function calls (custom tools): Functions that are defined by you, enabling the model to call your own code. Learn
    /// more about function calling.
    /// </para>
    /// </remarks>
    property Tools: TArray<TResponseTool> read FTools write FTools;

    /// <summary>
    /// An integer between 0 and 20 specifying the number of most likely tokens to return at each token position,
    /// each with an associated log probability.
    /// </summary>
    property TopLogprobs: Int64 read FTopLogprobs write FTopLogprobs;

    /// <summary>
    /// An alternative to sampling with temperature, called nucleus sampling, where the model considers the results of
    /// the tokens with top_p probability mass. So 0.1 means only the tokens comprising the top 10% probability mass are
    /// considered.
    /// </summary>
    /// <remarks>
    /// We generally recommend altering this or temperature but not both.
    /// </remarks>
    property TopP: Double read FTopP write FTopP;

    /// <summary>
    /// The truncation strategy to use for the model response.
    /// <para>
    /// - auto: If the context of this response and previous ones exceeds the model's context window size,
    /// the model will truncate the response to fit the context window by dropping input items in the middle
    /// of the conversation.
    /// </para>
    /// <para>
    /// - disabled (default): If a model response will exceed the context window size for a model, the
    /// request will fail with a 400 error.
    /// </para>
    /// </summary>
    property Truncation: string read FTruncation write FTruncation;

    /// <summary>
    /// Represents token usage details including input tokens, output tokens, a breakdown of output tokens, and the total
    /// tokens used.
    /// </summary>
    property Usage: TResponseUsage read FUsage write FUsage;

    /// <summary>
    /// A unique identifier representing your end-user, which can help OpenAI to monitor and detect abuse.
    /// </summary>
    /// <remarks>
    /// Learn more. https://platform.openai.com/docs/guides/safety-best-practices#end-user-ids
    /// </remarks>
    property User: string read FUser write FUser;

    destructor Destroy; override;
  end;

  TUrlIncludeParams = class(TUrlParam)
  public
    /// <summary>
    /// Additional fields to include in the response. See the include parameter for Response creation above for more information.
    /// </summary>
    function Include(const Value: TArray<string>): TURLIncludeParams; overload;

    /// <summary>
    /// Additional fields to include in the response. See the include parameter for Response creation above for more information.
    /// </summary>
    function Include(const Value: TArray<TOutputIncluding>): TURLIncludeParams; overload;
  end;

  TUrlResponseListParams = class(TUrlParam)
  public
    /// <summary>
    /// An item ID to list items after, used in pagination.
    /// </summary>
    function After(const Value: string): TUrlResponseListParams;

    /// <summary>
    /// An item ID to list items before, used in pagination.
    /// </summary>
    function Before(const Value: string): TUrlResponseListParams;

    /// <summary>
    /// Additional fields to include in the response. See the include parameter for Response creation above for more information.
    /// </summary>
    function Include(const Value: TArray<string>): TUrlResponseListParams; overload;

    /// <summary>
    /// Additional fields to include in the response. See the include parameter for Response creation above for more information.
    /// </summary>
    function Include(const Value: TArray<TOutputIncluding>): TUrlResponseListParams; overload;

    /// <summary>
    /// A limit on the number of objects to be returned. Limit can range between 1 and 100, and the default is 20.
    /// </summary>
    function Limit(const Value: Integer): TUrlResponseListParams;

    /// <summary>
    /// The order to return the input items in. Default is asc.
    /// <para>
    /// - asc: Return the input items in ascending order.
    /// </para>
    /// <para>
    /// - desc: Return the input items in descending order.
    /// </para>
    /// </summary>
    function Order(const Value: string): TUrlResponseListParams;
  end;

  TResponseDelete = class(TJSONFingerprint)
  private
    FId      : string;
    FObject  : string;
    FDeleted : Boolean;
  public
    /// <summary>
    /// The ID of the response to delete.
    /// </summary>
    property Id: string read FId write FId;

    /// <summary>
    /// Allways reponse.deleted
    /// </summary>
    property &Object: string read FObject write FObject;

    /// <summary>
    /// True if the response has been deleted
    /// </summary>
    property Deleted: Boolean read FDeleted write FDeleted;
  end;

  {$REGION 'Dev note'}
(******************************************************************************

  Streaming events:
  ================

   Stream Chat Completions in real time. Receive chunks of completions returned
   from the model using server-sent events.

        1- response.created
        2- response.in_progress
        3- response.completed
        4- response.failed
        5- response.incomplete
        6- response.output_item.added
        7- response.output_item.done
        8- response.content_part.added
        9- response.content_part.done
        10- response.output_text.delta
        11- response.output_text.done
        12- response.refusal.delta
        13- response.refusal.done
        14- response.function_call_arguments.delta
        15- response.function_call_arguments.done
        16- response.file_search_call.in_progress
        17- response.file_search_call.searching
        18- response.file_search_call.completed
        19- response.web_search_call.in_progress
        20- response.web_search_call.searching
        21- response.web_search_call.completed
        22- response.reasoning_summary_part.added
        23- response.reasoning_summary_part.done
        24- response.reasoning_summary_text.delta
        25- response.reasoning_summary_text.done
        26- response.reasoning_text.delta
        27- response.reasoning_text.done
        28- response.image_generation_call.completed
        29- response.image_generation_call.generating
        30- response.image_generation_call.in_progress
        31- response.image_generation_call.partial_image
        32- response.mcp_call_arguments.delta
        33- response.mcp_call_arguments.done
        34- response.mcp_call.completed
        35- response.mcp_call.failed
        36- response.mcp_call.in_progress
        37- response.mcp_list_tools.completed
        38- response.mcp_list_tools.failed
        39- response.mcp_list_tools.in_progress
        40- response.code_interpreter_call.in_progress
        41- response.code_interpreter_call.interpreting
        42- response.code_interpreter_call.completed
        43- response.code_interpreter_call_code.delta
        44- response.code_interpreter_call_code.done
        45- response.output_text.annotation.added
        46- response.queued
        47- response.custom_tool_call_input.delta
        48- response.custom_tool_call_input.done
        49- error

*******************************************************************************)
   {$ENDREGION}

   TResponseOutputLogprobItem = class
  private
    FLogprob: Double;
    FToken: string;
  public
    /// <summary>
    /// The log probability of this token.
    /// </summary>
    property Logprob: Double read FLogprob write FLogprob;

    /// <summary>
    /// A possible text token.
    /// </summary>
    property Token: string read FToken write FToken;
  end;

  TResponseOutputLogprob = class
  private
    FLogprob: Double;
    FToken: string;
    [JsonNameAttribute('top_logprobs')]
    FTopLogprobs: TArray<TResponseOutputLogprobItem>;
  public
    /// <summary>
    /// The log probability of this token.
    /// </summary>
    property Logprob: Double read FLogprob write FLogprob;

    /// <summary>
    /// A possible text token.
    /// </summary>
    property Token: string read FToken write FToken;

    /// <summary>
    /// The log probability of the top 20 most likely tokens.
    /// </summary>
    property TopLogprobs: TArray<TResponseOutputLogprobItem> read FTopLogprobs write FTopLogprobs;
    destructor Destroy; override;
  end;

  TResponseStreamingCommon = class(TJSONFingerprint)
  private
    [JsonReflectAttribute(ctString, rtString, TResponseStreamTypeInterceptor)]
    FType           : TResponseStreamType;
    [JsonNameAttribute('sequence_number')]
    FSequenceNumber : Int64;
  public
    /// <summary>
    /// The type of the event.
    /// </summary>
    property &Type: TResponseStreamType read FType write FType;

    /// <summary>
    /// The sequence number for this event.
    /// </summary>
    property SequenceNumber: Int64 read FSequenceNumber write FSequenceNumber;
  end;

  /// <summary>
  /// response.created : An event that is emitted when a response is created.
  /// </summary>
  TResponseCreated = class(TResponseStreamingCommon)
  private
    FResponse : TResponse;
  public
    /// <summary>
    /// The response depending of the type value (created, in_prgress, completed, failed or incomplete).
    /// </summary>
    property Response: TResponse read FResponse write FResponse;

    destructor Destroy; override;
  end;

  /// <summary>
  /// response.in_progress : Emitted when the response is in progress.
  /// </summary>
  TResponseInProgress = class(TResponseCreated)
    {--- This class does not introduce any new functionality; all methods and properties
         are inherited from its ancestor. }
  end;

  /// <summary>
  /// response.completed : Emitted when the model response is complete.
  /// </summary>
  TResponseCompleted = class(TResponseInProgress)
  end;

  /// <summary>
  /// response.failed : An event that is emitted when a response fails.
  /// </summary>
  TResponseFailed = class(TResponseCompleted)
  end;

  /// <summary>
  /// response.incomplete : An event that is emitted when a response finishes as incomplete.
  /// </summary>
  TResponseIncomplete = class(TResponseFailed)
  end;

  /// <summary>
  /// response.output_item.added : Emitted when a new output item is added.
  /// </summary>
  TResponseOutputItemAdded = class(TResponseIncomplete)
  private
    [JsonNameAttribute('output_index')]
    FOutputIndex : Integer;
    FItem        : TResponseOutput;
  public
    /// <summary>
    /// The output item that was marked done.
    /// </summary>
    property Item: TResponseOutput read FItem write FItem;

    /// <summary>
    /// The index of the output item that was marked done.
    /// </summary>
    property OutputIndex: Integer read FOutputIndex write FOutputIndex;

    destructor Destroy; override;
  end;

  /// <summary>
  /// response.output_item.done : Emitted when an output item is marked done.
  /// </summary>
  TResponseOutputItemDone = class(TResponseOutputItemAdded)
  end;

  /// <summary>
  /// response.content_part.added : Emitted when a new content part is added.
  /// </summary>
  TResponseContentpartAdded = class(TResponseOutputItemDone)
  private
    [JsonNameAttribute('content_index')]
    FContentIndex  : Int64;
    [JsonNameAttribute('item_id')]
    FItemId        : string;
    [JsonNameAttribute('output_index')]
    FOutputIndex   : Int64;
    FPart          : TResponseContent;
  public
    /// <summary>
    /// The index of the content part that was added.
    /// </summary>
    property ContentIndex: Int64 read FContentIndex write FContentIndex;

    /// <summary>
    /// The ID of the output item that the content part was added to.
    /// </summary>
    property ItemId: string read FItemId write FItemId;

    /// <summary>
    /// The index of the output item that the content part was added to.
    /// </summary>
    property OutputIndex: Int64 read FOutputIndex write FOutputIndex;

    /// <summary>
    /// The content part that was added.
    /// </summary>
    property Part: TResponseContent read FPart write FPart;

    destructor Destroy; override;
  end;

  /// <summary>
  /// response.content_part.done : Emitted when a content part is done.
  /// </summary>
  TResponseContentpartDone = class(TResponseContentpartAdded)
  end;

  /// <summary>
  /// response.output_text.delta : Emitted when there is an additional text delta.
  /// </summary>
  TResponseOutputTextDelta = class(TResponseContentpartDone)
  private
    FDelta : string;
    FLogprobs: TArray<TResponseOutputLogprob>;
  public
    /// <summary>
    /// The text delta that was added.
    /// </summary>
    property Delta: string read FDelta write FDelta;

    /// <summary>
    /// The log probabilities of the tokens in the delta.
    /// </summary>
    property Logprobs: TArray<TResponseOutputLogprob> read FLogprobs write FLogprobs;

    destructor Destroy; override;
  end;

  /// <summary>
  /// response.output_text.annotation.added : Emitted when a text annotation is added.
  /// </summary>
  TResponseOutputTextAnnotationAdded = class(TResponseOutputTextDelta)
  private
    FAnnotation: TResponseMessageAnnotation;
    [JsonNameAttribute('annotation_index')]
    FAnnotationIndex: Int64;
  public
    /// <summary>
    /// The index of the annotation within the content part.
    /// </summary>
    property AnnotationIndex: Int64 read FAnnotationIndex write FAnnotationIndex;

    /// <summary>
    /// The annotation object being added. (See annotation schema for details.)
    /// </summary>
    property Annotation: TResponseMessageAnnotation read FAnnotation write FAnnotation;

    destructor Destroy; override;
  end;

  /// <summary>
  /// response.output_text.done : Emitted when text content is finalized.
  /// </summary>
  TResponseOutputTextDone = class(TResponseOutputTextAnnotationAdded)
  private
    FText : string;
  public
    /// <summary>
    /// The text content that is finalized.
    /// </summary>
    property Text: string read FText write FText;
  end;

  /// <summary>
  /// response.refusal.delta : Emitted when there is a partial refusal text.
  /// </summary>
  TResponseRefusalDelta = class(TResponseOutputTextDone)
  end;

  /// <summary>
  /// response.refusal.done : Emitted when refusal text is finalized.
  /// </summary>
  TResponseRefusalDone = class(TResponseRefusalDelta)
  private
    FRefusal : string;
  public
    /// <summary>
    /// The refusal text that is finalized.
    /// </summary>
    property Refusal: string read FRefusal write FRefusal;
  end;

  /// <summary>
  /// response.function_call_arguments.delta : Emitted when there is a partial function-call arguments delta.
  /// </summary>
  TResponseFunctionCallArgumentsDelta = class(TResponseRefusalDone)
  end;

  /// <summary>
  /// response.function_call_arguments.done : Emitted when function-call arguments are finalized.
  /// </summary>
  TResponseFunctionCallArgumentsDone = class(TResponseFunctionCallArgumentsDelta)
  private
    FArguments : string;
  public
    /// <summary>
    /// The function-call arguments.
    /// </summary>
    property Arguments: string read FArguments write FArguments;
  end;

  /// <summary>
  /// response.file_search_call.in_progress : Emitted when a file search call is initiated.
  /// </summary>
  TResponseFileSearchCallInprogress = class(TResponseFunctionCallArgumentsDone)
  end;

  /// <summary>
  /// response.file_search_call.searching : Emitted when a file search is currently searching.
  /// </summary>
  TResponseFileSearchCallSearching = class(TResponseFileSearchCallInprogress)
  end;

  /// <summary>
  /// response.file_search_call.completed : Emitted when a file search call is completed (results found).
  /// </summary>
  TResponseFileSearchCallCompleted = class(TResponseFileSearchCallSearching)
  end;

  /// <summary>
  /// response.web_search_call.in_progress : Emitted when a web search call is initiated.
  /// </summary>
  TResponseWebSearchCallInprogress = class(TResponseFileSearchCallCompleted)
  end;

  /// <summary>
  /// response.web_search_call.searching : Emitted when a web search call is executing.
  /// </summary>
  TResponseWebSearchCallSearching = class(TResponseWebSearchCallInprogress)
  end;

  /// <summary>
  /// response.web_search_call.completed : Emitted when a web search call is completed.
  /// </summary>
  TResponseWebSearchCallCompleted = class(TResponseWebSearchCallSearching)
  end;

  /// <summary>
  /// Emitted when a new reasoning summary part is added.
  /// </summary>
  TResponseReasoningSummaryPartAdded = class(TResponseWebSearchCallCompleted)
  private
    [JsonNameAttribute('summary_index')]
    FSummaryIndex : Int64;
  public
    property SummaryIndex: Int64 read FSummaryIndex write FSummaryIndex;
  end;

  /// <summary>
  /// Emitted when a reasoning summary part is completed.
  /// </summary>
  TResponseReasoningSummaryPartDone = class(TResponseReasoningSummaryPartAdded)
  end;

  /// <summary>
  /// Emitted when a delta is added to a reasoning summary text.
  /// </summary>
  TResponseReasoningSummaryTextDelta = class(TResponseReasoningSummaryPartDone)
  end;

  /// <summary>
  /// Emitted when a reasoning summary text is completed.
  /// </summary>
  TResponseReasoningSummaryTextDone = class(TResponseReasoningSummaryTextDelta)
  end;

  /// <summary>
  /// Emitted when a delta is added to a reasoning text.
  /// </summary>
  TResponseReasoningTextDelta = class(TResponseReasoningSummaryTextDone)
  end;

  /// <summary>
  /// Emitted when a reasoning text is completed.
  /// </summary>
  TResponseReasoningTextDone = class(TResponseReasoningTextDelta)
  end;

  /// <summary>
  /// Emitted when an image generation tool call has completed and the final image is available.
  /// </summary>
  TResponseImageGenerationCallCompleted = class(TResponseReasoningTextDone)
  end;

  /// <summary>
  /// Emitted when an image generation tool call is actively generating an image (intermediate state).
  /// </summary>
  TResponseImageGenerationCallGenerating = class(TResponseImageGenerationCallCompleted)
  end;

  /// <summary>
  /// Emitted when an image generation tool call is in progress.
  /// </summary>
  TResponseImageGenerationCallInProgress = class(TResponseImageGenerationCallGenerating)
  end;

  /// <summary>
  /// Emitted when a partial image is available during image generation streaming.
  /// </summary>
  TResponseImageGenerationCallPartialImage = class(TResponseImageGenerationCallInProgress)
  private
    [JsonNameAttribute('partial_image_b64')]
    FPartialImageB64   : string;
    [JsonNameAttribute('partial_image_index')]
    FPartialImageIndex : Int64;
  public
    function GetStream: TStream;

    /// <summary>
    /// Base64-encoded partial image data, suitable for rendering as an image.
    /// </summary>
    property PartialImageB64: string read FPartialImageB64 write FPartialImageB64;

    /// <summary>
    /// 0-based index for the partial image (backend is 1-based, but this is 0-based for the user).
    /// </summary>
    property PartialImageIndex: Int64 read FPartialImageIndex write FPartialImageIndex;
  end;

  /// <summary>
  /// Emitted when there is a delta (partial update) to the arguments of an MCP tool call.
  /// </summary>
  TResponseMcpCallArgumentsDelta = class(TResponseImageGenerationCallPartialImage)
  end;

  /// <summary>
  /// Emitted when the arguments for an MCP tool call are finalized.
  /// </summary>
  TResponseMcpCallArgumentsDone = class(TResponseMcpCallArgumentsDelta)
  end;

  /// <summary>
  /// Emitted when an MCP tool call has completed successfully.
  /// </summary>
  TResponseMcpCallCompleted = class(TResponseMcpCallArgumentsDone)
  end;

  /// <summary>
  /// Emitted when an MCP tool call has failed.
  /// </summary>
  TResponseMcpCallFailed = class(TResponseMcpCallCompleted)
  end;

  /// <summary>
  /// Emitted when an MCP tool call is in progress.
  /// </summary>
  TResponseMcpCallInProgress = class(TResponseMcpCallFailed)
  end;

  /// <summary>
  /// Emitted when the list of available MCP tools has been successfully retrieved.
  /// </summary>
  TResponseMcpListToolsCompleted = class(TResponseMcpCallInProgress)
  end;

  /// <summary>
  /// Emitted when the attempt to list available MCP tools has failed.
  /// </summary>
  TResponseMcpListToolsFailed = class(TResponseMcpListToolsCompleted)
  end;

  /// <summary>
  /// Emitted when the system is in the process of retrieving the list of available MCP tools.
  /// </summary>
  TResponseMcpListToolsInProgress = class(TResponseMcpListToolsFailed)
  end;

  /// <summary>
  /// Emitted when a code interpreter call is in progress.
  /// </summary>
  TResponseCodeInterpreterCallInProgress = class(TResponseMcpListToolsInProgress)
  end;

  /// <summary>
  /// Emitted when the code interpreter is actively interpreting the code snippet.
  /// </summary>
  TResponseCodeInterpreterCallInterpreting = class(TResponseCodeInterpreterCallInProgress)
  end;

  /// <summary>
  /// Emitted when the code interpreter call is completed.
  /// </summary>
  TResponseCodeInterpreterCallCompleted = class(TResponseCodeInterpreterCallInterpreting)
  end;

  /// <summary>
  /// Emitted when a partial code snippet is streamed by the code interpreter.
  /// </summary>
  TResponseCodeInterpreterCallCodeDelta = class(TResponseCodeInterpreterCallCompleted)
  end;

  /// <summary>
  /// Emitted when the code snippet is finalized by the code interpreter.
  /// </summary>
  TResponseCodeInterpreterCallCodeDone = class(TResponseCodeInterpreterCallCodeDelta)
  end;

  /// <summary>
  /// Emitted when a response is queued and waiting to be processed.
  /// </summary>
  TResponseQueued = class(TResponseCodeInterpreterCallCodeDone)
  end;

  /// <summary>
  /// Event representing a delta (partial update) to the input of a custom tool call.
  /// </summary>
  TResponseCustomToolCallInputDelta = class(TResponseQueued)
  end;

  /// <summary>
  /// Event indicating that input for a custom tool call is complete.
  /// </summary>
  TResponseCustomToolCallInputDone = class(TResponseCustomToolCallInputDelta)
  end;

  /// <summary>
  /// response.error: Emitted when an error occurs.
  /// </summary>
  TResponseStreamError = class(TResponseCustomToolCallInputDone)
  private
    FCode    : string;
    FMessage : string;
    FParam   : string;
  public
    /// <summary>
    /// The error code.
    /// </summary>
    property Code: string read FCode write FCode;

    /// <summary>
    /// The error message.
    /// </summary>
    property Message: string read FMessage write FMessage;

    /// <summary>
    /// The error parameter.
    /// </summary>
    property Param: string read FParam write FParam;
  end;

  {$REGION 'Dev note'}
  {--- This class is made up of the following classes:
     TResponseStreamingCommon,
     TResponseCreated,
     TResponseInProgress,
     TResponseCompleted,
     TResponseFailed,
     TResponseIncomplete,
     TResponseOutputItemAdded,
     TResponseOutputItemDone,
     TResponseContentpartAdded,
     TResponseContentpartDone,
     TResponseOutputTextDelta,
     TResponseOutputTextDone,
     TResponseRefusalDelta,
     TResponseRefusalDone,
     TResponseFunctionCallArgumentsDelta,
     TResponseFunctionCallArgumentsDone,
     TResponseFileSearchCallInprogress,
     TResponseFileSearchCallSearching,
     TResponseFileSearchCallCompleted,
     TResponseWebSearchCallInprogress,
     TResponseWebSearchCallSearching,
     TResponseWebSearchCallCompleted,
     TResponseReasoningSummaryPartAdded,
     TResponseReasoningSummaryPartDone,
     TResponseReasoningSummaryTextDelta,
     TResponseReasoningSummaryTextDone,
     TResponseReasoningTextDelta,
     TResponseReasoningTextDone,
     TResponseReasoningSummaryTextDone,
     TResponseImageGenerationCallCompleted,
     TResponseImageGenerationCallGenerating,
     TResponseImageGenerationCallInProgress,
     TResponseImageGenerationCallPartialImage,
     TResponseMcpCallArgumentsDelta,
     TResponseMcpCallArgumentsDone,
     TResponseMcpCallCompleted,
     TResponseMcpCallFailed,
     TResponseMcpCallInProgress,
     TResponseMcpListToolsCompleted,
     TResponseMcpListToolsFailed,
     TResponseMcpListToolsInProgress,
     TResponseCodeInterpreterCallInProgress,
     TResponseCodeInterpreterCallInterpreting,
     TResponseCodeInterpreterCallCompleted,
     TResponseCodeInterpreterCallCodeDelta,
     TResponseCodeInterpreterCallCodeDone,
     TResponseQueued,
     TResponseCustomToolCallInputDelta,
     TResponseCustomToolCallInputDone,
     TResponseStreamError }
  {$ENDREGION}
  TResponseStream = class(TResponseStreamError);

implementation

{ TResponseMessageContent }

destructor TResponseMessageContent.Destroy;
begin
  for var Item in FAnnotations do
    Item.Free;
  for var Item in FLogprobs do
    Item.Free;
  inherited;
end;

{ TResponseFileSearchFiltersCompound }

destructor TResponseFileSearchFiltersCompound.Destroy;
begin
  for var Item in FFilters do
    Item.Free;
  inherited;
end;

{ TResponseOutputMessage }

destructor TResponseOutputMessage.Destroy;
begin
  for var Item in FContent do
    Item.Free;
  inherited;
end;

{ TResponseOutputFileSearch }

destructor TResponseOutputFileSearch.Destroy;
begin
  for var Item in FResults do
    Item.Free;
  inherited;
end;

{ TResponseOutputComputer }

destructor TResponseOutputComputer.Destroy;
begin
  if Assigned(FAction) then
    FAction.Free;
  for var Item in FPendingSafetyChecks do
    Item.Free;
  inherited;
end;

{ TResponseOutputReasoning }

destructor TResponseOutputReasoning.Destroy;
begin
  for var Item in FSummary do
    Item.Free;
  inherited;
end;

{ TResponseOutputMCPList }

destructor TResponseOutputMCPList.Destroy;
begin
  for var Item in FTools do
    Item.Free;
  inherited;
end;

{ TResponseText }

destructor TResponseText.Destroy;
begin
  if Assigned(FFormat) then
    FFormat.Free;
  inherited;
end;

{ TResponseToolFileSearch }

destructor TResponseToolFileSearch.Destroy;
begin
  if Assigned(FFilters) then
    FFilters.Free;
  if Assigned(FRankingOptions) then
    FRankingOptions.Free;
  inherited;
end;

{ TResponseToolWebSearch }

destructor TResponseToolWebSearch.Destroy;
begin
  if Assigned(FUserLocation) then
    FUserLocation.Free;
  inherited;
end;

{ TResponseImageGenerationTool }

destructor TResponseImageGenerationTool.Destroy;
begin
  if Assigned(FInputImageMask) then
    FInputImageMask.Free;
  inherited;
end;

{ TResponseUsage }

destructor TResponseUsage.Destroy;
begin
  if Assigned(FInputTokensDetails) then
    FInputTokensDetails.Free;
  if Assigned(FOutputTokensDetails) then
    FOutputTokensDetails.Free;
  inherited;
end;

{ TResponse }

destructor TResponse.Destroy;
begin
  if Assigned(FError) then
    FError.Free;
  if Assigned(FIncompleteDetails) then
    FIncompleteDetails.Free;
  for var Item in FOutput do
    Item.Free;
  if Assigned(FReasoning) then
    FReasoning.Free;
  if Assigned(FText) then
    FText.Free;
  for var Item in FTools do
    Item.Free;
  if Assigned(FUsage) then
    FUsage.Free;
  if Assigned(FPrompt) then
    FPrompt.Free;
  for var Item in FInstructions do
    Item.Free;
  inherited;
end;

function TResponse.GetCreatedAtAsString: string;
begin
  Result := TInt64OrNull(FCreatedAt).ToUtcDateString;
end;

{ TResponseCreated }

destructor TResponseCreated.Destroy;
begin
  if Assigned(FResponse) then
    FResponse.Free;
  inherited;
end;

{ TResponseOutputItemAdded }

destructor TResponseOutputItemAdded.Destroy;
begin
  if Assigned(FItem) then
    FItem.Free;
  inherited;
end;

{ TResponseContentpartAdded }

destructor TResponseContentpartAdded.Destroy;
begin
  if Assigned(FPart) then
    FPart.Free;
  inherited;
end;

{ TUrlIncludeParams }

function TUrlIncludeParams.Include(
  const Value: TArray<string>): TUrlIncludeParams;
begin
  Result := TUrlIncludeParams(Add('include', Value));
end;

function TUrlIncludeParams.Include(
  const Value: TArray<TOutputIncluding>): TUrlIncludeParams;
var
  Include: TArray<string>;
begin
  for var Item in Value do
    Include := Include + [Item.ToString];
  Result := TUrlIncludeParams(Add('include', Include));
end;

{ TUrlResponseListParams }

function TUrlResponseListParams.After(
  const Value: string): TUrlResponseListParams;
begin
  Result := TUrlResponseListParams(Add('after', Value));
end;

function TUrlResponseListParams.Before(
  const Value: string): TUrlResponseListParams;
begin
  Result := TUrlResponseListParams(Add('before', Value));
end;

function TUrlResponseListParams.Include(
  const Value: TArray<TOutputIncluding>): TUrlResponseListParams;
var
  Include: TArray<string>;
begin
  for var Item in Value do
    Include := Include + [Item.ToString];
  Result := TUrlResponseListParams(Add('include', Include));
end;

function TUrlResponseListParams.Limit(
  const Value: Integer): TUrlResponseListParams;
begin
  Result := TUrlResponseListParams(Add('limit', Value));
end;

function TUrlResponseListParams.Include(
  const Value: TArray<string>): TUrlResponseListParams;
begin
  Result := TUrlResponseListParams(Add('include', Value));
end;

function TUrlResponseListParams.Order(
  const Value: string): TUrlResponseListParams;
begin
  Result := TUrlResponseListParams(Add('order', Value));
end;

{ TResponseImageGenerationCallPartialImage }

function TResponseImageGenerationCallPartialImage.GetStream: TStream;
begin
  Result := TImageHelper.Create(FPartialImageB64).GetStream;
end;

{ TResponseOutputImageGeneration }

function TResponseOutputImageGeneration.GetStream: TStream;
begin
  Exit(TImageHelper.Create(FResult).GetStream);
end;

procedure TResponseOutputImageGeneration.SaveToFile(const FileName: string);
begin
  TImageHelper.Create(FResult).SaveAs(FileName);
end;

{ TInputOutputMessage }

destructor TInputOutputMessage.Destroy;
begin
  for var Item in FContent do
    Item.Free;
  inherited;
end;

{ TInstructionsContentInputMessage }

destructor TInstructionsContentInputMessage.Destroy;
begin
  for var Item in FAnnotations do
    Item.Free;
  for var Item in FLogprobs do
    Item.Free;
  inherited;
end;

{ TLogProb }

destructor TLogProb.Destroy;
begin
  for var Item in FTopLogprobs do
    Item.Free;
  inherited;
end;

{ TInstructionsCommon }

destructor TInstructionsCommon.Destroy;
begin
  if Assigned(FOutput) then
    FOutput.Free;
  for var Item in FResults do
    Item.Free;
  if Assigned(FAction) then
    FAction.Free;
  for var Item in FPendingSafetyChecks do
    Item.Free;
  for var Item in FAcknowledgedSafetyChecks do
    Item.Free;
  for var Item in FSummary do
    Item.Free;
  for var Item in FOutputs do
    Item.Free;
  for var Item in FTools do
    Item.Free;
  inherited;
end;

{ TInstructionsAction }

destructor TInstructionsAction.Destroy;
begin
  for var Item in FDrag do
    Item.Free;
  inherited;
end;

{ TResponseOutputWebSearch }

destructor TResponseOutputWebSearch.Destroy;
begin
  if Assigned(FAction) then
    FAction.Free;
  inherited;
end;

{ TResponseOutputCodeInterpreter }

destructor TResponseOutputCodeInterpreter.Destroy;
begin
  for var Item in FOutputs do
    Item.Free;
  inherited;
end;

{ TResponseOutputLogprob }

destructor TResponseOutputLogprob.Destroy;
begin
  for var Item in FTopLogprobs do
    Item.Free;
  inherited;
end;

{ TResponseOutputTextDelta }

destructor TResponseOutputTextDelta.Destroy;
begin
  for var Item in FLogprobs do
    Item.Free;
  inherited;
end;

{ TResponseOutputTextAnnotationAdded }

destructor TResponseOutputTextAnnotationAdded.Destroy;
begin
   if Assigned(FAnnotation) then
    FAnnotation.Free;
  inherited;
end;

end.
