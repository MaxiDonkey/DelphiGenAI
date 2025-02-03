unit GenAI.Runs;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGenAI
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.SysUtils, System.Classes, System.Threading, System.JSON, REST.Json.Types,
  REST.JsonReflect, System.Net.URLClient,
  GenAI.API.Params, GenAI.API, GenAI.Consts, GenAI.Types, GenAI.Async.Support,
  GenAI.API.Lists, GenAI.Assistants, GenAI.Threads, GenAI.Messages, GenAI.Chat;

type
  /// <summary>
  /// Represents the URL parameters for API requests related to execution runs on threads.
  /// </summary>
  /// <remarks>
  /// This class is used to customize and configure URL-based parameters for retrieving or
  /// managing runs in API requests.
  /// It extends the base functionality of <c>TUrlAdvancedParams</c>, enabling additional
  /// customization for OpenAI API endpoints related to execution runs.
  /// </remarks>
  TRunsUrlParams = TUrlAdvancedParams;

  /// <summary>
  /// Represents the configuration for selecting a tool choice when creating or running an execution
  /// run on a thread in the OpenAI API.
  /// </summary>
  /// <remarks>
  /// This class allows specifying the tool type and, optionally, the name of the function to be
  /// called during the run.
  /// The tool choice is essential for directing the assistant to use specific tools like functions
  /// during an API run execution.
  /// </remarks>
  TRunsToolChoice = class(TJSONParam)
  public
    /// <summary>
    /// Sets the type of the tool to be used for this run.
    /// </summary>
    /// <param name="Value">
    /// The type of tool to use. For example, "function" when the assistant is expected to call
    /// a function during the run.
    /// </param>
    /// <returns>
    /// Returns the current instance of <c>TRunsToolChoice</c> to allow method chaining.
    /// </returns>
    function &Type(const Value: string): TRunsToolChoice;
    /// <summary>
    /// Sets the name of the function to be called by the assistant during the run.
    /// </summary>
    /// <param name="Value">
    /// The name of the function. It should match a function defined within the assistant's toolset.
    /// </param>
    /// <returns>
    /// Returns the current instance of <c>TRunsToolChoice</c> to allow method chaining.
    /// </returns>
    function &function(const Value: string): TRunsToolChoice;
    /// <summary>
    /// Creates a new tool choice with the specified function name.
    /// </summary>
    /// <param name="FunctionName">
    /// The name of the function that should be called by the assistant during the run.
    /// </param>
    /// <returns>
    /// Returns a new instance of <c>TRunsToolChoice</c> configured with the specified function
    /// name and tool type set to "function".
    /// </returns>
    class function New(const FunctionName: string): TRunsToolChoice;
  end;

  /// <summary>
  /// Represents the truncation strategy configuration for a run in the OpenAI API.
  /// </summary>
  /// <remarks>
  /// This class allows specifying how the thread context should be truncated when constructing
  /// the prompt for the run.
  /// Different truncation strategies help optimize token usage and focus the context on relevant
  /// messages.
  /// </remarks>
  TRunsTruncationStrategy = class(TJSONParam)
  public
    /// <summary>
    /// Sets the type of truncation strategy to be used.
    /// </summary>
    /// <param name="Value">
    /// The truncation strategy type. For example, "auto" to automatically determine which messages
    /// to drop or "last_messages" to keep the most recent messages.
    /// </param>
    /// <returns>
    /// Returns the current instance of <c>TRunsTruncationStrategy</c> to allow method chaining.
    /// </returns>
    function &Type(const Value: string): TRunsTruncationStrategy; overload;
    /// <summary>
    /// Sets the type of truncation strategy using the predefined <c>TTruncationStrategyType</c>.
    /// </summary>
    /// <param name="Value">
    /// The truncation strategy type as an enumerated value.
    /// </param>
    /// <returns>
    /// Returns the current instance of <c>TRunsTruncationStrategy</c> to allow method chaining.
    /// </returns>
    function &Type(const Value: TTruncationStrategyType): TRunsTruncationStrategy; overload;
    /// <summary>
    /// Specifies the number of recent messages to retain when using the "last_messages" truncation
    /// strategy.
    /// </summary>
    /// <param name="Value">
    /// The number of most recent messages to keep in the context.
    /// </param>
    /// <returns>
    /// Returns the current instance of <c>TRunsTruncationStrategy</c> to allow method chaining.
    /// </returns>
    function LastMessages(const Value: Integer): TRunsTruncationStrategy;
  end;

  /// <summary>
  /// Represents the core parameters for creating or modifying a run in the OpenAI API.
  /// </summary>
  /// <remarks>
  /// This class provides methods to configure various settings such as model selection,
  /// instructions, token limits, tool usage, and other options that affect the behavior
  /// of the run.
  /// </remarks>
  TRunsCoreParams = class(TJSONParam)
  public
    /// <summary>
    /// Specifies the assistant to be used for the run.
    /// </summary>
    /// <param name="Value">
    /// The ID of the assistant that will execute the run.
    /// </param>
    /// <returns>
    /// Returns the current instance of <c>TRunsCoreParams</c> to allow method chaining.
    /// </returns>
    function AssistantId(const Value: string): TRunsCoreParams;
    /// <summary>
    /// Specifies the model to be used for the run, overriding the default model of the assistant
    /// if provided.
    /// </summary>
    /// <param name="Value">
    /// The ID of the model to use.
    /// </param>
    /// <returns>
    /// Returns the current instance of <c>TRunsCoreParams</c> to allow method chaining.
    /// </returns>
    function Model(const Value: string): TRunsCoreParams;
    /// <summary>
    /// Sets the primary instructions or system message that the assistant will follow during the run.
    /// </summary>
    /// <param name="Value">
    /// The instruction text.
    /// </param>
    /// <returns>
    /// Returns the current instance of <c>TRunsCoreParams</c> to allow method chaining.
    /// </returns>
    function Instructions(const Value: string): TRunsCoreParams;
    /// <summary>
    /// Appends additional instructions to the existing ones for the run.
    /// </summary>
    /// <param name="Value">
    /// The additional instruction text to append.
    /// </param>
    /// <returns>
    /// Returns the current instance of <c>TRunsCoreParams</c> to allow method chaining.
    /// </returns>
    function AdditionalInstructions(const Value: string): TRunsCoreParams;
    /// <summary>
    /// Sets the list of tools that can be used by the assistant during the run.
    /// </summary>
    /// <param name="Value">
    /// An array of tool configuration parameters.
    /// </param>
    /// <returns>
    /// Returns the current instance of <c>TRunsCoreParams</c> to allow method chaining.
    /// </returns>
    function Tools(const Value: TArray<TAssistantsToolsParams>): TRunsCoreParams;
    /// <summary>
    /// Adds metadata to the run in the form of key-value pairs.
    /// </summary>
    /// <param name="Value">
    /// A JSON object containing metadata information.
    /// </param>
    /// <returns>
    /// Returns the current instance of <c>TRunsCoreParams</c> to allow method chaining.
    /// </returns>
    function Metadata(const Value: TJSONObject): TRunsCoreParams;
    /// <summary>
    /// Specifies the temperature for sampling during the run.
    /// </summary>
    /// <param name="Value">
    /// The temperature value between 0 and 2, where higher values produce more random output.
    /// </param>
    /// <returns>
    /// Returns the current instance of <c>TRunsCoreParams</c> to allow method chaining.
    /// </returns>
    function Temperature(const Value: Double): TRunsCoreParams;
    /// <summary>
    /// Specifies the nucleus sampling value (top-p) to be used during the run.
    /// </summary>
    /// <param name="Value">
    /// A value between 0 and 1, where smaller values consider fewer tokens.
    /// </param>
    /// <returns>
    /// Returns the current instance of <c>TRunsCoreParams</c> to allow method chaining.
    /// </returns>
    function TopP(const Value: Double): TRunsCoreParams;
    /// <summary>
    /// Enables or disables token streaming during the run.
    /// </summary>
    /// <param name="Value">
    /// Set to <c>True</c> to enable streaming of tokens as they are generated.
    /// </param>
    /// <returns>
    /// Returns the current instance of <c>TRunsCoreParams</c> to allow method chaining.
    /// </returns>
    function Stream(const Value: Boolean): TRunsCoreParams;
    /// <summary>
    /// Sets the maximum number of prompt tokens allowed during the run.
    /// </summary>
    /// <param name="Value">
    /// The maximum number of tokens to use for the input prompt.
    /// </param>
    /// <returns>
    /// Returns the current instance of <c>TRunsCoreParams</c> to allow method chaining.
    /// </returns>
    function MaxPromptTokens(const Value: Integer): TRunsCoreParams;
    /// <summary>
    /// Sets the maximum number of completion tokens allowed during the run.
    /// </summary>
    /// <param name="Value">
    /// The maximum number of tokens to be generated as the output.
    /// </param>
    /// <returns>
    /// Returns the current instance of <c>TRunsCoreParams</c> to allow method chaining.
    /// </returns>
    function MaxCompletionTokens(const Value: Integer): TRunsCoreParams;
    /// <summary>
    /// Specifies the truncation strategy to be used when constructing the context for the run.
    /// </summary>
    /// <param name="Value">
    /// The truncation strategy to apply.
    /// </param>
    /// <returns>
    /// Returns the current instance of <c>TRunsCoreParams</c> to allow method chaining.
    /// </returns>
    function TruncationStrategy(const Value: TRunsTruncationStrategy): TRunsCoreParams;
    /// <summary>
    /// Sets the tool choice configuration for the run.
    /// </summary>
    /// <param name="Value">
    /// The tool choice string or object defining which tool to invoke.
    /// </param>
    /// <returns>
    /// Returns the current instance of <c>TRunsCoreParams</c> to allow method chaining.
    /// </returns>
    function ToolChoice(const Value: string): TRunsCoreParams; overload;
    /// <summary>
    /// Sets the tool choice using an object that specifies the tool and optional function details.
    /// </summary>
    /// <param name="Value">
    /// An object containing the tool and function details.
    /// </param>
    /// <returns>
    /// Returns the current instance of <c>TRunsCoreParams</c> to allow method chaining.
    /// </returns>
    function ToolChoice(const Value: TRunsToolChoice): TRunsCoreParams; overload;
    /// <summary>
    /// Enables or disables parallel tool calls during the run.
    /// </summary>
    /// <param name="Value">
    /// Set to <c>True</c> to enable multiple tool calls to run in parallel.
    /// </param>
    /// <returns>
    /// Returns the current instance of <c>TRunsCoreParams</c> to allow method chaining.
    /// </returns>
    function ParallelToolCalls(const Value: Boolean): TRunsCoreParams;
    /// <summary>
    /// Specifies the response format to be used by the assistant during the run.
    /// </summary>
    /// <param name="Value">
    /// The format string or object describing the expected response format.
    /// </param>
    /// <returns>
    /// Returns the current instance of <c>TRunsCoreParams</c> to allow method chaining.
    /// </returns>
    function ResponseFormat(const Value: string = 'auto'): TRunsCoreParams; overload;
    /// <summary>
    /// Specifies the response format using a structured object.
    /// </summary>
    /// <param name="Value">
    /// A structured response format parameter.
    /// </param>
    /// <returns>
    /// Returns the current instance of <c>TRunsCoreParams</c> to allow method chaining.
    /// </returns>
    function ResponseFormat(const Value: TResponseFormatParams): TRunsCoreParams; overload;
    /// <summary>
    /// Specifies the response format using a JSON object.
    /// </summary>
    /// <param name="Value">
    /// A JSON object describing the response format.
    /// </param>
    /// <returns>
    /// Returns the current instance of <c>TRunsCoreParams</c> to allow method chaining.
    /// </returns>
    function ResponseFormat(const Value: TJSONObject): TRunsCoreParams; overload;
  end;

  /// <summary>
  /// Represents the parameters for creating a run in the OpenAI API, extending the core parameters
  /// with additional settings.
  /// </summary>
  /// <remarks>
  /// This class extends <c>TRunsCoreParams</c> by adding options for including additional messages
  /// at the start of the thread.
  /// It allows fine-tuning the initial context and behavior of the assistant during the run.
  /// </remarks>
  TRunsParams = class(TRunsCoreParams)
  public
    /// <summary>
    /// Specifies additional messages to be included at the start of the run.
    /// </summary>
    /// <param name="Value">
    /// An array of message parameters representing the messages to include.
    /// Each message defines a role (e.g., user or assistant) and its content.
    /// </param>
    /// <returns>
    /// Returns the current instance of <c>TRunsParams</c> to allow method chaining.
    /// </returns>
    function AdditionalMessages(const Value: TArray<TThreadsMessageParams>): TRunsParams;
  end;

  /// <summary>
  /// Represents the parameters for creating a new thread and running it in the OpenAI API.
  /// </summary>
  /// <remarks>
  /// This class extends <c>TRunsCoreParams</c> and allows configuring both the thread and the
  /// tools/resources available to the assistant during the run.
  /// It is used when you need to create a new conversation thread and immediately execute the run.
  /// </remarks>
  TCreateRunsParams = class(TRunsCoreParams)
  public
    /// <summary>
    /// Specifies the configuration for creating the initial thread associated with the run.
    /// </summary>
    /// <param name="Value">
    /// A <c>TThreadsCreateParams</c> object containing details about the initial messages, roles,
    /// and context for the thread.
    /// </param>
    /// <returns>
    /// Returns the current instance of <c>TCreateRunsParams</c> to allow method chaining.
    /// </returns>
    function Thread(const Value: TThreadsCreateParams): TCreateRunsParams;
    /// <summary>
    /// Specifies the tools and resources that will be available to the assistant during the run.
    /// </summary>
    /// <param name="Value">
    /// A <c>TToolResourcesParams</c> object defining the resources, such as files or vector stores,
    /// that the assistant can access during the run.
    /// </param>
    /// <returns>
    /// Returns the current instance of <c>TCreateRunsParams</c> to allow method chaining.
    /// </returns>
    function ToolResources(const Value: TToolResourcesParams): TCreateRunsParams;
  end;

  /// <summary>
  /// Represents the parameters for updating an existing run in the OpenAI API.
  /// </summary>
  /// <remarks>
  /// This class allows modifying metadata associated with a run, enabling the attachment of
  /// key-value pairs for tracking additional information.
  /// </remarks>
  TUpdateParams = class(TJSONParam)
  public
    /// <summary>
    /// Updates the metadata associated with the run.
    /// </summary>
    /// <param name="Value">
    /// A JSON object containing key-value pairs representing additional information about the run.
    /// Keys have a maximum length of 64 characters, and values have a maximum length of 512 characters.
    /// </param>
    /// <returns>
    /// Returns the current instance of <c>TUpdateParams</c> to allow method chaining.
    /// </returns>
    function Metadata(const Value: TJSONObject): TUpdateParams;
  end;

  /// <summary>
  /// Represents the parameters for submitting tool outputs to a run in the OpenAI API.
  /// </summary>
  /// <remarks>
  /// This class allows specifying the output generated by a tool and associating it with
  /// the appropriate tool call within the run.
  /// Tool outputs are required to continue or complete certain runs that depend on external
  /// computations.
  /// </remarks>
  TToolOutputParam = class(TJSONParam)
  public
    /// <summary>
    /// Specifies the ID of the tool call that the output corresponds to.
    /// </summary>
    /// <param name="Value">
    /// The ID of the tool call, as provided in the required action details of the run.
    /// </param>
    /// <returns>
    /// Returns the current instance of <c>TToolOutputParam</c> to allow method chaining.
    /// </returns>
    function ToolCallId(const Value: string): TToolOutputParam;
    /// <summary>
    /// Sets the output produced by the tool.
    /// </summary>
    /// <param name="Value">
    /// The output value generated by the tool, which will be submitted to the run.
    /// </param>
    /// <returns>
    /// Returns the current instance of <c>TToolOutputParam</c> to allow method chaining.
    /// </returns>
    function Output(const Value: string): TToolOutputParam;
  end;

  /// <summary>
  /// Represents the parameters for submitting tool outputs to a run in the OpenAI API.
  /// </summary>
  /// <remarks>
  /// This class is used when a run requires external tool outputs to continue.
  /// It allows specifying the outputs from the tools and submitting them in a structured manner.
  /// </remarks>
  TSubmitToolParams = class(TJSONParam)
  public
    /// <summary>
    /// Specifies the outputs generated by the tools that are being submitted.
    /// </summary>
    /// <param name="Value">
    /// An instance of <c>TToolOutputParam</c> containing the details of the tool outputs, such
    /// as the tool call ID and its corresponding output.
    /// </param>
    /// <returns>
    /// Returns the current instance of <c>TSubmitToolParams</c> to allow method chaining.
    /// </returns>
    function ToolOutputs(const Value: TToolOutputParam): TSubmitToolParams;
    /// <summary>
    /// Enables or disables token streaming when submitting tool outputs.
    /// </summary>
    /// <param name="Value">
    /// Set to <c>True</c> to enable streaming, allowing the server to return a stream of events
    /// as the submission is processed.
    /// </param>
    /// <returns>
    /// Returns the current instance of <c>TSubmitToolParams</c> to allow method chaining.
    /// </returns>
    function Stream(const Value: Boolean): TSubmitToolParams;
  end;

  /// <summary>
  /// Represents the tool output submissions required to continue a run in the OpenAI API.
  /// </summary>
  /// <remarks>
  /// This class holds the collection of tool call outputs that are needed to satisfy the required
  /// action of a run.
  /// Each tool call output contains the necessary details to be processed by the run.
  /// </remarks>
  TSubmitToolOutputs = class
  private
    [JsonNameAttribute('tool_calls')]
    FToolCalls: TArray<TToolcall>;
  public
    /// <summary>
    /// Gets or sets the array of tool call objects representing the outputs to be submitted.
    /// </summary>
    property ToolCalls: TArray<TToolcall> read FToolCalls write FToolCalls;
    destructor Destroy; override;
  end;

  /// <summary>
  /// Represents details about an action required to continue an execution run in the OpenAI API.
  /// </summary>
  /// <remarks>
  /// When a run is paused and requires input or tool output to proceed, this class provides
  /// information on the specific action needed.
  /// </remarks>
  TRequiredAction = class
  private
    FType: string;
    [JsonNameAttribute('submit_tool_outputs')]
    FSubmitToolOutputs: TSubmitToolOutputs;
  public
    /// <summary>
    /// Gets or sets the type of required action.
    /// </summary>
    property &Type: string read FType write FType;
    /// <summary>
    /// Gets or sets details about the tool outputs required to continue the run.
    /// </summary>
    property SubmitToolOutputs: TSubmitToolOutputs read FSubmitToolOutputs write FSubmitToolOutputs;
    destructor Destroy; override;
  end;

  /// <summary>
  /// Represents details about the last error encountered during an execution run in the OpenAI API.
  /// </summary>
  /// <remarks>
  /// This class provides information about the error, including its code and a descriptive message.
  /// </remarks>
  TLastError = class
  private
    FCode: string;
    FMessage: string;
  public
    /// <summary>
    /// Gets or sets the code associated with the error.
    /// </summary>
    /// <remarks>
    /// Possible values include server_error, rate_limit_exceeded, or invalid_prompt.
    /// </remarks>
    property Code: string read FCode write FCode;
    /// <summary>
    /// Gets or sets a human-readable message describing the error.
    /// </summary>
    property Message: string read FMessage write FMessage;
  end;

  /// <summary>
  /// Represents details about why an execution run is incomplete in the OpenAI API.
  /// </summary>
  /// <remarks>
  /// This class provides the reason explaining why the run did not complete successfully,
  /// such as token limits or other restrictions.
  /// </remarks>
  TIncompleteDetailsReason = class
  private
    FReason: string;
  public
    /// <summary>
    /// Gets or sets the reason explaining why the run is incomplete.
    /// </summary>
    property Reason: string read FReason write FReason;
  end;

  /// <summary>
  /// Represents token usage statistics for an execution run in the OpenAI API.
  /// </summary>
  /// <remarks>
  /// This class tracks the number of tokens used during the run, including prompt tokens,
  /// completion tokens, and the total token count.
  /// </remarks>
  TRunUsage = class
  private
    [JsonNameAttribute('completion_tokens')]
    FCompletionTokens: Int64;
    [JsonNameAttribute('prompt_tokens')]
    FPromptTokens: Int64;
    [JsonNameAttribute('total_tokens')]
    FTotalTokens: Int64;
  public
    /// <summary>
    /// Gets or sets the number of completion tokens used during the run.
    /// </summary>
    property CompletionTokens: Int64 read FCompletionTokens write FCompletionTokens;
    /// <summary>
    /// Gets or sets the number of prompt tokens used during the run.
    /// </summary>
    property PromptTokens: Int64 read FPromptTokens write FPromptTokens;
    /// <summary>
    /// Gets or sets the total number of tokens (prompt + completion) used during the run.
    /// </summary>
    property TotalTokens: Int64 read FTotalTokens write FTotalTokens;
  end;

  /// <summary>
  /// Represents the truncation strategy used to manage the context window for an execution run
  /// in the OpenAI API.
  /// </summary>
  /// <remarks>
  /// This class allows control over how much of the thread's context is included in the prompt,
  /// which helps optimize token usage.
  /// </remarks>
  TTruncationStrategy = class
  private
    [JsonReflectAttribute(ctString, rtString, TTruncationStrategyTypeInterceptor)]
    FType: TTruncationStrategyType;
    [JsonNameAttribute('last_messages')]
    FLastMessages: Int64;
  public
    /// <summary>
    /// Gets or sets the type of truncation strategy.
    /// </summary>
    /// <remarks>
    /// Common types include "auto" for automatic truncation and "last_messages" for retaining only
    /// the most recent messages.
    /// </remarks>
    property &Type: TTruncationStrategyType read FType write FType;
    /// <summary>
    /// Gets or sets the number of most recent messages to retain when using the "last_messages"
    /// truncation strategy.
    /// </summary>
    property LastMessages: Int64 read FLastMessages write FLastMessages;
  end;

  TRunTimeStamp = class(TJSONFingerprint)
  protected
    function GetCreatedAtAsString: string; virtual; abstract;
    function GetExpiresAtAsString: string; virtual; abstract;
    function GetStartedAtAsString: string; virtual; abstract;
    function GetCancelledAtAsString: string; virtual; abstract;
    function GetFailedAtAsString: string; virtual; abstract;
    function GetCompletedAtAsString: string; virtual; abstract;
  public
    property CreatedAtAsString: string read GetCreatedAtAsString;
    property ExpiresAtAsString: string read GetExpiresAtAsString;
    property StartedAtAsString: string read GetStartedAtAsString;
    property CancelledAtAsString: string read GetCancelledAtAsString;
    property FailedAtAsString: string read GetFailedAtAsString;
    property CompletedAtAsString: string read GetCompletedAtAsString;
  end;

  /// <summary>
  /// Represents an execution run on a thread in the OpenAI API.
  /// </summary>
  /// <remarks>
  /// This class contains information about the run, such as its status, associated assistant,
  /// model, instructions, token usage, and any errors encountered.
  /// </remarks>
  TRun = class(TRunTimeStamp)
  private
    FId: string;
    [JsonNameAttribute('created_at')]
    FCreatedAt: Int64;
    FObject: string;
    [JsonNameAttribute('thread_id')]
    FThreadId: string;
    [JsonNameAttribute('assistant_id')]
    FAssistantId: string;
    [JsonReflectAttribute(ctString, rtString, TRunStatusInterceptor)]
    FStatus: TRunStatus;
    [JsonNameAttribute('required_action')]
    FRequiredAction: TRequiredAction;
    [JsonNameAttribute('last_error')]
    FLastError: TLastError;
    [JsonNameAttribute('expires_at')]
    FExpiresAt: Int64;
    [JsonNameAttribute('started_at')]
    FStartedAt: Int64;
    [JsonNameAttribute('cancelled_at')]
    FCancelledAt: Int64;
    [JsonNameAttribute('failed_at')]
    FFailedAt: Int64;
    [JsonNameAttribute('completed_at')]
    FCompletedAt: Int64;
    [JsonNameAttribute('incomplete_details')]
    FIncompleteDetails: TIncompleteDetails;
    FModel: string;
    FInstructions: string;
    FTools: TArray<TAssistantsTools>;
    [JsonReflectAttribute(ctString, rtString, TMetadataInterceptor)]
    FMetadata: string;
    FUsage: TRunUsage;
    FTemperature: Double;
    [JsonNameAttribute('top_p')]
    FTopP: Double;
    [JsonNameAttribute('max_prompt_tokens')]
    FMaxPromptTokens: Int64;
    [JsonNameAttribute('max_completion_tokens')]
    FMaxCompletionTokens: Int64;
    [JsonNameAttribute('truncation_strategy')]
    FTruncationStrategy: TTruncationStrategy;
    [JsonNameAttribute('tool_choice')]
    FToolChoice: string;
    [JsonNameAttribute('parallel_tool_calls')]
    FParallelToolCalls: Boolean;
    [JsonNameAttribute('response_format')]
    FResponseFormat: string;
  protected
    function GetCreatedAtAsString: string; override;
    function GetExpiresAtAsString: string; override;
    function GetStartedAtAsString: string; override;
    function GetCancelledAtAsString: string; override;
    function GetFailedAtAsString: string; override;
    function GetCompletedAtAsString: string; override;
  public
    /// <summary>
    /// Gets or sets the unique identifier of the run.
    /// </summary>
    property Id: string read FId write FId;
    /// <summary>
    /// Gets or sets the creation timestamp of the run.
    /// </summary>
    property CreatedAt: Int64 read FCreatedAt write FCreatedAt;
    /// <summary>
    /// Gets or sets the object type, which is always "thread.run".
    /// </summary>
    property &Object: string read FObject write FObject;
    /// <summary>
    /// Gets or sets the ID of the thread associated with this run.
    /// </summary>
    property ThreadId: string read FThreadId write FThreadId;
    /// <summary>
    /// Gets or sets the ID of the assistant used during the run.
    /// </summary>
    property AssistantId: string read FAssistantId write FAssistantId;
    /// <summary>
    /// Gets or sets the status of the run.
    /// </summary>
    /// <remarks>
    /// Possible statuses include "queued", "in_progress", "requires_action", "failed",
    /// "completed", and others.
    /// </remarks>
    property Status: TRunStatus read FStatus write FStatus;
    /// <summary>
    /// Gets or sets details of any required action to continue the run.
    /// </summary>
    property RequiredAction: TRequiredAction read FRequiredAction write FRequiredAction;
    /// <summary>
    /// Gets or sets details about the last error encountered during the run, if any.
    /// </summary>
    property LastError: TLastError read FLastError write FLastError;
    /// <summary>
    /// Gets or sets the expiration timestamp of the run.
    /// </summary>
    property ExpiresAt: Int64 read FExpiresAt write FExpiresAt;
    /// <summary>
    /// Gets or sets the timestamp when the run started.
    /// </summary>
    property StartedAt: Int64 read FStartedAt write FStartedAt;
    /// <summary>
    /// Gets or sets the timestamp when the run was canceled, if applicable.
    /// </summary>
    property CancelledAt: Int64 read FCancelledAt write FCancelledAt;
    /// <summary>
    /// Gets or sets the timestamp when the run failed, if applicable.
    /// </summary>
    property FailedAt: Int64 read FFailedAt write FFailedAt;
    /// <summary>
    /// Gets or sets the timestamp when the run was completed, if applicable.
    /// </summary>
    property CompletedAt: Int64 read FCompletedAt write FCompletedAt;
    /// <summary>
    /// Gets or sets details explaining why the run is incomplete, if applicable.
    /// </summary>
    property IncompleteDetails: TIncompleteDetails read FIncompleteDetails write FIncompleteDetails;
    /// <summary>
    /// Gets or sets the model used during the run.
    /// </summary>
    property Model: string read FModel write FModel;
    /// <summary>
    /// Gets or sets the instructions provided to the assistant for this run.
    /// </summary>
    property Instructions: string read FInstructions write FInstructions;
    /// <summary>
    /// Gets or sets the tools available or used by the assistant during the run.
    /// </summary>
    property Tools: TArray<TAssistantsTools> read FTools write FTools;
    /// <summary>
    /// Gets or sets metadata associated with the run.
    /// </summary>
    property Metadata: string read FMetadata write FMetadata;
    /// <summary>
    /// Gets or sets the token usage statistics for this run.
    /// </summary>
    property Usage: TRunUsage read FUsage write FUsage;
    /// <summary>
    /// Gets or sets the sampling temperature used for the run.
    /// </summary>
    /// <remarks>
    /// Higher values make the output more random, while lower values make it more focused
    /// and deterministic.
    /// </remarks>
    property Temperature: Double read FTemperature write FTemperature;
    /// <summary>
    /// Gets or sets the nucleus sampling parameter for the run.
    /// </summary>
    /// <remarks>
    /// The top_p value determines the probability mass to consider for selecting tokens
    /// during generation.
    /// </remarks>
    property TopP: Double read FTopP write FTopP;
    /// <summary>
    /// Gets or sets the maximum number of prompt tokens allowed during the run.
    /// </summary>
    property MaxPromptTokens: Int64 read FMaxPromptTokens write FMaxPromptTokens;
    /// <summary>
    /// Gets or sets the maximum number of completion tokens allowed during the run.
    /// </summary>
    property MaxCompletionTokens: Int64 read FMaxCompletionTokens write FMaxCompletionTokens;
    /// <summary>
    /// Gets or sets the truncation strategy used for the run.
    /// </summary>
    property TruncationStrategy: TTruncationStrategy read FTruncationStrategy write FTruncationStrategy;
    /// <summary>
    /// Gets or sets the tool choice configuration for the run.
    /// </summary>
    property ToolChoice: string read FToolChoice write FToolChoice;
    /// <summary>
    /// Gets or sets whether parallel tool calls are enabled during the run.
    /// </summary>
    property ParallelToolCalls: Boolean read FParallelToolCalls write FParallelToolCalls;
    /// <summary>
    /// Gets or sets the response format expected for the run.
    /// </summary>
    property ResponseFormat: string read FResponseFormat write FResponseFormat;
    destructor Destroy; override;
  end;

  /// <summary>
  /// Represents a list of execution runs on a thread in the OpenAI API.
  /// </summary>
  /// <remarks>
  /// This class is a collection of <c>TRun</c> objects, providing access to multiple execution
  /// runs associated with a specific thread.
  /// It can be used to iterate through and retrieve information about each run.
  /// </remarks>
  TRuns = TAdvancedList<TRun>;

  /// <summary>
  /// Manages asynchronous callBacks for a request using <c>TRun</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynRun</c> type extends the <c>TAsynParams&lt;TRun&gt;</c> record to handle the lifecycle
  /// of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts,
  /// completes successfully, or encounters an error.
  /// This structure facilitates non-blocking operations.
  /// </remarks>
  TAsynRun = TAsynCallBack<TRun>;

  /// <summary>
  /// Manages asynchronous callBacks for a request using <c>TRuns</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynRuns</c> type extends the <c>TAsynParams&lt;TRuns&gt;</c> record to handle the
  /// lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts,
  /// completes successfully, or encounters an error.
  /// This structure facilitates non-blocking operations.
  /// </remarks>
  TAsynRuns = TAsynCallBack<TRuns>;

  /// <summary>
  /// Represents the route for managing execution runs in the OpenAI API.
  /// </summary>
  /// <remarks>
  /// This class provides methods to create, retrieve, update, list, and manage execution runs on threads.
  /// It handles both synchronous and asynchronous requests, allowing efficient interaction with
  /// the OpenAI API for execution management.
  /// </remarks>
  TRunsRoute = class(TGenAIRoute)
  protected
    /// <summary>
    /// Customizes the headers used for the message routes.
    /// </summary>
    procedure HeaderCustomize; override;
  public
    /// <summary>
    /// Asynchronously creates an execution run on a thread.
    /// </summary>
    /// <param name="ThreadId">The ID of the thread to run.</param>
    /// <param name="ParamProc">A procedure specifying run parameters.</param>
    /// <param name="CallBacks">Callback functions to handle asynchronous execution.</param>
    procedure AsynCreate(const ThreadId: string; const ParamProc: TProc<TRunsParams>;
      const CallBacks: TFunc<TAsynRun>);
    /// <summary>
    /// Asynchronously creates a thread and runs it in one request.
    /// </summary>
    /// <param name="ParamProc">A procedure specifying thread creation and run parameters.</param>
    /// <param name="CallBacks">Callback functions to handle asynchronous execution.</param>
    procedure AsynCreateAndRun(const ParamProc: TProc<TCreateRunsParams>;
      const CallBacks: TFunc<TAsynRun>);
    /// <summary>
    /// Asynchronously retrieves a list of execution runs associated with a thread.
    /// </summary>
    /// <param name="ThreadId">The ID of the thread whose runs are to be listed.</param>
    /// <param name="CallBacks">Callback functions to handle asynchronous execution.</param>
    procedure AsynList(const ThreadId: string; const CallBacks: TFunc<TAsynRuns>); overload;
    /// <summary>
    /// Asynchronously retrieves a filtered list of execution runs associated with a thread.
    /// </summary>
    /// <param name="ThreadId">The ID of the thread whose runs are to be listed.</param>
    /// <param name="ParamProc">A procedure specifying filter parameters for listing runs.</param>
    /// <param name="CallBacks">Callback functions to handle asynchronous execution.</param>
    procedure AsynList(const ThreadId: string; const ParamProc: TProc<TRunsUrlParams>;
      const CallBacks: TFunc<TAsynRuns>); overload;
    /// <summary>
    /// Asynchronously retrieves details of a specific execution run.
    /// </summary>
    /// <param name="ThreadId">The ID of the thread that contains the run.</param>
    /// <param name="RunId">The ID of the run to retrieve.</param>
    /// <param name="CallBacks">Callback functions to handle asynchronous execution.</param>
    procedure AsynRetrieve(const ThreadId: string; const RunId: string;
      const CallBacks: TFunc<TAsynRun>);
    /// <summary>
    /// Asynchronously updates an existing execution run with new metadata.
    /// </summary>
    /// <param name="ThreadId">The ID of the thread containing the run.</param>
    /// <param name="RunId">The ID of the run to update.</param>
    /// <param name="ParamProc">A procedure specifying update parameters.</param>
    /// <param name="CallBacks">Callback functions to handle asynchronous execution.</param>
    procedure AsynUpdate(const ThreadId: string; const RunId: string;
      const ParamProc: TProc<TUpdateParams>;
      const CallBacks: TFunc<TAsynRun>);
    /// <summary>
    /// Asynchronously submits tool outputs for a paused run that requires them to continue.
    /// </summary>
    /// <param name="ThreadId">The ID of the thread containing the run.</param>
    /// <param name="RunId">The ID of the run requiring tool outputs.</param>
    /// <param name="ParamProc">A procedure specifying tool output parameters.</param>
    /// <param name="CallBacks">Callback functions to handle asynchronous execution.</param>
    procedure AsynSubmitTool(const ThreadId: string; const RunId: string;
      const ParamProc: TProc<TSubmitToolParams>;
      const CallBacks: TFunc<TAsynRun>);
    /// <summary>
    /// Asynchronously cancels an execution run that is in progress.
    /// </summary>
    /// <param name="ThreadId">The ID of the thread containing the run.</param>
    /// <param name="RunId">The ID of the run to cancel.</param>
    /// <param name="CallBacks">Callback functions to handle asynchronous execution.</param>
    procedure AsynCancel(const ThreadId: string; const RunId: string;
      const CallBacks: TFunc<TAsynRun>);
    /// <summary>
    /// Creates a new execution run on a thread.
    /// </summary>
    /// <param name="ThreadId">The ID of the thread to run.</param>
    /// <param name="ParamProc">A procedure specifying run parameters.</param>
    /// <returns>The created <c>TRun</c> object representing the execution run.</returns>
    function Create(const ThreadId: string; const ParamProc: TProc<TRunsParams>): TRun;
    /// <summary>
    /// Creates a thread and runs it in one request.
    /// </summary>
    /// <param name="ParamProc">A procedure specifying thread creation and run parameters.</param>
    /// <returns>The created <c>TRun</c> object representing the execution run.</returns>
    function CreateAndRun(const ParamProc: TProc<TCreateRunsParams>): TRun;
    /// <summary>
    /// Retrieves a list of execution runs associated with a thread.
    /// </summary>
    /// <param name="ThreadId">The ID of the thread whose runs are to be listed.</param>
    /// <returns>A list of <c>TRun</c> objects representing the execution runs.</returns>
    function List(const ThreadId: string): TRuns; overload;
    /// <summary>
    /// Retrieves a filtered list of execution runs associated with a thread.
    /// </summary>
    /// <param name="ThreadId">The ID of the thread whose runs are to be listed.</param>
    /// <param name="ParamProc">A procedure specifying filter parameters for listing runs.</param>
    /// <returns>A list of <c>TRun</c> objects representing the filtered execution runs.</returns>
    function List(const ThreadId: string; const ParamProc: TProc<TRunsUrlParams>): TRuns; overload;
    /// <summary>
    /// Retrieves details of a specific execution run.
    /// </summary>
    /// <param name="ThreadId">The ID of the thread containing the run.</param>
    /// <param name="RunId">The ID of the run to retrieve.</param>
    /// <returns>The <c>TRun</c> object containing the run details.</returns>
    function Retrieve(const ThreadId: string; const RunId: string): TRun;
    /// <summary>
    /// Updates an existing execution run with new metadata.
    /// </summary>
    /// <param name="ThreadId">The ID of the thread containing the run.</param>
    /// <param name="RunId">The ID of the run to update.</param>
    /// <param name="ParamProc">A procedure specifying update parameters.</param>
    /// <returns>The updated <c>TRun</c> object.</returns>
    function Update(const ThreadId: string; const RunId: string;
      const ParamProc: TProc<TUpdateParams>): TRun;
    /// <summary>
    /// Submits tool outputs for a paused run that requires them to continue.
    /// </summary>
    /// <param name="ThreadId">The ID of the thread containing the run.</param>
    /// <param name="RunId">The ID of the run requiring tool outputs.</param>
    /// <param name="ParamProc">A procedure specifying tool output parameters.</param>
    /// <returns>The updated <c>TRun</c> object after tool submission.</returns>
    function SubmitTool(const ThreadId: string; const RunId: string;
      const ParamProc: TProc<TSubmitToolParams>): TRun;
    /// <summary>
    /// Cancels an execution run that is in progress.
    /// </summary>
    /// <param name="ThreadId">The ID of the thread containing the run.</param>
    /// <param name="RunId">The ID of the run to cancel.</param>
    /// <returns>The <c>TRun</c> object with the updated status indicating cancellation.</returns>
    function Cancel(const ThreadId: string; const RunId: string): TRun;
  end;

