unit GenAI.Api.JsonFingerprintBinder;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGenAI
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.SysUtils, System.Rtti, System.TypInfo,
  System.Generics.Collections;

type
  TJSONFingerprintBinder = record
  public type
    TOnTruncated = reference to procedure(const VisitedNodes, MaxVisitedNodes: NativeInt);
  private
    class var FOnTruncated: TOnTruncated;
    class var FDefaultMaxNodes: NativeInt;
  public
    /// <summary>
    /// Optional callback invoked if traversal is truncated due to node limit.
    /// </summary>
    /// <remarks>
    /// This callback is global. Assign it once at initialization time and avoid changing it while
    /// traversals may be running. The binder snapshots the callback at the start of each run.
    /// </remarks>
    class property OnTruncated: TOnTruncated read FOnTruncated write FOnTruncated;

    /// <summary>
    /// Gets or sets the default maximum number of unique objects that may be visited during a
    /// single <c>Bind</c> traversal.
    /// </summary>
    /// <remarks>
    /// This limit is applied per call. A "node" corresponds to one unique <c>TObject</c> instance
    /// encountered while walking the graph. Set to <c>0</c> to disable the limit.
    /// </remarks>
    class property DefaultMaxNodes: NativeInt read FDefaultMaxNodes write FDefaultMaxNodes;

    /// <summary>
    /// Propagates the source JSON string to all <c>TJSONFingerprint</c> instances found in the
    /// object graph rooted at <paramref name="Root"/>.
    /// </summary>
    /// <remarks>
    /// Traversal is RTTI-based and strictly field-driven (no properties are evaluated) to avoid
    /// triggering application-level getters. Each object instance is visited at most once to
    /// prevent infinite recursion on cyclic graphs. If traversal exceeds the node limit,
    /// it is truncated and <c>OnTruncated</c> is invoked (if assigned).
    /// </remarks>
    /// <param name="Root">
    /// Root object of the deserialized graph to traverse. If <c>nil</c>, this method does nothing.
    /// </param>
    /// <param name="JSON">
    /// The formatted JSON source string to inject into <c>JSONResponse</c>.
    /// </param>
    class procedure Bind(const Root: TObject; const JSON: string); static;
  end;

implementation

{$REGION 'Dev note'}
(*
  JSONFingerprintBinder
  ---------------------

  - Purpose
    Propagate the source JSON string (JSONResponse) to all instances inheriting
    from TJSONFingerprint within a deserialized object graph, without evaluating
    any application-level getters.

  - Principle
    - RTTI traversal is strictly "fields-only": no properties are evaluated.
    - Descent occurs only through fields of type class or TArray<> instances.
    - Each unique object instance is visited once (cycle prevention via Visited).
    - On each visit of a TJSONFingerprint descendant, JSONResponse is injected.

  - Definition of a "node"
    A node corresponds to one unique TObject instance encountered during traversal
    (e.g. TChat, TUsageMetadata, each element of a TArray<T>).
    Primitive types (string, integers, enums, records) are not counted.

  - Protection against pathological graphs
    - A per-call node limit is enforced (DefaultMaxNodes, default 250000).
    - The counter is reset on each call to Bind.
    - Node counting occurs after the Visited check, so only unique nodes are counted.
    - When the limit is exceeded, traversal is cleanly truncated.

  - Truncation signaling
    - Optional callback: TJSONFingerprintBinder.OnTruncated
      Signature: procedure(const VisitedNodes, MaxVisitedNodes: NativeInt)
    - Invoked once, after traversal, if truncation occurred.
    - DEBUG: a handler may raise an exception to ease diagnosis.
    - RELEASE: leave OnTruncated = nil or attach a thread-safe logger.

  - Concurrency
    - Traversal state is local to each call (RTTI context, dictionary, counters).
    - Multiple concurrent deserializations are fully independent.
    - OnTruncated is global: assign it once at initialization and avoid modifying
      it while traversal is in progress. The binder snapshots the callback at the
      start of each run to avoid races.
*)
{$ENDREGION}

uses
  GenAI.API.Params;

type
  TJSONFingerprintBinderImpl = record
  private type
    {--- Work item stored on an explicit stack to avoid recursion. }
    TWorkKind = (wkObject, wkValue);

    TWorkItem = record
      Kind: TWorkKind;
      Obj: TObject;
      Val: TValue;
      class function FromObject(const AObj: TObject): TWorkItem; static; inline;
      class function FromValue(const AVal: TValue): TWorkItem; static; inline;
    end;

  private
    FContext: TRttiContext;
    FVisited: TDictionary<Pointer, Byte>;
    FJSON: string;

    FVisitedNodes: NativeInt;
    FMaxVisitedNodes: NativeInt;
    FTruncated: Boolean;

    FOnTruncatedSnapshot: TJSONFingerprintBinder.TOnTruncated;

    procedure MarkTruncated; inline;
    function  TryConsumeNodeBudget: Boolean; inline;

    procedure HandleObject(const Obj: TObject; var Stack: TStack<TWorkItem>);
    procedure HandleValue(const Value: TValue; var Stack: TStack<TWorkItem>);
  public
    /// <summary>
    /// Executes a single binding pass: traverses the object graph rooted at <paramref name="Root"/>
    /// and injects <paramref name="JSON"/> into <c>JSONResponse</c> for each encountered
    /// <c>TJSONFingerprint</c> instance.
    /// </summary>
    /// <remarks>
    /// Traversal is RTTI field-based (no properties are evaluated). Each object is visited at most
    /// once (cycle-safe). The traversal is performed iteratively (explicit stack) to avoid
    /// stack overflows on very deep graphs. If the number of visited unique objects exceeds
    /// <paramref name="MaxVisitedNodes"/>, traversal is truncated and
    /// <c>TJSONFingerprintBinder.OnTruncated</c> is invoked (if assigned).
    /// </remarks>
    /// <param name="Root">Root object to traverse; if <c>nil</c>, nothing is done.</param>
    /// <param name="JSON">Formatted source JSON to inject.</param>
    /// <param name="MaxVisitedNodes">
    /// Maximum number of unique objects to visit; set to <c>0</c> to disable the limit.
    /// </param>
    procedure Run(const Root: TObject; const JSON: string; const MaxVisitedNodes: NativeInt);
  end;

