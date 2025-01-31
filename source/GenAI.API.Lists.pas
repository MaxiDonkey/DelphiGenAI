unit GenAI.API.Lists;

interface

uses
  GenAI.API.Params, REST.Json.Types;

type
  /// <summary>
  /// Represents a generic advanced list structure for handling API responses.
  /// </summary>
  /// <remarks>
  /// This class is a generic container for handling paginated API responses. It provides
  /// properties to store the retrieved data, pagination information, and object metadata.
  /// The generic type parameter <c>T</c> must be a class with a parameterless constructor.
  /// </remarks>
  /// <typeparam name="T">
  /// The class type of objects contained in the list. The type must have a parameterless
  /// constructor.
  /// </typeparam>
  TAdvancedList<T: class, constructor> = class(TJSONFingerprint)
    FObject: string;
    FData: TArray<T>;
    [JsonNameAttribute('has_more')]
    FHasMore: Boolean;
    [JsonNameAttribute('first_id')]
    FFirstId: string;
    [JsonNameAttribute('last_id')]
    FLastId: string;
  public
    /// <summary>
    /// Represents the type of object contained in the list.
    /// </summary>
    property &Object: string read FObject write FObject;
    /// <summary>
    /// Stores the list of retrieved objects.
    /// </summary>
    property Data: TArray<T> read FData write FData;
    /// <summary>
    /// Indicates whether there are more results available in the API pagination.
    /// </summary>
    property HasMore: Boolean read FHasMore write FHasMore;
    /// <summary>
    /// The ID of the first object in the current result set.
    /// </summary>
    property FirstId: string read FFirstId write FFirstId;
    /// <summary>
    /// The ID of the last object in the current result set.
    /// </summary>
    property LastId: string read FLastId write FLastId;
    destructor Destroy; override;
  end;

  /// <summary>
  /// Represents a paginated list of objects.
  /// This generic class can store a list of objects of type <c>T</c> and
  /// provides metadata about pagination, such as whether more results are available.
  /// </summary>
  /// <typeparam name="T">
  /// The type of objects stored in the list. It must be a class and have a default constructor.
  /// </typeparam>
  TPaginatedList<T: class, constructor> = class(TJSONFingerprint)
    FObject: string;
    FData: TArray<T>;
    [JsonNameAttribute('has_more')]
    FHasMore: Boolean;
  public
    /// <summary>
    /// Gets or sets the object type. This usually describes the nature of the list (e.g., "fine_tuning.jobs").
    /// </summary>
    property &Object: string read FObject write FObject;
    /// <summary>
    /// Gets or sets the array of objects stored in the list.
    /// Each element is of type <c>T</c>.
    /// </summary>
    property Data: TArray<T> read FData write FData;
    /// <summary>
    /// Gets or sets a boolean value indicating whether there are more results to fetch.
    /// </summary>
    property HasMore: Boolean read FHasMore write FHasMore;
    /// <summary>
    /// Destructor for the <c>TPaginatedList</c> class.
    /// Frees all objects stored in the <c>Data</c> property to release memory.
    /// </summary>
    destructor Destroy; override;
  end;

implementation

{ TAdvancedList<T> }

destructor TAdvancedList<T>.Destroy;
begin
  for var Item in FData do
    Item.Free;
  inherited;
end;

{ TPaginatedList<T> }

destructor TPaginatedList<T>.Destroy;
begin
  for var Item in FData do
    Item.Free;
  inherited;
end;

end.
