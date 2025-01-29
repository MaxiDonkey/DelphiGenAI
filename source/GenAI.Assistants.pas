unit GenAI.Assistants;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGenAI
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

 (*

  GenAI.Assistants - OpenAI Assistants API Integration
  -----------------------------------------------------

  This unit provides a  complete interface for managing  OpenAI assistants, allowing you
  to create, retrieve, update, list, and delete assistants,   as well as configure their
  tools and response settings.

  Key Features:
  -------------
  - Assistant Management: Create, modify,  and delete  assistants  via TAssistantsRoute.
  - Tool Integration: Enable tools such as File Search, Code Interpreter, and Functions.
  - Custom Instructions: Define assistant behavior using Instructions.
  - Response Formatting: Control output format (JSON, Text, Structured Outputs).
  - Parameter Tuning: Adjust Temperature and TopP for response precision.
  - Synchronous & Asynchronous Methods: Use AsynCreate, AsynList, etc., for non-blocking
    operations.
  - Error Handling: Manage API errors with OnError callbacks in async operations.

  Best Practices:
  ---------------
  - Choose the right model (gpt-4o, gpt-3.5-turbo) for optimal performance.
  - Use only necessary tools to improve efficiency.
  - Leverage asynchronous methods to avoid UI freezing.
  - Fine-tune assistant responses using Temperature and TopP.
  - Implement proper error handling to ensure robust API interactions.

  Example Usage:
  --------------
  var
    Assistant: TAssistant;
  begin
    Assistant := TAssistantsRoute.Create(
      procedure(Params: TAssistantsParams)
      begin
        Params.Model('gpt-4-turbo')
              .Name('My Assistant')
              .Instructions('Respond concisely and professionally.')
              .Temperature(0.7);
      end
    );
  end;

  Utilisation des Méthodes Asynchrones
  ------------------------------------
  TAssistantsRoute.AsynCreate(
    procedure(Params: TAssistantsParams)
    begin
      Params.Model('gpt-4-turbo').Name('Assistant Async');
    end,
    function: TAsynAssistant
    begin
      Result.OnSuccess := procedure(A: TAssistant)
        begin
          ShowMessage('Assistant créé : ' + A.Name);
        end;
      Result.OnError := procedure(E: Exception)
        begin
          ShowMessage('Erreur : ' + E.Message);
        end;
    end);

*)

interface

uses
  System.SysUtils, System.Classes, System.Threading, System.JSON, REST.Json.Types,
  REST.JsonReflect, System.Net.URLClient,
  GenAI.API.Params, GenAI.API, GenAI.Consts, GenAI.Types, GenAI.Async.Support,
  GenAI.Schema;

