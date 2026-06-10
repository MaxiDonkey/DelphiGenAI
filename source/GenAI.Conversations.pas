unit GenAI.Conversations;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGenAI
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.SysUtils, System.Classes, System.Threading, System.JSON, REST.Json.Types,
  REST.JsonReflect,
  GenAI.API.Params, GenAI.API, GenAI.Types,
  GenAI.Async.Params, GenAI.Async.Support, GenAI.Async.Promise, GenAI.Chat.Parallel,
  GenAI.Responses.InputParams, GenAI.Responses.InputItemList, GenAI.Responses.OutputParams;

type
  TConversationsParams = class(TJSONParam)
    /// <summary>
    /// Initial items to include in the conversation context. You may add up to 20 items at a time.
    /// </summary>
    function Items(const Value: TArray<TInputListItem>): TConversationsParams;

    /// <summary>
    /// Set of 16 key-value pairs that can be attached to an object. This can be useful for storing
    /// additional information about the object in a structured format, and querying for objects via
    /// API or the dashboard. Keys are strings with a maximum length of 64 characters. Values are
    /// strings with a maximum length of 512 characters.
    /// </summary>
    function Metadata(const Value: TJSONObject): TConversationsParams;

    class function New: TConversationsParams;
  end;

  TUpdateConversationsParams = class(TJSONParam)
    /// <summary>
    /// Set of 16 key-value pairs that can be attached to an object. This can be useful for storing
    /// additional information about the object in a structured format, and querying for objects via
    /// API or the dashboard. Keys are strings with a maximum length of 64 characters. Values are
    /// strings with a maximum length of 512 characters.
    /// </summary>
    function Metadata(const Value: TJSONObject): TUpdateConversationsParams;

    class function New: TUpdateConversationsParams;
  end;

  TUrlListItemsParams = class(TUrlParam)
    /// <summary>
    /// An item ID to list items after, used in pagination.
    /// </summary>
    function After(const Value: string): TUrlListItemsParams;

    /// <summary>
    /// Specify additional output data to include in the model response.
    /// </summary>
    /// <remarks>
    /// Currently supported values are:
    /// <para>
    /// • <c>web_search_call_action_sources</c>: Include the sources of the web search tool call.
    /// </para>
    /// <para>
    /// • <c>code_interpreter_call_outputs</c>: Includes the outputs of python code execution in code
    /// </para>
    /// <para>
    /// • <c>computer_call_output_output_image_url</c>: Include image urls from the computer call output.
    /// </para>
    /// <para>
    /// • <c>file_search_call_results</c>: Include the search results of the file search tool call.
    /// </para>
    /// <para>
    /// • <c>message_input_image_image_url</c>: Include image urls from the input message.
    /// </para>
    /// <para>
    /// • <c>message_output_text_logprobs</c>: Include logprobs with assistant messages.
    /// </para>
    /// <para>
    /// • <c>reasoning_encrypted_content</c>: Includes an encrypted version of reasoning tokens in reasoning item
    /// outputs. This enables reasoning items to be used in multi-turn conversations when using the Responses
    /// API statelessly (like when the store parameter is set to false, or when an organization is enrolled
    /// in the zero data retention program).
    /// </para>
    /// </remarks>
    function Include(const Value: TArray<TOutputIncluding>): TUrlListItemsParams; overload;

    /// <summary>
    /// Specify additional output data to include in the model response.
    /// </summary>
    /// <remarks>
    /// Currently supported values are:
    /// <para>
    /// • <c>web_search_call.action.sources</c>: Include the sources of the web search tool call.
    /// </para>
    /// <para>
    /// • <c>code_interpreter_call.outputs</c>: Includes the outputs of python code execution in code
    /// </para>
    /// <para>
    /// • <c>computer_call_output.output.image_url</c>: Include image urls from the computer call output.
    /// </para>
    /// <para>
    /// • <c>file_search_call.results</c>: Include the search results of the file search tool call.
    /// </para>
    /// <para>
    /// • <c>message.input_image.image_url</c>: Include image urls from the input message.
    /// </para>
    /// <para>
    /// • <c>message.output_text.logprobs</c>: Include logprobs with assistant messages.
    /// </para>
    /// <para>
    /// • <c>reasoning.encrypted_content</c>: Includes an encrypted version of reasoning tokens in reasoning item
    /// outputs. This enables reasoning items to be used in multi-turn conversations when using the Responses
    /// API statelessly (like when the store parameter is set to false, or when an organization is enrolled
    /// in the zero data retention program).
    /// </para>
    /// </remarks>
    function Include(const Value: TArray<string>): TUrlListItemsParams; overload;

    /// <summary>
    /// A limit on the number of objects to be returned.
    /// </summary>
    /// <remarks>
    /// Limit can range between 1 and 100, and the default is 20.
    /// </remarks>
    function Limit(const Value: Integer): TUrlListItemsParams;

    /// <summary>
    /// The order to return the input items in. Default is desc.
    /// </summary>
    /// <remarks>
    /// <para>
    /// • asc: Return the input items in ascending order.
    /// </para>
    /// <para>
    /// • desc: Return the input items in descending order.
    /// </para>
    /// </remarks>
    function Order(const Value: string = 'desc'): TUrlListItemsParams;
  end;

  TUrlConversationsItemParams = class(TUrlParam)
    /// <summary>
    /// Specify additional output data to include in the model response.
    /// </summary>
    /// <remarks>
    /// Currently supported values are:
    /// <para>
    /// • <c>web_search_call_action_sources</c>: Include the sources of the web search tool call.
    /// </para>
    /// <para>
    /// • <c>code_interpreter_call_outputs</c>: Includes the outputs of python code execution in code
    /// </para>
    /// <para>
    /// • <c>computer_call_output_output_image_url</c>: Include image urls from the computer call output.
    /// </para>
    /// <para>
    /// • <c>file_search_call_results</c>: Include the search results of the file search tool call.
    /// </para>
    /// <para>
    /// • <c>message_input_image_image_url</c>: Include image urls from the input message.
    /// </para>
    /// <para>
    /// • <c>message_output_text_logprobs</c>: Include logprobs with assistant messages.
    /// </para>
    /// <para>
    /// • <c>reasoning_encrypted_content</c>: Includes an encrypted version of reasoning tokens in reasoning item
    /// outputs. This enables reasoning items to be used in multi-turn conversations when using the Responses
    /// API statelessly (like when the store parameter is set to false, or when an organization is enrolled
    /// in the zero data retention program).
    /// </para>
    /// </remarks>
    function Include(const Value: TArray<TOutputIncluding>): TUrlConversationsItemParams; overload;

    /// <summary>
    /// Specify additional output data to include in the model response.
    /// </summary>
    /// <remarks>
    /// Currently supported values are:
    /// <para>
    /// • <c>web_search_call.action.sources</c>: Include the sources of the web search tool call.
    /// </para>
    /// <para>
    /// • <c>code_interpreter_call.outputs</c>: Includes the outputs of python code execution in code
    /// </para>
    /// <para>
    /// • <c>computer_call_output.output.image_url</c>: Include image urls from the computer call output.
    /// </para>
    /// <para>
    /// • <c>file_search_call.results</c>: Include the search results of the file search tool call.
    /// </para>
    /// <para>
    /// • <c>message.input_image.image_url</c>: Include image urls from the input message.
    /// </para>
    /// <para>
    /// • <c>message.output_text.logprobs</c>: Include logprobs with assistant messages.
    /// </para>
    /// <para>
    /// • <c>reasoning.encrypted_content</c>: Includes an encrypted version of reasoning tokens in reasoning item
    /// outputs. This enables reasoning items to be used in multi-turn conversations when using the Responses
    /// API statelessly (like when the store parameter is set to false, or when an organization is enrolled
    /// in the zero data retention program).
    /// </para>
    /// </remarks>
    function Include(const Value: TArray<string>): TUrlConversationsItemParams; overload;
  end;

  TConversationsItemParams = class(TJSONParam)
    /// <summary>
    /// The items to add to the conversation. You may add up to 20 items at a time.
    /// </summary>
    function Items(const Value: TArray<TInputListItem>): TConversationsItemParams;
  end;

  /// <summary>
  /// Represents a Conversation resource returned by the Conversations API.
  /// </summary>
  /// <remarks>
  /// <para>
  /// This class mirrors the server-side conversation object and is typically produced by
  /// route methods such as <c>TConversationsRoute.Create</c>, <c>TConversationsRoute.Retrieve</c>,
  /// <c>TConversationsRoute.Update</c>, and <c>TConversationsRoute.Delete</c>.
  /// </para>
  /// <para>
  /// It inherits <c>TJSONFingerprint</c>, which captures the raw JSON payload in
  /// <c>JSONResponse</c> for diagnostics, logging, or exact round-trip scenarios.
  /// </para>
  /// <para>
  /// <b>Metadata handling:</b> By default, the deserializer treats metadata as a JSON string
  /// (controlled by the global <c>MetadataAsObject</c> flag). The <c>TMetadataInterceptor</c>
  /// ensures correct conversion/round-tripping between the raw JSON and this string representation,
  /// allowing heterogeneous metadata schemas across different models.
  /// </para>
  /// </remarks>
  TConversations = class(TJSONFingerprint)
  private
    [JsonNameAttribute('created_at')]
    FCreatedAt : Int64;
    FId : string;
    FMetadata : string;
    FObject : string;
  public
    /// <summary>
    /// Unix timestamp (in seconds) when the conversation was created.
    /// </summary>
    /// <remarks>
    /// This is the server-reported creation time expressed as seconds since the Unix epoch
    /// (UTC, January 1, 1970). Use standard date/time utilities to convert to local time if needed.
    /// </remarks>
    property CreatedAt: Int64 read FCreatedAt write FCreatedAt;

    /// <summary>
    /// Unique identifier of the conversation (e.g., "conv_123").
    /// </summary>
    /// <remarks>
    /// The ID is stable for the lifetime of the resource and can be used to retrieve, update,
    /// list items, and delete the conversation via <c>TConversationsRoute</c>.
    /// </remarks>
    property Id: string read FId write FId;

    /// <summary>
    /// Metadata associated with the conversation, serialized as a JSON string.
    /// </summary>
    /// <remarks>
    /// <para>
    /// The API accepts up to 16 key-value pairs. Keys are limited to 64 characters; values may be
    /// strings (≤512 chars), booleans, or numbers. This property contains the raw JSON representation
    /// as handled by <c>TMetadataInterceptor</c>.
    /// </para>
    /// <para>
    /// If you need structured access, parse the string into a <c>TJSONObject</c>. When updating,
    /// supply a <c>TJSONObject</c> through the corresponding route method; the framework will serialize
    /// it back to this string form automatically.
    /// </para>
    /// </remarks>
    property Metadata: string read FMetadata write FMetadata;

    /// <summary>
    /// Discriminator indicating the resource kind; always "conversation".
    /// </summary>
    /// <remarks>
    /// Mirrors the <c>object</c> field from the API. Useful for sanity checks during deserialization.
    /// </remarks>
    property &Object: string read FObject write FObject;
  end;

  /// <summary>
  /// Asynchronous callback wrapper for operations that return a <c>TConversations</c> result.
  /// </summary>
  /// <remarks>
  /// <para>
  /// This type is an alias of <c>TAsynCallBack&lt;TConversations&gt;</c>. It exposes the framework’s
  /// event-driven async lifecycle for conversation-related requests, enabling non-blocking execution
  /// with dispatcher-safe notifications.
  /// </para>
  /// <para>
  /// Standard handlers include <c>OnStart</c> for kickoff, <c>OnSuccess</c> delivering the
  /// <c>TConversations</c> payload upon completion, and <c>OnError</c> for failure propagation.
  /// </para>
  /// <para>
  /// Use this alias with methods such as <c>TConversationsRoute.AsynCreate</c>,
  /// <c>TConversationsRoute.AsynRetrieve</c>, <c>TConversationsRoute.AsynUpdate</c>, and
  /// related routines to keep intent explicit and preserve strong typing of the callback payload.
  /// </para>
  /// <para>
  /// The resulting <c>TConversations</c> instance inherits <c>TJSONFingerprint</c>, making the raw API
  /// payload available via <c>JSONResponse</c>. Its <c>Metadata</c> field is serialized as a JSON string
  /// and round-tripped by <c>TMetadataInterceptor</c>.
  /// </para>
  /// </remarks>
  TAsynConversations = TAsynCallBack<TConversations>;

  /// <summary>
  /// Promise-style asynchronous wrapper for operations that return a <c>TConversations</c> result.
  /// </summary>
  /// <remarks>
  /// <para>
  /// This type is an alias of <c>TPromiseCallBack&lt;TConversations&gt;</c>. It provides a
  /// promise-oriented asynchronous flow for conversation-related operations, supporting
  /// structured chaining and composition of async tasks.
  /// </para>
  /// <para>
  /// Standard promise handlers include <c>OnStart</c> (triggered when the request begins),
  /// <c>OnSuccess</c> (resolve, invoked when the operation completes successfully with a
  /// <c>TConversations</c> result), and <c>OnError</c> (reject, invoked on failure).
  /// </para>
  /// <para>
  /// Use this alias with methods such as <c>TConversationsRoute.AsyncAwaitCreate</c>,
  /// <c>TConversationsRoute.AsyncAwaitRetrieve</c>, or <c>TConversationsRoute.AsyncAwaitUpdate</c>
  /// to handle conversation operations within a promise-based asynchronous pattern.
  /// </para>
  /// <para>
  /// The resulting <c>TConversations</c> instance inherits <c>TJSONFingerprint</c>, giving access
  /// to the raw API response via <c>JSONResponse</c>. Its <c>Metadata</c> property is stored as a JSON
  /// string and automatically managed by <c>TMetadataInterceptor</c> during deserialization.
  /// </para>
  /// </remarks>
  TPromiseConversations = TPromiseCallBack<TConversations>;

  /// <summary>
  /// Alias for the standard delete-response DTO returned by the Conversations API.
  /// </summary>
  /// <remarks>
  /// <para>
  /// This type represents the acknowledgment payload returned by the API when a
  /// conversation is deleted. It is an alias of <c>TResponseDelete</c>.
  /// </para>
  /// <para>
  /// The underlying structure usually contains three core fields:
  /// </para>
  /// <para>
  /// <c>Id</c> — The unique identifier of the deleted conversation (for example, "conv_123").
  /// </para>
  /// <para>
  /// <c>Object</c> — A discriminator indicating the returned object type, typically
  /// "conversation.deleted".
  /// </para>
  /// <para>
  /// <c>Deleted</c> — A boolean flag confirming whether the delete operation succeeded (<c>true</c>)
  /// or not.
  /// </para>
  /// <para>
  /// This alias improves readability and intent clarity when invoking
  /// <c>TConversationsRoute.Delete</c> and other methods related to conversation lifecycle management.
  /// </para>
  /// </remarks>
  TConversationsDeleted = TResponseDelete;

  /// <summary>
  /// Asynchronous callback wrapper for operations that return a <c>TConversationsDeleted</c> result.
  /// </summary>
  /// <remarks>
  /// <para>
  /// This type is an alias of <c>TAsynCallBack&lt;TConversationsDeleted&gt;</c>. It provides the
  /// event-driven asynchronous execution model used for handling the results of conversation
  /// deletion requests without blocking the main thread.
  /// </para>
  /// <para>
  /// The standard asynchronous lifecycle includes <c>OnStart</c> (triggered when the operation
  /// begins), <c>OnSuccess</c> (invoked upon successful completion with a
  /// <c>TConversationsDeleted</c> payload), and <c>OnError</c> (triggered in case of failure).
  /// </para>
  /// <para>
  /// This alias is typically used with <c>TConversationsRoute.AsynDelete</c> or similar methods to
  /// make the intent of asynchronous delete operations explicit and maintain strong typing for the
  /// callback payload.
  /// </para>
  /// <para>
  /// The resulting <c>TConversationsDeleted</c> instance is an alias of <c>TResponseDelete</c>,
  /// providing fields such as <c>Id</c> (the deleted conversation ID), <c>Object</c>
  /// (expected to be "conversation.deleted"), and <c>Deleted</c> (a boolean flag indicating
  /// whether the delete operation succeeded).
  /// </para>
  /// </remarks>
  TAsynConversationsDeleted = TAsynCallBack<TConversationsDeleted>;

  /// <summary>
  /// Promise-style asynchronous wrapper for operations that return a <c>TConversationsDeleted</c> result.
  /// </summary>
  /// <remarks>
  /// <para>
  /// This type is an alias of <c>TPromiseCallBack&lt;TConversationsDeleted&gt;</c>. It provides a
  /// promise-based asynchronous workflow for conversation deletion operations, enabling structured
  /// chaining, continuation, and error handling patterns.
  /// </para>
  /// <para>
  /// The standard promise lifecycle includes <c>OnStart</c> (triggered when the operation begins),
  /// <c>OnSuccess</c> (resolve, invoked when the deletion completes successfully with a
  /// <c>TConversationsDeleted</c> payload), and <c>OnError</c> (reject, invoked in case of failure).
  /// </para>
  /// <para>
  /// This alias is typically used with <c>TConversationsRoute.AsyncAwaitDelete</c> or similar
  /// asynchronous methods, providing a strongly typed result and consistent promise semantics.
  /// </para>
  /// <para>
  /// The resulting <c>TConversationsDeleted</c> instance is an alias of <c>TResponseDelete</c>,
  /// containing the fields <c>Id</c> (identifier of the deleted conversation), <c>Object</c>
  /// (object type, typically "conversation.deleted"), and <c>Deleted</c> (a boolean flag confirming
  /// whether the operation succeeded).
  /// </para>
  /// </remarks>
  TPromiseConversationsDeleted = TPromiseCallBack<TConversationsDeleted>;

  /// <summary>
  /// Alias for the list container of model responses associated with a conversation.
  /// </summary>
  /// <remarks>
  /// <para>
  /// This type is an alias of <c>TResponses</c>. It represents a paged collection of <c>TResponse</c> items
  /// returned by list and append operations scoped to a single conversation.
  /// </para>
  /// <para>
  /// Typical producers include <c>TConversationsRoute.List</c> for enumerating items within a conversation,
  /// and <c>TConversationsRoute.CreateItem</c> for appending new items and obtaining the resulting list view.
  /// </para>
  /// <para>
  /// The underlying payload usually includes list metadata such as the object kind, pagination markers, and an
  /// ordered array of response items. Each element of the collection is a <c>TResponse</c> carrying its own fields
  /// like identifiers, timestamps, model information, output content, usage, and optional error details.
  /// </para>
  /// <para>
  /// Use this alias to make intent explicit when working with conversation-scoped listings, while retaining
  /// all functionality and utilities provided by <c>TResponses</c>.
  /// </para>
  /// </remarks>
  TConversationList = TResponses;

  /// <summary>
  /// Asynchronous callback wrapper for operations that return a <c>TConversationList</c> result.
  /// </summary>
  /// <remarks>
  /// <para>
  /// This type is an alias of <c>TAsynCallBack&lt;TConversationList&gt;</c>. It provides the framework’s
  /// event-driven asynchronous lifecycle for conversation-scoped listing and append operations, enabling
  /// non-blocking execution with dispatcher-safe notifications.
  /// </para>
  /// <para>
  /// Standard handlers include <c>OnStart</c> when the request begins, <c>OnSuccess</c> delivering the
  /// <c>TConversationList</c> payload upon completion, and <c>OnError</c> for failure propagation.
  /// </para>
  /// <para>
  /// Use this alias with methods such as <c>TConversationsRoute.AsynList</c> and
  /// <c>TConversationsRoute.AsynCreateItem</c> to keep intent explicit and preserve strong typing of the
  /// callback payload.
  /// </para>
  /// <para>
  /// The resulting <c>TConversationList</c> is an alias of <c>TResponses</c>, containing <c>TResponse</c>
  /// items. Each <c>TResponse</c> inherits <c>TJSONFingerprint</c> and exposes the raw API payload via
  /// <c>JSONResponse</c>.
  /// </para>
  /// </remarks>
  TAsynConversationList = TAsynCallBack<TConversationList>;

  /// <summary>
  /// Promise-style asynchronous wrapper for operations that return a <c>TConversationList</c> result.
  /// </summary>
  /// <remarks>
  /// <para>
  /// This type is an alias of <c>TPromiseCallBack&lt;TConversationList&gt;</c>. It provides a
  /// promise-based asynchronous workflow for conversation-scoped listing and append operations,
  /// enabling structured chaining, continuation, and error-handling patterns.
  /// </para>
  /// <para>
  /// The standard promise lifecycle includes <c>OnStart</c> (triggered when the operation begins),
  /// <c>OnSuccess</c> (resolve, invoked when the operation completes successfully with a
  /// <c>TConversationList</c> payload), and <c>OnError</c> (reject, invoked in case of failure).
  /// </para>
  /// <para>
  /// Use this alias with asynchronous methods such as <c>TConversationsRoute.AsyncAwaitList</c> or
  /// <c>TConversationsRoute.AsyncAwaitCreateItem</c> to handle conversation item enumeration and
  /// creation within a promise-based asynchronous pattern.
  /// </para>
  /// <para>
  /// The resulting <c>TConversationList</c> is an alias of <c>TResponses</c>, which holds a collection
  /// of <c>TResponse</c> instances representing the individual model responses or conversation items.
  /// Each <c>TResponse</c> inherits <c>TJSONFingerprint</c> and exposes the raw API payload through
  /// <c>JSONResponse</c>.
  /// </para>
  /// </remarks>
  TPromiseConversationList = TPromiseCallBack<TConversationList>;

  /// <summary>
  /// Alias for the conversation item resource returned by the Conversations API.
  /// </summary>
  /// <remarks>
  /// <para>
  /// This type is an alias of <c>TResponseItem</c>. It represents a single item
  /// (message, tool call, or structured event) within a conversation, as returned
  /// by endpoints such as <c>TConversationsRoute.RetrieveItem</c> or
  /// <c>TConversationsRoute.CreateItem</c>.
  /// </para>
  /// <para>
  /// A <c>TConversationsItem</c> can represent multiple categories of data —
  /// input messages, model-generated outputs, code-interpreter executions,
  /// file search calls, function or computer tool invocations, and more.
  /// </para>
  /// <para>
  /// Each item inherits from <c>TJSONFingerprint</c> and retains its raw JSON
  /// payload in <c>JSONResponse</c>. The full hierarchy includes specialized
  /// descendants such as:
  /// </para>
  /// <para>
  /// • <c>TResponseItemInputMessage</c> — user, system, or developer messages
  /// • <c>TResponseItemOutputMessage</c> — assistant responses
  /// • <c>TResponseItemFunctionToolCall</c>, <c>TResponseItemComputerToolCall</c>,
  ///   <c>TResponseItemFileSearchToolCall</c> — model tool call representations
  /// • <c>TResponseItemCodeInterpreter</c> — code execution and outputs
  /// • <c>TResponseItemImageGeneration</c> — generated images (base64-encoded)
  /// • <c>TResponseItemMCPTool</c>, <c>TResponseItemMCPList</c>,
  ///   <c>TResponseItemMCPApprovalRequest</c> — MCP integration objects
  /// </para>
  /// <para>
  /// The design ensures complete compatibility with automatic deserialization
  /// of conversation items while maintaining a strict, type-safe class structure
  /// for each possible item category.
  /// </para>
  /// <para>
  /// Use this alias for clarity when dealing with individual conversation entries,
  /// while leveraging all properties and nested types of <c>TResponseItem</c>.
  /// </para>
  /// </remarks>
  TConversationsItem = TResponseItem;

  /// <summary>
  /// Asynchronous callback wrapper for operations that return a <c>TConversationsItem</c> result.
  /// </summary>
  /// <remarks>
  /// <para>
  /// This type is an alias of <c>TAsynCallBack&lt;TConversationsItem&gt;</c>. It provides the framework’s
  /// event-driven asynchronous lifecycle for conversation item operations, enabling non-blocking execution
  /// with dispatcher-safe notifications.
  /// </para>
  /// <para>
  /// Standard handlers include <c>OnStart</c> when the request begins, <c>OnSuccess</c> delivering the
  /// <c>TConversationsItem</c> payload upon completion, and <c>OnError</c> for failure propagation.
  /// </para>
  /// <para>
  /// Use this alias with methods such as <c>TConversationsRoute.AsynRetrieveItem</c> and
  /// <c>TConversationsRoute.AsynCreateItem</c> to keep intent explicit and preserve strong typing
  /// of the callback payload.
  /// </para>
  /// <para>
  /// The resulting <c>TConversationsItem</c> is an alias of <c>TResponseItem</c> and inherits
  /// <c>TJSONFingerprint</c>, exposing the raw API payload via <c>JSONResponse</c>.
  /// </para>
  /// </remarks>
  TAsynConversationsItem = TAsynCallBack<TConversationsItem>;

  /// <summary>
  /// Promise-style asynchronous wrapper for operations that return a <c>TConversationsItem</c> result.
  /// </summary>
  /// <remarks>
  /// <para>
  /// This type is an alias of <c>TPromiseCallBack&lt;TConversationsItem&gt;</c>. It provides a
  /// promise-based asynchronous workflow for conversation item operations, supporting structured
  /// chaining, continuation, and error-handling patterns.
  /// </para>
  /// <para>
  /// The standard promise lifecycle includes <c>OnStart</c> (triggered when the request begins),
  /// <c>OnSuccess</c> (resolve, invoked when the operation completes successfully with a
  /// <c>TConversationsItem</c> payload), and <c>OnError</c> (reject, invoked in case of failure).
  /// </para>
  /// <para>
  /// Use this alias with asynchronous methods such as <c>TConversationsRoute.AsyncAwaitRetrieveItem</c>
  /// or <c>TConversationsRoute.AsyncAwaitCreateItem</c> to handle conversation item retrieval and creation
  /// within a promise-based asynchronous pattern.
  /// </para>
  /// <para>
  /// The resulting <c>TConversationsItem</c> is an alias of <c>TResponseItem</c>, which represents
  /// a single message, tool call, or structured event within a conversation. It inherits
  /// <c>TJSONFingerprint</c>, exposing the raw API payload through the <c>JSONResponse</c> property.
  /// </para>
  /// </remarks>
  TPromiseConversationsItem = TPromiseCallBack<TConversationsItem>;

  TConversationsAbstractSupport = class(TGenAIRoute)
  protected
    function Create(const ParamProc: TProc<TConversationsParams>): TConversations; virtual; abstract;
    function Delete(const ConversationId: string): TConversationsDeleted; virtual; abstract;
    function Retrieve(const ConversationId: string): TConversations; virtual; abstract;
    function Update(const ConversationId: string; const ParamProc: TProc<TUpdateConversationsParams>): TConversations; virtual; abstract;
    function List(const ConversationId: string; const ParamProc: TProc<TUrlListItemsParams>): TConversationList; virtual; abstract;
    function CreateItem(const ConversationId: string;
      const ParamProc: TProc<TConversationsItemParams>): TConversationList; overload; virtual; abstract;
    function CreateItem(const ConversationId: string;
      const Include: TArray<TOutputIncluding>;
      const ParamProc: TProc<TConversationsItemParams>): TConversationList; overload; virtual; abstract;
    function RetrieveItem(const ConversationId: string;
      const MessageId: string): TConversationsItem; overload; virtual; abstract;
    function RetrieveItem(const ConversationId: string;
      const MessageId: string;
      const UrlParamProc: TProc<TUrlConversationsItemParams>): TConversationsItem; overload; virtual; abstract;
    function DeleteItem(const ConversationId: string;
      const MessageId: string): TConversations; overload; virtual; abstract;
  end;

  TConversationsAsynchronousSupport = class(TConversationsAbstractSupport)
  public
    procedure AsynCreate(const ParamProc: TProc<TConversationsParams>;
      const CallBacks: TFunc<TAsynConversations>);
    procedure AsynDelete(const ConversationId: string;
      const CallBacks: TFunc<TAsynConversationsDeleted>);
    procedure AsynRetrieve(const ConversationId: string;
      const CallBacks: TFunc<TAsynConversations>);
    procedure AsynUpdate(const ConversationId: string;
      const ParamProc: TProc<TUpdateConversationsParams>;
      const CallBacks: TFunc<TAsynConversations>);
    procedure AsynList(const ConversationId: string;
      const ParamProc: TProc<TUrlListItemsParams>;
      const CallBacks: TFunc<TAsynConversationList>);
    procedure AsynCreateItem(const ConversationId: string;
      const ParamProc: TProc<TConversationsItemParams>;
      const CallBacks: TFunc<TAsynConversationList>); overload;
    procedure AsynCreateItem(const ConversationId: string;
      const Include: TArray<TOutputIncluding>;
      const ParamProc: TProc<TConversationsItemParams>;
      const CallBacks: TFunc<TAsynConversationList>); overload;
    procedure AsynRetrieveItem(const ConversationId: string;
      const MessageId: string;
      const CallBacks: TFunc<TAsynConversationsItem>); overload;
    procedure AsynRetrieveItem(const ConversationId: string;
      const MessageId: string;
      const UrlParamProc: TProc<TUrlConversationsItemParams>;
      const CallBacks: TFunc<TAsynConversationsItem>); overload;
    procedure AsynDeleteItem(const ConversationId: string;
      const MessageId: string;
      const CallBacks: TFunc<TAsynConversations>);
  end;

  /// <summary>
  /// Provides the full routing interface for all operations related to Conversations and their items.
  /// </summary>
  /// <remarks>
  /// <para>
  /// <c>TConversationsRoute</c> defines the primary access layer for managing conversation resources
  /// through the OpenAI Conversations API. It inherits from <c>TGenAIRoute</c> and exposes both
  /// synchronous and asynchronous methods for conversation lifecycle management.
  /// </para>
  /// <para>
  /// Core operations include:
  /// </para>
  /// <para>
  /// • <c>Create</c>, <c>Retrieve</c>, <c>Update</c>, and <c>Delete</c> — manage conversation objects
  /// • <c>List</c> — enumerate conversation items
  /// • <c>CreateItem</c>, <c>RetrieveItem</c>, and <c>DeleteItem</c> — manipulate messages or tool calls within a conversation
  /// • <c>AsyncAwait*</c> and <c>Asyn*</c> variants — provide non-blocking and promise-based asynchronous APIs
  /// </para>
  /// <para>
  /// Each method internally delegates to the REST layer encapsulated by <c>TGenAIAPI</c>, handling
  /// parameter serialization, request dispatch, and automatic deserialization of the response into
  /// strongly typed DTOs such as <c>TConversations</c>, <c>TConversationsDeleted</c>,
  /// <c>TConversationList</c>, and <c>TConversationsItem</c>.
  /// </para>
  /// <para>
  /// The route supports composable parameter builders (<c>TConversationsParams</c>,
  /// <c>TUpdateConversationsParams</c>, <c>TUrlListItemsParams</c>, etc.) to simplify construction
  /// of complex API requests while ensuring type safety and readability.
  /// </para>
  /// <para>
  /// Asynchronous methods are designed to integrate seamlessly with the framework’s task scheduler and
  /// callback system (<c>TAsynCallBack&lt;T&gt;</c> / <c>TPromiseCallBack&lt;T&gt;</c>), providing both
  /// event-driven and promise-based programming styles.
  /// </para>
  /// <para>
  /// Typical usage scenarios include:
  /// </para>
  /// <para>
  /// • Creating or resuming multi-turn conversations
  /// • Appending model-generated items (e.g., assistant messages, tool calls, outputs)
  /// • Querying or retrieving specific conversation items
  /// • Performing batch deletions or metadata updates
  /// • Integrating async workflows for background or UI-safe operations
  /// </para>
  /// <para>
  /// The class acts as a cohesive API endpoint layer, abstracting low-level REST interactions
  /// while preserving transparency of all request parameters and response structures.
  /// </para>
  /// </remarks>
  TConversationsRoute = class(TConversationsAsynchronousSupport)
  private
    function CreateItem(const ConversationId: string;
      const UrlParamProc: TProc<TUrlConversationsItemParams>;
      const ParamProc: TProc<TConversationsItemParams>): TConversationList; overload;
  public
    /// <summary>
    /// Asynchronously creates a new conversation and returns a <c>TPromise&lt;TConversations&gt;</c> handle.
    /// </summary>
    /// <param name="ParamProc">
    /// A configuration procedure used to build the JSON payload through <c>TConversationsParams</c>.
    /// Use it to define initial items, metadata, or any other properties to include in the new conversation.
    /// </param>
    /// <param name="CallBacks">
    /// (Optional) A callback factory returning a <c>TPromiseConversations</c> instance, allowing the attachment
    /// of asynchronous lifecycle handlers such as <c>OnStart</c>, <c>OnSuccess</c>, and <c>OnError</c>.
    /// </param>
    /// <returns>
    /// A <c>TPromise&lt;TConversations&gt;</c> object that resolves asynchronously with the created
    /// <c>TConversations</c> instance.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This method performs a non-blocking POST request to the <c>/conversations</c> endpoint of the API.
    /// Upon completion, the resulting <c>TConversations</c> object contains fields such as <c>Id</c>,
    /// <c>CreatedAt</c>, <c>Metadata</c>, and <c>Object</c>.
    /// </para>
    /// <para>
    /// • The asynchronous execution model ensures that conversation creation occurs in the background,
    /// preventing the main thread from blocking. The returned promise can be awaited, chained, or resolved
    /// through the provided callbacks, offering a flexible integration model for UI and background workflows.
    /// </para>
    /// <para>
    /// • Internally, this method delegates to <c>TConversationsRoute.AsynCreate</c> and wraps the callback-based
    /// execution into a promise abstraction using <c>TAsyncAwaitHelper.WrapAsyncAwait</c>.
    /// </para>
    /// </remarks>
    function AsyncAwaitCreate(const ParamProc: TProc<TConversationsParams>;
      const CallBacks: TFunc<TPromiseConversations> = nil): TPromise<TConversations>;

    /// <summary>
    /// Asynchronously deletes an existing conversation and returns a <c>TPromise&lt;TConversationsDeleted&gt;</c> handle.
    /// </summary>
    /// <param name="ConversationId">
    /// The unique identifier of the conversation to delete.
    /// This corresponds to the <c>Id</c> field of the <c>TConversations</c> object (for example, “conv_123”).
    /// </param>
    /// <param name="CallBacks">
    /// (Optional) A callback factory returning a <c>TPromiseConversationsDeleted</c> instance,
    /// allowing the attachment of asynchronous lifecycle handlers such as <c>OnStart</c>,
    /// <c>OnSuccess</c>, and <c>OnError</c>.
    /// </param>
    /// <returns>
    /// A <c>TPromise&lt;TConversationsDeleted&gt;</c> object that resolves asynchronously with
    /// the deletion acknowledgment payload.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This method performs a non-blocking DELETE request to the <c>/conversations/{id}</c> endpoint of the API,
    /// removing the specified conversation resource.
    /// </para>
    /// <para>
    /// • Upon successful completion, the resolved <c>TConversationsDeleted</c> instance (an alias of
    /// <c>TResponseDelete</c>) contains confirmation fields such as <c>Id</c>, <c>Object</c>,
    /// and <c>Deleted</c>, indicating the outcome of the deletion.
    /// </para>
    /// <para>
    /// • The asynchronous execution model ensures that the delete operation is executed in the background
    /// without blocking the main thread. The returned promise can be awaited, chained, or resolved
    /// through the provided callback handlers.
    /// </para>
    /// <para>
    /// • Internally, this method delegates to <c>TConversationsRoute.AsynDelete</c> and wraps the
    /// callback-based execution into a promise abstraction using <c>TAsyncAwaitHelper.WrapAsyncAwait</c>.
    /// </para>
    /// </remarks>
    function AsyncAwaitDelete(const ConversationId: string;
      const CallBacks: TFunc<TPromiseConversationsDeleted> = nil): TPromise<TConversationsDeleted>;

    /// <summary>
    /// Asynchronously retrieves an existing conversation and returns a <c>TPromise&lt;TConversations&gt;</c> handle.
    /// </summary>
    /// <param name="ConversationId">
    /// The unique identifier of the conversation to retrieve.
    /// This corresponds to the <c>Id</c> field of the <c>TConversations</c> object (for example, “conv_123”).
    /// </param>
    /// <param name="CallBacks">
    /// (Optional) A callback factory returning a <c>TPromiseConversations</c> instance,
    /// allowing the attachment of asynchronous lifecycle handlers such as <c>OnStart</c>,
    /// <c>OnSuccess</c>, and <c>OnError</c>.
    /// </param>
    /// <returns>
    /// A <c>TPromise&lt;TConversations&gt;</c> object that resolves asynchronously with the retrieved
    /// <c>TConversations</c> instance.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This method performs a non-blocking GET request to the <c>/conversations/{id}</c> endpoint of the API,
    /// retrieving the details of the specified conversation.
    /// </para>
    /// <para>
    /// • Upon successful completion, the resulting <c>TConversations</c> object contains fields such as
    /// <c>Id</c>, <c>CreatedAt</c>, <c>Metadata</c>, and <c>Object</c>, reflecting the server-side
    /// state of the conversation.
    /// </para>
    /// <para>
    /// • The asynchronous execution model ensures that the retrieval process runs in the background
    /// without blocking the main thread. The returned promise can be awaited, chained, or handled
    /// through the provided callback structure for fine-grained control over the async lifecycle.
    /// </para>
    /// <para>
    /// • Internally, this method delegates to <c>TConversationsRoute.AsynRetrieve</c> and wraps the
    /// callback-based operation into a promise abstraction using <c>TAsyncAwaitHelper.WrapAsyncAwait</c>.
    /// </para>
    /// </remarks>
    function AsyncAwaitRetrieve(const ConversationId: string;
      const CallBacks: TFunc<TPromiseConversations> = nil): TPromise<TConversations>;

    /// <summary>
    /// Asynchronously updates an existing conversation and returns a <c>TPromise&lt;TConversations&gt;</c> handle.
    /// </summary>
    /// <param name="ConversationId">
    /// The unique identifier of the conversation to update.
    /// This corresponds to the <c>Id</c> field of the <c>TConversations</c> object (for example, “conv_123”).
    /// </param>
    /// <param name="ParamProc">
    /// A configuration procedure used to build the JSON payload through <c>TUpdateConversationsParams</c>.
    /// Use it to define or modify metadata fields or any other mutable properties supported by the API.
    /// </param>
    /// <param name="CallBacks">
    /// (Optional) A callback factory returning a <c>TPromiseConversations</c> instance,
    /// allowing the attachment of asynchronous lifecycle handlers such as <c>OnStart</c>,
    /// <c>OnSuccess</c>, and <c>OnError</c>.
    /// </param>
    /// <returns>
    /// A <c>TPromise&lt;TConversations&gt;</c> object that resolves asynchronously with the updated
    /// <c>TConversations</c> instance.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This method performs a non-blocking POST request to the <c>/conversations/{id}</c> endpoint of the API,
    /// updating the specified conversation with new metadata or other supported parameters.
    /// </para>
    /// <para>
    /// • Upon successful completion, the resolved <c>TConversations</c> object reflects the updated state
    /// of the conversation, including fields such as <c>Id</c>, <c>CreatedAt</c>, <c>Metadata</c>,
    /// and <c>Object</c>.
    /// </para>
    /// <para>
    /// • The asynchronous execution model ensures that the update operation executes in the background,
    /// preventing UI or thread blocking. The returned promise can be awaited, chained, or controlled
    /// through the optional callback handlers for more granular lifecycle management.
    /// </para>
    /// <para>
    /// • Internally, this method delegates to <c>TConversationsRoute.AsynUpdate</c> and wraps the
    /// callback-based logic into a promise abstraction via <c>TAsyncAwaitHelper.WrapAsyncAwait</c>.
    /// </para>
    /// </remarks>
    function AsyncAwaitUpdate(const ConversationId: string;
      const ParamProc: TProc<TUpdateConversationsParams>;
      const CallBacks: TFunc<TPromiseConversations> = nil): TPromise<TConversations>;

    /// <summary>
    /// Asynchronously retrieves the list of items belonging to a given conversation and returns a <c>TPromise&lt;TConversationList&gt;</c> handle.
    /// </summary>
    /// <param name="ConversationId">
    /// The unique identifier of the conversation whose items are to be listed.
    /// This corresponds to the <c>Id</c> field of the <c>TConversations</c> object (for example, “conv_123”).
    /// </param>
    /// <param name="ParamProc">
    /// A configuration procedure used to build the URL parameters via <c>TUrlListItemsParams</c>.
    /// Use it to specify pagination (<c>After</c>), result limits (<c>Limit</c>), sort order (<c>Order</c>),
    /// or additional inclusion fields (<c>Include</c>) for fine-grained query control.
    /// </param>
    /// <param name="CallBacks">
    /// (Optional) A callback factory returning a <c>TPromiseConversationList</c> instance,
    /// allowing the attachment of asynchronous lifecycle handlers such as <c>OnStart</c>,
    /// <c>OnSuccess</c>, and <c>OnError</c>.
    /// </param>
    /// <returns>
    /// A <c>TPromise&lt;TConversationList&gt;</c> object that resolves asynchronously with the retrieved
    /// <c>TConversationList</c> result.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This method performs a non-blocking GET request to the <c>/conversations/{id}/items</c> endpoint of the API,
    /// returning a paginated collection of conversation items such as messages, tool calls, or generated outputs.
    /// </para>
    /// <para>
    /// • Upon successful completion, the resulting <c>TConversationList</c> (alias of <c>TResponses</c>)
    /// contains an ordered array of <c>TResponse</c> elements, each representing an individual conversation entry.
    /// </para>
    /// <para>
    /// • The asynchronous execution model ensures that item retrieval occurs in the background without blocking
    /// the main thread. The returned promise can be awaited, chained, or resolved via the provided callback handlers.
    /// </para>
    /// <para>
    /// • Internally, this method delegates to <c>TConversationsRoute.AsynList</c> and wraps the
    /// callback-based logic into a promise abstraction through <c>TAsyncAwaitHelper.WrapAsyncAwait</c>.
    /// </para>
    /// </remarks>
    function AsyncAwaitList(const ConversationId: string;
      const ParamProc: TProc<TUrlListItemsParams>;
      const CallBacks: TFunc<TPromiseConversationList> = nil): TPromise<TConversationList>;

    /// <summary>
    /// Asynchronously creates a new item within a conversation and returns a <c>TPromise&lt;TConversationList&gt;</c> handle.
    /// </summary>
    /// <param name="ConversationId">
    /// The unique identifier of the target conversation in which the new item will be created.
    /// This corresponds to the <c>Id</c> field of the <c>TConversations</c> object (for example, “conv_123”).
    /// </param>
    /// <param name="ParamProc">
    /// A configuration procedure used to build the JSON payload via <c>TConversationsItemParams</c>.
    /// Use it to specify one or more items (<c>Items</c>) to append to the conversation context.
    /// </param>
    /// <param name="CallBacks">
    /// (Optional) A callback factory returning a <c>TPromiseConversationList</c> instance, allowing
    /// the attachment of asynchronous lifecycle handlers such as <c>OnStart</c>, <c>OnSuccess</c>,
    /// and <c>OnError</c>.
    /// </param>
    /// <returns>
    /// A <c>TPromise&lt;TConversationList&gt;</c> object that resolves asynchronously with the
    /// updated <c>TConversationList</c> result.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This method performs a non-blocking POST request to the <c>/conversations/{id}/items</c> endpoint of the API,
    /// appending one or several items (messages, tool calls, or inputs) to an existing conversation.
    /// </para>
    /// <para>
    /// • Upon successful completion, the resulting <c>TConversationList</c> (alias of <c>TResponses</c>)
    /// contains the updated list of conversation entries, including the newly added items.
    /// </para>
    /// <para>
    /// • The asynchronous execution model ensures that the operation runs in the background
    /// without blocking the main thread. The returned promise can be awaited, chained, or managed
    /// via the provided callback structure for fine-grained lifecycle control.
    /// </para>
    /// <para>
    /// • Internally, this method delegates to <c>TConversationsRoute.AsynCreateItem</c> and wraps the
    /// callback-based execution into a promise abstraction through <c>TAsyncAwaitHelper.WrapAsyncAwait</c>.
    /// </para>
    /// </remarks>
    function AsyncAwaitCreateItem(const ConversationId: string;
      const ParamProc: TProc<TConversationsItemParams>;
      const CallBacks: TFunc<TPromiseConversationList> = nil): TPromise<TConversationList>; overload;

    /// <summary>
    /// Asynchronously creates a new item within a conversation, including specific output fields in the response,
    /// and returns a <c>TPromise&lt;TConversationList&gt;</c> handle.
    /// </summary>
    /// <param name="ConversationId">
    /// The unique identifier of the target conversation in which the new item will be created.
    /// This corresponds to the <c>Id</c> field of the <c>TConversations</c> object (for example, “conv_123”).
    /// </param>
    /// <param name="Include">
    /// An array of <c>TOutputIncluding</c> values specifying which output fields to include in the API response.
    /// Use this parameter to control the level of detail returned for the newly created item(s).
    /// </param>
    /// <param name="ParamProc">
    /// A configuration procedure used to build the JSON payload through <c>TConversationsItemParams</c>.
    /// Use it to define one or several items (<c>Items</c>) to append to the conversation.
    /// </param>
    /// <param name="CallBacks">
    /// (Optional) A callback factory returning a <c>TPromiseConversationList</c> instance, allowing
    /// the attachment of asynchronous lifecycle handlers such as <c>OnStart</c>, <c>OnSuccess</c>,
    /// and <c>OnError</c>.
    /// </param>
    /// <returns>
    /// A <c>TPromise&lt;TConversationList&gt;</c> object that resolves asynchronously with the
    /// updated <c>TConversationList</c> result.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This method performs a non-blocking POST request to the <c>/conversations/{id}/items</c> endpoint of the API,
    /// appending one or several items (messages, tool calls, or inputs) to an existing conversation, while optionally
    /// requesting extended output fields specified by the <c>Include</c> array.
    /// </para>
    /// <para>
    /// • Upon successful completion, the resulting <c>TConversationList</c> (alias of <c>TResponses</c>)
    /// contains the updated set of conversation entries, including the newly created item(s) and any
    /// requested additional fields.
    /// </para>
    /// <para>
    /// • The asynchronous execution model ensures that the operation executes in the background without blocking
    /// the main thread. The returned promise can be awaited, chained, or resolved through the provided callbacks
    /// for fine-grained control of the async workflow.
    /// </para>
    /// <para>
    /// • Internally, this method delegates to <c>TConversationsRoute.AsynCreateItem</c> and wraps the
    /// callback-based logic into a promise abstraction using <c>TAsyncAwaitHelper.WrapAsyncAwait</c>.
    /// </para>
    /// </remarks>
    function AsyncAwaitCreateItem(const ConversationId: string;
      const Include: TArray<TOutputIncluding>;
      const ParamProc: TProc<TConversationsItemParams>;
      const CallBacks: TFunc<TPromiseConversationList> = nil): TPromise<TConversationList>; overload;

    /// <summary>
    /// Asynchronously retrieves a specific item within a conversation and returns a <c>TPromise&lt;TConversationsItem&gt;</c> handle.
    /// </summary>
    /// <param name="ConversationId">
    /// The unique identifier of the conversation containing the target item.
    /// This corresponds to the <c>Id</c> field of the <c>TConversations</c> object (for example, “conv_123”).
    /// </param>
    /// <param name="MessageId">
    /// The unique identifier of the conversation item to retrieve.
    /// This corresponds to the <c>Id</c> field of the <c>TConversationsItem</c> object (for example, “msg_456”).
    /// </param>
    /// <param name="CallBacks">
    /// (Optional) A callback factory returning a <c>TPromiseConversationsItem</c> instance, allowing
    /// the attachment of asynchronous lifecycle handlers such as <c>OnStart</c>, <c>OnSuccess</c>,
    /// and <c>OnError</c>.
    /// </param>
    /// <returns>
    /// A <c>TPromise&lt;TConversationsItem&gt;</c> object that resolves asynchronously with the retrieved
    /// <c>TConversationsItem</c> instance.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This method performs a non-blocking GET request to the <c>/conversations/{conversation_id}/items/{item_id}</c>
    /// endpoint of the API, retrieving detailed information about a specific message or tool call within a conversation.
    /// </para>
    /// <para>
    /// • Upon successful completion, the resulting <c>TConversationsItem</c> (alias of <c>TResponseItem</c>)
    /// contains fields describing the item type, content, tool-related data, and any additional contextual metadata.
    /// </para>
    /// <para>
    /// • The asynchronous execution model ensures that the retrieval process occurs in the background without
    /// blocking the main thread. The returned promise can be awaited, chained, or resolved through the provided
    /// callback handlers for finer lifecycle control.
    /// </para>
    /// <para>
    /// • Internally, this method delegates to <c>TConversationsRoute.AsynRetrieveItem</c> and wraps the
    /// callback-based execution into a promise abstraction via <c>TAsyncAwaitHelper.WrapAsyncAwait</c>.
    /// </para>
    /// </remarks>
    function AsyncAwaitRetrieveItem(const ConversationId: string;
      const MessageId: string;
      const CallBacks: TFunc<TPromiseConversationsItem> = nil): TPromise<TConversationsItem>; overload;

    /// <summary>
    /// Asynchronously retrieves a specific item within a conversation, using additional URL parameters,
    /// and returns a <c>TPromise&lt;TConversationsItem&gt;</c> handle.
    /// </summary>
    /// <param name="ConversationId">
    /// The unique identifier of the conversation containing the target item.
    /// This corresponds to the <c>Id</c> field of the <c>TConversations</c> object (for example, “conv_123”).
    /// </param>
    /// <param name="MessageId">
    /// The unique identifier of the conversation item to retrieve.
    /// This corresponds to the <c>Id</c> field of the <c>TConversationsItem</c> object (for example, “msg_456”).
    /// </param>
    /// <param name="UrlParamProc">
    /// A configuration procedure used to define query parameters via <c>TUrlConversationsItemParams</c>.
    /// Use it to specify additional retrieval options such as included fields, expansions, or contextual filters.
    /// </param>
    /// <param name="CallBacks">
    /// (Optional) A callback factory returning a <c>TPromiseConversationsItem</c> instance, allowing
    /// the attachment of asynchronous lifecycle handlers such as <c>OnStart</c>, <c>OnSuccess</c>,
    /// and <c>OnError</c>.
    /// </param>
    /// <returns>
    /// A <c>TPromise&lt;TConversationsItem&gt;</c> object that resolves asynchronously with the retrieved
    /// <c>TConversationsItem</c> instance.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This method performs a non-blocking GET request to the <c>/conversations/{conversation_id}/items/{item_id}</c>
    /// endpoint of the API, applying optional URL parameters for refined data retrieval.
    /// The parameters built in <c>TUrlConversationsItemParams</c> allow for customization of the returned payload.
    /// </para>
    /// <para>
    /// • Upon successful completion, the resulting <c>TConversationsItem</c> (alias of <c>TResponseItem</c>)
    /// contains the complete structured representation of the requested conversation item, including
    /// its type, content, metadata, and tool-related information when applicable.
    /// </para>
    /// <para>
    /// • The asynchronous execution model ensures that the retrieval runs in the background without blocking
    /// the main thread. The returned promise can be awaited, chained, or managed through the optional
    /// callback handlers for lifecycle control.
    /// </para>
    /// <para>
    /// • Internally, this method delegates to <c>TConversationsRoute.AsynRetrieveItem</c> and wraps the
    /// callback-based logic into a promise abstraction using <c>TAsyncAwaitHelper.WrapAsyncAwait</c>.
    /// </para>
    /// </remarks>
    function AsyncAwaitRetrieveItem(const ConversationId: string;
      const MessageId: string;
      const UrlParamProc: TProc<TUrlConversationsItemParams>;
      const CallBacks: TFunc<TPromiseConversationsItem> = nil): TPromise<TConversationsItem>; overload;

    /// <summary>
    /// Asynchronously deletes a specific item from a conversation and returns a <c>TPromise&lt;TConversations&gt;</c> handle.
    /// </summary>
    /// <param name="ConversationId">
    /// The unique identifier of the conversation that contains the item to delete.
    /// This corresponds to the <c>Id</c> field of the <c>TConversations</c> object (for example, “conv_123”).
    /// </param>
    /// <param name="MessageId">
    /// The unique identifier of the conversation item to delete.
    /// This corresponds to the <c>Id</c> field of the <c>TConversationsItem</c> object (for example, “msg_456”).
    /// </param>
    /// <param name="CallBacks">
    /// (Optional) A callback factory returning a <c>TPromiseConversations</c> instance, allowing
    /// the attachment of asynchronous lifecycle handlers such as <c>OnStart</c>, <c>OnSuccess</c>,
    /// and <c>OnError</c>.
    /// </param>
    /// <returns>
    /// A <c>TPromise&lt;TConversations&gt;</c> object that resolves asynchronously with the updated
    /// <c>TConversations</c> instance after deletion.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This method performs a non-blocking DELETE request to the
    /// <c>/conversations/{conversation_id}/items/{item_id}</c> endpoint of the API, removing the
    /// specified item (message or tool call) from an existing conversation.
    /// </para>
    /// <para>
    /// • Upon successful completion, the resulting <c>TConversations</c> object reflects the updated
    /// state of the conversation after the item has been deleted.
    /// The response includes metadata such as <c>Id</c>, <c>CreatedAt</c>, and <c>Metadata</c>.
    /// </para>
    /// <para>
    /// • The asynchronous execution model ensures that the delete operation runs in the background
    /// without blocking the main thread. The returned promise can be awaited, chained, or resolved
    /// through the provided callback structure for granular lifecycle control.
    /// </para>
    /// <para>
    /// • Internally, this method delegates to <c>TConversationsRoute.AsynDeleteItem</c> and wraps the
    /// callback-based logic into a promise abstraction via <c>TAsyncAwaitHelper.WrapAsyncAwait</c>.
    /// </para>
    /// </remarks>
    function AsyncAwaitDeleteItem(const ConversationId: string;
      const MessageId: string;
      const CallBacks: TFunc<TPromiseConversations> = nil): TPromise<TConversations>;

    /// <summary>
    /// Creates a new conversation synchronously and returns a <c>TConversations</c> instance.
    /// </summary>
    /// <param name="ParamProc">
    /// A configuration procedure used to initialize the request body via a <c>TConversationsParams</c> instance.
    /// Use this callback to define initial conversation parameters such as input items or metadata.
    /// </param>
    /// <returns>
    /// A fully populated <c>TConversations</c> object representing the newly created conversation resource.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This method performs a synchronous POST request to the <c>/conversations</c> endpoint of the API,
    /// creating a new conversation and returning its corresponding data structure.
    /// </para>
    /// <para>
    /// • The request parameters are defined through the <c>ParamProc</c> procedure, which configures a
    /// <c>TConversationsParams</c> object. You can specify fields such as:
    /// </para>
    /// <para>
    /// • <c>Items</c> — An array of initial input messages or context items (up to 20).
    /// <c>Metadata</c> — Optional key-value pairs for tagging or structuring additional information.
    /// </para>
    /// <para>
    /// • Upon success, the returned <c>TConversations</c> object includes details such as:
    /// </para>
    /// <para>
    /// • <c>Id</c> — The unique identifier of the newly created conversation (e.g., “conv_123”).
    /// <c>CreatedAt</c> — The Unix timestamp of creation (in seconds).
    /// <c>Metadata</c> — The associated structured metadata, serialized as a JSON string.
    /// </para>
    /// <para>
    /// • This is a blocking call: it executes the HTTP request synchronously and returns only when the
    /// operation completes or fails. For asynchronous execution, consider using
    /// <c>AsyncAwaitCreate</c> or <c>AsynCreate</c>.
    /// </para>
    /// <para>
    /// • Internally, this method delegates to <c>API.Post&lt;TConversations, TConversationsParams&gt;</c>,
    /// ensuring full type-safe deserialization and JSON fingerprinting through the
    /// <c>TJSONFingerprint</c> inheritance chain.
    /// </para>
    /// </remarks>
    function Create(const ParamProc: TProc<TConversationsParams>): TConversations; override;

    /// <summary>
    /// Deletes a conversation synchronously and returns a <c>TConversationsDeleted</c> acknowledgment object.
    /// </summary>
    /// <param name="ConversationId">
    /// The unique identifier of the conversation to delete.
    /// This corresponds to the <c>Id</c> field of the <c>TConversations</c> object (for example, “conv_123”).
    /// </param>
    /// <returns>
    /// A <c>TConversationsDeleted</c> object confirming the result of the delete operation.
    /// It contains fields such as <c>Id</c>, <c>&amp;Object</c>, and <c>Deleted</c>.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This method performs a synchronous DELETE request to the <c>/conversations/{conversation_id}</c> endpoint
    /// of the API, permanently removing the specified conversation and its associated items.
    /// </para>
    /// <para>
    /// • Upon success, the returned <c>TConversationsDeleted</c> (alias of <c>TResponseDelete</c>) provides:
    /// </para>
    /// <para>
    /// • <c>Id</c> — The unique identifier of the deleted conversation.
    /// <c>&amp;Object</c> — A discriminator string, typically set to “conversation.deleted”.
    /// <c>Deleted</c> — A boolean flag indicating the success (<c>true</c>) or failure (<c>false</c>) of the deletion.
    /// </para>
    /// <para>
    /// • This is a blocking call: it executes synchronously and only returns when the deletion request has completed
    /// or failed. To perform non-blocking deletion, consider using <c>AsyncAwaitDelete</c> or <c>AsynDelete</c>.
    /// </para>
    /// <para>
    /// • Internally, this method delegates to <c>API.Delete&lt;TConversationsDeleted&gt;</c>, ensuring
    /// type-safe deserialization of the API’s acknowledgment response and preserving the raw JSON payload
    /// via <c>TJSONFingerprint.JSONResponse</c>.
    /// </para>
    /// </remarks>
    function Delete(const ConversationId: string): TConversationsDeleted; override;

    /// <summary>
    /// Retrieves a specific conversation synchronously and returns a <c>TConversations</c> instance.
    /// </summary>
    /// <param name="ConversationId">
    /// The unique identifier of the conversation to retrieve.
    /// This corresponds to the <c>Id</c> field of the <c>TConversations</c> object (for example, “conv_123”).
    /// </param>
    /// <returns>
    /// A <c>TConversations</c> object containing the full details of the retrieved conversation.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This method performs a synchronous GET request to the <c>/conversations/{conversation_id}</c> endpoint
    /// of the API, fetching the current state and metadata of the specified conversation.
    /// </para>
    /// <para>
    /// • Upon success, the returned <c>TConversations</c> object includes fields such as:
    /// </para>
    /// <para>
    /// • <c>Id</c> — The conversation’s unique identifier.
    /// <c>CreatedAt</c> — The Unix timestamp (in seconds) representing when the conversation was created.
    /// <c>Metadata</c> — A JSON string containing optional key-value metadata attached to the conversation.
    /// <c>&amp;Object</c> — A discriminator value indicating the resource type, typically “conversation”.
    /// </para>
    /// <para>
    /// • This is a blocking call that executes the retrieval request synchronously and returns only when
    /// the operation completes or fails.
    /// For non-blocking operations, use <c>AsyncAwaitRetrieve</c> or <c>AsynRetrieve</c>.
    /// </para>
    /// <para>
    /// • Internally, this method delegates to <c>API.Get&lt;TConversations&gt;</c>, ensuring type-safe deserialization
    /// and preserving the raw API response as a formatted JSON string accessible via
    /// <c>TJSONFingerprint.JSONResponse</c>.
    /// </para>
    /// </remarks>
    function Retrieve(const ConversationId: string): TConversations; override;

    /// <summary>
    /// Updates an existing conversation synchronously and returns the updated <c>TConversations</c> instance.
    /// </summary>
    /// <param name="ConversationId">
    /// The unique identifier of the conversation to update.
    /// This corresponds to the <c>Id</c> field of the <c>TConversations</c> object (for example, “conv_123”).
    /// </param>
    /// <param name="ParamProc">
    /// A configuration procedure used to define the update parameters via a <c>TUpdateConversationsParams</c> instance.
    /// Use this callback to modify conversation attributes such as <c>Metadata</c>.
    /// </param>
    /// <returns>
    /// A <c>TConversations</c> object reflecting the conversation’s new state after the update.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This method performs a synchronous POST request to the <c>/conversations/{conversation_id}</c> endpoint
    /// of the API, applying the provided update parameters to the specified conversation.
    /// </para>
    /// <para>
    /// • The parameters are configured through the <c>ParamProc</c> procedure, which operates on a
    /// <c>TUpdateConversationsParams</c> object. Common updateable fields include:
    /// </para>
    /// <para>
    /// • <c>Metadata</c> — A JSON object containing up to 16 key-value pairs of additional information
    /// (each key up to 64 characters, each value up to 512 characters).
    /// </para>
    /// <para>
    /// • Upon success, the returned <c>TConversations</c> instance contains the conversation’s
    /// updated attributes, including <c>Id</c>, <c>CreatedAt</c>, and <c>Metadata</c>, along with
    /// its identifying discriminator field <c>&amp;Object</c> (always “conversation”).
    /// </para>
    /// <para>
    /// • This is a blocking call: it executes the update request synchronously and returns only when
    /// the operation completes or fails.
    /// To perform updates asynchronously, use <c>AsyncAwaitUpdate</c> or <c>AsynUpdate</c>.
    /// </para>
    /// <para>
    /// • Internally, this method delegates to <c>API.Post&lt;TConversations, TUpdateConversationsParams&gt;</c>,
    /// ensuring type-safe deserialization of the API response and preserving the full raw JSON payload
    /// through <c>TJSONFingerprint.JSONResponse</c>.
    /// </para>
    /// </remarks>
    function Update(const ConversationId: string; const ParamProc: TProc<TUpdateConversationsParams>): TConversations; override;

    /// <summary>
    /// Retrieves a paginated list of items (messages, tool calls, etc.) belonging to a specific conversation
    /// and returns the result as a <c>TConversationList</c> collection.
    /// </summary>
    /// <param name="ConversationId">
    /// The unique identifier of the conversation whose items should be listed.
    /// This corresponds to the <c>Id</c> field of the <c>TConversations</c> object (for example, “conv_123”).
    /// </param>
    /// <param name="ParamProc">
    /// A configuration procedure used to define URL parameters through a <c>TUrlListItemsParams</c> instance.
    /// Use it to control pagination (<c>After</c>, <c>Limit</c>), ordering (<c>Order</c>),
    /// or included fields (<c>Include</c>).
    /// </param>
    /// <returns>
    /// A <c>TConversationList</c> object containing the list of items in the specified conversation.
    /// Each item in the list is a <c>TConversationsItem</c> (alias of <c>TResponseItem</c>).
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This method performs a synchronous GET request to the
    /// <c>/conversations/{conversation_id}/items</c> endpoint of the API, retrieving all available
    /// items (inputs, outputs, or tool interactions) associated with the specified conversation.
    /// </para>
    /// <para>
    /// • The <c>ParamProc</c> procedure allows fine-grained control over the listing behavior:
    /// </para>
    /// <para>
    /// • <c>After</c> — Continue pagination after a specific item ID.
    /// <c>Limit</c> — Restrict the number of returned items (between 1 and 100, default is 20).
    /// <c>Order</c> — Define the sorting order (<c>asc</c> or <c>desc</c>).
    /// <c>Include</c> — Specify optional output data to include (such as <c>web_search_call_action_sources</c>
    /// or <c>message_output_text_logprobs</c>).
    /// </para>
    /// <para>
    /// • Upon success, the resulting <c>TConversationList</c> (alias of <c>TResponses</c>) contains
    /// the structured collection of response items for that conversation, including message content,
    /// tool outputs, and reasoning traces when applicable.
    /// </para>
    /// <para>
    /// • This method executes synchronously, blocking until the API response is received.
    /// For asynchronous retrieval, use <c>AsyncAwaitList</c> or <c>AsynList</c>.
    /// </para>
    /// <para>
    /// • Internally, this method delegates to <c>API.Get&lt;TConversationList, TUrlListItemsParams&gt;</c>,
    /// handling automatic deserialization and preserving the raw JSON response through
    /// <c>TJSONFingerprint.JSONResponse</c>.
    /// </para>
    /// </remarks>
    function List(const ConversationId: string; const ParamProc: TProc<TUrlListItemsParams>): TConversationList; override;

    /// <summary>
    /// Adds one or more new items to an existing conversation synchronously
    /// and returns an updated <c>TConversationList</c> containing the inserted items.
    /// </summary>
    /// <param name="ConversationId">
    /// The unique identifier of the target conversation to which the items will be added.
    /// This corresponds to the <c>Id</c> field of the <c>TConversations</c> object (for example, “conv_123”).
    /// </param>
    /// <param name="ParamProc">
    /// A configuration procedure used to define the items to add via a <c>TConversationsItemParams</c> instance.
    /// Use this callback to specify the input messages or contextual data elements to include.
    /// </param>
    /// <returns>
    /// A <c>TConversationList</c> object representing the updated list of conversation items,
    /// including those newly added by the operation.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This method performs a synchronous POST request to the
    /// <c>/conversations/{conversation_id}/items</c> endpoint of the API, appending new items
    /// (messages, tool calls, or structured inputs) to the existing conversation.
    /// </para>
    /// <para>
    /// • The <c>ParamProc</c> parameter allows defining one or more items via <c>TConversationsItemParams.Items</c>,
    /// supporting up to 20 items per request. Each item represents a structured input to the model and
    /// may include text, images, or multimodal content.
    /// </para>
    /// <para>
    /// • Upon success, the returned <c>TConversationList</c> (alias of <c>TResponses</c>) contains
    /// all relevant response entries for the conversation, including the new additions and their
    /// corresponding model outputs, if applicable.
    /// </para>
    /// <para>
    /// • This is a blocking call: it executes synchronously and returns only once the API confirms
    /// that the new items have been successfully appended.
    /// For non-blocking asynchronous execution, use <c>AsyncAwaitCreateItem</c> or <c>AsynCreateItem</c>.
    /// </para>
    /// <para>
    /// • Internally, this method delegates to
    /// <c>API.Post&lt;TConversationList, TConversationsItemParams&gt;</c>, which handles type-safe
    /// serialization and deserialization of the request and response payloads.
    /// The original JSON API response is preserved in <c>TJSONFingerprint.JSONResponse</c>.
    /// </para>
    /// </remarks>
    function CreateItem(const ConversationId: string;
      const ParamProc: TProc<TConversationsItemParams>): TConversationList; overload; override;

    /// <summary>
    /// Adds one or more new items to an existing conversation synchronously,
    /// while specifying additional output fields to include in the response,
    /// and returns an updated <c>TConversationList</c> containing the inserted items.
    /// </summary>
    /// <param name="ConversationId">
    /// The unique identifier of the target conversation to which the items will be added.
    /// This corresponds to the <c>Id</c> field of the <c>TConversations</c> object (for example, “conv_123”).
    /// </param>
    /// <param name="Include">
    /// An array of <c>TOutputIncluding</c> values specifying which additional data fields should be
    /// included in the response.
    /// For example: <c>message_output_text_logprobs</c>, <c>web_search_call_action_sources</c>,
    /// or <c>code_interpreter_call_outputs</c>.
    /// </param>
    /// <param name="ParamProc">
    /// A configuration procedure used to define the items to add via a <c>TConversationsItemParams</c> instance.
    /// Use this callback to specify one or more input messages or contextual items to append to the conversation.
    /// </param>
    /// <returns>
    /// A <c>TConversationList</c> object representing the updated list of conversation items,
    /// including the newly added elements and their corresponding outputs.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This method performs a synchronous POST request to the
    /// <c>/conversations/{conversation_id}/items</c> endpoint of the API, allowing the inclusion
    /// of additional output data as specified by the <c>Include</c> parameter.
    /// </para>
    /// <para>
    /// • The <c>Include</c> array controls the richness of the returned data. It can request supplementary
    /// output structures, such as model reasoning traces, code execution results, or image URLs,
    /// depending on the tools or modalities involved in the conversation.
    /// </para>
    /// <para>
    /// • The <c>ParamProc</c> argument defines the set of items to add using <c>TConversationsItemParams.Items</c>.
    /// Each item represents a structured input (e.g., user message, system directive, or tool invocation).
    /// Up to 20 items may be added in a single request.
    /// </para>
    /// <para>
    /// • Upon success, the returned <c>TConversationList</c> (alias of <c>TResponses</c>) contains
    /// all conversation entries, including the newly created items, and may include enriched
    /// response details based on the <c>Include</c> options provided.
    /// </para>
    /// <para>
    /// • This is a blocking call: it executes synchronously and returns only once the operation
    /// is complete. For asynchronous handling, use <c>AsyncAwaitCreateItem</c> or <c>AsynCreateItem</c>.
    /// </para>
    /// <para>
    /// • Internally, this method delegates to an overload of <c>CreateItem</c> that configures
    /// <c>TUrlConversationsItemParams</c> via the <c>Include</c> array, then posts the request through
    /// <c>API.Post&lt;TConversationList, TUrlConversationsItemParams, TConversationsItemParams&gt;</c>.
    /// The raw API response is preserved in <c>TJSONFingerprint.JSONResponse</c> for audit or debugging purposes.
    /// </para>
    /// </remarks>
    function CreateItem(const ConversationId: string;
      const Include: TArray<TOutputIncluding>;
      const ParamProc: TProc<TConversationsItemParams>): TConversationList; overload; override;

    /// <summary>
    /// Retrieves a specific item (message, tool call, or output) from a conversation synchronously
    /// and returns it as a <c>TConversationsItem</c> instance.
    /// </summary>
    /// <param name="ConversationId">
    /// The unique identifier of the conversation containing the target item.
    /// This corresponds to the <c>Id</c> property of the <c>TConversations</c> object (for example, “conv_123”).
    /// </param>
    /// <param name="MessageId">
    /// The unique identifier of the conversation item to retrieve.
    /// This corresponds to the <c>Id</c> property of the <c>TConversationsItem</c> object (for example, “msg_456”).
    /// </param>
    /// <returns>
    /// A <c>TConversationsItem</c> object containing the full details of the requested item,
    /// including its type, content, metadata, and any associated tool or model output data.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This method performs a synchronous GET request to the
    /// <c>/conversations/{conversation_id}/items/{item_id}</c> endpoint of the API,
    /// fetching the complete representation of a specific message or tool call within a conversation.
    /// </para>
    /// <para>
    /// • The returned <c>TConversationsItem</c> (alias of <c>TResponseItem</c>) may represent various kinds
    /// of conversation elements, such as:
    /// </para>
    /// <para>
    /// • <c>Input messages</c> from the user or system.
    /// <c>Output messages</c> generated by the model.
    /// <c>Tool call results</c> (e.g., file searches, code execution, or web queries).
    /// <c>Structured response data</c> such as images, logs, or computed values.
    /// </para>
    /// <para>
    /// • This is a blocking operation that executes synchronously and returns only once the retrieval
    /// request has completed.
    /// For asynchronous retrieval, consider using <c>AsyncAwaitRetrieveItem</c> or <c>AsynRetrieveItem</c>.
    /// </para>
    /// <para>
    /// • Internally, this method delegates to <c>API.Get&lt;TConversationsItem&gt;</c> with automatic
    /// type-safe deserialization and field mapping.
    /// The original JSON response is preserved and accessible via <c>TJSONFingerprint.JSONResponse</c>.
    /// </para>
    /// </remarks>
    function RetrieveItem(const ConversationId: string;
      const MessageId: string): TConversationsItem; overload; override;

    /// <summary>
    /// Retrieves a specific item (message, tool call, or output) from a conversation synchronously,
    /// allowing additional URL parameters to customize the response, and returns a <c>TConversationsItem</c> instance.
    /// </summary>
    /// <param name="ConversationId">
    /// The unique identifier of the conversation containing the target item.
    /// This corresponds to the <c>Id</c> property of the <c>TConversations</c> object (for example, “conv_123”).
    /// </param>
    /// <param name="MessageId">
    /// The unique identifier of the conversation item to retrieve.
    /// This corresponds to the <c>Id</c> property of the <c>TConversationsItem</c> object (for example, “msg_456”).
    /// </param>
    /// <param name="UrlParamProc">
    /// A configuration procedure used to define URL query parameters via a <c>TUrlConversationsItemParams</c> instance.
    /// Use this callback to specify optional response customizations, such as additional included fields (<c>Include</c>),
    /// tool output expansions, or specific response details.
    /// </param>
    /// <returns>
    /// A <c>TConversationsItem</c> object representing the requested conversation item,
    /// enriched with any optional data specified by <c>UrlParamProc</c>.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This method performs a synchronous GET request to the
    /// <c>/conversations/{conversation_id}/items/{item_id}</c> endpoint of the API,
    /// retrieving the specified conversation item with optional query customizations.
    /// </para>
    /// <para>
    /// • The <c>UrlParamProc</c> callback allows the caller to define one or more URL parameters
    /// via <c>TUrlConversationsItemParams</c>. Common examples include:
    /// </para>
    /// <para>
    /// • <c>Include</c>: specify additional response components to return, such as
    /// <c>web_search_call_action_sources</c>, <c>code_interpreter_call_outputs</c>, or
    /// <c>message_output_text_logprobs</c>.
    /// <c>Reasoning_encrypted_content</c>: include reasoning token data when applicable.
    /// </para>
    /// <para>
    /// • The resulting <c>TConversationsItem</c> (alias of <c>TResponseItem</c>) provides the complete
    /// representation of the requested conversation element, including its metadata, content,
    /// type discriminator, and optional tool- or model-related output data.
    /// </para>
    /// <para>
    /// • This is a blocking operation: it executes synchronously and returns only after the retrieval
    /// request completes.
    /// For non-blocking asynchronous usage, use <c>AsyncAwaitRetrieveItem</c> or <c>AsynRetrieveItem</c>.
    /// </para>
    /// <para>
    /// • Internally, this method delegates to
    /// <c>API.Get&lt;TConversationsItem, TUrlConversationsItemParams&gt;</c>, which performs automatic
    /// type-safe deserialization and structured data mapping.
    /// The raw API response JSON is preserved via <c>TJSONFingerprint.JSONResponse</c> for reference or debugging.
    /// </para>
    /// </remarks>
    function RetrieveItem(const ConversationId: string;
      const MessageId: string;
      const UrlParamProc: TProc<TUrlConversationsItemParams>): TConversationsItem; overload; override;

    /// <summary>
    /// Deletes a specific item (message, tool call, or output) from a conversation synchronously
    /// and returns the updated <c>TConversations</c> instance reflecting the new state.
    /// </summary>
    /// <param name="ConversationId">
    /// The unique identifier of the conversation containing the item to delete.
    /// This corresponds to the <c>Id</c> property of the <c>TConversations</c> object (for example, “conv_123”).
    /// </param>
    /// <param name="MessageId">
    /// The unique identifier of the conversation item to remove.
    /// This corresponds to the <c>Id</c> property of the <c>TConversationsItem</c> object (for example, “msg_456”).
    /// </param>
    /// <returns>
    /// A <c>TConversations</c> object representing the conversation after the item has been deleted.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This method performs a synchronous DELETE request to the
    /// <c>/conversations/{conversation_id}/items/{item_id}</c> endpoint of the API,
    /// permanently removing the specified item (message, tool call, or structured output)
    /// from the given conversation.
    /// </para>
    /// <para>
    /// • Upon success, the returned <c>TConversations</c> instance contains the updated metadata
    /// and identifiers of the conversation after deletion. The item itself will no longer be
    /// accessible in subsequent retrieval or listing operations.
    /// </para>
    /// <para>
    /// • Typical use cases include deleting redundant or invalid conversation elements,
    /// clearing intermediate tool calls, or pruning conversation history.
    /// </para>
    /// <para>
    /// • This is a blocking operation that executes synchronously and returns only once
    /// the deletion process is completed.
    /// For non-blocking asynchronous execution, use <c>AsyncAwaitDeleteItem</c> or <c>AsynDeleteItem</c>.
    /// </para>
    /// <para>
    /// • Internally, this method delegates to <c>API.Delete&lt;TConversations&gt;</c>, which performs
    /// a type-safe request and automatically deserializes the API response into the corresponding
    /// <c>TConversations</c> object.
    /// The full JSON payload returned by the API is preserved and can be accessed via
    /// <c>TJSONFingerprint.JSONResponse</c> for auditing or debugging.
    /// </para>
    /// </remarks>
    function DeleteItem(const ConversationId: string;
      const MessageId: string): TConversations; overload; override;

  end;

