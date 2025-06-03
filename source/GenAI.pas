unit GenAI;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGenAI
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

(*

   This Delphi project relies on several key dependencies that cover network functionality,
   JSON handling,  serialization,  asynchronous operations,  and error management. Here are
   the main categories of dependencies:

     1. Standard Delphi Dependencies:

   Utilizes  native libraries such as  System.Classes,  System.SysUtils,  System.JSON,  and
   System.Net.HttpClient for general operations, input/output, date management, and network
   communications.

     2. JSON and REST:

   Uses units like REST.Json.Types,  REST.Json.Interceptors, and REST.JsonReflect to handle
   object serialization/deserialization and REST API calls.

     3. Custom Exception and Error Handling:

   Internal modules GenAI.Exceptions and GenAI.Errors capture and propagate errors specific
   to the API.

     4. Custom GenAI API Modules:

   Custom modules like GenAI.API, GenAI.API.Params,  and GenAI.HttpClientInterface are used
   to build HTTP requests to the GenAI API and handle asynchronous responses.

     5. Multithreading and Asynchronous Operations:

   Utilizes System.Threading  and internal classes  (such as TAsynCallBack)  to handle long
   running tasks and avoid blocking the main thread.

     6. Testing Dependencies:

   Uses  DUnitX.TestFramework and  related  modules to implement  unit tests  and  validate
   critical project functionality.

   This  project is structured to be modular and extensible, with  abstractions that  allow
   for  easily switching  network  libraries  or  adding  new  features  while  maintaining
   robustness and testability.

*)

interface

