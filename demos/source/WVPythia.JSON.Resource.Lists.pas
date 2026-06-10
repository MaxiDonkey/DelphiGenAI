unit WVPythia.JSON.Resource.Lists;

interface

uses
  System.SysUtils, WVPythia.JSON.Resource;

type
  EIndexOutOfBounds = class(EArgumentOutOfRangeException);
  EArgumentNil = class(EArgumentNilException);

  TJSONListParams<T: class; U: class, constructor> = class abstract(TJSONResource)
  private
    FData: TArray<U>;
    procedure FreeItems(const Values: TArray<U>);
    function ContainsReference(const Values: TArray<U>; const Item: U): Boolean;
    procedure SetData(const Value: TArray<U>);
  protected
    function EnsureIndex(const Index: Integer): T;
    function IndexOf(const Item: TObject): Integer;
    function ItemCheck(const Item: TObject): T;
  public
    constructor Create; override;
    destructor Destroy; override;

    function AddItem: U; virtual;
    function Clear: T;
    function Delete(const Index: Integer): T; overload;
    function Delete(const Item: TObject): T; overload; virtual;

    function WithData(const Value: TArray<U>): T; overload;
    function WithData(const Value: TArray<TFactory<U>>): T; overload;

    property Data: TArray<U> read FData write SetData;
  end;

implementation

{ TJSONListParams<T, U> }

constructor TJSONListParams<T, U>.Create;
begin
  inherited Create;
  FData := nil;
end;

destructor TJSONListParams<T, U>.Destroy;
begin
  Clear;
  inherited;
end;

procedure TJSONListParams<T, U>.FreeItems(const Values: TArray<U>);
begin
  for var I := Low(Values) to High(Values) do
    if Assigned(Values[I]) then
      Values[I].Free;
end;

function TJSONListParams<T, U>.ContainsReference(const Values: TArray<U>; const Item: U): Boolean;
begin
  Result := False;
  for var I := Low(Values) to High(Values) do
    if TObject(Values[I]) = TObject(Item) then
      Exit(True);
end;

function TJSONListParams<T, U>.AddItem: U;
begin
  Result := U.Create;
  FData := FData + [Result];
end;


function TJSONListParams<T, U>.Clear: T;
begin
  FreeItems(FData);
  FData := nil;
  Result := Self as T;
end;

function TJSONListParams<T, U>.Delete(const Item: TObject): T;
begin
  ItemCheck(Item);
  Result := Delete(IndexOf(Item));
end;

function TJSONListParams<T, U>.Delete(const Index: Integer): T;
var
  ItemToFree: U;
begin
  if Index < 0 then
    Exit(Self as T);

  EnsureIndex(Index);
  ItemToFree := FData[Index];

  for var I := Index to High(FData) - 1 do
    FData[I] := FData[I + 1];
  SetLength(FData, Length(FData) - 1);

  if Assigned(ItemToFree) then
    ItemToFree.Free;

  Result := Self as T;
end;

function TJSONListParams<T, U>.EnsureIndex(const Index: Integer): T;
begin
  if not Assigned(FData) then
    raise EArgumentNil.Create('Data are empty');

  if (Index < 0) or (Index >= Length(FData)) then
    raise EIndexOutOfBounds.CreateFmt(
      'JSONList: index %d out of bounds [0..%d]', [Index, Length(FData) - 1]);
  Result := Self as T;
end;

function TJSONListParams<T, U>.IndexOf(const Item: TObject): Integer;
begin
  for Result := 0 to High(FData) do
    if TObject(FData[Result]) = TObject(Item) then
      Exit;
  Result := -1;
end;

function TJSONListParams<T, U>.ItemCheck(const Item: TObject): T;
begin
  if not Assigned(Item) then
    raise EArgumentNil.Create('Item is nil');

  if not (Item is U) then
    raise EArgumentException.CreateFmt('Class %s not supported', [Item.ClassName]);

  EnsureIndex(IndexOf(Item));
  Result := Self as T;
end;

procedure TJSONListParams<T, U>.SetData(const Value: TArray<U>);
begin
  FData := Value ;
end;

function TJSONListParams<T, U>.WithData(const Value: TArray<TFactory<U>>): T;
begin
  var OldData := FData;
  SetLength(FData, Length(Value));

  for var I := 0 to High(Value) do
    FData[I] := Value[I]();

  FreeItems(OldData);
  Result := Self as T;
end;

function TJSONListParams<T, U>.WithData(const Value: TArray<U>): T;
begin
  var OldData := FData;
  SetLength(FData, Length(Value));
  for var I := 0 to High(Value) do
    FData[I] := Value[I];

  for var I := Low(OldData) to High(OldData) do
    if Assigned(OldData[I]) and (not ContainsReference(FData, OldData[I])) then
      OldData[I].Free;

  Result := Self as T;
end;

end.