implementation

{ TConversationsParams }

function TConversationsParams.Items(
  const Value: TArray<TInputListItem>): TConversationsParams;
begin
  var JSONArray := TJSONArray.Create;
  for var Item in Value do
    JSONArray.Add(Item.Detach);
  Result := TConversationsParams(Add('items', JSONArray));
end;

function TConversationsParams.Metadata(
  const Value: TJSONObject): TConversationsParams;
begin
  Result := TConversationsParams(Add('metadata', Value));
end;

class function TConversationsParams.New: TConversationsParams;
begin
  Result := TConversationsParams.Create;
end;

{ TConversationsRoute }

function TConversationsRoute.AsyncAwaitCreate(
  const ParamProc: TProc<TConversationsParams>;
  const CallBacks: TFunc<TPromiseConversations>): TPromise<TConversations>;
begin
  Result := TAsyncAwaitHelper.WrapAsyncAwait<TConversations>(
    procedure(const CallBackParams: TFunc<TAsynConversations>)
    begin
      Self.AsynCreate(ParamProc, CallBackParams);
    end,
    CallBacks);
end;

function TConversationsRoute.AsyncAwaitCreateItem(const ConversationId: string;
  const ParamProc: TProc<TConversationsItemParams>;
  const CallBacks: TFunc<TPromiseConversationList>): TPromise<TConversationList>;