uses
  System.SysUtils, System.Classes, System.JSON,
  GenAI.API, GenAI.API.Params, GenAI.Types, GenAI.API.Deletion, GenAI.Models,
  GenAI.Functions.Core, GenAI.Batch.Interfaces, GenAI.Schema, GenAI.Embeddings,
  GenAI.Audio, GenAI.Chat, GenAI.Moderation, GenAI.Images, GenAI.Files, GenAI.Uploads,
  GenAI.Batch, GenAI.Batch.Reader, GenAI.Batch.Builder, GenAI.Completions, GenAI.FineTuning,
  GenAI.Assistants, GenAI.Threads, GenAI.Messages, GenAI.Runs, GenAI.RunSteps,
  GenAI.Vector, GenAI.VectorFiles, GenAI.VectorBatch, GenAI.Monitoring, GenAI.Chat.Parallel,
  GenAI.Responses, GenAI.Responses.InputParams, GenAI.Responses.InputItemList,
  GenAI.Responses.OutputParams, GenAI.Async.Promise, GenAI.Responses.Internal;

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

    function GetAssistantsRoute: TAssistantsRoute;
    function GetAudioRoute: TAudioRoute;
    function GetBatchRoute: TBatchRoute;
    function GetChatRoute: TChatRoute;
    function GetCompletionRoute: TCompletionRoute;
    function GetEmbeddingsRoute: TEmbeddingsRoute;
    function GetFilesRoute: TFilesRoute;
    function GetFineTuningRoute: TFineTuningRoute;
    function GetImagesRoute: TImagesRoute;
    function GetMesssagesRoute: TMessagesRoute;
    function GetModelsRoute: TModelsRoute;
    function GetModerationRoute: TModerationRoute;
    function GetRunsRoute: TRunsRoute;
    function GetRunStepRoute: TRunStepRoute;
    function GetThreadsRoute: TThreadsRoute;
    function GetUploadsRoute: TUploadsRoute;
    function GetVectorStoreRoute: TVectorStoreRoute;
    function GetVectorStoreBatchRoute: TVectorStoreBatchRoute;
    function GetVectorStoreFilesRoute: TVectorStoreFilesRoute;
    function GetResponses: TResponsesRoute;

    /// <summary>
    /// Represents the API route handler for managing assistants.
    /// </summary>
    /// <remarks>
    /// This class provides methods to create, retrieve, update, list, and delete assistants
    /// using the OpenAI API. It extends <c>TGenAIRoute</c> to handle API interactions and
    /// custom headers.
    /// </remarks>
    property Assistants: TAssistantsRoute read GetAssistantsRoute;
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
    /// Manages the API routes for handling messages within a thread in the OpenAI API.
    /// </summary>
    /// <remarks>
    /// This class provides methods to create, retrieve, update, delete, and list messages
    /// within a thread. It also supports asynchronous operations for non-blocking message handling.
    /// </remarks>
    property Messages : TMessagesRoute read GetMesssagesRoute;
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
    /// Represents the route for managing execution runs in the OpenAI API.
    /// </summary>
    /// <remarks>
    /// This class provides methods to create, retrieve, update, list, and manage execution runs on threads.
    /// It handles both synchronous and asynchronous requests, allowing efficient interaction with the OpenAI API for execution management.
    /// </remarks>
    property Runs: TRunsRoute read GetRunsRoute;
    /// <summary>
    /// Represents the route for managing run steps within execution runs in the OpenAI API.
    /// </summary>
    /// <remarks>
    /// This class provides methods to list or retrieve details of run steps. It handles both synchronous
    /// and asynchronous requests, enabling efficient interaction with the OpenAI API for managing run steps.
    /// </remarks>
    property RunStep: TRunStepRoute read GetRunStepRoute;
    /// <summary>
    /// Provides an interface for interacting with OpenAI threads via API routes.
    /// This class supports both synchronous and asynchronous operations, including creating, retrieving, modifying, and deleting threads.
    /// </summary>
    /// <remarks>
    /// <para>
    /// The class encapsulates API requests and manages the associated headers, routes, and callbacks required
    /// for interacting with the OpenAI API. Developers can use it to perform thread-related tasks while leveraging
    /// both synchronous and non-blocking (asynchronous) execution flows.
    /// </para>
    /// <para>
    /// The tool resources associated with threads, such as files and vector stores, can be specified to enhance
    /// assistant capabilities like code execution or vector-based searches. Metadata can also be attached
    /// to threads for storing structured information.
    /// </para>
    /// </remarks>
    property Threads: TThreadsRoute read GetThreadsRoute;
    /// <summary>
    /// Manages routes for handling file uploads, including creating uploads, adding parts, completing uploads, and canceling uploads.
    /// </summary>
    /// <remarks>
    /// This class provides methods to interact with the upload API endpoints. It supports asynchronous and synchronous
    /// operations for creating an upload, adding parts to it, completing the upload, and canceling an upload.
    /// </remarks>
    property Uploads: TUploadsRoute read GetUploadsRoute;
    /// <summary>
    /// Provides methods to manage vector stores in the OpenAI API.
    /// </summary>
    /// <remarks>
    /// The <c>TVectorStoreRoute</c> class allows you to create, retrieve, update, list, and delete
    /// vector stores through various API endpoints. It supports both synchronous and asynchronous
    /// operations, making it flexible for different application needs.
    /// </remarks>
    property VectorStore: TVectorStoreRoute read GetVectorStoreRoute;
    /// <summary>
    /// Provides methods to manage file batches within a vector store using the OpenAI API.
    /// </summary>
    /// <remarks>
    /// This class allows users to create, retrieve, cancel, and list file batches associated
    /// with a specific vector store. It supports both synchronous and asynchronous operations,
    /// enabling flexible interaction with the API for managing batch processing.
    /// </remarks>
    property VectorStoreBatch: TVectorStoreBatchRoute read GetVectorStoreBatchRoute;
    /// <summary>
    /// Provides methods to manage files within a vector store using the OpenAI API.
    /// </summary>
    /// <remarks>
    /// The <c>TVectorStoreFilesRoute</c> class allows users to create, retrieve, list, and delete
    /// files associated with a vector store. It supports both synchronous and asynchronous
    /// operations, enabling flexible interaction with the API for managing file storage and processing.
    /// </remarks>
    property VectorStoreFiles: TVectorStoreFilesRoute read GetVectorStoreFilesRoute;

    property Responses: TResponsesRoute read GetResponses;

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

    FAssistantsRoute: TAssistantsRoute;
    FAudioRoute: TAudioRoute;
    FBatchRoute: TBatchRoute;
    FChatRoute: TChatRoute;
    FCompletionRoute: TCompletionRoute;
    FEmbeddingsRoute: TEmbeddingsRoute;
    FFilesRoute: TFilesRoute;
    FFineTuningRoute: TFineTuningRoute;
    FImagesRoute: TImagesRoute;
    FMessagesRoute: TMessagesRoute;
    FModelsRoute: TModelsRoute;
    FModerationRoute: TModerationRoute;
    FRunsRoute: TRunsRoute;
    FRunStepRoute: TRunStepRoute;
    FThreadsRoute: TThreadsRoute;
    FUploadsRoute: TUploadsRoute;
    FVectorStoreRoute: TVectorStoreRoute;
    FVectorStoreBatchRoute: TVectorStoreBatchRoute;
    FVectorStoreFilesRoute: TVectorStoreFilesRoute;
    FResponsesRoute: TResponsesRoute;

    function GetAPI: TGenAIAPI;
    function GetAPIKey: string;
    procedure SetAPIKey(const Value: string);
    function GetBaseUrl: string;
    procedure SetBaseUrl(const Value: string);

    function GetAssistantsRoute: TAssistantsRoute;
    function GetAudioRoute: TAudioRoute;
    function GetBatchRoute: TBatchRoute;
    function GetChatRoute: TChatRoute;
    function GetCompletionRoute: TCompletionRoute;
    function GetEmbeddingsRoute: TEmbeddingsRoute;
    function GetFilesRoute: TFilesRoute;
    function GetFineTuningRoute: TFineTuningRoute;
    function GetImagesRoute: TImagesRoute;
    function GetMesssagesRoute: TMessagesRoute;
    function GetModelsRoute: TModelsRoute;
    function GetModerationRoute: TModerationRoute;
    function GetRunsRoute: TRunsRoute;
    function GetRunStepRoute: TRunStepRoute;
    function GetThreadsRoute: TThreadsRoute;
    function GetUploadsRoute: TUploadsRoute;
    function GetVectorStoreRoute: TVectorStoreRoute;
    function GetVectorStoreBatchRoute: TVectorStoreBatchRoute;
    function GetVectorStoreFilesRoute: TVectorStoreFilesRoute;
    function GetResponses: TResponsesRoute;

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

  {$REGION 'GenAI.Async.Promise'}

  TStringPromise = GenAI.Async.Promise.TStringPromise;

  {$ENDREGION}

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
  /// Represents the parameters for listing.
  /// This class provides the functionality to control pagination and set limits on the number of objects retrieved.
  /// It is useful for efficiently managing and navigating through large sets of objects.
  /// </summary>
  TUrlPaginationParams = GenAI.API.Params.TUrlPaginationParams;

  /// <summary>
  /// Represents the advanced parameters for listing and filtering data.
  /// This class extends <see cref="TUrlPaginationParams"/> to provide additional functionality for
  /// sorting and navigating through paginated data.
  /// It is designed to manage more complex scenarios where both pagination and sorting are required.
  /// </summary>
  TUrlAdvancedParams = GenAI.API.Params.TUrlAdvancedParams;

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

  /// <summary>
  /// Represents a generic key-value parameter manager.
  /// </summary>
  /// <remarks>
  /// This class allows storing and retrieving various types of parameters as key-value pairs.
  /// It supports basic types (integers, strings, booleans, floating-point numbers), objects,
  /// as well as arrays of these types.
  /// </remarks>
  /// <example>
  ///   <code>
  ///     var Params: TParameters;
  ///     begin
  ///       Params := TParameters.Create;
  ///       Params.Add('Limit', 100)
  ///             .Add('Order', 'Asc')
  ///             .Add('IsEnabled', True);
  ///       if Params.Exists('Limit') then
  ///         ShowMessage(IntToStr(Params.GetInteger('Limit')));
  ///       Params.Free;
  ///     end;
  ///   </code>
  /// </example>
  TParameters = GenAI.API.Params.TParameters;

  {$ENDREGION}

  {$REGION 'GenAI.API.Deletion'}

  /// <summary>
  /// Represents a deletion response, providing details about the identifier, object type,
  /// and whether the deletion was successful.
  /// </summary>
  /// <remarks>
  /// This class is primarily used to store the result of a deletion request, including
  /// the unique ID of the deleted object, the type of the object, and a status indicating
  /// whether the deletion was completed successfully.
  /// </remarks>
  TDeletion = GenAI.API.Deletion.TDeletion;

  /// <summary>
  /// Manages asynchronous callBacks for a request using <c>TDeletion</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynDeletion</c> type extends the <c>TAsynParams&lt;TDeletion&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking operations.
  /// </remarks>
  TAsynDeletion = GenAI.API.Deletion.TAsynDeletion;

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
  /// Manages asynchronous callBacks for a request using <c>TSpeechResult</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynSpeechResult</c> type extends the <c>TAsynParams&lt;TSpeechResult&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking operations.
  /// </remarks>
  TAsynSpeechResult = GenAI.Audio.TAsynSpeechResult;

  /// <summary>
  /// Manages asynchronous callBacks for a request using <c>TTranscription</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynTranscription</c> type extends the <c>TAsynParams&lt;TTranscription&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking operations.
  /// </remarks>
  TAsynTranscription = GenAI.Audio.TAsynTranscription;

  /// <summary>
  /// Manages asynchronous callBacks for a request using <c>TTranslation</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynTranslation</c> type extends the <c>TAsynParams&lt;TTranslation&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking operations.
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
  /// Manages asynchronous callBacks a request using <c>TEmbeddings</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynEmbeddings</c> type extends the <c>TAsynParams&lt;TEmbeddings&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking operations.
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
  /// Manages asynchronous callBacks for a request using <c>TModel</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynModel</c> type extends the <c>TAsynParams&lt;TModel&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking operations.
  /// </remarks>
  TAsynModel = GenAI.Models.TAsynModel;

  /// <summary>
  /// Manages asynchronous callBacks for a request using <c>TModels</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynModels</c> type extends the <c>TAsynParams&lt;TModels&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking operations.
  /// </remarks>
  TAsynModels = GenAI.Models.TAsynModels;

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
  /// Approximate location parameters for the search.
  /// </summary>
  TUserLocationApproximate = GenAI.Chat.TUserLocationApproximate;

  /// <summary>
  /// Approximate location parameters for the search.
  /// </summary>
  TUserLocation = GenAI.Chat.TUserLocation;

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
  /// Represents the parameters for updating an existing chat completion.
  /// </summary>
  /// <remarks>
  /// Use this class to configure one or more metadata fields on a chat completion
  /// before sending an update request to the API.
  /// </remarks>
  TChatUpdateParams = GenAI.Chat.TChatUpdateParams;

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
  /// Represents a URL citation within a message, providing details about
  /// the referenced web resource, including its title, URL, and position in the text.
  /// </summary>
  /// <remarks>
  /// This class is used to store metadata about a URL citation found in a chat message.
  /// It includes the start and end indices of the citation within the message text,
  /// the URL itself, and the title of the referenced resource.
  /// </remarks>
  TUrlCitation = GenAI.Chat.TUrlCitation;

  /// <summary>
  /// Represents an annotation within a message, providing additional metadata
  /// related to web citations, such as referenced URLs.
  /// </summary>
  /// <remarks>
  /// This class is used to store information about web citations that appear in a chat message.
  /// It includes the type of annotation (which is always "url_citation") and a reference
  /// to a <c>TUrlCitation</c> instance containing details about the cited web resource.
  /// </remarks>
  TAnnotation = GenAI.Chat.TAnnotation;

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
  TChatMessage = GenAI.Chat.TChatMessage;

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
  /// Manages asynchronous chat callBacks for a request using <c>TChat</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynChat</c> type extends the <c>TAsynParams&lt;TChat&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking operations.
  /// </remarks>
  TAsynChat = GenAI.Chat.TAsynChat;

  /// <summary>
  /// Manages asynchronous streaming callBacks for a request using <c>TChat</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynChatStream</c> type extends the <c>TAsynStreamParams&lt;TChat&gt;</c> record to support the lifecycle of an asynchronous streaming chat operation.
  /// It provides callbacks for different stages, including when the operation starts, progresses with new data chunks, completes successfully, or encounters an error.
  /// This structure is ideal for handling scenarios where the chat response is streamed incrementally, providing real-time updates to the user interface.
  /// </remarks>
  TAsynChatStream = GenAI.Chat.TAsynChatStream;

  /// <summary>
  /// Provides URL parameter helpers for retrieving chat messages by completion ID,
  /// supporting pagination and sort ordering.
  /// </summary>
  TUrlChatParams = GenAI.Chat.TUrlChatParams;

  /// <summary>
  /// Provides URL parameter helpers for listing chat completions,
  /// supporting pagination, metadata filtering, model filtering, and sort ordering.
  /// </summary>
  TUrlChatListParams = GenAI.Chat.TUrlChatListParams;

  /// <summary>
  /// Represents a single message returned in a chat completion response,
  /// including its content, author role, optional audio payload, and any
  /// associated annotations or tool call details.
  /// </summary>
  TChatCompletionMessage = GenAI.Chat.TChatCompletionMessage;

  /// <summary>
  /// Represents a paginated list of chat completion messages, including
  /// navigation cursors and flags for additional pages.
  /// </summary>
  TChatMessages = GenAI.Chat.TChatMessages;

  /// <summary>
  /// Represents a paginated list of chat completion responses returned by the API.
  /// </summary>
  /// <remarks>
  /// Contains an array of <c>TChat</c> objects along with pagination cursors and a flag
  /// indicating whether additional pages are available.
  /// </remarks>
  TChatCompletion = GenAI.Chat.TChatCompletion;

  /// <summary>
  /// Represents the result of a chat completion deletion request.
  /// </summary>
  /// <remarks>
  /// This class is used to deserialize the API response when a chat completion
  /// is deleted. It includes the identifier of the deleted completion, the
  /// object type returned by the service, and a flag indicating whether the
  /// deletion was successful.
  TChatDelete = GenAI.Chat.TChatDelete;

  /// <summary>
  /// Represents an asynchronous callback structure for retrieving chat messages.
  /// </summary>
  /// <remarks>
  /// Use this callback type to handle the lifecycle events (start, success, error, and cancellation)
  /// when fetching <see cref="TChatMessages"/> instances asynchronously.
  /// </remarks>
  TAsynChatMessages = GenAI.Chat.TAsynChatMessages;

  /// <summary>
  /// Represents an asynchronous callback structure for retrieving chat completion results.
  /// </summary>
  /// <remarks>
  /// Use this callback type to handle the lifecycle events (start, success, error, and cancellation)
  /// when fetching <see cref="TChatCompletion"/> instances asynchronously.
  /// </remarks>
  TAsynChatCompletion = GenAI.Chat.TAsynChatCompletion;

  /// <summary>
  /// Represents an asynchronous callback structure for deleting a chat completion.
  /// </summary>
  /// <remarks>
  /// Use this callback type to handle the lifecycle events (start, success, error, and cancellation)
  /// when performing an asynchronous delete operation for a <see cref="TChatDelete"/> instance.
  /// </remarks>
  TAsynChatDelete = GenAI.Chat.TAsynChatDelete;

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
  /// Manages asynchronous callBacks for a request using <c>TCompletion</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynCompletion</c> type extends the <c>TAsynParams&lt;TCompletion&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking chat operations and is specifically tailored for scenarios where multiple choices from a chat model are required.
  /// </remarks>
  TAsynCompletion = GenAI.Completions.TAsynCompletion;

  /// <summary>
  /// Manages asynchronous streaming callBacks for a request using <c>TCompletion</c> as the response type.
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
  /// Manages asynchronous callBacks for a request using <c>TModeration</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynModeration</c> type extends the <c>TAsynParams&lt;TModeration&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking operations.
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
  /// Manages asynchronous callBacks for a request using <c>TGeneratedImages</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynImagesCreate</c> type extends the <c>TAsynParams&lt;TGeneratedImages&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking operations.
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
  /// Manages asynchronous callBacks for a request using <c>TFile</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynFile</c> type extends the <c>TAsynParams&lt;TFile&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking operations.
  /// </remarks>
  TAsynFile = GenAI.Files.TAsynFile;

  /// <summary>
  /// Manages asynchronous callBacks for a request using <c>TFiles</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynFiles</c> type extends the <c>TAsynParams&lt;TFiles&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking operations.
  /// </remarks>
  TAsynFiles = GenAI.Files.TAsynFiles;

  /// <summary>
  /// Manages asynchronous callBacks for a request using <c>TFiles</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynFiles</c> type extends the <c>TAsynParams&lt;TFiles&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking operations.
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
  /// Manages asynchronous callBacks for a request using <c>TUpload</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynUpload</c> type extends the <c>TAsynParams&lt;TUpload&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking operations.
  /// </remarks>
  TAsynUpload = GenAI.Uploads.TAsynUpload;

  /// <summary>
  /// Manages asynchronous callBacks for a request using <c>TUploadPart</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynUploadPart</c> type extends the <c>TAsynParams&lt;TUploadPart&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking operations.
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
  /// Manages asynchronous callBacks for a request using <c>TBatch</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynBatch</c> type extends the <c>TAsynParams&lt;TBatch&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking operations.
  /// </remarks>
  TAsynBatch = GenAI.Batch.TAsynBatch;

  /// <summary>
  /// Manages asynchronous callBacks for a request using <c>TBatches</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynBatches</c> type extends the <c>TAsynParams&lt;TBatches&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking operations.
  /// </remarks>
  TAsynBatches = GenAI.Batch.TAsynBatches;

  {$ENDREGION}

  {$REGION 'GenAI.FineTuning'}

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
  /// Manages asynchronous callBacks for a request using <c>TFineTuningJob</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynFineTuningJob</c> type extends the <c>TAsynParams&lt;TFineTuningJob&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking operations.
  /// </remarks>
  TAsynFineTuningJob = GenAI.FineTuning.TAsynFineTuningJob;

  /// <summary>
  /// Manages asynchronous callBacks for a request using <c>TFineTuningJobs</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynFineTuningJobs</c> type extends the <c>TAsynParams&lt;TFineTuningJobs&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking operations.
  /// </remarks>
  TAsynFineTuningJobs = GenAI.FineTuning.TAsynFineTuningJobs;

  /// <summary>
  /// Manages asynchronous callBacks for a request using <c>TJobEvents</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynJobEvents</c> type extends the <c>TAsynParams&lt;TJobEvents&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking operations.
  /// </remarks>
  TAsynJobEvents = GenAI.FineTuning.TAsynJobEvents;

  /// <summary>
  /// Manages asynchronous callBacks for a request using <c>TJobCheckpoints</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynFineJobCheckpoints</c> type extends the <c>TAsynParams&lt;TJobCheckpoints&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking operations.
  /// </remarks>
  TAsynJobCheckpoints = GenAI.FineTuning.TAsynJobCheckpoints;

  {$ENDREGION}

  {$REGION 'GenAI.Assistants'}

  /// <summary>
  /// Represents the parameters used to configure ranking options in a file search operation.
  /// </summary>
  /// <remarks>
  /// This class provides methods to set the ranker and score threshold, which define
  /// how search results are ranked and filtered. It extends <c>TJSONParam</c> to support
  /// serialization to JSON format.
  /// </remarks>
  TRankingOptionsParams = GenAI.Assistants.TRankingOptionsParams;

  /// <summary>
  /// Represents the parameters used to configure the file search tool in an assistant.
  /// </summary>
  /// <remarks>
  /// This class provides methods to set the maximum number of results and ranking options
  /// for the file search operation. It extends <c>TJSONParam</c> to enable JSON serialization.
  /// </remarks>
  TFileSearchToolParams = GenAI.Assistants.TFileSearchToolParams;

  /// <summary>
  /// Represents the parameters used to define a custom function for an assistant.
  /// </summary>
  /// <remarks>
  /// This class provides methods to set the function's name, description, parameters,
  /// and strict mode. It extends <c>TJSONParam</c> to enable JSON serialization.
  /// </remarks>
  TAssistantsFunctionParams = GenAI.Assistants.TAssistantsFunctionParams;

  /// <summary>
  /// Represents the parameters used to configure tools for an assistant.
  /// </summary>
  /// <remarks>
  /// This class provides methods to define different types of tools, including
  /// file search and custom functions. It extends <c>TJSONParam</c> to support
  /// JSON serialization.
  /// </remarks>
  TAssistantsToolsParams = GenAI.Assistants.TAssistantsToolsParams;

  /// <summary>
  /// Represents the parameters used to configure the code interpreter tool for an assistant.
  /// </summary>
  /// <remarks>
  /// This class provides methods to specify the file IDs that the code interpreter tool
  /// can access. It extends <c>TJSONParam</c> to enable JSON serialization.
  /// </remarks>
  TCodeInterpreterParams = GenAI.Assistants.TCodeInterpreterParams;

  /// <summary>
  /// Represents the parameters used to configure static chunking for file processing.
  /// </summary>
  /// <remarks>
  /// This class provides methods to set the maximum chunk size and overlap between chunks.
  /// It is used to control how large text or data is divided into manageable parts for
  /// processing. The class extends <c>TJSONParam</c> to enable JSON serialization.
  /// </remarks>
  TChunkStaticParams = GenAI.Assistants.TChunkStaticParams;

  /// <summary>
  /// Represents the parameters used to configure the chunking strategy for file processing.
  /// </summary>
  /// <remarks>
  /// This class provides methods to define the type of chunking strategy and configure
  /// specific parameters, such as static chunking options. It extends <c>TJSONParam</c>
  /// to enable JSON serialization.
  /// </remarks>
  TChunkingStrategyParams = GenAI.Assistants.TChunkingStrategyParams;

  /// <summary>
  /// Represents the parameters used to configure vector stores for file search operations.
  /// </summary>
  /// <remarks>
  /// This class provides methods to specify file IDs, chunking strategies, and metadata
  /// associated with vector stores. It extends <c>TJSONParam</c> to enable JSON serialization.
  /// </remarks>
  TVectorStoresParams = GenAI.Assistants.TVectorStoresParams;

  /// <summary>
  /// Represents the parameters used to configure file search operations in an assistant.
  /// </summary>
  /// <remarks>
  /// This class provides methods to specify vector store IDs and configure vector stores
  /// for efficient file searching. It extends <c>TJSONParam</c> to enable JSON serialization.
  /// </remarks>
  TFileSearchParams = GenAI.Assistants.TFileSearchParams;

  /// <summary>
  /// Represents the parameters used to configure tool resources for an assistant.
  /// </summary>
  /// <remarks>
  /// This class provides methods to specify resources for the code interpreter and
  /// file search tools. It extends <c>TJSONParam</c> to enable JSON serialization.
  /// </remarks>
  TToolResourcesParams = GenAI.Assistants.TToolResourcesParams;

  /// <summary>
  /// Represents the parameters used to define a JSON schema for structured responses.
  /// </summary>
  /// <remarks>
  /// This class provides methods to specify the schema name, description, and structure.
  /// It allows strict schema adherence for function calls and output validation.
  /// Extends <c>TJSONParam</c> to enable JSON serialization.
  /// </remarks>
  TJsonSchemaParams = GenAI.Assistants.TJsonSchemaParams;

  /// <summary>
  /// Represents the parameters used to configure the response format for an assistant.
  /// </summary>
  /// <remarks>
  /// This class provides methods to define the type of response format, including JSON
  /// schema and structured outputs. It extends <c>TJSONParam</c> to enable JSON serialization.
  /// </remarks>
  TResponseFormatParams = GenAI.Assistants.TResponseFormatParams;

  /// <summary>
  /// Represents the parameters used to configure an assistant.
  /// </summary>
  /// <remarks>
  /// This class provides methods to specify the assistant's model, name, description,
  /// instructions, tools, and response format. It extends <c>TJSONParam</c> to enable
  /// JSON serialization.
  /// </remarks>
  TAssistantsParams = GenAI.Assistants.TAssistantsParams;

  /// <summary>
  /// Represents the ranking options for a file search operation.
  /// </summary>
  /// <remarks>
  /// This class provides properties to configure the ranking mechanism of a file search,
  /// including the ranker type and score threshold for filtering results.
  /// </remarks>
  TRankingOptions = GenAI.Assistants.TRankingOptions;

  /// <summary>
  /// Represents the file search configuration for an assistant.
  /// </summary>
  /// <remarks>
  /// This class provides properties to define the file search behavior, including the
  /// maximum number of search results and ranking options for filtering results.
  /// </remarks>
  TAssistantsFileSearch = GenAI.Assistants.TAssistantsFileSearch;

  /// <summary>
  /// Represents a custom function definition for an assistant.
  /// </summary>
  /// <remarks>
  /// This class provides properties to define a function's name, description, parameters,
  /// and strict mode. Functions allow the assistant to execute predefined operations.
  /// </remarks>
  TAssistantsFunction = GenAI.Assistants.TAssistantsFunction;

  /// <summary>
  /// Represents a tool configuration for an assistant.
  /// </summary>
  /// <remarks>
  /// This class provides properties to define different types of tools that an assistant
  /// can use, such as file search or custom functions. Each tool configuration includes
  /// specific settings based on its type.
  /// </remarks>
  TAssistantsTools = GenAI.Assistants.TAssistantsTools;

  /// <summary>
  /// Represents the configuration for the code interpreter tool.
  /// </summary>
  /// <remarks>
  /// This class provides properties to specify the files accessible to the code interpreter.
  /// It enables the assistant to process and analyze code-related files.
  /// </remarks>
  TCodeInterpreter = GenAI.Assistants.TCodeInterpreter;

  /// <summary>
  /// Represents the configuration for the file search tool.
  /// </summary>
  /// <remarks>
  /// This class provides properties to specify the vector stores used for file searching.
  /// It enables the assistant to perform efficient and accurate file searches.
  /// </remarks>
  TFileSearch = GenAI.Assistants.TFileSearch;

  /// <summary>
  /// Represents the resources used by the tools configured for an assistant.
  /// </summary>
  /// <remarks>
  /// This class provides properties to define the resources available to tools such as
  /// the code interpreter and file search. These resources ensure that tools can perform
  /// their operations efficiently.
  /// </remarks>
  TToolResources = GenAI.Assistants.TToolResources;

  /// <summary>
  /// Represents an assistant configuration and its associated properties.
  /// </summary>
  /// <remarks>
  /// This class provides properties to define the assistant's settings, including its
  /// name, model, instructions, tools, and metadata. It extends <c>TJSONFingerprint</c>
  /// to support JSON serialization.
  /// </remarks>
  TAssistant = GenAI.Assistants.TAssistant;

  /// <summary>
  /// Represents a list of assistant objects.
  /// </summary>
  /// <remarks>
  /// This type is a specialization of <c>TAdvancedList</c> for handling a collection of
  /// <c>TAssistant</c> objects. It includes pagination metadata and provides access to
  /// multiple assistant configurations in a structured format.
  /// </remarks>
  TAssistants = GenAI.Assistants.TAssistants;

  /// <summary>
  /// Manages asynchronous callBacks for a request using <c>TAssistant</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynAssistant</c> type extends the <c>TAsynParams&lt;TAssistant&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking operations.
  /// </remarks>
  TAsynAssistant = GenAI.Assistants.TAsynAssistant;

  /// <summary>
  /// Manages asynchronous callBacks for a request using <c>TAssistants</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynAssistants</c> type extends the <c>TAsynParams&lt;TAssistants&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking operations.
  /// </remarks>
  TAsynAssistants = GenAI.Assistants.TAsynAssistants;

  {$ENDREGION}

  {$REGION 'GenAI.Messages'}

  /// <summary>
  /// Represents URL parameters used for customizing requests related to assistants in the OpenAI API.
  /// </summary>
  /// <remarks>
  /// This class extends <c>TUrlAdvancedParams</c> to provide additional parameters
  /// that can be added to API calls when interacting with assistant-related threads.
  /// </remarks>
  TAssistantsUrlParams = GenAI.Messages.TAssistantsUrlParams;

  /// <summary>
  /// Represents parameters used for updating messages within a thread in the OpenAI API.
  /// </summary>
  /// <remarks>
  /// This class extends <c>TJSONParam</c> to provide structured key-value pairs
  /// for modifying messages, such as attaching metadata or updating message-specific details.
  /// </remarks>
  TMessagesUpdateParams = GenAI.Messages.TMessagesUpdateParams;

  /// <summary>
  /// Represents details related to incomplete messages within a thread in the OpenAI API.
  /// </summary>
  /// <remarks>
  /// This class contains information on why a message was marked as incomplete,
  /// typically providing a reason for the failure or interruption during processing.
  /// </remarks>
  TIncompleteDetails = GenAI.Messages.TIncompleteDetails;

  /// <summary>
  /// Represents an image file attached to a message within a thread in the OpenAI API.
  /// </summary>
  /// <remarks>
  /// This class is used to reference an image that is included as part of a message.
  /// The image is identified by its file ID and can have an associated detail level.
  /// </remarks>
  TMessagesImageFile = GenAI.Messages.TMessagesImageFile;

  /// <summary>
  /// Represents an external image URL attached to a message within a thread in the OpenAI API.
  /// </summary>
  /// <remarks>
  /// This class is used to reference an image located at an external URL.
  /// The image can have an associated detail level, which determines the resolution or processing cost.
  /// </remarks>
  TMessagesImageUrl = GenAI.Messages.TMessagesImageUrl;

  /// <summary>
  /// Represents a citation within a message that references a specific portion of a file in the OpenAI API.
  /// </summary>
  /// <remarks>
  /// This class is used to provide contextual citations by referencing parts of a file
  /// that the assistant used during message generation or processing.
  /// </remarks>
  TFileCitation = GenAI.Messages.TFileCitation;

  /// <summary>
  /// Represents the file path of a file generated or referenced during message processing in the OpenAI API.
  /// </summary>
  /// <remarks>
  /// This class is used to reference a file by its path or identifier, typically when
  /// files are generated dynamically during tasks like code execution or data processing.
  /// </remarks>
  TFilePath = GenAI.Messages.TFilePath;

  /// <summary>
  /// Represents an annotation within a message, providing contextual references such as file citations or file paths.
  /// </summary>
  /// <remarks>
  /// This class is used to add annotations that point to specific parts of external files,
  /// providing traceable references within the message content.
  /// </remarks>
  TMesssagesAnnotation = GenAI.Messages.TMesssagesAnnotation;

  /// <summary>
  /// Represents the text content of a message within the OpenAI API, including any associated annotations.
  /// </summary>
  /// <remarks>
  /// This class stores the text content of a message along with any annotations that provide
  /// additional context, such as file citations or file paths.
  /// </remarks>
  TMessagesText = GenAI.Messages.TMessagesText;

  /// <summary>
  /// Represents the content of a message in the OpenAI API, including text, images, and refusal reasons.
  /// </summary>
  /// <remarks>
  /// This class stores various types of content that can be part of a message,
  /// such as plain text, image references, or refusal messages indicating that the assistant
  /// declined to respond.
  /// </remarks>
  TMessagesContent = GenAI.Messages.TMessagesContent;

  /// <summary>
  /// Represents a tool associated with an attachment in a message within the OpenAI API.
  /// </summary>
  /// <remarks>
  /// This class specifies the type of tool linked to an attachment, such as a code interpreter
  /// or file search tool, which can be used during message processing.
  /// </remarks>
  TAttachmentTool = GenAI.Messages.TAttachmentTool;

  /// <summary>
  /// Represents an attachment associated with a message in the OpenAI API.
  /// </summary>
  /// <remarks>
  /// This class stores information about a file attached to a message and the tools
  /// that can be used to process or interact with the file.
  /// </remarks>
  TAttachment = GenAI.Messages.TAttachment;

  /// <summary>
  /// Represents a message within a thread in the OpenAI API, including its content, status, metadata, and attachments.
  /// </summary>
  /// <remarks>
  /// This class stores all the details related to a message, such as its creation timestamp,
  /// role, status, and the content it contains (text, images, or other media).
  /// </remarks>
  TMessages = GenAI.Messages.TMessages;

  /// <summary>
  /// Represents a list of messages within a thread in the OpenAI API.
  /// </summary>
  /// <remarks>
  /// This class extends <c>TAdvancedList</c> to provide a collection of <c>TMessages</c> objects,
  /// allowing for easy iteration and manipulation of messages retrieved from the API.
  /// </remarks>
  TMessagesList = GenAI.Messages.TMessagesList;

  /// <summary>
  /// Manages asynchronous callBacks for a request using <c>TMessages</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynMessages</c> type extends the <c>TAsynParams&lt;TMessages&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking operations.
  /// </remarks>
  TAsynMessages = GenAI.Messages.TAsynMessages;

  /// <summary>
  /// Manages asynchronous callBacks for a request using <c>TMessagesList</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynMessagesList</c> type extends the <c>TAsynParams&lt;TMessagesList&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking operations.
  /// </remarks>
  TAsynMessagesList = GenAI.Messages.TAsynMessagesList;

  {$ENDREGION}

  {$REGION 'GenAI.Threads'}

  /// <summary>
  /// Represents parameters for specifying image files in OpenAI threads.
  /// This class is used to define image-related details such as the file ID and image detail level.
  /// </summary>
  TThreadsImageFileParams = GenAI.Threads.TThreadsImageFileParams;

  /// <summary>
  /// Represents parameters for specifying image URLs in OpenAI threads.
  /// This class is used to define URL-related details such as the image URL and its detail level.
  /// </summary>
  TThreadsImageUrlParams = GenAI.Threads.TThreadsImageUrlParams;

  /// <summary>
  /// Represents the parameters used to define the content of messages in OpenAI threads.
  /// This can include text content, image files, or image URLs.
  /// </summary>
  TThreadsContentParams = GenAI.Threads.TThreadsContentParams;

  /// <summary>
  /// Represents attachments that can be included in messages in OpenAI threads.
  /// Attachments can be files with specific tools applied, such as a code interpreter or file search.
  /// </summary>
  TThreadsAttachment = GenAI.Threads.TThreadsAttachment;

  /// <summary>
  /// Represents the parameters used to define a message in OpenAI threads.
  /// A message contains details such as its role, content, attachments, and metadata.
  /// </summary>
  TThreadsMessageParams = GenAI.Threads.TThreadsMessageParams;

  /// <summary>
  /// Represents the parameters for creating a new thread in OpenAI threads.
  /// This includes defining initial messages, tool resources, and metadata.
  /// </summary>
  TThreadsCreateParams = GenAI.Threads.TThreadsCreateParams;

  /// <summary>
  /// Represents the parameters used to modify an existing thread in OpenAI threads.
  /// This includes updating tool resources and metadata.
  /// </summary>
  TThreadsModifyParams = GenAI.Threads.TThreadsModifyParams;

  /// <summary>
  /// Represents a thread object in OpenAI threads.
  /// A thread contains messages, tool resources, metadata, and other properties related to its creation and management.
  /// </summary>
  TThreads = GenAI.Threads.TThreads;

  /// <summary>
  /// Manages asynchronous callBacks for a request using <c>TThreads</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynThreads</c> type extends the <c>TAsynParams&lt;TThreads&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking operations.
  /// </remarks>
  TAsynThreads = GenAI.Threads.TAsynThreads;

  {$ENDREGION}

  {$REGION 'GenAI.Runs'}

  /// <summary>
  /// Represents the URL parameters for API requests related to execution runs on threads.
  /// </summary>
  /// <remarks>
  /// This class is used to customize and configure URL-based parameters for retrieving or managing runs in API requests.
  /// It extends the base functionality of <c>TUrlAdvancedParams</c>, enabling additional customization for OpenAI API endpoints related to execution runs.
  /// </remarks>
  TRunsUrlParams = GenAI.Runs.TRunsUrlParams;

  /// <summary>
  /// Represents the configuration for selecting a tool choice when creating or running an execution run on a thread in the OpenAI API.
  /// </summary>
  /// <remarks>
  /// This class allows specifying the tool type and, optionally, the name of the function to be called during the run.
  /// The tool choice is essential for directing the assistant to use specific tools like functions during an API run execution.
  /// </remarks>
  TRunsToolChoice = GenAI.Runs.TRunsToolChoice;

  /// <summary>
  /// Represents the truncation strategy configuration for a run in the OpenAI API.
  /// </summary>
  /// <remarks>
  /// This class allows specifying how the thread context should be truncated when constructing the prompt for the run.
  /// Different truncation strategies help optimize token usage and focus the context on relevant messages.
  /// </remarks>
  TRunsTruncationStrategy = GenAI.Runs.TRunsTruncationStrategy;

  /// <summary>
  /// Represents the core parameters for creating or modifying a run in the OpenAI API.
  /// </summary>
  /// <remarks>
  /// This class provides methods to configure various settings such as model selection, instructions, token limits, tool usage, and other options that affect the behavior of the run.
  /// </remarks>
  TRunsCoreParams = GenAI.Runs.TRunsCoreParams;

  /// <summary>
  /// Represents the parameters for creating a run in the OpenAI API, extending the core parameters with additional settings.
  /// </summary>
  /// <remarks>
  /// This class extends <c>TRunsCoreParams</c> by adding options for including additional messages at the start of the thread.
  /// It allows fine-tuning the initial context and behavior of the assistant during the run.
  /// </remarks>
  TRunsParams = GenAI.Runs.TRunsParams;

  /// <summary>
  /// Represents the parameters for creating a new thread and running it in the OpenAI API.
  /// </summary>
  /// <remarks>
  /// This class extends <c>TRunsCoreParams</c> and allows configuring both the thread and the tools/resources available to the assistant during the run.
  /// It is used when you need to create a new conversation thread and immediately execute the run.
  /// </remarks>
  TCreateRunsParams = GenAI.Runs.TCreateRunsParams;

  /// <summary>
  /// Represents the parameters for updating an existing run in the OpenAI API.
  /// </summary>
  /// <remarks>
  /// This class allows modifying metadata associated with a run, enabling the attachment of key-value pairs for tracking additional information.
  /// </remarks>
  TRunUpdateParams = GenAI.Runs.TRunUpdateParams;

  /// <summary>
  /// Represents the parameters for submitting tool outputs to a run in the OpenAI API.
  /// </summary>
  /// <remarks>
  /// This class allows specifying the output generated by a tool and associating it with the appropriate tool call within the run.
  /// Tool outputs are required to continue or complete certain runs that depend on external computations.
  /// </remarks>
  TToolOutputParam = GenAI.Runs.TToolOutputParam;

  /// <summary>
  /// Represents the parameters for submitting tool outputs to a run in the OpenAI API.
  /// </summary>
  /// <remarks>
  /// This class is used when a run requires external tool outputs to continue.
  /// It allows specifying the outputs from the tools and submitting them in a structured manner.
  /// </remarks>
  TSubmitToolParams = GenAI.Runs.TSubmitToolParams;

  /// <summary>
  /// Represents the tool output submissions required to continue a run in the OpenAI API.
  /// </summary>
  /// <remarks>
  /// This class holds the collection of tool call outputs that are needed to satisfy the required action of a run.
  /// Each tool call output contains the necessary details to be processed by the run.
  /// </remarks>
  TSubmitToolOutputs = GenAI.Runs.TSubmitToolOutputs;

  /// <summary>
  /// Represents details about an action required to continue an execution run in the OpenAI API.
  /// </summary>
  /// <remarks>
  /// When a run is paused and requires input or tool output to proceed, this class provides information on the specific action needed.
  /// </remarks>
  TRequiredAction = GenAI.Runs.TRequiredAction;

  /// <summary>
  /// Represents details about the last error encountered during an execution run in the OpenAI API.
  /// </summary>
  /// <remarks>
  /// This class provides information about the error, including its code and a descriptive message.
  /// </remarks>
  TLastError = GenAI.Runs.TLastError;

  /// <summary>
  /// Represents details about why an execution run is incomplete in the OpenAI API.
  /// </summary>
  /// <remarks>
  /// This class provides the reason explaining why the run did not complete successfully, such as token limits or other restrictions.
  /// </remarks>
  TIncompleteDetailsReason = GenAI.Runs.TIncompleteDetailsReason;

  /// <summary>
  /// Represents token usage statistics for an execution run in the OpenAI API.
  /// </summary>
  /// <remarks>
  /// This class tracks the number of tokens used during the run, including prompt tokens, completion tokens, and the total token count.
  /// </remarks>
  TRunUsage = GenAI.Runs.TRunUsage;

  /// <summary>
  /// Represents the truncation strategy used to manage the context window for an execution run in the OpenAI API.
  /// </summary>
  /// <remarks>
  /// This class allows control over how much of the thread's context is included in the prompt, which helps optimize token usage.
  /// </remarks>
  TTruncationStrategy = GenAI.Runs.TTruncationStrategy;

  /// <summary>
  /// Represents an execution run on a thread in the OpenAI API.
  /// </summary>
  /// <remarks>
  /// This class contains information about the run, such as its status, associated assistant, model, instructions, token usage, and any errors encountered.
  /// </remarks>
  TRun = GenAI.Runs.TRun;

  /// <summary>
  /// Represents a list of execution runs on a thread in the OpenAI API.
  /// </summary>
  /// <remarks>
  /// This class is a collection of <c>TRun</c> objects, providing access to multiple execution runs associated with a specific thread.
  /// It can be used to iterate through and retrieve information about each run.
  /// </remarks>
  TRuns = GenAI.Runs.TRuns;

  /// <summary>
  /// Manages asynchronous callBacks for a request using <c>TRun</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynRun</c> type extends the <c>TAsynParams&lt;TRun&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking operations.
  /// </remarks>
  TAsynRun = GenAI.Runs.TAsynRun;

  /// <summary>
  /// Manages asynchronous callBacks for a request using <c>TRuns</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynRuns</c> type extends the <c>TAsynParams&lt;TRuns&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking operations.
  /// </remarks>
  TAsynRuns = GenAI.Runs.TAsynRuns;

  {$ENDREGION}

  {$REGION 'GenAI.RunSteps'}

  /// <summary>
  /// Represents URL parameters for retrieving specific run step details in the OpenAI API.
  /// </summary>
  /// <remarks>
  /// This class is used to customize URL parameters when making requests to retrieve details about
  /// specific steps within an execution run. It enables including additional fields in the API response.
  /// </remarks>
  TRetrieveStepUrlParam = GenAI.RunSteps.TRetrieveStepUrlParam;

  /// <summary>
  /// Represents URL parameters for listing or retrieving multiple run steps in the OpenAI API.
  /// </summary>
  /// <remarks>
  /// This class is used to customize URL parameters when making requests to list or retrieve details
  /// about multiple steps within an execution run. It allows for including additional data in the API response.
  /// </remarks>
  TRunStepUrlParam = GenAI.RunSteps.TRunStepUrlParam;

  /// <summary>
  /// Represents details about the message creation step within an execution run in the OpenAI API.
  /// </summary>
  /// <remarks>
  /// This class provides information related to a message created during a run step, such as
  /// the unique identifier of the created message.
  /// </remarks>
  TRunStepMessageCreation = GenAI.RunSteps.TRunStepMessageCreation;

  /// <summary>
  /// Represents details of an image output generated during a code interpreter run step in the OpenAI API.
  /// </summary>
  /// <remarks>
  /// This class provides information about an image output, including the unique file identifier.
  /// </remarks>
  TOutputImage = GenAI.RunSteps.TOutputImage;

  /// <summary>
  /// Represents the output generated by the code interpreter during a run step in the OpenAI API.
  /// </summary>
  /// <remarks>
  /// This class contains details about the output from the code interpreter, which can include logs
  /// and image outputs.
  /// </remarks>
  TCodeInterpreterOutput = GenAI.RunSteps.TCodeInterpreterOutput;

  /// <summary>
  /// Represents the details of a code interpreter step within an execution run in the OpenAI API.
  /// </summary>
  /// <remarks>
  /// This class contains information about the input provided to the code interpreter and the outputs
  /// it generated, such as logs or images.
  /// </remarks>
  TRunStepCodeInterpreter = GenAI.RunSteps.TRunStepCodeInterpreter;

  /// <summary>
  /// Represents the content of a search result within a file search tool call during an execution run in the OpenAI API.
  /// </summary>
  /// <remarks>
  /// This class contains details about the content type and the corresponding text found during the file search.
  /// </remarks>
  TResultContent = GenAI.RunSteps.TResultContent;

  /// <summary>
  /// Represents a result from a file search tool call within an execution run in the OpenAI API.
  /// </summary>
  /// <remarks>
  /// This class contains information about a file search result, including the file details, score, and
  /// the content found within the file.
  /// </remarks>
  TRunFileSearchResult = GenAI.RunSteps.TRunFileSearchResult;

  /// <summary>
  /// Represents details of a file search tool call within an execution run in the OpenAI API.
  /// </summary>
  /// <remarks>
  /// This class contains information about the file search operation, including the ranking options used
  /// and the results retrieved from the search.
  /// </remarks>
  TRunStepFileSearch = GenAI.RunSteps.TRunStepFileSearch;

  /// <summary>
  /// Represents details of a function tool call within an execution run in the OpenAI API.
  /// </summary>
  /// <remarks>
  /// This class contains information about a function tool call, including the function name,
  /// arguments passed, and the output generated.
  /// </remarks>
  TRunStepFunction = GenAI.RunSteps.TRunStepFunction;

  /// <summary>
  /// Represents details of tool calls made during a specific run step in the OpenAI API.
  /// </summary>
  /// <remarks>
  /// This class provides information about various tool calls, such as code interpreter executions,
  /// file searches, or function invocations.
  /// </remarks>
  TRunStepToolCalls = GenAI.RunSteps.TRunStepToolCalls;

  /// <summary>
  /// Represents the detailed information of a run step within an execution run in the OpenAI API.
  /// </summary>
  /// <remarks>
  /// This class provides details about the type of run step and any associated tool calls
  /// or message creation activities.
  /// </remarks>
  TRunStepDetails = GenAI.RunSteps.TRunStepDetails;

  /// <summary>
  /// Represents a specific step within an execution run in the OpenAI API.
  /// </summary>
  /// <remarks>
  /// This class contains details about the run step, such as its type, status, associated assistant,
  /// and any outputs or errors generated during the step.
  /// </remarks>
  TRunStep = GenAI.RunSteps.TRunStep;

  /// <summary>
  /// Represents a collection of run steps within an execution run in the OpenAI API.
  /// </summary>
  /// <remarks>
  /// This class is a list of <c>TRunStep</c> objects, providing access to multiple steps within a run.
  /// It allows for iteration over the run steps to retrieve their details, such as outputs, statuses, or errors.
  /// </remarks>
  TRunSteps = GenAI.RunSteps.TRunSteps;

  /// <summary>
  /// Manages asynchronous callBacks for a request using <c>TRunStep</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynRunStep</c> type extends the <c>TAsynParams&lt;TRunStep&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking operations.
  /// </remarks>
  TAsynRunStep = GenAI.RunSteps.TAsynRunStep;

  /// <summary>
  /// Manages asynchronous callBacks for a request using <c>TRunSteps</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynRunSteps</c> type extends the <c>TAsynParams&lt;TRunSteps&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking operations.
  /// </remarks>
  TAsynRunSteps = GenAI.RunSteps.TAsynRunSteps;

  {$ENDREGION}

  {$REGION 'GenAI.Vector'}

  /// <summary>
  /// Represents URL parameters for configuring requests to manage vector stores in the OpenAI API.
  /// </summary>
  /// <remarks>
  /// The <c>TVectorStoreUrlParam</c> class is designed to facilitate customization of query parameters
  /// when interacting with the vector stores API, such as listing or filtering vector stores.
  /// It extends the base <c>TUrlAdvancedParams</c> class, inheriting functionality for parameter management.
  /// </remarks>
  TVectorStoreUrlParam = GenAI.Vector.TVectorStoreUrlParam;

  /// <summary>
  /// Represents parameters for specifying the expiration policy of a vector store in the OpenAI API.
  /// </summary>
  /// <remarks>
  /// The <c>TExpiresAfterParams</c> class is used to configure when a vector store should expire
  /// based on a specified anchor timestamp and the number of days after the anchor.
  /// This helps in automatically managing the lifecycle of vector stores.
  /// </remarks>
  TExpiresAfterParams = GenAI.Vector.TExpiresAfterParams;

  /// <summary>
  /// Represents the parameters required to create a new vector store in the OpenAI API.
  /// </summary>
  /// <remarks>
  /// The <c>TVectorStoreCreateParams</c> class provides methods for setting parameters such as file IDs,
  /// expiration policies, chunking strategies, and metadata. These parameters are used when making
  /// API requests to create a vector store that can be utilized by tools like file search.
  /// </remarks>
  TVectorStoreCreateParams = GenAI.Vector.TVectorStoreCreateParams;

  /// <summary>
  /// Represents the parameters required to update an existing vector store in the OpenAI API.
  /// </summary>
  /// <remarks>
  /// The <c>TVectorStoreUpdateParams</c> class provides methods for updating properties such as
  /// the vector store name, expiration policy, and metadata. These parameters are used when making
  /// API requests to modify an existing vector store.
  /// </remarks>
  TVectorStoreUpdateParams = GenAI.Vector.TVectorStoreUpdateParams;

  /// <summary>
  /// Represents the counts of files in various processing states within a vector store in the OpenAI API.
  /// </summary>
  /// <remarks>
  /// The <c>TVectorFileCounts</c> class provides detailed counts of files associated with a vector store,
  /// including files that are being processed, successfully completed, failed, or canceled.
  /// This helps monitor the status and progress of file processing in a vector store.
  /// </remarks>
  TVectorFileCounts = GenAI.Vector.TVectorFileCounts;

  /// <summary>
  /// Represents the expiration policy for a vector store in the OpenAI API.
  /// </summary>
  /// <remarks>
  /// The <c>TExpiresAfter</c> class defines when a vector store will expire based on an anchor timestamp
  /// and the number of days after the anchor. This class is useful for managing the automatic cleanup
  /// or deactivation of vector stores.
  /// </remarks>
  TExpiresAfter = GenAI.Vector.TExpiresAfter;

  /// <summary>
  /// Represents a vector store in the OpenAI API.
  /// </summary>
  /// <remarks>
  /// The <c>TVectorStore</c> class encapsulates the properties and status of a vector store,
  /// including its name, creation timestamp, expiration settings, file usage, and metadata.
  /// A vector store is used to store and retrieve processed files for use by tools such as file search.
  /// </remarks>
  TVectorStore = GenAI.Vector.TVectorStore;

  /// <summary>
  /// Represents a collection of vector stores in the OpenAI API.
  /// </summary>
  /// <remarks>
  /// The <c>TVectorStores</c> class is a list of <c>TVectorStore</c> objects, providing access to multiple
  /// vector stores. It allows iteration over the vector stores to retrieve details such as their status,
  /// usage, expiration policies, and metadata.
  /// </remarks>
  TVectorStores = GenAI.Vector.TVectorStores;

  /// <summary>
  /// Manages asynchronous callBacks for a request using <c>TVectorStore</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynVectorStore</c> type extends the <c>TAsynParams&lt;TVectorStore&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking operations.
  /// </remarks>
  TAsynVectorStore = GenAI.Vector.TAsynVectorStore;

  /// <summary>
  /// Manages asynchronous callBacks for a request using <c>TVectorStores</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynVectorStores</c> type extends the <c>TAsynParams&lt;TVectorStores&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking operations.
  /// </remarks>
  TAsynVectorStores = GenAI.Vector.TAsynVectorStores;

  {$ENDREGION}

  {$REGION 'GenAI.VectorFiles'}

  /// <summary>
  /// Represents URL parameters for configuring requests related to vector store files in the OpenAI API.
  /// </summary>
  /// <remarks>
  /// The <c>TVectorStoreFilesUrlParams</c> class allows users to customize the URL query parameters
  /// when listing or filtering files associated with a specific vector store.
  /// This is useful when retrieving files with particular statuses or conditions.
  /// </remarks>
  TVectorStoreFilesUrlParams = GenAI.VectorFiles.TVectorStoreFilesUrlParams;

  /// <summary>
  /// Represents parameters for creating vector store files in the OpenAI API.
  /// </summary>
  /// <remarks>
  /// The <c>TVectorStoreFilesCreateParams</c> class allows users to specify key parameters such as
  /// the file ID and chunking strategy when adding a file to a vector store. These parameters
  /// determine how the file will be chunked and indexed within the vector store.
  /// </remarks>
  TVectorStoreFilesCreateParams = GenAI.VectorFiles.TVectorStoreFilesCreateParams;

  /// <summary>
  /// Represents the static chunking strategy settings for dividing files into chunks in the OpenAI API.
  /// </summary>
  /// <remarks>
  /// The <c>TChunkingStrategyStatic</c> class defines the static configuration for chunking a file
  /// into smaller, overlapping segments. This strategy is used when users want precise control over
  /// the size and overlap of the chunks.
  /// </remarks>
  TChunkingStrategyStatic = GenAI.VectorFiles.TChunkingStrategyStatic;

  /// <summary>
  /// Represents the chunking strategy configuration used for splitting files into chunks in the OpenAI API.
  /// </summary>
  /// <remarks>
  /// The <c>TChunkingStrategy</c> class defines how files are divided into chunks for indexing in a vector store.
  /// It supports both static and dynamic chunking strategies, depending on the configuration.
  /// </remarks>
  TChunkingStrategy = GenAI.VectorFiles.TChunkingStrategy;

  /// <summary>
  /// Represents a file attached to a vector store in the OpenAI API.
  /// </summary>
  /// <remarks>
  /// The <c>TVectorStoreFile</c> class encapsulates details about a file added to a vector store,
  /// including its ID, usage, creation timestamp, status, and chunking strategy. This information
  /// is used to monitor file processing and storage within the vector store.
  /// </remarks>
  TVectorStoreFile = GenAI.VectorFiles.TVectorStoreFile;

  /// <summary>
  /// Represents a list of files attached to a vector store in the OpenAI API.
  /// </summary>
  /// <remarks>
  /// The <c>TVectorStoreFiles</c> class is a collection of <c>TVectorStoreFile</c> objects,
  /// providing access to details about multiple files within a vector store. It supports
  /// iteration, allowing users to retrieve information about each file, such as its status,
  /// usage, and chunking strategy.
  /// </remarks>
  TVectorStoreFiles = GenAI.VectorFiles.TVectorStoreFiles;

  /// <summary>
  /// Manages asynchronous callBacks for a request using <c>TVectorStoreFile</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynVectorStoreFile</c> type extends the <c>TAsynParams&lt;TVectorStoreFile&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking operations.
  /// </remarks>
  TAsynVectorStoreFile = GenAI.VectorFiles.TAsynVectorStoreFile;

  /// <summary>
  /// Manages asynchronous callBacks for a request using <c>TVectorStoreFiles</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynVectorStoreFiles</c> type extends the <c>TAsynParams&lt;TVectorStoreFiles&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking operations.
  /// </remarks>
  TAsynVectorStoreFiles = GenAI.VectorFiles.TAsynVectorStoreFiles;

  {$ENDREGION}

  {$REGION 'GenAI.VectorBatch'}

  /// <summary>
  /// Represents URL parameters for configuring requests related to file batches in a vector store using the OpenAI API.
  /// </summary>
  /// <remarks>
  /// This class extends <c>TVectorStoreFilesUrlParams</c> and provides the ability to customize the URL query parameters
  /// when listing or filtering batches of files associated with a specific vector store.
  /// It is useful for narrowing down results or retrieving batches with particular statuses.
  /// </remarks>
  TVectorStoreBatchUrlParams = GenAI.VectorBatch.TVectorStoreBatchUrlParams;

  /// <summary>
  /// Represents the parameters for creating file batches in a vector store using the OpenAI API.
  /// </summary>
  /// <remarks>
  /// This class extends <c>TVectorStoreFilesCreateParams</c> and allows users to define key parameters
  /// when creating a new batch of files in a vector store, including the file IDs and chunking strategy.
  /// These settings control how files are processed and chunked before being stored.
  /// </remarks>
  TVectorStoreBatchCreateParams = GenAI.VectorBatch.TVectorStoreBatchCreateParams;

  /// <summary>
  /// Represents a batch of files attached to a vector store in the OpenAI API.
  /// </summary>
  /// <remarks>
  /// This class provides details about a file batch within a vector store, including its creation timestamp,
  /// status, and the number of files processed. It is used to monitor and manage the batch processing of files
  /// for indexing and retrieval in the vector store.
  /// </remarks>
  TVectorStoreBatch = GenAI.VectorBatch.TVectorStoreBatch;

  /// <summary>
  /// Represents a list of file batches attached to a vector store in the OpenAI API.
  /// </summary>
  /// <remarks>
  /// This class extends <c>TAdvancedList&lt;TVectorStoreBatch&gt;</c> and provides an iterable
  /// collection of file batches within a vector store. Each batch contains information such as
  /// its status, creation timestamp, and file counts.
  /// </remarks>
  TVectorStoreBatches = GenAI.VectorBatch.TVectorStoreBatches;

  /// <summary>
  /// Manages asynchronous callBacks for a request using <c>TVectorStoreBatch</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynVectorStoreBatch</c> type extends the <c>TAsynParams&lt;TVectorStoreBatch&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking operations.
  /// </remarks>
  TAsynVectorStoreBatch = GenAI.VectorBatch.TAsynVectorStoreBatch;

  /// <summary>
  /// Manages asynchronous callBacks for a request using <c>TVectorStoreBatches</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynVectorStoreBatches</c> type extends the <c>TAsynParams&lt;TVectorStoreBatches&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking operations.
  /// </remarks>
  TAsynVectorStoreBatches = GenAI.VectorBatch.TAsynVectorStoreBatches;

  {$ENDREGION}

  {$REGION 'GenAI.Chat.Parallel'}

  /// <summary>
  /// Represents an item in a bundle of chat prompts and responses.
  /// </summary>
  /// <remarks>
  /// This class stores information about a single chat request, including its index,
  /// associated prompt, generated response, and related chat object.
  /// It is used within a <c>TBundleList</c> to manage multiple asynchronous chat requests.
  /// </remarks>
  TBundleItem = GenAI.Chat.Parallel.TBundleItem;

  /// <summary>
  /// Manages a collection of <c>TBundleItem</c> objects.
  /// </summary>
  /// <remarks>
  /// This class provides methods to add, retrieve, and count items in a bundle.
  /// It is designed to store multiple chat request items processed in parallel.
  /// The internal storage uses a <c>TObjectList&lt;TBundleItem&gt;</c> with automatic memory management.
  /// </remarks>
  TBundleList = GenAI.Chat.Parallel.TBundleList;

  /// <summary>
  /// Represents an asynchronous callback buffer for handling chat responses.
  /// </summary>
  /// <remarks>
  /// This class is a specialized type used to manage asynchronous operations
  /// related to chat request processing. It inherits from <c>TAsynCallBack&lt;TBundleList&gt;</c>,
  /// enabling structured handling of callback events.
  /// </remarks>
  TAsynBundleList = GenAI.Chat.Parallel.TAsynBundleList;
  TAsynBuffer = TAsynBundleList; //deprecated : naming error

  /// <summary>
  /// Represents an asynchronous callback buffer for handling parallele chat responses for promise chaining
  /// </summary>
  /// <remarks>
  /// This class is a specialized type used to manage asynchronous operations
  /// related to chat request processing. It inherits from <c>TAsynCallBack&lt;TBundleList&gt;</c>,
  /// enabling structured handling of callback events.
  /// </remarks>
  TPromiseBundleList = GenAI.Chat.Parallel.TPromiseBundleList;

  /// <summary>
  /// Represents the parameters used for configuring a chat request bundle.
  /// </summary>
  /// <remarks>
  /// This class extends <c>TParameters</c> and provides specific methods for setting chat-related
  /// parameters, such as prompts, model selection, and reasoning effort.
  /// It is used to structure and pass multiple requests efficiently in parallel processing.
  /// </remarks>
  TBundleParams = GenAI.Chat.Parallel.TBundleParams;

  {$ENDREGION}

  {$REGION 'GenAI.Responses.InputParams'}

  TItemContent = GenAI.Responses.InputParams.TItemContent;

  TInputListItem = GenAI.Responses.InputParams.TInputListItem;

  TInputMessage = GenAI.Responses.InputParams.TInputMessage;

  TItemInputMessage = GenAI.Responses.InputParams.TItemInputMessage;

  TInputItemReference = GenAI.Responses.InputParams.TInputItemReference;

  TOutputNotation = GenAI.Responses.InputParams.TOutputNotation;

  TOutputMessageContent = GenAI.Responses.InputParams.TOutputMessageContent;

  TItemOutputMessage = GenAI.Responses.InputParams.TItemOutputMessage;

  TFileSearchToolCallResult = GenAI.Responses.InputParams.TFileSearchToolCallResult;

  TFileSearchToolCall = GenAI.Responses.InputParams.TFileSearchToolCall;

  TPendingSafetyCheck = GenAI.Responses.InputParams.TPendingSafetyCheck;

  TAcknowledgedSafetyCheckParams = GenAI.Responses.InputParams.TAcknowledgedSafetyCheckParams;

  TComputerToolCallOutputObject = GenAI.Responses.InputParams.TComputerToolCallOutputObject;

  TComputerToolCallAction = GenAI.Responses.InputParams.TComputerToolCallAction;

  TComputerClick = GenAI.Responses.InputParams.TComputerClick;

  TComputerDoubleClick = GenAI.Responses.InputParams.TComputerDoubleClick;

  TComputerDragPoint = GenAI.Responses.InputParams.TComputerDragPoint;

  TComputerDrag = GenAI.Responses.InputParams.TComputerDrag;

  TComputerKeyPressed = GenAI.Responses.InputParams.TComputerKeyPressed;

  TComputerMove = GenAI.Responses.InputParams.TComputerMove;

  TComputerScreenshot = GenAI.Responses.InputParams.TComputerScreenshot;

  TComputerScroll = GenAI.Responses.InputParams.TComputerScroll;

  TComputerType = GenAI.Responses.InputParams.TComputerType;

  TComputerWait = GenAI.Responses.InputParams.TComputerWait;

  TComputerToolCallOutput = GenAI.Responses.InputParams.TComputerToolCallOutput;

  TWebSearchToolCall = GenAI.Responses.InputParams.TWebSearchToolCall;

  TFunctionToolCall = GenAI.Responses.InputParams.TFunctionToolCall;

  TFunctionToolCalloutput = GenAI.Responses.InputParams.TFunctionToolCalloutput;

  TReasoningTextContent = GenAI.Responses.InputParams.TReasoningTextContent;

  TReasoningObject = GenAI.Responses.InputParams.TReasoningObject;

  TComputerToolCall = GenAI.Responses.InputParams.TComputerToolCall;

  TImageGeneration = GenAI.Responses.InputParams.TImageGeneration;

  TCodeInterpreterToolCallResult = GenAI.Responses.InputParams.TCodeInterpreterToolCallResult;

  TCodeInterpreterTextOutput = GenAI.Responses.InputParams.TCodeInterpreterTextOutput;

  TCodeInterpreterFile = GenAI.Responses.InputParams.TCodeInterpreterFile;

  TCodeInterpreterFileOutput = GenAI.Responses.InputParams.TCodeInterpreterFileOutput;

  TCodeInterpreterToolCall = GenAI.Responses.InputParams.TCodeInterpreterToolCall;

  TLocalShellCallAction = GenAI.Responses.InputParams.TLocalShellCallAction;

  TLocalShellCall = GenAI.Responses.InputParams.TLocalShellCall;

  TLocalShellCallOutput = GenAI.Responses.InputParams.TLocalShellCallOutput;

  TMCPTools = GenAI.Responses.InputParams.TMCPTools;

  TMCPListTools = GenAI.Responses.InputParams.TMCPListTools;

  TMCPApprovalRequest = GenAI.Responses.InputParams.TMCPApprovalRequest;

  TMCPApprovalResponse = GenAI.Responses.InputParams.TMCPApprovalResponse;

  TMCPToolCall = GenAI.Responses.InputParams.TMCPToolCall;

  TReasoningParams = GenAI.Responses.InputParams.TReasoningParams;

  TTextFormatParams = GenAI.Responses.InputParams.TTextFormatParams;

  TTextFormatTextPrams = GenAI.Responses.InputParams.TTextFormatTextPrams;

  TTextJSONSchemaParams = GenAI.Responses.InputParams.TTextJSONSchemaParams;

  TTextJSONObjectParams = GenAI.Responses.InputParams.TTextJSONObjectParams;

  TTextParams = GenAI.Responses.InputParams.TTextParams;

  TResponseToolChoiceParams = GenAI.Responses.InputParams.TResponseToolChoiceParams;

  THostedToolParams = GenAI.Responses.InputParams.THostedToolParams;

  TFunctionToolParams = GenAI.Responses.InputParams.TFunctionToolParams;

  TFileSearchFilters = GenAI.Responses.InputParams.TFileSearchFilters;

  TComparisonFilter = GenAI.Responses.InputParams.TComparisonFilter;

  TCompoundFilter = GenAI.Responses.InputParams.TCompoundFilter;

  TResponseToolParams = GenAI.Responses.InputParams.TResponseToolParams;

  TResponseFileSearchParams = GenAI.Responses.InputParams.TResponseFileSearchParams;

  TResponseFunctionParams = GenAI.Responses.InputParams.TResponseFunctionParams;

  TResponseComputerUseParams = GenAI.Responses.InputParams.TResponseComputerUseParams;

  TResponseUserLocationParams = GenAI.Responses.InputParams.TResponseUserLocationParams;

  TResponseWebSearchParams = GenAI.Responses.InputParams.TResponseWebSearchParams;

  TMCPToolsListParams = GenAI.Responses.InputParams.TMCPToolsListParams;

  TMCPAllowedToolsParams = GenAI.Responses.InputParams.TMCPAllowedToolsParams;

  TMCPRequireApprovalParams = GenAI.Responses.InputParams.TMCPRequireApprovalParams;

  TResponseMCPToolParams = GenAI.Responses.InputParams.TResponseMCPToolParams;

  TCodeInterpreterContainerAutoParams = GenAI.Responses.InputParams.TCodeInterpreterContainerAutoParams;

  TResponseCodeInterpreterParams = GenAI.Responses.InputParams.TResponseCodeInterpreterParams;

  TLocalShellToolParams = GenAI.Responses.InputParams.TLocalShellToolParams;

  TResponsesParams = GenAI.Responses.InputParams.TResponsesParams;

  TInputImageMaskParams = GenAI.Responses.InputParams.TInputImageMaskParams;

  TResponseImageGenerationParams = GenAI.Responses.InputParams.TResponseImageGenerationParams;

  {$ENDREGION}

  {$REGION 'GenAI.Responses.InputItemList'}

  TCodeInterpreterResultFiles = GenAI.Responses.InputItemList.TCodeInterpreterResultFiles;

  TCodeInterpreterResult = GenAI.Responses.InputItemList.TCodeInterpreterResult;

  TFileSearchResult = GenAI.Responses.InputItemList.TFileSearchResult;

  TDragPoint = GenAI.Responses.InputItemList.TDragPoint;

  TPendingSafetyChecks = GenAI.Responses.InputItemList.TPendingSafetyChecks;

  TComputerOutput = GenAI.Responses.InputItemList.TComputerOutput;

  TAcknowledgedSafetyCheck = GenAI.Responses.InputItemList.TAcknowledgedSafetyCheck;

  TComputerActionCommon = GenAI.Responses.InputItemList.TComputerActionCommon;

  TComputerActionClick = GenAI.Responses.InputItemList.TComputerActionClick;

  TComputerActionDoubleClick = GenAI.Responses.InputItemList.TComputerActionDoubleClick;

  TComputerActionDrag = GenAI.Responses.InputItemList.TComputerActionDrag;

  TComputerActionKeyPressed = GenAI.Responses.InputItemList.TComputerActionKeyPressed;

  TComputerActionMove = GenAI.Responses.InputItemList.TComputerActionMove;

  TComputerActionScreenshot = GenAI.Responses.InputItemList.TComputerActionScreenshot;

  TComputerActionScroll = GenAI.Responses.InputItemList.TComputerActionScroll;

  TComputerActionType = GenAI.Responses.InputItemList.TComputerActionType;

  TComputerActionWait = GenAI.Responses.InputItemList.TComputerActionWait;

  TToolCallAction = GenAI.Responses.InputItemList.TToolCallAction;

  TComputerAction = GenAI.Responses.InputItemList.TComputerAction;

  TResponseMessageAnnotationCommon = GenAI.Responses.InputItemList.TResponseMessageAnnotationCommon;

  TAnnotationFileCitation = GenAI.Responses.InputItemList.TAnnotationFileCitation;

  TAnnotationUrlCitation = GenAI.Responses.InputItemList.TAnnotationUrlCitation;

  TAnnotationFilePath = GenAI.Responses.InputItemList.TAnnotationFilePath;

  TResponseMessageAnnotation = GenAI.Responses.InputItemList.TResponseMessageAnnotation;

  TResponseItemContentCommon = GenAI.Responses.InputItemList.TResponseItemContentCommon;

  TResponseItemContentTextInput = GenAI.Responses.InputItemList.TResponseItemContentTextInput;

  TResponseItemContentImageInput = GenAI.Responses.InputItemList.TResponseItemContentImageInput;

  TResponseItemContentFileInput = GenAI.Responses.InputItemList.TResponseItemContentFileInput;

  TResponseItemContentOutputText = GenAI.Responses.InputItemList.TResponseItemContentOutputText;

  TResponseItemContentRefusal = GenAI.Responses.InputItemList.TResponseItemContentRefusal;

  TResponseItemContent = GenAI.Responses.InputItemList.TResponseItemContent;

  TResponseItemCommon = GenAI.Responses.InputItemList.TResponseItemCommon;

  TResponseItemInputMessage = GenAI.Responses.InputItemList.TResponseItemInputMessage;

  TResponseItemOutputMessage = GenAI.Responses.InputItemList.TResponseItemOutputMessage;

  TResponseItemFileSearchToolCall = GenAI.Responses.InputItemList.TResponseItemFileSearchToolCall;

  TResponseItemComputerToolCall = GenAI.Responses.InputItemList.TResponseItemComputerToolCall;

  TResponseItemComputerToolCallOutput = GenAI.Responses.InputItemList.TResponseItemComputerToolCallOutput;

  TResponseItemWebSearchToolCall = GenAI.Responses.InputItemList.TResponseItemWebSearchToolCall;

  TResponseItemFunctionToolCall = GenAI.Responses.InputItemList.TResponseItemFunctionToolCall;

  TResponseItemFunctionToolCallOutput = GenAI.Responses.InputItemList.TResponseItemFunctionToolCallOutput;

  TResponseItemImageGeneration = GenAI.Responses.InputItemList.TResponseItemImageGeneration;

  TResponseItemCodeInterpreter = GenAI.Responses.InputItemList.TResponseItemCodeInterpreter;

  TResponseItemLocalShell = GenAI.Responses.InputItemList.TResponseItemLocalShell;

  TResponseItemMCPTool = GenAI.Responses.InputItemList.TResponseItemMCPTool;

  TResponseItemMCPList = GenAI.Responses.InputItemList.TResponseItemMCPList;

  TResponseItemMCPApproval = GenAI.Responses.InputItemList.TResponseItemMCPApproval;

  TResponseItem = GenAI.Responses.InputItemList.TResponseItem;

  TResponses = GenAI.Responses.InputItemList.TResponses;

  {$ENDREGION}

  {$REGION 'GenAI.Responses.Internal'}

  TPromiseResponse = GenAI.Responses.Internal.TPromiseResponse;

  TPromiseResponseStream = GenAI.Responses.Internal.TPromiseResponseStream;

  TPromiseResponseDelete = GenAI.Responses.Internal.TPromiseResponseDelete;

  TPromiseResponses = GenAI.Responses.Internal.TPromiseResponses;

  TResponseEvent = GenAI.Responses.Internal.TResponseEvent;

  TAsynResponse = GenAI.Responses.Internal.TAsynResponse;

  TAsynResponseStream = GenAI.Responses.Internal.TAsynResponseStream;

  TAsynResponseDelete = GenAI.Responses.Internal.TAsynResponseDelete;

  TAsynResponses = GenAI.Responses.Internal.TAsynResponses;

  {$ENDREGION}

  {$REGION 'GenAI.Responses.OutputParams'}

  TResponseError = GenAI.Responses.OutputParams.TResponseError;

  TResponseIncompleteDetails = GenAI.Responses.OutputParams.TResponseIncompleteDetails;

  TResponseMessageContentCommon = GenAI.Responses.OutputParams.TResponseMessageContentCommon;

  TResponseMessageContent = GenAI.Responses.OutputParams.TResponseMessageContent;

  TResponseMessageRefusal = GenAI.Responses.OutputParams.TResponseMessageRefusal;

  TResponseContent = GenAI.Responses.OutputParams.TResponseContent;

  TResponseReasoningSummary = GenAI.Responses.OutputParams.TResponseReasoningSummary;

  TResponseReasoning = GenAI.Responses.OutputParams.TResponseReasoning;

  TResponseRankingOptions = GenAI.Responses.OutputParams.TResponseRankingOptions;

  TResponseFileSearchFiltersCommon = GenAI.Responses.OutputParams.TResponseFileSearchFiltersCommon;

  TResponseFileSearchFiltersComparaison = GenAI.Responses.OutputParams.TResponseFileSearchFiltersComparaison;

  TResponseFileSearchFiltersCompound = GenAI.Responses.OutputParams.TResponseFileSearchFiltersCompound;

  TResponseFileSearchFilters = GenAI.Responses.OutputParams.TResponseFileSearchFilters;

  TResponseWebSearchLocation = GenAI.Responses.OutputParams.TResponseWebSearchLocation;

  TResponseOutputCommon = GenAI.Responses.OutputParams.TResponseOutputCommon;

  TResponseOutputMessage = GenAI.Responses.OutputParams.TResponseOutputMessage;

  TResponseOutputFileSearch = GenAI.Responses.OutputParams.TResponseOutputFileSearch;

  TResponseOutputFunction = GenAI.Responses.OutputParams.TResponseOutputFunction;

  TResponseOutputWebSearch = GenAI.Responses.OutputParams.TResponseOutputWebSearch;

  TResponseOutputComputer = GenAI.Responses.OutputParams.TResponseOutputComputer;

  TResponseOutputReasoning = GenAI.Responses.OutputParams.TResponseOutputReasoning;

  TResponseOutputImageGeneration = GenAI.Responses.OutputParams.TResponseOutputImageGeneration;

  TResponseOutputCodeInterpreter = GenAI.Responses.OutputParams.TResponseOutputCodeInterpreter;

  TResponseOutputLocalShell = GenAI.Responses.OutputParams.TResponseOutputLocalShell;

  TResponseOutputMCPTool = GenAI.Responses.OutputParams.TResponseOutputMCPTool;

  TResponseOutputMCPList = GenAI.Responses.OutputParams.TResponseOutputMCPList;

  TResponseMCPApproval = GenAI.Responses.OutputParams.TResponseMCPApproval;

  TResponseOutput = GenAI.Responses.OutputParams.TResponseOutput;

  TResponseTextFormatCommon = GenAI.Responses.OutputParams.TResponseTextFormatCommon;

  TResponseFormatText = GenAI.Responses.OutputParams.TResponseFormatText;

  TResponseFormatJSONObject = GenAI.Responses.OutputParams.TResponseFormatJSONObject;

  TResponseFormatJSONSchema = GenAI.Responses.OutputParams.TResponseFormatJSONSchema;

  TResponseTextFormat = GenAI.Responses.OutputParams.TResponseTextFormat;

  TResponseText = GenAI.Responses.OutputParams.TResponseText;

  TResponseToolCommon = GenAI.Responses.OutputParams.TResponseToolCommon;

  TResponseToolFileSearch = GenAI.Responses.OutputParams.TResponseToolFileSearch;

  TResponseToolFunction = GenAI.Responses.OutputParams.TResponseToolFunction;

  TResponseToolComputerUse = GenAI.Responses.OutputParams.TResponseToolComputerUse;

  TResponseToolWebSearch = GenAI.Responses.OutputParams.TResponseToolWebSearch;

  TResponseMCPTool = GenAI.Responses.OutputParams.TResponseMCPTool;

  TResponseCodeInterpreter = GenAI.Responses.OutputParams.TResponseCodeInterpreter;

  TResponseImageGenerationTool = GenAI.Responses.OutputParams.TResponseImageGenerationTool;

  TResponseLocalShellTool = GenAI.Responses.OutputParams.TResponseLocalShellTool;

  TResponseTool = GenAI.Responses.OutputParams.TResponseTool;

  TInputTokensDetails = GenAI.Responses.OutputParams.TInputTokensDetails;

  TOutputTokensDetails = GenAI.Responses.OutputParams.TOutputTokensDetails;

  TResponseUsage = GenAI.Responses.OutputParams.TResponseUsage;

  TResponse = GenAI.Responses.OutputParams.TResponse;

  TUrlIncludeParams = GenAI.Responses.OutputParams.TUrlIncludeParams;

  TUrlResponseListParams = GenAI.Responses.OutputParams.TUrlResponseListParams;

  TResponseDelete = GenAI.Responses.OutputParams.TResponseDelete;

  TResponseStreamingCommon = GenAI.Responses.OutputParams.TResponseStreamingCommon;

  TResponseCreated = GenAI.Responses.OutputParams.TResponseCreated;

  TResponseInProgress = GenAI.Responses.OutputParams.TResponseInProgress;

  TResponseCompleted = GenAI.Responses.OutputParams.TResponseCompleted;

  TResponseFailed = GenAI.Responses.OutputParams.TResponseFailed;

  TResponseIncomplete = GenAI.Responses.OutputParams.TResponseIncomplete;

  TResponseOutputItemAdded = GenAI.Responses.OutputParams.TResponseOutputItemAdded;

  TResponseOutputItemDone = GenAI.Responses.OutputParams.TResponseOutputItemDone;

  TResponseContentpartAdded = GenAI.Responses.OutputParams.TResponseContentpartAdded;

  TResponseContentpartDone = GenAI.Responses.OutputParams.TResponseContentpartDone;

  TResponseOutputTextDelta = GenAI.Responses.OutputParams.TResponseOutputTextDelta;

  TResponseOutputTextAnnotationAdded = GenAI.Responses.OutputParams.TResponseOutputTextAnnotationAdded;

  TResponseOutputTextDone = GenAI.Responses.OutputParams.TResponseOutputTextDone;

  TResponseRefusalDelta = GenAI.Responses.OutputParams.TResponseRefusalDelta;

  TResponseRefusalDone = GenAI.Responses.OutputParams.TResponseRefusalDone;

  TResponseFunctionCallArgumentsDelta = GenAI.Responses.OutputParams.TResponseFunctionCallArgumentsDelta;

  TResponseFunctionCallArgumentsDone = GenAI.Responses.OutputParams.TResponseFunctionCallArgumentsDone;

  TResponseFileSearchCallInprogress = GenAI.Responses.OutputParams.TResponseFileSearchCallInprogress;

  TResponseFileSearchCallSearching = GenAI.Responses.OutputParams.TResponseFileSearchCallSearching;

  TResponseFileSearchCallCompleted = GenAI.Responses.OutputParams.TResponseFileSearchCallCompleted;

  TResponseWebSearchCallInprogress = GenAI.Responses.OutputParams.TResponseWebSearchCallInprogress;

  TResponseWebSearchCallSearching = GenAI.Responses.OutputParams.TResponseWebSearchCallSearching;

  TResponseWebSearchCallCompleted = GenAI.Responses.OutputParams.TResponseWebSearchCallCompleted;

  TResponseStreamError = GenAI.Responses.OutputParams.TResponseStreamError;

  TResponseStream = GenAI.Responses.OutputParams.TResponseStream;

  {$ENDREGION}

