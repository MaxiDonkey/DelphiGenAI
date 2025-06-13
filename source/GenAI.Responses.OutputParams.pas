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
  TResponseError = class
  private
    FCode: string;
    FMessage: string;
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
    FReason: string;
  public
    /// <summary>
    /// The reason why the response is incomplete.
    /// </summary>
    property Reason: string read FReason write FReason;
  end;

  TResponseMessageContentCommon = class
  private
    [JsonReflectAttribute(ctString, rtString, TResponseContentTypeInterceptor)]
    FType: TResponseContentType;
  public
    /// <summary>
    /// The type of the output text. One of output_text or refusal
    /// </summary>
    property &Type: TResponseContentType read FType write FType;
  end;

  TResponseMessageContent = class(TResponseMessageContentCommon)
  private
    FAnnotations: TArray<TResponseMessageAnnotation>;
    FText: string;
  public
    /// <summary>
    /// The annotations of the text output.
    /// </summary>
    property Annotations: TArray<TResponseMessageAnnotation> read FAnnotations write FAnnotations;

    /// <summary>
    /// The text output from the model.
    /// </summary>
    property Text: string read FText write FText;

    destructor Destroy; override;
  end;

  TResponseMessageRefusal = class(TResponseMessageContent)
  private
    FRefusal: string;
  public
    /// <summary>
    /// The refusal explanationfrom the model.
    /// </summary>
    property Refusal: string read FRefusal write FRefusal;
  end;

  {--- This class is made up of the following classes:
     TResponseMessageContentCommon,
     TResponseMessageContent,
     TResponseMessageRefusal }
  TResponseContent = class(TResponseMessageRefusal);

  TResponseReasoningSummary = class
  private
    FText: string;
    FType: string;
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
    FEffort: TReasoningEffort;
    FSummary: string;
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
    FRanker: string;
    [JsonNameAttribute('score_threshold')]
    FScoreThreshold: Double;
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
    FType: TResponseToolsFilterType;
  public
    /// <summary>
    /// Specifies the comparison operator or the type of operation
    /// </summary>
    property &Type: TResponseToolsFilterType read FType write FType;
  end;

  TResponseFileSearchFiltersComparaison = class(TResponseFileSearchFiltersCommon)
  private
    FKey: string;
    FValue: Variant;
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
    FFilters: TArray<TResponseFileSearchFiltersCompound>;
  public
    /// <summary>
    /// Array of filters to combine. Items can be ComparisonFilter or CompoundFilter.
    /// </summary>
    property Filters: TArray<TResponseFileSearchFiltersCompound> read FFilters write FFilters;

    destructor Destroy; override;
  end;

  {--- This class is made up of the following classes:
    TResponseFileSearchFiltersCommon,
    TResponseFileSearchFiltersComparaison,
    TResponseFileSearchFiltersCompound }
  TResponseFileSearchFilters = class(TResponseFileSearchFiltersCompound);

  TResponseWebSearchLocation = class
  private
    FType: string;
    FCity: string;
    FCountry: string;
    FRegion: string;
    FTimezone: string;
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