implementation

{ TRunsRoute }

procedure TRunsRoute.AsynCancel(const ThreadId, RunId: string;
  const CallBacks: TFunc<TAsynRun>);
begin
  with TAsynCallBackExec<TAsynRun, TRun>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TRun
      begin
        Result := Self.Cancel(ThreadId, RunId);
      end);
  finally
    Free;
  end;
end;

procedure TRunsRoute.AsynCreate(const ThreadId: string;
  const ParamProc: TProc<TRunsParams>; const CallBacks: TFunc<TAsynRun>);
begin
  with TAsynCallBackExec<TAsynRun, TRun>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TRun
      begin
        Result := Self.Create(ThreadId, ParamProc);
      end);
  finally
    Free;
  end;
end;

procedure TRunsRoute.AsynCreateAndRun(const ParamProc: TProc<TCreateRunsParams>;
  const CallBacks: TFunc<TAsynRun>);
begin
  with TAsynCallBackExec<TAsynRun, TRun>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TRun
      begin
        Result := Self.CreateAndRun(ParamProc);
      end);
  finally
    Free;
  end;
end;

procedure TRunsRoute.AsynList(const ThreadId: string;
  const ParamProc: TProc<TRunsUrlParams>; const CallBacks: TFunc<TAsynRuns>);
