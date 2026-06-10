unit GenAI.Responses.InputParams;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGenAI
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.SysUtils, System.Classes, System.Threading, System.JSON,
  REST.Json.Types, REST.JsonReflect,
  GenAI.API.Params, GenAI.API, GenAI.Consts, GenAI.Schema, GenAI.Types,
  GenAI.Functions.Core;

type
  TRankingOptionsParams = class(TJSONParam)
    function Ranker(const Value: string): TRankingOptionsParams;
    function ScoreThreshold(const Value: Double): TRankingOptionsParams;
  end;

  {$REGION 'output top logprobs'}

  TOutputTopLogprobs  = class(TJSONParam)
    function Bytes(const Value: TArray<Int64>): TOutputTopLogprobs;

    function Logprob(const Value: Double): TOutputTopLogprobs;

    function Token(const Value: string): TOutputTopLogprobs;

    function New(const AToken: string): TOutputTopLogprobs;
  end;

  {$ENDREGION}

  {$REGION 'conversation'}

  TConversationParams = class(TJSONParam)
    /// <summary>
    /// The unique ID of the conversation.
    /// </summary>
    function Id(const Value: string): TConversationParams;

    class function New(const Value: string): TConversationParams;
  end;

  {$ENDREGION}

  {$REGION 'context management'}

  TContextManagementParams = class(TJSONParam)
    /// <summary>
    /// The context management entry type. Currently only compaction is supported.
    /// </summary>
    function &Type(const Value: string = 'compaction'): TContextManagementParams;

    /// <summary>
    /// Token threshold at which compaction should be triggered for this entry.
    /// </summary>
    function CompactThreshold(const Value: Integer): TContextManagementParams;

    class function New: TContextManagementParams;
  end;

  {$ENDREGION}

  {$REGION 'Input string or array'}

  {$REGION 'Input message'}

    {$REGION 'Input message content'}

  TItemAudioContent = class(TJSONParam)
    /// <summary>
    /// Base64-encoded audio data.
    /// </summary>
    function Data(const Value: string): TItemAudioContent;

    /// <summary>
    /// The format of the audio data. Currently supported formats are mp3 and wav.
    /// </summary>
    function Format(const Value: TAudioFormat): TItemAudioContent; overload;

    /// <summary>
    /// The format of the audio data. Currently supported formats are mp3 and wav.
    /// </summary>
    function Format(const Value: string): TItemAudioContent; overload;

    class function NewMp3(const Value: string): TItemAudioContent;
    class function NewWav(const Value: string): TItemAudioContent;
  end;

  TItemContent = class(TJSONParam)
    /// <summary>
    /// The type of the input item.
    /// </summary>
    function &Type(const Value: TInputItemType): TItemContent; overload;

    /// <summary>
    /// The type of the input item.
    /// </summary>
    function &Type(const Value: string): TItemContent; overload;

    /// <summary>
    /// The text input to the model.
    /// </summary>
    function Text(const Value: string): TItemContent;

    /// <summary>
    /// The detail level of the image to be sent to the model. One of high, low, or auto. Defaults to auto.
    /// </summary>
    function Detail(const Value: TImageDetail): TItemContent; overload;

    /// <summary>
    /// The detail level of the image to be sent to the model. One of high, low, or auto. Defaults to auto.
    /// </summary>
    function Detail(const Value: string): TItemContent; overload;

    /// <summary>
    /// The ID of the file to be sent to the model.
    /// </summary>
    function FileId(const Value: string): TItemContent;

    /// <summary>
    /// The URL of the image to be sent to the model. A fully qualified URL or base64 encoded image in a data URL.
    /// </summary>
    function ImageUrl(const Value: string): TItemContent;

    /// <summary>
    /// The content of the file to be sent to the model.
    /// </summary>
    function FileData(const Value: string): TItemContent;

    /// <summary>
    /// The URL of the file to be sent to the model.
    /// </summary>
    function FileUrl(const Value: string): TItemContent;

    /// <summary>
    /// The name of the file to be sent to the model.
    /// </summary>
    function FileName(const Value: string): TItemContent;

    /// <summary>
    /// The audio input to the model, provided as an input_audio object.
    /// Use this to attach base64-encoded audio data and its format (mp3 or wav).
    /// </summary>
    function InputAudio(const Value: TItemAudioContent): TItemContent;

    class function NewText: TItemContent;
    class function NewImage: TItemContent; overload;
    class function NewImage(const Value: string; const Detail: string = 'auto'): TItemContent; overload;
    class function NewFile: TItemContent;
    class function NewFileData(const FileLocation: string): TItemContent;
    class function NewAudio: TItemContent; overload;
    class function NewAudio(const FileLocation: string): TItemContent; overload;
  end;

  /// <summary>
  /// Fluent builder for composing a <c>TArray&lt;TItemContent&gt;</c> to be passed to
  /// <see cref="TInputMessage.Content(const Value: TArray{TItemContent})" />.
  /// </summary>
  /// <remarks>
  /// <para><b>Thread-safety:</b> This builder is <b>not</b> thread-safe.</para>
  /// <para>
  /// Do not share a single <c>TContent</c> instance across threads. If you need to build content
  /// concurrently, create one <c>TContent</c> per request/thread.
  /// </para>
  /// <para>
  /// Internally, <c>TContent</c> maintains a growable buffer (dynamic array) and a count; concurrent
  /// mutations can lead to races and memory corruption.
  /// </para>
  /// <para>
  /// Also note that calling <c>TInputMessage.Content(...)</c> typically transfers ownership of the
  /// contained <c>TItemContent</c> items to the message payload (via detaching/JSON materialization).
  /// Avoid reusing the same <c>TContent</c> (or the same <c>TItemContent</c> instances) across requests.
  /// </para>
  /// </remarks>
  TContent = record
  private
    FItems: TArray<TItemContent>;
    FCount: Integer;
    procedure Append(const Item: TItemContent); inline;
  public
    class function Create(const Capacity: Integer = 2): TContent; static;

    /// <summary>
    /// Ensures that the internal buffer has at least the specified capacity.
    /// If the current capacity is smaller, the buffer is expanded; otherwise,
    /// it is left unchanged. This is useful for reducing the number of internal
    /// reallocations when the expected number of added items is known in advance.
    /// </summary>
    /// <param name="Capacity">
    /// The minimum number of items that the internal buffer should be able to hold.
    /// </param>
    /// <returns>
    /// The updated <c>TContent</c> instance, allowing fluent-style method chaining.
    /// </returns>
    function Reserve(const Capacity: Integer): TContent;

    /// <summary>
    /// Adds a text prompt to the content list. This creates a new text
    /// <c>TItemContent</c> instance containing the specified string and appends it
    /// to the internal buffer.
    /// </summary>
    /// <param name="AText">
    /// The text to be added as a prompt item.
    /// </param>
    /// <returns>
    /// The updated <c>TContent</c> instance, enabling fluent-style method chaining.
    /// </returns>
    function AddPrompt(const AText: string): TContent;

    /// <summary>
    /// Adds an image input to the content list. The path or URL is wrapped
    /// into a <c>TItemContent</c> instance configured as an image input and
    /// appended to the internal buffer.
    /// </summary>
    /// <param name="APathOrUrl">
    /// A local file path or a fully qualified URL pointing to the image.
    /// </param>
    /// <returns>
    /// The updated <c>TContent</c> instance, supporting fluent-style chaining.
    /// </returns>
    function AddImage(const APathOrUrl: string): TContent;

    /// <summary>
    /// Adds a file input to the content list. The specified file path is loaded
    /// and wrapped into a <c>TItemContent</c> instance configured as file data,
    /// then appended to the internal buffer.
    /// </summary>
    /// <param name="AFilePath">
    /// The path to the file to include as input.
    /// </param>
    /// <returns>
    /// The updated <c>TContent</c> instance, allowing fluent-style method chaining.
    /// </returns>
    function AddFile(const AFilePath: string): TContent;

    /// <summary>
    /// Adds an audio input to the content list. The specified audio file path
    /// is wrapped into a <c>TItemContent</c> instance configured as an audio
    /// input (base64-encoded with inferred format), and appended to the internal buffer.
    /// </summary>
    /// <param name="AAudioPath">
    /// The path to the audio file to include as input (e.g., .mp3 or .wav).
    /// </param>
    /// <returns>
    /// The updated <c>TContent</c> instance, enabling fluent-style chaining.
    /// </returns>
    function AddAudio(const AAudioPath: string): TContent;

    /// <summary>
    /// Implicitly converts a <c>TContent</c> instance into a dynamic array of
    /// <c>TItemContent</c>. Only the populated portion of the internal buffer is
    /// returned, excluding any unused preallocated capacity.
    /// </summary>
    /// <param name="Value">
    /// The <c>TContent</c> instance to convert.
    /// </param>
    /// <returns>
    /// A <c>TArray&lt;TItemContent&gt;</c> containing all items that were added
    /// to the <c>TContent</c> builder.
    /// </returns>
    class operator Implicit(const Value: TContent): TArray<TItemContent>;
  end;

  /// <summary>
  /// Value is TInputListItem or his descendant
  /// <para>
  /// - TInputMessage
  /// </para>
  /// <para>
  /// - TItemOutputMessage
  /// </para>
  /// <para>
  /// - TFileSearchToolCall
  /// </para>
  /// <para>
  /// - TComputerToolCall
  /// </para>
  /// <para>
  /// - TWebSearchToolCall
  /// </para>
  /// <para>
  /// - TFunctionToolCall
  /// </para>
  /// <para>
  /// - TFunctionToolCalloutput
  /// </para>
  /// <para>
  /// - TReasoningObject
  /// </para>
  /// <para>
  /// - TImageGeneration
  /// </para>
  /// <para>
  /// - TCodeInterpreterToolCall
  /// </para>
  /// <para>
  /// - TLocalShellCall
  /// </para>
  /// <para>
  /// - TLocalShellCallOutput
  /// </para>
  /// <para>
  /// - TMCPListTools
  /// </para>
  /// <para>
  /// - TMCPApprovalRequest
  /// </para>
  /// <para>
  /// - TMCPApprovalResponse
  /// </para>
  /// <para>
  /// - TMCPToolCal
  /// </para>
  /// <para>
  /// - TCustomToolCallOutput
  /// </para>
  /// <para>
  /// - TCustomToolCall
  /// </para>
  /// <para>
  /// - TInputItemReference
  /// </para>
  /// <para>
  /// - TCompactionItemParams
  /// </para>
  /// <para>
  /// - TShellCallParams
  /// </para>
  /// <para>
  /// - TShellCallOutputParams
  /// </para>
  /// <para>
  /// - TApplyPatchCallParams
  /// </para>
  /// <para>
  /// - TApplyPatchCallOutputParams
  /// </para>
  /// <para>
  /// - TToolSearchCallParams
  /// </para>
  /// <para>
  /// - TToolSearchOutputParams
  /// </para>
  /// </summary>
  TInputListItem = class(TJSONParam);

  TInputMessage = class(TInputListItem)
    /// <summary>
    /// The role of the message input. One of user, assistant, system, or developer.
    /// </summary>
    function Role(const Value: TRole): TInputMessage; overload;

    /// <summary>
    /// The role of the message input. One of user, assistant, system, or developer.
    /// </summary>
    function Role(const Value: string): TInputMessage; overload;

    /// <summary>
    /// The type of the message input.
    /// </summary>
    function &Type(const Value: string = 'message'): TInputMessage;

    /// <summary>
    /// Text, image, or audio input to the model, used to generate a response. Can also contain previous
    /// assistant responses.
    /// </summary>
    function Content(const Value: string): TInputMessage; overload;

    /// <summary>
    /// Text, image, or audio input to the model, used to generate a response. Can also contain previous
    /// assistant responses.
    /// </summary>
    function Content(const Value: TJSONArray): TInputMessage; overload;

    /// <summary>
    /// Text, image, or audio input to the model, used to generate a response. Can also contain previous
    /// assistant responses.
    /// </summary>
    function Content(const Value: TArray<TItemContent>): TInputMessage; overload;

    class function New: TInputMessage;
  end;

    {$ENDREGION}

  TItemInputMessage = class(TInputMessage)
    /// <summary>
    /// The role of the message input. One of user, system, or developer.
    /// </summary>
    function Role(const Value: TRole): TItemInputMessage; overload;

    /// <summary>
    /// The role of the message input. One of user, system, or developer.
    /// </summary>
    function Role(const Value: string): TItemInputMessage; overload;

    /// <summary>
    /// The type of the message input
    /// </summary>
    function &Type(const Value: string = 'message'): TItemInputMessage;

    /// <summary>
    /// A list of one or many input items to the model, containing different content
    /// </summary>
    function Content(const Value: string): TItemInputMessage; overload;

    /// <summary>
    /// A list of one or many input items to the model, containing different content
    /// </summary>
    function Content(const Value: TArray<TItemContent>): TItemInputMessage; overload;

    /// <summary>
    /// The status of item. One of in_progress, completed, or incomplete. Populated when items are returned via API.
    /// </summary>
    function Status(const Value: TMessageStatus): TItemInputMessage; overload;

    /// <summary>
    /// The status of item. One of in_progress, completed, or incomplete. Populated when items are returned via API.
    /// </summary>
    function Status(const Value: string): TItemInputMessage; overload;

    class function New: TItemInputMessage;
  end;

  {$ENDREGION}

  {$REGION 'Output message'}

    {$REGION 'Output message content'}

  TOutputLogprobs  = class(TJSONParam)
    function Bytes(const Value: TArray<Int64>): TOutputLogprobs;

    function Logprob(const Value: Double): TOutputLogprobs;

    function Token(const Value: string): TOutputLogprobs;

    function New(const AToken: string): TOutputLogprobs;
  end;

  TOutputNotation = class(TJSONParam)
    /// <summary>
    /// The ID of the file.
    /// </summary>
    function FileId(const Value: string): TOutputNotation;

    /// <summary>
    /// The index of the file in the list of files.
    /// </summary>
    function Index(const Value: Integer): TOutputNotation;

    /// <summary>
    /// The type of the file citation. file_citation, url_citation or file_path
    /// </summary>
    function &Type(const Value: string): TOutputNotation;

    /// <summary>
    /// The index of the last character of the URL citation in the message.
    /// </summary>
    function EndIndex(const Value: Integer): TOutputNotation;

    /// <summary>
    /// The index of the first character of the URL citation in the message.
    /// </summary>
    function StartIndex(const Value: Integer): TOutputNotation;

    /// <summary>
    /// The title of the web resource.
    /// </summary>
    function Title(const Value: string): TOutputNotation;

    /// <summary>
    /// The URL of the web resource.
    /// </summary>
    function Url(const Value: string): TOutputNotation;

    /// <summary>
    /// File citation
    /// </summary>
    class function NewFileCitation: TOutputNotation;

    /// <summary>
    /// A path to a file.
    /// </summary>
    class function NewFilePath: TOutputNotation;

    /// <summary>
    /// URL citation
    /// </summary>
    class function NewUrlCitation: TOutputNotation;
  end;

  TOutputMessageContent = class(TJSONParam)
    /// <summary>
    /// The type of the output text. Always output_text.
    /// </summary>
    function &Type(const Value: string): TOutputMessageContent;

    /// <summary>
    /// The text output from the model.
    /// </summary>
    function Text(const Value: string): TOutputMessageContent;

    /// <summary>
    /// The annotations of the text output.
    /// </summary>
    function Annotations(const Value: TArray<TOutputNotation>): TOutputMessageContent; overload;

    /// <summary>
    /// The annotations of the text output, supplied as a raw JSON array string.
    /// The string must be a valid JSON array.
    /// </summary>
    function Annotations(const Value: string): TOutputMessageContent; overload;

    /// <summary>
    /// The refusal explanationfrom the model.
    /// </summary>
    function Refusal(const Value: string): TOutputMessageContent;

    /// <summary>
    /// Sets the log probabilities for the generated tokens.
    /// </summary>
    function Logprobs(const Value: TArray<TOutputLogprobs>): TOutputMessageContent; overload;

    /// <summary>
    /// Sets the log probabilities for the generated tokens, supplied as a raw JSON
    /// array string. The string must be a valid JSON array.
    /// </summary>
    function Logprobs(const Value: string): TOutputMessageContent; overload;

    /// <summary>
    /// A text output from the model.
    /// </summary>
    class function NewOutputText: TOutputMessageContent;

    /// <summary>
    /// A refusal from the model.
    /// </summary>
    class function NewRefusal: TOutputMessageContent;
  end;

    {$ENDREGION}

  TItemOutputMessage = class(TInputListItem)
    /// <summary>
    /// The unique ID of the output message.
    /// </summary>
    function Id(const Value: string): TItemOutputMessage;

    /// <summary>
    /// The role of the output message. Always assistant.
    /// </summary>
    function Role(const Value: TRole): TItemOutputMessage; overload;

    /// <summary>
    /// The role of the output message. Always assistant.
    /// </summary>
    function Role(const Value: string): TItemOutputMessage; overload;

    /// <summary>
    /// The status of the message input. One of in_progress, completed, or incomplete. Populated when input items
    /// are returned via API.
    /// </summary>
    function Status(const Value: TMessageStatus): TItemOutputMessage; overload;

    /// <summary>
    /// The status of the message input. One of in_progress, completed, or incomplete. Populated when input items
    /// are returned via API.
    /// </summary>
    function Status(const Value: string): TItemOutputMessage; overload;

    /// <summary>
    /// The type of the output message. Always message.
    /// </summary>
    function &Type(const Value: string = 'message'): TItemOutputMessage; overload;

    /// <summary>
    /// The content of the output message.
    /// </summary>
    function Content(const Value: TArray<TOutputMessageContent>): TItemOutputMessage;

    class function New: TItemOutputMessage;
  end;

  {$ENDREGION}

  {$REGION 'File search tool call'}

    {$REGION 'File search tool call results'}

  TFileSearchToolCallResult = class(TJSONParam)
    /// <summary>
    /// Set of 16 key-value pairs that can be attached to an object. This can be useful for storing additional
    /// information about the object in a structured format, and querying for objects via API or the dashboard.
    /// Keys are strings with a maximum length of 64 characters. Values are strings with a maximum length of
    /// 512 characters, booleans, or numbers.
    /// </summary>
    function Attributes(const Value: TJSONObject): TFileSearchToolCallResult; overload;

    /// <summary>
    /// Set of 16 key-value pairs that can be attached to an object. This can be useful for storing additional
    /// information about the object in a structured format, and querying for objects via API or the dashboard.
    /// Keys are strings with a maximum length of 64 characters. Values are strings with a maximum length of
    /// 512 characters, booleans, or numbers.
    /// </summary>
    function Attributes(const Value: string): TFileSearchToolCallResult; overload;

    /// <summary>
    /// The unique ID of the file.
    /// </summary>
    function FileId(const Value: string): TFileSearchToolCallResult;

    /// <summary>
    /// The name of the file.
    /// </summary>
    function Filename(const Value: string): TFileSearchToolCallResult;

    /// <summary>
    /// The relevance score of the file - a value between 0 and 1.
    /// </summary>
    function Score(const Value: Double): TFileSearchToolCallResult;

    /// <summary>
    /// The text that was retrieved from the file.
    /// </summary>
    function Text(const Value: string): TFileSearchToolCallResult;

    class function New: TFileSearchToolCallResult;
  end;

    {$ENDREGION}

  TFileSearchToolCall = class(TInputListItem)
    /// <summary>
    /// The unique ID of the file search tool call.
    /// </summary>
    function Id(const Value: string): TFileSearchToolCall;

    /// <summary>
    /// The queries used to search for files.
    /// </summary>
    function Queries(const Value: TArray<string>): TFileSearchToolCall;

    /// <summary>
    /// The status of the file search tool call. One of in_progress, searching, incomplete or failed,
    /// </summary>
    function Status(const Value: TFileSearchToolCallType): TFileSearchToolCall; overload;

    /// <summary>
    /// The status of the file search tool call. One of in_progress, searching, incomplete or failed,
    /// </summary>
    function Status(const Value: string): TFileSearchToolCall; overload;

    /// <summary>
    /// The type of the file search tool call. Always file_search_call.
    /// </summary>
    function &Type(const Value: string = 'file_search_call'): TFileSearchToolCall;

    /// <summary>
    /// The results of the file search tool call.
    /// </summary>
    function Results(const Value: TArray<TFileSearchToolCallResult>): TFileSearchToolCall; overload;

    /// <summary>
    /// The results of the file search tool call.
    /// </summary>
    function Results(const Value: string): TFileSearchToolCall; overload;

    class function New: TFileSearchToolCall;
  end;

  {$ENDREGION}

  {$REGION 'Computer tool call'}

    {$REGION 'Computer tool call utils'}

  TComputerToolCallOutputObject = class(TJSONParam)
    /// <summary>
    /// The identifier of an uploaded file that contains the screenshot.
    /// </summary>
    function FileId(const Value: string): TComputerToolCallOutputObject;

    /// <summary>
    /// The URL of the screenshot image.
    /// </summary>
    function ImageUrl(const Value: string): TComputerToolCallOutputObject;

    /// <summary>
    /// The type of the computer tool call output. Always computer_screenshot.
    /// </summary>
    function &Type(const Value: string = 'computer_screenshot'): TComputerToolCallOutputObject;

    class function New: TComputerToolCallOutputObject;
  end;

    {$REGION 'Computer tool actions'}

  TComputerToolCallAction = class(TJSONParam);

  TComputerClick = class(TComputerToolCallAction)
    /// <summary>
    /// Indicates which mouse button was pressed during the click. One of left, right, wheel, back, or forward.
    /// </summary>
    function Button(const Value: TMouseButton): TComputerClick; overload;

    /// <summary>
    /// Indicates which mouse button was pressed during the click. One of left, right, wheel, back, or forward.
    /// </summary>
    function Button(const Value: string): TComputerClick; overload;

    /// <summary>
    /// Specifies the event type. For a click action, this property is always set to click.
    /// </summary>
    function &Type(const Value: string = 'click'): TComputerClick;

    /// <summary>
    /// The x-coordinate where the click occurred.
    /// </summary>
    function X(const Value: Integer): TComputerClick;

    /// <summary>
    /// The y-coordinate where the click occurred.
    /// </summary>
    function Y(const Value: Integer): TComputerClick;

    class function New: TComputerClick;
  end;

  TComputerDoubleClick = class(TComputerToolCallAction)
    /// <summary>
    /// Specifies the event type. For a double click action, this property is always set to double_click.
    /// </summary>
    function &Type(const Value: string = 'double_click'): TComputerDoubleClick;

    /// <summary>
    /// The x-coordinate where the double click occurred.
    /// </summary>
    function X(const Value: Integer): TComputerDoubleClick;

    /// <summary>
    /// The y-coordinate where the double click occurred.
    /// </summary>
    function Y(const Value: Integer): TComputerDoubleClick;

    class function New: TComputerDoubleClick;
  end;

  TComputerDragPoint = class(TJSONParam)
    /// <summary>
    /// The x-coordinate
    /// </summary>
    function X(const Value: Integer): TComputerDragPoint;

    /// <summary>
    /// The y-coordinate
    /// </summary>
    function Y(const Value: Integer): TComputerDragPoint;

    class function New(const x,y: Integer): TComputerDragPoint;
  end;

  TComputerDrag = class(TComputerToolCallAction)
    /// <summary>
    /// Specifies the event type. For a drag action, this property is always set to drag.
    /// </summary>
    function &Type(const Value: string = 'drag'): TComputerDrag;

    /// <summary>
    /// An array of coordinates representing the path of the drag action. Coordinates will appear
    /// as an array of point objects.
    /// </summary>
    function Path(const Value: TArray<TComputerDragPoint>): TComputerDrag;  overload;

    /// <summary>
    /// An array of coordinates representing the path of the drag action. Coordinates will appear
    /// as an array of point objects.
    /// </summary>
    function Path(const Value: string): TComputerDrag; overload;

    class function New: TComputerDrag;
  end;

  TComputerKeyPressed = class(TComputerToolCallAction)
    /// <summary>
    /// Specifies the event type. For a keypress action, this property is always set to keypress.
    /// </summary>
    function &Type(const Value: string = 'keypress'): TComputerKeyPressed;

    /// <summary>
    /// The combination of keys the model is requesting to be pressed. This is an array of strings,
    /// each representing a key.
    /// </summary>
    function Keys(const Value: TArray<string>): TComputerKeyPressed;

    class function New: TComputerKeyPressed;
  end;

  TComputerMove = class(TComputerToolCallAction)
    /// <summary>
    /// Specifies the event type. For a move action, this property is always set to move.
    /// </summary>
    function &Type(const Value: string = 'move'): TComputerMove;

    /// <summary>
    /// The x-coordinate to move to.
    /// </summary>
    function X(const Value: Integer): TComputerMove;

    /// <summary>
    /// The y-coordinate to move to.
    /// </summary>
    function Y(const Value: Integer): TComputerMove;

    class function New: TComputerMove;
  end;

  TComputerScreenshot = class(TComputerToolCallAction)
    /// <summary>
    /// Specifies the event type. For a screenshot action, this property is always set to screenshot.
    /// </summary>
    function &Type(const Value: string = 'screenshot'): TComputerScreenshot;

    class function New: TComputerScreenshot;
  end;

  TComputerScroll = class(TComputerToolCallAction)
    /// <summary>
    /// Specifies the event type. For a scroll action, this property is always set to scroll.
    /// </summary>
    function &Type(const Value: string = 'scroll'): TComputerScroll;

    /// <summary>
    /// The horizontal scroll distance.
    /// </summary>
    function ScrollX(const Value: Integer): TComputerScroll;

    /// <summary>
    /// The vertical scroll distance.
    /// </summary>
    function ScrollY(const Value: Integer): TComputerScroll;

    /// <summary>
    /// The x-coordinate where the scroll occurred.
    /// </summary>
    function X(const Value: Integer): TComputerScroll;

    /// <summary>
    /// The y-coordinate where the scroll occurred.
    /// </summary>
    function Y(const Value: Integer): TComputerScroll;

    class function New: TComputerScroll;
  end;

  TComputerType = class(TComputerToolCallAction)
    /// <summary>
    /// Specifies the event type. For a type action, this property is always set to type.
    /// </summary>
    function &Type(const Value: string = 'type'): TComputerType;

    /// <summary>
    /// The text to type.
    /// </summary>
    function Text(const Value: string): TComputerType;

    class function New: TComputerType;
  end;

  TComputerWait = class(TComputerToolCallAction)
    /// <summary>
    /// Specifies the event type. For a wait action, this property is always set to wait.
    /// </summary>
    function &Type(const Value: string = 'wait'): TComputerWait;

    class function New: TComputerWait;
  end;

    {$ENDREGION}

  TPendingSafetyCheck = class(TJSONParam)
    /// <summary>
    /// The type of the pending safety check.
    /// </summary>
    function Code(const Value: string): TPendingSafetyCheck;

    /// <summary>
    /// The ID of the pending safety check.
    /// </summary>
    function Id(const Value: string): TPendingSafetyCheck;

    /// <summary>
    /// Details about the pending safety check.
    /// </summary>
    function Message(const Value: string): TPendingSafetyCheck;
  end;

    {$ENDREGION}

  TComputerToolCall = class(TInputListItem)
    /// <summary>
    /// The computer action.
    /// </summary>
    /// <remarks>
    /// Value is TComputerToolCallAction class or his descendant e.g.
    /// <para>
    /// TComputerClick, TComputerDoubleClick, TComputerDragPoint, TComputerDrag, TComputerKeyPressed, TComputerMove, TComputerScreenshot, TComputerScroll, TComputerType or TComputerWait
    /// </para>
    /// </remarks>
    function Action(const Value: TComputerToolCallAction): TComputerToolCall; overload;

    /// <summary>
    /// The computer action.
    /// </summary>
    /// <remarks>
    /// Value is TComputerToolCallAction class or his descendant e.g.
    /// <para>
    /// TComputerClick, TComputerDoubleClick, TComputerDragPoint, TComputerDrag, TComputerKeyPressed, TComputerMove, TComputerScreenshot, TComputerScroll, TComputerType or TComputerWait
    /// </para>
    /// </remarks>
    function Action(const Value: string): TComputerToolCall; overload;

    /// <summary>
    /// An identifier used when responding to the tool call with output.
    /// </summary>
    function CallId(const Value: string): TComputerToolCall;

    /// <summary>
    /// The unique ID of the computer call.
    /// </summary>
    function Id(const Value: string): TComputerToolCall;

    /// <summary>
    /// The pending safety checks for the computer call.
    /// </summary>
    function PendingSafetyChecks(const Value: TArray<TPendingSafetyCheck>): TComputerToolCall; overload;

    /// <summary>
    /// The pending safety checks for the computer call.
    /// </summary>
    function PendingSafetyChecks(const Value: string): TComputerToolCall; overload;

    /// <summary>
    /// The status of the item. One of in_progress, completed, or incomplete. Populated when items are returned via API.
    /// </summary>
    function Status(const Value: TMessageStatus): TComputerToolCall; overload;

    /// <summary>
    /// The status of the item. One of in_progress, completed, or incomplete. Populated when items are returned via API.
    /// </summary>
    function Status(const Value: string): TComputerToolCall; overload;

    /// <summary>
    /// The type of the computer call. Always computer_call.
    /// </summary>
    function &Type(const Value: string = 'computer_call'): TComputerToolCall;

    class function New: TComputerToolCall;
  end;

  {$ENDREGION}

  {$REGION 'Computer tool call output'}

    {$REGION 'Acknowledged safety check'}

  TAcknowledgedSafetyCheckParams = class(TJSONParam)
    /// <summary>
    /// The type of the pending safety check.
    /// </summary>
    function Code(const Value: string): TAcknowledgedSafetyCheckParams;

    /// <summary>
    /// The ID of the pending safety check.
    /// </summary>
    function Id(const Value: string): TAcknowledgedSafetyCheckParams;

    /// <summary>
    /// Details about the pending safety check.
    /// </summary>
    function Message(const Value: string): TAcknowledgedSafetyCheckParams;

    class function New: TAcknowledgedSafetyCheckParams;
  end;

    {$ENDREGION}

  TComputerToolCallOutput = class(TComputerToolCallAction)
    /// <summary>
    /// acknowledged safety checks for computer tool call outpu
    /// </summary>
    function AcknowledgedSafetyChecks(const Value: TArray<TAcknowledgedSafetyCheckParams>): TComputerToolCallOutput; overload;

    /// <summary>
    /// acknowledged safety checks for computer tool call outpu
    /// </summary>
    function AcknowledgedSafetyChecks(const Value: string): TComputerToolCallOutput; overload;

    /// <summary>
    /// The ID of the computer tool call that produced the output.
    /// </summary>
    function CallId(const Value: string): TComputerToolCallOutput;

    /// <summary>
    /// The unique ID of the computer tool call.
    /// </summary>
    function Id(const Value: string): TComputerToolCallOutput;

    /// <summary>
    /// The output of a computer tool call.
    /// </summary>
    function Output(const Value: TComputerToolCallOutputObject): TComputerToolCallOutput; overload;

    /// <summary>
    /// The output of a computer tool call.
    /// </summary>
    function Output(const Value: string): TComputerToolCallOutput; overload;

    /// <summary>
    /// The status of the file search tool call. One of in_progress, searching, incomplete or failed
    /// </summary>
    function Status(const Value: TMessageStatus): TComputerToolCallOutput; overload;

    /// <summary>
    /// The status of the file search tool call. One of in_progress, searching, incomplete or failed
    /// </summary>
    function Status(const Value: string): TComputerToolCallOutput; overload;

    /// <summary>
    /// The type of the computer tool call output. Always computer_call_output.
    /// </summary>
    function &Type(const Value: string = 'computer_call_output'): TComputerToolCallOutput;

    class function New: TComputerToolCallOutput;
  end;

  {$ENDREGION}

  {$REGION 'Web search tool call'}

  TWebSearchAction = class(TJSONParam);

    {$REGION 'Web search actions'}

  TSearchActionSourceParam = class(TJSONParam)
    /// <summary>
    /// The type of source. Always url.
    /// </summary>
    function &Type(const Value: string = 'url'): TSearchActionSourceParam;

    /// <summary>
    /// The URL of the source.
    /// </summary>
    function Url(const Value: string): TSearchActionSourceParam;

    class function New: TSearchActionSourceParam;
  end;

  TSearchAction = class(TWebSearchAction)
    /// <summary>
    /// The search query.
    /// </summary>
    function Query(const Value: string): TSearchAction;

    /// <summary>
    /// The action type.
    /// </summary>
    function &Type(const Value: string): TSearchAction;

    /// <summary>
    /// The sources used in the search.
    /// </summary>
    function Sources(const Value: TArray<TSearchActionSourceParam>): TSearchAction;
  end;

  TOpenPageAction = class(TWebSearchAction)
    /// <summary>
    /// The action type.
    /// </summary>
    function &Type(const Value: string): TOpenPageAction;

    /// <summary>
    /// The URL opened by the model.
    /// </summary>
    function Url(const Value: string): TOpenPageAction;
  end;

  TFindAction = class(TWebSearchAction)
    /// <summary>
    /// The pattern or text to search for within the page.
    /// </summary>
    function Pattern(const Value: string): TFindAction;

    /// <summary>
    /// The action type.
    /// </summary>
    function &Type(const Value: string): TFindAction;

    /// <summary>
    /// The URL of the page searched for the pattern.
    /// </summary>
    function Url(const Value: string): TFindAction;
  end;

    {$ENDREGION}

  TWebSearchToolCall = class(TInputListItem)
    /// <summary>
    /// The results of a web search tool call.
    /// </summary>
    /// <remarks>
    /// For more information, see https://platform.openai.com/docs/guides/tools-web-search
    /// </remarks>
    function Action(const Value: TWebSearchAction): TWebSearchToolCall; overload;

    /// <summary>
    /// The results of a web search tool call.
    /// </summary>
    /// <remarks>
    /// For more information, see https://platform.openai.com/docs/guides/tools-web-search
    /// </remarks>
    function Action(const Value: string): TWebSearchToolCall; overload;

    /// <summary>
    /// The unique ID of the web search tool call.
    /// </summary>
    function Id(const Value: string): TWebSearchToolCall;

    /// <summary>
    /// The status of the web search tool call. One of in_progress, searching, incomplete or failed
    /// </summary>
    function Status(const Value: TMessageStatus): TWebSearchToolCall; overload;

    /// <summary>
    /// The status of the web search tool call. One of in_progress, searching, incomplete or failed
    /// </summary>
    function Status(const Value: string): TWebSearchToolCall; overload;

    /// <summary>
    /// The type of the web search tool call. Always web_search_call.
    /// </summary>
    function &Type(const Value: string = 'web_search_call'): TWebSearchToolCall;

    class function New: TWebSearchToolCall;
  end;

  {$ENDREGION}

  {$REGION 'Function tool call object'}

  TFunctionToolCall = class(TInputListItem)
    /// <summary>
    /// A JSON string of the arguments to pass to the function.
    /// </summary>
    function Arguments(const Value: string): TFunctionToolCall;

    /// <summary>
    /// The unique ID of the function tool call generated by the model.
    /// </summary>
    function CallId(const Value: string): TFunctionToolCall;

    /// <summary>
    /// The unique ID of the function tool call.
    /// </summary>
    function Id(const Value: string): TFunctionToolCall;

    /// <summary>
    /// The name of the function to run.
    /// </summary>
    function Name(const Value: string): TFunctionToolCall;

    /// <summary>
    /// The status of the item. One of in_progress, completed, or incomplete. Populated when items are returned via API.
    /// </summary>
    function Status(const Value: TMessageStatus): TFunctionToolCall; overload;

    /// <summary>
    /// The status of the item. One of in_progress, completed, or incomplete. Populated when items are returned via API.
    /// </summary>
    function Status(const Value: string): TFunctionToolCall; overload;

    /// <summary>
    /// The type of the function tool call. Always function_call.
    /// </summary>
    function &Type(const Value: string = 'function_call'): TFunctionToolCall;

    class function New: TFunctionToolCall;
  end;

  {$ENDREGION}

  {$REGION 'Function tool call output object'}

  TFunctionOutput = class(TJSONParam);

    {$REGION 'Function output: text, image, file'}

  TFunctionInputText = class(TFunctionOutput)
    /// <summary>
    /// The type of the input item. Always input_text.
    /// </summary>
    function &Type(const Value: string = 'input_text'): TFunctionInputText;

    /// <summary>
    /// The text input to the model.
    /// </summary>
    function Text(const Value: string): TFunctionInputText;

    class function New: TFunctionInputText;
  end;

  TFunctionInputImage = class(TFunctionOutput)
    /// <summary>
    /// The type of the input item. Always input_image.
    /// </summary>
    function &Type(const Value: string = 'input_image'): TFunctionInputImage;

    /// <summary>
    /// The detail level of the image to be sent to the model. One of high, low, or auto. Defaults to auto.
    /// </summary>
    function Detail(const Value: TImageDetail): TFunctionInputImage; overload;

    /// <summary>
    /// The detail level of the image to be sent to the model. One of high, low, or auto. Defaults to auto.
    /// </summary>
    function Detail(const Value: string): TFunctionInputImage; overload;

    /// <summary>
    /// The ID of the file to be sent to the model.
    /// </summary>
    function FileId(const Value: string): TFunctionInputImage;

    /// <summary>
    /// The URL of the image to be sent to the model. A fully qualified URL or base64 encoded image
    /// in a data URL.
    /// </summary>
    function ImageUrl(const Value: string): TFunctionInputImage;

    class function New: TFunctionInputImage;
  end;

  TFunctionInputFile = class(TFunctionOutput)
    /// <summary>
    /// The type of the input item. Always input_file.
    /// </summary>
    function &Type(const Value: string = 'input_file'): TFunctionInputFile;

    /// <summary>
    /// The base64-encoded data of the file to be sent to the model.
    /// </summary>
    function FileData(const Value: string): TFunctionInputFile;

    /// <summary>
    /// The ID of the file to be sent to the model.
    /// </summary>
    function FileId(const Value: string): TFunctionInputFile;

    /// <summary>
    /// The URL of the file to be sent to the model.
    /// </summary>
    function FileUrl(const Value: string): TFunctionInputFile;

    /// <summary>
    /// The name of the file to be sent to the model.
    /// </summary>
    function Filename(const Value: string): TFunctionInputFile;

    class function New: TFunctionInputFile;
  end;

    {$ENDREGION}

  TFunctionToolCalloutput = class(TInputListItem)
    /// <summary>
    /// The unique ID of the function tool call generated by the model.
    /// </summary>
    function CallId(const Value: string): TFunctionToolCalloutput;

    /// <summary>
    /// The name of the function tool call
    /// </summary>
    function Id(const Value: string): TFunctionToolCalloutput;

    /// <summary>
    /// A JSON string of the output of the function tool call.
    /// </summary>
    function Output(const Value: string): TFunctionToolCalloutput; overload;

    /// <summary>
    /// A JSON string of the output of the function tool call.
    /// </summary>
    function Output(const Value: TArray<TFunctionOutput>): TFunctionToolCalloutput; overload;

    /// <summary>
    /// The status of the item. One of in_progress, completed, or incomplete. Populated when items are returned via API.
    /// </summary>
    function Status(const Value: TMessageStatus): TFunctionToolCalloutput; overload;

    /// <summary>
    /// The status of the item. One of in_progress, completed, or incomplete. Populated when items are returned via API.
    /// </summary>
    function Status(const Value: string): TFunctionToolCalloutput; overload;

    /// <summary>
    /// The type of the function tool call output. Always function_call_output.
    /// </summary>
    function &Type(const Value: string = 'function_call_output'): TFunctionToolCalloutput;

    class function New: TFunctionToolCalloutput;
  end;

  {$ENDREGION}

  {$REGION 'Reasoning'}

    {$REGION 'Reasoning summary'}

  TReasoningTextContent = class(TJSONParam)
    /// <summary>
    /// A short summary of the reasoning used by the model when generating the response.
    /// </summary>
    function Text(const Value: string): TReasoningTextContent;

    /// <summary>
    /// The type of the object. Always summary_text.
    /// </summary>
    function &Type(const Value: string = 'summary_text'): TReasoningTextContent;

    class function New: TReasoningTextContent;
  end;

    {$ENDREGION}

  TReasoningObject = class(TInputListItem)
    /// <summary>
    /// The unique identifier of the reasoning content.
    /// </summary>
    function Id(const Value: string): TReasoningObject;

    /// <summary>
    /// The status of the item. One of in_progress, completed, or incomplete. Populated when items are returned via API.
    /// </summary>
    function Status(const Value: TMessageStatus): TReasoningObject; overload;

    /// <summary>
    /// The status of the item. One of in_progress, completed, or incomplete. Populated when items are returned via API.
    /// </summary>
    function Status(const Value: string): TReasoningObject; overload;

    /// <summary>
    /// Reasoning text contents.
    /// </summary>
    function Summary(const Value: TArray<TReasoningTextContent>): TReasoningObject; overload;

    /// <summary>
    /// Reasoning text contents.
    /// </summary>
    function Summary(const Value: string): TReasoningObject; overload;

    /// <summary>
    /// The encrypted content of the reasoning item - populated when a response is generated with
    /// reasoning.encrypted_content in the include parameter.
    /// </summary>
    function EncryptedContent(const Value: string): TReasoningObject;

    /// <summary>
    /// The type of the object. Always reasoning.
    /// </summary>
    function &Type(const Value: string = 'reasoning'): TReasoningObject;

    class function New: TReasoningObject;
  end;

  {$ENDREGION}

  {$REGION 'Image generation call'}

  TImageGeneration = class(TInputListItem)
    /// <summary>
    /// The unique ID of the image generation call.
    /// </summary>
    function Id(const Value: string): TImageGeneration;

    /// <summary>
    /// The generated image encoded in base64.
    /// </summary>
    function Result(const Value: string): TImageGeneration;

    /// <summary>
    /// The status of the item. One of in_progress, completed, or incomplete. Populated when items are returned via API.
    /// </summary>
    function Status(const Value: TMessageStatus): TImageGeneration; overload;

    /// <summary>
    /// The status of the item. One of in_progress, completed, or incomplete. Populated when items are returned via API.
    /// </summary>
    function Status(const Value: string): TImageGeneration; overload;

    /// <summary>
    /// The type of the image generation call. Always image_generation_call.
    /// </summary>
    function &Type(const Value: string = 'image_generation_call'): TImageGeneration;

    class function New: TImageGeneration;
  end;

  {$ENDREGION}

  {$REGION 'Code interpreter tool call'}

  TCodeInterpreterOutputs = class(TJSONParam);

    {$REGION 'Code interpreter outputs'}

  TCodeInterpreterOutputLogs = class(TCodeInterpreterOutputs)
    /// <summary>
    /// The type of the code interpreter text output. Always logs.
    /// </summary>
    function &Type(const Value: string = 'logs'): TCodeInterpreterOutputLogs;

    /// <summary>
    /// The logs of the code interpreter tool call.
    /// </summary>
    function Logs(const Value: string): TCodeInterpreterOutputLogs;

    class function New: TCodeInterpreterOutputLogs;
  end;

  TCodeInterpreterOutputImage = class(TCodeInterpreterOutputs)
    /// <summary>
    /// The type of the output. Always 'image'.
    /// </summary>
    function &Type(const Value: string = 'image'): TCodeInterpreterOutputImage;

    /// <summary>
    /// The URL of the image output from the code interpreter.
    /// </summary>
    function Url(const Value: string): TCodeInterpreterOutputImage;

    class function New: TCodeInterpreterOutputImage;
  end;

    {$ENDREGION}

  TCodeInterpreterToolCall = class(TInputListItem)
    /// <summary>
    /// The code to run.
    /// </summary>
    function Code(const Value: string): TCodeInterpreterToolCall;

    /// <summary>
    /// The unique ID of the code interpreter tool call.
    /// </summary>
    function Id(const Value: string): TCodeInterpreterToolCall;

    /// <summary>
    /// The outputs generated by the code interpreter, such as logs or images. Can be null if no outputs are available.
    /// </summary>
    function Outputs(const Value: TArray<TCodeInterpreterOutputs>): TCodeInterpreterToolCall; overload;

    /// <summary>
    /// The outputs generated by the code interpreter, supplied as a raw JSON array string.
    /// The string must be a valid JSON array.
    /// </summary>
    function Outputs(const Value: string): TCodeInterpreterToolCall; overload;

    /// <summary>
    /// The status of the item. One of in_progress, completed, or incomplete. Populated when items are returned via API.
    /// </summary>
    function Status(const Value: TMessageStatus): TCodeInterpreterToolCall; overload;

    /// <summary>
    /// The status of the item. One of in_progress, completed, or incomplete. Populated when items are returned via API.
    /// </summary>
    function Status(const Value: string): TCodeInterpreterToolCall; overload;

    /// <summary>
    /// The type of the code interpreter tool call. Always code_interpreter_call.
    /// </summary>
    function &Type(const Value: string = 'code_interpreter_call'): TCodeInterpreterToolCall;

    /// <summary>
    /// The ID of the container used to run the code.
    /// </summary>
    function ContainerId(const Value: string): TCodeInterpreterToolCall;

    class function New: TCodeInterpreterToolCall;
  end;

  {$ENDREGION}

  {$REGION 'Local shell call'}

    {$REGION 'Local shell call actions'}

  TLocalShellCallAction = class(TJSONParam)
    /// <summary>
    /// The command to run.
    /// </summary>
    function Command(const Value: string): TLocalShellCallAction;

    /// <summary>
    /// Environment variables to set for the command.
    /// </summary>
    function Env(const Value: TJsonObject): TLocalShellCallAction;

    /// <summary>
    /// The type of the local shell action. Always exec.
    /// </summary>
    function &Type(const Value: string = 'exec'): TLocalShellCallAction;

    /// <summary>
    /// Optional timeout in milliseconds for the command.
    /// </summary>
    function TimeoutMs(const Value: Integer): TLocalShellCallAction;

    /// <summary>
    /// Optional user to run the command as.
    /// </summary>
    function User(const Value: string): TLocalShellCallAction;

    /// <summary>
    /// Optional working directory to run the command in.
    /// </summary>
    function WorkingDirectory(const Value: string): TLocalShellCallAction;

    class function New: TLocalShellCallAction;
  end;

    {$ENDREGION}

  TLocalShellCall = class(TInputListItem)
    /// <summary>
    /// Execute a shell command on the server.
    /// </summary>
    function Action(const Value: TLocalShellCallAction): TLocalShellCall; overload;

    /// <summary>
    /// Execute a shell command on the server.
    /// </summary>
    function Action(const Value: string): TLocalShellCall; overload;

    /// <summary>
    /// The unique ID of the local shell tool call generated by the model.
    /// </summary>
    function CallId(const Value: string): TLocalShellCall;

    /// <summary>
    /// The unique ID of the local shell call.
    /// </summary>
    function Id(const Value: string): TLocalShellCall;

    /// <summary>
    /// The status of the item. One of in_progress, completed, or incomplete. Populated when items are returned via API.
    /// </summary>
    function Status(const Value: TMessageStatus): TLocalShellCall; overload;

    /// <summary>
    /// The status of the item. One of in_progress, completed, or incomplete. Populated when items are returned via API.
    /// </summary>
    function Status(const Value: string): TLocalShellCall; overload;

    /// <summary>
    /// The type of the local shell call. Always local_shell_call.
    /// </summary>
    function &Type(const Value: string = 'local_shell_call'): TLocalShellCall;

    class function New: TLocalShellCall;
  end;

  {$ENDREGION}

  {$REGION 'Local shell call output'}

  TLocalShellCallOutput = class(TInputListItem)
    /// <summary>
    /// The unique ID of the local shell tool call generated by the model.
    /// </summary>
    function Id(const Value: string): TLocalShellCallOutput;

    /// <summary>
    /// A JSON string of the output of the local shell tool call.
    /// </summary>
    function Output(const Value: string): TLocalShellCallOutput;

    /// <summary>
    /// The status of the item. One of in_progress, completed, or incomplete. Populated when items are returned via API.
    /// </summary>
    function Status(const Value: TMessageStatus): TLocalShellCallOutput; overload;

    /// <summary>
    /// The status of the item. One of in_progress, completed, or incomplete. Populated when items are returned via API.
    /// </summary>
    function Status(const Value: string): TLocalShellCallOutput; overload;

    /// <summary>
    /// The type of the local shell tool call output. Always local_shell_call_output.
    /// </summary>
    function &Type(const Value: string = 'local_shell_call_output'): TLocalShellCallOutput;

    class function New: TLocalShellCallOutput;
  end;

  {$ENDREGION}

  {$REGION 'MCP list tools'}

    {$REGION 'MCP tool'}

  TMCPTools = class(TJSONParam)
    /// <summary>
    /// The JSON schema as TSchemaParams describing the tool's input.
    /// </summary>
    function InputSchema(const Value: TSchemaParams): TMCPTools; overload;

    /// <summary>
    /// The JSON schema as TJSONObject describing the tool's input.
    /// </summary>
    function InputSchema(const Value: TJSONObject): TMCPTools; overload;

    /// <summary>
    /// The JSON schema as string describing the tool's input.
    /// </summary>
    function InputSchema(const Value: string): TMCPTools; overload;

    /// <summary>
    /// The name of the tool.
    /// </summary>
    function Name(const Value: string): TMCPTools;

    /// <summary>
    /// Additional annotations about the tool.
    /// </summary>
    function Annotations(const Value: TJSONObject): TMCPTools;

    /// <summary>
    /// The description of the tool.
    /// </summary>
    function Description(const Value: string): TMCPTools;

    class function New: TMCPTools;
  end;

    {$ENDREGION}

  TMCPListTools = class(TInputListItem)
    /// <summary>
    /// The unique ID of the list.
    /// </summary>
    function Id(const Value: string): TMCPListTools;

    /// <summary>
    /// The label of the MCP server.
    /// </summary>
    function ServerLabel(const Value: string): TMCPListTools;

    /// <summary>
    /// The tools available on the server.
    /// </summary>
    function Tools(const Value: TArray<TMCPTools>): TMCPListTools; overload;

    /// <summary>
    /// The tools available on the server, supplied as a raw JSON array string.
    /// The string must be a valid JSON array.
    /// </summary>
    function Tools(const Value: string): TMCPListTools; overload;

    /// <summary>
    /// The type of the item. Always mcp_list_tools.
    /// </summary>
    function &Type(const Value: string = 'mcp_list_tools'): TMCPListTools;

    /// <summary>
    /// Error message if the server could not list tools.
    /// </summary>
    function Error(const Value: string): TMCPListTools;

    class function New: TMCPListTools;
  end;

  {$ENDREGION}

  {$REGION 'MCP approval request'}

  TMCPApprovalRequest = class(TInputListItem)
    /// <summary>
    /// A JSON string of arguments for the tool.
    /// </summary>
    function Arguments(const Value: string): TMCPApprovalRequest;

    /// <summary>
    /// The unique ID of the approval request.
    /// </summary>
    function Id(const Value: string): TMCPApprovalRequest;

    /// <summary>
    /// The name of the tool to run.
    /// </summary>
    function Name(const Value: string): TMCPApprovalRequest;

    /// <summary>
    /// The label of the MCP server making the request.
    /// </summary>
    function ServerLabel(const Value: string): TMCPApprovalRequest;

    /// <summary>
    /// The type of the item. Always mcp_approval_request.
    /// </summary>
    function &Type(const Value: string = 'mcp_approval_request'): TMCPApprovalRequest;

    class function New: TMCPApprovalRequest;
  end;

  {$ENDREGION}

  {$REGION 'MCP approval response'}

  TMCPApprovalResponse = class(TInputListItem)
    /// <summary>
    /// The ID of the approval request being answered.
    /// </summary>
    function ApprovalRequestId(const Value: string): TMCPApprovalResponse;

    /// <summary>
    /// Whether the request was approved.
    /// </summary>
    function Approve(const Value: Boolean): TMCPApprovalResponse;

    /// <summary>
    /// The type of the item. Always mcp_approval_response.
    /// </summary>
    function &Type(const Value: string = 'mcp_approval_response'): TMCPApprovalResponse;

    /// <summary>
    /// The unique ID of the approval response
    /// </summary>
    function Id(const Value: string): TMCPApprovalResponse;

    /// <summary>
    /// Optional reason for the decision.
    /// </summary>
    function Reason(const Value: string): TMCPApprovalResponse;

    class function New: TMCPApprovalResponse;
  end;

  {$ENDREGION}

  {$REGION 'MCP tool call'}

  TMCPToolCall = class(TInputListItem)
    /// <summary>
    /// A JSON string of the arguments passed to the tool.
    /// </summary>
    function Arguments(const Value: string): TMCPToolCall;

    /// <summary>
    /// The unique ID of the tool call.
    /// </summary>
    function Id(const Value: string): TMCPToolCall;

    /// <summary>
    /// The name of the tool that was run.
    /// </summary>
    function Name(const Value: string): TMCPToolCall;

    /// <summary>
    /// The label of the MCP server running the tool.
    /// </summary>
    function ServerLabel(const Value: string): TMCPToolCall;

    /// <summary>
    /// The type of the item. Always mcp_call.
    /// </summary>
    function &Type(const Value: string = 'mcp_call'): TMCPToolCall;

    /// <summary>
    /// The error from the tool call, if any.
    /// </summary>
    function Error(const Value: string): TMCPToolCall;

    /// <summary>
    /// The output from the tool call.
    /// </summary>
    function Output(const Value: string): TMCPToolCall;

    class function New: TMCPToolCall;
  end;

  {$ENDREGION}

  {$REGION 'Custom tool call output'}

  TCustomToolCallOutput = class(TInputListItem)
    /// <summary>
    /// The call ID, used to map this custom tool call output to a custom tool call.
    /// </summary>
    function CallId(const Value: string): TCustomToolCallOutput;

    /// <summary>
    /// The output from the custom tool call generated by your code. Can be a string or an list
    /// of output content.
    /// </summary>
    function Output(const Value: string): TCustomToolCallOutput; overload;

    /// <summary>
    /// The output from the custom tool call generated by your code. Can be a string or an list
    /// of output content.
    /// </summary>
    /// <remarks>
    /// We use 'TFunctionOupput' here because the properties are identical
    /// </remarks>
    function Output(const Value: TArray<TFunctionOutput>): TCustomToolCallOutput; overload;

    /// <summary>
    /// The type of the custom tool call output. Always custom_tool_call_output.
    /// </summary>
    function &Type(const Value: string = 'custom_tool_call_output'): TCustomToolCallOutput;

    /// <summary>
    /// The unique ID of the custom tool call output in the OpenAI platform.
    /// </summary>
    function Id(const Value: string): TCustomToolCallOutput;

    class function New: TCustomToolCallOutput;
  end;

  {$ENDREGION}

  {$REGION 'Custom tool call output'}

  TCustomToolCall = class(TInputListItem)
    /// <summary>
    /// An identifier used to map this custom tool call to a tool call output.
    /// </summary>
    function CallId(const Value: string): TCustomToolCall;

    /// <summary>
    /// The input for the custom tool call generated by the model.
    /// </summary>
    function Input(const Value: string): TCustomToolCall;

    /// <summary>
    /// The name of the custom tool being called.
    /// </summary>
    function Name(const Value: string): TCustomToolCall;

    /// <summary>
    /// The type of the custom tool call. Always custom_tool_call.
    /// </summary>
    function &Type(const Value: string = 'custom_tool_call'): TCustomToolCall;

    /// <summary>
    /// The unique ID of the custom tool call in the OpenAI platform.
    /// </summary>
    function Id(const Value: string): TCustomToolCall;
  end;

  {$ENDREGION}

  {$REGION 'Item reference'}

  TInputItemReference = class(TInputListItem)
    /// <summary>
    /// The ID of the item to reference.
    /// </summary>
    function Id(const Value: string): TInputItemReference;

    /// <summary>
    /// The type of item to reference. Always item_reference.
    /// </summary>
    function &Type(const Value: string = 'item_reference'): TInputItemReference;

    class function New: TInputItemReference; overload;
    class function New(const Value: string): TInputItemReference; overload;
  end;

  {$ENDREGION}

  {$ENDREGION}

  {$REGION 'prompt'}

  TPromptParams = class(TJsonParam)
    /// <summary>
    /// The unique identifier of the prompt template to use.
    /// </summary>
    function Id(const Value: string): TPromptParams;

    /// <summary>
    /// Optional map of values to substitute in for variables in your prompt. The substitution values
    /// can either be strings, or other Response input types like images or files.
    /// </summary>
    function Variables(const Value: TJSONObject): TPromptParams; overload;

    /// <summary>
    /// Optional map of values to substitute in for variables in your prompt, supplied
    /// as a raw JSON object string. The string must be a valid JSON object.
    /// </summary>
    function Variables(const Value: string): TPromptParams; overload;

    /// <summary>
    /// Optional version of the prompt template.
    /// </summary>
    function Version(const Value: string): TPromptParams;

    class function New: TPromptParams;
  end;

  {$ENDREGION}

  {$REGION 'reasoning'}

  TReasoningParams = class(TJSONParam)
    /// <summary>
    /// Constrains effort on reasoning for reasoning models. Currently supported values are low, medium, and high.
    /// Reducing reasoning effort can result in faster responses and fewer tokens used on reasoning in a response.
    /// </summary>
    /// <remarks>
    /// o-series models only
    /// </remarks>
    function Effort(const Value: TReasoningEffort): TReasoningParams; overload;

    /// <summary>
    /// Constrains effort on reasoning for reasoning models. Currently supported values are low, medium, and high.
    /// Reducing reasoning effort can result in faster responses and fewer tokens used on reasoning in a response.
    /// </summary>
    /// <remarks>
    /// o-series models only
    /// </remarks>
    function Effort(const Value: string): TReasoningParams; overload;

    /// <summary>
    /// A summary of the reasoning performed by the model. This can be useful for debugging and understanding the
    /// model's reasoning process. One of concise or detailed.
    /// </summary>
    function Summary(const Value: TReasoningGenerateSummary): TReasoningParams; overload;

    /// <summary>
    /// A summary of the reasoning performed by the model. This can be useful for debugging and understanding the
    /// model's reasoning process. One of concise or detailed.
    /// </summary>
    function Summary(const Value: string): TReasoningParams; overload;

    class function New: TReasoningParams;
  end;

  {$ENDREGION}

  {$REGION 'text'}

  /// <summary>
  /// Value is TTextFormatParams or his descendant e.g. TTextFormatTextPrams, TTextJSONSchemaParams, TTextJSONObjectParams,
  /// TTextParams
  /// </summary>
  TTextFormatParams = class(TJSONParam);

  TTextFormatTextPrams = class(TTextFormatParams)
    /// <summary>
    /// The type of response format being defined. Always text.
    /// </summary>
    function &Type(const Value: string = 'text'): TTextFormatTextPrams;

    class function New: TTextFormatTextPrams;
  end;

  TTextJSONSchemaParams = class(TTextFormatParams)
    /// <summary>
    /// A description of what the response format is for, used by the model to determine how to respond in the format.
    /// </summary>
    function Description(const Value: string): TTextJSONSchemaParams;

    /// <summary>
    /// The name of the response format. Must be a-z, A-Z, 0-9, or contain underscores and dashes, with a maximum length of 64.
    /// </summary>
    function Name(const Value: string): TTextJSONSchemaParams;

    /// <summary>
    /// The schema for the response format, described as a JSON Schema object. Learn how to build JSON schemas here.
    /// </summary>
    function Schema(const Value: TSchemaParams): TTextJSONSchemaParams; overload;

    /// <summary>
    /// The schema for the response format, described as a JSON Schema object. Learn how to build JSON schemas here.
    /// </summary>
    function Schema(const Value: string): TTextJSONSchemaParams; overload;

    /// <summary>
    /// Whether to enable strict schema adherence when generating the output. If set to true, the model will always
    /// follow the exact schema defined in the schema field. Only a subset of JSON Schema is supported when strict
    /// is true.
    /// </summary>
    function Strict(const Value: Boolean): TTextJSONSchemaParams;

    /// <summary>
    /// The type of response format being defined. Always json_schema.
    /// </summary>
    function &Type(const Value: string = 'json_schema'): TTextJSONSchemaParams;

    class function New: TTextJSONSchemaParams;
  end;

  TTextJSONObjectParams = class(TTextFormatParams)
    /// <summary>
    /// The type of response format being defined. Always json_object.
    /// </summary>
    function &Type(const Value: string = 'json_object'): TTextJSONObjectParams;

    class function New: TTextJSONObjectParams;
  end;

  TTextParams = class(TJSONParam)
    /// <summary>
    /// An object specifying the format that the model must output.
    /// <para>
    /// - Configuring { "type": "json_schema" } enables Structured Outputs,
    /// which ensures the model will match your supplied JSON schema.
    /// </para>
    /// <para>
    /// - The default format is { "type": "text" } with no additional options.
    /// </para>
    /// <para>
    /// - Not recommended for gpt-4o and newer models:
    /// Setting to { "type": "json_object" } enables the older JSON mode, which ensures the message the model generates
    /// is valid JSON. Using json_schema is preferred for models that support it.
    /// </para>
    /// </summary>
    function Format(const Value: TTextFormatParams): TTextParams; overload;

    function Format(const Value: string): TTextParams; overload;

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
    function Verbosity(const Value: TVerbosityType): TTextParams; overload;

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
    function Verbosity(const Value: string): TTextParams; overload;
  end;

  {$ENDREGION}

  {$REGION 'tool_choice'}

  /// <summary>
  /// Value is TResponseToolChoiceParams or his descendant e.g. THostedToolParams, TFunctionToolParams
  /// </summary>
  TResponseToolChoiceParams = class(TJSONParam);

  THostedToolParams = class(TResponseToolChoiceParams)
    /// <summary>
    /// The type of hosted tool the model should to use. Learn more about built-in tools.
    /// <para>
    /// Allowed values are:
    /// </para>
    /// <para>
    /// - file_search
    /// </para>
    /// <para>
    /// - web_search_preview
    /// </para>
    /// <para>
    /// - computer_use_preview
    /// </para>
    /// </summary>
    function &Type(const Value: THostedTooltype): THostedToolParams; overload;

    /// <summary>
    /// The type of hosted tool the model should to use. Learn more about built-in tools.
    /// <para>
    /// Allowed values are:
    /// </para>
    /// <para>
    /// - file_search
    /// </para>
    /// <para>
    /// - web_search_preview
    /// </para>
    /// <para>
    /// - computer_use_preview
    /// </para>
    /// </summary>
    function &Type(const Value: string): THostedToolParams; overload;

    class function New(const Value: string): THostedToolParams;
  end;

  TFunctionToolParams = class(TResponseToolChoiceParams)
    /// <summary>
    /// The name of the function to call.
    /// </summary>
    function Name(const Value: string): TFunctionToolParams;

    /// <summary>
    /// For function calling, the type is always function.
    /// </summary>
    function &Type(const Value: string = 'function'): TFunctionToolParams;

    class function New: TFunctionToolParams;
  end;

  TMCPToolParams = class(TResponseToolChoiceParams)
    /// <summary>
    /// For MCP tools, the type is always mcp.
    /// </summary>
    function &Type(const Value: string = 'mcp'): TMCPToolParams;

    /// <summary>
    /// The name of the tool to call on the server.
    /// </summary>
    function Name(const Value: string): TMCPToolParams;

    /// <summary>
    /// The label of the MCP server to use.
    /// </summary>
    function ServerLabel(const Value: string): TMCPToolParams;

    class function New: TMCPToolParams;
  end;

  TCustomToolChoiceParams = class(TResponseToolChoiceParams)
    /// <summary>
    /// For custom tool calling, the type is always custom.
    /// </summary>
    function &Type(const Value: string = 'custom'): TCustomToolChoiceParams;

    /// <summary>
    /// The name of the custom tool to call.
    /// </summary>
    function Name(const Value: string): TCustomToolChoiceParams;
  end;

  {$ENDREGION}

  {$REGION 'tools'}

  /// <summary>
  /// Value is TResponseToolParams or his descendant e.g. TResponseFileSearchParams, TResponseFunctionParams,
  /// TResponseComputerUseParams, TResponseWebSearchParams
  /// </summary>
  TResponseToolParams = class(TJSONParam);

    {$REGION 'Function'}

  TResponseFunctionParams = class(TResponseToolParams)
    /// <summary>
    /// A description of the function. Used by the model to determine whether or not to call the function.
    /// </summary>
    function Description(const Value: string): TResponseFunctionParams;

    /// <summary>
    /// The name of the function to call.
    /// </summary>
    function Name(const Value: string): TResponseFunctionParams;

    /// <summary>
    /// A JSON schema object describing the parameters of the function.
    /// </summary>
    function Parameters(const Value: TSchemaParams): TResponseFunctionParams; overload;

    /// <summary>
    /// A JSON schema object describing the parameters of the function.
    /// </summary>
    function Parameters(const Value: string): TResponseFunctionParams; overload;

    /// <summary>
    /// Whether to enforce strict parameter validation. Default true.
    /// </summary>
    function Strict(const Value: Boolean): TResponseFunctionParams;

    /// <summary>
    /// Whether the tool definition should be deferred and loaded on demand by the model.
    /// </summary>
    function DeferLoading(const Value: Boolean): TResponseFunctionParams;

    /// <summary>
    /// The type of the function tool. Always function.
    /// </summary>
    function &Type(const Value: string = 'function'): TResponseFunctionParams;

    class function New: TResponseFunctionParams; overload;
    class function New(const Value: IFunctionCore): TResponseFunctionParams; overload;
  end;

    {$ENDREGION}

    {$REGION 'File search'}

      {$REGION 'Filters'}

  /// <summary>
  /// Value is TFileSearchFilters or his descendant e.g. TComparisonFilter, TCompoundFilter
  /// </summary>
  TFileSearchFilters = class(TJSONParam);

  TComparisonFilter = class(TFileSearchFilters)
    /// <summary>
    /// The key to compare against the value.
    /// </summary>
    function Key(const Value: string): TComparisonFilter;

    /// <summary>
    /// Specifies the comparison operator: eq, ne, gt, gte, lt, lte.
    /// </summary>
    /// <remarks>
    /// <para>
    /// - eq: equals
    /// </para>
    /// <para>
    /// - ne: not equal
    /// </para>
    /// <para>
    /// - gt: greater than
    /// </para>
    /// <para>
    /// - gte: greater than or equal
    /// </para>
    /// <para>
    /// - lt: less than
    /// </para>
    /// <para>
    /// - lte: less than or equal
    /// </para>
    /// </remarks>
    function &Type(const Value: TComparisonFilterType): TComparisonFilter; overload;

    /// <summary>
    /// Specifies the comparison operator: eq, ne, gt, gte, lt, lte.
    /// </summary>
    /// <remarks>
    /// <para>
    /// - eq: equals
    /// </para>
    /// <para>
    /// - ne: not equal
    /// </para>
    /// <para>
    /// - gt: greater than
    /// </para>
    /// <para>
    /// - gte: greater than or equal
    /// </para>
    /// <para>
    /// - lt: less than
    /// </para>
    /// <para>
    /// - lte: less than or equal
    /// </para>
    /// </remarks>
    function &Type(const Value: string): TComparisonFilter; overload;

    /// <summary>
    /// Uses text for comparison
    /// <para>
    /// equals for eq, notEqual for ne, greaterThan for gt, greaterThanOrEqual for gte, lessThan for lt, lessThanOrEqual for lte
    /// </para>
    /// </summary>
    function Comparison(const Value: string): TComparisonFilter;

    /// <summary>
    /// The value to compare against the attribute key; supports string, number, or boolean types.
    /// </summary>
    function Value(const Value: string): TComparisonFilter; overload;

    /// <summary>
    /// The value to compare against the attribute key; supports string, number, or boolean types.
    /// </summary>
    function Value(const Value: Integer): TComparisonFilter; overload;

    /// <summary>
    /// The value to compare against the attribute key; supports string, number, or boolean types.
    /// </summary>
    function Value(const Value: Double): TComparisonFilter; overload;

    /// <summary>
    /// The value to compare against the attribute key; supports string, number, or boolean types.
    /// </summary>
    function Value(const Value: Boolean): TComparisonFilter; overload;

    class function New: TComparisonFilter; overload;
    class function New(const Key, Comparison, Value: string): TComparisonFilter; overload;
    class function New(const Key, Comparison: string; const Value: Integer): TComparisonFilter; overload;
    class function New(const Key, Comparison: string; const Value: Double): TComparisonFilter; overload;
    class function New(const Key, Comparison: string; const Value: Boolean): TComparisonFilter; overload;
  end;

  TCompoundFilter = class(TFileSearchFilters)
    /// <summary>
    /// Type of operation: and or or.
    /// </summary>
    function &Type(const Value: TCompoundFilterType): TCompoundFilter;
    function &And: TCompoundFilter; overload;
    function &Or: TCompoundFilter; overload;

    /// <summary>
    /// Array of filters to combine. Items can be ComparisonFilter or CompoundFilter.
    /// </summary>
    function Filters(const Value: TArray<TFileSearchFilters>): TCompoundFilter;

    class function New: TCompoundFilter;
    class function &And(const Value: TArray<TFileSearchFilters>): TCompoundFilter; overload;
    class function &Or(const Value: TArray<TFileSearchFilters>): TCompoundFilter; overload;
  end;

      {$ENDREGION}

  TResponseFileSearchParams = class(TResponseToolParams)
    /// <summary>
    /// The IDs of the vector stores to search.
    /// </summary>
    function VectorStoreIds(const Value: TArray<string>): TResponseFileSearchParams;

    /// <summary>
    /// A filter to apply based on file attributes.
    /// </summary>
    /// <remarks>
    /// Value is TFileSearchFilters or his descendant e.g. TComparisonFilter, TCompoundFilter
    /// </remarks>
    function Filters(const Value: TFileSearchFilters): TResponseFileSearchParams; overload;

    /// <summary>
    /// A filter to apply based on file attributes.
    /// </summary>
    /// <remarks>
    /// Value is TFileSearchFilters or his descendant e.g. TComparisonFilter, TCompoundFilter
    /// </remarks>
    function Filters(const Value: string): TResponseFileSearchParams; overload;

    /// <summary>
    /// The maximum number of results to return. This number should be between 1 and 50 inclusive
    /// </summary>
    function MaxNumResults(const Value: Integer): TResponseFileSearchParams;

    /// <summary>
    /// Ranking options for search.
    /// </summary>
    function RankingOptions(const Value: TRankingOptionsParams): TResponseFileSearchParams; overload;

    /// <summary>
    /// Ranking options for search.
    /// </summary>
    function RankingOptions(const Value: string): TResponseFileSearchParams; overload;

    /// <summary>
    /// The type of the file search tool. Always file_search.
    /// </summary>
    function &Type(const Value: string = 'file_search'): TResponseFileSearchParams;

    class function New: TResponseFileSearchParams;
  end;

    {$ENDREGION}

    {$REGION 'Computer use preview'}

  TResponseComputerUseParams = class(TResponseToolParams)
    /// <summary>
    /// The height of the computer display
    /// </summary>
    function DisplayHeight(const Value: Integer): TResponseComputerUseParams;

    /// <summary>
    /// The width of the computer display.
    /// </summary>
    function DisplayWidth(const Value: Integer): TResponseComputerUseParams;

    /// <summary>
    /// The type of computer environment to control.
    /// </summary>
    function Environment(const Value: string): TResponseComputerUseParams;

    /// <summary>
    /// The type of the computer use tool. Always computer_use_preview.
    /// </summary>
    function &Type(const Value: string = 'computer_use_preview'): TResponseComputerUseParams;

    class function New: TResponseComputerUseParams;
  end;

      {$ENDREGION}

    {$REGION 'Web search'}

  TResponseUserLocationParams = class(TJSONParam)
    /// <summary>
    /// Free text input for the city of the user, e.g. San Francisco.
    /// </summary>
    function City(const Value: string): TResponseUserLocationParams;

    /// <summary>
    /// The two-letter ISO country code of the user, e.g. US.
    /// </summary>
    function Country(const Value: string): TResponseUserLocationParams;

    /// <summary>
    /// Free text input for the region of the user, e.g. California.
    /// </summary>
    function Region(const Value: string): TResponseUserLocationParams;

    /// <summary>
    /// The IANA timezone of the user, e.g. America/Los_Angeles.
    /// </summary>
    function Timezone(const Value: string): TResponseUserLocationParams;

    /// <summary>
    /// The type of location approximation. Always approximate.
    /// </summary>
    function &Type(const Value: string = 'approximate'): TResponseUserLocationParams;

    class function New: TResponseUserLocationParams;
  end;

  TWebSearchFiltersParams = class(TJSONParam)
    /// <summary>
    /// Allowed domains for the search. If not provided, all domains are allowed. Subdomains of the
    /// provided domains are allowed as well.
    /// </summary>
    function AllowedDomains(const Value: TArray<string>): TWebSearchFiltersParams;

    class function New: TWebSearchFiltersParams;
  end;

  TResponseWebSearchParams = class(TResponseToolParams)
    /// <summary>
    /// High level guidance for the amount of context window space to use for the search.
    /// One of low, medium, or high. medium is the default.
    /// </summary>
    function SearchContextSize(const Value: TSearchWebOptions): TResponseWebSearchParams; overload;

    /// <summary>
    /// High level guidance for the amount of context window space to use for the search.
    /// One of low, medium, or high. medium is the default.
    /// </summary>
    function SearchContextSize(const Value: string = 'medium'): TResponseWebSearchParams; overload;

    /// <summary>
    /// Approximate location parameters for the search.
    /// </summary>
    function UserLocation(const Value: TResponseUserLocationParams): TResponseWebSearchParams; overload;

    /// <summary>
    /// Approximate location parameters for the search.
    /// </summary>
    function UserLocation(const Value: string): TResponseWebSearchParams; overload;

    /// <summary>
    /// Filters for the search.
    /// </summary>
    function Filters(const Value: TWebSearchFiltersParams): TResponseWebSearchParams; overload;

    /// <summary>
    /// Filters for the search.
    /// </summary>
    function Filters(const Value: string): TResponseWebSearchParams; overload;

    /// <summary>
    /// The type of the web search tool. One of:
    /// <para>
    /// - web_search_preview
    /// </para>
    /// <para>
    /// - web_search_preview_2025_03_11
    /// </para>
    /// </summary>
    function &Type(const Value: TWebSearchType): TResponseWebSearchParams; overload;

    /// <summary>
    /// The type of the web search tool. One of:
    /// <para>
    /// - web_search_preview
    /// </para>
    /// <para>
    /// - web_search_preview_2025_03_11
    /// </para>
    /// </summary>
    function &Type(const Value: string = 'web_search'): TResponseWebSearchParams; overload;

    class function New: TResponseWebSearchParams;
  end;

    {$ENDREGION}

    {$REGION 'MCP tool'}

      {$REGION 'MCP tool utils '}

  TMCPToolsListParams = class(TJSONParam)
    /// <summary>
    /// List of tools
    /// </summary>
    function ToolNames(const Value: TArray<string>): TMCPToolsListParams;
  end;

  TMCPAllowedToolsParams = class(TJSONParam)
    /// <summary>
    /// List of tools
    /// </summary>
    function ToolNames(const Value: TArray<string>): TMCPAllowedToolsParams;

    /// <summary>
    /// Indicates whether or not a tool modifies data or is read-only. If an MCP server is
    /// annotated with the read-only hint, it will be ignored unless this is set to false.
    /// </summary>
    function ReadOnly(const Value: Boolean): TMCPAllowedToolsParams;
  end;

  TMCPRequireApprovalParams = class(TJSONParam)
    /// <summary>
    /// A list of tools that always require approval.
    /// </summary>
    function Always(const Value: TArray<string>): TMCPRequireApprovalParams;

    /// <summary>
    /// A list of tools that never require approval.
    /// </summary>
    function Never(const Value: TArray<string>): TMCPRequireApprovalParams;

    class function New: TMCPRequireApprovalParams;
  end;

      {$ENDREGION}

  TResponseMCPToolParams = class(TResponseToolParams)
    /// <summary>
    /// A label for this MCP server, used to identify it in tool calls.
    /// </summary>
    function ServerLabel(const Value: string): TResponseMCPToolParams;

    /// <summary>
    /// The URL for the MCP server.
    /// </summary>
    function ServerUrl(const Value: string): TResponseMCPToolParams;

    /// <summary>
    /// The type of the MCP tool. Always mcp.
    /// </summary>
    function &Type(const Value: string = 'mcp'): TResponseMCPToolParams;

    /// <summary>
    /// Allowed tool names or a filter object.
    /// </summary>
    function AllowedTools(const Value: TArray<string>): TResponseMCPToolParams; overload;

    /// <summary>
    /// Allowed tool names or a filter object.
    /// </summary>
    function AllowedTools(const Value: TMCPAllowedToolsParams): TResponseMCPToolParams; overload;

    /// <summary>
    /// List of allowed tool names or a filter object.
    /// </summary>
    function AllowedTools(const Value: TArray<TMCPAllowedToolsParams>): TResponseMCPToolParams; overload;

    /// <summary>
    /// Optional HTTP headers to send to the MCP server. Use for authentication or other purposes.
    /// </summary>
    function Headers(const Value: TJSONObject): TResponseMCPToolParams; overload;

    /// <summary>
    /// Optional HTTP headers to send to the MCP server. Use for authentication or other purposes.
    /// </summary>
    function Headers(const Value: string): TResponseMCPToolParams; overload;

    /// <summary>
    /// Specify which of the MCP server's tools require approval.
    /// </summary>
    /// <remarks>
    /// Specify a single approval policy for all tools. One of always or never. When set to always,
    /// all tools will require approval. When set to never, all tools will not require approval.
    /// </remarks>
    function RequireApproval(const Value: string = 'always'): TResponseMCPToolParams; overload;

    /// <summary>
    /// Specify which of the MCP server's tools require approval.
    /// </summary>
    function RequireApproval(const Value: TMCPRequireApprovalParams): TResponseMCPToolParams; overload;

    /// <summary>
    /// Optional description of the MCP server, used to provide more context.
    /// </summary>
    function ServerDescription(const Value: string): TResponseMCPToolParams;

    /// <summary>
    /// An OAuth access token that can be used with a remote MCP server, either with a custom MCP
    /// server URL or a service connector. Your application must handle the OAuth authorization flow
    /// and provide the token here.
    /// </summary>
    function Authorization(const Value: string): TResponseMCPToolParams;

    /// <summary>
    /// Identifier for service connectors, like those available in ChatGPT. One of server_url or
    /// connector_id must be provided.
    /// </summary>
    /// <remarks>
    /// Learn more about service connectors here: https://platform.openai.com/docs/guides/tools-remote-mcp#connectors
    /// </remarks>
    function ConnectorId(const Value: TMCPConnectorType): TResponseMCPToolParams; overload;

    /// <summary>
    /// Identifier for service connectors, like those available in ChatGPT. One of server_url or
    /// connector_id must be provided.
    /// </summary>
    function ConnectorId(const Value: string): TResponseMCPToolParams; overload;

    /// <summary>
    /// Whether the tool definitions exposed by this MCP server should be deferred and loaded on
    /// demand by the model rather than eagerly listed.
    /// </summary>
    function DeferLoading(const Value: Boolean): TResponseMCPToolParams;

    class function New: TResponseMCPToolParams;
  end;

    {$ENDREGION}

    {$REGION 'Code interpreter'}

  TCodeInterpreterContainerAutoParams = class(TJSONParam)
    /// <summary>
    /// Always auto
    /// </summary>
    function &Type(const Value: string = 'auto'): TCodeInterpreterContainerAutoParams;

    /// <summary>
    /// An optional list of uploaded files to make available to your code.
    /// </summary>
    function FileIds(const Value: TArray<string>): TCodeInterpreterContainerAutoParams;

    class function New(const Value: TArray<string>): TCodeInterpreterContainerAutoParams;
  end;

  TResponseCodeInterpreterParams = class(TResponseToolParams)
    /// <summary>
    /// The code interpreter container. Can be a container ID or an object that specifies uploaded file IDs
    /// to make available to your code.
    /// </summary>
    function Container(const Value: string): TResponseCodeInterpreterParams; overload;

    /// <summary>
    /// The code interpreter container. Can be a container ID or an object that specifies uploaded file IDs
    /// to make available to your code.
    /// </summary>
    function Container(const Value: TCodeInterpreterContainerAutoParams): TResponseCodeInterpreterParams; overload;

    /// <summary>
    /// The type of the code interpreter tool. Always code_interpreter.
    /// </summary>
    function &Type(const Value: string = 'code_interpreter'): TResponseCodeInterpreterParams;

    class function New: TResponseCodeInterpreterParams;
  end;

    {$ENDREGION}

    {$REGION 'Image generation tool'}

  TInputImageMaskParams = class(TJSONParam)
    /// <summary>
    /// File ID for the mask image.
    /// </summary>
    function FileId(const Value: string): TInputImageMaskParams;

    /// <summary>
    /// Base64-encoded mask image.
    /// </summary>
    function ImageUrl(const Value: string): TInputImageMaskParams;

    class function New: TInputImageMaskParams;
  end;

  TResponseImageGenerationParams = class(TResponseToolParams)
    /// <summary>
    /// The type of the image generation tool. Always image_generation.
    /// </summary>
    function &Type(const Value: string = 'image_generation'): TResponseImageGenerationParams;

    /// <summary>
    /// The image action to perform. One of generate, edit, or auto. Default: auto.
    /// </summary>
    function Action(const Value: TImageGenActionType): TResponseImageGenerationParams; overload;

    /// <summary>
    /// The image action to perform. One of generate, edit, or auto. Default: auto.
    /// </summary>
    function Action(const Value: string): TResponseImageGenerationParams; overload;

    /// <summary>
    /// Background type for the generated image. One of transparent, opaque, or auto. Default: auto.
    /// </summary>
    function Background(const Value: string): TResponseImageGenerationParams; overload;

    /// <summary>
    /// Background type for the generated image. One of transparent, opaque, or auto. Default: auto.
    /// </summary>
    function Background(const Value: TBackGroundType): TResponseImageGenerationParams; overload;

    /// <summary>
    /// Control how much effort the model will exert to match the style and features, especially facial features,
    /// of input images. This parameter is only supported for gpt-image-1. Supports high and low. Defaults to low.
    /// </summary>
    function InputFidelity(const Value: string): TResponseImageGenerationParams; overload;

    /// <summary>
    /// Control how much effort the model will exert to match the style and features, especially facial features,
    /// of input images. This parameter is only supported for gpt-image-1. Supports high and low. Defaults to low.
    /// </summary>
    function InputFidelity(const Value: TFidelityType): TResponseImageGenerationParams; overload;

    /// <summary>
    /// Optional mask for inpainting. Contains image_url (string, optional) and file_id (string, optional).
    /// </summary>
    function InputImageMask(const Value: TInputImageMaskParams): TResponseImageGenerationParams; overload;

    /// <summary>
    /// Optional mask for inpainting. Contains image_url (string, optional) and file_id (string, optional).
    /// </summary>
    function InputImageMask(const Value: string): TResponseImageGenerationParams; overload;

    /// <summary>
    /// The image generation model to use. Default: gpt-image-1.
    /// </summary>
    function Model(const Value: string): TResponseImageGenerationParams;

    /// <summary>
    /// Moderation level for the generated image. Default: auto.
    /// </summary>
    function Moderation(const Value: string): TResponseImageGenerationParams;

    /// <summary>
    /// Compression level for the output image. Default: 100.
    /// </summary>
    function OutputCompression(const Value: Integer): TResponseImageGenerationParams;

    /// <summary>
    /// The output format of the generated image. One of png, webp, or jpeg. Default: png.
    /// </summary>
    function OutputFormat(const Value: string): TResponseImageGenerationParams; overload;

    /// <summary>
    /// The output format of the generated image. One of png, webp, or jpeg. Default: png.
    /// </summary>
    function OutputFormat(const Value: TOutputFormatType): TResponseImageGenerationParams; overload;

    /// <summary>
    /// Number of partial images to generate in streaming mode, from 0 (default value) to 3.
    /// </summary>
    function PartialImages(const Value: Integer): TResponseImageGenerationParams;

    /// <summary>
    /// The quality of the generated image. One of low, medium, high, or auto. Default: auto.
    /// </summary>
    function Quality(const Value: string): TResponseImageGenerationParams; overload;

    /// <summary>
    /// The quality of the generated image. One of low, medium, high, or auto. Default: auto.
    /// </summary>
    function Quality(const Value: TImageQualityType): TResponseImageGenerationParams; overload;

    /// <summary>
    /// The size of the generated image. One of 1024x1024, 1024x1536, 1536x1024, or auto. Default: auto.
    /// </summary>
    function Size(const Value: string): TResponseImageGenerationParams; overload;

    /// <summary>
    /// The size of the generated image. One of 1024x1024, 1024x1536, 1536x1024, or auto. Default: auto.
    /// </summary>
    function Size(const Value: TImageSize): TResponseImageGenerationParams; overload;

    class function New: TResponseImageGenerationParams;
  end;

    {$ENDREGION}

    {$REGION 'Local shell tool'}

  TLocalShellToolParams = class(TResponseToolParams)
    /// <summary>
    /// The type of the local shell tool. Always local_shell.
    /// </summary>
    function &Type(const Value: string = 'local_shell'): TLocalShellToolParams;

    class function New: TLocalShellToolParams;
  end;

    {$ENDREGION}

    {$REGION 'Custom tool'}

  TToolParamsFormatParams = class(TJSONParam)
    /// <summary>
    /// Unconstrained text format "text" or Grammar format "grammar"
    /// </summary>
    function &Type(const Value: TToolParamsFormatType): TToolParamsFormatParams; overload;

    /// <summary>
    /// Unconstrained text format "text" or Grammar format "grammar"
    /// </summary>
    function &Type(const Value: string): TToolParamsFormatParams; overload;

    /// <summary>
    /// The grammar definition.
    /// </summary>
    function Definition(const Value: string): TToolParamsFormatParams;

    /// <summary>
    /// The syntax of the grammar definition. One of lark or regex.
    /// </summary>
    function Syntax(const Value: TSyntaxFormatType): TToolParamsFormatParams; overload;

    /// <summary>
    /// The syntax of the grammar definition. One of lark or regex.
    /// </summary>
    function Syntax(const Value: string): TToolParamsFormatParams; overload;

    class function New(const Value: TToolParamsFormatType): TToolParamsFormatParams; overload;
    class function New(const Value: string): TToolParamsFormatParams; overload;
  end;

  TCustomToolParams = class(TResponseToolParams)
    /// <summary>
    /// The type of the custom tool. Always custom
    /// </summary>
    function &Type(const Value: string = 'custom'): TCustomToolParams;

    /// <summary>
    /// The name of the custom tool, used to identify it in tool calls.
    /// </summary>
    function Name(const Value: string): TCustomToolParams;

    /// <summary>
    /// Optional description of the custom tool, used to provide more context.
    /// </summary>
    function Description(const Value: string): TCustomToolParams;

    /// <summary>
    /// The input format for the custom tool. Default is unconstrained text.
    /// </summary>
    function Format(const Value: TToolParamsFormatParams): TCustomToolParams; overload;

    /// <summary>
    /// The input format for the custom tool. Default is unconstrained text.
    /// </summary>
    function Format(const Value: string): TCustomToolParams; overload;

    class function New: TCustomToolParams;
  end;

    {$ENDREGION}

    {$REGION 'Web search preview'}

  TWebSearchPreviewParams = class(TResponseToolParams)
    /// <summary>
    /// High level guidance for the amount of context window space to use for the search. One of low,
    /// medium, or high. medium is the default.
    /// </summary>
    function SearchContextSize(const Value: TSearchWebOptions): TWebSearchPreviewParams; overload;

    /// <summary>
    /// High level guidance for the amount of context window space to use for the search. One of low,
    /// medium, or high. medium is the default.
    /// </summary>
    function SearchContextSize(const Value: string = 'medium'): TWebSearchPreviewParams; overload;

    /// <summary>
    /// The user's location.
    /// </summary>
    function UserLocation(const Value: TResponseUserLocationParams): TWebSearchPreviewParams; overload;

    /// <summary>
    /// The user's location.
    /// </summary>
    function UserLocation(const Value: string): TWebSearchPreviewParams; overload;

    /// <summary>
    /// The type of the web search tool. One of web_search_preview or web_search_preview_2025_03_11
    /// </summary>
    function &Type(const Value: TWebSearchPreviewType): TWebSearchPreviewParams; overload;

    /// <summary>
    /// The type of the web search tool. One of web_search_preview or web_search_preview_2025_03_11
    /// </summary>
    function &Type(const Value: string = 'web_search_preview'): TWebSearchPreviewParams; overload;

    class function New: TWebSearchPreviewParams;
  end;

    {$ENDREGION}

    {$REGION 'Apply patch tool'}

  TApplyPatchToolParams = class(TResponseToolParams)
    /// <summary>
    /// The type of the apply patch tool. Always apply_patch.
    /// </summary>
    function &Type(const Value: string = 'apply_patch'): TApplyPatchToolParams;

    class function New: TApplyPatchToolParams;
  end;

    {$ENDREGION}

    {$REGION 'Tool search tool'}

  TToolSearchToolParams = class(TResponseToolParams)
    /// <summary>
    /// The type of the tool. Always tool_search.
    /// </summary>
    function &Type(const Value: string = 'tool_search'): TToolSearchToolParams;

    /// <summary>
    /// Optional description of the tool search tool.
    /// </summary>
    function Description(const Value: string): TToolSearchToolParams;

    /// <summary>
    /// Where the tool search is executed. One of server or client.
    /// </summary>
    function Execution(const Value: TToolSearchExecution): TToolSearchToolParams; overload;

    /// <summary>
    /// Where the tool search is executed. One of server or client.
    /// </summary>
    function Execution(const Value: string): TToolSearchToolParams; overload;

    /// <summary>
    /// A JSON schema object describing the parameters of the tool search.
    /// </summary>
    function Parameters(const Value: TSchemaParams): TToolSearchToolParams; overload;

    /// <summary>
    /// A JSON schema object describing the parameters of the tool search.
    /// </summary>
    function Parameters(const Value: TJSONObject): TToolSearchToolParams; overload;

    /// <summary>
    /// A JSON schema object describing the parameters of the tool search.
    /// </summary>
    function Parameters(const Value: string): TToolSearchToolParams; overload;

    class function New: TToolSearchToolParams;
  end;

    {$ENDREGION}

    {$REGION 'Namespace tool'}

  TNamespaceToolParams = class(TResponseToolParams)
    /// <summary>
    /// The type of the namespace tool. Always namespace.
    /// </summary>
    function &Type(const Value: string = 'namespace'): TNamespaceToolParams;

    /// <summary>
    /// The name of the namespace, used to group the contained tools.
    /// </summary>
    function Name(const Value: string): TNamespaceToolParams;

    /// <summary>
    /// The description of the namespace, used to provide more context.
    /// </summary>
    function Description(const Value: string): TNamespaceToolParams;

    /// <summary>
    /// The tools contained in the namespace. Each item is a function or custom tool definition.
    /// </summary>
    /// <remarks>
    /// Value items are TResponseToolParams descendants, typically TResponseFunctionParams or
    /// TCustomToolParams.
    /// </remarks>
    function Tools(const Value: TArray<TResponseToolParams>): TNamespaceToolParams; overload;

    /// <summary>
    /// The tools contained in the namespace. Each item is a function or custom tool definition.
    /// </summary>
    function Tools(const Value: TJSONArray): TNamespaceToolParams; overload;

    function Tools(const Value: string): TNamespaceToolParams; overload;

    class function New: TNamespaceToolParams;
  end;

    {$ENDREGION}

    {$REGION 'Shell tool'}

      {$REGION 'Shell environment utils'}

  TContainerNetworkPolicyDomainSecretParams = class(TJSONParam)
    /// <summary>
    /// The domain associated with the secret.
    /// </summary>
    function Domain(const Value: string): TContainerNetworkPolicyDomainSecretParams;

    /// <summary>
    /// The name of the secret to inject for the domain.
    /// </summary>
    function Name(const Value: string): TContainerNetworkPolicyDomainSecretParams;

    /// <summary>
    /// The secret value to inject for the domain.
    /// </summary>
    function Value(const Value: string): TContainerNetworkPolicyDomainSecretParams;

    class function New: TContainerNetworkPolicyDomainSecretParams;
  end;

  /// <summary>
  /// Value is TContainerNetworkPolicyParams or his descendant e.g. TContainerNetworkPolicyDisabledParams,
  /// TContainerNetworkPolicyAllowlistParams
  /// </summary>
  TContainerNetworkPolicyParams = class(TJSONParam);

  TContainerNetworkPolicyDisabledParams = class(TContainerNetworkPolicyParams)
    /// <summary>
    /// Disable outbound network access. Always disabled.
    /// </summary>
    function &Type(const Value: string = 'disabled'): TContainerNetworkPolicyDisabledParams;

    class function New: TContainerNetworkPolicyDisabledParams;
  end;

  TContainerNetworkPolicyAllowlistParams = class(TContainerNetworkPolicyParams)
    /// <summary>
    /// Allow outbound network access only to specified domains. Always allowlist.
    /// </summary>
    function &Type(const Value: string = 'allowlist'): TContainerNetworkPolicyAllowlistParams;

    /// <summary>
    /// A list of allowed domains when type is allowlist.
    /// </summary>
    function AllowedDomains(const Value: TArray<string>): TContainerNetworkPolicyAllowlistParams;

    /// <summary>
    /// Optional domain-scoped secrets for allowlisted domains.
    /// </summary>
    function DomainSecrets(const Value: TArray<TContainerNetworkPolicyDomainSecretParams>): TContainerNetworkPolicyAllowlistParams; overload;

    /// <summary>
    /// Optional domain-scoped secrets for allowlisted domains.
    /// </summary>
    function DomainSecrets(const Value: string): TContainerNetworkPolicyAllowlistParams; overload;

    class function New: TContainerNetworkPolicyAllowlistParams;
  end;

  TInlineSkillSourceParams = class(TJSONParam)
    /// <summary>
    /// The type of the inline skill source. Must be base64.
    /// </summary>
    function &Type(const Value: string = 'base64'): TInlineSkillSourceParams;

    /// <summary>
    /// The media type of the inline skill payload. Must be application/zip.
    /// </summary>
    function MediaType(const Value: string = 'application/zip'): TInlineSkillSourceParams;

    /// <summary>
    /// Base64-encoded skill zip bundle.
    /// </summary>
    function Data(const Value: string): TInlineSkillSourceParams;

    class function New: TInlineSkillSourceParams;
  end;

  /// <summary>
  /// Value is TContainerSkillParams or his descendant e.g. TSkillReferenceParams, TInlineSkillParams
  /// </summary>
  TContainerSkillParams = class(TJSONParam);

  TSkillReferenceParams = class(TContainerSkillParams)
    /// <summary>
    /// References a skill created with the /v1/skills endpoint. Always skill_reference.
    /// </summary>
    function &Type(const Value: string = 'skill_reference'): TSkillReferenceParams;

    /// <summary>
    /// The ID of the referenced skill.
    /// </summary>
    function SkillId(const Value: string): TSkillReferenceParams;

    /// <summary>
    /// Optional skill version. Use a positive integer or latest. Omit for default.
    /// </summary>
    function Version(const Value: string): TSkillReferenceParams;

    class function New: TSkillReferenceParams;
  end;

  TInlineSkillParams = class(TContainerSkillParams)
    /// <summary>
    /// The type of the skill. Always inline.
    /// </summary>
    function &Type(const Value: string = 'inline'): TInlineSkillParams;

    /// <summary>
    /// The name of the skill.
    /// </summary>
    function Name(const Value: string): TInlineSkillParams;

    /// <summary>
    /// The description of the skill.
    /// </summary>
    function Description(const Value: string): TInlineSkillParams;

    /// <summary>
    /// The inline source of the skill.
    /// </summary>
    function Source(const Value: TInlineSkillSourceParams): TInlineSkillParams;

    class function New: TInlineSkillParams;
  end;

  TLocalSkillParams = class(TJSONParam)
    /// <summary>
    /// The name of the skill.
    /// </summary>
    function Name(const Value: string): TLocalSkillParams;

    /// <summary>
    /// The description of the skill.
    /// </summary>
    function Description(const Value: string): TLocalSkillParams;

    /// <summary>
    /// The path to the directory containing the skill.
    /// </summary>
    function Path(const Value: string): TLocalSkillParams;

    class function New: TLocalSkillParams;
  end;

      {$ENDREGION}

  /// <summary>
  /// Value is TShellEnvironmentParams or his descendant e.g. TShellContainerReferenceParams,
  /// TShellLocalEnvironmentParams, TShellContainerAutoParams
  /// </summary>
  TShellEnvironmentParams = class(TJSONParam);

  TShellContainerReferenceParams = class(TShellEnvironmentParams)
    /// <summary>
    /// References a container created with the /v1/containers endpoint. Always container_reference.
    /// </summary>
    function &Type(const Value: string = 'container_reference'): TShellContainerReferenceParams;

    /// <summary>
    /// The ID of the referenced container.
    /// </summary>
    function ContainerId(const Value: string): TShellContainerReferenceParams;

    class function New: TShellContainerReferenceParams;
  end;

  TShellLocalEnvironmentParams = class(TShellEnvironmentParams)
    /// <summary>
    /// Use a local computer environment. Always local.
    /// </summary>
    function &Type(const Value: string = 'local'): TShellLocalEnvironmentParams;

    /// <summary>
    /// An optional list of skills.
    /// </summary>
    function Skills(const Value: TArray<TLocalSkillParams>): TShellLocalEnvironmentParams; overload;

    /// <summary>
    /// An optional list of skills.
    /// </summary>
    function Skills(const Value: string): TShellLocalEnvironmentParams; overload;

    class function New: TShellLocalEnvironmentParams;
  end;

  TShellContainerAutoParams = class(TShellEnvironmentParams)
    /// <summary>
    /// Automatically creates a container for this request. Always container_auto.
    /// </summary>
    function &Type(const Value: string = 'container_auto'): TShellContainerAutoParams;

    /// <summary>
    /// An optional list of uploaded files to make available to your code.
    /// </summary>
    function FileIds(const Value: TArray<string>): TShellContainerAutoParams;

    /// <summary>
    /// The memory limit for the container. One of 1g, 4g, 16g, or 64g.
    /// </summary>
    function MemoryLimit(const Value: TContainerMemoryLimit): TShellContainerAutoParams; overload;

    /// <summary>
    /// The memory limit for the container. One of 1g, 4g, 16g, or 64g.
    /// </summary>
    function MemoryLimit(const Value: string): TShellContainerAutoParams; overload;

    /// <summary>
    /// Network access policy for the container.
    /// </summary>
    /// <remarks>
    /// Value is TContainerNetworkPolicyParams or his descendant e.g. TContainerNetworkPolicyDisabledParams,
    /// TContainerNetworkPolicyAllowlistParams
    /// </remarks>
    function NetworkPolicy(const Value: TContainerNetworkPolicyParams): TShellContainerAutoParams; overload;

    /// <summary>
    /// Network access policy for the container.
    /// </summary>
    /// <remarks>
    /// Value is TContainerNetworkPolicyParams or his descendant e.g. TContainerNetworkPolicyDisabledParams,
    /// TContainerNetworkPolicyAllowlistParams
    /// </remarks>
    function NetworkPolicy(const Value: string): TShellContainerAutoParams; overload;

    /// <summary>
    /// An optional list of skills referenced by id or inline data.
    /// </summary>
    /// <remarks>
    /// Value items are TContainerSkillParams descendants e.g. TSkillReferenceParams, TInlineSkillParams
    /// </remarks>
    function Skills(const Value: TArray<TContainerSkillParams>): TShellContainerAutoParams; overload;

    /// <summary>
    /// An optional list of skills referenced by id or inline data.
    /// </summary>
    /// <remarks>
    /// Value items are TContainerSkillParams descendants e.g. TSkillReferenceParams, TInlineSkillParams
    /// </remarks>
    function Skills(const Value: string): TShellContainerAutoParams; overload;

    class function New: TShellContainerAutoParams;
  end;

  TFunctionShellToolParams = class(TResponseToolParams)
    /// <summary>
    /// The type of the shell tool. Always shell.
    /// </summary>
    function &Type(const Value: string = 'shell'): TFunctionShellToolParams;

    /// <summary>
    /// The execution environment for the shell tool.
    /// </summary>
    /// <remarks>
    /// Value is TShellEnvironmentParams or his descendant e.g. TShellContainerReferenceParams,
    /// TShellLocalEnvironmentParams, TShellContainerAutoParams
    /// </remarks>
    function Environment(const Value: TShellEnvironmentParams): TFunctionShellToolParams; overload;

    /// <summary>
    /// The execution environment for the shell tool.
    /// </summary>
    /// <remarks>
    /// Value is TShellEnvironmentParams or his descendant e.g. TShellContainerReferenceParams,
    /// TShellLocalEnvironmentParams, TShellContainerAutoParams
    /// </remarks>
    function Environment(const Value: string): TFunctionShellToolParams; overload;

    class function New: TFunctionShellToolParams;
  end;

    {$ENDREGION}

  {$ENDREGION}

  {$REGION 'tool_choice (allowed_tools)'}

  /// <summary>
  /// Constrains the tools available to the model to a pre-defined set. Declared after the tools
  /// region because its typed overload references TResponseToolParams.
  /// </summary>
  TAllowedToolsChoiceParams = class(TResponseToolChoiceParams)
    /// <summary>
    /// Allowed tool configuration type. Always allowed_tools.
    /// </summary>
    function &Type(const Value: string = 'allowed_tools'): TAllowedToolsChoiceParams;

    /// <summary>
    /// Constrains the tools available to the model to a pre-defined set.
    /// <para>
    /// - auto allows the model to pick from among the allowed tools and generate a message.
    /// </para>
    /// <para>
    /// - required requires the model to call one or more of the allowed tools.
    /// </para>
    /// </summary>
    function Mode(const Value: TAllowedToolsMode): TAllowedToolsChoiceParams; overload;

    /// <summary>
    /// Constrains the tools available to the model to a pre-defined set.
    /// </summary>
    function Mode(const Value: string): TAllowedToolsChoiceParams; overload;

    /// <summary>
    /// A list of tool definitions that the model should be allowed to call.
    /// </summary>
    /// <remarks>
    /// Value items are TResponseToolParams descendants.
    /// </remarks>
    function Tools(const Value: TArray<TResponseToolParams>): TAllowedToolsChoiceParams; overload;

    /// <summary>
    /// A list of tool definitions that the model should be allowed to call.
    /// </summary>
    function Tools(const Value: TJSONArray): TAllowedToolsChoiceParams; overload;

    /// <summary>
    /// A list of tool definitions, supplied as a raw JSON array string.
    /// The string must be a valid JSON array.
    /// </summary>
    function Tools(const Value: string): TAllowedToolsChoiceParams; overload;

    class function New: TAllowedToolsChoiceParams;
  end;

  {$ENDREGION}

  {$REGION 'agentic input items'}

  TShellCallActionParams = class(TJSONParam)
    function Commands(const Value: TArray<string>): TShellCallActionParams;
    function TimeoutMs(const Value: Int64): TShellCallActionParams;
    function MaxOutputLength(const Value: Int64): TShellCallActionParams;
    class function New: TShellCallActionParams;
  end;

  TShellCallParams = class(TInputListItem)
    function Id(const Value: string): TShellCallParams;
    function CallId(const Value: string): TShellCallParams;
    function CreatedBy(const Value: string): TShellCallParams;
    function Action(const Value: TShellCallActionParams): TShellCallParams; overload;
    function Action(const Value: string): TShellCallParams; overload;
    function Status(const Value: TMessageStatus): TShellCallParams; overload;
    function Status(const Value: string): TShellCallParams; overload;
    function &Type(const Value: string = 'shell_call'): TShellCallParams;
    class function New: TShellCallParams;
  end;

  TApplyPatchOperationParams = class(TJSONParam)
    function Diff(const Value: string): TApplyPatchOperationParams;
    function Path(const Value: string): TApplyPatchOperationParams;
    function &Type(const Value: string): TApplyPatchOperationParams;
    class function New: TApplyPatchOperationParams;
  end;

  TApplyPatchCallParams = class(TInputListItem)
    function Id(const Value: string): TApplyPatchCallParams;
    function CallId(const Value: string): TApplyPatchCallParams;
    function CreatedBy(const Value: string): TApplyPatchCallParams;
    function Operation(const Value: TApplyPatchOperationParams): TApplyPatchCallParams; overload;
    function Operation(const Value: string): TApplyPatchCallParams; overload;
    function Status(const Value: TMessageStatus): TApplyPatchCallParams; overload;
    function Status(const Value: string): TApplyPatchCallParams; overload;
    function &Type(const Value: string = 'apply_patch_call'): TApplyPatchCallParams;
    class function New: TApplyPatchCallParams;
  end;

  TToolSearchCallParams = class(TInputListItem)
    function Id(const Value: string): TToolSearchCallParams;
    function CallId(const Value: string): TToolSearchCallParams;
    function CallIdNull: TToolSearchCallParams;
    function CreatedBy(const Value: string): TToolSearchCallParams;
    function Execution(const Value: TToolSearchExecution): TToolSearchCallParams; overload;
    function Execution(const Value: string): TToolSearchCallParams; overload;
    function Arguments(const Value: TJSONObject): TToolSearchCallParams; overload;
    function Arguments(const Value: string): TToolSearchCallParams; overload;
    function Status(const Value: TMessageStatus): TToolSearchCallParams; overload;
    function Status(const Value: string): TToolSearchCallParams; overload;
    function &Type(const Value: string = 'tool_search_call'): TToolSearchCallParams;
    class function New: TToolSearchCallParams;
  end;

  /// <summary>
  /// An opaque compaction item returned by the responses compact endpoint.
  /// Preserve it unchanged when replaying a compacted context.
  /// </summary>
  TCompactionItemParams = class(TInputListItem)
    function Id(const Value: string): TCompactionItemParams;
    function CreatedBy(const Value: string): TCompactionItemParams;
    function EncryptedContent(const Value: string): TCompactionItemParams;
    function &Type(const Value: string = 'compaction'): TCompactionItemParams;
    class function New: TCompactionItemParams;
  end;

  TShellCallOutputOutcomeParams = class(TJSONParam)
    function &Type(const Value: string): TShellCallOutputOutcomeParams;
    function ExitCode(const Value: Int64): TShellCallOutputOutcomeParams;
    class function NewExit(const ExitCode: Int64): TShellCallOutputOutcomeParams;
    class function NewTimeout: TShellCallOutputOutcomeParams;
  end;

  TShellCallOutputContentParams = class(TJSONParam)
    function CreatedBy(const Value: string): TShellCallOutputContentParams;
    function Stdout(const Value: string): TShellCallOutputContentParams;
    function Stderr(const Value: string): TShellCallOutputContentParams;
    function Outcome(const Value: TShellCallOutputOutcomeParams): TShellCallOutputContentParams;
    class function New: TShellCallOutputContentParams;
  end;

  TShellCallOutputParams = class(TInputListItem)
    function Id(const Value: string): TShellCallOutputParams;
    function CallId(const Value: string): TShellCallOutputParams;
    function CreatedBy(const Value: string): TShellCallOutputParams;
    function MaxOutputLength(const Value: Int64): TShellCallOutputParams;
    function Output(const Value: TArray<TShellCallOutputContentParams>): TShellCallOutputParams; overload;
    function Output(const Value: TJSONArray): TShellCallOutputParams; overload;
    function Output(const Value: string): TShellCallOutputParams; overload;
    function Status(const Value: string): TShellCallOutputParams;
    function &Type(const Value: string = 'shell_call_output'): TShellCallOutputParams;
    class function New: TShellCallOutputParams;
  end;

  TApplyPatchCallOutputParams = class(TInputListItem)
    function Id(const Value: string): TApplyPatchCallOutputParams;
    function CallId(const Value: string): TApplyPatchCallOutputParams;
    function CreatedBy(const Value: string): TApplyPatchCallOutputParams;
    function Output(const Value: string): TApplyPatchCallOutputParams;
    function Status(const Value: string): TApplyPatchCallOutputParams;
    function &Type(const Value: string = 'apply_patch_call_output'): TApplyPatchCallOutputParams;
    class function New: TApplyPatchCallOutputParams;
  end;

  TToolSearchOutputParams = class(TInputListItem)
    function Id(const Value: string): TToolSearchOutputParams;
    function CallId(const Value: string): TToolSearchOutputParams;
    function CallIdNull: TToolSearchOutputParams;
    function CreatedBy(const Value: string): TToolSearchOutputParams;
    function Execution(const Value: TToolSearchExecution): TToolSearchOutputParams; overload;
    function Execution(const Value: string): TToolSearchOutputParams; overload;
    function Status(const Value: string): TToolSearchOutputParams;
    function Tools(const Value: TArray<TResponseToolParams>): TToolSearchOutputParams; overload;
    function Tools(const Value: TJSONArray): TToolSearchOutputParams; overload;
    function Tools(const Value: string): TToolSearchOutputParams; overload;
    function &Type(const Value: string = 'tool_search_output'): TToolSearchOutputParams;
    class function New: TToolSearchOutputParams;
  end;

  /// <summary>
  /// Parameters accepted by POST /responses/compact.
  /// </summary>
  TResponseCompactParams = class(TJSONParam)
    function Model(const Value: string): TResponseCompactParams;
    function Input(const Value: string): TResponseCompactParams; overload;
    function Input(const Value: TJSONArray): TResponseCompactParams; overload;
    function Input(const Value: TArray<TInputListItem>): TResponseCompactParams; overload;
    function Instructions(const Value: string): TResponseCompactParams;
    function PreviousResponseId(const Value: string): TResponseCompactParams;
    function PromptCacheKey(const Value: string): TResponseCompactParams;
    function PromptCacheRetention(const Value: TPromptCacheRetention): TResponseCompactParams; overload;
    function PromptCacheRetention(const Value: string): TResponseCompactParams; overload;
    function ServiceTier(const Value: TServiceTier): TResponseCompactParams; overload;
    function ServiceTier(const Value: string): TResponseCompactParams; overload;
  end;

  {$ENDREGION}

  TResponsesParams = class(TJSONParam)
    /// <summary>
    /// Whether to run the model response in the background.
    /// </summary>
    function Background(const Value: Boolean): TResponsesParams;

    /// <summary>
    /// The conversation that this response belongs to. Items from this conversation are prepended
    /// to input_items for this response request. Input items and output items from this response
    /// are automatically added to this conversation after this response completes.
    /// </summary>
    function Conversation(const Value: string): TResponsesParams; overload;

    /// <summary>
    /// The conversation that this response belongs to. Items from this conversation are prepended
    /// to input_items for this response request. Input items and output items from this response
    /// are automatically added to this conversation after this response completes.
    /// </summary>
    function Conversation(const Value: TConversationParams): TResponsesParams; overload;

    /// <summary>
    /// Configuration for context management. A list of entries describing how the model should manage
    /// the context window, such as compaction.
    /// </summary>
    function ContextManagement(const Value: TArray<TContextManagementParams>): TResponsesParams;

    /// <summary>
    /// Specify additional output data to include in the model response. Currently supported values are:
    /// <para>
    /// file_search_call.results: Include the search results of the file search tool call.
    /// </para>
    /// <para>
    /// message.input_image.image_url: Include image urls from the input message.
    /// </para>
    /// <para>
    /// computer_call_output.output.image_url: Include image urls from the computer call output.
    /// </para>
    /// </summary>
    function Include(const Value: TArray<TOutputIncluding>): TResponsesParams; overload;

    /// <summary>
    /// Specify additional output data to include in the model response. Currently supported values are:
    /// <para>
    /// file_search_call.results: Include the search results of the file search tool call.
    /// </para>
    /// <para>
    /// message.input_image.image_url: Include image urls from the input message.
    /// </para>
    /// <para>
    /// computer_call_output.output.image_url: Include image urls from the computer call output.
    /// </para>
    /// </summary>
    function Include(const Value: TArray<string>): TResponsesParams; overload;

    /// <summary>
    /// Text, image, or file inputs to the model, used to generate a response.
    /// </summary>
    function Input(const Value: string): TResponsesParams; overload;

    /// <summary>
    /// Text, image, or file inputs to the model, used to generate a response.
    /// </summary>
    /// <param name="Value">
    /// Value is TInputListItem or his descendant
    /// </param>
    function Input(const Value: TArray<TInputListItem>): TResponsesParams; overload;

    /// <summary>
    /// Text, image, or file inputs to the model, used to generate a response.
    /// </summary>
    /// <param name="Value">
    /// Value is TJSONArray
    /// </param>
    function Input(const Value: TJSONArray): TResponsesParams; overload;

    /// <summary>
    /// Method to create a user default role message payload with multiple document references
    /// (images and/or PDF)-local or distant documents.
    /// </summary>
    /// <param name="Content">
    /// The main content of the user message.
    /// </param>
    /// <param name="Docs">
    /// An array of document paths to include. Only for images.
    /// </param>
    function Input(const Content: string; const Docs: TArray<string>; const Role: string = 'user'): TResponsesParams; overload;

    /// <summary>
    /// Inserts a system (or developer) message as the first item in the model's context.
    /// </summary>
    /// <remarks>
    /// When using along with previous_response_id, the instructions from a previous response will not be carried
    /// over to the next response. This makes it simple to swap out system (or developer) messages in new responses.
    /// </remarks>
    function Instructions(const Value: string): TResponsesParams;

    /// <summary>
    /// An upper bound for the number of tokens that can be generated for a response, including visible output tokens
    /// and reasoning tokens.
    /// </summary>
    function MaxOutputTokens(const Value: Integer): TResponsesParams;

    /// <summary>
    ///  The maximum number of total calls to built-in tools that can be processed in a response. This
    /// maximum number applies across all built-in tool calls, not per individual tool. Any further
    /// attempts to call a tool by the model will be ignored.
    /// </summary>
    function MaxToolCalls(const Value: Integer): TResponsesParams;

    /// <summary>
    /// Set of 16 key-value pairs that can be attached to an object. This can be useful for storing additional information
    /// about the object in a structured format, and querying for objects via API or the dashboard.
    /// </summary>
    /// <remarks>
    /// Keys are strings with a maximum length of 64 characters. Values are strings with a maximum length of 512 characters.
    /// </remarks>
    function Metadata(const Value: TJSONObject): TResponsesParams;

    /// <summary>
    /// Model ID used to generate the response, like gpt-4o or o1. OpenAI offers a wide range of models
    /// with different capabilities, performance characteristics, and price points. Refer to the model
    /// guide to browse and compare available models.
    /// </summary>
    function Model(const Value: string): TResponsesParams;

    /// <summary>
    /// Whether to allow the model to run tool calls in parallel.
    /// </summary>
    function ParallelToolCalls(const Value: Boolean): TResponsesParams;

    /// <summary>
    /// The unique ID of the previous response to the model. Use this to create multi-turn conversations. Learn more about
    /// conversation state.
    /// </summary>
    function PreviousResponseId(const Value: string): TResponsesParams;

    /// <summary>
    /// Reference to a prompt template and its variables.
    /// </summary>
    /// <remarks>
    /// Refer to https://platform.openai.com/docs/guides/text?api-mode=responses&prompt-templates-examples=simple#reusable-prompts
    /// </remarks>
    function Prompt(const Value: TPromptParams): TResponsesParams;

    /// <summary>
    /// Used by OpenAI to cache responses for similar requests to optimize your cache hit rates. Replaces the user field.
    /// </summary>
    /// <remarks>
    /// Refer to https://platform.openai.com/docs/guides/prompt-caching
    /// </remarks>
    function PromptCacheKey(const Value: string): TResponsesParams;

    /// <summary>
    /// The retention policy for the prompt cache. Set to 24h to enable extended prompt caching, which
    /// keeps cached prefixes active for longer, up to a maximum of 24 hours. One of in_memory or 24h.
    /// </summary>
    function PromptCacheRetention(const Value: TPromptCacheRetention): TResponsesParams; overload;

    /// <summary>
    /// The retention policy for the prompt cache. Set to 24h to enable extended prompt caching, which
    /// keeps cached prefixes active for longer, up to a maximum of 24 hours. One of in_memory or 24h.
    /// </summary>
    function PromptCacheRetention(const Value: string): TResponsesParams; overload;

    /// <summary>
    /// o-series models only. Configuration options for reasoning models.
    /// </summary>
    function Reasoning(const Value: TReasoningParams): TResponsesParams; overload;

    /// <summary>
    /// o-series models only. Configuration options for reasoning models.
    /// </summary>
    function Reasoning(const Value: string): TResponsesParams; overload;

    /// <summary>
    /// A stable identifier used to help detect users of your application that may be violating OpenAI's
    /// usage policies. The IDs should be a string that uniquely identifies each user. We recommend hashing
    /// their username or email address, in order to avoid sending us any identifying information.
    /// </summary>
    /// <remarks>
    /// Refer to https://platform.openai.com/docs/guides/safety-best-practices#safety-identifiers
    /// </remarks>
    function SafetyIdentifier(const Value: string): TResponsesParams;

    /// <summary>
    /// Specifies the latency tier to use for processing the request. This parameter is relevant for
    /// customers subscribed to the scale tier service:
    /// <para>
    /// - If set to 'auto', and the Project is Scale tier enabled, the system will utilize scale tier
    /// credits until they are exhausted.
    /// </para>
    /// <para>
    /// - If set to 'auto', and the Project is not Scale tier enabled, the request will be processed
    /// using the default service tier with a lower uptime SLA and no latency guarantee.
    /// </para>
    /// <para>
    /// - If set to 'default', the request will be processed using the default service tier with a
    /// lower uptime SLA and no latency guarantee.
    /// </para>
    /// <para>
    /// - If set to 'flex', the request will be processed with the Flex Processing service tier.
    /// </para>
    /// <para>
    /// - When not set, the default behavior is 'auto'.
    /// </para>
    /// When this parameter is set, the response body will include the service_tier utilized.
    /// </summary>
    /// <remarks>
    /// One of auto, default, flex, scale or priority.
    /// </remarks>
    function ServiceTier(const Value: TServiceTier): TResponsesParams; overload;

    /// <summary>
    /// Specifies the latency tier to use for processing the request.
    /// </summary>
    /// <remarks>
    /// One of auto, default, flex, scale or priority.
    /// </remarks>
    function ServiceTier(const Value: string): TResponsesParams; overload;

    /// <summary>
    /// Whether to store the generated model response for later retrieval via API.
    /// </summary>
    function Store(const Value: Boolean = True): TResponsesParams;

    /// <summary>
    /// if set to true, the model response data will be streamed to the client as it is generated using server-sent events.
    /// </summary>
    function Stream(const Value: Boolean = True): TResponsesParams;

    /// <summary>
    /// Configures options for streaming responses, such as inclusion of usage data.
    /// </summary>
    /// <param name="Value">
    /// A JSON object specifying streaming options.
    /// </param>
    /// <returns>
    /// Returns an instance of TChatParams with streaming options set.
    /// </returns>
    function StreamOptions(const Value: TStreamOptions): TResponsesParams;

    /// <summary>
    /// What sampling temperature to use, between 0 and 2. Higher values like 0.8 will make the output more random, while
    /// lower values like 0.2 will make it more focused and deterministic. We generally recommend altering this or top_p
    /// but not both.
    /// </summary>
    function Temperature(const Value: Double): TResponsesParams;

    /// <summary>
    /// Configuration options for a text response from the model. Can be plain text or structured JSON data. Learn more:
    /// <para>
    /// - Text inputs and outputs https://platform.openai.com/docs/guides/text
    /// </para>
    /// <para>
    /// - Structured Outputs https://platform.openai.com/docs/guides/structured-outputs
    /// </para>
    /// </summary>
    function Text(const Value: TTextParams): TResponsesParams; overload;

    /// <summary>
    /// Configuration options for a text response from the model. Can be plain text or structured JSON data. Learn more:
    /// <para>
    /// - Text inputs and outputs https://platform.openai.com/docs/guides/text
    /// </para>
    /// <para>
    /// - Structured Outputs https://platform.openai.com/docs/guides/structured-outputs
    /// </para>
    /// </summary>
    /// <remarks>
    /// Value is TTextFormatParams or his descendant e.g. TTextFormatTextPrams, TTextJSONSchemaParams, TTextJSONObjectParams,
    /// TTextParams
    /// </remarks>
    function Text(const Value: TTextFormatParams): TResponsesParams; overload;

    /// <summary>
    /// Configuration options for a text response from the model. Can be plain text or structured JSON data. Learn more:
    /// <para>
    /// - Text inputs and outputs https://platform.openai.com/docs/guides/text
    /// </para>
    /// <para>
    /// - Structured Outputs https://platform.openai.com/docs/guides/structured-outputs
    /// </para>
    /// </summary>
    function Text(const Value: string; const SchemaParams: TTextJSONSchemaParams = nil): TResponsesParams; overload;

    /// <summary>
    /// Configuration options for a text response from the model. Can be plain text or structured JSON data. Learn more:
    /// <para>
    /// - Text inputs and outputs https://platform.openai.com/docs/guides/text
    /// </para>
    /// <para>
    /// - Structured Outputs https://platform.openai.com/docs/guides/structured-outputs
    /// </para>
    /// </summary>
    function Text(const Value: TResponseOption; const SchemaParams: TTextJSONSchemaParams = nil): TResponsesParams; overload;

    /// <summary>
    /// How the model should select which tool (or tools) to use when generating a response. See the tools parameter
    /// to see how to specify which tools the model can call.
    /// </summary>
    function ToolChoice(const Value: TToolChoice): TResponsesParams; overload;

    /// <summary>
    /// How the model should select which tool (or tools) to use when generating a response. See the tools parameter
    /// to see how to specify which tools the model can call.
    /// </summary>
    /// <remarks>
    /// Controls which (if any) tool is called by the model.
    /// <para>
    /// - none means the model will not call any tool and instead generates a message.
    /// </para>
    /// <para>
    /// - auto means the model can pick between generating a message or calling one or more tools.
    /// </para>
    /// <para>
    /// - required means the model must call one or more tools.
    /// </para>
    /// </remarks>
    function ToolChoice(const Value: string): TResponsesParams; overload;

    /// <summary>
    /// How the model should select which tool (or tools) to use when generating a response. See the tools parameter
    /// to see how to specify which tools the model can call.
    /// </summary>
    /// <remarks>
    /// Value is TResponseToolChoiceParams or his descendant e.g. THostedToolParams, TFunctionToolParams
    /// </remarks>
    function ToolChoice(const Value: TResponseToolChoiceParams): TResponsesParams; overload;

    /// <summary>
    /// An array of tools the model may call while generating a response. You can specify which tool to use by setting
    /// the tool_choice parameter.
    /// <para>
    /// The two categories of tools you can provide the model are:
    /// </para>
    /// <para>
    /// - Built-in tools: Tools that are provided by OpenAI that extend the model's capabilities, like web search or
    /// file search. Learn more about built-in tools.
    /// </para>
    /// <para>
    /// - Function calls (custom tools): Functions that are defined by you, enabling the model to call your own code.
    /// Learn more about function calling.
    /// </para>
    /// </summary>
    /// <remarks>
    /// The descendant avalaible for then TResponseToolParams class are :
    /// <para>
    /// - TResponseFileSearchParams, TResponseFunctionParams, TResponseComputerUseParams, TResponseWebSearchParams
    /// </para>
    /// </remarks>
    function Tools(const Value: TArray<TResponseToolParams>): TResponsesParams; overload;

    /// <summary>
    /// An array of tools the model may call, supplied as a raw JSON array string.
    /// Convenient for quick tests or when the tool definitions are already
    /// available as JSON. The string must be a valid JSON array.
    /// </summary>
    function Tools(const Value: string): TResponsesParams; overload;

    /// <summary>
    /// An integer between 0 and 20 specifying the number of most likely tokens to return at each token
    /// position, each with an associated log probability.
    /// </summary>
    function TopLogprobs(const Value: Integer): TResponsesParams;

    /// <summary>
    /// An alternative to sampling with temperature, called nucleus sampling, where the model considers the results of
    /// the tokens with top_p probability mass. So 0.1 means only the tokens comprising the top 10% probability mass
    /// are considered.
    /// </summary>
    /// <remarks>
    /// We generally recommend altering this or temperature but not both.
    /// </remarks>
    function TopP(const Value: Double): TResponsesParams;

    /// <summary>
    /// The truncation strategy to use for the model response.
    /// </summary>
    /// <remarks>
    /// <para>
    /// - auto: If the context of this response and previous ones exceeds the model's context window size, the model
    /// will truncate the response to fit the context window by dropping input items in the middle of the conversation.
    /// </para>
    /// <para>
    /// - disabled (default): If a model response will exceed the context window size for a model, the request will fail
    /// with a 400 error.
    /// </para>
    /// </remarks>
    function Truncation(const Value: TResponseTruncationType): TResponsesParams; overload;

    /// <summary>
    /// The truncation strategy to use for the model response.
    /// </summary>
    /// <remarks>
    /// <para>
    /// - auto: If the context of this response and previous ones exceeds the model's context window size, the model
    /// will truncate the response to fit the context window by dropping input items in the middle of the conversation.
    /// </para>
    /// <para>
    /// - disabled (default): If a model response will exceed the context window size for a model, the request will fail
    /// with a 400 error.
    /// </para>
    /// </remarks>
    function Truncation(const Value: string): TResponsesParams; overload;

    /// <summary>
    /// A unique identifier representing your end-user, which can help OpenAI to monitor and detect abuse. Learn more.
    /// </summary>
    function User(const Value: string): TResponsesParams;
  end;

  TResponsesParamsProc = TProc<TResponsesParams>;

