unit GenAI;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGenAI
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.SysUtils, System.Classes, GenAI.API, GenAI.API.Params, GenAI.Models,
  GenAI.Functions.Core, GenAI.Batch.Interfaces, GenAI.Schema, GenAI.Embeddings,
  GenAI.Audio, GenAI.Chat, GenAI.Moderation, GenAI.Images, GenAI.Files, GenAI.Uploads,
  GenAI.Batch, GenAI.Batch.Reader, GenAI.Batch.Builder, GenAI.Completions,
  GenAI.FineTuning;

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
    function GetBatchRoute: TBatchRoute;
    function GetChatRoute: TChatRoute;
    function GetCompletionRoute: TCompletionRoute;
    function GetEmbeddingsRoute: TEmbeddingsRoute;
    function GetFilesRoute: TFilesRoute;
    function GetFineTuningRoute: TFineTuningRoute;
    function GetImagesRoute: TImagesRoute;
    function GetModelsRoute: TModelsRoute;
    function GetModerationRoute: TModerationRoute;
    function GetUploadsRoute: TUploadsRoute;

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
    /// Provides routes for managing batches within the OpenAI API.
    /// This class offers methods to create, retrieve, cancel, and list batches, facilitating the orchestration of batch operations.
    /// It is designed to support both synchronous and asynchronous execution of these operations, enhancing flexibility and efficiency
    /// in application workflows.
    /// </summary>
    property Batch: TBatchRoute read GetBatchRoute;
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
    /// Manages the routes for creating and streaming completions using the OpenAI API.
    /// This class handles both synchronous and asynchronous operations to interact with the API
    /// for generating text completions.
    /// </summary>
    property Completion: TCompletionRoute read GetCompletionRoute;
    /// <summary>
    /// Provides routes for creating embeddings via the OpenAI API.
    /// </summary>
    /// <remarks>
    /// This class offers methods to asynchronously or synchronously create embeddings based on the parameters
    /// provided by the caller. It utilizes TGenAIRoute as a base to inherit API communication capabilities.
    /// </remarks>
    property Embeddings: TEmbeddingsRoute read GetEmbeddingsRoute;
    /// <summary>
    /// Represents a route for managing file operations in the API.
    /// </summary>
    /// <remarks>
    /// This class provides methods for performing file-related operations, including uploading files,
    /// listing files, retrieving specific file details or content, and deleting files.
    /// It supports both synchronous and asynchronous operations for efficient file management.
    /// </remarks>
    property Files: TFilesRoute read GetFilesRoute;
    /// <summary>
    /// Provides methods to interact with the OpenAI fine-tuning API routes.
    /// </summary>
    /// <remarks>
    /// This class includes methods for creating, retrieving, listing, canceling, and managing fine-tuning jobs,
    /// as well as accessing associated events and checkpoints.
    /// </remarks>
    property FineTuning: TFineTuningRoute read GetFineTuningRoute;
    /// <summary>
    /// Represents the route handler for image-related operations using the OpenAI API.
    /// </summary>
    /// <remarks>
    /// This class provides methods for creating, editing, and generating variations of images.
    /// It supports both synchronous and asynchronous operations, making it suitable for
    /// diverse use cases involving image generation and manipulation.
    /// </remarks>
    property Images: TImagesRoute read GetImagesRoute;
    /// <summary>
    /// Provides routes for managing model data via API calls, including listing, retrieving, and deleting models.
    /// </summary>
    /// <remarks>
    /// The TModelsRoute class includes methods that facilitate asynchronous and synchronous operations
    /// to list, delete, and retrieve OpenAI models through the API. It acts as a controller for the
    /// interaction with the OpenAI model endpoints.
    /// </remarks>
    property Models: TModelsRoute read GetModelsRoute;
    /// <summary>
    /// Represents a route for handling moderation requests in the GenAI framework.
    /// This class provides methods for evaluating moderation parameters both
    /// synchronously and asynchronously.
    /// </summary>
    /// <remarks>
    /// This class is designed to manage moderation requests by interfacing with
    /// the GenAI API. It supports both synchronous and asynchronous operations
    /// for evaluating content against moderation models.
    /// </remarks>
    property Moderation: TModerationRoute read GetModerationRoute;
    /// <summary>
    /// Manages routes for handling file uploads, including creating uploads, adding parts, completing uploads, and canceling uploads.
    /// </summary>
    /// <remarks>
    /// This class provides methods to interact with the upload API endpoints. It supports asynchronous and synchronous
    /// operations for creating an upload, adding parts to it, completing the upload, and canceling an upload.
    /// </remarks>
    property Uploads: TUploadsRoute read GetUploadsRoute;

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
    FBatchRoute: TBatchRoute;
    FChatRoute: TChatRoute;
    FCompletionRoute: TCompletionRoute;
    FEmbeddingsRoute: TEmbeddingsRoute;
    FFilesRoute: TFilesRoute;
    FFineTuningRoute: TFineTuningRoute;
    FImagesRoute: TImagesRoute;
    FModelsRoute: TModelsRoute;
    FModerationRoute: TModerationRoute;
    FUploadsRoute: TUploadsRoute;

    function GetAPI: TGenAIAPI;
    function GetAPIKey: string;
    procedure SetAPIKey(const Value: string);
    function GetBaseUrl: string;
    procedure SetBaseUrl(const Value: string);

    function GetAudioRoute: TAudioRoute;
    function GetBatchRoute: TBatchRoute;
    function GetChatRoute: TChatRoute;
    function GetCompletionRoute: TCompletionRoute;
    function GetEmbeddingsRoute: TEmbeddingsRoute;
    function GetFilesRoute: TFilesRoute;
    function GetFineTuningRoute: TFineTuningRoute;
    function GetImagesRoute: TImagesRoute;
    function GetModelsRoute: TModelsRoute;
    function GetModerationRoute: TModerationRoute;
    function GetUploadsRoute: TUploadsRoute;

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

  {$REGION 'GenAI.API'}

  /// <summary>
  /// Manages and processes errors from the GenAI API responses.
  /// </summary>
  /// <remarks>
  /// This class extends <c>TApiHttpHandler</c> and provides error-handling capabilities
  /// by parsing error data and raising appropriate exceptions.
  /// </remarks>
  TApiDeserializer = GenAI.API.TApiDeserializer;

  {$ENDREGION}

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

  {$REGION 'GenAI.Schema'}

  /// <summary>
  /// Provides helper methods for creating property items in OpenAPI schema definitions.
  /// </summary>
  /// <remarks>
  /// This record simplifies the creation of property entries when building schema objects,
  /// particularly for object properties in OpenAPI specifications.
  /// </remarks>
  TPropertyItem = GenAI.Schema.TPropertyItem;

  /// <summary>
  /// Represents the Schema Object in OpenAPI, enabling the definition of input and output data types.
  /// These types can be objects, primitives, or arrays. This class provides methods to build and
  /// configure schema definitions as per the OpenAPI 3.0 Specification.
  /// </summary>
  /// <remarks>
  /// The Schema Object allows the definition of input and output data types in the OpenAPI Specification.
  /// This class provides a fluent interface to construct schema definitions programmatically.
  /// </remarks>
  TSchemaParams = GenAI.Schema.TSchemaParams;

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

  {$REGION 'GenAI.Completions'}

  /// <summary>
  /// Represents parameters for generating text completions using a specified model.
  /// This class provides a fluent interface to set various parameters like model,
  /// prompt, maximum tokens, and more that influence the behavior of the completion
  /// generation process.
  /// </summary>
  /// <remarks>
  /// Instances of this class can be customized using its methods to set values for
  /// different parameters like echo, stop sequences, penalties, etc. Each method
  /// modifies the instance and returns the same modified instance, allowing for
  /// method chaining.
  /// </remarks>
  TCompletionParams = GenAI.Completions.TCompletionParams;

  /// <summary>
  /// Represents the log probabilities and associated metadata for tokens generated in a text completion.
  /// This class is part of the detailed response structure providing insights into the model's token generation process.
  /// </summary>
  TChoicesLogprobs = GenAI.Completions.TChoicesLogprobs;

  /// <summary>
  /// Represents a single choice from the set of completions generated by the model.
  /// This class includes details about the text generated, the reasons for stopping,
  /// and probabilities associated with the tokens.
  /// </summary>
  TCompletionChoice = GenAI.Completions.TCompletionChoice;

  /// <summary>
  /// Represents the response from the completion API containing all generated choices,
  /// their details, and associated system information.
  /// This class extends TJSONFingerprint to include metadata about the API interaction.
  /// </summary>
  TCompletion = GenAI.Completions.TCompletion;

  /// <summary>
  /// Manages asynchronous chat callBacks for a chat request using <c>TCompletion</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynCompletion</c> type extends the <c>TAsynParams&lt;TCompletion&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking chat operations and is specifically tailored for scenarios where multiple choices from a chat model are required.
  /// </remarks>
  TAsynCompletion = GenAI.Completions.TAsynCompletion;

  /// <summary>
  /// Manages asynchronous streaming chat callBacks for a chat request using <c>TCompletion</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynCompletionStream</c> type extends the <c>TAsynStreamParams&lt;TCompletion&gt;</c> record to support the lifecycle of an asynchronous streaming chat operation.
  /// It provides callbacks for different stages, including when the operation starts, progresses with new data chunks, completes successfully, or encounters an error.
  /// This structure is ideal for handling scenarios where the chat response is streamed incrementally, providing real-time updates to the user interface.
  /// </remarks>
  TAsynCompletionStream = GenAI.Completions.TAsynCompletionStream;

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

  {$REGION 'GenAI.Images'}

  /// <summary>
  /// Represents a parameter class for creating images through the OpenAI API, enabling
  /// the configuration of prompts, models, and other settings for image generation.
  /// </summary>
  /// <remarks>
  /// This class provides methods to specify various parameters required for generating images,
  /// such as the text prompt, model, output size, and response format. It is designed
  /// for use with the image creation API to streamline the construction of requests.
  /// </remarks>
  TImageCreateParams = GenAI.Images.TImageCreateParams;

  /// <summary>
  /// Represents a parameter class for editing images through the OpenAI API, enabling
  /// the configuration of images, masks, prompts, and other settings for image editing.
  /// </summary>
  /// <remarks>
  /// This class provides methods to specify various parameters required for editing images,
  /// such as the image file, mask, text prompt, model, output size, and response format.
  /// It is designed for use with the image editing API to streamline the construction of requests.
  /// </remarks>
  TImageEditParams = GenAI.Images.TImageEditParams;

  /// <summary>
  /// Represents a parameter class for creating image variations through the OpenAI API, enabling
  /// the configuration of images, models, and other settings for variation generation.
  /// </summary>
  /// <remarks>
  /// This class provides methods to specify various parameters required for generating image variations,
  /// such as the base image, model, output size, and response format. It is designed
  /// for use with the image variation API to streamline the construction of requests.
  /// </remarks>
  TImageVariationParams = GenAI.Images.TImageVariationParams;

  /// <summary>
  /// Represents the data object for an image created through the OpenAI API.
  /// </summary>
  /// <remarks>
  /// This class contains the properties of the generated image, including its URL,
  /// base64-encoded content, and the revised prompt (if applicable).
  /// </remarks>
  TImageCreateData = GenAI.Images.TImageCreateData;

  /// <summary>
  /// Represents a part of the generated image, extending the <c>TImageCreateData</c> class
  /// to include file management functionality.
  /// </summary>
  /// <remarks>
  /// This class provides additional methods for handling the generated image, such as
  /// saving it to a file or retrieving it as a stream. It is designed for scenarios where
  /// the generated image needs to be manipulated or stored locally.
  /// </remarks>
  TImagePart = GenAI.Images.TImagePart;

  /// <summary>
  /// Represents the response object containing a collection of generated images
  /// and metadata about the creation process.
  /// </summary>
  /// <remarks>
  /// This class encapsulates the data returned by the OpenAI API for image generation,
  /// including the timestamp of creation and the list of generated images. It provides
  /// functionality for managing the lifecycle of these objects.
  /// </remarks>
  TGeneratedImages = GenAI.Images.TGeneratedImages;

  /// <summary>
  /// Manages asynchronous chat callBacks for a chat request using <c>TGeneratedImages</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynImagesCreate</c> type extends the <c>TAsynParams&lt;TGeneratedImages&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking chat operations and is specifically tailored for scenarios where multiple choices from a chat model are required.
  /// </remarks>
  TAsynGeneratedImages = GenAI.Images.TAsynGeneratedImages;

  {$ENDREGION}

  {$REGION 'GenAI.Files'}

  /// <summary>
  /// Represents a class for constructing URL parameters specifically for file-related operations in the API.
  /// </summary>
  /// <remarks>
  /// This class provides methods to configure URL parameters such as purpose, limit, order, and pagination.
  /// It is designed to simplify the creation of query strings for file operations like listing files or filtering them by specific criteria.
  /// </remarks>
  TFileUrlParams = GenAI.Files.TFileUrlParams;

  /// <summary>
  /// Represents a class for constructing parameters for uploading files to the API.
  /// </summary>
  /// <remarks>
  /// This class provides methods to configure multipart form data for file uploads,
  /// including setting the file path and specifying its purpose.
  /// It is designed to facilitate file uploads for various use cases such as fine-tuning, batch processing, or assistants.
  /// </remarks>
  TFileUploadParams = GenAI.Files.TFileUploadParams;

  /// <summary>
  /// Represents a file object in the API, containing metadata and attributes of the uploaded file.
  /// </summary>
  /// <remarks>
  /// This class provides properties to access file metadata such as ID, size, creation timestamp, filename,
  /// purpose, and type. It is used for operations that involve file management within the API.
  /// </remarks>
  TFile = GenAI.Files.TFile;

  /// <summary>
  /// Represents a collection of file objects retrieved from the API.
  /// </summary>
  /// <remarks>
  /// This class provides properties to access the metadata of a collection of files,
  /// including the list of files, pagination information, and object type.
  /// It is used for operations that involve listing or retrieving multiple files.
  /// </remarks>
  TFiles = GenAI.Files.TFiles;

  /// <summary>
  /// Represents the content of a file retrieved from the API.
  /// </summary>
  /// <remarks>
  /// This class provides properties to access the base64-encoded content of a file
  /// and a method to decode it into a readable string. It is used for operations that involve
  /// retrieving and processing the actual content of files.
  /// </remarks>
  TFileContent = GenAI.Files.TFileContent;

  /// <summary>
  /// Manages asynchronous chat callBacks for a chat request using <c>TFile</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynFile</c> type extends the <c>TAsynParams&lt;TFile&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking chat operations and is specifically tailored for scenarios where multiple choices from a chat model are required.
  /// </remarks>
  TAsynFile = GenAI.Files.TAsynFile;

  /// <summary>
  /// Manages asynchronous chat callBacks for a chat request using <c>TFiles</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynFiles</c> type extends the <c>TAsynParams&lt;TFiles&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking chat operations and is specifically tailored for scenarios where multiple choices from a chat model are required.
  /// </remarks>
  TAsynFiles = GenAI.Files.TAsynFiles;

  /// <summary>
  /// Manages asynchronous chat callBacks for a chat request using <c>TFiles</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynFiles</c> type extends the <c>TAsynParams&lt;TFiles&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking chat operations and is specifically tailored for scenarios where multiple choices from a chat model are required.
  /// </remarks>
  TAsynFileContent = GenAI.Files.TAsynFileContent;

  {$ENDREGION}

  {$REGION 'GenAI.Uploads'}

  /// <summary>
  /// Represents the parameters required for creating an upload object in the OpenAI API.
  /// </summary>
  /// <remarks>
  /// This class provides methods to configure the necessary fields for initiating an upload.
  /// An upload is used to prepare a file for adding multiple parts and eventually creating
  /// a File object that can be utilized within the platform.
  /// </remarks>
  TUploadCreateParams = GenAI.Uploads.TUploadCreateParams;

  /// <summary>
  /// Represents parameters for creating an upload part in a multipart form-data request.
  /// </summary>
  /// <remarks>
  /// This class provides methods to add data to the form-data structure, allowing the uploading
  /// of individual parts (chunks) of a file. It is specifically designed for use with APIs
  /// that handle large file uploads by splitting the file into smaller parts.
  /// </remarks>
  TUploadPartParams = GenAI.Uploads.TUploadPartParams;

  /// <summary>
  /// Represents parameters for completing an upload by specifying the order of parts and optional checksum validation.
  /// </summary>
  /// <remarks>
  /// This class provides methods to configure the finalization of a multipart upload by
  /// specifying the part IDs in the correct order and verifying the file's integrity using an MD5 checksum.
  /// </remarks>
  TUploadCompleteParams = GenAI.Uploads.TUploadCompleteParams;

  /// <summary>
  /// Represents the metadata and details of an upload, including its status, purpose, and associated file.
  /// </summary>
  /// <remarks>
  /// This class provides properties to access information about an upload object, such as its ID,
  /// filename, size, purpose, status, and expiration time. It also includes a reference to the
  /// associated file object once the upload is completed.
  /// </remarks>
  TUpload = GenAI.Uploads.TUpload;

  /// <summary>
  /// Represents metadata and details of a single upload part, including its ID, creation timestamp, and associated upload.
  /// </summary>
  /// <remarks>
  /// This class provides properties to access information about an upload part, such as its unique ID,
  /// creation time, and the ID of the parent upload to which it belongs.
  /// </remarks>
  TUploadPart = GenAI.Uploads.TUploadPart;

  /// <summary>
  /// Manages asynchronous chat callBacks for a chat request using <c>TUpload</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynUpload</c> type extends the <c>TAsynParams&lt;TUpload&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking chat operations and is specifically tailored for scenarios where multiple choices from a chat model are required.
  /// </remarks>
  TAsynUpload = GenAI.Uploads.TAsynUpload;

  /// <summary>
  /// Manages asynchronous chat callBacks for a chat request using <c>TUploadPart</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynUploadPart</c> type extends the <c>TAsynParams&lt;TUploadPart&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking chat operations and is specifically tailored for scenarios where multiple choices from a chat model are required.
  /// </remarks>
  TAsynUploadPart = GenAI.Uploads.TAsynUploadPart;

  {$ENDREGION}

  {$REGION 'GenAI.Batch'}

  /// <summary>
  /// Represents the parameters required to create a batch operation within the OpenAI API.
  /// This class encapsulates the settings and metadata necessary to initiate a batch process, including the input file, endpoint specification,
  /// completion window, and any optional metadata associated with the batch.
  /// </summary>
  TBatchCreateParams = GenAI.Batch.TBatchCreateParams;

  /// <summary>
  /// Represents the parameters for listing batches in the OpenAI API.
  /// This class provides the functionality to control pagination and set limits on the number of batch objects retrieved.
  /// It is useful for efficiently managing and navigating through large sets of batches.
  /// </summary>
  TBatchListParams = GenAI.Batch.TBatchListParams;

  /// <summary>
  /// Represents the error details associated with a specific request within a batch operation.
  /// This class holds detailed information about an error, including a machine-readable code, a human-readable message,
  /// and the specific parameter or line that caused the error. This facilitates debugging and error handling in batch processing.
  /// </summary>
  TBatchErrorsData = GenAI.Batch.TBatchErrorsData;

  /// <summary>
  /// Represents a collection of errors associated with a batch operation.
  /// This class aggregates all errors that occurred during the execution of a batch, facilitating centralized error management
  /// and analysis. Each error is detailed by an instance of TBatchErrorsData, which provides specific error information.
  /// </summary>
  TBatchErrors = GenAI.Batch.TBatchErrors;

  /// <summary>
  /// Provides a count of requests at various stages of processing within a batch operation.
  /// This class includes properties for tracking the total number of requests, the number of requests that have been completed successfully,
  /// and the number of requests that have failed. This information is crucial for monitoring and managing the progress of batch operations.
  /// </summary>
  TBatchRequestCounts = GenAI.Batch.TBatchRequestCounts;

  /// <summary>
  /// Represents a batch operation as managed by the OpenAI API, encapsulating comprehensive details
  /// necessary for managing batch processing tasks. This class includes functionalities such as tracking
  /// the batch's progress, its inputs and outputs, handling errors, and managing lifecycle timestamps.
  /// </summary>
  TBatch = GenAI.Batch.TBatch;

  /// <summary>
  /// Represents a collection of batch objects from the OpenAI API.
  /// This class provides an aggregated view of multiple batch entries, enabling effective navigation and management
  /// of batch operations. It includes functionality for pagination to handle large sets of data efficiently.
  /// </summary>
  TBatches = GenAI.Batch.TBatches;

  /// <summary>
  /// Manages asynchronous chat callBacks for a chat request using <c>TBatch</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynBatch</c> type extends the <c>TAsynParams&lt;TBatch&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking chat operations and is specifically tailored for scenarios where multiple choices from a chat model are required.
  /// </remarks>
  TAsynBatch = GenAI.Batch.TAsynBatch;

  /// <summary>
  /// Manages asynchronous chat callBacks for a chat request using <c>TBatches</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynBatches</c> type extends the <c>TAsynParams&lt;TBatches&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking chat operations and is specifically tailored for scenarios where multiple choices from a chat model are required.
  /// </remarks>
  TAsynBatches = GenAI.Batch.TAsynBatches;

  {$ENDREGION}

  {$REGION 'GenAI.FineTuning'}

  /// <summary>
  /// Represents the URL parameters for fine-tuning-related API requests.
  /// This class provides methods for setting pagination parameters
  /// such as "after" and "limit" to filter and retrieve fine-tuning jobs
  /// or related events.
  /// </summary>
  TFineTuningURLParams = GenAI.FineTuning.TFineTuningURLParams;

  /// <summary>
  /// Represents the configuration parameters for Weights and Biases (WandB) integration
  /// in fine-tuning jobs. These parameters specify project details, run names, entities,
  /// and tags associated with WandB.
  /// </summary>
  TWandbParams = GenAI.FineTuning.TWandbParams;

  /// <summary>
  /// Represents the configuration parameters for integrating external services
  /// into fine-tuning jobs. This class supports defining the type of integration
  /// (e.g., Weights and Biases) and its associated configuration details.
  /// </summary>
  TJobIntegrationParams = GenAI.FineTuning.TJobIntegrationParams;

  /// <summary>
  /// Represents the configuration of hyperparameters for fine-tuning jobs.
  /// This class provides methods to set parameters such as batch size,
  /// learning rate, number of epochs, and beta (for DPO).
  /// </summary>
  THyperparametersParams = GenAI.FineTuning.THyperparametersParams;

  /// <summary>
  /// Represents the configuration parameters for the supervised fine-tuning method.
  /// This class allows specifying hyperparameters to be used in supervised learning tasks.
  /// </summary>
  TSupervisedMethodParams = GenAI.FineTuning.TSupervisedMethodParams;

  /// <summary>
  /// Represents the configuration parameters for the DPO (Direct Preference Optimization)
  /// fine-tuning method. This class allows specifying hyperparameters to be used
  /// in DPO-based learning tasks.
  /// </summary>
  TDpoMethodParams = GenAI.FineTuning.TDpoMethodParams;

  /// <summary>
  /// Represents the configuration for the fine-tuning method to be used in a job.
  /// This class supports multiple methods, such as supervised learning or
  /// Direct Preference Optimization (DPO), and allows setting their respective parameters.
  /// </summary>
  TJobMethodParams = GenAI.FineTuning.TJobMethodParams;

  /// <summary>
  /// Represents the configuration parameters for creating a fine-tuning job.
  /// This class allows setting various properties, such as the model to fine-tune,
  /// training and validation files, hyperparameters, and optional metadata.
  /// </summary>
  TFineTuningJobParams = GenAI.FineTuning.TFineTuningJobParams;

  /// <summary>
  /// Represents detailed error information for a fine-tuning job that has failed.
  /// This class contains information about the error code, message, and the parameter
  /// that caused the failure.
  /// </summary>
  TFineTuningJobError = GenAI.FineTuning.TFineTuningJobError;

  /// <summary>
  /// Represents the hyperparameters used for a fine-tuning job in OpenAI's fine-tuning API.
  /// </summary>
  /// <remarks>
  /// The hyperparameters include options to control the training process, such as the batch size,
  /// learning rate, number of epochs, and beta (used in specific fine-tuning methods like DPO).
  /// These parameters allow customization of the model's fine-tuning behavior for optimal performance.
  /// </remarks>
  THyperparameters = GenAI.FineTuning.THyperparameters;

  /// <summary>
  /// Represents the configuration for integrating with Weights and Biases (WandB) in a fine-tuning job.
  /// </summary>
  /// <remarks>
  /// This class provides methods to set project details, display names, entities, and tags
  /// for runs tracked in WandB during the fine-tuning process.
  /// </remarks>
  TWanDB = GenAI.FineTuning.TWanDB;

  /// <summary>
  /// Represents the integration settings for a fine-tuning job, including integration with tools
  /// like Weights and Biases (WandB).
  /// </summary>
  /// <remarks>
  /// This class allows configuration of the type of integration and specific settings for each tool,
  /// such as WandB.
  /// </remarks>
  FineTuningJobIntegration = GenAI.FineTuning.FineTuningJobIntegration;

  /// <summary>
  /// Represents the configuration for supervised fine-tuning in a fine-tuning job.
  /// </summary>
  /// <remarks>
  /// This class contains the hyperparameters that define the supervised fine-tuning process.
  /// </remarks>
  TSupervised = GenAI.FineTuning.TSupervised;

  /// <summary>
  /// Represents the configuration for the DPO (Direct Preference Optimization) fine-tuning method
  /// in a fine-tuning job.
  /// </summary>
  /// <remarks>
  /// This class contains the hyperparameters that define the DPO fine-tuning process.
  /// </remarks>
  TDpo = GenAI.FineTuning.TDpo;

  /// <summary>
  /// Represents the method configuration for fine-tuning in a fine-tuning job.
  /// </summary>
  /// <remarks>
  /// This class defines the type of fine-tuning method (e.g., supervised or DPO) and includes the
  /// specific configurations for each method.
  /// </remarks>
  TFineTuningMethod = GenAI.FineTuning.TFineTuningMethod;

  /// <summary>
  /// Represents a fine-tuning job in OpenAI's fine-tuning API.
  /// </summary>
  /// <remarks>
  /// This class contains details about a fine-tuning job, including its status, configuration, and results.
  /// </remarks>
  TFineTuningJob = GenAI.FineTuning.TFineTuningJob;

  /// <summary>
  /// Represents a list of fine-tuning jobs in OpenAI's fine-tuning API.
  /// </summary>
  /// <remarks>
  /// This class extends <c>TJobList</c> to provide a collection of fine-tuning jobs and their details.
  /// </remarks>
  TFineTuningJobs = GenAI.FineTuning.TFineTuningJobs;

  /// <summary>
  /// Represents an event associated with a fine-tuning job in OpenAI's fine-tuning API.
  /// </summary>
  /// <remarks>
  /// This class provides information about a specific event, including its type, timestamp,
  /// message, and associated data.
  /// </remarks>
  TJobEvent = GenAI.FineTuning.TJobEvent;

  /// <summary>
  /// Represents a list of events associated with a fine-tuning job in OpenAI's fine-tuning API.
  /// </summary>
  /// <remarks>
  /// This class extends <c>TJobList</c> to provide a collection of events for a specific fine-tuning job,
  /// including their details such as type, message, and timestamps.
  /// </remarks>
  TJobEvents = GenAI.FineTuning.TJobEvents;

  /// <summary>
  /// Represents the metrics collected during a fine-tuning job in OpenAI's fine-tuning API.
  /// </summary>
  /// <remarks>
  /// This class contains various metrics related to the training and validation process,
  /// including loss values and token accuracy.
  /// </remarks>
  TMetrics = GenAI.FineTuning.TMetrics;

  /// <summary>
  /// Represents a model checkpoint for a fine-tuning job in OpenAI's fine-tuning API.
  /// </summary>
  /// <remarks>
  /// This class contains details about a specific checkpoint, including the step number, metrics,
  /// and the fine-tuned model checkpoint identifier.
  /// </remarks>
  TJobCheckpoint = GenAI.FineTuning.TJobCheckpoint;

  /// <summary>
  /// Represents a list of checkpoints for a fine-tuning job in OpenAI's fine-tuning API.
  /// </summary>
  /// <remarks>
  /// This class extends <c>TJobList</c> to provide a collection of checkpoints generated during
  /// a fine-tuning job. Each checkpoint includes details such as step number, metrics, and associated model data.
  /// </remarks>
  TJobCheckpoints = GenAI.FineTuning.TJobCheckpoints;

  /// <summary>
  /// Manages asynchronous chat callBacks for a chat request using <c>TFineTuningJob</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynFineTuningJob</c> type extends the <c>TAsynParams&lt;TFineTuningJob&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking chat operations and is specifically tailored for scenarios where multiple choices from a chat model are required.
  /// </remarks>
  TAsynFineTuningJob = GenAI.FineTuning.TAsynFineTuningJob;

  /// <summary>
  /// Manages asynchronous chat callBacks for a chat request using <c>TFineTuningJobs</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynFineTuningJobs</c> type extends the <c>TAsynParams&lt;TFineTuningJobs&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking chat operations and is specifically tailored for scenarios where multiple choices from a chat model are required.
  /// </remarks>
  TAsynFineTuningJobs = GenAI.FineTuning.TAsynFineTuningJobs;

  /// <summary>
  /// Manages asynchronous chat callBacks for a chat request using <c>TJobEvents</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynJobEvents</c> type extends the <c>TAsynParams&lt;TJobEvents&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking chat operations and is specifically tailored for scenarios where multiple choices from a chat model are required.
  /// </remarks>
  TAsynJobEvents = GenAI.FineTuning.TAsynJobEvents;

  /// <summary>
  /// Manages asynchronous chat callBacks for a chat request using <c>TJobCheckpoints</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynFineJobCheckpoints</c> type extends the <c>TAsynParams&lt;TJobCheckpoints&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking chat operations and is specifically tailored for scenarios where multiple choices from a chat model are required.
  /// </remarks>
  TAsynJobCheckpoints = GenAI.FineTuning.TAsynJobCheckpoints;

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