type
  /// <summary>
  /// Represents the parameters used to configure ranking options in a file search operation.
  /// </summary>
  /// <remarks>
  /// This class provides methods to set the ranker and score threshold, which define
  /// how search results are ranked and filtered. It extends <c>TJSONParam</c> to support
  /// serialization to JSON format.
  /// </remarks>
  TRankingOptionsParams = class(TJSONParam)
  public
    /// <summary>
    /// Sets the ranker to be used for the file search operation.
    /// </summary>
    /// <param name="Value">
    /// A string representing the ranker. Possible values depend on the implementation of
    /// the file search tool.
    /// </param>
    /// <returns>
    /// The <c>TRankingOptionsParams</c> instance, allowing for method chaining.
    /// </returns>
    function Ranker(const Value: string): TRankingOptionsParams;
    /// <summary>
    /// Sets the score threshold for filtering search results.
    /// </summary>
    /// <param name="Value">
    /// A floating-point value between 0 and 1, representing the minimum score that a search
    /// result must have to be included in the output. Higher values filter out lower-quality
    /// results.
    /// </param>
    /// <returns>
    /// The <c>TRankingOptionsParams</c> instance, allowing for method chaining.
    /// </returns>
    function ScoreThreshold(const Value: Double): TRankingOptionsParams;
  end;

  /// <summary>
  /// Represents the parameters used to configure the file search tool in an assistant.
  /// </summary>
  /// <remarks>
  /// This class provides methods to set the maximum number of results and ranking options
  /// for the file search operation. It extends <c>TJSONParam</c> to enable JSON serialization.
  /// </remarks>
  TFileSearchToolParams = class(TJSONParam)
  public
    /// <summary>
    /// Sets the maximum number of results to return from the file search operation.
    /// </summary>
    /// <param name="Value">
    /// An integer representing the maximum number of results to include. The value must be
    /// between 1 and 50, inclusive.
    /// </param>
    /// <returns>
    /// The <c>TFileSearchToolParams</c> instance, allowing for method chaining.
    /// </returns>
    function MaxNumResults(const Value: Integer): TFileSearchToolParams;
    /// <summary>
    /// Sets the ranking options for the file search operation.
    /// </summary>
    /// <param name="Value">
    /// A <c>TRankingOptionsParams</c> instance that specifies the ranker and score threshold
    /// for ranking and filtering search results.
    /// </param>
    /// <returns>
    /// The <c>TFileSearchToolParams</c> instance, allowing for method chaining.
    /// </returns>
    function RankingOptions(const Value: TRankingOptionsParams): TFileSearchToolParams;
  end;

  /// <summary>
  /// Represents the parameters used to define a custom function for an assistant.
  /// </summary>
  /// <remarks>
  /// This class provides methods to set the function's name, description, parameters,
  /// and strict mode. It extends <c>TJSONParam</c> to enable JSON serialization.
  /// </remarks>
  TFunctionParams = class(TJSONParam)
  public
    /// <summary>
    /// Sets the description of the function.
    /// </summary>
    /// <param name="Value">
    /// A string describing the function's purpose. This helps the assistant determine
    /// when and how to call the function.
    /// </param>
    /// <returns>
    /// The <c>TFunctionParams</c> instance, allowing for method chaining.
    /// </returns>
    function Description(const Value: string): TFunctionParams;
    /// <summary>
    /// Sets the name of the function.
    /// </summary>
    /// <param name="Value">
    /// A string representing the function's name. The name must be alphanumeric or contain
    /// underscores and dashes, with a maximum length of 64 characters.
    /// </param>
    /// <returns>
    /// The <c>TFunctionParams</c> instance, allowing for method chaining.
    /// </returns>
    function Name(const Value: string): TFunctionParams;
    /// <summary>
    /// Sets the parameters schema for the function.
    /// </summary>
    /// <param name="Value">
    /// A <c>TSchemaParams</c> instance defining the expected parameters for the function,
    /// following the JSON Schema format.
    /// </param>
    /// <returns>
    /// The <c>TFunctionParams</c> instance, allowing for method chaining.
    /// </returns>
    function Parameters(const Value: TSchemaParams): TFunctionParams; overload;
    /// <summary>
    /// Sets the parameters schema for the function using a JSON object.
    /// </summary>
    /// <param name="Value">
    /// A <c>TJSONObject</c> instance specifying the function parameters in JSON format.
    /// </param>
    /// <returns>
    /// The <c>TFunctionParams</c> instance, allowing for method chaining.
    /// </returns>
    function Parameters(const Value: TJSONObject): TFunctionParams; overload;
    /// <summary>
    /// Enables or disables strict mode for function parameters.
    /// </summary>
    /// <param name="Value">
    /// A boolean value indicating whether strict mode is enabled. If <c>true</c>,
    /// the assistant strictly follows the defined schema when generating function calls.
    /// </param>
    /// <returns>
    /// The <c>TFunctionParams</c> instance, allowing for method chaining.
    /// </returns>
    function &Strict(const Value: Boolean): TFunctionParams;
  end;

  /// <summary>
  /// Represents the parameters used to configure tools for an assistant.
  /// </summary>
  /// <remarks>
  /// This class provides methods to define different types of tools, including
  /// file search and custom functions. It extends <c>TJSONParam</c> to support
  /// JSON serialization.
  /// </remarks>
  TAssistantsToolsParams = class(TJSONParam)
  public
    /// <summary>
    /// Sets the type of tool to be used by the assistant.
    /// </summary>
    /// <param name="Value">
    /// A string representing the tool type. Valid values include "file_search"
    /// and "function".
    /// </param>
    /// <returns>
    /// The <c>TAssistantsToolsParams</c> instance, allowing for method chaining.
    /// </returns>
    function &Type(const Value: string): TAssistantsToolsParams; overload;
    /// <summary>
    /// Sets the type of tool using the <c>TAssistantsToolsType</c> enumeration.
    /// </summary>
    /// <param name="Value">
    /// A <c>TAssistantsToolsType</c> value representing the tool type.
    /// </param>
    /// <returns>
    /// The <c>TAssistantsToolsParams</c> instance, allowing for method chaining.
    /// </returns>
    function &Type(const Value: TAssistantsToolsType): TAssistantsToolsParams; overload;
    /// <summary>
    /// Configures the file search tool parameters.
    /// </summary>
    /// <param name="Value">
    /// A <c>TFileSearchToolParams</c> instance specifying the file search settings,
    /// including ranking options and result limits.
    /// </param>
    /// <returns>
    /// The <c>TAssistantsToolsParams</c> instance, allowing for method chaining.
    /// </returns>
    function FileSearch(const Value: TFileSearchToolParams): TAssistantsToolsParams;
    /// <summary>
    /// Configures a custom function tool.
    /// </summary>
    /// <param name="Value">
    /// A <c>TFunctionParams</c> instance defining the function's properties, including
    /// its name, description, and parameter schema.
    /// </param>
    /// <returns>
    /// The <c>TAssistantsToolsParams</c> instance, allowing for method chaining.
    /// </returns>
    function &Function(const Value: TFunctionParams): TAssistantsToolsParams;
  end;

  /// <summary>
  /// Represents the parameters used to configure the code interpreter tool for an assistant.
  /// </summary>
  /// <remarks>
  /// This class provides methods to specify the file IDs that the code interpreter tool
  /// can access. It extends <c>TJSONParam</c> to enable JSON serialization.
  /// </remarks>
  TCodeInterpreterParams = class(TJSONParam)
  public
    /// <summary>
    /// Sets the list of file IDs accessible by the code interpreter tool.
    /// </summary>
    /// <param name="Value">
    /// An array of strings representing the file IDs. The maximum number of files allowed
    /// is 20.
    /// </param>
    /// <returns>
    /// The <c>TCodeInterpreterParams</c> instance, allowing for method chaining.
    /// </returns>
    function FileIds(const Value: TArray<string>): TCodeInterpreterParams;
  end;

  /// <summary>
  /// Represents the parameters used to configure static chunking for file processing.
  /// </summary>
  /// <remarks>
  /// This class provides methods to set the maximum chunk size and overlap between chunks.
  /// It is used to control how large text or data is divided into manageable parts for
  /// processing. The class extends <c>TJSONParam</c> to enable JSON serialization.
  /// </remarks>
  TChunkStaticParams = class(TJSONParam)
  public
    /// <summary>
    /// Sets the maximum size of each chunk in tokens.
    /// </summary>
    /// <param name="Value">
    /// An integer representing the maximum number of tokens allowed per chunk.
    /// Larger values allow bigger chunks, but may impact performance.
    /// </param>
    /// <returns>
    /// The <c>TChunkStaticParams</c> instance, allowing for method chaining.
    /// </returns>
    function MaxChunkSizeTokens(const Value: Integer): TChunkStaticParams;
    /// <summary>
    /// Sets the overlap size between consecutive chunks in tokens.
    /// </summary>
    /// <param name="Value">
    /// An integer representing the number of tokens that should overlap between
    /// consecutive chunks. This ensures continuity between chunks.
    /// </param>
    /// <returns>
    /// The <c>TChunkStaticParams</c> instance, allowing for method chaining.
    /// </returns>
    function ChunkOverlapTokens(const Value: Integer): TChunkStaticParams;
  end;

  /// <summary>
  /// Represents the parameters used to configure the chunking strategy for file processing.
  /// </summary>
  /// <remarks>
  /// This class provides methods to define the type of chunking strategy and configure
  /// specific parameters, such as static chunking options. It extends <c>TJSONParam</c>
  /// to enable JSON serialization.
  /// </remarks>
  TChunkingStrategyParams = class(TJSONParam)
  public
    /// <summary>
    /// Sets the type of chunking strategy to use.
    /// </summary>
    /// <param name="Value">
    /// A string representing the type of chunking strategy. This could include strategies
    /// like "static" or others depending on the use case.
    /// </param>
    /// <returns>
    /// The <c>TChunkingStrategyParams</c> instance, allowing for method chaining.
    /// </returns>
    function &Type(const Value: string): TChunkingStrategyParams; overload;
    /// <summary>
    /// Sets the type of chunking strategy using the <c>TChunkingStrategyType</c> enumeration.
    /// </summary>
    /// <param name="Value">
    /// A <c>TChunkingStrategyType</c> enumeration value representing the chunking strategy.
    /// </param>
    /// <returns>
    /// The <c>TChunkingStrategyParams</c> instance, allowing for method chaining.
    /// </returns>
    function &Type(const Value: TChunkingStrategyType): TChunkingStrategyParams; overload;
    /// <summary>
    /// Configures the static chunking parameters for the chunking strategy.
    /// </summary>
    /// <param name="Value">
    /// A <c>TChunkStaticParams</c> instance that defines the static chunking parameters,
    /// such as maximum chunk size and overlap size.
    /// </param>
    /// <returns>
    /// The <c>TChunkingStrategyParams</c> instance, allowing for method chaining.
    /// </returns>
    function Static(const Value: TChunkStaticParams): TChunkingStrategyParams;
  end;

  /// <summary>
  /// Represents the parameters used to configure vector stores for file search operations.
  /// </summary>
  /// <remarks>
  /// This class provides methods to specify file IDs, chunking strategies, and metadata
  /// associated with vector stores. It extends <c>TJSONParam</c> to enable JSON serialization.
  /// </remarks>
  TVectorStoresParams = class(TJSONParam)
  public
    /// <summary>
    /// Sets the list of file IDs to be included in the vector store.
    /// </summary>
    /// <param name="Value">
    /// An array of strings representing the file IDs to include in the vector store.
    /// </param>
    /// <returns>
    /// The <c>TVectorStoresParams</c> instance, allowing for method chaining.
    /// </returns>
    function FileIds(const Value: TArray<string>): TVectorStoresParams;
    /// <summary>
    /// Configures the chunking strategy for processing files in the vector store.
    /// </summary>
    /// <param name="Value">
    /// A <c>TChunkingStrategyParams</c> instance specifying the chunking strategy to use,
    /// such as static chunking with overlap and size settings.
    /// </param>
    /// <returns>
    /// The <c>TVectorStoresParams</c> instance, allowing for method chaining.
    /// </returns>
    function ChunkingStrategy(const Value: TChunkingStrategyParams): TVectorStoresParams;
    /// <summary>
    /// Sets the metadata for the vector store.
    /// </summary>
    /// <param name="Value">
    /// A <c>TJSONObject</c> instance containing key-value pairs that represent additional
    /// metadata about the vector store. Keys can be up to 64 characters, and values up
    /// to 512 characters.
    /// </param>
    /// <returns>
    /// The <c>TVectorStoresParams</c> instance, allowing for method chaining.
    /// </returns>
    function Metadata(const Value: TJSONObject): TVectorStoresParams;
  end;

  /// <summary>
  /// Represents the parameters used to configure file search operations in an assistant.
  /// </summary>
  /// <remarks>
  /// This class provides methods to specify vector store IDs and configure vector stores
  /// for efficient file searching. It extends <c>TJSONParam</c> to enable JSON serialization.
  /// </remarks>
  TFileSearchParams = class(TJSONParam)
  public
    /// <summary>
    /// Sets the list of vector store IDs used for the file search.
    /// </summary>
    /// <param name="Value">
    /// An array of strings representing the IDs of the vector stores to use during
    /// the file search.
    /// </param>
    /// <returns>
    /// The <c>TFileSearchParams</c> instance, allowing for method chaining.
    /// </returns>
    function VectorStoreIds(const Value: TArray<string>): TFileSearchParams;
    /// <summary>
    /// Configures the vector stores for the file search operation.
    /// </summary>
    /// <param name="Value">
    /// An array of <c>TVectorStoresParams</c> instances that define the properties of
    /// the vector stores, including file IDs, chunking strategy, and metadata.
    /// </param>
    /// <returns>
    /// The <c>TFileSearchParams</c> instance, allowing for method chaining.
    /// </returns>
    function VectorStores(const Value: TArray<TVectorStoresParams>): TFileSearchParams;
  end;

  /// <summary>
  /// Represents the parameters used to configure tool resources for an assistant.
  /// </summary>
  /// <remarks>
  /// This class provides methods to specify resources for the code interpreter and
  /// file search tools. It extends <c>TJSONParam</c> to enable JSON serialization.
  /// </remarks>
  TToolResourcesParams = class(TJSONParam)
  public
    /// <summary>
    /// Configures the code interpreter tool with the specified parameters.
    /// </summary>
    /// <param name="Value">
    /// A <c>TCodeInterpreterParams</c> instance that defines the files available
    /// to the code interpreter.
    /// </param>
    /// <returns>
    /// The <c>TToolResourcesParams</c> instance, allowing for method chaining.
    /// </returns>
    function CodeInterpreter(const Value: TCodeInterpreterParams): TToolResourcesParams; overload;
    /// <summary>
    /// Configures the code interpreter tool with a list of file IDs.
    /// </summary>
    /// <param name="FileIds">
    /// An array of strings representing the file IDs available to the code interpreter.
    /// </param>
    /// <returns>
    /// The <c>TToolResourcesParams</c> instance, allowing for method chaining.
    /// </returns>
    function CodeInterpreter(const FileIds: TArray<string>): TToolResourcesParams; overload;
    /// <summary>
    /// Configures the file search tool with the specified parameters.
    /// </summary>
    /// <param name="Value">
    /// A <c>TFileSearchParams</c> instance that defines the vector stores used
    /// for file searching.
    /// </param>
    /// <returns>
    /// The <c>TToolResourcesParams</c> instance, allowing for method chaining.
    /// </returns>
    function FileSearch(const Value: TFileSearchParams): TToolResourcesParams;
  end;

  /// <summary>
  /// Represents the parameters used to define a JSON schema for structured responses.
  /// </summary>
  /// <remarks>
  /// This class provides methods to specify the schema name, description, and structure.
  /// It allows strict schema adherence for function calls and output validation.
  /// Extends <c>TJSONParam</c> to enable JSON serialization.
  /// </remarks>
  TJsonSchemaParams = class(TJSONParam)
  public
    /// <summary>
    /// Sets the description of the JSON schema.
    /// </summary>
    /// <param name="Value">
    /// A string describing the purpose and structure of the JSON schema. This helps
    /// the assistant understand the format of expected outputs.
    /// </param>
    /// <returns>
    /// The <c>TJsonSchemaParams</c> instance, allowing for method chaining.
    /// </returns>
    function Description(const Value: string): TJsonSchemaParams;
    /// <summary>
    /// Sets the name of the JSON schema.
    /// </summary>
    /// <param name="Value">
    /// A string representing the name of the schema. The name must be alphanumeric or
    /// contain underscores and dashes, with a maximum length of 64 characters.
    /// </param>
    /// <returns>
    /// The <c>TJsonSchemaParams</c> instance, allowing for method chaining.
    /// </returns>
    function Name(const Value: string): TJsonSchemaParams;
    /// <summary>
    /// Sets the schema definition using a <c>TSchemaParams</c> instance.
    /// </summary>
    /// <param name="Value">
    /// A <c>TSchemaParams</c> instance defining the structure and expected properties
    /// of the JSON schema.
    /// </param>
    /// <returns>
    /// The <c>TJsonSchemaParams</c> instance, allowing for method chaining.
    /// </returns>
    function Schema(const Value: TSchemaParams): TJsonSchemaParams; overload;
    /// <summary>
    /// Sets the schema definition using a JSON object.
    /// </summary>
    /// <param name="Value">
    /// A <c>TJSONObject</c> instance representing the JSON schema definition.
    /// </param>
    /// <returns>
    /// The <c>TJsonSchemaParams</c> instance, allowing for method chaining.
    /// </returns>
    function Schema(const Value: TJSONObject): TJsonSchemaParams; overload;
    /// <summary>
    /// Enables or disables strict schema adherence.
    /// </summary>
    /// <param name="Value">
    /// A boolean value indicating whether strict mode is enabled. If <c>true</c>,
    /// the model follows the exact schema definition when generating responses.
    /// </param>
    /// <returns>
    /// The <c>TJsonSchemaParams</c> instance, allowing for method chaining.
    /// </returns>
    function &Strict(const Value: Boolean): TJsonSchemaParams;
  end;

  /// <summary>
  /// Represents the parameters used to configure the response format for an assistant.
  /// </summary>
  /// <remarks>
  /// This class provides methods to define the type of response format, including JSON
  /// schema and structured outputs. It extends <c>TJSONParam</c> to enable JSON serialization.
  /// </remarks>
  TResponseFormatParams = class(TJSONParam)
  public
    /// <summary>
    /// Sets the type of response format to use.
    /// </summary>
    /// <param name="Value">
    /// A string representing the response format type. Common values include "text",
    /// "json_object", and "json_schema".
    /// </param>
    /// <returns>
    /// The <c>TResponseFormatParams</c> instance, allowing for method chaining.
    /// </returns>
    function &Type(const Value: string): TResponseFormatParams; overload;
    /// <summary>
    /// Sets the type of response format using the <c>TResponseFormatType</c> enumeration.
    /// </summary>
    /// <param name="Value">
    /// A <c>TResponseFormatType</c> enumeration value specifying the response format type.
    /// </param>
    /// <returns>
    /// The <c>TResponseFormatParams</c> instance, allowing for method chaining.
    /// </returns>
    function &Type(const Value: TResponseFormatType): TResponseFormatParams; overload;
    /// <summary>
    /// Configures a JSON schema for the response format.
    /// </summary>
    /// <param name="Value">
    /// A <c>TJsonSchemaParams</c> instance that defines the structure and properties
    /// of the JSON schema for the response.
    /// </param>
    /// <returns>
    /// The <c>TResponseFormatParams</c> instance, allowing for method chaining.
    /// </returns>
    function JsonSchema(const Value: TJsonSchemaParams): TResponseFormatParams; overload;
    /// <summary>
    /// Configures a JSON schema for the response format.
    /// </summary>
    /// <param name="Value">
    /// A <c>TJsonObject</c> instance that defines the structure and properties
    /// of the JSON schema for the response.
    /// </param>
    /// <returns>
    /// The <c>TResponseFormatParams</c> instance, allowing for method chaining.
    /// </returns>
    function JsonSchema(const Value: TJsonObject): TResponseFormatParams; overload;
  end;

  /// <summary>
  /// Represents the parameters used to configure an assistant.
  /// </summary>
  /// <remarks>
  /// This class provides methods to specify the assistant's model, name, description,
  /// instructions, tools, and response format. It extends <c>TJSONParam</c> to enable
  /// JSON serialization.
  /// </remarks>
  TAssistantsParams = class(TJSONParam)
  public
    /// <summary>
    /// Sets the model ID to be used by the assistant.
    /// </summary>
    /// <param name="Value">
    /// A string representing the model ID. Available models can be retrieved using the
    /// OpenAI API.
    /// </param>
    /// <returns>
    /// The <c>TAssistantsParams</c> instance, allowing for method chaining.
    /// </returns>
    function Model(const Value: string): TAssistantsParams;
    /// <summary>
    /// Sets the name of the assistant.
    /// </summary>
    /// <param name="Value">
    /// A string representing the assistant's name. The maximum length is 256 characters.
    /// </param>
    /// <returns>
    /// The <c>TAssistantsParams</c> instance, allowing for method chaining.
    /// </returns>
    function Name(const Value: string): TAssistantsParams;
    /// <summary>
    /// Sets the description of the assistant.
    /// </summary>
    /// <param name="Value">
    /// A string describing the assistant's purpose. The maximum length is 512 characters.
    /// </param>
    /// <returns>
    /// The <c>TAssistantsParams</c> instance, allowing for method chaining.
    /// </returns>
    function Description(const Value: string): TAssistantsParams;
    /// <summary>
    /// Sets the system instructions for the assistant.
    /// </summary>
    /// <param name="Value">
    /// A string containing instructions that guide the assistant's behavior. The maximum
    /// length is 256,000 characters.
    /// </param>
    /// <returns>
    /// The <c>TAssistantsParams</c> instance, allowing for method chaining.
    /// </returns>
    function Instructions(const Value: string): TAssistantsParams;
    /// <summary>
    /// Configures the tools that the assistant can use.
    /// </summary>
    /// <param name="Value">
    /// An array of <c>TAssistantsToolsParams</c> instances defining the tools, such as
    /// code interpreter, file search, or function calls.
    /// </param>
    /// <returns>
    /// The <c>TAssistantsParams</c> instance, allowing for method chaining.
    /// </returns>
    function Tools(const Value: TArray<TAssistantsToolsParams>): TAssistantsParams;
    /// <summary>
    /// Configures the tool resources for the assistant.
    /// </summary>
    /// <param name="Value">
    /// A <c>TToolResourcesParams</c> instance specifying the resources available to the
    /// assistant's tools.
    /// </param>
    /// <returns>
    /// The <c>TAssistantsParams</c> instance, allowing for method chaining.
    /// </returns>
    function ToolResources(const Value: TToolResourcesParams): TAssistantsParams;
    /// <summary>
    /// Sets metadata for the assistant.
    /// </summary>
    /// <param name="Value">
    /// A <c>TJSONObject</c> instance containing metadata as key-value pairs. Keys can be
    /// up to 64 characters, and values up to 512 characters.
    /// </param>
    /// <returns>
    /// The <c>TAssistantsParams</c> instance, allowing for method chaining.
    /// </returns>
    function Metadata(const Value: TJSONObject): TAssistantsParams;
    /// <summary>
    /// Sets the temperature parameter for response randomness.
    /// </summary>
    /// <param name="Value">
    /// A floating-point number between 0 and 2. Higher values (e.g., 0.8) make the
    /// output more random, while lower values (e.g., 0.2) make it more deterministic.
    /// </param>
    /// <returns>
    /// The <c>TAssistantsParams</c> instance, allowing for method chaining.
    /// </returns>
    function Temperature(const Value: Double): TAssistantsParams;
    /// <summary>
    /// Sets the top-p parameter for nucleus sampling.
    /// </summary>
    /// <param name="Value">
    /// A floating-point number between 0 and 1. Lower values limit token selection to
    /// the most probable choices (e.g., 0.1 means only the top 10% probability mass is
    /// considered).
    /// </param>
    /// <returns>
    /// The <c>TAssistantsParams</c> instance, allowing for method chaining.
    /// </returns>
    function TopP(const Value: Double): TAssistantsParams;
    /// <summary>
    /// Sets the response format type.
    /// </summary>
    /// <param name="Value">
    /// A string representing the response format type. The default is "auto". Other values
    /// include "json_object" and "json_schema" for structured outputs.
    /// </param>
    /// <returns>
    /// The <c>TAssistantsParams</c> instance, allowing for method chaining.
    /// </returns>
    function ResponseFormat(const Value: string = 'auto'): TAssistantsParams; overload;
    /// <summary>
    /// Configures the response format using a <c>TResponseFormatParams</c> instance.
    /// </summary>
    /// <param name="Value">
    /// A <c>TResponseFormatParams</c> instance defining the response format properties.
    /// </param>
    /// <returns>
    /// The <c>TAssistantsParams</c> instance, allowing for method chaining.
    /// </returns>
    function ResponseFormat(const Value: TResponseFormatParams): TAssistantsParams; overload;
    /// <summary>
    /// Configures the response format using a <c>TJSONObject</c> instance.
    /// </summary>
    /// <param name="Value">
    /// A <c>TJSONObject</c> instance defining the response format properties.
    /// </param>
    /// <returns>
    /// The <c>TAssistantsParams</c> instance, allowing for method chaining.
    /// </returns>
    function ResponseFormat(const Value: TJSONObject): TAssistantsParams; overload;
  end;

  /// <summary>
  /// Represents a generic advanced list structure for handling API responses.
  /// </summary>
  /// <remarks>
  /// This class is a generic container for handling paginated API responses. It provides
  /// properties to store the retrieved data, pagination information, and object metadata.
  /// The generic type parameter <c>T</c> must be a class with a parameterless constructor.
  /// </remarks>
  /// <typeparam name="T">
  /// The class type of objects contained in the list. The type must have a parameterless
  /// constructor.
  /// </typeparam>
  TAdvancedList<T: class, constructor> = class(TJSONFingerprint)
    FObject: string;
    FData: TArray<T>;
    [JsonNameAttribute('has_more')]
    FHasMore: Boolean;
    [JsonNameAttribute('first_id')]
    FFirstId: string;
    [JsonNameAttribute('last_id')]
    FLastId: string;
  public
    /// <summary>
    /// Represents the type of object contained in the list.
    /// </summary>
    property &Object: string read FObject write FObject;
    /// <summary>
    /// Stores the list of retrieved objects.
    /// </summary>
    property Data: TArray<T> read FData write FData;
    /// <summary>
    /// Indicates whether there are more results available in the API pagination.
    /// </summary>
    property HasMore: Boolean read FHasMore write FHasMore;
    /// <summary>
    /// The ID of the first object in the current result set.
    /// </summary>
    property FirstId: string read FFirstId write FFirstId;
    /// <summary>
    /// The ID of the last object in the current result set.
    /// </summary>
    property LastId: string read FLastId write FLastId;
    destructor Destroy; override;
  end;

  /// <summary>
  /// Represents the ranking options for a file search operation.
  /// </summary>
  /// <remarks>
  /// This class provides properties to configure the ranking mechanism of a file search,
  /// including the ranker type and score threshold for filtering results.
  /// </remarks>
  TRankingOptions = class
  private
    FRanker: string;
    [JsonNameAttribute('score_threshold')]
    FScoreThreshold: Double;
  public
    /// <summary>
    /// Specifies the ranking algorithm used for the file search.
    /// </summary>
    property Ranker: string read FRanker write FRanker;
    /// <summary>
    /// Defines the minimum score threshold for search results.
    /// </summary>
    /// <remarks>
    /// Only results with a score greater than or equal to this threshold will be included
    /// in the output. The value must be a floating-point number between 0 and 1.
    /// </remarks>
    property ScoreThreshold: Double read FScoreThreshold write FScoreThreshold;
  end;

  /// <summary>
  /// Represents the file search configuration for an assistant.
  /// </summary>
  /// <remarks>
  /// This class provides properties to define the file search behavior, including the
  /// maximum number of search results and ranking options for filtering results.
  /// </remarks>
  TAssistantsFileSearch = class
  private
    [JsonNameAttribute('max_num_results')]
    FMaxNumResults: Int64;
    [JsonNameAttribute('ranking_options')]
    FRankingOptions: TRankingOptions;
  public
    /// <summary>
    /// Specifies the maximum number of results to return from the file search.
    /// </summary>
    /// <remarks>
    /// The value must be an integer between 1 and 50. The default is 20 for GPT-4 models
    /// and 5 for GPT-3.5-turbo.
    /// </remarks>
    property MaxNumResults: Int64 read FMaxNumResults write FMaxNumResults;
    /// <summary>
    /// Defines the ranking options used for filtering and ordering search results.
    /// </summary>
    /// <remarks>
    /// The ranking options allow customization of the ranking algorithm and the minimum
    /// score threshold required for results to be included.
    /// </remarks>
    property RankingOptions: TRankingOptions read FRankingOptions write FRankingOptions;
    destructor Destroy; override;
  end;

  /// <summary>
  /// Represents a custom function definition for an assistant.
  /// </summary>
  /// <remarks>
  /// This class provides properties to define a function's name, description, parameters,
  /// and strict mode. Functions allow the assistant to execute predefined operations.
  /// </remarks>
  TFunction = class
  private
    FDescription: string;
    FName: string;
    FParameters: string;
    FStrict: Boolean;
  public
    /// <summary>
    /// A brief description of what the function does.
    /// </summary>
    /// <remarks>
    /// This description helps the assistant determine when and how to call the function.
    /// </remarks>
    property Description: string read FDescription write FDescription;
    /// <summary>
    /// The name of the function.
    /// </summary>
    /// <remarks>
    /// The function name must be alphanumeric and can contain underscores and dashes.
    /// The maximum length is 64 characters.
    /// </remarks>
    property Name: string read FName write FName;
    /// <summary>
    /// Defines the parameters the function accepts.
    /// </summary>
    /// <remarks>
    /// This property specifies the expected input format using a JSON schema. It ensures
    /// that function calls follow a structured parameter format.
    /// </remarks>
    property Parameters: string read FParameters write FParameters;
    /// <summary>
    /// Determines whether the function follows strict schema adherence.
    /// </summary>
    /// <remarks>
    /// If set to <c>true</c>, the function strictly adheres to the defined parameter schema.
    /// This ensures structured outputs and prevents deviations from the expected format.
    /// </remarks>
    property Strict: Boolean read FStrict write FStrict;
  end;

  /// <summary>
  /// Represents a tool configuration for an assistant.
  /// </summary>
  /// <remarks>
  /// This class provides properties to define different types of tools that an assistant
  /// can use, such as file search or custom functions. Each tool configuration includes
  /// specific settings based on its type.
  /// </remarks>
  TAssistantsTools = class
  private
    [JsonReflectAttribute(ctString, rtString, TAssistantsToolsTypeInterceptor)]
    FType: TAssistantsToolsType;
    [JsonNameAttribute('file_search')]
    FFileSearch: TAssistantsFileSearch;
    FFunction: TFunction;
  public
    /// <summary>
    /// Specifies the type of tool.
    /// </summary>
    /// <remarks>
    /// The type can be "file_search", "code_interpreter", or "function", depending on the
    /// tool's purpose. This determines which configuration properties are applicable.
    /// </remarks>
    property &Type: TAssistantsToolsType read FType write FType;
    /// <summary>
    /// Configuration settings for the file search tool.
    /// </summary>
    /// <remarks>
    /// This property is applicable only if the tool type is "file_search". It allows
    /// customization of file search behavior, including maximum results and ranking options.
    /// </remarks>
    property FileSearch: TAssistantsFileSearch read FFileSearch write FFileSearch;
    /// <summary>
    /// Configuration settings for a custom function tool.
    /// </summary>
    /// <remarks>
    /// This property is applicable only if the tool type is "function". It defines the
    /// function's name, description, parameters, and strict mode.
    /// </remarks>
    property &Function: TFunction read FFunction write FFunction;
    destructor Destroy; override;
  end;

  /// <summary>
  /// Represents the configuration for the code interpreter tool.
  /// </summary>
  /// <remarks>
  /// This class provides properties to specify the files accessible to the code interpreter.
  /// It enables the assistant to process and analyze code-related files.
  /// </remarks>
  TCodeInterpreter = class
  private
    [JsonNameAttribute('file_ids')]
    FFileIds: TArray<string>;
  public
    /// <summary>
    /// Specifies the list of file IDs accessible to the code interpreter.
    /// </summary>
    /// <remarks>
    /// This property allows defining which files the code interpreter can process.
    /// A maximum of 20 file IDs can be specified.
    /// </remarks>
    property FileIds: TArray<string> read FFileIds write FFileIds;
  end;

  /// <summary>
  /// Represents the configuration for the file search tool.
  /// </summary>
  /// <remarks>
  /// This class provides properties to specify the vector stores used for file searching.
  /// It enables the assistant to perform efficient and accurate file searches.
  /// </remarks>
  TFileSearch = class
  private
    [JsonNameAttribute('vector_store_ids')]
    FVectorStoreIds: TArray<string>;
  public
    /// <summary>
    /// Specifies the list of vector store IDs used for the file search.
    /// </summary>
    /// <remarks>
    /// This property allows defining the vector stores that the file search tool will query.
    /// The vector stores contain pre-processed data to optimize search operations.
    /// </remarks>
    property VectorStoreIds: TArray<string> read FVectorStoreIds write FVectorStoreIds;
  end;

  /// <summary>
  /// Represents the resources used by the tools configured for an assistant.
  /// </summary>
  /// <remarks>
  /// This class provides properties to define the resources available to tools such as
  /// the code interpreter and file search. These resources ensure that tools can perform
  /// their operations efficiently.
  /// </remarks>
  TToolResources = class
  private
    [JsonNameAttribute('code_interpreter')]
    FCodeInterpreter: TCodeInterpreter;
    [JsonNameAttribute('file_search')]
    FFileSearch: TFileSearch;
  public
    /// <summary>
    /// Specifies the configuration for the code interpreter tool.
    /// </summary>
    /// <remarks>
    /// This property allows defining the files accessible to the code interpreter tool,
    /// enabling it to process and analyze code-related files.
    /// </remarks>
    property CodeInterpreter: TCodeInterpreter read FCodeInterpreter write FCodeInterpreter;
    /// <summary>
    /// Specifies the configuration for the file search tool.
    /// </summary>
    /// <remarks>
    /// This property allows defining the vector stores that the file search tool will use
    /// for querying and retrieving relevant results.
    /// </remarks>
    property FileSearch: TFileSearch read FFileSearch write FFileSearch;
    destructor Destroy; override;
  end;

  /// <summary>
  /// Represents an assistant configuration and its associated properties.
  /// </summary>
  /// <remarks>
  /// This class provides properties to define the assistant's settings, including its
  /// name, model, instructions, tools, and metadata. It extends <c>TJSONFingerprint</c>
  /// to support JSON serialization.
  /// </remarks>
  TAssistant = class(TJSONFingerprint)
  private
    FId: string;
    [JsonNameAttribute('created_at')]
    FCreatedAt: Int64;
    FObject: string;
    FName: string;
    FDescription: string;
    FModel: string;
    FInstructions: string;
    FTools: TArray<TAssistantsTools>;
    [JsonNameAttribute('tool_resources')]
    FToolResources: TToolResources;
    FMetadata: string;
    FTemperature: Double;
    [JsonNameAttribute('top_p')]
    FTopP: Double;
    [JsonNameAttribute('response_format')]
    FResponseFormat: string;
  public
    /// <summary>
    /// The unique identifier of the assistant.
    /// </summary>
    property Id: string read FId write FId;
    /// <summary>
    /// The creation timestamp of the assistant.
    /// </summary>
    /// <remarks>
    /// This property stores the Unix timestamp (in seconds) indicating when the assistant
    /// was created.
    /// </remarks>
    property CreatedAt: Int64 read FCreatedAt write FCreatedAt;
    /// <summary>
    /// The object type, which is always "assistant".
    /// </summary>
    property &Object: string read FObject write FObject;
    /// <summary>
    /// The name of the assistant.
    /// </summary>
    /// <remarks>
    /// The assistant's name is a descriptive identifier with a maximum length of 256 characters.
    /// </remarks>
    property Name: string read FName write FName;
    /// <summary>
    /// A brief description of the assistant.
    /// </summary>
    /// <remarks>
    /// The description provides an overview of the assistant's purpose, with a maximum
    /// length of 512 characters.
    property Description: string read FDescription write FDescription;
    /// <summary>
    /// The model used by the assistant.
    /// </summary>
    /// <remarks>
    /// The model defines the assistant's capabilities. Available models can be retrieved
    /// using the OpenAI API.
    /// </remarks>
    property Model: string read FModel write FModel;
    /// <summary>
    /// The system instructions that guide the assistant's behavior.
    /// </summary>
    /// <remarks>
    /// Instructions define how the assistant should respond and interact. The maximum
    /// length is 256,000 characters.
    /// </remarks>
    property Instructions: string read FInstructions write FInstructions;
    /// <summary>
    /// The list of tools enabled for the assistant.
    /// </summary>
    /// <remarks>
    /// This property specifies the tools the assistant can use, such as file search,
    /// code interpreter, or custom functions.
    /// </remarks>
    property Tools: TArray<TAssistantsTools> read FTools write FTools;
    /// <summary>
    /// The resources available to the assistant's tools.
    /// </summary>
    property ToolResources: TToolResources read FToolResources write FToolResources;
    /// <summary>
    /// Metadata associated with the assistant.
    /// </summary>
    /// <remarks>
    /// This property stores additional information about the assistant as key-value pairs.
    /// Each key can have a maximum length of 64 characters, and each value up to 512 characters.
    /// </remarks>
    property Metadata: string read FMetadata write FMetadata;
    /// <summary>
    /// The temperature setting for response randomness.
    /// </summary>
    /// <remarks>
    /// A value between 0 and 2, where higher values (e.g., 0.8) make responses more random,
    /// while lower values (e.g., 0.2) make them more focused and deterministic.
    /// </remarks>
    property Temperature: Double read FTemperature write FTemperature;
    /// <summary>
    /// The top-p parameter for nucleus sampling.
    /// </summary>
    /// <remarks>
    /// A value between 0 and 1. Lower values limit token selection to the most probable
    /// choices (e.g., 0.1 means only the top 10% probability mass is considered).
    /// </remarks>
    property TopP: Double read FTopP write FTopP;
    /// <summary>
    /// The format in which the assistant should generate responses.
    /// </summary>
    /// <remarks>
    /// Possible values include "auto", "json_object", or "json_schema". Structured
    /// response formats ensure that outputs match a predefined schema.
    /// </remarks>
    property ResponseFormat: string read FResponseFormat write FResponseFormat;
    destructor Destroy; override;
  end;

  /// <summary>
  /// Represents a list of assistant objects.
  /// </summary>
  /// <remarks>
  /// This type is a specialization of <c>TAdvancedList</c> for handling a collection of
  /// <c>TAssistant</c> objects. It includes pagination metadata and provides access to
  /// multiple assistant configurations in a structured format.
  /// </remarks>
  TAssistants = TAdvancedList<TAssistant>;

  /// <summary>
  /// Represents the response returned after deleting an assistant.
  /// </summary>
  /// <remarks>
  /// This class provides information about the deletion status of an assistant, including
  /// its ID, object type, and whether the deletion was successful. It extends
  /// <c>TJSONFingerprint</c> for JSON serialization.
  /// </remarks>
  TAssistantDeletion = class(TJSONFingerprint)
  private
    FId: string;
    FObject: string;
    FDeleted: Boolean;
  public
    /// <summary>
    /// The unique identifier of the deleted assistant.
    /// </summary>
    property Id: string read FId write FId;
    /// <summary>
    /// The object type, which is always "assistant".
    /// </summary>
    property &Object: string read FObject write FObject;
    /// <summary>
    /// Indicates whether the assistant was successfully deleted.
    /// </summary>
    /// <remarks>
    /// This property is set to <c>true</c> if the deletion was successful, and <c>false</c>
    /// otherwise.
    /// </remarks>
    property Deleted: Boolean read FDeleted write FDeleted;
  end;

  /// <summary>
  /// Manages asynchronous chat callBacks for a chat request using <c>TAssistant</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynAssistant</c> type extends the <c>TAsynParams&lt;TAssistant&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking chat operations and is specifically tailored for scenarios where multiple choices from a chat model are required.
  /// </remarks>
  TAsynAssistant = TAsynCallBack<TAssistant>;

  /// <summary>
  /// Manages asynchronous chat callBacks for a chat request using <c>TAssistants</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynAssistants</c> type extends the <c>TAsynParams&lt;TAssistants&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking chat operations and is specifically tailored for scenarios where multiple choices from a chat model are required.
  /// </remarks>
  TAsynAssistants = TAsynCallBack<TAssistants>;

  /// <summary>
  /// Manages asynchronous chat callBacks for a chat request using <c>TAssistantDeletion</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynAssistantDeletion</c> type extends the <c>TAsynParams&lt;TAssistantDeletion&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking chat operations and is specifically tailored for scenarios where multiple choices from a chat model are required.
  /// </remarks>
  TAsynAssistantDeletion = TAsynCallBack<TAssistantDeletion>;

  /// <summary>
  /// Represents the API route handler for managing assistants.
  /// </summary>
  /// <remarks>
  /// This class provides methods to create, retrieve, update, list, and delete assistants
  /// using the OpenAI API. It extends <c>TGenAIRoute</c> to handle API interactions and
  /// custom headers.
  /// </remarks>
  TAssistantsRoute = class(TGenAIRoute)
  protected
    /// <summary>
    /// Customizes headers for the assistants API requests.
    /// </summary>
    /// <remarks>
    /// This method ensures that specific headers required by the OpenAI Assistants API
    /// are included in every request.
    /// </remarks>
    procedure HeaderCustomize; override;
  public
    /// <summary>
    /// Asynchronously creates a new assistant.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure that defines the parameters for creating the assistant, using
    /// <c>TAssistantsParams</c>.
    /// </param>
    /// <param name="CallBacks">
    /// A callback function to handle the asynchronous response.
    /// </param>
    procedure AsynCreate(const ParamProc: TProc<TAssistantsParams>; const CallBacks: TFunc<TAsynAssistant>);
    /// <summary>
    /// Asynchronously retrieves a list of assistants.
    /// </summary>
    /// <param name="CallBacks">
    /// A callback function to handle the asynchronous response.
    /// </param>
    procedure AsynList(const CallBacks: TFunc<TAsynAssistants>); overload;
    /// <summary>
    /// Asynchronously retrieves a list of assistants with additional parameters.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure to define advanced parameters for listing assistants, using
    /// <c>TUrlAdvancedParams</c>.
    /// </param>
    /// <param name="CallBacks">
    /// A callback function to handle the asynchronous response.
    /// </param>
    procedure AsynList(const ParamProc: TProc<TUrlAdvancedParams>; const CallBacks: TFunc<TAsynAssistants>); overload;
    /// <summary>
    /// Asynchronously retrieves a specific assistant by ID.
    /// </summary>
    /// <param name="AssistantId">
    /// The unique identifier of the assistant to retrieve.
    /// </param>
    /// <param name="CallBacks">
    /// A callback function to handle the asynchronous response.
    /// </param>
    procedure AsynRetrieve(const AssistantId: string; const CallBacks: TFunc<TAsynAssistant>);
    /// <summary>
    /// Asynchronously updates an existing assistant by ID.
    /// </summary>
    /// <param name="AssistantId">
    /// The unique identifier of the assistant to update.
    /// </param>
    /// <param name="ParamProc">
    /// A procedure that defines the parameters for updating the assistant, using
    /// <c>TAssistantsParams</c>.
    /// </param>
    /// <param name="CallBacks">
    /// A callback function to handle the asynchronous response.
    /// </param>
    procedure AsynUpdate(const AssistantId: string; const ParamProc: TProc<TAssistantsParams>;
      const CallBacks: TFunc<TAsynAssistant>);
    /// <summary>
    /// Asynchronously deletes an assistant by ID.
    /// </summary>
    /// <param name="AssistantId">
    /// The unique identifier of the assistant to delete.
    /// </param>
    /// <param name="CallBacks">
    /// A callback function to handle the asynchronous response.
    /// </param>
    procedure AsynDelete(const AssistantId: string; const CallBacks: TFunc<TAsynAssistantDeletion>);
    /// <summary>
    /// Creates a new assistant synchronously.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure that defines the parameters for creating the assistant, using
    /// <c>TAssistantsParams</c>.
    /// </param>
    /// <returns>
    /// A <c>TAssistant</c> object representing the created assistant.
    /// </returns>
    function Create(const ParamProc: TProc<TAssistantsParams>): TAssistant;
    /// <summary>
    /// Retrieves a list of assistants synchronously.
    /// </summary>
    /// <returns>
    /// A <c>TAssistants</c> object containing a list of assistant configurations.
    /// </returns>
    function List: TAssistants; overload;
    /// <summary>
    /// Retrieves a list of assistants synchronously with additional parameters.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure to define advanced parameters for listing assistants, using
    /// <c>TUrlAdvancedParams</c>.
    /// </param>
    /// <returns>
    /// A <c>TAssistants</c> object containing a list of assistant configurations.
    /// </returns>
    function List(const ParamProc: TProc<TUrlAdvancedParams>): TAssistants; overload;
    /// <summary>
    /// Retrieves a specific assistant synchronously by ID.
    /// </summary>
    /// <param name="AssistantId">
    /// The unique identifier of the assistant to retrieve.
    /// </param>
    /// <returns>
    /// A <c>TAssistant</c> object representing the retrieved assistant.
    /// </returns>
    function Retrieve(const AssistantId: string): TAssistant;
    /// <summary>
    /// Updates an existing assistant synchronously by ID.
    /// </summary>
    /// <param name="AssistantId">
    /// The unique identifier of the assistant to update.
    /// </param>
    /// <param name="ParamProc">
    /// A procedure that defines the parameters for updating the assistant, using
    /// <c>TAssistantsParams</c>.
    /// </param>
    /// <returns>
    /// A <c>TAssistant</c> object representing the updated assistant.
    /// </returns>
    function Update(const AssistantId: string; const ParamProc: TProc<TAssistantsParams>): TAssistant;
    /// <summary>
    /// Deletes an assistant synchronously by ID.
    /// </summary>
    /// <param name="AssistantId">
    /// The unique identifier of the assistant to delete.
    /// </param>
    /// <returns>
    /// A <c>TAssistantDeletion</c> object containing the deletion status.
    /// </returns>
    function Delete(const AssistantId: string): TAssistantDeletion;
  end;

