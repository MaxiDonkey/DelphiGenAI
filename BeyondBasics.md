# Beyond the Basics Advanced Usage

- [Uploads](#Uploads)
    - [Upload create](#upload-create)
    - [Upload cancel](#upload-cancel)
    - [Upload add part](#upload-add-part)
    - [Upload complete](#upload-complete)
- [Batch](#batch)
    - [Batch create](#batch-create)
    - [Batch List](#batch-List)
    - [Batch retrieve](#batch-retrieve)
    - [Batch cancel](#batch-cancel)
    - [Batch output viewer](#batch-output-viewer)
- [Fine tuning](#fine-tuning)
    - [Fine tuning create](#fine-tuning-create)
    - [Fine tuning list](#fine-tuning-list)
    - [Fine tuning cancel](#fine-tuning-cancel)
    - [Fine tuning events](#fine-tuning-events)
    - [Fine tuning check point](#fine-tuning-check-point)
    - [Fine tuning retrieve](#fine-tuning-retrieve)
    - [Difference Between Supervised and DPO](#difference-Between-Supervised-and-DPO)
- [Vector store](#vector-store)
    - [Vector store create](#vector-store-create) 
    - [Vector store list](#vector-store-list) 
    - [Vector store retrieve](#vector-store-retrieve) 
    - [Vector store modify](#vector-store-modify) 
    - [Vector store delete](#vector-store-delete) 
- [Vector store files](#vector-store-files)
    - [Vsf create](#vsf-create)
    - [Vsf list](#vsf-list)
    - [Vsf retrieve](#vsf-retrieve)
    - [Vsf delete](#vsf-delete)
- [Vector store batches](#vector-store-batches)
    - [Vsb create](#vsb-create)
    - [Vsb list](#vsb-list)
    - [Vsb retrieve](#vsb-retrieve)
    - [Vsb cancel](#vsb-cancel)
- [Assistants](#assistants)
    - [Create assistant](#create-assistant)
    - [List assistants](#list-assistants)
    - [Retrieve assistant](#retrieve-assistant)
    - [Modify assistant](#modify-assistant)
    - [Delete assistant](#delete-assistant)
- [Threads](#threads)
    - [Create thread](#create-thread)
    - [Retrieve thread](#retrieve-thread)
    - [Modify thread](#modify-thread)
    - [Delete thread](#delete-thread)
- [Messages](#messages)
    - [Create message](#create-message)
    - [List messages](#list-messages)
    - [Retrieve message](#retrieve-message)
    - [Modify message](#modify-message)
    - [Delete message](#delete-message)
- [Runs](#runs)
    - [Create run](#create-run)
    - [Create thread and run](#create-thread-and-run)
    - [List runs](#list-runs)
    - [Retrieve run](#retrieve-run)
    - [Modify run](#modify-run)
    - [Submit tool outputs](#submit-tool-outputs)
    - [Cancel run](#cancel-run)
- [Runs steps](#runs-steps)
    - [List run steps](#list-run-steps)
    - [Retrieve run steps](#retrieve-run-steps)
- [Model distilation](#model-distilation)
___

## Uploads

Allows you to upload large files in multiple parts.

<br/>

### Upload create

An intermediate [Upload](https://platform.openai.com/docs/api-reference/uploads/object) object is created, allowing you to attach multiple [parts](https://platform.openai.com/docs/api-reference/uploads/part-object). The maximum size for an Upload is 8 GB, and it will automatically expire one hour after creation.

Once the Upload is finalized, a [File](https://platform.openai.com/docs/api-reference/files/object) object is generated, incorporating all the uploaded parts. This File object can then be used seamlessly across our platform, functioning like any regular file.

For certain `purposes`, specifying the correct `mime_type` is essential. Be sure to consult the documentation to identify the supported MIME types that suit your use case.

Guidance for [Assistants](https://platform.openai.com/docs/assistants/tools/file-search#supported-files):
For details on selecting the appropriate file extensions for different scenarios, refer to the documentation on [File creation](https://platform.openai.com/docs/api-reference/files/create).

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  //Asynchronous example
  Client.Uploads.AsynCreate(
    procedure (Params: TUploadCreateParams)
    begin
      Params.Purpose('fine-tune');
      Params.Filename('BatchExample.jsonl');
      Params.bytes(FileSize('BatchExample.jsonl'));
      Params.MimeType('text/jsonl');
    end,
    function : TAsynUpload
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);

  //Synchronous example
//  var Value := Client.Uploads.Create(
//    procedure (Params: TUploadCreateParams)
//    begin
//      Params.Purpose('fine-tune');
//      Params.Filename('BatchExample.jsonl');
//      Params.bytes(FileSize('BatchExample.jsonl'));
//      Params.MimeType('text/jsonl');
//    end);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;

  //Asynchronous promise example
//  var Promise := Client.Uploads.AsyncAwaitCreate(
//    procedure (Params: TUploadCreateParams)
//    begin
//      Params.Purpose('fine-tune');
//      Params.Filename('BatchExample.jsonl');
//      Params.bytes(FileSize('BatchExample.jsonl'));
//      Params.MimeType('text/jsonl');
//    end);
//
//  Promise
//    .&Then<TUpload>(
//      function (Value: TUpload): TUpload
//      begin
//        Display(TutorialHub, Value);
//        Result := Value;
//      end)
//    .&Catch(
//      procedure (E: Exception)
//      begin
//        Display(TutorialHub, E.Message);
//      end);
```

<br/>

### Upload cancel

Cancels the Upload. No Parts may be added after an Upload is cancelled.

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.Id := 'upload_679207849ec8819086bc0e54f5c66d62';

  //Asynchronous example
  Client.Uploads.AsynCancel(TutorialHub.Id,
    function : TAsynUpload
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);

  //Synchronous example
//  var Value := Client.Uploads.Cancel(TutorialHub.Id);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;

  //Asynchronous promise example
//  var Promise := Client.Uploads.AsyncAwaitCancel(TutorialHub.Id);
//
//  Promise
//    .&Then<TUpload>(
//      function (Value: TUpload): TUpload
//      begin
//        Display(TutorialHub, Value);
//        Result := Value;
//      end)
//    .&Catch(
//      procedure (E: Exception)
//      begin
//        Display(TutorialHub, E.Message);
//      end);
```

<br/>

### Upload add part

Adds a [Part](https://platform.openai.com/docs/api-reference/uploads/part-object) to an [Upload](https://platform.openai.com/docs/api-reference/uploads/object) object. A Part represents a chunk of bytes from the file you are trying to upload.

Each Part can be at most 64 MB, and you can add Parts until you hit the Upload maximum of 8 GB.

It is possible to add multiple Parts in parallel. You can decide the intended order of the Parts when you [complete the Upload](https://platform.openai.com/docs/api-reference/uploads/complete).

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.Id := 'upload_679207849ec8819086bc0e54f5c66d62';

  //Asynchronous example
  Client.Uploads.AsynAddPart(TutorialHub.Id,
    procedure (Params: TUploadPartParams)
    begin
      Params.Data('BatchExample.jsonl');
    end,
    function : TAsynUploadPart
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);

  //Asynchronous example
//  var Value := Client.Uploads.AddPart(TutorialHub.Id,
//    procedure (Params: TUploadPartParams)
//    begin
//      Params.Data('BatchExample.jsonl');
//    end);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;

  //Asynchronous promise example
//  var Promise := Client.Uploads.AsyncAwaitAddPart(
//    TutorialHub.Id,
//    procedure (Params: TUploadPartParams)
//    begin
//      Params.Data('BatchExample.jsonl');
//    end);
//
//  Promise
//    .&Then<TUploadPart>(
//      function (Value: TUploadPart): TUploadPart
//      begin
//        Display(TutorialHub, Value);
//        Result := Value;
//      end)
//    .&Catch(
//      procedure (E: Exception)
//      begin
//        Display(TutorialHub, E.Message);
//      end);
```

<br/>

### Upload complete

Completes the [Upload](https://platform.openai.com/docs/api-reference/uploads/object).

Within the returned Upload object, there is a nested [File](https://platform.openai.com/docs/api-reference/files/object) object that is ready to use in the rest of the platform.

You can specify the order of the Parts by passing in an ordered list of the Part IDs.

The number of bytes uploaded upon completion must match the number of bytes initially specified when creating the Upload object. No Parts may be added after an Upload is completed.

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.Id := 'upload_679207849ec8819086bc0e54f5c66d62';

  //Asynchronous example
  Client.Uploads.AsynComplete(TutorialHub.Id,
    procedure (Params: TUploadCompleteParams)
    begin
      Params.PartIds(['BatchExample.jsonl'])
    end,
    function : TAsynUpload
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);

  //Asynchronous example
//  var Value := Client.Uploads.Complete(TutorialHub.Id,
//    procedure (Params: TUploadCompleteParams)
//    begin
//      Params.PartIds(['BatchExample.jsonl'])
//    end);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;

  //Asynchronous promise example
//  var Promise := Client.Uploads.AsyncAwaitComplete(
//    TutorialHub.Id,
//    procedure (Params: TUploadCompleteParams)
//    begin
//      Params.PartIds(['BatchExample.jsonl'])
//    end);
//
//  Promise
//    .&Then<TUpload>(
//      function (Value: TUpload): TUpload
//      begin
//        Display(TutorialHub, Value);
//        Result := Value;
//      end)
//    .&Catch(
//      procedure (E: Exception)
//      begin
//        Display(TutorialHub, E.Message);
//      end);
```

<br/>

___

## Batch

Create large batches of API requests for asynchronous processing. The Batch API returns completions within 24 hours for a 50% discount. Related guide: [Batch](https://platform.openai.com/docs/guides/batch)

<br/>

### Batch create

Creates and executes a batch from an uploaded file of requests.

For our example, the contents of the batch JSONL file are as follows :

BatchExample.jsonl
```JSON
{"custom_id": "request-1", "method": "POST", "url": "/v1/chat/completions", "body": {"model": "gpt-4o-mini", "messages": [{"role": "system", "content": "You are a helpful assistant."}, {"role": "user", "content": "What is 2+2?"}]}}
{"custom_id": "request-2", "method": "POST", "url": "/v1/chat/completions", "body": {"model": "gpt-4o-mini", "messages": [{"role": "system", "content": "You are a helpful assistant."}, {"role": "user", "content": "What is the topology definition?"}]}}
```

Use the [File upload](#File-upload) method and get the ID referring to the JSONL file.

<br/>

Now create the batch as follow :

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.Id := '...id of BatchExample.jsonl...';

 {--- If needed, then create metadata }
  var MetaData := TJSONObject.Create
    .AddPair('customer_id', 'user_123456789')
    .AddPair('batch_description', 'Nightly eval job');

  //Asynchronous example
  Client.Batch.AsynCreate(
    procedure (Params: TBatchCreateParams)
    begin
      Params.InputFileId(TutorialHub.Id);
      Params.Endpoint('/v1/chat/completions');
      Params.CompletionWindow('24h');
      Params.Metadata(MetaData);
      TutorialHub.JSONRequest := Params.ToFormat();
    end,
    function : TAsynBatch
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);


  //Synchronous example
//  var Value := Client.Batch.Create(
//    procedure (Params: TBatchCreateParams)
//    begin
//      Params.InputFileId(TutorialHub.Id);
//      Params.Endpoint('/v1/chat/completions');
//      Params.CompletionWindow('24h');
//      Params.Metadata(MetaData);
//      TutorialHub.JSONRequest := Params.ToFormat();
//    end);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

>[!TIP]
> `GenAI` provides, through the `IBatchJSONBuilder` interface (available in the `GenAI.Batch.Interfaces` unit and implemented in the `GenAI.Batch.Builder` unit), powerful tools to easily build batch files from collected data. For further details, refer to the two units mentioned above.


<br/>

### Batch List

List your organization's batches.

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  //Asynchronous example
  Client.Batch.AsynList(
    procedure (Params: TUrlPaginationParams)
    begin
      Params.Limit(4);
    end,
    function : TAsynBatches
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);

  //Synchronous example
//  var Value := Client.Batch.List(
//    procedure (Params: TUrlPaginationParams)
//    begin
//      Params.Limit(4);
//    end);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

With out request parameters

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  //Asynchronous example
  Client.Batch.AsynList(
    function : TAsynBatches
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);

  //Synchronous example
//  var Value := Client.Batch.List;
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

Refer to [parameters documentation](https://platform.openai.com/docs/api-reference/batch/list).

<br/>

### Batch retrieve

Retrieves a batch using its ID.

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.Id := '...Id of batch to retrieve...';

  //Asynchronous example
  Client.Batch.AsynRetrieve(TutorialHub.Id,
    function : TAsynBatch
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);

  //Synchronous example
//  var Value := Client.Batch.Retrieve(TutorialHub.Id);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

<br/>

### Batch cancel

Cancels an in-progress batch. The batch will be in status `cancelling` for up to 10 minutes, before changing to `cancelled`, where it will have partial results (if any) available in the output file.

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.Id := '...Id of batch to cancel...';

  //Asynchronous example
  Client.Batch.AsynCancel(TutorialHub.Id,
    function : TAsynBatch
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);

  //Synchronous example
//  var Value := Client.Batch.Cancel(TutorialHub.Id);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

<br/>

### Batch output viewer

Open and view the results obtained after processing the batch.

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.Id := '...Id of batch...';
  var Output := EmptyStr;

  var Value := Client.Files.RetrieveContent(TutorialHub.Id);
  try
    Output := Value.Content;
  finally
    Value.Free;
  end;

  for var Item in JSONLChatReader.Deserialize(Output) do
    try
      Display(TutorialHub, Item.Response.Body);
    finally
      Item.Free;
    end;
```

>[!TIP]
> `GenAI` provides, through the `IJSONLReader` interface (available in the `GenAI.Batch.Interfaces` unit and implemented in the `GenAI.Batch.Reader` unit), powerful tools to easily read batch files content. For further details, refer to the two units mentioned above.

<br/>

___

## Fine tuning

Handle fine-tuning tasks to customize a model according to your specific training dataset. Relevant guide: [Model fine-tuning](https://platform.openai.com/docs/guides/fine-tuning).

After determining that fine-tuning is the appropriate approach (meaning you’ve already optimized your prompt to its full potential and identified remaining issues with the model), the next step is to prepare the training data. You’ll need to create a varied collection of sample conversations that resemble the types of interactions the model will handle during inference in production.

<br/>

### Fine tuning create

#### Preparing your dataset

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

#### Upload dataset

Once the training and test files have been created, they must be uploaded using the File API. The purpose property should be set to `finetune` (refer to the enumerated type `TFilesPurpose`). Please see the [example](#File-upload) above for detailed steps on uploading the files.

#### Create the fine-tuning job

```Delphi
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

### Fine tuning list

List your organization's fine-tuning jobs. Refer to [parameters documentation](https://platform.openai.com/docs/api-reference/fine-tuning/list).

```Delphi
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

### Fine tuning cancel

Immediately cancel a fine-tune job.

```Delphi
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

### Fine tuning events

Get status updates for a fine-tuning job.

```Delphi
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

### Fine tuning check point

List checkpoints for a fine-tuning job.

```Delphi
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

### Fine tuning retrieve

Get info about a fine-tuning job.

```Delphi
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

### Difference Between Supervised and DPO

<br/>

#### SUPERVISED Fine-Tuning Method

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

#### DPO (Direct Preference Optimization) Method


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

#### Choosing Between the Two Methods


 |    Criteria       |         Supervised               |                 DPO                      |
 | --- | --- |--- |
 | Data Availability                           | Requires data with clear target outputs  | Requires comparisons between responses  (preferences)  |
 | Implementation  Complexity   | Simpler                                                               | More complex, needs well-collected preferences      |
 | Human Alignment                       | Limited                                                               | Strong alignment due to human preference incorporation |
 | Primary Use Cases                      | Well-defined, objective tasks                      | Subjective tasks or those requiring fine-tuned alignment  |
 
<br/>

#### Recommendations

- **Use the supervised method if:**
    - You have a  labeled  dataset  with ideal responses  for your prompts.   
    - Your task is  well-defined and does  not require subjective adjustments  or alignment with human preferences.

- **Use the DPO method if:**
    - You want the model to generate responses that align with human or specific subjective preferences.
    - You have a dataset with comparisons between multiple responses.
    - You  aim  to  improve  response  quality  for  creative  or  open-ended  tasks  where preferences  are  key.

In summary, the  supervised method  is ideal for  well-defined tasks, while  DPO is more suitable when human preferences or subjective criteria are central to your project.

 <br/>

___

## Vector store

Vector stores are used to store files for use by the [`file_search`](https://platform.openai.com/docs/assistants/tools/file-search) tool.

### Vector store create

Create a vector store. [Refer to documentation](https://platform.openai.com/docs/api-reference/vector-stores/create)

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;
  
  TutorialHub.JSONRequestClear;
  
  //Asynchronous example
  Client.VectorStore.AsynCreate(
    procedure (Params: TVectorStoreCreateParams)
    begin
      Params.Name('Support FAQ');
      TutorialHub.JSONRequest := Params.ToFormat();
    end,
    function : TAsynVectorStore
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);

  //Synchronous example
//  var Value := Client.VectorStore.Create(
//    procedure (Params: TVectorStoreCreateParams)
//    begin
//      Params.Name('Support FAQ');
//      TutorialHub.JSONRequest := Params.ToFormat();
//    end);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;

  //Asynchronous promise example
//  var Promise := Client.VectorStore.AsyncAwaitCreate(
//    procedure (Params: TVectorStoreCreateParams)
//    begin
//      Params.Name('GenAI project Data');
//      TutorialHub.JSONRequest := Params.ToFormat();
//    end);
//
//  Promise
//    .&Then<string>(
//      function (Value: TVectorStore): string
//      begin
//        Result := Value.Id;
//        Display(TutorialHub, Value);
//      end)
//    .&Catch(
//      procedure (E: Exception)
//      begin
//        Display(TutorialHub, E.Message);
//      end);
```

The Json response.
```JSON
{
  "id": "vs_abc123",
  "object": "vector_store",
  "created_at": 1699061776,
  "name": "Support FAQ",
  "bytes": 139920,
  "file_counts": {
    "in_progress": 0,
    "completed": 3,
    "failed": 0,
    "cancelled": 0,
    "total": 3
  }
}
```

<br/>

### Vector store list

Returns a list of vector stores.  

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.JSONRequestClear;

  //Asynchronous example
  Client.VectorStore.AsynList(
    function : TAsynVectorStores
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);

  //Synchronous example
//  var Value := Client.VectorStore.List;
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;

  //Asynchronous promise example
//  var Promise := Client.VectorStore.AsyncAwaitList;
//
//  Promise
//    .&Then<TVectorStores>(
//      function (Value: TVectorStores): TVectorStores
//      begin
//        Result := Value;
//        Display(TutorialHub, Value);
//      end)
//    .&Catch(
//      procedure (E: Exception)
//      begin
//        Display(TutorialHub, E.Message);
//      end);
```

Example using [parameter](https://platform.openai.com/docs/api-reference/vector-stores/list).

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.JSONRequestClear;

  //Asynchronous example
  Client.VectorStore.AsynList(
    procedure (Params: TVectorStoreUrlParam)
    begin
      Params.Limit(3);
    end,
    function : TAsynVectorStores
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);

  //Synchronous example
//  var Value := Client.VectorStore.List(
//    procedure (Params: TVectorStoreUrlParam)
//    begin
//      Params.Limit(3);
//    end);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;

  //Asynchronous promise example
//  var Promise := Client.VectorStore.AsyncAwaitList(
//    procedure (Params: TVectorStoreUrlParam)
//    begin
//      Params.Limit(30);
//    end);
//
//  Promise
//    .&Then<TVectorStores>(
//      function (Value: TVectorStores): TVectorStores
//      begin
//        Result := Value;
//        Display(TutorialHub, Value);
//      end)
//    .&Catch(
//      procedure (E: Exception)
//      begin
//        Display(TutorialHub, E.Message);
//      end);
```

<br/>

### Vector store retrieve

Retrieves a vector store by its ID.

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.Id := 'vs_abc123';

  //Asynchronous example
  Client.VectorStore.AsynRetrieve(TutorialHub.Id,
    function : TAsynVectorStore
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);

  //Synchronous example
//  var Value := Client.VectorStore.Retrieve(TutorialHub.Id);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;

  //Asynchronous promise example
//  var Promise := Client.VectorStore.AsyncAwaitRetrieve(TutorialHub.Id);
//
//  Promise
//    .&Then<string>(
//      function (Value: TVectorStore): string
//      begin
//        Result := Value.Id;
//        Display(TutorialHub, Value);
//      end)
//    .&Catch(
//      procedure (E: Exception)
//      begin
//        Display(TutorialHub, E.Message);
//      end);
```

<br/>

### Vector store modify

Modifies a vector store by its ID.

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.Id := 'vs_abc123';

  var MetaData := TJSONObject.Create
    .AddPair('customer_id', 'user_123456789')
    .AddPair('vector_description', 'vector store user');

  //Asynchronous example
  Client.VectorStore.AsynUpdate(TutorialHub.Id,
    procedure (Params: TVectorStoreUpdateParams)
    begin
      Params.Name('Support FAQ user');
      Params.Metadata(Metadata);
      TutorialHub.JSONRequest := Params.ToFormat();
    end,
    function : TAsynVectorStore
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);

  //Synchronous example
//  var Value := Client.VectorStore.Update(TutorialHub.Id,
//    procedure (Params: TVectorStoreUpdateParams)
//    begin
//      Params.Name('Support FAQ user');
//      Params.Metadata(Metadata);
//      TutorialHub.JSONRequest := Params.ToFormat();
//    end);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;

  //Asynchronous promise example
//  var Promise := Client.VectorStore.AsyncAwaitUpdate(
//    TutorialHub.Id,
//    procedure (Params: TVectorStoreUpdateParams)
//    begin
//      Params.Name('Support FAQ user');
//      Params.Metadata(Metadata);
//      TutorialHub.JSONRequest := Params.ToFormat();
//    end);
//
//  Promise
//    .&Then<string>(
//      function (Value: TVectorStore): string
//      begin
//        Result := Value.Id;
//        Display(TutorialHub, Value);
//      end)
//    .&Catch(
//      procedure (E: Exception)
//      begin
//        Display(TutorialHub, E.Message);
//      end);
```

<br/>

### Vector store delete

Delete a vector store by its ID.

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.Id := 'vs_abc123';

  //Asynchronous example
  Client.VectorStore.AsynDelete(TutorialHub.Id,
    function : TAsynDeletion
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);

  //Synchronous example
//  var Value := Client.VectorStore.Delete(TutorialHub.Id);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;

  //Asynchronous promise example
//  var Promise := Client.VectorStore.AsyncAwaitDelete(TutorialHub.Id);
//
//  Promise
//    .&Then<string>(
//      function (Value: TDeletion): string
//      begin
//        Result := Value.Id;
//        Display(TutorialHub, Value);
//      end)
//    .&Catch(
//      procedure (E: Exception)
//      begin
//        Display(TutorialHub, E.Message);
//      end);
```

The JSON response.
```JSON
{
    "id": "vs_abc123",
    "object": "vector_store.deleted",
    "deleted": true
}
```

<br/>

___

## Vector store files

Vector store files represent files inside a vector store.

Related guide: [File Search](https://platform.openai.com/docs/assistants/tools/file-search)

<br/>

### Vsf create

Create a vector store file by attaching a [File](https://platform.openai.com/docs/api-reference/files) to a [vector store](https://platform.openai.com/docs/api-reference/vector-stores/object).

<br/>

#### Create a vector store

To create the vector store, it is advisable to refer to the example provided [at this location](#Vector-store-create) . Once the creation is complete, it is essential to retrieve the vector store ID. 

<br/>

#### Upload files en get Ids

To link the files to the vector store created in the previous step, it is necessary to [upload](#File-upload) them first, as described earlier. Additionally, it is essential to retrieve the file IDs after the upload, just like in the previous step.

Let’s consider the upload of two files, ***file1*** and ***file2***, ensuring that the `purpose` field is set to `assistant`. This will provide the corresponding file IDs, ***fileId1*** and ***fileId2***, respectively.

<br/>

#### Create the vector store files

To create the file store containing ***file1*** and ***file2***, the provided code will need to be executed twice, once for each identifier: ***fileId1*** and ***fileId2***. Upon completion of these operations, calling the file store will grant access to both associated files.

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.JSONRequestClear;
  TutorialHub.Id := 'vs_abc123';  //Id of vector store
  var Id1 := 'file-123';
  var Id2 := 'file-456';

  //Asynchronous example
  Client.VectorStoreFiles.AsynCreate(TutorialHub.id,
    procedure (Params: TVectorStoreFilesCreateParams)
    begin
      Params.FileId(Id1);  // or Params.FileId(Id2);
      TutorialHub.JSONRequest := Params.ToFormat();
    end,
    function : TAsynVectorStoreFile
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);

  //Synchronous example
//  var Value := Client.VectorStoreFiles.Create(TutorialHub.id,
//    procedure (Params: TVectorStoreFilesCreateParams)
//    begin
//      Params.FileId(Id1); // or Params.FileId(Id2);
//      TutorialHub.JSONRequest := Params.ToFormat();
//    end);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;

  //Asynchronous promise example
//  var Promise := Client.VectorStoreFiles.AsyncAwaitCreate(
//    TutorialHub.id,
//    procedure (Params: TVectorStoreFilesCreateParams)
//    begin
//      Params.FileId(Id1); // or Params.FileId(Id2);
//      TutorialHub.JSONRequest := Params.ToFormat();
//    end);
//
//  Promise
//    .&Then<TVectorStoreFile>(
//      function (Value: TVectorStoreFile): TVectorStoreFile
//      begin
//        Result := Value;
//        Display(TutorialHub, Value);
//      end)
//    .&Catch(
//      procedure (E: Exception)
//      begin
//        Display(TutorialHub, E.Message);
//      end);
```

The JSON response:
```JSON
{
    "id": "file-124",
    "object": "vector_store.file",
    "usage_bytes": 62353,
    "created_at": 1738906505,
    "vector_store_id": "vs_abc123",
    "status": "completed",
    "last_error": null,
    "chunking_strategy": {
        "type": "static",
        "static": {
            "max_chunk_size_tokens": 800,
            "chunk_overlap_tokens": 400
        }
    }
}  
```

<br/>

### Vsf list

Returns a list of vector store files.

<br/>

#### Without parameters

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;
 
  TutorialHub.JSONRequestClear;
  TutorialHub.Id := 'vs_abc123';

  //Asynchronous example
  Client.VectorStoreFiles.AsynList(TutorialHub.Id,
    function : TAsynVectorStoreFiles
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);

  //Synchronous example
//  var Value := Client.VectorStoreFiles.List(TutorialHub.Id);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;

  //Asynchronous promise example
//  var Promise := Client.VectorStoreFiles.AsyncAwaitList(TutorialHub.Id);
//
//  promise
//    .&Then<TVectorStoreFiles>(
//      function (Value: TVectorStoreFiles): TVectorStoreFiles
//      begin
//        Result := Value;
//        Display(TutorialHub, Value);
//      end)
//    .&Catch(
//      procedure (E: Exception)
//      begin
//        Display(TutorialHub, E.Message);
//      end);
```

<br/>

#### with parameters

Refert to [parameters documentation](https://platform.openai.com/docs/api-reference/vector-stores-files/listFiles).

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.JSONRequestClear;
  TutorialHub.Id := 'vs_abc123';

  //Asynchronous example
  Client.VectorStoreFiles.AsynList(TutorialHub.Id,
    procedure (Params: TVectorStoreFilesUrlParams)
    begin
      Params.Limit(5);
      Params.Filter('completed');
    end,
    function : TAsynVectorStoreFiles
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);

  //Synchronous example
//  var Value := Client.VectorStoreFiles.List(TutorialHub.Id,
//    procedure (Params: TVectorStoreFilesUrlParams)
//    begin
//      Params.Limit(5);
//      Params.Filter('completed');
//    end);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;

  //Asynchronous promise example
//  var Promise := Client.VectorStoreFiles.AsyncAwaitList(TutorialHub.Id,
//    procedure (Params: TVectorStoreFilesUrlParams)
//    begin
//      Params.Limit(5);
//      Params.Filter('completed');
//    end);
//
//  promise
//    .&Then<TVectorStoreFiles>(
//      function (Value: TVectorStoreFiles): TVectorStoreFiles
//      begin
//        Result := Value;
//        Display(TutorialHub, Value);
//      end)
//    .&Catch(
//      procedure (E: Exception)
//      begin
//        Display(TutorialHub, E.Message);
//      end);
```

The JSON response:
```JSON
{
    "object": "list",
    "data": [
        {
            "id": "file-123",
            "object": "vector_store.file",
            "usage_bytes": 62353,
            "created_at": 1738906505,
            "vector_store_id": "vs_abc123",
            "status": "completed",
            "last_error": null,
            "chunking_strategy": {
                "type": "static",
                "static": {
                    "max_chunk_size_tokens": 800,
                    "chunk_overlap_tokens": 400
                }
            },
            "metadata": {
            }
        },
        {
            "id": "file-456",
            "object": "vector_store.file",
            "usage_bytes": 1601511,
            "created_at": 1738902946,
            "vector_store_id": "vs_abc123",
            "status": "completed",
            "last_error": null,
            "chunking_strategy": {
                "type": "static",
                "static": {
                    "max_chunk_size_tokens": 800,
                    "chunk_overlap_tokens": 400
                }
            },
            "metadata": {
            }
        }
    ],
    "first_id": "file-123",
    "last_id": "file-456",
    "has_more": false
}
```

<br/>

### Vsf retrieve

Retrieves a vector store file.

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.JSONRequestClear;
  TutorialHub.Id := 'vs_abc123';
  var Id1 := 'file-123';

  //Asynchronous example
  Client.VectorStoreFiles.AsynRetrieve(
    TutorialHub.Id,
    Id1,
    function : TAsynVectorStoreFile
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);

  //Synchronous example
//  var Value := Client.VectorStoreFiles.Retrieve(
//                 TutorialHub.Id,
//                 Id1);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;

  //Asynchronous promise example
//  var Promise := Client.VectorStoreFiles.AsyncAwaitRetrieve(TutorialHub.Id, Id);
//
//  Promise
//    .&Then<int64>(
//      function (Value: TVectorStoreFile): int64
//      begin
//        Result := Value.UsageBytes;
//        Display(TutorialHub, Value);
//        ShowMessage((Result div 1000000).ToString + ' MB created at : ' + Value.CreatedAtAsString);
//      end)
//    .&Catch(
//      procedure (E: Exception)
//      begin
//        Display(TutorialHub, E.Message);
//      end);
```

The JSON response:
```JSON
{
    "id": "file-123",
    "object": "vector_store.file",
    "usage_bytes": 1601511,
    "created_at": 1738902946,
    "vector_store_id": "vs_abc123",
    "status": "completed",
    "last_error": null,
    "chunking_strategy": {
        "type": "static",
        "static": {
            "max_chunk_size_tokens": 800,
            "chunk_overlap_tokens": 400
        }
    }
}
```

<br/>

### Vsf delete

Remove a vector store file. This action will detach the file from the vector store without deleting the file itself. To permanently delete the file, use the [delete file](#File-Deletion) endpoint.

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.JSONRequestClear;
  TutorialHub.Id := 'vs_abc123';
  var Id1 := 'file-123';

  //Asynchronous example
  Client.VectorStoreFiles.AsynDelete(
    TutorialHub.Id,
    Id1,
    function : TAsynDeletion
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);


  //Synchronous example
//  var Value := Client.VectorStoreFiles.Delete(
//                 TutorialHub.Id,
//                 Id1);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;

  //Asynchronous promise example
//  var Promise := Client.VectorStore.AsyncAwaitDelete(TutorialHub.Id);
//
//  Promise
//    .&Then<string>(
//      function (Value: TDeletion): string
//      begin
//        Result := Value.Id;
//        Display(TutorialHub, Value);
//      end)
//    .&Catch(
//      procedure (E: Exception)
//      begin
//        Display(TutorialHub, E.Message);
//      end);
```

The JSON response:
```JSON
{
    "id": "file-123",
    "object": "vector_store.file.deleted",
    "deleted": true
}
```

<br/>

___

## Vector store batches

Vector store file batches represent operations to add multiple files to a vector store. Related guide: [File Search](https://platform.openai.com/docs/assistants/tools/file-search)

<br/>

### Vsb create

<br/>

#### Create a vector store

To create the vector store, it is advisable to refer to the example provided [at this location](#Vector-store-create) . Once the creation is complete, it is essential to retrieve the vector store ID. 

<br/>

#### Upload files en get Ids

To link the files to the vector store created in the previous step, it is necessary to [upload](#File-upload) them first, as described earlier. Additionally, it is essential to retrieve the file IDs after the upload, just like in the previous step.

Let’s consider the upload of two files, ***file1*** and ***file2***, ensuring that the `purpose` field is set to `assistant`. This will provide the corresponding file IDs, ***fileId1*** and ***fileId2***, respectively.

<br/>

#### Create the vector store batches

To create the batch store containing ***file1*** and ***file2***, uses example bellow.


```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.JSONRequestClear;
  TutorialHub.Id := 'vs_cde456';
  var Id1 := 'file-123';
  var Id2 := 'file-456';

  //Asynchronous example
  Client.VectorStoreBatch.AsynCreate(TutorialHub.id,
    procedure (Params: TVectorStoreBatchCreateParams)
    begin
      Params.FileId([Id1, Id2]);
      TutorialHub.JSONRequest := Params.ToFormat();
    end,
    function : TAsynVectorStoreBatch
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);

  //Synchronous example
//  var Value := Client.VectorStoreBatch.Create(TutorialHub.id,
//    procedure (Params: TVectorStoreBatchCreateParams)
//    begin
//      Params.FileId([Id1, Id2]);
//      TutorialHub.JSONRequest := Params.ToFormat();
//    end);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

The JSON response:
```JSON
{
    "id": "vsfb_123",
    "object": "vector_store.file_batch",
    "created_at": 1738956347,
    "status": "in_progress",
    "vector_store_id": "vs_cde456",
    "file_counts": {
        "in_progress": 2,
        "completed": 0,
        "failed": 0,
        "cancelled": 0,
        "total": 2
    }
}
```

<br/>

### Vsb list

Returns a list of vector store files in a batch.

#### Without parameters

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;
 
  TutorialHub.JSONRequestClear;
  TutorialHub.Id := 'vs_cde456';
  var BatchId := 'vsfb_789';

  //Asynchronous example
  Client.VectorStoreBatch.AsynList(
    TutorialHub.Id,
    BatchId,
    function : TAsynVectorStoreBatches
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);

  //Synchronous example
//  var Value := Client.VectorStoreBatch.List(TutorialHub.Id, BatchId);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

<br/>

#### with parameters

Refert to [parameters documentation](https://platform.openai.com/docs/api-reference/vector-stores-files/listFiles).

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.JSONRequestClear;
  TutorialHub.Id := 'vs_cde456';
  var BatchId := 'vsfb_789';

  //Asynchronous example
  Client.VectorStoreBatch.AsynList(
    TutorialHub.Id,
    BatchId,
    procedure (Params: TVectorStoreFilesUrlParams)
    begin
      Params.Limit(5);
      Params.Filter('completed');
    end,
    function : TAsynVectorStoreBatches
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);

  //Synchronous example
//  var Value := Client.VectorStoreBatch.List(TutorialHub.Id, BatchId,
//    procedure (Params: TVectorStoreFilesUrlParams)
//    begin
//      Params.Limit(5);
//      Params.Filter('completed');
//    end);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

The JSON response:
```JSON
{
    "object": "list",
    "data": [
        {
            "id": "file-123",
            "object": "vector_store.file",
            "created_at": 1738955835,
            "vector_store_id": "vs_cde456",
            "status": "completed",
            "last_error": null
        },
        {
            "id": "file-456",
            "object": "vector_store.file",
            "created_at": 1738902946,
            "vector_store_id": "vs_cde456",
            "status": "completed",
            "last_error": null
        }
    ],
    "first_id": "file-123",
    "last_id": "file-456",
    "has_more": false
}
```

<br/>

### Vsb retrieve

Returns a list of vector store files in a batch.

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.JSONRequestClear;
  TutorialHub.Id := 'vs_cde456';
  var BatchId := 'vsfb_7891';

  //Asynchronous example
  Client.VectorStoreBatch.AsynRetrieve(
    TutorialHub.Id,
    BatchId,
    function : TAsynVectorStoreBatch
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);

  //Synchronous example
//  var Value := Client.VectorStoreBatch.Retrieve(
//                 TutorialHub.Id,
//                 BatchId);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

The JSON response:
```JSON
{
    "id": "vsfb_789",
    "object": "vector_store.file_batch",
    "created_at": 1738958063,
    "status": "completed",
    "vector_store_id": "vs_cde456",
    "file_counts": {
        "in_progress": 0,
        "completed": 2,
        "failed": 0,
        "cancelled": 0,
        "total": 2
    }
}
```

<br/>

### Vsb cancel

Cancel a vector store file batch. This attempts to cancel the processing of files in this batch as soon as possible.

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.JSONRequestClear;
  TutorialHub.Id := 'vs_cde456';
  var BatchId := 'vsfb_789';

  //Asynchronous example
  Client.VectorStoreBatch.AsynRetrieve(
    TutorialHub.Id,
    BatchId,
    function : TAsynVectorStoreBatch
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);

  //Synchronous example
//  var Value := Client.VectorStoreBatch.Cancel(
//                 TutorialHub.Id,
//                 BatchId);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

The JSON response:
```JSON
{
    "id": "vsfb_789",
    "object": "vector_store.file_batch",
    "created_at": 1738958063,
    "status": "completed",
    "vector_store_id": "vs_cde456",
    "file_counts": {
        "in_progress": 0,
        "completed": 2,
        "failed": 0,
        "cancelled": 0,
        "total": 2
    }
}
```

<br/>

___

## Assistants

Build assistants that can call models and use tools to perform tasks.

The version of assistants integrated by `GenAI` is version 2, currently offered in beta by **OpenAI**.

[Get started with the Assistants API](https://platform.openai.com/docs/assistants)

<br/>

### Create assistant

<br/>

#### Code interpreter

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.JSONRequestClear;

  //Asynchronous example
 Client.Assistants.AsynCreate(
    procedure (Params: TAssistantsParams)
    begin
      Params.Model('gpt-4o');
      Params.Instructions('You are an HR bot, and you have access to files to answer employee questions about company policies.');
      Params.Name('HR Bot');

      // ---> Change github documentation

      Params.Tools([file_search]);
      Params.ToolResources(file_search_storeId);
      TutorialHub.JSONRequest := Params.ToFormat();
    end,
    function : TAsynAssistant
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);

  //Synchronous example
//  var Value := Client.Assistants.Create(
//    procedure (Params: TAssistantsParams)
//    begin
//      Params.Model('gpt-4o');
//      Params.Instructions('You are an HR bot, and you have access to files to answer employee questions about company policies.');
//      Params.Name('HR Bot');
//      Params.Tools([file_search]);
//      Params.ToolResources(file_search_storeId);
//      TutorialHub.JSONRequest := Params.ToFormat();
//    end);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

The JSON response:
```JSON
{
    "id": "asst_4FYKxWZ3CFprvgLKe4E8CZGl",
    "object": "assistant",
    "created_at": 1738960690,
    "name": "Math Tutor",
    "description": null,
    "model": "gpt-4o",
    "instructions": "You are a personal math tutor. When asked a question, write and run Python code to answer the question.",
    "tools": [
    ],
    "top_p": 1.0,
    "temperature": 1.0,
    "reasoning_effort": null,
    "tool_resources": {
    },
    "metadata": {
    },
    "response_format": "auto"
}
```

<br/>

#### File search

To fully utilize this feature offered by the `assistants`, you must be comfortable managing file stores. For further details, you can refer to the sections [vector store files](#Vector-store-files) outlined above.

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.JSONRequestClear;
  var FilesId := 'vs_123';  //Id of a vector store files

  //Asynchronous example
  Client.Assistants.AsynCreate(
    procedure (Params: TAssistantsParams)
    begin
      Params.Model('gpt-4o');
      Params.Instructions('You are an HR bot, and you have access to files to answer employee questions about company policies.');
      Params.Name('HR Bot');
      Params.Tools([File_search]);
      Params.ToolResources(File_search([FilesId]));
      TutorialHub.JSONRequest := Params.ToFormat();
    end,
    function : TAsynAssistant
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);

  //Synchronous example
//  var Value := Client.Assistants.Create(
//    procedure (Params: TAssistantsParams)
//    begin
//      Params.Model('gpt-4o');
//      Params.Instructions('You are an HR bot, and you have access to files to answer employee questions about company policies.');
//      Params.Name('HR Bot');
//      Params.Tools([File_search]);
//      Params.ToolResources(File_search([FilesId]));
//      TutorialHub.JSONRequest := Params.ToFormat();
//    end);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

The JSON response:
```JSON
{
  "id": "asst_abc123",
  "object": "assistant",
  "created_at": 1738963996,
  "name": "HR Helper",
  "description": null,
  "model": "gpt-4o",
  "instructions": "You are an HR bot, and you have access to files to answer employee questions about company policies.",
  "tools": [
    {
      "type": "file_search"
    }
  ],
  "tool_resources": {
    "file_search": {
      "vector_store_ids": ["vs_123"]
    }
  },
  "metadata": {},
  "top_p": 1.0,
  "temperature": 1.0,
  "response_format": "auto"
}
```

<br/>

### List assistants

Returns a list of assistants.

Consult the [official documentation](https://platform.openai.com/docs/api-reference/assistants/listAssistants) for details on list parameters.

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.JSONRequestClear;

  //Asynchronous example
  Client.Assistants.AsynList(
    procedure (Params: TUrlAdvancedParams)
    begin
      Params.Limit(5);
    end,
    function : TAsynAssistants
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);

  //Synchronous example
//  var Value := Client.Assistants.List(
//    procedure (Params: TUrlAdvancedParams)
//    begin
//      Params.Limit(5);
//    end);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

<br/>

### Retrieve assistant

Retrieves an assistant by its ID.

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.JSONRequestClear;
  TutorialHub.Id := 'asst_abc123';

  //Asynchronous example
  Client.Assistants.AsynRetrieve(TutorialHub.Id,
    function : TAsynAssistant
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);

  //Synchronous example
//  var Value := Client.Assistants.Retrieve(TutorialHub.Id);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

<br/>

### Modify assistant

Modifies an assistant by its ID.

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.JSONRequestClear;
  TutorialHub.Id := 'asst_abc123';

  //Asynchronous example
  Client.Assistants.AsynUpdate(TutorialHub.Id,
    procedure (Params: TAssistantsParams)
    begin
      Params.Model('o3-mini');
      Params.ReasoningEffort(TReasoningEffort.medium);
      TutorialHub.JSONRequest := Params.ToFormat();
    end,
    function : TAsynAssistant
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);

  //Synchronous example
//  var Value := Client.Assistants.Update(TutorialHub.Id,
//    procedure (Params: TAssistantsParams)
//    begin
//      Params.Model('o3-mini');
//      Params.ReasoningEffort(TReasoningEffort.medium);
//      TutorialHub.JSONRequest := Params.ToFormat();
//    end);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

The JSON response
```JSON
{
    "id": "asst_abc123",
    "object": "assistant",
    "created_at": 1738963996,
    "name": "HR Bot",
    "description": null,
    "model": "o3-mini",
    "instructions": "You are an HR bot, and you have access to files to answer employee questions about company policies.",
    "tools": [
        {
            "type": "file_search",
            "file_search": {
                "ranking_options": {
                    "ranker": "default_2024_08_21",
                    "score_threshold": 0.0
                }
            }
        }
    ],
    "top_p": 1.0,
    "temperature": 1.0,
    "reasoning_effort": "medium",
    "tool_resources": {
        "file_search": {
            "vector_store_ids": [
                "vs_123"
            ]
        }
    },
    "metadata": {
    },
    "response_format": "auto"
}
```

<br/>

### Delete assistant

Delete an assistant by its ID.

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;
  
  TutorialHub.JSONRequestClear;
  TutorialHub.Id := 'asst_abc123';

  //Asynchronous example
  Client.Assistants.AsynDelete(TutorialHub.Id,
    function : TAsynDeletion
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);

  //Synchronous example
//  var Value := Client.Assistants.Delete(TutorialHub.Id);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

<br/>

___

## Threads

Create threads that assistants can interact with.

Related guide: [Assistants](https://platform.openai.com/docs/assistants/overview)

<br/>

### Create thread

Create a thread.

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.JSONRequestClear;

  //Synchronous example
  Client.Threads.AsynCreate(
    function : TAsynThreads
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);

  //Synchronous example
//  var Value := Client.Threads.Create;
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

<br/>

### Retrieve thread

Retrieves a thread by its ID.

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.Id := 'thread_xyz321';

  //Synchronous example
  Client.Threads.AsynRetrieve(TutorialHub.Id,
    function : TAsynThreads
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);

  //Synchronous example
//  var Value := Client.Threads.Retrieve(TutorialHub.Id);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

<br/>

### Modify thread

Modifies a thread by its ID.

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.Id := 'thread_xyz321';

  var MetaData := TJSONObject.Create
    .AddPair('customer_id', 'user_12345')
    .AddPair('batch_description', 'Nightly eval job');

  //Synchronous example
  Client.Threads.AsynModify(TutorialHub.Id,
    procedure (Params: TThreadsModifyParams)
    begin
      Params.Metadata(Metadata);
    end,
    function : TAsynThreads
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);

  //Synchronous example
//  var Value := Client.Threads.Modify(TutorialHub.Id,
//    procedure (Params: TThreadsModifyParams)
//    begin
//      Params.Metadata(Metadata);
//    end);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

The JSON response:
```JSON
{
    "id": "thread_xyz321",
    "object": "thread",
    "created_at": 1738969338,
    "metadata": {
        "customer_id": "user_12345",
        "batch_description": "Nightly eval job"
    },
    "tool_resources": {
    }
}
```

<br/>

### Delete thread

Delete a thread by its ID.

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.Id := 'thread_xyz321';

  //Synchronous example
  Client.Threads.AsynDelete(TutorialHub.Id,
    function : TAsynDeletion
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);

  //Synchronous example
//  var Value := Client.Threads.Delete(TutorialHub.Id);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

<br/>

___

## Messages

Create messages within threads

Related guide: [Assistants](https://platform.openai.com/docs/assistants/overview)

<br/>

### Create message

Create a message.

To take full advantage of this feature provided by Messages, it is essential to be proficient in managing Threads. For more information, please refer to the [Threads sections](#Threads) mentioned earlier.

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.JSONRequestClear;
  var ThreadId := 'thread_123abc';

  //Asynchronous example
  Client.Messages.AsynCreate(ThreadId,
    procedure (Params: TThreadsMessageParams)
    begin
      Params.Role('user');
      Params.Content('How does AI work? Explain it in simple terms.');
    end,
    function : TAsynMessages
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);

  //Synchronous example
//  var Value := Client.Messages.Create(ThreadId,
//    procedure (Params: TThreadsMessageParams)
//    begin
//      Params.Role('user');
//      Params.Content('How does AI work? Explain it in simple terms.');
//    end);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

The JSON response:
```JSON
{
    "id": "msg_456xyz",
    "object": "thread.message",
    "created_at": 1738971461,
    "assistant_id": null,
    "thread_id": "thread_123abc",
    "run_id": null,
    "role": "user",
    "content": [
        {
            "type": "text",
            "text": {
                "value": "How does AI work? Explain it in simple terms.",
                "annotations": [
                ]
            }
        }
    ],
    "attachments": [
    ],
    "metadata": {
    }
}
```

<br/>

### List messages

Returns a list of messages for a given thread.

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.JSONRequestClear;
  TutorialHub.Id := 'thread_123abc';

  //Asynchronous example
  Client.Messages.AsynList(TutorialHub.Id,
    procedure (Params: TAssistantsUrlParams)
    begin
      Params.Limit(5);
    end,
    function : TAsynMessagesList
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);

  //Synchronous example
//  var Value := Client.Messages.List(TutorialHub.Id,
//    procedure (Params: TAssistantsUrlParams)
//    begin
//      Params.Limit(5);
//    end);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

The JSON response:
```JSON
{
    "object": "list",
    "data": [
        {
            "id": "msg_456xyz",
            "object": "thread.message",
            "created_at": 1738972475,
            "assistant_id": null,
            "thread_id": "thread_123abc",
            "run_id": null,
            "role": "user",
            "content": [
                {
                    "type": "text",
                    "text": {
                        "value": "How does AI work? Explain it in simple terms.",
                        "annotations": [
                        ]
                    }
                }
            ],
            "attachments": [
            ],
            "metadata": {
            }
        }
    ],
    "first_id": "msg_456xyz",
    "last_id": "msg_456xyz",
    "has_more": false
}
```

<br/>

### Retrieve message

Retrieve a message by its ID.

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.JSONRequestClear;
  TutorialHub.Id := 'thread_123abc';
  var MessageId := 'msg_456xyz';

  //Asynchronous example
  Client.Messages.AsynRetrieve(TutorialHub.Id, MessageId,
    function : TAsynMessages
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);

  //Synchronous example
//  var Value := Client.Messages.Retrieve(TutorialHub.Id, MessageId);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

The JSON response:
```JSON
{
    "id": "msg_456xyz",
    "object": "thread.message",
    "created_at": 1738972475,
    "assistant_id": null,
    "thread_id": "thread_123abc",
    "run_id": null,
    "role": "user",
    "content": [
        {
            "type": "text",
            "text": {
                "value": "How does AI work? Explain it in simple terms.",
                "annotations": [
                ]
            }
        }
    ],
    "attachments": [
    ],
    "metadata": {
    }
}
```

<br/>

### Modify message

Modifies a message by its ID.

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.JSONRequestClear;
  TutorialHub.Id := 'thread_123abc';
  var MessageId := 'msg_456xyz';

  var MetaData := TJSONObject.Create
    .AddPair('customer_id', 'user_123456789')
    .AddPair('message_description', 'Eval job');

  //Asynchronous example
  Client.Messages.AsynUpdate(TutorialHub.Id, MessageId,
    procedure (Params: TMessagesUpdateParams)
    begin
      Params.Metadata(Metadata);
    end,
    function : TAsynMessages
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);

  //Synchronous example
//  var Value := Client.Messages.Update(TutorialHub.Id, MessageId,
//    procedure (Params: TMessagesUpdateParams)
//    begin
//      Params.Metadata(Metadata);
//    end);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

The JSON response:
```JSON
{
    "id": "msg_456xyz",
    "object": "thread.message",
    "created_at": 1738972475,
    "assistant_id": null,
    "thread_id": "thread_123abc",
    "run_id": null,
    "role": "user",
    "content": [
        {
            "type": "text",
            "text": {
                "value": "How does AI work? Explain it in simple terms.",
                "annotations": [
                ]
            }
        }
    ],
    "file_ids": [
    ],
    "metadata": {
        "customer_id": "user_123456789",
        "message_description": "Eval job"
    }
}
```

<br/>

### Delete message

Deletes a message by its ID.

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.JSONRequestClear;
  TutorialHub.Id := 'thread_123abc';
  var MessageId := 'msg_456xyz';

  //Asynchronous example
  Client.Messages.AsynDelete(TutorialHub.Id, MessageId,
    function : TAsynDeletion
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);

  //Synchronous example
//  var Value := Client.Messages.Delete(TutorialHub.Id, MessageId);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

The JSON response:
```JSON
{
    "id": "msg_456xyz",
    "object": "thread.message.deleted",
    "deleted": true
}
```

<br/>

___

## Runs

Represents an execution run on a thread.

Related guide: [Assistants](https://platform.openai.com/docs/assistants/overview)

<br/>

### Create run

Create a run.

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.JSONRequestClear;
  var ThreadId := 'thread_abc123';
  var AssistantId := 'asst_abc123';

  //Asynchronous example
  Client.Runs.AsynCreate(ThreadId,
    procedure (Params: TRunsParams)
    begin
      Params.AssistantId(AssistantId);
    end,
    function : TAsynRun
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);

  //Synchronous example
//  var Value := Client.Runs.Create(ThreadId,
//    procedure (Params: TRunsParams)
//    begin
//      Params.AssistantId(AssistantId);
//    end);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

```JSON
{
  "id": "run_abc123",
  "object": "thread.run",
  "created_at": 1699063290,
  "assistant_id": "asst_abc123",
  "thread_id": "thread_abc123",
  "status": "queued",
  "started_at": 1699063290,
  "expires_at": null,
  "cancelled_at": null,
  "failed_at": null,
  "completed_at": 1699063291,
  "last_error": null,
  "model": "gpt-4o",
  "instructions": null,
  "incomplete_details": null,
  "tools": [
    {
      "type": "code_interpreter"
    }
  ],
  "metadata": {},
  "usage": null,
  "temperature": 1.0,
  "top_p": 1.0,
  "max_prompt_tokens": 1000,
  "max_completion_tokens": 1000,
  "truncation_strategy": {
    "type": "auto",
    "last_messages": null
  },
  "response_format": "auto",
  "tool_choice": "auto",
  "parallel_tool_calls": true
}
```

<br/>

Create a thread and run it in one request.

### Create thread and run

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.JSONRequestClear;
  var AssistantId := 'asst_abc123';

  //Asynchronous example
  Client.Runs.AsynCreateAndRun(
    procedure (Params: TCreateRunsParams)
    begin
      Params.AssistantId(AssistantId);
      TutorialHub.JSONRequest := Params.ToFormat();
    end,
    function : TAsynRun
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);

  //Synchronous example
//  var Value := Client.Runs.CreateAndRun(
//    procedure (Params: TCreateRunsParams)
//    begin
//      Params.AssistantId(AssistantId);
//      TutorialHub.JSONRequest := Params.ToFormat();
//    end);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

```JSON
{
  "id": "run_abc123",
  "object": "thread.run",
  "created_at": 1699076792,
  "assistant_id": "asst_abc123",
  "thread_id": "thread_abc123",
  "status": "queued",
  "started_at": null,
  "expires_at": 1699077392,
  "cancelled_at": null,
  "failed_at": null,
  "completed_at": null,
  "required_action": null,
  "last_error": null,
  "model": "gpt-4o",
  "instructions": "You are a helpful assistant.",
  "tools": [],
  "tool_resources": {},
  "metadata": {},
  "temperature": 1.0,
  "top_p": 1.0,
  "max_completion_tokens": null,
  "max_prompt_tokens": null,
  "truncation_strategy": {
    "type": "auto",
    "last_messages": null
  },
  "incomplete_details": null,
  "usage": null,
  "response_format": "auto",
  "tool_choice": "auto",
  "parallel_tool_calls": true
}
```

<br/>

### List runs

Returns a list of runs belonging to a thread.

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  var ThreadId := 'thread_abc123';
  
  //Asynchronous example
  Client.Runs.AsynList(ThreadId,
    procedure (Params: TRunsUrlParams)
    begin
      Params.Limit(5);
    end,
    function : TAsynRuns
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);

  //Synchronous example
//  var Value := Client.Runs.List(ThreadId,
//    procedure (Params: TRunsUrlParams)
//    begin
//      Params.Limit(5);
//    end);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

<br/>

### Retrieve run

Retrieves a run by its ID.

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.JSONRequestClear;
  TutorialHub.Id := 'thread_abc123';
  var RunId := 'asst_abc123';

  //Asynchronous example
  Client.Runs.AsynRetrieve(TutorialHub.Id, RunId,
    function : TAsynRun
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);

  //Synchronous example
//  var Value := Client.Runs.Retrieve(TutorialHub.Id, RunId);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

```JSON
{
  "id": "run_abc123",
  "object": "thread.run",
  "created_at": 1699075072,
  "assistant_id": "asst_abc123",
  "thread_id": "thread_abc123",
  "status": "completed",
  "started_at": 1699075072,
  "expires_at": null,
  "cancelled_at": null,
  "failed_at": null,
  "completed_at": 1699075073,
  "last_error": null,
  "model": "gpt-4o",
  "instructions": null,
  "incomplete_details": null,
  "tools": [
    {
      "type": "code_interpreter"
    }
  ],
  "metadata": {},
  "usage": {
    "prompt_tokens": 123,
    "completion_tokens": 456,
    "total_tokens": 579
  },
  "temperature": 1.0,
  "top_p": 1.0,
  "max_prompt_tokens": 1000,
  "max_completion_tokens": 1000,
  "truncation_strategy": {
    "type": "auto",
    "last_messages": null
  },
  "response_format": "auto",
  "tool_choice": "auto",
  "parallel_tool_calls": true
}
```

<br/>

### Modify run

Modifies a run by its ID.

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.JSONRequestClear;
  TutorialHub.Id := 'thread_abc123';
  var RunId := 'run_abc123';

  var MetaData := TJSONObject.Create
    .AddPair('user_id', 'user_abc123');

  //Asynchronous example
  Client.Runs.AsynUpdate(TutorialHub.Id, RunId,
    procedure (Params: TRunUpdateParams)
    begin
      Params.Metadata(MetaData);
      TutorialHub.JSONRequest := Params.ToFormat();
    end,
    function : TAsynRun
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);

  //Synchronous example
//  var Value := Client.Runs.Update(TutorialHub.Id, RunId,
//    procedure (Params: TRunUpdateParams)
//    begin
//      Params.Metadata(MetaData);
//      TutorialHub.JSONRequest := Params.ToFormat();
//    end);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

```JSON
{
  "id": "run_abc123",
  "object": "thread.run",
  "created_at": 1699075072,
  "assistant_id": "asst_abc123",
  "thread_id": "thread_abc123",
  "status": "completed",
  "started_at": 1699075072,
  "expires_at": null,
  "cancelled_at": null,
  "failed_at": null,
  "completed_at": 1699075073,
  "last_error": null,
  "model": "gpt-4o",
  "instructions": null,
  "incomplete_details": null,
  "tools": [
    {
      "type": "code_interpreter"
    }
  ],
  "tool_resources": {
    "code_interpreter": {
      "file_ids": [
        "file-abc123",
        "file-abc456"
      ]
    }
  },
  "metadata": {
    "user_id": "user_abc123"
  },
  "usage": {
    "prompt_tokens": 123,
    "completion_tokens": 456,
    "total_tokens": 579
  },
  "temperature": 1.0,
  "top_p": 1.0,
  "max_prompt_tokens": 1000,
  "max_completion_tokens": 1000,
  "truncation_strategy": {
    "type": "auto",
    "last_messages": null
  },
  "response_format": "auto",
  "tool_choice": "auto",
  "parallel_tool_calls": true
}
```

<br/>

### Submit tool outputs

When a run has the `status: "requires_action"` and `required_action.type` is `submit_tool_outputs`, this endpoint can be used to submit the outputs from the tool calls once they're all completed. All outputs must be submitted in a single request.

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.JSONRequestClear;
  TutorialHub.Id := 'thread_123';
  var RunId := 'run_123';

  //Asynchronous example
  Client.Runs.AsynSubmitTool(TutorialHub.Id, RunId,
    procedure (Params: TSubmitToolParams)
    begin
      Params.ToolOutputs([
        TToolOutputParam.Create.ToolCallId('call_001').Output('70 degrees and sunny.')
      ]);
      TutorialHub.JSONRequest := Params.ToFormat();
    end,
    function : TAsynRun
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);

  //Synchronous example
//  var Value := Client.Runs.SubmitTool(TutorialHub.Id, RunId,
//    procedure (Params: TSubmitToolParams)
//    begin
//      Params.ToolOutputs([
//        TToolOutputParam.Create.ToolCallId('call_001').Output('70 degrees and sunny.')
//      ]);
//      TutorialHub.JSONRequest := Params.ToFormat();
//    end);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

```JSON
{
  "id": "run_123",
  "object": "thread.run",
  "created_at": 1699075592,
  "assistant_id": "asst_123",
  "thread_id": "thread_123",
  "status": "queued",
  "started_at": 1699075592,
  "expires_at": 1699076192,
  "cancelled_at": null,
  "failed_at": null,
  "completed_at": null,
  "last_error": null,
  "model": "gpt-4o",
  "instructions": null,
  "tools": [
    {
      "type": "function",
      "function": {
        "name": "get_current_weather",
        "description": "Get the current weather in a given location",
        "parameters": {
          "type": "object",
          "properties": {
            "location": {
              "type": "string",
              "description": "The city and state, e.g. San Francisco, CA"
            },
            "unit": {
              "type": "string",
              "enum": ["celsius", "fahrenheit"]
            }
          },
          "required": ["location"]
        }
      }
    }
  ],
  "metadata": {},
  "usage": null,
  "temperature": 1.0,
  "top_p": 1.0,
  "max_prompt_tokens": 1000,
  "max_completion_tokens": 1000,
  "truncation_strategy": {
    "type": "auto",
    "last_messages": null
  },
  "response_format": "auto",
  "tool_choice": "auto",
  "parallel_tool_calls": true
}
```

<br/>

### Cancel run

Cancels a run that is `in_progress`.

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.JSONRequestClear;
  TutorialHub.Id := 'thread_abc123';
  var RunId := 'run_abc123';

  //Asynchronous example
  Client.Runs.AsynCancel(TutorialHub.Id, RunId,
    function : TAsynRun
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);

  //Synchronous example
//  var Value := Client.Runs.Cancel(TutorialHub.Id, RunId);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

```JSON
{
  "id": "run_abc123",
  "object": "thread.run",
  "created_at": 1699076126,
  "assistant_id": "asst_abc123",
  "thread_id": "thread_abc123",
  "status": "cancelling",
  "started_at": 1699076126,
  "expires_at": 1699076726,
  "cancelled_at": null,
  "failed_at": null,
  "completed_at": null,
  "last_error": null,
  "model": "gpt-4o",
  "instructions": "You summarize books.",
  "tools": [
    {
      "type": "file_search"
    }
  ],
  "tool_resources": {
    "file_search": {
      "vector_store_ids": ["vs_123"]
    }
  },
  "metadata": {},
  "usage": null,
  "temperature": 1.0,
  "top_p": 1.0,
  "response_format": "auto",
  "tool_choice": "auto",
  "parallel_tool_calls": true
}
```

<br/>

___

## Runs steps

Represents the steps (model and tool calls) taken during the run.

Related guide: [Assistants](https://platform.openai.com/docs/assistants/overview)

<br/>

### List run steps

Returns a list of run steps belonging to a run.

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.JSONRequestClear;
  var ThreadId := 'thread_abc123';
  var RunId := 'run_abc123';

  //Asynchronous example
  Client.RunStep.AsynList(ThreadId, RunId,
    procedure (Params: TRunStepUrlParam)
    begin
      Params.Limit(20);
    end,
    function : TAsynRunSteps
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);

  //Synchronous example
//  var Value := Client.RunStep.List(ThreadId, RunId,
//    procedure (Params: TRunStepUrlParam)
//    begin
//      Params.Limit(20);
//    end);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

```JSON
{
    "object": "list",
    "data": [
        {
            "id": "step_abc123",
            "object": "thread.run.step",
            "created_at": 1738977420,
            "run_id": "run_abc123",
            "assistant_id": "asst_abc123",
            "thread_id": "thread_abc123",
            "type": "message_creation",
            "status": "completed",
            "cancelled_at": null,
            "completed_at": 1738977421,
            "expires_at": null,
            "failed_at": null,
            "last_error": null,
            "step_details": {
                "type": "message_creation",
                "message_creation": {
                    "message_id": "msg_abc123"
                }
            },
            "usage": {
                "prompt_tokens": 973,
                "completion_tokens": 37,
                "total_tokens": 1010,
                "prompt_token_details": {
                    "cached_tokens": 0
                },
                "completion_tokens_details": {
                    "reasoning_tokens": 0
                }
            }
        }
    ],
    "first_id": "step_abc123",
    "last_id": "step_abc123",
    "has_more": false
}
```

>[!NOTE]
> In the JSON response, we can see that the message with the ID ***msg_abc123*** (***thread_abc123***) contains the reply generated by the model assigned to the assistant.
> By using the [message retrieve](#Retrieve-message) API with the parameters ***thread_abc123*** and ***msg_abc123***, it is possible to access the generated message content.

<br/>

### Retrieve run steps

Retrieves a run step.

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.JSONRequestClear;
  var ThreadId := 'thread_abc123';
  var RunId := 'run_abc123';
  var StepId := 'step_abc123';

  //Asynchronous example
  Client.RunStep.AsynRetrieve(ThreadId, RunId, StepId,
    function : TAsynRunStep
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);

  //Synchronous example
//  var Value := Client.RunStep.Retrieve(ThreadId, RunId, StepId);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

```JSON
{
    "id": "step_abc123",
    "object": "thread.run.step",
    "created_at": 1738977420,
    "run_id": "run_abc123",
    "assistant_id": "asst_abc123",
    "thread_id": "thread_abc123",
    "type": "message_creation",
    "status": "completed",
    "cancelled_at": null,
    "completed_at": 1738977421,
    "expires_at": null,
    "failed_at": null,
    "last_error": null,
    "step_details": {
        "type": "message_creation",
        "message_creation": {
            "message_id": "msg_abc123"
        }
    },
    "usage": {
        "prompt_tokens": 973,
        "completion_tokens": 37,
        "total_tokens": 1010,
        "prompt_token_details": {
            "cached_tokens": 0
        },
        "completion_tokens_details": {
            "reasoning_tokens": 0
        }
    }
}
```

<br/>

___

## Model distilation

Refer to [official documentation](https://platform.openai.com/docs/guides/distillation).

Model distillation involves using outputs (completions) from a large model to fine-tune a smaller model, enabling it to achieve similar performance for a specific task while reducing both cost and latency.

 1. Store outputs from the large model:
       - Generate high-quality results using a large model (e.g., o1-preview or gpt-4o) that meet your performance standards.
       - Use the store: true option and the metadata field in the Chat Completions API to save these results.
       - You can later view and filter these [stored completions through the dashboard](https://platform.openai.com/evaluations).
       
 2. Evaluate to establish a baseline:
       - Use the stored completions to assess the performance of both the large and small models using the evaluation product (evals).
       - Compare the results to measure the initial performance gap between the two models.
       
 3. Create a training dataset for fine-tuning:
       - Select the stored completions you want to use as training data for fine-tuning the smaller model.
       - Start a fine-tuning session by selecting the base snapshot (e.g., GPT-4o-mini). A few hundred samples may be enough, but a larger, more diverse set of thousands of examples can yield better results.

 4. Evaluate the fine-tuned small model:
       - Once fine-tuning is complete, run new evaluations to compare the fine-tuned model with the base small model and the large model.
       - Alternatively, store new completions generated by the fine-tuned model and evaluate them. Adjustments can be made to improve performance by: 
           - Increasing the diversity of the training data,
           - Refining prompts and outputs generated by the large model,
           - Improving evaluation criteria (graders).

By iteratively refining these elements, the smaller model can closely match the large model’s performance for specific tasks. Model distillation is a powerful method, but it is just one of many ways to optimize model outputs.

<br/>
