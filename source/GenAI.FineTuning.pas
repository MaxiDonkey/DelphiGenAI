unit GenAI.FineTuning;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGenAI
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

(*
    --- NOTE ---
  Difference Between Supervised and DPO (Direct Preference Optimization) Methods

    1. SUPERVISED Fine-Tuning Method

  The supervised method  is a classic fine-tuning approach  where the model is trained on a labeled
  dataset to learn  how to map specific inputs  (prompts)  to target outputs  (ideal responses).

  Key Features:
   - The model learns solely from the examples provided in the training data.
   - Each training example contains a prompt and a corresponding target response.
   - The goal is to minimize the error (loss) between the model's output and the target response in
     the training data.

  Advantages:
   - Easy to implement: Requires only a well-annotated training dataset.
   - Ideal for specific tasks: Works well for well-defined tasks where high-quality labeled data is
     available (e.g., classification, translation, summarization).

  Limitations:
   - Can be prone to overfitting if the training data is not diverse enough.
   - Does not account for human preferences or comparisons between multiple potential responses.

  When to use it:
   - When you have a labeled dataset containing specific examples of what the model should produce.
   - When you aim to train the model  for a specific, well-defined task  (e.g., answering questions
     or generating structured summaries).


    2. DPO (Direct Preference Optimization) Method

  The DPO method is a more advanced approach  that incorporates human preferences into the training
  process. Instead  of  focusing  on  "ideal"  responses,  this method  uses  pairs of responses to
  indicate which one is preferred (based on human or automated evaluations).

  Key Features:
   - The dataset includes comparisons between two responses generated for the same prompt, with one
     response marked as preferred.
   - The model is optimized to replicate these preferences.
   - This method is often used to fine-tune a model to align its responses with subjective or human
     preferences.

  Advantages:
   - Captures human preferences: Improves response quality based on subjective  or context-specific
     criteria.
   - Resilient to data  uncertainty:  Useful when  traditional  labeled  data  is  unavailable, but
     preference judgments are feasible.

  Limitations:
   - Requires a dataset with comparison data, which can be costly or time-consuming to create.
   - More complex to implement and train than the supervised method.

  When to use it:
   - When you want the model to produce responses that reflect subjective or human preferences, for
     example:
       - Generating more fluent or engaging text.
       - Aligning responses  with specific criteria  (e.g., avoiding  bias  or  generating  content
         tailored to a specific domain).

   - When  you  have a dataset containing  response  comparisons  (e.g., human ratings  of response
     quality between two options).


  Choosing Between the Two Methods

 +-------------------+----------------------------------+------------------------------------------+
 +    Criteria       +         Supervised               +                 DPO                      +
 +-------------------+----------------------------------+------------------------------------------+
 +                   +                                  +                                          +
 + Data Availability + Requires data with clear target  + Requires comparisons between responses   +
 +                   + outputs                          + (preferences)                            +
 +-------------------+----------------------------------+------------------------------------------+
 +                   +                                  +                                          +
 + Implementation    + Simpler                          + More complex, needs well-collected       +
 + Complexity        +                                  + preferences                              +
 +                   +                                  +                                          +
 +-------------------+----------------------------------+------------------------------------------+
 +                   +                                  +                                          +
 + Human Alignment   + Limited                          + Strong alignment due to human preference +
 +                   +                                  + incorporation                            +
 +-------------------+----------------------------------+------------------------------------------+
 +                   +                                  +                                          +
 + Primary Use Cases + Well-defined, objective tasks    + Subjective tasks or those requiring      +
 +                   +                                  + fine-tuned alignment                     +
 +-------------------+----------------------------------+------------------------------------------+


    3. Recommendation
        * Use the supervised method if:
            - You have a  labeled  dataset  with ideal responses  for your prompts.
            - Your task is  well-defined and does  not require subjective adjustments  or alignment
              with human preferences.

        * Use the DPO method if:
            - You want the model to generate responses that align with human or specific subjective
              preferences.
            - You have a dataset with comparisons between multiple responses.
            - You  aim  to  improve  response  quality  for  creative  or  open-ended  tasks  where
              preferences  are  key.

  In summary, the  supervised method  is ideal for  well-defined tasks, while  DPO is more suitable
  when human preferences or subjective criteria are central to your project.

*)

interface

uses
  System.SysUtils, System.Classes, System.Threading, System.JSON, REST.Json.Types,
  REST.JsonReflect,
  GenAI.API.Params, GenAI.API, GenAI.Consts, GenAI.Types, GenAI.Async.Support;