implementation

uses
  System.StrUtils, GenAI.NetEncoding.Base64, GenAI.Responses.Helpers, GenAI.Httpx,
  GenAI.Exceptions;

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

{ TItemContent }

function TItemContent.Detail(const Value: TImageDetail): TItemContent;
begin
  Result := TItemContent(Add('detail', Value.ToString));
end;

function TItemContent.Detail(const Value: string): TItemContent;
begin
  Result := TItemContent(Add('detail', TImageDetail.Create(Value).ToString));
end;

function TItemContent.FileData(const Value: string): TItemContent;
begin
  Result := TItemContent(Add('file_data', Value));
end;

function TItemContent.FileId(const Value: string): TItemContent;
begin
  Result := TItemContent(Add('file_id', Value));
end;

function TItemContent.FileName(const Value: string): TItemContent;
begin
  Result := TItemContent(Add('filename', Value));
end;

function TItemContent.FileUrl(const Value: string): TItemContent;
begin
  Result := TItemContent(Add('file_url', Value));
end;

function TItemContent.ImageUrl(const Value: string): TItemContent;
var
  Detail: string;
begin
  var FileName := TFormatHelper.ExtractFileName(Value, Detail);
  if Detail.IsEmpty then
    Result := TItemContent(Add('image_url', GetUrlOrEncodeBase64(Value)))
  else
    Result := TItemContent(Add('image_url', GetUrlOrEncodeBase64(Filename))).Detail(Detail);
