unit GenAI.Aliases;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGenAI
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  GenAI.API.Params,
  GenAI.API.Deletion,
  GenAI.Chat,
  GenAI.Completions,
  GenAI.Chat.Request,
  GenAI.ChatDTO,
  GenAI.Chat.Parallel,
  GenAI.Models,
  GenAI.Audio,
  GenAI.Audio.Stream,
  GenAI.VoiceContents,
  GenAI.Batch,
  GenAI.Batch.Interfaces,
  GenAI.Batch.Builder,
  GenAI.Containers,
  GenAI.ContainerFiles,
  GenAI.Skills,
  GenAI.Embeddings,
  GenAI.Files,
  GenAI.FineTuning,
  GenAI.Images,
  GenAI.Moderation,
  GenAI.Uploads,
  GenAI.Vector,
  GenAI.VectorBatch,
  GenAI.VectorFiles,
  GenAI.Responses.Helpers,
  GenAI.Responses.ImageHelper,
  GenAI.Responses.InputItemList,
  GenAI.Responses.InputParams,
  GenAI.Responses.OutputParams,
  GenAI.Responses.Internal,
  GenAI.Responses.StreamCallbacks,
  GenAI.Responses.StreamEngine,
  GenAI.Responses,
  GenAI.Conversations,
  GenAI.Functions.Core,
  GenAI.Functions.Tools,
  GenAI.Gemini.Extra_body,
  GenAI.Schema;

