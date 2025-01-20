unit GenAI.Chat;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGenAI
      Visit the Github repository for the documentation and use examples

  NOTE: Regarding the management of streamed messages.

    This unit provides an abstraction for managing streaming data from APIs such
    as OpenAI or Anthropic. The "GenAI.Chat.StreamingInterface" defines a flexible
    interface for handling real-time data chunks, enabling the application to react
    to incoming data dynamically and efficiently.

    Key Features:
      - Streaming Management: Processes data in real-time by handling chunks as
        they arrive.

      - Event-driven Design: Utilizes callback mechanisms to provide flexible and
        dynamic responses to streaming events.

      - Adaptable Architecture: Supports experimentation with different streaming
        techniques, such as OpenAI's sequential streaming or Anthropic's contextual
        approaches, allowing easy integration of various streaming models.

      - Control and Flexibility: Enables custom chunk processing, flow control, and
        integration with user-defined logic, improving user experience and system
        responsiveness.

    This interface lays the groundwork for implementing and comparing alternative
    streaming techniques while maintaining a clean, modular, and extensible
    architecture.

 ------------------------------------------------------------------------------}

interface

uses
  System.SysUtils, System.Classes, System.Threading, System.JSON, REST.Json.Types,
  REST.JsonReflect,
  GenAI.API.Params, GenAI.API, GenAI.Consts, GenAI.Schema, GenAI.Chat.StreamingCallback,
  GenAI.Types, GenAI.Chat.StreamingInterface, GenAI.Functions.Tools, GenAI.Functions.Core,
  GenAI.Async.Params, GenAI.Async.Support;