end;

function TItemContent.InputAudio(const Value: TItemAudioContent): TItemContent;
begin
  Result := TItemContent(Add('input_audio', Value.Detach));
end;

class function TItemContent.NewAudio: TItemContent;
begin
  Result := TItemContent.Create.&Type('input_audio');
end;

class function TItemContent.NewAudio(const FileLocation: string): TItemContent;
var
  MimeType: string;
  Data: string;
begin
  {--- Retrieve mimetype }
  if FileLocation.ToLower.StartsWith('http') then
    begin
      Data := THttpx.LoadDataToBase64(FileLocation, MimeType);
      Data := Format('data:%s;base64,%s', [MimeType, Data]);
    end
  else
    begin
      MimeType := GetMimeType(FileLocation);
      Data := GetUrlOrEncodeBase64(FileLocation);
    end;

  var AudioType := MimeTypeToAudioType(MimeType);

  Result := NewAudio.InputAudio(
    TItemAudioContent.Create
      .Format(AudioType)
      .Data(Data)
  );
end;

class function TItemContent.NewFile: TItemContent;
begin
  Result := TItemContent.Create.&Type('input_file');
end;

class function TItemContent.NewFileData(const FileLocation: string): TItemContent;
var
  MimeType: string;
  Data: string;
  FileName: string;
