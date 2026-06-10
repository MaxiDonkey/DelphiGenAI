unit GenAI.Chat.Request;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGenAI
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.SysUtils, System.Classes, System.JSON,
  GenAI.API.Params, GenAI.Types, GenAI.Schema, GenAI.Functions.Core,
  GenAI.Functions.Tools, GenAI.Gemini.Extra_body;

type
  TImageUrl = class(TJSONParam)
    /// <summary>
    /// Sets the URL of the image. This can be a direct web link or a base64-encoded
    /// string representing the image data.
    /// </summary>
    function Url(const Value: string): TImageUrl;

    /// <summary>
    /// Sets the detail level of the image, influencing how the image is processed
    /// or displayed by the consuming API. The default is set to 'auto', which
    /// lets the API decide the optimal level of detail.
    /// </summary>
    function Detail(const Value: TImageDetail): TImageUrl;

    class function New: TImageUrl; overload;
    class function New(const PathLocation: string; const Detail: TImageDetail = TImageDetail.auto): TImageUrl; overload;
  end;

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

    class function New(const PathLocation: string): TInputAudio; overload;
  end;

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

  TContentPart = class(TJSONParam)
    function &Type(const Value: string = 'text'): TContentPart;

    function Text(const Value: string): TContentPart;

    class function New: TContentPart; overload;
    class function New(const Value: string): TContentPart; overload;
  end;

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

    class function New(const Id: string; const Name: string; const Arguments: string): TToolCallsParams;
  end;

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
    function Content(const Value: string): TMessagePayload; overload;

    /// <summary>
    /// Adds content to the message payload, which can be text, an array of content parts,
    /// or structured JSON data, depending on the message's intended purpose.
    /// </summary>
    function Content(const Value: TArray<TContentPart>): TMessagePayload; overload;

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
    /// Constructs a new message payload for a specific role with specified content.
    /// </summary>
    class function New(const Role: TRole; const Content: TArray<TContentPart>; const Name: string = ''):TMessagePayload; overload;

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
    class function Developer(const Content: string; const Name: string = ''):TMessagePayload; overload;

    /// <summary>
    /// Factory method to create a developer role message payload.
    /// </summary>
    class function Developer(const Content: TArray<TContentPart>; const Name: string = ''):TMessagePayload; overload;

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
    class function System(const Content: string; const Name: string = ''):TMessagePayload; overload;

    /// <summary>
    /// Factory method to create a system role message payload.
    /// </summary>
    class function System(const Content: TArray<TContentPart>; const Name: string = ''):TMessagePayload; overload;

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
    /// Constructs an assistant message payload from a string.
    /// </summary>
    /// <param name="Value">
    /// A string value
    /// </param>
    /// <returns>
    /// Returns the passed TMessagePayload instance.
    /// </returns>
    class function Assistant(const Value: string): TMessagePayload; overload;

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

    /// <summary>
    /// Constructs an assistant message payload whitn an audio id.
    /// </summary>
    /// <param name="Value">
    /// A string value
    /// </param>
    /// <returns>
    /// Returns the passed TMessagePayload instance.
    /// </returns>
    class function AssistantAudioId(const Value: string): TMessagePayload; overload;
  end;

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

    class function New(const AType: string; const Text: string): TPredictionPartParams;
  end;

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

    class function New(const Value: string): TPredictionParams; overload;
    class function New(const Value: TArray<TPredictionPartParams>): TPredictionParams; overload;
  end;

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

    class function New(const Name: string): TToolChoiceParams;
  end;

  TUserLocationApproximate = class(TJSONParam)
  public
    /// <summary>
    /// Free text input for the city of the user, e.g. San Francisco.
    /// </summary>
    /// <param name="Value">
    /// The name of the city.
    /// </param>
    /// <returns>
    /// Returns an instance of TUserLocationApproximate.
    /// </returns>
    function City(const Value: string): TUserLocationApproximate;

    /// <summary>
    /// The two-letter ISO country code of the user, e.g. US.
    /// </summary>
    /// <param name="Value">
    /// The name of the country e.g. FR (for France) or JP (for Japan)
    /// </param>
    /// <returns>
    /// Returns an instance of TUserLocationApproximate.
    /// </returns>
    /// <remarks>
    /// Refer to https://en.wikipedia.org/wiki/ISO_3166-1
    /// </remarks>
    function Country(const Value: string): TUserLocationApproximate;

    /// <summary>
    /// Free text input for the region of the user, e.g. California.
    /// </summary>
    /// <param name="Value">
    /// The name of the region.
    /// </param>
    /// <returns>
    /// Returns an instance of TUserLocationApproximate.
    /// </returns>
    function Region(const Value: string): TUserLocationApproximate;

    /// <summary>
    /// The IANA timezone of the user, e.g. America/Los_Angeles.
    /// </summary>
    /// <param name="Value">
    /// The timezone e.g. Europe/Paris or Asia/Tokyo
    /// </param>
    /// <returns>
    /// Returns an instance of TUserLocationApproximate.
    /// </returns>
    /// <remarks>
    /// Refer to https://timeapi.io/documentation/iana-timezones
    /// </remarks>
    function Timezone(const Value: string): TUserLocationApproximate;
  end;

  TUserLocation = class(TJSONParam)
  public
    /// <summary>
    /// The type of location approximation. Always approximate.
    /// </summary>
    /// <param name="Value">
    /// Allways : approximate
    /// </param>
    /// <returns>
    /// Returns an instance of TUserLocation.
    /// </returns>
    function &Type(const Value: string = 'approximate'): TUserLocation;

    /// <summary>
    /// Approximate location parameters for the search.
    /// </summary>
    /// <param name="Value">
    /// e.g. TUserLocationApproximate.Create.Country('fr').Timezone('+01:00')
    /// </param>
    /// <returns>
    /// Returns an instance of TUserLocation.
    /// </returns>
    function Approximate(const Value: TUserLocationApproximate): TUserLocation; overload;

    /// <summary>
    /// Approximate location parameters for the search.
    /// </summary>
    /// <param name="Value">
    /// e.g. TUserLocationApproximate.Create.Country('fr').Detach
    /// </param>
    /// <returns>
    /// Returns an instance of TUserLocation.
    /// </returns>
    function Approximate(const Value: TJSONObject): TUserLocation; overload;

    class function New(const Value: TUserLocationApproximate): TUserLocation; overload;
    class function New(const Value: TJSONObject): TUserLocation; overload;
  end;

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
    /// Sets a penalty on generating tokens that introduce new topics, encouraging focus on the current topics.
    /// </summary>
    /// <param name="Value">
    /// The penalty value, where higher values encourage more focus on existing topics.
    /// </param>
    /// <returns>
    /// An instance of TChatParams with the presence penalty configured.
    /// </returns>
    function PresencePenalty(const Value: Double): TChatParams;

    function PromptCacheKey(const Value: string): TChatParams;

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

    function SafetyIdentifier(const Value: string): TChatParams;

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
    /// Enables or disables the storing of output from chat completion requests.
    /// </summary>
    /// <param name="Value">
    /// Boolean value indicating whether to store the output.
    /// </param>
    /// <returns>
    /// Returns an instance of TChatParams with the storage option configured.
    /// </returns>
    function Store(const Value: Boolean = True): TChatParams;

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
    function StreamOptions(const Value: TStreamOptions): TChatParams; overload;

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
    /// Specifies a unique identifier for the end-user, helping monitor and prevent abuse.
    /// </summary>
    /// <param name="Value">
    /// The user identifier.
    /// </param>
    /// <returns>
    /// An instance of TChatParams configured with the user identifier.
    /// </returns>
    function User(const Value: string): TChatParams;

    /// <summary>
    /// Constrains the verbosity of the model's response. Lower values will result in more concise responses, while higher values will result in more verbose responses.
    /// </summary>
    /// <param name="Value">
    /// Enum value of [low, medium, high]
    /// </param>
    /// <returns>
    /// An instance of TChatParams configured with the user identifier.
    /// </returns>
    /// <remarks>
    /// Currently supported values are low, medium, and high.
    /// </remarks>
    function Verbosity(const Value: TVerbosityType): TChatParams; overload;

    /// <summary>
    /// Constrains the verbosity of the model's response. Lower values will result in more concise responses, while higher values will result in more verbose responses.
    /// </summary>
    /// <param name="Value">
    /// string value "low", or "medium" or "high"
    /// </param>
    /// <returns>
    /// An instance of TChatParams configured with the user identifier.
    /// </returns>
    /// <remarks>
    /// Currently supported values are low, medium, and high.
    /// </remarks>
    function Verbosity(const Value: string): TChatParams; overload;

    /// <summary>
    /// Configures web search options for chat completion requests, allowing
    /// integration of contextual search results.
    /// </summary>
    /// <remarks>
    /// This method sets the search context size and user location settings to
    /// refine the results retrieved during a chat session. The options determine
    /// how much contextual information should be retrieved from the web and how
    /// the search should be influenced by the user's approximate location.
    /// </remarks>
    /// <param name="Value">
    /// The <c>TSearchWebOptions</c> instance specifying search-related parameters,
    /// such as the size of the search context.
    /// </param>
    /// <param name="UserLocation">
    /// Optional. A <c>TUserLocation</c> instance representing the approximate
    /// geographical location of the user. This information helps refine search results.
    /// </param>
    /// <returns>
    /// Returns an instance of <c>TChatParams</c> with the web search options configured.
    /// </returns>
    function WebSearchOptions(const Value: TSearchWebOptions; const UserLocation: TUserLocation = nil): TChatParams; overload;

    /// <summary>
    /// Configures web search options for chat completion requests, allowing
    /// integration of contextual search results while considering an approximate user location.
    /// </summary>
    /// <remarks>
    /// This method allows defining search-related parameters such as the size of the search context
    /// and refining the search results using an approximate geographical location.
    /// </remarks>
    /// <param name="Value">
    /// An instance of <c>TSearchWebOptions</c> that specifies search-related parameters,
    /// such as the context size for web search.
    /// </param>
    /// <param name="Approximation">
    /// Optional. An instance of <c>TUserLocationApproximate</c> that provides an approximate
    /// user location to refine search results.
    /// </param>
    /// <returns>
    /// Returns an instance of <c>TChatParams</c> with the web search options configured.
    /// </returns>
    function WebSearchOptions(const Value: TSearchWebOptions; const Approximation: TUserLocationApproximate = nil): TChatParams; overload;

    /// <summary>
    /// Configures web search options using a string representation of the search
    /// context size and an optional user location.
    /// </summary>
    /// <remarks>
    /// This method allows specifying the size of the search context as a string value.
    /// It also provides an optional parameter for user location to refine search results.
    /// </remarks>
    /// <param name="Value">
    /// A string representing the search context size, which determines how much
    /// information should be retrieved from the web during a chat completion request.
    /// </param>
    /// <param name="UserLocation">
    /// Optional. A <c>TUserLocation</c> instance representing the approximate
    /// geographical location of the user, helping to refine search results.
    /// </param>
    /// <returns>
    /// Returns an instance of <c>TChatParams</c> with the configured web search options.
    /// </returns>
    function WebSearchOptions(const Value: string; const UserLocation: TUserLocation): TChatParams; overload;

    /// <summary>
    /// Configures web search options using a string representation of the search
    /// context size while incorporating an approximate user location.
    /// </summary>
    /// <remarks>
    /// This method allows specifying the size of the search context as a string value.
    /// It also provides an optional parameter for the approximate user location
    /// to refine search results.
    /// </remarks>
    /// <param name="Value">
    /// A string representing the search context size, which determines how much
    /// information should be retrieved from the web during a chat completion request.
    /// </param>
    /// <param name="Approximation">
    /// Optional. An instance of <c>TUserLocationApproximate</c> that provides an
    /// approximate user location to enhance the relevance of search results.
    /// </param>
    /// <returns>
    /// Returns an instance of <c>TChatParams</c> with the configured web search options.
    /// </returns>
    function WebSearchOptions(const Value: string; const Approximation: TUserLocationApproximate): TChatParams; overload;

    /// <summary>
    /// Configures web search options using the user's approximate location.
    /// </summary>
    /// <remarks>
    /// This method allows integrating the user's geographical location into the
    /// chat completion request, refining search results based on the provided location.
    /// </remarks>
    /// <param name="UserLocation">
    /// A <c>TUserLocation</c> instance representing the approximate geographical
    /// location of the user.
    /// </param>
    /// <returns>
    /// Returns an instance of <c>TChatParams</c> with the user location-based
    /// web search options configured.
    /// </returns>
    function WebSearchOptions(const UserLocation: TUserLocation): TChatParams; overload;

    /// <summary>
    /// Configures web search options using only an approximate user location.
    /// </summary>
    /// <remarks>
    /// This method integrates the user's geographical location into the chat completion
    /// request, refining search results based on the provided location without explicitly
    /// specifying search parameters.
    /// </remarks>
    /// <param name="Approximation">
    /// An instance of <c>TUserLocationApproximate</c> that specifies the approximate
    /// geographical location of the user.
    /// </param>
    /// <returns>
    /// Returns an instance of <c>TChatParams</c> with the user location-based web search options configured.
    /// </returns>
    function WebSearchOptions(const Approximation: TUserLocationApproximate): TChatParams; overload;

    /// <summary>
    /// Configures web search options using a string representation of the search
    /// context size and an optional user location.
    /// </summary>
    /// <remarks>
    /// This method allows specifying the size of the search context as a string value.
    /// It also provides an optional parameter for user location to refine search results.
    /// </remarks>
    /// <param name="Value">
    /// A string representing the search context size, which determines how much
    /// information should be retrieved from the web during a chat completion request.
    /// </param>
    /// <returns>
    /// Returns an instance of <c>TChatParams</c> with the configured web search options.
    /// </returns>
    function WebSearchOptions(const Value: string): TChatParams; overload;

    function ExtraBody(const Value: TExtraBody): TChatParams;
  end;

  TUrlChatParams = class(TUrlParam)
  public
    /// <summary>
    /// Sets the cursor for pagination by specifying the ID of the last message
    /// returned in a previous request. Subsequent calls will retrieve messages
    /// appearing after this ID.
    /// </summary>
    /// <param name="Value">
    /// The identifier of the last message from the previous page.
    /// </param>
    /// <returns>
    /// A reference to the updated TUrlChatParams instance for method chaining.
    /// </returns>
    function After(const Value: string): TUrlChatParams;

    /// <summary>
    /// Specifies the maximum number of chat messages to retrieve in the response.
    /// </summary>
    /// <param name="Value">
    /// The limit on the number of messages to return.
    /// </param>
    /// <returns>
    /// A reference to the updated TUrlChatParams instance for method chaining.
    /// </returns>
    function Limit(const Value: Integer): TUrlChatParams;

    /// <summary>
    /// Determines the sort order for the returned messages based on their timestamp.
    /// </summary>
    /// <param name="Value">
    /// The sort direction: 'asc' for ascending or 'desc' for descending. Defaults to 'asc'.
    /// </param>
    /// <returns>
    /// A reference to the updated TUrlChatParams instance for method chaining.
    /// </returns>
    function Order(const Value: string): TUrlChatParams;
  end;

  TUrlChatListParams = class(TUrlParam)
  public
    /// <summary>
    /// Sets the cursor for pagination by specifying the ID of the last chat completion
    /// returned in a previous request. Subsequent calls will retrieve completions
    /// occurring after this ID.
    /// </summary>
    /// <param name="Value">
    /// The identifier of the last chat completion from the previous page.
    /// </param>
    /// <returns>
    /// A reference to the updated TUrlChatListParams instance for method chaining.
    /// </returns>
    function After(const Value: string): TUrlChatListParams;

    /// <summary>
    /// Specifies the maximum number of chat completions to retrieve in the response.
    /// </summary>
    /// <param name="Value">
    /// The limit on the number of completions to return.
    /// </param>
    /// <returns>
    /// A reference to the updated TUrlChatListParams instance for method chaining.
    /// </returns>
    function Limit(const Value: Integer): TUrlChatListParams;

    /// <summary>
    /// Filters the list of chat completions by metadata key‑value pairs.
    /// </summary>
    /// <param name="Value">
    /// A JSON object where each pair represents a metadata key and its required value.
    /// Example: metadata['environment']='production'.
    /// </param>
    /// <returns>
    /// A reference to the updated TUrlChatListParams instance for method chaining.
    /// </returns>
    function Metadata(const Value: TJSONObject): TUrlChatListParams;

    /// <summary>
    /// Filters the list of chat completions by the model identifier used to generate them.
    /// </summary>
    /// <param name="Value">
    /// The model name or identifier (e.g., 'gpt-4', 'claude-v1').
    /// </param>
    /// <returns>
    /// A reference to the updated TUrlChatListParams instance for method chaining.
    /// </returns>
    function Model(const Value: string): TUrlChatListParams;

    /// <summary>
    /// Determines the sort order for the returned completions based on their timestamp.
    /// </summary>
    /// <param name="Value">
    /// The sort direction: 'asc' for ascending or 'desc' for descending. Defaults to 'asc'.
    /// </param>
    /// <returns>
    /// A reference to the updated TUrlChatListParams instance for method chaining.
    /// </returns>
    function Order(const Value: string): TUrlChatListParams;
  end;

  TChatUpdateParams = class(TJSONParam)
  public
    /// <summary>
    /// Adds or replaces metadata for the chat completion update request.
    /// </summary>
    /// <param name="Value">
    /// A <c>TJSONObject</c> containing key-value pairs that describe the metadata
    /// to apply. Each pair represents a metadata field name and its new value.
    /// </param>
    /// <returns>
    /// Returns the current <c>TChatUpdateParams</c> instance to allow method chaining.
    /// </returns>
    function Metadata(const Value: TJSONObject): TChatUpdateParams;
  end;

