unit GenAI.API.ArrayBuilder;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGenAI
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

type
  /// <summary>
  /// Generic helper record for incrementally building <c>TArray&lt;T&gt;</c> values.
  /// </summary>
  /// <remarks>
  /// <c>TArrayBuilder&lt;T&gt;</c> provides a fluent API for composing arrays
  /// step by step using <c>Add</c> (and optionally <c>Reserve</c>), and then
  /// converting to a regular dynamic array via the implicit operator. It is
  /// intended for scenarios where arrays are built progressively, such as
  /// constructing parameter lists or JSON-ready collections, while keeping
  /// calling code concise and readable.
  /// </remarks>
  TArrayBuilder<T> = record
  private
    FItems: TArray<T>;
    FCount: Integer;
    procedure Append(const Item: T); inline;
  public
    /// <summary>
    /// Creates a new <c>TArrayBuilder&lt;T&gt;</c> instance with an optional
    /// initial capacity.
    /// </summary>
    /// <param name="Capacity">
    /// Optional. The initial capacity of the internal buffer. If less than or
    /// equal to zero, no memory is preallocated. Default is 2.
    /// </param>
    /// <returns>
    /// A new <c>TArrayBuilder&lt;T&gt;</c> ready to receive items via
    /// <c>Add</c>.
    /// </returns>
    /// <remarks>
    /// Providing a reasonable initial capacity can reduce the number of
    /// reallocations when many elements are added.
    /// </remarks>
    class function Create(const Capacity: Integer = 2): TArrayBuilder<T>; static;

    /// <summary>
    /// Reserves capacity for at least the specified number of items.
    /// </summary>
    /// <param name="Capacity">
    /// The minimum number of elements the internal buffer should be able to hold.
    /// If the current capacity is already greater than or equal to this value,
    /// no reallocation is performed.
    /// </param>
    /// <returns>
    /// Returns the updated <c>TArrayBuilder&lt;T&gt;</c> instance, allowing
    /// for method chaining.
    /// </returns>
    /// <remarks>
    /// Use this method when you know in advance how many elements will be
    /// added, to reduce the number of internal reallocations while building
    /// the array.
    /// </remarks>
    function Reserve(const Capacity: Integer): TArrayBuilder<T>;

    /// <summary>
    /// Appends a new item to the builder.
    /// </summary>
    /// <param name="Item">
    /// The element to add to the internal array buffer.
    /// </param>
    /// <returns>
    /// Returns the updated <c>TArrayBuilder&lt;T&gt;</c> instance, allowing
    /// for method chaining.
    /// </returns>
    /// <remarks>
    /// If necessary, the internal buffer is automatically grown before the
    /// item is appended.
    /// </remarks>
    function Add(const Item: T): TArrayBuilder<T>;

    /// <summary>
    /// Implicitly converts a <c>TArrayBuilder&lt;T&gt;</c> to a dynamic
    /// <c>TArray&lt;T&gt;</c>.
    /// </summary>
    /// <param name="Value">
    /// The builder instance whose accumulated items will be copied into the
    /// resulting array.
    /// </param>
    /// <returns>
    /// A <c>TArray&lt;T&gt;</c> containing all elements added to the builder,
    /// in insertion order.
    /// </returns>
    /// <remarks>
    /// This operator is typically used at the end of a fluent construction
    /// chain, when the final array is needed (for example, to pass into an
    /// API that expects a <c>TArray&lt;T&gt;</c>).
    /// </remarks>
    class operator Implicit(const Value: TArrayBuilder<T>): TArray<T>;
  end;

implementation

{$REGION 'dev note'}

(*

  TArrayBuilder<T> is a small utility to make incremental construction of
  TArray<T> more ergonomic, especially when building nested JSON structures
  from fluent APIs.

  The idea is that user code works with a builder (Create, Add, Reserve, ...)
  and only produces the final TArray<T> at the end via the implicit conversion.
  This keeps the public API signatures simple (they still accept plain
  TArray<T>), while allowing higher-level helpers to expose chained methods
  like:
    .AddFunction(...)
    .AddGoogleSearchRetrieval(...)
    .AddCodeExecution(...)
  without manual array bookkeeping in user code.

  Internally the builder manages the underlying buffer and its capacity, so the
  caller only has to express "append this element" in a fluent way. The goal is
  to make composing complex JSON payloads (lists of tools, parts, parameters,
  etc.) clearer, less error-prone, and easier to read.

*)

{$ENDREGION}

{ TArrayBuilder<T> }

function TArrayBuilder<T>.Add(const Item: T): TArrayBuilder<T>;
begin
  Result := Self;
  Result.Append(Item);
end;

procedure TArrayBuilder<T>.Append(const Item: T);
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

class function TArrayBuilder<T>.Create(
  const Capacity: Integer): TArrayBuilder<T>;
begin
  Result.FItems := nil;
  Result.FCount := 0;

  if Capacity > 0 then
    SetLength(Result.FItems, Capacity);
end;

class operator TArrayBuilder<T>.Implicit(
  const Value: TArrayBuilder<T>): TArray<T>;
begin
  Result := Copy(Value.FItems, 0, Value.FCount);
end;

function TArrayBuilder<T>.Reserve(const Capacity: Integer): TArrayBuilder<T>;
begin
  Result := Self;
  if (Capacity > 0) and (Length(Result.FItems) < Capacity) then
    SetLength(Result.FItems, Capacity);
end;

end.