begin
  with TAsynCallBackExec<TAsynRuns, TRuns>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TRuns
      begin
        Result := Self.List(ThreadId, ParamProc);
      end);
  finally
    Free;
  end;
end;

procedure TRunsRoute.AsynList(const ThreadId: string;
  const CallBacks: TFunc<TAsynRuns>);
begin
  with TAsynCallBackExec<TAsynRuns, TRuns>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TRuns
      begin
        Result := Self.List(ThreadId);
      end);
  finally
    Free;
  end;
end;

procedure TRunsRoute.AsynRetrieve(const ThreadId, RunId: string;
  const CallBacks: TFunc<TAsynRun>);
begin
  with TAsynCallBackExec<TAsynRun, TRun>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TRun
      begin
        Result := Self.Retrieve(ThreadId, RunId);
      end);
  finally
    Free;
  end;
end;

procedure TRunsRoute.AsynSubmitTool(const ThreadId, RunId: string;
  const ParamProc: TProc<TSubmitToolParams>; const CallBacks: TFunc<TAsynRun>);
begin
  with TAsynCallBackExec<TAsynRun, TRun>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TRun
      begin
        Result := Self.SubmitTool(ThreadId, RunId, ParamProc);
      end);
  finally
    Free;
  end;
end;

procedure TRunsRoute.AsynUpdate(const ThreadId, RunId: string;
  const ParamProc: TProc<TUpdateParams>; const CallBacks: TFunc<TAsynRun>);
