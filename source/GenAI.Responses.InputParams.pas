unit GenAI.Responses.InputParams;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGenAI
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.SysUtils, System.Classes, System.Threading, System.JSON, REST.Json.Types,
  REST.JsonReflect,
  GenAI.API.Params, GenAI.API, GenAI.Consts, GenAI.Schema, GenAI.Types;

type
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
    /// The name of the file to be sent to the model.
    /// </summary>
    function FileName(const Value: string): TItemContent;

    class function NewText: TItemContent;
    class function NewImage: TItemContent; overload;
    class function NewImage(const Value: string; const Detail: string = 'auto'): TItemContent; overload;
    class function NewFile: TItemContent;
    class function NewFileData(const FileLocation: string): TItemContent;
  end;

  /// <summary>
  /// Value is TInputListItem or his descendant e.g. TInputMessage, TItemInputMessage, TItemOutputMessage,
  /// TItemOutputMessage, TFileSearchToolCall, TComputerToolCall, TInputItemReference
  /// </summary>
  TInputListItem = class(TJSONParam);

  TInputMessage = class(TInputListItem)
  public
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

  TItemInputMessage = class(TInputMessage)
  public
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

  TInputItemReference = class(TInputListItem)
  public
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

  TOutputNotation = class(TJSONParam)
  public
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
  public
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
    function Annotations(const Value: TArray<TOutputNotation>): TOutputMessageContent;
    /// <summary>
    /// The refusal explanationfrom the model.
    /// </summary>
    function Refusal(const Value: string): TOutputMessageContent;
    /// <summary>
    /// A text output from the model.
    /// </summary>
    class function NewOutputText: TOutputMessageContent;
    /// <summary>
    /// A refusal from the model.
    /// </summary>
    class function NewRefusal: TOutputMessageContent;
  end;

  TItemOutputMessage = class(TInputListItem)
  public
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

  TFileSearchToolCallResult = class(TJSONParam)
  public
    /// <summary>
    /// Set of 16 key-value pairs that can be attached to an object. This can be useful for storing additional
    /// information about the object in a structured format, and querying for objects via API or the dashboard.
    /// Keys are strings with a maximum length of 64 characters. Values are strings with a maximum length of
    /// 512 characters, booleans, or numbers.
    /// </summary>
    function Attributes(const Value: TJSONObject): TFileSearchToolCallResult;
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

  TFileSearchToolCall = class(TInputListItem)
  public
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
    function Results(const Value: TArray<TFileSearchToolCallResult>): TFileSearchToolCall;

    class function New: TFileSearchToolCall;
  end;

  TPendingSafetyCheck = class(TJSONParam)
  public
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

  TAcknowledgedSafetyCheckParams = class(TJSONParam)
  public
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

  TComputerToolCallOutputObject = class(TJSONParam)
  public
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

  TComputerToolCallAction = class(TJSONParam);

  TComputerClick = class(TComputerToolCallAction)
  public
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

  TComputerToolCallOutput = class(TComputerToolCallAction)
  public
    /// <summary>
    /// acknowledged safety checks for computer tool call outpu
    /// </summary>
    function AcknowledgedSafetyChecks(const Value: TArray<TAcknowledgedSafetyCheckParams>): TComputerToolCallOutput;
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
    function Output(const Value: TComputerToolCallOutputObject): TComputerToolCallOutput;
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

  TWebSearchToolCall = class(TComputerToolCallAction)
  public
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

  TFunctionToolCall = class(TComputerToolCallAction)
  public
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

  TFunctionToolCalloutput = class(TComputerToolCallAction)
  public
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
    function Output(const Value: string): TFunctionToolCalloutput;
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

  TReasoningTextContent = class(TJSONParam)
  public
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

  TReasoningObject = class(TComputerToolCallAction)
  public
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
    function Summary(const Value: TArray<TReasoningTextContent>): TReasoningObject;
    /// <summary>
    /// The type of the object. Always reasoning.
    /// </summary>
    function &Type(const Value: string = 'reasoning'): TReasoningObject;

    class function New: TReasoningObject;
  end;

  TComputerToolCall = class(TInputListItem)
  public
    /// <summary>
    /// The computer action
    /// </summary>
    /// <remarks>
    /// Value is TComputerToolCallAction class or his descendant e.g. TComputerClick,
    /// TComputerDoubleClick, TComputerToolCallOutput, TWebSearchToolCall, TFunctionToolCall,
    /// TFunctionToolCalloutput, TReasoningObject
    /// </remarks>
    function Action(const Value: TComputerToolCallAction): TComputerToolCall;
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
    function PendingSafetyChecks(const Value: TArray<TPendingSafetyCheck>): TComputerToolCall;
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

implementation

uses
  System.StrUtils, GenAI.NetEncoding.Base64, GenAI.Responses.Helpers, GenAI.Httpx;

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
    Result :=  NewImage.Detail(Detail).ImageUrl(Value)
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
begin
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
  Result := TItemOutputMessage(Add('status', TMessageStatus.Create(Value).ToString));
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
  Result := TFileSearchToolCall(Add('status', TFileSearchToolCallType.Create(Value).ToString));
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
  Result := TComputerClick(Add('button', TMouseButton.Create(Value).ToString));
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
  const Value: string): TFunctionToolCalloutput;
begin
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

end.
