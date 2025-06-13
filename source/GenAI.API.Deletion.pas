unit GenAI.API.Deletion;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGenAI
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  GenAI.API.Params, GenAI.Async.Support;

type
  /// <summary>
  /// Represents a deletion response, providing details about the identifier, object type,
  /// and whether the deletion was successful.
  /// </summary>
  /// <remarks>
  /// This class is primarily used to store the result of a deletion request, including
  /// the unique ID of the deleted object, the type of the object, and a status indicating
  /// whether the deletion was completed successfully.
  /// </remarks>
  TDeletion = class(TJSONFingerprint)
  private
    FId: string;
    FObject: string;
    FDeleted: Boolean;
  public
    /// <summary>
    /// The unique identifier.
    /// </summary>
    property Id: string read FId write FId;
    /// <summary>
    /// The object type.
    /// </summary>
    property &Object: string read FObject write FObject;
    /// <summary>
    /// Indicates whether the operation was successfully deleted.
    /// </summary>
    /// <remarks>
    /// This property is set to <c>true</c> if the deletion was successful, and <c>false</c>
    /// otherwise.
    /// </remarks>
    property Deleted: Boolean read FDeleted write FDeleted;
  end;

  /// <summary>
  /// Manages asynchronous callBacks for a request using <c>TDeletion</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynDeletion</c> type extends the <c>TAsynParams&lt;TDeletion&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking operations.
  /// </remarks>
  TAsynDeletion = TAsynCallBack<TDeletion>;

  /// <summary>
  /// Represents a promise-based callback for handling asynchronous deletion operations.
  /// </summary>
  /// <remarks>
  /// <para>
  /// This type alias specializes <c>TPromiseCallBack</c> with <c>TDeletion</c>,
  /// providing a promise-style mechanism to process the result of a deletion request.
  /// It encapsulates both success and error handling for operations that return a <c>TDeletion</c> response.
  /// </para>
  /// <para>
  /// Use <c>TPromiseDeletion</c> whenever you need to initiate a deletion request
  /// and react to its completion (successful or failed) in a non-blocking, promise-like fashion.
  /// </para>
  /// </remarks>
  TPromiseDeletion = TPromiseCallBack<TDeletion>;

implementation

end.