begin
  {--- Retrieve mimetype }
  if FileLocation.ToLower.StartsWith('http') then
    begin
      Data := THttpx.LoadDataToBase64(FileLocation, MimeType);
      Data := Format('data:%s;base64,%s', [MimeType, Data]);
      FileName := THttpx.ExtractURIFileName(FileLocation);
    end
  else
    begin
      MimeType := GetMimeType(FileLocation);
      Data := GetUrlOrEncodeBase64(FileLocation);
      FileName := ExtractFileName(FileLocation);
    end;

  {--- Pdf file managment }
  var index := IndexStr(MimeType, DocTypeAccepted);
  if index = -1 then
    raise Exception.Create('PDF files only accepted');

  Result := Create.&Type('input_file').FileName(FileName).FileData(Data);
end;

class function TItemContent.NewImage: TItemContent;
begin
  Result := TItemContent.Create.&Type('input_image');
end;

class function TItemContent.NewImage(const Value, Detail: string): TItemContent;
begin
  if Value.ToLower.StartsWith('http') then
    Result := NewImage.Detail(Detail).ImageUrl(Value)
  else
  if FileExists(Value.Trim) then
    Result := NewImage.Detail(Detail).ImageUrl(Value)
  else
    Result := NewImage.Detail(Detail).FileId(Value);
end;

class function TItemContent.NewText: TItemContent;
begin
  Result := TItemContent.Create.&Type('input_text');
end;

function TItemContent.Text(const Value: string): TItemContent;
begin
  Result := TItemContent(Add('text', Value));
end;

function TItemContent.&Type(const Value: TInputItemType): TItemContent;
begin
  Result := TItemContent(Add('type', Value.ToString));
end;

function TItemContent.&Type(const Value: string): TItemContent;
begin
  Result := TItemContent(Add('type', TInputItemType.Create(Value).ToString));