type
  {$REGION 'GenAI.Types'}

  TUrlPaginationParams = GenAI.API.Params.TUrlPaginationParams;
  TUrlAdvancedParams = GenAI.API.Params.TUrlAdvancedParams;
  TUrlParam = GenAI.API.Params.TUrlParam;
  TJSONParam = GenAI.API.Params.TJSONParam;
  TJSONFingerprint = GenAI.API.Params.TJSONFingerprint;
  TJSONInterceptorStringToString = GenAI.API.Params.TJSONInterceptorStringToString;
  TParameters = GenAI.API.Params.TParameters;

  {$ENDREGION}

  {$REGION 'GenAI.Schema'}

  /// <summary>
  /// Helper record for creating schema property entries.
  /// </summary>
  TPropertyItem = GenAI.Schema.TPropertyItem;

  /// <summary>
  /// Fluent builder for JSON schema payloads.
  /// </summary>
  TSchemaParams = GenAI.Schema.TSchemaParams;

  {$ENDREGION}

  {$REGION 'GenAI.Functions'}

  /// <summary>
  /// Interface implemented by function/tool descriptors.
  /// </summary>
  IFunctionCore = GenAI.Functions.Core.IFunctionCore;

  /// <summary>
  /// Base implementation for function/tool descriptors.
  /// </summary>
  TFunctionCore = GenAI.Functions.Core.TFunctionCore;

  /// <summary>
  /// Chat tool descriptor built from a function definition.
  /// </summary>
  TChatMessageTool = GenAI.Functions.Tools.TChatMessageTool;

  /// <summary>
  /// Function call details returned by a tool call.
  /// </summary>
  TCalledFunctionSpecifics = GenAI.Functions.Tools.TCalledFunctionSpecifics;

  /// <summary>
  /// Tool call wrapper returned by the model.
  /// </summary>
  TCalledFunction = GenAI.Functions.Tools.TCalledFunction;

  {$ENDREGION}

  {$REGION 'GenAI.Gemini.Extra_body'}

  /// <summary>
  /// Gemini thinking configuration payload.
  /// </summary>
  TThinkingConfig = GenAI.Gemini.Extra_body.TThinkingConfig;

  /// <summary>
  /// Extra body payload used for provider-specific request options.
  /// </summary>
  TExtraBody = GenAI.Gemini.Extra_body.TExtraBody;

  {$ENDREGION}

  {$REGION 'GenAI.Chat.Request'}

  /// <summary>
  /// Image URL payload used by chat content parts.
  /// </summary>
  TImageUrl = GenAI.Chat.Request.TImageUrl;

  /// <summary>
  /// Audio input payload used by chat content parts.
  /// </summary>
  TInputAudio = GenAI.Chat.Request.TInputAudio;

  /// <summary>
  /// Content payload used for multimodal chat messages.
  /// </summary>
  TContentParams = GenAI.Chat.Request.TContentParams;

  /// <summary>
  /// Simple text content part.
  /// </summary>
  TContentPart = GenAI.Chat.Request.TContentPart;

  /// <summary>
  /// Function payload for tool calls.
  /// </summary>
  TFunctionParams = GenAI.Chat.Request.TFunctionParams;

  /// <summary>
  /// Tool call payload for chat messages.
  /// </summary>
  TToolCallsParams = GenAI.Chat.Request.TToolCallsParams;

  /// <summary>
  /// Assistant content payload.
  /// </summary>
  TAssistantContentParams = GenAI.Chat.Request.TAssistantContentParams;

  /// <summary>
  /// Chat message payload builder.
  /// </summary>
  TMessagePayload = GenAI.Chat.Request.TMessagePayload;

  /// <summary>
  /// Prediction content part payload.
  /// </summary>
  TPredictionPartParams = GenAI.Chat.Request.TPredictionPartParams;

  /// <summary>
  /// Prediction payload for chat requests.
  /// </summary>
  TPredictionParams = GenAI.Chat.Request.TPredictionParams;

  /// <summary>
  /// Audio output options payload.
  /// </summary>
  TAudioParams = GenAI.Chat.Request.TAudioParams;

  /// <summary>
  /// Function selector payload for tool choice.
  /// </summary>
  TToolChoiceFunctionParams = GenAI.Chat.Request.TToolChoiceFunctionParams;

  /// <summary>
  /// Tool choice payload.
  /// </summary>
  TToolChoiceParams = GenAI.Chat.Request.TToolChoiceParams;

  /// <summary>
  /// Approximate user location payload.
  /// </summary>
  TUserLocationApproximate = GenAI.Chat.Request.TUserLocationApproximate;

  /// <summary>
  /// User location payload.
  /// </summary>
  TUserLocation = GenAI.Chat.Request.TUserLocation;

  /// <summary>
  /// Chat completions request payload.
  /// </summary>
  TChatParams = GenAI.Chat.Request.TChatParams;

  /// <summary>
  /// Query parameters for chat messages.
  /// </summary>
  TUrlChatParams = GenAI.Chat.Request.TUrlChatParams;

  /// <summary>
  /// Query parameters for stored chat completion listing.
  /// </summary>
  TUrlChatListParams = GenAI.Chat.Request.TUrlChatListParams;

  /// <summary>
  /// Payload used to update stored chat completions.
  /// </summary>
  TChatUpdateParams = GenAI.Chat.Request.TChatUpdateParams;

  {$ENDREGION}

  {$REGION 'GenAI.ChatDTO'}

  /// <summary>
  /// Shape of a raw chat content node captured during deserialization.
  /// </summary>
  TChatContentKind = GenAI.ChatDTO.TChatContentKind;

  /// <summary>
  /// Top log probability item.
  /// </summary>
  TTopLogprobs = GenAI.ChatDTO.TTopLogprobs;

  /// <summary>
  /// Log probability detail item.
  /// </summary>
  TLogprobsDetail = GenAI.ChatDTO.TLogprobsDetail;

  /// <summary>
  /// Log probability details returned for a choice.
  /// </summary>
  TLogprobs = GenAI.ChatDTO.TLogprobs;

  /// <summary>
  /// Function details returned inside a tool call.
  /// </summary>
  TFunction = GenAI.ChatDTO.TFunction;

  /// <summary>
  /// Tool call returned by a chat completion.
  /// </summary>
  TToolCall = GenAI.ChatDTO.TToolCall;

  /// <summary>
  /// Audio data returned by a chat completion.
  /// </summary>
  TAudioData = GenAI.ChatDTO.TAudioData;

  /// <summary>
  /// Audio object returned by a chat completion.
  /// </summary>
  TAudio = GenAI.ChatDTO.TAudio;

  /// <summary>
  /// URL citation details.
  /// </summary>
  TUrlCitation = GenAI.ChatDTO.TUrlCitation;

  /// <summary>
  /// Annotation returned with a chat message.
  /// </summary>
  TAnnotation = GenAI.ChatDTO.TAnnotation;

  /// <summary>
  /// Streamed delta returned by chat completions.
  /// </summary>
  TDelta = GenAI.ChatDTO.TDelta;

  /// <summary>
  /// Completed chat message returned by chat completions.
  /// </summary>
  TChatMessage = GenAI.ChatDTO.TChatMessage;

  /// <summary>
  /// Choice returned by a chat completion.
  /// </summary>
  TChoice = GenAI.ChatDTO.TChoice;

  /// <summary>
  /// Completion token usage detail.
  /// </summary>
  TCompletionDetail = GenAI.ChatDTO.TCompletionDetail;

  /// <summary>
  /// Prompt token usage detail.
  /// </summary>
  TPromptDetail = GenAI.ChatDTO.TPromptDetail;

  /// <summary>
  /// Usage information returned by a chat completion.
  /// </summary>
  TUsage = GenAI.ChatDTO.TUsage;

  /// <summary>
  /// Chat completion response DTO.
  /// </summary>
  TChat = GenAI.ChatDTO.TChat;

  /// <summary>
  /// Stored chat completion message DTO.
  /// </summary>
  TChatCompletionMessage = GenAI.ChatDTO.TChatCompletionMessage;

  /// <summary>
  /// Stored chat completion messages list DTO.
  /// </summary>
  TChatMessages = GenAI.ChatDTO.TChatMessages;

  /// <summary>
  /// Stored chat completions list DTO.
  /// </summary>
  TChatCompletion = GenAI.ChatDTO.TChatCompletion;

  /// <summary>
  /// Stored chat completion deletion DTO.
  /// </summary>
  TChatDelete = GenAI.ChatDTO.TChatDelete;

  {$ENDREGION}

  {$REGION 'GenAI.Chat.Parallel'}

  /// <summary>
  /// Represents an item in a bundle of chat prompts and responses.
  /// </summary>
  TBundleItem = GenAI.Chat.Parallel.TBundleItem;

  /// <summary>
  /// Manages a collection of <c>TBundleItem</c> objects.
  /// </summary>
  TBundleList = GenAI.Chat.Parallel.TBundleList;

  /// <summary>
  /// Represents an asynchronous callback buffer for handling chat responses.
  /// </summary>
  TAsynBundleList = GenAI.Chat.Parallel.TAsynBundleList;
  TAsynBuffer = TAsynBundleList;

  /// <summary>
  /// Represents an asynchronous callback buffer for handling parallel chat responses for promise chaining.
  /// </summary>
  TPromiseBundleList = GenAI.Chat.Parallel.TPromiseBundleList;

  /// <summary>
  /// Represents the parameters used for configuring a chat request bundle.
  /// </summary>
  TBundleParams = GenAI.Chat.Parallel.TBundleParams;

  {$ENDREGION}

  {$REGION 'GenAI.Chat'}

  /// <summary>
  /// Alias for chat streaming callbacks.
  /// </summary>
  TChatStreamCallbackEvent = GenAI.Chat.TChatStreamCallbackEvent;

  /// <summary>
  /// Asynchronous callback record for chat completion responses.
  /// </summary>
  TAsynChat = GenAI.Chat.TAsynChat;

  /// <summary>
  /// Promise callback record for chat completion responses.
  /// </summary>
  TPromiseChat = GenAI.Chat.TPromiseChat;

  /// <summary>
  /// Asynchronous callback record for streamed chat completion responses.
  /// </summary>
  TAsynChatStream = GenAI.Chat.TAsynChatStream;

  /// <summary>
  /// Promise callback record for streamed chat completion responses.
  /// </summary>
  TPromiseChatStream = GenAI.Chat.TPromiseChatStream;

  /// <summary>
  /// Asynchronous callback record for stored chat messages.
  /// </summary>
  TAsynChatMessages = GenAI.Chat.TAsynChatMessages;

  /// <summary>
  /// Promise callback record for stored chat messages.
  /// </summary>
  TPromiseChatMessages = GenAI.Chat.TPromiseChatMessages;

  /// <summary>
  /// Asynchronous callback record for stored chat completion lists.
  /// </summary>
  TAsynChatCompletion = GenAI.Chat.TAsynChatCompletion;

  /// <summary>
  /// Promise callback record for stored chat completion lists.
  /// </summary>
  TPromiseChatCompletion = GenAI.Chat.TPromiseChatCompletion;

  /// <summary>
  /// Asynchronous callback record for chat deletion responses.
  /// </summary>
  TAsynChatDelete = GenAI.Chat.TAsynChatDelete;

  /// <summary>
  /// Promise callback record for chat deletion responses.
  /// </summary>
  TPromiseChatDelete = GenAI.Chat.TPromiseChatDelete;

  {$ENDREGION}

  {$REGION 'GenAI.Completions'}

  TCompletionParams = GenAI.Completions.TCompletionParams;
  TChoicesLogprobs = GenAI.Completions.TChoicesLogprobs;
  TCompletionChoice = GenAI.Completions.TCompletionChoice;
  TCompletion = GenAI.Completions.TCompletion;
  TAsynCompletion = GenAI.Completions.TAsynCompletion;
  TAsynCompletionStream = GenAI.Completions.TAsynCompletionStream;
  TPromiseCompletion = GenAI.Completions.TPromiseCompletion;
  TPromiseCompletionStream = GenAI.Completions.TPromiseCompletionStream;

  {$ENDREGION}

  {$REGION 'GenAI.Models'}

  /// <summary>
  /// OpenAI model resource DTO.
  /// </summary>
  TModel = GenAI.Models.TModel;

  /// <summary>
  /// Listing of OpenAI model resources.
  /// </summary>
  TModels = GenAI.Models.TModels;

  /// <summary>
  /// Asynchronous callback record for a single model response.
  /// </summary>
  TAsynModel = GenAI.Models.TAsynModel;

  /// <summary>
  /// Promise callback record for a single model response.
  /// </summary>
  TPromiseModel = GenAI.Models.TPromiseModel;

  /// <summary>
  /// Asynchronous callback record for a model list response.
  /// </summary>
  TAsynModels = GenAI.Models.TAsynModels;

  /// <summary>
  /// Promise callback record for a model list response.
  /// </summary>
  TPromiseModels = GenAI.Models.TPromiseModels;

  {$ENDREGION}

  {$REGION 'GenAI.Audio'}

  /// <summary>
  /// Speech generation request payload.
  /// </summary>
  TSpeechParams = GenAI.Audio.TSpeechParams;

  /// <summary>
  /// Custom voice payload for speech generation.
  /// </summary>
  TSpeechVoiceParams = GenAI.Audio.TSpeechVoiceParams;

  /// <summary>
  /// Speech generation result (audio bytes).
  /// </summary>
  TSpeechResult = GenAI.Audio.TSpeechResult;

  /// <summary>
  /// Server-side VAD configuration for transcription chunking.
  /// </summary>
  TTranscriptionServerVadParams = GenAI.Audio.TTranscriptionServerVadParams;

  /// <summary>
  /// Chunking strategy payload for transcription requests.
  /// </summary>
  TTranscriptionChunkingStrategyParams = GenAI.Audio.TTranscriptionChunkingStrategyParams;

  /// <summary>
  /// Audio transcription request payload (multipart).
  /// </summary>
  TTranscriptionParams = GenAI.Audio.TTranscriptionParams;

  /// <summary>
  /// Single transcribed word with timestamps.
  /// </summary>
  TTranscriptionWord = GenAI.Audio.TTranscriptionWord;

  /// <summary>
  /// Transcription segment with timing and confidence metrics.
  /// </summary>
  TTranscriptionSegment = GenAI.Audio.TTranscriptionSegment;

  /// <summary>
  /// Speaker-annotated transcription segment.
  /// </summary>
  TTranscriptionDiarizedSegment = GenAI.Audio.TTranscriptionDiarizedSegment;

  /// <summary>
  /// Token log probability returned by transcription responses.
  /// </summary>
  TTranscriptionLogprob = GenAI.Audio.TTranscriptionLogprob;

  /// <summary>
  /// Input token details for transcription usage.
  /// </summary>
  TTranscriptionInputTokenDetails = GenAI.Audio.TTranscriptionInputTokenDetails;

  /// <summary>
  /// Token or duration usage returned by transcription responses.
  /// </summary>
  TTranscriptionUsage = GenAI.Audio.TTranscriptionUsage;

  /// <summary>
  /// Audio transcription result.
  /// </summary>
  TTranscription = GenAI.Audio.TTranscription;

  /// <summary>
  /// Audio translation request payload (multipart).
  /// </summary>
  TTranslationParams = GenAI.Audio.TTranslationParams;

  /// <summary>
  /// Audio translation result.
  /// </summary>
  TTranslation = GenAI.Audio.TTranslation;

  /// <summary>
  /// Asynchronous callback record for a speech result.
  /// </summary>
  TAsynSpeechResult = GenAI.Audio.TAsynSpeechResult;

  /// <summary>
  /// Promise callback record for a speech result.
  /// </summary>
  TPromiseSpeechResult = GenAI.Audio.TPromiseSpeechResult;

  /// <summary>
  /// Asynchronous callback record for a transcription result.
  /// </summary>
  TAsynTranscription = GenAI.Audio.TAsynTranscription;

  /// <summary>
  /// Promise callback record for a transcription result.
  /// </summary>
  TPromiseTranscription = GenAI.Audio.TPromiseTranscription;

  /// <summary>
  /// Asynchronous callback record for a translation result.
  /// </summary>
  TAsynTranslation = GenAI.Audio.TAsynTranslation;

  /// <summary>
  /// Promise callback record for a translation result.
  /// </summary>
  TPromiseTranslation = GenAI.Audio.TPromiseTranslation;

  /// <summary>
  /// Streamed speech payload chunk.
  /// </summary>
  TSpeechStreamChunk = GenAI.Audio.Stream.TSpeechStreamChunk;

  /// <summary>
  /// Aggregated streamed speech result.
  /// </summary>
  TSpeechStreamResult = GenAI.Audio.Stream.TSpeechStreamResult;

  /// <summary>
  /// Token log probability returned by streamed transcription events.
  /// </summary>
  TTranscriptionStreamLogprob = GenAI.Audio.Stream.TTranscriptionStreamLogprob;

  /// <summary>
  /// Input token details returned by streamed transcription usage.
  /// </summary>
  TTranscriptionStreamInputTokenDetails = GenAI.Audio.Stream.TTranscriptionStreamInputTokenDetails;

  /// <summary>
  /// Usage data returned by streamed transcription events.
  /// </summary>
  TTranscriptionStreamUsage = GenAI.Audio.Stream.TTranscriptionStreamUsage;

  /// <summary>
  /// Segment data returned by streamed transcription events.
  /// </summary>
  TTranscriptionStreamSegment = GenAI.Audio.Stream.TTranscriptionStreamSegment;

  /// <summary>
  /// Streamed transcription event.
  /// </summary>
  TTranscriptionStream = GenAI.Audio.Stream.TTranscriptionStream;

  /// <summary>
  /// Aggregated streamed transcription result.
  /// </summary>
  TTranscriptionStreamResult = GenAI.Audio.Stream.TTranscriptionStreamResult;

  /// <summary>
  /// Speech stream callback event.
  /// </summary>
  TSpeechStreamEvent = GenAI.Audio.Stream.TSpeechStreamEvent;

  /// <summary>
  /// Transcription stream callback event.
  /// </summary>
  TTranscriptionStreamEvent = GenAI.Audio.Stream.TTranscriptionStreamEvent;

  /// <summary>
  /// Asynchronous callback record for streamed speech.
  /// </summary>
  TAsynSpeechStream = GenAI.Audio.Stream.TAsynSpeechStream;

  /// <summary>
  /// Promise callback record for streamed speech.
  /// </summary>
  TPromiseSpeechStream = GenAI.Audio.Stream.TPromiseSpeechStream;

  /// <summary>
  /// Asynchronous callback record for streamed transcription.
  /// </summary>
  TAsynTranscriptionStream = GenAI.Audio.Stream.TAsynTranscriptionStream;

  /// <summary>
  /// Promise callback record for streamed transcription.
  /// </summary>
  TPromiseTranscriptionStream = GenAI.Audio.Stream.TPromiseTranscriptionStream;

  {$ENDREGION}

  {$REGION 'GenAI.VoiceContents'}

  /// <summary>
  /// Custom voice creation request payload.
  /// </summary>
  TVoiceContentCreateParams = GenAI.VoiceContents.TVoiceContentCreateParams;

  /// <summary>
  /// Custom voice creation result.
  /// </summary>
  TVoiceContent = GenAI.VoiceContents.TVoiceContent;

  /// <summary>
  /// Asynchronous callback record for custom voice creation.
  /// </summary>
  TAsynVoiceContent = GenAI.VoiceContents.TAsynVoiceContent;

  /// <summary>
  /// Promise callback record for custom voice creation.
  /// </summary>
  TPromiseVoiceContent = GenAI.VoiceContents.TPromiseVoiceContent;

  {$ENDREGION}

  {$REGION 'GenAI.Batch'}

  /// <summary>
  /// Batch creation request payload.
  /// </summary>
  TBatchCreateParams = GenAI.Batch.TBatchCreateParams;

  /// <summary>
  /// Error detail entry attached to a batch.
  /// </summary>
  TBatchErrorsData = GenAI.Batch.TBatchErrorsData;

  /// <summary>
  /// Collection of errors attached to a batch.
  /// </summary>
  TBatchErrors = GenAI.Batch.TBatchErrors;

  /// <summary>
  /// Request counts breakdown for a batch.
  /// </summary>
  TBatchRequestCounts = GenAI.Batch.TBatchRequestCounts;

  /// <summary>
  /// Batch resource DTO.
  /// </summary>
  TBatch = GenAI.Batch.TBatch;

  /// <summary>
  /// Paginated listing of batch resources.
  /// </summary>
  TBatches = GenAI.Batch.TBatches;

  /// <summary>
  /// Asynchronous callback record for a single batch response.
  /// </summary>
  TAsynBatch = GenAI.Batch.TAsynBatch;

  /// <summary>
  /// Asynchronous callback record for a batch list response.
  /// </summary>
  TAsynBatches = GenAI.Batch.TAsynBatches;

  /// <summary>
  /// Promise callback record for a single batch response.
  /// </summary>
  TPromiseBatch = GenAI.Batch.TPromiseBatch;

  /// <summary>
  /// Promise callback record for a batch list response.
  /// </summary>
  TPromiseBatches = GenAI.Batch.TPromiseBatches;

  {$ENDREGION}

  {$REGION 'GenAI.Embeddings'}

  /// <summary>
  /// Embeddings creation request payload.
  /// </summary>
  TEmbeddingsParams = GenAI.Embeddings.TEmbeddingsParams;

  /// <summary>
  /// Single embedding vector returned by the embeddings endpoint.
  /// </summary>
  TEmbedding = GenAI.Embeddings.TEmbedding;

  /// <summary>
  /// Collection of embedding vectors returned by the embeddings endpoint.
  /// </summary>
  TEmbeddings = GenAI.Embeddings.TEmbeddings;

  /// <summary>
  /// Asynchronous callback record for an embeddings response.
  /// </summary>
  TAsynEmbeddings = GenAI.Embeddings.TAsynEmbeddings;

  /// <summary>
  /// Promise callback record for an embeddings response.
  /// </summary>
  TPromiseEmbeddings = GenAI.Embeddings.TPromiseEmbeddings;

  {$ENDREGION}

  {$REGION 'GenAI.Files'}

  /// <summary>
  /// URL query parameters for listing files.
  /// </summary>
  TFileUrlParams = GenAI.Files.TFileUrlParams;

  /// <summary>
  /// Multipart payload for uploading a file.
  /// </summary>
  TFileUploadParams = GenAI.Files.TFileUploadParams;

  /// <summary>
  /// File resource DTO.
  /// </summary>
  TFile = GenAI.Files.TFile;

  /// <summary>
  /// Decoded content of a retrieved file.
  /// </summary>
  TFileContent = GenAI.Files.TFileContent;

  /// <summary>
  /// Paginated listing of file resources.
  /// </summary>
  TFiles = GenAI.Files.TFiles;

  /// <summary>
  /// Asynchronous callback record for a single file response.
  /// </summary>
  TAsynFile = GenAI.Files.TAsynFile;

  /// <summary>
  /// Promise callback record for a single file response.
  /// </summary>
  TPromiseFile = GenAI.Files.TPromiseFile;

  /// <summary>
  /// Asynchronous callback record for a file list response.
  /// </summary>
  TAsynFiles = GenAI.Files.TAsynFiles;

  /// <summary>
  /// Promise callback record for a file list response.
  /// </summary>
  TPromiseFiles = GenAI.Files.TPromiseFiles;

  /// <summary>
  /// Asynchronous callback record for a file content response.
  /// </summary>
  TAsynFileContent = GenAI.Files.TAsynFileContent;

  {$ENDREGION}

  {$REGION 'GenAI.Vector'}

  /// <summary>
  /// URL query parameters for listing vector stores.
  /// </summary>
  TVectorStoreUrlParam = GenAI.Vector.TVectorStoreUrlParam;

  /// <summary>
  /// Static chunking strategy details for vector-store file processing.
  /// </summary>
  TChunkStaticParams = GenAI.Vector.TChunkStaticParams;

  /// <summary>
  /// Chunking strategy parameters for vector-store file processing.
  /// </summary>
  TChunkingStrategyParams = GenAI.Vector.TChunkingStrategyParams;

  /// <summary>
  /// Expiration policy parameters for vector stores.
  /// </summary>
  TVectorStoreExpiresAfterParams = GenAI.Vector.TVectorStoreExpiresAfterParams;

  /// <summary>
  /// Vector-store creation request payload.
  /// </summary>
  TVectorStoreCreateParams = GenAI.Vector.TVectorStoreCreateParams;

  /// <summary>
  /// Vector-store update request payload.
  /// </summary>
  TVectorStoreUpdateParams = GenAI.Vector.TVectorStoreUpdateParams;

  /// <summary>
  /// Counts of files by processing state within a vector store.
  /// </summary>
  TVectorFileCounts = GenAI.Vector.TVectorFileCounts;

  /// <summary>
  /// Expiration policy returned for a vector store.
  /// </summary>
  TVectorStoreExpiresAfter = GenAI.Vector.TVectorStoreExpiresAfter;

  /// <summary>
  /// Vector-store resource DTO.
  /// </summary>
  TVectorStore = GenAI.Vector.TVectorStore;

  /// <summary>
  /// Paginated listing of vector stores.
  /// </summary>
  TVectorStores = GenAI.Vector.TVectorStores;

  /// <summary>
  /// Asynchronous callback record for a vector-store response.
  /// </summary>
  TAsynVectorStore = GenAI.Vector.TAsynVectorStore;

  /// <summary>
  /// Promise callback record for a vector-store response.
  /// </summary>
  TPromiseVectorStore = GenAI.Vector.TPromiseVectorStore;

  /// <summary>
  /// Asynchronous callback record for a vector-store list response.
  /// </summary>
  TAsynVectorStores = GenAI.Vector.TAsynVectorStores;

  /// <summary>
  /// Promise callback record for a vector-store list response.
  /// </summary>
  TPromiseVectorStores = GenAI.Vector.TPromiseVectorStores;

  {$ENDREGION}

  {$REGION 'GenAI.VectorBatch'}

  TVectorStoreBatchUrlParams = GenAI.VectorBatch.TVectorStoreBatchUrlParams;
  TVectorStoreBatchCreateParams = GenAI.VectorBatch.TVectorStoreBatchCreateParams;
  TVectorStoreBatch = GenAI.VectorBatch.TVectorStoreBatch;
  TVectorStoreBatches = GenAI.VectorBatch.TVectorStoreBatches;
  TAsynVectorStoreBatch = GenAI.VectorBatch.TAsynVectorStoreBatch;
  TPromiseVectorStoreBatch = GenAI.VectorBatch.TPromiseVectorStoreBatch;
  TAsynVectorStoreBatches = GenAI.VectorBatch.TAsynVectorStoreBatches;
  TPromiseVectorStoreBatches = GenAI.VectorBatch.TPromiseVectorStoreBatches;

  {$ENDREGION}

  {$REGION 'GenAI.VectorFiles'}

  TVectorStoreFilesUrlParams = GenAI.VectorFiles.TVectorStoreFilesUrlParams;
  TVectorStoreFilesCreateParams = GenAI.VectorFiles.TVectorStoreFilesCreateParams;
  TLastError = GenAI.VectorFiles.TLastError;
  TChunkingStrategyStatic = GenAI.VectorFiles.TChunkingStrategyStatic;
  TChunkingStrategy = GenAI.VectorFiles.TChunkingStrategy;
  TVectorStoreFile = GenAI.VectorFiles.TVectorStoreFile;
  TVectorStoreFiles = GenAI.VectorFiles.TVectorStoreFiles;
  TAsynVectorStoreFile = GenAI.VectorFiles.TAsynVectorStoreFile;
  TPromiseVectorStoreFile = GenAI.VectorFiles.TPromiseVectorStoreFile;
  TAsynVectorStoreFiles = GenAI.VectorFiles.TAsynVectorStoreFiles;
  TPromiseVectorStoreFiles = GenAI.VectorFiles.TPromiseVectorStoreFiles;

  {$ENDREGION}

  {$REGION 'GenAI.FineTuning'}


  /// <summary>
  /// Weights and Biases integration parameters.
  /// </summary>
  TWandbParams = GenAI.FineTuning.TWandbParams;

  /// <summary>
  /// External-service integration parameters for a fine-tuning job.
  /// </summary>
  TJobIntegrationParams = GenAI.FineTuning.TJobIntegrationParams;

  /// <summary>
  /// Hyperparameters configuration for a fine-tuning method.
  /// </summary>
  THyperparametersParams = GenAI.FineTuning.THyperparametersParams;

  /// <summary>
  /// Supervised fine-tuning method parameters.
  /// </summary>
  TSupervisedMethodParams = GenAI.FineTuning.TSupervisedMethodParams;

  /// <summary>
  /// DPO fine-tuning method parameters.
  /// </summary>
  TDpoMethodParams = GenAI.FineTuning.TDpoMethodParams;

  /// <summary>
  /// Fine-tuning method configuration parameters.
  /// </summary>
  TJobMethodParams = GenAI.FineTuning.TJobMethodParams;

  /// <summary>
  /// Fine-tuning job creation request payload.
  /// </summary>
  TFineTuningJobParams = GenAI.FineTuning.TFineTuningJobParams;

  /// <summary>
  /// Error detail attached to a failed fine-tuning job.
  /// </summary>
  TFineTuningJobError = GenAI.FineTuning.TFineTuningJobError;

  /// <summary>
  /// Hyperparameters reported for a fine-tuning job.
  /// </summary>
  THyperparameters = GenAI.FineTuning.THyperparameters;

  /// <summary>
  /// Weights and Biases settings reported for a fine-tuning job.
  /// </summary>
  TWanDB = GenAI.FineTuning.TWanDB;

  /// <summary>
  /// Integration entry reported for a fine-tuning job.
  /// </summary>
  TFineTuningJobIntegration = GenAI.FineTuning.FineTuningJobIntegration;

  /// <summary>
  /// Supervised method configuration reported for a fine-tuning job.
  /// </summary>
  TSupervised = GenAI.FineTuning.TSupervised;

  /// <summary>
  /// DPO method configuration reported for a fine-tuning job.
  /// </summary>
  TDpo = GenAI.FineTuning.TDpo;

  /// <summary>
  /// Method configuration reported for a fine-tuning job.
  /// </summary>
  TFineTuningMethod = GenAI.FineTuning.TFineTuningMethod;

  /// <summary>
  /// Fine-tuning job resource DTO.
  /// </summary>
  TFineTuningJob = GenAI.FineTuning.TFineTuningJob;

  /// <summary>
  /// Paginated listing of fine-tuning jobs.
  /// </summary>
  TFineTuningJobs = GenAI.FineTuning.TFineTuningJobs;

  /// <summary>
  /// Free-form data attached to a fine-tuning job event.
  /// </summary>
  TEventData = GenAI.FineTuning.TEventData;

  /// <summary>
  /// Event emitted during a fine-tuning job.
  /// </summary>
  TJobEvent = GenAI.FineTuning.TJobEvent;

  /// <summary>
  /// Paginated listing of fine-tuning job events.
  /// </summary>
  TJobEvents = GenAI.FineTuning.TJobEvents;

  /// <summary>
  /// Metrics recorded at a fine-tuning checkpoint.
  /// </summary>
  TMetrics = GenAI.FineTuning.TMetrics;

  /// <summary>
  /// Model checkpoint produced by a fine-tuning job.
  /// </summary>
  TJobCheckpoint = GenAI.FineTuning.TJobCheckpoint;

  /// <summary>
  /// Paginated listing of fine-tuning job checkpoints.
  /// </summary>
  TJobCheckpoints = GenAI.FineTuning.TJobCheckpoints;

  /// <summary>
  /// Asynchronous callback record for a single fine-tuning job response.
  /// </summary>
  TAsynFineTuningJob = GenAI.FineTuning.TAsynFineTuningJob;

  /// <summary>
  /// Asynchronous callback record for a fine-tuning job list response.
  /// </summary>
  TAsynFineTuningJobs = GenAI.FineTuning.TAsynFineTuningJobs;

  /// <summary>
  /// Asynchronous callback record for a fine-tuning job events response.
  /// </summary>
  TAsynJobEvents = GenAI.FineTuning.TAsynJobEvents;

  /// <summary>
  /// Asynchronous callback record for a fine-tuning job checkpoints response.
  /// </summary>
  TAsynJobCheckpoints = GenAI.FineTuning.TAsynJobCheckpoints;

  /// <summary>
  /// Promise callback record for a single fine-tuning job response.
  /// </summary>
  TPromiseFineTuningJob = GenAI.FineTuning.TPromiseFineTuningJob;

  /// <summary>
  /// Promise callback record for a fine-tuning job list response.
  /// </summary>
  TPromiseFineTuningJobs = GenAI.FineTuning.TPromiseFineTuningJobs;

  /// <summary>
  /// Promise callback record for a fine-tuning job events response.
  /// </summary>
  TPromiseJobEvents = GenAI.FineTuning.TPromiseJobEvents;

  /// <summary>
  /// Promise callback record for a fine-tuning job checkpoints response.
  /// </summary>
  TPromiseJobCheckpoints = GenAI.FineTuning.TPromiseJobCheckpoints;

  {$ENDREGION}

  {$REGION 'GenAI.Images'}

  /// <summary>
  /// Image generation request payload.
  /// </summary>
  TImageCreateParams = GenAI.Images.TImageCreateParams;

  /// <summary>
  /// Image edit request multipart payload.
  /// </summary>
  TImageEditParams = GenAI.Images.TImageEditParams;

  /// <summary>
  /// Image variation request multipart payload.
  /// </summary>
  TImageVariationParams = GenAI.Images.TImageVariationParams;

  /// <summary>
  /// Data object for a single generated image.
  /// </summary>
  TImageCreateData = GenAI.Images.TImageCreateData;

  /// <summary>
  /// Generated image with file-management helpers.
  /// </summary>
  TImagePart = GenAI.Images.TImagePart;

  /// <summary>
  /// Detailed input-token usage for image generation.
  /// </summary>
  TInputTokensDetails = GenAI.Images.TInputTokensDetails;

  /// <summary>
  /// Token usage information for image generation (gpt-image-1).
  /// </summary>
  TGenerateImageUsage = GenAI.Images.TGenerateImageUsage;

  /// <summary>
  /// Response object containing generated images and metadata.
  /// </summary>
  TGeneratedImages = GenAI.Images.TGeneratedImages;

  /// <summary>
  /// Asynchronous callback record for a generated images response.
  /// </summary>
  TAsynGeneratedImages = GenAI.Images.TAsynGeneratedImages;

  /// <summary>
  /// Promise callback record for a generated images response.
  /// </summary>
  TPromiseGeneratedImages = GenAI.Images.TPromiseGeneratedImages;

  {$ENDREGION}

  {$REGION 'GenAI.Moderation'}

  /// <summary>
  /// Text input parameters for a moderation request.
  /// </summary>
  TTextModerationParams = GenAI.Moderation.TTextModerationParams;

  /// <summary>
  /// URL input parameters for a moderation request.
  /// </summary>
  TUrlModerationParams = GenAI.Moderation.TUrlModerationParams;

  /// <summary>
  /// Image input parameters for a moderation request.
  /// </summary>
  TImageModerationParams = GenAI.Moderation.TImageModerationParams;

  /// <summary>
  /// Moderation request payload.
  /// </summary>
  TModerationParams = GenAI.Moderation.TModerationParams;

  /// <summary>
  /// Flag status of all moderation categories.
  /// </summary>
  TModerationCategories = GenAI.Moderation.TModerationCategories;

  /// <summary>
  /// Confidence scores for each moderation category.
  /// </summary>
  TModerationCategoryScores = GenAI.Moderation.TModerationCategoryScores;

  /// <summary>
  /// Input types associated with each flagged moderation category.
  /// </summary>
  TModerationCategoryApplied = GenAI.Moderation.TModerationCategoryApplied;

  /// <summary>
  /// Flagged moderation category and its confidence score.
  /// </summary>
  TFlaggedItem = GenAI.Moderation.TFlaggedItem;

  /// <summary>
  /// Single moderation result entry.
  /// </summary>
  TModerationResult = GenAI.Moderation.TModerationResult;

  /// <summary>
  /// Moderation response DTO.
  /// </summary>
  TModeration = GenAI.Moderation.TModeration;

  /// <summary>
  /// Asynchronous callback record for a moderation response.
  /// </summary>
  TAsynModeration = GenAI.Moderation.TAsynModeration;

  /// <summary>
  /// Promise callback record for a moderation response.
  /// </summary>
  TPromiseModeration = GenAI.Moderation.TPromiseModeration;

  {$ENDREGION}

  {$REGION 'GenAI.Uploads'}

  /// <summary>
  /// Upload creation request payload.
  /// </summary>
  TUploadCreateParams = GenAI.Uploads.TUploadCreateParams;

  /// <summary>
  /// Upload part multipart payload.
  /// </summary>
  TUploadPartParams = GenAI.Uploads.TUploadPartParams;

  /// <summary>
  /// Upload completion request payload.
  /// </summary>
  TUploadCompleteParams = GenAI.Uploads.TUploadCompleteParams;

  /// <summary>
  /// Upload resource DTO.
  /// </summary>
  TUpload = GenAI.Uploads.TUpload;

  /// <summary>
  /// Upload part resource DTO.
  /// </summary>
  TUploadPart = GenAI.Uploads.TUploadPart;

  /// <summary>
  /// Asynchronous callback record for an upload response.
  /// </summary>
  TAsynUpload = GenAI.Uploads.TAsynUpload;

  /// <summary>
  /// Promise callback record for an upload response.
  /// </summary>
  TPromiseUpload = GenAI.Uploads.TPromiseUpload;

  /// <summary>
  /// Asynchronous callback record for an upload part response.
  /// </summary>
  TAsynUploadPart = GenAI.Uploads.TAsynUploadPart;

  /// <summary>
  /// Promise callback record for an upload part response.
  /// </summary>
  TPromiseUploadPart = GenAI.Uploads.TPromiseUploadPart;

  {$ENDREGION}

  {$REGION 'GenAI.Conversations'}

  /// <summary>
  /// Conversation creation request payload.
  /// </summary>
  TConversationsParams = GenAI.Conversations.TConversationsParams;

  /// <summary>
  /// Conversation update request payload.
  /// </summary>
  TUpdateConversationsParams = GenAI.Conversations.TUpdateConversationsParams;

  /// <summary>
  /// URL query parameters for listing conversation items.
  /// </summary>
  TUrlListItemsParams = GenAI.Conversations.TUrlListItemsParams;

  /// <summary>
  /// URL query parameters for a single conversation item.
  /// </summary>
  TUrlConversationsItemParams = GenAI.Conversations.TUrlConversationsItemParams;

  /// <summary>
  /// Conversation item creation request payload.
  /// </summary>
  TConversationsItemParams = GenAI.Conversations.TConversationsItemParams;

  /// <summary>
  /// Conversation resource DTO.
  /// </summary>
  TConversations = GenAI.Conversations.TConversations;

  /// <summary>
  /// Deletion result for a conversation.
  /// </summary>
  TConversationsDeleted = GenAI.Conversations.TConversationsDeleted;

  /// <summary>
  /// Listing of conversation items.
  /// </summary>
  TConversationList = GenAI.Conversations.TConversationList;

  /// <summary>
  /// Single conversation item.
  /// </summary>
  TConversationsItem = GenAI.Conversations.TConversationsItem;

  /// <summary>
  /// Asynchronous callback record for a conversation response.
  /// </summary>
  TAsynConversations = GenAI.Conversations.TAsynConversations;

  /// <summary>
  /// Promise callback record for a conversation response.
  /// </summary>
  TPromiseConversations = GenAI.Conversations.TPromiseConversations;

  /// <summary>
  /// Asynchronous callback record for a conversation deletion response.
  /// </summary>
  TAsynConversationsDeleted = GenAI.Conversations.TAsynConversationsDeleted;

  /// <summary>
  /// Promise callback record for a conversation deletion response.
  /// </summary>
  TPromiseConversationsDeleted = GenAI.Conversations.TPromiseConversationsDeleted;

  /// <summary>
  /// Asynchronous callback record for a conversation item list response.
  /// </summary>
  TAsynConversationList = GenAI.Conversations.TAsynConversationList;

  /// <summary>
  /// Promise callback record for a conversation item list response.
  /// </summary>
  TPromiseConversationList = GenAI.Conversations.TPromiseConversationList;

  /// <summary>
  /// Asynchronous callback record for a single conversation item response.
  /// </summary>
  TAsynConversationsItem = GenAI.Conversations.TAsynConversationsItem;

  /// <summary>
  /// Promise callback record for a single conversation item response.
  /// </summary>
  TPromiseConversationsItem = GenAI.Conversations.TPromiseConversationsItem;

  {$ENDREGION}

  {$REGION 'GenAI.Containers'}

  TExpiresAfterParams = GenAI.Containers.TExpiresAfterParams;
  TContainerParams = GenAI.Containers.TContainerParams;
  TUrlContainerParams = GenAI.Containers.TUrlContainerParams;
  TExpiresAfter = GenAI.Containers.TExpiresAfter;
  TContainer = GenAI.Containers.TContainer;
  TContainerList = GenAI.Containers.TContainerList;
  TContainersDelete = GenAI.Containers.TContainersDelete;
  TAsynContainer = GenAI.Containers.TAsynContainer;
  TPromiseContainer = GenAI.Containers.TPromiseContainer;
  TAsynContainerList = GenAI.Containers.TAsynContainerList;
  TPromiseContainerList = GenAI.Containers.TPromiseContainerList;
  TAsynContainersDelete = GenAI.Containers.TAsynContainersDelete;
  TPromiseContainersDelete = GenAI.Containers.TPromiseContainersDelete;

  {$ENDREGION}

  {$REGION 'GenAI.ContainerFiles'}

  TContainerFilesParams = GenAI.ContainerFiles.TContainerFilesParams;
  TUrlContainerFileParams = GenAI.ContainerFiles.TUrlContainerFileParams;
  TContainerFile = GenAI.ContainerFiles.TContainerFile;
  TContainerFileList = GenAI.ContainerFiles.TContainerFileList;
  TContainerFilesDelete = GenAI.ContainerFiles.TContainerFilesDelete;
  TContainerFileContent = GenAI.ContainerFiles.TContainerFileContent;
  TAsynContainerFile = GenAI.ContainerFiles.TAsynContainerFile;
  TPromiseContainerFile = GenAI.ContainerFiles.TPromiseContainerFile;
  TAsynContainerFileList = GenAI.ContainerFiles.TAsynContainerFileList;
  TPromiseContainerFileList = GenAI.ContainerFiles.TPromiseContainerFileList;
  TAsynContainerFilesDelete = GenAI.ContainerFiles.TAsynContainerFilesDelete;
  TPromiseContainerFilesDelete = GenAI.ContainerFiles.TPromiseContainerFilesDelete;
  TAsynContainerFileContent = GenAI.ContainerFiles.TAsynContainerFileContent;
  TPromiseContainerFileContent = GenAI.ContainerFiles.TPromiseContainerFileContent;

  {$REGION 'GenAI.Skills'}

  TUrlSkillsParams = GenAI.Skills.TUrlSkillsParams;
  TSkillCreateParams = GenAI.Skills.TSkillCreateParams;
  TSkillUpdateParams = GenAI.Skills.TSkillUpdateParams;
  TSkill = GenAI.Skills.TSkill;
  TSkillContent = GenAI.Skills.TSkillContent;
  TSkills = GenAI.Skills.TSkills;
  TAsynSkill = GenAI.Skills.TAsynSkill;
  TPromiseSkill = GenAI.Skills.TPromiseSkill;
  TAsynSkills = GenAI.Skills.TAsynSkills;
  TPromiseSkills = GenAI.Skills.TPromiseSkills;
  TAsynSkillContent = GenAI.Skills.TAsynSkillContent;
  TPromiseSkillContent = GenAI.Skills.TPromiseSkillContent;
  TSkillVersionCreateParams = GenAI.Skills.TSkillVersionCreateParams;
  TSkillVersion = GenAI.Skills.TSkillVersion;
  TSkillVersions = GenAI.Skills.TSkillVersions;
  TAsynSkillVersion = GenAI.Skills.TAsynSkillVersion;
  TPromiseSkillVersion = GenAI.Skills.TPromiseSkillVersion;
  TAsynSkillVersions = GenAI.Skills.TAsynSkillVersions;
  TPromiseSkillVersions = GenAI.Skills.TPromiseSkillVersions;

  {$ENDREGION}

  /// <summary>
  /// Error object returned inside a batch output line.
  /// </summary>
  TBatchResponseError = GenAI.Batch.Interfaces.TBatchResponseError;

  /// <summary>
  /// Interface to build a JSONL batch body for submission.
  /// </summary>
  IBatchJSONBuilder = GenAI.Batch.Interfaces.IBatchJSONBuilder;

  /// <summary>
  /// Concrete JSONL batch body builder.
  /// </summary>
  TBatchJSONBuilder = GenAI.Batch.Builder.TBatchJSONBuilder;

  {$ENDREGION}

  {$REGION 'GenAI.Responses'}

  TResponsesParamsProc = GenAI.Responses.InputParams.TResponsesParamsProc;
  TRankingOptionsParams = GenAI.Responses.InputParams.TRankingOptionsParams;
  TOutputTopLogprobs = GenAI.Responses.InputParams.TOutputTopLogprobs;
  TConversationParams = GenAI.Responses.InputParams.TConversationParams;
  TItemAudioContent = GenAI.Responses.InputParams.TItemAudioContent;
  TItemContent = GenAI.Responses.InputParams.TItemContent;
  TContent = GenAI.Responses.InputParams.TContent;
  TInputListItem = GenAI.Responses.InputParams.TInputListItem;
  TInputMessage = GenAI.Responses.InputParams.TInputMessage;
  TItemInputMessage = GenAI.Responses.InputParams.TItemInputMessage;
  TOutputLogprobs = GenAI.Responses.InputParams.TOutputLogprobs;
  TOutputNotation = GenAI.Responses.InputParams.TOutputNotation;
  TOutputMessageContent = GenAI.Responses.InputParams.TOutputMessageContent;
  TItemOutputMessage = GenAI.Responses.InputParams.TItemOutputMessage;
  TFileSearchToolCallResult = GenAI.Responses.InputParams.TFileSearchToolCallResult;
  TFileSearchToolCall = GenAI.Responses.InputParams.TFileSearchToolCall;
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
  TPendingSafetyCheck = GenAI.Responses.InputParams.TPendingSafetyCheck;
  TComputerToolCall = GenAI.Responses.InputParams.TComputerToolCall;
  TAcknowledgedSafetyCheckParams = GenAI.Responses.InputParams.TAcknowledgedSafetyCheckParams;
  TComputerToolCallOutput = GenAI.Responses.InputParams.TComputerToolCallOutput;
  TWebSearchAction = GenAI.Responses.InputParams.TWebSearchAction;
  TSearchActionSourceParam = GenAI.Responses.InputParams.TSearchActionSourceParam;
  TSearchAction = GenAI.Responses.InputParams.TSearchAction;
  TOpenPageAction = GenAI.Responses.InputParams.TOpenPageAction;
  TFindAction = GenAI.Responses.InputParams.TFindAction;
  TWebSearchToolCall = GenAI.Responses.InputParams.TWebSearchToolCall;
  TFunctionToolCall = GenAI.Responses.InputParams.TFunctionToolCall;
  TFunctionOutput = GenAI.Responses.InputParams.TFunctionOutput;
  TFunctionInputText = GenAI.Responses.InputParams.TFunctionInputText;
  TFunctionInputImage = GenAI.Responses.InputParams.TFunctionInputImage;
  TFunctionInputFile = GenAI.Responses.InputParams.TFunctionInputFile;
  TFunctionToolCalloutput = GenAI.Responses.InputParams.TFunctionToolCalloutput;
  TReasoningTextContent = GenAI.Responses.InputParams.TReasoningTextContent;
  TReasoningObject = GenAI.Responses.InputParams.TReasoningObject;
  TImageGeneration = GenAI.Responses.InputParams.TImageGeneration;
  TCodeInterpreterOutputs = GenAI.Responses.InputParams.TCodeInterpreterOutputs;
  TCodeInterpreterOutputLogs = GenAI.Responses.InputParams.TCodeInterpreterOutputLogs;
  TCodeInterpreterOutputImage = GenAI.Responses.InputParams.TCodeInterpreterOutputImage;
  TCodeInterpreterToolCall = GenAI.Responses.InputParams.TCodeInterpreterToolCall;
  TLocalShellCallAction = GenAI.Responses.InputParams.TLocalShellCallAction;
  TLocalShellCall = GenAI.Responses.InputParams.TLocalShellCall;
  TLocalShellCallOutput = GenAI.Responses.InputParams.TLocalShellCallOutput;
  TMCPTools = GenAI.Responses.InputParams.TMCPTools;
  TMCPListTools = GenAI.Responses.InputParams.TMCPListTools;
  TMCPApprovalRequest = GenAI.Responses.InputParams.TMCPApprovalRequest;
  TMCPApprovalResponse = GenAI.Responses.InputParams.TMCPApprovalResponse;
  TMCPToolCall = GenAI.Responses.InputParams.TMCPToolCall;
  TCustomToolCallOutput = GenAI.Responses.InputParams.TCustomToolCallOutput;
  TCustomToolCall = GenAI.Responses.InputParams.TCustomToolCall;
  TInputItemReference = GenAI.Responses.InputParams.TInputItemReference;
  TPromptParams = GenAI.Responses.InputParams.TPromptParams;
  TReasoningParams = GenAI.Responses.InputParams.TReasoningParams;
  TTextFormatParams = GenAI.Responses.InputParams.TTextFormatParams;
  TTextFormatTextPrams = GenAI.Responses.InputParams.TTextFormatTextPrams;
  TTextJSONSchemaParams = GenAI.Responses.InputParams.TTextJSONSchemaParams;
  TTextJSONObjectParams = GenAI.Responses.InputParams.TTextJSONObjectParams;
  TTextParams = GenAI.Responses.InputParams.TTextParams;
  TResponseToolChoiceParams = GenAI.Responses.InputParams.TResponseToolChoiceParams;
  THostedToolParams = GenAI.Responses.InputParams.THostedToolParams;
  TFunctionToolParams = GenAI.Responses.InputParams.TFunctionToolParams;
  TMCPToolParams = GenAI.Responses.InputParams.TMCPToolParams;
  TCustomToolChoiceParams = GenAI.Responses.InputParams.TCustomToolChoiceParams;
  TResponseToolParams = GenAI.Responses.InputParams.TResponseToolParams;
  TResponseFunctionParams = GenAI.Responses.InputParams.TResponseFunctionParams;
  TFileSearchFilters = GenAI.Responses.InputParams.TFileSearchFilters;
  TComparisonFilter = GenAI.Responses.InputParams.TComparisonFilter;
  TCompoundFilter = GenAI.Responses.InputParams.TCompoundFilter;
  TResponseFileSearchParams = GenAI.Responses.InputParams.TResponseFileSearchParams;
  TResponseComputerUseParams = GenAI.Responses.InputParams.TResponseComputerUseParams;
  TResponseUserLocationParams = GenAI.Responses.InputParams.TResponseUserLocationParams;
  TResponseWebSearchParams = GenAI.Responses.InputParams.TResponseWebSearchParams;
  TMCPToolsListParams = GenAI.Responses.InputParams.TMCPToolsListParams;
  TMCPAllowedToolsParams = GenAI.Responses.InputParams.TMCPAllowedToolsParams;
  TMCPRequireApprovalParams = GenAI.Responses.InputParams.TMCPRequireApprovalParams;
  TResponseMCPToolParams = GenAI.Responses.InputParams.TResponseMCPToolParams;
  TCodeInterpreterContainerAutoParams = GenAI.Responses.InputParams.TCodeInterpreterContainerAutoParams;
  TResponseCodeInterpreterParams = GenAI.Responses.InputParams.TResponseCodeInterpreterParams;
  TInputImageMaskParams = GenAI.Responses.InputParams.TInputImageMaskParams;
  TResponseImageGenerationParams = GenAI.Responses.InputParams.TResponseImageGenerationParams;
  TLocalShellToolParams = GenAI.Responses.InputParams.TLocalShellToolParams;
  TToolParamsFormatParams = GenAI.Responses.InputParams.TToolParamsFormatParams;
  TCustomToolParams = GenAI.Responses.InputParams.TCustomToolParams;
  TWebSearchPreviewParams = GenAI.Responses.InputParams.TWebSearchPreviewParams;
  TShellCallActionParams = GenAI.Responses.InputParams.TShellCallActionParams;
  TShellCallParams = GenAI.Responses.InputParams.TShellCallParams;
  TApplyPatchOperationParams = GenAI.Responses.InputParams.TApplyPatchOperationParams;
  TApplyPatchCallParams = GenAI.Responses.InputParams.TApplyPatchCallParams;
  TToolSearchCallParams = GenAI.Responses.InputParams.TToolSearchCallParams;
  TCompactionItemParams = GenAI.Responses.InputParams.TCompactionItemParams;
  TShellCallOutputOutcomeParams = GenAI.Responses.InputParams.TShellCallOutputOutcomeParams;
  TShellCallOutputContentParams = GenAI.Responses.InputParams.TShellCallOutputContentParams;
  TShellCallOutputParams = GenAI.Responses.InputParams.TShellCallOutputParams;
  TApplyPatchCallOutputParams = GenAI.Responses.InputParams.TApplyPatchCallOutputParams;
  TToolSearchOutputParams = GenAI.Responses.InputParams.TToolSearchOutputParams;
  TResponseCompactParams = GenAI.Responses.InputParams.TResponseCompactParams;
  TResponsesParams = GenAI.Responses.InputParams.TResponsesParams;
  TContextManagementParams = GenAI.Responses.InputParams.TContextManagementParams;
  TWebSearchFiltersParams = GenAI.Responses.InputParams.TWebSearchFiltersParams;
  TApplyPatchToolParams = GenAI.Responses.InputParams.TApplyPatchToolParams;
  TToolSearchToolParams = GenAI.Responses.InputParams.TToolSearchToolParams;
  TNamespaceToolParams = GenAI.Responses.InputParams.TNamespaceToolParams;
  TContainerNetworkPolicyDomainSecretParams = GenAI.Responses.InputParams.TContainerNetworkPolicyDomainSecretParams;
  TContainerNetworkPolicyParams = GenAI.Responses.InputParams.TContainerNetworkPolicyParams;
  TContainerNetworkPolicyDisabledParams = GenAI.Responses.InputParams.TContainerNetworkPolicyDisabledParams;
  TContainerNetworkPolicyAllowlistParams = GenAI.Responses.InputParams.TContainerNetworkPolicyAllowlistParams;
  TInlineSkillSourceParams = GenAI.Responses.InputParams.TInlineSkillSourceParams;
  TContainerSkillParams = GenAI.Responses.InputParams.TContainerSkillParams;
  TSkillReferenceParams = GenAI.Responses.InputParams.TSkillReferenceParams;
  TInlineSkillParams = GenAI.Responses.InputParams.TInlineSkillParams;
  TLocalSkillParams = GenAI.Responses.InputParams.TLocalSkillParams;
  TShellEnvironmentParams = GenAI.Responses.InputParams.TShellEnvironmentParams;
  TShellContainerReferenceParams = GenAI.Responses.InputParams.TShellContainerReferenceParams;
  TShellLocalEnvironmentParams = GenAI.Responses.InputParams.TShellLocalEnvironmentParams;
  TShellContainerAutoParams = GenAI.Responses.InputParams.TShellContainerAutoParams;
  TFunctionShellToolParams = GenAI.Responses.InputParams.TFunctionShellToolParams;
  TAllowedToolsChoiceParams = GenAI.Responses.InputParams.TAllowedToolsChoiceParams;
  TDragPoint = GenAI.Responses.InputItemList.TDragPoint;
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
  TComputerAction = GenAI.Responses.InputItemList.TComputerAction;
  TToolCallAction = GenAI.Responses.InputItemList.TToolCallAction;
  TAction = GenAI.Responses.InputItemList.TAction;
  TResponseMessageAnnotationCommon = GenAI.Responses.InputItemList.TResponseMessageAnnotationCommon;
  TAnnotationFileCitation = GenAI.Responses.InputItemList.TAnnotationFileCitation;
  TAnnotationUrlCitation = GenAI.Responses.InputItemList.TAnnotationUrlCitation;
  TAnnotationContainerFileCitation = GenAI.Responses.InputItemList.TAnnotationContainerFileCitation;
  TAnnotationFilePath = GenAI.Responses.InputItemList.TAnnotationFilePath;
  TResponseMessageAnnotation = GenAI.Responses.InputItemList.TResponseMessageAnnotation;
  TItemInputAudio = GenAI.Responses.InputItemList.TItemInputAudio;
  TResponseItemContentCommon = GenAI.Responses.InputItemList.TResponseItemContentCommon;
  TResponseItemContentTextInput = GenAI.Responses.InputItemList.TResponseItemContentTextInput;
  TResponseItemContentImageInput = GenAI.Responses.InputItemList.TResponseItemContentImageInput;
  TResponseItemContentFileInput = GenAI.Responses.InputItemList.TResponseItemContentFileInput;
  TResponseItemAudioInput = GenAI.Responses.InputItemList.TResponseItemAudioInput;
  TResponseItemContentOutputText = GenAI.Responses.InputItemList.TResponseItemContentOutputText;
  TResponseItemContentRefusal = GenAI.Responses.InputItemList.TResponseItemContentRefusal;
  TResponseItemContent = GenAI.Responses.InputItemList.TResponseItemContent;
  TCodeInterpreterOutput = GenAI.Responses.InputItemList.TCodeInterpreterOutput;
  TCodeInterpreterResultFiles = GenAI.Responses.InputItemList.TCodeInterpreterResultFiles;
  TCodeInterpreterResult = GenAI.Responses.InputItemList.TCodeInterpreterResult;
  TFileSearchResult = GenAI.Responses.InputItemList.TFileSearchResult;
  TMCPListTool = GenAI.Responses.InputItemList.TMCPListTool;
  TPendingSafetyChecks = GenAI.Responses.InputItemList.TPendingSafetyChecks;
  TComputerOutput = GenAI.Responses.InputItemList.TComputerOutput;
  TAcknowledgedSafetyCheck = GenAI.Responses.InputItemList.TAcknowledgedSafetyCheck;
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
  TResponseItemLocalShellCall = GenAI.Responses.InputItemList.TResponseItemLocalShellCall;
  TResponseItemLocalShellCallOutput = GenAI.Responses.InputItemList.TResponseItemLocalShellCallOutput;
  TResponseItemMCPTool = GenAI.Responses.InputItemList.TResponseItemMCPTool;
  TResponseItemMCPList = GenAI.Responses.InputItemList.TResponseItemMCPList;
  TResponseItemMCPApprovalRequest = GenAI.Responses.InputItemList.TResponseItemMCPApprovalRequest;
  TResponseItemMCPApprovalResponse = GenAI.Responses.InputItemList.TResponseItemMCPApprovalResponse;
  TResponseItemMCPToolCall = GenAI.Responses.InputItemList.TResponseItemMCPToolCall;
  TResponseItem = GenAI.Responses.InputItemList.TResponseItem;
  TResponses = GenAI.Responses.InputItemList.TResponses;
  TSearchActionSource = GenAI.Responses.InputItemList.TSearchActionSource;

  TConversation = GenAI.Responses.OutputParams.TConversation;
  TResponseError = GenAI.Responses.OutputParams.TResponseError;
  TResponseIncompleteDetails = GenAI.Responses.OutputParams.TResponseIncompleteDetails;
  TTopLogProb = GenAI.Responses.OutputParams.TTopLogProb;
  TLogProb = GenAI.Responses.OutputParams.TLogProb;
  TDragPath = GenAI.Responses.OutputParams.TDragPath;
  TInstructionsResults = GenAI.Responses.OutputParams.TInstructionsResults;
  TInstructionsOutput = GenAI.Responses.OutputParams.TInstructionsOutput;
  TInstructionsSafetyChecks = GenAI.Responses.OutputParams.TInstructionsSafetyChecks;
  TInstructionsAction = GenAI.Responses.OutputParams.TInstructionsAction;
  TInstructionsReasoningSummary = GenAI.Responses.OutputParams.TInstructionsReasoningSummary;
  TInstructionsOutputs = GenAI.Responses.OutputParams.TInstructionsOutputs;
  TInstructionsTools = GenAI.Responses.OutputParams.TInstructionsTools;
  TInstructionsAnnotation = GenAI.Responses.OutputParams.TInstructionsAnnotation;
  TInstructionsContentInputMessage = GenAI.Responses.OutputParams.TInstructionsContentInputMessage;
  TInstructionsContent = GenAI.Responses.OutputParams.TInstructionsContent;
  TInstructionsCommon = GenAI.Responses.OutputParams.TInstructionsCommon;
  TInputOutputMessage = GenAI.Responses.OutputParams.TInputOutputMessage;
  TInstructions = GenAI.Responses.OutputParams.TInstructions;
  TResponseMessageContentCommon = GenAI.Responses.OutputParams.TResponseMessageContentCommon;
  TResponseMessageContent = GenAI.Responses.OutputParams.TResponseMessageContent;
  TResponseMessageRefusal = GenAI.Responses.OutputParams.TResponseMessageRefusal;
  TResponseContent = GenAI.Responses.OutputParams.TResponseContent;
  TResponseReasoningSummary = GenAI.Responses.OutputParams.TResponseReasoningSummary;
  TResponseRankingOptions = GenAI.Responses.OutputParams.TResponseRankingOptions;
  TResponseFileSearchFiltersCommon = GenAI.Responses.OutputParams.TResponseFileSearchFiltersCommon;
  TResponseFileSearchFiltersComparaison = GenAI.Responses.OutputParams.TResponseFileSearchFiltersComparaison;
  TResponseFileSearchFiltersCompound = GenAI.Responses.OutputParams.TResponseFileSearchFiltersCompound;
  TWebSearchFilter = GenAI.Responses.OutputParams.TWebSearchFilter;
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
  TResponseCodeInterpreterOutput = GenAI.Responses.OutputParams.TResponseCodeInterpreterOutput;
  TResponseOutputCodeInterpreter = GenAI.Responses.OutputParams.TResponseOutputCodeInterpreter;
  TResponseOutputLocalShell = GenAI.Responses.OutputParams.TResponseOutputLocalShell;
  TResponseOutputMCPTool = GenAI.Responses.OutputParams.TResponseOutputMCPTool;
  TResponseOutputMCPList = GenAI.Responses.OutputParams.TResponseOutputMCPList;
  TResponseMCPApproval = GenAI.Responses.OutputParams.TResponseMCPApproval;
  TResponseCustomTool = GenAI.Responses.OutputParams.TResponseCustomTool;
  TResponseApplyPatchOperation = GenAI.Responses.OutputParams.TResponseApplyPatchOperation;
  TResponseShellAction = GenAI.Responses.OutputParams.TResponseShellAction;
  TResponseShellOutcome = GenAI.Responses.OutputParams.TResponseShellOutcome;
  TResponseShellOutput = GenAI.Responses.OutputParams.TResponseShellOutput;
  TResponseOutput = GenAI.Responses.OutputParams.TResponseOutput;
  TPrompt = GenAI.Responses.OutputParams.TPrompt;
  TResponseReasoning = GenAI.Responses.OutputParams.TResponseReasoning;
  TResponseTextFormatCommon = GenAI.Responses.OutputParams.TResponseTextFormatCommon;
  TResponseFormatText = GenAI.Responses.OutputParams.TResponseFormatText;
  TResponseFormatJSONObject = GenAI.Responses.OutputParams.TResponseFormatJSONObject;
  TResponseFormatJSONSchema = GenAI.Responses.OutputParams.TResponseFormatJSONSchema;
  TResponseToolContainer = GenAI.Responses.OutputParams.TResponseToolContainer;
  TResponseTextFormat = GenAI.Responses.OutputParams.TResponseTextFormat;
  TResponseText = GenAI.Responses.OutputParams.TResponseText;
  TCustomToolFormat = GenAI.Responses.OutputParams.TCustomToolFormat;
  TResponseToolCommon = GenAI.Responses.OutputParams.TResponseToolCommon;
  TResponseToolFileSearch = GenAI.Responses.OutputParams.TResponseToolFileSearch;
  TResponseToolFunction = GenAI.Responses.OutputParams.TResponseToolFunction;
  TResponseToolComputerUse = GenAI.Responses.OutputParams.TResponseToolComputerUse;
  TResponseToolWebSearch = GenAI.Responses.OutputParams.TResponseToolWebSearch;
  TResponseMCPTool = GenAI.Responses.OutputParams.TResponseMCPTool;
  TResponseCodeInterpreter = GenAI.Responses.OutputParams.TResponseCodeInterpreter;
  TInputImageMask = GenAI.Responses.OutputParams.TInputImageMask;
  TResponseImageGenerationTool = GenAI.Responses.OutputParams.TResponseImageGenerationTool;
  TResponseLocalShellTool = GenAI.Responses.OutputParams.TResponseLocalShellTool;
  TCustomTool = GenAI.Responses.OutputParams.TCustomTool;
  TResponseToolWebSearchPreview = GenAI.Responses.OutputParams.TResponseToolWebSearchPreview;
  TResponseTool = GenAI.Responses.OutputParams.TResponseTool;
  TOutputTokensDetails = GenAI.Responses.OutputParams.TOutputTokensDetails;
  TResponseUsage = GenAI.Responses.OutputParams.TResponseUsage;
  TResponseToolChoice = GenAI.Responses.OutputParams.TResponseToolChoice;
  TResponseCompaction = GenAI.Responses.OutputParams.TResponseCompaction;
  TResponse = GenAI.Responses.OutputParams.TResponse;
  TUrlIncludeParams = GenAI.Responses.OutputParams.TUrlIncludeParams;
  TUrlResponseListParams = GenAI.Responses.OutputParams.TUrlResponseListParams;
  TResponseDelete = GenAI.Responses.OutputParams.TResponseDelete;
  TResponseOutputLogprobItem = GenAI.Responses.OutputParams.TResponseOutputLogprobItem;
  TResponseOutputLogprob = GenAI.Responses.OutputParams.TResponseOutputLogprob;
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
  TResponseReasoningSummaryPartAdded = GenAI.Responses.OutputParams.TResponseReasoningSummaryPartAdded;
  TResponseReasoningSummaryPartDone = GenAI.Responses.OutputParams.TResponseReasoningSummaryPartDone;
  TResponseReasoningSummaryTextDelta = GenAI.Responses.OutputParams.TResponseReasoningSummaryTextDelta;
  TResponseReasoningSummaryTextDone = GenAI.Responses.OutputParams.TResponseReasoningSummaryTextDone;
  TResponseReasoningTextDelta = GenAI.Responses.OutputParams.TResponseReasoningTextDelta;
  TResponseReasoningTextDone = GenAI.Responses.OutputParams.TResponseReasoningTextDone;
  TResponseImageGenerationCallCompleted = GenAI.Responses.OutputParams.TResponseImageGenerationCallCompleted;
  TResponseImageGenerationCallGenerating = GenAI.Responses.OutputParams.TResponseImageGenerationCallGenerating;
  TResponseImageGenerationCallInProgress = GenAI.Responses.OutputParams.TResponseImageGenerationCallInProgress;
  TResponseImageGenerationCallPartialImage = GenAI.Responses.OutputParams.TResponseImageGenerationCallPartialImage;
  TResponseMcpCallArgumentsDelta = GenAI.Responses.OutputParams.TResponseMcpCallArgumentsDelta;
  TResponseMcpCallArgumentsDone = GenAI.Responses.OutputParams.TResponseMcpCallArgumentsDone;
  TResponseMcpCallCompleted = GenAI.Responses.OutputParams.TResponseMcpCallCompleted;
  TResponseMcpCallFailed = GenAI.Responses.OutputParams.TResponseMcpCallFailed;
  TResponseMcpCallInProgress = GenAI.Responses.OutputParams.TResponseMcpCallInProgress;
  TResponseMcpListToolsCompleted = GenAI.Responses.OutputParams.TResponseMcpListToolsCompleted;
  TResponseMcpListToolsFailed = GenAI.Responses.OutputParams.TResponseMcpListToolsFailed;
  TResponseMcpListToolsInProgress = GenAI.Responses.OutputParams.TResponseMcpListToolsInProgress;
  TResponseCodeInterpreterCallInProgress = GenAI.Responses.OutputParams.TResponseCodeInterpreterCallInProgress;
  TResponseCodeInterpreterCallInterpreting = GenAI.Responses.OutputParams.TResponseCodeInterpreterCallInterpreting;
  TResponseCodeInterpreterCallCompleted = GenAI.Responses.OutputParams.TResponseCodeInterpreterCallCompleted;
  TResponseCodeInterpreterCallCodeDelta = GenAI.Responses.OutputParams.TResponseCodeInterpreterCallCodeDelta;
  TResponseCodeInterpreterCallCodeDone = GenAI.Responses.OutputParams.TResponseCodeInterpreterCallCodeDone;
  TResponseQueued = GenAI.Responses.OutputParams.TResponseQueued;
  TResponseCustomToolCallInputDelta = GenAI.Responses.OutputParams.TResponseCustomToolCallInputDelta;
  TResponseCustomToolCallInputDone = GenAI.Responses.OutputParams.TResponseCustomToolCallInputDone;
  TResponseStreamError = GenAI.Responses.OutputParams.TResponseStreamError;
  TResponseStream = GenAI.Responses.OutputParams.TResponseStream;
  TResponseEvent = GenAI.Responses.Internal.TResponseEvent;
  TAsynResponse = GenAI.Responses.Internal.TAsynResponse;
  TPromiseResponse = GenAI.Responses.Internal.TPromiseResponse;
  TAsynResponseCompaction = GenAI.Responses.Internal.TAsynResponseCompaction;
  TPromiseResponseCompaction = GenAI.Responses.Internal.TPromiseResponseCompaction;
  TAsynResponseStream = GenAI.Responses.Internal.TAsynResponseStream;
  TAsynResponseStreamFunc = GenAI.Responses.Internal.TAsynResponseStreamFunc;
  TPromiseResponseStream = GenAI.Responses.Internal.TPromiseResponseStream;
  TAsynResponseDelete = GenAI.Responses.Internal.TAsynResponseDelete;
  TPromiseResponseDelete = GenAI.Responses.Internal.TPromiseResponseDelete;
  TAsynResponses = GenAI.Responses.Internal.TAsynResponses;
  TPromiseResponses = GenAI.Responses.Internal.TPromiseResponses;

  TToolCallSnapshot = GenAI.Responses.StreamCallbacks.TToolCallSnapshot;
  TToolResultSnapshot = GenAI.Responses.StreamCallbacks.TToolResultSnapshot;
  TResponsesEventData = GenAI.Responses.StreamCallbacks.TResponsesEventData;
  TResponseStreamEventCallBack = GenAI.Responses.StreamCallbacks.TResponseStreamEventCallBack;
  IResponsesEventDispatcher = GenAI.Responses.StreamCallbacks.IResponsesEventDispatcher;
  TResponsesEventDispatcher = GenAI.Responses.StreamCallbacks.TResponsesEventDispatcher;
  IResponsesEventEngineManager = GenAI.Responses.StreamEngine.IResponsesEventEngineManager;
  TResponsesEventEngineManagerFactory = GenAI.Responses.StreamEngine.TResponsesEventEngineManagerFactory;

  {$ENDREGION}

  {$REGION 'GenAI.API'}

  /// <summary>
  /// Generic deletion response.
  /// </summary>
  TDeletion = GenAI.API.Deletion.TDeletion;

  /// <summary>
  /// Asynchronous callback record for deletion responses.
  /// </summary>
  TAsynDeletion = GenAI.API.Deletion.TAsynDeletion;

  /// <summary>
  /// Promise callback record for deletion responses.
  /// </summary>
  TPromiseDeletion = GenAI.API.Deletion.TPromiseDeletion;

  {$ENDREGION}

implementation

end.