type
  /// <summary>
  /// Represents the URL parameters for fine-tuning-related API requests.
  /// This class provides methods for setting pagination parameters
  /// such as "after" and "limit" to filter and retrieve fine-tuning jobs
  /// or related events.
  /// </summary>
  TFineTuningURLParams = class(TUrlParam)
  public
    /// <summary>
    /// Specifies the identifier of the last job from the previous pagination request.
    /// This parameter allows fetching the next set of results after the given identifier.
    /// </summary>
    /// <param name="Value">
    /// The identifier of the last job from the previous pagination request.
    /// </param>
    /// <returns>
    /// Returns the current instance of <c>TFineTuningURLParams</c> to allow method chaining.
    /// </returns>
    function After(const Value: string): TFineTuningURLParams;
    /// <summary>
    /// Sets the limit on the number of results to retrieve in a single API request.
    /// The limit specifies the maximum number of fine-tuning jobs or events to fetch.
    /// </summary>
    /// <param name="Value">
    /// An integer representing the maximum number of results to retrieve.
    /// </param>
    /// <returns>
    /// Returns the current instance of <c>TFineTuningURLParams</c> to allow method chaining.
    /// </returns>
    function Limit(const Value: Int64): TFineTuningURLParams;
  end;

  /// <summary>
  /// Represents the configuration parameters for Weights and Biases (WandB) integration
  /// in fine-tuning jobs. These parameters specify project details, run names, entities,
  /// and tags associated with WandB.
  /// </summary>
  TWandbParams = class(TJSONParam)
  public
    /// <summary>
    /// Sets the name of the project in Weights and Biases where metrics for the fine-tuning job
    /// will be stored.
    /// </summary>
    /// <param name="Value">
    /// The name of the project to associate with the WandB run.
    /// </param>
    /// <returns>
    /// Returns the current instance of <c>TWandbParams</c> to allow method chaining.
    /// </returns>
    function Project(const Value: string): TWandbParams;
    /// <summary>
    /// Sets a custom display name for the Weights and Biases run.
    /// If not provided, the fine-tuning job ID will be used as the default name.
    /// </summary>
    /// <param name="Value">
    /// A string representing the custom display name for the WandB run.
    /// </param>
    /// <returns>
    /// Returns the current instance of <c>TWandbParams</c> to allow method chaining.
    /// </returns>
    function Name(const Value: string): TWandbParams;
    /// <summary>
    /// Sets the entity (e.g., team or username) to associate with the Weights and Biases run.
    /// If not specified, the default entity for the registered WandB API key is used.
    /// </summary>
    /// <param name="Value">
    /// A string representing the entity for the WandB run.
    /// </param>
    /// <returns>
    /// Returns the current instance of <c>TWandbParams</c> to allow method chaining.
    /// </returns>
    function Entity(const Value: string): TWandbParams;
    /// <summary>
    /// Attaches tags to the Weights and Biases run. These tags can be used for filtering
    /// and categorizing runs within the WandB interface.
    /// </summary>
    /// <param name="Value">
    /// An array of strings representing tags to assign to the WandB run.
    /// </param>
    /// <returns>
    /// Returns the current instance of <c>TWandbParams</c> to allow method chaining.
    /// </returns>
    function Tags(const Value: TArray<string>): TWandbParams;
    /// <summary>
    /// Creates a new instance of <c>TWandbParams</c> with the specified project, name, entity,
    /// and tags pre-configured.
    /// </summary>
    /// <param name="Project">
    /// The name of the project to associate with the WandB run.
    /// </param>
    /// <param name="Name">
    /// A custom display name for the WandB run.
    /// </param>
    /// <param name="Entity">
    /// The entity (team or username) to associate with the WandB run.
    /// </param>
    /// <param name="Tags">
    /// An array of strings representing tags for the WandB run.
    /// </param>
    /// <returns>
    /// A new instance of <c>TWandbParams</c> with the specified parameters.
    /// </returns>
    class function New(const Project, Name, Entity: string; const Tags: TArray<string>): TWandbParams;
  end;

  /// <summary>
  /// Represents the configuration parameters for integrating external services
  /// into fine-tuning jobs. This class supports defining the type of integration
  /// (e.g., Weights and Biases) and its associated configuration details.
  /// </summary>
  TJobIntegrationParams = class(TJSONParam)
  public
    /// <summary>
    /// Sets the type of integration to enable for the fine-tuning job.
    /// For example, "wandb" can be used to enable Weights and Biases integration.
    /// </summary>
    /// <param name="Value">
    /// A string representing the type of integration (e.g., "wandb").
    /// </param>
    /// <returns>
    /// Returns the current instance of <c>TJobIntegrationParams</c> to allow method chaining.
    /// </returns>
    function &Type(const Value: string): TJobIntegrationParams;
    /// <summary>
    /// Configures the Weights and Biases (WandB) integration for the fine-tuning job
    /// using a pre-defined <c>TWandbParams</c> object.
    /// </summary>
    /// <param name="Value">
    /// An instance of <c>TWandbParams</c> containing the configuration details
    /// for the WandB integration.
    /// </param>
    /// <returns>
    /// Returns the current instance of <c>TJobIntegrationParams</c> to allow method chaining.
    /// </returns>
    function Wandb(const Value: TWandbParams): TJobIntegrationParams; overload;
    /// <summary>
    /// Configures the Weights and Biases (WandB) integration for the fine-tuning job
    /// using a raw JSON object.
    /// </summary>
    /// <param name="Value">
    /// A JSON object (<c>TJSONObject</c>) containing the configuration details
    /// for the WandB integration.
    /// </param>
    /// <returns>
    /// Returns the current instance of <c>TJobIntegrationParams</c> to allow method chaining.
    /// </returns>
    function Wandb(const Value: TJSONObject): TJobIntegrationParams; overload;
  end;

  /// <summary>
  /// Represents the configuration of hyperparameters for fine-tuning jobs.
  /// This class provides methods to set parameters such as batch size,
  /// learning rate, number of epochs, and beta (for DPO).
  /// </summary>
  THyperparametersParams = class(TJSONParam)
  public
    /// <summary>
    /// Sets the beta value for the DPO (Direct Preference Optimization) fine-tuning method.
    /// A higher beta value increases the weight of the penalty between the policy
    /// and reference models.
    /// </summary>
    /// <param name="Value">
    /// A floating-point value representing the beta parameter for the DPO method.
    /// </param>
    /// <returns>
    /// Returns the current instance of <c>THyperparametersParams</c> to allow method chaining.
    /// </returns>
    function Beta(const Value: Double): THyperparametersParams;
    /// <summary>
    /// Sets the batch size for the fine-tuning job. A larger batch size means
    /// model parameters are updated less frequently, but with lower variance.
    /// </summary>
    /// <param name="Value">
    /// An integer representing the number of examples in each batch.
    /// </param>
    /// <returns>
    /// Returns the current instance of <c>THyperparametersParams</c> to allow method chaining.
    /// </returns>
    function BatchSize(const Value: Integer): THyperparametersParams;
    /// <summary>
    /// Sets the learning rate multiplier for the fine-tuning job. A smaller learning
    /// rate may help avoid overfitting, while a larger one speeds up training.
    /// </summary>
    /// <param name="Value">
    /// A floating-point value representing the scaling factor for the learning rate.
    /// </param>
    /// <returns>
    /// Returns the current instance of <c>THyperparametersParams</c> to allow method chaining.
    /// </returns>
    function LearningRateMultiplier(const Value: Double): THyperparametersParams;
    /// <summary>
    /// Sets the number of epochs for the fine-tuning job. An epoch refers to one
    /// full cycle through the training dataset.
    /// </summary>
    /// <param name="Value">
    /// An integer representing the number of epochs to train the model.
    /// </param>
    /// <returns>
    /// Returns the current instance of <c>THyperparametersParams</c> to allow method chaining.
    /// </returns>
    function NEpochs(const Value: Integer): THyperparametersParams;
  end;

  /// <summary>
  /// Represents the configuration parameters for the supervised fine-tuning method.
  /// This class allows specifying hyperparameters to be used in supervised learning tasks.
  /// </summary>
  TSupervisedMethodParams = class(TJSONParam)
  public
    /// <summary>
    /// Sets the hyperparameters for the supervised fine-tuning method.
    /// These hyperparameters include values such as batch size, learning rate,
    /// and the number of epochs.
    /// </summary>
    /// <param name="Value">
    /// An instance of <c>THyperparametersParams</c> that defines the hyperparameters
    /// for supervised fine-tuning.
    /// </param>
    /// <returns>
    /// Returns the current instance of <c>TSupervisedMethodParams</c> to allow method chaining.
    /// </returns>
    function Hyperparameters(const Value: THyperparametersParams): TSupervisedMethodParams;
    /// <summary>
    /// Creates a new instance of <c>TSupervisedMethodParams</c> with the specified hyperparameters.
    /// This method simplifies initialization when configuring the supervised method for fine-tuning.
    /// </summary>
    /// <param name="Value">
    /// An instance of <c>THyperparametersParams</c> that defines the hyperparameters
    /// for supervised fine-tuning.
    /// </param>
    /// <returns>
    /// A new instance of <c>TSupervisedMethodParams</c> configured with the provided hyperparameters.
    /// </returns>
    class function New(const Value: THyperparametersParams): TSupervisedMethodParams;
  end;

  /// <summary>
  /// Represents the configuration parameters for the DPO (Direct Preference Optimization)
  /// fine-tuning method. This class allows specifying hyperparameters to be used
  /// in DPO-based learning tasks.
  /// </summary>
  TDpoMethodParams = class(TJSONParam)
  public
    /// <summary>
    /// Sets the hyperparameters for the DPO fine-tuning method.
    /// These hyperparameters include values such as batch size, learning rate,
    /// number of epochs, and beta.
    /// </summary>
    /// <param name="Value">
    /// An instance of <c>THyperparametersParams</c> that defines the hyperparameters
    /// for the DPO fine-tuning method.
    /// </param>
    /// <returns>
    /// Returns the current instance of <c>TDpoMethodParams</c> to allow method chaining.
    /// </returns>
    function Hyperparameters(const Value: THyperparametersParams): TDpoMethodParams;
    /// <summary>
    /// Creates a new instance of <c>TDpoMethodParams</c> with the specified hyperparameters.
    /// This method simplifies initialization when configuring the DPO method for fine-tuning.
    /// </summary>
    /// <param name="Value">
    /// An instance of <c>THyperparametersParams</c> that defines the hyperparameters
    /// for the DPO fine-tuning method.
    /// </param>
    /// <returns>
    /// A new instance of <c>TDpoMethodParams</c> configured with the provided hyperparameters.
    /// </returns>
    class function New(const Value: THyperparametersParams): TDpoMethodParams;
  end;

  /// <summary>
  /// Represents the configuration for the fine-tuning method to be used in a job.
  /// This class supports multiple methods, such as supervised learning or
  /// Direct Preference Optimization (DPO), and allows setting their respective parameters.
  /// </summary>
  TJobMethodParams = class(TJSONParam)
  public
    /// <summary>
    /// Sets the type of fine-tuning method to use, such as "supervised" or "dpo".
    /// </summary>
    /// <param name="Value">
    /// A string representing the fine-tuning method type (e.g., "supervised" or "dpo").
    /// </param>
    /// <returns>
    /// Returns the current instance of <c>TJobMethodParams</c> to allow method chaining.
    /// </returns>
    function &Type(const Value: string): TJobMethodParams; overload;
    /// <summary>
    /// Sets the type of fine-tuning method to use, using the <c>TJobMethodType</c> enumeration.
    /// </summary>
    /// <param name="Value">
    /// A value from the <c>TJobMethodType</c> enumeration representing the fine-tuning method type.
    /// </param>
    /// <returns>
    /// Returns the current instance of <c>TJobMethodParams</c> to allow method chaining.
    /// </returns>
    function &Type(const Value: TJobMethodType): TJobMethodParams; overload;
    /// <summary>
    /// Configures the supervised fine-tuning method by setting its hyperparameters.
    /// </summary>
    /// <param name="Value">
    /// An instance of <c>TSupervisedMethodParams</c> containing the hyperparameters
    /// for the supervised fine-tuning method.
    /// </param>
    /// <returns>
    /// Returns the current instance of <c>TJobMethodParams</c> to allow method chaining.
    /// </returns>
    function Supervised(const Value: TSupervisedMethodParams): TJobMethodParams;
    /// <summary>
    /// Configures the DPO (Direct Preference Optimization) fine-tuning method by setting its hyperparameters.
    /// </summary>
    /// <param name="Value">
    /// An instance of <c>TDpoMethodParams</c> containing the hyperparameters
    /// for the DPO fine-tuning method.
    /// </param>
    /// <returns>
    /// Returns the current instance of <c>TJobMethodParams</c> to allow method chaining.
    /// </returns>
    function Dpo(const Value: TDpoMethodParams): TJobMethodParams;
    /// <summary>
    /// Creates a new instance of <c>TJobMethodParams</c> configured with a supervised fine-tuning method.
    /// </summary>
    /// <param name="Value">
    /// An instance of <c>THyperparametersParams</c> containing the hyperparameters
    /// for the supervised fine-tuning method.
    /// </param>
    /// <returns>
    /// A new instance of <c>TJobMethodParams</c> configured for supervised fine-tuning.
    /// </returns>
    class function NewSupervised(const Value: THyperparametersParams): TJobMethodParams;
    /// <summary>
    /// Creates a new instance of <c>TJobMethodParams</c> configured with a DPO fine-tuning method.
    /// </summary>
    /// <param name="Value">
    /// An instance of <c>THyperparametersParams</c> containing the hyperparameters
    /// for the DPO fine-tuning method.
    /// </param>
    /// <returns>
    /// A new instance of <c>TJobMethodParams</c> configured for DPO fine-tuning.
    /// </returns>
    class function NewDpo(const Value: THyperparametersParams): TJobMethodParams;
  end;

  /// <summary>
  /// Represents the configuration parameters for creating a fine-tuning job.
  /// This class allows setting various properties, such as the model to fine-tune,
  /// training and validation files, hyperparameters, and optional metadata.
  /// </summary>
  TFineTuningJobParams = class(TJSONParam)
  public
    /// <summary>
    /// Sets the base model to be fine-tuned.
    /// </summary>
    /// <param name="Value">
    /// A string representing the name of the base model to fine-tune.
    /// </param>
    /// <returns>
    /// Returns the current instance of <c>TFineTuningJobParams</c> to allow method chaining.
    /// </returns>
    function Model(const Value: string): TFineTuningJobParams;
    /// <summary>
    /// Sets the file ID of the training dataset to be used for fine-tuning.
    /// The file must be uploaded and formatted as a JSONL file with the purpose "fine-tune".
    /// </summary>
    /// <param name="Value">
    /// A string representing the file ID of the training dataset.
    /// </param>
    /// <returns>
    /// Returns the current instance of <c>TFineTuningJobParams</c> to allow method chaining.
    /// </returns>
    function TrainingFile(const Value: string): TFineTuningJobParams;
    /// <summary>
    /// Sets an optional suffix to be added to the name of the fine-tuned model.
    /// </summary>
    /// <param name="Value">
    /// A string of up to 64 characters to append to the model name.
    /// </param>
    /// <returns>
    /// Returns the current instance of <c>TFineTuningJobParams</c> to allow method chaining.
    /// </returns>
    function Suffix(const Value: string): TFineTuningJobParams;
    /// <summary>
    /// Sets the file ID of the validation dataset to be used for fine-tuning.
    /// The file must be uploaded and formatted as a JSONL file with the purpose "fine-tune".
    /// </summary>
    /// <param name="Value">
    /// A string representing the file ID of the validation dataset.
    /// </param>
    /// <returns>
    /// Returns the current instance of <c>TFineTuningJobParams</c> to allow method chaining.
    /// </returns>
    function ValidationFile(const Value: string): TFineTuningJobParams;
    /// <summary>
    /// Configures the integrations (e.g., Weights and Biases) for the fine-tuning job.
    /// </summary>
    /// <param name="Value">
    /// An array of <c>TJobIntegrationParams</c> objects defining the integrations to enable.
    /// </param>
    /// <returns>
    /// Returns the current instance of <c>TFineTuningJobParams</c> to allow method chaining.
    /// </returns>
    function Integrations(const Value: TArray<TJobIntegrationParams>): TFineTuningJobParams;
    /// <summary>
    /// Sets the random seed for the fine-tuning job to ensure reproducibility.
    /// If not provided, a random seed will be generated.
    /// </summary>
    /// <param name="Value">
    /// An integer representing the random seed for the fine-tuning job.
    /// </param>
    /// <returns>
    /// Returns the current instance of <c>TFineTuningJobParams</c> to allow method chaining.
    /// </returns>
    function Seed(const Value: Integer): TFineTuningJobParams;
    /// <summary>
    /// Configures the method and hyperparameters for the fine-tuning job.
    /// </summary>
    /// <param name="Value">
    /// An instance of <c>TJobMethodParams</c> that defines the fine-tuning method
    /// and its hyperparameters (e.g., supervised or DPO).
    /// </param>
    /// <returns>
    /// Returns the current instance of <c>TFineTuningJobParams</c> to allow method chaining.
    /// </returns>
    function Method(const Value: TJobMethodParams): TFineTuningJobParams; overload;
    /// <summary>
    /// Configures the method and hyperparameters for the fine-tuning job
    /// by specifying the method type and its corresponding hyperparameters.
    /// </summary>
    /// <param name="AType">
    /// The type of fine-tuning method, such as <c>TJobMethodType.supervised</c> or <c>TJobMethodType.dpo</c>.
    /// </param>
    /// <param name="Value">
    /// An instance of <c>THyperparametersParams</c> that defines the hyperparameters
    /// for the specified fine-tuning method.
    /// </param>
    /// <returns>
    /// Returns the current instance of <c>TFineTuningJobParams</c> to allow method chaining.
    /// </returns>
    function Method(const AType: TJobMethodType; const Value: THyperparametersParams): TFineTuningJobParams; overload;
  end;

  /// <summary>
  /// Represents a paginated list of fine-tuning job-related objects.
  /// This generic class can store a list of objects of type <c>T</c> and
  /// provides metadata about pagination, such as whether more results are available.
  /// </summary>
  /// <typeparam name="T">
  /// The type of objects stored in the list. It must be a class and have a default constructor.
  /// </typeparam>
  TJobList<T: class, constructor> = class(TJSONFingerprint)
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
    /// Destructor for the <c>TJobList</c> class.
    /// Frees all objects stored in the <c>Data</c> property to release memory.
    /// </summary>
    destructor Destroy; override;
  end;

  /// <summary>
  /// Represents detailed error information for a fine-tuning job that has failed.
  /// This class contains information about the error code, message, and the parameter
  /// that caused the failure.
  /// </summary>
  TFineTuningJobError = class
  private
    FCode: string;
    FMessage: string;
    FParam: string;
  public
    /// <summary>
    /// Gets or sets the machine-readable error code.
    /// </summary>
    property Code: string read FCode write FCode;
    /// <summary>
    /// Gets or sets the human-readable error message providing details about the error.
    /// </summary>
    property Message: string read FMessage write FMessage;
    /// <summary>
    /// Gets or sets the name of the parameter that caused the error, if applicable.
    /// </summary>
    property Param: string read FParam write FParam;
  end;

  /// <summary>
  /// Represents the hyperparameters used for a fine-tuning job in OpenAI's fine-tuning API.
  /// </summary>
  /// <remarks>
  /// The hyperparameters include options to control the training process, such as the batch size,
  /// learning rate, number of epochs, and beta (used in specific fine-tuning methods like DPO).
  /// These parameters allow customization of the model's fine-tuning behavior for optimal performance.
  /// </remarks>
  THyperparameters = class
  private
    FBeta: Variant;
    [JsonNameAttribute('batch_size')]
    FBatchSize: Variant;
    [JsonNameAttribute('learning_rate_multiplier')]
    FLearningRateMultiplier: Variant;
    [JsonNameAttribute('n_epochs')]
    FNEpochs: Variant;
  public
    /// <summary>
    /// Gets or sets the beta value for the fine-tuning job.
    /// </summary>
    /// <remarks>
    /// The beta value as a number or "auto." A higher beta applies greater weight to the penalty between
    /// the policy and reference model in DPO fine-tuning.
    /// </remarks>
    property Beta: Variant read FBeta write FBeta;
    /// <summary>
    /// Gets or sets the batch size for the fine-tuning job.
    /// </summary>
    /// <remarks>
    /// The batch size as an integer or "auto." A larger batch size reduces the frequency of updates
    /// but decreases the variance in parameter updates.
    /// </remarks>
    property BatchSize: Variant read FBatchSize write FBatchSize;
    /// <summary>
    /// Gets or sets the learning rate multiplier for the fine-tuning job.
    /// </summary>
    /// <remarks>
    /// The learning rate multiplier as a number or "auto." This value scales the base learning rate
    /// to control the magnitude of parameter updates.
    /// </value>
    property LearningRateMultiplier: Variant read FLearningRateMultiplier write FLearningRateMultiplier;
    /// <summary>
    /// Gets or sets the number of epochs for the fine-tuning job.
    /// </summary>
    /// <remarks>
    /// The number of epochs as an integer or "auto." An epoch represents a complete pass through the
    /// training dataset.
    /// </value>
    property NEpochs: Variant read FNEpochs write FNEpochs;
  end;

  /// <summary>
  /// Represents the configuration for integrating with Weights and Biases (WandB) in a fine-tuning job.
  /// </summary>
  /// <remarks>
  /// This class provides methods to set project details, display names, entities, and tags
  /// for runs tracked in WandB during the fine-tuning process.
  /// </remarks>
  TWanDB = class
  private
    FProject: string;
    FName: string;
    FEntity: string;
    FTags: TArray<string>;
  public
    /// <summary>
    /// Gets or sets the project name in WandB under which the fine-tuning metrics will be logged.
    /// </summary>
    /// <param name="Value">
    /// The name of the WandB project.
    /// </param>
    /// <returns>
    /// The updated instance of the <c>TWanDB</c> class.
    /// </returns>
    property Project: string read FProject write FProject;
    /// <summary>
    /// Gets or sets the display name for the run in WandB.
    /// </summary>
    /// <param name="Value">
    /// The display name to set for the run. If not specified, the job ID will be used.
    /// </param>
    /// <returns>
    /// The updated instance of the <c>TWanDB</c> class.
    /// </returns>
    property Name: string read FName write FName;
    /// <summary>
    /// Gets or sets the entity (team or username) associated with the WandB run.
    /// </summary>
    /// <param name="Value">
    /// The entity to associate with the run. If not specified, the default entity
    /// for the registered WandB API key will be used.
    /// </param>
    /// <returns>
    /// The updated instance of the <c>TWanDB</c> class.
    /// </returns>
    property Entity: string read FEntity write FEntity;
    /// <summary>
    /// Gets or sets the tags to be attached to the WandB run.
    /// </summary>
    /// <param name="Value">
    /// An array of strings representing tags to attach to the run. These tags can help categorize and
    /// filter runs in WandB.
    /// </param>
    /// <returns>
    /// The updated instance of the <c>TWanDB</c> class.
    /// </returns>
    property Tags: TArray<string> read FTags write FTags;
  end;

  /// <summary>
  /// Represents the integration settings for a fine-tuning job, including integration with tools
  /// like Weights and Biases (WandB).
  /// </summary>
  /// <remarks>
  /// This class allows configuration of the type of integration and specific settings for each tool,
  /// such as WandB.
  /// </remarks>
  FineTuningJobIntegration = class
  private
    FType: string;
    FWandb: TWanDB;
  public
    /// <summary>
    /// Gets or sets the type of integration being enabled for the fine-tuning job.
    /// </summary>
    /// <remarks>
    /// A string representing the integration type, such as "wandb".
    /// </remarks>
    property &Type: string read FType write FType;
    /// <summary>
    /// Gets or sets the configuration for the Weights and Biases (WandB) integration.
    /// </summary>
    /// <remarks>
    /// An instance of the <c>TWanDB</c> class containing the WandB settings, such as project name,
    /// tags, and entity.
    /// </remarks>
    property Wandb: TWanDB read FWandb write FWandb;
    destructor Destroy; override;
  end;

  /// <summary>
  /// Represents the configuration for supervised fine-tuning in a fine-tuning job.
  /// </summary>
  /// <remarks>
  /// This class contains the hyperparameters that define the supervised fine-tuning process.
  /// </remarks>
  TSupervised = class
  private
    FHyperparameters: THyperparameters;
  public
    /// <summary>
    /// Gets or sets the hyperparameters for the supervised fine-tuning method.
    /// </summary>
    /// <remarks>
    /// An instance of the <c>THyperparameters</c> class containing the configuration details, such as
    /// batch size, learning rate, and number of epochs.
    /// </remarks>
    property Hyperparameters: THyperparameters read FHyperparameters write FHyperparameters;
    destructor Destroy; override;
  end;

  /// <summary>
  /// Represents the configuration for the DPO (Direct Preference Optimization) fine-tuning method
  /// in a fine-tuning job.
  /// </summary>
  /// <remarks>
  /// This class contains the hyperparameters that define the DPO fine-tuning process.
  /// </remarks>
  TDpo = class
  private
    FHyperparameters: THyperparameters;
  public
    /// <summary>
    /// Gets or sets the hyperparameters for the DPO fine-tuning method.
    /// </summary>
    /// <remarks
    /// An instance of the <c>THyperparameters</c> class containing the configuration details, such as
    /// beta, batch size, learning rate, and number of epochs.
    /// </remarks>
    property Hyperparameters: THyperparameters read FHyperparameters write FHyperparameters;
    destructor Destroy; override;
  end;

  /// <summary>
  /// Represents the method configuration for fine-tuning in a fine-tuning job.
  /// </summary>
  /// <remarks>
  /// This class defines the type of fine-tuning method (e.g., supervised or DPO) and includes the
  /// specific configurations for each method.
  /// </remarks>
  TFineTuningMethod = class
  private
    [JsonReflectAttribute(ctString, rtString, TJobMethodTypeInterceptor)]
    FType: TJobMethodType;
    FSupervised: TSupervised;
    FDpo: TDpo;
  public
    /// <summary>
    /// Gets or sets the type of fine-tuning method.
    /// </summary>
    /// <remarks>
    /// A value of type <c>TJobMethodType</c> that specifies whether the method is "supervised" or "dpo".
    /// </remarks>
    property &Type: TJobMethodType read FType write FType;
    /// <summary>
    /// Gets or sets the configuration for supervised fine-tuning.
    /// </summary>
    /// <remarks>
    /// An instance of the <c>TSupervised</c> class containing the hyperparameters for supervised
    /// fine-tuning.
    /// </remarks>
    property Supervised: TSupervised read FSupervised write FSupervised;
    /// <summary>
    /// Gets or sets the configuration for DPO (Direct Preference Optimization) fine-tuning.
    /// </summary>
    /// <remarks>
    /// An instance of the <c>TDpo</c> class containing the hyperparameters for DPO fine-tuning.
    /// </remarks>
    property Dpo: TDpo read FDpo write FDpo;
    destructor Destroy; override;
  end;

  /// <summary>
  /// Represents a fine-tuning job in OpenAI's fine-tuning API.
  /// </summary>
  /// <remarks>
  /// This class contains details about a fine-tuning job, including its status, configuration, and results.
  /// </remarks>
  TFineTuningJob = class(TJSONFingerprint)
  private
    FId: string;
    [JsonNameAttribute('created_at')]
    FCreatedAt: Int64;
    FError: TFineTuningJobError;
    [JsonNameAttribute('fine_tuned_model')]
    FFineTunedModel: string;
    [JsonNameAttribute('finished_at')]
    FFinishedAt: Int64;
    FHyperparameters: THyperparameters;
    FModel: string;
    FObject: string;
    [JsonNameAttribute('organization_id')]
    FOrganizationId: string;
    [JsonNameAttribute('result_files')]
    FResultFiles: TArray<string>;
    [JsonReflectAttribute(ctString, rtString, TFineTunedStatusInterceptor)]
    FStatus: TFineTunedStatus;
    [JsonNameAttribute('trained_tokens')]
    FTrainedTokens: Int64;
    [JsonNameAttribute('training_file')]
    FTrainingFile: string;
    [JsonNameAttribute('validation_file')]
    FValidationFile: string;
    FIntegrations: TArray<FineTuningJobIntegration>;
    FSeed: Int64;
    [JsonNameAttribute('estimated_finish')]
    FEstimatedFinish: Int64;
    FMethod: TFineTuningMethod;
  private
    function GetCreatedAtAsString: string;
    function GetFinishedAtAsString: string;
    function GetEstimatedFinishAsString: string;
  public
    /// <summary>
    /// Gets or sets the unique identifier of the fine-tuning job.
    /// </summary>
    /// <remarks>
    /// A string representing the fine-tuning job's ID.
    /// </remarks>
    property Id: string read FId write FId;
    /// <summary>
    /// Gets or sets the creation timestamp of the fine-tuning job in Unix format (seconds).
    /// </summary>
    /// <remarks>
    /// A 64-bit integer representing the creation time of the job.
    /// </remarks>
    property CreatedAt: Int64 read FCreatedAt write FCreatedAt;
    /// <summary>
    /// Gets the creation timestamp of the fine-tuning job as a human-readable string.
    /// </summary>
    /// <remarks>
    /// A string representation of the job's creation timestamp.
    /// </remarks>
    property CreatedAtAsString: string read GetCreatedAtAsString;
    /// <summary>
    /// Gets or sets the error details, if the fine-tuning job has failed.
    /// </summary>
    /// <remarks>
    /// An instance of <c>TFineTuningJobError</c> containing error information, or <c>nil</c> if no error occurred.
    /// </remarks>
    property Error: TFineTuningJobError read FError write FError;
    /// <summary>
    /// Gets or sets the name of the fine-tuned model created by this job.
    /// </summary>
    /// <remarks>
    /// A string representing the name of the fine-tuned model, or <c>nil</c> if the job is not complete.
    /// </remarks>
    property FineTunedModel: string read FFineTunedModel write FFineTunedModel;
    /// <summary>
    /// Gets or sets the completion timestamp of the fine-tuning job in Unix format (seconds).
    /// </summary>
    /// <remarks>
    /// A 64-bit integer representing the completion time of the job, or <c>nil</c> if the job is still running.
    /// </remarks>
    property FinishedAt: Int64 read FFinishedAt write FFinishedAt;
    /// <summary>
    /// Gets the completion timestamp of the fine-tuning job as a human-readable string.
    /// </summary>
    /// <remarks>
    /// A string representation of the job's completion timestamp.
    /// </remarks>
    property FinishedAtAsString: string read GetFinishedAtAsString;
    /// <summary>
    /// Gets or sets the hyperparameters used in the fine-tuning job.
    /// </summary>
    /// <remarks>
    /// An instance of the <c>THyperparameters</c> class containing the hyperparameter configuration.
    /// </remarks>
    property Hyperparameters: THyperparameters read FHyperparameters write FHyperparameters;
    /// <summary>
    /// Gets or sets the base model being fine-tuned.
    /// </summary>
    /// <remarks>
    /// A string representing the name of the base model.
    /// </remarks>
    property Model: string read FModel write FModel;
    /// <summary>
    /// Gets or sets the object type for the fine-tuning job.
    /// </summary>
    /// <remarks>
    /// A string that always indicates the type of this object, typically "fine_tuning.job".
    /// </remarks>
    property &Object: string read FObject write FObject;
    /// <summary>
    /// Gets or sets the organization ID associated with the fine-tuning job.
    /// </summary>
    /// <remarks>
    /// A string representing the organization ID.
    /// </remarks>
    property OrganizationId: string read FOrganizationId write FOrganizationId;
    /// <summary>
    /// Gets or sets the list of result file IDs generated by the fine-tuning job.
    /// </summary>
    /// <remarks>
    /// An array of strings containing the IDs of the result files.
    /// </remarks>
    property ResultFiles: TArray<string> read FResultFiles write FResultFiles;
    /// <summary>
    /// Gets or sets the current status of the fine-tuning job.
    /// </summary>
    /// <remarks>
    /// A value of type <c>TFineTunedStatus</c> representing the job's status (e.g., running, succeeded, failed).
    /// </remarks>
    property Status: TFineTunedStatus read FStatus write FStatus;
    /// <summary>
    /// Gets or sets the total number of billable tokens processed by this fine-tuning job.
    /// </summary>
    /// <remarks>
    /// A 64-bit integer representing the total tokens processed, or <c>nil</c> if the job is still running.
    /// </remarks>
    property TrainedTokens: Int64 read FTrainedTokens write FTrainedTokens;
    /// <summary>
    /// Gets or sets the file ID used for training data in the fine-tuning job.
    /// </summary>
    /// <remarks>
    /// A string representing the training file ID.
    /// </remarks>
    property TrainingFile: string read FTrainingFile write FTrainingFile;
    /// <summary>
    /// Gets or sets the file ID used for validation data in the fine-tuning job.
    /// </summary>
    /// <remarks>
    /// A string representing the validation file ID, or <c>nil</c> if no validation file was provided.
    /// </remarks>
    property ValidationFile: string read FValidationFile write FValidationFile;
    /// <summary>
    /// Gets or sets the list of integrations enabled for the fine-tuning job.
    /// </summary>
    /// <remarks>
    /// An array of <c>FineTuningJobIntegration</c> instances representing the enabled integrations.
    /// </remarks>
    property Integrations: TArray<FineTuningJobIntegration> read FIntegrations write FIntegrations;
    /// <summary>
    /// Gets or sets the random seed used for the fine-tuning job.
    /// </summary>
    /// <remarks>
    /// A 64-bit integer representing the seed value.
    /// </remarks>
    property Seed: Int64 read FSeed write FSeed;
    /// <summary>
    /// Gets or sets the estimated completion time for the fine-tuning job in Unix format (seconds).
    /// </summary>
    /// <remarks>
    /// A 64-bit integer representing the estimated finish time, or <c>nil</c> if the job is not running.
    /// </remarks>
    property EstimatedFinish: Int64 read FEstimatedFinish write FEstimatedFinish;
    /// <summary>
    /// Gets the estimated completion time of the fine-tuning job as a human-readable string.
    /// </summary>
    /// <remarks>
    /// A string representation of the job's estimated finish time.
    /// </remarks>
    property EstimatedFinishAsString: string read GetEstimatedFinishAsString;
    /// <summary>
    /// Gets or sets the method configuration for the fine-tuning job.
    /// </summary>
    /// <remarks>
    /// An instance of the <c>TFineTuningMethod</c> class containing the method configuration.
    /// </remarks>
    property Method: TFineTuningMethod read FMethod write FMethod;
    destructor Destroy; override;
  end;

  /// <summary>
  /// Represents a list of fine-tuning jobs in OpenAI's fine-tuning API.
  /// </summary>
  /// <remarks>
  /// This class extends <c>TJobList</c> to provide a collection of fine-tuning jobs and their details.
  /// </remarks>
  TFineTuningJobs = TJobList<TFineTuningJob>;

  TEventData = class
  private
  public
  end;

  /// <summary>
  /// Represents an event associated with a fine-tuning job in OpenAI's fine-tuning API.
  /// </summary>
  /// <remarks>
  /// This class provides information about a specific event, including its type, timestamp,
  /// message, and associated data.
  /// </remarks>
  TJobEvent = class
  private
    FObject: string;
    FId: string;
    [JsonNameAttribute('created_at')]
    FCreatedAt: Int64;
    FLevel: string;
    FMessage: string;
    FType: string;
    FData: TEventData;
  private
    function GetCreatedAtAsString: string;
  public
    /// <summary>
    /// Gets or sets the object type of the event.
    /// </summary>
    /// <remarks>
    /// A string that always has the value "fine_tuning.job.event".
    /// </remarks>
    property &Object: string read FObject write FObject;
    /// <summary>
    /// Gets or sets the unique identifier for the event.
    /// </summary>
    /// <remarks>
    /// A string representing the event's unique ID.
    /// </remarks>
    property Id: string read FId write FId;
    /// <summary>
    /// Gets or sets the timestamp when the event was created, in Unix format (seconds).
    /// </summary>
    /// <remarks>
    /// A 64-bit integer representing the event's creation time.
    /// </remarks>
    property CreatedAt: Int64 read FCreatedAt write FCreatedAt;
    /// <summary>
    /// Gets the creation timestamp of the event as a human-readable string.
    /// </summary>
    /// <remarks>
    /// A string representation of the event's creation timestamp.
    /// </remarks>
    property CreatedAtAsString: string read GetCreatedAtAsString;
    /// <summary>
    /// Gets or sets the log level of the event.
    /// </summary>
    /// <remarks>
    /// A string indicating the log level (e.g., "info", "warning", "error").
    /// </remarks>
    property Level: string read FLevel write FLevel;
    /// <summary>
    /// Gets or sets the message associated with the event.
    /// </summary>
    /// <remarks>
    /// A string containing a human-readable description of the event.
    /// </remarks>
    property Message: string read FMessage write FMessage;
    /// <summary>
    /// Gets or sets the type of the event.
    /// </summary>
    /// <remarks>
    /// A string describing the event type (e.g., "status", "metrics").
    /// </remarks>
    property &Type: string read FType write FType;
    /// <summary>
    /// Gets or sets the additional data associated with the event.
    /// </summary>
    /// <remarks>
    /// An instance of <c>TEventData</c> containing event-specific data, or <c>nil</c> if no data is available.
    /// </remarks>
    property Data: TEventData read FData write FData;
    destructor Destroy; override;
  end;

  /// <summary>
  /// Represents a list of events associated with a fine-tuning job in OpenAI's fine-tuning API.
  /// </summary>
  /// <remarks>
  /// This class extends <c>TJobList</c> to provide a collection of events for a specific fine-tuning job,
  /// including their details such as type, message, and timestamps.
  /// </remarks>
  TJobEvents = TJobList<TJobEvent>;

  /// <summary>
  /// Represents the metrics collected during a fine-tuning job in OpenAI's fine-tuning API.
  /// </summary>
  /// <remarks>
  /// This class contains various metrics related to the training and validation process,
  /// including loss values and token accuracy.
  /// </remarks>
  TMetrics = class
  private
    FStep: Double;
    [JsonNameAttribute('train_loss')]
    FTrainLoss: Double;
    [JsonNameAttribute('train_mean_token_accuracy')]
    FTrainMeanTokenAccuracy: Double;
    [JsonNameAttribute('valid_loss')]
    FValidLoss: Double;
    [JsonNameAttribute('valid_mean_token_accuracy')]
    FValidMeanTokenAccuracy: Double;
    [JsonNameAttribute('full_valid_loss')]
    FFullValidLoss: Double;
    [JsonNameAttribute('full_valid_mean_token_accuracy')]
    FFullValidMeanTokenAccuracy: Double;
  public
    /// <summary>
    /// Gets or sets the current step number in the fine-tuning process.
    /// </summary>
    /// <remarks>
    /// A double representing the step at which the metrics were collected.
    /// </remarks>
    property Step: Double read FStep write FStep;
    /// <summary>
    /// Gets or sets the training loss at the specified step.
    /// </summary>
    /// <remarks>
    /// A double representing the loss value calculated from the training dataset.
    /// </remarks>
    property TrainLoss: Double read FTrainLoss write FTrainLoss;
    /// <summary>
    /// Gets or sets the mean token accuracy during training at the specified step.
    /// </summary>
    /// <remarks>
    /// A double representing the average accuracy of tokens processed during training.
    /// </remarks>
    property TrainMeanTokenAccuracy: Double read FTrainMeanTokenAccuracy write FTrainMeanTokenAccuracy;
    /// <summary>
    /// Gets or sets the validation loss at the specified step.
    /// </summary>
    /// <remarks>
    /// A double representing the loss value calculated from the validation dataset.
    /// </remarks>
    property ValidLoss: Double read FValidLoss write FValidLoss;
    /// <summary>
    /// Gets or sets the mean token accuracy during validation at the specified step.
    /// </summary>
    /// <remarks>
    /// A double representing the average accuracy of tokens processed during validation.
    /// </remarks>
    property ValidMeanTokenAccuracy: Double read FValidMeanTokenAccuracy write FValidMeanTokenAccuracy;
    /// <summary>
    /// Gets or sets the full validation loss at the specified step.
    /// </summary>
    /// <remarks>
    /// A double representing the loss value calculated from the entire validation dataset.
    /// </remarks>
    property FullValidLoss: Double read FFullValidLoss write FFullValidLoss;
    /// <summary>
    /// Gets or sets the mean token accuracy over the entire validation dataset at the specified step.
    /// </summary>
    /// <remarks>
    /// A double representing the average accuracy of tokens processed over the full validation dataset.
    /// </remarks>
    property FullValidMeanTokenAccuracy: Double read FFullValidMeanTokenAccuracy write FFullValidMeanTokenAccuracy;
  end;

  /// <summary>
  /// Represents a model checkpoint for a fine-tuning job in OpenAI's fine-tuning API.
  /// </summary>
  /// <remarks>
  /// This class contains details about a specific checkpoint, including the step number, metrics,
  /// and the fine-tuned model checkpoint identifier.
  /// </remarks>
  TJobCheckpoint = class
  private
    FId: string;
    [JsonNameAttribute('created_at')]
    FCreatedAt: Int64;
    [JsonNameAttribute('fine_tuned_model_checkpoint')]
    FFineTunedModelCheckpoint: string;
    [JsonNameAttribute('step_number')]
    FStepNumber: Int64;
    FMetrics: TMetrics;
    [JsonNameAttribute('fine_tuning_job_id')]
    FFineTuningJobId: string;
    FObject: string;
  private
    function GetCreatedAtAsString: string;
  public
    /// <summary>
    /// Gets or sets the unique identifier for the checkpoint.
    /// </summary>
    /// <remarks>
    /// A string representing the checkpoint's unique ID.
    /// </remarks>
    property Id: string read FId write FId;
    /// <summary>
    /// Gets or sets the timestamp when the checkpoint was created, in Unix format (seconds).
    /// </summary>
    /// <remarks>
    /// A 64-bit integer representing the checkpoint's creation time.
    /// </remarks>
    property CreatedAt: Int64 read FCreatedAt write FCreatedAt;
    /// <summary>
    /// Gets the creation timestamp of the checkpoint as a human-readable string.
    /// </summary>
    /// <remarks>
    /// A string representation of the checkpoint's creation timestamp.
    /// </remarks>
    property CreatedAtAsString: string read GetCreatedAtAsString;
    /// <summary>
    /// Gets or sets the identifier of the fine-tuned model checkpoint.
    /// </summary>
    /// <remarks>
    /// A string representing the name of the fine-tuned model checkpoint.
    /// </remarks>
    property FineTunedModelCheckpoint: string read FFineTunedModelCheckpoint write FFineTunedModelCheckpoint;
    /// <summary>
    /// Gets or sets the step number when this checkpoint was created.
    /// </summary>
    /// <remarks>
    /// A 64-bit integer representing the step number at which the checkpoint was generated.
    /// </remarks>
    property StepNumber: Int64 read FStepNumber write FStepNumber;
    /// <summary>
    /// Gets or sets the metrics recorded at the checkpoint's step.
    /// </summary>
    /// <remarks>
    /// An instance of <c>TMetrics</c> containing metrics such as training loss and accuracy.
    /// </remarks>
    property Metrics: TMetrics read FMetrics write FMetrics;
    /// <summary>
    /// Gets or sets the ID of the fine-tuning job associated with this checkpoint.
    /// </summary>
    /// <remarks>
    /// A string representing the ID of the fine-tuning job that generated this checkpoint.
    /// </remarks>
    property FineTuningJobId: string read FFineTuningJobId write FFineTuningJobId;
    /// <summary>
    /// Gets or sets the object type of the checkpoint.
    /// </summary>
    /// <remarks>
    /// A string that always has the value "fine_tuning.job.checkpoint".
    /// </remarks>
    property &Object: string read FObject write FObject;
    destructor Destroy; override;
  end;

  /// <summary>
  /// Represents a list of checkpoints for a fine-tuning job in OpenAI's fine-tuning API.
  /// </summary>
  /// <remarks>
  /// This class extends <c>TJobList</c> to provide a collection of checkpoints generated during
  /// a fine-tuning job. Each checkpoint includes details such as step number, metrics, and associated model data.
  /// </remarks>
  TJobCheckpoints = TJobList<TJobCheckpoint>;

  /// <summary>
  /// Manages asynchronous chat callBacks for a chat request using <c>TFineTuningJob</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynFineTuningJob</c> type extends the <c>TAsynParams&lt;TFineTuningJob&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking chat operations and is specifically tailored for scenarios where multiple choices from a chat model are required.
  /// </remarks>
  TAsynFineTuningJob = TAsynCallBack<TFineTuningJob>;

  /// <summary>
  /// Manages asynchronous chat callBacks for a chat request using <c>TFineTuningJobs</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynFineTuningJobs</c> type extends the <c>TAsynParams&lt;TFineTuningJobs&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking chat operations and is specifically tailored for scenarios where multiple choices from a chat model are required.
  /// </remarks>
  TAsynFineTuningJobs = TAsynCallBack<TFineTuningJobs>;

  /// <summary>
  /// Manages asynchronous chat callBacks for a chat request using <c>TJobEvents</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynJobEvents</c> type extends the <c>TAsynParams&lt;TJobEvents&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking chat operations and is specifically tailored for scenarios where multiple choices from a chat model are required.
  /// </remarks>
  TAsynJobEvents = TAsynCallBack<TJobEvents>;

  /// <summary>
  /// Manages asynchronous chat callBacks for a chat request using <c>TJobCheckpoints</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynFineJobCheckpoints</c> type extends the <c>TAsynParams&lt;TJobCheckpoints&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking chat operations and is specifically tailored for scenarios where multiple choices from a chat model are required.
  /// </remarks>
  TAsynJobCheckpoints = TAsynCallBack<TJobCheckpoints>;

  /// <summary>
  /// Provides methods to interact with the OpenAI fine-tuning API routes.
  /// </summary>
  /// <remarks>
  /// This class includes methods for creating, retrieving, listing, canceling, and managing fine-tuning jobs,
  /// as well as accessing associated events and checkpoints.
  /// </remarks>
  TFineTuningRoute = class(TGenAIRoute)
    /// <summary>
    /// Asynchronously creates a new fine-tuning job with the specified parameters.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure that sets the parameters for the fine-tuning job.
    /// </param>
    /// <param name="CallBacks">
    /// A function that defines the asynchronous callback behavior.
    /// </param>
    /// <remarks>
    /// This method initiates a fine-tuning job creation and invokes the provided callbacks when complete.
    /// </remarks>
    procedure AsynCreate(const ParamProc: TProc<TFineTuningJobParams>; const CallBacks: TFunc<TAsynFineTuningJob>);
    /// <summary>
    /// Asynchronously cancels a running fine-tuning job.
    /// </summary>
    /// <param name="JobId">
    /// The ID of the fine-tuning job to cancel.
    /// </param>
    /// <param name="CallBacks">
    /// A function that defines the asynchronous callback behavior.
    /// </param>
    /// <remarks>
    /// This method cancels a fine-tuning job and invokes the provided callbacks when complete.
    /// </remarks>
    procedure AsynCancel(const JobId: string; const CallBacks: TFunc<TAsynFineTuningJob>);
    /// <summary>
    /// Asynchronously retrieves a list of fine-tuning jobs.
    /// </summary>
    /// <param name="CallBacks">
    /// A function that defines the asynchronous callback behavior.
    /// </param>
    /// <remarks>
    /// This method retrieves all fine-tuning jobs associated with the account and invokes the callbacks when complete.
    /// </remarks>
    procedure AsynList(const CallBacks: TFunc<TAsynFineTuningJobs>); overload;
    /// <summary>
    /// Asynchronously retrieves a list of fine-tuning jobs with additional query parameters.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure to define query parameters such as pagination.
    /// </param>
    /// <param name="CallBacks">
    /// A function that defines the asynchronous callback behavior.
    /// </param>
    /// <remarks>
    /// This method retrieves fine-tuning jobs using the specified parameters and invokes the callbacks when complete.
    /// </remarks>
    procedure AsynList(const ParamProc: TProc<TFineTuningURLParams>; const CallBacks: TFunc<TAsynFineTuningJobs>); overload;
    /// <summary>
    /// Asynchronously retrieves events for a specific fine-tuning job.
    /// </summary>
    /// <param name="JobId">
    /// The ID of the fine-tuning job for which events are being retrieved.
    /// </param>
    /// <param name="CallBacks">
    /// A function that defines the asynchronous callback behavior.
    /// </param>
    /// <remarks>
    /// This method retrieves status updates and events for the specified fine-tuning job.
    /// </remarks>
    procedure AsynEvents(const JobId: string; const CallBacks: TFunc<TAsynJobEvents>); overload;
    /// <summary>
    /// Asynchronously retrieves events for a specific fine-tuning job with additional query parameters.
    /// </summary>
    /// <param name="JobId">
    /// The ID of the fine-tuning job for which events are being retrieved.
    /// </param>
    /// <param name="ParamProc">
    /// A procedure to define query parameters such as pagination.
    /// </param>
    /// <param name="CallBacks">
    /// A function that defines the asynchronous callback behavior.
    /// </param>
    /// <remarks>
    /// This method retrieves status updates and events for the specified fine-tuning job
    /// with additional parameters for customization.
    /// </remarks>
    procedure AsynEvents(const JobId: string; const ParamProc: TProc<TFineTuningURLParams>;
      const CallBacks: TFunc<TAsynJobEvents>); overload;
    /// <summary>
    /// Asynchronously retrieves checkpoints for a specific fine-tuning job.
    /// </summary>
    /// <param name="JobId">
    /// The ID of the fine-tuning job for which checkpoints are being retrieved.
    /// </param>
    /// <param name="CallBacks">
    /// A function that defines the asynchronous callback behavior.
    /// </param>
    /// <remarks>
    /// This method retrieves checkpoints generated during the specified fine-tuning job.
    /// </remarks>
    procedure AsynCheckpoints(const JobId: string; const CallBacks: TFunc<TAsynJobCheckpoints>); overload;
    /// <summary>
    /// Asynchronously retrieves checkpoints for a specific fine-tuning job with additional query parameters.
    /// </summary>
    /// <param name="JobId">
    /// The ID of the fine-tuning job for which checkpoints are being retrieved.
    /// </param>
    /// <param name="ParamProc">
    /// A procedure to define query parameters such as pagination.
    /// </param>
    /// <param name="CallBacks">
    /// A function that defines the asynchronous callback behavior.
    /// </param>
    /// <remarks>
    /// This method retrieves checkpoints generated during the specified fine-tuning job
    /// with additional parameters for customization.
    /// </remarks>
    procedure AsynCheckpoints(const JobId: string; const ParamProc: TProc<TFineTuningURLParams>;
      const CallBacks: TFunc<TAsynJobCheckpoints>); overload;
    /// <summary>
    /// Asynchronously retrieves details about a specific fine-tuning job.
    /// </summary>
    /// <param name="JobId">
    /// The ID of the fine-tuning job to retrieve.
    /// </param>
    /// <param name="CallBacks">
    /// A function that defines the asynchronous callback behavior.
    /// </param>
    /// <remarks>
    /// This method retrieves details about the specified fine-tuning job and invokes the callbacks when complete.
    /// </remarks>
    procedure AsynRetrieve(const JobId: string; const CallBacks: TFunc<TAsynFineTuningJob>);
    /// <summary>
    /// Creates a new fine-tuning job with the specified parameters.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure that sets the parameters for the fine-tuning job.
    /// </param>
    /// <returns>
    /// An instance of <c>TFineTuningJob</c> containing the details of the created job.
    /// </returns>
    /// <remarks>
    /// This method synchronously creates a fine-tuning job and returns the job details.
    /// </remarks>
    function Create(const ParamProc: TProc<TFineTuningJobParams>): TFineTuningJob;
    /// <summary>
    /// Cancels a running fine-tuning job.
    /// </summary>
    /// <param name="JobId">
    /// The ID of the fine-tuning job to cancel.
    /// </param>
    /// <returns>
    /// An instance of <c>TFineTuningJob</c> with updated status after cancellation.
    /// </returns>
    /// <remarks>
    /// This method synchronously cancels the specified fine-tuning job.
    /// </remarks>
    function Cancel(const JobId: string): TFineTuningJob;
    /// <summary>
    /// Retrieves a list of fine-tuning jobs.
    /// </summary>
    /// <returns>
    /// An instance of <c>TFineTuningJobs</c> containing the list of fine-tuning jobs.
    /// </returns>
    /// <remarks>
    /// This method synchronously retrieves all fine-tuning jobs associated with the account.
    /// </remarks>
    function List: TFineTuningJobs; overload;
    /// <summary>
    /// Retrieves a list of fine-tuning jobs with additional query parameters.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure to define query parameters such as pagination.
    /// </param>
    /// <returns>
    /// An instance of <c>TFineTuningJobs</c> containing the list of fine-tuning jobs.
    /// </returns>
    /// <remarks>
    /// This method synchronously retrieves fine-tuning jobs using the specified parameters.
    /// </remarks>
    function List(const ParamProc: TProc<TFineTuningURLParams>): TFineTuningJobs; overload;
    /// <summary>
    /// Retrieves events for a specific fine-tuning job.
    /// </summary>
    /// <param name="JobId">
    /// The ID of the fine-tuning job for which events are being retrieved.
    /// </param>
    /// <returns>
    /// An instance of <c>TJobEvents</c> containing the events associated with the job.
    /// </returns>
    /// <remarks>
    /// This method synchronously retrieves status updates and events for the specified fine-tuning job.
    /// </remarks>
    function Events(const JobId: string): TJobEvents; overload;
    /// <summary>
    /// Retrieves events for a specific fine-tuning job with additional query parameters.
    /// </summary>
    /// <param name="JobId">
    /// The ID of the fine-tuning job for which events are being retrieved.
    /// </param>
    /// <param name="ParamProc">
    /// A procedure to define query parameters such as pagination.
    /// </param>
    /// <returns>
    /// An instance of <c>TJobEvents</c> containing the events associated with the job.
    /// </returns>
    /// <remarks>
    /// This method synchronously retrieves status updates and events for the specified fine-tuning job
    /// with additional parameters for customization.
    /// </remarks>
    function Events(const JobId: string; const ParamProc: TProc<TFineTuningURLParams>): TJobEvents; overload;
    /// <summary>
    /// Retrieves checkpoints for a specific fine-tuning job.
    /// </summary>
    /// <param name="JobId">
    /// The ID of the fine-tuning job for which checkpoints are being retrieved.
    /// </param>
    /// <returns>
    /// An instance of <c>TJobCheckpoints</c> containing the checkpoints generated during the job.
    /// </returns>
    /// <remarks>
    /// This method synchronously retrieves checkpoints for the specified fine-tuning job.
    /// </remarks>
    function Checkpoints(const JobId: string): TJobCheckpoints; overload;
    /// <summary>
    /// Retrieves checkpoints for a specific fine-tuning job with additional query parameters.
    /// </summary>
    /// <param name="JobId">
    /// The ID of the fine-tuning job for which checkpoints are being retrieved.
    /// </param>
    /// <param name="ParamProc">
    /// A procedure to define query parameters such as pagination.
    /// </param>
    /// <returns>
    /// An instance of <c>TJobCheckpoints</c> containing the checkpoints generated during the job.
    /// </returns>
    /// <remarks>
    /// This method synchronously retrieves checkpoints for the specified fine-tuning job
    /// with additional parameters for customization.
    /// </remarks>
    function Checkpoints(const JobId: string; const ParamProc: TProc<TFineTuningURLParams>): TJobCheckpoints; overload;
    /// <summary>
    /// Retrieves details about a specific fine-tuning job.
    /// </summary>
    /// <param name="JobId">
    /// The ID of the fine-tuning job to retrieve.
    /// </param>
    /// <returns>
    /// An instance of <c>TFineTuningJob</c> containing the details of the job.
    /// </returns>
    /// <remarks>
    /// This method synchronously retrieves details about the specified fine-tuning job.
    /// </remarks>
    function Retrieve(const JobId: string): TFineTuningJob;
  end;