end;

{ TInputMessage }

function TInputMessage.Content(const Value: string): TInputMessage;
var
  JSONArray: TJSONArray;
begin
  {--- Content may be a plain text string or a JSON array of content blocks:
       if the string is a JSON array, treat it as such; otherwise send it as text. }
  if TJSONHelper.TryGetArray(Value, JSONArray) then
    Exit(TInputMessage(Add('content', JSONArray)));

  Result := TInputMessage(Add('content', Value));
end;

function TInputMessage.Content(const Value: TArray<TItemContent>): TInputMessage;
begin
  var JSONArray := TJSONArray.Create;
  for var Item in Value do
    JSONArray.Add(Item.Detach);
  Result := TInputMessage(Add('content', JSONArray));
end;

function TInputMessage.Content(const Value: TJSONArray): TInputMessage;
begin
  Result := TInputMessage(Add('content', Value));
end;

class function TInputMessage.New: TInputMessage;
begin
  Result := TInputMessage.Create.&Type();
end;

function TInputMessage.Role(const Value: TRole): TInputMessage;
begin
  Result := TInputMessage(Add('role', Value.ToString));
end;

function TInputMessage.Role(const Value: string): TInputMessage;
begin
  Result := TInputMessage(Add('role', TRole.Create(Value).ToString));
end;

function TInputMessage.&Type(const Value: string): TInputMessage;
begin
  Result := TInputMessage(Add('type', Value));
end;

{ TItemInputMessage }

function TItemInputMessage.&Type(const Value: string): TItemInputMessage;
begin
  Result := TItemInputMessage(inherited &Type(Value));
end;

function TItemInputMessage.Content(
  const Value: TArray<TItemContent>): TItemInputMessage;
begin
  Result := TItemInputMessage(inherited Content(Value));
end;

class function TItemInputMessage.New: TItemInputMessage;
begin
  Result := TItemInputMessage.Create.&Type();
end;

function TItemInputMessage.Content(const Value: string): TItemInputMessage;
begin
  Result := TItemInputMessage(inherited Content(Value));
end;

function TItemInputMessage.Role(const Value: string): TItemInputMessage;
begin
  Result := TItemInputMessage(inherited Role(Value));
end;

function TItemInputMessage.Role(const Value: TRole): TItemInputMessage;
begin
  Result := TItemInputMessage(inherited Role(Value));
end;

function TItemInputMessage.Status(const Value: string): TItemInputMessage;
begin
  Result := TItemInputMessage(Add('status', TMessageStatus.Create(Value).ToString));
end;

function TItemInputMessage.Status(
  const Value: TMessageStatus): TItemInputMessage;
begin
  Result := TItemInputMessage(Add('status', Value.ToString));
end;

{ TInputItemReference }

class function TInputItemReference.New(
  const Value: string): TInputItemReference;
begin
  Result := New.Id(Value);
end;

class function TInputItemReference.New: TInputItemReference;
begin
  Result := TInputItemReference.Create.&Type();
end;

function TInputItemReference.&Type(const Value: string): TInputItemReference;
begin
  Result := TInputItemReference(Add('type', Value));
end;

function TInputItemReference.Id(const Value: string): TInputItemReference;
begin
  Result := TInputItemReference(Add('id', Value));
end;

{ TItemOutputMessage }

function TItemOutputMessage.&Type(const Value: string): TItemOutputMessage;
begin
  Result := TItemOutputMessage(Add('type', Value));
end;

function TItemOutputMessage.Content(
  const Value: TArray<TOutputMessageContent>): TItemOutputMessage;
begin
  var JSONArray := TJSONArray.Create;
  for var Item in Value do
    JSONArray.Add(Item.Detach);
  Result := TItemOutputMessage(Add('content', JSONArray));
end;

function TItemOutputMessage.Id(const Value: string): TItemOutputMessage;
begin
  Result := TItemOutputMessage(Add('id', Value));
end;

class function TItemOutputMessage.New: TItemOutputMessage;
begin
  Result := TItemOutputMessage.Create.&Type().Role('assistant');
end;

function TItemOutputMessage.Role(const Value: TRole): TItemOutputMessage;
begin
  Result := TItemOutputMessage(Add('role', Value.ToString));
end;

function TItemOutputMessage.Role(const Value: string): TItemOutputMessage;
begin
  Result := TItemOutputMessage(Add('role', TRole.Create(Value).ToString));
end;

function TItemOutputMessage.Status(const Value: string): TItemOutputMessage;
begin
  Result := Status(TMessageStatus.Create(Value));
end;

function TItemOutputMessage.Status(
  const Value: TMessageStatus): TItemOutputMessage;
begin
  Result := TItemOutputMessage(Add('status', Value.ToString));
end;

{ TOutputMessageContent }

function TOutputMessageContent.&Type(
  const Value: string): TOutputMessageContent;
begin
  Result := TOutputMessageContent(Add('type', Value));
end;

function TOutputMessageContent.Annotations(
  const Value: TArray<TOutputNotation>): TOutputMessageContent;
begin
  var JSONArray := TJSONArray.Create;
  for var Item in Value do
    JSONArray.Add(Item.Detach);
  Result := TOutputMessageContent(Add('annotations', JSONArray));
end;

function TOutputMessageContent.Annotations(
  const Value: string): TOutputMessageContent;
var
  JSONArray: TJSONArray;
begin
  if TJSONHelper.TryGetArray(Value, JSONArray) then
    Exit(TOutputMessageContent(Add('annotations', JSONArray)));

  raise TGenAIAPIException.Create('Invalid JSON Array');
end;

function TOutputMessageContent.Logprobs(
  const Value: string): TOutputMessageContent;
var
  JSONArray: TJSONArray;
begin
  if TJSONHelper.TryGetArray(Value, JSONArray) then
    Exit(TOutputMessageContent(Add('logprobs', JSONArray)));

  raise TGenAIAPIException.Create('Invalid JSON Array');
end;

function TOutputMessageContent.Logprobs(
  const Value: TArray<TOutputLogprobs>): TOutputMessageContent;
begin
  var JSONArray := TJSONArray.Create;
  for var Item in Value do
    JSONArray.Add(Item.Detach);
  Result := TOutputMessageContent(Add('logprobs', JSONArray));
end;

class function TOutputMessageContent.NewOutputText: TOutputMessageContent;
begin
  Result := TOutputMessageContent.Create.&Type('output_text');
end;

class function TOutputMessageContent.NewRefusal: TOutputMessageContent;
begin
  Result := TOutputMessageContent.Create.&Type('refusal');
end;

function TOutputMessageContent.Refusal(
  const Value: string): TOutputMessageContent;
begin
  Result := TOutputMessageContent(Add('refusal', Value));
end;

function TOutputMessageContent.Text(const Value: string): TOutputMessageContent;
begin
  Result := TOutputMessageContent(Add('text', Value));
end;

{ TOutputNotation }

function TOutputNotation.&Type(const Value: string): TOutputNotation;
begin
  Result := TOutputNotation(Add('type', Value));
end;

function TOutputNotation.EndIndex(const Value: Integer): TOutputNotation;
begin
  Result := TOutputNotation(Add('end_index', Value));
end;

function TOutputNotation.FileId(const Value: string): TOutputNotation;
begin
  Result := TOutputNotation(Add('file_id', Value));
end;

function TOutputNotation.Index(const Value: Integer): TOutputNotation;
begin
  Result := TOutputNotation(Add('index', Value));
end;

class function TOutputNotation.NewFileCitation: TOutputNotation;
begin
  Result := TOutputNotation.Create.&Type('file_citation');
end;

class function TOutputNotation.NewFilePath: TOutputNotation;
begin
  Result := TOutputNotation.Create.&Type('file_path');
end;

class function TOutputNotation.NewUrlCitation: TOutputNotation;
begin
  Result := TOutputNotation.Create.&Type('url_citation');
end;

function TOutputNotation.StartIndex(const Value: Integer): TOutputNotation;
begin
  Result := TOutputNotation(Add('start_index', Value));
end;

function TOutputNotation.Title(const Value: string): TOutputNotation;
begin
  Result := TOutputNotation(Add('title', Value));
end;

function TOutputNotation.Url(const Value: string): TOutputNotation;
begin
  Result := TOutputNotation(Add('url', Value));
end;

{ TFileSearchToolCall }

function TFileSearchToolCall.&Type(const Value: string): TFileSearchToolCall;
begin
   Result := TFileSearchToolCall(Add('type', Value));
end;

function TFileSearchToolCall.Id(const Value: string): TFileSearchToolCall;
begin
  Result := TFileSearchToolCall(Add('id', Value));
end;

class function TFileSearchToolCall.New: TFileSearchToolCall;
begin
  Result := TFileSearchToolCall.Create.&Type();
end;

function TFileSearchToolCall.Queries(
  const Value: TArray<string>): TFileSearchToolCall;
begin
  Result := TFileSearchToolCall(Add('queries', Value));
end;

function TFileSearchToolCall.Results(const Value: string): TFileSearchToolCall;
var
  JSONArray: TJSONArray;
begin
  if TJSONHelper.TryGetArray(Value, JSONArray) then
    Exit(TFileSearchToolCall(Add('results', JSONArray)));

  raise TGenAIAPIException.Create('Invalid JSON Array');
end;

function TFileSearchToolCall.Results(
  const Value: TArray<TFileSearchToolCallResult>): TFileSearchToolCall;
begin
  var JSONArray := TJSONArray.Create;
  for var Item in Value do
    JSONArray.Add(Item.Detach);
  Result := TFileSearchToolCall(Add('results', JSONArray));
end;

function TFileSearchToolCall.Status(const Value: string): TFileSearchToolCall;
begin
  Result := Status(TFileSearchToolCallType.Create(Value));
end;

function TFileSearchToolCall.Status(
  const Value: TFileSearchToolCallType): TFileSearchToolCall;
begin
  Result := TFileSearchToolCall(Add('status', Value.ToString));
end;

{ TFileSearchToolCallResult }

function TFileSearchToolCallResult.Attributes(
  const Value: TJSONObject): TFileSearchToolCallResult;
begin
  Result := TFileSearchToolCallResult(Add('attributes', Value));
end;

function TFileSearchToolCallResult.Attributes(
  const Value: string): TFileSearchToolCallResult;
var
  JSONObject: TJSONObject;
begin
  if TJSONHelper.TryGetObject(Value, JSONObject) then
    Exit(TFileSearchToolCallResult(Add('attributes', JSONObject)));

  raise TGenAIAPIException.Create('Invalid JSON Object');
end;

function TFileSearchToolCallResult.FileId(
  const Value: string): TFileSearchToolCallResult;
begin
  Result := TFileSearchToolCallResult(Add('file_id', Value));
end;

function TFileSearchToolCallResult.Filename(
  const Value: string): TFileSearchToolCallResult;
begin
  Result := TFileSearchToolCallResult(Add('filename', Value));
end;

class function TFileSearchToolCallResult.New: TFileSearchToolCallResult;
begin
  Result := TFileSearchToolCallResult.Create;
end;

function TFileSearchToolCallResult.Score(
  const Value: Double): TFileSearchToolCallResult;
begin
  Result := TFileSearchToolCallResult(Add('score', Value));
end;

function TFileSearchToolCallResult.Text(
  const Value: string): TFileSearchToolCallResult;
begin
  Result := TFileSearchToolCallResult(Add('text', Value));
end;

{ TComputerToolCall }

function TComputerToolCall.Action(
  const Value: TComputerToolCallAction): TComputerToolCall;
begin
  Result := TComputerToolCall(Add('action', Value.Detach));
end;

function TComputerToolCall.Action(const Value: string): TComputerToolCall;
var
  JSONObject: TJSONObject;
begin
  if TJSONHelper.TryGetObject(Value, JSONObject) then
    Exit(TComputerToolCall(Add('action', JSONObject)));

  raise TGenAIAPIException.Create('Invalid JSON Object');
end;

function TComputerToolCall.CallId(const Value: string): TComputerToolCall;
begin
  Result := TComputerToolCall(Add('call_id', Value));
end;

function TComputerToolCall.Id(const Value: string): TComputerToolCall;
begin
  Result := TComputerToolCall(Add('id', Value));
end;

class function TComputerToolCall.New: TComputerToolCall;
begin
  Result := TComputerToolCall.Create.&Type();
end;

function TComputerToolCall.PendingSafetyChecks(
  const Value: string): TComputerToolCall;
var
  JSONArray: TJSONArray;
begin
  if TJSONHelper.TryGetArray(Value, JSONArray) then
    Exit(TComputerToolCall(Add('pending_safety_checks', JSONArray)));

  raise TGenAIAPIException.Create('Invalid JSON Array');
end;

function TComputerToolCall.PendingSafetyChecks(
  const Value: TArray<TPendingSafetyCheck>): TComputerToolCall;
begin
  var JSONArray := TJSONArray.Create;
  for var item in Value do
    JSONArray.Add(Item.Detach);
  Result := TComputerToolCall(Add('pending_safety_checks', JSONArray));
end;

function TComputerToolCall.Status(const Value: string): TComputerToolCall;
begin
  Result := TComputerToolCall(Add('status', TMessageStatus.Create(Value).ToString));
end;

function TComputerToolCall.Status(
  const Value: TMessageStatus): TComputerToolCall;
begin
  Result := TComputerToolCall(Add('status', Value.ToString));
end;

function TComputerToolCall.&Type(const Value: string): TComputerToolCall;
begin
  Result := TComputerToolCall(Add('type', Value));
end;

{ TPendingSafetyCheck }

function TPendingSafetyCheck.Code(const Value: string): TPendingSafetyCheck;
begin
  Result := TPendingSafetyCheck(Add('code', Value));
end;

function TPendingSafetyCheck.Id(const Value: string): TPendingSafetyCheck;
begin
  Result := TPendingSafetyCheck(Add('id', Value));
end;

function TPendingSafetyCheck.Message(const Value: string): TPendingSafetyCheck;
begin
  Result := TPendingSafetyCheck(Add('message', Value));
end;

{ TComputerClick }

function TComputerClick.&Type(const Value: string): TComputerClick;
begin
  Result := TComputerClick(Add('type', Value));
end;

function TComputerClick.Button(const Value: TMouseButton): TComputerClick;
begin
  Result := TComputerClick(Add('button', Value.ToString));
end;

function TComputerClick.Button(const Value: string): TComputerClick;
begin
  Result := Button(TMouseButton.Create(Value));
end;

class function TComputerClick.New: TComputerClick;
begin
  Result := TComputerClick.Create.&Type();
end;

function TComputerClick.X(const Value: Integer): TComputerClick;
begin
  Result := TComputerClick(Add('x', Value));
end;

function TComputerClick.Y(const Value: Integer): TComputerClick;
begin
  Result := TComputerClick(Add('y', Value));
end;


{ TComputerDoubleClick }

class function TComputerDoubleClick.New: TComputerDoubleClick;
begin
  Result := TComputerDoubleClick.Create.&Type();
end;

function TComputerDoubleClick.&Type(const Value: string): TComputerDoubleClick;
begin
  Result := TComputerDoubleClick(Add('type', Value));
end;

function TComputerDoubleClick.X(const Value: Integer): TComputerDoubleClick;
begin
  Result := TComputerDoubleClick(Add('x', Value));
end;

function TComputerDoubleClick.Y(const Value: Integer): TComputerDoubleClick;
begin
  Result := TComputerDoubleClick(Add('y', Value));
end;

{ TComputerToolCallOutput }

function TComputerToolCallOutput.&Type(
  const Value: string): TComputerToolCallOutput;
begin
  Result := TComputerToolCallOutput(Add('type', Value));
end;

function TComputerToolCallOutput.AcknowledgedSafetyChecks(
  const Value: TArray<TAcknowledgedSafetyCheckParams>): TComputerToolCallOutput;
begin
  var JSONArray := TJSONArray.Create;
  for var Item in Value do
    JSONArray.Add(Item.Detach);
  Result := TComputerToolCallOutput(Add('acknowledged_safety_checks', JSONArray));
end;

function TComputerToolCallOutput.AcknowledgedSafetyChecks(
  const Value: string): TComputerToolCallOutput;
var
  JSONArray: TJSONArray;
begin
  if TJSONHelper.TryGetArray(Value, JSONArray) then
    Exit(TComputerToolCallOutput(Add('acknowledged_safety_checks', JSONArray)));

  raise TGenAIAPIException.Create('Invalid JSON Array');
end;

function TComputerToolCallOutput.CallId(
  const Value: string): TComputerToolCallOutput;
begin
  Result := TComputerToolCallOutput(Add('call_id', Value));
end;

function TComputerToolCallOutput.Id(
  const Value: string): TComputerToolCallOutput;
begin
  Result := TComputerToolCallOutput(Add('id', Value));
end;

class function TComputerToolCallOutput.New: TComputerToolCallOutput;
begin
  Result := TComputerToolCallOutput.Create.&Type();
end;

function TComputerToolCallOutput.Output(
  const Value: string): TComputerToolCallOutput;
var
  JSONObject: TJSONObject;
begin
  if TJSONHelper.TryGetObject(Value, JSONObject) then
    Exit(TComputerToolCallOutput(Add('output', JSONObject)));

  raise TGenAIAPIException.Create('Invalid JSON Object');
end;

function TComputerToolCallOutput.Output(
  const Value: TComputerToolCallOutputObject): TComputerToolCallOutput;
begin
  Result := TComputerToolCallOutput(Add('output', Value.Detach));
end;

function TComputerToolCallOutput.Status(
  const Value: string): TComputerToolCallOutput;
begin
  Result := TComputerToolCallOutput(Add('status', TMessageStatus.Create(Value).ToString));
end;

function TComputerToolCallOutput.Status(
  const Value: TMessageStatus): TComputerToolCallOutput;
begin
  Result := TComputerToolCallOutput(Add('status', Value.ToString));
end;

{ TComputerToolCallOutputObject }

function TComputerToolCallOutputObject.&Type(
  const Value: string): TComputerToolCallOutputObject;
begin
  Result := TComputerToolCallOutputObject(Add('type', Value));
end;

function TComputerToolCallOutputObject.FileId(
  const Value: string): TComputerToolCallOutputObject;
begin
  Result := TComputerToolCallOutputObject(Add('file_id', Value));
end;

function TComputerToolCallOutputObject.ImageUrl(
  const Value: string): TComputerToolCallOutputObject;
begin
  Result := TComputerToolCallOutputObject(Add('image_url', Value));
end;

class function TComputerToolCallOutputObject.New: TComputerToolCallOutputObject;
begin
  Result := TComputerToolCallOutputObject.Create.&Type();
end;

{ TAcknowledgedSafetyCheckParams }

function TAcknowledgedSafetyCheckParams.Code(
  const Value: string): TAcknowledgedSafetyCheckParams;
begin
  Result := TAcknowledgedSafetyCheckParams(Add('code', Value));
end;

function TAcknowledgedSafetyCheckParams.Id(
  const Value: string): TAcknowledgedSafetyCheckParams;
begin
  Result := TAcknowledgedSafetyCheckParams(Add('id', Value));
end;

function TAcknowledgedSafetyCheckParams.Message(
  const Value: string): TAcknowledgedSafetyCheckParams;
begin
  Result := TAcknowledgedSafetyCheckParams(Add('message', Value));
end;

class function TAcknowledgedSafetyCheckParams.New: TAcknowledgedSafetyCheckParams;
begin
  Result := TAcknowledgedSafetyCheckParams.Create;
end;

{ TWebSearchToolCall }

function TWebSearchToolCall.Action(
  const Value: TWebSearchAction): TWebSearchToolCall;
begin
  Result := TWebSearchToolCall(Add('action', Value.Detach));
end;

function TWebSearchToolCall.Action(const Value: string): TWebSearchToolCall;
var
  JSONObject: TJSONObject;
begin
  if TJSONHelper.TryGetObject(Value, JSONObject) then
    Exit(TWebSearchToolCall(Add('action', JSONObject)));

  raise TGenAIAPIException.Create('Invalid JSON Object');
end;

function TWebSearchToolCall.Id(const Value: string): TWebSearchToolCall;
begin
  Result := TWebSearchToolCall(Add('id', Value));
end;

class function TWebSearchToolCall.New: TWebSearchToolCall;
begin
  Result := TWebSearchToolCall.Create.&Type();
end;

function TWebSearchToolCall.Status(const Value: string): TWebSearchToolCall;
begin
  Result := TWebSearchToolCall(Add('status', TMessageStatus.Create(Value).ToString));
end;

function TWebSearchToolCall.Status(
  const Value: TMessageStatus): TWebSearchToolCall;
begin
  Result := TWebSearchToolCall(Add('status', Value.ToString));
end;

function TWebSearchToolCall.&Type(const Value: string): TWebSearchToolCall;
begin
  Result := TWebSearchToolCall(Add('type', Value));
end;

{ TFunctionToolCall }

function TFunctionToolCall.&Type(const Value: string): TFunctionToolCall;
begin
  Result := TFunctionToolCall(Add('type', Value));
end;

function TFunctionToolCall.Arguments(const Value: string): TFunctionToolCall;
begin
  Result := TFunctionToolCall(Add('arguments', Value));
end;

function TFunctionToolCall.CallId(const Value: string): TFunctionToolCall;
begin
  Result := TFunctionToolCall(Add('call_id', Value));
end;

function TFunctionToolCall.Id(const Value: string): TFunctionToolCall;
begin
  Result := TFunctionToolCall(Add('id', Value));
end;

function TFunctionToolCall.Name(const Value: string): TFunctionToolCall;
begin
  Result := TFunctionToolCall(Add('name', Value));
end;

class function TFunctionToolCall.New: TFunctionToolCall;
begin
  Result := TFunctionToolCall.Create.&Type();
end;

function TFunctionToolCall.Status(const Value: string): TFunctionToolCall;
begin
  Result := TFunctionToolCall(Add('status', TMessageStatus.Create(Value).ToString));
end;

function TFunctionToolCall.Status(
  const Value: TMessageStatus): TFunctionToolCall;
begin
  Result := TFunctionToolCall(Add('status', Value.ToString));
end;

{ TFunctionToolCalloutput }

function TFunctionToolCalloutput.&Type(
  const Value: string): TFunctionToolCalloutput;
begin
  Result := TFunctionToolCalloutput(Add('type', Value));
end;

function TFunctionToolCalloutput.CallId(
  const Value: string): TFunctionToolCalloutput;
begin
  Result := TFunctionToolCalloutput(Add('call_id', Value));
end;

function TFunctionToolCalloutput.Id(
  const Value: string): TFunctionToolCalloutput;
begin
  Result := TFunctionToolCalloutput(Add('id', Value));
end;

class function TFunctionToolCalloutput.New: TFunctionToolCalloutput;
begin
  Result := TFunctionToolCalloutput.Create.&Type();
end;

function TFunctionToolCalloutput.Output(
  const Value: TArray<TFunctionOutput>): TFunctionToolCalloutput;
begin
  var JSONArray := TJSONArray.Create;
  for var Item in Value do
    JSONArray.Add(Item.Detach);

  Result := TFunctionToolCalloutput(Add('output', JSONArray));
end;

function TFunctionToolCalloutput.Output(
  const Value: string): TFunctionToolCalloutput;
var
  JSONObject: TJSONObject;
begin
  if TJSONHelper.TryGetObject(Value, JSONObject) then
    Exit(TFunctionToolCalloutput(Add('output', JSONObject)));

  Result := TFunctionToolCalloutput(Add('output', Value));
end;

function TFunctionToolCalloutput.Status(
  const Value: string): TFunctionToolCalloutput;
begin
  Result := TFunctionToolCalloutput(Add('status', TMessageStatus.Create(Value).ToString));
end;

function TFunctionToolCalloutput.Status(
  const Value: TMessageStatus): TFunctionToolCalloutput;
begin
  Result := TFunctionToolCalloutput(Add('status', Value.ToString));
end;

{ TReasoningObject }

function TReasoningObject.EncryptedContent(
  const Value: string): TReasoningObject;
begin
  Result := TReasoningObject(Add('encrypted_content', Value));
end;

function TReasoningObject.Id(const Value: string): TReasoningObject;
begin
  Result := TReasoningObject(Add('id', Value));
end;

class function TReasoningObject.New: TReasoningObject;
begin
  Result := TReasoningObject.Create.&Type();
end;

function TReasoningObject.Status(const Value: string): TReasoningObject;
begin
  Result := TReasoningObject(Add('status', TMessageStatus.Create(Value).ToString));
end;

function TReasoningObject.Summary(const Value: string): TReasoningObject;
var
  JSONArray: TJSONArray;
begin
  if TJSONHelper.TryGetArray(Value, JSONArray) then
    Exit(TReasoningObject(Add('summary', JSONArray)));

  raise TGenAIAPIException.Create('Invalid JSON Array');
end;

function TReasoningObject.Summary(
  const Value: TArray<TReasoningTextContent>): TReasoningObject;
begin
  var JSONArray := TJSONArray.Create;
  for var Item in Value do
    JSONArray.Add(Item.Detach);
  Result := TReasoningObject(Add('summary', JSONArray));
end;

function TReasoningObject.Status(const Value: TMessageStatus): TReasoningObject;
begin
  Result := TReasoningObject(Add('status', Value.ToString));
end;

function TReasoningObject.&Type(const Value: string): TReasoningObject;
begin
  Result := TReasoningObject(Add('type', Value));
end;

{ TReasoningTextContent }

class function TReasoningTextContent.New: TReasoningTextContent;
begin
  Result := TReasoningTextContent.Create.&Type();
end;

function TReasoningTextContent.Text(const Value: string): TReasoningTextContent;
begin
  Result := TReasoningTextContent(Add('text', Value));
end;

function TReasoningTextContent.&Type(
  const Value: string): TReasoningTextContent;
begin
  Result := TReasoningTextContent(Add('type', Value));
end;

{ TOutputLogprobs }

function TOutputLogprobs.Bytes(const Value: TArray<Int64>): TOutputLogprobs;
begin
  Result := TOutputLogprobs(Add('bytes', Value));
end;

function TOutputLogprobs.logprob(const Value: Double): TOutputLogprobs;
begin
  Result := TOutputLogprobs(Add('logprob', Value));
end;

function TOutputLogprobs.New(const AToken: string): TOutputLogprobs;
begin
  Result := TOutputLogprobs.Create.Token(AToken);
end;

function TOutputLogprobs.Token(const Value: string): TOutputLogprobs;
begin
  Result := TOutputLogprobs(Add('token', Value));
end;

{ TOutputTopLogprobs }

function TOutputTopLogprobs.Bytes(
  const Value: TArray<Int64>): TOutputTopLogprobs;
begin
  Result := TOutputTopLogprobs(Add('bytes', Value));
end;

function TOutputTopLogprobs.Logprob(const Value: Double): TOutputTopLogprobs;
begin
  Result := TOutputTopLogprobs(Add('logprob', Value));
end;

function TOutputTopLogprobs.New(const AToken: string): TOutputTopLogprobs;
begin
  Result := TOutputTopLogprobs.Create.Token(AToken);
end;

function TOutputTopLogprobs.Token(const Value: string): TOutputTopLogprobs;
begin
  Result := TOutputTopLogprobs(Add('token', Value));
end;

{ TComputerDrag }

class function TComputerDrag.New: TComputerDrag;
begin
  Result := TComputerDrag.Create.&Type();
end;

function TComputerDrag.Path(
  const Value: TArray<TComputerDragPoint>): TComputerDrag;
begin
  var JSONArray := TJSONArray.Create;
  for var Item in Value do
    JSONArray.Add(Item.Detach);
  Result := TComputerDrag(Add('path', JSONArray));
end;

function TComputerDrag.Path(const Value: string): TComputerDrag;
var
  JSONArray: TJSONArray;
begin
  if TJSONHelper.TryGetArray(Value, JSONArray) then
    Exit(TComputerDrag(Add('path', JSONArray)));

  raise TGenAIAPIException.Create('Invalid JSON Array');
end;

function TComputerDrag.&Type(const Value: string): TComputerDrag;
begin
  Result := TComputerDrag(Add('type', Value));
end;

{ TComputerDragPoint }

class function TComputerDragPoint.New(const x, y: Integer): TComputerDragPoint;
begin
  Result := TComputerDragPoint.Create.X(x).Y(y);
end;

function TComputerDragPoint.X(const Value: Integer): TComputerDragPoint;
begin
  Result := TComputerDragPoint(Add('x', Value));
end;

function TComputerDragPoint.Y(const Value: Integer): TComputerDragPoint;
begin
  Result := TComputerDragPoint(Add('y', Value));
end;

{ TComputerKeyPressed }

function TComputerKeyPressed.Keys(const Value: TArray<string>): TComputerKeyPressed;
begin
  Result := TComputerKeyPressed(Add('keys', Value));
end;

class function TComputerKeyPressed.New: TComputerKeyPressed;
begin
  Result := TComputerKeyPressed.Create.&Type();
end;

function TComputerKeyPressed.&Type(const Value: string): TComputerKeyPressed;
begin
  Result := TComputerKeyPressed(Add('type', Value));
end;

{ TComputerMove }

class function TComputerMove.New: TComputerMove;
begin
  Result := TComputerMove.Create.&Type();
end;

function TComputerMove.&Type(const Value: string): TComputerMove;
begin
  Result := TComputerMove(Add('type', Value));
end;

function TComputerMove.X(const Value: Integer): TComputerMove;
begin
  Result := TComputerMove(Add('x', Value));
end;

function TComputerMove.Y(const Value: Integer): TComputerMove;
begin
  Result := TComputerMove(Add('y', Value));
end;

{ TComputerScreenshot }

class function TComputerScreenshot.New: TComputerScreenshot;
begin
  Result := TComputerScreenshot.Create.&Type();
end;

function TComputerScreenshot.&Type(const Value: string): TComputerScreenshot;
begin
  Result := TComputerScreenshot(Add('type', Value));
end;

{ TComputerScroll }

class function TComputerScroll.New: TComputerScroll;
begin
  Result := TComputerScroll.Create.&Type();
end;

function TComputerScroll.ScrollX(const Value: Integer): TComputerScroll;
begin
  Result := TComputerScroll(Add('scroll_x', Value));
end;

function TComputerScroll.ScrollY(const Value: Integer): TComputerScroll;
begin
  Result := TComputerScroll(Add('scroll_y', Value));
end;

function TComputerScroll.&Type(const Value: string): TComputerScroll;
begin
  Result := TComputerScroll(Add('type', Value));
end;

function TComputerScroll.X(const Value: Integer): TComputerScroll;
begin
  Result := TComputerScroll(Add('x', Value));
end;

function TComputerScroll.Y(const Value: Integer): TComputerScroll;
begin
  Result := TComputerScroll(Add('y', Value));
end;

{ TComputerType }

class function TComputerType.New: TComputerType;
begin
  Result := TComputerType.Create.&Type();
end;

function TComputerType.Text(const Value: string): TComputerType;
begin
  Result := TComputerType(Add('text', Value));
end;

function TComputerType.&Type(const Value: string): TComputerType;
begin
  Result := TComputerType(Add('type', Value));
end;

{ TComputerWait }

class function TComputerWait.New: TComputerWait;
begin
  Result := TComputerWait.Create.&Type();
end;

function TComputerWait.&Type(const Value: string): TComputerWait;
begin
  Result := TComputerWait(Add('type', Value));
end;

{ TImageGeneration }

function TImageGeneration.&Type(const Value: string): TImageGeneration;
begin
  Result := TImageGeneration(Add('type', Value));
end;

function TImageGeneration.Id(const Value: string): TImageGeneration;
begin
  Result := TImageGeneration(Add('id', Value));
end;

class function TImageGeneration.New: TImageGeneration;
begin
  Result := TImageGeneration.Create.&Type();
end;

function TImageGeneration.Result(const Value: string): TImageGeneration;
begin
  Result := TImageGeneration(Add('result', Value));
end;

function TImageGeneration.Status(const Value: string): TImageGeneration;
begin
  Result := TImageGeneration(Add('status', TMessageStatus.Create(Value).ToString));
end;

function TImageGeneration.Status(const Value: TMessageStatus): TImageGeneration;
begin
  Result := TImageGeneration(Add('status', Value.ToString));
end;

{ TCodeInterpreterToolCall }

function TCodeInterpreterToolCall.&Type(
  const Value: string): TCodeInterpreterToolCall;
begin
  Result := TCodeInterpreterToolCall(Add('type', Value));
end;

function TCodeInterpreterToolCall.Code(
  const Value: string): TCodeInterpreterToolCall;
begin
  Result := TCodeInterpreterToolCall(Add('code', Value));
end;

function TCodeInterpreterToolCall.ContainerId(
  const Value: string): TCodeInterpreterToolCall;
begin
  Result := TCodeInterpreterToolCall(Add('container_id', Value));