type
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
  TImageUrl = class(TJSONParam)
  public
    /// <summary>
    /// Sets the URL of the image. This can be a direct web link or a base64-encoded
    /// string representing the image data.
    /// </summary>
    /// <param name="Value">
    /// The URL as a string or base64-encoded image data.
    /// </param>
    /// <returns>
    /// Returns an instance of TImageUrl.
    /// </returns>
    function Url(const Value: string): TImageUrl;
    /// <summary>
    /// Sets the detail level of the image, influencing how the image is processed
    /// or displayed by the consuming API. The default is set to 'auto', which
    /// lets the API decide the optimal level of detail.
    /// </summary>
    /// <param name="Value">
    /// A value from the TImageDetail enumeration specifying the level of detail.
    /// </param>
    /// <returns>
    /// Returns an instance of TImageUrl.
    /// </returns>
    function Detail(const Value: TImageDetail): TImageUrl;
    /// <summary>
    /// Creates a new instance of TImageUrl with a specified URL and optional detail.
    /// </summary>
    /// <param name="PathLocation">
    /// The path to the image, either as a URL or a file path for base64 encoding.
    /// </param>
    /// <param name="Detail">
    /// Optional. The detail level for the image. The default is 'auto'.
    /// </param>
    /// <returns>
    /// Returns a newly instantiated object of TImageUrl.
    /// </returns>
    class function New(const PathLocation: string; const Detail: TImageDetail = id_auto): TImageUrl;
  end;

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
  TInputAudio = class(TJSONParam)
  public
    /// <summary>
    /// Sets the base64-encoded data of the audio.
    /// </summary>
    /// <param name="Value">
    /// The base64-encoded audio data.
    /// </param>
    /// <returns>
    /// Returns an instance of TInputAudio.
    /// </returns>
    function Data(const Value: string): TInputAudio;
    /// <summary>
    /// Sets the format of the audio data.
    /// </summary>
    /// <param name="Value">
    /// The format of the audio, specified as a string.
    /// </param>
    /// <returns>
    /// Returns an instance of TInputAudio.
    /// </returns>
    function Format(const Value: string): TInputAudio; overload;
    /// <summary>
    /// Sets the format of the audio data using a predefined audio format type.
    /// </summary>
    /// <param name="Value">
    /// The audio format type.
    /// </param>
    /// <returns>
    /// Returns an instance of TInputAudio.
    /// </returns>
    function Format(const Value: TAudioFormat): TInputAudio; overload;
    /// <summary>
    /// Creates a new instance of TInputAudio with specified audio data path.
    /// </summary>
    /// <param name="PathLocation">
    /// The file path or URL from which to load and encode the audio data.
    /// </param>
    /// <returns>
    /// Returns a newly instantiated object of TInputAudio.
    /// </returns>
    class function New(const PathLocation: string): TInputAudio; overload;
  end;

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
  TContentParams = class(TJSONParam)
  private
    class function Extract(const Value: string; var Detail: TImageDetail): string;
  public
    /// <summary>
    /// Sets the type of the content, such as 'text', 'image_url', or 'input_audio'.
    /// </summary>
    /// <param name="Value">
    /// The type of the content.
    /// </param>
    /// <returns>
    /// Returns an instance of TContentParams.
    /// </returns>
    function &Type(const Value: string): TContentParams;
    /// <summary>
    /// Sets the text content.
    /// </summary>
    /// <param name="Value">
    /// The text content.
    /// </param>
    /// <returns>
    /// Returns an instance of TContentParams.
    /// </returns>
    function Text(const Value: string): TContentParams;
    /// <summary>
    /// Configures the URL for an image.
    /// </summary>
    /// <param name="Value">
    /// An instance of TImageUrl containing the image URL and detail settings.
    /// </param>
    /// <returns>
    /// Returns an instance of TContentParams.
    /// </returns>
    function ImageUrl(const Value: TImageUrl): TContentParams;
    /// <summary>
    /// Configures the audio input with its base64-encoded data and format.
    /// </summary>
    /// <param name="Value">
    /// An instance of TInputAudio containing the audio data and format.
    /// </param>
    /// <returns>
    /// Returns an instance of TContentParams.
    /// </returns>
    function InputAudio(const Value: TInputAudio): TContentParams;
    /// <summary>
    /// Adds a file's content to the parameters, automatically determining the type
    /// based on the file's MIME type and handling it accordingly.
    /// </summary>
    /// <param name="FileLocation">
    /// The location of the file to be added.
    /// </param>
    /// <returns>
    /// Returns an instance of TContentParams.
    /// </returns>
    class function AddFile(const FileLocation: string): TContentParams;
  end;

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
  TFunctionParams = class(TJSONParam)
  public
    /// <summary>
    /// Sets the name of the function.
    /// </summary>
    /// <param name="Value">
    /// The name of the function.
    /// </param>
    /// <returns>
    /// Returns an instance of TFunctionParams.
    /// </returns>
    function Name(const Value: string): TFunctionParams;
    /// <summary>
    /// Sets the arguments for the function in a JSON-formatted string.
    /// </summary>
    /// <param name="Value">
    /// The JSON-formatted arguments string.
    /// </param>
    /// <returns>
    /// Returns an instance of TFunctionParams.
    /// </returns>
    function Arguments(const Value: string): TFunctionParams;
  end;

  /// <summary>
  /// Manages the parameters for tool calls within a JSON structure, facilitating the integration
  /// of tool functionality such as functions or specific actions within an API request.
  /// </summary>
  /// <remarks>
  /// This class allows for specifying the ID, type, and function details for tools that are to be
  /// called within an API request. It ensures that tool interactions are well-defined and correctly
  /// structured to perform expected operations.
  /// </remarks>
  TToolCallsParams = class(TJSONParam)
  public
    /// <summary>
    /// Sets the unique identifier for the tool call.
    /// </summary>
    /// <param name="Value">
    /// The identifier for the tool call.
    /// </param>
    /// <returns>
    /// Returns an instance of TToolCallsParams.
    /// </returns>
    function Id(const Value: string): TToolCallsParams;
    /// <summary>
    /// Sets the type of the tool, such as a function or other executable action.
    /// </summary>
    /// <param name="Value">
    /// The type of the tool.
    /// </param>
    /// <returns>
    /// Returns an instance of TToolCallsParams.
    /// </returns>
    function &Type(const Value: string): TToolCallsParams; overload;
    /// <summary>
    /// Sets the type of the tool, such as a function or other executable action.
    /// </summary>
    /// <param name="Value">
    /// The type of the tool.
    /// </param>
    /// <returns>
    /// Returns an instance of TToolCallsParams.
    /// </returns>
    function &Type(const Value: TToolCalls): TToolCallsParams; overload;
    /// <summary>
    /// Configures the function details for a tool call, specifying the function name
    /// and its arguments.
    /// </summary>
    /// <param name="Name">
    /// The name of the function to be called.
    /// </param>
    /// <param name="Arguments">
    /// The JSON-formatted arguments for the function.
    /// </param>
    /// <returns>
    /// Returns an instance of TToolCallsParams.
    /// </returns>
    function &Function(const Name: string; const Arguments: string): TToolCallsParams;
    /// <summary>
    /// Creates a new instance of TToolCallsParams with specified tool call details.
    /// </summary>
    /// <param name="Id">
    /// The unique identifier for the tool call.
    /// </param>
    /// <param name="Name">
    /// The name of the function to call.
    /// </param>
    /// <param name="Arguments">
    /// The JSON-formatted arguments for the function.
    /// </param>
    /// <returns>
    /// Returns a newly instantiated object of TToolCallsParams.
    /// </returns>
    class function New(const Id: string; const Name: string; const Arguments: string): TToolCallsParams;
  end;

  /// <summary>
  /// Manages the content parameters for assistant messages, facilitating the integration
  /// of text or refusal content within a JSON structure for virtual assistants.
  /// </summary>
  /// <remarks>
  /// This class provides methods to set text content or a refusal message in responses
  /// generated by an assistant. It allows for precise control over the content delivered
  /// by the assistant, ensuring that responses are appropriate and well-structured.
  /// </remarks>
  TAssistantContentParams = class(TJSONParam)
  public
    /// <summary>
    /// Sets the type of content, such as text or a refusal message.
    /// </summary>
    /// <param name="Value">
    /// The type of the content.
    /// </param>
    /// <returns>
    /// Returns an instance of TAssistantContentParams.
    /// </returns>
    function &Type(const Value: string): TAssistantContentParams;
    /// <summary>
    /// Sets the text content for the assistant message.
    /// </summary>
    /// <param name="Value">
    /// The text content.
    /// </param>
    /// <returns>
    /// Returns an instance of TAssistantContentParams.
    /// </returns>
    function Text(const Value: string): TAssistantContentParams;
    /// <summary>
    /// Sets a refusal message for the assistant to use if it cannot comply with a request.
    /// </summary>
    /// <param name="Value">
    /// The refusal message.
    /// </param>
    /// <returns>
    /// Returns an instance of TAssistantContentParams.
    /// </returns>
    function Refusal(const Value: string): TAssistantContentParams;
    /// <summary>
    /// Creates an instance of TAssistantContentParams with text content specified.
    /// </summary>
    /// <param name="AType">
    /// The type of the content, typically 'text'.
    /// </param>
    /// <param name="Value">
    /// The text content.
    /// </param>
    /// <returns>
    /// Returns a newly instantiated object of TAssistantContentParams with text content.
    /// </returns>
    class function AddText(const AType: string; const Value: string): TAssistantContentParams;
    /// <summary>
    /// Creates an instance of TAssistantContentParams with a refusal message specified.
    /// </summary>
    /// <param name="AType">
    /// The type of the content, typically 'refusal'.
    /// </param>
    /// <param name="Value">
    /// The refusal message.
    /// </param>
    /// <returns>
    /// Returns a newly instantiated object of TAssistantContentParams with a refusal message.
    /// </returns>
    class function AddRefusal(const AType: string; const Value: string): TAssistantContentParams;
  end;

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
  TMessagePayload = class(TJSONParam)
  public
    /// <summary>
    /// Assigns a role to the message author, which can be 'user', 'assistant', 'system',
    /// or 'tool' to reflect the message's origin within the interaction context.
    /// </summary>
    /// <param name="Value">
    /// A string representation of the role.
    /// </param>
    /// <returns>
    /// Returns an instance of TMessagePayload configured with the specified role.
    /// </returns>
    function Role(const Value: TRole): TMessagePayload; overload;
    /// <summary>
    /// Assigns a role to the message author, which can be 'user', 'assistant', 'system',
    /// or 'tool' to reflect the message's origin within the interaction context.
    /// </summary>
    /// <param name="Value">
    /// A string representation of the role.
    /// </param>
    /// <returns>
    /// Returns an instance of TMessagePayload configured with the specified role.
    /// </returns>
    function Role(const Value: string): TMessagePayload; overload;
    /// <summary>
    /// Adds content to the message payload, which can be text, an array of content parts,
    /// or structured JSON data, depending on the message's intended purpose.
    /// </summary>
    /// <param name="Value">
    /// The content to add, specified as a string or JSON structure.
    /// </param>
    /// <returns>
    /// Returns an updated instance of TMessagePayload with the new content added.
    /// </returns>
    function Content(const Value: string): TMessagePayload; overload;
    /// <summary>
    /// Adds content to the message payload, which can be text, an array of content parts,
    /// or structured JSON data, depending on the message's intended purpose.
    /// </summary>
    /// <param name="Value">
    /// The content to add, specified as a string or JSON structure.
    /// </param>
    /// <returns>
    /// Returns an updated instance of TMessagePayload with the new content added.
    /// </returns>
    function Content(const Value: TJSONArray): TMessagePayload; overload;
    /// <summary>
    /// Adds content to the message payload, which can be text, an array of content parts,
    /// or structured JSON data, depending on the message's intended purpose.
    /// </summary>
    /// <param name="Value">
    /// The content to add, specified as a string or JSON structure.
    /// </param>
    /// <returns>
    /// Returns an updated instance of TMessagePayload with the new content added.
    /// </returns>
    function Content(const Value: TArray<TAssistantContentParams>): TMessagePayload; overload;
    /// <summary>
    /// Adds content to the message payload, which can be text, an array of content parts,
    /// or structured JSON data, depending on the message's intended purpose.
    /// </summary>
    /// <param name="Value">
    /// The content to add, specified as a string or JSON structure.
    /// </param>
    /// <returns>
    /// Returns an updated instance of TMessagePayload with the new content added.
    /// </returns>
    function Content(const Value: TJSONObject): TMessagePayload; overload;
    /// <summary>
    /// Specifies the name of the participant, which can be used to personalize responses
    /// or distinguish between participants in a multi-user environment.
    /// </summary>
    /// <param name="Value">
    /// The name of the participant.
    /// </param>
    /// <returns>
    /// Returns an updated instance of TMessagePayload with the participant's name set.
    /// </returns>
    function Name(const Value: string): TMessagePayload;
    /// <summary>
    /// Adds a refusal reason to the message, used primarily by the assistant to
    /// indicate why it cannot comply with a user's request.
    /// </summary>
    /// <param name="Value">
    /// The text specifying the refusal reason.
    /// </param>
    /// <returns>
    /// Returns an updated instance of TMessagePayload including the refusal reason.
    /// </returns>
    function Refusal(const Value: string): TMessagePayload;
    /// <summary>
    /// Attaches audio data to the message payload, primarily for responses that
    /// involve spoken content or commands.
    /// </summary>
    /// <param name="Value">
    /// The identifier for the audio data.
    /// </param>
    /// <returns>
    /// Returns an updated instance of TMessagePayload with the audio data attached.
    /// </returns>
    function Audio(const Value: string): TMessagePayload;
    /// <summary>
    /// Adds tool calls to the message payload, linking it to specific tool functions
    /// that the message may trigger or be associated with.
    /// </summary>
    /// <param name="Value">
    /// An array of TToolCallsParams representing the tool calls to be added to the message.
    /// </param>
    /// <returns>
    /// Returns an updated instance of TMessagePayload with the tool calls included.
    /// </returns>
    function ToolCalls(const Value: TArray<TToolCallsParams>): TMessagePayload;
    /// <summary>
    /// Sets the tool call identifier for the message payload, linking it to a specific
    /// tool interaction or process.
    /// </summary>
    /// <param name="Value">
    /// The string identifier of the tool call to associate with this message.
    /// </param>
    /// <returns>
    /// Returns an updated instance of TMessagePayload with the tool call ID set.
    /// </returns>
    function ToolCallId(const Value: string): TMessagePayload;
    /// <summary>
    /// Constructs a new message payload for a specific role with specified content.
    /// </summary>
    /// <param name="Role">
    /// The role of the message's author.
    /// </param>
    /// <param name="Content">
    /// The content of the message.
    /// </param>
    /// <param name="Name">
    /// Optional. The name of the participant.
    /// </param>
    /// <returns>
    /// Returns a newly created TMessagePayload with the defined role and content.
    /// </returns>
    class function New(const Role: TRole; const Content: string; const Name: string = ''):TMessagePayload; overload;
    /// <summary>
    /// Factory method to create a developer role message payload.
    /// </summary>
    /// <param name="Content">
    /// The content of the developer message.
    /// </param>
    /// <param name="Name">
    /// Optional. The name of the developer.
    /// </param>
    /// <returns>
    /// Returns a TMessagePayload instance representing a developer message.
    /// </returns>
    class function Developer(const Content: string; const Name: string = ''):TMessagePayload;
    /// <summary>
    /// Factory method to create a system role message payload.
    /// </summary>
    /// <param name="Content">
    /// The content of the system message.
    /// </param>
    /// <param name="Name">
    /// Optional. The name of the system or module sending the message.
    /// </param>
    /// <returns>
    /// Returns a TMessagePayload instance representing a system message.
    /// </returns>
    class function System(const Content: string; const Name: string = ''):TMessagePayload;
    /// <summary>
    /// Factory method to create a user role message payload.
    /// </summary>
    /// <param name="Content">
    /// The content of the user message.
    /// </param>
    /// <param name="Name">
    /// Optional. The name of the user.
    /// </param>
    /// <returns>
    /// Returns a TMessagePayload instance representing a user message.
    /// </returns>
    class function User(const Content: string; const Name: string = ''):TMessagePayload; overload;
    /// <summary>
    /// Factory method to create a user role message payload with multiple document references.
    /// </summary>
    /// <param name="Content">
    /// The main content of the user message.
    /// </param>
    /// <param name="Docs">
    /// An array of document paths to include.
    /// </param>
    /// <param name="Name">
    /// Optional. The name of the user.
    /// </param>
    /// <returns>
    /// Returns a TMessagePayload instance representing a user message with additional documents.
    /// </returns>
    class function User(const Content: string; const Docs: TArray<string>; const Name: string = ''):TMessagePayload; overload;
    /// <summary>
    /// Factory method to create a user role message payload with an array of document references.
    /// </summary>
    /// <param name="Docs">
    /// An array of document paths to include as part of the message content.
    /// </param>
    /// <param name="Name">
    /// Optional. The name of the user.
    /// </param>
    /// <returns>
    /// Returns a TMessagePayload instance representing a user message including multiple documents.
    /// </returns>
    class function User(const Docs: TArray<string>; const Name: string = ''):TMessagePayload; overload;
    /// <summary>
    /// Constructs an assistant message payload by executing a passed delegate that configures the payload.
    /// </summary>
    /// <param name="ParamProc">
    /// A delegate to configure the payload.
    /// </param>
    /// <returns>
    /// Returns a TMessagePayload instance configured by the delegate.
    /// </returns>
    class function Assistant(const ParamProc: TProcRef<TMessagePayload>): TMessagePayload; overload;
    /// <summary>
    /// Constructs an assistant message payload from another message payload instance.
    /// </summary>
    /// <param name="Value">
    /// An existing message payload instance.
    /// </param>
    /// <returns>
    /// Returns the passed TMessagePayload instance.
    /// </returns>
    class function Assistant(const Value: TMessagePayload): TMessagePayload; overload;
    /// <summary>
    /// Constructs a tool message payload to associate it with a specific tool call ID.
    /// </summary>
    /// <param name="Content">
    /// The content of the tool message.
    /// </param>
    /// <param name="ToolCallId">
    /// The identifier of the tool call associated with this message.
    /// </param>
    /// <returns>
    /// Returns a TMessagePayload instance configured for a specific tool.
    /// </returns>
    class function Tool(const Content: string; const ToolCallId: string): TMessagePayload;
  end;

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
  TPredictionPartParams = class(TJSONParam)
  public
    /// <summary>
    /// Sets the type of the prediction part, which defines the nature of the content
    /// being predicted.
    /// </summary>
    /// <param name="Value">
    /// The type as a string, typically identifying the content format or structure.
    /// </param>
    /// <returns>
    /// Returns an instance of TPredictionPartParams.
    /// </returns>
    function &Type(const Value: string): TPredictionPartParams;
    /// <summary>
    /// Sets the text of the predicted content part. This is used to define specific
    /// content that should be matched or anticipated by the processing system.
    /// </summary>
    /// <param name="Value">
    /// The text content to be predicted.
    /// </param>
    /// <returns>
    /// Returns an instance of TPredictionPartParams.
    /// </returns>
    function Text(const Value: string): TPredictionPartParams;
    /// <summary>
    /// Creates a new instance of TPredictionPartParams with specified type and text,
    /// facilitating the inclusion of predicted content in a structured manner.
    /// </summary>
    /// <param name="AType">
    /// The type of the prediction part, detailing the format or expected structure.
    /// </param>
    /// <param name="Text">
    /// The specific text content that is predicted, enabling pre-emptive matching.
    /// </param>
    /// <returns>
    /// Returns a newly instantiated object of TPredictionPartParams.
    /// </returns>
    class function New(const AType: string; const Text: string): TPredictionPartParams;
  end;

  /// <summary>
  /// Manages the configuration of prediction parameters for JSON requests, specifically
  /// designed to optimize model response generation by including expected content.
  /// </summary>
  /// <remarks>
  /// This class facilitates the integration of predictable or static content within
  /// JSON structured requests to optimize processing efficiencies and response accuracies
  /// in scenarios where certain outputs are known beforehand.
  /// </remarks>
  TPredictionParams = class(TJSONParam)
  public
    /// <summary>
    /// Sets the type of the prediction content, typically specifying the overarching
    /// structure or format expected in the response.
    /// </summary>
    /// <param name="Value">
    /// A string identifying the type of prediction, such as 'text' or 'structured'.
    /// </param>
    /// <returns>
    /// Returns an instance of TPredictionParams.
    /// </returns>
    function &Type(const Value: string): TPredictionParams;
    /// <summary>
    /// Configures the content for prediction, which could include specific text or
    /// structured data expected in the response.
    /// </summary>
    /// <param name="Value">
    /// The content expected, which could be text or a JSON object.
    /// </param>
    /// <returns>
    /// Returns an instance of TPredictionParams.
    /// </returns>
    function Content(const Value: string): TPredictionParams; overload;
    /// <summary>
    /// Configures the content for prediction, which could include specific text or
    /// structured data expected in the response.
    /// </summary>
    /// <param name="Value">
    /// The content expected, which could be text or a JSON object.
    /// </param>
    /// <returns>
    /// Returns an instance of TPredictionParams.
    /// </returns>
    function Content(const Value: TArray<TPredictionPartParams>): TPredictionParams; overload;
    /// <summary>
    /// Creates a new instance of TPredictionParams with predefined types and content,
    /// enabling optimized response generation.
    /// </summary>
    /// <param name="Value">
    /// An array of TPredictionPartParams detailing the predictable content.
    /// </param>
    /// <returns>
    /// Returns a newly instantiated object of TPredictionParams.
    /// </returns>
    class function New(const Value: string): TPredictionParams; overload;
    /// <summary>
    /// Creates a new instance of TPredictionParams with predefined types and content,
    /// enabling optimized response generation.
    /// </summary>
    /// <param name="Value">
    /// An array of TPredictionPartParams detailing the predictable content.
    /// </param>
    /// <returns>
    /// Returns a newly instantiated object of TPredictionParams.
    /// </returns>
    class function New(const Value: TArray<TPredictionPartParams>): TPredictionParams; overload;
  end;

  /// <summary>
  /// Configures audio parameters within JSON requests to manage voice and format
  /// specifications for audio generation.
  /// </summary>
  /// <remarks>
  /// This class is designed to detail the audio output settings, such as voice type
  /// and audio format, to tailor the audio responses generated by models or APIs.
  /// </remarks>
  TAudioParams = class(TJSONParam)
  public
    /// <summary>
    /// Sets the voice to be used for the audio output, specifying the tone and style
    /// of the generated audio.
    /// </summary>
    /// <param name="Value">
    /// A TChatVoice enumeration value representing the selected voice.
    /// </param>
    /// <returns>
    /// Returns an instance of TAudioParams.
    /// </returns>
    function Voice(const Value: TChatVoice): TAudioParams;
    /// <summary>
    /// Sets the audio format for the output, such as MP3 or WAV, determining how
    /// the audio is encoded.
    /// </summary>
    /// <param name="Value">
    /// A TAudioFormat value indicating the format of the audio output.
    /// </param>
    /// <returns>
    /// Returns an instance of TAudioParams.
    /// </returns>
    function Format(const Value: TAudioFormat): TAudioParams;
  end;

  /// <summary>
  /// Provides a means to specify a particular function that should be called by
  /// the tool choice mechanism within JSON requests.
  /// </summary>
  /// <remarks>
  /// This class is crucial for specifying which specific function should be executed,
  /// particularly in scenarios involving dynamic or automated decision-making processes
  /// where a specific operational function is needed.
  /// </remarks>
  TToolChoiceFunctionParams = class(TJSONParam)
  public
    /// <summary>
    /// Sets the name of the function that the tool choice should execute, linking
    /// to predefined functions within the system.
    /// </summary>
    /// <param name="Value">
    /// The name of the function to be executed.
    /// </param>
    /// <returns>
    /// Returns an instance of TToolChoiceFunctionParams.
    /// </returns>
    function Name(const Value: string): TToolChoiceFunctionParams;
  end;

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
  TToolChoiceParams = class(TJSONParam)
  public
    /// <summary>
    /// Specifies the type of tool to be used, typically defining whether a function
    /// or other tool type is to be called.
    /// </summary>
    /// <param name="Value">
    /// The type as a string, such as 'function' to indicate a function call.
    /// </param>
    /// <returns>
    /// Returns an instance of TToolChoiceParams.
    /// </returns>
    function &Type(const Value: string): TToolChoiceParams;
    /// <summary>
    /// Configures a specific function to be called as part of the tool choice.
    /// This method allows for the specification of the function name to be executed.
    /// </summary>
    /// <param name="Name">
    /// The name of the function to be called.
    /// </param>
    /// <returns>
    /// Returns an instance of TToolChoiceParams configured to call the specified function.
    /// </returns>
    function &Function(const Name: string): TToolChoiceParams;
    /// <summary>
    /// Creates a new instance of TToolChoiceParams configured to call a specified function.
    /// This constructor facilitates easy setup of tool choice parameters for API requests.
    /// </summary>
    /// <param name="Name">
    /// The name of the function to be called, defining the specific tool or function.
    /// </param>
    /// <returns>
    /// Returns a newly instantiated object of TToolChoiceParams.
    /// </returns>
    class function New(const Name: string): TToolChoiceParams;
  end;

  /// <summary>
  /// Manages parameters for chat request configurations in JSON format, supporting a wide
  /// range of attributes to customize the chat completion process.
  /// </summary>
  /// <remarks>
  /// This class facilitates the comprehensive configuration of chat-related parameters,
  /// allowing the control over model selection, token limitations, response modalities,
  /// and various other settings to optimize interaction dynamics and computational efficiency.
  /// </remarks>
  TChatParams = class(TJSONParam)
  public
    /// <summary>
    /// Adds messages to the chat configuration, accepting an array of message payloads.
    /// </summary>
    /// <param name="Value">
    /// An array of TMessagePayload instances representing the chat messages.
    /// </param>
    /// <returns>
    /// Returns an instance of TChatParams with the messages added.
    /// </returns>
    function Messages(const Value: TArray<TMessagePayload>): TChatParams; overload;
    /// <summary>
    /// Adds messages to the chat configuration, accepting an array of message payloads.
    /// </summary>
    /// <param name="Value">
    /// An array of TMessagePayload instances representing the chat messages.
    /// </param>
    /// <returns>
    /// Returns an instance of TChatParams with the messages added.
    /// </returns>
    function Messages(const Value: TJSONObject): TChatParams; overload;
    /// <summary>
    /// Adds messages to the chat configuration, accepting an array of message payloads.
    /// </summary>
    /// <param name="Value">
    /// An array of TMessagePayload instances representing the chat messages.
    /// </param>
    /// <returns>
    /// Returns an instance of TChatParams with the messages added.
    /// </returns>
    function Messages(const Value: TJSONArray): TChatParams; overload;
    /// <summary>
    /// Specifies the model to use for generating chat completions.
    /// </summary>
    /// <param name="Value">
    /// A string identifier for the model.
    /// </param>
    /// <returns>
    /// Returns an instance of TChatParams with the model set.
    /// </returns>
    function Model(const Value: string): TChatParams;
    /// <summary>
    /// Enables or disables the storing of output from chat completion requests.
    /// </summary>
    /// <param name="Value">
    /// Boolean value indicating whether to store the output.
    /// </param>
    /// <returns>
    /// Returns an instance of TChatParams with the storage option configured.
    /// </returns>
    function Store(const Value: Boolean): TChatParams;
    /// <summary>
    /// Specifies the effort level for reasoning when generating responses.
    /// </summary>
    /// <param name="Value">
    /// A string representing the desired effort level ('low', 'medium', or 'high').
    /// </param>
    /// <returns>
    /// Returns an instance of TChatParams with the reasoning effort set.
    /// </returns>
    function ReasoningEffort(const Value: TReasoningEffort): TChatParams; overload;
    /// <summary>
    /// Specifies the effort level for reasoning when generating responses.
    /// </summary>
    /// <param name="Value">
    /// A string representing the desired effort level ('low', 'medium', or 'high').
    /// </param>
    /// <returns>
    /// Returns an instance of TChatParams with the reasoning effort set.
    /// </returns>
    function ReasoningEffort(const Value: string): TChatParams; overload;
    /// <summary>
    /// Sets user-defined metadata for filtering or identifying completions in the dashboard.
    /// </summary>
    /// <param name="Value">
    /// A JSON object containing key-value pairs of metadata.
    /// </param>
    /// <returns>
    /// Returns an instance of TChatParams with metadata configured.
    /// </returns>
    function Metadata(const Value: TJSONObject): TChatParams;
    /// <summary>
    /// Configures how often and in what circumstances the model will refer to its previous outputs.
    /// </summary>
    /// <param name="Value">
    /// The frequency penalty as a double.
    /// </param>
    /// <returns>
    /// Returns an instance of TChatParams with the frequency penalty set.
    /// </returns>
    function FrequencyPenalty(const Value: Double): TChatParams;
    /// <summary>
    /// Specifies the likelihood of specified tokens appearing in the completion.
    /// </summary>
    /// <param name="Value">
    /// A JSON object mapping token IDs to bias values.
    /// </param>
    /// <returns>
    /// Returns an instance of TChatParams with the logit bias configured.
    /// </returns>
    function LogitBias(const Value: TJSONObject): TChatParams;
    /// <summary>
    /// Enables the return of log probabilities for the generated tokens.
    /// </summary>
    /// <param name="Value">
    /// Set to true to enable log probabilities.
    /// </param>
    /// <returns>
    /// An instance of TChatParams with log probability setting applied.
    /// </returns>
    function Logprobs(const Value: Boolean): TChatParams;
    /// <summary>
    /// Specifies the number of the most likely tokens to return at each token position.
    /// </summary>
    /// <param name="Value">
    /// The number of top log probabilities to return.
    /// </param>
    /// <returns>
    /// An instance of TChatParams with top log probabilities configured.
    /// </returns>
    function TopLogprobs(const Value: Integer): TChatParams;
    /// <summary>
    /// Sets the maximum number of tokens that can be generated for a completion.
    /// </summary>
    /// <param name="Value">
    /// The maximum number of tokens allowed.
    /// </param>
    /// <returns>
    /// Returns an instance of TChatParams with the maximum token limit set.
    /// </returns>
    function MaxCompletionTokens(const Value: Integer): TChatParams;
    /// <summary>
    /// Sets how many chat completion choices to generate for each input message.
    /// </summary>
    /// <param name="Value">
    /// The number of completions to generate.
    /// </param>
    /// <returns>
    /// An instance of TChatParams configured with the specified number of completions.
    /// </returns>
    function N(const Value: Integer): TChatParams;
    /// <summary>
    /// Specifies the modalities (text, audio) that the model should generate responses for.
    /// </summary>
    /// <param name="Value">
    /// An array of strings representing the desired output modalities.
    /// </param>
    /// <returns>
    /// Returns an instance of TChatParams with the modalities set.
    /// </returns>
    function Modalities(const Value: TArray<string>): TChatParams; overload;
    /// <summary>
    /// Specifies the modalities (text, audio) that the model should generate responses for.
    /// </summary>
    /// <param name="Value">
    /// An array of strings representing the desired output modalities.
    /// </param>
    /// <returns>
    /// Returns an instance of TChatParams with the modalities set.
    /// </returns>
    function Modalities(const Value: TArray<TModalities>): TChatParams; overload;
    /// <summary>
    /// Configures predictions for the chat completion, aiming to optimize response generation.
    /// </summary>
    /// <param name="Value">
    /// Predicted content or a configuration for handling predicted outputs.
    /// </param>
    /// <returns>
    /// An instance of TChatParams with prediction settings applied.
    /// </returns>
    function Prediction(const Value: string): TChatParams; overload;
     /// <summary>
    /// Configures predictions for the chat completion, aiming to optimize response generation.
    /// </summary>
    /// <param name="Value">
    /// Predicted content or a configuration for handling predicted outputs.
    /// </param>
    /// <returns>
    /// An instance of TChatParams with prediction settings applied.
    /// </returns>
    function Prediction(const Value: TArray<TPredictionPartParams>): TChatParams; overload;
    /// <summary>
    /// Specifies the audio parameters for responses, including voice type and format.
    /// </summary>
    /// <param name="Voice">
    /// The voice setting for the audio output.
    /// </param>
    /// <param name="Format">
    /// The audio format (e.g., mp3, wav).
    /// </param>
    /// <returns>
    /// An instance of TChatParams configured with specified audio settings.
    /// </returns>
    function Audio(const Voice: TChatVoice; const Format: TAudioFormat): TChatParams; overload;
    /// <summary>
    /// Specifies the audio parameters for responses, including voice type and format.
    /// </summary>
    /// <param name="Voice">
    /// The voice setting for the audio output.
    /// </param>
    /// <param name="Format">
    /// The audio format (e.g., mp3, wav).
    /// </param>
    /// <returns>
    /// An instance of TChatParams configured with specified audio settings.
    /// </returns>
    function Audio(const Voice, Format: string): TChatParams; overload;
    /// <summary>
    /// Sets a penalty on generating tokens that introduce new topics, encouraging focus on the current topics.
    /// </summary>
    /// <param name="Value">
    /// The penalty value, where higher values encourage more focus on existing topics.
    /// </param>
    /// <returns>
    /// An instance of TChatParams with the presence penalty configured.
    /// </returns>
    function PresencePenalty(const Value: Double): TChatParams;
    /// <summary>
    /// Specifies the format that the model must output, supporting structured and JSON outputs.
    /// </summary>
    /// <param name="Value">
    /// The format configuration for the model output.
    /// </param>
    /// <returns>
    /// An instance of TChatParams with response format settings applied.
    /// </returns>
    function ResponseFormat(const Value: TSchemaParams): TChatParams; overload;
    /// <summary>
    /// Specifies the format that the model must output, supporting structured and JSON outputs.
    /// </summary>
    /// <param name="Value">
    /// The format configuration for the model output.
    /// </param>
    /// <returns>
    /// An instance of TChatParams with response format settings applied.
    /// </returns>
    function ResponseFormat(const ParamProc: TProcRef<TSchemaParams>): TChatParams; overload;
    /// <summary>
    /// Specifies the format that the model must output, supporting structured and JSON outputs.
    /// </summary>
    /// <param name="Value">
    /// The format configuration for the model output.
    /// </param>
    /// <returns>
    /// An instance of TChatParams with response format settings applied.
    /// </returns>
    function ResponseFormat(const Value: TJSONObject): TChatParams; overload;
    /// <summary>
    /// Sets the seed for deterministic generation, ensuring repeatable results across sessions.
    /// </summary>
    /// <param name="Value">
    /// The seed as an integer.
    /// </param>
    /// <returns>
    /// Returns an instance of TChatParams with the seed set for deterministic responses.
    /// </returns>
    function Seed(const Value: Integer): TChatParams;
    /// <summary>
    /// Sets the service tier to use for processing the chat request, affecting latency and availability.
    /// </summary>
    /// <param name="Value">
    /// The service tier as a string ('auto' or 'default').
    /// </param>
    /// <returns>
    /// Returns an instance of TChatParams with the service tier configured.
    /// </returns>
    function ServiceTier(const Value: string): TChatParams;
    /// <summary>
    /// Determines when the API should stop generating further tokens.
    /// </summary>
    /// <param name="Value">
    /// A string or array of strings indicating stop sequences.
    /// </param>
    /// <returns>
    /// Returns an instance of TChatParams with the stop conditions set.
    /// </returns>
    function Stop(const Value: string): TChatParams; overload;
    /// <summary>
    /// Determines when the API should stop generating further tokens.
    /// </summary>
    /// <param name="Value">
    /// A string or array of strings indicating stop sequences.
    /// </param>
    /// <returns>
    /// Returns an instance of TChatParams with the stop conditions set.
    /// </returns>
    function Stop(const Value: TArray<string>): TChatParams; overload;
   /// <summary>
    /// Enables streaming of chat completions, allowing partial responses to be processed as they are generated.
    /// </summary>
    /// <param name="Value">
    /// A boolean indicating whether to enable streaming.
    /// </param>
    /// <returns>
    /// Returns an instance of TChatParams with streaming enabled.
    /// </returns>
    function Stream(const Value: Boolean = True): TChatParams;
    /// <summary>
    /// Configures options for streaming responses, such as inclusion of usage data.
    /// </summary>
    /// <param name="Value">
    /// A JSON object specifying streaming options.
    /// </param>
    /// <returns>
    /// Returns an instance of TChatParams with streaming options set.
    /// </returns>
    function StreamOptions(const Value: TJSONObject): TChatParams; overload;
    /// <summary>
    /// Configures options for streaming responses, such as inclusion of usage data.
    /// </summary>
    /// <param name="Value">
    /// A JSON object specifying streaming options.
    /// </param>
    /// <returns>
    /// Returns an instance of TChatParams with streaming options set.
    /// </returns>
    function StreamOptions(const IncludeUsage: Boolean): TChatParams; overload;
    /// <summary>
    /// Sets the temperature for generating responses, influencing the randomness and variety.
    /// </summary>
    /// <param name="Value">
    /// The temperature as a double.
    /// </param>
    /// <returns>
    /// Returns an instance of TChatParams with the temperature set.
    /// </returns>
    function Temperature(const Value: Double): TChatParams;
    /// <summary>
    /// Specifies the nucleus sampling threshold, determining how focused or broad the responses should be.
    /// </summary>
    /// <param name="Value">
    /// The top-p as a double, representing the probability mass threshold.
    /// </param>
    /// <returns>
    /// Returns an instance of TChatParams with the top-p configured.
    /// </returns>
    function TopP(const Value: Double): TChatParams;
    /// <summary>
    /// Configures which tools the model may call during the session.
    /// </summary>
    /// <param name="Value">
    /// An array of tools or functions the model can use.
    /// </param>
    /// <returns>
    /// An instance of TChatParams with tools configured.
    /// </returns>
    function Tools(const Value: TArray<TChatMessageTool>): TChatParams; overload;
    /// <summary>
    /// Configures which tools the model may call during the session.
    /// </summary>
    /// <param name="Value">
    /// An array of tools or functions the model can use.
    /// </param>
    /// <returns>
    /// An instance of TChatParams with tools configured.
    /// </returns>
    function Tools(const Value: TArray<IFunctionCore>): TChatParams; overload;
    /// <summary>
    /// Configures which tools the model may call during the session.
    /// </summary>
    /// <param name="Value">
    /// An array of tools or functions the model can use.
    /// </param>
    /// <returns>
    /// An instance of TChatParams with tools configured.
    /// </returns>
    function Tools(const Value: TJSONObject): TChatParams; overload;
    /// <summary>
    /// Sets the tool choice for the chat session, specifying how tools should be used.
    /// </summary>
    /// <param name="Value">
    /// The tool choice settings, including none, auto, or required.
    /// </param>
    /// <returns>
    /// An instance of TChatParams configured with tool choice settings.
    /// </returns>
    function ToolChoice(const Value: string): TChatParams; overload;
    /// <summary>
    /// Sets the tool choice for the chat session, specifying how tools should be used.
    /// </summary>
    /// <param name="Value">
    /// The tool choice settings, including none, auto, or required.
    /// </param>
    /// <returns>
    /// An instance of TChatParams configured with tool choice settings.
    /// </returns>
    function ToolChoice(const Value: TToolChoice): TChatParams; overload;
    /// <summary>
    /// Sets the tool choice for the chat session, specifying how tools should be used.
    /// </summary>
    /// <param name="Value">
    /// The tool choice settings, including none, auto, or required.
    /// </param>
    /// <returns>
    /// An instance of TChatParams configured with tool choice settings.
    /// </returns>
    function ToolChoice(const Value: TJSONObject): TChatParams; overload;
    /// <summary>
    /// Sets the tool choice for the chat session, specifying how tools should be used.
    /// </summary>
    /// <param name="Value">
    /// The tool choice settings, including none, auto, or required.
    /// </param>
    /// <returns>
    /// An instance of TChatParams configured with tool choice settings.
    /// </returns>
    function ToolChoice(const Value: TToolChoiceParams): TChatParams; overload;
    /// <summary>
    /// Enables or disables parallel tool calls during tool use.
    /// </summary>
    /// <param name="Value">
    /// True to enable parallel calls, false to disable.
    /// </param>
    /// <returns>
    /// An instance of TChatParams configured for parallel tool calling.
    /// </returns>
    function ParallelToolCalls(const Value: Boolean): TChatParams;
    /// <summary>
    /// Specifies a unique identifier for the end-user, helping monitor and prevent abuse.
    /// </summary>
    /// <param name="Value">
    /// The user identifier.
    /// </param>
    /// <returns>
    /// An instance of TChatParams configured with the user identifier.
    /// </returns>
    function User(const Value: string): TChatParams;
  end;

  /// <summary>
  /// Represents a single token's top log probability details.
  /// </summary>
  TTopLogprobs = class
  private
    FToken: string;
    FLogprob: Double;
    FBytes: TArray<Int64>;
  public
    /// <summary>
    /// The token analyzed for log probability.
    /// </summary>
    property Token: string read FToken write FToken;
    /// <summary>
    /// The log probability of the token.
    /// </summary>
    property Logprob: Double read FLogprob write FLogprob;
    /// <summary>
    /// The UTF-8 byte representation of the token.
    /// </summary>
    property Bytes: TArray<Int64> read FBytes write FBytes;
  end;

  /// <summary>
  /// Details about the log probabilities for a specific token, including its top probable alternatives.
  /// </summary>
  TLogprobsDetail = class
  private
    FToken: string;
    FLogprob: Double;
    FBytes: TArray<Int64>;
    [JsonNameAttribute('top_logprobs')]
    FTopLogprobs: TArray<TTopLogprobs>;
  public
    /// <summary>
    /// The token analyzed for log probability.
    /// </summary>
    property Token: string read FToken write FToken;
    /// <summary>
    /// The log probability of the token.
    /// </summary>
    property Logprob: Double read FLogprob write FLogprob;
    /// <summary>
    /// The UTF-8 byte representation of the token.
    /// </summary>
    property Bytes: TArray<Int64> read FBytes write FBytes;
    /// <summary>
    /// A list of the most likely alternatives and their respective log probabilities.
    /// </summary>
    property TopLogprobs: TArray<TTopLogprobs> read FTopLogprobs write FTopLogprobs;
    destructor Destroy; override;
  end;

  /// <summary>
  /// Manages the collection of log probability details for both content and refusal message tokens.
  /// </summary>
  TLogprobs = class
  private
    FContent: TArray<TLogprobsDetail>;
    FRefusal: TArray<TLogprobsDetail>;
  public
    /// <summary>
    /// Contains log probability details for content message tokens.
    /// </summary>
    property Content: TArray<TLogprobsDetail> read FContent write FContent;
    /// <summary>
    /// Contains log probability details for refusal message tokens.
    /// </summary>
    property Refusal: TArray<TLogprobsDetail> read FRefusal write FRefusal;
    destructor Destroy; override;
  end;

  /// <summary>
  /// Represents a function parameter in a tool call, specifying the function name
  /// and its arguments.
  /// </summary>
  /// <remarks>
  /// This class is used within the context of an API that supports remote function
  /// calls, enabling the specification of the function's name and the corresponding
  /// arguments in JSON format.
  /// </remarks>
  TFunction = class
  private
    FName: string;
    FArguments: string;
  public
    /// <summary>
    /// Gets or sets the name of the function to be called.
    /// </summary>
    property Name: string read FName write FName;
    /// <summary>
    /// Gets or sets the arguments for the function call in JSON formatted string.
    /// </summary>
    property Arguments: string read FArguments write FArguments;
  end;

  /// <summary>
  /// Encapsulates a tool call within a chat or API interaction, linking the call
  /// to a specific function with its parameters.
  /// </summary>
  /// <remarks>
  /// TToolcall is used to manage the execution of backend functions as part of
  /// an interactive session or a workflow, associating each tool call with a unique
  /// identifier and the necessary function parameters.
  /// </remarks>
  TToolcall = class
  private
    FId: string;
    [JsonReflectAttribute(ctString, rtString, TToolCallsInterceptor)]
    FType: TToolCalls;
    FFunction: TFunction;
  public
    /// <summary>
    /// Gets or sets the unique identifier for the tool call.
    /// </summary>
    property Id: string read FId write FId;
    /// <summary>
    /// Gets or sets the type of the tool call, typically linked to the nature
    /// of the function being called.
    /// </summary>
    property &Type: TToolCalls read FType write FType;
    /// <summary>
    /// Gets or sets the function to be executed as part of this tool call.
    /// </summary>
    property &Function: TFunction read FFunction write FFunction;
    destructor Destroy; override;
  end;

  /// <summary>
  /// Represents audio data that can be streamed or stored during a chat or API session,
  /// including its identifier and expiration metadata.
  /// </summary>
  /// <remarks>
  /// TAudioData is used in contexts where audio responses are managed, providing
  /// support for both temporary and persistent storage of audio files with associated
  /// metadata about expiration and format.
  /// </remarks>
  TAudioData = class
  private
    FId: string;
    [JsonNameAttribute('expires_at')]
    FExpiresAt: Int64;
    FData: string;
    FTranscript: string;
  public
    /// <summary>
    /// Gets or sets the unique identifier for the audio data, used for tracking
    /// and retrieval purposes.
    /// </summary>
    property Id: string read FId write FId;
    /// <summary>
    /// Gets or sets the expiration timestamp for the audio data, after which the
    /// data may no longer be available.
    /// </summary>
    property ExpiresAt: Int64 read FExpiresAt write FExpiresAt;
    /// <summary>
    /// Gets or sets the base64-encoded audio data.
    /// </summary>
    property Data: string read FData write FData;
    /// <summary>
    /// Gets or sets the transcript of the audio content, providing a text
    /// representation of the audio.
    /// </summary>
    property Transcript: string read FTranscript write FTranscript;
  end;

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
  TAudio = class(TAudioData)
  private
    FFileName: string;
  public
    /// <summary>
    /// Retrieves the audio content as a stream, allowing for playback or processing
    /// in real-time applications.
    /// </summary>
    /// <returns>
    /// A TStream object containing the audio data ready for use.
    /// </returns>
    function GetStream: TStream;
    /// <summary>
    /// Saves the audio data to a file, using the format specified during the
    /// creation of the audio data object.
    /// </summary>
    /// <param name="FileName">
    /// The name of the file where the audio data will be saved. The format of the
    /// audio file will correspond to the encoded data type.
    /// </param>
    procedure SaveToFile(const FileName: string);
    /// <summary>
    /// Property to get or set the file name associated with the audio data.
    /// </summary>
    /// <remarks>
    /// This property can be used to manage file naming for saved audio data,
    /// facilitating easier storage and retrieval operations.
    /// </remarks>
    property FileName: string read FFileName write FFileName;
  end;

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
  TDelta = class
  private
    FContent: string;
    [JsonNameAttribute('tool_calls')]
    FToolCalls: TArray<TToolcall>;
    [JsonReflectAttribute(ctString, rtString, TRoleInterceptor)]
    FRole: TRole;
    FRefusal: string;
  public
    /// <summary>
    /// Provides access to the content of the delta, which includes any text or structured
    /// data that has been added or modified in the chat message.
    /// </summary>
    /// <returns>
    /// A string containing the updated content.
    /// </returns>
    property Content: string read FContent write FContent;
    /// <summary>
    /// Lists tool calls associated with the delta, allowing for interaction with
    /// external functions or processes triggered by the chat updates.
    /// </summary>
    /// <returns>
    /// An array of TToolcall objects, each representing a specific call to an external tool.
    /// </returns>
    property ToolCalls: TArray<Ttoolcall> read FToolCalls write FToolCalls;
    /// <summary>
    /// Represents the role of the message author, helping to differentiate between
    /// user, system, and assistant messages within the chat structure.
    /// </summary>
    /// <returns>
    /// A TRole value indicating the role of the message author.
    /// </returns>
    property Role: TRole read FRole write FRole;
    /// <summary>
    /// Contains any refusal message that might be sent if the delta cannot be applied,
    /// providing feedback on errors or constraints within the chat process.
    /// </summary>
    /// <returns>
    /// A string detailing the refusal reason, if applicable.
    /// </returns>
    property Refusal: string read FRefusal write FRefusal;
    destructor Destroy; override;
  end;

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
  TMessage = class
  private
    FContent: string;
    FRefusal: string;
    [JsonNameAttribute('tool_calls')]
    FToolCalls: TArray<TToolcall>;
    [JsonReflectAttribute(ctString, rtString, TRoleInterceptor)]
    FRole: TRole;
    FAudio: TAudio;
  public
    /// <summary>
    /// Accesses the main content of the message, which could be text or structured data.
    /// </summary>
    /// <returns>
    /// A string representing the content of the message.
    /// </returns>
    property Content: string read FContent write FContent;
    /// <summary>
    /// If applicable, provides a refusal message indicating why a particular response
    /// or action was not taken.
    /// </summary>
    /// <returns>
    /// A string containing the refusal message.
    /// </returns>
    property Refusal: string read FRefusal write FRefusal;
    /// <summary>
    /// Details any tool calls that have been initiated as part of the message interaction,
    /// allowing for external processes or functions to be executed.
    /// </summary>
    /// <returns>
    /// An array of TToolcall objects, each representing a tool interaction.
    /// </returns>
    property ToolCalls: TArray<Ttoolcall> read FToolCalls write FToolCalls;
    /// <summary>
    /// Defines the role of the message's author, distinguishing between different types
    /// of participants such as user, assistant, or system.
    /// </summary>
    /// <returns>
    /// A TRole value indicating the author's role in the conversation.
    /// </returns>
    property Role: TRole read FRole write FRole;
    /// <summary>
    /// Contains any audio response data linked with the message, suitable for playback
    /// or further processing.
    /// </summary>
    /// <returns>
    /// A TAudio object encapsulating the audio data associated with the message.
    /// </returns>
    property Audio: TAudio read FAudio write FAudio;
    destructor Destroy; override;
  end;

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
  TChoice = class
  private
    [JsonReflectAttribute(ctString, rtString, TFinishReasonInterceptor)]
    [JsonNameAttribute('finish_reason')]
    FFinishReason: TFinishReason;
    FIndex: Int64;
    FMessage: TMessage;
    FLogprobs: TLogprobs;
    FDelta: TDelta;
  public
    /// <summary>
    /// Describes the reason why the message generation was stopped, such as reaching
    /// a stop condition or fulfilling all required tokens.
    /// </summary>
    /// <returns>
    /// A TFinishReason enumeration value describing the stop condition.
    /// </returns>
    property FinishReason: TFinishReason read FFinishReason write FFinishReason;
    /// <summary>
    /// Indicates the position or index of this choice relative to other possible
    /// choices generated in the same request.
    /// </summary>
    /// <returns>
    /// An integer representing the order or sequence of the choice.
    /// </returns>
    property Index: Int64 read FIndex write FIndex;
    /// <summary>
    /// Provides access to the message associated with this choice, including any
    /// text, audio, or structured responses.
    /// </summary>
    /// <returns>
    /// A TMessage object containing the response and any associated metadata.
    /// </returns>
    property Message: TMessage read FMessage write FMessage;
    /// <summary>
    /// Contains log probability details for the tokens used in the choice's message,
    /// useful for analyzing model behavior and decisions.
    /// </summary>
    /// <returns>
    /// A TLogprobs obje
    property Logprobs: TLogprobs read FLogprobs write FLogprobs;
    /// <summary>
    /// Represents a delta update for chat completions, encapsulating modifications
    /// made during streaming or batch updates of chat messages.
    /// </summary>
    /// <returns>
    /// A TDelta object detailing modifications made to the chat interaction.
    /// </returns>
    property Delta: TDelta read FDelta write FDelta;
    destructor Destroy; override;
  end;

  /// <summary>
  /// Represents detailed token usage statistics for a specific chat completion, providing insights into
  /// how tokens are allocated across different categories such as audio, reasoning, and predictions.
  /// </summary>
  /// <remarks>
  /// TCompletionDetail is essential for monitoring and analyzing the computational resources used during
  /// chat interactions. This class helps in understanding the efficiency and distribution of token usage
  /// within the completion process, aiding in optimization and resource management.
  /// </remarks>
  TCompletionDetail = class
  private
    [JsonNameAttribute('accepted_prediction_tokens')]
    FAcceptedPredictionTokens: Int64;
    [JsonNameAttribute('audio_tokens')]
    FAudioTokens: Int64;
    [JsonNameAttribute('reasoning_tokens')]
    FReasoningTokens: Int64;
    [JsonNameAttribute('rejected_prediction_tokens')]
    FRejectedPredictionTokens: Int64;
  public
    /// <summary>
    /// The number of tokens that were accepted during the prediction phase of the chat completion.
    /// </summary>
    /// <returns>
    /// An integer representing the count of tokens accepted for predictions.
    /// </returns>
    property AcceptedPredictionTokens: Int64 read FAcceptedPredictionTokens write FAcceptedPredictionTokens;
    /// <summary>
    /// The number of tokens used for processing audio components within the chat completion.
    /// </summary>
    /// <returns>
    /// An integer indicating the total tokens used for audio-related activities.
    /// </returns>
    property AudioTokens: Int64 read FAudioTokens write FAudioTokens;
    /// <summary>
    /// The number of tokens dedicated to reasoning processes, helping to understand the depth of
    /// analysis performed by the chat model.
    /// </summary>
    /// <returns>
    /// An integer showing the amount of tokens used for reasoning.
    /// </returns>
    property ReasoningTokens: Int64 read FReasoningTokens write FReasoningTokens;
    /// <summary>
    /// The number of tokens that were rejected or not used in the final output during the prediction
    /// phase, reflecting efficiency and decision-making within the model.
    /// </summary>
    /// <returns>
    /// An integer detailing the tokens that were rejected during the prediction process.
    /// </returns>
    property RejectedPredictionTokens: Int64 read FRejectedPredictionTokens write FRejectedPredictionTokens;
  end;

  /// <summary>
  /// Provides detailed statistics about the tokens used in the prompt of a chat session,
  /// highlighting the resource utilization during the initial stages of chat interactions.
  /// </summary>
  /// <remarks>
  /// TPromptDetail is crucial for evaluating the computational cost of initiating chat interactions,
  /// specifically in terms of the number of tokens used for audio and cached content. This class aids
  /// in optimizing token usage, ensuring efficient management of resources in chat applications.
  /// </remarks>
  TPromptDetail = class
  private
    [JsonNameAttribute('audio_tokens')]
    FAudioTokens: Int64;
    [JsonNameAttribute('cached_tokens')]
    FCachedTokens: Int64;
  public
    /// <summary>
    /// The number of tokens used for processing audio elements in the prompt, reflecting
    /// the computational resources allocated to handle audio inputs.
    /// </summary>
    /// <returns>
    /// An integer representing the count of audio tokens used.
    /// </returns>
    property AudioTokens: Int64 read FAudioTokens write FAudioTokens;
    /// <summary>
    /// The number of tokens used from cached responses or content, indicating the reuse of
    /// previously computed data to optimize response times and resource consumption.
    /// </summary>
    /// <returns>
    /// An integer showing the amount of cached tokens utilized in the prompt.
    /// </returns>
    property CachedTokens: Int64 read FCachedTokens write FCachedTokens;
  end;

  /// <summary>
  /// Provides a comprehensive overview of token usage statistics for a chat completion request,
  /// facilitating detailed analysis of computational resource allocation.
  /// </summary>
  /// <remarks>
  /// TUsage is instrumental in tracking and managing the resource usage in chat applications,
  /// offering insights into how tokens are distributed between the prompt and completion phases.
  /// This class allows developers to assess and optimize the efficiency of the token utilization process.
  /// </remarks>
  TUsage = class
  private
    [JsonNameAttribute('completion_tokens')]
    FCompletionTokens: Int64;
    [JsonNameAttribute('prompt_tokens')]
    FPromptTokens: Int64;
    [JsonNameAttribute('total_tokens')]
    FTotalTokens: Int64;
    [JsonNameAttribute('completion_tokens_details')]
    FCompletionTokensDetails: TCompletionDetail;
    [JsonNameAttribute('prompt_tokens_details')]
    FPromptTokensDetails: TPromptDetail;
  public
    /// <summary>
    /// Represents the total number of tokens used during the completion phase of the chat interaction.
    /// </summary>
    /// <returns>
    /// An integer representing the total number of completion tokens used.
    /// </returns>
    property CompletionTokens: Int64 read FCompletionTokens write FCompletionTokens;
    /// <summary>
    /// Represents the total number of tokens used during the prompt phase of the chat interaction.
    /// </summary>
    /// <returns>
    /// An integer representing the total number of prompt tokens used.
    /// </returns>
    property PromptTokens: Int64 read FPromptTokens write FPromptTokens;
    /// <summary>
    /// Represents the total number of tokens used in both the prompt and completion phases combined.
    /// </summary>
    /// <returns>
    /// An integer representing the total number of tokens used in the entire chat interaction.
    /// </returns>
    property TotalTokens: Int64 read FTotalTokens write FTotalTokens;
    /// <summary>
    /// Provides detailed insights into token usage specifically within the completion phase,
    /// aiding in understanding and optimizing resource allocation.
    /// </summary>
    /// <returns>
    /// A TCompletionDetail object that contains detailed statistics on token usage during the completion phase.
    /// </returns>
    property CompletionTokensDetails: TCompletionDetail read FCompletionTokensDetails write FCompletionTokensDetails;
    /// <summary>
    /// Provides detailed insights into token usage specifically within the prompt phase,
    /// aiding in understanding and optimizing resource allocation.
    /// </summary>
    /// <returns>
    /// A TPromptDetail object that contains detailed statistics on token usage during the prompt phase.
    /// </returns>
    property PromptTokensDetails: TPromptDetail read FPromptTokensDetails write FPromptTokensDetails;
    destructor Destroy; override;
  end;

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
  TChat = class(TJSONFingerprint)
  private
    FId: string;
    FChoices: TArray<TChoice>;
    FCreated: Int64;
    FModel: string;
    [JsonNameAttribute('service_tier')]
    FServiceTier: string;
    [JsonNameAttribute('system_fingerprint')]
    FSystemFingerprint: string;
    FObject: string;
    FUsage: TUsage;
  public
    /// <summary>
    /// The unique identifier for the chat completion.
    /// </summary>
    /// <returns>
    /// A string representing the ID of the chat completion.
    /// </returns>
    property Id: string read FId write FId;
    /// <summary>
    /// A collection of choice objects that represent the possible responses generated by the model.
    /// </summary>
    /// <returns>
    /// An array of TChoice objects, each detailing a potential response within the chat interaction.
    /// </returns>
    property Choices: TArray<TChoice> read FChoices write FChoices;
    /// <summary>
    /// The Unix timestamp indicating when the chat completion was created.
    /// </summary>
    /// <returns>
    /// An Int64 value representing the creation time of the chat completion.
    /// </returns>
    property Created: Int64 read FCreated write FCreated;
    /// <summary>
    /// The model identifier used to generate the chat completion.
    /// </summary>
    /// <returns>
    /// A string representing the model used for generating the chat response.
    /// </returns>
    property Model: string read FModel write FModel;
    /// <summary>
    /// The service tier under which the chat completion request was processed.
    /// </summary>
    /// <returns>
    /// A string representing the service tier, influencing the processing priorities and resources allocated.
    /// </returns>
    property ServiceTier: string read FServiceTier write FServiceTier;
    /// <summary>
    /// A fingerprint that represents the backend configuration under which the model runs.
    /// </summary>
    /// <returns>
    /// A string representing the system fingerprint, useful for debugging and ensuring consistency across sessions.
    /// </returns>
    property SystemFingerprint: string read FSystemFingerprint write FSystemFingerprint;
    /// <summary>
    /// The type of object, always set to 'chat.completion' to identify the nature of this JSON object.
    /// </summary>
    /// <returns>
    /// A string that confirms the object type as 'chat.completion'.
    /// </returns>
    property &Object: string read FObject write FObject;
    /// <summary>
    /// Provides detailed statistics on token usage for the entire chat completion request.
    /// </summary>
    /// <returns>
    /// A TUsage object that includes detailed token usage data for assessing computational resource allocation.
    /// </returns>
    property Usage: TUsage read FUsage write FUsage;
    destructor Destroy; override;
  end;

  /// <summary>
  /// Manages asynchronous chat callBacks for a chat request using <c>TChat</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynChat</c> type extends the <c>TAsynParams&lt;TChat&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking chat operations and is specifically tailored for scenarios where multiple choices from a chat model are required.
  /// </remarks>
  TAsynChat = TAsynCallBack<TChat>;

  /// <summary>
  /// Manages asynchronous streaming chat callBacks for a chat request using <c>TChat</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynChatStream</c> type extends the <c>TAsynStreamParams&lt;TChat&gt;</c> record to support the lifecycle of an asynchronous streaming chat operation.
  /// It provides callbacks for different stages, including when the operation starts, progresses with new data chunks, completes successfully, or encounters an error.
  /// This structure is ideal for handling scenarios where the chat response is streamed incrementally, providing real-time updates to the user interface.
  /// </remarks>
  TAsynChatStream = TAsynStreamCallBack<TChat>;

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
  TChatRoute = class(TGenAIRoute)
    /// <summary>
    /// Asynchronously creates a chat completion, invoking the specified callbacks
    /// to handle the response data and events.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure that allows setting parameters for the chat completion request.
    /// </param>
    /// <param name="CallBacks">
    /// A function that returns an instance of TAsynChat, providing callbacks for different
    /// stages of the request lifecycle such as start, success, and error handling.
    /// </param>
    procedure AsynCreate(ParamProc: TProc<TChatParams>; CallBacks: TFunc<TAsynChat>);
    /// <summary>
    /// Asynchronously creates a chat completion and supports streaming the responses,
    /// suitable for real-time interaction applications.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure that allows setting parameters for the chat completion request.
    /// </param>
    /// <param name="CallBacks">
    /// A function that returns an instance of TAsynChatStream, providing an interface for
    /// managing streamed chat responses.
    /// </param>
    procedure AsynCreateStream(ParamProc: TProc<TChatParams>; CallBacks: TFunc<TAsynChatStream>);
    /// <summary>
    /// Synchronously creates a chat completion, directly returning the chat completion
    /// object upon completion.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure that allows setting parameters for the chat completion request.
    /// </param>
    /// <returns>
    /// A TChat object containing the completion response from the model.
    /// </returns>
    function Create(ParamProc: TProc<TChatParams>): TChat;
    /// <summary>
    /// Initiates a synchronous stream of chat completions, allowing for real-time interaction
    /// and updates via a provided event handler.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure that allows setting parameters for the chat completion request.
    /// </param>
    /// <param name="Event">
    /// An event handler that processes the streamed chat completion data.
    /// </param>
    /// <returns>
    /// Returns True if the streaming session is initiated successfully, otherwise False.
    /// </returns>
    function CreateStream(ParamProc: TProc<TChatParams>; Event: TStreamCallbackEvent<TChat>): Boolean;
  end;

