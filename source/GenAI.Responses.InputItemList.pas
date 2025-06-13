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
  /// <summary>
  /// The output of a code interpreter tool call that is a file.
  /// </summary>
  TCodeInterpreterResultFiles = class
  private
    [JsonNameAttribute('file_id')]
    FFileId: string;
    [JsonNameAttribute('mime_type')]
    FMimeType: string;
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
    FLogs: string;
    FType: string;
    FFiles: TArray<TCodeInterpreterResultFiles>;
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
    FAttributes: string;
    [JsonNameAttribute('file_id')]
    FFileId: string;
    FFilename: string;
    FScore: Double;
    FText: string;
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

  TMCPListTool = class
  private
    [JsonNameAttribute('input_schema')]
    FInputSchema: string;
    FDescription: string;
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
    /// The description of the tool.
    /// </summary>
    property Description: string read FDescription write FDescription;
  end;

  TDragPoint = class
  private
    FX: Int64;
    FY: Int64;
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

  TPendingSafetyChecks = class
  private
    FCode: string;
    FId: string;
    FMessage: string;
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

  TComputerOutput = class
  private
    FType: string;
    [JsonNameAttribute('file_id')]
    FFileId: string;
    [JsonNameAttribute('image_url')]
    FImageUrl: string;
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
  end;

  TAcknowledgedSafetyCheck = class
  private
    FCode: string;
    FId: string;
    FMessage: string;
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

  TComputerActionCommon = class
  private
    FType: string;
  public
    /// <summary>
    /// Specifies the event type.
    /// </summary>
    property &Type: string read FType write FType;
  end;

  TComputerActionClick = class(TComputerActionCommon)
  private
    [JsonReflectAttribute(ctString, rtString, TMouseButtonInterceptor)]
    FButton: TMouseButton;
    FX: Int64;
    FY: Int64;
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
    {--- This class does not introduce any new functionality; all methods and properties
         are inherited from its ancestor. }
  end;

  TComputerActionDrag = class(TComputerActionDoubleClick)
  private
    FPath: TArray<TDragPoint>;
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
    FKeys: TArray<string>;
  public
    /// <summary>
    /// The combination of keys the model is requesting to be pressed. This is an array of strings, each representing a key.
    /// </summary>
    property Keys: TArray<string> read FKeys write FKeys;
  end;

  TComputerActionMove = class(TComputerActionKeyPressed)
    {--- This class does not introduce any new functionality; all methods and properties
         are inherited from its ancestor. }
  end;

  TComputerActionScreenshot = class(TComputerActionMove)
    {--- This class does not introduce any new functionality; all methods and properties
         are inherited from its ancestor. }
  end;

  TComputerActionScroll = class(TComputerActionScreenshot)
  private
     {--- X and Y are already described in TComputerActionClick }
    [JsonNameAttribute('scroll_x')]
    FScrollX: Int64;
    [JsonNameAttribute('scroll_y')]
    FScrollY: Int64;
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
    FText: string;
  public
    /// <summary>
    /// The text to type.
    /// </summary>
    property Text: string read FText write FText;
  end;

  TComputerActionWait = class(TComputerActionType)
    {--- This class does not introduce any new functionality; all methods and properties
         are inherited from its ancestor. }
  end;

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
  TComputerAction = class(TComputerActionWait);

  /// <summary>
  /// The results of the file search tool call.
  /// </summary>
  /// <remarks>
  /// Inherits from TComputerAction because both tools have "Action" field in common !!!
  /// </remarks>
  TToolCallAction = class(TComputerAction)
  private
    FCommand: TArray<string>;
    FEnv: string;
    [JsonNameAttribute('timeout_ms')]
    FTimeout: Int64;
    FUser: string;
    [JsonNameAttribute('working_directory')]
    FWorkingDirectory: string;
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

  TAction = class(TToolCallAction);

  TResponseMessageAnnotationCommon = class
  private
    [JsonReflectAttribute(ctString, rtString, TResponseAnnotationTypeInterceptor)]
    FType: TResponseAnnotationType;
  public
    /// <summary>
    /// The type of the file citation. One of file_citation, url_citation or file_path
    /// </summary>
    property &Type: TResponseAnnotationType read FType write FType;
  end;

  TAnnotationFileCitation = class(TResponseMessageAnnotationCommon)
  private
    [JsonNameAttribute('file_id')]
    FFileId: string;
    FIndex: Int64;
    FFilename: string;
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
    FEndIndex: Int64;
    [JsonNameAttribute('start_index')]
    FStartIndex: Int64;
    FTitle: string;
    FUrl: string;
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

  TAnnotationFilePath = class(TAnnotationUrlCitation)
    {--- This class does not introduce any new functionality; all methods and properties
         are inherited from its ancestor. }
  end;

  {--- This class is made up of the following classes:
     TResponseMessageAnnotationCommon,
     TAnnotationFileCitation,
     TAnnotationUrlCitation,
     TAnnotationFilePath }
  TResponseMessageAnnotation = class(TAnnotationFilePath);

  TResponseItemContentCommon = class
  private
    [JsonReflectAttribute(ctString, rtString, TResponseItemContentTypeInterceptor)]
    FType: TResponseItemContentType;
  public
    /// <summary>
    /// The type of the input item. One of input_text, input_image, input_file
    /// </summary>
    property &Type: TResponseItemContentType read FType write FType;
  end;

  TResponseItemContentTextInput = class(TResponseItemContentCommon)
  private
    FText: string;
  public
    /// <summary>
    /// The text input to the model.
    /// </summary>
    property Text: string read FText write FText;
  end;

  TResponseItemContentImageInput = class(TResponseItemContentTextInput)
  private
    [JsonReflectAttribute(ctString, rtString, TImageDetailInterceptor)]
    FDetail: TImageDetail;
    [JsonNameAttribute('file_id')]
    FFileId: string;
    [JsonNameAttribute('image_url')]
    FImageUrl: string;
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
    FFileData: string;
    FFilename: string;
  public
    /// <summary>
    /// The content of the file to be sent to the model.
    /// </summary>
    property FileData: string read FFileData write FFileData;

    /// <summary>
    /// The name of the file to be sent to the model.
    /// </summary>
    property Filename: string read FFilename write FFilename;
  end;

  TResponseItemContentOutputText = class(TResponseItemContentFileInput)
  private
    FAnnotations: TArray<TResponseMessageAnnotation>;
  public
    /// <summary>
    /// The annotations of the text output.
    /// </summary>
    property Annotations: TArray<TResponseMessageAnnotation> read FAnnotations write FAnnotations;

    destructor Destroy; override;
  end;

  TResponseItemContentRefusal = class(TResponseItemContentOutputText)
  private
    FRefusal: string;
  public
    /// <summary>
    /// The refusal explanationfrom the model.
    /// </summary>
    property Refusal: string read FRefusal write FRefusal;
  end;

  {--- This class is made up of the following classes:
     TResponseItemContentCommon,
     TResponseItemContentTextInput,
     TResponseItemContentImageInput,
     TResponseItemContentFileInput,
     TResponseItemContentOutputText,
     TResponseItemContentRefusal}
  TResponseItemContent = class(TResponseItemContentRefusal);

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

  TResponseItemCommon = class
  private
    FId: string;
    [JsonReflectAttribute(ctString, rtString, TResponseTypesInterceptor)]
    FType: TResponseTypes;
    FStatus: string;
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
    FRole: TRole;
    FContent: TArray<TResponseItemContent>;
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
    {--- This class does not introduce any new functionality; all methods and properties
         are inherited from its ancestor. }
  end;

  TResponseItemFileSearchToolCall = class(TResponseItemOutputMessage)
  private
    FQueries: TArray<string>;
    FResults: TArray<TFileSearchResult>;
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
    FAction: TAction;
    [JsonNameAttribute('call_id')]
    FCallId: string;
    [JsonNameAttribute('pending_safety_checks')]
    FPendingSafetyChecks: TArray<TPendingSafetyChecks>;
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
    FOutput: TComputerOutput;
    [JsonNameAttribute('acknowledged_safety_checks')]
    FAcknowledgedSafetyChecks: TArray<TAcknowledgedSafetyCheck>;
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
    {--- This class does not introduce any new functionality; all methods and properties
         are inherited from its ancestor. }
  end;

  TResponseItemFunctionToolCall = class(TResponseItemWebSearchToolCall)
  private
    FArguments: string;
    FName: string;
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
  private
    {---
         FOutput: string > Automatic deserialization not possible-
            name already used as TComputerOutput by TResponseItemComputerToolCallOutput class

         Access to field contents from JSONResponse string possible
    }
  end;

  TResponseItemImageGeneration = class(TResponseItemFunctionToolCallOutput)
  private
    FResult: string;
  public
    /// <summary>
    /// The generated image encoded in base64.
    /// </summary>
    property Result: string read FResult write FResult;
  end;

  TResponseItemCodeInterpreter = class(TResponseItemImageGeneration)
  private
    FCode: string;
    [JsonNameAttribute('container_id')]
    FContainerId: string;
    {
      FResults: intercepted by TResponseOutputFileSearch (property in common)
    }
  public
    /// <summary>
    /// The code to run.
    /// </summary>
    property Code: string read FCode write FCode;

    /// <summary>
    /// The ID of the container used to run the code.
    /// </summary>
    property ContainerId: string read FContainerId write FContainerId;
  end;

  TResponseItemLocalShell = class(TResponseItemCodeInterpreter)
    {
      FAction: intercepted by TResponseOutputComputer (property in common)
      FCallId: intercepted by TResponseOutputFunction (property in common)
    }
  end;

  TResponseItemMCPTool = class(TResponseItemLocalShell)
  private
    {
      FArguments: intercepted by TResponseOutputFunction (property in common)
    }
    [JsonNameAttribute('server_label')]
    FServerLabel: string;
    FError: string;
    FOutput: string;
  public
    /// <summary>
    /// The label of the MCP server running the tool.
    /// </summary>
    property ServerLabel: string read FServerLabel write FServerLabel;

    /// <summary>
    /// The error from the tool call, if any.
    /// </summary>
    property Error: string read FError write FError;

    /// <summary>
    /// The output from the tool call.
    /// </summary>
    property Output: string read FOutput write FOutput;
  end;

  TResponseItemMCPList = class(TResponseItemMCPTool)   
  private
    FTools: TArray<TMCPListTool>;
  public
    property Tools: TArray<TMCPListTool> read FTools write FTools;

    destructor Destroy; override;
  end;

  TResponseItemMCPApproval = class(TResponseItemMCPList)
    {
      FArguments: intercepted by TResponseOutputFunction (property in common)
      FServerLabel: intercepted by TResponseOutputMCPTool (property in common)
    }
  end;

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
    TResponseItemLocalShell,
    TResponseItemMCPTool,
    TResponseItemMCPApproval
  }
  TResponseItem = class(TResponseItemMCPApproval);

(*
    End TResponseItem definition

 ******************************************************************************)

  TResponses = class(TJSONFingerprint)
  private
    [JsonNameAttribute('first_id')]
    FFirstId: string;
    [JsonNameAttribute('has_more')]
    FHasMore: Boolean;
    [JsonNameAttribute('last_id')]
    FLastId: string;
    FObject: string;
    FData: TArray<TResponseItem>;
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

{ TResponseItemContentOutputText }

destructor TResponseItemContentOutputText.Destroy;
begin
  for var Item in FAnnotations do
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

end.
