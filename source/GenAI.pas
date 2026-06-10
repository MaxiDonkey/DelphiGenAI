unit GenAI;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGenAI
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

{$REGION 'Facade aliases compiler switch'}

(*
  Apple ARM64 / iOS Delphi compilers can fail when a facade unit accumulates
  many type aliases. Keep facade aliases enabled by default for compatibility,
  but disable them automatically on the affected targets.

  Define GENAI_FORCE_FACADE_ALIASES to re-enable the aliases manually.
*)

{$IFDEF DCCOSXARM64}
  {$DEFINE GENAI_FACADE_ALIASES_UNSAFE_TARGET}
{$ENDIF}
{$IFDEF DCCIOSARM64}
  {$DEFINE GENAI_FACADE_ALIASES_UNSAFE_TARGET}
{$ENDIF}
{$IFDEF DCCIOSSIMARM64}
  {$DEFINE GENAI_FACADE_ALIASES_UNSAFE_TARGET}
{$ENDIF}

{$IFDEF GENAI_FACADE_ALIASES_UNSAFE_TARGET}
  {$IFNDEF GENAI_FORCE_FACADE_ALIASES}
    {$DEFINE GENAI_DISABLE_FACADE_ALIASES}
  {$ENDIF}
{$ENDIF}

{$ENDREGION}

uses
  System.SysUtils, System.Classes, System.Net.URLClient, System.JSON,
  GenAI.API, GenAI.API.Params, GenAI.HttpClientInterface, GenAI.Monitoring,
  GenAI.Chat, GenAI.Completions, GenAI.Models, GenAI.Audio, GenAI.VoiceContents,
  GenAI.Batch, GenAI.Containers, GenAI.Batch.Interfaces,
  GenAI.ContainerFiles, GenAI.Skills, GenAI.Embeddings, GenAI.Files, GenAI.FineTuning,
  GenAI.Images, GenAI.Moderation, GenAI.Uploads, GenAI.Vector, GenAI.VectorBatch,
  GenAI.VectorFiles, GenAI.Responses, GenAI.Conversations
  {$IFNDEF GENAI_DISABLE_FACADE_ALIASES}
  , GenAI.Aliases
  {$ENDIF};

const
  VERSION = '2.0.0';