implementation

uses
  System.StrUtils, GenAI.Httpx, GenAI.NetEncoding.Base64, REST.Json;

{ TMessagePayload }

function TMessagePayload.Content(const Value: string): TMessagePayload;
begin
  Result := TMessagePayload(Add('content', Value));
end;

class function TMessagePayload.Assistant(
  const ParamProc: TProcRef<TMessagePayload>): TMessagePayload;
begin
  Result := TMessagePayload.Create.Role(TRole.assistant);
  if Assigned(ParamProc) then
    begin
      ParamProc(Result);
    end;
end;

class function TMessagePayload.Assistant(
  const Value: TMessagePayload): TMessagePayload;
begin
  Result := Value;
end;

function TMessagePayload.Audio(const Value: string): TMessagePayload;
begin
  Result := TMessagePayload(Add('audio', TJSONObject.Create.AddPair('id', Value)));
end;

function TMessagePayload.Content(
  const Value: TArray<TAssistantContentParams>): TMessagePayload;
begin
  var JSONArray := TJSONArray.Create;
  for var Item in Value do
    JSONArray.Add(Item.Detach);
  Result := TMessagePayload(Add('content', JSONArray));
end;

function TMessagePayload.Content(const Value: TJSONArray): TMessagePayload;
begin
  Result := TMessagePayload(Add('content', Value));