end;

function TCodeInterpreterToolCall.Id(
  const Value: string): TCodeInterpreterToolCall;
begin
  Result := TCodeInterpreterToolCall(Add('id', Value));
end;

class function TCodeInterpreterToolCall.New: TCodeInterpreterToolCall;
begin
  Result := TCodeInterpreterToolCall.Create.&Type();
end;

function TCodeInterpreterToolCall.Outputs(
  const Value: TArray<TCodeInterpreterOutputs>): TCodeInterpreterToolCall;
begin
  var JSONArray := TJSONArray.Create;
  for var Item in Value do
    JSONArray.Add(Item.Detach);
  Result := TCodeInterpreterToolCall(Add('outputs', JSONArray));
end;

function TCodeInterpreterToolCall.Outputs(
  const Value: string): TCodeInterpreterToolCall;
var
  JSONArray: TJSONArray;
begin
  if TJSONHelper.TryGetArray(Value, JSONArray) then
    Exit(TCodeInterpreterToolCall(Add('outputs', JSONArray)));

  raise TGenAIAPIException.Create('Invalid JSON Array');
end;

function TCodeInterpreterToolCall.Status(
  const Value: string): TCodeInterpreterToolCall;
begin
  Result := TCodeInterpreterToolCall(Add('status', TMessageStatus.Create(Value).ToString));
end;

function TCodeInterpreterToolCall.Status(
  const Value: TMessageStatus): TCodeInterpreterToolCall;
begin
  Result := TCodeInterpreterToolCall(Add('status', Value.ToString));
end;

{ TCodeInterpreterOutputLogs }

class function TCodeInterpreterOutputLogs.New: TCodeInterpreterOutputLogs;
begin
  Result := TCodeInterpreterOutputLogs.Create.&Type();
end;

function TCodeInterpreterOutputLogs.&Type(
  const Value: string): TCodeInterpreterOutputLogs;
begin
  Result := TCodeInterpreterOutputLogs(Add('type', Value));
end;

function TCodeInterpreterOutputLogs.Logs(
  const Value: string): TCodeInterpreterOutputLogs;
begin
  Result := TCodeInterpreterOutputLogs(Add('logs', Value));
end;

{ TLocalShellCall }

function TLocalShellCall.&Type(const Value: string): TLocalShellCall;
begin
  Result := TLocalShellCall(Add('type', Value));
end;

function TLocalShellCall.Action(
  const Value: TLocalShellCallAction): TLocalShellCall;
begin
  Result := TLocalShellCall(Add('action', Value.Detach));
end;

function TLocalShellCall.Action(const Value: string): TLocalShellCall;
var
  JSONObject: TJSONObject;
begin
  if TJSONHelper.TryGetObject(Value, JSONObject) then
    Exit(TLocalShellCall(Add('action', JSONObject)));

  raise TGenAIAPIException.Create('Invalid JSON Object');
end;

function TLocalShellCall.CallId(const Value: string): TLocalShellCall;
begin
  Result := TLocalShellCall(Add('call_id', Value));
end;

function TLocalShellCall.Id(const Value: string): TLocalShellCall;
begin
  Result := TLocalShellCall(Add('id', Value));
end;

class function TLocalShellCall.New: TLocalShellCall;
begin
  Result := TLocalShellCall.Create.&Type();
end;

function TLocalShellCall.Status(const Value: string): TLocalShellCall;
begin
  Result := TLocalShellCall(Add('status', TMessageStatus.Create(Value).ToString));
end;

function TLocalShellCall.Status(const Value: TMessageStatus): TLocalShellCall;
begin
  Result := TLocalShellCall(Add('status', Value.ToString));
end;

{ TLocalShellCallAction }

function TLocalShellCallAction.TimeoutMs(
  const Value: Integer): TLocalShellCallAction;
begin
  Result := TLocalShellCallAction(Add('timeout_ms', Value));
end;

function TLocalShellCallAction.&Type(
  const Value: string): TLocalShellCallAction;
begin
  Result := TLocalShellCallAction(Add('type', Value));
end;

function TLocalShellCallAction.User(const Value: string): TLocalShellCallAction;
begin
  Result := TLocalShellCallAction(Add('user', Value));
end;

function TLocalShellCallAction.WorkingDirectory(
  const Value: string): TLocalShellCallAction;
begin
  Result := TLocalShellCallAction(Add('working_directory', Value));
end;

function TLocalShellCallAction.Command(
  const Value: string): TLocalShellCallAction;
begin
  Result := TLocalShellCallAction(Add('command', Value));
end;

function TLocalShellCallAction.Env(
  const Value: TJsonObject): TLocalShellCallAction;
begin
  Result := TLocalShellCallAction(Add('env', Value));
end;

class function TLocalShellCallAction.New: TLocalShellCallAction;
begin
  Result := TLocalShellCallAction.Create.&Type();
end;

{ TLocalShellCallOutput }

function TLocalShellCallOutput.&Type(const Value: string): TLocalShellCallOutput;
begin
  Result := TLocalShellCallOutput(Add('type', Value));
end;

function TLocalShellCallOutput.Id(const Value: string): TLocalShellCallOutput;
begin
  Result := TLocalShellCallOutput(Add('id', Value));
end;

class function TLocalShellCallOutput.New: TLocalShellCallOutput;
begin
  Result := TLocalShellCallOutput.Create.&Type();
end;

function TLocalShellCallOutput.Output(
  const Value: string): TLocalShellCallOutput;
begin
  Result := TLocalShellCallOutput(Add('output', Value));
end;

function TLocalShellCallOutput.Status(
  const Value: string): TLocalShellCallOutput;
begin
  Result := TLocalShellCallOutput(Add('status', TMessageStatus.Create(Value).ToString));
end;

function TLocalShellCallOutput.Status(
  const Value: TMessageStatus): TLocalShellCallOutput;
begin
  Result := TLocalShellCallOutput(Add('status', Value.ToString));
end;

{ TMCPListTools }

function TMCPListTools.Tools(const Value: TArray<TMCPTools>): TMCPListTools;
begin
  var JSONArray := TJSONArray.Create;
  for var Item in Value do
    JSONArray.Add(Item.Detach);
  Result := TMCPListTools(Add('tools', JSONArray));
end;

function TMCPListTools.Tools(const Value: string): TMCPListTools;
var
  JSONArray: TJSONArray;
begin
  if TJSONHelper.TryGetArray(Value, JSONArray) then
    Exit(TMCPListTools(Add('tools', JSONArray)));

  raise TGenAIAPIException.Create('Invalid JSON Array');
end;

function TMCPListTools.&Type(const Value: string): TMCPListTools;
begin
  Result := TMCPListTools(Add('type', Value));
end;

function TMCPListTools.Error(const Value: string): TMCPListTools;
begin
  Result := TMCPListTools(Add('error', Value));
end;

function TMCPListTools.Id(const Value: string): TMCPListTools;
begin
  Result := TMCPListTools(Add('id', Value));
end;

class function TMCPListTools.New: TMCPListTools;
begin
   Result := TMCPListTools.Create.&Type();
end;

function TMCPListTools.ServerLabel(const Value: string): TMCPListTools;
begin
  Result := TMCPListTools(Add('server_label', Value));
end;

{ TMCPTools }

function TMCPTools.Annotations(const Value: TJSONObject): TMCPTools;
begin
  Result := TMCPTools(Add('annotations', Value));
end;

function TMCPTools.Description(const Value: string): TMCPTools;
begin
  Result := TMCPTools(Add('description', Value));
end;


function TMCPTools.InputSchema(const Value: string): TMCPTools;
var
  JSONObject: TJSONObject;
begin
  if TJSONHelper.TryGetObject(Value, JSONObject) then
    Exit(TMCPTools(Add('input_schema', JSONObject)));

  raise TGenAIAPIException.Create('Invalid JSON Object');
end;

function TMCPTools.InputSchema(const Value: TSchemaParams): TMCPTools;
begin
  Result := TMCPTools(Add('input_schema', Value.Detach));
end;

function TMCPTools.InputSchema(const Value: TJSONObject): TMCPTools;
begin
  Result := TMCPTools(Add('input_schema', Value));
end;

function TMCPTools.Name(const Value: string): TMCPTools;
begin
  Result := TMCPTools(Add('name', Value));
end;

class function TMCPTools.New: TMCPTools;
begin
  Result := TMCPTools.Create;
end;

{ TMCPApprovalRequest }

function TMCPApprovalRequest.&Type(const Value: string): TMCPApprovalRequest;
begin
  Result := TMCPApprovalRequest(Add('type', Value));
end;

function TMCPApprovalRequest.Arguments(
  const Value: string): TMCPApprovalRequest;
begin
  Result := TMCPApprovalRequest(Add('arguments', Value));
end;

function TMCPApprovalRequest.Id(const Value: string): TMCPApprovalRequest;
begin
  Result := TMCPApprovalRequest(Add('id', Value));
end;

function TMCPApprovalRequest.Name(const Value: string): TMCPApprovalRequest;
begin
  Result := TMCPApprovalRequest(Add('name', Value));
end;

class function TMCPApprovalRequest.New: TMCPApprovalRequest;
begin
  Result := TMCPApprovalRequest.Create.&Type();
end;

function TMCPApprovalRequest.ServerLabel(
  const Value: string): TMCPApprovalRequest;
begin
  Result := TMCPApprovalRequest(Add('server_label', Value));
end;

{ TMCPApprovalResponse }

function TMCPApprovalResponse.&Type(const Value: string): TMCPApprovalResponse;
begin
  Result := TMCPApprovalResponse(Add('type', Value));
end;

function TMCPApprovalResponse.ApprovalRequestId(
  const Value: string): TMCPApprovalResponse;
begin
  Result := TMCPApprovalResponse(Add('approval_request_id', Value));
end;

function TMCPApprovalResponse.Approve(
  const Value: Boolean): TMCPApprovalResponse;
begin
  Result := TMCPApprovalResponse(Add('approve', Value));
end;

function TMCPApprovalResponse.Id(const Value: string): TMCPApprovalResponse;
begin
  Result := TMCPApprovalResponse(Add('id', Value));
end;

class function TMCPApprovalResponse.New: TMCPApprovalResponse;
begin
  Result := TMCPApprovalResponse.Create.&Type();
end;

function TMCPApprovalResponse.Reason(const Value: string): TMCPApprovalResponse;
begin
  Result := TMCPApprovalResponse(Add('reason', Value));
end;

{ TMCPToolCall }

function TMCPToolCall.&Type(const Value: string): TMCPToolCall;
begin
  Result := TMCPToolCall(Add('type', Value));
end;

function TMCPToolCall.Arguments(const Value: string): TMCPToolCall;
begin
  Result := TMCPToolCall(Add('arguments', Value));
end;

function TMCPToolCall.Error(const Value: string): TMCPToolCall;
begin
  Result := TMCPToolCall(Add('error', Value));
end;

function TMCPToolCall.Id(const Value: string): TMCPToolCall;
begin
  Result := TMCPToolCall(Add('id', Value));
end;

function TMCPToolCall.Name(const Value: string): TMCPToolCall;
begin
  Result := TMCPToolCall(Add('name', Value));
end;

class function TMCPToolCall.New: TMCPToolCall;
begin
  Result := TMCPToolCall.Create.&Type();
end;

function TMCPToolCall.Output(const Value: string): TMCPToolCall;
begin
  Result := TMCPToolCall(Add('output', Value));
end;

function TMCPToolCall.ServerLabel(const Value: string): TMCPToolCall;
begin
  Result := TMCPToolCall(Add('server_label', Value));
end;

{ TReasoningParams }

function TReasoningParams.Effort(const Value: TReasoningEffort): TReasoningParams;
begin
  Result := TReasoningParams(Add('effort', Value.ToString));
end;

function TReasoningParams.Effort(const Value: string): TReasoningParams;
begin
  Result := Effort(TReasoningEffort.Create(Value));
end;

class function TReasoningParams.New: TReasoningParams;
begin
  Result := TReasoningParams.Create;
end;

function TReasoningParams.Summary(const Value: string): TReasoningParams;
begin
  Result := Summary(TReasoningGenerateSummary.Create(Value));
end;

function TReasoningParams.Summary(
  const Value: TReasoningGenerateSummary): TReasoningParams;
begin
  Result := TReasoningParams(Add('summary', Value.ToString));
end;

{ TTextFormatTextPrams }

class function TTextFormatTextPrams.New: TTextFormatTextPrams;
begin
  Result := TTextFormatTextPrams.Create.&Type();
end;

function TTextFormatTextPrams.&Type(const Value: string): TTextFormatTextPrams;
begin
  Result := TTextFormatTextPrams(Add('type', Value));
end;

{ TTextJSONSchemaParams }

function TTextJSONSchemaParams.&Type(
  const Value: string): TTextJSONSchemaParams;
begin
  Result := TTextJSONSchemaParams(Add('type', Value));
end;

function TTextJSONSchemaParams.Description(
  const Value: string): TTextJSONSchemaParams;
begin
  Result := TTextJSONSchemaParams(Add('description', Value));
end;

function TTextJSONSchemaParams.Name(const Value: string): TTextJSONSchemaParams;
begin
  Result := TTextJSONSchemaParams(Add('name', Value));
end;

class function TTextJSONSchemaParams.New: TTextJSONSchemaParams;
begin
  Result := TTextJSONSchemaParams.Create.&Type();
end;

function TTextJSONSchemaParams.Schema(
  const Value: TSchemaParams): TTextJSONSchemaParams;
begin
  Result := TTextJSONSchemaParams(Add('schema', Value.Detach));
end;

function TTextJSONSchemaParams.Schema(
  const Value: string): TTextJSONSchemaParams;
var
  JSONObject: TJSONObject;
begin
  if TJSONHelper.TryGetObject(Value, JSONObject) then
    Exit(TTextJSONSchemaParams(Add('schema', JSONObject)));

  raise TGenAIAPIException.Create('Invalid JSON Object');
end;

function TTextJSONSchemaParams.Strict(
  const Value: Boolean): TTextJSONSchemaParams;
begin
  Result := TTextJSONSchemaParams(Add('strict', Value));
end;

{ TTextJSONObjectParams }

class function TTextJSONObjectParams.New: TTextJSONObjectParams;
begin
  Result := TTextJSONObjectParams.Create.&Type();
end;

function TTextJSONObjectParams.&Type(
  const Value: string): TTextJSONObjectParams;
begin
  Result := TTextJSONObjectParams(Add('type', Value));
end;

{ TTextParams }

function TTextParams.Format(const Value: TTextFormatParams): TTextParams;
begin
  Result := TTextParams(Add('format', Value.Detach));
end;

function TTextParams.Format(const Value: string): TTextParams;
var
  JSONObject: TJSONObject;
begin
  if TJSONHelper.TryGetObject(Value, JSONObject) then
    Exit(TTextParams(Add('format', JSONObject)));

  raise TGenAIAPIException.Create('Invalid JSON Object');
end;

function TTextParams.Verbosity(const Value: TVerbosityType): TTextParams;
begin
  Result := TTextParams(Add('verbosity', Value.ToString));
end;

function TTextParams.Verbosity(const Value: string): TTextParams;
begin
  Result := TTextParams(Add('verbosity', TVerbosityType.Create(Value).ToString));
end;

{ THostedToolParams }

function THostedToolParams.&Type(
  const Value: THostedTooltype): THostedToolParams;
begin
  Result := THostedToolParams(Add('type', Value.ToString));
end;

class function THostedToolParams.New(const Value: string): THostedToolParams;
begin
  Result := THostedToolParams.Create.&Type(Value);
end;

function THostedToolParams.&Type(const Value: string): THostedToolParams;
begin
  Result := THostedToolParams(Add('type', THostedTooltype.Create(Value).ToString));
end;

{ TFunctionToolParams }

function TFunctionToolParams.Name(const Value: string): TFunctionToolParams;
begin
  Result := TFunctionToolParams(Add('name', Value));
end;

class function TFunctionToolParams.New: TFunctionToolParams;
begin
  Result := TFunctionToolParams.Create.&Type();
end;

function TFunctionToolParams.&Type(const Value: string): TFunctionToolParams;
begin
  Result := TFunctionToolParams(Add('type', Value));
end;

{ TComparisonFilter }

function TComparisonFilter.&Type(
  const Value: TComparisonFilterType): TComparisonFilter;
begin
  Result := TComparisonFilter(Add('type', Value.ToString));
end;

class function TComparisonFilter.New: TComparisonFilter;
begin
  Result := TComparisonFilter.Create;
end;

function TComparisonFilter.&Type(const Value: string): TComparisonFilter;
begin
  Result := TComparisonFilter(Add('type', TComparisonFilterType.Create(Value).ToString));
end;

function TComparisonFilter.Comparison(const Value: string): TComparisonFilter;
begin
  Result := TComparisonFilter(Add('type', TComparisonFilterType.ToOperator(Value).ToString));
end;

function TComparisonFilter.Key(const Value: string): TComparisonFilter;
begin
  Result := TComparisonFilter(Add('key', Value));
end;

class function TComparisonFilter.New(const Key, Comparison: string;
  const Value: Double): TComparisonFilter;
begin
  Result := New.Key(Key).Comparison(Comparison).Value(Value);
end;

class function TComparisonFilter.New(const Key, Comparison: string;
  const Value: Integer): TComparisonFilter;
begin
  Result := New.Key(Key).Comparison(Comparison).Value(Value);
end;

class function TComparisonFilter.New(const Key, Comparison,
  Value: string): TComparisonFilter;
begin
  Result := New.Key(Key).Comparison(Comparison).Value(Value);
end;

class function TComparisonFilter.New(const Key, Comparison: string;
  const Value: Boolean): TComparisonFilter;
begin
  Result := New.Key(Key).Comparison(Comparison).Value(Value);
end;

function TComparisonFilter.Value(const Value: string): TComparisonFilter;
begin
  Result := TComparisonFilter(Add('value', Value));
end;

function TComparisonFilter.Value(const Value: Integer): TComparisonFilter;
begin
  Result := TComparisonFilter(Add('value', Value));
end;

function TComparisonFilter.Value(const Value: Double): TComparisonFilter;
begin
  Result := TComparisonFilter(Add('value', Value));
end;

function TComparisonFilter.Value(const Value: Boolean): TComparisonFilter;
begin
  Result := TComparisonFilter(Add('value', Value));
end;

{ TCompoundFilter }

function TCompoundFilter.&And: TCompoundFilter;
begin
  Result := &Type(TCompoundFilterType.and);
end;

class function TCompoundFilter.&And(
  const Value: TArray<TFileSearchFilters>): TCompoundFilter;
begin
  Result := TCompoundFilter.New.&And.Filters(Value);
end;

function TCompoundFilter.Filters(
  const Value: TArray<TFileSearchFilters>): TCompoundFilter;
begin
  var JSONArray := TJSONArray.Create;
  for var Item in Value do
    JSONArray.Add(Item.Detach);
  Result := TCompoundFilter(Add('filters', JSONArray));
end;

class function TCompoundFilter.New: TCompoundFilter;
begin
  Result := TCompoundFilter.Create;
end;

function TCompoundFilter.&Or: TCompoundFilter;
begin
  Result := &Type(TCompoundFilterType.or);
end;

class function TCompoundFilter.&Or(
  const Value: TArray<TFileSearchFilters>): TCompoundFilter;
begin
  Result := TCompoundFilter.New.&Or.Filters(Value);
end;

function TCompoundFilter.&Type(
  const Value: TCompoundFilterType): TCompoundFilter;
begin
  Result := TCompoundFilter(Add('type', Value.ToString));
end;

{ TResponseFileSearchParams }

function TResponseFileSearchParams.Filters(
  const Value: TFileSearchFilters): TResponseFileSearchParams;
begin
  Result := TResponseFileSearchParams(Add('filters', Value.Detach));
end;

function TResponseFileSearchParams.Filters(
  const Value: string): TResponseFileSearchParams;
var
  JSONObject: TJSONObject;
begin
  if TJSONHelper.TryGetObject(Value, JSONObject) then
    Exit(TResponseFileSearchParams(Add('filters', JSONObject)));

  raise TGenAIAPIException.Create('Invalid JSON Object');
end;

function TResponseFileSearchParams.MaxNumResults(
  const Value: Integer): TResponseFileSearchParams;
begin
  Result := TResponseFileSearchParams(Add('max_num_results', Value));
end;

class function TResponseFileSearchParams.New: TResponseFileSearchParams;
begin
  Result := TResponseFileSearchParams.Create.&Type();
end;

function TResponseFileSearchParams.RankingOptions(
  const Value: string): TResponseFileSearchParams;
var
  JSONObject: TJSONObject;
begin
  if TJSONHelper.TryGetObject(Value, JSONObject) then
    Exit(TResponseFileSearchParams(Add('ranking_options', JSONObject)));

  raise TGenAIAPIException.Create('Invalid JSON Object');
end;

function TResponseFileSearchParams.RankingOptions(
  const Value: TRankingOptionsParams): TResponseFileSearchParams;
begin
  Result := TResponseFileSearchParams(Add('ranking_options', Value.Detach));
end;

function TResponseFileSearchParams.&Type(
  const Value: string): TResponseFileSearchParams;
begin
  Result := TResponseFileSearchParams(Add('type', Value));
end;

function TResponseFileSearchParams.VectorStoreIds(
  const Value: TArray<string>): TResponseFileSearchParams;
begin
  Result := TResponseFileSearchParams(Add('vector_store_ids', Value));
end;

{ TResponseFunctionParams }

function TResponseFunctionParams.&Type(
  const Value: string): TResponseFunctionParams;
begin
  Result := TResponseFunctionParams(Add('type', Value));
end;

function TResponseFunctionParams.Description(
  const Value: string): TResponseFunctionParams;
begin
  Result := TResponseFunctionParams(Add('description', Value));
end;

function TResponseFunctionParams.Name(
  const Value: string): TResponseFunctionParams;
begin
  Result := TResponseFunctionParams(Add('name', Value));
end;

class function TResponseFunctionParams.New(
  const Value: IFunctionCore): TResponseFunctionParams;
begin
  Result := New.Description(Value.Description).Name(Value.Name).Parameters(Value.Parameters).Strict(Value.&Strict);
end;

class function TResponseFunctionParams.New: TResponseFunctionParams;
begin
  Result := TResponseFunctionParams.Create.&Type();
end;

function TResponseFunctionParams.Parameters(
  const Value: string): TResponseFunctionParams;
var
  JSONObject: TJSONObject;
begin
  if TJSONHelper.TryGetObject(Value, JSONObject) then
    Exit(TResponseFunctionParams(Add('parameters', JSONObject)));

  raise TGenAIAPIException.Create('Invalid JSON Object');
end;

function TResponseFunctionParams.Parameters(
  const Value: TSchemaParams): TResponseFunctionParams;
begin
  Result := TResponseFunctionParams(Add('parameters', Value.Detach));
end;

function TResponseFunctionParams.Strict(
  const Value: Boolean): TResponseFunctionParams;
begin
  Result := TResponseFunctionParams(Add('strict', Value));
end;

function TResponseFunctionParams.DeferLoading(
  const Value: Boolean): TResponseFunctionParams;
begin
  Result := TResponseFunctionParams(Add('defer_loading', Value));
end;

{ TResponseComputerUseParams }

function TResponseComputerUseParams.&Type(
  const Value: string): TResponseComputerUseParams;
begin
  Result := TResponseComputerUseParams(Add('type', Value));
end;

function TResponseComputerUseParams.DisplayHeight(
  const Value: Integer): TResponseComputerUseParams;
begin
  Result := TResponseComputerUseParams(Add('display_height', Value));
end;

function TResponseComputerUseParams.DisplayWidth(
  const Value: Integer): TResponseComputerUseParams;
begin
  Result := TResponseComputerUseParams(Add('display_width', Value));
end;

function TResponseComputerUseParams.Environment(
  const Value: string): TResponseComputerUseParams;
begin
  Result := TResponseComputerUseParams(Add('environment', Value));
end;

class function TResponseComputerUseParams.New: TResponseComputerUseParams;
begin
  Result := TResponseComputerUseParams.Create.&Type();
end;

{ TResponseUserLocationParams }

function TResponseUserLocationParams.City(
  const Value: string): TResponseUserLocationParams;
begin
  Result := TResponseUserLocationParams(Add('city', Value));
end;

function TResponseUserLocationParams.Country(
  const Value: string): TResponseUserLocationParams;
begin
  Result := TResponseUserLocationParams(Add('country', Value));
end;

class function TResponseUserLocationParams.New: TResponseUserLocationParams;
begin
  Result := TResponseUserLocationParams.Create.&Type();
end;

function TResponseUserLocationParams.Region(
  const Value: string): TResponseUserLocationParams;
begin
  Result := TResponseUserLocationParams(Add('region', Value));
end;

function TResponseUserLocationParams.Timezone(
  const Value: string): TResponseUserLocationParams;
begin
  Result := TResponseUserLocationParams(Add('timezone', Value));
end;

function TResponseUserLocationParams.&Type(
  const Value: string): TResponseUserLocationParams;
begin
  Result := TResponseUserLocationParams(Add('type', Value));
end;

{ TResponseWebSearchParams }

function TResponseWebSearchParams.&Type(
  const Value: TWebSearchType): TResponseWebSearchParams;
begin
  Result := TResponseWebSearchParams(Add('type', Value.ToString));
end;

function TResponseWebSearchParams.&Type(
  const Value: string): TResponseWebSearchParams;
begin
  Result := TResponseWebSearchParams(Add('type', TWebSearchType.Create(Value).ToString));
end;

function TResponseWebSearchParams.UserLocation(
  const Value: string): TResponseWebSearchParams;
var
  JSONObject: TJSONObject;
begin
  if TJSONHelper.TryGetObject(Value, JSONObject) then
    Exit(TResponseWebSearchParams(Add('user_location', JSONObject)));

  raise TGenAIAPIException.Create('Invalid JSON Object');
end;

function TResponseWebSearchParams.UserLocation(
  const Value: TResponseUserLocationParams): TResponseWebSearchParams;
begin
  Result := TResponseWebSearchParams(Add('user_location', Value.Detach));
end;

function TResponseWebSearchParams.SearchContextSize(
  const Value: TSearchWebOptions): TResponseWebSearchParams;
begin
  Result := TResponseWebSearchParams(Add('search_context_size', Value.ToString));
end;

function TResponseWebSearchParams.Filters(
  const Value: string): TResponseWebSearchParams;
var
  JSONObject: TJSONObject;
begin
  if TJSONHelper.TryGetObject(Value, JSONObject) then
    Exit(TResponseWebSearchParams(Add('filters', JSONObject)));

  raise TGenAIAPIException.Create('Invalid JSON Object');
end;

function TResponseWebSearchParams.Filters(
  const Value: TWebSearchFiltersParams): TResponseWebSearchParams;
begin
  Result := TResponseWebSearchParams(Add('filters', Value.Detach));
end;

class function TResponseWebSearchParams.New: TResponseWebSearchParams;
begin
  Result := TResponseWebSearchParams.Create.&Type();
end;

function TResponseWebSearchParams.SearchContextSize(
  const Value: string): TResponseWebSearchParams;
begin
  Result := TResponseWebSearchParams(Add('search_context_size', TSearchWebOptions.Create(Value).ToString));
end;

{ TMCPToolsListParams }

function TMCPToolsListParams.ToolNames(const Value: TArray<string>): TMCPToolsListParams;
begin
  Result := TMCPToolsListParams(Add('tool_names', Value));
end;

{ TMCPAllowedToolsParams }

function TMCPAllowedToolsParams.ToolNames(
  const Value: TArray<string>): TMCPAllowedToolsParams;
begin
  Result := TMCPAllowedToolsParams(Add('tool_names', Value));
end;

function TMCPAllowedToolsParams.ReadOnly(
  const Value: Boolean): TMCPAllowedToolsParams;
begin
  Result := TMCPAllowedToolsParams(Add('read_only', Value));
end;

{ TMCPRequireApprovalParams }

function TMCPRequireApprovalParams.Always(
  const Value: TArray<string>): TMCPRequireApprovalParams;
begin
  Result := TMCPRequireApprovalParams(Add('always', TMCPToolsListParams.Create.ToolNames(Value).Detach));
end;

function TMCPRequireApprovalParams.Never(
  const Value: TArray<string>): TMCPRequireApprovalParams;
begin
  Result := TMCPRequireApprovalParams(Add('never', TMCPToolsListParams.Create.ToolNames(Value).Detach));
end;

class function TMCPRequireApprovalParams.New: TMCPRequireApprovalParams;
begin
  Result := TMCPRequireApprovalParams.Create;
end;

{ TResponseMCPToolParams }

function TResponseMCPToolParams.&Type(
  const Value: string): TResponseMCPToolParams;
begin
  Result := TResponseMCPToolParams(Add('type', Value));
end;

function TResponseMCPToolParams.AllowedTools(
  const Value: TMCPAllowedToolsParams): TResponseMCPToolParams;
begin
  Result := TResponseMCPToolParams(Add('allowed_tools', Value.Detach));
end;

function TResponseMCPToolParams.AllowedTools(
  const Value: TArray<TMCPAllowedToolsParams>): TResponseMCPToolParams;
begin
  var JSONArray := TJSONArray.Create;
  for var Item in Value do
    JSONArray.Add(Item.Detach);
  Result := TResponseMCPToolParams(Add('allowed_tools', JSONArray));
end;

function TResponseMCPToolParams.AllowedTools(
  const Value: TArray<string>): TResponseMCPToolParams;
begin
  Result := TResponseMCPToolParams(Add('allowed_tools', Value));
end;

function TResponseMCPToolParams.Headers(
  const Value: TJSONObject): TResponseMCPToolParams;
begin
  Result := TResponseMCPToolParams(Add('headers', Value));
end;

function TResponseMCPToolParams.Headers(
  const Value: string): TResponseMCPToolParams;
var
  JSONObject: TJSONObject;
begin
  if TJSONHelper.TryGetObject(Value, JSONObject) then
    Exit(TResponseMCPToolParams(Add('headers', JSONObject)));

  raise TGenAIAPIException.Create('Invalid JSON Object');
end;

class function TResponseMCPToolParams.New: TResponseMCPToolParams;
begin
  Result := TResponseMCPToolParams.Create.&Type();
end;

function TResponseMCPToolParams.RequireApproval(
  const Value: string): TResponseMCPToolParams;
begin
  Result := TResponseMCPToolParams(Add('require_approval', Value));
end;

function TResponseMCPToolParams.RequireApproval(
  const Value: TMCPRequireApprovalParams): TResponseMCPToolParams;
begin
  Result := TResponseMCPToolParams(Add('require_approval', Value.Detach));
end;

function TResponseMCPToolParams.ServerDescription(
  const Value: string): TResponseMCPToolParams;
begin
  Result := TResponseMCPToolParams(Add('server_description', Value));
end;

function TResponseMCPToolParams.ServerLabel(
  const Value: string): TResponseMCPToolParams;
begin
  Result := TResponseMCPToolParams(Add('server_label', Value));
end;

function TResponseMCPToolParams.ServerUrl(
  const Value: string): TResponseMCPToolParams;
begin
  Result := TResponseMCPToolParams(Add('server_url', Value));
end;

function TResponseMCPToolParams.Authorization(
  const Value: string): TResponseMCPToolParams;
begin
  Result := TResponseMCPToolParams(Add('authorization', Value));
end;

function TResponseMCPToolParams.ConnectorId(
  const Value: TMCPConnectorType): TResponseMCPToolParams;
begin
  Result := TResponseMCPToolParams(Add('connector_id', Value.ToString));
end;

function TResponseMCPToolParams.ConnectorId(
  const Value: string): TResponseMCPToolParams;
begin
  Result := TResponseMCPToolParams(Add('connector_id', TMCPConnectorType.Create(Value).ToString));
end;

function TResponseMCPToolParams.DeferLoading(
  const Value: Boolean): TResponseMCPToolParams;
begin
  Result := TResponseMCPToolParams(Add('defer_loading', Value));
end;

{ TCodeInterpreterContainerAutoParams }

function TCodeInterpreterContainerAutoParams.FileIds(
  const Value: TArray<string>): TCodeInterpreterContainerAutoParams;
begin
  Result := TCodeInterpreterContainerAutoParams(Add('file_ids', Value));
end;

class function TCodeInterpreterContainerAutoParams.New(
  const Value: TArray<string>): TCodeInterpreterContainerAutoParams;
begin
  Result := TCodeInterpreterContainerAutoParams.Create.&Type();
end;

function TCodeInterpreterContainerAutoParams.&Type(
  const Value: string): TCodeInterpreterContainerAutoParams;
begin
  Result := TCodeInterpreterContainerAutoParams(Add('type', Value));
end;

