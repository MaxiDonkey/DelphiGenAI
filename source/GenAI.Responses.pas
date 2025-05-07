unit GenAI.Responses;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGenAI
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.SysUtils, System.Classes, System.Threading, System.JSON, REST.Json.Types,
  REST.JsonReflect, REST.Json,
  GenAI.API.Params, GenAI.API, GenAI.Consts, GenAI.Schema, GenAI.Types,
  GenAI.Async.Params, GenAI.Async.Support, GenAI.Assistants, GenAI.Functions.Core,
  GenAI.Responses.InputParams, GenAI.Responses.InputItemList, GenAI.Chat.Parallel;

type
  TReasoningParams = class(TJSONParam)
  public
    /// <summary>
    /// Constrains effort on reasoning for reasoning models. Currently supported values are low, medium, and high.
    /// Reducing reasoning effort can result in faster responses and fewer tokens used on reasoning in a response.
    /// </summary>
    /// <remarks>
    /// o-series models only
    /// </remarks>
    function Effort(const Value: TReasoningEffort): TReasoningParams; overload;
    /// <summary>
    /// Constrains effort on reasoning for reasoning models. Currently supported values are low, medium, and high.
    /// Reducing reasoning effort can result in faster responses and fewer tokens used on reasoning in a response.
    /// </summary>
    /// <remarks>
    /// o-series models only
    /// </remarks>
    function Effort(const Value: string): TReasoningParams; overload;
    /// <summary>
    /// A summary of the reasoning performed by the model. This can be useful for debugging and understanding the
    /// model's reasoning process. One of concise or detailed.
    /// </summary>
    function Summary(const Value: TReasoningGenerateSummary): TReasoningParams; overload;
    /// <summary>
    /// A summary of the reasoning performed by the model. This can be useful for debugging and understanding the
    /// model's reasoning process. One of concise or detailed.
    /// </summary>
    function Summary(const Value: string): TReasoningParams; overload;

    class function New: TReasoningParams;
  end;

  /// <summary>
  /// Value is TTextFormatParams or his descendant e.g. TTextFormatTextPrams, TTextJSONSchemaParams, TTextJSONObjectParams,
  /// TTextParams
  /// </summary>
  TTextFormatParams = class(TJSONParam);

  TTextFormatTextPrams = class(TTextFormatParams)
  public
    /// <summary>
    /// The type of response format being defined. Always text.
    /// </summary>
    function &Type(const Value: string = 'text'): TTextFormatTextPrams;

    class function New: TTextFormatTextPrams;
  end;

  TTextJSONSchemaParams = class(TTextFormatParams)
  public
    /// <summary>
    /// A description of what the response format is for, used by the model to determine how to respond in the format.
    /// </summary>
    function Description(const Value: string): TTextJSONSchemaParams;
    /// <summary>
    /// The name of the response format. Must be a-z, A-Z, 0-9, or contain underscores and dashes, with a maximum length of 64.
    /// </summary>
    function Name(const Value: string): TTextJSONSchemaParams;
    /// <summary>
    /// The schema for the response format, described as a JSON Schema object. Learn how to build JSON schemas here.
    /// </summary>
    function Schema(const Value: TSchemaParams): TTextJSONSchemaParams; overload;
    /// <summary>
    /// The schema for the response format, described as a JSON Schema object. Learn how to build JSON schemas here.
    /// </summary>
    function Schema(const Value: string): TTextJSONSchemaParams; overload;
    /// <summary>
    /// Whether to enable strict schema adherence when generating the output. If set to true, the model will always
    /// follow the exact schema defined in the schema field. Only a subset of JSON Schema is supported when strict
    /// is true.
    /// </summary>
    function Strict(const Value: Boolean): TTextJSONSchemaParams;
    /// <summary>
    /// The type of response format being defined. Always json_schema.
    /// </summary>
    function &Type(const Value: string = 'json_schema'): TTextJSONSchemaParams;

    class function New: TTextJSONSchemaParams;
  end;

  TTextJSONObjectParams = class(TTextFormatParams)
  public
    /// <summary>
    /// The type of response format being defined. Always json_object.
    /// </summary>
    function &Type(const Value: string = 'json_object'): TTextJSONObjectParams;

    class function New: TTextJSONObjectParams;
  end;

  TTextParams = class(TJSONParam)
  public
    /// <summary>
    /// An object specifying the format that the model must output.
    /// <para>
    /// - Configuring { "type": "json_schema" } enables Structured Outputs,
    /// which ensures the model will match your supplied JSON schema.
    /// </para>
    /// <para>
    /// - The default format is { "type": "text" } with no additional options.
    /// </para>
    /// <para>
    /// - Not recommended for gpt-4o and newer models:
    /// Setting to { "type": "json_object" } enables the older JSON mode, which ensures the message the model generates
    /// is valid JSON. Using json_schema is preferred for models that support it.
    /// </para>
    /// </summary>
    function Format(const Value: TTextFormatParams): TTextParams;
  end;

  /// <summary>
  /// Value is TResponseToolChoiceParams or his descendant e.g. THostedToolParams, TFunctionToolParams
  /// </summary>
  TResponseToolChoiceParams = class(TJSONParam);

  THostedToolParams = class(TResponseToolChoiceParams)
  public
    /// <summary>
    /// The type of hosted tool the model should to use. Learn more about built-in tools.
    /// <para>
    /// Allowed values are:
    /// </para>
    /// <para>
    /// - file_search
    /// </para>
    /// <para>
    /// - web_search_preview
    /// </para>
    /// <para>
    /// - computer_use_preview
    /// </para>
    /// </summary>
    function &Type(const Value: THostedTooltype): THostedToolParams; overload;
    /// <summary>
    /// The type of hosted tool the model should to use. Learn more about built-in tools.
    /// <para>
    /// Allowed values are:
    /// </para>
    /// <para>
    /// - file_search
    /// </para>
    /// <para>
    /// - web_search_preview
    /// </para>
    /// <para>
    /// - computer_use_preview
    /// </para>
    /// </summary>
    function &Type(const Value: string): THostedToolParams; overload;

    class function New(const Value: string): THostedToolParams;
  end;

  TFunctionToolParams = class(TResponseToolChoiceParams)
  public
    /// <summary>
    /// The name of the function to call.
    /// </summary>
    function Name(const Value: string): TFunctionToolParams;
    /// <summary>
    /// For function calling, the type is always function.
    /// </summary>
    function &Type(const Value: string = 'function'): TFunctionToolParams;

    class function New: TFunctionToolParams;
  end;

  /// <summary>
  /// Value is TFileSearchFilters or his descendant e.g. TComparisonFilter, TCompoundFilter
  /// </summary>
  TFileSearchFilters = class(TJSONParam);

  TComparisonFilter = class(TFileSearchFilters)
  public
    /// <summary>
    /// The key to compare against the value.
    /// </summary>
    function Key(const Value: string): TComparisonFilter;
    /// <summary>
    /// Specifies the comparison operator: eq, ne, gt, gte, lt, lte.
    /// </summary>
    /// <remarks>
    /// <para>
    /// - eq: equals
    /// </para>
    /// <para>
    /// - ne: not equal
    /// </para>
    /// <para>
    /// - gt: greater than
    /// </para>
    /// <para>
    /// - gte: greater than or equal
    /// </para>
    /// <para>
    /// - lt: less than
    /// </para>
    /// <para>
    /// - lte: less than or equal
    /// </para>
    /// </remarks>
    function &Type(const Value: TComparisonFilterType): TComparisonFilter; overload;
    /// <summary>
    /// Specifies the comparison operator: eq, ne, gt, gte, lt, lte.
    /// </summary>
    /// <remarks>
    /// <para>
    /// - eq: equals
    /// </para>
    /// <para>
    /// - ne: not equal
    /// </para>
    /// <para>
    /// - gt: greater than
    /// </para>
    /// <para>
    /// - gte: greater than or equal
    /// </para>
    /// <para>
    /// - lt: less than
    /// </para>
    /// <para>
    /// - lte: less than or equal
    /// </para>
    /// </remarks>
    function &Type(const Value: string): TComparisonFilter; overload;
    /// <summary>
    /// Uses text for comparison
    /// <para>
    /// equals for eq, notEqual for ne, greaterThan for gt, greaterThanOrEqual for gte, lessThan for lt, lessThanOrEqual for lte
    /// </para>
    /// </summary>
    function Comparison(const Value: string): TComparisonFilter;
    /// <summary>
    /// The value to compare against the attribute key; supports string, number, or boolean types.
    /// </summary>
    function Value(const Value: string): TComparisonFilter; overload;
    /// <summary>
    /// The value to compare against the attribute key; supports string, number, or boolean types.
    /// </summary>
    function Value(const Value: Integer): TComparisonFilter; overload;
    /// <summary>
    /// The value to compare against the attribute key; supports string, number, or boolean types.
    /// </summary>
    function Value(const Value: Double): TComparisonFilter; overload;
    /// <summary>
    /// The value to compare against the attribute key; supports string, number, or boolean types.
    /// </summary>
    function Value(const Value: Boolean): TComparisonFilter; overload;

    class function New: TComparisonFilter; overload;
    class function New(const Key, Comparison, Value: string): TComparisonFilter; overload;
    class function New(const Key, Comparison: string; const Value: Integer): TComparisonFilter; overload;
    class function New(const Key, Comparison: string; const Value: Double): TComparisonFilter; overload;
    class function New(const Key, Comparison: string; const Value: Boolean): TComparisonFilter; overload;
  end;

  TCompoundFilter = class(TFileSearchFilters)
  public
    /// <summary>
    /// Type of operation: and or or.
    /// </summary>
    function &Type(const Value: TCompoundFilterType): TCompoundFilter;
    function &And: TCompoundFilter; overload;
    function &Or: TCompoundFilter; overload;
    /// <summary>
    /// Array of filters to combine. Items can be ComparisonFilter or CompoundFilter.
    /// </summary>
    function Filters(const Value: TArray<TFileSearchFilters>): TCompoundFilter;

    class function New: TCompoundFilter;
    class function &And(const Value: TArray<TFileSearchFilters>): TCompoundFilter; overload;
    class function &Or(const Value: TArray<TFileSearchFilters>): TCompoundFilter; overload;
  end;

  /// <summary>
  /// Value is TResponseToolParams or his descendant e.g. TResponseFileSearchParams, TResponseFunctionParams,
  /// TResponseComputerUseParams, TResponseWebSearchParams
  /// </summary>
  TResponseToolParams = class(TJSONParam);

  TResponseFileSearchParams = class(TResponseToolParams)
  public
    /// <summary>
    /// The IDs of the vector stores to search.
    /// </summary>
    function VectorStoreIds(const Value: TArray<string>): TResponseFileSearchParams;
    /// <summary>
    /// A filter to apply based on file attributes.
    /// </summary>
    /// <remarks>
    /// Value is TFileSearchFilters or his descendant e.g. TComparisonFilter, TCompoundFilter
    /// </remarks>
    function Filters(const Value: TFileSearchFilters): TResponseFileSearchParams;
    /// <summary>
    /// The maximum number of results to return. This number should be between 1 and 50 inclusive
    /// </summary>
    function MaxNumResults(const Value: Integer): TResponseFileSearchParams;
    /// <summary>
    /// Ranking options for search.
    /// </summary>
    function RankingOptions(const Value: TRankingOptionsParams): TResponseFileSearchParams;
    /// <summary>
    /// The type of the file search tool. Always file_search.
    /// </summary>
    function &Type(const Value: string = 'file_search'): TResponseFileSearchParams;

    class function New: TResponseFileSearchParams;
  end;

  TResponseFunctionParams = class(TResponseToolParams)
  public
    /// <summary>
    /// A description of the function. Used by the model to determine whether or not to call the function.
    /// </summary>
    function Description(const Value: string): TResponseFunctionParams;
    /// <summary>
    /// The name of the function to call.
    /// </summary>
    function Name(const Value: string): TResponseFunctionParams;
    /// <summary>
    /// A JSON schema object describing the parameters of the function.
    /// </summary>
    function Parameters(const Value: TSchemaParams): TResponseFunctionParams; overload;
    /// <summary>
    /// A JSON schema object describing the parameters of the function.
    /// </summary>
    function Parameters(const Value: string): TResponseFunctionParams; overload;
    /// <summary>
    /// Whether to enforce strict parameter validation. Default true.
    /// </summary>
    function Strict(const Value: Boolean): TResponseFunctionParams;
    /// <summary>
    /// The type of the function tool. Always function.
    /// </summary>
    function &Type(const Value: string = 'function'): TResponseFunctionParams;

    class function New: TResponseFunctionParams; overload;
    class function New(const Value: IFunctionCore): TResponseFunctionParams; overload;
  end;

  TResponseComputerUseParams = class(TResponseToolParams)
  public
    /// <summary>
    /// The height of the computer display
    /// </summary>
    function DisplayHeight(const Value: Integer): TResponseComputerUseParams;
    /// <summary>
    /// The width of the computer display.
    /// </summary>
    function DisplayWidth(const Value: Integer): TResponseComputerUseParams;
    /// <summary>
    /// The type of computer environment to control.
    /// </summary>
    function Environment(const Value: string): TResponseComputerUseParams;
    /// <summary>
    /// The type of the computer use tool. Always computer_use_preview.
    /// </summary>
    function &Type(const Value: string = 'computer_use_preview'): TResponseComputerUseParams;

    class function New: TResponseComputerUseParams;
  end;

  TResponseUserLocationParams = class(TJSONParam)
  public
    /// <summary>
    /// Free text input for the city of the user, e.g. San Francisco.
    /// </summary>
    function City(const Value: string): TResponseUserLocationParams;
    /// <summary>
    /// The two-letter ISO country code of the user, e.g. US.
    /// </summary>
    function Country(const Value: string): TResponseUserLocationParams;
    /// <summary>
    /// Free text input for the region of the user, e.g. California.
    /// </summary>
    function Region(const Value: string): TResponseUserLocationParams;
    /// <summary>
    /// The IANA timezone of the user, e.g. America/Los_Angeles.
    /// </summary>
    function Timezone(const Value: string): TResponseUserLocationParams;
    /// <summary>
    /// The type of location approximation. Always approximate.
    /// </summary>
    function &Type(const Value: string = 'approximate'): TResponseUserLocationParams;

    class function New: TResponseUserLocationParams;
  end;

  TResponseWebSearchParams = class(TResponseToolParams)
  public
    /// <summary>
    /// High level guidance for the amount of context window space to use for the search.
    /// One of low, medium, or high. medium is the default.
    /// </summary>
    function SearchContextSize(const Value: TSearchWebOptions): TResponseWebSearchParams; overload;
    /// <summary>
    /// High level guidance for the amount of context window space to use for the search.
    /// One of low, medium, or high. medium is the default.
    /// </summary>
    function SearchContextSize(const Value: string = 'medium'): TResponseWebSearchParams; overload;
    /// <summary>
    /// Approximate location parameters for the search.
    /// </summary>
    function UserLocation(const Value: TResponseUserLocationParams): TResponseWebSearchParams;
    /// <summary>
    /// The type of the web search tool. One of:
    /// <para>
    /// - web_search_preview
    /// </para>
    /// <para>
    /// - web_search_preview_2025_03_11
    /// </para>
    /// </summary>
    function &Type(const Value: TWebSearchType): TResponseWebSearchParams; overload;
    /// <summary>
    /// The type of the web search tool. One of:
    /// <para>
    /// - web_search_preview
    /// </para>
    /// <para>
    /// - web_search_preview_2025_03_11
    /// </para>
    /// </summary>
    function &Type(const Value: string = 'web_search_preview'): TResponseWebSearchParams; overload;

    class function New: TResponseWebSearchParams;
  end;

  TResponsesParams = class(TJSONParam)
  public
    /// <summary>
    /// Text, image, or file inputs to the model, used to generate a response.
    /// </summary>
    function Input(const Value: string): TResponsesParams; overload;
    /// <summary>
    /// Text, image, or file inputs to the model, used to generate a response.
    /// </summary>
    /// <param name="Value">
    /// Value is TInputListItem or his descendant e.g. TInputMessage, TItemInputMessage, TItemOutputMessage,
    /// TItemOutputMessage, TFileSearchToolCall, TComputerToolCall
    /// </param>
    function Input(const Value: TArray<TInputListItem>): TResponsesParams; overload;
    /// <summary>
    /// Text, image, or file inputs to the model, used to generate a response.
    /// </summary>
    /// <param name="Value">
    /// Value is TJSONArray
    /// </param>
    function Input(const Value: TJSONArray): TResponsesParams; overload;
    /// <summary>
    /// Method to create a user default role message payload with multiple document references
    /// (images and/or PDF)-local or distant documents.
    /// </summary>
    /// <param name="Content">
    /// The main content of the user message.
    /// </param>
    /// <param name="Docs">
    /// An array of document paths to include. Only for images.
    /// </param>
    function Input(const Content: string; const Docs: TArray<string>; const Role: string = 'user'): TResponsesParams; overload;
    /// <summary>
    /// Model ID used to generate the response, like gpt-4o or o1. OpenAI offers a wide range of models
    /// with different capabilities, performance characteristics, and price points. Refer to the model
    /// guide to browse and compare available models.
    /// </summary>
    function Model(const Value: string): TResponsesParams;
    /// <summary>
    /// Specify additional output data to include in the model response. Currently supported values are:
    /// <para>
    /// file_search_call.results: Include the search results of the file search tool call.
    /// </para>
    /// <para>
    /// message.input_image.image_url: Include image urls from the input message.
    /// </para>
    /// <para>
    /// computer_call_output.output.image_url: Include image urls from the computer call output.
    /// </para>
    /// </summary>
    function Include(const Value: TArray<TOutputIncluding>): TResponsesParams; overload;
    /// <summary>
    /// Specify additional output data to include in the model response. Currently supported values are:
    /// <para>
    /// file_search_call.results: Include the search results of the file search tool call.
    /// </para>
    /// <para>
    /// message.input_image.image_url: Include image urls from the input message.
    /// </para>
    /// <para>
    /// computer_call_output.output.image_url: Include image urls from the computer call output.
    /// </para>
    /// </summary>
    function Include(const Value: TArray<string>): TResponsesParams; overload;
    /// <summary>
    /// Inserts a system (or developer) message as the first item in the model's context.
    /// </summary>
    /// <remarks>
    /// When using along with previous_response_id, the instructions from a previous response will not be carried
    /// over to the next response. This makes it simple to swap out system (or developer) messages in new responses.
    /// </remarks>
    function Instructions(const Value: string): TResponsesParams;
    /// <summary>
    /// An upper bound for the number of tokens that can be generated for a response, including visible output tokens
    /// and reasoning tokens.
    /// </summary>
    function MaxOutputTokens(const Value: Integer): TResponsesParams;
    /// <summary>
    /// Set of 16 key-value pairs that can be attached to an object. This can be useful for storing additional information
    /// about the object in a structured format, and querying for objects via API or the dashboard.
    /// </summary>
    /// <remarks>
    /// Keys are strings with a maximum length of 64 characters. Values are strings with a maximum length of 512 characters.
    /// </remarks>
    function Metadata(const Value: TJSONObject): TResponsesParams;
    /// <summary>
    /// Whether to allow the model to run tool calls in parallel.
    /// </summary>
    function ParallelToolCalls(const Value: Boolean): TResponsesParams;
    /// <summary>
    /// The unique ID of the previous response to the model. Use this to create multi-turn conversations. Learn more about
    /// conversation state.
    /// </summary>
    function PreviousResponseId(const Value: string): TResponsesParams;
    /// <summary>
    /// o-series models only. Configuration options for reasoning models.
    /// </summary>
    function Reasoning(const Value: TReasoningParams): TResponsesParams; overload;
    /// <summary>
    /// o-series models only. Configuration options for reasoning models.
    /// </summary>
    function Reasoning(const Value: string): TResponsesParams; overload;
    /// <summary>
    /// Whether to store the generated model response for later retrieval via API.
    /// </summary>
    function Store(const Value: Boolean = True): TResponsesParams;
    /// <summary>
    /// if set to true, the model response data will be streamed to the client as it is generated using server-sent events.
    /// </summary>
    function Stream(const Value: Boolean = True): TResponsesParams;
    /// <summary>
    /// What sampling temperature to use, between 0 and 2. Higher values like 0.8 will make the output more random, while
    /// lower values like 0.2 will make it more focused and deterministic. We generally recommend altering this or top_p
    /// but not both.
    /// </summary>
    function Temperature(const Value: Double): TResponsesParams;
    /// <summary>
    /// Configuration options for a text response from the model. Can be plain text or structured JSON data. Learn more:
    /// <para>
    /// - Text inputs and outputs https://platform.openai.com/docs/guides/text
    /// </para>
    /// <para>
    /// - Structured Outputs https://platform.openai.com/docs/guides/structured-outputs
    /// </para>
    /// </summary>
    function Text(const Value: TTextParams): TResponsesParams; overload;
    /// <summary>
    /// Configuration options for a text response from the model. Can be plain text or structured JSON data. Learn more:
    /// <para>
    /// - Text inputs and outputs https://platform.openai.com/docs/guides/text
    /// </para>
    /// <para>
    /// - Structured Outputs https://platform.openai.com/docs/guides/structured-outputs
    /// </para>
    /// </summary>
    /// <remarks>
    /// Value is TTextFormatParams or his descendant e.g. TTextFormatTextPrams, TTextJSONSchemaParams, TTextJSONObjectParams,
    /// TTextParams
    /// </remarks>
    function Text(const Value: TTextFormatParams): TResponsesParams; overload;
    /// <summary>
    /// Configuration options for a text response from the model. Can be plain text or structured JSON data. Learn more:
    /// <para>
    /// - Text inputs and outputs https://platform.openai.com/docs/guides/text
    /// </para>
    /// <para>
    /// - Structured Outputs https://platform.openai.com/docs/guides/structured-outputs
    /// </para>
    /// </summary>
    function Text(const Value: string; const SchemaParams: TTextJSONSchemaParams = nil): TResponsesParams; overload;
    /// <summary>
    /// Configuration options for a text response from the model. Can be plain text or structured JSON data. Learn more:
    /// <para>
    /// - Text inputs and outputs https://platform.openai.com/docs/guides/text
    /// </para>
    /// <para>
    /// - Structured Outputs https://platform.openai.com/docs/guides/structured-outputs
    /// </para>
    /// </summary>
    function Text(const Value: TResponseOption; const SchemaParams: TTextJSONSchemaParams = nil): TResponsesParams; overload;
    /// <summary>
    /// How the model should select which tool (or tools) to use when generating a response. See the tools parameter
    /// to see how to specify which tools the model can call.
    /// </summary>
    function ToolChoice(const Value: TToolChoice): TResponsesParams; overload;
    /// <summary>
    /// How the model should select which tool (or tools) to use when generating a response. See the tools parameter
    /// to see how to specify which tools the model can call.
    /// </summary>
    /// <remarks>
    /// Controls which (if any) tool is called by the model.
    /// <para>
    /// - none means the model will not call any tool and instead generates a message.
    /// </para>
    /// <para>
    /// - auto means the model can pick between generating a message or calling one or more tools.
    /// </para>
    /// <para>
    /// - required means the model must call one or more tools.
    /// </para>
    /// </remarks>
    function ToolChoice(const Value: string): TResponsesParams; overload;
    /// <summary>
    /// How the model should select which tool (or tools) to use when generating a response. See the tools parameter
    /// to see how to specify which tools the model can call.
    /// </summary>
    /// <remarks>
    /// Value is TResponseToolChoiceParams or his descendant e.g. THostedToolParams, TFunctionToolParams
    /// </remarks>
    function ToolChoice(const Value: TResponseToolChoiceParams): TResponsesParams; overload;
    /// <summary>
    /// An array of tools the model may call while generating a response. You can specify which tool to use by setting
    /// the tool_choice parameter.
    /// <para>
    /// The two categories of tools you can provide the model are:
    /// </para>
    /// <para>
    /// - Built-in tools: Tools that are provided by OpenAI that extend the model's capabilities, like web search or
    /// file search. Learn more about built-in tools.
    /// </para>
    /// <para>
    /// - Function calls (custom tools): Functions that are defined by you, enabling the model to call your own code.
    /// Learn more about function calling.
    /// </para>
    /// </summary>
    /// <remarks>
    /// The descendant avalaible for then TResponseToolParams class are :
    /// <para>
    /// - TResponseFileSearchParams, TResponseFunctionParams, TResponseComputerUseParams, TResponseWebSearchParams
    /// </para>
    /// </remarks>
    function Tools(const Value: TArray<TResponseToolParams>): TResponsesParams; overload;
    /// <summary>
    /// An alternative to sampling with temperature, called nucleus sampling, where the model considers the results of
    /// the tokens with top_p probability mass. So 0.1 means only the tokens comprising the top 10% probability mass
    /// are considered.
    /// </summary>
    /// <remarks>
    /// We generally recommend altering this or temperature but not both.
    /// </remarks>
    function TopP(const Value: Double): TResponsesParams;
    /// <summary>
    /// The truncation strategy to use for the model response.
    /// </summary>
    /// <remarks>
    /// <para>
    /// - auto: If the context of this response and previous ones exceeds the model's context window size, the model
    /// will truncate the response to fit the context window by dropping input items in the middle of the conversation.
    /// </para>
    /// <para>
    /// - disabled (default): If a model response will exceed the context window size for a model, the request will fail
    /// with a 400 error.
    /// </para>
    /// </remarks>
    function Truncation(const Value: TResponseTruncationType): TResponsesParams; overload;
    /// <summary>
    /// The truncation strategy to use for the model response.
    /// </summary>
    /// <remarks>
    /// <para>
    /// - auto: If the context of this response and previous ones exceeds the model's context window size, the model
    /// will truncate the response to fit the context window by dropping input items in the middle of the conversation.
    /// </para>
    /// <para>
    /// - disabled (default): If a model response will exceed the context window size for a model, the request will fail
    /// with a 400 error.
    /// </para>
    /// </remarks>
    function Truncation(const Value: string): TResponsesParams; overload;
    /// <summary>
    /// A unique identifier representing your end-user, which can help OpenAI to monitor and detect abuse. Learn more.
    /// </summary>
    function User(const Value: string): TResponsesParams;
  end;

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
     TResponseMessageContentCommon, TResponseMessageContent, TResponseMessageRefusal }
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
    TResponseFileSearchFiltersCommon, TResponseFileSearchFiltersComparaison,
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

  {--- This class is made up of the following classes:
    TResponseOutputCommon, TResponseOutputMessage, TResponseOutputFileSearch, TResponseOutputFunction,
    TResponseOutputWebSearch, TResponseOutputComputer, TResponseOutputReasoning}
  TResponseOutput = class(TResponseOutputReasoning);

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
    TResponseTextFormatCommon, TResponseFormatText, TResponseFormatJSONObject,
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

  {--- This class is made up of the following classes:
    TResponseToolCommon, TResponseToolFileSearch, TResponseToolFunction,
    TResponseToolComputerUse, TResponseToolWebSearch}
  TResponseTool = class(TResponseToolWebSearch);

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
      This data may be represented in either string or object format, which can lead to complications
      during the deserialization process. }
    FTools: TArray<TResponseTool>;
    [JsonNameAttribute('top_p')]
    FTopP: Double;
    FUsage: TResponseUsage;
    FUser: string;
  protected
    function GetCreatedAtAsString: string;
  public
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

  TResponseStreamingCommon = class(TJSONFingerprint)
  private
    [JsonReflectAttribute(ctString, rtString, TResponseStreamTypeInterceptor)]
    FType: TResponseStreamType;
  public
    /// <summary>
    /// The type of the event.
    /// </summary>
    property &Type: TResponseStreamType read FType write FType;
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
  TRresponseIncomplete = class(TResponseFailed)
    {--- This class does not introduce any new functionality; all methods and properties
         are inherited from its ancestor. }
  end;

  /// <summary>
  /// response.output_item.added : Emitted when a new output item is added.
  /// </summary>
  TResponseOutputItemAdded = class(TRresponseIncomplete)
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

  /// <summary>
  /// response.error: Emitted when an error occurs.
  /// </summary>
  TResponseStreamError = class(TResponseReasoningSummaryTextDone)
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
     TResponseStreamingCommon, TResponseCreated, TResponseInProgress,
     TResponseCompleted, TResponseFailed, TRresponseIncomplete,
     TResponseOutputItemAdded, TResponseOutputItemDone, TResponseContentpartAdded,
     TResponseContentpartDone, TResponseOutputTextDelta, TResponseOutputTextAnnotationAdded,
     TResponseOutputTextDone, TResponseRefusalDelta, TResponseRefusalDone,
     TResponseFunctionCallArgumentsDelta, TResponseFunctionCallArgumentsDone, TResponseFileSearchCallInprogress,
     TResponseFileSearchCallSearching, TResponseFileSearchCallCompleted, TResponseWebSearchCallInprogress,
     TResponseWebSearchCallSearching, TResponseWebSearchCallCompleted, TResponseReasoningSummaryPartAdded,
     TResponseReasoningSummaryPartDone, TResponseReasoningSummaryTextDelta, TResponseReasoningSummaryTextDone,
     TResponseStreamError }
  TResponseStream = class(TResponseStreamError);

  /// <summary>
  /// Represents the callback procedure type used for processing streaming AI responses.
  /// </summary>
  /// <param name="Response">
  /// A variable of type TResponseStream containing the latest chunk of streamed response data.
  /// </param>
  /// <param name="IsDone">
  /// A Boolean value indicating whether the streaming response has completed.
  /// </param>
  /// <param name="Cancel">
  /// A variable Boolean that can be set to True to cancel further streaming events.
  /// </param>
  /// <remarks>
  /// TResponseEvent is used in streaming methods to deliver incremental response data.
  /// This callback is invoked repeatedly as new data becomes available. When <paramref name="IsDone"/> is True,
  /// the streaming process has finished, and no further updates will be sent. If needed, you can set <paramref name="Cancel"/>
  /// to True in order to stop receiving additional streamed data.
  /// </remarks>
  TResponseEvent = reference to procedure(var Response: TResponseStream; IsDone: Boolean; var Cancel: Boolean);

  /// <summary>
  /// Manages asynchronous responses callBacks for a responses request using <c>TResponse</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynResponse</c> type extends the <c>TAsynParams&lt;TResponse&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking chat operations and is specifically tailored for scenarios where multiple choices from a chat model are required.
  /// </remarks>
  TAsynResponse = TAsynCallBack<TResponse>;

  /// <summary>
  /// Manages asynchronous streaming responses callBacks for a responses request using <c>TResponseStream</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynResponseStream</c> type extends the <c>TAsynStreamParams&lt;TResponseStream&gt;</c> record to support the lifecycle of an asynchronous streaming responses operation.
  /// It provides callbacks for different stages, including when the operation starts, progresses with new data chunks, completes successfully, or encounters an error.
  /// This structure is ideal for handling scenarios where the responses response is streamed incrementally, providing real-time updates to the user interface.
  /// </remarks>
  TAsynResponseStream = TAsynStreamCallBack<TResponseStream>;

  /// <summary>
  /// Manages asynchronous callbacks for a response deletion request.
  /// </summary>
  /// <remarks>
  /// This type is a specialized alias for <c>TAsynCallBack&lt;TResponseDelete&gt;</c> and is used to handle asynchronous operations
  /// related to deletion requests. It encapsulates a <c>TResponseDelete</c> instance containing details about the deletion outcome,
  /// including the identifier of the deleted response, the type of object involved, and a boolean flag indicating if the deletion
  /// was successful. This mechanism allows for non-blocking deletion operations and provides a consistent interface for handling
  /// deletion responses in asynchronous workflows.
  /// </remarks>
  TAsynResponseDelete = TAsynCallBack<TResponseDelete>;

  /// <summary>
  /// Provides an asynchronous callback mechanism for handling operations that return a collection of responses.
  /// </summary>
  /// <remarks>
  /// This type is an alias for <c>TAsynCallBack&lt;TResponses&gt;</c>, which facilitates asynchronous workflows by encapsulating
  /// the results of operations that yield a paginated set of response items. The underlying <c>TResponses</c> type represents
  /// a structured collection that includes metadata for pagination (such as first and last identifiers, and a flag indicating
  /// whether more data is available) and an array of <c>TResponseItem</c> instances. Each <c>TResponseItem</c> may contain various
  /// elements such as text content, annotations, file search results, and tool call outputs. This design supports non-blocking
  /// operations and efficient handling of complex response data in an asynchronous context.
  /// </remarks>
  TAsynResponses = TAsynCallBack<TResponses>;

  /// <summary>
  /// Provides methods to create, retrieve, delete, and list AI responses.
  /// </summary>
  /// <remarks>
  /// TResponsesRoute is a subclass of TGenAIRoute and implements both synchronous and asynchronous
  /// operations for interacting with the “responses” endpoint of the API. It also supports
  /// overloads that allow additional parameter configuration.
  /// </remarks>
  TResponsesRoute = class(TGenAIRoute)
    /// <summary>
    /// Asynchronously creates a new AI response.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure to configure the request parameters using a TResponsesParams instance.
    /// </param>
    /// <param name="CallBacks">
    /// A callback function that returns a TAsynResponse instance, used to handle start, success, and error events.
    /// </param>
    /// <remarks>
    /// Sends a non-blocking request to create an AI response.
    ///
    /// <code>
    /// Client.Responses.AsynCreate(
    ///   procedure (Params: TResponsesParams)
    ///   begin
    ///     Params.Model('gpt-4.1-mini');
    ///     Params.Input('What is the difference between a mathematician and a physicist?');
    ///   end,
    ///   function : TAsynResponse
    ///   begin
    ///     Result.Sender := Self;
    ///     Result.OnStart := procedure(Sender: TObject)
    ///       begin
    ///         // Initialization code
    ///       end;
    ///     Result.OnSuccess := procedure(Sender: TObject; Value: TResponse)
    ///       begin
    ///         // Process the created response
    ///       end;
    ///     Result.OnError := procedure(Sender: TObject; const ErrorMsg: string)
    ///       begin
    ///         // Handle any errors
    ///       end;
    ///   end);
    /// </code>
    /// </remarks>
    procedure AsynCreate(ParamProc: TProc<TResponsesParams>; CallBacks: TFunc<TAsynResponse>);
    /// <summary>
    /// Asynchronously creates a streamed AI response.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure to configure the request parameters using a TResponsesParams instance.
    /// </param>
    /// <param name="Event">
    /// A callback of type TResponseEvent that is invoked repeatedly as streaming data is received.
    /// </param>
    /// <returns>
    /// True if the streaming response request was successfully initiated.
    /// </returns>
    /// <remarks>
    /// Initiates a streaming request to receive incremental output from the AI.
    ///
    /// <code>
    ///   Client.Responses.AsynCreateStream(
    ///      procedure (Params: TResponsesParams)
    ///      begin
    ///        Params.Model('gpt-4.1-mini');
    ///        Params.Input('What is the difference between a mathematician and a physicist?');
    ///        Params.Stream;
    ///      end,
    ///      function : TAsynResponseStream
    ///      begin
    ///        Result.Sender := Self;
    ///        Result.OnStart := StartCallback;
    ///        Result.OnProgress := ProgressCallback;
    ///        Result.OnError := ErrorCallback;
    ///        Result.OnDoCancel := CancelCallback;
    ///        Result.OnCancellation := CancellationCallback;
    ///      end)
    /// </code>
    /// </remarks>
    procedure AsynCreateStream(ParamProc: TProc<TResponsesParams>; CallBacks: TFunc<TAsynResponseStream>);
    /// <summary>
    /// Asynchronously retrieves an AI response identified by its ID.
    /// </summary>
    /// <param name="ResponseId">
    /// The unique identifier of the response to retrieve.
    /// </param>
    /// <param name="CallBacks">
    /// A callback function that returns a TAsynResponse instance to handle the retrieval process.
    /// </param>
    /// <remarks>
    /// Retrieves the specified response asynchronously.
    ///
    /// <code>
    /// Client.Responses.AsynRetrieve('response_id_here',
    ///   function : TAsynResponse
    ///   begin
    ///     Result.Sender := Self;
    ///     Result.OnStart := StartCallback;
    ///     Result.OnSuccess := SuccessCallback;
    ///     Result.OnError := ErrorCallback;
    ///   end);
    /// </code>
    /// </remarks>
    procedure AsynRetrieve(const ResponseId: string; CallBacks: TFunc<TAsynResponse>); overload;
    /// <summary>
    /// Asynchronously retrieves an AI response by its ID with additional URL parameters.
    /// </summary>
    /// <param name="ResponseId">
    /// The unique identifier of the response to retrieve.
    /// </param>
    /// <param name="ParamProc">
    /// A procedure to configure additional URL parameters using a TURLIncludeParams instance.
    /// </param>
    /// <param name="CallBacks">
    /// A callback function that returns a TAsynResponse instance to handle the retrieval process.
    /// </param>
    /// <remarks>
    /// Retrieves the specified response asynchronously with extra URL configuration.
    ///
    /// <code>
    /// Client.Responses.AsynRetrieve('response_id_here',
    ///   procedure(Params: TURLIncludeParams)
    ///   begin
    ///     Params.Include(['file_search_result', 'input_image_url']);
    ///   end,
    ///   function : TAsynResponse
    ///   begin
    ///     Result.Sender := Self;
    ///     Result.OnStart := StartCallback;
    ///     Result.OnSuccess := SuccessCallback;
    ///     Result.OnError := ErrorCallback;
    ///   end);
    /// </code>
    /// </remarks>
    procedure AsynRetrieve(const ResponseId: string; const ParamProc: TProc<TURLIncludeParams>; CallBacks: TFunc<TAsynResponse>); overload;
    /// <summary>
    /// Asynchronously deletes an AI response identified by its ID.
    /// </summary>
    /// <param name="ResponseId">
    /// The unique identifier of the response to delete.
    /// </param>
    /// <param name="CallBacks">
    /// A callback function that returns a TAsynResponseDelete instance to handle deletion events.
    /// </param>
    /// <remarks>
    /// Sends a non-blocking deletion request for the specified response.
    ///
    /// <code>
    /// Client.Responses.AsynDelete('response_id_here',
    ///   function : TAsynResponseDelete
    ///   begin
    ///     Result.Sender := Self;
    ///     Result.OnStart := StartCallback;
    ///     Result.OnSuccess := SuccessCallback;
    ///     Result.OnError := ErrorCallback;
    ///   end);
    /// </code>
    /// </remarks>
    procedure AsynDelete(const ResponseId: string; CallBacks: TFunc<TAsynResponseDelete>);
    /// <summary>
    /// Asynchronously lists the input items used to generate a specific AI response.
    /// </summary>
    /// <param name="ResponseId">
    /// The unique identifier of the response.
    /// </param>
    /// <param name="CallBacks">
    /// A callback function that returns a TAsynResponses instance to handle the listing process.
    /// </param>
    /// <remarks>
    /// Retrieves the input items associated with the given response asynchronously.
    ///
    /// <code>
    /// Client.Responses.AsynList('response_id_here',
    ///   function : TAsynResponses
    ///   begin
    ///     Result.Sender := Self;
    ///     Result.OnStart := StartCallback;
    ///     Result.OnSuccess := SuccessCallback;
    ///     Result.OnError := ErrorCallback;
    ///   end);
    /// </code>
    /// </remarks>
    procedure AsynList(const ResponseId: string; CallBacks: TFunc<TAsynResponses>); overload;
    /// <summary>
    /// Asynchronously lists the input items used to generate a specific AI response with additional URL parameters.
    /// </summary>
    /// <param name="ResponseId">
    /// The unique identifier of the response.
    /// </param>
    /// <param name="ParamProc">
    /// A procedure to configure additional URL parameters using a TUrlResponseListParams instance.
    /// </param>
    /// <param name="CallBacks">
    /// A callback function that returns a TAsynResponses instance to handle the listing process.
    /// </param>
    /// <remarks>
    /// Retrieves the list of input items asynchronously with extra configuration.
    ///
    /// <code>
    /// Client.Responses.AsynList('response_id_here',
    ///   procedure (Params: TUrlResponseListParams)
    ///   begin
    ///     Params.Limit(15);
    ///   end,
    ///   function : TAsynResponses
    ///   begin
    ///     Result.Sender := Self;
    ///     Result.OnStart := StartCallback;
    ///     Result.OnSuccess := SuccessCallback;
    ///     Result.OnError := ErrorCallback;
    ///   end);
    /// </code>
    /// </remarks>
    procedure AsynList(const ResponseId: string; const ParamProc: TProc<TUrlResponseListParams>; CallBacks: TFunc<TAsynResponses>); overload;
    /// <summary>
    /// Synchronously creates a new AI response.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure to configure the request parameters using a TResponsesParams instance.
    /// </param>
    /// <returns>
    /// A TResponse object representing the newly created AI response.
    /// </returns>
    /// <remarks>
    /// Sends a blocking request to create an AI response and returns the result.
    ///
    /// <code>
    /// var
    ///   Response: TResponse;
    /// begin
    ///   Response := Client.Responses.Create(
    ///     procedure (Params: TResponsesParams)
    ///     begin
    ///       Params.Model('gpt-4.1-mini');
    ///       Params.Input('What is the difference between a mathematician and a physicist?');
    ///     end);
    ///   try
    ///     // Process the response
    ///   finally
    ///     Response.Free;
    ///   end;
    /// end;
    /// </code>
    /// </remarks>
    function Create(ParamProc: TProc<TResponsesParams>): TResponse;
    /// <summary>
    /// Synchronously creates a streaming AI response.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure used to configure the streaming response parameters via a TResponsesParams instance.
    /// </param>
    /// <param name="Event">
    /// A callback (of type TResponseEvent) that is invoked as streaming data is received and when the stream completes.
    /// </param>
    /// <returns>
    /// True if the streaming response request was successfully initiated; otherwise, False.
    /// </returns>
    /// <remarks>
    /// This method sends a request to begin a streaming AI response and blocks until the initial response is accepted.
    /// Use it when you require immediate confirmation that the stream has been started. Stream data is handled via the specified callback.
    ///
    /// <code>
    /// var
    ///   StreamStarted: Boolean;
    /// begin
    ///   StreamStarted := Client.Responses.CreateStream(
    ///     procedure (Params: TResponsesParams)
    ///     begin
    ///       Params.Model('gpt-4.1-mini');
    ///       Params.Input('What is the difference between a mathematician and a physicist?');
    ///       Params.Stream;
    ///     end,
    ///     procedure (var Chat: TResponseStream; IsDone: Boolean; var Cancel: Boolean)
    ///     begin
    ///       if not IsDone then
    ///         // Process the intermediate streaming data
    ///       else
    ///         // Handle the completion of the stream
    ///     end);
    /// end;
    /// </code>
    /// </remarks>
    function CreateStream(ParamProc: TProc<TResponsesParams>; Event: TResponseEvent): Boolean;
    /// <summary>
    /// Synchronously retrieves an AI response by its ID.
    /// </summary>
    /// <param name="ResponseId">
    /// The unique identifier of the response to retrieve.
    /// </param>
    /// <returns>
    /// A TResponse object with the details of the requested AI response.
    /// </returns>
    /// <remarks>
    /// Fetches the specified response in a blocking manner.
    ///
    /// <code>
    /// var
    ///   Response: TResponse;
    /// begin
    ///   Response := Client.Responses.Retrieve('response_id_here');
    ///   try
    ///     // Work with the response data
    ///   finally
    ///     Response.Free;
    ///   end;
    /// end;
    /// </code>
    /// </remarks>
    function Retrieve(const ResponseId: string): TResponse; overload;
    /// <summary>
    /// Synchronously retrieves an AI response by its ID with additional URL parameters.
    /// </summary>
    /// <param name="ResponseId">
    /// The unique identifier of the response to retrieve.
    /// </param>
    /// <param name="ParamProc">
    /// A procedure to configure additional URL parameters using a TURLIncludeParams instance.
    /// </param>
    /// <returns>
    /// A TResponse object with the details of the requested AI response.
    /// </returns>
    /// <remarks>
    /// Retrieves the specified response with extra configuration in a blocking manner.
    ///
    /// <code>
    /// var
    ///   Response: TResponse;
    /// begin
    ///   Response := Client.Responses.Retrieve('response_id_here',
    ///     procedure (Params: TURLIncludeParams)
    ///     begin
    ///       Params.Include(['file_search_result', 'input_image_url']);
    ///     end);
    ///   try
    ///     // Process the response
    ///   finally
    ///     Response.Free;
    ///   end;
    /// end;
    /// </code>
    /// </remarks>
    function Retrieve(const ResponseId: string; const ParamProc: TProc<TURLIncludeParams>): TResponse; overload;
    /// <summary>
    /// Synchronously deletes an AI response by its ID.
    /// </summary>
    /// <param name="ResponseId">
    /// The unique identifier of the response to delete.
    /// </param>
    /// <returns>
    /// A TResponseDelete object indicating the result of the deletion.
    /// </returns>
    /// <remarks>
    /// Sends a blocking deletion request for the specified response.
    ///
    /// <code>
    /// var
    ///   DeleteResult: TResponseDelete;
    /// begin
    ///   DeleteResult := Client.Responses.Delete('response_id_here');
    ///   try
    ///     // Verify deletion status
    ///   finally
    ///     DeleteResult.Free;
    ///   end;
    /// end;
    /// </code>
    /// </remarks>
    function Delete(const ResponseId: string): TResponseDelete;
    /// <summary>
    /// Synchronously lists input items used to generate a specific AI response.
    /// </summary>
    /// <param name="ResponseId">
    /// The unique identifier of the AI response.
    /// </param>
    /// <returns>
    /// A TResponses object containing the list of input items.
    /// </returns>
    /// <remarks>
    /// Retrieves the list of input items in a blocking manner.
    ///
    /// <code>
    /// var
    ///   Responses: TResponses;
    /// begin
    ///   Responses := Client.Responses.List('response_id_here');
    ///   try
    ///     // Process the list of input items
    ///   finally
    ///     Responses.Free;
    ///   end;
    /// end;
    /// </code>
    /// </remarks>
    function List(const ResponseId: string): TResponses; overload;
    /// <summary>
    /// Synchronously lists input items used to generate a specific AI response with additional URL parameters.
    /// </summary>
    /// <param name="ResponseId">
    /// The unique identifier of the AI response.
    /// </param>
    /// <param name="ParamProc">
    /// A procedure to configure additional URL parameters using a TUrlResponseListParams instance.
    /// </param>
    /// <returns>
    /// A TResponses object containing the list of input items.
    /// </returns>
    /// <remarks>
    /// Retrieves the list of input items with extra configuration in a blocking manner.
    ///
    /// <code>
    /// var
    ///   Responses: TResponses;
    /// begin
    ///   Responses := Client.Responses.List('response_id_here',
    ///     procedure (Params: TUrlResponseListParams)
    ///     begin
    ///       Params.Limit(50);
    ///     end);
    ///   try
    ///     // Process the list of input items
    ///   finally
    ///     Responses.Free;
    ///   end;
    /// end;
    /// </code>
    /// </remarks>
    function List(const ResponseId: string; const ParamProc: TProc<TUrlResponseListParams>): TResponses; overload;
    /// <summary>
    /// Initiates parallel processing of "responses" prompts by creating multiple "responses"
    /// asynchronously, with results stored in a bundle and provided back to the callback function.
    /// This method allows for parallel processing of multiple prompts in an efficient manner,
    /// handling errors and successes for each chat completion.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure delegate that configures the parameters for the bundle. It is responsible
    /// for providing the necessary settings (such as model and reasoning effort) for the chat completions.
    /// </param>
    /// <param name="CallBacks">
    /// A function that returns an instance of TAsynBuffer, which manages the lifecycle of the
    /// asynchronous operation. The callbacks include handlers for start, error, and success events.
    /// </param>
    /// <remarks>
    /// The method allows for efficient parallel processing of multiple prompts by delegating
    /// individual tasks to separate threads. It handles the reasoning effort for specific models
    /// and ensures each task's result is properly bundled and communicated back to the caller.
    /// If an error occurs, the error handling callback will be triggered, and the rest of the tasks
    /// will continue processing. The success callback is triggered once all tasks are completed.
    /// </remarks>
    procedure CreateParallel(ParamProc: TProc<TBundleParams>; const CallBacks: TFunc<TAsynBundleList>);
  end;