type
  /// <summary>
  /// Defines the primary interface for interacting with the GenAI API.
  /// </summary>
  IGenAI = interface
    ['{4A1E56DB-67B7-4553-957E-4324C5BFC983}']
    function GetAPI: TGenAIAPI;
    function GetHttpClient: IHttpClientAPI;
    procedure SetAPIKey(const Value: string);
    function GetAPIKey: string;
    function GetBaseUrl: string;
    procedure SetBaseUrl(const Value: string);
    function GetVersion: string;
    function GetChatRoute: TChatRoute;
    function GetCompletionsRoute: TCompletionRoute;
    function GetResponsesRoute: TResponsesRoute;
    function GetConversationsRoute: TConversationsRoute;
    function GetModelsRoute: TModelsRoute;
    function GetAudioRoute: TAudioRoute;
    function GetVoiceContentsRoute: TVoiceContentsRoute;
    function GetBatchRoute: TBatchRoute;
    function GetContainersRoute: TContainersRoute;
    function GetContainerFilesRoute: TContainerFilesRoute;
    function GetSkillsRoute: TSkillsRoute;
    function GetEmbeddingsRoute: TEmbeddingsRoute;
    function GetFilesRoute: TFilesRoute;
    function GetFineTuningRoute: TFineTuningRoute;
    function GetImagesRoute: TImagesRoute;
    function GetModerationRoute: TModerationRoute;
    function GetUploadsRoute: TUploadsRoute;
    function GetVectorStoreRoute: TVectorStoreRoute;
    function GetVectorStoreBatchRoute: TVectorStoreBatchRoute;
    function GetVectorStoreFilesRoute: TVectorStoreFilesRoute;

    /// <summary>
    /// Provides access to the chat API.
    /// </summary>
    /// <remarks>
    /// <para>
    /// This property exposes the <c>TChatRoute</c> entry point for chat operations such as message
    /// creation, streaming message creation, and token counting.
    /// </para>
    /// <para>
    /// The route instance is created lazily on first access and reused for subsequent calls.
    /// </para>
    /// <para>
    /// The returned route shares the same underlying <c>TGenAIAPI</c> instance and therefore uses
    /// the current authentication key and base URL configuration.
    /// </para>
    /// <para>
    /// Use this property to access chat-related operations through a single, centralized client
    /// instance.
    /// </para>
    /// </remarks>
    property Chat: TChatRoute read GetChatRoute;

    /// <summary>
    /// Provides access to the legacy completions API.
    /// </summary>
    /// <remarks>
    /// The route instance is created lazily on first access and reused for subsequent calls.
    /// </remarks>
    property Completions: TCompletionRoute read GetCompletionsRoute;

    /// <summary>
    /// Provides access to the responses API.
    /// </summary>
    /// <remarks>
    /// The route instance is created lazily on first access and reused for subsequent calls.
    /// </remarks>
    property Responses: TResponsesRoute read GetResponsesRoute;

    /// <summary>
    /// Provides access to the conversations API.
    /// </summary>
    /// <remarks>
    /// The route instance is created lazily on first access and reused for subsequent calls.
    /// </remarks>
    property Conversations: TConversationsRoute read GetConversationsRoute;

    /// <summary>
    /// Provides access to the models API.
    /// </summary>
    /// <remarks>
    /// <para>
    /// This property exposes the <c>TModelsRoute</c> entry point for model operations such as listing,
    /// retrieving, and deleting models.
    /// </para>
    /// <para>
    /// The route instance is created lazily on first access and reused for subsequent calls.
    /// </para>
    /// </remarks>
    property Models: TModelsRoute read GetModelsRoute;

    /// <summary>
    /// Provides access to the audio API.
    /// </summary>
    /// <remarks>
    /// <para>
    /// This property exposes the <c>TAudioRoute</c> entry point for audio operations such as speech
    /// generation, transcription, and translation.
    /// </para>
    /// <para>
    /// The route instance is created lazily on first access and reused for subsequent calls.
    /// </para>
    /// </remarks>
    property Audio: TAudioRoute read GetAudioRoute;

    /// <summary>
    /// Provides access to the custom voice creation API.
    /// </summary>
    /// <remarks>
    /// The route instance is created lazily on first access and reused for subsequent calls.
    /// </remarks>
    property VoiceContents: TVoiceContentsRoute read GetVoiceContentsRoute;

    /// <summary>
    /// Provides access to the batch API.
    /// </summary>
    /// <remarks>
    /// <para>
    /// This property exposes the <c>TBatchRoute</c> entry point for batch operations such as creating,
    /// retrieving, cancelling, and listing batches.
    /// </para>
    /// <para>
    /// The route instance is created lazily on first access and reused for subsequent calls.
    /// </para>
    /// </remarks>
    property Batch: TBatchRoute read GetBatchRoute;

    /// <summary>
    /// Provides access to the containers API.
    /// </summary>
    /// <remarks>
    /// The route instance is created lazily on first access and reused for subsequent calls.
    /// </remarks>
    property Containers: TContainersRoute read GetContainersRoute;

    /// <summary>
    /// Provides access to the container files API.
    /// </summary>
    /// <remarks>
    /// The route instance is created lazily on first access and reused for subsequent calls.
    /// </remarks>
    property ContainerFiles: TContainerFilesRoute read GetContainerFilesRoute;

    /// <summary>
    /// Provides access to the skills API.
    /// </summary>
    /// <remarks>
    /// The route instance is created lazily on first access and reused for subsequent calls.
    /// </remarks>
    property Skills: TSkillsRoute read GetSkillsRoute;

    /// <summary>
    /// Provides access to the embeddings API.
    /// </summary>
    /// <remarks>
    /// <para>
    /// This property exposes the <c>TEmbeddingsRoute</c> entry point for creating embedding vectors
    /// from text input.
    /// </para>
    /// <para>
    /// The route instance is created lazily on first access and reused for subsequent calls.
    /// </para>
    /// </remarks>
    property Embeddings: TEmbeddingsRoute read GetEmbeddingsRoute;

    /// <summary>
    /// Provides access to the files API.
    /// </summary>
    /// <remarks>
    /// <para>
    /// This property exposes the <c>TFilesRoute</c> entry point for file operations such as uploading,
    /// listing, retrieving, retrieving content, and deleting files.
    /// </para>
    /// <para>
    /// The route instance is created lazily on first access and reused for subsequent calls.
    /// </para>
    /// </remarks>
    property Files: TFilesRoute read GetFilesRoute;

    /// <summary>
    /// Provides access to the fine-tuning API.
    /// </summary>
    /// <remarks>
    /// <para>
    /// This property exposes the <c>TFineTuningRoute</c> entry point for fine-tuning operations such as creating,
    /// retrieving, listing, and cancelling jobs, and accessing their events and checkpoints.
    /// </para>
    /// <para>
    /// The route instance is created lazily on first access and reused for subsequent calls.
    /// </para>
    /// </remarks>
    property FineTuning: TFineTuningRoute read GetFineTuningRoute;

    /// <summary>
    /// Provides access to the images API.
    /// </summary>
    /// <remarks>
    /// <para>
    /// This property exposes the <c>TImagesRoute</c> entry point for image operations such as generation,
    /// editing, and variation.
    /// </para>
    /// <para>
    /// The route instance is created lazily on first access and reused for subsequent calls.
    /// </para>
    /// </remarks>
    property Images: TImagesRoute read GetImagesRoute;

    /// <summary>
    /// Provides access to the moderation API.
    /// </summary>
    /// <remarks>
    /// <para>
    /// This property exposes the <c>TModerationRoute</c> entry point for classifying text and image
    /// content against moderation models.
    /// </para>
    /// <para>
    /// The route instance is created lazily on first access and reused for subsequent calls.
    /// </para>
    /// </remarks>
    property Moderation: TModerationRoute read GetModerationRoute;

    /// <summary>
    /// Provides access to the uploads API.
    /// </summary>
    /// <remarks>
    /// <para>
    /// This property exposes the <c>TUploadsRoute</c> entry point for multipart upload operations:
    /// creating an upload, adding parts, completing, and cancelling.
    /// </para>
    /// <para>
    /// The route instance is created lazily on first access and reused for subsequent calls.
    /// </para>
    /// </remarks>
    property Uploads: TUploadsRoute read GetUploadsRoute;

    /// <summary>
    /// Provides access to the vector stores API.
    /// </summary>
    /// <remarks>
    /// The route instance is created lazily on first access and reused for subsequent calls.
    /// </remarks>
    property VectorStore: TVectorStoreRoute read GetVectorStoreRoute;

    /// <summary>
    /// Provides access to the vector store file batch API.
    /// </summary>
    /// <remarks>
    /// The route instance is created lazily on first access and reused for subsequent calls.
    /// </remarks>
    property VectorStoreBatch: TVectorStoreBatchRoute read GetVectorStoreBatchRoute;

    /// <summary>
    /// Provides access to the vector store files API.
    /// </summary>
    /// <remarks>
    /// The route instance is created lazily on first access and reused for subsequent calls.
    /// </remarks>
    property VectorStoreFiles: TVectorStoreFilesRoute read GetVectorStoreFilesRoute;

    /// <summary>
    /// Provides access to the underlying API client used to issue requests.
    /// </summary>
    /// <remarks>
    /// <para>
    /// This property exposes the shared <c>TGenAIAPI</c> instance used internally by all route
    /// objects.
    /// </para>
    /// <para>
    /// It provides direct access to low-level request methods (GET/POST/DELETE, multipart uploads,
    /// deserialization, and header construction) when route-level abstractions are not sufficient.
    /// </para>
    /// <para>
    /// The returned instance reflects the current configuration (key, base URL, headers, and HTTP
    /// transport template) and is intended to be long-lived.
    /// </para>
    /// <para>
    /// Use this property for advanced scenarios such as custom routing, diagnostics, or integration
    /// with auxiliary infrastructure that requires the raw API client.
    /// </para>
    /// </remarks>
    property API: TGenAIAPI read GetAPI;

    /// <summary>
    /// Provides access to the underlying HTTP client implementation used by the API.
    /// </summary>
    /// <remarks>
    /// <para>
    /// This property exposes the <c>IHttpClientAPI</c> instance used internally to execute all HTTP
    /// requests.
    /// </para>
    /// <para>
    /// It reflects the active HTTP transport configured on the shared <c>TGenAIAPI</c> instance.
    /// </para>
    /// <para>
    /// Use this property when you need to customize transport behavior or integrate monitoring,
    /// middleware, or client-specific options.
    /// </para>
    /// <para>
    /// The returned reference is shared across all routes and remains valid for the lifetime of the
    /// owning GenAI client instance.
    /// </para>
    /// </remarks>
    property HttpClient: IHttpClientAPI read GetHttpClient;

    /// <summary>
    /// Sets or retrieves the API key used for authentication.
    /// </summary>
    /// <remarks>
    /// <para>
    /// This property holds the API key sent with each request to authenticate against the GenAI API.
    /// </para>
    /// <para>
    /// Updating this value affects all subsequent requests issued by the client and its route objects.
    /// </para>
    /// <para>
    /// The key must be a non-empty string; otherwise request execution will fail during validation.
    /// </para>
    /// <para>
    /// Use this property to rotate credentials or defer key assignment until after client creation.
    /// </para>
    /// </remarks>
    property APIKey: string read GetAPIKey write SetAPIKey;

    /// <summary>
    /// Sets or retrieves the base URL used for all API requests.
    /// </summary>
    /// <remarks>
    /// <para>
    /// This property defines the root endpoint used to construct request URLs for all API calls.
    /// </para>
    /// <para>
    /// The default value is <c>https://api.openai.com/v1</c>.
    /// </para>
    /// <para>
    /// Updating this value affects all subsequent requests issued by the client and its route objects.
    /// </para>
    /// <para>
    /// Use this property to target alternative endpoints, such as proxies, gateways, or test
    /// environments.
    /// </para>
    /// </remarks>
    property BaseURL: string read GetBaseUrl write SetBaseUrl;

    /// <summary>
    /// Gets the current version of the GenAI library.
    /// </summary>
    /// <remarks>
    /// The <c>Version</c> property provides the semantic version number of the library as a string.
    /// This can be used for compatibility checks or displaying version information in your application.
    /// </remarks>
    /// <returns>
    /// A string representing the library version.
    /// </returns>
    property Version: string read GetVersion;
  end;

  /// <summary>
  /// Factory class responsible for creating and configuring GenAI client instances.
  /// </summary>
  /// <remarks>
  /// <para>
  /// <c>TGenAIFactory</c> centralizes the instantiation logic for GenAI clients, ensuring
  /// consistent configuration and initialization across the application.
  /// </para>
  /// <para>
  /// It typically encapsulates concerns such as API key injection, base URL selection, HTTP
  /// client configuration, and default headers.
  /// </para>
  /// <para>
  /// The factory may expose one or more creation methods that return an <c>IGenAI</c>
  /// interface, allowing consumers to remain decoupled from concrete implementation classes.
  /// </para>
  /// <para>
  /// Use this class to obtain fully initialized GenAI client instances instead of creating
  /// them directly, promoting consistency, testability, and easier future evolution of the
  /// client construction process.
  /// </para>
  TGenAIFactory = class
    /// <summary>
    /// Creates a GenAI instance configured to use the standard OpenAI API with the provided API key.
    /// </summary>
    /// <remarks>
    /// This factory method initializes an <c>IGenAI</c> implementation backed by <c>TGenAIAPI</c>
    /// in hosted-API mode. The provided <paramref name="AAPIKey"/> is applied to the underlying
    /// API client and is required for authenticating all requests to <c>https://api.openai.com/v1</c>
    /// (or any custom base URL subsequently configured).
    /// <para>
    /// Use this method for all interactions with OpenAI's cloud services, including models,
    /// chat completions, embeddings, file management, fine-tuning, vector stores, and other endpoints.
    /// </para>
    /// </remarks>
    /// <param name="AAPIKey">
    /// The OpenAI API key used to authenticate requests. This value must be a valid key; otherwise
    /// API calls will fail with authentication errors.
    /// </param>
    /// <returns>
    /// An <c>IGenAI</c> instance configured for authenticated communication with the OpenAI API.
    /// </returns>
    class function CreateInstance(const AAPIKey: string): IGenAI;

    /// <summary>
    /// Creates a GenAI instance configured to use a local LM Studio server instead of the hosted API.
    /// </summary>
    /// <remarks>
    /// This factory method initializes an <c>IGenAI</c> implementation with <c>TGenAIAPI</c>
    /// running in "local LMS" mode. When <paramref name="URLBase"/> is empty, the instance
    /// uses the global <c>TGenAIAPI.LocalUrlBase</c> value (which defaults to
    /// <c>http://127.0.0.1:1234/v1</c>). When a non-empty URL is provided, it overrides the
    /// global local base URL for LM Studio connections.
    /// <para>
    /// Use this helper when you want to work with models served by LM Studio or another
    /// OpenAI-compatible local endpoint, without requiring an OpenAI API key.
    /// </para>
    /// </remarks>
    /// <param name="URLBase">
    /// Optional base URL of the local LM Studio (or compatible) server. If omitted or empty,
    /// the current value of <c>TGenAIAPI.LocalUrlBase</c> is used.
    /// </param>
    /// <returns>
    /// An <c>IGenAI</c> instance configured to send all requests to the specified local LM Studio server.
    /// </returns>
    class function CreateLMSInstance(const URLBase: string = ''): IGenAI;

    /// <summary>
    /// Creates a <c>GenAI</c> instance configured to target Google's Gemini models through an
    /// OpenAI-compatible API surface.
    /// </summary>
    /// <remarks>
    /// Gemini models can be accessed using a subset of OpenAI-style API routes exposed by this
    /// library by switching the <see cref="IGenAI.BaseURL"/> to the Gemini-compatible endpoint.
    /// <para>
    /// <b>Compatibility note:</b> when using the Gemini base URL, only the following endpoints
    /// are supported: <c>v1/chat/completions</c>, <c>v1/images/generations</c>,
    /// <c>v1/embeddings</c>, and <c>v1/models</c>.
    /// Other OpenAI endpoints (including <c>v1/responses</c>, audio, fine-tuning, files,
    /// batches, vector stores, assistants, and related routes) are not supported by Gemini
    /// and will fail if used against the Gemini base URL.
    /// </para>
    /// <para>
    /// This helper returns an authenticated instance (using <paramref name="AAPIKey"/>) with its
    /// <see cref="IGenAI.BaseURL"/> set to <c>TGenAIConfiguration.URL_BASE_GEMINI</c>.
    /// </para>
    /// </remarks>
    /// <param name="AAPIKey">
    /// The API key used to authenticate requests to the Gemini-compatible endpoint.
    /// </param>
    /// <returns>
    /// An <c>IGenAI</c> instance configured for Gemini access via the supported OpenAI-style routes.
    /// </returns>
    class function CreateGeminiInstance(const AAPIKey: string): IGenAI;

    /// <summary>
    /// Creates a GenAI instance configured to target Anthropic's Claude API.
    /// </summary>
    /// <remarks>
    /// This factory method initializes an <c>IGenAI</c> implementation backed by <c>TGenAIAPI</c>
    /// and sets <see cref="IGenAI.BaseURL"/> to <c>TGenAIConfiguration.URL_BASE_CLAUDE</c>.
    /// The provided <paramref name="AAPIKey"/> is applied to the underlying API client and is
    /// required for authenticating requests to the Claude endpoint.
    /// <para>
    /// <b>Compatibility note:</b> Claude is not an OpenAI service. While this library exposes a common
    /// surface area across providers, endpoint availability and request/response schemas may differ.
    /// Some GenAI routes may not be supported by Claude and can fail when used against the Claude base URL.
    /// </para>
    /// </remarks>
    /// <param name="AAPIKey">
    /// The API key used to authenticate requests to the Claude endpoint.
    /// </param>
    /// <returns>
    /// An <c>IGenAI</c> instance configured for authenticated communication with Anthropic's Claude API.
    /// </returns>
    class function CreateClaudeInstance(const AAPIKey: string): IGenAI;

    /// <summary>
    /// Creates a GenAI instance configured to target the DeepSeek API.
    /// </summary>
    /// <remarks>
    /// This factory method initializes an <c>IGenAI</c> implementation backed by <c>TGenAIAPI</c>
    /// and sets <see cref="IGenAI.BaseURL"/> to <c>TGenAIConfiguration.URL_BASE_DEEPSEEK</c>.
    /// The provided <paramref name="AAPIKey"/> is applied to the underlying API client and is
    /// required for authenticating requests to the DeepSeek endpoint.
    /// <para>
    /// <b>Compatibility note:</b> DeepSeek is not an OpenAI service. Although this library provides
    /// a unified, OpenAI-style API surface, endpoint availability and request/response schemas
    /// may differ. Some GenAI routes may not be supported by DeepSeek and can fail when used
    /// against the DeepSeek base URL.
    /// </para>
    /// </remarks>
    /// <param name="AAPIKey">
    /// The API key used to authenticate requests to the DeepSeek endpoint.
    /// </param>
    /// <returns>
    /// An <c>IGenAI</c> instance configured for authenticated communication with the DeepSeek API.
    /// </returns>
    class function CreateDeepSeekInstance(const AAPIKey: string): IGenAI;

    /// <summary>
    /// Creates a GenAI instance configured to target xAI's Grok API.
    /// </summary>
    /// <remarks>
    /// This factory method initializes an <c>IGenAI</c> implementation backed by <c>TGenAIAPI</c>
    /// and sets <see cref="IGenAI.BaseURL"/> to <c>TGenAIConfiguration.URL_BASE_GROK</c>.
    /// The provided <paramref name="AAPIKey"/> is applied to the underlying API client and is
    /// required for authenticating requests to the xAI endpoint.
    /// <para>
    /// <b>Compatibility note:</b> Grok (xAI) is not an OpenAI service. While this library exposes a
    /// unified, OpenAI-style API surface, endpoint availability and request/response schemas may differ.
    /// Some GenAI routes may not be supported by xAI and can fail when used against the Grok base URL.
    /// </para>
    /// </remarks>
    /// <param name="AAPIKey">
    /// The API key used to authenticate requests to the xAI endpoint.
    /// </param>
    /// <returns>
    /// An <c>IGenAI</c> instance configured for authenticated communication with xAI's Grok API.
    /// </returns>
    class function CreateGrokInstance(const AAPIKey: string): IGenAI;

    /// <summary>
    /// Creates a GenAI instance configured to target a custom, external API endpoint.
    /// </summary>
    /// <remarks>
    /// This factory method initializes an <c>IGenAI</c> implementation backed by <c>TGenAIAPI</c>
    /// and sets <see cref="IGenAI.BaseURL"/> to the value provided in <paramref name="BaseUrl"/>.
    /// The supplied <paramref name="AAPIKey"/> is applied to the underlying API client and is
    /// used for authenticating requests to the external service.
    /// <para>
    /// This helper is intended for OpenAI-compatible or partially compatible APIs that expose
    /// a similar HTTP and JSON contract. The caller is responsible for ensuring that
    /// <paramref name="BaseUrl"/> points to a valid API root (typically ending with <c>/v1</c>)
    /// and that the target service supports the routes being invoked.
    /// </para>
    /// <para>
    /// <b>Compatibility note:</b> Because external endpoints may diverge from OpenAI semantics,
    /// not all GenAI routes or features are guaranteed to work. Unsupported endpoints,
    /// request fields, or response schemas may result in runtime API errors.
    /// </para>
    /// </remarks>
    /// <param name="BaseUrl">
    /// The base URL of the external API endpoint. This value is assigned directly to
    /// <see cref="IGenAI.BaseURL"/> and should represent the root path for API requests.
    /// </param>
    /// <param name="AAPIKey">
    /// The API key used to authenticate requests to the external endpoint.
    /// </param>
    /// <returns>
    /// An <c>IGenAI</c> instance configured for authenticated communication with the specified
    /// external API endpoint.
    /// </returns>
    class function CreateExternalInstance(
      const BaseUrl: string;
      const AAPIKey: string): IGenAI;
  end;

  TLazyRouteFactory = class(TInterfacedObject)
  protected
    FChatLock: TObject;
    FCompletionsLock: TObject;
    FResponsesLock: TObject;
    FConversationsLock: TObject;
    FModelsLock: TObject;
    FAudioLock: TObject;
    FVoiceContentsLock: TObject;
    FBatchLock: TObject;
    FContainersLock: TObject;
    FContainerFilesLock: TObject;
    FSkillsLock: TObject;
    FEmbeddingsLock: TObject;
    FFilesLock: TObject;
    FFineTuningLock: TObject;
    FImagesLock: TObject;
    FModerationLock: TObject;
    FUploadsLock: TObject;
    FVectorStoreLock: TObject;
    FVectorStoreBatchLock: TObject;
    FVectorStoreFilesLock: TObject;

    function Lazy<T: class>(var AField: T; const ALock: TObject;
      const AFactory: TFunc<T>): T; inline;

  public
    constructor Create;
    destructor Destroy; override;
  end;

  TGenAI = class(TLazyRouteFactory, IGenAI)
  private
    FAPI: TGenAIAPI;

    FChatRoute: TChatRoute;
    FCompletionsRoute: TCompletionRoute;
    FResponsesRoute: TResponsesRoute;
    FConversationsRoute: TConversationsRoute;
    FModelsRoute: TModelsRoute;
    FAudioRoute: TAudioRoute;
    FVoiceContentsRoute: TVoiceContentsRoute;
    FBatchRoute: TBatchRoute;
    FContainersRoute: TContainersRoute;
    FContainerFilesRoute: TContainerFilesRoute;
    FSkillsRoute: TSkillsRoute;
    FEmbeddingsRoute: TEmbeddingsRoute;
    FFilesRoute: TFilesRoute;
    FFineTuningRoute: TFineTuningRoute;
    FImagesRoute: TImagesRoute;
    FModerationRoute: TModerationRoute;
    FUploadsRoute: TUploadsRoute;
    FVectorStoreRoute: TVectorStoreRoute;
    FVectorStoreBatchRoute: TVectorStoreBatchRoute;
    FVectorStoreFilesRoute: TVectorStoreFilesRoute;

    function GetAPI: TGenAIAPI;
    function GetAPIKey: string;
    procedure SetAPIKey(const Value: string);
    function GetBaseUrl: string;
    procedure SetBaseUrl(const Value: string);
    function GetHttpClient: IHttpClientAPI;
    function GetVersion: string;

    function GetChatRoute: TChatRoute;
    function GetCompletionsRoute: TCompletionRoute;
    function GetResponsesRoute: TResponsesRoute;
    function GetConversationsRoute: TConversationsRoute;
    function GetModelsRoute: TModelsRoute;
    function GetAudioRoute: TAudioRoute;
    function GetVoiceContentsRoute: TVoiceContentsRoute;
    function GetBatchRoute: TBatchRoute;
    function GetContainersRoute: TContainersRoute;
    function GetContainerFilesRoute: TContainerFilesRoute;
    function GetSkillsRoute: TSkillsRoute;
    function GetEmbeddingsRoute: TEmbeddingsRoute;
    function GetFilesRoute: TFilesRoute;
    function GetFineTuningRoute: TFineTuningRoute;
    function GetImagesRoute: TImagesRoute;
    function GetModerationRoute: TModerationRoute;
    function GetUploadsRoute: TUploadsRoute;
    function GetVectorStoreRoute: TVectorStoreRoute;
    function GetVectorStoreBatchRoute: TVectorStoreBatchRoute;
    function GetVectorStoreFilesRoute: TVectorStoreFilesRoute;

  public
    /// <summary>
    /// Provides access to the underlying API client used to issue requests.
    /// </summary>
    /// <remarks>
    /// <para>
    /// This property exposes the shared <c>TGenAIAPI</c> instance used internally by all route
    /// objects.
    /// </para>
    /// <para>
    /// It provides direct access to low-level request methods (GET/POST/DELETE, multipart uploads,
    /// deserialization, and header construction) when route-level abstractions are not sufficient.
    /// </para>
    /// <para>
    /// The returned instance reflects the current configuration (key, base URL, headers, and HTTP
    /// transport template) and is intended to be long-lived.
    /// </para>
    /// <para>
    /// Use this property for advanced scenarios such as custom routing, diagnostics, or integration
    /// with auxiliary infrastructure that requires the raw API client.
    /// </para>
    /// </remarks>
    property API: TGenAIAPI read GetAPI;

    /// <summary>
    /// Provides access to the underlying HTTP client implementation used by the API.
    /// </summary>
    /// <remarks>
    /// <para>
    /// This property exposes the <c>IHttpClientAPI</c> instance used internally to execute all HTTP
    /// requests.
    /// </para>
    /// <para>
    /// It reflects the active HTTP transport configured on the shared <c>TGenAIAPI</c> instance.
    /// </para>
    /// <para>
    /// Use this property when you need to customize transport behavior or integrate monitoring,
    /// middleware, or client-specific options.
    /// </para>
    /// <para>
    /// The returned reference is shared across all routes and remains valid for the lifetime of the
    /// owning GenAI client instance.
    /// </para>
    /// </remarks>
    property HttpClient: IHttpClientAPI read GetHttpClient;

    /// <summary>
    /// Sets or retrieves the API key used for authentication.
    /// </summary>
    /// <remarks>
    /// <para>
    /// This property holds the API key sent with each request to authenticate against the GenAI API.
    /// </para>
    /// <para>
    /// Updating this value affects all subsequent requests issued by the client and its route objects.
    /// </para>
    /// <para>
    /// The key must be a non-empty string; otherwise request execution will fail during validation.
    /// </para>
    /// <para>
    /// Use this property to rotate credentials or defer key assignment until after client creation.
    /// </para>
    /// </remarks>
    property APIKey: string read GetAPIKey write SetAPIKey;

    /// <summary>
    /// Sets or retrieves the base URL used for all API requests.
    /// </summary>
    /// <remarks>
    /// <para>
    /// This property defines the root endpoint used to construct request URLs for all API calls.
    /// </para>
    /// <para>
    /// The default value is <c>https://api.openai.com/v1</c>.
    /// </para>
    /// <para>
    /// Updating this value affects all subsequent requests issued by the client and its route objects.
    /// </para>
    /// <para>
    /// Use this property to target alternative endpoints, such as proxies, gateways, or test
    /// environments.
    /// </para>
    /// </remarks>
    property BaseURL: string read GetBaseUrl write SetBaseUrl;

    /// <summary>
    /// Gets the current version of the GenAI library.
    /// </summary>
    /// <remarks>
    /// The <c>Version</c> property provides the semantic version number of the library as a string.
    /// This can be used for compatibility checks or displaying version information in your application.
    /// </remarks>
    /// <returns>
    /// A string representing the library version.
    /// </returns>
    property Version: string read GetVersion;

    /// <summary>
    /// Initializes a new instance of the <see cref="TGenAI"/> class.
    /// </summary>
    /// <param name="LocalLMS">
    /// When <c>True</c>, the instance is created in local LM Studio mode and targets
    /// <c>TGenAIAPI.LocalUrlBase</c> instead of the hosted API. The default is <c>False</c>.
    /// </param>
    /// <remarks>
    /// This constructor is typically used when no API key is provided initially.
    /// The key can be set later via the <see cref="APIKey"/> property.
    /// </remarks>
    constructor Create(const LocalLMS: Boolean = False); overload;

    /// <summary>
    /// Initializes a new instance of the <see cref="TGenAI"/> class with the provided API key.
    /// </summary>
    /// <param name="AAPIKey">
    /// The API key as a string, required for authenticating with the GenAI API.
    /// </param>
    /// <param name="LocalLMS">
    /// When <c>True</c>, the instance is created in local LM Studio mode and targets
    /// <c>TGenAIAPI.LocalUrlBase</c> instead of the hosted API. The default is <c>False</c>.
    /// </param>
    /// <remarks>
    /// This constructor allows the user to specify an API key at the time of initialization.
    /// </remarks>
    constructor Create(const AAPIKey: string; const LocalLMS: Boolean = False); overload;

    /// <summary>
    /// Releases all resources used by the current instance of the <see cref="TGenAI"/> class.
    /// </summary>
    /// <remarks>
    /// This method is called to clean up any resources before the object is destroyed.
    /// It overrides the base <see cref="TInterfacedObject.Destroy"/> method.
    /// </remarks>
    destructor Destroy; override;
  end;

  {$IFNDEF GENAI_DISABLE_FACADE_ALIASES}
  {$I GenAI.FacadeAliases.inc}
  {$ENDIF}

  /// <summary>
  /// Returns the current version string of the GenAI client library.
  /// </summary>
  function CurrentVersion: string;

  /// <summary>
  /// Returns the global request monitor used to track active HTTP requests.
  /// </summary>
  function HttpMonitoring: IRequestMonitor;

  /// <summary>
  /// Builds a developer-role message payload for chat completions.
  /// </summary>
  function FromDeveloper(const Content: string; const Name: string = ''): TMessagePayload;

  /// <summary>
  /// Builds a system-role message payload for chat completions.
  /// </summary>
  function FromSystem(const Content: string; const Name: string = ''): TMessagePayload;

  /// <summary>
  /// Builds a user-role message payload for chat completions.
  /// </summary>
  function FromUser(const Content: string; const Name: string = ''): TMessagePayload; overload;

  /// <summary>
  /// Builds a user-role message payload including document references.
  /// </summary>
  function FromUser(const Content: string; const Docs: TArray<string>; const Name: string = ''): TMessagePayload; overload;

  /// <summary>
  /// Builds a user-role message payload from document references only.
  /// </summary>
  function FromUser(const Docs: TArray<string>; const Name: string = ''): TMessagePayload; overload;

  /// <summary>
  /// Builds an assistant-role message payload configured through a delegate.
  /// </summary>
  function FromAssistant(const ParamProc: TProcRef<TMessagePayload>): TMessagePayload; overload;

  /// <summary>
  /// Builds an assistant-role message payload from an existing payload instance.
  /// </summary>
  function FromAssistant(const Value: TMessagePayload): TMessagePayload; overload;

  /// <summary>
  /// Builds an assistant-role message payload from a string.
  /// </summary>
  function FromAssistant(const Value: string): TMessagePayload; overload;

  /// <summary>
  /// Builds an assistant-role message payload referencing an audio id.
  /// </summary>
  function FromAssistantAudioId(const Value: string): TMessagePayload;

  /// <summary>
  /// Builds a tool-role message payload bound to a tool call id.
  /// </summary>
  function FromTool(const Content: string; const ToolCallId: string): TMessagePayload;

  /// <summary>
  /// Builds a tool-call parameter for a chat message.
  /// </summary>
  function ToolCall(const Id: string; const Name: string; const Arguments: string): TToolCallsParams;

  /// <summary>
  /// Builds a prediction content part for chat completions.
  /// </summary>
  function PredictionPart(const AType: string; const Text: string): TPredictionPartParams;

  /// <summary>
  /// Builds a tool-choice parameter forcing a specific function name.
  /// </summary>
  function ToolName(const Name: string): TToolChoiceParams;

  function web_search_preview(const SearchWebOption: string = ''): TResponseWebSearchParams;
  function Locate: TResponseUserLocationParams;
  function file_search(const vector_store_ids: TArray<string> = []): TResponseFileSearchParams;