function FromDeveloper(const Content: string; const Name: string = ''):TMessagePayload;
function FromSystem(const Content: string; const Name: string = ''):TMessagePayload;
function FromUser(const Content: string; const Name: string = ''):TMessagePayload; overload;
function FromUser(const Content: string; const Docs: TArray<string>; const Name: string = ''):TMessagePayload; overload;
function FromUser(const Docs: TArray<string>; const Name: string = ''):TMessagePayload; overload;
function FromAssistant(const ParamProc: TProcRef<TMessagePayload>): TMessagePayload; overload;
function FromAssistant(const Value: TMessagePayload): TMessagePayload; overload;
function FromAssistant(const Value: string): TMessagePayload; overload;
function FromAssistantAudioId(const Value: string): TMessagePayload;
function FromTool(const Content: string; const ToolCallId: string): TMessagePayload;

function ToolCall(const Id: string; const Name: string; const Arguments: string): TToolCallsParams;
function PredictionPart(const AType: string; const Text: string): TPredictionPartParams;
function ToolName(const Name: string): TToolChoiceParams;

function Code_interpreter: TAssistantsToolsParams; overload;
function Code_interpreter(const FileIds: TArray<string>): TToolResourcesParams; overload;

function RankingOptions(const ScoreThreshold: Double; const Ranker: string = 'auto'): TRankingOptionsParams;