(******************************************************************************

  TResponseOutput :
  ================

  To enable optimal automatic deserialization, you need to set up a hierarchy
  of successive classes. However, this does make the code heavier if you want
  to maintain the wrapper’s overall architectural principles.

*******************************************************************************)

  TResponseOutputCommon = class
  private
    FId: string;
    FStatus: string;
    [JsonReflectAttribute(ctString, rtString, TResponseTypesInterceptor)]
    FType: TResponseTypes;
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
    FContent: TArray<TResponseContent>;
    [JsonReflectAttribute(ctString, rtString, TRoleInterceptor)]
    FRole: TRole;
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
    FQueries: TArray<string>;
    FResults: TArray<TFileSearchResult>;
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
    FArguments: string;
    [JsonNameAttribute('call_id')]
    FCallId: string;
    FName: string;
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
    {--- All fields are already described into ancestors }
  end;

  TResponseOutputComputer = class(TResponseOutputWebSearch)
  private
    {--- FCallId: string; already défined in TResponseOutputFunction }
    FAction: TComputerAction;
    [JsonNameAttribute('pending_safety_checks')]
    FPendingSafetyChecks: TArray<TPendingSafetyChecks>;
  public
    /// <summary>
    /// Action to execute on computer
    /// </summary>
    property Action: TComputerAction read FAction write FAction;

    /// <summary>
    /// The pending safety checks for the computer call.
    /// </summary>
    property PendingSafetyChecks: TArray<TPendingSafetyChecks> read FPendingSafetyChecks write FPendingSafetyChecks;

    destructor Destroy; override;
  end;

  TResponseOutputReasoning = class(TResponseOutputComputer)
  private
    FSummary: TArray<TResponseReasoningSummary>;
  public
    /// <summary>
    /// Reasoning text contents.
    /// </summary>
    property Summary: TArray<TResponseReasoningSummary> read FSummary write FSummary;

    destructor Destroy; override;
  end;

  TResponseOutputImageGeneration = class(TResponseOutputReasoning)
  private
    FResult: string;
  public
    function GetStream: TStream;

    procedure SaveToFile(const FileName: string);

    /// <summary>
    /// The generated image encoded in base64.
    /// </summary>
    property Result: string read FResult write FResult;
  end;

  TResponseOutputCodeInterpreter = class(TResponseOutputImageGeneration)
  private
    FCode: string;
    [JsonNameAttribute('container_id')]
    FContainerId: string;
    {
      FResults: intercepted by TResponseOutputFileSearch (property in common)
    }
  public
    /// <summary>
    /// The code to run.
    /// </summary>
    property Code: string read FCode write FCode;

    /// <summary>
    /// The ID of the container used to run the code.
    /// </summary>
    property ContainerId: string read FContainerId write FContainerId;
  end;

  TResponseOutputLocalShell = class(TResponseOutputCodeInterpreter)
    {
      FAction: intercepted by TResponseOutputComputer (property in common)
      FCallId: intercepted by TResponseOutputFunction (property in common)
    }
  end;

  TResponseOutputMCPTool = class(TResponseOutputLocalShell)
  private
    {
      FArguments: intercepted by TResponseOutputFunction (property in common)
    }
    [JsonNameAttribute('server_label')]
    FServerLabel: string;
    FError: string;
    FOutput: string;
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
    FTools: TArray<TMCPListTool>;
  public
    property Tools: TArray<TMCPListTool> read FTools write FTools;

    destructor Destroy; override;
  end;

  TResponseMCPApproval = class(TResponseOutputMCPList)
    {
      FArguments: intercepted by TResponseOutputFunction (property in common)
      FServerLabel: intercepted by TResponseOutputMCPTool (property in common)
    }
  end;

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
  TResponseOutput = class(TResponseMCPApproval);