var
  JSONLChatReader: GenAI.Batch.Interfaces.IJSONLReader<TChat>;
  JSONLEmbeddingReader: GenAI.Batch.Interfaces.IJSONLReader<TEmbeddings>;
  BatchBuilder: GenAI.Batch.Interfaces.IBatchJSONBuilder;

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
  FBatchRoute.Free;
  FChatRoute.Free;
  FCompletionRoute.Free;
  FEmbeddingsRoute.Free;
  FFilesRoute.Free;
  FFineTuningRoute.Free;
  FImagesRoute.Free;
  FModelsRoute.Free;
  FModerationRoute.Free;
  FUploadsRoute.Free;
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

function TGenAI.GetBatchRoute: TBatchRoute;
begin
  if not Assigned(FBatchRoute) then
    FBatchRoute := TBatchRoute.CreateRoute(API);
  Result := FBatchRoute;
end;

function TGenAI.GetEmbeddingsRoute: TEmbeddingsRoute;
begin
  if not Assigned(FEmbeddingsRoute) then
    FEmbeddingsRoute := TEmbeddingsRoute.CreateRoute(API);
  Result := FEmbeddingsRoute;
end;

function TGenAI.GetFilesRoute: TFilesRoute;
begin
  if not Assigned(FFilesRoute) then
    FFilesRoute := TFilesRoute.CreateRoute(API);
  Result := FFilesRoute;