function Vector_store(const FileIds: TArray<string>;
  const Metadata: TJSONObject = nil): TVectorStoresParams; overload;
function Vector_store(const FileIds: TArray<string>;
  const ChunkingStrategy: TChunkingStrategyParams;
  const Metadata: TJSONObject = nil): TVectorStoresParams; overload;

function web_search_preview(const SearchWebOption: string = ''): TResponseWebSearchParams;
function Locate: TResponseUserLocationParams;
function file_search(const vector_store_ids: TArray<string> = []): TResponseFileSearchParams;


function HttpMonitoring: IRequestMonitor;

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

function FromAssistant(const Value: string): TMessagePayload; overload;
begin
  Result := TMessagePayload.Assistant(Value);
end;

function FromAssistantAudioId(const Value: string): TMessagePayload;
begin
  Result := TMessagePayload.AssistantAudioId(Value);
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

function Code_interpreter: TAssistantsToolsParams;
begin
  Result := TAssistantsToolsParams.Create.&Type(TAssistantsToolsType.code_interpreter);
end;

function Code_interpreter(const FileIds: TArray<string>): TToolResourcesParams;
begin
  Result := TToolResourcesParams.Create.CodeInterpreter(FileIds);
end;

function RankingOptions(const ScoreThreshold: Double; const Ranker: string = 'auto'): TRankingOptionsParams;
begin
  Result := TRankingOptionsParams.Create.Ranker(Ranker).ScoreThreshold(ScoreThreshold);