implementation

uses
  System.StrUtils, GenAI.Consts, GenAI.Httpx, GenAI.NetEncoding.Base64;

{ TImageUrl }

function TImageUrl.Detail(const Value: TImageDetail): TImageUrl;
begin
  Result := TImageUrl(Add('detail', Value.ToString));
end;

class function TImageUrl.New(const PathLocation: string; const Detail: TImageDetail): TImageUrl;
begin
  Result := TImageUrl.Create.Url( GetUrlOrEncodeBase64(PathLocation) );
  if Detail <> TImageDetail.auto then
    Result := Result.Detail(Detail);
end;

class function TImageUrl.New: TImageUrl;
begin
  Result := TImageUrl.Create;
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
    Result := TInputAudio.Create.Data(THttpx.LoadDataToBase64(PathLocation, MimeType))
  else
    Result := TInputAudio.Create.Data(EncodeBase64(PathLocation, MimeType));
  Result := Result.Format(TAudioFormat.MimeTypeInput(MimeType));
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
  Detail := TImageDetail.auto;
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

{ TContentPart }

class function TContentPart.New: TContentPart;
begin
  Result := TContentPart.Create.&Type();
end;

class function TContentPart.New(const Value: string): TContentPart;
begin
  Result := TContentPart.New.Text(Value);