end;

function TGenAI.GetFineTuningRoute: TFineTuningRoute;
begin
  if not Assigned(FFineTuningRoute) then
    FFineTuningRoute := TFineTuningRoute.CreateRoute(API);
  Result := FFineTuningRoute;
end;

function TGenAI.GetImagesRoute: TImagesRoute;
begin
  if not Assigned(FImagesRoute) then
    FImagesRoute := TImagesRoute.CreateRoute(API);
  Result := FImagesRoute;
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

function TGenAI.GetUploadsRoute: TUploadsRoute;
begin
  if not Assigned(FUploadsRoute) then
    FUploadsRoute := TUploadsRoute.CreateRoute(API);
  Result := FUploadsRoute;
end;

function TGenAI.GetChatRoute: TChatRoute;
begin
  if not Assigned(FChatRoute) then
    FChatRoute := TChatRoute.CreateRoute(API);
  Result := FChatRoute;
end;

function TGenAI.GetCompletionRoute: TCompletionRoute;
begin
  if not Assigned(FCompletionRoute) then
    FCompletionRoute := TCompletionRoute.CreateRoute(API);
  Result := FCompletionRoute;
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

initialization
  JSONLChatReader := TJSONLReader<TChat>.CreateInstance;
  JSONLEmbeddingReader := TJSONLReader<TEmbeddings>.CreateInstance;
  BatchBuilder := TBatchJSONBuilder.Create;
end.