begin
  Result := TAsyncAwaitHelper.WrapAsyncAwait<TConversationList>(
    procedure(const CallBackParams: TFunc<TAsynConversationList>)
    begin
      Self.AsynCreateItem(ConversationId, ParamProc, CallBackParams);
    end,
    CallBacks);
end;

function TConversationsRoute.AsyncAwaitCreateItem(const ConversationId: string;
  const Include: TArray<TOutputIncluding>;
  const ParamProc: TProc<TConversationsItemParams>;
  const CallBacks: TFunc<TPromiseConversationList>): TPromise<TConversationList>;
begin
  Result := TAsyncAwaitHelper.WrapAsyncAwait<TConversationList>(
    procedure(const CallBackParams: TFunc<TAsynConversationList>)
    begin
      Self.AsynCreateItem(ConversationId, Include, ParamProc, CallBackParams);
    end,
    CallBacks);
end;

function TConversationsRoute.AsyncAwaitDelete(const ConversationId: string;
  const CallBacks: TFunc<TPromiseConversationsDeleted>): TPromise<TConversationsDeleted>;
begin
  Result := TAsyncAwaitHelper.WrapAsyncAwait<TConversationsDeleted>(
    procedure(const CallBackParams: TFunc<TAsynConversationsDeleted>)
    begin
      Self.AsynDelete(ConversationId, CallBackParams);
    end,
    CallBacks);