var
  JSONLChatReader: GenAI.Batch.Interfaces.IJSONLReader<TChat>;
  JSONLEmbeddingReader: GenAI.Batch.Interfaces.IJSONLReader<TEmbeddings>;
  BatchBuilder: GenAI.Batch.Interfaces.IBatchJSONBuilder;

implementation

function CurrentVersion: string;
begin
  Result := VERSION;
end;

function HttpMonitoring: IRequestMonitor;
begin
  Result := Monitoring;
end;

function FromDeveloper(const Content: string; const Name: string): TMessagePayload;
begin
  Result := TMessagePayload.Developer(Content, Name);
end;

function FromSystem(const Content: string; const Name: string): TMessagePayload;
begin
  Result := TMessagePayload.System(Content, Name);
end;

function FromUser(const Content: string; const Name: string): TMessagePayload;
begin
  Result := TMessagePayload.User(Content, Name);
end;

function FromUser(const Content: string; const Docs: TArray<string>; const Name: string): TMessagePayload;
begin
  Result := TMessagePayload.User(Content, Docs, Name);
end;

function FromUser(const Docs: TArray<string>; const Name: string): TMessagePayload;
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

function FromAssistant(const Value: string): TMessagePayload;
begin
  Result := TMessagePayload.Assistant(Value);
