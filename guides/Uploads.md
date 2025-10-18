# Uploads

- [Upload create](#upload-create)
- [Upload cancel](#upload-cancel)
- [Upload add part](#upload-add-part)
- [Upload complete](#upload-complete)

___

Allows you to upload large files in multiple parts.

<br/>

## Upload create

An intermediate [Upload](https://platform.openai.com/docs/api-reference/uploads/object) object is created, allowing you to attach multiple [parts](https://platform.openai.com/docs/api-reference/uploads/part-object). The maximum size for an Upload is 8 GB, and it will automatically expire one hour after creation.

Once the Upload is finalized, a [File](https://platform.openai.com/docs/api-reference/files/object) object is generated, incorporating all the uploaded parts. This File object can then be used seamlessly across our platform, functioning like any regular file.

For certain `purposes`, specifying the correct `mime_type` is essential. Be sure to consult the documentation to identify the supported MIME types that suit your use case.

Guidance for [Assistants](https://platform.openai.com/docs/assistants/tools/file-search#supported-files):
For details on selecting the appropriate file extensions for different scenarios, refer to the documentation on [File creation](https://platform.openai.com/docs/api-reference/files/create).

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  //Asynchronous example
  Client.Uploads.AsynCreate(
    procedure (Params: TUploadCreateParams)
    begin
      Params.Purpose('fine-tune');
      Params.Filename('BatchExample.jsonl');
      Params.bytes(FileSize('BatchExample.jsonl'));
      Params.MimeType('text/jsonl');
    end,
    function : TAsynUpload
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);

  //Synchronous example
//  var Value := Client.Uploads.Create(
//    procedure (Params: TUploadCreateParams)
//    begin
//      Params.Purpose('fine-tune');
//      Params.Filename('BatchExample.jsonl');
//      Params.bytes(FileSize('BatchExample.jsonl'));
//      Params.MimeType('text/jsonl');
//    end);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;

  //Asynchronous promise example
//  var Promise := Client.Uploads.AsyncAwaitCreate(
//    procedure (Params: TUploadCreateParams)
//    begin
//      Params.Purpose('fine-tune');
//      Params.Filename('BatchExample.jsonl');
//      Params.bytes(FileSize('BatchExample.jsonl'));
//      Params.MimeType('text/jsonl');
//    end);
//
//  Promise
//    .&Then<TUpload>(
//      function (Value: TUpload): TUpload
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

## Upload cancel

Cancels the Upload. No Parts may be added after an Upload is cancelled.

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.Id := 'upload_679207849ec8819086bc0e54f5c66d62';

  //Asynchronous example
  Client.Uploads.AsynCancel(TutorialHub.Id,
    function : TAsynUpload
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);

  //Synchronous example
//  var Value := Client.Uploads.Cancel(TutorialHub.Id);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;

  //Asynchronous promise example
//  var Promise := Client.Uploads.AsyncAwaitCancel(TutorialHub.Id);
//
//  Promise
//    .&Then<TUpload>(
//      function (Value: TUpload): TUpload
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

## Upload add part

Adds a [Part](https://platform.openai.com/docs/api-reference/uploads/part-object) to an [Upload](https://platform.openai.com/docs/api-reference/uploads/object) object. A Part represents a chunk of bytes from the file you are trying to upload.

Each Part can be at most 64 MB, and you can add Parts until you hit the Upload maximum of 8 GB.

It is possible to add multiple Parts in parallel. You can decide the intended order of the Parts when you [complete the Upload](https://platform.openai.com/docs/api-reference/uploads/complete).

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.Id := 'upload_679207849ec8819086bc0e54f5c66d62';

  //Asynchronous example
  Client.Uploads.AsynAddPart(TutorialHub.Id,
    procedure (Params: TUploadPartParams)
    begin
      Params.Data('BatchExample.jsonl');
    end,
    function : TAsynUploadPart
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);

  //Asynchronous example
//  var Value := Client.Uploads.AddPart(TutorialHub.Id,
//    procedure (Params: TUploadPartParams)
//    begin
//      Params.Data('BatchExample.jsonl');
//    end);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;

  //Asynchronous promise example
//  var Promise := Client.Uploads.AsyncAwaitAddPart(
//    TutorialHub.Id,
//    procedure (Params: TUploadPartParams)
//    begin
//      Params.Data('BatchExample.jsonl');
//    end);
//
//  Promise
//    .&Then<TUploadPart>(
//      function (Value: TUploadPart): TUploadPart
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

## Upload complete

Completes the [Upload](https://platform.openai.com/docs/api-reference/uploads/object).

Within the returned Upload object, there is a nested [File](https://platform.openai.com/docs/api-reference/files/object) object that is ready to use in the rest of the platform.

You can specify the order of the Parts by passing in an ordered list of the Part IDs.

The number of bytes uploaded upon completion must match the number of bytes initially specified when creating the Upload object. No Parts may be added after an Upload is completed.

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.Id := 'upload_679207849ec8819086bc0e54f5c66d62';

  //Asynchronous example
  Client.Uploads.AsynComplete(TutorialHub.Id,
    procedure (Params: TUploadCompleteParams)
    begin
      Params.PartIds(['BatchExample.jsonl'])
    end,
    function : TAsynUpload
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);

  //Asynchronous example
//  var Value := Client.Uploads.Complete(TutorialHub.Id,
//    procedure (Params: TUploadCompleteParams)
//    begin
//      Params.PartIds(['BatchExample.jsonl'])
//    end);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;

  //Asynchronous promise example
//  var Promise := Client.Uploads.AsyncAwaitComplete(
//    TutorialHub.Id,
//    procedure (Params: TUploadCompleteParams)
//    begin
//      Params.PartIds(['BatchExample.jsonl'])
//    end);
//
//  Promise
//    .&Then<TUpload>(
//      function (Value: TUpload): TUpload
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