implementation

{ TFineTuningJobParams }

function TFineTuningJobParams.Integrations(
  const Value: TArray<TJobIntegrationParams>): TFineTuningJobParams;
begin
  var JSONArray := TJSONArray.Create;
  for var Item in Value do
    JSONArray.Add(Item.Detach);
  Result := TFineTuningJobParams(Add('integrations', JSONArray));
end;

function TFineTuningJobParams.Method(
  const Value: TJobMethodParams): TFineTuningJobParams;
begin
  Result := TFineTuningJobParams(Add('method', Value.Detach));
end;

function TFineTuningJobParams.Method(const AType: TJobMethodType;
  const Value: THyperparametersParams): TFineTuningJobParams;
begin
  case AType of
    TJobMethodType.supervised:
      Result := Method(TJobMethodParams.NewSupervised(Value));

    TJobMethodType.dpo:
      Result := Method(TJobMethodParams.NewDpo(Value));

    else
      Result := Self;
  end;
end;

function TFineTuningJobParams.Model(const Value: string): TFineTuningJobParams;
begin
  Result := TFineTuningJobParams(Add('model', Value));
end;

function TFineTuningJobParams.Seed(const Value: Integer): TFineTuningJobParams;
begin
  Result := TFineTuningJobParams(Add('seed', Value));