end;

function TConversationsRoute.AsyncAwaitDeleteItem(
  const ConversationId, MessageId: string;
  const CallBacks: TFunc<TPromiseConversations>): TPromise<TConversations>;
begin
  Result := TAsyncAwaitHelper.WrapAsyncAwait<TConversations>(
    procedure(const CallBackParams: TFunc<TAsynConversations>)
    begin
      Self.AsynDeleteItem(ConversationId, MessageId, CallBackParams);
    end,
    CallBacks);
end;

function TConversationsRoute.AsyncAwaitList(const ConversationId: string;
  const ParamProc: TProc<TUrlListItemsParams>;
  const CallBacks: TFunc<TPromiseConversationList>): TPromise<TConversationList>;
begin
  Result := TAsyncAwaitHelper.WrapAsyncAwait<TConversationList>(
    procedure(const CallBackParams: TFunc<TAsynConversationList>)
    begin
      Self.AsynList(ConversationId, ParamProc, CallBackParams);
    end,
    CallBacks);
end;

function TConversationsRoute.AsyncAwaitRetrieve(const ConversationId: string;
  const CallBacks: TFunc<TPromiseConversations>): TPromise<TConversations>;
begin
  Result := TAsyncAwaitHelper.WrapAsyncAwait<TConversations>(
    procedure(const CallBackParams: TFunc<TAsynConversations>)
    begin
      Self.AsynRetrieve(ConversationId, CallBackParams);
    end,
    CallBacks);
