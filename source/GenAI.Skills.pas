unit GenAI.Skills;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGenAI
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.SysUtils, System.Classes, System.Threading, System.JSON, REST.Json.Types,
  REST.JsonReflect, System.Net.Mime,
  GenAI.API.Params, GenAI.API, GenAI.Consts, GenAI.Types, GenAI.Async.Support,
  GenAI.Async.Promise, GenAI.API.Lists, GenAI.API.Deletion,
  GenAI.API.MultiFormData;

type
  TUrlSkillsParams = class(TUrlParam)
  public
    /// <summary>
    /// A cursor for use in pagination. after is an object ID that defines your place in the list.
    /// </summary>
    /// <param name="Value">
    /// A string specifying the ID of the last skill from the previous page to start fetching the next page.
    /// </param>
    /// <returns>
    /// Returns an instance of TUrlSkillsParams, allowing for method chaining.
    /// </returns>
    function After(const Value: string): TUrlSkillsParams;

    /// <summary>
    /// A limit on the number of objects to be returned. Limit can range between 1 and 100, and the default is 20.
    /// </summary>
    /// <param name="Value">
    /// An integer specifying the maximum number of skills to be returned.
    /// </param>
    /// <returns>
    /// Returns an instance of TUrlSkillsParams, allowing for method chaining.
    /// </returns>
    function Limit(const Value: Integer): TUrlSkillsParams;

    /// <summary>
    /// Sort order by the created_at timestamp of the objects. asc for ascending order and desc for descending order.
    /// </summary>
    /// <param name="Value">
    /// A string specifying the sort order, either 'asc' or 'desc'. Defaults to 'desc'.
    /// </param>
    /// <returns>
    /// Returns an instance of TUrlSkillsParams, allowing for method chaining.
    /// </returns>
    function Order(const Value: string = 'desc'): TUrlSkillsParams;
  end;

  TSkillCreateParams = class(TMultiFormDataParams)
  public
    constructor Create; reintroduce;

    /// <summary>
    /// Adds a single skill file (e.g., a zip bundle) to the form data, using a file path.
    /// </summary>
    /// <param name="Value">
    /// A string representing the path to the file to be uploaded.
    /// </param>
    /// <returns>
    /// Returns an instance of TSkillCreateParams, allowing for method chaining.
    /// </returns>
    /// <remarks>
    /// Sent as the multipart field <c>files[]</c>.
    /// </remarks>
    function &File(const Value: string): TSkillCreateParams; overload;

    /// <summary>
    /// Adds a single skill file to the form data, using a stream.
    /// </summary>
    /// <param name="Value">
    /// A <c>TStream</c> object containing the file data.
    /// </param>
    /// <param name="FileName">
    /// A string representing the file name associated with the stream, used for reference purposes.
    /// </param>
    /// <returns>
    /// Returns an instance of TSkillCreateParams, allowing for method chaining.
    /// </returns>
    /// <remarks>
    /// Sent as the multipart field <c>files[]</c>.
    /// </remarks>
    function &File(const Value: TStream; const FileName: string): TSkillCreateParams; overload;

    /// <summary>
    /// Adds several skill files to the form data, using a list of file paths (directory upload).
    /// </summary>
    /// <param name="Value">
    /// An array of strings, each representing the path of a file to upload.
    /// </param>
    /// <returns>
    /// Returns an instance of TSkillCreateParams, allowing for method chaining.
    /// </returns>
    /// <remarks>
    /// Each file is sent as the repeated multipart field <c>files[]</c>.
    /// </remarks>
    function Files(const Value: TArray<string>): TSkillCreateParams;
  end;

  TSkillUpdateParams = class(TJSONParam)
  public
    /// <summary>
    /// The skill version number to set as the default version for the skill.
    /// </summary>
    /// <param name="Value">
    /// A string representing the version to be set as default.
    /// </param>
    /// <returns>
    /// Returns an instance of TSkillUpdateParams, allowing for method chaining.
    /// </returns>
    function DefaultVersion(const Value: string): TSkillUpdateParams;

    class function New: TSkillUpdateParams;
  end;

  TSkill = class(TJSONFingerprint)
  private
    FId: string;
    FObject: string;
    [JsonNameAttribute('created_at')]
    FCreatedAt: Int64;
    FName: string;
    FDescription: string;
    [JsonNameAttribute('default_version')]
    FDefaultVersion: string;
    [JsonNameAttribute('latest_version')]
    FLatestVersion: string;
  private
    function GetCreatedAt: Int64;
    function GetCreatedAtAsString: string;
  public
    /// <summary>
    /// Unique identifier for the skill.
    /// </summary>
    property Id: string read FId write FId;

    /// <summary>
    /// The type of this object, which is always "skill".
    /// </summary>
    property &Object: string read FObject write FObject;

    /// <summary>
    /// Unix timestamp (in seconds) when the skill was created.
    /// </summary>
    property CreatedAt: Int64 read GetCreatedAt;

    /// <summary>
    /// The creation timestamp of the skill as a string.
    /// </summary>
    property CreatedAtAsString: string read GetCreatedAtAsString;

    /// <summary>
    /// Name of the skill.
    /// </summary>
    property Name: string read FName write FName;

    /// <summary>
    /// Description of the skill.
    /// </summary>
    property Description: string read FDescription write FDescription;

    /// <summary>
    /// Default version for the skill.
    /// </summary>
    property DefaultVersion: string read FDefaultVersion write FDefaultVersion;

    /// <summary>
    /// Latest version for the skill.
    /// </summary>
    property LatestVersion: string read FLatestVersion write FLatestVersion;
  end;

  /// <summary>
  /// Represents the zip bundle content downloaded for a skill.
  /// </summary>
  TSkillContent = class
  private
    FData: string;
  public
    /// <summary>
    /// The base64-encoded representation of the downloaded zip bundle.
    /// </summary>
    property Data: string read FData write FData;

    /// <summary>
    /// Decodes the base64-encoded content and returns it as a string.
    /// </summary>
    /// <remarks>
    /// Only meaningful for text-based bundle content; for the binary zip use <c>SaveToFile</c>.
    /// </remarks>
    function AsString: string;

    /// <summary>
    /// Decodes the base64-encoded content and saves it to the specified file path.
    /// </summary>
    /// <param name="FileName">
    /// A string specifying the file path where the zip bundle will be saved.
    /// </param>
    procedure SaveToFile(const FileName: string);
  end;

  /// <summary>
  /// Represents a collection of skills retrieved from the API.
  /// </summary>
  TSkills = TAdvancedList<TSkill>;

  /// <summary>
  /// Manages asynchronous callBacks for a request using <c>TSkill</c> as the response type.
  /// </summary>
  TAsynSkill = TAsynCallBack<TSkill>;

  /// <summary>
  /// Represents a promise-based callback for asynchronous operations returning a <see cref="TSkill"/> instance.
  /// </summary>
  TPromiseSkill = TPromiseCallBack<TSkill>;

  /// <summary>
  /// Manages asynchronous callBacks for a request using <c>TSkills</c> as the response type.
  /// </summary>
  TAsynSkills = TAsynCallBack<TSkills>;

  /// <summary>
  /// Represents a promise-based callback for asynchronous operations returning a <see cref="TSkills"/> collection.
  /// </summary>
  TPromiseSkills = TPromiseCallBack<TSkills>;

  /// <summary>
  /// Manages asynchronous callBacks for a request using <c>TSkillContent</c> as the response type.
  /// </summary>
  TAsynSkillContent = TAsynCallBack<TSkillContent>;

  /// <summary>
  /// Represents a promise-based callback for asynchronous operations returning a <see cref="TSkillContent"/> instance.
  /// </summary>
  TPromiseSkillContent = TPromiseCallBack<TSkillContent>;

  TSkillVersionCreateParams = class(TMultiFormDataParams)
  public
    constructor Create; reintroduce;

    /// <summary>
    /// Adds a single skill version file (e.g., a zip bundle) to the form data, using a file path.
    /// </summary>
    /// <remarks>
    /// Sent as the multipart field <c>files[]</c>.
    /// </remarks>
    function &File(const Value: string): TSkillVersionCreateParams; overload;

    /// <summary>
    /// Adds a single skill version file to the form data, using a stream.
    /// </summary>
    /// <remarks>
    /// Sent as the multipart field <c>files[]</c>.
    /// </remarks>
    function &File(const Value: TStream; const FileName: string): TSkillVersionCreateParams; overload;

    /// <summary>
    /// Adds several skill version files to the form data, using a list of file paths (directory upload).
    /// </summary>
    /// <remarks>
    /// Each file is sent as the repeated multipart field <c>files[]</c>.
    /// </remarks>
    function Files(const Value: TArray<string>): TSkillVersionCreateParams;

    /// <summary>
    /// Sets the name of the skill version.
    /// </summary>
    function Name(const Value: string): TSkillVersionCreateParams;

    /// <summary>
    /// Sets the description of the skill version.
    /// </summary>
    function Description(const Value: string): TSkillVersionCreateParams;
  end;

  TSkillVersion = class(TJSONFingerprint)
  private
    FId: string;
    FObject: string;
    [JsonNameAttribute('created_at')]
    FCreatedAt: Int64;
    FVersion: string;
    [JsonNameAttribute('skill_id')]
    FSkillId: string;
    FName: string;
    FDescription: string;
  private
    function GetCreatedAt: Int64;
    function GetCreatedAtAsString: string;
  public
    /// <summary>
    /// Unique identifier for the skill version.
    /// </summary>
    property Id: string read FId write FId;

    /// <summary>
    /// The type of this object, which is always "skill.version".
    /// </summary>
    property &Object: string read FObject write FObject;

    /// <summary>
    /// Unix timestamp (in seconds) when the skill version was created.
    /// </summary>
    property CreatedAt: Int64 read GetCreatedAt;

    /// <summary>
    /// The creation timestamp of the skill version as a string.
    /// </summary>
    property CreatedAtAsString: string read GetCreatedAtAsString;

    /// <summary>
    /// The version number.
    /// </summary>
    property Version: string read FVersion write FVersion;

    /// <summary>
    /// The identifier of the skill this version belongs to.
    /// </summary>
    property SkillId: string read FSkillId write FSkillId;

    /// <summary>
    /// Name of the skill version.
    /// </summary>
    property Name: string read FName write FName;

    /// <summary>
    /// Description of the skill version.
    /// </summary>
    property Description: string read FDescription write FDescription;
  end;

  /// <summary>
  /// Represents a collection of skill versions retrieved from the API.
  /// </summary>
  TSkillVersions = TAdvancedList<TSkillVersion>;

  /// <summary>
  /// Manages asynchronous callBacks for a request using <c>TSkillVersion</c> as the response type.
  /// </summary>
  TAsynSkillVersion = TAsynCallBack<TSkillVersion>;

  /// <summary>
  /// Represents a promise-based callback for asynchronous operations returning a <see cref="TSkillVersion"/> instance.
  /// </summary>
  TPromiseSkillVersion = TPromiseCallBack<TSkillVersion>;

  /// <summary>
  /// Manages asynchronous callBacks for a request using <c>TSkillVersions</c> as the response type.
  /// </summary>
  TAsynSkillVersions = TAsynCallBack<TSkillVersions>;

  /// <summary>
  /// Represents a promise-based callback for asynchronous operations returning a <see cref="TSkillVersions"/> collection.
  /// </summary>
  TPromiseSkillVersions = TPromiseCallBack<TSkillVersions>;

  TSkillVersionsAbstractSupport = class(TGenAIRoute)
  protected
    function Create(const SkillId: string;
      const ParamProc: TProc<TSkillVersionCreateParams>): TSkillVersion; virtual; abstract;
    function List(const SkillId: string): TSkillVersions; overload; virtual; abstract;
    function List(const SkillId: string;
      const ParamProc: TProc<TUrlSkillsParams>): TSkillVersions; overload; virtual; abstract;
    function Retrieve(const SkillId: string; const Version: string): TSkillVersion; virtual; abstract;
    function Delete(const SkillId: string; const Version: string): TDeletion; virtual; abstract;
    function GetContent(const SkillId: string; const Version: string): TSkillContent; virtual; abstract;
  end;

  TSkillVersionsAsynchronousSupport = class(TSkillVersionsAbstractSupport)
  public
    procedure AsynCreate(const SkillId: string;
      const ParamProc: TProc<TSkillVersionCreateParams>;
      const CallBacks: TFunc<TAsynSkillVersion>);
    procedure AsynList(const SkillId: string;
      const CallBacks: TFunc<TAsynSkillVersions>); overload;
    procedure AsynList(const SkillId: string;
      const ParamProc: TProc<TUrlSkillsParams>;
      const CallBacks: TFunc<TAsynSkillVersions>); overload;
    procedure AsynRetrieve(const SkillId: string; const Version: string;
      const CallBacks: TFunc<TAsynSkillVersion>);
    procedure AsynDelete(const SkillId: string; const Version: string;
      const CallBacks: TFunc<TAsynDeletion>);
    procedure AsynGetContent(const SkillId: string; const Version: string;
      const CallBacks: TFunc<TAsynSkillContent>);
  end;

  /// <summary>
  /// Provides methods to manage the versions of a skill in the OpenAI API.
  /// </summary>
  /// <remarks>
  /// The <c>TSkillVersionsRoute</c> class allows you to create immutable versions, retrieve, list, and
  /// delete versions of a skill, as well as download a version zip bundle. It is exposed through the
  /// <see cref="TSkillsRoute.Versions"/> property.
  /// </remarks>
  TSkillVersionsRoute = class(TSkillVersionsAsynchronousSupport)
  public
    /// <summary>
    /// Initiates an asynchronous request to create a new immutable skill version and returns a promise.
    /// </summary>
    function AsyncAwaitCreate(const SkillId: string;
      const ParamProc: TProc<TSkillVersionCreateParams>;
      const CallBacks: TFunc<TPromiseSkillVersion> = nil): TPromise<TSkillVersion>;

    /// <summary>
    /// Initiates an asynchronous request to list all versions of a skill and returns a promise.
    /// </summary>
    function AsyncAwaitList(const SkillId: string;
      const CallBacks: TFunc<TPromiseSkillVersions> = nil): TPromise<TSkillVersions>; overload;

    /// <summary>
    /// Initiates an asynchronous request to list versions of a skill with URL parameters and returns a promise.
    /// </summary>
    function AsyncAwaitList(const SkillId: string;
      const ParamProc: TProc<TUrlSkillsParams>;
      const CallBacks: TFunc<TPromiseSkillVersions> = nil): TPromise<TSkillVersions>; overload;

    /// <summary>
    /// Initiates an asynchronous request to retrieve a specific skill version and returns a promise.
    /// </summary>
    function AsyncAwaitRetrieve(const SkillId: string; const Version: string;
      const CallBacks: TFunc<TPromiseSkillVersion> = nil): TPromise<TSkillVersion>;

    /// <summary>
    /// Initiates an asynchronous request to delete a specific skill version and returns a promise.
    /// </summary>
    function AsyncAwaitDelete(const SkillId: string; const Version: string;
      const CallBacks: TFunc<TPromiseDeletion> = nil): TPromise<TDeletion>;

    /// <summary>
    /// Initiates an asynchronous request to download a skill version zip bundle and returns a promise.
    /// </summary>
    function AsyncAwaitGetContent(const SkillId: string; const Version: string;
      const CallBacks: TFunc<TPromiseSkillContent> = nil): TPromise<TSkillContent>;

    /// <summary>
    /// Creates a new immutable version of a skill synchronously.
    /// </summary>
    /// <param name="SkillId">
    /// The unique identifier of the skill for which the version is created.
    /// </param>
    /// <param name="ParamProc">
    /// A procedure that configures the multipart parameters (version files, name, description).
    /// </param>
    /// <returns>
    /// A <c>TSkillVersion</c> object representing the created version.
    /// </returns>
    function Create(const SkillId: string;
      const ParamProc: TProc<TSkillVersionCreateParams>): TSkillVersion; override;

    /// <summary>
    /// Lists all versions of a skill synchronously.
    /// </summary>
    function List(const SkillId: string): TSkillVersions; overload; override;

    /// <summary>
    /// Lists versions of a skill with the specified URL parameters synchronously.
    /// </summary>
    function List(const SkillId: string;
      const ParamProc: TProc<TUrlSkillsParams>): TSkillVersions; overload; override;

    /// <summary>
    /// Retrieves details of a specific skill version synchronously.
    /// </summary>
    function Retrieve(const SkillId: string; const Version: string): TSkillVersion; override;

    /// <summary>
    /// Deletes a specific skill version synchronously.
    /// </summary>
    function Delete(const SkillId: string; const Version: string): TDeletion; override;

    /// <summary>
    /// Downloads the zip bundle of a specific skill version synchronously.
    /// </summary>
    function GetContent(const SkillId: string; const Version: string): TSkillContent; override;
  end;

  TSkillsAbstractSupport = class(TGenAIRoute)
  protected
    function Create(const ParamProc: TProc<TSkillCreateParams>): TSkill; virtual; abstract;
    function List: TSkills; overload; virtual; abstract;
    function List(const ParamProc: TProc<TUrlSkillsParams>): TSkills; overload; virtual; abstract;
    function Retrieve(const SkillId: string): TSkill; virtual; abstract;
    function Update(const SkillId: string; const ParamProc: TProc<TSkillUpdateParams>): TSkill; virtual; abstract;
    function Delete(const SkillId: string): TDeletion; virtual; abstract;
    function GetContent(const SkillId: string): TSkillContent; virtual; abstract;
  end;

  TSkillsAsynchronousSupport = class(TSkillsAbstractSupport)
  public
    procedure AsynCreate(const ParamProc: TProc<TSkillCreateParams>;
      const CallBacks: TFunc<TAsynSkill>);
    procedure AsynList(const CallBacks: TFunc<TAsynSkills>); overload;
    procedure AsynList(const ParamProc: TProc<TUrlSkillsParams>;
      const CallBacks: TFunc<TAsynSkills>); overload;
    procedure AsynRetrieve(const SkillId: string; const CallBacks: TFunc<TAsynSkill>);
    procedure AsynUpdate(const SkillId: string; const ParamProc: TProc<TSkillUpdateParams>;
      const CallBacks: TFunc<TAsynSkill>);
    procedure AsynDelete(const SkillId: string; const CallBacks: TFunc<TAsynDeletion>);
    procedure AsynGetContent(const SkillId: string; const CallBacks: TFunc<TAsynSkillContent>);
  end;

  /// <summary>
  /// Provides methods to manage skills in the OpenAI API.
  /// </summary>
  /// <remarks>
  /// The <c>TSkillsRoute</c> class allows you to create, retrieve, update, list, and delete skills,
  /// as well as download their zip bundle, through various API endpoints. It supports both synchronous
  /// and asynchronous operations.
  /// </remarks>
  TSkillsRoute = class(TSkillsAsynchronousSupport)
  private
    FVersions: TSkillVersionsRoute;
    function GetVersions: TSkillVersionsRoute;
  public
    destructor Destroy; override;

    /// <summary>
    /// Provides access to the skill versions sub-resource (create, list, retrieve, delete, download content).
    /// </summary>
    /// <remarks>
    /// The sub-route instance is created lazily on first access and reused for subsequent calls.
    /// It shares the same underlying API client as the parent skills route and is owned (and freed) by it.
    /// </remarks>
    property Versions: TSkillVersionsRoute read GetVersions;

    /// <summary>
    /// Initiates an asynchronous skill creation request and returns a promise that resolves with the created skill.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure to configure the multipart parameters (skill files) via a <see cref="TSkillCreateParams"/> instance.
    /// </param>
    /// <param name="CallBacks">
    /// An optional function providing <see cref="TPromiseSkill"/> callbacks for start, success, and error handling.
    /// </param>
    /// <returns>
    /// A <c>TPromise&lt;TSkill&gt;</c> that completes when the skill creation succeeds or fails.
    /// </returns>
    function AsyncAwaitCreate(const ParamProc: TProc<TSkillCreateParams>;
      const CallBacks: TFunc<TPromiseSkill> = nil): TPromise<TSkill>;

    /// <summary>
    /// Initiates an asynchronous request to list all skills and returns a promise that resolves with the collection.
    /// </summary>
    /// <param name="CallBacks">
    /// An optional function providing <see cref="TPromiseSkills"/> callbacks for start, success, and error handling.
    /// </param>
    /// <returns>
    /// A <c>TPromise&lt;TSkills&gt;</c> that completes when the list operation succeeds or fails.
    /// </returns>
    function AsyncAwaitList(const CallBacks: TFunc<TPromiseSkills> = nil): TPromise<TSkills>; overload;

    /// <summary>
    /// Initiates an asynchronous request to list skills with the specified URL parameters and returns a promise.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure to configure URL parameters (pagination, order) via a <see cref="TUrlSkillsParams"/> instance.
    /// </param>
    /// <param name="CallBacks">
    /// An optional function providing <see cref="TPromiseSkills"/> callbacks for start, success, and error handling.
    /// </param>
    /// <returns>
    /// A <c>TPromise&lt;TSkills&gt;</c> that completes when the list operation succeeds or fails.
    /// </returns>
    function AsyncAwaitList(const ParamProc: TProc<TUrlSkillsParams>;
      const CallBacks: TFunc<TPromiseSkills> = nil): TPromise<TSkills>; overload;

    /// <summary>
    /// Initiates an asynchronous request to retrieve a specific skill and returns a promise.
    /// </summary>
    /// <param name="SkillId">
    /// The unique identifier of the skill to retrieve.
    /// </param>
    /// <param name="CallBacks">
    /// An optional function providing <see cref="TPromiseSkill"/> callbacks for start, success, and error handling.
    /// </param>
    /// <returns>
    /// A <c>TPromise&lt;TSkill&gt;</c> that completes when the retrieval succeeds or fails.
    /// </returns>
    function AsyncAwaitRetrieve(const SkillId: string;
      const CallBacks: TFunc<TPromiseSkill> = nil): TPromise<TSkill>;

    /// <summary>
    /// Initiates an asynchronous request to update a skill's default version and returns a promise.
    /// </summary>
    /// <param name="SkillId">
    /// The unique identifier of the skill to update.
    /// </param>
    /// <param name="ParamProc">
    /// A procedure to configure the update parameters via a <see cref="TSkillUpdateParams"/> instance.
    /// </param>
    /// <param name="CallBacks">
    /// An optional function providing <see cref="TPromiseSkill"/> callbacks for start, success, and error handling.
    /// </param>
    /// <returns>
    /// A <c>TPromise&lt;TSkill&gt;</c> that completes when the update succeeds or fails.
    /// </returns>
    function AsyncAwaitUpdate(const SkillId: string;
      const ParamProc: TProc<TSkillUpdateParams>;
      const CallBacks: TFunc<TPromiseSkill> = nil): TPromise<TSkill>;

    /// <summary>
    /// Initiates an asynchronous request to delete a skill and returns a promise.
    /// </summary>
    /// <param name="SkillId">
    /// The unique identifier of the skill to delete.
    /// </param>
    /// <param name="CallBacks">
    /// An optional function providing <see cref="TPromiseDeletion"/> callbacks for start, success, and error handling.
    /// </param>
    /// <returns>
    /// A <c>TPromise&lt;TDeletion&gt;</c> that completes when the deletion succeeds or fails.
    /// </returns>
    function AsyncAwaitDelete(const SkillId: string;
      const CallBacks: TFunc<TPromiseDeletion> = nil): TPromise<TDeletion>;

    /// <summary>
    /// Initiates an asynchronous request to download the skill zip bundle and returns a promise.
    /// </summary>
    /// <param name="SkillId">
    /// The unique identifier of the skill whose bundle is to be downloaded.
    /// </param>
    /// <param name="CallBacks">
    /// An optional function providing <see cref="TPromiseSkillContent"/> callbacks for start, success, and error handling.
    /// </param>
    /// <returns>
    /// A <c>TPromise&lt;TSkillContent&gt;</c> that completes when the download succeeds or fails.
    /// </returns>
    function AsyncAwaitGetContent(const SkillId: string;
      const CallBacks: TFunc<TPromiseSkillContent> = nil): TPromise<TSkillContent>;

    /// <summary>
    /// Creates a new skill synchronously based on the provided parameters.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure that configures the multipart parameters (skill files) for the creation request.
    /// </param>
    /// <returns>
    /// A <c>TSkill</c> object representing the created skill.
    /// </returns>
    function Create(const ParamProc: TProc<TSkillCreateParams>): TSkill; override;

    /// <summary>
    /// Lists all skills for the current project synchronously.
    /// </summary>
    /// <returns>
    /// A <c>TSkills</c> object containing the list of skills.
    /// </returns>
    function List: TSkills; overload; override;

    /// <summary>
    /// Lists skills with the specified URL parameters synchronously.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure that configures the URL parameters for filtering the skill list.
    /// </param>
    /// <returns>
    /// A <c>TSkills</c> object containing the filtered list of skills.
    /// </returns>
    function List(const ParamProc: TProc<TUrlSkillsParams>): TSkills; overload; override;

    /// <summary>
    /// Retrieves details of a specific skill synchronously.
    /// </summary>
    /// <param name="SkillId">
    /// The unique identifier of the skill to retrieve.
    /// </param>
    /// <returns>
    /// A <c>TSkill</c> object containing the skill's metadata.
    /// </returns>
    function Retrieve(const SkillId: string): TSkill; override;

    /// <summary>
    /// Updates the default version of a skill synchronously.
    /// </summary>
    /// <param name="SkillId">
    /// The unique identifier of the skill to update.
    /// </param>
    /// <param name="ParamProc">
    /// A procedure that configures the update parameters.
    /// </param>
    /// <returns>
    /// A <c>TSkill</c> object representing the updated skill.
    /// </returns>
    function Update(const SkillId: string; const ParamProc: TProc<TSkillUpdateParams>): TSkill; override;

    /// <summary>
    /// Deletes a specific skill synchronously.
    /// </summary>
    /// <param name="SkillId">
    /// The unique identifier of the skill to delete.
    /// </param>
    /// <returns>
    /// A <c>TDeletion</c> object indicating the status of the deletion.
    /// </returns>
    function Delete(const SkillId: string): TDeletion; override;

    /// <summary>
    /// Downloads the zip bundle of a specific skill synchronously.
    /// </summary>
    /// <param name="SkillId">
    /// The unique identifier of the skill whose bundle is to be downloaded.
    /// </param>
    /// <returns>
    /// A <c>TSkillContent</c> object containing the base64-encoded zip bundle.
    /// </returns>
    function GetContent(const SkillId: string): TSkillContent; override;
  end;