end;

function FromAssistantAudioId(const Value: string): TMessagePayload;
begin
  Result := TMessagePayload.AssistantAudioId(Value);
end;

function FromTool(const Content: string; const ToolCallId: string): TMessagePayload;
begin
  Result := TMessagePayload.Tool(Content, ToolCallId);
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

constructor TGenAI.Create(const LocalLMS: Boolean);
begin
  inherited Create;
  FAPI := TGenAIAPI.Create(LocalLMS);
end;

constructor TGenAI.Create(const AAPIKey: string; const LocalLMS: Boolean);
begin
  Create(LocalLMS);
  APIKey := AAPIKey;
end;

destructor TGenAI.Destroy;
begin
  FChatRoute.Free;
  FCompletionsRoute.Free;
  FResponsesRoute.Free;
  FConversationsRoute.Free;
  FModelsRoute.Free;
  FAudioRoute.Free;
  FVoiceContentsRoute.Free;
  FBatchRoute.Free;
  FContainersRoute.Free;
  FContainerFilesRoute.Free;
  FSkillsRoute.Free;
  FEmbeddingsRoute.Free;
  FFilesRoute.Free;
  FFineTuningRoute.Free;
  FImagesRoute.Free;
  FModerationRoute.Free;
  FUploadsRoute.Free;
  FVectorStoreRoute.Free;
  FVectorStoreBatchRoute.Free;
  FVectorStoreFilesRoute.Free;
  FAPI.Free;
  inherited;
