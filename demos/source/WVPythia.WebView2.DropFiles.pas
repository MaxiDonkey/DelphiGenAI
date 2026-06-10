unit WVPythia.WebView2.DropFiles;

interface

uses
  System.SysUtils, System.JSON, Winapi.ActiveX, uWVTypeLibrary;

type
  TWebView2DropFiles = record
    class function TryBuildFileDropInJson(
      const ARawJson: string;
      const AArgs: ICoreWebView2WebMessageReceivedEventArgs;
      out AJson: string): Boolean; static;
  end;

implementation

const
  FILE_DROP_IN_EVENT = 'file-drop-in';
  PROP_EVENT = 'event';
  PROP_FILENAMES = 'filenames';

function IsFileDropInEvent(const ARawJson: string): Boolean;
begin
  Result := False;

  var Value := TJSONObject.ParseJSONValue(ARawJson);
  try
    if not (Value is TJSONObject) then
      Exit;

    var EventValue := TJSONObject(Value).GetValue(PROP_EVENT);

    Result :=
      Assigned(EventValue) and
      SameText(EventValue.Value, FILE_DROP_IN_EVENT);
  finally
    Value.Free;
  end;
end;

function ExtractDroppedFilePaths(
  const AArgs: ICoreWebView2WebMessageReceivedEventArgs): TArray<string>;
var
  Args2: ICoreWebView2WebMessageReceivedEventArgs2;
  Objects: ICoreWebView2ObjectCollectionView;
  Count: SYSUINT;
  Item: IUnknown;
  WebViewFile: ICoreWebView2File;
  PathValue: PWideChar;
  Path: string;
begin
  Result := [];

  if not Assigned(AArgs) then
    Exit;

  if AArgs.QueryInterface(
       IID_ICoreWebView2WebMessageReceivedEventArgs2, Args2) <> S_OK then
    Exit;

  if not Assigned(Args2) or
     (Args2.Get_AdditionalObjects(Objects) <> S_OK) or
     not Assigned(Objects) then
    Exit;

  Count := 0;
  if (Objects.Get_Count(Count) <> S_OK) or (Count = 0) then
    Exit;

  for var Index := 0 to Count - 1 do
    begin
      Item := nil;
      WebViewFile := nil;

      if (Objects.GetValueAtIndex(Index, Item) <> S_OK) or
         not Assigned(Item) or
         (Item.QueryInterface(IID_ICoreWebView2File, WebViewFile) <> S_OK) or
         not Assigned(WebViewFile) then
        Continue;

      PathValue := nil;

      if (WebViewFile.Get_Path(PathValue) = S_OK) and
         Assigned(PathValue) then
        try
          Path := string(PathValue).Trim;

          if not Path.IsEmpty then
            Result := Result + [Path];
        finally
          CoTaskMemFree(PathValue);
        end;
    end;
end;

function BuildFileDropInJson(const APaths: TArray<string>): string;
begin
  var Obj := TJSONObject.Create;
  try
    Obj.AddPair(PROP_EVENT, FILE_DROP_IN_EVENT);

    var Arr := TJSONArray.Create;
    Obj.AddPair(PROP_FILENAMES, Arr);

    for var Path in APaths do
      Arr.AddElement(TJSONString.Create(Path));

    Result := Obj.ToJSON;
  finally
    Obj.Free;
  end;
end;

class function TWebView2DropFiles.TryBuildFileDropInJson(
  const ARawJson: string;
  const AArgs: ICoreWebView2WebMessageReceivedEventArgs;
  out AJson: string): Boolean;
begin
  AJson := '';

  if not IsFileDropInEvent(ARawJson) then
    Exit(False);

  var Paths := ExtractDroppedFilePaths(AArgs);

  Result := Length(Paths) > 0;

  if Result then
    AJson := BuildFileDropInJson(Paths);
end;

end.