{ TResponseCodeInterpreterParams }

function TResponseCodeInterpreterParams.Container(
  const Value: string): TResponseCodeInterpreterParams;
var
  JSONObject: TJSONObject;
begin
  if TJSONHelper.TryGetObject(Value, JSONObject) then
    Exit(TResponseCodeInterpreterParams(Add('container', JSONObject)));

  raise TGenAIAPIException.Create('Invalid JSON Object');
end;

function TResponseCodeInterpreterParams.Container(
  const Value: TCodeInterpreterContainerAutoParams): TResponseCodeInterpreterParams;
begin
  Result := TResponseCodeInterpreterParams(Add('container', Value.Detach));
end;

function TResponseCodeInterpreterParams.&Type(
  const Value: string): TResponseCodeInterpreterParams;
begin
  Result := TResponseCodeInterpreterParams(Add('type', Value));
end;

class function TResponseCodeInterpreterParams.New: TResponseCodeInterpreterParams;
begin
  Result := TResponseCodeInterpreterParams.Create.&Type();
end;

{ TLocalShellToolParams }

class function TLocalShellToolParams.New: TLocalShellToolParams;
begin
  Result := TLocalShellToolParams.Create.&Type();
end;

function TLocalShellToolParams.&Type(
  const Value: string): TLocalShellToolParams;
begin
  Result := TLocalShellToolParams(Add('type', Value));
end;

{ TShellCallActionParams }

function TShellCallActionParams.Commands(
  const Value: TArray<string>): TShellCallActionParams;
begin
  Result := TShellCallActionParams(Add('commands', Value));
end;

function TShellCallActionParams.MaxOutputLength(
  const Value: Int64): TShellCallActionParams;
begin
  Result := TShellCallActionParams(Add('max_output_length', Value));
end;

class function TShellCallActionParams.New: TShellCallActionParams;
begin
  Result := TShellCallActionParams.Create;
end;

function TShellCallActionParams.TimeoutMs(
  const Value: Int64): TShellCallActionParams;
begin
  Result := TShellCallActionParams(Add('timeout_ms', Value));
end;

{ TShellCallParams }

function TShellCallParams.Action(
  const Value: TShellCallActionParams): TShellCallParams;
begin
  Result := TShellCallParams(Add('action', Value.Detach));
end;

function TShellCallParams.Action(const Value: string): TShellCallParams;
var
  JSONObject: TJSONObject;
begin
  if TJSONHelper.TryGetObject(Value, JSONObject) then
    Exit(TShellCallParams(Add('action', JSONObject)));

  raise TGenAIAPIException.Create('Invalid JSON Object');
end;

function TShellCallParams.CallId(const Value: string): TShellCallParams;
begin
  Result := TShellCallParams(Add('call_id', Value));
end;

function TShellCallParams.CreatedBy(const Value: string): TShellCallParams;
begin
  Result := TShellCallParams(Add('created_by', Value));
end;

function TShellCallParams.Id(const Value: string): TShellCallParams;
begin
  Result := TShellCallParams(Add('id', Value));
end;

class function TShellCallParams.New: TShellCallParams;
begin
  Result := TShellCallParams.Create.&Type();
end;

function TShellCallParams.Status(
  const Value: TMessageStatus): TShellCallParams;
begin
  Result := TShellCallParams(Add('status', Value.ToString));
end;

function TShellCallParams.Status(const Value: string): TShellCallParams;
begin
  Result := Status(TMessageStatus.Create(Value));
end;

function TShellCallParams.&Type(const Value: string): TShellCallParams;
begin
  Result := TShellCallParams(Add('type', Value));
end;

{ TApplyPatchOperationParams }

function TApplyPatchOperationParams.Diff(
  const Value: string): TApplyPatchOperationParams;
begin
  Result := TApplyPatchOperationParams(Add('diff', Value));
end;

class function TApplyPatchOperationParams.New: TApplyPatchOperationParams;
begin
  Result := TApplyPatchOperationParams.Create;
end;

function TApplyPatchOperationParams.Path(
  const Value: string): TApplyPatchOperationParams;
begin
  Result := TApplyPatchOperationParams(Add('path', Value));
end;

function TApplyPatchOperationParams.&Type(
  const Value: string): TApplyPatchOperationParams;
begin
  Result := TApplyPatchOperationParams(Add('type', Value));
end;

{ TApplyPatchCallParams }

function TApplyPatchCallParams.CallId(
  const Value: string): TApplyPatchCallParams;
begin
  Result := TApplyPatchCallParams(Add('call_id', Value));
end;

function TApplyPatchCallParams.CreatedBy(
  const Value: string): TApplyPatchCallParams;
begin
  Result := TApplyPatchCallParams(Add('created_by', Value));
end;

function TApplyPatchCallParams.Id(
  const Value: string): TApplyPatchCallParams;
begin
  Result := TApplyPatchCallParams(Add('id', Value));
end;

class function TApplyPatchCallParams.New: TApplyPatchCallParams;
begin
  Result := TApplyPatchCallParams.Create.&Type();
end;

function TApplyPatchCallParams.Operation(
  const Value: TApplyPatchOperationParams): TApplyPatchCallParams;
begin
  Result := TApplyPatchCallParams(Add('operation', Value.Detach));
end;

function TApplyPatchCallParams.Operation(
  const Value: string): TApplyPatchCallParams;
var
  JSONObject: TJSONObject;
begin
  if TJSONHelper.TryGetObject(Value, JSONObject) then
    Exit(TApplyPatchCallParams(Add('operation', JSONObject)));

  raise TGenAIAPIException.Create('Invalid JSON Object');
end;

function TApplyPatchCallParams.Status(
  const Value: TMessageStatus): TApplyPatchCallParams;
begin
  Result := TApplyPatchCallParams(Add('status', Value.ToString));
end;

function TApplyPatchCallParams.Status(
  const Value: string): TApplyPatchCallParams;
begin
  Result := Status(TMessageStatus.Create(Value));
end;

function TApplyPatchCallParams.&Type(
  const Value: string): TApplyPatchCallParams;
begin
  Result := TApplyPatchCallParams(Add('type', Value));
end;

{ TToolSearchCallParams }

function TToolSearchCallParams.Arguments(
  const Value: TJSONObject): TToolSearchCallParams;
begin
  Result := TToolSearchCallParams(Add('arguments', Value));
end;

function TToolSearchCallParams.Arguments(
  const Value: string): TToolSearchCallParams;
var
  JSONObject: TJSONObject;
begin
  if TJSONHelper.TryGetObject(Value, JSONObject) then
    Exit(TToolSearchCallParams(Add('arguments', JSONObject)));

  raise TGenAIAPIException.Create('Invalid JSON Object');
end;

function TToolSearchCallParams.CallId(
  const Value: string): TToolSearchCallParams;
begin
  Result := TToolSearchCallParams(Add('call_id', Value));
end;

function TToolSearchCallParams.CallIdNull: TToolSearchCallParams;
begin
  Result := TToolSearchCallParams(Add('call_id', TJSONNull.Create));
end;

function TToolSearchCallParams.CreatedBy(
  const Value: string): TToolSearchCallParams;
begin
  Result := TToolSearchCallParams(Add('created_by', Value));
end;

function TToolSearchCallParams.Execution(
  const Value: TToolSearchExecution): TToolSearchCallParams;
begin
  Result := TToolSearchCallParams(Add('execution', Value.ToString));
end;

function TToolSearchCallParams.Execution(
  const Value: string): TToolSearchCallParams;
begin
  Result := Execution(TToolSearchExecution.Create(Value));
end;

function TToolSearchCallParams.Id(
  const Value: string): TToolSearchCallParams;
begin
  Result := TToolSearchCallParams(Add('id', Value));
end;

class function TToolSearchCallParams.New: TToolSearchCallParams;
begin
  Result := TToolSearchCallParams.Create.&Type();
end;

function TToolSearchCallParams.Status(
  const Value: TMessageStatus): TToolSearchCallParams;
begin
  Result := TToolSearchCallParams(Add('status', Value.ToString));
end;

function TToolSearchCallParams.Status(
  const Value: string): TToolSearchCallParams;
begin
  Result := Status(TMessageStatus.Create(Value));
end;

function TToolSearchCallParams.&Type(
  const Value: string): TToolSearchCallParams;
begin
  Result := TToolSearchCallParams(Add('type', Value));
end;

{ TCompactionItemParams }

function TCompactionItemParams.CreatedBy(
  const Value: string): TCompactionItemParams;
begin
  Result := TCompactionItemParams(Add('created_by', Value));
end;

function TCompactionItemParams.EncryptedContent(
  const Value: string): TCompactionItemParams;
begin
  Result := TCompactionItemParams(Add('encrypted_content', Value));
end;

function TCompactionItemParams.Id(const Value: string): TCompactionItemParams;
begin
  Result := TCompactionItemParams(Add('id', Value));
end;

class function TCompactionItemParams.New: TCompactionItemParams;
begin
  Result := TCompactionItemParams.Create.&Type();
end;

function TCompactionItemParams.&Type(
  const Value: string): TCompactionItemParams;
begin
  Result := TCompactionItemParams(Add('type', Value));
end;

{ TShellCallOutputOutcomeParams }

function TShellCallOutputOutcomeParams.ExitCode(
  const Value: Int64): TShellCallOutputOutcomeParams;
begin
  Result := TShellCallOutputOutcomeParams(Add('exit_code', Value));
end;

class function TShellCallOutputOutcomeParams.NewExit(
  const ExitCode: Int64): TShellCallOutputOutcomeParams;
begin
  Result := TShellCallOutputOutcomeParams.Create.&Type('exit').ExitCode(ExitCode);
end;

class function TShellCallOutputOutcomeParams.NewTimeout: TShellCallOutputOutcomeParams;
begin
  Result := TShellCallOutputOutcomeParams.Create.&Type('timeout');
end;

function TShellCallOutputOutcomeParams.&Type(
  const Value: string): TShellCallOutputOutcomeParams;
begin
  Result := TShellCallOutputOutcomeParams(Add('type', Value));
end;

{ TShellCallOutputContentParams }

function TShellCallOutputContentParams.CreatedBy(
  const Value: string): TShellCallOutputContentParams;
begin
  Result := TShellCallOutputContentParams(Add('created_by', Value));
end;

class function TShellCallOutputContentParams.New: TShellCallOutputContentParams;
begin
  Result := TShellCallOutputContentParams.Create;
end;

function TShellCallOutputContentParams.Outcome(
  const Value: TShellCallOutputOutcomeParams): TShellCallOutputContentParams;
begin
  Result := TShellCallOutputContentParams(Add('outcome', Value.Detach));
end;

function TShellCallOutputContentParams.Stderr(
  const Value: string): TShellCallOutputContentParams;
begin
  Result := TShellCallOutputContentParams(Add('stderr', Value));
end;

function TShellCallOutputContentParams.Stdout(
  const Value: string): TShellCallOutputContentParams;
begin
  Result := TShellCallOutputContentParams(Add('stdout', Value));
end;

{ TShellCallOutputParams }

function TShellCallOutputParams.CallId(
  const Value: string): TShellCallOutputParams;
begin
  Result := TShellCallOutputParams(Add('call_id', Value));
end;

function TShellCallOutputParams.CreatedBy(
  const Value: string): TShellCallOutputParams;
begin
  Result := TShellCallOutputParams(Add('created_by', Value));
end;

function TShellCallOutputParams.Id(const Value: string): TShellCallOutputParams;
begin
  Result := TShellCallOutputParams(Add('id', Value));
end;

function TShellCallOutputParams.MaxOutputLength(
  const Value: Int64): TShellCallOutputParams;
begin
  Result := TShellCallOutputParams(Add('max_output_length', Value));
end;

class function TShellCallOutputParams.New: TShellCallOutputParams;
begin
  Result := TShellCallOutputParams.Create.&Type();
end;

function TShellCallOutputParams.Output(
  const Value: TArray<TShellCallOutputContentParams>): TShellCallOutputParams;
begin
  var JSONArray := TJSONArray.Create;
  for var Item in Value do
    JSONArray.Add(Item.Detach);
  Result := TShellCallOutputParams(Add('output', JSONArray));
end;

function TShellCallOutputParams.Output(
  const Value: TJSONArray): TShellCallOutputParams;
begin
  Result := TShellCallOutputParams(Add('output', Value));
end;

function TShellCallOutputParams.Output(
  const Value: string): TShellCallOutputParams;
var
  JSONArray: TJSONArray;
begin
  if TJSONHelper.TryGetArray(Value, JSONArray) then
    Exit(TShellCallOutputParams(Add('output', JSONArray)));

  raise TGenAIAPIException.Create('Invalid JSON Array');
end;

function TShellCallOutputParams.Status(
  const Value: string): TShellCallOutputParams;
begin
  Result := TShellCallOutputParams(Add('status', Value));
end;

function TShellCallOutputParams.&Type(
  const Value: string): TShellCallOutputParams;
begin
  Result := TShellCallOutputParams(Add('type', Value));
end;

{ TApplyPatchCallOutputParams }

function TApplyPatchCallOutputParams.CallId(
  const Value: string): TApplyPatchCallOutputParams;
begin
  Result := TApplyPatchCallOutputParams(Add('call_id', Value));
end;

function TApplyPatchCallOutputParams.CreatedBy(
  const Value: string): TApplyPatchCallOutputParams;
begin
  Result := TApplyPatchCallOutputParams(Add('created_by', Value));
end;

function TApplyPatchCallOutputParams.Id(
  const Value: string): TApplyPatchCallOutputParams;
begin
  Result := TApplyPatchCallOutputParams(Add('id', Value));
end;

class function TApplyPatchCallOutputParams.New: TApplyPatchCallOutputParams;
begin
  Result := TApplyPatchCallOutputParams.Create.&Type();
end;

function TApplyPatchCallOutputParams.Output(
  const Value: string): TApplyPatchCallOutputParams;
begin
  Result := TApplyPatchCallOutputParams(Add('output', Value));
end;

function TApplyPatchCallOutputParams.Status(
  const Value: string): TApplyPatchCallOutputParams;
begin
  Result := TApplyPatchCallOutputParams(Add('status', Value));
end;

function TApplyPatchCallOutputParams.&Type(
  const Value: string): TApplyPatchCallOutputParams;
begin
  Result := TApplyPatchCallOutputParams(Add('type', Value));
end;

{ TToolSearchOutputParams }

function TToolSearchOutputParams.CallId(
  const Value: string): TToolSearchOutputParams;
begin
  Result := TToolSearchOutputParams(Add('call_id', Value));
end;

function TToolSearchOutputParams.CallIdNull: TToolSearchOutputParams;
begin
  Result := TToolSearchOutputParams(Add('call_id', TJSONNull.Create));
end;

function TToolSearchOutputParams.CreatedBy(
  const Value: string): TToolSearchOutputParams;
begin
  Result := TToolSearchOutputParams(Add('created_by', Value));
end;

function TToolSearchOutputParams.Execution(
  const Value: TToolSearchExecution): TToolSearchOutputParams;
begin
  Result := TToolSearchOutputParams(Add('execution', Value.ToString));
end;

function TToolSearchOutputParams.Execution(
  const Value: string): TToolSearchOutputParams;
begin
  Result := Execution(TToolSearchExecution.Create(Value));
end;

function TToolSearchOutputParams.Id(
  const Value: string): TToolSearchOutputParams;
begin
  Result := TToolSearchOutputParams(Add('id', Value));
end;

class function TToolSearchOutputParams.New: TToolSearchOutputParams;
begin
  Result := TToolSearchOutputParams.Create.&Type();
end;

function TToolSearchOutputParams.Status(
  const Value: string): TToolSearchOutputParams;
begin
  Result := TToolSearchOutputParams(Add('status', Value));
end;

function TToolSearchOutputParams.Tools(
  const Value: TArray<TResponseToolParams>): TToolSearchOutputParams;
begin
  var JSONArray := TJSONArray.Create;
  for var Item in Value do
    JSONArray.Add(Item.Detach);
  Result := TToolSearchOutputParams(Add('tools', JSONArray));
end;

function TToolSearchOutputParams.Tools(
  const Value: TJSONArray): TToolSearchOutputParams;
begin
  Result := TToolSearchOutputParams(Add('tools', Value));
end;

function TToolSearchOutputParams.Tools(
  const Value: string): TToolSearchOutputParams;
var
  JSONArray: TJSONArray;
begin
  if TJSONHelper.TryGetArray(Value, JSONArray) then
    Exit(TToolSearchOutputParams(Add('tools', JSONArray)));

  raise TGenAIAPIException.Create('Invalid JSON Array');
end;

function TToolSearchOutputParams.&Type(
  const Value: string): TToolSearchOutputParams;
begin
  Result := TToolSearchOutputParams(Add('type', Value));
end;

{ TResponseCompactParams }

function TResponseCompactParams.Input(
  const Value: TArray<TInputListItem>): TResponseCompactParams;
begin
  var JSONArray := TJSONArray.Create;
  for var Item in Value do
    JSONArray.Add(Item.Detach);
  Result := TResponseCompactParams(Add('input', JSONArray));
end;

function TResponseCompactParams.Input(
  const Value: TJSONArray): TResponseCompactParams;
begin
  Result := TResponseCompactParams(Add('input', Value));
end;

function TResponseCompactParams.Input(
  const Value: string): TResponseCompactParams;
var
  JSONArray: TJSONArray;
begin
  if TJSONHelper.TryGetArray(Value, JSONArray) then
    Exit(TResponseCompactParams(Add('input', JSONArray)));

  Result := TResponseCompactParams(Add('input', Value));
end;

function TResponseCompactParams.Instructions(
  const Value: string): TResponseCompactParams;
begin
  Result := TResponseCompactParams(Add('instructions', Value));
end;

function TResponseCompactParams.Model(
  const Value: string): TResponseCompactParams;
begin
  Result := TResponseCompactParams(Add('model', Value));
end;

function TResponseCompactParams.PreviousResponseId(
  const Value: string): TResponseCompactParams;
begin
  Result := TResponseCompactParams(Add('previous_response_id', Value));
end;

function TResponseCompactParams.PromptCacheKey(
  const Value: string): TResponseCompactParams;
begin
  Result := TResponseCompactParams(Add('prompt_cache_key', Value));
end;

function TResponseCompactParams.PromptCacheRetention(
  const Value: TPromptCacheRetention): TResponseCompactParams;
begin
  Result := TResponseCompactParams(Add('prompt_cache_retention', Value.ToString));
end;

function TResponseCompactParams.PromptCacheRetention(
  const Value: string): TResponseCompactParams;
begin
  Result := PromptCacheRetention(TPromptCacheRetention.Create(Value));
end;

function TResponseCompactParams.ServiceTier(
  const Value: TServiceTier): TResponseCompactParams;
begin
  Result := TResponseCompactParams(Add('service_tier', Value.ToString));
end;

function TResponseCompactParams.ServiceTier(
  const Value: string): TResponseCompactParams;
begin
  Result := ServiceTier(TServiceTier.Create(Value));
end;

{ TResponsesParams }

function TResponsesParams.Include(
  const Value: TArray<TOutputIncluding>): TResponsesParams;
begin
  var JSONArray := TJSONArray.Create;
  for var Item in Value do
    JSONArray.Add(Item.ToString);
  Result := TResponsesParams(Add('include', JSONArray));
end;

function TResponsesParams.Background(const Value: Boolean): TResponsesParams;
begin
  Result := TResponsesParams(Add('background', Value));
end;

function TResponsesParams.Conversation(const Value: string): TResponsesParams;
begin
  Result := TResponsesParams(Add('conversation', Value));
end;

function TResponsesParams.Conversation(
  const Value: TConversationParams): TResponsesParams;
begin
  Result := TResponsesParams(Add('conversation', Value.Detach));
end;

function TResponsesParams.Include(
  const Value: TArray<string>): TResponsesParams;
begin
  var JSONArray := TJSONArray.Create;
  for var Item in Value do
    JSONArray.Add(TOutputIncluding.Create(Item).ToString);
  Result := TResponsesParams(Add('include', JSONArray));
end;

function TResponsesParams.Input(const Content: string;
  const Docs: TArray<string>; const Role: string): TResponsesParams;
var
  MimeType: string;
