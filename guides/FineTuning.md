# Fine tuning

- [Fine tuning create](#fine-tuning-create)
    - [Preparing your dataset](#preparing-your-dataset)
    - [Upload dataset](#upload-dataset)
    - [Create the fine-tuning job](#create-the-fine-tuning-job)
- [Fine tuning list](#fine-tuning-list)
- [Fine tuning cancel](#fine-tuning-cancel)
- [Fine tuning events](#fine-tuning-events)
- [Fine tuning check point](#fine-tuning-check-point)
- [Fine tuning retrieve](#fine-tuning-retrieve)
- [Difference Between Supervised and DPO](#difference-between-supervised-and-dpo)
    - [SUPERVISED Fine-Tuning Method](#supervised-fine-tuning-method)
    - [DPO (Direct Preference Optimization) Method](#dpo-direct-preference-optimization-method)
    - [Choosing Between the Two Methods](#choosing-between-the-two-methods)
    - [Recommendations](#recommendations)
___

Handle fine-tuning tasks to customize a model according to your specific training dataset. Relevant guide: [Model fine-tuning](https://platform.openai.com/docs/guides/fine-tuning).

After determining that fine-tuning is the appropriate approach (meaning you’ve already optimized your prompt to its full potential and identified remaining issues with the model), the next step is to prepare the training data. You’ll need to create a varied collection of sample conversations that resemble the types of interactions the model will handle during inference in production.

<br/>

## Fine tuning create

### Preparing your dataset

Each data sample should follow the format used by the ***Chat Completions API***, consisting of a list of messages where each message includes a role, content, and an optional name. Some of these training examples should specifically address situations where the current model's responses are inadequate, with the assistant messages in the dataset reflecting the ideal outcomes you want the model to generate.

Example format

```JSON
{"messages": [{"role": "system", "content": "Marv is a factual chatbot that is also sarcastic."}, {"role": "user", "content": "What's the capital of France?"}, {"role": "assistant", "content": "Paris, as if everyone doesn't know that already."}]}
{"messages": [{"role": "system", "content": "Marv is a factual chatbot that is also sarcastic."}, {"role": "user", "content": "Who wrote 'Romeo and Juliet'?"}, {"role": "assistant", "content": "Oh, just some guy named William Shakespeare. Ever heard of him?"}]}
{"messages": [{"role": "system", "content": "Marv is a factual chatbot that is also sarcastic."}, {"role": "user", "content": "How far is the Moon from Earth?"}, {"role": "assistant", "content": "Around 384,400 kilometers. Give or take a few, like that really matters."}]}
```

Multi-turn chat examples

```JSON
{"messages": [{"role": "system", "content": "Marv is a factual chatbot that is also sarcastic."}, {"role": "user", "content": "What's the capital of France?"}, {"role": "assistant", "content": "Paris", "weight": 0}, {"role": "user", "content": "Can you be more sarcastic?"}, {"role": "assistant", "content": "Paris, as if everyone doesn't know that already.", "weight": 1}]}
{"messages": [{"role": "system", "content": "Marv is a factual chatbot that is also sarcastic."}, {"role": "user", "content": "Who wrote 'Romeo and Juliet'?"}, {"role": "assistant", "content": "William Shakespeare", "weight": 0}, {"role": "user", "content": "Can you be more sarcastic?"}, {"role": "assistant", "content": "Oh, just some guy named William Shakespeare. Ever heard of him?", "weight": 1}]}
{"messages": [{"role": "system", "content": "Marv is a factual chatbot that is also sarcastic."}, {"role": "user", "content": "How far is the Moon from Earth?"}, {"role": "assistant", "content": "384,400 kilometers", "weight": 0}, {"role": "user", "content": "Can you be more sarcastic?"}, {"role": "assistant", "content": "Around 384,400 kilometers. Give or take a few, like that really matters.", "weight": 1}]}
```

To fine-tune a model, you need to provide at least 10 examples. Generally, noticeable improvements can be observed with fine-tuning using 50 to 100 training examples, especially with gpt-4o-mini and gpt-3.5-turbo. However, the appropriate number of examples can vary significantly depending on the specific use case.

>[!NOTE]
> After collecting the initial dataset, it is recommended to split it into a training set and a test set. When submitting a fine-tuning task with these two sets, statistics will be provided throughout the training process for both files. This information will serve as the first indicator of the model’s improvement. Additionally, creating a test set from the start will allow you to assess the model’s performance after training by generating samples from the test set.

<br/>

### Upload dataset

Once the training and test files have been created, they must be uploaded using the File API. The purpose property should be set to `finetune` (refer to the enumerated type `TFilesPurpose`). Please see the [example](Files.md#File-upload) above for detailed steps on uploading the files.

<br>

### Create the fine-tuning job

```pascal
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  //Synchronous example
  var Value := Client.FineTuning.Create(
    procedure (Params: TFineTuningJobParams)
    begin
      Params.TrainingFile('...Id of file training...');
      Params.ValidationFile('...Id of file test...');
      Params.Model('gpt-4o-2024-08-06');
      //when use DPO, add
      //Params.Method(TJobMethodParams.NewDpo(THyperparametersParams.Create.Beta(0.1)));
    end);
  try
    TutorialHub.JSONResponse := Value.JSONResponse;
    //display the ID of the fine-tuning job
    Display(TutorialHub, Value.Id);
  finally
    Value.Free;
  end;
```

e.g. return values
```JSON
{
  "object": "fine_tuning.job",
  "id": "ftjob-abc123",
  "model": "gpt-4o-mini-2024-07-18",
  "created_at": 1721764800,
  "fine_tuned_model": null,
  "organization_id": "org-123",
  "result_files": [],
  "status": "queued",
  "validation_file": null,
  "training_file": "file-abc123",
  "method": {
    "type": "supervised",
    "supervised": {
      "hyperparameters": {
        "batch_size": "auto",
        "learning_rate_multiplier": "auto",
        "n_epochs": "auto",
      }
    }
  }
}
```

<br/>

## Fine tuning list

List your organization's fine-tuning jobs. Refer to [parameters documentation](https://platform.openai.com/docs/api-reference/fine-tuning/list).

```pascal
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  //Asynchronous example
  Client.FineTuning.AsynList(
    procedure (Params: TUrlPaginationParams)
    begin
      Params.Limit(1);
    end,
    function : TAsynFineTuningJobs
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess :=
        procedure (Sender: TObject; Value: TFineTuningJobs)
        begin
          TutorialHub.JSONResponse := Value.JSONResponse;
          for var Item in Value.Data do
            Display(TutorialHub, Item.Id);
          Display(TutorialHub, F('hasmore',VarToStr(Value.HasMore)));
        end;
      Result.OnError := Display;
    end);

  //Synchronous example
//  var Value := Client.FineTuning.List(
//    procedure (Params: TUrlPaginationParams)
//    begin
//      Params.Limit(1);
//    end);
//  try
//    TutorialHub.JSONResponse := Value.JSONResponse;
//    for var Item in Value.Data do
//      Display(TutorialHub, Item.Id);
//    Display(TutorialHub, F('hasmore',VarToStr(Value.HasMore)));
//  finally
//    Value.Free;
//  end;
```

<br/>

## Fine tuning cancel

Immediately cancel a fine-tune job.

```pascal
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.Id := '...Id of fine-tuning job';

  //Synchronous example
  var Value := Client.FineTuning.Cancel(TutorialHub.Id);
  try
    TutorialHub.JSONResponse := Value.JSONResponse;
    Display(TutorialHub, Value.Status.ToString);
  finally
    Value.Free;
  end;
```

<br/>

## Fine tuning events

Get status updates for a fine-tuning job.

```pascal
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.Id := '...Id of fine-tuning job';

  //Synchronous example
  var Value := Client.FineTuning.Events(TutorialHub.Id);
  try
    TutorialHub.JSONResponse := Value.JSONResponse;
    for var Item in value.Data do
      Display(TutorialHub, [Item.&Object,
        F('id', Item.Id),
        F('message', Item.Message)]);
  finally
    Value.Free;
  end;
```

e.g. return values
```JSON
{
  "object": "list",
  "data": [
    {
      "object": "fine_tuning.job.event",
      "id": "ft-event-ddTJfwuMVpfLXseO0Am0Gqjm",
      "created_at": 1721764800,
      "level": "info",
      "message": "Fine tuning job successfully completed",
      "data": null,
      "type": "message"
    },
    {
      "object": "fine_tuning.job.event",
      "id": "ft-event-tyiGuB72evQncpH87xe505Sv",
      "created_at": 1721764800,
      "level": "info",
      "message": "New fine-tuned model created: ft:gpt-4o-mini:openai::7p4lURel",
      "data": null,
      "type": "message"
    }
  ],
  "has_more": true
}  
```

<br/>

## Fine tuning check point

List checkpoints for a fine-tuning job.

```pascal
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.Id := '...Id of fine-tuning job';

  //Synchronous example
  var Value := Client.FineTuning.Checkpoints(TutorialHub.Id);
  try
    TutorialHub.JSONResponse := Value.JSONResponse;
    for var Item in value.Data do
      Display(TutorialHub, [Item.&Object,
        F('id', Item.Id),
        F('step_number', Item.StepNumber.ToString)]);
  finally
    Value.Free;
  end;
```

e.g. return values
```JSON
{
  "object": "list"
  "data": [
    {
      "object": "fine_tuning.job.checkpoint",
      "id": "ftckpt_zc4Q7MP6XxulcVzj4MZdwsAB",
      "created_at": 1721764867,
      "fine_tuned_model_checkpoint": "ft:gpt-4o-mini-2024-07-18:my-org:custom-suffix:96olL566:ckpt-step-2000",
      "metrics": {
        "full_valid_loss": 0.134,
        "full_valid_mean_token_accuracy": 0.874
      },
      "fine_tuning_job_id": "ftjob-abc123",
      "step_number": 2000,
    },
    {
      "object": "fine_tuning.job.checkpoint",
      "id": "ftckpt_enQCFmOTGj3syEpYVhBRLTSy",
      "created_at": 1721764800,
      "fine_tuned_model_checkpoint": "ft:gpt-4o-mini-2024-07-18:my-org:custom-suffix:7q8mpxmy:ckpt-step-1000",
      "metrics": {
        "full_valid_loss": 0.167,
        "full_valid_mean_token_accuracy": 0.781
      },
      "fine_tuning_job_id": "ftjob-abc123",
      "step_number": 1000,
    },
  ],
  "first_id": "ftckpt_zc4Q7MP6XxulcVzj4MZdwsAB",
  "last_id": "ftckpt_enQCFmOTGj3syEpYVhBRLTSy",
  "has_more": true
}  
```
<br/>

## Fine tuning retrieve

Get info about a fine-tuning job.

```pascal
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.Id := '...Id of fine-tuning job';

  //Synchronous example
  var Value := Client.FineTuning.Retrieve(TutorialHub.Id);
  try
    TutorialHub.JSONResponse := Value.JSONResponse;
    Display(TutorialHub, [Value.&Object,
        F('id', Value.Id),
        F('status', Value.Status.ToString)]);
  finally
    Value.Free;
  end;
```

<br/>

## Difference Between Supervised and DPO

### SUPERVISED Fine-Tuning Method

The supervised method  is a classic fine-tuning approach  where the model is trained on a labeled dataset to learn  how to map specific inputs  (prompts)  to target outputs  (ideal responses).

**Key Features:** 
   - The model learns solely from the examples provided in the training data.
   - Each training example contains a prompt and a corresponding target response.
   - The goal is to minimize the error (loss) between the model's output and the target response in the training data.

**Advantages:**
   - Easy to implement: Requires only a well-annotated training dataset.
   - Ideal for specific tasks: Works well for well-defined tasks where high-quality labeled data is
     available (e.g., classification, translation, summarization).

**Limitations:**
   - Can be prone to overfitting if the training data is not diverse enough.
   - Does not account for human preferences or comparisons between multiple potential responses.

**When to use it:**
   - When you have a labeled dataset containing specific examples of what the model should produce.
   - When you aim to train the model  for a specific, well-defined task  (e.g., answering questions or generating structured summaries).

<br/>

### DPO (Direct Preference Optimization) Method


he DPO method is a more advanced approach  that incorporates human preferences into the training process. Instead  of  focusing  on  "ideal"  responses,  this method  uses  pairs of responses to indicate which one is preferred (based on human or automated evaluations).

**Key Features:**
   - The dataset includes comparisons between two responses generated for the same prompt, with one response marked as preferred.
   - The model is optimized to replicate these preferences.
   - This method is often used to fine-tune a model to align its responses with subjective or human preferences.

**Advantages:**
   - Captures human preferences: Improves response quality based on subjective  or context-specific criteria.
   - Resilient to data  uncertainty:  Useful when  traditional  labeled  data  is  unavailable, but preference judgments are feasible.

**Limitations:**
   - Requires a dataset with comparison data, which can be costly or time-consuming to create.
   - More complex to implement and train than the supervised method.

**When to use it:**
   - When you want the model to produce responses that reflect subjective or human preferences, for example:
       - Generating more fluent or engaging text.
       - Aligning responses  with specific criteria  (e.g., avoiding  bias  or  generating  content tailored to a specific domain).
   - When  you  have a dataset containing  response  comparisons  (e.g., human ratings  of response quality between two options).

<br/>

### Choosing Between the Two Methods


 |    Criteria       |         Supervised               |                 DPO                      |
 | --- | --- |--- |
 | Data Availability                           | Requires data with clear target outputs  | Requires comparisons between responses  (preferences)  |
 | Implementation  Complexity   | Simpler                                                               | More complex, needs well-collected preferences      |
 | Human Alignment                       | Limited                                                               | Strong alignment due to human preference incorporation |
 | Primary Use Cases                      | Well-defined, objective tasks                      | Subjective tasks or those requiring fine-tuned alignment  |
 
<br/>

### Recommendations

- **Use the supervised method if:**
    - You have a  labeled  dataset  with ideal responses  for your prompts.   
    - Your task is  well-defined and does  not require subjective adjustments  or alignment with human preferences.

- **Use the DPO method if:**
    - You want the model to generate responses that align with human or specific subjective preferences.
    - You have a dataset with comparisons between multiple responses.
    - You  aim  to  improve  response  quality  for  creative  or  open-ended  tasks  where preferences  are  key.

In summary, the  supervised method  is ideal for  well-defined tasks, while  DPO is more suitable when human preferences or subjective criteria are central to your project.