begin
  with TAsynCallBackExec<TAsynRun, TRun>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TRun
      begin
        Result := Self.Update(ThreadId, RunId, ParamProc);
      end);
  finally
    Free;
  end;
end;

function TRunsRoute.Cancel(const ThreadId, RunId: string): TRun;
begin
  HeaderCustomize;
  Result := API.Post<TRun>('threads/' + ThreadId + '/runs/' + RunId + '/cancel');
end;

function TRunsRoute.Create(const ThreadId: string;
  const ParamProc: TProc<TRunsParams>): TRun;
begin
  HeaderCustomize;
  Result := API.Post<TRun, TRunsParams>('threads/' + ThreadId + '/runs', ParamProc);
end;

function TRunsRoute.CreateAndRun(
  const ParamProc: TProc<TCreateRunsParams>): TRun;
begin
  HeaderCustomize;
  Result := API.Post<TRun, TCreateRunsParams>('threads/runs', ParamProc);
end;

procedure TRunsRoute.HeaderCustomize;
begin
  inherited;
  API.CustomHeaders := [TNetHeader.Create('OpenAI-Beta', 'assistants=v2')];
end;

function TRunsRoute.List(const ThreadId: string): TRuns;
begin
  HeaderCustomize;
  Result := API.Get<TRuns>('threads/' + ThreadId + '/runs');