implementation

uses
  System.NetEncoding, System.IOUtils, System.DateUtils, GenAI.TextCodec;

{ TUrlSkillsParams }

function TUrlSkillsParams.After(const Value: string): TUrlSkillsParams;
begin
  Result := TUrlSkillsParams(Add('after', Value));
end;

function TUrlSkillsParams.Limit(const Value: Integer): TUrlSkillsParams;
begin
  Result := TUrlSkillsParams(Add('limit', Value));
end;

function TUrlSkillsParams.Order(const Value: string): TUrlSkillsParams;
begin
  Result := TUrlSkillsParams(Add('order', Value));
end;

{ TSkillCreateParams }

constructor TSkillCreateParams.Create;
begin
  inherited Create;
end;

function TSkillCreateParams.&File(const Value: string): TSkillCreateParams;
begin
  AddFile('files[]', Value);
  Result := Self;
end;

function TSkillCreateParams.&File(const Value: TStream;
  const FileName: string): TSkillCreateParams;
begin
  {$IF RTLVersion > 35.0}
    AddStream('files[]', Value, True, FileName);
  {$ELSE}
    AddStream('files[]', Value, FileName);
  {$ENDIF}
  Result := Self;
end;

function TSkillCreateParams.Files(const Value: TArray<string>): TSkillCreateParams;
begin
  AddFiles('files[]', Value, True);
  Result := Self;
