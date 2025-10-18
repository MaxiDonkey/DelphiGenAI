# Vector store managment

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

___

# Vector store

Vector stores are used to store files for use by the [`file_search`](https://platform.openai.com/docs/assistants/tools/file-search) tool.

## Vector store create

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

## Vector store list

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

## Vector store retrieve

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

## Vector store modify

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

## Vector store delete

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

# Vector store files

Vector store files represent files inside a vector store.

Related guide: [File Search](https://platform.openai.com/docs/assistants/tools/file-search#vector-stores)

<br/>

## Vsf create

Create a vector store file by attaching a [File](https://platform.openai.com/docs/api-reference/files) to a [vector store](https://platform.openai.com/docs/api-reference/vector-stores/create).

<br/>

### Create a vector store

To create the vector store, it is advisable to refer to the example provided [at this location](VectorStore.md#vector-store-create) . Once the creation is complete, it is essential to retrieve the vector store ID. 

<br/>

### Upload files en get Ids

To link the files to the vector store created in the previous step, it is necessary to [upload](Files.md#file-upload) them first, as described earlier. Additionally, it is essential to retrieve the file IDs after the upload, just like in the previous step.

Let’s consider the upload of two files, ***file1*** and ***file2***, ensuring that the `purpose` field is set to `assistant`. This will provide the corresponding file IDs, ***fileId1*** and ***fileId2***, respectively.

<br/>

### Create the vector store files

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

## Vsf list

Returns a list of vector store files.

<br/>

### Without parameters

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

### with parameters

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

## Vsf retrieve

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

## Vsf delete

Remove a vector store file. This action will detach the file from the vector store without deleting the file itself. To permanently delete the file, use the [delete file](Files.md#file-deletion) endpoint.

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

# Vector store batches

Vector store file batches represent operations to add multiple files to a vector store. Related guide: [File Search](https://platform.openai.com/docs/assistants/tools/file-search#vector-stores)

<br/>

## Vsb create

<br/>

### Create a vector store

To create the vector store, it is advisable to refer to the example provided [at this location](VectorStore.md#vector-store-create) . Once the creation is complete, it is essential to retrieve the vector store ID. 

<br/>

### Upload files en get Ids

To link the files to the vector store created in the previous step, it is necessary to [upload](Files.md#file-upload) them first, as described earlier. Additionally, it is essential to retrieve the file IDs after the upload, just like in the previous step.

Let’s consider the upload of two files, ***file1*** and ***file2***, ensuring that the `purpose` field is set to `assistant`. This will provide the corresponding file IDs, ***fileId1*** and ***fileId2***, respectively.

<br/>

### Create the vector store batches

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

## Vsb list

Returns a list of vector store files in a batch.

### Without parameters

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

### with parameters

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

## Vsb retrieve

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

## Vsb cancel

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