end;

function Vector_store(const FileIds: TArray<string>; const Metadata: TJSONObject): TVectorStoresParams;
begin
  if Length(FileIds) = 0 then
    raise Exception.Create('File Ids can''t be null');
  Result := TVectorStoresParams.Create.FileIds(FileIds);
  if Assigned(Metadata) then
    Result := Result.Metadata(Metadata);
end;

function Vector_store(const FileIds: TArray<string>;
  const ChunkingStrategy: TChunkingStrategyParams;
  const Metadata: TJSONObject = nil): TVectorStoresParams; overload;
begin
  Result := Vector_store(FileIds, Metadata).ChunkingStrategy(ChunkingStrategy);
end;

function web_search_preview(const SearchWebOption: string): TResponseWebSearchParams;
begin
  Result := TResponseWebSearchParams.New;
  if not SearchWebOption.Trim.IsEmpty then
    Result.SearchContextSize(SearchWebOption);
end;

function Locate: TResponseUserLocationParams;
begin
  Result := TResponseUserLocationParams.New;
end;

function file_search(const vector_store_ids: TArray<string>): TResponseFileSearchParams;
begin
  Result := TResponseFileSearchParams.New;
  if Length(vector_store_ids) > 0 then
    Result.VectorStoreIds(vector_store_ids);
