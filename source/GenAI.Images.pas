unit GenAI.Images;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGenAI
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.SysUtils, System.Classes, System.Threading, System.JSON, REST.Json.Types,
  REST.JsonReflect, System.Net.Mime,
  GenAI.API.Params, GenAI.API, GenAI.Consts, GenAI.Types, GenAI.Async.Support;

type
  /// <summary>
  /// Represents a parameter class for creating images through the OpenAI API, enabling
  /// the configuration of prompts, models, and other settings for image generation.
  /// </summary>
  /// <remarks>
  /// This class provides methods to specify various parameters required for generating images,
  /// such as the text prompt, model, output size, and response format. It is designed
  /// for use with the image creation API to streamline the construction of requests.
  /// </remarks>
  TImageCreateParams = class(TJSONParam)
  public
    /// <summary>
    /// Sets the text prompt for the image generation process.
    /// </summary>
    /// <param name="Value">
    /// A string containing the textual description of the desired image.
    /// </param>
    /// <returns>
    /// Returns an instance of <c>TImageCreateParams</c> with the updated prompt.
    /// </returns>
    function Prompt(const Value: string): TImageCreateParams;
    /// <summary>
    /// Specifies the model to be used for image generation.
    /// </summary>
    /// <param name="Value">
    /// A string representing the name of the model, typically 'dall-e-2'.
    /// </param>
    /// <returns>
    /// Returns an instance of <c>TImageCreateParams</c> with the specified model.
    /// </returns>
    function Model(const Value: string): TImageCreateParams;
    /// <summary>
    /// Sets the number of images to generate.
    /// </summary>
    /// <param name="Value">
    /// An integer representing the desired number of images, between 1 and 10.
    /// </param>
    /// <returns>
    /// Returns an instance of <c>TImageCreateParams</c> with the specified number of images.
    /// </returns>
    function N(const Value: Integer): TImageCreateParams;
    /// <summary>
    /// Sets the quality of the generated images.
    /// </summary>
    /// <param name="Value">
    /// A string specifying the quality setting, such as 'high', 'medium', or 'low'.
    /// </param>
    /// <returns>
    /// Returns an instance of <c>TImageCreateParams</c> with the updated quality setting.
    /// </returns>
    function Quality(const Value: string): TImageCreateParams;
    /// <summary>
    /// Specifies the response format for the generated image(s).
    /// </summary>
    /// <param name="Value">
    /// A string representing the desired response format, such as 'url' or 'b64_json'.
    /// </param>
    /// <returns>
    /// Returns an instance of <c>TImageCreateParams</c> with the updated response format.
    /// </returns>
    function ResponseFormat(const Value: string): TImageCreateParams; overload;
    /// <summary>
    /// Specifies the response format for the generated image(s) using a predefined format type.
    /// </summary>
    /// <param name="Value">
    /// A <c>TResponseFormat</c> object representing the desired response format.
    /// </param>
    /// <returns>
    /// Returns an instance of <c>TImageCreateParams</c> with the updated response format.
    /// </returns>
    function ResponseFormat(const Value: TResponseFormat): TImageCreateParams; overload;
    /// <summary>
    /// Sets the size of the generated images.
    /// </summary>
    /// <param name="Value">
    /// A string specifying the dimensions of the image, such as '256x256', '512x512', or '1024x1024'.
    /// </param>
    /// <returns>
    /// Returns an instance of <c>TImageCreateParams</c> with the specified image size.
    /// </returns>
    function Size(const Value: string): TImageCreateParams; overload;
    /// <summary>
    /// Sets the size of the generated images using a predefined size type.
    /// </summary>
    /// <param name="Value">
    /// A <c>TImageSize</c> object representing the dimensions of the image.
    /// </param>
    /// <returns>
    /// Returns an instance of <c>TImageCreateParams</c> with the specified image size.
    /// </returns>
    function Size(const Value: TImageSize): TImageCreateParams; overload;
    /// <summary>
    /// Sets the style for the generated images using a string value.
    /// </summary>
    /// <param name="Value">
    /// A string specifying the desired style for the image, such as 'photorealistic' or 'sketch'.
    /// </param>
    /// <returns>
    /// Returns an instance of <c>TImageCreateParams</c> with the updated style setting.
    /// </returns>
    function Style(const Value: string): TImageCreateParams; overload;
    /// <summary>
    /// Sets the style for the generated images using a predefined style type.
    /// </summary>
    /// <param name="Value">
    /// A <c>TImageStyle</c> object representing the desired style for the image.
    /// </param>
    /// <returns>
    /// Returns an instance of <c>TImageCreateParams</c> with the updated style setting.
    /// </returns>
    function Style(const Value: TImageStyle): TImageCreateParams; overload;
    /// <summary>
    /// Sets the user identifier for the request.
    /// </summary>
    /// <param name="Value">
    /// A string representing the unique identifier for the end user. This can help
    /// with tracking and monitoring usage.
    /// </param>
    /// <returns>
    /// Returns an instance of <c>TImageCreateParams</c> with the updated user identifier.
    /// </returns>
    function User(const Value: string): TImageCreateParams;
  end;

  /// <summary>
  /// Represents a parameter class for editing images through the OpenAI API, enabling
  /// the configuration of images, masks, prompts, and other settings for image editing.
  /// </summary>
  /// <remarks>
  /// This class provides methods to specify various parameters required for editing images,
  /// such as the image file, mask, text prompt, model, output size, and response format.
  /// It is designed for use with the image editing API to streamline the construction of requests.
  /// </remarks>
  TImageEditParams = class(TMultipartFormData)
  public
    constructor Create; reintroduce;
    /// <summary>
    /// Specifies the image to be edited using a file path.
    /// </summary>
    /// <param name="Value">
    /// A string representing the file path of the image to be edited.
    /// </param>
    /// <returns>
    /// Returns an instance of <c>TImageEditParams</c> with the specified image file.
    /// </returns>
    function Image(const Value: string): TImageEditParams; overload;
    /// <summary>
    /// Specifies the image to be edited using a stream.
    /// </summary>
    /// <param name="Value">
    /// A <c>TStream</c> object containing the image data.
    /// </param>
    /// <param name="FileName">
    /// A string representing the file path for the image, used for reference purposes.
    /// </param>
    /// <returns>
    /// Returns an instance of <c>TImageEditParams</c> with the specified image stream.
    /// </returns>
    function Image(const Value: TStream; const FileName: string): TImageEditParams; overload;
    /// <summary>
    /// Sets the text prompt for the image editing process.
    /// </summary>
    /// <param name="Value">
    /// A string containing the textual description of the desired edits.
    /// </param>
    /// <returns>
    /// Returns an instance of <c>TImageEditParams</c> with the updated prompt.
    /// </returns>
    function Prompt(const Value: string): TImageEditParams;
    /// <summary>
    /// Specifies the mask image for the areas to be edited using a file path.
    /// </summary>
    /// <param name="Value">
    /// A string representing the file path of the mask image.
    /// </param>
    /// <returns>
    /// Returns an instance of <c>TImageEditParams</c> with the specified mask file.
    /// </returns>
    function Mask(const Value: string): TImageEditParams; overload;
    /// <summary>
    /// Specifies the mask image for the areas to be edited using a stream.
    /// </summary>
    /// <param name="Value">
    /// A <c>TStream</c> object containing the mask image data.
    /// </param>
    /// <param name="FilePath">
    /// A string representing the file path for the mask, used for reference purposes.
    /// </param>
    /// <returns>
    /// Returns an instance of <c>TImageEditParams</c> with the specified mask stream.
    /// </returns>
    function Mask(const Value: TStream; const FilePath: string): TImageEditParams; overload;
    /// <summary>
    /// Specifies the model to be used for image editing.
    /// </summary>
    /// <param name="Value">
    /// A string representing the name of the model, typically 'dall-e-2'.
    /// </param>
    /// <returns>
    /// Returns an instance of <c>TImageEditParams</c> with the specified model.
    /// </returns>
    function Model(const Value: string): TImageEditParams;
    /// <summary>
    /// Sets the number of images to generate during the edit.
    /// </summary>
    /// <param name="Value">
    /// An integer representing the desired number of images, between 1 and 10.
    /// </param>
    /// <returns>
    /// Returns an instance of <c>TImageEditParams</c> with the specified number of images.
    /// </returns>
    function N(const Value: Integer): TImageEditParams;
    /// <summary>
    /// Sets the size of the generated images.
    /// </summary>
    /// <param name="Value">
    /// A string specifying the dimensions of the image, such as '256x256', '512x512', or '1024x1024'.
    /// </param>
    /// <returns>
    /// Returns an instance of <c>TImageEditParams</c> with the specified image size.
    /// </returns>
    function Size(const Value: string): TImageEditParams; overload;
    /// <summary>
    /// Sets the size of the generated images using a predefined size type.
    /// </summary>
    /// <param name="Value">
    /// A <c>TImageSize</c> object representing the dimensions of the image.
    /// </param>
    /// <returns>
    /// Returns an instance of <c>TImageEditParams</c> with the specified image size.
    /// </returns>
    function Size(const Value: TImageSize): TImageEditParams; overload;
    /// <summary>
    /// Specifies the response format for the edited image(s).
    /// </summary>
    /// <param name="Value">
    /// A string representing the desired response format, such as 'url' or 'b64_json'.
    /// </param>
    /// <returns>
    /// Returns an instance of <c>TImageEditParams</c> with the updated response format.
    /// </returns>
    function ResponseFormat(const Value: string): TImageEditParams; overload;
    /// <summary>
    /// Specifies the response format for the edited image(s) using a predefined format type.
    /// </summary>
    /// <param name="Value">
    /// A <c>TResponseFormat</c> object representing the desired response format.
    /// </param>
    /// <returns>
    /// Returns an instance of <c>TImageEditParams</c> with the updated response format.
    /// </returns>
    function ResponseFormat(const Value: TResponseFormat): TImageEditParams; overload;
    /// <summary>
    /// Sets the user identifier for the request.
    /// </summary>
    /// <param name="Value">
    /// A string representing the unique identifier for the end user. This can help
    /// with tracking and monitoring usage.
    /// </param>
    /// <returns>
    /// Returns an instance of <c>TImageEditParams</c> with the updated user identifier.
    /// </returns>
    function User(const Value: string): TImageEditParams;
  end;

  /// <summary>
  /// Represents a parameter class for creating image variations through the OpenAI API, enabling
  /// the configuration of images, models, and other settings for variation generation.
  /// </summary>
  /// <remarks>
  /// This class provides methods to specify various parameters required for generating image variations,
  /// such as the base image, model, output size, and response format. It is designed
  /// for use with the image variation API to streamline the construction of requests.
  /// </remarks>
  TImageVariationParams = class(TMultipartFormData)
  public
    constructor Create; reintroduce;
    /// <summary>
    /// Specifies the base image to be used for generating variations using a file path.
    /// </summary>
    /// <param name="Value">
    /// A string representing the file path of the base image.
    /// </param>
    /// <returns>
    /// Returns an instance of <c>TImageVariationParams</c> with the specified base image file.
    /// </returns>
    function Image(const Value: string): TImageVariationParams; overload;
    /// <summary>
    /// Specifies the base image to be used for generating variations using a stream.
    /// </summary>
    /// <param name="Value">
    /// A <c>TStream</c> object containing the base image data.
    /// </param>
    /// <param name="FilePath">
    /// A string representing the file path for the image, used for reference purposes.
    /// </param>
    /// <returns>
    /// Returns an instance of <c>TImageVariationParams</c> with the specified base image stream.
    /// </returns>
    function Image(const Value: TStream; const FilePath: string): TImageVariationParams; overload;
    /// <summary>
    /// Specifies the model to be used for generating image variations.
    /// </summary>
    /// <param name="Value">
    /// A string representing the name of the model, typically 'dall-e-2'.
    /// </param>
    /// <returns>
    /// Returns an instance of <c>TImageVariationParams</c> with the specified model.
    /// </returns>
    function Model(const Value: string): TImageVariationParams;
    /// <summary>
    /// Sets the number of variations to generate.
    /// </summary>
    /// <param name="Value">
    /// An integer representing the desired number of image variations, between 1 and 10.
    /// </param>
    /// <returns>
    /// Returns an instance of <c>TImageVariationParams</c> with the specified number of variations.
    /// </returns>
    function N(const Value: Integer): TImageVariationParams;
    /// <summary>
    /// Specifies the response format for the generated image variations.
    /// </summary>
    /// <param name="Value">
    /// A string representing the desired response format, such as 'url' or 'b64_json'.
    /// </param>
    /// <returns>
    /// Returns an instance of <c>TImageVariationParams</c> with the updated response format.
    /// </returns>
    function ResponseFormat(const Value: string): TImageVariationParams; overload;
    /// <summary>
    /// Specifies the response format for the generated image variations using a predefined format type.
    /// </summary>
    /// <param name="Value">
    /// A <c>TResponseFormat</c> object representing the desired response format.
    /// </param>
    /// <returns>
    /// Returns an instance of <c>TImageVariationParams</c> with the updated response format.
    /// </returns>
    function ResponseFormat(const Value: TResponseFormat): TImageVariationParams; overload;
    /// <summary>
    /// Sets the size of the generated image variations.
    /// </summary>
    /// <param name="Value">
    /// A string specifying the dimensions of the image, such as '256x256', '512x512', or '1024x1024'.
    /// </param>
    /// <returns>
    /// Returns an instance of <c>TImageVariationParams</c> with the specified image size.
    /// </returns>
    function Size(const Value: string): TImageVariationParams; overload;
    /// <summary>
    /// Sets the size of the generated image variations using a predefined size type.
    /// </summary>
    /// <param name="Value">
    /// A <c>TImageSize</c> object representing the dimensions of the image.
    /// </param>
    /// <returns>
    /// Returns an instance of <c>TImageVariationParams</c> with the specified image size.
    /// </returns>
    function Size(const Value: TImageSize): TImageVariationParams; overload;
    /// <summary>
    /// Sets the user identifier for the request.
    /// </summary>
    /// <param name="Value">
    /// A string representing the unique identifier for the end user. This can help
    /// with tracking and monitoring usage.
    /// </param>
    /// <returns>
    /// Returns an instance of <c>TImageVariationParams</c> with the updated user identifier.
    /// </returns>
    function User(const Value: string): TImageVariationParams;
  end;

  /// <summary>
  /// Represents the data object for an image created through the OpenAI API.
  /// </summary>
  /// <remarks>
  /// This class contains the properties of the generated image, including its URL,
  /// base64-encoded content, and the revised prompt (if applicable).
  /// </remarks>
  TImageCreateData = class
  private
    [JsonNameAttribute('b64_json')]
    FB64Json: string;
    FUrl: string;
    [JsonNameAttribute('revised_prompt')]
    FRevisedPrompt: string;
  public
    /// <summary>
    /// Gets or sets the base64-encoded representation of the generated image.
    /// </summary>
    /// <value>
    /// A string containing the base64-encoded image content.
    /// </value>
    property B64Json: string read FB64Json write FB64Json;
    /// <summary>
    /// Gets or sets the URL of the generated image.
    /// </summary>
    /// <value>
    /// A string containing the URL of the generated image.
    /// </value>
    property Url: string read FUrl write FUrl;
    /// <summary>
    /// Gets or sets the revised prompt used to generate the image.
    /// </summary>
    /// <value>
    /// A string containing the revised prompt, if applicable.
    /// </value>
    property RevisedPrompt: string read FRevisedPrompt write FRevisedPrompt;
  end;

  /// <summary>
  /// Represents a part of the generated image, extending the <c>TImageCreateData</c> class
  /// to include file management functionality.
  /// </summary>
  /// <remarks>
  /// This class provides additional methods for handling the generated image, such as
  /// saving it to a file or retrieving it as a stream. It is designed for scenarios where
  /// the generated image needs to be manipulated or stored locally.
  /// </remarks>
  TImagePart = class(TImageCreateData)
  private
    FFileName: string;
  public
    /// <summary>
    /// Retrieves the generated image as a stream.
    /// </summary>
    /// <returns>
    /// A <c>TStream</c> object containing the image data.
    /// </returns>
    function GetStream: TStream;
    /// <summary>
    /// Downloads the generated image and saves it to the specified file path.
    /// </summary>
    /// <param name="FileName">
    /// A string specifying the file path where the image will be saved.
    /// </param>
    procedure Download(const FileName: string);
    /// <summary>
    /// Saves the generated image to the specified file path.
    /// </summary>
    /// <param name="FileName">
    /// A string specifying the file path where the image will be saved.
    /// </param>
    /// <param name="RaiseError">
    /// A boolean value indicating whether to raise an exception if the <c>FileName</c> is empty.
    /// <para>
    /// - If set to <c>True</c>, an exception will be raised for an empty file path.
    /// </para>
    /// <para>
    /// - If set to <c>False</c>, the method will exit silently without saving.
    /// </para>
    /// </param>
    /// <remarks>
    /// This method saves the base64-encoded image content to the specified file. Ensure that
    /// the <c>FileName</c> parameter is valid if <c>RaiseError</c> is set to <c>True</c>.
    /// If the <c>FileName</c> is empty and <c>RaiseError</c> is <c>False</c>, the method
    /// will terminate without performing any operation.
    /// </remarks>
    procedure SaveToFile(const FileName: string; const RaiseError: Boolean = True);
    /// <summary>
    /// Gets or sets the name of the file associated with the generated image.
    /// </summary>
    /// <value>
    /// A string representing the file name.
    /// </value>
    property FileName: string read FFileName write FFileName;
  end;

  /// <summary>
  /// Represents the response object containing a collection of generated images
  /// and metadata about the creation process.
  /// </summary>
  /// <remarks>
  /// This class encapsulates the data returned by the OpenAI API for image generation,
  /// including the timestamp of creation and the list of generated images. It provides
  /// functionality for managing the lifecycle of these objects.
  /// </remarks>
  TGeneratedImages = class(TJSONFingerprint)
  private
    FCreated: TInt64OrNull;
    FData: TArray<TImagePart>;
  private
    function GetCreatedAsString: string;
    function GetCreated: Int64;
  public
    /// <summary>
    /// Gets the timestamp indicating when the images were created.
    /// </summary>
    property Created: Int64 read GetCreated;
    /// <summary>
    /// Gets the timestamp as string, indicating when the images were created.
    /// </summary>
    property CreatedAsString: string read GetCreatedAsString;
    /// <summary>
    /// Gets or sets the collection of generated images.
    /// </summary>
    property Data: TArray<TImagePart> read FData write FData;
    destructor Destroy; override;
  end;

  /// <summary>
  /// Manages asynchronous callBacks for a request using <c>TGeneratedImages</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynImagesCreate</c> type extends the <c>TAsynParams&lt;TGeneratedImages&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking operations.
  /// </remarks>
  TAsynGeneratedImages = TAsynCallBack<TGeneratedImages>;

  /// <summary>
  /// Represents the route handler for image-related operations using the OpenAI API.
  /// </summary>
  /// <remarks>
  /// This class provides methods for creating, editing, and generating variations of images.
  /// It supports both synchronous and asynchronous operations, making it suitable for
  /// diverse use cases involving image generation and manipulation.
  /// </remarks>
  TImagesRoute = class(TGenAIRoute)
    /// <summary>
    /// Initiates an asynchronous image creation process.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure that configures the parameters for the image creation request.
    /// </param>
    /// <param name="CallBacks">
    /// A function that defines the callbacks for handling success, error, and completion states.
    /// </param>
    procedure AsynCreate(const ParamProc: TProc<TImageCreateParams>; const CallBacks: TFunc<TAsynGeneratedImages>);
    /// <summary>
    /// Initiates an asynchronous image editing process.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure that configures the parameters for the image editing request.
    /// </param>
    /// <param name="CallBacks">
    /// A function that defines the callbacks for handling success, error, and completion states.
    /// </param>
    procedure AsynEdit(const ParamProc: TProc<TImageEditParams>; const CallBacks: TFunc<TAsynGeneratedImages>);
    /// <summary>
    /// Initiates an asynchronous process for generating variations of an image.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure that configures the parameters for the image variation request.
    /// </param>
    /// <param name="CallBacks">
    /// A function that defines the callbacks for handling success, error, and completion states.
    /// </param>
    procedure AsynVariation(const ParamProc: TProc<TImageVariationParams>; const CallBacks: TFunc<TAsynGeneratedImages>);
    /// <summary>
    /// Creates an image synchronously based on the provided parameters.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure that configures the parameters for the image creation request.
    /// </param>
    /// <returns>
    /// A <c>TGeneratedImages</c> object containing the created images and metadata.
    /// </returns>
    function Create(const ParamProc: TProc<TImageCreateParams>): TGeneratedImages;
    /// <summary>
    /// Edits an image synchronously based on the provided parameters.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure that configures the parameters for the image editing request.
    /// </param>
    /// <returns>
    /// A <c>TGeneratedImages</c> object containing the edited images and metadata.
    /// </returns>
    function Edit(const ParamProc: TProc<TImageEditParams>): TGeneratedImages;
    /// <summary>
    /// Generates variations of an image synchronously based on the provided parameters.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure that configures the parameters for the image variation request.
    /// </param>
    /// <returns>
    /// A <c>TGeneratedImages</c> object containing the image variations and metadata.
    /// </returns>
    function Variation(const ParamProc: TProc<TImageVariationParams>): TGeneratedImages;
  end;

