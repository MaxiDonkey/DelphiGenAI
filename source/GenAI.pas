unit GenAI;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGenAI
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.SysUtils, System.Classes, GenAI.API, GenAI.API.Params, GenAI.Models,
  GenAI.Functions.Core, GenAI.Embeddings, GenAI.Audio, GenAI.Chat, GenAI.Moderation;

type
  /// <summary>
  /// The IGenAI interface provides access to the various features and routes of the Open AI API.
  /// This interface allows interaction with different services such as agents, chat, code completion,
  /// embeddings, file management, fine-tuning, and model information.
  /// </summary>
  /// <remarks>
  /// This interface should be implemented by any class that wants to provide a structured way of accessing
  /// the Open AI services. It includes methods and properties for authenticating with an API key,
  /// configuring the base URL, and accessing different API routes.
  /// </remarks>
  IGenAI = interface
    ['{4A1E56DB-67B7-4553-957E-4324C5BFC983}']
    function GetAPI: TGenAIAPI;
    function GetAPIKey: string;
    procedure SetAPIKey(const Value: string);
    function GetBaseUrl: string;
    procedure SetBaseUrl(const Value: string);

    function GetAudioRoute: TAudioRoute;
    function GetChatRoute: TChatRoute;
    function GetEmbeddingsRoute: TEmbeddingsRoute;
    function GetModelsRoute: TModelsRoute;
    function GetModerationRoute: TModerationRoute;

    /// <summary>
    /// Provides routes to handle audio-related requests including speech generation, transcription, and translation.
    /// </summary>
    /// <remarks>
    /// This class offers a set of methods to interact with OpenAI's API for generating speech from text,
    /// transcribing audio into text, and translating audio into English. It supports both synchronous and asynchronous
    /// operations to accommodate different application needs.
    /// </remarks>
    property Audio: TAudioRoute read GetAudioRoute;
    /// <summary>
    /// Handles the routing and execution of chat-related API requests within the application,
    /// facilitating interaction with AI models for generating chat completions.
    /// </summary>
    /// <remarks>
    /// TChatRoute is designed to manage chat interaction requests and responses, providing
    /// methods for both synchronous and asynchronous operations. This class plays a pivotal
    /// role in integrating and managing the AI-driven chat functionalities within diverse
    /// software architectures.
    /// </remarks>
    property Chat: TChatRoute read GetChatRoute;
    /// <summary>
    /// Provides routes for creating embeddings via the OpenAI API.
    /// </summary>
    /// <remarks>
    /// This class offers methods to asynchronously or synchronously create embeddings based on the parameters
    /// provided by the caller. It utilizes TGenAIRoute as a base to inherit API communication capabilities.
    /// </remarks>
    property Embeddings: TEmbeddingsRoute read GetEmbeddingsRoute;
    /// <summary>
    /// Provides routes for managing model data via API calls, including listing, retrieving, and deleting models.
    /// </summary>
    /// <remarks>
    /// The TModelsRoute class includes methods that facilitate asynchronous and synchronous operations
    /// to list, delete, and retrieve OpenAI models through the API. It acts as a controller for the
    /// interaction with the OpenAI model endpoints.
    /// </remarks>
    property Models: TModelsRoute read GetModelsRoute;


    property Moderation: TModerationRoute read GetModerationRoute;

    /// <summary>
    /// the main API object used for making requests.
    /// </summary>
    /// <returns>
    /// An instance of TGenAIAPI for making API calls.
    /// </returns>
    property API: TGenAIAPI read GetAPI;
    /// Sets or retrieves the API API key for authentication.
    /// </summary>
    /// <param name="Value">
    /// The API key as a string.
    /// </param>
    /// <returns>
    /// The current API key.
    /// </returns>
    property APIKey: string read GetAPIKey write SetAPIKey;
    /// <summary>
    /// Sets or retrieves the base URL for API requests.
    /// Default is https://api.openai.com/v1.
    /// </summary>
    /// <param name="Value">
    /// The base URL as a string.
    /// </param>
    /// <returns>
    /// The current base URL.
    /// </returns>
    property BaseURL: string read GetBaseUrl write SetBaseUrl;
    /// <summary>
    /// Provides access to agent completion API.
    /// An AI agent is an autonomous system using large language models (LLM) to perform tasks based on high-level instructions.
    /// </summary>
    /// <returns>
    /// An instance of TAgentRoute for agent-related operations.
    /// </returns>
  end;

  TGenAIFactory = class
    class function CreateInstance(const AAPIKey: string): IGenAI;
  end;

  /// <summary>
  /// The TGenAI class provides access to the various features and routes of the Open AI API.
  /// This class allows interaction with different services such as agents, chat, code completion,
  /// embeddings, file management, fine-tuning, and model information.
  /// </summary>
  /// <remarks>
  /// This class should be implemented by any class that wants to provide a structured way of accessing
  /// the Open AI services. It includes methods and properties for authenticating with an API key,
  /// configuring the base URL, and accessing different API routes.
  /// </remarks>
  TGenAI = class(TInterfacedObject, IGenAI)
  private
    FAPI: TGenAIAPI;

    FAudioRoute: TAudioRoute;
    FChatRoute: TChatRoute;
    FEmbeddingsRoute: TEmbeddingsRoute;
    FModelsRoute: TModelsRoute;
    FModerationRoute: TModerationRoute;

    function GetAPI: TGenAIAPI;
    function GetAPIKey: string;
    procedure SetAPIKey(const Value: string);
    function GetBaseUrl: string;
    procedure SetBaseUrl(const Value: string);

    function GetAudioRoute: TAudioRoute;
    function GetChatRoute: TChatRoute;
    function GetEmbeddingsRoute: TEmbeddingsRoute;
    function GetModelsRoute: TModelsRoute;
    function GetModerationRoute: TModerationRoute;
  public
    /// <summary>
    /// the main API object used for making requests.
    /// </summary>
    /// <returns>
    /// An instance of TGenAIAPI for making API calls.
    /// </returns>
    property API: TGenAIAPI read GetAPI;
    /// <summary>
    /// Sets or retrieves the API key for authentication.
    /// </summary>
    /// <param name="Value">
    /// The API key as a string.
    /// </param>
    /// <returns>
    /// The current API key.
    /// </returns>
    property APIKey: string read GetAPIKey write SetAPIKey;
    /// <summary>
    /// Sets or retrieves the base URL for API requests.
    /// Default is https://api.openai.com/v1.
    /// </summary>
    /// <param name="Value">
    /// The base URL as a string.
    /// </param>
    /// <returns>
    /// The current base URL.
    /// </returns>
    property BaseURL: string read GetBaseUrl write SetBaseUrl;
  public
    constructor Create; overload;
    constructor Create(const AAPIKey: string); overload;
    destructor Destroy; override;
  end;

  {$REGION 'GenAI.API.Params'}

  /// <summary>
  /// Represents a utility class for managing URL parameters and constructing query strings.
  /// </summary>
  /// <remarks>
  /// This class allows the addition of key-value pairs to construct a query string,
  /// which can be appended to a URL for HTTP requests. It provides overloads for adding
  /// various types of values, including strings, integers, booleans, doubles, and arrays.
  /// </remarks>
  TUrlParam = GenAI.API.Params.TUrlParam;

  /// <summary>
  /// Represents a utility class for managing JSON objects and constructing JSON structures dynamically.
  /// </summary>
  /// <remarks>
  /// This class provides methods to add, remove, and manipulate key-value pairs in a JSON object.
  /// It supports various data types, including strings, integers, booleans, dates, arrays, and nested JSON objects.
  /// </remarks>
  TJSONParam = GenAI.API.Params.TJSONParam;

  /// <summary>
  /// Represents a base class for all classes obtained after deserialization.
  /// </summary>
  /// <remarks>
  /// This class is designed to store the raw JSON string returned by the API,
  /// allowing applications to access the original JSON response if needed.
  /// </remarks>
  TJSONFingerprint = GenAI.API.Params.TJSONFingerprint;

  /// <summary>
  /// A custom JSON interceptor for handling string-to-string conversions in JSON serialization and deserialization.
  /// </summary>
  /// <remarks>
  /// This interceptor is designed to override the default behavior of JSON serialization
  /// and deserialization for string values, ensuring compatibility with specific formats
  /// or custom requirements.
  /// </remarks>
  TJSONInterceptorStringToString = GenAI.API.Params.TJSONInterceptorStringToString;

  {$ENDREGION}

  {$REGION 'GenAI.Functions.Core'}

  /// <summary>
  /// Interface defining the core structure and functionality of a function in the system.
  /// </summary>
  /// <remarks>
  /// This interface outlines the basic properties and methods that any function implementation must include.
  /// </remarks>
  IFunctionCore = GenAI.Functions.Core.IFunctionCore;

  {$ENDREGION}

  {$REGION 'GenAI.Audio'}

  /// <summary>
  /// Represents the parameters required to generate speech from text using the OpenAI API.
  /// </summary>
  /// <remarks>
  /// This class encapsulates the settings that can be configured for the speech synthesis request,
  /// including the model to use, the text input, the voice type, the response format, and the speed of speech.
  /// </remarks>
  TSpeechParams = GenAI.Audio.TSpeechParams;

  /// <summary>
  /// Represents the result of a speech synthesis request.
  /// </summary>
  /// <remarks>
  /// This class handles the response from the OpenAI API after a speech generation request,
  /// providing methods to access the generated audio content either as a stream or by saving it to a file.
  /// </remarks>
  TSpeechResult = GenAI.Audio.TSpeechResult;

  /// <summary>
  /// Represents the parameters required for transcribing audio into text using the OpenAI API.
  /// </summary>
  /// <remarks>
  /// This class encapsulates the settings that can be configured for the audio transcription request,
  /// such as the audio file, model to use, language of the audio, optional prompt, response format, and transcription temperature.
  /// </remarks>
  TTranscriptionParams = GenAI.Audio.TTranscriptionParams;

  /// <summary>
  /// Represents a single word from the transcription result with its corresponding timestamps.
  /// </summary>
  /// <remarks>
  /// This class provides detailed information about the timing of each word in the transcribed text,
  /// including the start and end times, which are useful for applications requiring precise synchronization
  /// between the audio and its transcription.
  /// </remarks>
  TTranscriptionWord = GenAI.Audio.TTranscriptionWord;

  /// <summary>
  /// Represents a segment of the transcription, providing details such as segment text and its corresponding timing.
  /// </summary>
  /// <remarks>
  /// This class details each segment of the transcribed audio, offering a deeper level of granularity for applications
  /// that need to break down the transcription into smaller pieces for analysis or display.
  /// </remarks>
  TTranscriptionSegment = GenAI.Audio.TTranscriptionSegment;

  /// <summary>
  /// Represents the full transcription result returned by the OpenAI audio transcription API.
  /// </summary>
  /// <remarks>
  /// This class encapsulates the complete transcription of an audio file, including the language,
  /// duration, and detailed segments and words with their corresponding timestamps.
  /// It serves as a comprehensive container for all the transcription details necessary for further processing
  /// or analysis in applications.
  /// </remarks>
  TTranscription = GenAI.Audio.TTranscription;

  /// <summary>
  /// Represents the parameters required for translating audio into English using the OpenAI API.
  /// </summary>
  /// <remarks>
  /// This class encapsulates settings for audio translation requests, including the audio file,
  /// the translation model, optional guiding prompt, response format, and translation temperature.
  /// </remarks>
  TTranslationParams = GenAI.Audio.TTranslationParams;

  /// <summary>
  /// Represents the translation result returned by the OpenAI audio translation API.
  /// </summary>
  /// <remarks>
  /// This class encapsulates the result of translating audio into English, containing the translated text.
  /// It is used to provide a straightforward interface to access the textual translation of spoken content.
  /// </remarks>
  TTranslation = GenAI.Audio.TTranslation;

  /// <summary>
  /// Manages asynchronous chat callBacks for a chat request using <c>TSpeechResult</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynSpeechResult</c> type extends the <c>TAsynParams&lt;TSpeechResult&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking chat operations and is specifically tailored for scenarios where multiple choices from a chat model are required.
  /// </remarks>
  TAsynSpeechResult = GenAI.Audio.TAsynSpeechResult;

  /// <summary>
  /// Manages asynchronous chat callBacks for a chat request using <c>TTranscription</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynTranscription</c> type extends the <c>TAsynParams&lt;TTranscription&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking chat operations and is specifically tailored for scenarios where multiple choices from a chat model are required.
  /// </remarks>
  TAsynTranscription = GenAI.Audio.TAsynTranscription;

  /// <summary>
  /// Manages asynchronous chat callBacks for a chat request using <c>TTranslation</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynTranslation</c> type extends the <c>TAsynParams&lt;TTranslation&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking chat operations and is specifically tailored for scenarios where multiple choices from a chat model are required.
  /// </remarks>
  TAsynTranslation = GenAI.Audio.TAsynTranslation;

  {$ENDREGION}

  {$REGION 'GenAI.Embeddings'}

  /// <summary>
  /// Represents the parameters required to create embeddings using the OpenAI API.
  /// </summary>
  /// <remarks>
  /// This class provides methods to specify different parameters for generating embeddings.
  /// The input can be a single string or an array of strings. You can also specify the model,
  /// encoding format, dimensions, and a user identifier. These parameters are used to configure
  /// the request to the OpenAI API to obtain embeddings that can be consumed by machine learning
  /// models and algorithms.
  /// </remarks>
  TEmbeddingsParams = GenAI.Embeddings.TEmbeddingsParams;

  /// <summary>
  /// Represents a single embedding vector returned by the OpenAI API.
  /// </summary>
  /// <remarks>
  /// This class encapsulates the details of an embedding, including its index in the list of returned embeddings,
  /// the embedding vector itself, and the object type. It inherits from TJSONFingerprint to utilize JSON serialization
  /// capabilities.
  /// </remarks>
  TEmbedding = GenAI.Embeddings.TEmbedding;

  /// <summary>
  /// Represents a collection of embedding vectors returned by the OpenAI API.
  /// </summary>
  /// <remarks>
  /// This class holds a list of TEmbedding objects, each representing an individual embedding vector.
  /// It includes methods for managing the lifecycle of these objects, including destruction. The class
  /// also inherits from TJSONFingerprint to leverage JSON serialization capabilities.
  /// </remarks>
  TEmbeddings = GenAI.Embeddings.TEmbeddings;

  /// <summary>
  /// Manages asynchronous chat callBacks for a chat request using <c>TEmbeddings</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynEmbeddings</c> type extends the <c>TAsynParams&lt;TEmbeddings&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking chat operations and is specifically tailored for scenarios where multiple choices from a chat model are required.
  /// </remarks>
  TAsynEmbeddings = GenAI.Embeddings.TAsynEmbeddings;

  {$ENDREGION}

  {$REGION 'GenAI.Models'}

  /// <summary>
  /// Represents an OpenAI model, encapsulating key information about a specific API model.
  /// </summary>
  /// <remarks>
  /// The TModel class stores attributes such as the unique identifier, creation timestamp,
  /// object type, and ownership details of the model. This class is typically used to handle
  /// and manipulate data related to models provided by OpenAI's API.
  /// </remarks>
  TModel = GenAI.Models.TModel;

  /// <summary>
  /// Represents a collection of OpenAI models, providing a list structure for managing multiple model instances.
  /// </summary>
  /// <remarks>
  /// The TModels class encapsulates a list of TModel objects, each representing detailed information about
  /// individual models. This collection is useful for operations that require handling multiple models,
  /// such as listing all available models from the OpenAI API.
  /// </remarks>
  TModels = GenAI.Models.TModels;

  /// <summary>
  /// Represents the deletion status of an OpenAI model.
  /// </summary>
  /// <remarks>
  /// The TModelDeletion class encapsulates the outcome of a deletion request for a model,
  /// including identification and deletion status. It is used to confirm the removal of
  /// a fine-tuned model instance from the OpenAI API.
  /// </remarks>
  TModelDeletion = GenAI.Models.TModelDeletion;

  /// <summary>
  /// Manages asynchronous chat callBacks for a chat request using <c>TModel</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynModel</c> type extends the <c>TAsynParams&lt;TModel&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking chat operations and is specifically tailored for scenarios where multiple choices from a chat model are required.
  /// </remarks>
  TAsynModel = GenAI.Models.TAsynModel;

  /// <summary>
  /// Manages asynchronous chat callBacks for a chat request using <c>TModels</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynModels</c> type extends the <c>TAsynParams&lt;TModels&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking chat operations and is specifically tailored for scenarios where multiple choices from a chat model are required.
  /// </remarks>
  TAsynModels = GenAI.Models.TAsynModels;

  /// <summary>
  /// Manages asynchronous chat callBacks for a chat request using <c>TModelDeletion</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynModelDeletion</c> type extends the <c>TAsynParams&lt;TModelDeletion&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking chat operations and is specifically tailored for scenarios where multiple choices from a chat model are required.
  /// </remarks>
  TAsynModelDeletion = GenAI.Models.TAsynModelDeletion;

  {$ENDREGION}

  {$REGION 'GenAI.Chat'}

  /// <summary>
  /// Represents an image URL parameter for a JSON object, allowing the configuration
  /// of URLs or base64 encoded images with optional detail settings.
  /// </summary>
  /// <remarks>
  /// This class provides methods to set the URL and detail level for images that
  /// are to be included as part of JSON requests. It can handle both direct URLs
  /// and base64-encoded image data. The detail level can specify how much information
  /// the image should convey, which can influence processing or display in APIs
  /// consuming these URLs.
  /// </remarks>
  TImageUrl = GenAI.Chat.TImageUrl;

  /// <summary>
  /// Represents an audio input parameter for a JSON object, allowing the configuration
  /// of audio data and format.
  /// </summary>
  /// <remarks>
  /// This class provides methods to set the base64-encoded audio data and its format
  /// for use in JSON requests. The format specifies how the audio data is encoded,
  /// such as 'mp3' or 'wav', which is crucial for correct processing by APIs consuming
  /// this data.
  /// </remarks>
  TInputAudio = GenAI.Chat.TInputAudio;

  /// <summary>
  /// Manages content parameters for different types of inputs like text, images,
  /// and audio within a JSON structure.
  /// </summary>
  /// <remarks>
  /// This class serves as a utility to add various types of content to JSON requests.
  /// It supports handling text content, URLs for images, and base64-encoded audio data.
  /// Each method facilitates the inclusion of these content types into JSON objects
  /// with appropriate formatting and structure.
  /// </remarks>
  TContentParams = GenAI.Chat.TContentParams;

  /// <summary>
  /// Manages function parameters for API requests, allowing the setting of a function's
  /// name and its JSON-formatted arguments.
  /// </summary>
  /// <remarks>
  /// This class facilitates the construction of parameter objects for functions within
  /// JSON requests. It supports specifying the function name and its arguments in a
  /// structured format, ensuring that the function can be called correctly with the
  /// provided parameters.
  /// </remarks>
  TFunctionParams = GenAI.Chat.TFunctionParams;

  /// <summary>
  /// Manages the parameters for tool calls within a JSON structure, facilitating the integration
  /// of tool functionality such as functions or specific actions within an API request.
  /// </summary>
  /// <remarks>
  /// This class allows for specifying the ID, type, and function details for tools that are to be
  /// called within an API request. It ensures that tool interactions are well-defined and correctly
  /// structured to perform expected operations.
  /// </remarks>
  TToolCallsParams = GenAI.Chat.TToolCallsParams;

  /// <summary>
  /// Manages the content parameters for assistant messages, facilitating the integration
  /// of text or refusal content within a JSON structure for virtual assistants.
  /// </summary>
  /// <remarks>
  /// This class provides methods to set text content or a refusal message in responses
  /// generated by an assistant. It allows for precise control over the content delivered
  /// by the assistant, ensuring that responses are appropriate and well-structured.
  /// </remarks>
  TAssistantContentParams = GenAI.Chat.TAssistantContentParams;

  /// <summary>
  /// Represents a message payload within a JSON-based messaging API, facilitating
  /// the structuring of communication between different roles such as user, assistant,
  /// and system.
  /// </summary>
  /// <remarks>
  /// This class provides a flexible framework for constructing message payloads with
  /// various content types and metadata, supporting diverse interactions within a
  /// chat or command-based environment.
  /// </remarks>
  TMessagePayload = GenAI.Chat.TMessagePayload;

  /// <summary>
  /// Manages the configuration of predicted content parts in JSON parameters, useful for
  /// specifying predefined outputs to optimize response generation.
  /// </summary>
  /// <remarks>
  /// This class enables the detailed specification of static or predictable content
  /// that can be used to facilitate more efficient processing when parts of the
  /// response are known in advance. This is especially beneficial in scenarios
  /// where response times are critical and part of the output is predetermined.
  /// </remarks>
  TPredictionPartParams = GenAI.Chat.TPredictionPartParams;

  /// <summary>
  /// Manages the configuration of prediction parameters for JSON requests, specifically
  /// designed to optimize model response generation by including expected content.
  /// </summary>
  /// <remarks>
  /// This class facilitates the integration of predictable or static content within
  /// JSON structured requests to optimize processing efficiencies and response accuracies
  /// in scenarios where certain outputs are known beforehand.
  /// </remarks>
  TPredictionParams = GenAI.Chat.TPredictionParams;

  /// <summary>
  /// Configures audio parameters within JSON requests to manage voice and format
  /// specifications for audio generation.
  /// </summary>
  /// <remarks>
  /// This class is designed to detail the audio output settings, such as voice type
  /// and audio format, to tailor the audio responses generated by models or APIs.
  /// </remarks>
  TAudioParams = GenAI.Chat.TAudioParams;

  /// <summary>
  /// Provides a means to specify a particular function that should be called by
  /// the tool choice mechanism within JSON requests.
  /// </summary>
  /// <remarks>
  /// This class is crucial for specifying which specific function should be executed,
  /// particularly in scenarios involving dynamic or automated decision-making processes
  /// where a specific operational function is needed.
  /// </remarks>
  TToolChoiceFunctionParams = GenAI.Chat.TToolChoiceFunctionParams;

  /// <summary>
  /// Handles the configuration for tool choice parameters, enabling specific function
  /// calls within JSON structured requests.
  /// </summary>
  /// <remarks>
  /// This class is designed to specify which tools or functions the system should use
  /// during the execution of an API call. It facilitates the dynamic selection of
  /// tools based on the requirements of the application, ensuring targeted and
  /// efficient processing.
  /// </remarks>
  TToolChoiceParams = GenAI.Chat.TToolChoiceParams;

  /// <summary>
  /// Manages parameters for chat request configurations in JSON format, supporting a wide
  /// range of attributes to customize the chat completion process.
  /// </summary>
  /// <remarks>
  /// This class facilitates the comprehensive configuration of chat-related parameters,
  /// allowing the control over model selection, token limitations, response modalities,
  /// and various other settings to optimize interaction dynamics and computational efficiency.
  /// </remarks>
  TChatParams = GenAI.Chat.TChatParams;

  /// <summary>
  /// Represents a single token's top log probability details.
  /// </summary>
  TTopLogprobs = GenAI.Chat.TTopLogprobs;

  /// <summary>
  /// Details about the log probabilities for a specific token, including its top probable alternatives.
  /// </summary>
  TLogprobsDetail = GenAI.Chat.TLogprobsDetail;

  /// <summary>
  /// Manages the collection of log probability details for both content and refusal message tokens.
  /// </summary>
  TLogprobs = GenAI.Chat.TLogprobs;

  /// <summary>
  /// Represents a function parameter in a tool call, specifying the function name
  /// and its arguments.
  /// </summary>
  /// <remarks>
  /// This class is used within the context of an API that supports remote function
  /// calls, enabling the specification of the function's name and the corresponding
  /// arguments in JSON format.
  /// </remarks>
  TFunction = GenAI.Chat.TFunction;

  /// <summary>
  /// Encapsulates a tool call within a chat or API interaction, linking the call
  /// to a specific function with its parameters.
  /// </summary>
  /// <remarks>
  /// TToolcall is used to manage the execution of backend functions as part of
  /// an interactive session or a workflow, associating each tool call with a unique
  /// identifier and the necessary function parameters.
  /// </remarks>
  TToolcall = GenAI.Chat.TToolcall;

  /// <summary>
  /// Represents audio data that can be streamed or stored during a chat or API session,
  /// including its identifier and expiration metadata.
  /// </summary>
  /// <remarks>
  /// TAudioData is used in contexts where audio responses are managed, providing
  /// support for both temporary and persistent storage of audio files with associated
  /// metadata about expiration and format.
  /// </remarks>
  TAudioData = GenAI.Chat.TAudioData;

  /// <summary>
  /// Represents audio data for use within a JSON structure, facilitating the management
  /// of audio file information including IDs, expiration, data, and transcripts.
  /// </summary>
  /// <remarks>
  /// This class allows for detailed control and retrieval of audio data properties, useful
  /// for audio processing applications that require handling of both metadata and streamable
  /// content. It extends TAudioData to provide additional functionalities like saving to files
  /// or retrieving the stream directly.
  /// </remarks>
  TAudio = GenAI.Chat.TAudio;

  /// <summary>
  /// Represents a delta update for chat completions, encapsulating modifications
  /// made during streaming or batch updates of chat messages.
  /// </summary>
  /// <remarks>
  /// TDelta class is crucial for real-time updates in chat interfaces, allowing
  /// dynamic response and modification tracking. It includes properties for managing
  /// content changes, associated tool calls, and the role and refusal messages within
  /// the chat structure.
  /// </remarks>
  TDelta = GenAI.Chat.TDelta;

  /// <summary>
  /// Represents a message within a chat conversation, encapsulating the content, role,
  /// and additional interactive elements like tool calls and audio data.
  /// </summary>
  /// <remarks>
  /// TMessage class is designed to facilitate detailed interaction within chat systems,
  /// supporting rich content types including text, tools, and audio. It handles the roles
  /// of participants, ensuring appropriate responses based on user or system activity, and
  /// integrates external tool functions as part of the conversation flow.
  /// </remarks>
  TMessage = GenAI.Chat.TMessage;

  /// <summary>
  /// Represents a choice or option generated during a chat interaction, encapsulating
  /// specific responses and associated data like logs and deltas.
  /// </summary>
  /// <remarks>
  /// TChoice is integral to managing multiple potential responses in interactive systems
  /// like chatbots, where each choice can represent a different continuation of the conversation.
  /// This class includes detailed information about the response, reasoning, and any associated
  /// changes or tool calls made during the interaction.
  /// </remarks>
  TChoice = GenAI.Chat.TChoice;

  /// <summary>
  /// Represents detailed token usage statistics for a specific chat completion, providing insights into
  /// how tokens are allocated across different categories such as audio, reasoning, and predictions.
  /// </summary>
  /// <remarks>
  /// TCompletionDetail is essential for monitoring and analyzing the computational resources used during
  /// chat interactions. This class helps in understanding the efficiency and distribution of token usage
  /// within the completion process, aiding in optimization and resource management.
  /// </remarks>
  TCompletionDetail = GenAI.Chat.TCompletionDetail;

  /// <summary>
  /// Provides detailed statistics about the tokens used in the prompt of a chat session,
  /// highlighting the resource utilization during the initial stages of chat interactions.
  /// </summary>
  /// <remarks>
  /// TPromptDetail is crucial for evaluating the computational cost of initiating chat interactions,
  /// specifically in terms of the number of tokens used for audio and cached content. This class aids
  /// in optimizing token usage, ensuring efficient management of resources in chat applications.
  /// </remarks>
  TPromptDetail = GenAI.Chat.TPromptDetail;

  /// <summary>
  /// Provides a comprehensive overview of token usage statistics for a chat completion request,
  /// facilitating detailed analysis of computational resource allocation.
  /// </summary>
  /// <remarks>
  /// TUsage is instrumental in tracking and managing the resource usage in chat applications,
  /// offering insights into how tokens are distributed between the prompt and completion phases.
  /// This class allows developers to assess and optimize the efficiency of the token utilization process.
  /// </remarks>
  TUsage = GenAI.Chat.TUsage;

  /// <summary>
  /// Represents a chat completion response returned by the model, including all relevant
  /// interaction details, choices, and usage statistics.
  /// </summary>
  /// <remarks>
  /// TChat is crucial for handling the outputs of chat models, providing developers with
  /// structured data on the interactions, including the chosen responses, reasons for
  /// completion, and detailed token usage. This class facilitates the integration and
  /// management of AI-powered chat functionalities within applications.
  /// </remarks>
  TChat = GenAI.Chat.TChat;

  /// <summary>
  /// Manages asynchronous chat callBacks for a chat request using <c>TChat</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynChat</c> type extends the <c>TAsynParams&lt;TChat&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking chat operations and is specifically tailored for scenarios where multiple choices from a chat model are required.
  /// </remarks>
  TAsynChat = GenAI.Chat.TAsynChat;

  /// <summary>
  /// Manages asynchronous streaming chat callBacks for a chat request using <c>TChat</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynChatStream</c> type extends the <c>TAsynStreamParams&lt;TChat&gt;</c> record to support the lifecycle of an asynchronous streaming chat operation.
  /// It provides callbacks for different stages, including when the operation starts, progresses with new data chunks, completes successfully, or encounters an error.
  /// This structure is ideal for handling scenarios where the chat response is streamed incrementally, providing real-time updates to the user interface.
  /// </remarks>
  TAsynChatStream = GenAI.Chat.TAsynChatStream;

  {$ENDREGION}

  {$REGION 'GenAI.Moderation'}

  /// <summary>
  /// Represents a text moderation parameter for a JSON object, enabling the configuration
  /// of text inputs to be classified for moderation purposes.
  /// </summary>
  /// <remarks>
  /// This class provides methods to define the type and content of text data to be
  /// analyzed for potentially harmful content. It is specifically designed for use
  /// in moderation APIs to assess textual content.
  /// </remarks>
  TTextModerationParams = GenAI.Moderation.TTextModerationParams;

  /// <summary>
  /// Represents a URL moderation parameter for a JSON object, enabling the configuration
  /// of URLs to be classified for moderation purposes.
  /// </summary>
  /// <remarks>
  /// This class provides methods to define and handle URLs as input for moderation.
  /// It supports both direct web URLs and local file paths that can be encoded into
  /// base64 format for evaluation by the moderation API.
  /// </remarks>
  TUrlModerationParams = GenAI.Moderation.TUrlModerationParams;

  /// <summary>
  /// Represents an image moderation parameter for a JSON object, enabling the configuration
  /// of image inputs to be classified for moderation purposes.
  /// </summary>
  /// <remarks>
  /// This class provides methods to define the type and content of image data, either
  /// via direct URLs or base64-encoded strings, to be analyzed for potentially harmful content.
  /// It is specifically designed for use in moderation APIs to assess image content.
  /// </remarks>
  TImageModerationParams = GenAI.Moderation.TImageModerationParams;

  /// <summary>
  /// Represents the parameters for moderation requests, enabling configuration
  /// for input data and model selection to classify content for moderation purposes.
  /// </summary>
  /// <remarks>
  /// This class provides methods to configure and handle inputs for moderation,
  /// such as text, image URLs, or an array of mixed inputs. It also allows
  /// specifying the moderation model to use.
  /// </remarks>
  TModerationParams = GenAI.Moderation.TModerationParams;

  /// <summary>
  /// Represents the moderation categories used to classify content as potentially harmful.
  /// Each category indicates a specific type of harmful content, such as harassment,
  /// violence, or hate speech.
  /// </summary>
  /// <remarks>
  /// This class provides properties for each moderation category. These properties
  /// are boolean values indicating whether the corresponding category is flagged
  /// for the given input.
  /// </remarks>
  TModerationCategories = GenAI.Moderation.TModerationCategories;

  /// <summary>
  /// Represents the scores for various moderation categories, providing numerical
  /// values that indicate the likelihood of content falling into specific harmful
  /// categories.
  /// </summary>
  /// <remarks>
  /// This class defines properties to store scores for multiple categories, such as
  /// hate, harassment, violence, and others. The scores range from 0 to 1, where
  /// higher values indicate a stronger likelihood of the content being flagged for
  /// the respective category.
  /// </remarks>
  TModerationCategoryScores = GenAI.Moderation.TModerationCategoryScores;

  /// <summary>
  /// Represents a moderation category applied to various input types, providing
  /// details on how different moderation categories are assigned based on input.
  /// </summary>
  /// <remarks>
  /// This class provides properties to retrieve the specific input types (e.g., text or image)
  /// that are associated with each moderation category. It is useful for identifying
  /// the sources of flagged content within a moderation request.
  /// </remarks>
  TModerationCategoryApplied = GenAI.Moderation.TModerationCategoryApplied;

  /// <summary>
  /// Represents a flagged item that contains information about a harmful content category
  /// and its associated score as determined by a moderation model.
  /// </summary>
  /// <remarks>
  /// This record is used to store details about content that has been flagged during
  /// moderation, including the category of harm and its confidence score. It is
  /// typically part of a collection of flagged items in moderation results.
  /// </remarks>
  TFlaggedItem = GenAI.Moderation.TFlaggedItem;

  /// <summary>
  /// Represents the result of a moderation process, including information about
  /// flagged categories, their confidence scores, and the associated input types.
  /// </summary>
  /// <remarks>
  /// This class provides a detailed overview of the moderation analysis, including
  /// which categories were flagged, the confidence scores for each category, and
  /// the types of inputs (e.g., text or image) associated with flagged categories.
  /// </remarks>
  TModerationResult = GenAI.Moderation.TModerationResult;

  /// <summary>
  /// Represents the overall moderation response, including results, model information,
  /// and a unique identifier for the moderation request.
  /// </summary>
  /// <remarks>
  /// This class serves as the main container for moderation data, encapsulating
  /// results from the moderation process, the model used, and the unique request ID.
  /// </remarks>
  TModeration = GenAI.Moderation.TModeration;

  /// <summary>
  /// Manages asynchronous chat callBacks for a chat request using <c>TModeration</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynModeration</c> type extends the <c>TAsynParams&lt;TModeration&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking chat operations and is specifically tailored for scenarios where multiple choices from a chat model are required.
  /// </remarks>
  TAsynModeration = GenAI.Moderation.TAsynModeration;

  {$ENDREGION}