implementation

{ TAssistantsParams }

function TAssistantsParams.Description(const Value: string): TAssistantsParams;
begin
  Result := TAssistantsParams(Add('description', Value));
end;

function TAssistantsParams.Instructions(const Value: string): TAssistantsParams;
begin
  Result := TAssistantsParams(Add('instructions', Value));
end;

function TAssistantsParams.Metadata(
  const Value: TJSONObject): TAssistantsParams;
begin
  Result := TAssistantsParams(Add('metadata', Value));
end;

function TAssistantsParams.Model(const Value: string): TAssistantsParams;
begin
  Result := TAssistantsParams(Add('model', Value));
end;

function TAssistantsParams.Name(const Value: string): TAssistantsParams;
begin
  Result := TAssistantsParams(Add('name', Value));
end;

function TAssistantsParams.ResponseFormat(
  const Value: TJSONObject): TAssistantsParams;
begin
  Result := TAssistantsParams(Add('response_format', Value));
end;

function TAssistantsParams.ResponseFormat(
  const Value: TResponseFormatParams): TAssistantsParams;
begin
  Result := TAssistantsParams(Add('response_format', Value.Detach));
end;

function TAssistantsParams.ResponseFormat(
  const Value: string): TAssistantsParams;
begin
  Result := TAssistantsParams(Add('response_format', Value));
