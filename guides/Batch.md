# Batch

- [Batch create](#batch-create)
- [Batch List](#batch-list)
- [Batch retrieve](#batch-retrieve)
- [Batch cancel](#batch-cancel)
- [Batch output viewer](#batch-output-viewer)

___

Create large batches of API requests for asynchronous processing. The Batch API returns completions within 24 hours for a 50% discount. Related guide: [Batch](https://platform.openai.com/docs/guides/batch)

<br/>

## Batch create

Creates and executes a batch from an uploaded file of requests.

For our example, the contents of the batch JSONL file are as follows :

BatchExample.jsonl
```JSON
{"custom_id": "request-1", "method": "POST", "url": "/v1/chat/completions", "body": {"model": "gpt-4o-mini", "messages": [{"role": "system", "content": "You are a helpful assistant."}, {"role": "user", "content": "What is 2+2?"}]}}
{"custom_id": "request-2", "method": "POST", "url": "/v1/chat/completions", "body": {"model": "gpt-4o-mini", "messages": [{"role": "system", "content": "You are a helpful assistant."}, {"role": "user", "content": "What is the topology definition?"}]}}
```

Use the [File upload](Files.md#file-upload) method and get the ID referring to the JSONL file.

<br/>

Now create the batch as follow :

```pascal
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

## Batch List

List your organization's batches.

```pascal
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

```pascal
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

## Batch retrieve

Retrieves a batch using its ID.

```pascal
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

## Batch cancel

Cancels an in-progress batch. The batch will be in status `cancelling` for up to 10 minutes, before changing to `cancelled`, where it will have partial results (if any) available in the output file.

```pascal
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

## Batch output viewer

Open and view the results obtained after processing the batch.

```pascal
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