end;

function TContentPart.Text(const Value: string): TContentPart;
begin
  Result := TContentPart(Add('text', Value));
end;

function TContentPart.&Type(const Value: string): TContentPart;
begin
  Result := TContentPart(Add('type', Value));
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
  Result := TToolCallsParams.Create.Id(Id).&Type(TToolCalls.function).&Function(Name, Arguments);
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

class function TMessagePayload.Assistant(const Value: string): TMessagePayload;
begin
  Result := TMessagePayload.Create.Role(TRole.assistant).Content(Value);
end;

class function TMessagePayload.AssistantAudioId(
  const Value: string): TMessagePayload;
begin
  Result := TMessagePayload.Create.Role(TRole.assistant).Audio(Value);
end;

function TMessagePayload.Audio(const Value: string): TMessagePayload;
begin
  Result := TMessagePayload(Add('audio', TJSONObject.Create.AddPair('id', Value)));
end;

function TMessagePayload.Content(
  const Value: TArray<TContentPart>): TMessagePayload;
begin
  var JSONArray := TJSONArray.Create;
  for var Item in Value do
    JSONArray.Add(Item.Detach);
  Result := TMessagePayload(Add('content', JSONArray));
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

class function TMessagePayload.Developer(const Content: TArray<TContentPart>;
  const Name: string): TMessagePayload;