end;

function TRunsRoute.List(const ThreadId: string;
  const ParamProc: TProc<TRunsUrlParams>): TRuns;
begin
  HeaderCustomize;
  Result := API.Get<TRuns, TRunsUrlParams>('threads/' + ThreadId + '/runs', ParamProc);
end;

function TRunsRoute.Retrieve(const ThreadId, RunId: string): TRun;
begin
  HeaderCustomize;
  Result := API.Get<TRun>('threads/' + ThreadId + '/runs/' + RunId);
end;

function TRunsRoute.SubmitTool(const ThreadId, RunId: string;
  const ParamProc: TProc<TSubmitToolParams>): TRun;
begin
  HeaderCustomize;
  Result := API.Post<TRun, TSubmitToolParams>('threads/' + ThreadId + '/runs/' + RunId + '/submit_tool_outputs', ParamProc);
end;

function TRunsRoute.Update(const ThreadId, RunId: string;
  const ParamProc: TProc<TUpdateParams>): TRun;
begin
  HeaderCustomize;
  Result := API.Post<TRun, TUpdateParams>('threads/' + ThreadId + '/runs/' + RunId, ParamProc);
end;

{ TRunsCoreParams }

function TRunsCoreParams.AdditionalInstructions(const Value: string): TRunsCoreParams;
begin
  Result := TRunsCoreParams(Add('additional_instructions', Value));
