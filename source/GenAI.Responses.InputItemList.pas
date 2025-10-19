unit GenAI.Responses.InputItemList;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGenAI
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.SysUtils, System.Classes, System.Threading, System.JSON, REST.Json.Types,
  REST.JsonReflect,
  GenAI.API.Params, GenAI.API, GenAI.Consts, GenAI.Schema, GenAI.Types,
  GenAI.Async.Params, GenAI.Async.Support, GenAI.Assistants;

type
  {$REGION 'log probs'}

  TTopLogprobs = class
  private
    FBytes   : TArray<Double>;
    FLogprob : Double;
    FToken   : string;
  public
    property Bytes: TArray<Double> read FBytes write FBytes;
    property Logprob: Double read FLogprob write FLogprob;
    property Token: string read FToken write FToken;
  end;

  TLogprobs = class
  private
    [JsonNameAttribute('top_logprobs')]
    FTopLogprobs : TArray<TTopLogprobs>;
    FBytes       : TArray<Double>;
    FLogprob     : Double;
    FToken       : string;
  public
    property Bytes: TArray<Double> read FBytes write FBytes;
    property Logprob: Double read FLogprob write FLogprob;
    property Token: string read FToken write FToken;
    property TopLogprobs: TArray<TTopLogprobs> read FTopLogprobs write FTopLogprobs;
    destructor Destroy; override;
  end;

  {$ENDREGION}

  {$REGION 'actions'}

    {$REGION 'search action source'}

  TSearchActionSource = class
  private
    FType : string;
    FUrl  : string;
  public
    property &Type : string read FType write FType;
    property Url: string read FUrl write FUrl;
  end;

    {$ENDREGION}

    {$REGION 'drag point'}

  TDragPoint = class
  private
    FX : Int64;
    FY : Int64;
  public
    /// <summary>
    /// The x-coordinate.
    /// </summary>
    property X: Int64 read FX write FX;

    /// <summary>
    /// The y-coordinate.
    /// </summary>
    property Y: Int64 read FY write FY;
  end;

    {$ENDREGION}

  TComputerActionCommon = class
  private
    FType : string;
  public
    /// <summary>
    /// Specifies the event type.
    /// </summary>
    property &Type: string read FType write FType;
  end;

  TComputerActionClick = class(TComputerActionCommon)
  private
    [JsonReflectAttribute(ctString, rtString, TMouseButtonInterceptor)]
    FButton : TMouseButton;
    FX      : Int64;
    FY      : Int64;
  public
    /// <summary>
    /// Indicates which mouse button was pressed during the click. One of left, right, wheel, back, or forward.
    /// </summary>
    property Button: TMouseButton read FButton write FButton;

    /// <summary>
    /// The x-coordinate where the click occurred.
    /// </summary>
    property X: Int64 read FX write FX;

    /// <summary>
    /// The y-coordinate where the click occurred.
    /// </summary>
    property Y: Int64 read FY write FY;
  end;

  TComputerActionDoubleClick = class(TComputerActionClick)
  end;

  TComputerActionDrag = class(TComputerActionDoubleClick)
  private
    FPath : TArray<TDragPoint>;
  public
    /// <summary>
    /// An array of coordinates representing the path of the drag action. Coordinates will appear as an array
    /// of objects, eg [ { x: 100, y: 200 }, { x: 200, y: 300 }
    /// </summary>
    property Path: TArray<TDragPoint> read FPath write FPath;

    destructor Destroy; override;
  end;

  TComputerActionKeyPressed = class(TComputerActionDrag)
  private
    FKeys : TArray<string>;
  public
    /// <summary>
    /// The combination of keys the model is requesting to be pressed. This is an array of strings, each representing a key.
    /// </summary>
    property Keys: TArray<string> read FKeys write FKeys;
  end;

  TComputerActionMove = class(TComputerActionKeyPressed)
  end;

  TComputerActionScreenshot = class(TComputerActionMove)
  end;

  TComputerActionScroll = class(TComputerActionScreenshot)
  private
    [JsonNameAttribute('scroll_x')]
    FScrollX : Int64;
    [JsonNameAttribute('scroll_y')]
    FScrollY : Int64;
  public
    /// <summary>
    /// The horizontal scroll distance.
    /// </summary>
    property ScrollX: Int64 read FScrollX write FScrollX;

    /// <summary>
    /// The vertical scroll distance.
    /// </summary>
    property ScrollY: Int64 read FScrollY write FScrollY;
  end;

  TComputerActionType = class(TComputerActionScroll)
  private
    FText : string;
  public
    /// <summary>
    /// The text to type.
    /// </summary>
    property Text: string read FText write FText;
  end;

  TComputerActionWait = class(TComputerActionType)
  end;

  {$REGION 'Dev note'}
  {--- This class is made up of the following classes:
     TComputerActionCommon,
     TComputerActionClick,
     TComputerActionDoubleClick,
     TComputerActionDrag,
     TComputerActionKeyPressed,
     TComputerActionMove,
     TComputerActionScreenshot,
     TComputerActionScroll,
     TComputerActionType
     TComputerActionWait}
  {$ENDREGION}
  TComputerAction = class(TComputerActionWait);

  /// <summary>
  /// The results of the file search tool call.
  /// </summary>
  /// <remarks>
  /// Inherits from TComputerAction because both tools have "Action" field in common !!!
  /// </remarks>
  TToolCallAction = class(TComputerAction)
  private
    FCommand           : TArray<string>;
    [JsonReflectAttribute(ctString, rtString, TMetadataInterceptor)]
    FEnv               : string;
    [JsonNameAttribute('timeout_ms')]
    FTimeout           : Int64;
    FUser              : string;
    [JsonNameAttribute('working_directory')]
    FWorkingDirectory  : string;
  public
    /// <summary>
    /// The command to run.
    /// </summary>
    property Command: TArray<string> read FCommand write FCommand;

    /// <summary>
    /// Environment variables to set for the command.
    /// </summary>
    property Env: string read FEnv write FEnv;

    /// <summary>
    /// Optional timeout in milliseconds for the command.
    /// </summary>
    property Timeout: Int64 read FTimeout write FTimeout;

    /// <summary>
    /// Optional user to run the command as.
    /// </summary>
    property User: string read FUser write FUser;

    /// <summary>
    /// Optional working directory to run the command in.
    /// </summary>
    property WorkingDirectory: string read FWorkingDirectory write FWorkingDirectory;
  end;

  TWebSearchAction = class(TToolCallAction)
  private
    FQuery   : string;
    FUrl     : string;
    FPattern : string;
    FSources : TArray<TSearchActionSource>;

  public
    /// <summary>
    /// The web search query.
    /// </summary>
    property Query: string read FQuery write FQuery;

    /// <summary>
    /// <para>
    /// - The URL opened by the model.
    /// </para>
    /// <para>
    /// - The URL of the page searched for the pattern.
    /// </para>
    /// </summary>
    property Url: string read FUrl write FUrl;

    /// <summary>
    /// The pattern or text to search for within the page.
    /// </summary>
    property Pattern: string read FPattern write FPattern;

    /// <summary>
    /// The sources used in the search.
    /// </summary>
    property Sources: TArray<TSearchActionSource> read FSources write FSources;

    destructor Destroy; override;
  end;

  TOpenPageAction = class(TWebSearchAction)
  end;

  TFindAction = class(TOpenPageAction)
  end;


  TAction = class(TFindAction);

  {$ENDREGION}

  {$REGION 'annotations'}

  TResponseMessageAnnotationCommon = class
  private
    [JsonReflectAttribute(ctString, rtString, TResponseAnnotationTypeInterceptor)]
    FType : TResponseAnnotationType;
  public
    /// <summary>
    /// The type of the file citation. One of file_citation, url_citation or file_path
    /// </summary>
    property &Type: TResponseAnnotationType read FType write FType;
  end;

  TAnnotationFileCitation = class(TResponseMessageAnnotationCommon)
  private
    [JsonNameAttribute('file_id')]
    FFileId   : string;
    FIndex    : Int64;
    FFilename : string;
  public
    /// <summary>
    /// The ID of the file.
    /// </summary>
    property FileId: string read FFileId write FFileId;

    /// <summary>
    /// The index of the file in the list of files.
    /// </summary>
    property Index: Int64 read FIndex write FIndex;

    /// <summary>
    /// The name of the file.
    /// </summary>
    property Filename: string read FFilename write FFilename;
  end;

  TAnnotationUrlCitation = class(TAnnotationFileCitation)
  private
    [JsonNameAttribute('end_index')]
    FEndIndex   : Int64;
    [JsonNameAttribute('start_index')]
    FStartIndex : Int64;
    FTitle      : string;
    FUrl        : string;
  public
    /// <summary>
    /// The index of the last character of the URL citation in the message.
    /// </summary>
    property EndIndex: Int64 read FEndIndex write FEndIndex;

    /// <summary>
    /// The index of the first character of the URL citation in the message.
    /// </summary>
    property StartIndex: Int64 read FStartIndex write FStartIndex;

    /// <summary>
    /// The title of the web resource.
    /// </summary>
    property Title: string read FTitle write FTitle;

    /// <summary>
    /// The URL of the web resource.
    /// </summary>
    property Url: string read FUrl write FUrl;
  end;

  TAnnotationContainerFileCitation = class(TAnnotationUrlCitation)
  private
    [JsonNameAttribute('container_id')]
    FContainerId : string;
  public
    /// <summary>
    /// The unique ID of the code interpreter tool call.
    /// </summary>
    property ContainerId: string read FContainerId write FContainerId;
  end;

  TAnnotationFilePath = class(TAnnotationContainerFileCitation)
  end;

  {$REGION 'Dev note'}
  {--- This class is made up of the following classes:
     TResponseMessageAnnotationCommon,
     TAnnotationFileCitation,
     TAnnotationUrlCitation,
     TAnnotationFilePath }
  {$ENDREGION}
  TResponseMessageAnnotation = class(TAnnotationFilePath);

  {$ENDREGION}

  {$REGION 'item content'}

  TItemInputAudio = class
  private
    FData   : string;
    FFormat : string;
  public
    /// <summary>
    /// Base64-encoded audio data.
    /// </summary>
    property Data: string read FData write FData;

    /// <summary>
    /// The format of the audio data. Currently supported formats are mp3 and wav.
    /// </summary>
    property Format: string read FFormat write FFormat;
  end;

  TResponseItemContentCommon = class
  private
    [JsonReflectAttribute(ctString, rtString, TResponseItemContentTypeInterceptor)]
    FType : TResponseItemContentType;
  public
    /// <summary>
    /// The type of the input item. One of input_text, input_image, input_file
    /// </summary>
    property &Type: TResponseItemContentType read FType write FType;
  end;

  TResponseItemContentTextInput = class(TResponseItemContentCommon)
  private
    FText : string;
  public
    /// <summary>
    /// The text input to the model.
    /// </summary>
    property Text: string read FText write FText;
  end;

  TResponseItemContentImageInput = class(TResponseItemContentTextInput)
  private
    [JsonReflectAttribute(ctString, rtString, TImageDetailInterceptor)]
    FDetail   : TImageDetail;
    [JsonNameAttribute('file_id')]
    FFileId   : string;
    [JsonNameAttribute('image_url')]
    FImageUrl : string;
  public
    /// <summary>
    /// The detail level of the image to be sent to the model. One of high, low, or auto. Defaults to auto.
    /// </summary>
    property Detail: TImageDetail read FDetail write FDetail;

    /// <summary>
    /// The ID of the file to be sent to the model.
    /// </summary>
    property FileId: string read FFileId write FFileId;

    /// <summary>
    /// The URL of the image to be sent to the model. A fully qualified URL or base64 encoded image in a data URL.
    /// </summary>
    property ImageUrl: string read FImageUrl write FImageUrl;
  end;

  TResponseItemContentFileInput = class(TResponseItemContentImageInput)
  private
    [JsonNameAttribute('file_data')]
    FFileData : string;
    FFilename : string;
    [JsonNameAttribute('file_url')]
    FFileUrl  : string;
  public
    /// <summary>
    /// The content of the file to be sent to the model.
    /// </summary>
    property FileData: string read FFileData write FFileData;

    /// <summary>
    /// The name of the file to be sent to the model.
    /// </summary>
    property Filename: string read FFilename write FFilename;

    /// <summary>
    /// The URL of the file to be sent to the model.
    /// </summary>
    property FileUrl: string read FFileUrl write FFileUrl;
  end;

  TResponseItemAudioInput = class(TResponseItemContentFileInput)
  private
    [JsonNameAttribute('input_audio')]
    FInputAudio : TItemInputAudio;
  public
    /// <summary>
    ///  An audio input to the model.
    /// </summary>
    property InputAudio: TItemInputAudio read FInputAudio write FInputAudio;
    destructor Destroy; override;
  end;

  TResponseItemContentOutputText = class(TResponseItemAudioInput)
  private
    FAnnotations : TArray<TResponseMessageAnnotation>;
    FLogprobs    : TArray<TLogprobs>;
  public
    /// <summary>
    /// The annotations of the text output.
    /// </summary>
    property Annotations: TArray<TResponseMessageAnnotation> read FAnnotations write FAnnotations;

    /// <summary>
    /// Array of logprobs values
    /// </summary>
    property Logprobs: TArray<TLogprobs> read FLogprobs write FLogprobs;

    destructor Destroy; override;
  end;

  TResponseItemContentRefusal = class(TResponseItemContentOutputText)
  private
    FRefusal : string;
  public
    /// <summary>
    /// The refusal explanationfrom the model.
    /// </summary>
    property Refusal: string read FRefusal write FRefusal;
  end;

  {$REGION 'Dev note'}
  {--- This class is made up of the following classes:
     TResponseItemContentCommon,
     TResponseItemContentTextInput,
     TResponseItemContentImageInput,
     TResponseItemContentFileInput,
     TResponseItemContentOutputText,
     TResponseItemContentRefusal}
  {$ENDREGION}
  TResponseItemContent = class(TResponseItemContentRefusal);

  {$ENDREGION}

  {$REGION 'Response item'}

    {$REGION 'Dev note'}