end;

function TFineTuningJobParams.Suffix(const Value: string): TFineTuningJobParams;
begin
  Result := TFineTuningJobParams(Add('suffix', Value));
end;

function TFineTuningJobParams.TrainingFile(
  const Value: string): TFineTuningJobParams;
begin
  Result := TFineTuningJobParams(Add('training_file', Value));
end;

function TFineTuningJobParams.ValidationFile(
  const Value: string): TFineTuningJobParams;
begin
  Result := TFineTuningJobParams(Add('validation_file', Value));
end;

{ TJobIntegrationParams }

function TJobIntegrationParams.&Type(const Value: string): TJobIntegrationParams;
begin
  Result := TJobIntegrationParams(Add('type', Value));
end;

function TJobIntegrationParams.Wandb(const Value: TWandbParams): TJobIntegrationParams;
begin
  Result := TJobIntegrationParams(Add('wandb', Value.Detach));
end;

function TJobIntegrationParams.Wandb(const Value: TJSONObject): TJobIntegrationParams;
begin
  Result := TJobIntegrationParams(Add('wandb', Value));
end;

{ TWandbParams }

function TWandbParams.Entity(const Value: string): TWandbParams;
begin
  Result := TWandbParams(Add('entity', Value));
end;

function TWandbParams.Name(const Value: string): TWandbParams;
begin
  Result := TWandbParams(Add('name', Value));