begin
  Result := New(TRole.developer, Content, Name);
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

class function TMessagePayload.New(const Role: TRole;
  const Content: TArray<TContentPart>; const Name: string): TMessagePayload;
begin
  Result := TMessagePayload.Create.Role(Role).Content(Content);
  if not Name.IsEmpty then
    Result := Result.Name(Name);
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

class function TMessagePayload.System(const Content: TArray<TContentPart>;
  const Name: string): TMessagePayload;
begin
  Result := New(TRole.system, Content, Name);
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

{ TAudioParams }

function TAudioParams.Format(const Value: TAudioFormat): TAudioParams;
begin
  Result := TAudioParams(Add('format', Value.ToString));
end;

function TAudioParams.Voice(const Value: TChatVoice): TAudioParams;
begin
  Result := TAudioParams(Add('voice', Value.ToString));
end;

{ TToolChoiceFunctionParams }

function TToolChoiceFunctionParams.Name(
  const Value: string): TToolChoiceFunctionParams;
begin
  Result := TToolChoiceFunctionParams(Add('name', Value));
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

{ TUserLocationApproximate }

function TUserLocationApproximate.City(
  const Value: string): TUserLocationApproximate;
begin
  Result := TUserLocationApproximate(Add('city', Value));
end;

function TUserLocationApproximate.Country(
  const Value: string): TUserLocationApproximate;
