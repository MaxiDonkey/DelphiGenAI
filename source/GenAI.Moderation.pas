unit GenAI.Moderation;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGenAI
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.SysUtils, System.Classes, System.Threading, System.JSON, REST.Json.Types,
  REST.JsonReflect,
  GenAI.API.Params, GenAI.API, GenAI.Consts, GenAI.Types, GenAI.Async.Support,
  GenAI.Async.Promise;

type
  /// <summary>
  /// Represents a text moderation parameter for a JSON object, enabling the configuration
  /// of text inputs to be classified for moderation purposes.
  /// </summary>
  /// <remarks>
  /// This class provides methods to define the type and content of text data to be
  /// analyzed for potentially harmful content. It is specifically designed for use
  /// in moderation APIs to assess textual content.
  /// </remarks>
  TTextModerationParams = class(TJSONParam)
  public
    /// <summary>
    /// Sets the type of input as 'text'. This ensures that the API interprets the
    /// input data as textual content for moderation.
    /// </summary>
    /// <param name="Value">
    /// A string that specifies the input type, typically 'text'.
    /// </param>
    /// <returns>
    /// Returns an instance of TTextModerationParams.
    /// </returns>
    function &Type(const Value: string): TTextModerationParams;

    /// <summary>
    /// Sets the text content to be classified for moderation. This method allows
    /// the inclusion of a string of text that will be evaluated by the moderation API.
    /// </summary>
    /// <param name="Value">
    /// The text content to be analyzed for potentially harmful content.
    /// </param>
    /// <returns>
    /// Returns an instance of TTextModerationParams.
    /// </returns>
    function Text(const Value: string): TTextModerationParams;

    /// <summary>
    /// Creates a new instance of TTextModerationParams with the specified text input.
    /// This method combines the configuration of input type and text content for
    /// streamlined initialization.
    /// </summary>
    /// <param name="Value">
    /// The string of text to be classified for moderation.
    /// </param>
    /// <returns>
    /// Returns a newly instantiated object of TTextModerationParams.
    /// </returns>
    class function New(const Value: string): TTextModerationParams;
  end;

  /// <summary>
  /// Represents a URL moderation parameter for a JSON object, enabling the configuration
  /// of URLs to be classified for moderation purposes.
  /// </summary>
  /// <remarks>
  /// This class provides methods to define and handle URLs as input for moderation.
  /// It supports both direct web URLs and local file paths that can be encoded into
  /// base64 format for evaluation by the moderation API.
  /// </remarks>
  TUrlModerationParams = class(TJSONParam)
  public
    /// <summary>
    /// Sets the URL of the resource to be moderated. This can be a direct web link
    /// or a file path for base64 encoding.
    /// </summary>
    /// <param name="Value">
    /// The URL or file path of the resource to be analyzed for potentially harmful content.
    /// </param>
    /// <returns>
    /// Returns an instance of TUrlModerationParams.
    /// </returns>
    function Url(const Value: string): TUrlModerationParams;

    /// <summary>
    /// Creates a new instance of TUrlModerationParams with the specified URL.
    /// This method initializes the URL parameter for moderation requests.
    /// </summary>
    /// <param name="Value">
    /// The URL or file path of the resource to be analyzed.
    /// </param>
    /// <returns>
    /// Returns a newly instantiated object of TUrlModerationParams.
    /// </returns>
    class function New(const Value: string): TUrlModerationParams;
  end;

  /// <summary>
  /// Represents an image moderation parameter for a JSON object, enabling the configuration
  /// of image inputs to be classified for moderation purposes.
  /// </summary>
  /// <remarks>
  /// This class provides methods to define the type and content of image data, either
  /// via direct URLs or base64-encoded strings, to be analyzed for potentially harmful content.
  /// It is specifically designed for use in moderation APIs to assess image content.
  /// </remarks>
  TImageModerationParams = class(TJSONParam)
  public
    /// <summary>
    /// Sets the type of input as 'image_url'. This ensures that the API interprets the
    /// input data as an image URL or base64-encoded image for moderation.
    /// </summary>
    /// <param name="Value">
    /// A string that specifies the input type, typically 'image_url'.
    /// </param>
    /// <returns>
    /// Returns an instance of TImageModerationParams.
    /// </returns>
    function &Type(const Value: string): TImageModerationParams;

    /// <summary>
    /// Sets the image URL or base64-encoded data to be classified for moderation.
    /// This method allows the inclusion of an image URL or encoded image data
    /// that will be evaluated by the moderation API.
    /// </summary>
    /// <param name="Value">
    /// The URL or base64-encoded string representing the image content.
    /// </param>
    /// <returns>
    /// Returns an instance of TImageModerationParams.
    /// </returns>
    function ImageUrl(const Value: string): TImageModerationParams;

    /// <summary>
    /// Creates a new instance of TImageModerationParams with the specified image URL or
    /// base64-encoded image data. This method combines the configuration of input type
    /// and image content for streamlined initialization.
    /// </summary>
    /// <param name="Value">
    /// The string of the image URL or base64-encoded data to be classified for moderation.
    /// </param>
    /// <returns>
    /// Returns a newly instantiated object of TImageModerationParams.
    /// </returns>
    class function New(const Value: string): TImageModerationParams;
  end;

  /// <summary>
  /// Represents the parameters for moderation requests, enabling configuration
  /// for input data and model selection to classify content for moderation purposes.
  /// </summary>
  /// <remarks>
  /// This class provides methods to configure and handle inputs for moderation,
  /// such as text, image URLs, or an array of mixed inputs. It also allows
  /// specifying the moderation model to use.
  /// </remarks>
  TModerationParams = class(TJSONParam)
  public
    /// <summary>
    /// Sets the input data for the moderation request. This can be a single string
    /// or an array of strings, and the type is determined automatically.
    /// </summary>
    /// <param name="Value">
    /// The input content as a string or an array of strings.
    /// </param>
    /// <returns>
    /// Returns an instance of TModerationParams.
    /// </returns>
    function Input(const Value: string): TModerationParams; overload;

    /// <summary>
    /// Sets multiple input data elements for the moderation request. This method
    /// accepts an array of strings, which can include text or image paths/URLs.
    /// </summary>
    /// <param name="Value">
    /// An array of strings representing text or image inputs.
    /// </param>
    /// <returns>
    /// Returns an instance of TModerationParams.
    /// </returns>
    function Input(const Value: TArray<string>): TModerationParams; overload;

    /// <summary>
    /// Specifies the moderation model to be used for the request. The default
    /// model is "omni-moderation-latest".
    /// </summary>
    /// <param name="Value">
    /// A string representing the name of the moderation model.
    /// </param>
    /// <returns>
    /// Returns an instance of TModerationParams.
    /// </returns>
    function Model(const Value: string): TModerationParams;
  end;

  /// <summary>
  /// Represents the moderation categories used to classify content as potentially harmful.
  /// Each category indicates a specific type of harmful content, such as harassment,
  /// violence, or hate speech.
  /// </summary>
  /// <remarks>
  /// This class provides properties for each moderation category. These properties
  /// are boolean values indicating whether the corresponding category is flagged
  /// for the given input.
  /// </remarks>
  TModerationCategories = class
  private
    FHate: Boolean;
    [JsonNameAttribute('hate/threatening')]
    FHateThreatening: Boolean;
    FHarassment: Boolean;
    [JsonNameAttribute('harassment/threatening')]
    FHarassmentThreatening: Boolean;
    FIllicit: Boolean;
    [JsonNameAttribute('illicit/violent')]
    FIllicitViolent: Boolean;
    [JsonNameAttribute('self-harm')]
    FSelfHarm: Boolean;
    [JsonNameAttribute('self-harm/intent')]
    FSelfHarmIntent: Boolean;
    [JsonNameAttribute('self-harm/instructions')]
    FSelfHarmInstructions: Boolean;
    FSexual: Boolean;
    [JsonNameAttribute('sexual/minors')]
    FSexualMinors: Boolean;
    FViolence: Boolean;
    [JsonNameAttribute('violence/graphics')]
    FViolenceGraphic: Boolean;
  public
    /// <summary>
    /// Indicates whether the content contains hate speech based on race, gender,
    /// ethnicity, religion, nationality, sexual orientation, disability status, or caste.
    /// </summary>
    property Hate: Boolean read FHate write FHate;

    /// <summary>
    /// Indicates whether the content includes hateful speech that also involves
    /// violence or serious harm towards the targeted group.
    /// </summary>
    property HateThreatening: Boolean read FHateThreatening write FHateThreatening;

    /// <summary>
    /// Indicates whether the content contains language that is harassing towards a target.
    /// </summary>
    property Harassment: Boolean read FHarassment write FHarassment;

    /// <summary>
    /// Indicates whether the harassing content also involves threats of violence
    /// or serious harm.
    /// </summary>
    property HarassmentThreatening: Boolean read FHarassmentThreatening write FHarassmentThreatening;

    /// <summary>
    /// Indicates whether the content includes instructions or advice that facilitate
    /// wrongdoing or illicit acts.
    /// </summary>
    property Illicit: Boolean read FIllicit write FIllicit;

    /// <summary>
    /// Indicates whether the illicit content also involves violence or weapon procurement.
    /// </summary>
    property IllicitViolent: Boolean read FIllicitViolent write FIllicitViolent;

    /// <summary>
    /// Indicates whether the content promotes or depicts acts of self-harm, such as
    /// suicide, cutting, or eating disorders.
    /// </summary>
    property SelfHarm: Boolean read FSelfHarm write FSelfHarm;

    /// <summary>
    /// Indicates whether the content explicitly states an intent to commit self-harm.
    /// </summary>
    property SelfHarmIntent: Boolean read FSelfHarmIntent write FSelfHarmIntent;

    /// <summary>
    /// Indicates whether the content provides instructions or encouragement for
    /// acts of self-harm.
    /// </summary>
    property SelfHarmInstructions: Boolean read FSelfHarmInstructions write FSelfHarmInstructions;

    /// <summary>
    /// Indicates whether the content contains sexually explicit material designed
    /// to arouse sexual excitement.
    /// </summary>
    property Sexual: Boolean read FSexual write FSexual;

    /// <summary>
    /// Indicates whether the content contains sexual material involving minors.
    /// </summary>
    property SexualMinors: Boolean read FSexualMinors write FSexualMinors;

    /// <summary>
    /// Indicates whether the content depicts acts of violence, death, or physical injury.
    /// </summary>
    property Violence: Boolean read FViolence write FViolence;

    /// <summary>
    /// Indicates whether the violent content is graphically detailed.
    /// </summary>
    property ViolenceGraphic: Boolean read FViolenceGraphic write FViolenceGraphic;
  end;

  /// <summary>
  /// Represents the scores for various moderation categories, providing numerical
  /// values that indicate the likelihood of content falling into specific harmful
  /// categories.
  /// </summary>
  /// <remarks>
  /// This class defines properties to store scores for multiple categories, such as
  /// hate, harassment, violence, and others. The scores range from 0 to 1, where
  /// higher values indicate a stronger likelihood of the content being flagged for
  /// the respective category.
  /// </remarks>
  TModerationCategoryScores = class
  private
    FHate: Double;
    [JsonNameAttribute('hate/threatening')]
    FHateThreatening: Double;
    FHarassment: Double;
    [JsonNameAttribute('harassment/threatening')]
    FHarassmentThreatening: Double;
    FIllicit: Double;
    [JsonNameAttribute('illicit/violent')]
    FIllicitViolent: Double;
    [JsonNameAttribute('self-harm')]
    FSelfHarm: Double;
    [JsonNameAttribute('self-harm/intent')]
    FSelfHarmIntent: Double;
    [JsonNameAttribute('self-harm/instructions')]
    FSelfHarmInstructions: Double;
    FSexual: Double;
    [JsonNameAttribute('sexual/minors')]
    FSexualMinors: Double;
    FViolence: Double;
    [JsonNameAttribute('violence/graphics')]
    FViolenceGraphic: Double;
  public
    /// <summary>
    /// The score for the 'hate' category, representing the likelihood of hateful content.
    /// </summary>
    property Hate: Double read FHate write FHate;

    /// <summary>
    /// The score for the 'hate/threatening' category, representing the likelihood
    /// of threatening hateful content.
    /// </summary>
    property HateThreatening: Double read FHateThreatening write FHateThreatening;

    /// <summary>
    /// The score for the 'harassment' category, representing the likelihood of
    /// harassing content.
    /// </summary>
    property Harassment: Double read FHarassment write FHarassment;

    /// <summary>
    /// The score for the 'harassment/threatening' category, representing the likelihood
    /// of threatening harassing content.
    /// </summary>
    property HarassmentThreatening: Double read FHarassmentThreatening write FHarassmentThreatening;

    /// <summary>
    /// The score for the 'illicit' category, representing the likelihood of content
    /// promoting illicit activities.
    /// </summary>
    property Illicit: Double read FIllicit write FIllicit;

    /// <summary>
    /// The score for the 'illicit/violent' category, representing the likelihood
    /// of content promoting illicit violence.
    /// </summary>
    property IllicitViolent: Double read FIllicitViolent write FIllicitViolent;

    /// <summary>
    /// The score for the 'self-harm' category, representing the likelihood of content
    /// promoting or encouraging self-harm.
    /// </summary>
    property SelfHarm: Double read FSelfHarm write FSelfHarm;

    /// <summary>
    /// The score for the 'self-harm/intent' category, representing the likelihood
    /// of content indicating self-harm intent.
    /// </summary>
    property SelfHarmIntent: Double read FSelfHarmIntent write FSelfHarmIntent;

    /// <summary>
    /// The score for the 'self-harm/instructions' category, representing the likelihood
    /// of content providing instructions on self-harm.
    /// </summary>
    property SelfHarmInstructions: Double read FSelfHarmInstructions write FSelfHarmInstructions;

    /// <summary>
    /// The score for the 'sexual' category, representing the likelihood of content
    /// with explicit sexual material.
    /// </summary>
    property Sexual: Double read FSexual write FSexual;

    /// <summary>
    /// The score for the 'sexual/minors' category, representing the likelihood
    /// of sexual content involving minors.
    /// </summary>
    property SexualMinors: Double read FSexualMinors write FSexualMinors;

    /// <summary>
    /// The score for the 'violence' category, representing the likelihood of content
    /// involving violence.
    /// </summary>
    property Violence: Double read FViolence write FViolence;

    /// <summary>
    /// The score for the 'violence/graphics' category, representing the likelihood
    /// of content with graphic depictions of violence.
    /// </summary>
    property ViolenceGraphic: Double read FViolenceGraphic write FViolenceGraphic;
  end;

  /// <summary>
  /// Represents a moderation category applied to various input types, providing
  /// details on how different moderation categories are assigned based on input.
  /// </summary>
  /// <remarks>
  /// This class provides properties to retrieve the specific input types (e.g., text or image)
  /// that are associated with each moderation category. It is useful for identifying
  /// the sources of flagged content within a moderation request.
  /// </remarks>
  TModerationCategoryApplied = class
  private
    FHate: TArray<string>;
    [JsonNameAttribute('hate/threatening')]
    FHateThreatening: TArray<string>;
    FHarassment: TArray<string>;
    [JsonNameAttribute('harassment/threatening')]
    FHarassmentThreatening: TArray<string>;
    FIllicit: TArray<string>;
    [JsonNameAttribute('illicit/violent')]
    FIllicitViolent: TArray<string>;
    [JsonNameAttribute('self-harm')]
    FSelfHarm: TArray<string>;
    [JsonNameAttribute('self-harm/intent')]
    FSelfHarmIntent: TArray<string>;
    [JsonNameAttribute('self-harm/instructions')]
    FSelfHarmInstructions: TArray<string>;
    FSexual: TArray<string>;
    [JsonNameAttribute('sexual/minors')]
    FSexualMinors: TArray<string>;
    FViolence: TArray<string>;
    [JsonNameAttribute('violence/graphics')]
    FViolenceGraphic: TArray<string>;
  public
    /// <summary>
    /// Categories applied to hateful content.
    /// </summary>
    property Hate: TArray<string> read FHate write FHate;

    /// <summary>
    /// Categories applied to hateful content that includes threats.
    /// </summary>
    property HateThreatening: TArray<string> read FHateThreatening write FHateThreatening;

    /// <summary>
    /// Categories applied to harassment content.
    /// </summary>
    property Harassment: TArray<string> read FHarassment write FHarassment;

    /// <summary>
    /// Categories applied to harassment content that includes threats.
    /// </summary>
    property HarassmentThreatening: TArray<string> read FHarassmentThreatening write FHarassmentThreatening;

    /// <summary>
    /// Categories applied to illicit content.
    /// </summary>
    property Illicit: TArray<string> read FIllicit write FIllicit;

    /// <summary>
    /// Categories applied to illicit content that involves violence.
    /// </summary>
    property IllicitViolent: TArray<string> read FIllicitViolent write FIllicitViolent;

    /// <summary>
    /// Categories applied to self-harm-related content.
    /// </summary>
    property SelfHarm: TArray<string> read FSelfHarm write FSelfHarm;

    /// <summary>
    /// Categories applied to self-harm content expressing intent.
    /// </summary>
    property SelfHarmIntent: TArray<string> read FSelfHarmIntent write FSelfHarmIntent;

    /// <summary>
    /// Categories applied to self-harm content providing instructions.
    /// </summary>
    property SelfHarmInstructions: TArray<string> read FSelfHarmInstructions write FSelfHarmInstructions;

    /// <summary>
    /// Categories applied to sexual content.
    /// </summary>
    property Sexual: TArray<string> read FSexual write FSexual;

    /// <summary>
    /// Categories applied to sexual content involving minors.
    /// </summary>
    property SexualMinors: TArray<string> read FSexualMinors write FSexualMinors;

    /// <summary>
    /// Categories applied to violent content.
    /// </summary>
    property Violence: TArray<string> read FViolence write FViolence;

    /// <summary>
    /// Categories applied to graphically violent content.
    /// </summary>
    property ViolenceGraphic: TArray<string> read FViolenceGraphic write FViolenceGraphic;
  end;

  /// <summary>
  /// Represents a flagged item that contains information about a harmful content category
  /// and its associated score as determined by a moderation model.
  /// </summary>
  /// <remarks>
  /// This record is used to store details about content that has been flagged during
  /// moderation, including the category of harm and its confidence score. It is
  /// typically part of a collection of flagged items in moderation results.
  /// </remarks>
  TFlaggedItem = record
  private
    FCategory: THarmCategories;
    FScore: Double;
  public
    /// <summary>
    /// Gets or sets the category of harm associated with the flagged item.
    /// </summary>
    property Category: THarmCategories read FCategory write FCategory;

    /// <summary>
    /// Gets or sets the confidence score for the flagged category.
    /// </summary>
    property Score: Double read FScore write FScore;

    /// <summary>
    /// Initializes a new instance of the TFlaggedItem record with the specified
    /// harm category and confidence score.
    /// </summary>
    /// <param name="ACategory">
    /// The category of harm associated with the flagged item.
    /// </param>
    /// <param name="AScore">
    /// The confidence score for the flagged category.
    /// </param>
    constructor Create(const ACategory: THarmCategories; const AScore: Double);
  end;

  /// <summary>
  /// Represents the result of a moderation process, including information about
  /// flagged categories, their confidence scores, and the associated input types.
  /// </summary>
  /// <remarks>
  /// This class provides a detailed overview of the moderation analysis, including
  /// which categories were flagged, the confidence scores for each category, and
  /// the types of inputs (e.g., text or image) associated with flagged categories.
  /// </remarks>
  TModerationResult = class
  strict private
    function GetFlaggedDetail: TArray<TFlaggedItem>;
  private
    FFlagged: Boolean;
    FCategories: TModerationCategories;
    [JsonNameAttribute('category_scores')]
    FCategoryScores: TModerationCategoryScores;
    [JsonNameAttribute('category_applied_input_types')]
    FCategoryAppliedInputTypes: TModerationCategoryApplied;
  public
    /// <summary>
    /// Indicates whether any categories were flagged during moderation.
    /// </summary>
    property Flagged: Boolean read FFlagged write FFlagged;

    /// <summary>
    /// Provides the status of all moderation categories and whether they were flagged.
    /// </summary>
    property Categories: TModerationCategories read FCategories write FCategories;

    /// <summary>
    /// Provides the confidence scores for each moderation category as predicted by the model.
    /// </summary>
    property CategoryScores: TModerationCategoryScores read FCategoryScores write FCategoryScores;

    /// <summary>
    /// Specifies the input types (e.g., text, image) associated with flagged categories.
    /// </summary>
    property CategoryAppliedInputTypes: TModerationCategoryApplied read FCategoryAppliedInputTypes write FCategoryAppliedInputTypes;

    /// <summary>
    /// Retrieves detailed information about flagged items, including their categories
    /// and confidence scores.
    /// </summary>
    property FlaggedDetail: TArray<TFlaggedItem> read GetFlaggedDetail;

    destructor Destroy; override;
  end;

  /// <summary>
  /// Represents the overall moderation response, including results, model information,
  /// and a unique identifier for the moderation request.
  /// </summary>
  /// <remarks>
  /// This class serves as the main container for moderation data, encapsulating
  /// results from the moderation process, the model used, and the unique request ID.
  /// </remarks>
  TModeration = class(TJSONFingerprint)
  private
    FId: string;
    FModel: string;
    FResults: TArray<TModerationResult>;
  public
    /// <summary>
    /// Gets or sets the unique identifier for the moderation request.
    /// </summary>
    property Id: string read FId write FId;

    /// <summary>
    /// Gets or sets the name of the moderation model used for evaluation.
    /// </summary>
    property Model: string read FModel write FModel;

    /// <summary>
    /// Gets or sets the array of results from the moderation process.
    /// </summary>
    property Results: TArray<TModerationResult> read FResults write FResults;

    destructor Destroy; override;
  end;

  /// <summary>
  /// Manages asynchronous callBacks for a request using <c>TModeration</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynModeration</c> type extends the <c>TAsynParams&lt;TModeration&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking operations.
  /// </remarks>
  TAsynModeration = TAsynCallBack<TModeration>;

  /// <summary>
  /// Represents a promise-based callback for asynchronous moderation requests.
  /// </summary>
  /// <remarks>
  /// Specializes <see cref="TPromiseCallBack{TModeration}"/> to simplify handling of moderation API responses.
  /// Use this type when you need a <c>TPromise</c> that resolves with a <see cref="TModeration"/> instance.
  /// </remarks>
  TPromiseModeration = TPromiseCallBack<TModeration>;

  /// <summary>
  /// Represents a route for handling moderation requests in the GenAI framework.
  /// This class provides methods for evaluating moderation parameters both
  /// synchronously and asynchronously.
  /// </summary>
  /// <remarks>
  /// This class is designed to manage moderation requests by interfacing with
  /// the GenAI API. It supports both synchronous and asynchronous operations
  /// for evaluating content against moderation models.
  /// </remarks>
  TModerationRoute = class(TGenAIRoute)
    /// <summary>
    /// Asynchronously evaluates the given moderation parameters and returns a promise that resolves with the moderation result.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure to configure the moderation parameters via a <see cref="TModerationParams"/> instance.
    /// </param>
    /// <param name="CallBacks">
    /// An optional function providing <see cref="TPromiseModeration"/> callbacks for start, success, and error handling.
    /// </param>
    /// <returns>
    /// A <c>TPromise&lt;TModeration&gt;</c> that completes when the moderation evaluation succeeds or fails.
    /// </returns>
    /// <remarks>
    /// Wraps <see cref="AsynEvaluate"/> to enable promise-based workflows with the moderation API.
    /// If <c>CallBacks</c> is omitted, only resolution and rejection are handled.
    /// </remarks>
    function AsyncAwaitEvaluate(const ParamProc: TProc<TModerationParams>;
      const CallBacks: TFunc<TPromiseModeration> = nil): TPromise<TModeration>;

    /// <summary>
    /// Synchronously evaluates the given moderation parameters and returns
    /// the moderation result.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure to configure the moderation parameters.
    /// </param>
    /// <returns>
    /// Returns a TModeration object containing the results of the moderation process.
    /// </returns>
    function Evaluate(const ParamProc: TProc<TModerationParams>): TModeration;

    /// <summary>
    /// Asynchronously evaluates the given moderation parameters and triggers
    /// the specified callback functions upon completion.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure to configure the moderation parameters.
    /// </param>
    /// <param name="CallBacks">
    /// A function that defines the asynchronous callbacks for success, error,
    /// and other states during the operation.
    /// </param>
    procedure AsynEvaluate(const ParamProc: TProc<TModerationParams>;
      const CallBacks: TFunc<TAsynModeration>);
  end;