end;

function TConversationsRoute.AsyncAwaitRetrieveItem(
  const ConversationId, MessageId: string;
  const UrlParamProc: TProc<TUrlConversationsItemParams>;
  const CallBacks: TFunc<TPromiseConversationsItem>): TPromise<TConversationsItem>;
begin
  Result := TAsyncAwaitHelper.WrapAsyncAwait<TConversationsItem>(
    procedure(const CallBackParams: TFunc<TAsynConversationsItem>)
    begin
      Self.AsynRetrieveItem(ConversationId, MessageId, UrlParamProc, CallBackParams);
    end,
    CallBacks);
end;

function TConversationsRoute.AsyncAwaitRetrieveItem(
  const ConversationId, MessageId: string;
  const CallBacks: TFunc<TPromiseConversationsItem>): TPromise<TConversationsItem>;
begin
  Result := TAsyncAwaitHelper.WrapAsyncAwait<TConversationsItem>(
    procedure(const CallBackParams: TFunc<TAsynConversationsItem>)
    begin
      Self.AsynRetrieveItem(ConversationId, MessageId, CallBackParams);
    end,
    CallBacks);
end;

function TConversationsRoute.AsyncAwaitUpdate(const ConversationId: string;
  const ParamProc: TProc<TUpdateConversationsParams>;
  const CallBacks: TFunc<TPromiseConversations>): TPromise<TConversations>;
