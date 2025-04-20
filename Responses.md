# Responses

- [Text generation](#text-generation)
    - [Non streamed](#non-streamed) 
    - [Streamed](#streamed)
    - [Multi-turn conversations](#multi-turn-conversations) 
    - [Parallel method for generating text](#parallel-method-for-generating-text)


<br>

___

## Text generation

This interface represents OpenAI’s most advanced environment for driving model-generated responses. It supports both text and image inputs and outputs, and enables chaining interactions by automatically feeding the results of one turn back into the next. A suite of built-in tools (file exploration, web searches, system command execution, etc.) enhances the model’s capabilities. Additionally, function calls allow access to external systems and data to enrich interactions. Note: if the `store` parameter is not specified in the request, its default value is `true`.

### Non streamed

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

    TutorialHub.JSONRequestClear;

  //Asynchronous example
  Client.Responses.AsynCreate(
    procedure (Params: TResponsesParams)
    begin
      Params.Model('gpt-4.1-mini');
      Params.Input('What is the difference between a mathematician and a physicist?');
      //Params.Store(False);  // Response not stored
      TutorialHub.JSONRequest := Params.ToFormat();
    end,
    function : TAsynResponse
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess :=
        procedure (Sender: TObject; Response: TResponse)
        begin
          Display(Sender, Response);
          Ids.Add(Response.Id);
        end;
      Result.OnError := Display;
    end);

  //Synchronous example
//  var Value := Client.Responses.Create(
//    procedure (Params: TResponsesParams)
//    begin
//      Params.Model('gpt-4.1-mini');
//      Params.Input('What is the difference between a mathematician and a physicist?');
//      //Params.Store(False);  // Response not stored
//      TutorialHub.JSONRequest := Params.ToFormat();
//    end);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

<br>

>[!IMPORTANT]
> - Param.store to store the response (Refer to [CRUD section](#crud-operations-on-saved-chat-completions)) 
> - Stored response can be retrieved from the [Plateform Dashboard](https://platform.openai.com/logs?api=responses)

<br>

By using the GenAI.Tutorial.VCL unit along with the initialization described [above](#Strategies-for-quickly-using-the-code-examples), you can achieve results similar to the example shown below.

![Preview](../blob/main/images/GenAIResponseRequest.png?raw=true "Preview")

<br>