implementation

uses
  GenAI.Httpx, GenAI.NetEncoding.Base64;

{ TImageCreateParams }

function TImageCreateParams.Model(const Value: string): TImageCreateParams;
begin
  Result := TImageCreateParams(Add('model', Value));
end;

function TImageCreateParams.N(const Value: Integer): TImageCreateParams;
begin
  Result := TImageCreateParams(Add('n', Value));
end;

function TImageCreateParams.Prompt(const Value: string): TImageCreateParams;
begin
  Result := TImageCreateParams(Add('prompt', Value));
end;

function TImageCreateParams.Quality(const Value: string): TImageCreateParams;
begin
  Result := TImageCreateParams(Add('quality', Value));
end;

function TImageCreateParams.ResponseFormat(
  const Value: TResponseFormat): TImageCreateParams;
begin
  Result := TImageCreateParams(Add('response_format', Value.ToString));
end;

function TImageCreateParams.ResponseFormat(
  const Value: string): TImageCreateParams;
begin
  Result := TImageCreateParams(Add('response_format', TResponseFormat.Create(Value).ToString));
end;

function TImageCreateParams.Size(const Value: string): TImageCreateParams;
begin
  Result := TImageCreateParams(Add('size', TImageSize.Create(Value).ToString));
end;

function TImageCreateParams.Size(const Value: TImageSize): TImageCreateParams;
begin
  Result := TImageCreateParams(Add('size', Value.ToString));