end;

function HttpMonitoring: IRequestMonitor;
begin
  Result := Monitoring;
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
  FAssistantsRoute.Free;
  FAudioRoute.Free;
  FBatchRoute.Free;
  FChatRoute.Free;
  FCompletionRoute.Free;
  FEmbeddingsRoute.Free;
  FFilesRoute.Free;
  FFineTuningRoute.Free;
  FImagesRoute.Free;
  FMessagesRoute.Free;
  FModelsRoute.Free;
  FModerationRoute.Free;
  FRunsRoute.Free;
  FRunStepRoute.Free;
  FThreadsRoute.Free;
  FUploadsRoute.Free;
  FVectorStoreRoute.Free;
  FVectorStoreBatchRoute.Free;
  FVectorStoreFilesRoute.Free;
  FResponsesRoute.Free;
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

function TGenAI.GetMesssagesRoute: TMessagesRoute;
begin
  if not Assigned(FMessagesRoute) then
    FMessagesRoute := TMessagesRoute.CreateRoute(API);
  Result := FMessagesRoute;
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

function TGenAI.GetResponses: TResponsesRoute;
begin
  if not Assigned(FResponsesRoute) then
    FResponsesRoute := TResponsesRoute.CreateRoute(API);
  Result := FResponsesRoute;