class function TJSONFingerprintBinderImpl.TWorkItem.FromObject(const AObj: TObject): TWorkItem;
begin
  Result.Kind := wkObject;
  Result.Obj := AObj;
  Result.Val := TValue.Empty;
end;

class function TJSONFingerprintBinderImpl.TWorkItem.FromValue(const AVal: TValue): TWorkItem;
begin
  Result.Kind := wkValue;
  Result.Obj := nil;
  Result.Val := AVal;
end;

class procedure TJSONFingerprintBinder.Bind(const Root: TObject; const JSON: string);
begin
  var Impl: TJSONFingerprintBinderImpl;
  Impl.Run(Root, JSON, DefaultMaxNodes);
end;

procedure TJSONFingerprintBinderImpl.MarkTruncated;
begin
  FTruncated := True;
end;

function TJSONFingerprintBinderImpl.TryConsumeNodeBudget: Boolean;
begin
  Inc(FVisitedNodes);
  Result := not ((FMaxVisitedNodes > 0) and (FVisitedNodes > FMaxVisitedNodes));
  if not Result then
    MarkTruncated;
end;

procedure TJSONFingerprintBinderImpl.Run(const Root: TObject; const JSON: string; const MaxVisitedNodes: NativeInt);
begin
  if Root = nil then
    Exit;

  FContext := TRttiContext.Create;
  FVisited := TDictionary<Pointer, Byte>.Create;
  try
    FJSON := JSON;
    FVisitedNodes := 0;
    FMaxVisitedNodes := MaxVisitedNodes;
    FTruncated := False;

    {--- Snapshot callback once per run to avoid races. }
    FOnTruncatedSnapshot := TJSONFingerprintBinder.OnTruncated;

    var Stack := TStack<TWorkItem>.Create;
    try
      Stack.Push(TWorkItem.FromObject(Root));

      while (Stack.Count > 0) and (not FTruncated) do
        begin
          var Item := Stack.Pop;

          case Item.Kind of
            wkObject: HandleObject(Item.Obj, Stack);
            wkValue:  HandleValue(Item.Val, Stack);
          end;
        end;
    finally
      Stack.Free;
    end;

    {--- Fire callback once, after traversal, if truncated. }
    if FTruncated and Assigned(FOnTruncatedSnapshot) then
      FOnTruncatedSnapshot(FVisitedNodes, FMaxVisitedNodes);

  finally
    FVisited.Free;
  end;
end;

procedure TJSONFingerprintBinderImpl.HandleObject(const Obj: TObject; var Stack: TStack<TWorkItem>);
begin
  if (Obj = nil) or FTruncated then
    Exit;

  var Key := Pointer(Obj);

  {--- Already visited: do not consume node budget. }
  if FVisited.ContainsKey(Key) then
    Exit;

  {--- Mark visited before exploring children. }
  FVisited.Add(Key, 1);

  {--- Consume node budget for unique objects only. }
  if not TryConsumeNodeBudget then
    Exit;

  {--- Inject JSONResponse on fingerprints. }
  if Obj is TJSONFingerprint then
    TJSONFingerprint(Obj).JSONResponse := FJSON;

  var RType := FContext.GetType(Obj.ClassType);
  if RType = nil then
    Exit;

  {--- Fields-only traversal. }
  for var Field in RType.GetFields do
    begin
      if FTruncated then
        Exit;

      if (Field = nil) or (Field.FieldType = nil) then
        Continue;

      var Kind := Field.FieldType.TypeKind;
      if not (Kind in [tkClass, tkDynArray]) then
        Continue;

      try
        var Value := Field.GetValue(Obj);
        Stack.Push(TWorkItem.FromValue(Value));
      except
        Continue;
      end;
    end;
end;

procedure TJSONFingerprintBinderImpl.HandleValue(const Value: TValue; var Stack: TStack<TWorkItem>);
begin
  if FTruncated or Value.IsEmpty then
    Exit;

  case Value.Kind of
    tkClass:
      begin
        if Value.IsObject then
          Stack.Push(TWorkItem.FromObject(Value.AsObject));
      end;

    tkDynArray:
      begin
        var Length := Value.GetArrayLength;
        if Length = 0 then
          Exit;

        {--- Push elements onto the stack.
             Order does not matter for correctness; keep natural order. }
        for var I := 0 to Length - 1 do
          Stack.Push(TWorkItem.FromValue(Value.GetArrayElement(I)));
      end;
  end;
end;

initialization
  TJSONFingerprintBinder.DefaultMaxNodes := 250000;

  {$IFDEF DEBUG}
  TJSONFingerprintBinder.OnTruncated :=
    procedure(const VisitedNodes, MaxVisitedNodes: NativeInt)
    begin
      raise Exception.CreateFmt(
        'JSON fingerprint binding truncated (%d/%d nodes).',
        [VisitedNodes, MaxVisitedNodes]
      );
    end;
  {$ENDIF}

end.