implementation

uses
  GenAI.Httpx, GenAI.NetEncoding.Base64;

{ TModerationParams }

function TModerationParams.Input(const Value: string): TModerationParams;
begin
  Result := TModerationParams(Add('input', Value));
end;

function TModerationParams.Input(
  const Value: TArray<string>): TModerationParams;
begin
  var JSONArray := TJSONArray.Create;
  for var Item in Value do
    begin
      if Item.ToLower.StartsWith('http') or FileExists(Item) then
        JSONArray.Add( TImageModerationParams.New(Item).Detach ) else
        JSONArray.Add( TTextModerationParams.New(Item).Detach );
    end;
  Result := TModerationParams(Add('input', JSONArray));
end;

function TModerationParams.Model(const Value: string): TModerationParams;
begin
  Result := TModerationParams(Add('model', Value));
end;

{ TTextModerationParams }

class function TTextModerationParams.New(
  const Value: string): TTextModerationParams;
begin
  Result := TTextModerationParams.Create.&Type('text').Text(Value);
end;

function TTextModerationParams.Text(const Value: string): TTextModerationParams;
begin
  Result := TTextModerationParams(Add('text', Value));
end;

function TTextModerationParams.&Type(
  const Value: string): TTextModerationParams;
begin
  Result := TTextModerationParams(Add('type', Value));