end;

function TGenAI.GetAPI: TGenAIAPI;
begin
  Result := FAPI;
end;

function TGenAI.GetAPIKey: string;
begin
  Result := FAPI.APIKey;
end;

function TGenAI.GetBaseUrl: string;
begin
  Result := FAPI.BaseUrl;
end;

function TGenAI.GetAudioRoute: TAudioRoute;
begin
  Result := Lazy<TAudioRoute>(FAudioRoute, FAudioLock,
    function: TAudioRoute
    begin
      Result := TAudioRoute.CreateRoute(API);
    end);
end;

function TGenAI.GetVoiceContentsRoute: TVoiceContentsRoute;
begin
  Result := Lazy<TVoiceContentsRoute>(FVoiceContentsRoute, FVoiceContentsLock,
    function: TVoiceContentsRoute
    begin
      Result := TVoiceContentsRoute.CreateRoute(API);
    end);
end;

function TGenAI.GetBatchRoute: TBatchRoute;
begin
  Result := Lazy<TBatchRoute>(FBatchRoute, FBatchLock,
    function: TBatchRoute
    begin
      Result := TBatchRoute.CreateRoute(API);
    end);
end;

function TGenAI.GetContainersRoute: TContainersRoute;
begin
  Result := Lazy<TContainersRoute>(FContainersRoute, FContainersLock,
    function: TContainersRoute
    begin
      Result := TContainersRoute.CreateRoute(API);
    end);