end;

{ TSkillUpdateParams }

function TSkillUpdateParams.DefaultVersion(const Value: string): TSkillUpdateParams;
begin
  Result := TSkillUpdateParams(Add('default_version', Value));
end;

class function TSkillUpdateParams.New: TSkillUpdateParams;
begin
  Result := TSkillUpdateParams.Create;
end;

{ TSkill }

function TSkill.GetCreatedAt: Int64;
begin
  Result := FCreatedAt;
end;

function TSkill.GetCreatedAtAsString: string;
begin
  if FCreatedAt <= 0 then
    Exit(EmptyStr);
  Result := FormatDateTime('yyyy-mm-dd"T"hh:nn:ss"Z"', UnixToDateTime(FCreatedAt, True));
end;

{ TSkillContent }

function TSkillContent.AsString: string;
begin
  Result := TTextCodec.SafeBase64ToString(FData);
end;

procedure TSkillContent.SaveToFile(const FileName: string);
begin
  var Bytes := TNetEncoding.Base64.DecodeStringToBytes(FData);
  TFile.WriteAllBytes(FileName, Bytes);
end;

{ TSkillVersionCreateParams }

constructor TSkillVersionCreateParams.Create;
begin
  inherited Create;
end;

function TSkillVersionCreateParams.&File(const Value: string): TSkillVersionCreateParams;
begin
  AddFile('files[]', Value);
  Result := Self;