begin
  Result := TUserLocationApproximate(Add('country', Value));
end;

function TUserLocationApproximate.Region(
  const Value: string): TUserLocationApproximate;
begin
  Result := TUserLocationApproximate(Add('region', Value));
end;

function TUserLocationApproximate.Timezone(
  const Value: string): TUserLocationApproximate;
begin
  Result := TUserLocationApproximate(Add('timezone', Value));
end;

{ TUserLocation }

function TUserLocation.Approximate(
  const Value: TUserLocationApproximate): TUserLocation;
begin
  Result := TUserLocation(Add('approximate', Value.Detach));
end;

function TUserLocation.Approximate(const Value: TJSONObject): TUserLocation;
begin
  Result := TUserLocation(Add('approximate', Value));
end;

class function TUserLocation.New(const Value: TJSONObject): TUserLocation;
begin
  Result := TUserLocation.Create.&Type('approximate').Approximate(Value);
end;

class function TUserLocation.New(const Value: TUserLocationApproximate): TUserLocation;
begin
  Result := TUserLocation.Create.&Type('approximate').Approximate(Value);
end;

function TUserLocation.&Type(const Value: string): TUserLocation;
begin
  if Value.Trim.ToLower <> 'approximate' then
    raise Exception.Create('User_location type : always approximate');
  Result := TUserLocation(Add('type', Value));
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

