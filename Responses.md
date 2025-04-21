# Responses

- [Text generation](#text-generation)
    - [Non streamed](#non-streamed) 
    - [Streamed](#streamed)
    - [Multi-turn conversations](#multi-turn-conversations) 
    - [Parallel method for generating text](#parallel-method-for-generating-text)
    - [CRUD operations on saved responses](#crud-operations-on-saved-responses)
        - [Get a model response](#get-a-model-response)
        - [Delete a model response](#delete-a-model-response)
        - [List input items](#list-input-items)
- [Vision](#vision)
    - [Analyze single source](#analyze-single-source)
    - [Analyze multi-source](#analyze-multi-source)
    - [Low or high fidelity image understanding](#low-or-high-fidelity-image-understanding)
- [PDF file inputs](#pdf-file-inputs)
- [Reasoning with o1, o3 or o4](#reasoning-with-o1-o3-or-o4)
- [Web search](#web-search)
    - [User location](#user-location)
    - [Web_search code exemple](#web-search-code-exemple)
    - [Limitations](#limitations)
- [File search](#file-search)
- [Function calling](#function-calling)

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

![Preview](/../main/images/GenAIResponseRequest.png?raw=true "Preview")

<br>

### Streamed

When you create a Response with `stream` set to `true`, the server will emit server-sent events to the client as the Response is generated. This section contains the events that are emitted by the server. [Learn more.](https://platform.openai.com/docs/guides/streaming-responses?api-mode=responses)

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.JSONRequestClear;

  //Asynchronous example
  Client.Responses.AsynCreateStream(
    procedure(Params: TResponsesParams)
    begin
      Params.Model('gpt-4.1-nano');
      Params.Input('What is the difference between a mathematician and a physicist?');
      //Params.Store(False);  // Response not stored
      Params.Stream;
      TutorialHub.JSONRequest := Params.ToFormat();
    end,
    function : TAsynResponseStream
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnProgress := DisplayStream;
      Result.OnError := Display;
      Result.OnDoCancel := DoCancellation;
      Result.OnCancellation := Cancellation;
    end);

  //Synchronous example
//  Client.Responses.CreateStream(
//    procedure (Params: TResponsesParams)
//    begin
//      Params.Model('gpt-4.1-nano');
//      Params.Input('What is the difference between a mathematician and a physicist?');
//      //Params.Store(False);  // Response not stored
//      Params.Stream;
//      TutorialHub.JSONRequest := Params.ToFormat();
//    end,
//    procedure (var Chat: TResponseStream; IsDone: Boolean; var Cancel: Boolean)
//    begin
//      if (not IsDone) and Assigned(Chat) then
//        begin
//          DisplayStream(TutorialHub, Chat);
//        end;
//    end);
```

![Preview](/../main/images/GenAIResponseStreamedRequest.png?raw=true "Preview")

<br>


### Multi-turn conversations

The `GenAI Response API` enables the creation of interactive chat experiences tailored to your users' needs. Its chat functionality supports multiple rounds of questions and answers, allowing users to gradually work toward solutions or receive help with complex, multi-step issues. This capability is especially useful for applications requiring ongoing interaction, such as:

- **Chatbots**
- **Educational tools**
- **Customer support assistants**

APIs automate the handling of conversation history, so you don’t have to manually resend messages at every step.

To include the context from earlier responses, use the `previous_response_id` parameter. It lets you link messages together and keep the conversation flowing.

Refer to the [official documentation](https://platform.openai.com/docs/guides/conversation-state?api-mode=responses).

In the example below, we assume that one of the previous requests (streamed or non‑streamed) was executed with `store` set to `True`. Once the call completes, the response ID is returned (for example: `resp_67ffb72044648191b4faddb8254c79cf002f1563a5487ec4`). You then simply assign this value to the `PreviousResponseId` field when preparing the next conversation turn, as shown in the following code snippet:

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  //Asynchronous example
  Client.Responses.AsynCreate(
    procedure (Params: TResponsesParams)
    begin
      Params.Model('gpt-4.1-mini');
      Params.Input('question : second tour');
      Params.PreviousResponseId('resp_67ffb72044648191b4faddb8254c79cf002f1563a5487ec4');
      Params.Store(False);
    end 
  ...
```

Simply include the previous response’s ID with each turn. Thanks to CRUD operations, retrieving, processing, and deleting saved responses is straightforward. For more details, see the [CRUD operations on saved Responses](#crud-operations-on-saved-responses).

<br>

### Parallel method for generating text

This approach enables the simultaneous execution of multiple prompts, provided they are all processed by the same model. It also supports parallel web requests.

#### Example 1 : Two prompts processed in parallel.

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  Client.Responses.CreateParallel(
    procedure (Params: TBundleParams)
    begin
      Params.Prompts([
        'How many television channels were there in France in 1980?',
        'How many TV channels were there in Germany in 1980?.'
      ]);
      Params.System('Write the response in capital letters.');
      Params.Model('gpt-4.1-mini');
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
               // or Display(Sender, TResponse(Item.Chat).Output[0].Content[0].Text);
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
      Params.Model('gpt-4.1-mini');
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
              // or Display(Sender, TResponse(Item.Chat).Output[0].Content[0].Text);
            end;
        end;

      Result.OnError := Display;
    end)
```

To perform a web search, use the `gpt-4.1` or `gpt-4.1-mini` models with the `responses` endpoint. However, web search is not supported with these models when using the `chat/completion` endpoint; in that case, you should use the `gpt-4o-search-preview` model. Lastly, the `gpt-4.1-nano` model does not support web search, regardless of the endpoint used.

<br>
 
### CRUD operations on saved responses

>
>CRUD = `C`reate `R`ead `U`pdate `D`elete
>

#### Why CRUD on Responses ?

- **Traceability and Auditing:**  Being able to save, update, and delete responses directly from your wrapper makes it easier to manage the conversation history on both the client and server sides.

- **Business Scenarios:** For example, in a support assistant integrated into a Delphi application, it’s a real advantage to have an identifier—and the ability to correct or annotate—each generated response.


<br>

#### Get a model response

Retrieves a model response with the given ID. Refer to the [official documentation.](https://platform.openai.com/docs/api-reference/responses/get)

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.JSONRequestClear;

  //Asynchronous example
  Client.Responses.AsynRetrieve('Response_ID',
    function : TAsynResponse
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);

  //Synchronous example
//  var Value := Client.Responses.Retrieve('Response_ID');
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

<br>

#### Delete a model response

Deletes a model response with the given ID. Refer to the [official documentation.](https://platform.openai.com/docs/api-reference/responses/delete)

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.JSONRequestClear;

  Client.Responses.AsynDelete('Response_ID',
    function : TAsynResponseDelete
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);

  //Synchronous example
//  var Value := Client.Responses.Delete('Response_ID');
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

<br>

#### List input items

Returns a list of input items for a given response. Refer to the [official documentation.](https://platform.openai.com/docs/api-reference/responses/input-items)

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.JSONRequestClear;

  //Asynchronous example
  Client.Responses.AsynList('Response_ID',
    procedure (Params: TUrlResponseListParams)
    begin
      Params.Order('asc');
      Params.Limit(15);
    end,
    function : TAsynResponses
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end
  );

  //Synchronous example
//  var Value := Client.Responses.List('Response_ID',
//    procedure (Params: TUrlResponseListParams)
//    begin
//      Params.Limit(50);
//    end);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

<br>

___

## Vision

Refer to the [official documentation](https://platform.openai.com/docs/guides/vision).

<br>

### Analyze single source

`GenAI` processes images from both web sources and local files uniformly. It manages the submission of the source to the API, thereby simplifying the developer's task. Therefore, in this example, we will handle sources in the form of a ***URL*** and ***base-64 encoded*** data.

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.JSONRequestClear;
   var Url := 'https://upload.wikimedia.org/wikipedia/commons/thumb/d/dd/Gfp-wisconsin-madison-the-nature-boardwalk.jpg/2560px-Gfp-wisconsin-madison-the-nature-boardwalk.jpg';
  //var Ref := 'D:\My_folder\Images\My_image.png'; //This content will be encoded in base-64 by GenAI

  //Asynchronous example
  Client.Responses.AsynCreateStream(
    procedure (Params: TResponsesParams)
    begin
      Params.Model('gpt-4.1-mini');
      Params.Input('What is in this image?', [Url]);
     // Params.Input('What is in this image?', [Ref]);
      Params.Store(False);
      Params.Stream;
      TutorialHub.JSONRequest := Params.ToFormat();
    end,
    function : TAsynResponseStream
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnProgress := DisplayStream;
      Result.OnError := Display;
      Result.OnDoCancel := DoCancellation;
      Result.OnCancellation := Cancellation;
    end);

  //Synchronous example
//  var Value := Client.Responses.CreateStream(
//      procedure (Params: TResponsesParams)
//      begin
//        Params.Model('gpt-4.1-mini');
//        Params.Input('What is in this image?', [Url]);
//        // Params.Input('What is in this image?', [Ref]);
//        Params.Store(False);
//        Params.Stream;
//        TutorialHub.JSONRequest := Params.ToFormat();
//      end,
//      procedure (var Chat: TResponseStream; IsDone: Boolean; var Cancel: Boolean)
//      begin
//        if (not IsDone) and Assigned(Chat) then
//          begin
//            DisplayStream(TutorialHub, Chat);
//          end;
//      end);
```
This example uses streaming. The non-streamed version is straightforward to implement, so it is not covered here.

<br>

### Analyze multi-source

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.JSONRequestClear;
  var Ref1 := 'https://tripfixers.com/wp-content/uploads/2019/11/eiffel-tower-with-snow.jpeg';
  var Ref2 := 'https://cdn.pixabay.com/photo/2015/10/06/18/26/eiffel-tower-975004_1280.jpg';

  //Asynchronous example
  Client.Responses.AsynCreateStream(
    procedure (Params: TResponsesParams)
    begin
      Params.Model('gpt-4.1-mini');
      Params.Input('Compare images', [Ref1, Ref2]);
      Params.Store(False);
      Params.Stream;
      TutorialHub.JSONRequest := Params.ToFormat();
    end,
    function : TAsynResponseStream
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnProgress := DisplayStream;
      Result.OnError := Display;
      Result.OnDoCancel := DoCancellation;
      Result.OnCancellation := Cancellation;
    end);

  //Synchronous example
//  var Value := Client.Responses.CreateStream(
//      procedure (Params: TResponsesParams)
//      begin
//        Params.Model('gpt-4.1-mini');
//        Params.Input('Compare les images', [Ref1, Ref2]);
//        Params.Store(False);
//        Params.Stream;
//        TutorialHub.JSONRequest := Params.ToFormat();
//      end,
//      procedure (var Chat: TResponseStream; IsDone: Boolean; var Cancel: Boolean)
//      begin
//        if (not IsDone) and Assigned(Chat) then
//          begin
//            DisplayStream(TutorialHub, Chat);
//          end;
//      end);
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

<br>

___

## PDF file inputs

OpenAI models with vision capabilities can process PDF files as input. These files can be submitted either as Base64-encoded data or by using a file ID obtained after uploading the file via the dashboard or the `/v1/files` endpoint of the API. [Refer to file upload](https://github.com/MaxiDonkey/DelphiGenAI?tab=readme-ov-file#file-upload)

How it works
To help models understand the content of a PDF, each page is represented both as extracted text and as an image. These two formats are included in the model's context, allowing it to use both visual and textual information to generate responses. This is especially useful when important details—such as those found in diagrams or charts—are not present in the text alone.

Refer to the [official documentation](https://platform.openai.com/docs/guides/pdf-files)

However, with GenAI, it is possible to directly provide a local path or a URL pointing to the PDF files to be analyzed.

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.JSONRequestClear;
  var Ref := 'http://www.mysite.com/my_file.pdf';
//  var Ref := 'D:\my_folder\my_file.pdf';

  //Asynchronous example
  Client.Responses.AsynCreateStream(
    procedure (Params: TResponsesParams)
    begin
      Params.Model('gpt-4.1-mini');
      Params.Input('Summarize the document', [Ref]); 
      Params.Store(False);
      Params.Stream;
      TutorialHub.JSONRequest := Params.ToFormat();
    end,
    function : TAsynResponseStream
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnProgress := DisplayStream;
      Result.OnError := Display;
      Result.OnDoCancel := DoCancellation;
      Result.OnCancellation := Cancellation;
    end);

  //Synchronous example
//  var Value := Client.Responses.CreateStream(
//      procedure (Params: TResponsesParams)
//      begin
//        Params.Model('gpt-4.1-mini');
//        Params.Input('Summarize the document', [Ref]);
//        Params.Store(False);
//        Params.Stream;
//        TutorialHub.JSONRequest := Params.ToFormat();
//      end,
//      procedure (var Response: TResponseStream; IsDone: Boolean; var Cancel: Boolean)
//      begin
//        if (not IsDone) and Assigned(Response) then
//          begin
//            DisplayStream(TutorialHub, Response);
//          end;
//      end);
```
You can also submit multiple PDF files at once to perform analysis across a group of documents.

**File Size Limitations**
The API allows up to 100 pages and a total of 32MB per request, even when multiple files are included.

**Supported Models**
Only models that can handle both text and image inputs—such as gpt-4o, gpt-4o-mini, or o1—are able to accept PDF files as input. You can check the available model features [here].


<br>

>[!NOTE]
>It is possible to submit both image files and PDF documents simultaneously for a unified analysis.

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
  Client.Responses.AsynCreateStream(
    procedure (Params: TResponsesParams)
    begin
      Params.Model('o4-mini');
      Params.Instructions('You are an expert in bash script.');
      Params.Input('Write a bash script that takes a matrix represented as a string with format \"[1,2],[3,4],[5,6]\" and prints the transpose in the same format.');
      //Simplified
      Params.Reasoning('high' );
      //or deailled
      //Params.Reasoning(
      //  TReasoningParams.New.Effort('high').Summary('concise')
      //);
      Params.Stream;
      TutorialHub.JSONRequest := Params.ToFormat();
    end,
    function : TAsynResponseStream
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnProgress := DisplayStream;
      Result.OnError := Display;
      Result.OnDoCancel := DoCancellation;
      Result.OnCancellation := Cancellation;
    end);tion := Cancellation;
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

[The official documentation.](https://platform.openai.com/docs/guides/tools-web-search?api-mode=responses#user-location)

Models can be given access to real-time web data to enhance the relevance and accuracy of their responses.
To enable this capability, you can configure the web search function within the tools array of your API request when generating content through the Responses API. The model will then determine—based on the input prompt—whether or not it needs to perform an online search, just as it would with any other available tool.

If you want to ensure the model uses the web search function, you can enforce this behavior by setting the tool_choice parameter to `{type: "web_search_preview"}`. This can help deliver faster and more predictable results.

```Delphi
  procedure(Params: TResponsesParams)
    begin
      Params.Model('gpt-4.1-mini');
      ....
      Params.Tools([web_search_preview('high')]);
      ... 
```

<br>

### User location

To fine‑tune search results by geography, you can supply an approximate location for the user—country, city, region, and/or time zone.
- **City and region:** free‑text fields where you enter any string (e.g., Minneapolis for the city, Minnesota for the region).
- **Country:** a two‑letter ISO code such as US.
- **Time zone:** an IANA identifier like America/Chicago.

```Delphi
  procedure(Params: TResponsesParams)
    begin
      Params.Model('gpt-4.1-mini');
      ....
      Params.Tools([web_search_preview('high').UserLocation(Locate.City('Reims').Country('FR'))]);
      ... 
```

<br>

### Web_search code exemple

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.JSONRequestClear;

  //Asynchronous example
  Client.Responses.AsynCreateStream(
    procedure(Params: TResponsesParams)
    begin
      Params.Model('gpt-4.1-mini');
      Params.Input('What are the cultural news in France today?');
      Params.Tools([web_search_preview('high').UserLocation(Locate.City('Reims').Country('FR'))]); //Search context size : one of low, medium or High
      Params.Store(False);
      Params.Stream;
      TutorialHub.JSONRequest := Params.ToFormat();
    end,
    function : TAsynResponseStream
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnProgress := DisplayStream;
      Result.OnError := Display;
      Result.OnDoCancel := DoCancellation;
      Result.OnCancellation := Cancellation;
    end);

  //Synchronous example
//  Client.Responses.CreateStream(
//    procedure (Params: TResponsesParams)
//    begin
//      Params.Model('gpt-4.1');
//      Params.Input('What are the cultural news in France today?');
//      Params.Tools([web_search_preview('high').UserLocation(Locate.City('Reims').Country('FR'))]);
//      Params.Store(False);
//      Params.Stream;
//      TutorialHub.JSONRequest := Params.ToFormat();
//    end,
//    procedure (var Response: TResponseStream; IsDone: Boolean; var Cancel: Boolean)
//    begin
//      if (not IsDone) and Assigned(Response) then
//        begin
//          DisplayStream(TutorialHub, Response);
//        end;
//    end);
```

<br>

### Limitations

Here are the key points to know before using the web search feature:
- **Model Compatibility :** The `gpt-4.1-nano` model does not support web search.
- **“Search‑Preview” Variant Restrictions :** 
    - The `gpt-4o-search-preview` and `gpt-4o-mini-search-preview` models, available in the Chat Completions API, only accept a subset of the usual parameters.
    - Check each model’s spec sheet for its rate limits and supported features.
- **Rate Limits in the Responses API :** When web search is used as a tool via the Responses API, it adheres to the same rate‑limit tiers as the ***search‑preview*** models mentioned above. 
- **Maximum Context Size :** The context window for web search is capped at ***128,000 tokens***, even when using the `gpt-4.1` and `gpt-4.1-mini` models.
- **Data Handling :** For details on data processing, residency, and retention, refer to the [dedicated guide](https://platform.openai.com/docs/guides/your-data).

<br>

___

## File search

### Let your models query your own files before generating a response

#### 1. Overview

The Responses API includes a document‑search tool that lets the model draw—prior to answering—from a knowledge base made up of files you have previously uploaded. This search blends both keyword matching and semantic retrieval within a vector database.

#### 2. How it works

*(a)* Create a vector database
    - Build a vector store and upload your documents. Refer to [Files upload](https://github.com/MaxiDonkey/DelphiGenAI?tab=readme-ov-file#file-upload), [vector store](https://github.com/MaxiDonkey/DelphiGenAI/blob/main/BeyondBasics.md#vector-store) and [vector store file.](https://github.com/MaxiDonkey/DelphiGenAI/blob/main/BeyondBasics.md#vector-store-files)
    - These files expand the model’s built‑in knowledge, allowing it to rely on your private sources.

*(b)* Model‑triggered retrieval
    - When the model decides it’s helpful to consult your base, it automatically calls the tool.
    - The tool then queries the vector database, fetches the relevant passages, and returns them to the model, which weaves them into its reply.

*(c)* No infrastructure to manage
    - The tool is fully hosted and managed by OpenAI, so no additional code is required on your end.

#### 3. Learn more

Want a deeper dive into vector storage and semantic search? See our Information [Retrieval Guide.](https://platform.openai.com/docs/guides/retrieval)

<br>

#### 4. Use case

To demonstrate how this tool works, we will create a vector store from a PDF file, which will then be accessed via the `/responses` endpoint.
This approach allows the model to be enriched with specific information, thereby enhancing the relevance and contextual accuracy of the responses it generates.
In other words, it enables the model’s behavior to be refined ***without requiring an explicit fine-tuning phase.***

>[!NOTE]
> The PDF file used is written in French. However, thanks to the `file_search` tool, the content can be queried regardless of the document’s language, allowing for efficient multilingual search.

##### [--STEP 1--] Upload

**Upload the PDF file and retrieve the upload ID.**

The first step is to upload the PDF file, which returns a unique identifier. This `ID` will be used to reference the document in subsequent requests.

The PDF file is located in the sample directory of this repository.
The file is named `File_Search_file.pdf`.

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  var Value := Client.Files.Upload(
    procedure (Params: TFileUploadParams)
    begin
      Params.&File('File_Search_file.pdf');
      Params.Purpose(TFilesPurpose.user_data);
    end);
  try
    File_ID := Value.Id; //Retrieving the ID and then providing it to the file vector store
  finally
    Value.Free;
  end;
```

Result
```Json
{
    "object": "file",
    "id": "file-WNEwgxSLvUgXMk56HhyzAY",
    "purpose": "user_data",
    "filename": "File_Search_file.pdf",
    "bytes": 334640,
    "created_at": 1745216687,
    "expires_at": null,
    "status": "processed",
    "status_details": null
}
```

<br>

##### [--STEP 2--] Create store

**We now need to create a vector store and retrieve its ID.**

This step initializes a vector storage space, which will later be used to index the contents of the uploaded PDF file.

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  var Value := Client.VectorStore.Create(
    procedure (Params: TVectorStoreCreateParams)
    begin
      Params.Name('PDF Data for the tutorial');
      TutorialHub.JSONRequest := Params.ToFormat();
    end);
  try
    Display(TutorialHub, Value);
  finally
    Value.Free;
  end;
```

Result
```Json
{
    "id": "vs_6805e821210081919a4aabae08c63a14",
    "object": "vector_store",
    "created_at": 1745217569,
    "name": "PDF Data for the tutorial",
    "usage_bytes": 0,
    "file_counts": {
        "in_progress": 0,
        "completed": 0,
        "failed": 0,
        "cancelled": 0,
        "total": 0
    },
    "status": "completed",
    "expires_after": null,
    "expires_at": null,
    "last_active_at": 1745217569,
    "metadata": {
    }
}
```

<br>

##### [--STEP 3--] Link File

To complete the vector store setup, we will now attach the uploaded file to the vector store by providing both the `file ID` and the vector `store ID`.

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  var Value := Client.VectorStoreFiles.Create('vs_6805e821210081919a4aabae08c63a14',
    procedure (Params: TVectorStoreFilesCreateParams)
    begin
      Params.FileId('file-WNEwgxSLvUgXMk56HhyzAY');
      TutorialHub.JSONRequest := Params.ToFormat();
    end);
  try
    Display(TutorialHub, Value);
  finally
    Value.Free;
  end;
```

Result
```Json
{
    "id": "file-WNEwgxSLvUgXMk56HhyzAY",
    "object": "vector_store.file",
    "usage_bytes": 0,
    "created_at": 1745218347,
    "vector_store_id": "vs_6805e821210081919a4aabae08c63a14",
    "status": "in_progress",
    "last_error": null,
    "chunking_strategy": {
        "type": "static",
        "static": {
            "max_chunk_size_tokens": 800,
            "chunk_overlap_tokens": 400
        }
    },
    "attributes": {
    }
}
```

<br>

##### [--STEP 4--] Exploit Store

We will now leverage our vector store to allow the model to optionally use the information extracted from the PDF when generating its response.

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.JSONRequestClear;

  //Asynchronous example
  Client.Responses.AsynCreateStream(
    procedure(Params: TResponsesParams)
    begin
      Params.Model('gpt-4.1-mini');
      Params.Input('Identify all the conjectures and provide guidance or evidence to support their validation or refutation.');
      Params.Tools([file_search(['vs_6805e821210081919a4aabae08c63a14'])]);
//      Params.ToolChoice(TToolChoice.auto);
//  or   
//      Params.ToolChoice(THostedToolParams.New('file_search'));
      Params.Store(False);
      Params.Stream;
      TutorialHub.JSONRequest := Params.ToFormat();
    end,
    function : TAsynResponseStream
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

#### Note 1 : Tool_choice

```Delphi
   Params.ToolChoice(TToolChoice.auto); //none or required
//or
   Params.ToolChoice(THostedToolParams.New('file_search'));  //web_search_preview or  computer_use_preview
```
Refer to the [official documentation](https://platform.openai.com/docs/api-reference/responses/create#responses-create-tool_choice)

<br>

#### Note 2 : Include search results in the response

```Delphi
  Params.Include([TOutputIncluding.file_search_result]);
```

Refer to the [official documentation](https://platform.openai.com/docs/guides/tools-file-search#include-search-results-in-the-response)

<br>

#### 5. Final thoughts

Just like the `search_web` tool, the `file_search` tool stands out for both its precision and its practical value, making it a particularly powerful component.
Moreover, using the `/responses` endpoint proves to be a more effective approach than `/chat/completion`, as it significantly simplifies the integration of tools into queries.
 
We will not cover the `computer_use` tool here, as it requires implementing all the methods to handle the passed actions — a level of complexity that goes beyond the intended scope of this wrapper.

A GitHub repository may be shared in the future if the need to leverage this functionality becomes compelling.

___

## Function calling

<br>