end;

function TSkillVersionCreateParams.&File(const Value: TStream;
  const FileName: string): TSkillVersionCreateParams;
begin
  {$IF RTLVersion > 35.0}
    AddStream('files[]', Value, True, FileName);
  {$ELSE}
    AddStream('files[]', Value, FileName);
  {$ENDIF}
  Result := Self;
end;

function TSkillVersionCreateParams.Files(const Value: TArray<string>): TSkillVersionCreateParams;
begin
  AddFiles('files[]', Value, True);
  Result := Self;
end;

function TSkillVersionCreateParams.Name(const Value: string): TSkillVersionCreateParams;
begin
  AddField('name', Value);
  Result := Self;
end;

function TSkillVersionCreateParams.Description(const Value: string): TSkillVersionCreateParams;
begin
  AddField('description', Value);
  Result := Self;
end;

{ TSkillVersion }

function TSkillVersion.GetCreatedAt: Int64;
begin
  Result := FCreatedAt;
end;

function TSkillVersion.GetCreatedAtAsString: string;
begin
  if FCreatedAt <= 0 then
    Exit(EmptyStr);
  Result := FormatDateTime('yyyy-mm-dd"T"hh:nn:ss"Z"', UnixToDateTime(FCreatedAt, True));
end;

{ TSkillVersionsAsynchronousSupport }