function FromDeveloper(const Content: string; const Name: string = ''):TMessagePayload;
function FromSystem(const Content: string; const Name: string = ''):TMessagePayload;
function FromUser(const Content: string; const Name: string = ''):TMessagePayload; overload;
function FromUser(const Content: string; const Docs: TArray<string>; const Name: string = ''):TMessagePayload; overload;
function FromUser(const Docs: TArray<string>; const Name: string = ''):TMessagePayload; overload;
function FromAssistant(const ParamProc: TProcRef<TMessagePayload>): TMessagePayload; overload;
function FromAssistant(const Value: TMessagePayload): TMessagePayload; overload;
function FromTool(const Content: string; const ToolCallId: string): TMessagePayload;

function ToolCall(const Id: string; const Name: string; const Arguments: string): TToolCallsParams;
function PredictionPart(const AType: string; const Text: string): TPredictionPartParams;
function ToolName(const Name: string): TToolChoiceParams;

implementation

function FromDeveloper(const Content: string; const Name: string = ''):TMessagePayload;
begin
  Result := TMessagePayload.Developer(Content, Name);
end;

function FromSystem(const Content: string; const Name: string = ''):TMessagePayload;
begin
  Result := TMessagePayload.System(Content, Name);
end;

function FromUser(const Content: string; const Name: string = ''):TMessagePayload;
begin
  Result := TMessagePayload.User(Content, Name);