end;

class function TWandbParams.New(const Project, Name, Entity: string;
  const Tags: TArray<string>): TWandbParams;
begin
  Result := TWandbParams.Create.Project(Project).Name(Name).Entity(Entity).Tags(Tags);
end;

function TWandbParams.Project(const Value: string): TWandbParams;
begin
  Result := TWandbParams(Add('project', Value));
end;

function TWandbParams.Tags(const Value: TArray<string>): TWandbParams;
begin
  Result := TWandbParams(Add('tags', Value));
end;

{ TJobMethodParams }

function TJobMethodParams.&Type(const Value: string): TJobMethodParams;
begin
  Result := TJobMethodParams(Add('type', TJobMethodType.Create(Value).ToString));
end;

function TJobMethodParams.Dpo(const Value: TDpoMethodParams): TJobMethodParams;
begin
  Result := TJobMethodParams(Add('dpo', Value.Detach));
end;

class function TJobMethodParams.NewDpo(const Value: THyperparametersParams): TJobMethodParams;
begin
  Result := TJobMethodParams.Create.&Type(TJobMethodType.dpo).Dpo(TDpoMethodParams.New(Value));
end;

class function TJobMethodParams.NewSupervised(
  const Value: THyperparametersParams): TJobMethodParams;
begin
  Result := TJobMethodParams.Create.&Type(TJobMethodType.supervised).Supervised(TSupervisedMethodParams.New(Value));