function TChatParams.ExtraBody(const Value: TExtraBody): TChatParams;
begin
  Result := TChatParams(Add('extra_body', TJSONObject.Create.AddPair('google',Value.Detach)));
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

function TChatParams.PromptCacheKey(const Value: string): TChatParams;
begin
  Result := TChatParams(Add('prompt_cache_key', Value));
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

function TChatParams.SafetyIdentifier(const Value: string): TChatParams;
begin
  Result := TChatParams(Add('safety_identifier', Value));
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

function TChatParams.StreamOptions(const Value: TStreamOptions): TChatParams;
begin
  Result := TChatParams(Add('stream_options', Value.Detach));
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

function TChatParams.Verbosity(const Value: string): TChatParams;
begin
  Result := TChatParams(Add('verbosity', TVerbosityType.Create(Value).ToString));
end;

function TChatParams.Verbosity(const Value: TVerbosityType): TChatParams;
begin
  Result := TChatParams(Add('verbosity', Value.ToString));
end;

function TChatParams.WebSearchOptions(
  const Approximation: TUserLocationApproximate): TChatParams;
begin
  var Context := TJSONObject.Create.AddPair('user_location', TUserLocation.New(Approximation).Detach);
  Result := TChatParams(Add('web_search_options', Context));
end;

function TChatParams.WebSearchOptions(
  const UserLocation: TUserLocation): TChatParams;