end;

function TRunsCoreParams.AssistantId(const Value: string): TRunsCoreParams;
begin
  Result := TRunsCoreParams(Add('assistant_id', Value));
end;

function TRunsCoreParams.Instructions(const Value: string): TRunsCoreParams;
begin
  Result := TRunsCoreParams(Add('instructions', Value));
end;

function TRunsCoreParams.MaxCompletionTokens(const Value: Integer): TRunsCoreParams;
begin
  Result := TRunsCoreParams(Add('max_completion_tokens', Value));
end;

function TRunsCoreParams.MaxPromptTokens(const Value: Integer): TRunsCoreParams;
begin
  Result := TRunsCoreParams(Add('max_prompt_tokens', Value));
end;

function TRunsCoreParams.Metadata(const Value: TJSONObject): TRunsCoreParams;
begin
  Result := TRunsCoreParams(Add('metadata', Value));
end;

function TRunsCoreParams.Model(const Value: string): TRunsCoreParams;
begin
  Result := TRunsCoreParams(Add('model', Value));
end;

function TRunsCoreParams.ParallelToolCalls(const Value: Boolean): TRunsCoreParams;
begin
  Result := TRunsCoreParams(Add('parallel_tool_calls', Value));
end;

function TRunsCoreParams.ResponseFormat(
  const Value: TResponseFormatParams): TRunsCoreParams;