begin
  Result := TAsyncAwaitHelper.WrapAsyncAwait<TConversations>(
    procedure(const CallBackParams: TFunc<TAsynConversations>)
    begin
      Self.AsynUpdate(ConversationId, ParamProc, CallBackParams);
    end,
    CallBacks);
end;

{ TConversationsAsynchronousSupport }

procedure TConversationsAsynchronousSupport.AsynCreate(
  const ParamProc: TProc<TConversationsParams>;
  const CallBacks: TFunc<TAsynConversations>);
begin
  with TAsynCallBackExec<TAsynConversations, TConversations>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TConversations
      begin
        Result := Self.Create(ParamProc);
      end);
  finally
    Free;
  end;
end;

procedure TConversationsAsynchronousSupport.AsynCreateItem(const ConversationId: string;
  const ParamProc: TProc<TConversationsItemParams>;
  const CallBacks: TFunc<TAsynConversationList>);
begin
  with TAsynCallBackExec<TAsynConversationList, TConversationList>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TConversationList
      begin
        Result := Self.CreateItem(ConversationId, ParamProc);
      end);
  finally
    Free;
  end;
end;

procedure TConversationsAsynchronousSupport.AsynCreateItem(const ConversationId: string;
  const Include: TArray<TOutputIncluding>;
  const ParamProc: TProc<TConversationsItemParams>;
  const CallBacks: TFunc<TAsynConversationList>);