end;

function TJobMethodParams.Supervised(const Value: TSupervisedMethodParams): TJobMethodParams;
begin
  Result := TJobMethodParams(Add('supervised', Value.Detach));
end;

function TJobMethodParams.&Type(const Value: TJobMethodType): TJobMethodParams;
begin
  Result := TJobMethodParams(Add('type', Value.ToString));
end;

{ THyperparametersParams }

function THyperparametersParams.BatchSize(const Value: Integer): THyperparametersParams;
begin
  Result := THyperparametersParams(Add('batch_size', Value));
end;

function THyperparametersParams.Beta(const Value: Double): THyperparametersParams;
begin
  Result := THyperparametersParams(Add('type', Value));
end;

function THyperparametersParams.LearningRateMultiplier(
  const Value: Double): THyperparametersParams;
begin
  Result := THyperparametersParams(Add('learning_rate_multiplier', Value));
end;

function THyperparametersParams.NEpochs(const Value: Integer): THyperparametersParams;
begin
  Result := THyperparametersParams(Add('n_epochs', Value));
end;

{ TSupervisedMethodParams }

function TSupervisedMethodParams.Hyperparameters(
  const Value: THyperparametersParams): TSupervisedMethodParams;
begin
  Result := TSupervisedMethodParams(Add('hyperparameters', Value.Detach));