end;

function TMessagePayload.Content(const Value: TJSONObject): TMessagePayload;
begin
  Result := TMessagePayload(Add('content', Value));
end;

class function TMessagePayload.Developer(const Content,
  Name: string): TMessagePayload;
begin
  Result := New(TRole.developer, Content, Name);
end;

function TMessagePayload.Name(const Value: string): TMessagePayload;
begin
  Result := TMessagePayload(Add('name', Value));
end;

class function TMessagePayload.New(const Role: TRole; const Content,
  Name: string): TMessagePayload;
begin
  Result := TMessagePayload.Create.Role(Role).Content(Content);
  if not Name.IsEmpty then
    Result := Result.Name(Name);
end;

function TMessagePayload.Refusal(const Value: string): TMessagePayload;
begin
  Result := TMessagePayload(Add('refusal', Value));
end;

function TMessagePayload.Role(const Value: string): TMessagePayload;
begin
  Result := TMessagePayload(Add('role', TRole.Create(Value).ToString));
end;

function TMessagePayload.Role(const Value: TRole): TMessagePayload;
begin
  Result := TMessagePayload(Add('role', Value.ToString));
end;

class function TMessagePayload.System(const Content,
  Name: string): TMessagePayload;
begin
  Result := New(TRole.system, Content, Name);