end;

function FromUser(const Content: string; const Docs: TArray<string>; const Name: string = ''):TMessagePayload;
begin
  Result := TMessagePayload.User(Content, Docs, Name);
end;

function FromUser(const Docs: TArray<string>;
  const Name: string = ''):TMessagePayload;
begin
  Result := TMessagePayload.User(Docs, Name);
end;

function FromAssistant(const ParamProc: TProcRef<TMessagePayload>): TMessagePayload;
begin
  Result := TMessagePayload.Assistant(ParamProc);
end;

function FromAssistant(const Value: TMessagePayload): TMessagePayload;
begin
  Result := TMessagePayload.Assistant(Value);
end;

function FromTool(const Content: string; const ToolCallId: string): TMessagePayload;
begin
  Result := TMessagePayload.Tool(content, ToolCallId);
end;

function ToolCall(const Id: string; const Name: string; const Arguments: string): TToolCallsParams;
begin
  Result := TToolCallsParams.New(Id, Name, Arguments);
end;

function PredictionPart(const AType: string; const Text: string): TPredictionPartParams;
begin
  Result := TPredictionPartParams.New(AType, Text);
end;

function ToolName(const Name: string): TToolChoiceParams;
begin
  Result := TToolChoiceParams.New(Name);
end;

{ TGenAI }