begin
  with TAsynCallBackExec<TAsynConversationList, TConversationList>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TConversationList
      begin
        Result := Self.CreateItem(ConversationId, Include, ParamProc);
      end);
  finally
    Free;
  end;
end;

procedure TConversationsAsynchronousSupport.AsynDelete(const ConversationId: string;
  const CallBacks: TFunc<TAsynConversationsDeleted>);
begin
  with TAsynCallBackExec<TAsynConversationsDeleted, TConversationsDeleted>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TConversationsDeleted
      begin
        Result := Self.Delete(ConversationId);
      end);
  finally
    Free;
  end;
end;

procedure TConversationsAsynchronousSupport.AsynDeleteItem(const ConversationId,
  MessageId: string; const CallBacks: TFunc<TAsynConversations>);
begin
  with TAsynCallBackExec<TAsynConversations, TConversations>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TConversations
      begin
        Result := Self.DeleteItem(ConversationId, MessageId);
      end);
  finally
    Free;
  end;
end;

procedure TConversationsAsynchronousSupport.AsynList(const ConversationId: string;
  const ParamProc: TProc<TUrlListItemsParams>;
  const CallBacks: TFunc<TAsynConversationList>);
begin
  with TAsynCallBackExec<TAsynConversationList, TConversationList>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TConversationList
      begin
        Result := Self.List(ConversationId, ParamProc);
      end);
  finally
    Free;
  end;