end;

function TImageCreateParams.Style(
  const Value: TImageStyle): TImageCreateParams;
begin
  Result := TImageCreateParams(Add('style', Value.ToString));
end;

function TImageCreateParams.Style(const Value: string): TImageCreateParams;
begin
  Result := TImageCreateParams(Add('style', TImageStyle.Create(Value).ToString));
end;

function TImageCreateParams.User(const Value: string): TImageCreateParams;
begin
  Result := TImageCreateParams(Add('user', Value));
end;

{ TImagePart }

procedure TImagePart.Download(const FileName: string);
begin
  B64Json := THttpx.LoadDataToBase64(Url);
  SaveToFile(FileName);
end;

function TImagePart.GetStream: TStream;
begin
  {--- Download the image if the generation returns a URL instead of a Base64 string. }
  if B64JSON.IsEmpty then
    begin
      THttpx.UrlCheck(Url);
      B64Json := THttpx.LoadDataToBase64(Url);
    end;

  {--- Create a memory stream to write the decoded content. }
  Result := TMemoryStream.Create;
  try
    {--- Convert the base-64 string directly into the memory stream. }
    DecodeBase64ToStream(B64Json, Result)
  except
    Result.Free;
    raise;
  end;
end;

procedure TImagePart.SaveToFile(const FileName: string;
  const RaiseError: Boolean);