end;

function TGenAI.GetContainerFilesRoute: TContainerFilesRoute;
begin
  Result := Lazy<TContainerFilesRoute>(FContainerFilesRoute, FContainerFilesLock,
    function: TContainerFilesRoute
    begin
      Result := TContainerFilesRoute.CreateRoute(API);
    end);
end;

function TGenAI.GetSkillsRoute: TSkillsRoute;
begin
  Result := Lazy<TSkillsRoute>(FSkillsRoute, FSkillsLock,
    function: TSkillsRoute
    begin
      Result := TSkillsRoute.CreateRoute(API);
    end);
end;

function TGenAI.GetEmbeddingsRoute: TEmbeddingsRoute;
begin
  Result := Lazy<TEmbeddingsRoute>(FEmbeddingsRoute, FEmbeddingsLock,
    function: TEmbeddingsRoute
    begin
      Result := TEmbeddingsRoute.CreateRoute(API);
    end);
end;

function TGenAI.GetFilesRoute: TFilesRoute;
begin
  Result := Lazy<TFilesRoute>(FFilesRoute, FFilesLock,
    function: TFilesRoute
    begin
      Result := TFilesRoute.CreateRoute(API);
    end);
end;

function TGenAI.GetFineTuningRoute: TFineTuningRoute;
begin
  Result := Lazy<TFineTuningRoute>(FFineTuningRoute, FFineTuningLock,
    function: TFineTuningRoute
    begin
      Result := TFineTuningRoute.CreateRoute(API);
    end);