end;

function TAssistantsParams.Temperature(const Value: Double): TAssistantsParams;
begin
  Result := TAssistantsParams(Add('temperature', Value));
end;

function TAssistantsParams.ToolResources(
  const Value: TToolResourcesParams): TAssistantsParams;
begin
  Result := TAssistantsParams(Add('tool_resources', Value.Detach));
end;

function TAssistantsParams.Tools(
  const Value: TArray<TAssistantsToolsParams>): TAssistantsParams;
begin
  var JSONArray := TJSONArray.Create;
  for var Item in Value do
    JSONArray.Add(Item.Detach);
  Result := TAssistantsParams(Add('tools', JSONArray));
end;

function TAssistantsParams.TopP(const Value: Double): TAssistantsParams;
begin
  Result := TAssistantsParams(Add('top_p', Value));
end;

{ TAssistantsToolsParams }

function TAssistantsToolsParams.&Type(const Value: string): TAssistantsToolsParams;
begin
  Result := TAssistantsToolsParams(Add('type', TAssistantsToolsType.Create(Value).ToString));
end;

function TAssistantsToolsParams.&Function(
  const Value: TFunctionParams): TAssistantsToolsParams;
begin
  Result := TAssistantsToolsParams(Add('function', Value));
end;

function TAssistantsToolsParams.FileSearch(
  const Value: TFileSearchToolParams): TAssistantsToolsParams;