begin
  Result := TRunsCoreParams(Add('response_format', Value.Detach));
end;

function TRunsCoreParams.ResponseFormat(const Value: string): TRunsCoreParams;
begin
  Result := TRunsCoreParams(Add('response_format', Value));
end;

function TRunsCoreParams.Stream(const Value: Boolean): TRunsCoreParams;
begin
  Result := TRunsCoreParams(Add('stream', Value));
end;

function TRunsCoreParams.Temperature(const Value: Double): TRunsCoreParams;
begin
  Result := TRunsCoreParams(Add('temperature', Value));
end;

function TRunsCoreParams.ToolChoice(const Value: string): TRunsCoreParams;
begin
  Result := TRunsCoreParams(Add('tool_choice', Value));
end;

function TRunsCoreParams.ToolChoice(const Value: TRunsToolChoice): TRunsCoreParams;
begin
  Result := TRunsCoreParams(Add('tool_choice', Value.Detach));
end;

function TRunsCoreParams.Tools(const Value: TArray<TAssistantsToolsParams>): TRunsCoreParams;
begin
  var JSONArray := TJSONArray.Create;
  for var Item in Value do
    JSONArray.Add(Item.Detach);
  Result := TRunsCoreParams(Add('tools', JSONArray));
end;

function TRunsCoreParams.TopP(const Value: Double): TRunsCoreParams;
begin
  Result := TRunsCoreParams(Add('top_p', Value));