end;

function TGenAI.GetImagesRoute: TImagesRoute;
begin
  Result := Lazy<TImagesRoute>(FImagesRoute, FImagesLock,
    function: TImagesRoute
    begin
      Result := TImagesRoute.CreateRoute(API);
    end);
end;

function TGenAI.GetModerationRoute: TModerationRoute;
begin
  Result := Lazy<TModerationRoute>(FModerationRoute, FModerationLock,
    function: TModerationRoute
    begin
      Result := TModerationRoute.CreateRoute(API);
    end);
end;

function TGenAI.GetUploadsRoute: TUploadsRoute;
begin
  Result := Lazy<TUploadsRoute>(FUploadsRoute, FUploadsLock,
    function: TUploadsRoute
    begin
      Result := TUploadsRoute.CreateRoute(API);
    end);
end;

function TGenAI.GetVectorStoreRoute: TVectorStoreRoute;
begin
  Result := Lazy<TVectorStoreRoute>(FVectorStoreRoute, FVectorStoreLock,
    function: TVectorStoreRoute
    begin
      Result := TVectorStoreRoute.CreateRoute(API);
    end);
end;

function TGenAI.GetVectorStoreBatchRoute: TVectorStoreBatchRoute;
begin
  Result := Lazy<TVectorStoreBatchRoute>(FVectorStoreBatchRoute, FVectorStoreBatchLock,
    function: TVectorStoreBatchRoute
    begin
      Result := TVectorStoreBatchRoute.CreateRoute(API);
    end);
end;

function TGenAI.GetVectorStoreFilesRoute: TVectorStoreFilesRoute;
begin
  Result := Lazy<TVectorStoreFilesRoute>(FVectorStoreFilesRoute, FVectorStoreFilesLock,
    function: TVectorStoreFilesRoute
    begin
      Result := TVectorStoreFilesRoute.CreateRoute(API);
    end);
end;

function TGenAI.GetChatRoute: TChatRoute;
begin
  Result := Lazy<TChatRoute>(FChatRoute, FChatLock,
    function: TChatRoute
    begin
      Result := TChatRoute.CreateRoute(API);
    end);
