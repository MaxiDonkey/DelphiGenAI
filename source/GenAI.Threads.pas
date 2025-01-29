unit GenAI.Threads;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGenAI
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.SysUtils, System.Classes, System.Threading, System.JSON, REST.Json.Types,
  REST.JsonReflect, System.Net.URLClient,
  GenAI.API.Params, GenAI.API, GenAI.Consts, GenAI.Types, GenAI.Async.Support;

type
  TThreadsImageFileParams = class(TJSONparam)
  public
    function FileId(const Value: string): TThreadsImageFileParams;
    function Detail(const Value: TImageDetail): TThreadsImageFileParams;
  end;

  TThreadsImageUrlParams = class(TJSONparam)
  public
    function Url(const Value: string): TThreadsImageUrlParams;
    function Detail(const Value: TImageDetail): TThreadsImageUrlParams;
  end;

  TThreadsContentParams = class(TJSONparam)
  public
    function &Type(const Value: string): TThreadsContentParams; overload;
    function &Type(const Value: TThreadsContentType): TThreadsContentParams; overload;
    function ImageFile(const Value: TThreadsImageFileParams): TThreadsContentParams;
    function ImageUrl(const Value: TThreadsImageUrlParams): TThreadsContentParams;
    function Text(const Value: string): TThreadsContentParams;
  end;

  TThreadsAttachment = class(TJSONparam)
    function FileId(const Value: string): TThreadsAttachment;
    function Tool(const Value: TAssistantsToolsType): TThreadsAttachment; overload;
    function Tool(const Value: string): TThreadsAttachment; overload;
  end;

  TThreadsMessageParams = class(TJSONparam)
  public
    function Role(const Value: string): TThreadsMessageParams; overload;
    function Role(const Value: TRole): TThreadsMessageParams; overload;
    function Content(const Value: string): TThreadsMessageParams; overload;
    function Content(const Value: TArray<TThreadsContentParams>): TThreadsMessageParams; overload;
    function Attachments(const Value: TArray<TThreadsAttachment>): TThreadsMessageParams;
    function Metadata(const Value: TJSONObject): TThreadsMessageParams;
  end;

  TThreadsCreateParams = class(TJSONparam)
    function Messages(const Value: string): TThreadsCreateParams; overload;
    function Messages(const Value: TArray<TThreadsMessageParams>): TThreadsCreateParams; overload;
    //TODO tool_resources
    function Metadata(const Value: TJSONObject): TThreadsCreateParams;
  end;

  TThreadsRoute = class(TGenAIRoute)

  end;

implementation

{ TThreadsMessageParams }

function TThreadsMessageParams.Attachments(
  const Value: TArray<TThreadsAttachment>): TThreadsMessageParams;
begin
  var JSONArray := TJSONArray.Create;
  for var Item in Value do
    JSONArray.Add(Item.Detach);
    Result := TThreadsMessageParams(Add('attachments', JSONArray));
end;

function TThreadsMessageParams.Content(
  const Value: TArray<TThreadsContentParams>): TThreadsMessageParams;
begin
  var JSONArray := TJSONArray.Create;
  for var Item in Value do
    JSONArray.Add(Item.Detach);
  Result := TThreadsMessageParams(Add('content', JSONArray));
end;

function TThreadsMessageParams.Content(
  const Value: string): TThreadsMessageParams;
begin
  Result := TThreadsMessageParams(Add('content', Value));
end;

function TThreadsMessageParams.Metadata(
  const Value: TJSONObject): TThreadsMessageParams;
begin
  Result := TThreadsMessageParams(Add('metadata', Value));
end;

function TThreadsMessageParams.Role(
  const Value: string): TThreadsMessageParams;
begin
  Result := TThreadsMessageParams(Add('role', TRole.Create(Value).ToString));
end;

function TThreadsMessageParams.Role(
  const Value: TRole): TThreadsMessageParams;
begin
  Result := TThreadsMessageParams(Add('role', Value.ToString));
end;

{ TThreadsContentParams }

function TThreadsContentParams.ImageFile(
  const Value: TThreadsImageFileParams): TThreadsContentParams;
begin
  Result := TThreadsContentParams(Add('image_file', Value.Detach));
end;

function TThreadsContentParams.ImageUrl(
  const Value: TThreadsImageUrlParams): TThreadsContentParams;
begin
  Result := TThreadsContentParams(Add('image_url', Value.Detach));
end;

function TThreadsContentParams.&Type(
  const Value: string): TThreadsContentParams;
begin
  Result := TThreadsContentParams(Add('type', TThreadsContentType.Create(Value).ToString));
end;

function TThreadsContentParams.Text(const Value: string): TThreadsContentParams;
begin
  Result := TThreadsContentParams(Add('text', Value));
end;

function TThreadsContentParams.&Type(
  const Value: TThreadsContentType): TThreadsContentParams;
begin
  Result := TThreadsContentParams(Add('type', Value.ToString));
end;

{ TThreadsImageFileParams }

function TThreadsImageFileParams.Detail(
  const Value: TImageDetail): TThreadsImageFileParams;
begin
  Result := TThreadsImageFileParams(Add('detail', Value.ToString));
end;

function TThreadsImageFileParams.FileId(
  const Value: string): TThreadsImageFileParams;
begin
  Result := TThreadsImageFileParams(Add('file_id', Value));
end;

{ TThreadsImageUrlParams }

function TThreadsImageUrlParams.Detail(
  const Value: TImageDetail): TThreadsImageUrlParams;
begin
  Result := TThreadsImageUrlParams(Add('detail', Value.ToString));
end;

function TThreadsImageUrlParams.Url(
  const Value: string): TThreadsImageUrlParams;
begin
  Result := TThreadsImageUrlParams(Add('url', Value));
end;

{ TThreadsAttachment }

function TThreadsAttachment.FileId(const Value: string): TThreadsAttachment;
begin
  Result := TThreadsAttachment(Add('file_id', Value));
end;

function TThreadsAttachment.Tool(
  const Value: TAssistantsToolsType): TThreadsAttachment;
begin
  case Value of
    TAssistantsToolsType.code_interpreter,
    TAssistantsToolsType.file_search:
      Result := TThreadsAttachment(Add('tools', TJSONObject.Create.AddPair('type', Value.ToString)));
    else
      raise Exception.CreateFmt('%s: Threads attachments tools type value not managed', [Value.ToString]);
  end;
end;

function TThreadsAttachment.Tool(const Value: string): TThreadsAttachment;
begin
  Result := Tool(TAssistantsToolsType.Create(Value));
end;

{ TThreadsCreateParams }

function TThreadsCreateParams.Messages(
  const Value: string): TThreadsCreateParams;
begin
  var Msg := TThreadsMessageParams.Create.Role('user').Content(Value);
  Result := TThreadsCreateParams(Add('messages', Msg.Detach));
end;

function TThreadsCreateParams.Messages(
  const Value: TArray<TThreadsMessageParams>): TThreadsCreateParams;
begin
  var JSONArray := TJSONArray.Create;
  for var Item in Value do
    JSONArray.Add(Item.Detach);
  Result := TThreadsCreateParams(Add('messages', JSONArray));
end;

function TThreadsCreateParams.Metadata(
  const Value: TJSONObject): TThreadsCreateParams;
begin
  Result := TThreadsCreateParams(Add('metadata', Value));
end;

end.