procedure TSkillVersionsAsynchronousSupport.AsynCreate(const SkillId: string;
  const ParamProc: TProc<TSkillVersionCreateParams>;
  const CallBacks: TFunc<TAsynSkillVersion>);
begin
  with TAsynCallBackExec<TAsynSkillVersion, TSkillVersion>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TSkillVersion
      begin
        Result := Self.Create(SkillId, ParamProc);
      end);
  finally
    Free;
  end;
end;

procedure TSkillVersionsAsynchronousSupport.AsynList(const SkillId: string;
  const CallBacks: TFunc<TAsynSkillVersions>);
begin
  with TAsynCallBackExec<TAsynSkillVersions, TSkillVersions>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TSkillVersions
      begin
        Result := Self.List(SkillId);
      end);
  finally
    Free;
  end;
end;

procedure TSkillVersionsAsynchronousSupport.AsynList(const SkillId: string;
  const ParamProc: TProc<TUrlSkillsParams>;
  const CallBacks: TFunc<TAsynSkillVersions>);
begin
  with TAsynCallBackExec<TAsynSkillVersions, TSkillVersions>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TSkillVersions
      begin
        Result := Self.List(SkillId, ParamProc);
      end);
  finally
    Free;
  end;
end;

procedure TSkillVersionsAsynchronousSupport.AsynRetrieve(const SkillId, Version: string;
  const CallBacks: TFunc<TAsynSkillVersion>);