begin
  case RaiseError of
    True :
      if FileName.Trim.IsEmpty then
        raise Exception.Create('File record aborted. SaveToFile requires a filename.');
    else
      if FileName.Trim.IsEmpty then
        Exit;
  end;

  if RaiseError and FileName.Trim.IsEmpty then
    raise Exception.Create('File record aborted. SaveToFile requires a filename.');

  try
    Self.FFileName := FileName;
    {--- Perform the decoding operation and save it into the file specified by the FileName parameter. }
    DecodeBase64ToFile(B64Json, FileName)
  except
    raise;
  end;
end;

{ TImagesRoute }

procedure TImagesRoute.AsynCreate(const ParamProc: TProc<TImageCreateParams>;
  const CallBacks: TFunc<TAsynGeneratedImages>);
begin
  with TAsynCallBackExec<TAsynGeneratedImages, TGeneratedImages>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TGeneratedImages
      begin
        Result := Self.Create(ParamProc);
      end);
  finally
    Free;
  end;
end;

procedure TImagesRoute.AsynEdit(const ParamProc: TProc<TImageEditParams>;
  const CallBacks: TFunc<TAsynGeneratedImages>);
begin
  with TAsynCallBackExec<TAsynGeneratedImages, TGeneratedImages>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TGeneratedImages
      begin
        Result := Self.Edit(ParamProc);
      end);
  finally
    Free;
  end;