end;

class function TMessagePayload.Tool(const Content,
  ToolCallId: string): TMessagePayload;
begin
  Result := New(TRole.tool, Content).ToolCallId(ToolCallId);
end;

function TMessagePayload.ToolCallId(const Value: string): TMessagePayload;
begin
  Result := TMessagePayload(Add('tool_call_id', Value));
end;

function TMessagePayload.ToolCalls(
  const Value: TArray<TToolCallsParams>): TMessagePayload;
begin
  var JSONArray := TJSONArray.Create;
  for var Item in Value do
    JSONArray.Add(Item.Detach);
  Result := TMessagePayload(Add('tool_calls', JSONArray));
end;

class function TMessagePayload.User(const Content,
  Name: string): TMessagePayload;
begin
  Result := New(TRole.User, Content, Name);
end;

class function TMessagePayload.User(const Content: string;
  const Docs: TArray<string>; const Name: string): TMessagePayload;
begin
  var JSONArray := TJSONArray.Create;
  JSONArray.Add(TContentParams.Create.&Type('text').Text(Content).Detach);

  for var Item in Docs do
    JSONArray.Add(TContentParams.AddFile(Item).Detach);

  Result := TMessagePayload.Create.Role(TRole.user).Content(JSONArray);
  if not Name.IsEmpty then
    Result := Result.Name(Name);
