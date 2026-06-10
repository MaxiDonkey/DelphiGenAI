unit WVPythia.JSON.Resource;

interface

uses
  System.SysUtils, System.IOUtils, System.JSON, System.Rtti, REST.Json;

type
  TFactory<T> = reference to function: T;
  TJSONResourceClass = class of TJSONResource;

  TJSONResource = class
  public
    constructor Create; virtual;
    class function DefaultFileName: string; virtual;
    class function Load(const FileName: string = ''): TJSONResource; virtual;
    procedure Save(const FileName: string = '');
  end;

  TJSONChain = record
  private
    FInstance: TJSONResource;
    procedure SetPropByPath(const APropPath: string; const AValue: TValue);
  public
    class function FromInstance(AInstance: TJSONResource): TJSONChain; static;
    function Apply(const APropPath: string; const AValue: TValue): TJSONChain; overload;
    function Apply<T>(const APropPath: string; const AValue: T): TJSONChain; overload;
    function Apply<T>(const APropPath: string; const AValue: array of T): TJSONChain; overload;
    function Apply<T>(const APropPath: string; const AValue: array of TFactory<T>): TJSONChain; overload;
    function Save(const AFileName: string = ''): TJSONChain;
    property Instance: TJSONResource read FInstance;
  end;

  TJSONResourceHelper = class helper for TJSONResource
  public
    function Chain: TJSONChain;
  end;

implementation

function ResolveResourceFileName(const AFileName: string; const AClass: TJSONResourceClass): string;
begin
  Result := AFileName;
  if Result = EmptyStr then
    Result := AClass.DefaultFileName;

  Result := TPath.GetFullPath(Result);
end;

function JsonOptions: TJsonOptions;
begin
  Result := [joSerialFields, joSerialPublicProps, joIndentCaseCamel];
end;

function FindPropertyIgnoreCase(const ARttiType: TRttiType; const AName: string): TRttiProperty;
begin
  Result := nil;
  if ARttiType = nil then
    Exit;

  for var Prop in ARttiType.GetProperties do
    if SameText(Prop.Name, AName) then
      Exit(Prop);
end;

function FindFieldIgnoreCase(const ARttiType: TRttiType; const AName: string): TRttiField;
begin
  Result := nil;
  if ARttiType = nil then
    Exit;

  for var Field in ARttiType.GetFields do
    if SameText(Field.Name, AName) then
      Exit(Field);
end;

{ TJSONResource }

constructor TJSONResource.Create;
begin
  inherited Create;
end;

class function TJSONResource.DefaultFileName: string;
begin
  Result := ClassName.Substring(1) + '.json';
end;

class function TJSONResource.Load(const FileName: string): TJSONResource;
begin
  var LFileName := ResolveResourceFileName(FileName, TJSONResourceClass(Self));

  if not TFile.Exists(LFileName) then
    Exit(TJSONResourceClass(Self).Create);

  var Raw := TFile.ReadAllText(LFileName, TEncoding.UTF8);
  var JSONObject := TJSONObject.ParseJSONValue(Raw) as TJSONObject;
  if JSONObject = nil then
    raise Exception.CreateFmt('Invalid JSON in %s', [LFileName]);

  try
    Result := TJSONResourceClass(Self).Create;
    TJson.JsonToObject(Result, JSONObject, JsonOptions);
  finally
    JSONObject.Free;
  end;
end;

procedure TJSONResource.Save(const FileName: string);
var
  LFileName: string;
  LDirectory: string;
  LTempFileName: string;
  LBackupFileName: string;
  JsonValue: TJSONValue;
  Formatted: string;
begin
  LFileName := ResolveResourceFileName(FileName, TJSONResourceClass(ClassType));
  LDirectory := TPath.GetDirectoryName(LFileName);
  if LDirectory <> EmptyStr then
    ForceDirectories(LDirectory);

  JsonValue := TJson.ObjectToJsonObject(Self, JsonOptions);
  try
    Formatted := JsonValue.Format(2);
    LTempFileName := LFileName + '.tmp';
    LBackupFileName := LFileName + '.bak';

    if TFile.Exists(LTempFileName) then
      TFile.Delete(LTempFileName);
    if TFile.Exists(LBackupFileName) then
      TFile.Delete(LBackupFileName);

    TFile.WriteAllText(LTempFileName, Formatted, TEncoding.UTF8);

    if TFile.Exists(LFileName) then
    begin
      TFile.Move(LFileName, LBackupFileName);
      try
        TFile.Move(LTempFileName, LFileName);
        if TFile.Exists(LBackupFileName) then
          TFile.Delete(LBackupFileName);
      except
        on Exception do
        begin
          if TFile.Exists(LBackupFileName) and (not TFile.Exists(LFileName)) then
            TFile.Move(LBackupFileName, LFileName);
          if TFile.Exists(LTempFileName) then
            TFile.Delete(LTempFileName);
          raise;
        end;
      end;
    end
    else
      TFile.Move(LTempFileName, LFileName);
  finally
    JsonValue.Free;
  end;
