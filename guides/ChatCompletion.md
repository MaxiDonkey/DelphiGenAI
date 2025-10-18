# Chat completion

- [Text generation](#text-generation)
    - [Non streamed](#non-streamed) 
    - [Streamed](#streamed)
    - [Multi-turn conversations](#multi-turn-conversations) 
    - [Parallel method for generating text](#parallel-method-for-generating-text)
    - [CRUD operations on saved chat completions](#crud-operations-on-saved-chat-completions)
        - [Get chat completion](#get-chat-completion)
        - [Get chat messages](#get-chat-messages)
        - [List chat completions](#list-chat-completions)
        - [Update chat completion](#update-chat-completion)
        - [Delete chat completion](#delete-chat-completion)
- [Generating Audio Responses with Chat](#generating-audio-responses-with-chat)
- [Input Audio for Chat](#input-audio-for-chat)
    - [Audio and Text to Text](#audio-and-text-to-text)
    - [Audio to Audio](#audio-to-audio)
    - [Audio multi-turn conversations](#audio-multi-turn-conversations)
- [Vision](#vision)
    - [Analyze single source](#analyze-single-source)
    - [Analyze multi-source](#analyze-multi-source)
    - [Low or high fidelity image understanding](#low-or-high-fidelity-image-understanding)
- [Reasoning with o1, o3 or o4](#reasoning-with-o1-o3-or-o4)
- [Web search](#web-search)
- [Function calling](#function-calling)

<br>

___

## Text generation

You can send a structured list of input messages containing only text content, and the model will generate the next message in the conversation.

The Chat API can be used for both single-turn requests and multi-turn, stateless conversations.

>[!IMPORTANT]
>The `async/await` methods were introduced on the ***v1/chat/completion*** endpoint. Below you’ll find two examples: one for non-streamed responses and one for streamed responses.
>
>OpenAI maintains this endpoint solely for backward compatibility and does not plan any major updates. Consequently, we’ve provided only these two examples for `async/await`. It’s up to you to integrate these methods into your own code—using the ***v1/responses*** examples, with a few minor adjustments, is a great place to start.

### Non streamed

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.JSONRequestClear;

  //Asynchronous example
  Client.Chat.AsynCreate(
    procedure (Params: TChatParams)
    begin
      Params.Model('gpt-4o');
      Params.Messages([
        FromSystem('You are a comedian looking for jokes for your new show.'),
        FromUser('What is the difference between a mathematician and a physicist?')
      ]);
      //Params.Store(True);  // to store chat completion
      TutorialHub.JSONRequest := Params.ToFormat(); //to display JSON Request
    end,
    function : TAsynChat
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);

  //Synchronous example
//  var Value := Client.Chat.Create(
//    procedure (Params: TChatParams)
//    begin
//      Params.Model('gpt-4o');
//      Params.Messages([
//        FromSystem('You are a comedian looking for jokes for your new show.'),
//        FromUser('What is the difference between a mathematician and a physicist?')
//      ]);
//      //Params.Store(True);  // to store chat completion
//      TutorialHub.JSONRequest := Params.ToFormat();
//    end);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;

  //Asynchronous promise example
//  Display(TutorialHub, 'This may take a few seconds.');
//  var Promise := Client.Chat.AsyncAwaitCreate(
//    procedure (Params: TChatParams)
//    begin
//      Params.Model('gpt-4o');
//      Params.Messages([
//        FromSystem('You are a comedian looking for jokes for your new show.'),
//        FromUser('What is the difference between a mathematician and a physicist?')
//      ]);
//      Params.MaxCompletionTokens(1024);
//      Params.Store(False);
//      TutorialHub.JSONRequest := Params.ToFormat();
//    end);
//
//  promise
//    .&Then<string>(
//      function (Value: TChat): string
//      begin
//        for var Item in Value.Choices do
//          Result := Result + Item.Message.Content;
//        Display(TutorialHub, Value);
//        ShowMessage(Result);
//      end)
//    .&Catch(
//      procedure (E: Exception)
//      begin
//        Display(TutorialHub, E.Message);
//      end);
```
<br>

>[!IMPORTANT]
> - Param.store to store the chat completion (Refer to [CRUD section](#crud-operations-on-saved-chat-completions)) 
> - Stored completions can be retrieved from the [Plateform Dashboard](https://platform.openai.com/logs?api=chat-completions)

<br>

By using the GenAI.Tutorial.VCL unit along with the initialization described [above](https://github.com/MaxiDonkey/DelphiGenAI?tab=readme-ov-file#strategies-for-quickly-using-the-code-examples), you can achieve results similar to the example shown below.

<p align="center">
  <img src="https://github.com/MaxiDonkey/DelphiGenAI/blob/main/images/GenAIChatRequest.png?raw=true" width="700"/>
</p>

<br>

### Streamed

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.JSONRequestClear;

  //Asynchronous example
  Client.Chat.AsynCreateStream(
    procedure(Params: TChatParams)
    begin
      Params.Model('gpt-4.1-mini');
      Params.Messages([
          FromSystem('You are a comedian looking for jokes for your new show.'),
          FromUser('What is the difference between a mathematician and a physicist?')]);
      //Params.Store(True);  // to store chat completion
      Params.Stream;
      TutorialHub.JSONRequest := Params.ToFormat(); //to display JSON Request
    end,
    function : TAsynChatStream
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnProgress := DisplayStream;
      Result.OnError := Display;
      Result.OnDoCancel := DoCancellation;
      Result.OnCancellation := Cancellation;
    end);

  //Synchronous example
//  Client.Chat.CreateStream(
//    procedure (Params: TChatParams)
//    begin
//      Params.Model('gpt-4.1-mini');
//      Params.Messages([
//          Payload.System('You are a comedian looking for jokes for your new show.'),
//          Payload.User('What is the difference between a mathematician and a physicist?')]);
//      //Params.Store(True);  // to store chat completion
//      Params.Stream;
//      TutorialHub.JSONRequest := Params.ToFormat();
//    end,
//    procedure (var Chat: TChat; IsDone: Boolean; var Cancel: Boolean)
//    begin
//      if (not IsDone) and Assigned(Chat) then
//        begin
//          DisplayStream(TutorialHub, Chat);
//        end;
//    end);

  //Asynchronous promise example
//  var Promise := Client.Chat.AsyncAwaitCreateStream(
//    procedure(Params: TChatParams)
//    begin
//      Params.Model('gpt-4.1-nano');
//      Params.Messages([
//          FromDeveloper('You are a funny domestic assistant.'),
//          FromUser('Hello'),
//          FromAssistant('Great to meet you. What would you like to know?'),
//          FromUser('I have two dogs in my house. How many paws are in my house?')
//      ]);
//      Params.Stream;
//      Params.Store(False);
//      TutorialHub.JSONRequest := Params.ToFormat();
//    end,
//    function : TPromiseChatStream
//    begin
//      Result.Sender := TutorialHub;
//      Result.OnStart := Start;
//
//      Result.OnProgress :=
//        procedure (Sender: TObject; Chunk: TChat)
//        begin
//          DisplayStream(Sender, Chunk);
//        end;
//
//      Result.OnDoCancel := DoCancellation;
//
//      Result.OnCancellation :=
//        function (Sender: TObject): string
//        begin
//          Cancellation(Sender);
//        end
//    end);
//
//  Promise
//    .&Then<string>(
//      function (Value: string): string
//      begin
//        Result := Value;
//        ShowMessage(Result);
//      end)
//    .&Catch(
//      procedure (E: Exception)
//      begin
//        Display(TutorialHub, E.Message);
//      end);
```

<p align="center">
  <img src="https://github.com/MaxiDonkey/DelphiGenAI/blob/main/images/GenAIChatStreamedRequest.png?raw=true" width="700"/>
</p>

<br>

### Multi-turn conversations

The `GenAI Chat API` enables the creation of interactive chat experiences tailored to your users' needs. Its chat functionality supports multiple rounds of questions and answers, allowing users to gradually work toward solutions or receive help with complex, multi-step issues. This capability is especially useful for applications requiring ongoing interaction, such as:

- **Chatbots**
- **Educational tools**
- **Customer support assistants**

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.JSONRequestClear;

  //Asynchronous example
  Client.Chat.AsynCreateStream(
    procedure(Params: TChatParams)
    begin
      Params.Model('gpt-4.1-nano');
      Params.Messages([
          FromDeveloper('You are a funny domestic assistant.'),
          FromUser('Hello'),
          FromAssistant('Great to meet you. What would you like to know?'),
          FromUser('I have two dogs in my house. How many paws are in my house?') ]);
      Params.MaxCompletionTokens(1024);
      Params.Stream;
      TutorialHub.JSONRequest := Params.ToFormat(); //to display JSON Request
    end,
    function : TAsynChatStream
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnProgress := DisplayStream;
      Result.OnError := Display;
      Result.OnDoCancel := DoCancellation;
      Result.OnCancellation := Cancellation;
    end);

  //Synchronous example
//  Client.Chat.CreateStream(
//    procedure (Params: TChatParams)
//    begin
//      Params.Model('gpt-4.1-nano');
//      Params.Messages([
//          FromDeveloper('You are a funny domestic assistant.'),
//          FromUser('Hello'),
//          FromAssistant('Great to meet you. What would you like to know?'),
//          FromUser('I have two dogs in my house. How many paws are in my house?') ]);
//      Params.MaxCompletionTokens(1024);
//      Params.Stream;
//      TutorialHub.JSONRequest := Params.ToFormat();
//    end,
//    procedure (var Chat: TChat; IsDone: Boolean; var Cancel: Boolean)
//    begin
//      if (not IsDone) and Assigned(Chat) then
//        begin
//          DisplayStream(TutorialHub, Chat);
//        end;
//    end);
```

>[!TIP]
>The `FromUser` and `FromAssistant` methods simplify role management and enhance code readability, eliminating the need to use **TMessagePayload** (e.g., **TMessagePayload.User('Hello'))**. Similarly, `FromDeveloper`, `FromSystem`, and `FromTool` improve code clarity. For details on these methods and their configurations, refer to the `GenAI.pas` unit.
>

<br>

### Parallel method for generating text

This approach enables the simultaneous execution of multiple prompts, provided they are all processed by the same model. It also supports parallel web requests.

#### Example 1 : Two prompts processed in parallel.

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

    Client.Chat.CreateParallel(
    procedure (Params: TBundleParams)
    begin
      Params.Prompts([
        'How many television channels were there in France in 1980?',
        'How many TV channels were there in Germany in 1980?.'
      ]);
      Params.System('Write the response in capital letters.');
      Params.Model('gpt-4o-mini');
    end,
    function : TAsynBundleList
    begin
      Result.Sender := TutorialHub;

      Result.OnStart :=
        procedure (Sender: TObject)
        begin
          Display(Sender, 'Start the job' + sLineBreak);
        end;

      Result.OnSuccess :=
        procedure (Sender: TObject; Bundle: TBundleList)
        begin
          // Background bundle processing
          for var Item in Bundle.Items do
            begin
              Display(Sender, 'Index : ' + Item.Index.ToString);
              Display(Sender, 'FinishIndex : ' + Item.FinishIndex.ToString);
              Display(Sender, Item.Prompt + sLineBreak);
              Display(Sender, Item.Response + sLineBreak + sLineBreak);
              // or Display(Sender, TChat(Item.Chat).Choices[0].Message.Content);
            end;
        end;

      Result.OnError := Display;
    end)
```

You can also use reasoning models in parallel processing: <br> 

```Delphi
...
   Params.Prompts([
        'How many television channels were there in France in 1980?',
        'How many TV channels were there in Germany in 1980?.'
      ]);
      Params.Model('o4-mini');
      Params.ReasoningEffort('high');
    end,
...
```

<br>

#### Example 2 : Three web search processed in parallel.

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

    Client.Chat.CreateParallel(
    procedure (Params: TBundleParams)
    begin
      Params.Prompts([
        'What is the current date and time in Paris, France?',
        'What''s the news in the USA today?',
        'What''s new in Berlin today?'
      ]);
      Params.Model('gpt-4o-search-preview');
      Params.SearchSize('medium');
      Params.Country('FR');
      Params.City('Reims');
    end,
    function : TAsynBundleList
    begin
      Result.Sender := TutorialHub;

      Result.OnStart :=
        procedure (Sender: TObject)
        begin
          Display(Sender, 'Start the job' + sLineBreak);
        end;

      Result.OnSuccess :=
        procedure (Sender: TObject; Bundle: TBundleList)
        begin
          // Background bundle processing
          for var Item in Bundle.Items do
            begin
              Display(Sender, 'Index : ' + Item.Index.ToString);
              Display(Sender, 'FinishIndex : ' + Item.FinishIndex.ToString);
              Display(Sender, Item.Prompt + sLineBreak);
              Display(Sender, Item.Response + sLineBreak + sLineBreak);
              // or Display(Sender, TChat(Item.Chat).Choices[0].Message.Content);
            end;
        end;

      Result.OnError := Display;
    end)
```
<br>

### CRUD operations on saved chat completions

>
>CRUD = `C`reate `R`ead `U`pdate `D`elete
>

#### Why CRUD on chat completions ?

- **Traceability and Auditing:**  Being able to save, update, and delete responses directly from your wrapper makes it easier to manage the conversation history on both the client and server sides.

- **Business Scenarios:** For example, in a support assistant integrated into a Delphi application, it’s a real advantage to have an identifier—and the ability to correct or annotate—each generated response.

<br>

#### Get chat completion

Get a stored chat completion. Only [Chat Completions](#text-generation) that have been created with the `store` parameter set to `true` will be returned. Refer to [official documentation.](https://platform.openai.com/docs/api-reference/chat/get)

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.JSONRequestClear;

  //Asynchronous example
  Client.Chat.AsynGetCompletion('completion_id',   //e.g. 'chatcmpl-BO9ybVceB3aXFyMRKR3MKUEzWcFqE'
    function : TAsynChat
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);

  //Synchronous example
//  var Value := Client.Chat.GetCompletion('completion_id');   //e.g. 'chatcmpl-BO9ybVceB3aXFyMRKR3MKUEzWcFqE'
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;

  //Asynchronous promise example
//  var Promise := Client.Chat.AsyncAwaitGetCompletion('completion_id');   //e.g. 'chatcmpl-BO9ybVceB3aXFyMRKR3MKUEzWcFqE'
//
//  promise
//    .&Then<TChat>(
//      function (Value: TChat): TChat
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

<br>

#### Get chat messages

Get the messages in a stored chat completion. Only [Chat Completions](#text-generation) that have been created with the `store` parameter set to `true` will be returned. Refer to [official documentation.](https://platform.openai.com/docs/api-reference/chat/getMessages)

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.JSONRequestClear;

  //Asynchronous example
  Client.Chat.AsynGetMessages('completion_id',   //e.g. 'chatcmpl-BO9ybVceB3aXFyMRKR3MKUEzWcFqE'
    procedure (Param: TUrlChatParams)
    begin
      Param.Limit(15);
      Param.Order('asc');
    end,
    function : TAsynChatMessages
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);

  //Synchronous example
//  var Value := Client.Chat.GetMessages('completion_id',   //e.g. 'chatcmpl-BO9ybVceB3aXFyMRKR3MKUEzWcFqE'
//    procedure (Param: TUrlChatParams)
//    begin
//      Param.Limit(15);
//      Param.Order('asc')
//    end);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;

  //Asynchronous promise example
//  var Promise := Client.Chat.AsyncAwaitGetMessages(
//    'completion_id',   //e.g. 'chatcmpl-BO9ybVceB3aXFyMRKR3MKUEzWcFqE',
//    procedure (Param: TUrlChatParams)
//    begin
//      Param.Limit(15);
//      Param.Order('asc');
//    end);
//
//  promise
//    .&Then<TChatMessages>(
//      function (Value: TChatMessages): TChatMessages
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

<br>

#### List chat completions

List stored Chat Completions. Only [Chat Completions](#text-generation) that have been stored with the `store` parameter set to `true` will be returned. Refer to [official documentation.](https://platform.openai.com/docs/api-reference/chat/list)

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.JSONRequestClear;

  //Asynchronous example
  Client.Chat.AsynList(
    procedure (Params: TUrlChatListParams)
    begin
      Params.Limit(15);
    end,
    function : TAsynChatCompletion
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);


  //Synchronous example
//  var Value := Client.Chat.List(
//    procedure (Params: TUrlChatListParams)
//    begin
//      Params.Limit(15)
//    end);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;

  //Asynchronous promise example
//  var Promise := Client.Chat.AsyncAwaitList(
//    procedure (Params: TUrlChatListParams)
//    begin
//      Params.Limit(15);
//    end);
//
//  promise
//    .&Then<TChatCompletion>(
//      function (Value: TChatCompletion): TChatCompletion
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

<br>

#### Update chat completion

Modify a stored chat completion. Only [Chat Completions](#text-generation) that have been created with the `store` parameter set to `true` can be modified. Currently, the only supported modification is to update the `metadata` field. Refer to [official documentation.](https://platform.openai.com/docs/api-reference/chat/update)

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.JSONRequestClear;

  //Asynchronous example
  Client.Chat.AsynUpdate('completion_id',   //e.g. 'chatcmpl-BO9ybVceB3aXFyMRKR3MKUEzWcFqE'
    procedure (Params: TChatUpdateParams)
    begin
      Params.Metadata(TJSONObject.Create.AddPair('foo', 'bar'));
      TutorialHub.JSONRequest := Params.ToFormat();
    end,
    function : TAsynChat
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);

  //Synchronous example
//  var Value := Client.Chat.Update('completion_id',   //e.g. 'chatcmpl-BO9ybVceB3aXFyMRKR3MKUEzWcFqE'
//    procedure (Params: TChatUpdateParams)
//    begin
//      Params.Metadata(TJSONObject.Create.AddPair('foo', 'bar'));
//      TutorialHub.JSONRequest := Params.ToFormat();
//    end);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;

  //Asynchronous promise example
//  var Promise := Client.Chat.AsyncAwaitUpdate(
//    'completion_id',   //e.g. 'chatcmpl-BO9ybVceB3aXFyMRKR3MKUEzWcFqE'
//    procedure (Params: TChatUpdateParams)
//    begin
//      Params.Metadata(TJSONObject.Create.AddPair('foo1', 'bar1'));
//      TutorialHub.JSONRequest := Params.ToFormat();
//    end);
//
//  promise
//    .&Then<TChat>(
//      function (Value: TChat): TChat
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

<br>

#### Delete chat completion

Delete a stored chat completion. Only [Chat Completions](#text-generation) that have been created with the `store` parameter set to `true` can be deleted. Refer to [official documentation.](https://platform.openai.com/docs/api-reference/chat/delete)

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.JSONRequestClear;

  //Asynchronous example
  Client.Chat.AsynDelete('completion_id',   //e.g. 'chatcmpl-BO9ybVceB3aXFyMRKR3MKUEzWcFqE'
    function : TAsynChatDelete
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);

  //Synchronous example
//  var Value := Client.Chat.Delete('completion_id');   //e.g. 'chatcmpl-BO9ybVceB3aXFyMRKR3MKUEzWcFqE'
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;

  //Asynchronous promise example
//  var Promise := Client.Chat.AsyncAwaitDelete('completion_id');   //e.g. 'chatcmpl-BO9ybVceB3aXFyMRKR3MKUEzWcFqE'
//
//  promise
//    .&Then<TChatDelete>(
//      function (Value: TChatDelete): TChatDelete
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

<br>

___

## Generating Audio Responses with Chat

Beyond generating text and images, certain models enable the creation of spoken audio responses from prompts and the use of audio inputs to interact with the model. Audio inputs can provide richer information than text alone, allowing the model to capture tone, inflection, and other nuances.

These audio features can be leveraged to:

- Produce a spoken audio summary from a text body (text input, audio output)
- Conduct sentiment analysis on an audio recording (audio input, text output)
- Facilitate asynchronous speech-to-speech interactions with the model (audio input, audio output)

For example, the `GPT-4o-Audio-Preview` model can process audio both as input and output. Please note, this model does not have vision capability.

Refer to official [documentation](https://platform.openai.com/docs/guides/audio?example=audio-out).

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;
  
  TutorialHub.JSONRequestClear;
  TutorialHub.FileName := 'AudioResponse.mp3';

  //Asynchronous example
  Client.Chat.AsynCreate(
    procedure (Params: TChatParams)
    begin
      Params.Model('gpt-4o-audio-preview');
      Params.Modalities(['text', 'audio']);
      Params.Audio('ballad', 'mp3');
      Params.Messages([
        FromUser('Is a golden retriever a good family dog?')
      ]);
      Params.MaxCompletionTokens(1024);
      TutorialHub.JSONRequest := Params.ToFormat(); //to display JSON Request
    end,
    function : TAsynChat
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := DisplayAudio;
      Result.OnError := Display;
    end);

  //Synchronous example
//  var Value := Client.Chat.Create(
//    procedure (Params: TChatParams)
//    begin
//      Params.Model('gpt-4o-audio-preview');
//      Params.Modalities(['text', 'audio']);
//      Params.Audio('ash', 'mp3');
//      Params.Messages([
//        FromUser('Is a golden retriever a good family dog?')
//      ]);
//      Params.MaxCompletionTokens(1024)
//      TutorialHub.JSONRequest := Params.ToFormat();
//    end);
//  try
//    DisplayAudio(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

>[!NOTE]
>  The **Params.Audio('ash', 'mp3')** function allows you to select the output voice and specify the desired audio data format.
>
>  About **Params.Modalities(['text', 'audio'])**; modalities supported by gpt-4o-audio-preview**
>   - text in → text + audio out
>   - audio in → text + audio out
>   - audio in → text out
>   - text + audio in → text + audio out
>   - text + audio in → text out 

<br>

Let’s take a closer look at how the `DisplayAudio` method handles output to understand how the model’s response is managed.

```Delphi
procedure DisplayAudio(Sender: TObject; Value: TChat);
begin
  {--- Display the JSON response }
  TutorialHub.JSONResponse := Value.JSONResponse;

  {--- We need an audio filename for the tutorial }
  if TutorialHub.FileName.IsEmpty then
    raise Exception.Create('Set filename value in HFTutorial instance');

  {--- Store the audio Id. }
  TutorialHub.AudioId := Value.Choices[0].Message.Audio.Id;

  {--- Store the audio transcript. }
  TutorialHub.Transcript := Value.Choices[0].Message.Audio.Transcript;

  {--- The audio response is stored in a file. }
  Value.Choices[0].Message.Audio.SaveToFile(TutorialHub.FileName);

  {--- Display the textual response. }
  Display(Sender, Value.Choices[0].Message.Audio.Transcript);

  {--- Play audio response. }
  TutorialHub.PlayAudio;
  Display(Sender, sLineBreak);
end;
```

`GenAI` provides methods to handle audio responses generated by the model. The `SaveToFile` and `GetStream` methods enable the manipulation of received audio content.

<br>

___

## Input Audio for Chat

Refer to official [documentation](https://platform.openai.com/docs/guides/audio?example=audio-in).

### Audio and Text to Text

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.JSONRequestClear;
  var Ref := 'https://cdn.openai.com/API/docs/audio/alloy.wav';

  //Asynchronous example
  Client.Chat.ASynCreate(
    procedure (Params: TChatParams)
    begin
      Params.Model('gpt-4o-audio-preview');
      Params.Modalities(['text']); 
      Params.Messages([
        FromUser('What is in this recording?', [Ref])
      ]);
      Params.MaxCompletionTokens(1024);
      TutorialHub.JSONRequest := Params.ToFormat();
    end,
    function : TAsynChat
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display; 
      Result.OnError := Display;
    end);

  //Synchronous example
//  var Value := Client.Chat.Create(
//    procedure (Params: TChatParams)
//    begin
//      Params.Model('gpt-4o-audio-preview');
//      Params.Modalities(['text']);
//      Params.Messages([
//        FromUser('What is in this recording?', [Ref])
//      ]);
//      Params.MaxCompletionTokens(1024);
//      TutorialHub.JSONRequest := Params.ToFormat();
//    end);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

### Audio to Audio

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.JSONRequestClear;
  TutorialHub.FileName := 'Response.mp3';

  //Asynchronous example
  Client.Chat.ASynCreate(
    procedure (Params: TChatParams)
    begin
      Params.Model('gpt-4o-audio-preview');
      Params.Modalities(['text', 'audio']);
      Params.Audio('ash', 'mp3');
      Params.Messages([
        FromUser(['SpeechRecorded.mp3'])
      ]);
      Params.MaxCompletionTokens(1024);
      TutorialHub.JSONRequest := Params.ToFormat();
    end,
    function : TAsynChat
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := DisplayAudio;
      Result.OnError := Display;
    end);

  //Synchronous example
//  var Value := Client.Chat.Create(
//    procedure (Params: TChatParams)
//    begin
//      Params.Model('gpt-4o-audio-preview');
//      Params.Modalities(['text', 'audio']);
//      Params.Audio('ash', 'mp3');
//      Params.Messages([
//        FromUser(['SpeechRecorded.mp3'])
//      ]);
//      Params.MaxCompletionTokens(1024);
//      TutorialHub.JSONRequest := Params.ToFormat();
//    end);
//  try
//    DisplayAudio(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

<br>

>[!WARNING]
> OpenAI provides other models for simple speech to text and text to speech - when your task requires those conversions (and not dynamic content from a model), the `TTS` and `STT` models will be more performant and cost-efficient.

<br>

### Audio multi-turn conversations

TutorialHub retains the ID of the most recent audio response. To proceed, simply construct the message as follows:

```Delphi
  ...
    procedure (Params: TChatParams)
    begin
      Params.Model('gpt-4o-audio-preview');
      Params.Modalities(['text', 'audio']);
      Params.Audio('ash', 'mp3');
      Params.Messages([
        FromUser('Is a golden retriever a good family dog?'),
        FromAssistantAudioId(TutorialHub.AudioId),   //or FromAssistantAudioId(TutorialHub.Transcript),
        FromUser('Why do you say they are loyal?')
      ]);
  ...
```

The `message.audio.id` value above provides an identifier that you can use in an assistant message for a new `/chat/completions` request, as in the example above.

It is also possible to omit the audio ID and use the associated text via `Message.Audio.Transcript` instead. However, the model will not be able to analyze the emotions contained in the audio portion of the message.

>[!CAUTION]
>Of course, this is just a simple example. TutorialHub is designed solely to showcase `GenAI`. In a more general scenario, it would be necessary to maintain a history of **audio IDs** to accurately build the conversation history.

<br>

___

## Vision

Refer to the [official documentation](https://platform.openai.com/docs/guides/vision).

### Analyze single source

`GenAI` processes images from both web sources and local files uniformly. It manages the submission of the source to the API, thereby simplifying the developer's task. Therefore, in this example, we will handle sources in the form of a ***URL*** and ***base-64 encoded*** data.

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  var Url := 'https://upload.wikimedia.org/wikipedia/commons/thumb/d/dd/Gfp-wisconsin-madison-the-nature-boardwalk.jpg/2560px-Gfp-wisconsin-madison-the-nature-boardwalk.jpg';
  //var Ref := 'D:\My_folder\Images\My_image.png'; //This content will be encoded in base-64 by GenAI
  TutorialHub.JSONRequestClear;

  //Asynchronous example
  Client.Chat.AsynCreateStream(
    procedure (Params: TChatParams)
    begin
      Params.Model('gpt-4o-mini');
      Params.Messages([
        FromUser('What is in this image?', [Url])
        //FromUser('What is in this image?', [Ref])
      ]);
      Params.MaxCompletionTokens(1024);
      Params.Stream;
      TutorialHub.JSONRequest := Params.ToFormat();
    end,
    function : TAsynChatStream
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnProgress := DisplayStream;
      Result.OnError := Display;
      Result.OnDoCancel := DoCancellation;
      Result.OnCancellation := Cancellation;
    end);

  //Synchronous example
//  var Value := Client.Chat.CreateStream(
//    procedure (Params: TChatParams)
//    begin
//      Params.Model('gpt-4o-mini');
//      Params.Messages([
//        FromUser('What is in this image?', [Url])
//        //FromUser('What is in this image?', [Ref])
//      ]);
//      Params.MaxCompletionTokens(1024);
//      Params.Stream;
//      TutorialHub.JSONRequest := Params.ToFormat();
//    end,
//    procedure (var Chat: TChat; IsDone: Boolean; var Cancel: Boolean)
//    begin
//      if Assigned(Chat) and not IsDone then
//        DisplayStream(TutorialHub, Chat);
//    end);
```
This example uses streaming. The non-streamed version is straightforward to implement, so it is not covered here.

<br>

### Analyze multi-source

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  var Url1 := 'https://tripfixers.com/wp-content/uploads/2019/11/eiffel-tower-with-snow.jpeg';
  var Url2 := 'https://assets.visitorscoverage.com/production/wp-content/uploads/2024/04/AdobeStock_626542468-min-1024x683.jpeg';
  TutorialHub.JSONRequestClear;

  //Asynchronous example
  Client.Chat.AsynCreateStream(
    procedure (Params: TChatParams)
    begin
      Params.Model('gpt-4o-mini');
      Params.Messages([
        FromUser('What are the differences between two images?', [Url1, Url2])
      ]);
      Params.MaxCompletionTokens(1024);
      Params.Stream;
      TutorialHub.JSONRequest := Params.ToFormat();
    end,
    function : TAsynChatStream
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnProgress := DisplayStream;
      Result.OnError := Display;
      Result.OnDoCancel := DoCancellation;
      Result.OnCancellation := Cancellation;
    end);

  //Synchronous example
//  var Value := Client.Chat.CreateStream(
//    procedure (Params: TChatParams)
//    begin
//      Params.Model('gpt-4o-mini');
//      Params.Messages([
//        FromUser('What are the differences between two images?', [Url1, Url2])
//      ]);
//      Params.MaxCompletionTokens(1024);
//      Params.Stream;
//      TutorialHub.JSONRequest := Params.ToFormat();
//    end,
//    procedure (var Chat: TChat; IsDone: Boolean; var Cancel: Boolean)
//    begin
//      if Assigned(Chat) and not IsDone then
//        DisplayStream(TutorialHub, Chat);
//    end);
```

<br>

### Low or high fidelity image understanding

The detail parameter, which includes three options—**low**, **high**, and **auto**—allows you to customize how the model interprets the image and generates its textual representation. By default, the **auto** setting is applied, where the model evaluates the input image size and automatically selects either the **low** or **high** mode.

- **low mode** activates "low resolution" processing, where the model works with a 512px x 512px version of the image, represented using 85 tokens. This option is ideal for applications where speed and efficiency are prioritized over high detail, as it reduces response time and token consumption.

- **high mode** activates "high resolution" processing. Initially, the model examines the low-resolution image using 85 tokens, then refines its understanding by analyzing detailed segments of the image, dedicating 170 tokens per 512px x 512px tile. This mode is suited for cases requiring precise image details.

`GenAI` allows the addition of `detail=high` or `detail=low` directly in the URL, thereby simplifying the activation of the detail option as follows:

```Delphi
  var Url1 := 'https://tripfixers.com/.../eiffel-tower-with-snow.jpeg detail=high';
  //or
  var Url1 := 'https://tripfixers.com/.../eiffel-tower-with-snow.jpeg detail=low';
```

The same process is applied to the local file paths.

<br>

___

## Reasoning with o1, o3 or o4

**Advanced models for reasoning and problem-solving.**
Reasoning models, such as **OpenAI’s** `o1`, `o3` `o4-mini`, are large language models trained using reinforcement learning to handle complex reasoning tasks. These models “think” before generating a response by forming a detailed internal chain of reasoning. This approach allows them to excel in areas like advanced problem-solving, coding, scientific analysis, and multi-step planning within agent-driven workflows.

Similar to GPT models, they offer two options: a smaller, faster, and more cost-effective model (`o4-mini`) and a larger model (`o1`, `o3`) that, while slower and more expensive per token, often produces higher-quality responses for challenging tasks and demonstrates stronger generalization across various domains.

Since these models can require response times ranging from a few seconds to several tens of seconds, it is more prudent and efficient to use asynchronous methods when using them.

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.JSONRequestClear;

  //Asynchronous example
  Client.Chat.AsynCreateStream(
    procedure(Params: TChatParams)
    begin
      Params.Model('o4-mini');
      Params.Messages([
        FromUser('Write a bash script that takes a matrix represented as a string with format \"[1,2],[3,4],[5,6]\" and prints the transpose in the same format.')
      ]);
      Params.ReasoningEffort(TReasoningEffort.high);  //or Params.ReasoningEffort('high');
      Params.Stream;
      TutorialHub.JSONRequest := Params.ToFormat();
    end,
    function : TAsynChatStream
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnProgress := DisplayStream;
      Result.OnError := Display;
      Result.OnDoCancel := DoCancellation;
      Result.OnCancellation := Cancellation;
    end);
```

<br>

The OpenAI `o1`, `o3` and `o4` series models are highly capable across several advanced tasks, including:

- **Implementing complex algorithms and generating code:** For example, a prompt can instruct the o1 model to refactor a React component based on specific requirements.

- **Developing multi-step plans:** The models can create detailed plans, such as generating a complete filesystem structure and providing Python code that fulfills the given use case.

- **Supporting STEM research:** The models have demonstrated strong performance in scientific and technical research tasks, with prompts designed for basic research yielding highly effective results.

For more information, consult the [official documentation](https://platform.openai.com/docs/guides/reasoning).

<br>

___

## Web search

Now you can now search the web for the latest information before generating a response. With the chat completion API, you gain access to the same models and tools optimized for web search in ChatGPT.

When a request is sent via chat completion, the model automatically retrieves online information before formulating its response. However, if you want the web_search_preview tool to be used only when necessary, you should use the responses API instead.

Currently, only specific models support web search through chat completion:
- `gpt-4o-search-preview`
- `gpt-4o-mini-search-preview`

These models incorporate web search to deliver more accurate and up-to-date responses.

### Web search : code sample 1

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.JSONRequestClear;

  //Asynchronous example
  Client.Chat.AsynCreate(
    procedure (Params: TChatParams)
    begin
      Params.Model('gpt-4o-search-preview');
      Params.Messages([
        FromUser('What was a positive news story from today?')
      ]);
      TutorialHub.JSONRequest := Params.ToFormat();
    end,
    function : TAsynChat
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);

  //Synchronous example
//  var Value := Client.Chat.Create(
//    procedure (Params: TChatParams)
//    begin
//      Params.Model('gpt-4o-search-preview');
//      Params.Messages([
//        FromUser('What was a positive news story from today?')
//      ]);
//    end);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;  
```

<br>

### Output and citations

The choices element in the API response includes:
- **message.content:** The text generated by the model, with embedded citations referencing the sources.
- **annotations:** A list detailing the cited URLs.

By default, the model automatically incorporates citations from web search results. Additionally, each url_citation annotation provides specific details about the referenced source, including the URL, the page title, and the start and end character positions in the response where the citation appears.

```JSON
 [
        {
            "index": 0,
            "message": {
                "role": "assistant",
                "content": "As of March 12, 2025, a notable positive news story is the agreement between the United States and Ukraine on a 30-day ceasefire in the conflict with Russia. This development, announced on March 11, 2025, includes the resumption of U.S. military aid and intelligence sharing with Ukraine. U.S. Secretary of State Marco Rubio expressed hope that Russia would respond positively to the proposal, aiming for a swift transition to comprehensive negotiations. ([straitstimes.com](https:\/\/www.straitstimes.com\/world\/while-you-were-sleeping-5-stories-you-might-have-missed-march-12-2025?utm_source=openai))\n\nAdditionally, in Indonesia, authorities rescued a critically endangered two-month-old male Sumatran elephant that had become separated from its mother in a palm oil plantation. The calf was found in Riau province on Sumatra island and is now under the care of local conservation agencies. With only about 2,400-2,800 Sumatran elephants remaining, this rescue is a significant step toward the species' conservation. ([straitstimes.com](https:\/\/www.straitstimes.com\/world\/while-you-were-sleeping-5-stories-you-might-have-missed-march-12-2025?utm_source=openai))\n\nThese stories highlight ongoing efforts toward conflict resolution and wildlife conservation, reflecting positive developments in international relations and environmental protection. ",
                "refusal": null,
                "annotations": [
                    {
                        "type": "url_citation",
                        "url_citation": {
                            "end_index": 599,
                            "start_index": 455,
                            "title": "While You Were Sleeping: 5 stories you might have missed, March 12, 2025 | The Straits Times",
                            "url": "https:\/\/www.straitstimes.com\/world\/while-you-were-sleeping-5-stories-you-might-have-missed-march-12-2025?utm_source=openai"
                        }
                    },
                    {
                        "type": "url_citation",
                        "url_citation": {
                            "end_index": 1160,
                            "start_index": 1016,
                            "title": "While You Were Sleeping: 5 stories you might have missed, March 12, 2025 | The Straits Times",
                            "url": "https:\/\/www.straitstimes.com\/world\/while-you-were-sleeping-5-stories-you-might-have-missed-march-12-2025?utm_source=openai"
                        }
                    }
                ]
            },
            "finish_reason": "stop"
        }
 ]

```

<br>

### User location

To enhance search relevance based on geographic location, you can provide an approximate user location using details such as country, city, region, or timezone.
- **City and Region:** These are open-text fields where you can input values like *San Francisco* for the city and *California* for the region.
- **Country:** This follows the ISO 3166-1 alpha-2 standard, meaning it should be a two-letter country code like *FR* for France or *JP* for Japan.
- **Timezone:** Uses the IANA format, such as *Europe/Paris* or *Asia/Tokyo*, to specify the user's local time zone.

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;
  
  TutorialHub.JSONRequestClear;

  //Asynchronous example
  Client.Chat.AsynCreate(
    procedure (Params: TChatParams)
    begin
      Params.Model('gpt-4o-search-preview');
      Params.Messages([
        FromUser('What was a positive news story from today?')
      ]);
      Params.WebSearchOptions(
          TUserLocationApproximate.Create
            .City('London')
            .Country('GB')
            .Region('London')
        );
      TutorialHub.JSONRequest := Params.ToFormat();
    end,
    function : TAsynChat
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);

  //Synchronous example
//  var Value := Client.Chat.Create(
//    procedure (Params: TChatParams)
//    begin
//      Params.Model('gpt-4o-search-preview');
//      Params.Messages([
//        FromUser('What was a positive news story from today?')
//      ]);
//      Params.WebSearchOptions(
//          TUserLocationApproximate.Create
//            .City('London')
//            .Country('GB')
//            .Region('London')
//        );
//    end);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

<br>

### Search context size

The search_context_size parameter determines how much web context is retrieved to enhance responses. It does not affect the main model's token usage or carry over between interactions—its sole purpose is to generate the tool's reply.

Impact of Context Size:
- **Cost:** Larger contexts are more expensive. See pricing details.
- **Quality:** More context improves accuracy and depth.
- **Latency:** Bigger context means longer processing times.

Available Options:
- ***high*** – Most detailed, highest cost, slower.
- ***medium*** (default) – Balanced cost, speed, and quality.
- ***low*** – Fastest, cheapest, but may reduce accuracy.

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.JSONRequestClear;

  //Asynchronous example
  Client.Chat.AsynCreate(
    procedure (Params: TChatParams)
    begin
      Params.Model('gpt-4o-search-preview');
      Params.Messages([
        FromUser('What was a positive news story from today?')
      ]);
      Params.WebSearchOptions('high'); //or TSearchWebOptions.high
      TutorialHub.JSONRequest := Params.ToFormat();
    end,
    function : TAsynChat
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);

  //Synchronous example
//  var Value := Client.Chat.Create(
//    procedure (Params: TChatParams)
//    begin
//      Params.Model('gpt-4o-search-preview');
//      Params.Messages([
//        FromUser('What was a positive news story from today?')
//      ]);
//      Params.WebSearchOptions('high'); //or TSearchWebOptions.high
//    end);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

>[!NOTE]
> Context size and localization can be used simultaneously :
> ```Delphi
>    Params.WebSearchOptions(
>      'low',
>      TUserLocationApproximate.Create
>        .City('London')
>        .Country('GB')
>        .Region('London')
>    );
> ```

>[!WARNING]
> Web search can also be used with APIs designed for streaming. However, annotation data is not included in the returned chunks.

<br>

___

## Function calling

Allow models to access data and execute actions. <br/>
Function calling offers a robust and versatile method for OpenAI models to interact with your code or external services, serving two main purposes:

- **Data Retrieval:** Access real-time information to enhance the model's responses (RAG). This is particularly beneficial for searching knowledge bases and extracting specific data from APIs (e.g., obtaining the current weather).

- **Action Execution:** Carry out tasks such as form submissions, API calls, updating the application state (UI/frontend or backend), or executing agent-driven workflows (e.g., transferring a conversation).

Refer to the [official documentation](https://platform.openai.com/docs/guides/function-calling?example=get-weather).

<br/>

#### How build a plugin

Use case : **What’s the weather in Paris?**

In the `GenAI.Functions.Example` unit, there is a class that defines a function which OpenAI can choose to use or not, depending on the options provided. This class inherits from a parent class defined in the `GenAI.Functions.Core` unit. To create new functions, you can derive from the `TFunctionCore` class and define a new plugin.

#### Use a schema

In this unit, this schema will be used for function calls.
```Json
{
    "type": "object",
    "properties": {
         "location": {
             "type": "string",
             "description": "The city and department, e.g. Marseille, 13"
         },
         "unit": {
             "type": "string",
             "enum": ["celsius", "fahrenheit"]
         }
     },
     "required": ["location"],
     "additionalProperties": false
}
```

<br/>

We will use the TWeatherReportFunction plugin defined in the `GenAI.Functions.Example` unit.

```Delphi
  var Weather := TWeatherReportFunction.CreateInstance;
  //or
  var Weather := TWeatherReportFunction.CreateInstance(True);  //To activate `Strict` option

  //See step : Main method
```
<br/>

#### Methods to display result

We then define a method to display the result of the query using the Weather tool.

With this tutorial, a method is defined within TutorialHub. Let’s take a closer look at how this method works.

##### Display a stream text

```Delphi
procedure TVCLTutorialHub.DisplayWeatherStream(const Value: string);
begin
  //Asynchronous example
  Client.Chat.AsynCreateStream(
    procedure(Params: TChatParams)
    begin
      Params.Model('gpt-4o');
      Params.Messages([
          FromSystem('You are a weather presenter on a prime time TV channel.'),
          FromUser(Value)]);
      Params.MaxCompletionTokens(1024);
      Params.Stream;
    end,
    function : TAsynChatStream
    begin
      Result.Sender := TutorialHub;
      Result.OnProgress := DisplayStream;
      Result.OnError := Display;
      Result.OnDoCancel := DoCancellation;
      Result.OnCancellation := Cancellation;
    end);
end;
```

<br/>

##### Use audio with response

```Delphi
procedure TVCLTutorialHub.DisplayWeatherAudio(const Value: string);
begin
  FileName := 'AudioWeather.mp3';

  //Asynchronous example
  Client.Chat.AsynCreate(
    procedure (Params: TChatParams)
    begin
      Params.Model('gpt-4o-audio-preview');
      Params.Modalities(['text', 'audio']);
      Params.Audio('verse', 'mp3');
      Params.Messages([
        FromSystem('You are a weather presenter on a prime time TV channel.'),
        FromUser(Value)
      ]);
      Params.MaxCompletionTokens(1024);
    end,
    function : TAsynChat
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := DisplayAudio;
      Result.OnError := Display;
    end);
end;
```

<br/>

#### Main method

Building the query using the Weather tool. (Simply copy/paste this last code to test the usage of the functions.)

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL, GenAI.Functions.Example;

  TutorialHub.JSONRequestClear;
  var Weather := TWeatherReportFunction.CreateInstance(False);
//  TutorialHub.ToolCall := TutorialHub.DisplayWeatherStream;
// or
  TutorialHub.ToolCall := TutorialHub.DisplayWeatherAudio;
  TutorialHub.Tool := Weather;

  //Synchronous example
  var Value := Client.Chat.Create(
    procedure (Params: TChatParams)
    begin
      Params.Model('gpt-4o');
      Params.Messages([
        FromUser('What is the weather in Paris?')
      ]);
      Params.Tools([Weather]);
      Params.ToolChoice(TToolChoice.auto);
      Params.MaxCompletionTokens(1024);
      TutorialHub.JSONRequest := Params.ToFormat();
    end);
  try
    Display(TutorialHub, Value);
  finally
    Value.Free;
  end;
```

#### FinishReason

Let's look at how the display method handles the function call.

```Delphi
procedure Display(Sender: TObject; Value: TChat);
begin
  TutorialHub.JSONResponse := Value.JSONResponse;
  for var Item in Value.Choices do
    {--- Examine FinishReason }
    if Item.FinishReason = TFinishReason.tool_calls then
      begin
        if Assigned(TutorialHub.ToolCall) then
          begin
            for var Func in Item.Message.ToolCalls do
              begin
                Display(Sender, Func.&function.Arguments);
                var Evaluation := TutorialHub.Tool.Execute(Func.&function.Arguments);
                Display(Sender, Evaluation);
                Display(Sender);
                TutorialHub.ToolCall(Evaluation);
              end;
          end;
      end
    else
      begin
        Display(Sender, Item.Message.Content);
      end;
  Display(Sender, sLineBreak);
end;
```

<br/>

>[!WARNING]
>Ensure user confirmation for actions like sending emails or making purchases to avoid unintended consequences.

<br/>