end;

function TRunsCoreParams.TruncationStrategy(
  const Value: TRunsTruncationStrategy): TRunsCoreParams;
begin
  Result := TRunsCoreParams(Add('truncation_strategy', Value.Detach));
end;

function TRunsCoreParams.ResponseFormat(const Value: TJSONObject): TRunsCoreParams;
begin
  Result := TRunsCoreParams(Add('response_format', Value));
end;

{ TRunsTruncationStrategy }

function TRunsTruncationStrategy.LastMessages(
  const Value: Integer): TRunsTruncationStrategy;
begin
  Result := TRunsTruncationStrategy(Add('last_messages', Value));
end;

function TRunsTruncationStrategy.&Type(const Value: string): TRunsTruncationStrategy;
begin
  Result := TRunsTruncationStrategy(Add('type', TTruncationStrategyType.Create(Value).ToString));
end;

function TRunsTruncationStrategy.&Type(
  const Value: TTruncationStrategyType): TRunsTruncationStrategy;
begin
  Result := TRunsTruncationStrategy(Add('type', Value.ToString));
end;

{ TRunsToolChoice }

function TRunsToolChoice.&function(
  const Value: string): TRunsToolChoice;
begin
  Result := TRunsToolChoice(Add('function', TJSONObject.Create.AddPair('name', Value)));
end;

class function TRunsToolChoice.New(
  const FunctionName: string): TRunsToolChoice;
begin
  Result := TRunsToolChoice.Create.&Type('function').&function(FunctionName);
end;

function TRunsToolChoice.&Type(
  const Value: string): TRunsToolChoice;
begin
  Result := TRunsToolChoice(Add('type', Value));
end;

{ TRun }

destructor TRun.Destroy;
begin
  if Assigned(FRequiredAction) then
    FRequiredAction.Free;
  if Assigned(FLastError) then
    FLastError.Free;
  if Assigned(FIncompleteDetails) then
    FIncompleteDetails.Free;
  for var Item in FTools do
    Item.Free;
  if Assigned(FUsage) then
    FUsage.Free;
  if Assigned(FTruncationStrategy) then
    FTruncationStrategy.Free;
  inherited;
end;

function TRun.GetCancelledAtAsString: string;
begin
  Result := TimestampToString(CancelledAt, UTCtimestamp);
end;

function TRun.GetCompletedAtAsString: string;
begin
  Result := TimestampToString(CompletedAt, UTCtimestamp);
end;

function TRun.GetCreatedAtAsString: string;
begin
  Result := TimestampToString(CreatedAt, UTCtimestamp);
end;

function TRun.GetExpiresAtAsString: string;
begin
  Result := TimestampToString(ExpiresAt, UTCtimestamp);
end;

function TRun.GetFailedAtAsString: string;
begin
  Result := TimestampToString(FailedAt, UTCtimestamp);
end;

function TRun.GetStartedAtAsString: string;
begin
  Result := TimestampToString(StartedAt, UTCtimestamp);
end;

{ TRequiredAction }

destructor TRequiredAction.Destroy;
begin
  if Assigned(FSubmitToolOutputs) then
    FSubmitToolOutputs.Free;
  inherited;
end;

{ TSubmitToolOutputs }

destructor TSubmitToolOutputs.Destroy;
begin
  for var Item in FToolCalls do
    Item.Free;
  inherited;
end;

{ TRunsParams }

function TRunsParams.AdditionalMessages(
  const Value: TArray<TThreadsMessageParams>): TRunsParams;
begin
  var JSONArray := TJSONArray.Create;
  for var Item in Value do
    JSONArray.Add(Item.Detach);
  Result := TRunsParams(Add('additional_messages', JSONArray));
end;

{ TCreateRunsParams }

function TCreateRunsParams.Thread(
  const Value: TThreadsCreateParams): TCreateRunsParams;
begin
  Result := TCreateRunsParams(Add('thread', Value.Detach));
end;

function TCreateRunsParams.ToolResources(
  const Value: TToolResourcesParams): TCreateRunsParams;
begin
  Result := TCreateRunsParams(Add('tool_resources', Value.Detach));
end;

{ TUpdateParams }

function TUpdateParams.Metadata(const Value: TJSONObject): TUpdateParams;
begin
  Result := TUpdateParams(Add('metadata', Value));
end;

{ TToolOutputParam }

function TToolOutputParam.Output(const Value: string): TToolOutputParam;
begin
  Result := TToolOutputParam(Add('output', Value));
end;

function TToolOutputParam.ToolCallId(const Value: string): TToolOutputParam;
begin
  Result := TToolOutputParam(Add('tool_call_id', Value));
end;

{ TSubmitToolParams }

function TSubmitToolParams.Stream(const Value: Boolean): TSubmitToolParams;
begin
  Result := TSubmitToolParams(Add('stream', Value));
end;

function TSubmitToolParams.ToolOutputs(
  const Value: TToolOutputParam): TSubmitToolParams;
begin
  Result := TSubmitToolParams(Add('tool_outputs', Value.Detach));
end;

end.