constructor TGenAI.Create;
begin
  inherited;
  FAPI := TGenAIAPI.Create;
end;

constructor TGenAI.Create(const AAPIKey: string);
begin
  Create;
  APIKey := AAPIKey;
end;

destructor TGenAI.Destroy;
begin
  FAudioRoute.Free;
  FEmbeddingsRoute.Free;
  FModelsRoute.Free;
  FChatRoute.Free;
  FModerationRoute.Free;
  FAPI.Free;
  inherited;
end;

function TGenAI.GetAPI: TGenAIAPI;
begin
  Result := FAPI;
end;

function TGenAI.GetAudioRoute: TAudioRoute;
begin
  if not Assigned(FAudioRoute) then
    FAudioRoute := TAudioRoute.CreateRoute(API);
  Result := FAudioRoute;
end;

function TGenAI.GetBaseUrl: string;
begin
  Result := FAPI.BaseURL;
end;

function TGenAI.GetEmbeddingsRoute: TEmbeddingsRoute;
begin
  if not Assigned(FEmbeddingsRoute) then
    FEmbeddingsRoute := TEmbeddingsRoute.CreateRoute(API);
  Result := FEmbeddingsRoute;
end;

function TGenAI.GetModelsRoute: TModelsRoute;
begin
  if not Assigned(FModelsRoute) then
    FModelsRoute := TModelsRoute.CreateRoute(API);
  Result := FModelsRoute;
end;

function TGenAI.GetModerationRoute: TModerationRoute;
begin
  if not Assigned(FModerationRoute) then
    FModerationRoute := TModerationRoute.CreateRoute(API);
  Result := FModerationRoute;
end;

function TGenAI.GetChatRoute: TChatRoute;
begin
  if not Assigned(FChatRoute) then
    FChatRoute := TChatRoute.CreateRoute(API);
  Result := FChatRoute;
end;

function TGenAI.GetAPIKey: string;
begin
  Result := FAPI.APIKey;
end;

procedure TGenAI.SetBaseUrl(const Value: string);
begin
  FAPI.BaseURL := Value;
end;

procedure TGenAI.SetAPIKey(const Value: string);
begin
  FAPI.APIKey := Value;
end;

{ TGenAIFactory }

class function TGenAIFactory.CreateInstance(const AAPIKey: string): IGenAI;
begin
  Result := TGenAI.Create(AAPIKey);
end;

end.