begin
  with TAsynCallBackExec<TAsynSkillVersion, TSkillVersion>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TSkillVersion
      begin
        Result := Self.Retrieve(SkillId, Version);
      end);
  finally
    Free;
  end;
end;

procedure TSkillVersionsAsynchronousSupport.AsynDelete(const SkillId, Version: string;
  const CallBacks: TFunc<TAsynDeletion>);
begin
  with TAsynCallBackExec<TAsynDeletion, TDeletion>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TDeletion
      begin
        Result := Self.Delete(SkillId, Version);
      end);
  finally
    Free;
  end;
end;

procedure TSkillVersionsAsynchronousSupport.AsynGetContent(const SkillId, Version: string;
  const CallBacks: TFunc<TAsynSkillContent>);
begin
  with TAsynCallBackExec<TAsynSkillContent, TSkillContent>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TSkillContent
      begin
        Result := Self.GetContent(SkillId, Version);
      end);
  finally
    Free;
  end;
end;

{ TSkillVersionsRoute }

function TSkillVersionsRoute.AsyncAwaitCreate(const SkillId: string;
  const ParamProc: TProc<TSkillVersionCreateParams>;
  const CallBacks: TFunc<TPromiseSkillVersion>): TPromise<TSkillVersion>;
begin
  Result := TAsyncAwaitHelper.WrapAsyncAwait<TSkillVersion>(
    procedure(const CallBackParams: TFunc<TAsynSkillVersion>)
    begin
      AsynCreate(SkillId, ParamProc, CallBackParams);
    end,
    CallBacks);
end;