end;

class function TSupervisedMethodParams.New(
  const Value: THyperparametersParams): TSupervisedMethodParams;
begin
  Result := TSupervisedMethodParams.Create.Hyperparameters(Value);
end;

{ TDpoMethodParams }

function TDpoMethodParams.Hyperparameters(const Value: THyperparametersParams): TDpoMethodParams;
begin
  Result := TDpoMethodParams(Add('hyperparameters', Value.Detach));
end;

class function TDpoMethodParams.New(const Value: THyperparametersParams): TDpoMethodParams;
begin
  Result := TDpoMethodParams.Create.Hyperparameters(Value);
end;

{ TFineTuningJob }

destructor TFineTuningJob.Destroy;
begin
  if Assigned(FError) then
    FError.Free;
  if Assigned(FHyperparameters) then
    FHyperparameters.Free;
  for var Item in FIntegrations do
    Item.Free;
  if Assigned(FMethod) then
    FMethod.Free;
  inherited;
end;

function TFineTuningJob.GetCreatedAtAsString: string;
begin
  Result := TimestampToString(CreatedAt, UTCtimestamp);
end;

function TFineTuningJob.GetEstimatedFinishAsString: string;
begin
  Result := TimestampToString(EstimatedFinish, UTCtimestamp);
end;

function TFineTuningJob.GetFinishedAtAsString: string;
begin
  Result := TimestampToString(FinishedAt, UTCtimestamp);
