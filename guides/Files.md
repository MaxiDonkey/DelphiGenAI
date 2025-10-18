# Files

- [Files list](#files-list)
- [File upload](#file-upload)
- [File retrieve](#file-retrieve)
- [File retrieve content](#file-retrieve-content)
- [File Deletion](#file-deletion)
___

Files are used to upload documents that can be used with features like **Assistants**, **Fine-tuning**, and **Batch API**.

<br/>

## Files list

Example without parameters

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  //Asynchronous example
  Client.Files.AsynList(
    function : TAsynFiles
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);

  //Synchronous example
//  var Value := Client.Files.List;
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;

    //Asynchronous promise example
//  var Promise := Client.Files.AsyncAwaitList;
//
//  Promise
//    .&Then<Integer>(
//      function (List: TFiles): Integer
//      begin
//        Display(TutorialHub, List);
//        Result := Length(List.Data);
//      end)
//    .&Catch(
//      procedure (E: Exception)
//      begin
//        Display(TutorialHub, E.Message);
//      end);
```

<br>

Example using parameters

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  //Asynchronous example
  Client.Files.AsynList(
    procedure (Params: TFileUrlParams)
    begin
      Params.Purpose('batch');
      Params.Limit(10);
    end,
    function : TAsynFiles
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);

  //Synchronous example
//  var Value := Client.Files.List(
//    procedure (Params: TFileUrlParams)
//    begin
//      Params.Purpose('batch');
//      Params.Limit(10);
//    end);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;

  //Asynchronous promise example
//  var Promise := Client.Files.AsyncAwaitList(
//    procedure (Params: TFileUrlParams)
//    begin
//      Params.Purpose('user_data');
//      Params.Limit(10);
//    end);
//
//  Promise
//    .&Then<Integer>(
//      function (List: TFiles): Integer
//      begin
//        Display(TutorialHub, List);
//        Result := Length(List.Data);
//      end)
//    .&Catch(
//      procedure (E: Exception)
//      begin
//        Display(TutorialHub, E.Message);
//      end);
```

Refer to [parameters documentation](https://platform.openai.com/docs/api-reference/files/list).

___

<br/>

## File upload

You can upload files for use across multiple endpoints. Each file can be as large as 512 MB, with a maximum combined storage limit of 100 GB per organization.

The Assistants API accommodates files containing up to 2 million tokens and accepts specific file formats. For more information, refer to the [Assistants Tools guide](https://platform.openai.com/docs/assistants/tools).

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  //Asynchronous example
  Client.Files.AsynUpload(
    procedure (Params: TFileUploadParams)
    begin
      Params.&File('BatchExample.jsonl');
      Params.Purpose(TFilesPurpose.batch);
    end,
    function : TAsynFile
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);

  //Synchronous example
//  var Value := Client.Files.Upload(
//    procedure (Params: TFileUploadParams)
//    begin
//      Params.&File('BatchExample.jsonl');
//      Params.Purpose(fp_batch);
//    end);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;

    //Asynchronous promise example
//  var Promise := Client.Files.AsyncAwaitUpload(
//    procedure (Params: TFileUploadParams)
//    begin
//      Params.&File(Document);
//      Params.Purpose(TFilesPurpose.user_data);
//    end,
//    function : TPromiseFile
//    begin
//      Result.Sender := TutorialHub;
//      Result.OnStart := Start;
//    end);
//
//  Promise
//    .&Then<TFile>(
//      function (Value: TFile): TFile
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

___

## File retrieve

Returns information about a specific file.

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.Id := '...Id file to retrieve...';

  //Asynchronous example
  Client.Files.AsynRetrieve(TutorialHub.Id,
    function : TAsynFile
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);

  //Synchronous example
//  var Value := Client.Files.Retrieve(TutorialHub.Id);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;

    //Asynchronous promise example
//  var Promise := Client.Files.AsyncAwaitRetrieve(
//    TutorialHub.Id,
//    function : TPromiseFile
//    begin
//      Result.Sender := TutorialHub;
//      Result.OnStart := Start;
//    end);
//
//  Promise
//    .&Then<TFile>(
//      function (Value: TFile): TFile
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

___

## File retrieve content

Returns the contents of the specified file.

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.Id := '...Id of the file to retrieve content...';

  //Asynchronous example
  Client.Files.AsynRetrieveContent(TutorialHub.Id,
    function : TAsynFileContent
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);

  //Synchronous example
//  var Value := Client.Files.RetrieveContent(TutorialHub.Id);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

<br/>

___

## File Deletion

Delete a file.

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.Id := '...Id file to delete...';

  //Synchronous example
  var Value := Client.Files.Delete(TutorialHub.Id);
  try
    Display(TutorialHub, F('Deleted', BoolToStr(Value.Deleted, True)));
  finally
    Value.Free;
  end;

  //Asynchronous promise example
//  var Promise := Client.Files.AsyncAwaitDelete(
//    TutorialHub.Id);
//
//  promise
//    .&Then<TDeletion>(
//      function (Value: TDeletion): TDeletion
//      begin
//        Result := Value;
//        Display(TutorialHub, F('Deleted', BoolToStr(Value.Deleted, True)));
//      end)
//    .&Catch(
//      procedure (E: Exception)
//      begin
//        Display(TutorialHub, E.Message);
//      end);
```