(******************************************************************************

  TResponseItem différent from TResponseOutput from GenAI.Responses unit
  ======================================================================

  At first glance, one might think to directly reuse the architecture of the
  TResponseOutput class (from the GenAI.Responses unit). In reality, however,
  the classes that make it up differ slightly—or are even missing
  entirely—depending on the category.

  Therefore, we need to build TResponseItem entirely from scratch. Although
  this makes the code more substantial, it guarantees that the class retains
  a single, focused responsibility and continues to support automatic
  deserialization.

*******************************************************************************)
    {$ENDREGION}

    {$REGION 'code interpreter output'}

  TCodeInterpreterOutput = class
  private
    FType : string;
    FLogs : string;
    FUrl  : string;
  public
    property &Type: string read FType write FType;
    property Logs: string read FLogs write FLogs;
    property Url: string read FUrl write FUrl;
  end;

    {$ENDREGION}

    {$REGION 'code interpreter file search result'}

    /// <summary>
  /// The output of a code interpreter tool call that is a file.
  /// </summary>
  TCodeInterpreterResultFiles = class
  private
    [JsonNameAttribute('file_id')]
    FFileId   : string;
    [JsonNameAttribute('mime_type')]
    FMimeType : string;
  public
    /// <summary>
    /// The ID of the file.
    /// </summary>
    property FileId: string read FFileId write FFileId;

    /// <summary>
    /// The MIME type of the file.
    /// </summary>
    property MimeType: string read FMimeType write FMimeType;
  end;

  TCodeInterpreterResult = class
  private
    FLogs  : string;
    FType  : string;
    FFiles : TArray<TCodeInterpreterResultFiles>;
  public
    /// <summary>
    /// The logs of the code interpreter tool call.
    /// </summary>
    property Logs: string read FLogs write FLogs;

    /// <summary>
    /// The output of a code interpreter tool call that is a file.
    /// </summary>
    property &Type: string read FType write FType;

    /// <summary>
    /// The output of a code interpreter tool call that is a file.
    /// </summary>
    property Files: TArray<TCodeInterpreterResultFiles> read FFiles write FFiles;

    destructor Destroy; override;
  end;

  /// <summary>
  /// The results of the file search tool call.
  /// </summary>
  /// <remarks>
  /// Inherits from TCodeInterpreterResult because both tools have a Results field in common !!!
  /// </remarks>
  TFileSearchResult = class(TCodeInterpreterResult)
  private
    [JsonReflectAttribute(ctString, rtString, TMetadataInterceptor)]
    FAttributes : string;
    [JsonNameAttribute('file_id')]
    FFileId     : string;
    FFilename   : string;
    FScore      : Double;
    FText       : string;
  public
    /// <summary>
    /// Set of 16 key-value pairs that can be attached to an object. This can be useful for storing additional information
    /// about the object in a structured format, and querying for objects via API or the dashboard. Keys are strings with
    /// a maximum length of 64 characters. Values are strings with a maximum length of 512 characters, booleans, or numbers.
    /// </summary>
    property Attributes: string read FAttributes write FAttributes;

    /// <summary>
    /// The unique ID of the file.
    /// </summary>
    property FileId: string read FFileId write FFileId;

    /// <summary>
    /// The name of the file.
    /// </summary>
    property Filename: string read FFilename write FFilename;

    /// <summary>
    /// The relevance score of the file - a value between 0 and 1.
    /// </summary>
    property Score: Double read FScore write FScore;

    /// <summary>
    /// The text that was retrieved from the file.
    /// </summary>
    property Text: string read FText write FText;
  end;

    {$ENDREGION}

    {$REGION 'MCP list tool'}

  TMCPListTool = class
  private
    [JsonReflectAttribute(ctString, rtString, TMetadataInterceptor)]
    [JsonNameAttribute('input_schema')]
    FInputSchema : string;
    FName        : string;
    FDescription : string;
    {$REGION  'Dev notes'}
    (*
         FAnnotations: string > Automatic deserialization not possible-
            Ambiguous object or name already used

         Access to field contents from JSONResponse string possible
    *)
    {$ENDREGION}
  public
    /// <summary>
    /// The JSON schemas string describing the tool's input.
    /// </summary>
    property InputSchema: string read FInputSchema write FInputSchema;

    /// <summary>
    /// The name of the tool.
    /// </summary>
    property Name: string read FName write FName;

    /// <summary>
    /// The description of the tool.
    /// </summary>
    property Description: string read FDescription write FDescription;
  end;

    {$ENDREGION}

    {$REGION 'pending safety checks'}

  TPendingSafetyChecks = class
  private
    FCode    : string;
    FId      : string;
    FMessage : string;
  public
    /// <summary>
    /// The type of the pending safety check.
    /// </summary>
    property Code: string read FCode write FCode;

    /// <summary>
    /// The ID of the pending safety check.
    /// </summary>
    property Id: string read FId write FId;

    /// <summary>
    /// Details about the pending safety check.
    /// </summary>
    property Message: string read FMessage write FMessage;
  end;

    {$ENDREGION}

    {$REGION 'computer output'}

  TComputerOutput = class
  private
    FType     : string;
    [JsonNameAttribute('file_id')]
    FFileId   : string;
    [JsonNameAttribute('image_url')]
    FImageUrl : string;
    FText     : string;
  public
    /// <summary>
    /// The identifier of an uploaded file that contains the screenshot.
    /// </summary>
    property FileId: string read FFileId write FFileId;

    /// <summary>
    /// The URL of the screenshot image.
    /// </summary>
    property ImageUrl: string read FImageUrl write FImageUrl;

    /// <summary>
    /// Specifies the event type. For a computer screenshot, this property is always set to computer_screenshot.
    /// </summary>
    property &Type: string read FType write FType;

    /// <summary>
    /// <para>
    /// - The output from the tool call.
    /// </para>
    /// <para>
    /// - The output from the custom tool call generated by your code.
    /// </para>
    /// <para>
    /// - A JSON string of the output of the local shell tool call.
    /// </para>
    /// </summary>
    property Text: string read FText write FText;
  end;

    {$ENDREGION}

    {$REGION 'acknowledge safety check'}

  TAcknowledgedSafetyCheck = class
  private
    FCode    : string;
    FId      : string;
    FMessage : string;
  public
    /// <summary>
    /// The type of the pending safety check.
    /// </summary>
    property Code: string read FCode write FCode;

    /// <summary>
    /// The ID of the pending safety check.
    /// </summary>
    property Id: string read FId write FId;

    /// <summary>
    /// Details about the pending safety check.
    /// </summary>
    property Message: string read FMessage write FMessage;
  end;

    {$ENDREGION}

  TResponseItemCommon = class(TJSONFingerprint)
  private
    [JsonReflectAttribute(ctString, rtString, TResponseTypesInterceptor)]
    FType    : TResponseTypes;
    FStatus  : string;
    FId      : string;
  public
    /// <summary>
    /// The unique ID of the object.
    /// </summary>
    property Id: string read FId write FId;

    /// <summary>
    /// The status of item. One of in_progress, completed, or incomplete. Populated when items are returned via API.
    /// </summary>
    property Status: string read FStatus write FStatus;

    /// <summary>
    /// The type of the object input.
    /// </summary>
    property &Type: TResponseTypes read FType write FType;
  end;

  TResponseItemInputMessage = class(TResponseItemCommon)
  private
    [JsonReflectAttribute(ctString, rtString, TRoleInterceptor)]
    FRole    : TRole;
    FContent : TArray<TResponseItemContent>;
  public
    /// <summary>
    /// The role of the message input. One of user, system, or developer.
    /// </summary>
    property Role: TRole read FRole write FRole;

    /// <summary>
    /// A list of one or many input items to the model, containing different content types.
    /// </summary>
    property Content: TArray<TResponseItemContent> read FContent write FContent;
    destructor Destroy; override;
  end;

  TResponseItemOutputMessage = class(TResponseItemInputMessage)
  end;

  TResponseItemFileSearchToolCall = class(TResponseItemOutputMessage)
  private
    FQueries : TArray<string>;
    FResults : TArray<TFileSearchResult>;
  public
    /// <summary>
    /// The queries used to search for files.
    /// </summary>
    property Queries: TArray<string> read FQueries write FQueries;

    /// <summary>
    /// The results of the file search tool call.
    /// </summary>
    property Results: TArray<TFileSearchResult> read FResults write FResults;

    destructor Destroy; override;
  end;

  TResponseItemComputerToolCall = class(TResponseItemFileSearchToolCall)
  private
    [JsonNameAttribute('call_id')]
    FCallId              : string;
    FAction              : TAction;
    [JsonNameAttribute('pending_safety_checks')]
    FPendingSafetyChecks : TArray<TPendingSafetyChecks>;
  public
    /// <summary>
    /// Action to execute on computer
    /// </summary>
    property Action: TAction read FAction write FAction;

    /// <summary>
    /// An identifier used when responding to the tool call with output.
    /// </summary>
    property CallId: string read FCallId write FCallId;

    /// <summary>
    /// The pending safety checks for the computer call.
    /// </summary>
    property PendingSafetyChecks: TArray<TPendingSafetyChecks> read FPendingSafetyChecks write FPendingSafetyChecks;

    destructor Destroy; override;
  end;

  TResponseItemComputerToolCallOutput = class(TResponseItemComputerToolCall)
  private
    [JsonNameAttribute('acknowledged_safety_checks')]
    FAcknowledgedSafetyChecks : TArray<TAcknowledgedSafetyCheck>;
    FOutput                   : TComputerOutput;
  public
    /// <summary>
    /// A computer screenshot image used with the computer use tool.
    /// </summary>
    property Output: TComputerOutput read FOutput write FOutput;

    /// <summary>
    /// The safety checks reported by the API that have been acknowledged by the developer.
    /// </summary>
    property AcknowledgedSafetyChecks: TArray<TAcknowledgedSafetyCheck> read FAcknowledgedSafetyChecks write FAcknowledgedSafetyChecks;

    destructor Destroy; override;
  end;

  TResponseItemWebSearchToolCall = class(TResponseItemComputerToolCallOutput)
  end;

  TResponseItemFunctionToolCall = class(TResponseItemWebSearchToolCall)
  private
    FArguments : string;
    FName      : string;
  public
    /// <summary>
    /// A JSON string of the arguments to pass to the function.
    /// </summary>
    property Arguments: string read FArguments write FArguments;

    /// <summary>
    /// The name of the function to run.
    /// </summary>
    property Name: string read FName write FName;
  end;

  TResponseItemFunctionToolCallOutput = class(TResponseItemFunctionToolCall)
  end;

  TResponseItemImageGeneration = class(TResponseItemFunctionToolCallOutput)
  private
    FResult : string;
  public
    /// <summary>
    /// The generated image encoded in base64.
    /// </summary>
    property Result: string read FResult write FResult;
  end;

  TResponseItemCodeInterpreter = class(TResponseItemImageGeneration)
  private
    [JsonNameAttribute('container_id')]
    FContainerId : string;
    FOutputs     : TArray<TCodeInterpreterOutput>;
    FCode        : string;
  public
    /// <summary>
    /// The code to run.
    /// </summary>
    property Code: string read FCode write FCode;

    /// <summary>
    /// The ID of the container used to run the code.
    /// </summary>
    property ContainerId: string read FContainerId write FContainerId;

    /// <summary>
    /// The outputs generated by the code interpreter, such as logs or images. Can be null if no outputs are available.
    /// </summary>
    property Outputs: TArray<TCodeInterpreterOutput> read FOutputs write FOutputs;

    destructor Destroy; override;
  end;

  TResponseItemLocalShellCall = class(TResponseItemCodeInterpreter)
  end;

  TResponseItemLocalShellCallOutput = class(TResponseItemLocalShellCall)
  end;

  TResponseItemMCPTool = class(TResponseItemLocalShellCallOutput)
  private
    [JsonNameAttribute('server_label')]
    FServerLabel : string;
    FError       : string;
  public
    /// <summary>
    /// The label of the MCP server running the tool.
    /// </summary>
    property ServerLabel: string read FServerLabel write FServerLabel;

    /// <summary>
    /// The error from the tool call, if any.
    /// </summary>
    property Error: string read FError write FError;
  end;

  TResponseItemMCPList = class(TResponseItemMCPTool)
  private
    FTools : TArray<TMCPListTool>;
  public
    /// <summary>
    /// The tools available on the server.
    /// </summary>
    property Tools: TArray<TMCPListTool> read FTools write FTools;

    destructor Destroy; override;
  end;

  TResponseItemMCPApprovalRequest = class(TResponseItemMCPList)
  end;

  TResponseItemMCPApprovalResponse = class(TResponseItemMCPApprovalRequest)
  private
    [JsonNameAttribute('approval_request_id')]
    FApprovalRequestId : string;
    FApprove           : Boolean;
    FReason            : string;
  public
    /// <summary>
    /// The ID of the approval request being answered.
    /// </summary>
    property ApprovalRequestId: string read FApprovalRequestId write FApprovalRequestId;

    /// <summary>
    /// Whether the request was approved.
    /// </summary>
    property Approve: Boolean read FApprove write FApprove;

    /// <summary>
    /// Optional reason for the decision.
    /// </summary>
    property Reason: string read FReason write FReason;
  end;

  TResponseItemMCPToolCall = class(TResponseItemMCPApprovalResponse)
  end;

  {$REGION 'Dev note'}
  {--- This class is made up of the following classes:
    TResponseItemCommon,
    TResponseItemInputMessage,
    TResponseItemOutputMessage,
    TResponseItemFileSearchToolCall,
    TResponseItemComputerToolCall,
    TResponseItemComputerToolCallOutput,
    TResponseItemWebSearchToolCall,
    TResponseItemFunctionToolCall,
    TResponseItemFunctionToolCallOutput,
    TResponseItemImageGeneration,
    TResponseItemCodeInterpreter,
    TResponseItemLocalShellCall,
    TResponseItemMCPTool,
    TResponseItemMCPApprovalRequest,
    TResponseItemMCPApprovalResponse
  }
  {$ENDREGION}
  TResponseItem = class(TResponseItemMCPToolCall);

  {$ENDREGION}

  TResponses = class(TJSONFingerprint)
  private
    [JsonNameAttribute('first_id')]
    FFirstId : string;
    [JsonNameAttribute('has_more')]
    FHasMore : Boolean;
    [JsonNameAttribute('last_id')]
    FLastId  : string;
    FObject  : string;
    FData    : TArray<TResponseItem>;
  public
    /// <summary>
    /// A list of items used to generate this response.
    /// </summary>
    property Data: TArray<TResponseItem> read FData write FData;

    /// <summary>
    /// The ID of the first item in the list.
    /// </summary>
    property FirstId: string read FFirstId write FFirstId;

    /// <summary>
    /// Whether there are more items available.
    /// </summary>
    property HasMore: Boolean read FHasMore write FHasMore;

    /// <summary>
    /// The ID of the last item in the list.
    /// </summary>
    property LastId: string read FLastId write FLastId;

    /// <summary>
    /// The type of object returned, must be list.
    /// </summary>
    property &Object: string read FObject write FObject;

    destructor Destroy; override;
  end;