end;

{ TJSONChain }

function TJSONChain.Apply<T>(const APropPath: string; const AValue: array of T): TJSONChain;
var
  Data: TArray<T>;
  I: Integer;
begin
  SetLength(Data, Length(AValue));
  for I := 0 to High(AValue) do
    Data[I] := AValue[I];
  Result := Apply(APropPath, TValue.From<TArray<T>>(Data));
end;

function TJSONChain.Apply<T>(const APropPath: string; const AValue: array of TFactory<T>): TJSONChain;
var
  Data: TArray<T>;
  I: Integer;
begin
  SetLength(Data, Length(AValue));
  for I := 0 to High(AValue) do
    Data[I] := AValue[I]();
  Result := Apply(APropPath, TValue.From<TArray<T>>(Data));
end;

function TJSONChain.Apply<T>(const APropPath: string; const AValue: T): TJSONChain;
begin
  Result := Apply(APropPath, TValue.From<T>(AValue));
end;

function TJSONChain.Apply(const APropPath: string; const AValue: TValue): TJSONChain;
begin
  Result := Self;
  SetPropByPath(APropPath, AValue);
end;

class function TJSONChain.FromInstance(AInstance: TJSONResource): TJSONChain;
begin
  Result.FInstance := AInstance;
end;

function TJSONChain.Save(const AFileName: string): TJSONChain;
begin
  if Assigned(FInstance) then
    FInstance.Save(AFileName);
  Result := Self;
end;

procedure TJSONChain.SetPropByPath(const APropPath: string; const AValue: TValue);
var
  Ctx: TRttiContext;
  RTTIType: TRttiType;
  Prop: TRttiProperty;
  Field: TRttiField;
  Parts: TArray<string>;
  CurrentObj: TObject;
  NextValue: TValue;
  Last: Integer;
begin
  if not Assigned(FInstance) then
    raise Exception.Create('TJSONChain has no attached instance');

  if Trim(APropPath) = EmptyStr then
    raise Exception.Create('Property path cannot be empty');

  Parts := APropPath.Split(['.']);
  Last := High(Parts);
  CurrentObj := FInstance;
  Ctx := TRttiContext.Create;
  try
    for var I := 0 to Last - 1 do
      begin
        RTTIType := Ctx.GetType(CurrentObj.ClassType);
        Prop := FindPropertyIgnoreCase(RTTIType, Parts[I]);

        if Assigned(Prop) then
          NextValue := Prop.GetValue(CurrentObj)
        else
          begin
            Field := FindFieldIgnoreCase(RTTIType, Parts[I]);
            if not Assigned(Field) then
              raise Exception.CreateFmt('Property or field "%s" not found on %s',
                [Parts[I], CurrentObj.ClassName]);
            NextValue := Field.GetValue(CurrentObj);
          end;

        CurrentObj := NextValue.AsObject;
        if CurrentObj = nil then
          raise Exception.CreateFmt('The sub-property "%s" is NIL', [Parts[I]]);
      end;

    RTTIType := Ctx.GetType(CurrentObj.ClassType);
    Prop := FindPropertyIgnoreCase(RTTIType, Parts[Last]);
    if Assigned(Prop) then
    begin
      if not Prop.IsWritable then
        raise Exception.CreateFmt('Property "%s" on %s is read-only',
          [Parts[Last], CurrentObj.ClassName]);
      Prop.SetValue(CurrentObj, AValue);
      Exit;
    end;

    Field := FindFieldIgnoreCase(RTTIType, Parts[Last]);
    if not Assigned(Field) then
      raise Exception.CreateFmt('Property or field "%s" not found on %s',
        [Parts[Last], CurrentObj.ClassName]);

    Field.SetValue(CurrentObj, AValue);
  finally
    Ctx.Free;
  end;
end;

{ TJSONResourceHelper }

function TJSONResourceHelper.Chain: TJSONChain;
begin
  Result := TJSONChain.FromInstance(Self);
end;

end.