begin
  Result := TAssistantsToolsParams(Add('file_search', Value.Detach));
end;

function TAssistantsToolsParams.&Type(
  const Value: TAssistantsToolsType): TAssistantsToolsParams;
begin
  Result := TAssistantsToolsParams(Add('type', Value.ToString));
end;

{ TFileSearchToolParams }

function TFileSearchToolParams.MaxNumResults(
  const Value: Integer): TFileSearchToolParams;
begin
  Result := TFileSearchToolParams(Add('max_num_results', Value));
end;

function TFileSearchToolParams.RankingOptions(
  const Value: TRankingOptionsParams): TFileSearchToolParams;
begin
  Result := TFileSearchToolParams(Add('ranking_options', Value.Detach));
end;

{ TRankingOptionsParams }

function TRankingOptionsParams.Ranker(
  const Value: string): TRankingOptionsParams;
begin
  Result := TRankingOptionsParams(Add('ranker', Value));
end;

function TRankingOptionsParams.ScoreThreshold(
  const Value: Double): TRankingOptionsParams;
begin
  Result := TRankingOptionsParams(Add('score_threshold', Value));
end;

{ TFunctionParams }

function TFunctionParams.Description(const Value: string): TFunctionParams;
begin
  Result := TFunctionParams(Add('description', Value));