implementation

uses
  System.StrUtils, GenAI.NetEncoding.Base64, GenAI.Responses.Helpers;

{ TResponsesParams }

function TResponsesParams.Include(
  const Value: TArray<TOutputIncluding>): TResponsesParams;
begin
  var JSONArray := TJSONArray.Create;
  for var Item in Value do
    JSONArray.Add(Item.ToString);
  Result := TResponsesParams(Add('include', JSONArray));
end;

function TResponsesParams.Include(
  const Value: TArray<string>): TResponsesParams;
begin
  var JSONArray := TJSONArray.Create;
  for var Item in Value do
    JSONArray.Add(TOutputIncluding.Create(Item).ToString);
  Result := TResponsesParams(Add('include', JSONArray));
end;

function TResponsesParams.Input(const Content: string;
  const Docs: TArray<string>; const Role: string): TResponsesParams;
var
  MimeType: string;
begin
  {--- Create an array with content (text and image documents }
  var JSONArray := TJSONArray.Create;
  JSONArray.Add(TItemContent.NewText.Text(Content).Detach);
  for var Item in Docs do
    begin
      MimeType := TFormatHelper.GetMimeType(Item);
      if TFormatHelper.IsPDFDocument(MimeType) then
        JSONArray.Add(TItemContent.NewFileData(Item).Detach)
      else
      if TFormatHelper.IsImageDocument(MimeType) then
        JSONArray.Add(TItemContent.NewImage(Item).Detach)
      else
      if MimeType = TFormatHelper.S_FILEID then
        JSONArray.Add(TItemContent.NewFile.FileId(Item).Detach)
      else
        raise Exception.CreateFmt('%s : Mime type not supported', [MimeType]);
    end;

  {--- Create the input message }
  var InputMessage := TJSONArray.Create.Add(TInputMessage.Create.Role(Role).Content(JSONArray).Detach);

  Result := TResponsesParams(Add('input', InputMessage));
end;

function TResponsesParams.Input(const Value: TJSONArray): TResponsesParams;
begin
  Result := TResponsesParams(Add('input', Value));
end;

function TResponsesParams.Input(const Value: TArray<TInputListItem>): TResponsesParams;
begin
  var JSONArray := TJSONArray.Create;
  for var Item in Value do
    JSONArray.Add(Item.Detach);
  Result := TResponsesParams(Add('input', JSONArray));
end;

function TResponsesParams.Input(const Value: string): TResponsesParams;
begin
  Result := TResponsesParams(Add('input', Value));
end;

function TResponsesParams.Instructions(const Value: string): TResponsesParams;
begin
  Result := TResponsesParams(Add('instructions', Value));
end;

function TResponsesParams.MaxOutputTokens(
  const Value: Integer): TResponsesParams;
begin
  Result := TResponsesParams(Add('max_output_tokens', Value));
end;

function TResponsesParams.Metadata(const Value: TJSONObject): TResponsesParams;
begin
  Result := TResponsesParams(Add('metadata', Value));
end;

function TResponsesParams.Model(const Value: string): TResponsesParams;
begin
  Result := TResponsesParams(Add('model', Value));
end;

function TResponsesParams.ParallelToolCalls(
  const Value: Boolean): TResponsesParams;
begin
  Result := TResponsesParams(Add('parallel_tool_calls', Value));
end;

function TResponsesParams.PreviousResponseId(
  const Value: string): TResponsesParams;
begin
  Result := TResponsesParams(Add('previous_response_id', Value));
end;

function TResponsesParams.Reasoning(const Value: TReasoningParams): TResponsesParams;
begin
  Result := TResponsesParams(Add('reasoning', Value.Detach));
end;

function TResponsesParams.Reasoning(const Value: string): TResponsesParams;
begin
  Result := TResponsesParams(Add('reasoning', TReasoningParams.New.Effort(Value).Detach));
end;

function TResponsesParams.Store(const Value: Boolean): TResponsesParams;
begin
  Result := TResponsesParams(Add('store', Value));
end;

function TResponsesParams.Stream(const Value: Boolean): TResponsesParams;
begin
  Result := TResponsesParams(Add('stream', Value));
end;

function TResponsesParams.Temperature(const Value: Double): TResponsesParams;
begin
  Result := TResponsesParams(Add('temperature', Value));
end;

function TResponsesParams.Text(const Value: TResponseOption;
  const SchemaParams: TTextJSONSchemaParams): TResponsesParams;
begin
  Result := Text(Value.ToString, SchemaParams);
end;

function TResponsesParams.ToolChoice(const Value: string): TResponsesParams;
begin
  Result := TResponsesParams(Add('tool_choice', TToolChoice.Create(Value).ToString));
end;

function TResponsesParams.ToolChoice(
  const Value: TToolChoice): TResponsesParams;
begin
  Result := TResponsesParams(Add('tool_choice', Value.ToString));
end;

function TResponsesParams.ToolChoice(
  const Value: TResponseToolChoiceParams): TResponsesParams;
begin
  Result := TResponsesParams(Add('tool_choice', Value.Detach));
end;

function TResponsesParams.Tools(
  const Value: TArray<TResponseToolParams>): TResponsesParams;
begin
  var JSONArray := TJSONArray.Create;
  for var Item in Value do
    JSONArray.Add(Item.Detach);
  Result := TResponsesParams(Add('tools', JSONArray));
end;

function TResponsesParams.TopP(const Value: Double): TResponsesParams;
begin
  Result := TResponsesParams(Add('top_p', Value));
end;

function TResponsesParams.Truncation(const Value: string): TResponsesParams;
begin
  Result := TResponsesParams(Add('truncation', TResponseTruncationType.Create(Value).ToString));
end;

function TResponsesParams.User(const Value: string): TResponsesParams;
begin
  Result := TResponsesParams(Add('user', Value));
end;

function TResponsesParams.Truncation(
  const Value: TResponseTruncationType): TResponsesParams;
begin
  Result := TResponsesParams(Add('truncation', Value.ToString));
end;

function TResponsesParams.Text(const Value: string;
  const SchemaParams: TTextJSONSchemaParams): TResponsesParams;
begin
  case TResponseOption.Create(Value) of
    TResponseOption.text:
      begin
        Result := Text(TTextFormatTextPrams.New);
        if Assigned(SchemaParams) then
          SchemaParams.Free;
      end;
    TResponseOption.json_object:
      begin
        Result := Text(TTextJSONObjectParams.New);
        if Assigned(SchemaParams) then
          SchemaParams.Free;
      end
    else
      begin
        if not Assigned(SchemaParams) then
          raise Exception.Create('Text options: Schema not defined.');
        Result := Text(SchemaParams);
      end;
  end;
end;

function TResponsesParams.Text(
  const Value: TTextFormatParams): TResponsesParams;
begin
  if Assigned(Value) then
    Result := Text(TTextParams.Create.Format(Value)) else
    Result := Self;
end;

function TResponsesParams.Text(const Value: TTextParams): TResponsesParams;
begin
  Result := TResponsesParams(Add('text', Value.Detach));
end;

{ TReasoningParams }

function TReasoningParams.Effort(const Value: TReasoningEffort): TReasoningParams;
begin
  Result := TReasoningParams(Add('effort', Value.ToString));
end;

function TReasoningParams.Effort(const Value: string): TReasoningParams;
begin
  Result := TReasoningParams(Add('effort', TReasoningEffort.Create(Value).ToString));
end;

function TReasoningParams.Summary(const Value: string): TReasoningParams;
begin
  Result := TReasoningParams(Add('summary', TReasoningGenerateSummary.Create(Value).ToString));
end;

class function TReasoningParams.New: TReasoningParams;
begin
  Result := TReasoningParams.Create;
end;

function TReasoningParams.Summary(
  const Value: TReasoningGenerateSummary): TReasoningParams;
begin
  Result := TReasoningParams(Add('summary', Value.ToString));
end;

{ TTextParams }

function TTextParams.Format(const Value: TTextFormatParams): TTextParams;
begin
  Result := TTextParams(Add('format', Value.Detach));
end;

{ TTextFormatTextPrams }

class function TTextFormatTextPrams.New: TTextFormatTextPrams;
begin
  Result := TTextFormatTextPrams.Create.&Type();
end;

function TTextFormatTextPrams.&Type(const Value: string): TTextFormatTextPrams;
begin
  Result := TTextFormatTextPrams(Add('type', Value));
end;

{ TTextJSONSchemaParams }

function TTextJSONSchemaParams.&Type(
  const Value: string): TTextJSONSchemaParams;
begin
  Result := TTextJSONSchemaParams(Add('type', Value));
end;

function TTextJSONSchemaParams.Description(
  const Value: string): TTextJSONSchemaParams;
begin
  Result := TTextJSONSchemaParams(Add('description', Value));
end;

function TTextJSONSchemaParams.Name(const Value: string): TTextJSONSchemaParams;
begin
  Result := TTextJSONSchemaParams(Add('name', Value));
end;

class function TTextJSONSchemaParams.New: TTextJSONSchemaParams;
begin
  Result := TTextJSONSchemaParams.Create.&Type();
end;

function TTextJSONSchemaParams.Schema(
  const Value: TSchemaParams): TTextJSONSchemaParams;
begin
  Result := TTextJSONSchemaParams(Add('schema', Value.Detach));
end;

function TTextJSONSchemaParams.Schema(
  const Value: string): TTextJSONSchemaParams;
begin
  var JSON := TJSONObject.ParseJSONValue(Value.ToLower.Replace(sLineBreak, '').Replace(#10, '').Replace(#13, '')) as TJSONObject;
  Result := TTextJSONSchemaParams(Add('schema', JSON));
end;

function TTextJSONSchemaParams.Strict(
  const Value: Boolean): TTextJSONSchemaParams;
begin
  Result := TTextJSONSchemaParams(Add('strict', Value));
end;

{ TTextJSONObjectParams }

class function TTextJSONObjectParams.New: TTextJSONObjectParams;
begin
  Result := TTextJSONObjectParams.Create.&Type();
end;

function TTextJSONObjectParams.&Type(
  const Value: string): TTextJSONObjectParams;
begin
  Result := TTextJSONObjectParams(Add('type', Value));
end;

{ THostedToolParams }

function THostedToolParams.&Type(
  const Value: THostedTooltype): THostedToolParams;
begin
  Result := THostedToolParams(Add('type', Value.ToString));
end;

class function THostedToolParams.New(const Value: string): THostedToolParams;
begin
  Result := THostedToolParams.Create.&Type(Value);
end;

function THostedToolParams.&Type(const Value: string): THostedToolParams;
begin
  Result := THostedToolParams(Add('type', THostedTooltype.Create(Value).ToString));
end;

{ TFunctionToolParams }

function TFunctionToolParams.Name(const Value: string): TFunctionToolParams;
begin
  Result := TFunctionToolParams(Add('name', Value));
end;

class function TFunctionToolParams.New: TFunctionToolParams;
begin
  Result := TFunctionToolParams.Create.&Type();
end;

function TFunctionToolParams.&Type(const Value: string): TFunctionToolParams;
begin
  Result := TFunctionToolParams(Add('type', Value));
end;

{ TResponseFileSearchParams }

function TResponseFileSearchParams.Filters(
  const Value: TFileSearchFilters): TResponseFileSearchParams;
begin
  Result := TResponseFileSearchParams(Add('filters', Value.Detach));
end;

function TResponseFileSearchParams.MaxNumResults(
  const Value: Integer): TResponseFileSearchParams;
begin
  Result := TResponseFileSearchParams(Add('max_num_results', Value));
end;

class function TResponseFileSearchParams.New: TResponseFileSearchParams;
begin
  Result := TResponseFileSearchParams.Create.&Type();
end;

function TResponseFileSearchParams.RankingOptions(
  const Value: TRankingOptionsParams): TResponseFileSearchParams;
begin
  Result := TResponseFileSearchParams(Add('ranking_options', Value.Detach));
end;

function TResponseFileSearchParams.&Type(
  const Value: string): TResponseFileSearchParams;
begin
  Result := TResponseFileSearchParams(Add('type', Value));
end;

function TResponseFileSearchParams.VectorStoreIds(
  const Value: TArray<string>): TResponseFileSearchParams;
begin
  Result := TResponseFileSearchParams(Add('vector_store_ids', Value));
end;

{ TComparisonFilter }

function TComparisonFilter.&Type(
  const Value: TComparisonFilterType): TComparisonFilter;
begin
  Result := TComparisonFilter(Add('type', Value.ToString));
end;

class function TComparisonFilter.New: TComparisonFilter;
begin
  Result := TComparisonFilter.Create;
end;

function TComparisonFilter.&Type(const Value: string): TComparisonFilter;
begin
  Result := TComparisonFilter(Add('type', TComparisonFilterType.Create(Value).ToString));
end;

function TComparisonFilter.Comparison(const Value: string): TComparisonFilter;
begin
  Result := TComparisonFilter(Add('type', TComparisonFilterType.ToOperator(Value).ToString));
end;

function TComparisonFilter.Key(const Value: string): TComparisonFilter;
begin
  Result := TComparisonFilter(Add('key', Value));
end;

class function TComparisonFilter.New(const Key, Comparison: string;
  const Value: Double): TComparisonFilter;
begin
  Result := New.Key(Key).Comparison(Comparison).Value(Value);
end;

class function TComparisonFilter.New(const Key, Comparison: string;
  const Value: Integer): TComparisonFilter;
begin
  Result := New.Key(Key).Comparison(Comparison).Value(Value);
end;

class function TComparisonFilter.New(const Key, Comparison,
  Value: string): TComparisonFilter;
begin
  Result := New.Key(Key).Comparison(Comparison).Value(Value);
end;

class function TComparisonFilter.New(const Key, Comparison: string;
  const Value: Boolean): TComparisonFilter;
begin
  Result := New.Key(Key).Comparison(Comparison).Value(Value);
end;

function TComparisonFilter.Value(const Value: string): TComparisonFilter;
begin
  Result := TComparisonFilter(Add('value', Value));
end;

function TComparisonFilter.Value(const Value: Integer): TComparisonFilter;
begin
  Result := TComparisonFilter(Add('value', Value));
end;

function TComparisonFilter.Value(const Value: Double): TComparisonFilter;
begin
  Result := TComparisonFilter(Add('value', Value));
end;

function TComparisonFilter.Value(const Value: Boolean): TComparisonFilter;
begin
  Result := TComparisonFilter(Add('value', Value));
end;

{ TCompoundFilter }

function TCompoundFilter.&And: TCompoundFilter;
begin
  Result := &Type(TCompoundFilterType.and);
end;

class function TCompoundFilter.&And(
  const Value: TArray<TFileSearchFilters>): TCompoundFilter;
begin
  Result := TCompoundFilter.New.&And.Filters(Value);
end;

function TCompoundFilter.Filters(
  const Value: TArray<TFileSearchFilters>): TCompoundFilter;
begin
  var JSONArray := TJSONArray.Create;
  for var Item in Value do
    JSONArray.Add(Item.Detach);
  Result := TCompoundFilter(Add('filters', JSONArray));
end;

class function TCompoundFilter.New: TCompoundFilter;
begin
  Result := TCompoundFilter.Create;
end;

function TCompoundFilter.&Or: TCompoundFilter;
begin
  Result := &Type(TCompoundFilterType.or);
end;

class function TCompoundFilter.&Or(
  const Value: TArray<TFileSearchFilters>): TCompoundFilter;
begin
  Result := TCompoundFilter.New.&Or.Filters(Value);
end;

function TCompoundFilter.&Type(
  const Value: TCompoundFilterType): TCompoundFilter;
begin
  Result := TCompoundFilter(Add('type', Value.ToString));
end;

{ TResponseFunctionParams }

function TResponseFunctionParams.&Type(
  const Value: string): TResponseFunctionParams;
begin
  Result := TResponseFunctionParams(Add('type', Value));
end;

function TResponseFunctionParams.Description(
  const Value: string): TResponseFunctionParams;
begin
  Result := TResponseFunctionParams(Add('description', Value));
end;

function TResponseFunctionParams.Name(
  const Value: string): TResponseFunctionParams;
begin
  Result := TResponseFunctionParams(Add('name', Value));
end;

class function TResponseFunctionParams.New(
  const Value: IFunctionCore): TResponseFunctionParams;
begin
  Result := New.Description(Value.Description).Name(Value.Name).Parameters(Value.Parameters).Strict(Value.&Strict);
end;

class function TResponseFunctionParams.New: TResponseFunctionParams;
begin
  Result := TResponseFunctionParams.Create.&Type();
end;

function TResponseFunctionParams.Parameters(
  const Value: string): TResponseFunctionParams;
begin
  var JSON := TJSONObject.ParseJSONValue(Value.ToLower.Replace(sLineBreak, '').Replace(#10, '').Replace(#13, '')) as TJSONObject;
  Result := TResponseFunctionParams(Add('parameters', JSON));
end;

function TResponseFunctionParams.Parameters(
  const Value: TSchemaParams): TResponseFunctionParams;
begin
  Result := TResponseFunctionParams(Add('parameters', Value.Detach));
end;

function TResponseFunctionParams.Strict(
  const Value: Boolean): TResponseFunctionParams;
begin
  Result := TResponseFunctionParams(Add('strict', Value));
end;

{ TResponseComputerUseParams }

function TResponseComputerUseParams.&Type(
  const Value: string): TResponseComputerUseParams;
begin
  Result := TResponseComputerUseParams(Add('type', Value));
end;

function TResponseComputerUseParams.DisplayHeight(
  const Value: Integer): TResponseComputerUseParams;
begin
  Result := TResponseComputerUseParams(Add('display_height', Value));
end;

function TResponseComputerUseParams.DisplayWidth(
  const Value: Integer): TResponseComputerUseParams;
begin
  Result := TResponseComputerUseParams(Add('display_width', Value));
end;

function TResponseComputerUseParams.Environment(
  const Value: string): TResponseComputerUseParams;
begin
  Result := TResponseComputerUseParams(Add('environment', Value));
end;

class function TResponseComputerUseParams.New: TResponseComputerUseParams;
begin
  Result := TResponseComputerUseParams.Create.&Type();
end;

{ TResponseWebSearchParams }

function TResponseWebSearchParams.&Type(
  const Value: TWebSearchType): TResponseWebSearchParams;
begin
  Result := TResponseWebSearchParams(Add('type', Value.ToString));
end;

function TResponseWebSearchParams.&Type(
  const Value: string): TResponseWebSearchParams;
begin
  Result := TResponseWebSearchParams(Add('type', TWebSearchType.Create(Value).ToString));
end;


function TResponseWebSearchParams.UserLocation(
  const Value: TResponseUserLocationParams): TResponseWebSearchParams;
begin
  Result := TResponseWebSearchParams(Add('user_location', Value.Detach));
end;

function TResponseWebSearchParams.SearchContextSize(
  const Value: TSearchWebOptions): TResponseWebSearchParams;
begin
  Result := TResponseWebSearchParams(Add('search_context_size', Value.ToString));
end;

class function TResponseWebSearchParams.New: TResponseWebSearchParams;
begin
  Result := TResponseWebSearchParams.Create.&Type();
end;

function TResponseWebSearchParams.SearchContextSize(
  const Value: string): TResponseWebSearchParams;
begin
  Result := TResponseWebSearchParams(Add('search_context_size', TSearchWebOptions.Create(Value).ToString));
end;

{ TResponseUserLocationParams }

function TResponseUserLocationParams.City(
  const Value: string): TResponseUserLocationParams;
begin
  Result := TResponseUserLocationParams(Add('city', Value));
end;

function TResponseUserLocationParams.Country(
  const Value: string): TResponseUserLocationParams;
begin
  Result := TResponseUserLocationParams(Add('country', Value));
end;

class function TResponseUserLocationParams.New: TResponseUserLocationParams;
begin
  Result := TResponseUserLocationParams.Create.&Type();
end;

function TResponseUserLocationParams.Region(
  const Value: string): TResponseUserLocationParams;
begin
  Result := TResponseUserLocationParams(Add('region', Value));
end;

function TResponseUserLocationParams.Timezone(
  const Value: string): TResponseUserLocationParams;
begin
  Result := TResponseUserLocationParams(Add('timezone', Value));
end;

function TResponseUserLocationParams.&Type(
  const Value: string): TResponseUserLocationParams;
begin
  Result := TResponseUserLocationParams(Add('type', Value));
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

{ TResponseOutputMessage }

destructor TResponseOutputMessage.Destroy;
begin
  for var Item in FContent do
    Item.Free;
  inherited;
end;

{ TResponseMessageContent }

destructor TResponseMessageContent.Destroy;
begin
  for var Item in FAnnotations do
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

{ ResponseFileSearchFiltersCompound }

destructor TResponseFileSearchFiltersCompound.Destroy;
begin
  for var Item in FFilters do
    Item.Free;
  inherited;
end;

{ TResponseToolWebSearch }

destructor TResponseToolWebSearch.Destroy;
begin
  if Assigned(FUserLocation) then
    FUserLocation.Free;
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

{ TResponsesRoute }

procedure TResponsesRoute.AsynCreate(ParamProc: TProc<TResponsesParams>;
  CallBacks: TFunc<TAsynResponse>);
begin
  with TAsynCallBackExec<TAsynResponse, TResponse>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TResponse
      begin
        Result := Self.Create(ParamProc);
      end);
  finally
    Free;
  end;
end;

procedure TResponsesRoute.AsynCreateStream(ParamProc: TProc<TResponsesParams>;
  CallBacks: TFunc<TAsynResponseStream>);
begin
  var CallBackParams := TUseParamsFactory<TAsynResponseStream>.CreateInstance(CallBacks);

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
            {--- Pass the instance of the current class in case no value was specified. }
            if not Assigned(Sender) then
              Sender := Self;

            {--- Trigger OnStart callback }
            if Assigned(OnStart) then
              TThread.Queue(nil,
                procedure
                begin
                  OnStart(Sender);
                end);
            try
              var Stop := False;

              {--- Processing }
              CreateStream(ParamProc,
                procedure (var Response: TResponseStream; IsDone: Boolean; var Cancel: Boolean)
                begin
                  {--- Check that the process has not been canceled }
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
                      {--- Trigger when processus was stopped }
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
                  if not IsDone and Assigned(Response) then
                    begin
                      var LocalResponse := Response;
                      Response := nil;

                      {--- Triggered when processus is progressing }
                      if Assigned(OnProgress) then
                        TThread.Synchronize(TThread.Current,
                        procedure
                        begin
                          try
                            OnProgress(Sender, LocalResponse);
                          finally
                            {--- Makes sure to release the instance containing the data obtained
                                 following processing}
                            LocalResponse.Free;
                          end;
                        end)
                     else
                       LocalResponse.Free;
                    end
                  else
                  if IsDone then
                    begin
                      {--- Trigger OnEnd callback when the process is done }
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

                    {--- Trigger OnError callback if the process has failed }
                    if Assigned(OnError) then
                      TThread.Queue(nil,
                      procedure
                      begin
                        OnError(Sender, ErrorMsg);
                      end);
                  finally
                    {--- Ensures that the instance of the caught exception is released}
                    Error.Free;
                  end;
                end;
            end;
          end);
  Task.Start;
end;

procedure TResponsesRoute.AsynDelete(const ResponseId: string;
  CallBacks: TFunc<TAsynResponseDelete>);
begin
  with TAsynCallBackExec<TAsynResponseDelete, TResponseDelete>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TResponseDelete
      begin
        Result := Self.Delete(ResponseId);
      end);
  finally
    Free;
  end;
end;

procedure TResponsesRoute.AsynList(const ResponseId: string;
  const ParamProc: TProc<TUrlResponseListParams>;
  CallBacks: TFunc<TAsynResponses>);
begin
  with TAsynCallBackExec<TAsynResponses, TResponses>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TResponses
      begin
        Result := Self.List(ResponseId, ParamProc);
      end);
  finally
    Free;
  end;
end;

procedure TResponsesRoute.AsynList(const ResponseId: string;
  CallBacks: TFunc<TAsynResponses>);
begin
  with TAsynCallBackExec<TAsynResponses, TResponses>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TResponses
      begin
        Result := Self.List(ResponseId);
      end);
  finally
    Free;
  end;
end;

procedure TResponsesRoute.AsynRetrieve(const ResponseId: string;
  const ParamProc: TProc<TURLIncludeParams>; CallBacks: TFunc<TAsynResponse>);
begin
  with TAsynCallBackExec<TAsynResponse, TResponse>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TResponse
      begin
        Result := Self.Retrieve(ResponseId, ParamProc);
      end);
  finally
    Free;
  end;