end;

class function TMessagePayload.User(const Docs: TArray<string>;
  const Name: string): TMessagePayload;
begin
  var JSONArray := TJSONArray.Create;
  for var Item in Docs do
    JSONArray.Add(TContentParams.AddFile(Item).Detach);

  Result := TMessagePayload.Create.Role(TRole.user).Content(JSONArray);
  if not Name.IsEmpty then
    Result := Result.Name(Name);
end;

{ TChatParams }

function TChatParams.Audio(const Voice: TChatVoice;
  const Format: TAudioFormat): TChatParams;
begin
  var Value := TAudioParams.Create.Voice(Voice).Format(Format);
  Result := TChatParams(Add('audio', Value.Detach));
end;

function TChatParams.Audio(const Voice, Format: string): TChatParams;
begin
  Result := Audio(TChatVoice.Create(Voice), TAudioFormat.Create(Format));
end;

function TChatParams.FrequencyPenalty(const Value: Double): TChatParams;
begin
  Result := TChatParams(Add('frequency_penalty', Value));
end;

function TChatParams.LogitBias(const Value: TJSONObject): TChatParams;
begin
  Result := TChatParams(Add('logit_bias', Value));
end;

function TChatParams.Logprobs(const Value: Boolean): TChatParams;
begin
  Result := TChatParams(Add('logprobs', Value));