end;

procedure TImagesRoute.AsynVariation(
  const ParamProc: TProc<TImageVariationParams>;
  const CallBacks: TFunc<TAsynGeneratedImages>);
begin
  with TAsynCallBackExec<TAsynGeneratedImages, TGeneratedImages>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TGeneratedImages
      begin
        Result := Self.Variation(ParamProc);
      end);
  finally
    Free;
  end;
end;

function TImagesRoute.Create(const ParamProc: TProc<TImageCreateParams>): TGeneratedImages;
begin
  Result := API.Post<TGeneratedImages, TImageCreateParams>('images/generations', ParamProc);
end;

function TImagesRoute.Edit(
  const ParamProc: TProc<TImageEditParams>): TGeneratedImages;
begin
  Result := API.PostForm<TGeneratedImages, TImageEditParams>('images/edits', ParamProc);
end;

function TImagesRoute.Variation(
  const ParamProc: TProc<TImageVariationParams>): TGeneratedImages;
begin
  Result := API.PostForm<TGeneratedImages, TImageVariationParams>('images/variations', ParamProc);
end;

{ TGeneratedImages }

destructor TGeneratedImages.Destroy;
begin
  for var Item in FData do
    Item.Free;
  inherited;
end;

function TGeneratedImages.GetCreated: Int64;
begin
  Result := TInt64OrNull(FCreated).ToInteger;