end;

procedure TResponsesRoute.AsynRetrieve(const ResponseId: string;
  CallBacks: TFunc<TAsynResponse>);
begin
  with TAsynCallBackExec<TAsynResponse, TResponse>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TResponse
      begin
        Result := Self.Retrieve(ResponseId);
      end);
  finally
    Free;
  end;
end;

function TResponsesRoute.Create(ParamProc: TProc<TResponsesParams>): TResponse;
begin
  Result := API.Post<TResponse, TResponsesParams>('responses', ParamProc);
end;

procedure TResponsesRoute.CreateParallel(ParamProc: TProc<TBundleParams>;
  const CallBacks: TFunc<TAsynBundleList>);
var
  Tasks: TArray<ITask>;
  BundleParams: TBundleParams;
  ReasoningEffort: string;
begin
  BundleParams := TBundleParams.Create;
  try
    if not Assigned(ParamProc) then
      raise Exception.Create('The lambda can''t be null');

    ParamProc(BundleParams);
    var Bundle := TBundleList.Create;
    var Ranking := 0;
    var ErrorExists := False;
    var Prompts := BundleParams.GetPrompt;
    var Counter := Length(Prompts);

    {--- Set the reasoning effort if necessary }
    if IsReasoningModel(BundleParams.GetModel) then
      ReasoningEffort := BundleParams.GetReasoningEffort
    else
      ReasoningEffort := EmptyStr;

    if Assigned(CallBacks.OnStart) then
      CallBacks.OnStart(CallBacks.Sender);

    SetLength(Tasks, Length(Prompts));
    for var index := 0 to Pred(Length(Prompts)) do
      begin
        Tasks[index] := TTask.Run(
          procedure
          begin
            var Buffer := Bundle.Add(index + 1);
            Buffer.Prompt := Prompts[index];
            try
              var Response := Create(
                procedure (Params: TResponsesParams)
                begin
                  {--- Set the model for the process }
                  Params.Model(BundleParams.GetModel);

                  {--- If reasoning model then set de reasoning parameters }
                  if not ReasoningEffort.IsEmpty then
                    Params.Reasoning(TReasoningParams.New.Effort(ReasoningEffort));

                  {--- Set the developer instructions }
                  Params.Instructions(BundleParams.GetSystem);

                  {--- Set the current prompt }
                  Params.Input(Buffer.Prompt);

                  {--- Set the web search parameters if necessary }
                  if not BundleParams.GetSearchSize.IsEmpty then
                    begin
                      var Search_web := TResponseWebSearchParams.New.SearchContextSize(BundleParams.GetSearchSize);

                      {---- Set the location if necessary }
                      if not BundleParams.GetCity.IsEmpty or
                         not BundleParams.GetCountry.IsEmpty then
                        begin
                          {--- "Location object" instantiation }
                          var Locate := TResponseUserLocationParams.New;

                          {--- Process for the city location }
                          if not BundleParams.GetCity.IsEmpty then
                            Locate.City(BundleParams.GetCity);

                            {--- Process for the country location }
                          if not BundleParams.GetCountry.IsEmpty then
                            Locate.Country(BundleParams.GetCountry);

                          {--- Sets the location object into the Search_web instance  }
                          Search_web.UserLocation(Locate);
                        end;

                      {--- Set the web search tool }
                      Params.Tools([Search_web]);
                    end;

                  {--- No storage because this type of treatment must be ephemeral }
                  Params.Store(False);
                end);
              Inc(Ranking);
              Buffer.FinishIndex := Ranking;

              {--- Construct the response as a directly usable text }
              for var Item in Response.Output do
                for var SubItem in Item.Content do
                  Buffer.Response := Buffer.Response + SubItem.Text + #10;

              {--- Return the "Response" object in the buffer }
              Buffer.Chat := Response;
            except
              on E: Exception do
                begin
                  {--- Catch the exception }
                  var Error := AcquireExceptionObject;
                  ErrorExists := True;
                  try
                    var ErrorMsg := (Error as Exception).Message;
                    {--- Trigger OnError callback if the process has failed }
                    if Assigned(CallBacks.OnError) then
                      TThread.Queue(nil,
                      procedure
                      begin
                        CallBacks.OnError(CallBacks.Sender, ErrorMsg);
                      end);
                  finally
                    {--- Ensures that the instance of the caught exception is released}
                    Error.Free;
                  end;
                end;
            end;
          end);

        if ErrorExists then
          Continue;

        {--- TTask.WaitForAll is not used due to a memory leak in TLightweightEvent/TCompleteEventsWrapper.
             See report RSP-12462 and RSP-25999. }
        TTaskHelper.ContinueWith(Tasks[Index],
          procedure
          begin
            Dec(Counter);
            if Counter = 0 then
              begin
                try
                  if not ErrorExists and Assigned(CallBacks.OnSuccess) then
                    CallBacks.OnSuccess(CallBacks.Sender, Bundle);
                finally
                  Bundle.Free;
                end;
              end;
          end);
        {--- Need a delay, otherwise the process runs only with the first task. }
        Sleep(30);
      end;
  finally
    BundleParams.Free;
  end;