end;

function TChatParams.MaxCompletionTokens(const Value: Integer): TChatParams;
begin
  Result := TChatParams(Add('max_completion_tokens', Value));
end;

function TChatParams.Messages(
  const Value: TArray<TMessagePayload>): TChatParams;
begin
  var JSONArray := TJSONArray.Create;
  for var Item in Value do
    JSONArray.Add(Item.Detach);
  Result := TChatParams(Add('messages', JSONArray));
end;

function TChatParams.Messages(const Value: TJSONObject): TChatParams;
begin
  Result := TChatParams(Add('messages', Value));
end;

function TChatParams.Messages(const Value: TJSONArray): TChatParams;
begin
  Result := TChatParams(Add('messages', Value));
end;

function TChatParams.Metadata(const Value: TJSONObject): TChatParams;
begin
  Result := TChatParams(Add('metadata', Value));
end;

function TChatParams.Modalities(const Value: TArray<string>): TChatParams;
var
  Checks: TArray<string>;
begin
  {--- Check string values }
  for var Item in Value do
    Checks := Checks + [TModalities.Create(Item).ToString];
  Result := TChatParams(Add('modalities', Checks));
end;

function TChatParams.Modalities(const Value: TArray<TModalities>): TChatParams;
begin
  var JSONArray := TJSONArray.Create;
  for var Item in Value do
    JSONArray.Add(Item.ToString);
  Result := TChatParams(Add('modalities', JSONArray));
end;

function TChatParams.Model(const Value: string): TChatParams;
begin
  Result := TChatParams(Add('model', Value));
end;

function TChatParams.N(const Value: Integer): TChatParams;
begin
  Result := TChatParams(Add('n', Value));
end;

function TChatParams.ParallelToolCalls(const Value: Boolean): TChatParams;
begin
  Result := TChatParams(Add('parallel_tool_calls', Value));
end;

function TChatParams.Prediction(
  const Value: TArray<TPredictionPartParams>): TChatParams;
begin
  Result := TChatParams(Add('prediction', TPredictionParams.New(Value).Detach));
end;

function TChatParams.PresencePenalty(const Value: Double): TChatParams;
begin
  Result := TChatParams(Add('presence_penalty', Value));
end;

function TChatParams.Prediction(const Value: string): TChatParams;
begin
  Result := TChatParams(Add('prediction', TPredictionParams.New(Value).Detach));
end;

function TChatParams.ReasoningEffort(
  const Value: TReasoningEffort): TChatParams;
begin
  Result := TChatParams(Add('reasoning_effort', Value.ToString));
end;

function TChatParams.ReasoningEffort(const Value: string): TChatParams;
begin
  Result := TChatParams(Add('reasoning_effort', TReasoningEffort.Create(Value).ToString));
end;

function TChatParams.ResponseFormat(
  const ParamProc: TProcRef<TSchemaParams>): TChatParams;
begin
  if Assigned(ParamProc) then
    begin
      var Value := TSchemaParams.Create;
      ParamProc(Value);
      Result := TChatParams(Add('response_format', Value.Detach));
    end
  else Result := Self;
end;

function TChatParams.ResponseFormat(const Value: TSchemaParams): TChatParams;
begin
  Result := TChatParams(Add('response_format', Value.Detach));
end;

function TChatParams.ResponseFormat(const Value: TJSONObject): TChatParams;
begin
  Result := TChatParams(Add('response_format', Value));
end;

function TChatParams.Seed(const Value: Integer): TChatParams;
begin
  Result := TChatParams(Add('seed', Value));
end;

function TChatParams.ServiceTier(const Value: string): TChatParams;
begin
  Result := TChatParams(Add('service_tier', Value));
end;

function TChatParams.Stop(const Value: string): TChatParams;
begin
  Result := TChatParams(Add('stop', Value));
end;

function TChatParams.Stop(const Value: TArray<string>): TChatParams;
begin
  Result := TChatParams(Add('stop', Value));
end;

function TChatParams.Store(const Value: Boolean): TChatParams;
begin
  Result := TChatParams(Add('store', Value));
end;

function TChatParams.Stream(const Value: Boolean): TChatParams;
begin
  Result := TChatParams(Add('stream', Value));
end;

function TChatParams.StreamOptions(const IncludeUsage: Boolean): TChatParams;
begin
  Result := StreamOptions(TJSONObject.Create.AddPair('stream_options', IncludeUsage));
end;

function TChatParams.StreamOptions(const Value: TJSONObject): TChatParams;
begin
  Result := TChatParams(Add('stream_options', Value));
end;

function TChatParams.Temperature(const Value: Double): TChatParams;
begin
  Result := TChatParams(Add('temperature', Value));
end;

function TChatParams.ToolChoice(const Value: string): TChatParams;
begin
  var index := IndexStr(Value.ToLower, ['none', 'auto', 'required']);
  if index > -1 then
    Result := TChatParams(Add('tool_choice', Value)) else
    Result := ToolChoice(TToolChoiceParams.New(Value));
end;

function TChatParams.ToolChoice(const Value: TToolChoice): TChatParams;
begin
  Result := ToolChoice(Value.ToString);
end;

function TChatParams.ToolChoice(const Value: TJSONObject): TChatParams;
begin
  Result := TChatParams(Add('tool_choice', Value));
end;

function TChatParams.ToolChoice(const Value: TToolChoiceParams): TChatParams;
begin
  Result := TChatParams(Add('tool_choice', Value.Detach));
end;

function TChatParams.Tools(const Value: TJSONObject): TChatParams;
begin
  Result := TChatParams(Add('tools', Value));
end;

function TChatParams.Tools(const Value: TArray<IFunctionCore>): TChatParams;
var
  Funcs: TArray<TChatMessageTool>;
begin
  for var Item in Value do
    Funcs := Funcs + [TChatMessageTool.Add(Item)];
  Result := Tools(Funcs);
end;

function TChatParams.Tools(const Value: TArray<TChatMessageTool>): TChatParams;
begin
  var JSONArray := TJSONArray.Create;
  for var Item in Value do
    JSONArray.Add(Item.ToJson);
  Result := TChatParams(Add('tools', JSONArray));
end;

function TChatParams.TopLogprobs(const Value: Integer): TChatParams;
begin
  Result := TChatParams(Add('top_logprobs', Value));
end;

function TChatParams.TopP(const Value: Double): TChatParams;
begin
  Result := TChatParams(Add('top_p', Value));
end;

function TChatParams.User(const Value: string): TChatParams;
begin
  Result := TChatParams(Add('user', Value));
end;

{ TContentParams }

class function TContentParams.AddFile(
  const FileLocation: string): TContentParams;
var
  MimeType: string;
  Detail: TImageDetail;
begin
  {--- Param detail extraction }
  var Location := Extract(FileLocation, Detail);

  {--- Retrieve mimetype }
  if Location.ToLower.StartsWith('http') then
    MimeType := THttpx.GetMimeType(Location) else
    MimeType := GetMimeType(Location);

  {--- Audio file managment }
  var index := IndexStr(MimeType, AudioTypeAccepted);
  if index <> -1 then
    Exit(TContentParams.Create.&Type('input_audio').InputAudio(TInputAudio.New(Location)));

  {--- Image file managment }
  index := IndexStr(MimeType, ImageTypeAccepted);
  if index <> -1 then
    Exit(TContentParams.Create.&Type('image_url').ImageUrl(TImageUrl.New(Location, Detail)));

  raise Exception.CreateFmt('%s : File not managed', [Location]);
end;

class function TContentParams.Extract(const Value: string;
  var Detail: TImageDetail): string;
begin
  Detail := id_auto;
  var index := Value.Trim.Tolower.IndexOf('detail');
  if index > -1 then
    begin
      Result := Value.Substring(0, index-1);
      var Details := Value.Substring(index, Value.Length).Replace(' ', '').Split(['=']);
      if Length(Details) = 2 then
        Detail := TImageDetail.Create(Details[1]);
    end
  else
    begin
      Result := Value.Trim;
    end;
end;

function TContentParams.ImageUrl(const Value: TImageUrl): TContentParams;
begin
  Result := TContentParams(Add('image_url', Value.Detach));
end;

function TContentParams.InputAudio(const Value: TInputAudio): TContentParams;
begin
  Result := TContentParams(Add('input_audio', Value.Detach));
end;

function TContentParams.Text(const Value: string): TContentParams;
begin
  Result := TContentParams(Add('text', Value));
end;

function TContentParams.&Type(const Value: string): TContentParams;
begin
  Result := TContentParams(Add('type', Value));