end;

{ FineTuningJobIntegration }

destructor FineTuningJobIntegration.Destroy;
begin
  if Assigned(FWandb) then
    FWandb.Free;
  inherited;
end;

{ TSupervised }

destructor TSupervised.Destroy;
begin
  if Assigned(FHyperparameters) then
    FHyperparameters.Free;
  inherited;
end;

{ TDpo }

destructor TDpo.Destroy;
begin
  if Assigned(FHyperparameters) then
    FHyperparameters.Free;
  inherited;
end;

{ TFineTuningMethod }

destructor TFineTuningMethod.Destroy;
begin
  if Assigned(FSupervised) then
    FSupervised.Free;
  if Assigned(FDpo) then
    FDpo.Free;
  inherited;
end;

{ TFineTuningRoute }

procedure TFineTuningRoute.AsynCancel(const JobId: string;
  const CallBacks: TFunc<TAsynFineTuningJob>);
begin
  with TAsynCallBackExec<TAsynFineTuningJob, TFineTuningJob>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TFineTuningJob
      begin
        Result := Self.Cancel(JobId);
      end);
  finally
    Free;
  end;
end;

procedure TFineTuningRoute.AsynCheckpoints(const JobId: string;
  const CallBacks: TFunc<TAsynJobCheckpoints>);
begin
  with TAsynCallBackExec<TAsynJobCheckpoints, TJobCheckpoints>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TJobCheckpoints
      begin
        Result := Self.Checkpoints(JobId);
      end);
  finally
    Free;
  end;
end;

procedure TFineTuningRoute.AsynCheckpoints(const JobId: string;
  const ParamProc: TProc<TFineTuningURLParams>;
  const CallBacks: TFunc<TAsynJobCheckpoints>);
begin
  with TAsynCallBackExec<TAsynJobCheckpoints, TJobCheckpoints>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TJobCheckpoints
      begin
        Result := Self.Checkpoints(JobId, ParamProc);
      end);
  finally
    Free;
  end;
end;

procedure TFineTuningRoute.AsynCreate(
  const ParamProc: TProc<TFineTuningJobParams>;
  const CallBacks: TFunc<TAsynFineTuningJob>);
begin
  with TAsynCallBackExec<TAsynFineTuningJob, TFineTuningJob>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TFineTuningJob
      begin
        Result := Self.Create(ParamProc);
      end);
  finally
    Free;
  end;
end;

procedure TFineTuningRoute.AsynEvents(const JobId: string;
  const CallBacks: TFunc<TAsynJobEvents>);
begin
  with TAsynCallBackExec<TAsynJobEvents, TJobEvents>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TJobEvents
      begin
        Result := Self.Events(JobId);
      end);
  finally
    Free;
  end;
end;

procedure TFineTuningRoute.AsynEvents(const JobId: string;
  const ParamProc: TProc<TFineTuningURLParams>;
  const CallBacks: TFunc<TAsynJobEvents>);
begin
  with TAsynCallBackExec<TAsynJobEvents, TJobEvents>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TJobEvents
      begin
        Result := Self.Events(JobId, ParamProc);
      end);
  finally
    Free;
  end;
end;

procedure TFineTuningRoute.AsynList(
  const CallBacks: TFunc<TAsynFineTuningJobs>);
begin
  with TAsynCallBackExec<TAsynFineTuningJobs, TFineTuningJobs>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TFineTuningJobs
      begin
        Result := Self.List;
      end);
  finally
    Free;
  end;
end;

procedure TFineTuningRoute.AsynList(
  const ParamProc: TProc<TFineTuningURLParams>;
  const CallBacks: TFunc<TAsynFineTuningJobs>);
begin
  with TAsynCallBackExec<TAsynFineTuningJobs, TFineTuningJobs>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TFineTuningJobs
      begin
        Result := Self.List(ParamProc);
      end);
  finally
    Free;
  end;
end;

procedure TFineTuningRoute.AsynRetrieve(const JobId: string;
  const CallBacks: TFunc<TAsynFineTuningJob>);
begin
  with TAsynCallBackExec<TAsynFineTuningJob, TFineTuningJob>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TFineTuningJob
      begin
        Result := Self.Retrieve(JobId);
      end);
  finally
    Free;
  end;
end;

function TFineTuningRoute.Cancel(const JobId: string): TFineTuningJob;
begin
  Result := API.Post<TFineTuningJob>('fine_tuning/jobs/' + JobId + '/cancel');
end;

function TFineTuningRoute.Checkpoints(const JobId: string): TJobCheckpoints;
begin
  Result := API.Get<TJobCheckpoints>('jobs/' + JobId + '/checkpoints');
end;

function TFineTuningRoute.Checkpoints(const JobId: string;
  const ParamProc: TProc<TFineTuningURLParams>): TJobCheckpoints;
begin
  Result := API.Get<TJobCheckpoints, TFineTuningURLParams>('jobs/' + JobId + '/checkpoints', ParamProc);
end;

function TFineTuningRoute.Create(
  const ParamProc: TProc<TFineTuningJobParams>): TFineTuningJob;
begin
  Result := API.Post<TFineTuningJob, TFineTuningJobParams>('fine_tuning/jobs', ParamProc);
end;

function TFineTuningRoute.Events(const JobId: string): TJobEvents;
begin
  Result := API.Get<TJobEvents>('jobs/'+ JobId + '/events');
end;

function TFineTuningRoute.Events(const JobId: string;
  const ParamProc: TProc<TFineTuningURLParams>): TJobEvents;
begin
  Result := API.Get<TJobEvents, TFineTuningURLParams>('jobs/'+ JobId + '/events', ParamProc);
end;

function TFineTuningRoute.List: TFineTuningJobs;
begin
  Result := API.Get<TFineTuningJobs>('fine_tuning/jobs');
end;

function TFineTuningRoute.List(
  const ParamProc: TProc<TFineTuningURLParams>): TFineTuningJobs;
begin
  Result := API.Get<TFineTuningJobs, TFineTuningURLParams>('fine_tuning/jobs', ParamProc);
end;

function TFineTuningRoute.Retrieve(const JobId: string): TFineTuningJob;
begin
  Result := API.Get<TFineTuningJob>('fine_tuning/jobs/' + JobId);
end;

{ TFineTuningURLParams }

function TFineTuningURLParams.After(const Value: string): TFineTuningURLParams;
begin
  Result := TFineTuningURLParams(Add('after', Value));
end;

function TFineTuningURLParams.Limit(const Value: Int64): TFineTuningURLParams;
begin
  Result := TFineTuningURLParams(Add('limit', Value));
end;

{ TJobEvent }

destructor TJobEvent.Destroy;
begin
  if Assigned(FData) then
    FData.Free;
  inherited;
end;

function TJobEvent.GetCreatedAtAsString: string;
begin
  Result := TimestampToString(CreatedAt, UTCtimestamp);
end;

{ TJobCheckpoint }

destructor TJobCheckpoint.Destroy;
begin
  if Assigned(FMetrics) then
    FMetrics.Free;
  inherited;
end;

function TJobCheckpoint.GetCreatedAtAsString: string;
begin
  Result := TimestampToString(CreatedAt, UTCtimestamp);
end;

{ TJobList<T> }

destructor TJobList<T>.Destroy;
begin
  for var Item in FData do
    Item.Free;
  inherited;
end;

end.