function TSkillVersionsRoute.AsyncAwaitList(const SkillId: string;
  const CallBacks: TFunc<TPromiseSkillVersions>): TPromise<TSkillVersions>;
begin
  Result := TAsyncAwaitHelper.WrapAsyncAwait<TSkillVersions>(
    procedure(const CallBackParams: TFunc<TAsynSkillVersions>)
    begin
      AsynList(SkillId, CallBackParams);
    end,
    CallBacks);
end;

function TSkillVersionsRoute.AsyncAwaitList(const SkillId: string;
  const ParamProc: TProc<TUrlSkillsParams>;
  const CallBacks: TFunc<TPromiseSkillVersions>): TPromise<TSkillVersions>;
begin
  Result := TAsyncAwaitHelper.WrapAsyncAwait<TSkillVersions>(
    procedure(const CallBackParams: TFunc<TAsynSkillVersions>)
    begin
      AsynList(SkillId, ParamProc, CallBackParams);
    end,
    CallBacks);
end;

function TSkillVersionsRoute.AsyncAwaitRetrieve(const SkillId, Version: string;
  const CallBacks: TFunc<TPromiseSkillVersion>): TPromise<TSkillVersion>;
begin
  Result := TAsyncAwaitHelper.WrapAsyncAwait<TSkillVersion>(
    procedure(const CallBackParams: TFunc<TAsynSkillVersion>)
    begin
      AsynRetrieve(SkillId, Version, CallBackParams);
    end,
    CallBacks);
end;

function TSkillVersionsRoute.AsyncAwaitDelete(const SkillId, Version: string;
  const CallBacks: TFunc<TPromiseDeletion>): TPromise<TDeletion>;
begin
  Result := TAsyncAwaitHelper.WrapAsyncAwait<TDeletion>(
    procedure(const CallBackParams: TFunc<TAsynDeletion>)
    begin
      AsynDelete(SkillId, Version, CallBackParams);
    end,
    CallBacks);
end;

function TSkillVersionsRoute.AsyncAwaitGetContent(const SkillId, Version: string;
  const CallBacks: TFunc<TPromiseSkillContent>): TPromise<TSkillContent>;
begin
  Result := TAsyncAwaitHelper.WrapAsyncAwait<TSkillContent>(
    procedure(const CallBackParams: TFunc<TAsynSkillContent>)
    begin
      AsynGetContent(SkillId, Version, CallBackParams);
    end,
    CallBacks);
end;

function TSkillVersionsRoute.Create(const SkillId: string;
  const ParamProc: TProc<TSkillVersionCreateParams>): TSkillVersion;
begin
  Result := API.PostForm<TSkillVersion, TSkillVersionCreateParams>('skills/' + SkillId + '/versions', ParamProc);
end;

function TSkillVersionsRoute.List(const SkillId: string): TSkillVersions;
begin
  Result := API.Get<TSkillVersions>('skills/' + SkillId + '/versions');
end;

function TSkillVersionsRoute.List(const SkillId: string;
  const ParamProc: TProc<TUrlSkillsParams>): TSkillVersions;
begin
  Result := API.Get<TSkillVersions, TUrlSkillsParams>('skills/' + SkillId + '/versions', ParamProc);
end;

function TSkillVersionsRoute.Retrieve(const SkillId, Version: string): TSkillVersion;
begin
  Result := API.Get<TSkillVersion>('skills/' + SkillId + '/versions/' + Version);
end;

function TSkillVersionsRoute.Delete(const SkillId, Version: string): TDeletion;
begin
  Result := API.Delete<TDeletion>('skills/' + SkillId + '/versions/' + Version);
end;

function TSkillVersionsRoute.GetContent(const SkillId, Version: string): TSkillContent;
begin
  try
    Result := TSkillContent.Create;
    var Bytes := API.GetBinary('skills/' + SkillId + '/versions/' + Version + '/content');
    Result.Data := TTextCodec.EncodeBytesToString(Bytes);
  except
    FreeAndNil(Result);
    raise;
  end;
end;

{ TSkillsAsynchronousSupport }

procedure TSkillsAsynchronousSupport.AsynCreate(const ParamProc: TProc<TSkillCreateParams>;
  const CallBacks: TFunc<TAsynSkill>);
begin
  with TAsynCallBackExec<TAsynSkill, TSkill>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TSkill
      begin
        Result := Self.Create(ParamProc);
      end);
  finally
    Free;
  end;
end;

procedure TSkillsAsynchronousSupport.AsynList(const CallBacks: TFunc<TAsynSkills>);
begin
  with TAsynCallBackExec<TAsynSkills, TSkills>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TSkills
      begin
        Result := Self.List;
      end);
  finally
    Free;
  end;
end;

procedure TSkillsAsynchronousSupport.AsynList(const ParamProc: TProc<TUrlSkillsParams>;
  const CallBacks: TFunc<TAsynSkills>);
begin
  with TAsynCallBackExec<TAsynSkills, TSkills>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TSkills
      begin
        Result := Self.List(ParamProc);
      end);
  finally
    Free;
  end;
end;

procedure TSkillsAsynchronousSupport.AsynRetrieve(const SkillId: string;
  const CallBacks: TFunc<TAsynSkill>);
begin
  with TAsynCallBackExec<TAsynSkill, TSkill>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TSkill
      begin
        Result := Self.Retrieve(SkillId);
      end);
  finally
    Free;
  end;
end;

procedure TSkillsAsynchronousSupport.AsynUpdate(const SkillId: string;
  const ParamProc: TProc<TSkillUpdateParams>; const CallBacks: TFunc<TAsynSkill>);
begin
  with TAsynCallBackExec<TAsynSkill, TSkill>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TSkill
      begin
        Result := Self.Update(SkillId, ParamProc);
      end);
  finally
    Free;
  end;