(*
   End Output classes

 *****************************************************************************)

  TResponseTextFormatCommon = class
  private
    [JsonReflectAttribute(ctString, rtString, TResponseFormatTypeInterceptor)]
    FType: TResponseFormatType;
  public
    /// <summary>
    /// The type of response format being defined. One of text, json_schema, json_object
    /// </summary>
    property &Type: TResponseFormatType read FType write FType;
  end;

  TResponseFormatText = class(TResponseTextFormatCommon)
    {--- All fields are already described into ancestors }
  end;

  TResponseFormatJSONObject = class(TResponseFormatText)
    {--- All fields are already described into ancestors }
  end;

  TResponseFormatJSONSchema = class(TResponseFormatJSONObject)
  private
    FName: string;
    [JsonReflectAttribute(ctString, rtString, TMetadataInterceptor)]
    FSchema: string;
    FDescription: string;
    FStrict: Boolean;
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

  {--- This class is made up of the following classes:
    TResponseTextFormatCommon,
    TResponseFormatText,
    TResponseFormatJSONObject,
    TResponseFormatJSONSchema }
  TResponseTextFormat = class(TResponseFormatJSONSchema);

  TResponseText = class
  private
    FFormat: TResponseTextFormat;
  public
    /// <summary>
    /// An object specifying the format that the model must output.
    /// </summary>
    property Format: TResponseTextFormat read FFormat write FFormat;

    destructor Destroy; override;
  end;

  TResponseToolCommon = class
  private
    [JsonReflectAttribute(ctString, rtString, TResponseToolsTypeInterceptor)]
    FType: TResponseToolsType;
  public
    /// <summary>
    /// The type of the tool
    /// </summary>
    property &Type: TResponseToolsType read FType write FType;
  end;

  TResponseToolFileSearch = class(TResponseToolCommon)
  private
    [JsonNameAttribute('vector_store_ids')]
    FVectorStoreIds: TArray<string>;
    FFilters: TResponseFileSearchFilters;
    [JsonNameAttribute('max_num_results')]
    FMaxNumResults: Int64;
    [JsonNameAttribute('ranking_options')]
    FRankingOptions: TResponseRankingOptions;
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
    FName: string;
    [JsonReflectAttribute(ctString, rtString, TMetadataInterceptor)]
    FParameters: string;
    FStrict: Boolean;
    FDescription: string;
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
    FDisplayHeight: Int64;
    [JsonNameAttribute('display_width')]
    FDisplayWidth: Int64;
    FEnvironment: string;
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
    FSearchContextSize: TReasoningEffort;
    [JsonNameAttribute('user_location')]
    FUserLocation: TResponseWebSearchLocation;
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
    FServerLabel: string;
    [JsonNameAttribute('server_url')]
    FServerUrl: string;
    {
      [JsonNameAttribute('allowed_tools')]
      FAllowedTools: untreated;  -> polymorphic deserialization cannot be directly achieved
    }
    FHeaders: string;
    {
      [JsonNameAttribute('require_approval')]
      FRequireApproval: untreated; -> polymorphic deserialization cannot be directly achieved
    }
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
  private
    {
      FContainer: untreated; -> polymorphic deserialization cannot be directly achieved
    }
  public
  end;

  TInputImageMask = class
  private
    [JsonNameAttribute('file_id')]
    FFileId: string;
    [JsonNameAttribute('image_url')]
    FImageUrl: string;
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
    FBackground: string;
    [JsonNameAttribute('input_image_mask')]
    FInputImageMask: TInputImageMask;
    FModel: string;
    FModeration: string;
    [JsonNameAttribute('output_compression')]
    FOutputCompression: Int64;
    [JsonNameAttribute('output_format')]
    FOutputFormat: string;
    [JsonNameAttribute('partial_images')]
    FPartialImages: Int64;
    FQuality: string;
    FSize: string;
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
  private
  public
  end;

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
  TResponseTool = class(TResponseLocalShellTool);

  TInputTokensDetails = class
  private
    [JsonNameAttribute('cached_tokens')]
    FCachedTokens: Int64;
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
    FReasoningTokens: Int64;
  public
    /// <summary>
    /// The number of reasoning tokens.
    /// </summary>
    property ReasoningTokens: Int64 read FReasoningTokens write FReasoningTokens;
  end;

  TResponseUsage = class
  private
    [JsonNameAttribute('input_tokens')]
    FInputTokens: Int64;
    [JsonNameAttribute('input_tokens_details')]
    FInputTokensDetails: TInputTokensDetails;
    [JsonNameAttribute('output_tokens')]
    FOutputTokens: Int64;
    [JsonNameAttribute('output_tokens_details')]
    FOutputTokensDetails: TOutputTokensDetails;
    [JsonNameAttribute('total_tokens')]
    FTotalTokens: Int64;
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

  TResponse = class(TJSONFingerprint)
  private
    FBackground: Boolean;
    [JsonNameAttribute('created_at')]
    FCreatedAt: TInt64OrNull;
    FError: TResponseError;
    FId: string;
    [JsonNameAttribute('incomplete_details')]
    FIncompleteDetails: TResponseIncompleteDetails;
    FInstructions: string;
    [JsonNameAttribute('max_output_tokens')]
    FMaxOutputTokens: Int64;
    [JsonReflectAttribute(ctString, rtString, TMetadataInterceptor)]
    FMetadata: string;
    FModel: string;
    FObject: string;
    FOutput: TArray<TResponseOutput>;
    [JsonNameAttribute('parallel_tool_calls')]
    FParallelToolCalls: Boolean;
    [JsonNameAttribute('previous_response_id')]
    FPreviousResponseId: string;
    FReasoning: TResponseReasoning;
    [JsonNameAttribute('service_tier')]
    FServiceTier: string;
    [JsonReflectAttribute(ctString, rtString, TResponseStatusInterceptor)]
    FStatus: TResponseStatus;
    FTemperature: Double;
    FText: TResponseText;
    {--- tool_choice string or object :
          - polymorphic deserialization cannot be directly achieved
          - Access to field contents from JSONResponse string possible}
    FTools: TArray<TResponseTool>;
    [JsonNameAttribute('top_p')]
    FTopP: Double;
    FTruncation: string;
    FUsage: TResponseUsage;
    FUser: string;
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
    property Instructions: string read FInstructions write FInstructions;

    /// <summary>
    /// An upper bound for the number of tokens that can be generated for a response, including visible output tokens
    /// and reasoning tokens.
    /// </summary>
    property MaxOutputTokens: Int64 read FMaxOutputTokens write FMaxOutputTokens;

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
    /// o-series models only
    /// </summary>
    property Reasoning: TResponseReasoning read FReasoning write FReasoning;

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
    FId: string;
    FObject: string;
    FDeleted: Boolean;
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

