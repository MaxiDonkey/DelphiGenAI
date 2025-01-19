unit GenAI.Functions.Tools;

interface

uses
  System.SysUtils, System.Classes, REST.JsonReflect, System.JSON, REST.Json.Types,
  GenAI.Functions.Core;

type
  /// <summary>
  /// Represents a tool used for interacting with chat messages, including the ability to convert
  /// functions to JSON format.
  /// </summary>
  TChatMessageTool = record
  private
    FFunction: IFunctionCore;
  public
    /// <summary>
    /// This method converts the TFunctionCore instance to a JSON object containing the type and
    /// representation of the function, and handles exceptions by deleting the JSON object and
    /// propagating the exception if an error occurs
    /// </summary>
    /// <returns>
    /// A <c>TJSONObject</c> representing the function in JSON format.
    /// </returns>
    function ToJson: TJSONObject;
    /// <summary>
    /// The function properties
    /// </summary>
    property &Function: IFunctionCore read FFunction write FFunction;
    /// <summary>
    /// Adds a function to the chat message tool.
    /// </summary>
    /// <param name="AFunction">
    /// The function to be added.
    /// </param>
    /// <returns>
    /// An instance of <c>TChatMessageTool</c> containing the specified function.
    /// </returns>
    class function Add(const AFunction: IFunctionCore): TChatMessageTool; static;
  end;

  /// <summary>
  /// Represents the specifics of a called function, including its name and calculated arguments.
  /// </summary>
  TCalledFunctionSpecifics = class
  private
    FName: string;
    FArguments: string;
  public
    /// <summary>
    /// Gets or sets the name of the called function
    /// </summary>
    property Name: string read FName write FName;
    /// <summary>
    /// Gets or sets the calculed Arguments for the called function
    /// </summary>
    property Arguments: string read FArguments write FArguments;
  end;

  /// <summary>
  /// Represents a called function, containing its specifics such as name and arguments.
  /// </summary>
  TCalledFunction = class
  private
    FId: string;
    FType: string;
    FFunction: TCalledFunctionSpecifics;
  public
    /// <summary>
    /// Gets or sets the id of the called function
    /// </summary>
    property Id: string read FId write FId;
    /// <summary>
    /// Gets or sets the type of the called function
    /// </summary>
    property &Type: string read FType write FType;
    /// <summary>
    /// Gets or sets the specifics of the called function
    /// </summary>
    property &Function: TCalledFunctionSpecifics read FFunction write FFunction;
    /// <summary>
    /// Destructor that ensures proper memory management by freeing the <c>FFunction</c> property
    /// when the <c>TCalledFunction</c> instance is destroyed.
    /// </summary>
    destructor Destroy; override;
  end;

implementation

{ TChatMessageTool }

class function TChatMessageTool.Add(
  const AFunction: IFunctionCore): TChatMessageTool;
begin
  Result.&Function := AFunction;
end;

function TChatMessageTool.ToJson: TJSONObject;
begin
  Result := FFunction.ToJson;
end;

{ TCalledFunction }

destructor TCalledFunction.Destroy;
begin
  if Assigned(FFunction) then
    FFunction.Free;
  inherited;
end;

end.

