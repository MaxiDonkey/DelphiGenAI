unit GenAI;

interface

uses
  System.SysUtils, System.Classes, GenAI.API, GenAI.API.Params, GenAI.Models,
  GenAI.Embeddings, GenAI.Audio, GenAI.Chat;

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
    function GetEmbeddingsRoute: TEmbeddingsRoute;
    function GetModelsRoute: TModelsRoute;
    function GetChatRoute: TChatRoute;

    property Audio: TAudioRoute read GetAudioRoute;
    property Embeddings: TEmbeddingsRoute read GetEmbeddingsRoute;
    property Models: TModelsRoute read GetModelsRoute;
    /// <summary>
    /// Provides access to the chat completion API.
    /// Allows for interaction with models fine-tuned for instruction-based dialogue.
    /// </summary>
    /// <returns>
    /// An instance of TChatRoute for chat-related operations.
    /// </returns>
    property Chat: TChatRoute read GetChatRoute;

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
    FEmbeddingsRoute: TEmbeddingsRoute;
    FModelsRoute: TModelsRoute;
    FChatRoute: TChatRoute;

    function GetAPI: TGenAIAPI;
    function GetAPIKey: string;
    procedure SetAPIKey(const Value: string);
    function GetBaseUrl: string;
    procedure SetBaseUrl(const Value: string);

    function GetAudioRoute: TAudioRoute;
    function GetEmbeddingsRoute: TEmbeddingsRoute;
    function GetModelsRoute: TModelsRoute;
    function GetChatRoute: TChatRoute;
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

  AssistantContent = GenAI.Chat.TAssistantContentParams;
  Payload = GenAI.Chat.TMessagePayload;

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