(******************************************************************************

  Streaming events:
  ================

   Stream Chat Completions in real time. Receive chunks of completions returned
   from the model using server-sent events.

        - response.created
        - response.in_progress
        - response.completed
        - response.failed
        - response.incomplete
        - response.output_item.added
        - response.output_item.done
        - response.content_part.added
        - response.content_part.done
        - response.output_text.delta
        - response.output_text.annotation.added
        - response.output_text.done
        - response.refusal.delta
        - response.refusal.done
        - response.function_call_arguments.delta
        - response.function_call_arguments.done
        - response.file_search_call.in_progress
        - response.file_search_call.searching
        - response.file_search_call.completed
        - response.web_search_call.in_progress
        - response.web_search_call.searching
        - response.web_search_call.completed
        - response.reasoning_summary_part.added
        - response.reasoning_summary_part.done
        - response.reasoning_summary_text.delta
        - response.reasoning_summary_text.done
        - response.image_generation_call.completed
        - response.image_generation_call.generating
        - response.image_generation_call.in_progress
        - response.image_generation_call.partial_image
        - response.mcp_call.arguments.delta
        - response.mcp_call.arguments.done
        - response.mcp_call.completed
        - response.mcp_call.failed
        - response.mcp_call.in_progress
        - response.mcp_list_tools.completed
        - response.mcp_list_tools.failed
        - response.mcp_list_tools.in_progress
        - response.queued
        - response.reasoning.delta
        - response.reasoning.done
        - response.reasoning_summary.delta
        - response.reasoning_summary.done
        - error

*******************************************************************************)

  TResponseStreamingCommon = class(TJSONFingerprint)
  private
    [JsonReflectAttribute(ctString, rtString, TResponseStreamTypeInterceptor)]
    FType: TResponseStreamType;
    [JsonNameAttribute('sequence_number')]
    FSequenceNumber: Int64;
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
    FResponse: TResponse;
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
    {--- This class does not introduce any new functionality; all methods and properties
         are inherited from its ancestor. }
  end;

  /// <summary>
  /// response.failed : An event that is emitted when a response fails.
  /// </summary>
  TResponseFailed = class(TResponseCompleted)
    {--- This class does not introduce any new functionality; all methods and properties
         are inherited from its ancestor. }
  end;

  /// <summary>
  /// response.incomplete : An event that is emitted when a response finishes as incomplete.
  /// </summary>
  TResponseIncomplete = class(TResponseFailed)
    {--- This class does not introduce any new functionality; all methods and properties
         are inherited from its ancestor. }
  end;

  /// <summary>
  /// response.output_item.added : Emitted when a new output item is added.
  /// </summary>
  TResponseOutputItemAdded = class(TResponseIncomplete)
  private
    FItem: TResponseOutput;
    [JsonNameAttribute('output_index')]
    FOutputIndex: Integer;
  public
    property Item: TResponseOutput read FItem write FItem;

    property OutputIndex: Integer read FOutputIndex write FOutputIndex;

    destructor Destroy; override;
  end;

  /// <summary>
  /// response.output_item.done : Emitted when an output item is marked done.
  /// </summary>
  TResponseOutputItemDone = class(TResponseOutputItemAdded)
    {--- This class does not introduce any new functionality; all methods and properties
         are inherited from its ancestor. }
  end;

  /// <summary>
  /// response.content_part.added : Emitted when a new content part is added.
  /// </summary>
  TResponseContentpartAdded = class(TResponseOutputItemDone)
  private
    [JsonNameAttribute('content_index')]
    FContentIndex: Int64;
    [JsonNameAttribute('item_id')]
    FItemId: string;
    [JsonNameAttribute('output_index')]
    FOutputIndex: Int64;
    FPart: TResponseContent;
  public
    property ContentIndex: Int64 read FContentIndex write FContentIndex;

    property ItemId: string read FItemId write FItemId;

    property OutputIndex: Int64 read FOutputIndex write FOutputIndex;

    property Part: TResponseContent read FPart write FPart;

    destructor Destroy; override;
  end;

  /// <summary>
  /// response.content_part.done : Emitted when a content part is done.
  /// </summary>
  TResponseContentpartDone = class(TResponseContentpartAdded)
    {--- This class does not introduce any new functionality; all methods and properties
         are inherited from its ancestor. }
  end;

  /// <summary>
  /// response.output_text.delta : Emitted when there is an additional text delta.
  /// </summary>
  TResponseOutputTextDelta = class(TResponseContentpartDone)
  private
    FDelta: string;
  public
    property Delta: string read FDelta write FDelta;
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
    property AnnotationIndex: Int64 read FAnnotationIndex write FAnnotationIndex;

    property Annotation: TResponseMessageAnnotation read FAnnotation write FAnnotation;

    destructor Destroy; override;
  end;

  /// <summary>
  /// response.output_text.done : Emitted when text content is finalized.
  /// </summary>
  TResponseOutputTextDone = class(TResponseOutputTextAnnotationAdded)
  private
    FText: string;
  public
    property Text: string read FText write FText;
  end;

  /// <summary>
  /// response.refusal.delta : Emitted when there is a partial refusal text.
  /// </summary>
  TResponseRefusalDelta = class(TResponseOutputTextDone)
    {--- This class does not introduce any new functionality; all methods and properties
         are inherited from its ancestor. }
  end;

  /// <summary>
  /// response.refusal.done : Emitted when refusal text is finalized.
  /// </summary>
  TResponseRefusalDone = class(TResponseRefusalDelta)
  private
    FRefusal: string;
  public
    property Refusal: string read FRefusal write FRefusal;
  end;

  /// <summary>
  /// response.function_call_arguments.delta : Emitted when there is a partial function-call arguments delta.
  /// </summary>
  TResponseFunctionCallArgumentsDelta = class(TResponseRefusalDone)
    {--- This class does not introduce any new functionality; all methods and properties
         are inherited from its ancestor. }
  end;

  /// <summary>
  /// response.function_call_arguments.done : Emitted when function-call arguments are finalized.
  /// </summary>
  TResponseFunctionCallArgumentsDone = class(TResponseFunctionCallArgumentsDelta)
  private
    FArguments: string;
  public
    property Arguments: string read FArguments write FArguments;
  end;

  /// <summary>
  /// response.file_search_call.in_progress : Emitted when a file search call is initiated.
  /// </summary>
  TResponseFileSearchCallInprogress = class(TResponseFunctionCallArgumentsDone)
    {--- This class does not introduce any new functionality; all methods and properties
         are inherited from its ancestor. }
  end;

  /// <summary>
  /// response.file_search_call.searching : Emitted when a file search is currently searching.
  /// </summary>
  TResponseFileSearchCallSearching = class(TResponseFileSearchCallInprogress)
    {--- This class does not introduce any new functionality; all methods and properties
         are inherited from its ancestor. }
  end;

  /// <summary>
  /// response.file_search_call.completed : Emitted when a file search call is completed (results found).
  /// </summary>
  TResponseFileSearchCallCompleted = class(TResponseFileSearchCallSearching)
    {--- This class does not introduce any new functionality; all methods and properties
         are inherited from its ancestor. }
  end;

  /// <summary>
  /// response.web_search_call.in_progress : Emitted when a web search call is initiated.
  /// </summary>
  TResponseWebSearchCallInprogress = class(TResponseFileSearchCallCompleted)
    {--- This class does not introduce any new functionality; all methods and properties
         are inherited from its ancestor. }
  end;

  /// <summary>
  /// response.web_search_call.searching : Emitted when a web search call is executing.
  /// </summary>
  TResponseWebSearchCallSearching = class(TResponseWebSearchCallInprogress)
    {--- This class does not introduce any new functionality; all methods and properties
         are inherited from its ancestor. }
  end;

  /// <summary>
  /// response.web_search_call.completed : Emitted when a web search call is completed.
  /// </summary>
  TResponseWebSearchCallCompleted = class(TResponseWebSearchCallSearching)
    {--- This class does not introduce any new functionality; all methods and properties
         are inherited from its ancestor. }
  end;

  TResponseReasoningSummaryPartAdded = class(TResponseWebSearchCallCompleted)
  private
    [JsonNameAttribute('summary_index')]
    FSummaryIndex: Int64;
  public
    property SummaryIndex: Int64 read FSummaryIndex write FSummaryIndex;
  end;

  TResponseReasoningSummaryPartDone = class(TResponseReasoningSummaryPartAdded)
    {--- This class does not introduce any new functionality; all methods and properties
         are inherited from its ancestor. }
  end;

  TResponseReasoningSummaryTextDelta = class(TResponseReasoningSummaryPartDone)
    {--- This class does not introduce any new functionality; all methods and properties
         are inherited from its ancestor. }
  end;

  TResponseReasoningSummaryTextDone = class(TResponseReasoningSummaryTextDelta)
    {--- This class does not introduce any new functionality; all methods and properties
         are inherited from its ancestor. }
  end;

  TResponseImageGenerationCallCompleted = class(TResponseReasoningSummaryTextDone)
    {--- This class does not introduce any new functionality; all methods and properties
         are inherited from its ancestor. }
  end;

  TResponseImageGenerationCallGenerating = class(TResponseImageGenerationCallCompleted)
    {--- This class does not introduce any new functionality; all methods and properties
         are inherited from its ancestor. }
  end;

  TResponseImageGenerationCallInProgress = class(TResponseImageGenerationCallGenerating)
    {--- This class does not introduce any new functionality; all methods and properties
         are inherited from its ancestor. }
  end;

  TResponseImageGenerationCallPartialImage = class(TResponseImageGenerationCallInProgress)
  private
    [JsonNameAttribute('partial_image_b64')]
    FPartialImageB64: string;
    [JsonNameAttribute('partial_image_index')]
    FPartialImageIndex: Int64;
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

  TResponseMcpCallArgumentsDelta = class(TResponseImageGenerationCallPartialImage)
  private
    {---
         FDelta: object > Automatic deserialization not possible-
            ambiguous definition and field name already used as string

         Access to field contents from JSONResponse string possible
    }
  end;

  TResponseMcpCallArgumentsDone = class(TResponseMcpCallArgumentsDelta)
  private
    {---
         FArguments: object > Automatic deserialization not possible
            ambiguous definition and field name already used as string

         Access to field contents from JSONResponse string possible
    }
  end;

  TResponseMcpCallCompleted = class(TResponseMcpCallArgumentsDone)
    {--- This class does not introduce any new functionality; all methods and properties
         are inherited from its ancestor. }
  end;

  TResponseMcpCallFailed = class(TResponseMcpCallCompleted)
    {--- This class does not introduce any new functionality; all methods and properties
         are inherited from its ancestor. }
  end;

  TResponseMcpCallInProgress = class(TResponseMcpCallFailed)
    {--- This class does not introduce any new functionality; all methods and properties
         are inherited from its ancestor. }
  end;

  TResponseMcpListToolsCompleted = class(TResponseMcpCallInProgress)
    {--- This class does not introduce any new functionality; all methods and properties
         are inherited from its ancestor. }
  end;

  TResponseMcpListToolsFailed = class(TResponseMcpListToolsCompleted)
    {--- This class does not introduce any new functionality; all methods and properties
         are inherited from its ancestor. }
  end;

  TResponseMcpListToolsInProgress = class(TResponseMcpListToolsFailed)
    {--- This class does not introduce any new functionality; all methods and properties
         are inherited from its ancestor. }
  end;

  TResponseQueued = class(TResponseMcpListToolsInProgress)
    {--- This class does not introduce any new functionality; all methods and properties
         are inherited from its ancestor. }
  end;

  TResponseReasoningDelta = class(TResponseQueued)
  private
    {---
         FDelta: object > Automatic deserialization not possible-
            ambiguous definition and field name already used as string

         Access to field contents from JSONResponse string possible
    }
  end;

  TResponseReasoningDone = class(TResponseReasoningDelta)
    {--- This class does not introduce any new functionality; all methods and properties
         are inherited from its ancestor. }
  end;

  TResponseReasoningSummaryDelta = class(TResponseReasoningDone)
    {---
         FDelta: object > Automatic deserialization not possible-
            ambiguous definition and field name already used as string

         Access to field contents from JSONResponse string possible
    }
  end;

  TResponseReasoningSummaryDone = class(TResponseReasoningSummaryDelta)
    {--- This class does not introduce any new functionality; all methods and properties
         are inherited from its ancestor. }
  end;

  /// <summary>
  /// response.error: Emitted when an error occurs.
  /// </summary>
  TResponseStreamError = class(TResponseReasoningSummaryDone)
  private
    FCode: string;
    FMessage: string;
    FParam: string;
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
     TResponseOutputTextAnnotationAdded,
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
     TResponseQueued,
     TResponseReasoningDelta,
     TResponseReasoningDone,
     TResponseReasoningSummaryDelta,
     TResponseReasoningSummaryDone,
     TResponseStreamError }
  TResponseStream = class(TResponseStreamError);

(*
    End streaming Events

 ******************************************************************************)

implementation

{ TResponseMessageContent }

destructor TResponseMessageContent.Destroy;
begin
  for var Item in FAnnotations do
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

{ TResponseOutputTextAnnotationAdded }

destructor TResponseOutputTextAnnotationAdded.Destroy;
begin
  if Assigned(FAnnotation) then
    FAnnotation.Free;
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

end.