end;

function TResponsesRoute.Retrieve(const ResponseId: string): TResponse;
begin
  Result := API.Get<TResponse>('responses/' + ResponseID);
end;

function TResponsesRoute.CreateStream(ParamProc: TProc<TResponsesParams>;
  Event: TResponseEvent): Boolean;

(*
    {"type":"response.created","response":{"id":"resp_67ffeb4f88f4819183b0c7bfd76270970c4424583b6f214d","object":"response","created_at":1744825167,"status":"in_progress","error":null,"incomplete_details":null,"instructions":null,"max_output_tokens":null,"model":"gpt-4.1-nano-2025-04-14","output":[],"parallel_tool_calls":true,"previous_response_id":null,"reasoning":{"effort":null,"summary":null},"store":false,"temperature":1.0,"text":{"format":{"type":"text"}},"tool_choice":"auto","tools":[],"top_p":1.0,"truncation":"disabled","usage":null,"user":null,"metadata":{}}}
    {"type":"response.in_progress","response":{"id":"resp_67ffeb4f88f4819183b0c7bfd76270970c4424583b6f214d","object":"response","created_at":1744825167,"status":"in_progress","error":null,"incomplete_details":null,"instructions":null,"max_output_tokens":null,"model":"gpt-4.1-nano-2025-04-14","output":[],"parallel_tool_calls":true,"previous_response_id":null,"reasoning":{"effort":null,"summary":null},"store":false,"temperature":1.0,"text":{"format":{"type":"text"}},"tool_choice":"auto","tools":[],"top_p":1.0,"truncation":"disabled","usage":null,"user":null,"metadata":{}}}
    {"type":"response.output_item.added","output_index":0,"item":{"id":"msg_67ffeb4fbe28819193360cdfa54b544e0c4424583b6f214d","type":"message","status":"in_progress","content":[],"role":"assistant"}}
    {"type":"response.content_part.added","item_id":"msg_67ffeb4fbe28819193360cdfa54b544e0c4424583b6f214d","output_index":0,"content_index":0,"part":{"type":"output_text","annotations":[],"text":""}}
    {"type":"response.output_text.delta","item_id":"msg_67ffeb4fbe28819193360cdfa54b544e0c4424583b6f214d","output_index":0,"content_index":0,"delta":"Great"}
    ...
    {"type":"response.output_text.done","item_id":"msg_67ffeb4fbe28819193360cdfa54b544e0c4424583b6f214d","output_index":0,"content_index":0,"text":"message."}
    {"type":"response.content_part.done","item_id":"msg_67ffeb4fbe28819193360cdfa54b544e0c4424583b6f214d","output_index":0,"content_index":0,"part":{"type":"output_text","annotations":[],"text":"message"}}
    {"type":"response.output_item.done","output_index":0,"item":{"id":"msg_67ffeb4fbe28819193360cdfa54b544e0c4424583b6f214d","type":"message","status":"completed","content":[{"type":"output_text","annotations":[],"text":"messagele":"assistant"}}
*)

var
  Response: TStringStream;

  {--- Persistent variables between callbacks }
  CurrentEvent, CurrentData: string;
begin
  Response := TStringStream.Create('', TEncoding.UTF8);
  try
    CurrentEvent := EmptyStr;
    CurrentData := EmptyStr;

    Result := API.Post<TResponsesParams>('responses', ParamProc, Response,
      procedure(const Sender: TObject; AContentLength, AReadCount: Int64; var AAbort: Boolean)
      var
        IsDone: Boolean;
        ResponseData: TResponseStream;

        {--- Local buffer containing only the part not yet processed }
        Buffer: string;
        BufferPos, PosLineEnd: Integer;
        Line: string;
        NewBuffer: string;
      begin
        {--- Retrieve only the new portion of the stream }
        Buffer := Response.DataString;

        {--- local position in Buffer }
        BufferPos := 0;

        {--- As long as a complete line (terminated by LF) is available }
        while True do
          begin
            PosLineEnd := Buffer.IndexOf(#10, BufferPos);
            if PosLineEnd < 0 then
              {--- incomplete line, wait for the rest }
              Break;

            {--- Line extraction }
            Line := Buffer.Substring(BufferPos, PosLineEnd - BufferPos).Trim([' ', #13, #10]);
            BufferPos := PosLineEnd + 1;

            if Line.IsEmpty then
              begin
                {--- End of event block }
                if not CurrentData.Trim.IsEmpty then
                  begin
                    IsDone := CurrentEvent = 'response.completed';
                    ResponseData := nil;
                    if not IsDone then
                      begin
                        {--- Quick check before JSON parsing (potential optimization) }
                        if (CurrentData.Trim.StartsWith('{')) or (CurrentData.Trim.StartsWith('[')) then
                          begin
                            try
                              ResponseData := TApiDeserializer.Parse<TResponseStream>(CurrentData);
                            except
                              {--- If there is a mistake, nothing will be done. }
                              ResponseData := nil;
                            end;
                          end;
                      end;

                    try
                      {--- Call the callback with the event, the cat object and the end flag }
                      Event(ResponseData, IsDone, AAbort);
                    finally
                      ResponseData.Free;
                    end;
                  end;

                {--- Reset for next block }
                CurrentEvent := EmptyStr;
                CurrentData := EmptyStr;
              end
            else
              begin
                {--- Retrieving the information "event: ..." }
                if Line.StartsWith('event: ') then
                  begin
                    CurrentEvent := Line.Substring(7).Trim([' ', #13, #10])
                  end
                else
                {--- Retrieving the information "data: ..." }
                if Line.StartsWith('data: ') then
                  begin
                    if not CurrentData.IsEmpty then
                      CurrentData := CurrentData + sLineBreak;
                    CurrentData := CurrentData + Line.Substring(6).Trim([' ', #13, #10]);
                  end;
              end;
          end;

        {--- Buffer cleanup: keep only the incomplete portion }
        if BufferPos > 0 then
          begin
            NewBuffer := Buffer.Substring(BufferPos);

            {--- We empty the stream }
            Response.Size := 0;

            {--- then we rewrite the remaining fragment. }
            if not NewBuffer.IsEmpty then
              Response.WriteString(NewBuffer);
          end;
      end);
  finally
    Response.Free;
  end;
end;

function TResponsesRoute.Delete(const ResponseId: string): TResponseDelete;
begin
  Result := API.Delete<TResponseDelete>('responses/' + ResponseId);
end;

function TResponsesRoute.List(const ResponseId: string;
  const ParamProc: TProc<TUrlResponseListParams>): TResponses;
begin
  Result := API.Get<TResponses, TUrlResponseListParams>('responses/' + ResponseId + '/input_items', ParamProc);
end;

function TResponsesRoute.List(const ResponseId: string): TResponses;
begin
  Result := API.Get<TResponses>('responses/' + ResponseId + '/input_items');
end;

function TResponsesRoute.Retrieve(const ResponseId: string;
  const ParamProc: TProc<TURLIncludeParams>): TResponse;
begin
  Result := API.Get<TResponse, TURLIncludeParams>('responses/' + ResponseID, ParamProc);
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

end.