end;

{ TImageUrl }

function TImageUrl.Detail(const Value: TImageDetail): TImageUrl;
begin
  Result := TImageUrl(Add('detail', Value.ToString));
end;

class function TImageUrl.New(const PathLocation: string; const Detail: TImageDetail): TImageUrl;
begin
  Result := TImageUrl.Create.Url( ProcessUrlOrEncodeData(PathLocation) );
  if Detail <> id_auto then
    Result := Result.Detail(Detail);
end;

function TImageUrl.Url(const Value: string): TImageUrl;
begin
  Result := TImageUrl(Add('url', Value));
end;

{ TInputAudio }

function TInputAudio.Data(const Value: string): TInputAudio;
begin
  Result := TInputAudio(Add('data', Value));
end;

function TInputAudio.Format(const Value: string): TInputAudio;
begin
  Result := TInputAudio(Add('format', Value));
end;

function TInputAudio.Format(const Value: TAudioFormat): TInputAudio;
begin
  Result := Format(Value.ToString);
end;

class function TInputAudio.New(const PathLocation: string): TInputAudio;
var
  MimeType: string;
begin
  if PathLocation.ToLower.StartsWith('http') then
    Result := TInputAudio.Create.Data(THttpx.LoadDataToBase64(PathLocation, MimeType)) else
    Result := TInputAudio.Create.Data(EncodeBase64(PathLocation, MimeType));
  Result := Result.Format(TAudioFormat.InputMimeType(MimeType));
end;

{ TToolCallsParams }

function TToolCallsParams.&Type(const Value: string): TToolCallsParams;
begin
  Result := TToolCallsParams(Add('type', TToolCalls.Create(Value).ToString));
end;

function TToolCallsParams.&Type(const Value: TToolCalls): TToolCallsParams;
begin
  Result := TToolCallsParams(Add('type', Value.ToString));
end;

function TToolCallsParams.&Function(const Name,
  Arguments: string): TToolCallsParams;
begin
  var Func := TFunctionParams.Create.Name(Name).Arguments(Arguments);
  Result := TToolCallsParams(Add('function', Func.Detach));
end;

function TToolCallsParams.Id(const Value: string): TToolCallsParams;
begin
  Result := TToolCallsParams(Add('id', Value));
end;

class function TToolCallsParams.New(const Id, Name,
  Arguments: string): TToolCallsParams;
begin
  Result := TToolCallsParams.Create.Id(Id).&Type(tc_function).&Function(Name, Arguments);
end;

{ TFunctionParams }

function TFunctionParams.Arguments(const Value: string): TFunctionParams;
begin
  Result := TFunctionParams(Add('arguments', Value));
end;

function TFunctionParams.Name(const Value: string): TFunctionParams;
begin
  Result := TFunctionParams(Add('name', Value));
end;

{ TAssistantContentParams }

class function TAssistantContentParams.AddRefusal(const AType,
  Value: string): TAssistantContentParams;
begin
  Result := TAssistantContentParams.Create.&Type(AType).Refusal(Value);
end;

class function TAssistantContentParams.AddText(const AType,
  Value: string): TAssistantContentParams;
begin
  Result := TAssistantContentParams.Create.&Type(AType).Text(Value);
end;

function TAssistantContentParams.Refusal(
  const Value: string): TAssistantContentParams;
begin
  Result := TAssistantContentParams(Add('refusal', Value));
end;

function TAssistantContentParams.Text(
  const Value: string): TAssistantContentParams;
begin
  Result := TAssistantContentParams(Add('text', Value));
end;

function TAssistantContentParams.&Type(
  const Value: string): TAssistantContentParams;
begin
  Result := TAssistantContentParams(Add('type', Value));
end;

{ TPredictionParams }

function TPredictionParams.Content(
  const Value: string): TPredictionParams;
begin
  Result := TPredictionParams(Add('content', Value));
end;

function TPredictionParams.Content(
  const Value: TArray<TPredictionPartParams>): TPredictionParams;
begin
  var JSONArray := TJSONArray.Create;
  for var Item in Value do
    JSONArray.Add(Item.Detach);
  Result := TPredictionParams(Add('content', JSONArray));
end;

class function TPredictionParams.New(
  const Value: TArray<TPredictionPartParams>): TPredictionParams;
begin
  Result := TPredictionParams.Create.&Type('content').Content(Value);
end;

class function TPredictionParams.New(const Value: string): TPredictionParams;
begin
  Result := TPredictionParams.Create.&Type('content').Content(Value);
end;

function TPredictionParams.&Type(const Value: string): TPredictionParams;
begin
  Result := TPredictionParams(Add('type', Value));
end;

{ TPredictionPartParams }

class function TPredictionPartParams.New(const AType,
  Text: string): TPredictionPartParams;
begin
  Result := TPredictionPartParams.Create.&Type(AType).Text(Text);
end;

function TPredictionPartParams.Text(
  const Value: string): TPredictionPartParams;
begin
  Result := TPredictionPartParams(Add('text', Value));
end;

function TPredictionPartParams.&Type(
  const Value: string): TPredictionPartParams;
begin
  Result := TPredictionPartParams(Add('type', Value));
end;

{ TAudioParams }

function TAudioParams.Format(const Value: TAudioFormat): TAudioParams;
begin
  Result := TAudioParams(Add('format', Value.ToString));
end;

function TAudioParams.Voice(const Value: TChatVoice): TAudioParams;
begin
  Result := TAudioParams(Add('voice', Value.ToString));
end;

{ TToolChoiceParams }

function TToolChoiceParams.&Function(const Name: string): TToolChoiceParams;
begin
  Result := TToolChoiceParams(Add('function', TToolChoiceFunctionParams.Create.Name(Name).Detach));
end;

class function TToolChoiceParams.New(const Name: string): TToolChoiceParams;
begin
  Result := TToolChoiceParams.Create.&Type('function').&Function(Name);
end;

function TToolChoiceParams.&Type(const Value: string): TToolChoiceParams;
begin
  Result := TToolChoiceParams(Add('type', Value));
end;

{ TToolChoiceFunctionParams }

function TToolChoiceFunctionParams.Name(
  const Value: string): TToolChoiceFunctionParams;
begin
  Result := TToolChoiceFunctionParams(Add('name', Value));
end;

{ TChat }

destructor TChat.Destroy;
begin
  for var Item in FChoices do
    Item.Free;
  if Assigned(FUsage) then
    FUsage.Free;
  inherited;
end;

{ TUsage }

destructor TUsage.Destroy;
begin
  if Assigned(FCompletionTokensDetails) then
    FCompletionTokensDetails.Free;
  if Assigned(FPromptTokensDetails) then
    FPromptTokensDetails.Free;
  inherited;
end;

{ TChoice }

destructor TChoice.Destroy;
begin
  if Assigned(FMessage) then
    FMessage.Free;
  if Assigned(FLogprobs) then
    FLogprobs.Free;
  if Assigned(FDelta) then
    FDelta.Free;
  inherited;
end;

{ Ttoolcall }

destructor Ttoolcall.Destroy;
begin
  if Assigned(FFunction) then
    FFunction.Free;
  inherited;
end;

{ TMessage }

destructor TMessage.Destroy;
begin
  for var Item in FToolCalls do
    Item.Free;
  if Assigned(FAudio) then
    FAudio.Free;
  inherited;
end;

{ TLogprobs }

destructor TLogprobs.Destroy;
begin
  for var Item in FContent do
    Item.Free;
  for var Item in FRefusal do
    Item.Free;
  inherited;
end;

{ TLogprobsDetail }

destructor TLogprobsDetail.Destroy;
begin
  for var Item in FTopLogprobs do
    Item.Free;
  inherited;
end;

{ TDelta }

destructor TDelta.Destroy;
begin
  for var Item in FToolCalls do
    Item.Free;
  inherited;
end;

{ TChatRoute }

procedure TChatRoute.AsynCreateStream(ParamProc: TProc<TChatParams>;
  CallBacks: TFunc<TAsynChatStream>);
begin
  var CallBackParams := TUseParamsFactory<TAsynChatStream>.CreateInstance(CallBacks);

  var Sender := CallBackParams.Param.Sender;
  var OnStart := CallBackParams.Param.OnStart;
  var OnSuccess := CallBackParams.Param.OnSuccess;
  var OnProgress := CallBackParams.Param.OnProgress;
  var OnError := CallBackParams.Param.OnError;
  var OnCancellation := CallBackParams.Param.OnCancellation;
  var OnDoCancel := CallBackParams.Param.OnDoCancel;

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
                procedure (var Chat: TChat; IsDone: Boolean; var Cancel: Boolean)
                begin
                  {--- Check that the process has not been canceled }
                  if Assigned(OnDoCancel) then
                    TThread.Queue(nil,
                        procedure
                        begin
                          Stop := OnDoCancel();
                        end);
                  if Stop then
                    begin
                      {--- Trigger when processus was stopped }
                      if Assigned(OnCancellation) then
                        TThread.Queue(nil,
                        procedure
                        begin
                          OnCancellation(Sender)
                        end);
                      Cancel := True;
                      Exit;
                    end;
                  if not IsDone and Assigned(Chat) then
                    begin
                      var LocalChat := Chat;
                      Chat := nil;

                      {--- Triggered when processus is progressing }
                      if Assigned(OnProgress) then
                        TThread.Synchronize(TThread.Current,
                        procedure
                        begin
                          try
                            OnProgress(Sender, LocalChat);
                          finally
                            {--- Makes sure to release the instance containing the data obtained
                                 following processing}
                            LocalChat.Free;
                          end;
                        end)
                     else
                       LocalChat.Free;
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

procedure TChatRoute.AsynCreate(ParamProc: TProc<TChatParams>;
  CallBacks: TFunc<TAsynChat>);
begin
  with TAsynCallBackExec<TAsynChat, TChat>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TChat
      begin
        Result := Self.Create(ParamProc);
      end);
  finally
    Free;
  end;
end;

function TChatRoute.Create(ParamProc: TProc<TChatParams>): TChat;
begin
  Result := API.Post<TChat, TChatParams>('chat/completions', ParamProc);
end;

function TChatRoute.CreateStream(ParamProc: TProc<TChatParams>;
  Event: TStreamCallbackEvent<TChat>): Boolean;
begin
  var Response := TStringStream.Create('', TEncoding.UTF8);
  try
    Result := API.Post<TChatParams>('chat/completions', ParamProc, Response,
      TStreamCallback<TChat>.CreateInstance(Response, Event, TApiDeserializer.Parse<TChat>).OnStream);
  finally
    Response.Free;
  end;
end;

{ TAudio }

function TAudio.GetStream: TStream;
begin
  {--- Create a memory stream to write the decoded content. }
  Result := TMemoryStream.Create;
  try
    {--- Convert the base-64 string directly into the memory stream. }
    DecodeBase64ToStream(Data, Result)
  except
    Result.Free;
    raise;
  end;
end;

procedure TAudio.SaveToFile(const FileName: string);
begin
  if FileName.Trim.IsEmpty then
    raise Exception.Create('File record aborted. SaveToFile requires a filename.');

  try
    Self.FFileName := FileName;
    {--- Perform the decoding operation and save it into the file specified by the FileName parameter. }
    DecodeBase64ToFile(Data, FileName)
  except
    raise;
  end;
end;

end.