begin
  var Context := TJSONObject.Create.AddPair('user_location', UserLocation.Detach);
  Result := TChatParams(Add('web_search_options', Context));
end;

function TChatParams.WebSearchOptions(
  const Value: string; const UserLocation: TUserLocation): TChatParams;
begin
  var Context := TJSONObject.Create.AddPair('search_context_size', TSearchWebOptions.Create(Value).ToString);
  if Assigned(UserLocation) then
    Context := Context.AddPair('user_location', UserLocation.Detach);
  Result := TChatParams(Add('web_search_options', Context));
end;

function TChatParams.WebSearchOptions(const Value: string;
  const Approximation: TUserLocationApproximate): TChatParams;
begin
  var Context := TJSONObject.Create.AddPair('search_context_size', TSearchWebOptions.Create(Value).ToString);
  if Assigned(Approximation) then
    Context := Context.AddPair('user_location', TUserLocation.New(Approximation).Detach);
  Result := TChatParams(Add('web_search_options', Context));
end;

function TChatParams.WebSearchOptions(
  const Value: TSearchWebOptions; const UserLocation: TUserLocation): TChatParams;
begin
  var Context := TJSONObject.Create.AddPair('search_context_size', Value.ToString);
  if Assigned(UserLocation) then
    Context := Context.AddPair('user_location', UserLocation.Detach);
  Result := TChatParams(Add('web_search_options', Context));
end;

function TChatParams.WebSearchOptions(const Value: TSearchWebOptions;
  const Approximation: TUserLocationApproximate): TChatParams;
begin
  var Context := TJSONObject.Create.AddPair('search_context_size', Value.ToString);
  if Assigned(Approximation) then
    Context := Context.AddPair('user_location', TUserLocation.New(Approximation).Detach);
  Result := TChatParams(Add('web_search_options', Context));
end;

function TChatParams.WebSearchOptions(const Value: string): TChatParams;
begin
  var Context := TJSONObject.Create.AddPair('search_context_size', TSearchWebOptions.Create(Value).ToString);
  Result := TChatParams(Add('web_search_options', Context));
end;

{ TUrlChatParams }

function TUrlChatParams.After(const Value: string): TUrlChatParams;
begin
  Result := TUrlChatParams(Add('after', Value));
end;

function TUrlChatParams.Limit(const Value: Integer): TUrlChatParams;
begin
  Result := TUrlChatParams(Add('limit', Value));
end;

function TUrlChatParams.Order(const Value: string): TUrlChatParams;
begin
  Result := TUrlChatParams(Add('order', Value));
end;

{ TUrlChatListParams }

function TUrlChatListParams.After(const Value: string): TUrlChatListParams;
begin
  Result := TUrlChatListParams(Add('after', Value));
end;

function TUrlChatListParams.Limit(const Value: Integer): TUrlChatListParams;
begin
  Result := TUrlChatListParams(Add('limit', Value));
end;

function TUrlChatListParams.Metadata(
  const Value: TJSONObject): TUrlChatListParams;
begin
  if not Assigned(Value) then
    Exit(Self);
  Result := TUrlChatListParams(Add('metadata', Format('{"metadata": %s}', [Value.ToJSON])));
  Value.Free;
end;

function TUrlChatListParams.Model(const Value: string): TUrlChatListParams;
begin
  Result := TUrlChatListParams(Add('model', Value));
end;

function TUrlChatListParams.Order(const Value: string): TUrlChatListParams;
begin
  Result := TUrlChatListParams(Add('order', Value));
end;

{ TChatUpdateParams }

function TChatUpdateParams.Metadata(
  const Value: TJSONObject): TChatUpdateParams;
begin
  Result := TChatUpdateParams(Add('metadata', Value));
end;

end.