implementation

  {$REGION 'Dev note'}
(*
      GenAI.Responses.InputItemList — Inheritance Documentation
      =========================================================
      Version: internal developer reference
      Language: Delphi / Object Pascal
      Context: Response data models for GenAI framework
      ---------------------------------------------------------


      INTRODUCTION
      ------------

      This document represents the inheritance tree and class relationships defined
      in the unit GenAI.Responses.InputItemList. It is meant as a quick reference
      for developers who need to understand the object model without reading the full
      source code.

      Each section focuses on one functional family of classes. Under each class,
      children are shown with indentation to represent inheritance.

      Legend:
        - |__ means "inherits from"
        - Comments describe the purpose and usage of each group.


      ---------------------------------------------------------
      1. COMPUTER ACTIONS AND TOOL CALLS
      ---------------------------------------------------------

      These classes represent user-computer interactions and tool execution
      requests/responses. They form the backbone of automation events.

      TComputerActionCommon
        |__ TComputerActionClick
              |__ TComputerActionDoubleClick
                    |__ TComputerActionDrag
                          |__ TComputerActionKeyPressed
                                |__ TComputerActionMove
                                      |__ TComputerActionScreenshot
                                            |__ TComputerActionScroll
                                                  |__ TComputerActionType
                                                        |__ TComputerActionWait
                                                              |__ TComputerAction

      TComputerAction
        |__ TToolCallAction
              |__ TWebSearchAction
                    |__ TOpenPageAction
                          |__ TFindAction
                                |__ TAction

      Explanation:
      - TComputerActionCommon is the root for mouse/keyboard/screen actions.
      - Derived types progressively add details: click → drag → key press, etc.
      - TToolCallAction extends computer actions with shell commands and web calls.
      - TAction is the ultimate unified action type used in tool calls.


      ---------------------------------------------------------
      2. ANNOTATIONS (CITATIONS AND PATHS)
      ---------------------------------------------------------

      These classes describe citations and references used in model responses.

      TResponseMessageAnnotationCommon
        |__ TAnnotationFileCitation
              |__ TAnnotationUrlCitation
                    |__ TAnnotationContainerFileCitation
                          |__ TAnnotationFilePath
                                |__ TResponseMessageAnnotation

      Explanation:
      - Used to annotate text responses with references to files, URLs, or code
        containers.
      - Hierarchy refines the type of annotation from generic → file → URL → container.


      ---------------------------------------------------------
      3. ITEM CONTENT (INPUT / OUTPUT)
      ---------------------------------------------------------

      Classes describing input elements provided to the model or output generated by it.

      TResponseItemContentCommon
        |__ TResponseItemContentTextInput
              |__ TResponseItemContentImageInput
                    |__ TResponseItemContentFileInput
                          |__ TResponseItemAudioInput
                                |__ TResponseItemContentOutputText
                                      |__ TResponseItemContentRefusal
                                            |__ TResponseItemContent

      Explanation:
      - Starts with generic content → text → image → file → audio → text output.
      - Final TResponseItemContent is the root for all input/output content types.


      ---------------------------------------------------------
      4. CODE INTERPRETER AND FILE SEARCH RESULTS
      ---------------------------------------------------------

      Results produced by code execution or file searching tools.

      TCodeInterpreterResult
        |__ TFileSearchResult

      Explanation:
      - TCodeInterpreterResult represents code execution logs and outputs.
      - TFileSearchResult adds metadata such as score, attributes, and retrieved text.


      ---------------------------------------------------------
      5. RESPONSE ITEM HIERARCHY
      ---------------------------------------------------------

      This is the central class tree representing all possible response items
      returned by the API.

      TResponseItemCommon
        |__ TResponseItemInputMessage
              |__ TResponseItemOutputMessage
                    |__ TResponseItemFileSearchToolCall
                          |__ TResponseItemComputerToolCall
                                |__ TResponseItemComputerToolCallOutput
                                      |__ TResponseItemWebSearchToolCall
                                            |__ TResponseItemFunctionToolCall
                                                  |__ TResponseItemFunctionToolCallOutput
                                                        |__ TResponseItemImageGeneration
                                                              |__ TResponseItemCodeInterpreter
                                                                    |__ TResponseItemLocalShellCall
                                                                          |__ TResponseItemLocalShellCallOutput
                                                                                |__ TResponseItemMCPTool
                                                                                      |__ TResponseItemMCPList
                                                                                            |__ TResponseItemMCPApprovalRequest
                                                                                                  |__ TResponseItemMCPApprovalResponse
                                                                                                        |__ TResponseItemMCPToolCall
                                                                                                              |__ TResponseItem

      Explanation:
      - This chain represents the entire lifecycle of responses:
        - Input/Output messages
        - Tool calls (file search, computer, web, function)
        - Code execution and image generation
        - Local shell calls and MCP (Model Control Protocol) tool calls
      - TResponseItem is the most derived and complete form.


      ---------------------------------------------------------
      6. LIST WRAPPER
      ---------------------------------------------------------

      TJSONFingerprint
        |__ TResponses

      Explanation:
      - TResponses is a wrapper for paginated API responses containing multiple TResponseItem objects.


      ---------------------------------------------------------
      7. STANDALONE CLASSES
      ---------------------------------------------------------

      The following classes inherit directly from TObject and have no specialized
      subclasses in this unit:

      - TTopLogprobs
      - TLogprobs
      - TSearchActionSource
      - TDragPoint
      - TCodeInterpreterOutput
      - TCodeInterpreterResultFiles
      - TMCPListTool
      - TPendingSafetyChecks
      - TComputerOutput
      - TAcknowledgedSafetyCheck
      - TItemInputAudio

      Explanation:
      - These are helper/data container types used by higher-level objects.
      - They hold structured data (e.g., log probabilities, search sources, audio data).
*)

  {$ENDREGION}