end;

procedure TSkillsAsynchronousSupport.AsynDelete(const SkillId: string;
  const CallBacks: TFunc<TAsynDeletion>);
begin
  with TAsynCallBackExec<TAsynDeletion, TDeletion>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TDeletion
      begin
        Result := Self.Delete(SkillId);
      end);
  finally
    Free;
  end;
end;

procedure TSkillsAsynchronousSupport.AsynGetContent(const SkillId: string;
  const CallBacks: TFunc<TAsynSkillContent>);
begin
  with TAsynCallBackExec<TAsynSkillContent, TSkillContent>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TSkillContent
      begin
        Result := Self.GetContent(SkillId);
      end);
  finally
    Free;
  end;
end;

{ TSkillsRoute }

destructor TSkillsRoute.Destroy;
begin
  if Assigned(FVersions) then
    FVersions.Free;
  inherited;
end;

function TSkillsRoute.GetVersions: TSkillVersionsRoute;
begin
  if not Assigned(FVersions) then
    FVersions := TSkillVersionsRoute.CreateRoute(API);
  Result := FVersions;
end;

function TSkillsRoute.AsyncAwaitCreate(const ParamProc: TProc<TSkillCreateParams>;
  const CallBacks: TFunc<TPromiseSkill>): TPromise<TSkill>;
begin
  Result := TAsyncAwaitHelper.WrapAsyncAwait<TSkill>(
    procedure(const CallBackParams: TFunc<TAsynSkill>)
    begin
      AsynCreate(ParamProc, CallBackParams);
    end,
    CallBacks);
end;

function TSkillsRoute.AsyncAwaitList(
  const CallBacks: TFunc<TPromiseSkills>): TPromise<TSkills>;
begin
  Result := TAsyncAwaitHelper.WrapAsyncAwait<TSkills>(
    procedure(const CallBackParams: TFunc<TAsynSkills>)
    begin
      AsynList(CallBackParams);
    end,
    CallBacks);
end;

function TSkillsRoute.AsyncAwaitList(const ParamProc: TProc<TUrlSkillsParams>;
  const CallBacks: TFunc<TPromiseSkills>): TPromise<TSkills>;
begin
  Result := TAsyncAwaitHelper.WrapAsyncAwait<TSkills>(
    procedure(const CallBackParams: TFunc<TAsynSkills>)
    begin
      AsynList(ParamProc, CallBackParams);
    end,
    CallBacks);
end;

function TSkillsRoute.AsyncAwaitRetrieve(const SkillId: string;
  const CallBacks: TFunc<TPromiseSkill>): TPromise<TSkill>;
begin
  Result := TAsyncAwaitHelper.WrapAsyncAwait<TSkill>(
    procedure(const CallBackParams: TFunc<TAsynSkill>)
    begin
      AsynRetrieve(SkillId, CallBackParams);
    end,
    CallBacks);
end;

function TSkillsRoute.AsyncAwaitUpdate(const SkillId: string;
  const ParamProc: TProc<TSkillUpdateParams>;
  const CallBacks: TFunc<TPromiseSkill>): TPromise<TSkill>;
begin
  Result := TAsyncAwaitHelper.WrapAsyncAwait<TSkill>(
    procedure(const CallBackParams: TFunc<TAsynSkill>)
    begin
      AsynUpdate(SkillId, ParamProc, CallBackParams);
    end,
    CallBacks);
end;

function TSkillsRoute.AsyncAwaitDelete(const SkillId: string;
  const CallBacks: TFunc<TPromiseDeletion>): TPromise<TDeletion>;
begin
  Result := TAsyncAwaitHelper.WrapAsyncAwait<TDeletion>(
    procedure(const CallBackParams: TFunc<TAsynDeletion>)
    begin
      AsynDelete(SkillId, CallBackParams);
    end,
    CallBacks);
end;

function TSkillsRoute.AsyncAwaitGetContent(const SkillId: string;
  const CallBacks: TFunc<TPromiseSkillContent>): TPromise<TSkillContent>;
begin
  Result := TAsyncAwaitHelper.WrapAsyncAwait<TSkillContent>(
    procedure(const CallBackParams: TFunc<TAsynSkillContent>)
    begin
      AsynGetContent(SkillId, CallBackParams);
    end,
    CallBacks);
end;

function TSkillsRoute.Create(const ParamProc: TProc<TSkillCreateParams>): TSkill;
begin
  Result := API.PostForm<TSkill, TSkillCreateParams>('skills', ParamProc);
end;

function TSkillsRoute.List: TSkills;
begin
  Result := API.Get<TSkills>('skills');
end;

function TSkillsRoute.List(const ParamProc: TProc<TUrlSkillsParams>): TSkills;
begin
  Result := API.Get<TSkills, TUrlSkillsParams>('skills', ParamProc);
end;

function TSkillsRoute.Retrieve(const SkillId: string): TSkill;
begin
  Result := API.Get<TSkill>('skills/' + SkillId);
end;

function TSkillsRoute.Update(const SkillId: string;
  const ParamProc: TProc<TSkillUpdateParams>): TSkill;
begin
  Result := API.Post<TSkill, TSkillUpdateParams>('skills/' + SkillId, ParamProc);
end;

function TSkillsRoute.Delete(const SkillId: string): TDeletion;
begin
  Result := API.Delete<TDeletion>('skills/' + SkillId);
end;

function TSkillsRoute.GetContent(const SkillId: string): TSkillContent;
begin
  try
    Result := TSkillContent.Create;
    var Bytes := API.GetBinary('skills/' + SkillId + '/content');
    Result.Data := TTextCodec.EncodeBytesToString(Bytes);
  except
    FreeAndNil(Result);
    raise;
  end;
end;

end.