end;

function TGeneratedImages.GetCreatedAsString: string;
begin
  Result := TInt64OrNull(FCreated).ToUtcDateString;
end;

{ TImageEditParams }

function TImageEditParams.Image(const Value: string): TImageEditParams;
begin
  AddFile('image', Value);
  Result := Self;
end;

constructor TImageEditParams.Create;
begin
  inherited Create(true);
end;

function TImageEditParams.Image(const Value: TStream; const FileName: string): TImageEditParams;
begin
  {$IF RTLVersion >= 35.0}
    AddStream('image', Value, True, FileName);
  {$ELSE}
    AddStream('image', Value, FileName);
  {$ENDIF}
  Result := Self;
end;

function TImageEditParams.Mask(const Value: TStream;
  const FilePath: string): TImageEditParams;
begin
  {$IF RTLVersion >= 35.0}
    AddStream('mask', Value, True, FilePath);
  {$ELSE}
    AddStream('mask', Value, FilePath);
  {$ENDIF}
  Result := Self;
end;

function TImageEditParams.Mask(const Value: string): TImageEditParams;
begin
  AddFile('mask', Value);
  Result := Self;
end;

function TImageEditParams.Model(const Value: string): TImageEditParams;
begin
  AddField('model', Value);
  Result := Self;
end;