end;

function TFunctionParams.Name(const Value: string): TFunctionParams;
begin
  Result := TFunctionParams(Add('name', Value));
end;

function TFunctionParams.Parameters(const Value: TJSONObject): TFunctionParams;
begin
  Result := TFunctionParams(Add('parameters', Value));
end;

function TFunctionParams.&Strict(const Value: Boolean): TFunctionParams;
begin
  Result := TFunctionParams(Add('strict', Value));
end;

function TFunctionParams.Parameters(
  const Value: TSchemaParams): TFunctionParams;
begin
  Result := TFunctionParams(Add('parameters', Value.Detach));
end;

{ TToolResourcesParams }

function TToolResourcesParams.CodeInterpreter(
  const Value: TCodeInterpreterParams): TToolResourcesParams;
begin
  Result := TToolResourcesParams(Add('code_interpreter', Value.Detach));
end;

function TToolResourcesParams.CodeInterpreter(
  const FileIds: TArray<string>): TToolResourcesParams;
begin
  Result := TToolResourcesParams(Add('code_interpreter', TCodeInterpreterParams.Create.FileIds(FileIds)));
end;

function TToolResourcesParams.FileSearch(
  const Value: TFileSearchParams): TToolResourcesParams;
begin
  Result := TToolResourcesParams(Add('file_search', Value.Detach));