end;

{ TImageModerationParams }

function TImageModerationParams.ImageUrl(
  const Value: string): TImageModerationParams;
begin
  Result := TImageModerationParams(Add('image_url', TUrlModerationParams.New(Value).Detach));
end;

class function TImageModerationParams.New(
  const Value: string): TImageModerationParams;
begin
  Result := TImageModerationParams.Create.&Type('image_url').ImageUrl(Value);
end;

function TImageModerationParams.&Type(
  const Value: string): TImageModerationParams;
begin
  Result := TImageModerationParams(Add('type', Value));
end;

{ TUrlModerationParams }

class function TUrlModerationParams.New(
  const Value: string): TUrlModerationParams;
begin
  Result := TUrlModerationParams.Create.Url(Value);
end;

function TUrlModerationParams.Url(const Value: string): TUrlModerationParams;
begin
  Result := TUrlModerationParams(Add('url', GetUrlOrEncodeBase64(Value)));
end;

{ TModeration }

destructor TModeration.Destroy;
begin
  for var Item in FResults do
    Item.Free;
  inherited;
end;

{ TModerationResult }

destructor TModerationResult.Destroy;
begin
  if Assigned(FCategories) then
    FCategories.Free;
  if Assigned(FCategoryScores) then
    FCategoryScores.Free;
  if Assigned(FCategoryAppliedInputTypes) then
    FCategoryAppliedInputTypes.Free;
  inherited;