end;

function TGenAI.GetCompletionsRoute: TCompletionRoute;
begin
  Result := Lazy<TCompletionRoute>(FCompletionsRoute, FCompletionsLock,
    function: TCompletionRoute
    begin
      Result := TCompletionRoute.CreateRoute(API);
    end);
end;

function TGenAI.GetResponsesRoute: TResponsesRoute;
begin
  Result := Lazy<TResponsesRoute>(FResponsesRoute, FResponsesLock,
    function: TResponsesRoute
    begin
      Result := TResponsesRoute.CreateRoute(API);
    end);
end;

function TGenAI.GetConversationsRoute: TConversationsRoute;
begin
  Result := Lazy<TConversationsRoute>(FConversationsRoute, FConversationsLock,
    function: TConversationsRoute
    begin
      Result := TConversationsRoute.CreateRoute(API);
    end);
end;

function TGenAI.GetModelsRoute: TModelsRoute;
begin
  Result := Lazy<TModelsRoute>(FModelsRoute, FModelsLock,
    function: TModelsRoute
    begin
      Result := TModelsRoute.CreateRoute(API);
    end);
end;

function TGenAI.GetHttpClient: IHttpClientAPI;
begin
  Result := API.HttpClient;
end;

function TGenAI.GetVersion: string;
begin
  Result := CurrentVersion;
end;

procedure TGenAI.SetAPIKey(const Value: string);
begin
  FAPI.APIKey := Value;
end;

procedure TGenAI.SetBaseUrl(const Value: string);
begin
  FAPI.BaseUrl := Value;
end;

{ TGenAIFactory }

class function TGenAIFactory.CreateInstance(const AAPIKey: string): IGenAI;
begin
  Result := TGenAI.Create(AAPIKey);
end;

class function TGenAIFactory.CreateLMSInstance(const URLBase: string): IGenAI;
begin
  if not URLBase.Trim.IsEmpty then
    begin
      var Base := URLBase.TrimRight(['/']);
      if not Base.EndsWith('/v1', True) then
        Base := Base + '/v1';
      TGenAIAPI.LocalUrlBase := Base;
    end;

  Result := TGenAI.Create('', True);
end;

class function TGenAIFactory.CreateGeminiInstance(const AAPIKey: string): IGenAI;
begin
  Result := TGenAI.Create(AAPIKey);
  Result.BaseURL := TGenAIConfiguration.URL_BASE_GEMINI;
end;

class function TGenAIFactory.CreateClaudeInstance(const AAPIKey: string): IGenAI;
begin
  Result := TGenAI.Create(AAPIKey);
  Result.BaseURL := TGenAIConfiguration.URL_BASE_CLAUDE;
end;

class function TGenAIFactory.CreateDeepSeekInstance(const AAPIKey: string): IGenAI;
begin
  Result := TGenAI.Create(AAPIKey);
  Result.BaseURL := TGenAIConfiguration.URL_BASE_DEEPSEEK;
end;

class function TGenAIFactory.CreateGrokInstance(const AAPIKey: string): IGenAI;
begin
  Result := TGenAI.Create(AAPIKey);
  Result.BaseURL := TGenAIConfiguration.URL_BASE_GROK;
end;

class function TGenAIFactory.CreateExternalInstance(const BaseUrl, AAPIKey: string): IGenAI;
begin
  Result := TGenAI.Create(AAPIKey);
  Result.BaseURL := BaseUrl;
end;

{ TLazyRouteFactory }

constructor TLazyRouteFactory.Create;
begin
  inherited Create;
  FChatLock := TObject.Create;
  FCompletionsLock := TObject.Create;
  FResponsesLock := TObject.Create;
  FConversationsLock := TObject.Create;
  FModelsLock := TObject.Create;
  FAudioLock := TObject.Create;
  FVoiceContentsLock := TObject.Create;
  FBatchLock := TObject.Create;
  FContainersLock := TObject.Create;
  FContainerFilesLock := TObject.Create;
  FSkillsLock := TObject.Create;
  FEmbeddingsLock := TObject.Create;
  FFilesLock := TObject.Create;
  FFineTuningLock := TObject.Create;
  FImagesLock := TObject.Create;
  FModerationLock := TObject.Create;
  FUploadsLock := TObject.Create;
  FVectorStoreLock := TObject.Create;
  FVectorStoreBatchLock := TObject.Create;
  FVectorStoreFilesLock := TObject.Create;
end;

destructor TLazyRouteFactory.Destroy;
begin
  FChatLock.Free;
  FCompletionsLock.Free;
  FResponsesLock.Free;
  FConversationsLock.Free;
  FModelsLock.Free;
  FAudioLock.Free;
  FVoiceContentsLock.Free;
  FBatchLock.Free;
  FContainersLock.Free;
  FContainerFilesLock.Free;
  FSkillsLock.Free;
  FEmbeddingsLock.Free;
  FFilesLock.Free;
  FFineTuningLock.Free;
  FImagesLock.Free;
  FModerationLock.Free;
  FUploadsLock.Free;
  FVectorStoreLock.Free;
  FVectorStoreBatchLock.Free;
  FVectorStoreFilesLock.Free;
  inherited;
end;

function TLazyRouteFactory.Lazy<T>(var AField: T; const ALock: TObject;
  const AFactory: TFunc<T>): T;
begin
  Result := AField;
  if Result <> nil then
    Exit;

  TMonitor.Enter(ALock);
  try
    if AField = nil then
      AField := AFactory();
    Result := AField;
  finally
    TMonitor.Exit(ALock);
  end;
end;

function web_search_preview(const SearchWebOption: string = ''): TResponseWebSearchParams;
begin
  Result := TResponseWebSearchParams.New;
  if not SearchWebOption.Trim.IsEmpty then
    Result.SearchContextSize(SearchWebOption);
end;

function Locate: TResponseUserLocationParams;
begin
  Result := TResponseUserLocationParams.New;
end;

function file_search(const vector_store_ids: TArray<string> = []): TResponseFileSearchParams;
begin
  Result := TResponseFileSearchParams.New;
  if Length(vector_store_ids) > 0 then
    Result.VectorStoreIds(vector_store_ids);
end;

end.