end;

function TGenAI.GetRunsRoute: TRunsRoute;
begin
  if not Assigned(FRunsRoute) then
    FRunsRoute := TRunsRoute.CreateRoute(API);
  Result := FRunsRoute;
end;

function TGenAI.GetRunStepRoute: TRunStepRoute;
begin
  if not Assigned(FRunStepRoute) then
    FRunStepRoute := TRunStepRoute.CreateRoute(API);
  Result := FRunStepRoute;
end;

function TGenAI.GetThreadsRoute: TThreadsRoute;
begin
  if not Assigned(FThreadsRoute) then
    FThreadsRoute := TThreadsRoute.CreateRoute(API);
  Result := FThreadsRoute;
end;

function TGenAI.GetUploadsRoute: TUploadsRoute;
begin
  if not Assigned(FUploadsRoute) then
    FUploadsRoute := TUploadsRoute.CreateRoute(API);
  Result := FUploadsRoute;
end;

function TGenAI.GetVectorStoreBatchRoute: TVectorStoreBatchRoute;
begin
  if not Assigned(FVectorStoreBatchRoute) then
    FVectorStoreBatchRoute := TVectorStoreBatchRoute.CreateRoute(API);
  Result := FVectorStoreBatchRoute;
end;

function TGenAI.GetVectorStoreFilesRoute: TVectorStoreFilesRoute;
begin
  if not Assigned(FVectorStoreFilesRoute) then
    FVectorStoreFilesRoute := TVectorStoreFilesRoute.CreateRoute(API);
  Result := FVectorStoreFilesRoute;
end;

function TGenAI.GetVectorStoreRoute: TVectorStoreRoute;
begin
  if not Assigned(FVectorStoreRoute) then
    FVectorStoreRoute := TVectorStoreRoute.CreateRoute(API);
  Result := FVectorStoreRoute;
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

function TGenAI.GetAssistantsRoute: TAssistantsRoute;
begin
  if not Assigned(FAssistantsRoute) then
    FAssistantsRoute := TAssistantsRoute.CreateRoute(API);
  Result := FAssistantsRoute;
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