begin
  {--- Create an array with content (text and image documents }
  var JSONArray := TJSONArray.Create;
  JSONArray.Add(TItemContent.NewText.Text(Content).Detach);
  for var Item in Docs do
    begin
      MimeType := TFormatHelper.GetMimeType(Item);
      if TFormatHelper.IsPDFDocument(MimeType) then
          JSONArray.Add(TItemContent.NewFileData(Item).Detach)
      else
      if TFormatHelper.IsImageDocument(MimeType) then
        JSONArray.Add(TItemContent.NewImage(Item).Detach)
      else
      if MimeType = TFormatHelper.S_FILEID then
        JSONArray.Add(TItemContent.NewFile.FileId(Item).Detach)
      else
        raise Exception.CreateFmt('%s : Mime type not supported', [MimeType]);
    end;

  {--- Create the input message }
  var InputMessage := TJSONArray.Create.Add(TInputMessage.Create.Role(Role).Content(JSONArray).Detach);

  Result := TResponsesParams(Add('input', InputMessage));
end;

function TResponsesParams.Input(const Value: TJSONArray): TResponsesParams;
begin
  Result := TResponsesParams(Add('input', Value));
end;

function TResponsesParams.Input(const Value: TArray<TInputListItem>): TResponsesParams;
begin
  var JSONArray := TJSONArray.Create;
  for var Item in Value do
    JSONArray.Add(Item.Detach);
  Result := TResponsesParams(Add('input', JSONArray));
end;

function TResponsesParams.Input(const Value: string): TResponsesParams;
var
  JSONArray: TJSONArray;
begin
  {--- If the string is a JSON array, treat it as a structured input list;
       otherwise send it as a plain text prompt. }
  if TJSONHelper.TryGetArray(Value, JSONArray) then
    Exit(TResponsesParams(Add('input', JSONArray)));

  Result := TResponsesParams(Add('input', Value));
end;

function TResponsesParams.Instructions(const Value: string): TResponsesParams;
begin
  Result := TResponsesParams(Add('instructions', Value));
end;

function TResponsesParams.MaxOutputTokens(
  const Value: Integer): TResponsesParams;
begin
  Result := TResponsesParams(Add('max_output_tokens', Value));
end;

function TResponsesParams.MaxToolCalls(const Value: Integer): TResponsesParams;
begin
  Result := TResponsesParams(Add('max_tool_calls', Value));
end;

function TResponsesParams.Metadata(const Value: TJSONObject): TResponsesParams;
begin
  Result := TResponsesParams(Add('metadata', Value));
end;

function TResponsesParams.Model(const Value: string): TResponsesParams;
begin
  Result := TResponsesParams(Add('model', Value));
end;

function TResponsesParams.ParallelToolCalls(
  const Value: Boolean): TResponsesParams;
begin
  Result := TResponsesParams(Add('parallel_tool_calls', Value));
end;

function TResponsesParams.PreviousResponseId(
  const Value: string): TResponsesParams;
begin
  Result := TResponsesParams(Add('previous_response_id', Value));
end;

function TResponsesParams.Prompt(const Value: TPromptParams): TResponsesParams;
begin
  Result := TResponsesParams(Add('prompt', Value.Detach));
end;

function TResponsesParams.PromptCacheKey(const Value: string): TResponsesParams;
begin
  Result := TResponsesParams(Add('prompt_cache_key', Value));
end;

function TResponsesParams.Reasoning(const Value: TReasoningParams): TResponsesParams;
begin
  Result := TResponsesParams(Add('reasoning', Value.Detach));
end;

function TResponsesParams.Reasoning(const Value: string): TResponsesParams;
begin
  Result := TResponsesParams(Add('reasoning', TReasoningParams.New.Effort(Value).Detach));
end;

function TResponsesParams.SafetyIdentifier(
  const Value: string): TResponsesParams;
begin
  Result := TResponsesParams(Add('safety_identifier', Value));
end;

function TResponsesParams.ServiceTier(const Value: string): TResponsesParams;
begin
  Result := TResponsesParams(Add('service_tier', Value));
end;

function TResponsesParams.Store(const Value: Boolean): TResponsesParams;
begin
  Result := TResponsesParams(Add('store', Value));
end;

function TResponsesParams.Stream(const Value: Boolean): TResponsesParams;
begin
  Result := TResponsesParams(Add('stream', Value));
end;

function TResponsesParams.StreamOptions(
  const Value: TStreamOptions): TResponsesParams;
begin
   Result := TResponsesParams(Add('stream_options', Value.Detach));
end;

function TResponsesParams.Temperature(const Value: Double): TResponsesParams;
begin
  Result := TResponsesParams(Add('temperature', Value));
end;

function TResponsesParams.Text(const Value: TResponseOption;
  const SchemaParams: TTextJSONSchemaParams): TResponsesParams;
begin
  Result := Text(Value.ToString, SchemaParams);
end;

function TResponsesParams.ToolChoice(const Value: string): TResponsesParams;
begin
  Result := TResponsesParams(Add('tool_choice', TToolChoice.Create(Value).ToString));
end;

function TResponsesParams.ToolChoice(
  const Value: TToolChoice): TResponsesParams;
begin
  Result := TResponsesParams(Add('tool_choice', Value.ToString));
end;

function TResponsesParams.ToolChoice(
  const Value: TResponseToolChoiceParams): TResponsesParams;
begin
  Result := TResponsesParams(Add('tool_choice', Value.Detach));
end;

function TResponsesParams.Tools(
  const Value: TArray<TResponseToolParams>): TResponsesParams;
begin
  var JSONArray := TJSONArray.Create;
  for var Item in Value do
    JSONArray.Add(Item.Detach);
  Result := TResponsesParams(Add('tools', JSONArray));
end;

function TResponsesParams.Tools(const Value: string): TResponsesParams;
var
  JSONArray: TJSONArray;
begin
  {--- The tools parameter is always a JSON array: parse the string as such,
       otherwise reject it. }
  if TJSONHelper.TryGetArray(Value, JSONArray) then
    Exit(TResponsesParams(Add('tools', JSONArray)));

  raise TGenAIAPIException.Create('Invalid JSON Array');
end;

function TResponsesParams.TopLogprobs(const Value: Integer): TResponsesParams;
begin
  Result := TResponsesParams(Add('top_logprobs', Value));
end;

function TResponsesParams.TopP(const Value: Double): TResponsesParams;
begin
  Result := TResponsesParams(Add('top_p', Value));
end;

function TResponsesParams.Truncation(const Value: string): TResponsesParams;
begin
  Result := TResponsesParams(Add('truncation', TResponseTruncationType.Create(Value).ToString));
end;

function TResponsesParams.User(const Value: string): TResponsesParams;
begin
  Result := TResponsesParams(Add('user', Value));
end;

function TResponsesParams.Truncation(
  const Value: TResponseTruncationType): TResponsesParams;
begin
  Result := TResponsesParams(Add('truncation', Value.ToString));
end;

function TResponsesParams.Text(const Value: string;
  const SchemaParams: TTextJSONSchemaParams): TResponsesParams;
begin
  case TResponseOption.Create(Value) of
    TResponseOption.text:
      begin
        Result := Text(TTextFormatTextPrams.New);
        if Assigned(SchemaParams) then
          SchemaParams.Free;
      end;
    TResponseOption.json_object:
      begin
        Result := Text(TTextJSONObjectParams.New);
        if Assigned(SchemaParams) then
          SchemaParams.Free;
      end
    else
      begin
        if not Assigned(SchemaParams) then
          raise Exception.Create('Text options: Schema not defined.');
        Result := Text(SchemaParams);
      end;
  end;
end;

function TResponsesParams.Text(
  const Value: TTextFormatParams): TResponsesParams;
begin
  if Assigned(Value) then
    Result := Text(TTextParams.Create.Format(Value)) else
    Result := Self;
end;

function TResponsesParams.Text(const Value: TTextParams): TResponsesParams;
begin
  Result := TResponsesParams(Add('text', Value.Detach));
end;

function TResponsesParams.ContextManagement(
  const Value: TArray<TContextManagementParams>): TResponsesParams;
begin
  var JSONArray := TJSONArray.Create;
  for var Item in Value do
    JSONArray.Add(Item.Detach);
  Result := TResponsesParams(Add('context_management', JSONArray));
end;

function TResponsesParams.PromptCacheRetention(
  const Value: TPromptCacheRetention): TResponsesParams;
begin
  Result := TResponsesParams(Add('prompt_cache_retention', Value.ToString));
end;

function TResponsesParams.PromptCacheRetention(
  const Value: string): TResponsesParams;
begin
  Result := TResponsesParams(Add('prompt_cache_retention', TPromptCacheRetention.Create(Value).ToString));
end;

function TResponsesParams.ServiceTier(
  const Value: TServiceTier): TResponsesParams;
begin
  Result := TResponsesParams(Add('service_tier', Value.ToString));
end;

{ TResponseImageGenerationParams }

function TResponseImageGenerationParams.Background(
  const Value: string): TResponseImageGenerationParams;
begin
  Result := Background(TBackGroundType.Create(Value));
end;

function TResponseImageGenerationParams.Background(
  const Value: TBackGroundType): TResponseImageGenerationParams;
begin
  Result := TResponseImageGenerationParams(Add('background', Value.ToString));
end;

function TResponseImageGenerationParams.InputFidelity(
  const Value: string): TResponseImageGenerationParams;
begin
  Result := TResponseImageGenerationParams(Add('input_fidelity', TFidelityType.Create(Value).ToString));
end;

function TResponseImageGenerationParams.InputFidelity(
  const Value: TFidelityType): TResponseImageGenerationParams;
begin
  Result := TResponseImageGenerationParams(Add('input_fidelity', Value.ToString));
end;

function TResponseImageGenerationParams.InputImageMask(
  const Value: string): TResponseImageGenerationParams;
var
  JSONObject: TJSONObject;
begin
  if TJSONHelper.TryGetObject(Value, JSONObject) then
    Exit(TResponseImageGenerationParams(Add('input_image_mask', JSONObject)));

  raise TGenAIAPIException.Create('Invalid JSON Object');
end;

function TResponseImageGenerationParams.InputImageMask(
  const Value: TInputImageMaskParams): TResponseImageGenerationParams;
begin
  Result := TResponseImageGenerationParams(Add('input_image_mask', Value.Detach));
end;

function TResponseImageGenerationParams.Model(
  const Value: string): TResponseImageGenerationParams;
begin
  Result := TResponseImageGenerationParams(Add('model', Value));
end;

function TResponseImageGenerationParams.Moderation(
  const Value: string): TResponseImageGenerationParams;
begin
  Result := TResponseImageGenerationParams(Add('moderation', Value));
end;

class function TResponseImageGenerationParams.New: TResponseImageGenerationParams;
begin
  Result := TResponseImageGenerationParams.Create.&Type();
end;

function TResponseImageGenerationParams.OutputCompression(
  const Value: Integer): TResponseImageGenerationParams;
begin
  Result := TResponseImageGenerationParams(Add('output_compression', Value));
end;

function TResponseImageGenerationParams.OutputFormat(
  const Value: TOutputFormatType): TResponseImageGenerationParams;
begin
  Result := TResponseImageGenerationParams(Add('output_format', Value.ToString));
end;

function TResponseImageGenerationParams.OutputFormat(
  const Value: string): TResponseImageGenerationParams;
begin
  Result := OutputFormat(TOutputFormatType.Create(Value));
end;

function TResponseImageGenerationParams.PartialImages(
  const Value: Integer): TResponseImageGenerationParams;
begin
  Result := TResponseImageGenerationParams(Add('partial_images', Value));
end;

function TResponseImageGenerationParams.Quality(
  const Value: TImageQualityType): TResponseImageGenerationParams;
begin
  Result := TResponseImageGenerationParams(Add('quality', Value.ToString));
end;

function TResponseImageGenerationParams.Quality(
  const Value: string): TResponseImageGenerationParams;
begin
  Result := Quality(TImageQualityType.Create(Value));
end;

function TResponseImageGenerationParams.Size(
  const Value: TImageSize): TResponseImageGenerationParams;
begin
  Result := TResponseImageGenerationParams(Add('size', Value.ToString));
end;

function TResponseImageGenerationParams.Size(
  const Value: string): TResponseImageGenerationParams;
begin
  Result := Size(TImageSize.Create(Value));
end;

function TResponseImageGenerationParams.&Type(
  const Value: string): TResponseImageGenerationParams;
begin
  Result := TResponseImageGenerationParams(Add('type', Value));
end;

{ TInputImageMaskParams }

function TInputImageMaskParams.FileId(
  const Value: string): TInputImageMaskParams;
begin
  Result := TInputImageMaskParams(Add('file_id', Value));
end;

function TInputImageMaskParams.ImageUrl(
  const Value: string): TInputImageMaskParams;
begin
  Result := TInputImageMaskParams(Add('image_url', Value));
end;

class function TInputImageMaskParams.New: TInputImageMaskParams;
begin
  Result := TInputImageMaskParams.Create;
end;

{ TPromptParams }

function TPromptParams.Id(const Value: string): TPromptParams;
begin
  Result := TPromptParams(Add('id', Value));
end;

class function TPromptParams.New: TPromptParams;
begin
  Result := TPromptParams.Create;
end;

function TPromptParams.Variables(const Value: TJSONObject): TPromptParams;
begin
  Result := TPromptParams(Add('variables', Value));
end;

function TPromptParams.Variables(const Value: string): TPromptParams;
var
  JSONObject: TJSONObject;
begin
  {--- The variables parameter is always a JSON object. }
  if TJSONHelper.TryGetObject(Value, JSONObject) then
    Exit(TPromptParams(Add('variables', JSONObject)));

  raise TGenAIAPIException.Create('Invalid JSON Object');
end;

function TPromptParams.Version(const Value: string): TPromptParams;
begin
  Result := TPromptParams(Add('version', Value));
end;

{ TCustomToolParams }

function TCustomToolParams.&Type(const Value: string): TCustomToolParams;
begin
  Result := TCustomToolParams(Add('type', Value));
end;

function TCustomToolParams.Description(const Value: string): TCustomToolParams;
begin
  Result := TCustomToolParams(Add('description', Value));
end;

function TCustomToolParams.Format(
  const Value: TToolParamsFormatParams): TCustomToolParams;
begin
  Result := TCustomToolParams(Add('format', Value.Detach));
end;

function TCustomToolParams.Format(const Value: string): TCustomToolParams;
var
  JSONObject: TJSONObject;
begin
  if TJSONHelper.TryGetObject(Value, JSONObject) then
    Exit(TCustomToolParams(Add('format', JSONObject)));

  raise TGenAIAPIException.Create('Invalid JSON Object');
end;
function TCustomToolParams.Name(const Value: string): TCustomToolParams;
begin
  Result := TCustomToolParams(Add('name', Value));
end;

class function TCustomToolParams.New: TCustomToolParams;
begin
  Result := TCustomToolParams.Create.&Type();
end;

{ TToolParamsFormatParams }

function TToolParamsFormatParams.Definition(
  const Value: string): TToolParamsFormatParams;
begin
  Result := TToolParamsFormatParams(Add('definition', Value));
end;

function TToolParamsFormatParams.Syntax(
  const Value: TSyntaxFormatType): TToolParamsFormatParams;
begin
  Result := TToolParamsFormatParams(Add('syntax', Value.ToString));
end;

function TToolParamsFormatParams.Syntax(
  const Value: string): TToolParamsFormatParams;
begin
  Result := Syntax(TSyntaxFormatType.Create(Value));
end;

class function TToolParamsFormatParams.New(
  const Value: TToolParamsFormatType): TToolParamsFormatParams;
begin
  Result := TToolParamsFormatParams.Create.&Type(Value);
end;

class function TToolParamsFormatParams.New(
  const Value: string): TToolParamsFormatParams;
begin
  Result := TToolParamsFormatParams.Create.&Type(Value);
end;

function TToolParamsFormatParams.&Type(
  const Value: TToolParamsFormatType): TToolParamsFormatParams;
begin
  Result := TToolParamsFormatParams(Add('type', Value.ToString));
end;

function TToolParamsFormatParams.&Type(
  const Value: string): TToolParamsFormatParams;
begin
  Result := TToolParamsFormatParams(Add('type', TToolParamsFormatType.Create(Value).ToString));
end;

{ TItemAudioContent }

function TItemAudioContent.Data(const Value: string): TItemAudioContent;
begin
  Result := TItemAudioContent(Add('data', Value));
end;

function TItemAudioContent.Format(const Value: TAudioFormat): TItemAudioContent;
begin
  Result := TItemAudioContent(Add('format', Value.ToString));
end;

function TItemAudioContent.Format(const Value: string): TItemAudioContent;
begin
  Result := TItemAudioContent(Add('format', TAudioFormat.Create(Value).ToString));
end;

class function TItemAudioContent.NewMp3(const Value: string): TItemAudioContent;
begin
  Result := TItemAudioContent.Create.Format(TAudioFormat.mp3)
end;

class function TItemAudioContent.NewWav(const Value: string): TItemAudioContent;
begin
  Result := TItemAudioContent.Create.Format(TAudioFormat.wav)
end;

{ TSearchAction }

function TSearchAction.Sources(
  const Value: TArray<TSearchActionSourceParam>): TSearchAction;
begin
  var JSONArray := TJSONArray.Create;
  for var Item in Value do
    JSONArray.Add(Item.Detach);

  Result := TSearchAction(Add('sources', JSONArray));
end;

function TSearchAction.&Type(const Value: string): TSearchAction;
begin
  Result := TSearchAction(Add('type', Value));
end;

function TSearchAction.Query(const Value: string): TSearchAction;
begin
  Result := TSearchAction(Add('query', Value));
end;

{ TSearchActionSourceParam }

class function TSearchActionSourceParam.New: TSearchActionSourceParam;
begin
  Result := TSearchActionSourceParam.Create.&Type();
end;

function TSearchActionSourceParam.&Type(const Value: string): TSearchActionSourceParam;
begin
  Result := TSearchActionSourceParam(Add('type', Value));
end;

function TSearchActionSourceParam.Url(const Value: string): TSearchActionSourceParam;
begin
  Result := TSearchActionSourceParam(Add('url', Value));
end;

{ TOpenPageAction }

function TOpenPageAction.&Type(const Value: string): TOpenPageAction;
begin
  Result := TOpenPageAction(Add('type', Value));
end;

function TOpenPageAction.Url(const Value: string): TOpenPageAction;
begin
  Result := TOpenPageAction(Add('url', Value));
end;

{ TFindAction }

function TFindAction.&Type(const Value: string): TFindAction;
begin
  Result := TFindAction(Add('type', Value));
end;

function TFindAction.Url(const Value: string): TFindAction;
begin
  Result := TFindAction(Add('url', Value));
end;

function TFindAction.Pattern(const Value: string): TFindAction;
begin
  Result := TFindAction(Add('pattern', Value));
end;

{ TFunctionInputText }

class function TFunctionInputText.New: TFunctionInputText;
begin
  Result := TFunctionInputText.Create.&Type();
end;

function TFunctionInputText.Text(const Value: string): TFunctionInputText;
begin
  Result := TFunctionInputText(Add('text', Value));
end;

function TFunctionInputText.&Type(const Value: string): TFunctionInputText;
begin
  Result := TFunctionInputText(Add('type', Value));
end;

{ TFunctionInputImage }

function TFunctionInputImage.Detail(
  const Value: TImageDetail): TFunctionInputImage;
begin
  Result := TFunctionInputImage(Add('detail', Value.ToString));
end;

function TFunctionInputImage.Detail(const Value: string): TFunctionInputImage;
begin
  Result := TFunctionInputImage(Add('detail', TImageDetail.Create(Value).ToString));
end;

function TFunctionInputImage.FileId(const Value: string): TFunctionInputImage;
begin
  Result := TFunctionInputImage(Add('file_id', Value));
end;

function TFunctionInputImage.ImageUrl(const Value: string): TFunctionInputImage;
begin
  Result := TFunctionInputImage(Add('image_url', Value)); //GetUrlOrEncodeBase64
end;

class function TFunctionInputImage.New: TFunctionInputImage;
begin
  Result := TFunctionInputImage.Create.&Type();
end;

function TFunctionInputImage.&Type(const Value: string): TFunctionInputImage;
begin
  Result := TFunctionInputImage(Add('type', Value));
end;

{ TFunctionInputFile }

function TFunctionInputFile.FileData(const Value: string): TFunctionInputFile;
begin
  Result := TFunctionInputFile(Add('file_data', Value)); //GetUrlOrEncodeBase64
end;

function TFunctionInputFile.FileId(const Value: string): TFunctionInputFile;
begin
  Result := TFunctionInputFile(Add('file_id', Value));
end;

function TFunctionInputFile.Filename(const Value: string): TFunctionInputFile;
begin
  Result := TFunctionInputFile(Add('filename', Value));
end;

function TFunctionInputFile.FileUrl(const Value: string): TFunctionInputFile;
begin
  Result := TFunctionInputFile(Add('file_url', Value));
end;

class function TFunctionInputFile.New: TFunctionInputFile;
begin
  Result := TFunctionInputFile.Create.&Type();
end;

function TFunctionInputFile.&Type(const Value: string): TFunctionInputFile;
begin
  Result := TFunctionInputFile(Add('type', Value));
end;

{ TCodeInterpreterOutputImage }

class function TCodeInterpreterOutputImage.New: TCodeInterpreterOutputImage;
begin
  Result := TCodeInterpreterOutputImage.Create.&Type();
end;

function TCodeInterpreterOutputImage.&Type(
  const Value: string): TCodeInterpreterOutputImage;
begin
  Result := TCodeInterpreterOutputImage(Add('type', Value));
end;

function TCodeInterpreterOutputImage.Url(
  const Value: string): TCodeInterpreterOutputImage;
begin
  Result := TCodeInterpreterOutputImage(Add('url', Value));
end;

{ TCustomToolCallOutput }

function TCustomToolCallOutput.&Type(
  const Value: string): TCustomToolCallOutput;
begin
  Result := TCustomToolCallOutput(Add('type', Value));
end;

function TCustomToolCallOutput.CallId(
  const Value: string): TCustomToolCallOutput;
begin
  Result := TCustomToolCallOutput(Add('call_id', Value));
end;

function TCustomToolCallOutput.Output(
  const Value: string): TCustomToolCallOutput;
var
  JSONArray: TJSONArray;
begin
  if TJSONHelper.TryGetArray(Value, JSONArray) then
    Exit(TCustomToolCallOutput(Add('output', JSONArray)));

  Result := TCustomToolCallOutput(Add('output', Value));
end;

function TCustomToolCallOutput.Id(const Value: string): TCustomToolCallOutput;
begin
  Result := TCustomToolCallOutput(Add('id', Value));
end;

class function TCustomToolCallOutput.New: TCustomToolCallOutput;
begin
  Result := TCustomToolCallOutput.Create.&Type();
end;

function TCustomToolCallOutput.Output(
  const Value: TArray<TFunctionOutput>): TCustomToolCallOutput;
begin
  var JSONArray := TJSONArray.Create;
  for var Item in Value do
    JSONArray.Add(Item.Detach);
  Result := TCustomToolCallOutput(Add('output', JSONArray));
end;

{ TCustomToolCall }

function TCustomToolCall.&Type(const Value: string): TCustomToolCall;
begin
  Result := TCustomToolCall(Add('type', Value));
end;

function TCustomToolCall.CallId(const Value: string): TCustomToolCall;
begin
  Result := TCustomToolCall(Add('call_id', Value));
end;

function TCustomToolCall.Id(const Value: string): TCustomToolCall;
begin
  Result := TCustomToolCall(Add('id', Value));
end;

function TCustomToolCall.Input(const Value: string): TCustomToolCall;
begin
  Result := TCustomToolCall(Add('input', Value));
end;

function TCustomToolCall.Name(const Value: string): TCustomToolCall;
begin
  Result := TCustomToolCall(Add('name', Value));
end;

{ TConversationParams }

function TConversationParams.Id(const Value: string): TConversationParams;
begin
  Result := TConversationParams(Add('id', Value));
end;

class function TConversationParams.New(
  const Value: string): TConversationParams;
begin
  Result := TConversationParams.Create.Id(Value);
end;

{ TWebSearchPreviewParams }

function TWebSearchPreviewParams.&Type(
  const Value: TWebSearchPreviewType): TWebSearchPreviewParams;
begin
  Result := TWebSearchPreviewParams(Add('type', Value.ToString));
end;

function TWebSearchPreviewParams.&Type(
  const Value: string): TWebSearchPreviewParams;
begin
  Result := TWebSearchPreviewParams(Add('type', TWebSearchPreviewType.Create(Value).ToString));
end;

function TWebSearchPreviewParams.UserLocation(
  const Value: string): TWebSearchPreviewParams;
var
  JSONObject: TJSONObject;
begin
  if TJSONHelper.TryGetObject(Value, JSONObject) then
    Exit(TWebSearchPreviewParams(Add('user_location', JSONObject)));

  raise TGenAIAPIException.Create('Invalid JSON Object');
end;

function TWebSearchPreviewParams.UserLocation(
  const Value: TResponseUserLocationParams): TWebSearchPreviewParams;
begin
  Result := TWebSearchPreviewParams(Add('user_location', Value.Detach));
end;

function TWebSearchPreviewParams.SearchContextSize(
  const Value: TSearchWebOptions): TWebSearchPreviewParams;
begin
  Result := TWebSearchPreviewParams(Add('search_context_size', Value.ToString));
end;

function TWebSearchPreviewParams.SearchContextSize(
  const Value: string): TWebSearchPreviewParams;
begin
  Result := SearchContextSize(TSearchWebOptions.Create(Value));
end;

class function TWebSearchPreviewParams.New: TWebSearchPreviewParams;
begin
  Result := TWebSearchPreviewParams.Create.&Type();
end;

{ TMCPToolParams }

function TMCPToolParams.Name(const Value: string): TMCPToolParams;
begin
  Result := TMCPToolParams(Add('name', Value));
end;

class function TMCPToolParams.New: TMCPToolParams;
begin
  Result := TMCPToolParams.Create.&Type();
end;

function TMCPToolParams.ServerLabel(const Value: string): TMCPToolParams;
begin
  Result := TMCPToolParams(Add('server_label', Value));
end;

function TMCPToolParams.&Type(const Value: string): TMCPToolParams;
begin
  Result := TMCPToolParams(Add('type', Value));
end;

{ TCustomToolChoiceParams }

function TCustomToolChoiceParams.Name(
  const Value: string): TCustomToolChoiceParams;
begin
  Result := TCustomToolChoiceParams(Add('name', Value));
end;

function TCustomToolChoiceParams.&Type(
  const Value: string): TCustomToolChoiceParams;
begin
  Result := TCustomToolChoiceParams(Add('type', Value));
end;

{ TContent }

class function TContent.Create(const Capacity: Integer): TContent;
begin
  Result.FItems := nil;
  Result.FCount := 0;

  if Capacity > 0 then
    SetLength(Result.FItems, Capacity);
end;

function TContent.Reserve(const Capacity: Integer): TContent;
begin
  Result := Self;
  if (Capacity > 0) and (Length(Result.FItems) < Capacity) then
    SetLength(Result.FItems, Capacity);
end;

procedure TContent.Append(const Item: TItemContent);
var
  NewCap: Integer;
begin
  if FCount = Length(FItems) then
  begin
    if Length(FItems) = 0 then
      NewCap := 4
    else
      NewCap := Length(FItems) * 2;
    SetLength(FItems, NewCap);
  end;

  FItems[FCount] := Item;
  Inc(FCount);
end;

function TContent.AddPrompt(const AText: string): TContent;
begin
  Result := Self;
  Result.Append(TItemContent.NewText.Text(AText));
end;

function TContent.AddImage(const APathOrUrl: string): TContent;
begin
  Result := Self;
  Result.Append(TItemContent.NewImage(APathOrUrl));
end;

function TContent.AddFile(const AFilePath: string): TContent;
begin
  Result := Self;
  Result.Append(TItemContent.NewFileData(AFilePath));
end;

function TContent.AddAudio(const AAudioPath: string): TContent;
begin
  Result := Self;
  Result.Append(TItemContent.NewAudio(AAudioPath));
end;

class operator TContent.Implicit(const Value: TContent): TArray<TItemContent>;
begin
  Result := Copy(Value.FItems, 0, Value.FCount);
end;

{ TResponseImageGenerationParams }

function TResponseImageGenerationParams.Action(
  const Value: TImageGenActionType): TResponseImageGenerationParams;
begin
  Result := TResponseImageGenerationParams(Add('action', Value.ToString));
end;

function TResponseImageGenerationParams.Action(
  const Value: string): TResponseImageGenerationParams;
begin
  Result := Action(TImageGenActionType.Create(Value));
end;

{ TContextManagementParams }

function TContextManagementParams.&Type(
  const Value: string): TContextManagementParams;
begin
  Result := TContextManagementParams(Add('type', Value));
end;

function TContextManagementParams.CompactThreshold(
  const Value: Integer): TContextManagementParams;
begin
  Result := TContextManagementParams(Add('compact_threshold', Value));
end;

class function TContextManagementParams.New: TContextManagementParams;
begin
  Result := TContextManagementParams.Create.&Type();
end;

{ TWebSearchFiltersParams }

function TWebSearchFiltersParams.AllowedDomains(
  const Value: TArray<string>): TWebSearchFiltersParams;
begin
  Result := TWebSearchFiltersParams(Add('allowed_domains', Value));
end;

class function TWebSearchFiltersParams.New: TWebSearchFiltersParams;
begin
  Result := TWebSearchFiltersParams.Create;
end;

{ TApplyPatchToolParams }

function TApplyPatchToolParams.&Type(
  const Value: string): TApplyPatchToolParams;
begin
  Result := TApplyPatchToolParams(Add('type', Value));
end;

class function TApplyPatchToolParams.New: TApplyPatchToolParams;
begin
  Result := TApplyPatchToolParams.Create.&Type();
end;

{ TToolSearchToolParams }

function TToolSearchToolParams.&Type(
  const Value: string): TToolSearchToolParams;
begin
  Result := TToolSearchToolParams(Add('type', Value));
end;

function TToolSearchToolParams.Description(
  const Value: string): TToolSearchToolParams;
begin
  Result := TToolSearchToolParams(Add('description', Value));
end;

function TToolSearchToolParams.Execution(
  const Value: TToolSearchExecution): TToolSearchToolParams;
begin
  Result := TToolSearchToolParams(Add('execution', Value.ToString));
end;

function TToolSearchToolParams.Execution(
  const Value: string): TToolSearchToolParams;
begin
  Result := Execution(TToolSearchExecution.Create(Value));
end;

function TToolSearchToolParams.Parameters(
  const Value: TSchemaParams): TToolSearchToolParams;
begin
  Result := TToolSearchToolParams(Add('parameters', Value.Detach));
end;

function TToolSearchToolParams.Parameters(
  const Value: TJSONObject): TToolSearchToolParams;
begin
  Result := TToolSearchToolParams(Add('parameters', Value));
end;

function TToolSearchToolParams.Parameters(
  const Value: string): TToolSearchToolParams;
var
  JSONObject: TJSONObject;
begin
  if TJSONHelper.TryGetObject(Value, JSONObject) then
    Exit(TToolSearchToolParams(Add('parameters', JSONObject)));

  raise TGenAIAPIException.Create('Invalid JSON Object');
end;

class function TToolSearchToolParams.New: TToolSearchToolParams;
begin
  Result := TToolSearchToolParams.Create.&Type();
end;

{ TNamespaceToolParams }

function TNamespaceToolParams.&Type(
  const Value: string): TNamespaceToolParams;
begin
  Result := TNamespaceToolParams(Add('type', Value));
end;

function TNamespaceToolParams.Name(const Value: string): TNamespaceToolParams;
begin
  Result := TNamespaceToolParams(Add('name', Value));
end;

function TNamespaceToolParams.Description(
  const Value: string): TNamespaceToolParams;
begin
  Result := TNamespaceToolParams(Add('description', Value));
end;

function TNamespaceToolParams.Tools(
  const Value: TArray<TResponseToolParams>): TNamespaceToolParams;
begin
  var JSONArray := TJSONArray.Create;
  for var Item in Value do
    JSONArray.Add(Item.Detach);
  Result := TNamespaceToolParams(Add('tools', JSONArray));
end;

function TNamespaceToolParams.Tools(
  const Value: TJSONArray): TNamespaceToolParams;
begin
  Result := TNamespaceToolParams(Add('tools', Value));
end;

function TNamespaceToolParams.Tools(const Value: string): TNamespaceToolParams;
var
  JSONArray: TJSONArray;
begin
  if TJSONHelper.TryGetArray(Value, JSONArray) then
    Exit(TNamespaceToolParams(Add('tools', JSONArray)));

  raise TGenAIAPIException.Create('Invalid JSON Array');
end;

class function TNamespaceToolParams.New: TNamespaceToolParams;
begin
  Result := TNamespaceToolParams.Create.&Type();
end;

{ TContainerNetworkPolicyDomainSecretParams }

function TContainerNetworkPolicyDomainSecretParams.Domain(
  const Value: string): TContainerNetworkPolicyDomainSecretParams;
begin
  Result := TContainerNetworkPolicyDomainSecretParams(Add('domain', Value));
end;

function TContainerNetworkPolicyDomainSecretParams.Name(
  const Value: string): TContainerNetworkPolicyDomainSecretParams;
begin
  Result := TContainerNetworkPolicyDomainSecretParams(Add('name', Value));
end;

function TContainerNetworkPolicyDomainSecretParams.Value(
  const Value: string): TContainerNetworkPolicyDomainSecretParams;
begin
  Result := TContainerNetworkPolicyDomainSecretParams(Add('value', Value));
end;

class function TContainerNetworkPolicyDomainSecretParams.New: TContainerNetworkPolicyDomainSecretParams;
begin
  Result := TContainerNetworkPolicyDomainSecretParams.Create;
end;

{ TContainerNetworkPolicyDisabledParams }

function TContainerNetworkPolicyDisabledParams.&Type(
  const Value: string): TContainerNetworkPolicyDisabledParams;
begin
  Result := TContainerNetworkPolicyDisabledParams(Add('type', Value));
end;

class function TContainerNetworkPolicyDisabledParams.New: TContainerNetworkPolicyDisabledParams;
begin
  Result := TContainerNetworkPolicyDisabledParams.Create.&Type();
end;

{ TContainerNetworkPolicyAllowlistParams }

function TContainerNetworkPolicyAllowlistParams.&Type(
  const Value: string): TContainerNetworkPolicyAllowlistParams;
begin
  Result := TContainerNetworkPolicyAllowlistParams(Add('type', Value));
end;

function TContainerNetworkPolicyAllowlistParams.AllowedDomains(
  const Value: TArray<string>): TContainerNetworkPolicyAllowlistParams;
begin
  Result := TContainerNetworkPolicyAllowlistParams(Add('allowed_domains', Value));
end;

function TContainerNetworkPolicyAllowlistParams.DomainSecrets(
  const Value: TArray<TContainerNetworkPolicyDomainSecretParams>): TContainerNetworkPolicyAllowlistParams;
begin
  var JSONArray := TJSONArray.Create;
  for var Item in Value do
    JSONArray.Add(Item.Detach);
  Result := TContainerNetworkPolicyAllowlistParams(Add('domain_secrets', JSONArray));
end;

function TContainerNetworkPolicyAllowlistParams.DomainSecrets(
  const Value: string): TContainerNetworkPolicyAllowlistParams;
var
  JSONArray: TJSONArray;
begin
  if TJSONHelper.TryGetArray(Value, JSONArray) then
    Exit(TContainerNetworkPolicyAllowlistParams(Add('domain_secrets', JSONArray)));

  raise TGenAIAPIException.Create('Invalid JSON Array');
end;

class function TContainerNetworkPolicyAllowlistParams.New: TContainerNetworkPolicyAllowlistParams;
begin
  Result := TContainerNetworkPolicyAllowlistParams.Create.&Type();
end;

{ TInlineSkillSourceParams }

function TInlineSkillSourceParams.&Type(
  const Value: string): TInlineSkillSourceParams;
begin
  Result := TInlineSkillSourceParams(Add('type', Value));
end;

function TInlineSkillSourceParams.MediaType(
  const Value: string): TInlineSkillSourceParams;
begin
  Result := TInlineSkillSourceParams(Add('media_type', Value));
end;

function TInlineSkillSourceParams.Data(
  const Value: string): TInlineSkillSourceParams;
begin
  Result := TInlineSkillSourceParams(Add('data', Value));
end;

class function TInlineSkillSourceParams.New: TInlineSkillSourceParams;
begin
  Result := TInlineSkillSourceParams.Create.&Type().MediaType();
end;

{ TSkillReferenceParams }

function TSkillReferenceParams.&Type(
  const Value: string): TSkillReferenceParams;
begin
  Result := TSkillReferenceParams(Add('type', Value));
end;

function TSkillReferenceParams.SkillId(
  const Value: string): TSkillReferenceParams;
begin
  Result := TSkillReferenceParams(Add('skill_id', Value));
end;

function TSkillReferenceParams.Version(
  const Value: string): TSkillReferenceParams;
begin
  Result := TSkillReferenceParams(Add('version', Value));
end;

class function TSkillReferenceParams.New: TSkillReferenceParams;
begin
  Result := TSkillReferenceParams.Create.&Type();
end;

{ TInlineSkillParams }

function TInlineSkillParams.&Type(const Value: string): TInlineSkillParams;
begin
  Result := TInlineSkillParams(Add('type', Value));
end;

function TInlineSkillParams.Name(const Value: string): TInlineSkillParams;
begin
  Result := TInlineSkillParams(Add('name', Value));
end;

function TInlineSkillParams.Description(
  const Value: string): TInlineSkillParams;
begin
  Result := TInlineSkillParams(Add('description', Value));
end;

function TInlineSkillParams.Source(
  const Value: TInlineSkillSourceParams): TInlineSkillParams;
begin
  Result := TInlineSkillParams(Add('source', Value.Detach));
end;

class function TInlineSkillParams.New: TInlineSkillParams;
begin
  Result := TInlineSkillParams.Create.&Type();
end;

{ TLocalSkillParams }

function TLocalSkillParams.Name(const Value: string): TLocalSkillParams;
begin
  Result := TLocalSkillParams(Add('name', Value));
end;

function TLocalSkillParams.Description(const Value: string): TLocalSkillParams;
begin
  Result := TLocalSkillParams(Add('description', Value));
end;

function TLocalSkillParams.Path(const Value: string): TLocalSkillParams;
begin
  Result := TLocalSkillParams(Add('path', Value));
end;

class function TLocalSkillParams.New: TLocalSkillParams;
begin
  Result := TLocalSkillParams.Create;
end;

{ TShellContainerReferenceParams }

function TShellContainerReferenceParams.&Type(
  const Value: string): TShellContainerReferenceParams;
begin
  Result := TShellContainerReferenceParams(Add('type', Value));
end;

function TShellContainerReferenceParams.ContainerId(
  const Value: string): TShellContainerReferenceParams;
begin
  Result := TShellContainerReferenceParams(Add('container_id', Value));
end;

class function TShellContainerReferenceParams.New: TShellContainerReferenceParams;
begin
  Result := TShellContainerReferenceParams.Create.&Type();
end;

{ TShellLocalEnvironmentParams }

function TShellLocalEnvironmentParams.&Type(
  const Value: string): TShellLocalEnvironmentParams;
begin
  Result := TShellLocalEnvironmentParams(Add('type', Value));
end;

function TShellLocalEnvironmentParams.Skills(
  const Value: TArray<TLocalSkillParams>): TShellLocalEnvironmentParams;
begin
  var JSONArray := TJSONArray.Create;
  for var Item in Value do
    JSONArray.Add(Item.Detach);
  Result := TShellLocalEnvironmentParams(Add('skills', JSONArray));
end;

function TShellLocalEnvironmentParams.Skills(
  const Value: string): TShellLocalEnvironmentParams;
var
  JSONArray: TJSONArray;
begin
  if TJSONHelper.TryGetArray(Value, JSONArray) then
    Exit(TShellLocalEnvironmentParams(Add('skills', JSONArray)));

  raise TGenAIAPIException.Create('Invalid JSON Array');
end;

class function TShellLocalEnvironmentParams.New: TShellLocalEnvironmentParams;
begin
  Result := TShellLocalEnvironmentParams.Create.&Type();
end;

{ TShellContainerAutoParams }

function TShellContainerAutoParams.&Type(
  const Value: string): TShellContainerAutoParams;
begin
  Result := TShellContainerAutoParams(Add('type', Value));
end;

function TShellContainerAutoParams.FileIds(
  const Value: TArray<string>): TShellContainerAutoParams;
begin
  Result := TShellContainerAutoParams(Add('file_ids', Value));
end;

function TShellContainerAutoParams.MemoryLimit(
  const Value: TContainerMemoryLimit): TShellContainerAutoParams;
begin
  Result := TShellContainerAutoParams(Add('memory_limit', Value.ToString));
end;

function TShellContainerAutoParams.MemoryLimit(
  const Value: string): TShellContainerAutoParams;
begin
  Result := MemoryLimit(TContainerMemoryLimit.Create(Value));
end;

function TShellContainerAutoParams.NetworkPolicy(
  const Value: TContainerNetworkPolicyParams): TShellContainerAutoParams;
begin
  Result := TShellContainerAutoParams(Add('network_policy', Value.Detach));
end;

function TShellContainerAutoParams.NetworkPolicy(
  const Value: string): TShellContainerAutoParams;
var
  JSONObject: TJSONObject;
begin
  if TJSONHelper.TryGetObject(Value, JSONObject) then
    Exit(TShellContainerAutoParams(Add('network_policy', JSONObject)));

  raise TGenAIAPIException.Create('Invalid JSON Object');
end;

function TShellContainerAutoParams.Skills(
  const Value: TArray<TContainerSkillParams>): TShellContainerAutoParams;
begin
  var JSONArray := TJSONArray.Create;
  for var Item in Value do
    JSONArray.Add(Item.Detach);
  Result := TShellContainerAutoParams(Add('skills', JSONArray));
end;

function TShellContainerAutoParams.Skills(
  const Value: string): TShellContainerAutoParams;
var
  JSONArray: TJSONArray;
begin
  if TJSONHelper.TryGetArray(Value, JSONArray) then
    Exit(TShellContainerAutoParams(Add('skills', JSONArray)));

  raise TGenAIAPIException.Create('Invalid JSON Array');
end;

class function TShellContainerAutoParams.New: TShellContainerAutoParams;
begin
  Result := TShellContainerAutoParams.Create.&Type();
end;

{ TFunctionShellToolParams }

function TFunctionShellToolParams.&Type(
  const Value: string): TFunctionShellToolParams;
begin
  Result := TFunctionShellToolParams(Add('type', Value));
end;

function TFunctionShellToolParams.Environment(
  const Value: TShellEnvironmentParams): TFunctionShellToolParams;
begin
  Result := TFunctionShellToolParams(Add('environment', Value.Detach));
end;

function TFunctionShellToolParams.Environment(
  const Value: string): TFunctionShellToolParams;
var
  JSONObject: TJSONObject;
begin
  if TJSONHelper.TryGetObject(Value, JSONObject) then
    Exit(TFunctionShellToolParams(Add('environment', JSONObject)));

  raise TGenAIAPIException.Create('Invalid JSON Object');
end;

class function TFunctionShellToolParams.New: TFunctionShellToolParams;
begin
  Result := TFunctionShellToolParams.Create.&Type();
end;

{ TAllowedToolsChoiceParams }

function TAllowedToolsChoiceParams.&Type(
  const Value: string): TAllowedToolsChoiceParams;
begin
  Result := TAllowedToolsChoiceParams(Add('type', Value));
end;

function TAllowedToolsChoiceParams.Mode(
  const Value: TAllowedToolsMode): TAllowedToolsChoiceParams;
begin
  Result := TAllowedToolsChoiceParams(Add('mode', Value.ToString));
end;

function TAllowedToolsChoiceParams.Mode(
  const Value: string): TAllowedToolsChoiceParams;
begin
  Result := Mode(TAllowedToolsMode.Create(Value));
end;

function TAllowedToolsChoiceParams.Tools(
  const Value: TArray<TResponseToolParams>): TAllowedToolsChoiceParams;
begin
  var JSONArray := TJSONArray.Create;
  for var Item in Value do
    JSONArray.Add(Item.Detach);
  Result := TAllowedToolsChoiceParams(Add('tools', JSONArray));
end;

function TAllowedToolsChoiceParams.Tools(
  const Value: TJSONArray): TAllowedToolsChoiceParams;
begin
  Result := TAllowedToolsChoiceParams(Add('tools', Value));
end;

function TAllowedToolsChoiceParams.Tools(
  const Value: string): TAllowedToolsChoiceParams;
var
  JSONArray: TJSONArray;
begin
  if TJSONHelper.TryGetArray(Value, JSONArray) then
    Exit(TAllowedToolsChoiceParams(Add('tools', JSONArray)));

  raise TGenAIAPIException.Create('Invalid JSON Array');
end;

class function TAllowedToolsChoiceParams.New: TAllowedToolsChoiceParams;
begin
  Result := TAllowedToolsChoiceParams.Create.&Type();
end;

end.
