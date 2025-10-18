# Legacy

- [Completion](#completion)
- [Streamed completion](#streamed-completion)

___

For practical purposes, **completion APIs** can be utilized through `GenAI`, enabling the use of models such as ***gpt-3.5-turbo-instruct***, among others. However, the assistant system in Beta 1 is not supported by `GenAI`.

<br>

## Completion

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  //Asynchronous example
  Client.Completion.AsynCreate(
    procedure (Params: TCompletionParams)
    begin
      Params.Model('gpt-3.5-turbo-instruct');
      Params.Prompt('Give a simple explanation of what curiosity is, in one short sentence.');
      Params.Logprobs(5);
      Params.MaxTokens(96);
      TutorialHub.JSONRequest := Params.ToFormat();
    end,
    function : TAsynCompletion
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);

  //Synchronous example
//  var Value := Client.Completion.Create(
//    procedure (Params: TCompletionParams)
//    begin
//      Params.Model('gpt-3.5-turbo-instruct');
//      Params.Prompt('Give a simple explanation of what curiosity is, in one short sentence.');
//      Params.Logprobs(5);
//      Params.MaxTokens(96);
//      TutorialHub.JSONRequest := Params.ToFormat();
//    end);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```
<br>

___

## Streamed completion

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  //Asynchronous example
  Client.Completion.AsynCreateStream(
    procedure (Params: TCompletionParams)
    begin
      Params.Model('gpt-3.5-turbo-instruct');
      Params.Prompt('Say this is a test');
      Params.MaxTokens(96);
      Params.Stream;
      TutorialHub.JSONRequest := Params.ToFormat();
    end,
    function : TAsynCompletionStream
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnProgress := DisplayStream;
      Result.OnError := Display;
      Result.OnDoCancel := DoCancellation;
      Result.OnCancellation := Cancellation;
    end);

  //Synchronous example
//  var Value := Client.Completion.CreateStream(
//    procedure (Params: TCompletionParams)
//    begin
//      Params.Model('gpt-3.5-turbo-instruct');
//      Params.Prompt('Say this is a test');
//      Params.MaxTokens(96);
//      Params.Stream;
//      TutorialHub.JSONRequest := Params.ToFormat();
//    end,
//    procedure (var Data: TCompletion; IsDone: Boolean; var Cancel: Boolean)
//    begin
//      if Assigned(Data) and not IsDone then
//        DisplayStream(TutorialHub, Data);
//    end);
```