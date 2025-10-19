# Models

- [List of models](#list-of-models)
- [Retrieve a model](#retrieve-a-model)
- [Delete a model](#delete-a-model)
- [Model distilation](#model-distilation)

___

Refert to [official documentation](https://platform.openai.com/docs/models).

## List of models

The list of available models can be retrieved from the Models API response. The models are ordered by release date, with the most recently published appearing first.

```pascal
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.JSONRequestClear;

  //Asynchronous example
  Client.Models.AsynList(
    function : TAsynModels
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);

  //Synchronous example
//  var Value := Client.Models.List;
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;

  //Asynchronous promise example
//  var Promise := Client.Models.AsyncAwaitList;
//
//  Promise
//    .&Then<TModels>(
//      function (Value: TModels): TModels
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

## Retrieve a model

Retrieve a model using its ID.

```pascal
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.JSONRequestClear;
  TutorialHub.ModelId := '...the id tio retrieve...';

  //Asynchronous example
  Client.Models.AsynRetrieve(TutorialHub.ModelId,
    function : TAsynModel
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);

  //Synchronous example
//  var Value := Client.Models.Retrieve(TutorialHub.ModelId);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;

  //Asynchronous promise example
//  var Promise := Client.Models.AsyncAwaitRetrieve(TutorialHub.ModelId);
//
//  Promise
//    .&Then<string>(
//      function (Value: TModel): string
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

## Delete a model

Deleting a model is only possible if the model is one of your fine-tuned models.

```pascal
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.JSONRequestClear;
  TutorialHub.ModelId := '...Id of the model to delete...';

  //Asynchronous example
  Client.Models.AsynDelete(TutorialHub.ModelId,
    function : TAsynDeletion
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);

  //Synchronous example
//  var Value := Client.Models.Delete(TutorialHub.ModelId);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;

  //Asynchronous promise example
//  var Promise := Client.Models.AsyncAwaitDelete(TutorialHub.ModelId);
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

<br/>

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
