# Deprecated

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

___

## Assistants

![deprecated](https://img.shields.io/badge/DEPRECATED-orange)

Build assistants that can call models and use tools to perform tasks.

The version of assistants integrated by `GenAI` is version 2, currently offered in beta by **OpenAI**.

[Get started with the Assistants API](https://platform.openai.com/docs/assistants)

<br/>

### Create assistant

![deprecated](https://img.shields.io/badge/DEPRECATED-orange)

#### Code interpreter

```pascal
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

![deprecated](https://img.shields.io/badge/DEPRECATED-orange)

To fully utilize this feature offered by the `assistants`, you must be comfortable managing file stores. For further details, you can refer to the sections [vector store files](#Vector-store-files) outlined above.

```pascal
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

![deprecated](https://img.shields.io/badge/DEPRECATED-orange)

Returns a list of assistants.

Consult the [official documentation](https://platform.openai.com/docs/api-reference/assistants/listAssistants) for details on list parameters.

```pascal
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

![deprecated](https://img.shields.io/badge/DEPRECATED-orange)

Retrieves an assistant by its ID.

```pascal
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

![deprecated](https://img.shields.io/badge/DEPRECATED-orange)

Modifies an assistant by its ID.

```pascal
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

![deprecated](https://img.shields.io/badge/DEPRECATED-orange)

Delete an assistant by its ID.

```pascal
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

![deprecated](https://img.shields.io/badge/DEPRECATED-orange)

Create threads that assistants can interact with.

Related guide: [Assistants](https://platform.openai.com/docs/assistants/overview)

<br/>

### Create thread

![deprecated](https://img.shields.io/badge/DEPRECATED-orange)

Create a thread.

```pascal
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

![deprecated](https://img.shields.io/badge/DEPRECATED-orange)

Retrieves a thread by its ID.

```pascal
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

![deprecated](https://img.shields.io/badge/DEPRECATED-orange)

Modifies a thread by its ID.

```pascal
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

![deprecated](https://img.shields.io/badge/DEPRECATED-orange)

Delete a thread by its ID.

```pascal
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

![deprecated](https://img.shields.io/badge/DEPRECATED-orange)

Create messages within threads

Related guide: [Assistants](https://platform.openai.com/docs/assistants/overview)

<br/>

### Create message

Create a message.

To take full advantage of this feature provided by Messages, it is essential to be proficient in managing Threads. For more information, please refer to the [Threads sections](#Threads) mentioned earlier.

```pascal
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

![deprecated](https://img.shields.io/badge/DEPRECATED-orange)

Returns a list of messages for a given thread.

```pascal
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

![deprecated](https://img.shields.io/badge/DEPRECATED-orange)

Retrieve a message by its ID.

```pascal
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

![deprecated](https://img.shields.io/badge/DEPRECATED-orange)

Modifies a message by its ID.

```pascal
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

![deprecated](https://img.shields.io/badge/DEPRECATED-orange)

Deletes a message by its ID.

```pascal
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

![deprecated](https://img.shields.io/badge/DEPRECATED-orange)

Represents an execution run on a thread.

Related guide: [Assistants](https://platform.openai.com/docs/assistants/overview)

<br/>

### Create run

![deprecated](https://img.shields.io/badge/DEPRECATED-orange)

Create a run.

```pascal
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

![deprecated](https://img.shields.io/badge/DEPRECATED-orange)

```pascal
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

![deprecated](https://img.shields.io/badge/DEPRECATED-orange)

Returns a list of runs belonging to a thread.

```pascal
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

![deprecated](https://img.shields.io/badge/DEPRECATED-orange)

Retrieves a run by its ID.

```pascal
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

![deprecated](https://img.shields.io/badge/DEPRECATED-orange)

Modifies a run by its ID.

```pascal
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

![deprecated](https://img.shields.io/badge/DEPRECATED-orange)

When a run has the `status: "requires_action"` and `required_action.type` is `submit_tool_outputs`, this endpoint can be used to submit the outputs from the tool calls once they're all completed. All outputs must be submitted in a single request.

```pascal
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

![deprecated](https://img.shields.io/badge/DEPRECATED-orange)

Cancels a run that is `in_progress`.

```pascal
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

![deprecated](https://img.shields.io/badge/DEPRECATED-orange)

Represents the steps (model and tool calls) taken during the run.

Related guide: [Assistants](https://platform.openai.com/docs/assistants/overview)

<br/>

### List run steps

![deprecated](https://img.shields.io/badge/DEPRECATED-orange)

Returns a list of run steps belonging to a run.

```pascal
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

![deprecated](https://img.shields.io/badge/DEPRECATED-orange)

Retrieves a run step.

```pascal
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