{ TResponseItemContentOutputText }

destructor TResponseItemContentOutputText.Destroy;
begin
  for var Item in FAnnotations do
    Item.Free;
  for var Item in FLogprobs do
    Item.Free;
  inherited;
end;

{ TResponseItemInputMessage }

destructor TResponseItemInputMessage.Destroy;
begin
  for var Item in FContent do
    Item.Free;
  inherited;
end;

{ TResponseItemFileSearchToolCall }

destructor TResponseItemFileSearchToolCall.Destroy;
begin
  for var Item in FResults do
    Item.Free;
  inherited;
end;

{ TComputerActionDrag }

destructor TComputerActionDrag.Destroy;
begin
  for var Item in FPath do
    Item.Free;
  inherited;
end;

{ TResponseItemComputerToolCall }

destructor TResponseItemComputerToolCall.Destroy;
begin
  if Assigned(FAction) then
    FAction.Free;
  for var Item in FPendingSafetyChecks do
    Item.Free;
  inherited;
end;

{ TResponseItemComputerToolCallOutput }

destructor TResponseItemComputerToolCallOutput.Destroy;
begin
  if Assigned(FOutput) then
    FOutput.Free;
  for var Item in FAcknowledgedSafetyChecks do
    Item.Free;
  inherited;
end;

{ TResponses }

destructor TResponses.Destroy;
begin
  for var Item in FData do
    Item.Free;
  inherited;
end;

{ TCodeInterpreterResult }

destructor TCodeInterpreterResult.Destroy;
begin
  for var Item in FFiles do
    Item.Free;
  inherited;
end;

{ TResponseItemMCPList }

destructor TResponseItemMCPList.Destroy;
begin
  for var Item in FTools do
    Item.Free;
  inherited;
end;

{ TLogprobs }

destructor TLogprobs.Destroy;
begin
  for var Item in FTopLogprobs do
    Item.Free;
  inherited;
end;

{ TResponseItemCodeInterpreter }

destructor TResponseItemCodeInterpreter.Destroy;
begin
  for var Item in FOutputs do
    Item.Free;
  inherited;
end;

{ TWebSearchAction }

destructor TWebSearchAction.Destroy;
begin
  for var Item in FSources do
    Item.Free;
  inherited;
end;

{ TResponseItemAudioInput }

destructor TResponseItemAudioInput.Destroy;
begin
  if Assigned(FInputAudio) then
    FInputAudio.Free;
  inherited;
end;

end.