function TImageEditParams.N(const Value: Integer): TImageEditParams;
begin
  AddField('n', Value.ToString);
  Result := Self;
end;

function TImageEditParams.Prompt(const Value: string): TImageEditParams;
begin
  AddField('prompt', Value);
  Result := Self;
end;

function TImageEditParams.ResponseFormat(
  const Value: TResponseFormat): TImageEditParams;
begin
  AddField('response_format', Value.ToString);
  Result := Self;
end;

function TImageEditParams.ResponseFormat(
  const Value: string): TImageEditParams;
begin
  AddField('response_format', TResponseFormat.Create(Value).ToString);
  Result := Self;
end;

function TImageEditParams.Size(const Value: TImageSize): TImageEditParams;
begin
  AddField('size', Value.ToString);
  Result := Self;
end;

function TImageEditParams.User(const Value: string): TImageEditParams;
begin
  AddField('user', Value);
  Result := Self;
end;

function TImageEditParams.Size(const Value: string): TImageEditParams;
begin
  AddField('size', TImageSize.Create(Value).ToString);
  Result := Self;
end;

{ TImageVariationParams }

constructor TImageVariationParams.Create;
begin
  inherited Create(true);
end;

function TImageVariationParams.Image(const Value: TStream;
  const FilePath: string): TImageVariationParams;