end;

{ TCodeInterpreterParams }

function TCodeInterpreterParams.FileIds(
  const Value: TArray<string>): TCodeInterpreterParams;
begin
  Result := TCodeInterpreterParams(Add('file_ids', Value));
end;

{ TFileSearchParams }

function TFileSearchParams.VectorStoreIds(
  const Value: TArray<string>): TFileSearchParams;
begin
  Result := TFileSearchParams(Add('vector_store_ids', Value));
end;

function TFileSearchParams.VectorStores(
  const Value: TArray<TVectorStoresParams>): TFileSearchParams;
begin
  var JSONArray := TJSONArray.Create;
  for var Item in Value do
    JSONArray.Add(Item.Detach);
  Result := TFileSearchParams(Add('vector_stores', JSONArray));
end;

{ TVectorStoresParams }

function TVectorStoresParams.ChunkingStrategy(
  const Value: TChunkingStrategyParams): TVectorStoresParams;
begin
  Result := TVectorStoresParams(Add('chunking_strategy', Value.Detach));
end;

function TVectorStoresParams.FileIds(
  const Value: TArray<string>): TVectorStoresParams;
begin
  Result := TVectorStoresParams(Add('file_ids', Value));
end;

function TVectorStoresParams.Metadata(
  const Value: TJSONObject): TVectorStoresParams;
