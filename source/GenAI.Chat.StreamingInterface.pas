unit GenAI.Chat.StreamingInterface;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGenAI
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.Net.HttpClient;

type
  /// <summary>
  /// Defines a reference to a procedure that handles streaming callback events.
  /// </summary>
  /// <typeparam name="T">
  /// The type of the class that represents a chunk of streaming data.
  /// Must be a class with a parameterless constructor.
  /// </typeparam>
  TStreamCallbackEvent<T: class, constructor> = reference to procedure(var Chunk: T; IsDone: Boolean; var Cancel: Boolean);

  /// <summary>
  /// Represents a callback interface for handling streaming data from the OpenAI API.
  /// </summary>
  IStreamCallback = interface
    ['{4F5F8B0D-0A08-4C47-8675-48F8D055F504}']
    /// <summary>
    /// Retrieves the callback method that is invoked when streaming data is received.
    /// </summary>
    /// <returns>
    /// A <see cref="TReceiveDataCallback"/> delegate that processes the streaming data.
    /// </returns>
    function GetOnStream: TReceiveDataCallback;
    /// <summary>
    /// Gets the callback method that is invoked when streaming data is received.
    /// </summary>
    /// <value>
    /// A <see cref="TReceiveDataCallback"/> delegate that processes the streaming data.
    /// </value>
    property OnStream: TReceiveDataCallback read GetOnStream;
  end;

implementation

end.