end;

function TModerationResult.GetFlaggedDetail: TArray<TFlaggedItem>;
begin
  if not Flagged then
    Exit;

  if Categories.Hate then
    Result := Result + [TFlaggedItem.Create(THarmCategories.hate, CategoryScores.Hate)];
  if Categories.HateThreatening then
    Result := Result + [TFlaggedItem.Create(THarmCategories.hateThreatening, CategoryScores.HateThreatening)];
  if Categories.Harassment then
    Result := Result + [TFlaggedItem.Create(THarmCategories.harassment, CategoryScores.Harassment)];
  if Categories.HarassmentThreatening then
    Result := Result + [TFlaggedItem.Create(THarmCategories.harassmentThreatening, CategoryScores.HarassmentThreatening)];
  if Categories.Illicit then
    Result := Result + [TFlaggedItem.Create(THarmCategories.illicit, CategoryScores.Illicit)];
  if Categories.IllicitViolent then
    Result := Result + [TFlaggedItem.Create(THarmCategories.illicitViolent, CategoryScores.IllicitViolent)];
  if Categories.SelfHarm then
    Result := Result + [TFlaggedItem.Create(THarmCategories.selfHarm, CategoryScores.SelfHarm)];
  if Categories.SelfHarmIntent then
    Result := Result + [TFlaggedItem.Create(THarmCategories.selfHarmIntent, CategoryScores.SelfHarmIntent)];
  if Categories.SelfHarmInstructions then
    Result := Result + [TFlaggedItem.Create(THarmCategories.selfHarmInstructions, CategoryScores.SelfHarmInstructions)];
  if Categories.Sexual then
    Result := Result + [TFlaggedItem.Create(THarmCategories.sexual, CategoryScores.Sexual)];
  if Categories.SexualMinors then
    Result := Result + [TFlaggedItem.Create(THarmCategories.sexualMinors, CategoryScores.SexualMinors)];
  if Categories.Violence then
    Result := Result + [TFlaggedItem.Create(THarmCategories.violence, CategoryScores.Violence)];
  if Categories.ViolenceGraphic then
    Result := Result + [TFlaggedItem.Create(THarmCategories.violenceGraphic, CategoryScores.ViolenceGraphic)];
end;

{ TModerationRoute }

function TModerationRoute.AsyncAwaitEvaluate(
  const ParamProc: TProc<TModerationParams>;
  const CallBacks: TFunc<TPromiseModeration>): TPromise<TModeration>;
begin
  Result := TAsyncAwaitHelper.WrapAsyncAwait<TModeration>(
    procedure(const CallBackParams: TFunc<TAsynModeration>)
    begin
      AsynEvaluate(ParamProc, CallBackParams);
    end,
    CallBacks);
end;

procedure TModerationRoute.AsynEvaluate(
  const ParamProc: TProc<TModerationParams>; const CallBacks: TFunc<TAsynModeration>);
begin
  with TAsynCallBackExec<TAsynModeration, TModeration>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TModeration
      begin
        Result := Self.Evaluate(ParamProc);
      end);
  finally
    Free;
  end;
end;

function TModerationRoute.Evaluate(
  const ParamProc: TProc<TModerationParams>): TModeration;
begin
  Result := API.Post<TModeration, TModerationParams>('moderations', ParamProc);
end;

{ TFlaggedItem }

constructor TFlaggedItem.Create(const ACategory: THarmCategories;
  const AScore: Double);
begin
  FCategory := ACategory;
  FScore := AScore;
end;

end.