begin
  Result := TVectorStoresParams(Add('metadata', Value));
end;

{ TChunkingStrategyParams }

function TChunkingStrategyParams.Static(
  const Value: TChunkStaticParams): TChunkingStrategyParams;
begin
  Result := TChunkingStrategyParams(Add('static', Value.Detach));
end;

function TChunkingStrategyParams.&Type(
  const Value: string): TChunkingStrategyParams;
begin
  Result := TChunkingStrategyParams(Add('type', TChunkingStrategyType.Create(Value).ToString));
end;

function TChunkingStrategyParams.&Type(
  const Value: TChunkingStrategyType): TChunkingStrategyParams;
begin
  Result := TChunkingStrategyParams(Add('type', Value.ToString));
end;

{ TChunkStaticParams }

function TChunkStaticParams.ChunkOverlapTokens(
  const Value: Integer): TChunkStaticParams;
begin
  Result := TChunkStaticParams(Add('chunk_overlap_tokens', Value));
end;

function TChunkStaticParams.MaxChunkSizeTokens(
  const Value: Integer): TChunkStaticParams;
begin
  Result := TChunkStaticParams(Add('max_chunk_size_tokens', Value));
end;

{ TResponseFormatParams }

function TResponseFormatParams.&Type(
  const Value: string): TResponseFormatParams;
begin
  Result := TResponseFormatParams(Add('type', TResponseFormatType.Create(Value).ToString));
end;

function TResponseFormatParams.&Type(
  const Value: TResponseFormatType): TResponseFormatParams;
begin
  Result := TResponseFormatParams(Add('type', Value.ToString));
end;

function TResponseFormatParams.JsonSchema(
  const Value: TJsonSchemaParams): TResponseFormatParams;
begin
  Result := TResponseFormatParams(Add('json_schema', Value.Detach));
end;

function TResponseFormatParams.JsonSchema(
  const Value: TJsonObject): TResponseFormatParams;
begin
  Result := TResponseFormatParams(Add('json_schema', Value));
end;

{ TJsonSchemaParams }

function TJsonSchemaParams.Description(const Value: string): TJsonSchemaParams;
begin
  Result := TJsonSchemaParams(Add('description', Value));
end;

function TJsonSchemaParams.Name(const Value: string): TJsonSchemaParams;
begin
  Result := TJsonSchemaParams(Add('name', Value));
end;

function TJsonSchemaParams.Schema(const Value: TJSONObject): TJsonSchemaParams;
begin
  Result := TJsonSchemaParams(Add('schema', Value));
end;

function TJsonSchemaParams.&Strict(const Value: Boolean): TJsonSchemaParams;
begin
  Result := TJsonSchemaParams(Add('strict', Value));
end;

function TJsonSchemaParams.Schema(
  const Value: TSchemaParams): TJsonSchemaParams;
begin
  Result := TJsonSchemaParams(Add('schema', Value.Detach));
end;

{ TAssistant }

destructor TAssistant.Destroy;
begin
  for var Item in FTools do
    Item.Free;
  if Assigned(FToolResources) then
    FToolResources.Free;
  inherited;
end;

{ TAssistantsFileSearch }

destructor TAssistantsFileSearch.Destroy;
begin
  if Assigned(FRankingOptions) then
    FRankingOptions.Free;
  inherited;
end;

{ TAssistantsTools }

destructor TAssistantsTools.Destroy;
begin
  if Assigned(FFileSearch) then
    FFileSearch.Free;
  if Assigned(FFunction) then
    FFunction.Free;
  inherited;
end;

{ TToolResources }

destructor TToolResources.Destroy;
begin
  if Assigned(FCodeInterpreter) then
    FCodeInterpreter.Free;
  if Assigned(FFileSearch) then
    FFileSearch.Free;
  inherited;
end;

{ TAssistantsRoute }

procedure TAssistantsRoute.AsynCreate(const ParamProc: TProc<TAssistantsParams>;
  const CallBacks: TFunc<TAsynAssistant>);
begin
  with TAsynCallBackExec<TAsynAssistant, TAssistant>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TAssistant
      begin
        Result := Self.Create(ParamProc);
      end);
  finally
    Free;
  end;
end;

procedure TAssistantsRoute.AsynList(const CallBacks: TFunc<TAsynAssistants>);
begin
  with TAsynCallBackExec<TAsynAssistants, TAssistants>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TAssistants
      begin
        Result := Self.List;
      end);
  finally
    Free;
  end;
end;

procedure TAssistantsRoute.AsynDelete(const AssistantId: string;
  const CallBacks: TFunc<TAsynAssistantDeletion>);
begin
  with TAsynCallBackExec<TAsynAssistantDeletion, TAssistantDeletion>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TAssistantDeletion
      begin
        Result := Self.Delete(AssistantId);
      end);
  finally
    Free;
  end;
end;

procedure TAssistantsRoute.AsynList(const ParamProc: TProc<TUrlAdvancedParams>;
  const CallBacks: TFunc<TAsynAssistants>);
begin
  with TAsynCallBackExec<TAsynAssistants, TAssistants>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TAssistants
      begin
        Result := Self.List(ParamProc);
      end);
  finally
    Free;
  end;
end;

procedure TAssistantsRoute.AsynRetrieve(const AssistantId: string;
  const CallBacks: TFunc<TAsynAssistant>);
begin
  with TAsynCallBackExec<TAsynAssistant, TAssistant>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TAssistant
      begin
        Result := Self.Retrieve(AssistantId);
      end);
  finally
    Free;
  end;
end;

procedure TAssistantsRoute.AsynUpdate(const AssistantId: string;
  const ParamProc: TProc<TAssistantsParams>;
  const CallBacks: TFunc<TAsynAssistant>);
begin
  with TAsynCallBackExec<TAsynAssistant, TAssistant>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TAssistant
      begin
        Result := Self.Update(AssistantId, ParamProc);
      end);
  finally
    Free;
  end;
end;

function TAssistantsRoute.Create(
  const ParamProc: TProc<TAssistantsParams>): TAssistant;
begin
  HeaderCustomize;
  Result := API.Post<TAssistant, TAssistantsParams>('assistants', ParamProc);
end;

function TAssistantsRoute.Delete(const AssistantId: string): TAssistantDeletion;
begin
  HeaderCustomize;
  Result := API.Delete<TAssistantDeletion>('assistants/' + AssistantId);
end;

procedure TAssistantsRoute.HeaderCustomize;
begin
  API.CustomHeaders := [TNetHeader.Create('OpenAI-Beta', 'assistants=v2')];
end;

function TAssistantsRoute.List: TAssistants;
begin
  HeaderCustomize;
  Result := API.Get<TAssistants>('assistants');
end;

function TAssistantsRoute.List(
  const ParamProc: TProc<TUrlAdvancedParams>): TAssistants;
begin
  HeaderCustomize;
  Result := API.Get<TAssistants, TUrlAdvancedParams>('assistants', ParamProc);
end;

function TAssistantsRoute.Retrieve(const AssistantId: string): TAssistant;
begin
  HeaderCustomize;
  Result := API.Get<TAssistant>('assistants/' + AssistantId );
end;

function TAssistantsRoute.Update(const AssistantId: string;
  const ParamProc: TProc<TAssistantsParams>): TAssistant;
begin
  HeaderCustomize;
  Result := API.Post<TAssistant, TAssistantsParams>('assistants/' + AssistantId, ParamProc);
end;

{ TAdvancedList<T> }

destructor TAdvancedList<T>.Destroy;
begin
  for var Item in FData do
    Item.Free;
  inherited;
end;

end.
