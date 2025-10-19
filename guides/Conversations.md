# Conversations

- [Create a conversation](#create-a-conversation)
- [Delete a conversation](#delete-a-conversation)
- [Retrieve a conversation](#retrieve-a-conversation)
- [Update a conversation](#update-a-conversation)
- [List items](#list-items)
- [Create items](#create-items)
- [Retrieve an item](#retrieve-an-item)
- [Delete an item](#delete-an-item)

___

Create and manage conversations to store and retrieve conversation state across Response API calls. This makes it possible to build and enrich the context in order to obtain a more relevant response.

It is possible to access and review the conversations from the [dashboard](https://platform.openai.com/logs?api=conversations).

Conversations can be injected when creating a [response template](https://platform.openai.com/docs/api-reference/responses/create) using the conversation property.

You can also refer to the wrapper’s internal documentation, for example at this [link](Responses.md#non-streamed).

## Create a conversation

[Create a conversation](https://platform.openai.com/docs/api-reference/conversations/create)

```pascal
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.JSONRequestClear;

  //Asynchronous promise example
  var Promise := Client.Conversations.AsyncAwaitCreate(
    procedure (Params: TConversationsParams)
    begin
      Params.Metadata(
        TJSONObject.Create
          .AddPair('topic', 'demo')
      );
      Params.Items([
        TInputMessage.New
          .&Type()
          .Role('user')
          .Content('Hello!')
      ]);
      TutorialHub.JSONRequest := Params.ToFormat();
    end);

  Promise
    .&Then<TConversations>(
      function (Value: TConversations): TConversations
      begin
        Result := Value;
        Display(TutorialHub, Value);
      end)
    .&Catch(
      procedure (E: Exception)
      begin
        Display(TutorialHub, E.Message);
      end);

  //Asynchronous example
//  Client.Conversations.AsynCreate(
//    procedure (Params: TConversationsParams)
//    begin
//      Params.Metadata(
//        TJSONObject.Create
//          .AddPair('topic', 'demo')
//      );
//      Params.Items([
//        TInputMessage.New
//          .&Type()
//          .Role('user')
//          .Content('Hello!')
//      ]);
//      TutorialHub.JSONRequest := Params.ToFormat();
//    end,
//    function : TAsynConversations
//    begin
//      Result.Sender := TutorialHub;
//      Result.OnStart := Start;
//      Result.OnSuccess := Display;
//      Result.OnError := Display;
//    end);

  //Synchronous example
//  var Value := Client.Conversations.Create(
//    procedure (Params: TConversationsParams)
//    begin
//      Params.Metadata(
//        TJSONObject.Create
//          .AddPair('topic', 'demo')
//      );
//      Params.Items([
//        TInputMessage.New
//          .&Type()
//          .Role('user')
//          .Content('Hello!')
//      ]);
//      TutorialHub.JSONRequest := Params.ToFormat();
//    end);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;  
```

Result

```json
{
    "id": "conv_68f4de2260348193b6cbaa1a55d6673905e7c3018568d016",
    "object": "conversation",
    "created_at": 1760878114,
    "metadata": {
        "topic": "demo"
    }
}
```

<br>

## Delete a conversation

[Delete a conversation](https://platform.openai.com/docs/api-reference/conversations/delete).

>[!NOTE]
> Items in the conversation will not be deleted

```pascal
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.JSONRequestClear;
  var ConvId := Edit1.Text; //e.g. conv_68f4de2260348193b6cbaa1a55d6673905e7c3018568d016

  //Asynchronous promise example
  var Promise := Client.Conversations.AsyncAwaitDelete(ConvId);

  Promise
    .&Then<TConversationsDeleted>(
      function (Value: TConversationsDeleted): TConversationsDeleted
      begin
        Result := Value;
        Display(TutorialHub, Value);
      end)
    .&Catch(
      procedure (E: Exception)
      begin
        Display(TutorialHub, E.Message);
      end);


  //Asynchronous example
//  Client.Conversations.AsynDelete(ConvId,
//    function : TAsynConversationsDeleted
//    begin
//      Result.Sender := TutorialHub;
//      Result.OnStart := Start;
//      Result.OnSuccess := Display;
//      Result.OnError := Display;
//    end);

  //Synchronous example
//  var Value := Client.Conversations.Delete(ConvId);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```
 Result

```json
{
    "id": "conv_68f4de2260348193b6cbaa1a55d6673905e7c3018568d016",
    "object": "conversation.deleted",
    "deleted": true
}
```

<br>

## Retrieve a conversation

[Get a conversation](https://platform.openai.com/docs/api-reference/conversations/retrieve)

```pascal
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.JSONRequestClear;
  var ConvId := Edit1.Text; //e.g. conv_68f4e03f470c8193be3fb646edd6e5eb096299d34425bc6b

  //Asynchronous promise example
  var Promise := Client.Conversations.AsyncAwaitRetrieve(ConvId);

  Promise
    .&Then<TConversations>(
      function (Value: TConversations): TConversations
      begin
        Result := Value;
        Display(TutorialHub, Value);
      end)
    .&Catch(
      procedure (E: Exception)
      begin
        Display(TutorialHub, E.Message);
      end);

  //Asynchronous example
//  Client.Conversations.AsynRetrieve(ConvId,
//    function : TAsynConversations
//    begin
//      Result.Sender := TutorialHub;
//      Result.OnStart := Start;
//      Result.OnSuccess := Display;
//      Result.OnError := Display;
//    end);

  //Synchronous example
//  var Value := Client.Conversations.Retrieve(ConvId);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

Result

```json
{
    "id": "conv_68f4e03f470c8193be3fb646edd6e5eb096299d34425bc6b",
    "object": "conversation",
    "created_at": 1760878655,
    "metadata": {
        "topic": "demo"
    }
}
```

<br>

## Update a conversation

[Update a conversation](https://platform.openai.com/docs/api-reference/conversations/update)

```pascal
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.JSONRequestClear;
  var ConvId := Edit1.Text; //e.g. conv_68f4e03f470c8193be3fb646edd6e5eb096299d34425bc6b

  //Asynchronous promise example
  var Promise := Client.Conversations.AsyncAwaitUpdate(ConvId,
    procedure (Params: TUpdateConversationsParams)
    begin
      Params.Metadata(
        TJSONObject.Create
          .AddPair('topic', 'the new topic')
      );
      TutorialHub.JSONRequest := Params.ToFormat();
    end);

  Promise
    .&Then<TConversations>(
      function (Value: TConversations): TConversations
      begin
        Result := Value;
        Display(TutorialHub, Value);
      end)
    .&Catch(
      procedure (E: Exception)
      begin
        Display(TutorialHub, E.Message);
      end);

  //Asynchronous example
//  Client.Conversations.AsynUpdate(ConvId,
//    procedure (Params: TUpdateConversationsParams)
//    begin
//      Params.Metadata(
//        TJSONObject.Create
//          .AddPair('topic', 'the new topic')
//      );
//      TutorialHub.JSONRequest := Params.ToFormat();
//    end,
//    function : TAsynConversations
//    begin
//      Result.Sender := TutorialHub;
//      Result.OnStart := Start;
//      Result.OnSuccess := Display;
//      Result.OnError := Display;
//    end);

  //Synchronous example
//  var Value := Client.Conversations.Update(ConvId,
//    procedure (Params: TUpdateConversationsParams)
//    begin
//      Params.Metadata(
//        TJSONObject.Create
//          .AddPair('topic', 'the new topic')
//      );
//      TutorialHub.JSONRequest := Params.ToFormat();
//    end);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

Result

```json
{
    "id": "conv_68f4e03f470c8193be3fb646edd6e5eb096299d34425bc6b",
    "object": "conversation",
    "created_at": 1760878655,
    "metadata": {
        "topic": "the new topic"
    }
}
```

<br>

## List items

[List all items for a conversation with the given ID](https://platform.openai.com/docs/api-reference/conversations/list-items)

```pascal
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.JSONRequestClear;
  var ConvId := Edit1.Text; //e.g. conv_68f4e03f470c8193be3fb646edd6e5eb096299d34425bc6b

  //Asynchronous promise example
  var Promise := Client.Conversations.AsyncAwaitList(ConvId,
    procedure (Params: TUrlListItemsParams)
    begin
      Params.Limit(50);
      Params.Order('asc');
    end);

  Promise
    .&Then<TConversationList>(
      function (Value: TConversationList): TConversationList
      begin
        Result := Value;
        Display(TutorialHub, Value);
      end)
    .&Catch(
      procedure (E: Exception)
      begin
        Display(TutorialHub, E.Message);
      end);

  //Asynchronous example
//  Client.Conversations.AsynList(ConvId,
//    procedure (Params: TUrlListItemsParams)
//    begin
//      Params.Limit(50);
//      Params.Order('asc');
//    end,
//    function : TAsynConversationList
//    begin
//      Result.Sender := TutorialHub;
//      Result.OnStart := Start;
//      Result.OnSuccess := Display;
//      Result.OnError := Display;
//    end);

  //Synchronous example
//  var Value := Client.Conversations.List(ConvId,
//    procedure (Params: TUrlListItemsParams)
//    begin
//      Params.Limit(50);
//      Params.Order('asc');
//    end);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

Result

```json
{
    "object": "list",
    "data": [
        {
            "id": "msg_68f4e03f47448193a5f2fbe044cfe4c4096299d34425bc6b",
            "type": "message",
            "status": "completed",
            "content": [
                {
                    "type": "input_text",
                    "text": "Hello!"
                }
            ],
            "role": "user"
        }
    ],
    "first_id": "msg_68f4e03f47448193a5f2fbe044cfe4c4096299d34425bc6b",
    "has_more": false,
    "last_id": "msg_68f4e03f47448193a5f2fbe044cfe4c4096299d34425bc6b"
}
```

<br>

## Create items

[Create items in a conversation with the given ID](https://platform.openai.com/docs/api-reference/conversations/create-items)

```pascal
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.JSONRequestClear;
  var ConvId := Edit1.Text; //e.g. conv_68f4e03f470c8193be3fb646edd6e5eb096299d34425bc6b

  //Asynchronous promise example
  var Promise := Client.Conversations.AsyncAwaitCreateItem(ConvId,
    procedure (Params: TConversationsItemParams)
    begin
      Params.Items([
        TInputMessage.New
          .&Type()
          .Role('assistant')
          .Content('C''est bien alors !!')
      ]);
      TutorialHub.JSONRequest := Params.ToFormat();
    end);

  Promise
    .&Then<TConversationList>(
      function (Value: TConversationList): TConversationList
      begin
        Result := Value;
        Display(TutorialHub, Value);
      end)
    .&Catch(
      procedure (E: Exception)
      begin
        Display(TutorialHub, E.Message);
      end);

  //Asynchronous example
//  Client.Conversations.AsynCreateItem(ConvId,
//    procedure (Params: TConversationsItemParams)
//    begin
//      Params.Items([
//        TInputMessage.New
//          .&Type()
//          .Role('assistant')
//          .Content('C''est bien alors !!')
//      ]);
//      TutorialHub.JSONRequest := Params.ToFormat();
//    end,
//    function : TAsynConversationList
//    begin
//      Result.Sender := TutorialHub;
//      Result.OnStart := Start;
//      Result.OnSuccess := Display;
//      Result.OnError := Display;
//    end);

  //Synchronous example
//  var Value := Client.Conversations.CreateItem(ConvId,
//    procedure (Params: TConversationsItemParams)
//    begin
//      Params.Items([
//        TInputMessage.New
//          .&Type()
//          .Role('assistant')
//          .Content('C''est bien alors !!')
//      ]);
//      TutorialHub.JSONRequest := Params.ToFormat();
//    end);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

Result

```json
{
    "object": "list",
    "data": [
        {
            "id": "msg_68f4e2c4b1f88193b8a96c496d3ad3ad096299d34425bc6b",
            "type": "message",
            "status": "completed",
            "content": [
                {
                    "type": "input_text",
                    "text": "C'est bien alors !!"
                }
            ],
            "role": "assistant"
        }
    ],
    "first_id": "msg_68f4e2c4b1f88193b8a96c496d3ad3ad096299d34425bc6b",
    "has_more": false,
    "last_id": "msg_68f4e2c4b1f88193b8a96c496d3ad3ad096299d34425bc6b"
}
```

If you run [List Item](#list-items) again, you will get the following result:

```json
{
    "object": "list",
    "data": [
        {
            "id": "msg_68f4e03f47448193a5f2fbe044cfe4c4096299d34425bc6b",
            "type": "message",
            "status": "completed",
            "content": [
                {
                    "type": "input_text",
                    "text": "Hello!"
                }
            ],
            "role": "user"
        },
        {
            "id": "msg_68f4e2c4b1f88193b8a96c496d3ad3ad096299d34425bc6b",
            "type": "message",
            "status": "completed",
            "content": [
                {
                    "type": "input_text",
                    "text": "C'est bien alors !!"
                }
            ],
            "role": "assistant"
        }
    ],
    "first_id": "msg_68f4e03f47448193a5f2fbe044cfe4c4096299d34425bc6b",
    "has_more": false,
    "last_id": "msg_68f4e2c4b1f88193b8a96c496d3ad3ad096299d34425bc6b"
}
```

<br>

## Retrieve an item

[Get a single item from a conversation with the given IDs](https://platform.openai.com/docs/api-reference/conversations/get-item)

```pascal
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.JSONRequestClear;
  var ConvId := Edit1.Text; //e.g. conv_68f4e03f470c8193be3fb646edd6e5eb096299d34425bc6b
  var MsgId := Edit2.Text; //e.g. msg_68f4e2c4b1f88193b8a96c496d3ad3ad096299d34425bc6b

  //Asynchronous promise example
  var Promise := Client.Conversations.AsyncAwaitRetrieveItem(ConvId, MsgId);

  Promise
    .&Then<TConversationsItem>(
      function (Value: TConversationsItem): TConversationsItem
      begin
        Result := Value;
        Display(TutorialHub, Value);
      end)
    .&Catch(
      procedure (E: Exception)
      begin
        Display(TutorialHub, E.Message);
      end);

  //Asynchronous example
//  Client.Conversations.AsynRetrieveItem(ConvId, MsgId,
//    function : TAsynConversationsItem
//    begin
//      Result.Sender := TutorialHub;
//      Result.OnStart := Start;
//      Result.OnSuccess := Display;
//      Result.OnError := Display;
//    end);

  //Synchronous example
//  var Value := Client.Conversations.RetrieveItem(ConvId, MsgId);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

Result

```json
{
    "id": "msg_68f4e2c4b1f88193b8a96c496d3ad3ad096299d34425bc6b",
    "type": "message",
    "status": "completed",
    "content": [
        {
            "type": "input_text",
            "text": "C'est bien alors !!"
        }
    ],
    "role": "assistant"
}
```

<br>

## Delete an item

[Delete an item from a conversation with the given IDs](https://platform.openai.com/docs/api-reference/conversations/delete-item)

```pascal
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.JSONRequestClear;
  var ConvId := Edit1.Text; //e.g. conv_68f4e03f470c8193be3fb646edd6e5eb096299d34425bc6b
  var MsgId := Edit2.Text; //e.g. msg_68f4e2c4b1f88193b8a96c496d3ad3ad096299d34425bc6b

  //Asynchronous promise example
  var Promise := Client.Conversations.AsyncAwaitDeleteItem(ConvId, MsgId);

  Promise
    .&Then<TConversations>(
      function (Value: TConversations): TConversations
      begin
        Result := Value;
        Display(TutorialHub, Value);
      end)
    .&Catch(
      procedure (E: Exception)
      begin
        Display(TutorialHub, E.Message);
      end);

  //Asynchronous example
//  Client.Conversations.AsynDeleteItem(ConvId, MsgId,
//    function : TAsynConversations
//    begin
//      Result.Sender := TutorialHub;
//      Result.OnStart := Start;
//      Result.OnSuccess := Display;
//      Result.OnError := Display;
//    end);

  //Synchronous example
//  var Value := Client.Conversations.DeleteItem(ConvId, MsgId);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;  
```

Result

```json
{
    "id": "conv_68f4e03f470c8193be3fb646edd6e5eb096299d34425bc6b",
    "object": "conversation",
    "created_at": 1760878655,
    "metadata": {
        "topic": "the new topic"
    }
}
```

If you run [List Item](#list-items) again, you will get the following result:

```json
{
    "object": "list",
    "data": [
        {
            "id": "msg_68f4e03f47448193a5f2fbe044cfe4c4096299d34425bc6b",
            "type": "message",
            "status": "completed",
            "content": [
                {
                    "type": "input_text",
                    "text": "Hello!"
                }
            ],
            "role": "user"
        }
    ],
    "first_id": "msg_68f4e03f47448193a5f2fbe044cfe4c4096299d34425bc6b",
    "has_more": false,
    "last_id": "msg_68f4e03f47448193a5f2fbe044cfe4c4096299d34425bc6b"
}
```