end;

procedure TConversationsAsynchronousSupport.AsynRetrieve(const ConversationId: string;
  const CallBacks: TFunc<TAsynConversations>);
begin
  with TAsynCallBackExec<TAsynConversations, TConversations>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TConversations
      begin
        Result := Self.Retrieve(ConversationId);
      end);
  finally
    Free;
  end;
end;

procedure TConversationsAsynchronousSupport.AsynRetrieveItem(
  const ConversationId, MessageId: string;
  const UrlParamProc: TProc<TUrlConversationsItemParams>;
  const CallBacks: TFunc<TAsynConversationsItem>);
begin
  with TAsynCallBackExec<TAsynConversationsItem, TConversationsItem>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TConversationsItem
      begin
        Result := Self.RetrieveItem(ConversationId, MessageId, UrlParamProc);
      end);
  finally
    Free;
  end;
end;

procedure TConversationsAsynchronousSupport.AsynRetrieveItem(const ConversationId,
  MessageId: string; const CallBacks: TFunc<TAsynConversationsItem>);
begin
  with TAsynCallBackExec<TAsynConversationsItem, TConversationsItem>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TConversationsItem
      begin
        Result := Self.RetrieveItem(ConversationId, MessageId);
      end);
  finally
    Free;
  end;
end;

procedure TConversationsAsynchronousSupport.AsynUpdate(const ConversationId: string;
  const ParamProc: TProc<TUpdateConversationsParams>;
  const CallBacks: TFunc<TAsynConversations>);
begin
  with TAsynCallBackExec<TAsynConversations, TConversations>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TConversations
      begin
        Result := Self.Update(ConversationId, ParamProc);
      end);
  finally
    Free;
  end;
end;

{ TConversationsRoute }

function TConversationsRoute.Create(
  const ParamProc: TProc<TConversationsParams>): TConversations;
begin
  Result := API.Post<TConversations, TConversationsParams>('conversations', ParamProc);
end;

function TConversationsRoute.CreateItem(const ConversationId: string;
  const UrlParamProc: TProc<TUrlConversationsItemParams>;
  const ParamProc: TProc<TConversationsItemParams>): TConversationList;
var
  UrlParams: TUrlConversationsItemParams;
begin
  UrlParams := TUrlConversationsItemParams.Create;
  try
    if Assigned(UrlParamProc) then
      UrlParamProc(UrlParams);
    Result := API.Post<TConversationList, TConversationsItemParams>(
      'conversations/' + ConversationId + '/items' + UrlParams.Value, ParamProc);
  finally
    UrlParams.Free;
  end;
end;

function TConversationsRoute.CreateItem(const ConversationId: string;
  const ParamProc: TProc<TConversationsItemParams>): TConversationList;
begin
  Result := API.Post<TConversationList, TConversationsItemParams>(
    'conversations/' + ConversationId + '/items',
    ParamProc);
end;

function TConversationsRoute.CreateItem(const ConversationId: string;
  const Include: TArray<TOutputIncluding>;
  const ParamProc: TProc<TConversationsItemParams>): TConversationList;
begin
  Result := CreateItem(ConversationId,
    procedure (Params: TUrlConversationsItemParams)
    begin
      Params.Include(Include);
    end,
    ParamProc);
end;

function TConversationsRoute.Delete(
  const ConversationId: string): TConversationsDeleted;
begin
  Result := API.Delete<TConversationsDeleted>('conversations/' + ConversationId);
end;

function TConversationsRoute.DeleteItem(const ConversationId,
  MessageId: string): TConversations;
begin
  Result := API.Delete<TConversations>('conversations/' + ConversationId + '/items/' + MessageId);
end;

function TConversationsRoute.List(const ConversationId: string;
  const ParamProc: TProc<TUrlListItemsParams>): TConversationList;
begin
  Result := API.Get<TConversationList, TUrlListItemsParams>(
    'conversations/' + ConversationId + '/items', ParamProc);
end;

function TConversationsRoute.Retrieve(
  const ConversationId: string): TConversations;
begin
  Result := API.Get<TConversations>('conversations/' + ConversationId);
end;

function TConversationsRoute.RetrieveItem(const ConversationId, MessageId: string;
  const UrlParamProc: TProc<TUrlConversationsItemParams>): TConversationsItem;
begin
  Result := API.Get<TConversationsItem, TUrlConversationsItemParams>(
    'conversations/' + ConversationId + '/items/' + MessageId,
    UrlParamProc);
end;

function TConversationsRoute.RetrieveItem(const ConversationId,
  MessageId: string): TConversationsItem;
begin
  Result := API.Get<TConversationsItem>(
    'conversations/' + ConversationId + '/items/' + MessageId);
end;

function TConversationsRoute.Update(const ConversationId: string;
  const ParamProc: TProc<TUpdateConversationsParams>): TConversations;
begin
  Result := API.Post<TConversations, TUpdateConversationsParams>('conversations/' + ConversationId, ParamProc);
end;

{ TUpdateConversationsParams }

function TUpdateConversationsParams.Metadata(
  const Value: TJSONObject): TUpdateConversationsParams;
begin
  Result := TUpdateConversationsParams(Add('metadata', Value));
end;

class function TUpdateConversationsParams.New: TUpdateConversationsParams;
begin
  Result := TUpdateConversationsParams.Create;
end;

{ TUrlListItemsParams }

function TUrlListItemsParams.After(const Value: string): TUrlListItemsParams;
begin
  Result := TUrlListItemsParams(Add('after', Value));
end;

function TUrlListItemsParams.Include(
  const Value: TArray<TOutputIncluding>): TUrlListItemsParams;
var
  Include: TArray<string>;
begin
  for var Item in Value do
    Include := Include + [Item.ToString];
  Result := TUrlListItemsParams(Add('include', Include));
end;

function TUrlListItemsParams.Include(
  const Value: TArray<string>): TUrlListItemsParams;
begin
  Result := TUrlListItemsParams(Add('include', Value));
end;

function TUrlListItemsParams.Limit(const Value: Integer): TUrlListItemsParams;
begin
  Result := TUrlListItemsParams(Add('limit', Value));
end;

function TUrlListItemsParams.Order(const Value: string): TUrlListItemsParams;
begin
  Result := TUrlListItemsParams(Add('order', Value));
end;

{ TConversationsItemParams }

function TConversationsItemParams.Items(
  const Value: TArray<TInputListItem>): TConversationsItemParams;
begin
  var JSONArray := TJSONArray.Create;
  for var Item in Value do
    JSONArray.Add(Item.Detach);
  Result := TConversationsItemParams(Add('items', JSONArray));
end;

{ TUrlConversationsItemParams }

function TUrlConversationsItemParams.Include(
  const Value: TArray<TOutputIncluding>): TUrlConversationsItemParams;
var
  Include: TArray<string>;
begin
  for var Item in Value do
    Include := Include + [Item.ToString];
  Result := TUrlConversationsItemParams(Add('include', Include));
end;

function TUrlConversationsItemParams.Include(
  const Value: TArray<string>): TUrlConversationsItemParams;
begin
  Result := TUrlConversationsItemParams(Add('include', Value));
end;

end.