begin
  {$IF RTLVersion >= 35.0}
    AddStream('image', Value, True, FilePath);
  {$ELSE}
    AddStream('image', Value, FilePath);
  {$ENDIF}
  Result := Self;
end;

function TImageVariationParams.Model(const Value: string): TImageVariationParams;
begin
  AddField('model', Value);
  Result := Self;
end;

function TImageVariationParams.N(const Value: Integer): TImageVariationParams;
begin
  AddField('n', Value.ToString);
  Result := Self;
end;

function TImageVariationParams.ResponseFormat(
  const Value: TResponseFormat): TImageVariationParams;
begin
  AddField('response_format', Value.ToString);
  Result := Self;
end;

function TImageVariationParams.Size(
  const Value: TImageSize): TImageVariationParams;
begin
  AddField('size', Value.ToString);
  Result := Self;
end;

function TImageVariationParams.User(const Value: string): TImageVariationParams;
begin
  AddField('user', Value);
  Result := Self;
end;

function TImageVariationParams.Size(const Value: string): TImageVariationParams;
begin
  AddField('size', TImageSize.Create(Value).ToString);
  Result := Self;
end;

function TImageVariationParams.ResponseFormat(
  const Value: string): TImageVariationParams;
begin
  AddField('response_format', TResponseFormat.Create(Value).ToString);
  Result := Self;
end;

function TImageVariationParams.Image(const Value: string): TImageVariationParams;
begin
  AddFile('image', Value);
  Result := Self;
end;

end.
