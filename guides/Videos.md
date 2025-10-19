# Videos

- [Introduction](#introduction)
- [Create video](#create-video)
- [Retrieve video](#retrieve-video)
- [Delete video](#delete-video)
- [List videos](#list-videos)
- [Remix video](#remix-video)
- [Retrieve video content](#retrieve-video-content)
___

## Introduction

The wrapper provides full access to OpenAI’s new ***Sora video generation API***, a state-of-the-art model capable of creating dynamic, high-fidelity video clips with audio ***from natural language prompts or images***.
Sora leverages multimodal diffusion, advanced 3D spatial understanding, motion consistency, and scene continuity to deliver realistic text-to-video generation.

### Available Endpoints

- **Create video:** Launch a new render from a prompt, with optional image/video references or remix IDs.
- **Get status:** Track render progress and retrieve job details.
- **Download video:** Fetch the final MP4 file once the generation is complete.
- **List videos:** Browse previously generated videos with pagination support.
- **Delete video:** Remove a video from OpenAI’s storage.

### Supported Models

| Model | Purpose |
|:---:|:---:|
|**sora-2**| Fast and flexible for ideation, style exploration, rapid iteration, social content, and prototypes. |
|**sora-2-pro**| Higher fidelity for cinematic production, marketing assets, and scenarios requiring visual precision. |

Sora lets you generate, extend, or remix videos programmatically, from first draft concepts to production-ready footage.

<br>

## Create video

[Create video](https://platform.openai.com/docs/api-reference/videos/create)

```pascal
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

TutorialHub.JSONRequestClear;

  //Asynchronous promise example
  var Promise := Client.Video.AsyncAwaitCreate(
    procedure (Params: TVideoParams)
    begin
      Params.Model('sora-2');
      Params.Prompt('A calico cat playing a piano on stage');
      TutorialHub.JSONRequest := 'MultipartFormData';
    end);

  Promise
    .&Then<TVideoJob>(
      function (Value: TVideoJob): TVideoJob
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
//  Client.Video.AsynCreate(
//    procedure (Params: TVideoParams)
//    begin
//      Params.Model('sora-2');
//      Params.Prompt('A calico cat playing a piano on stage');
//      TutorialHub.JSONRequest := 'MultipartFormData';
//    end,
//    function : TAsynVideoJob
//    begin
//      Result.Sender := TutorialHub;
//      Result.OnStart := Start;
//      Result.OnSuccess := Display;
//      Result.OnError := Display;
//    end);

  //Synchronous example
//  var Value := Client.Video.Create(
//    procedure (Params: TVideoParams)
//    begin
//      Params.Model('sora-2');
//      Params.Prompt('A calico cat playing a piano on stage');
//      TutorialHub.JSONRequest := 'MultipartFormData';
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
    "id": "video_68f42b7120d081919b3daed817c163ed0d041027cfe1806e",
    "object": "video",
    "created_at": 1760832369,
    "status": "queued",
    "completed_at": null,
    "error": null,
    "expires_at": null,
    "model": "sora-2",
    "progress": 0,
    "remixed_from_video_id": null,
    "seconds": "4",
    "size": "720x1280"
}
```

<br>

## Retrieve video

[Retrieve a video](https://platform.openai.com/docs/api-reference/videos/retrieve)

```pascal
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.JSONRequestClear;
  var VideoId := Edit1.Text; //e.g. video_68f42b7120d081919b3daed817c163ed0d041027cfe1806e

  //Asynchronous promise example
  var Promise := Client.Video.AsyncAwaitRetrieve(VideoId);

  Promise
    .&Then<TVideoJob>(
      function (Value: TVideoJob): TVideoJob
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
//  Client.Video.AsynRetrieve(VideoId,
//    function : TAsynVideoJob
//    begin
//      Result.Sender := TutorialHub;
//      Result.OnStart := Start;
//      Result.OnSuccess := Display;
//      Result.OnError := Display;
//    end);

  //Synchronous example
//  var Value := Client.Video.Retrieve(VideoId);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

Result

```json
{
    "id": "video_68f42b7120d081919b3daed817c163ed0d041027cfe1806e",
    "object": "video",
    "created_at": 1760832369,
    "status": "completed",
    "completed_at": 1760832448,
    "error": null,
    "expires_at": 1760836048,
    "model": "sora-2",
    "progress": 100,
    "remixed_from_video_id": null,
    "seconds": "4",
    "size": "720x1280"
}
```

<br>

## Delete video

[Delete video](https://platform.openai.com/docs/api-reference/videos/delete)

```pascal
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.JSONRequestClear;
  var VideoId := Edit1.Text; //e.g. video_68f42b7120d081919b3daed817c163ed0d041027cfe1806e

  //Asynchronous promise example
  var Promise := Client.Video.AsyncAwaitDelete(VideoId);

  Promise
    .&Then<TVideoJob>(
      function (Value: TVideoJob): TVideoJob
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
//  Client.Video.AsynDelete(VideoId,
//    function : TAsynVideoJob
//    begin
//      Result.Sender := TutorialHub;
//      Result.OnStart := Start;
//      Result.OnSuccess := Display;
//      Result.OnError := Display;
//    end);

  //Synchronous example
//  var Value := Client.Video.Delete(VideoId);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

Result

```json
{
    "id": "video_68f42b7120d081919b3daed817c163ed0d041027cfe1806e",
    "object": "video.deleted",
    "deleted": true
}
```

<br>

## List videos

[List videos](https://platform.openai.com/docs/api-reference/videos/list)

```pascal
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.JSONRequestClear;

  //Asynchronous promise example
  var Promise := Client.Video.AsyncAwaitList(
    procedure (Params: TUrlVideoParams)
    begin
      Params.Order('asc');
    end);

  Promise
    .&Then<TVideoJobList>(
      function (Value: TVideoJobList): TVideoJobList
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
//  Client.Video.AsynList(
//    procedure (Params: TUrlVideoParams)
//    begin
//      Params.Order('asc');
//    end,
//    function : TAsynVideoJobList
//    begin
//      Result.Sender := TutorialHub;
//      Result.OnStart := Start;
//      Result.OnSuccess := Display;
//      Result.OnError := Display;
//    end);

  //Synchronous example
//  var Value := Client.Video.List(
//    procedure (Params: TUrlVideoParams)
//    begin
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
            "id": "video_68efe12033d0819189d99905d424d56e0b51aaad6b95e54a",
            "object": "video",
            "created_at": 1760551200,
            "status": "completed",
            "completed_at": 1760551316,
            "error": null,
            "expires_at": 1760554916,
            "model": "sora-2",
            "progress": 100,
            "remixed_from_video_id": null,
            "seconds": "4",
            "size": "720x1280"
        },
        {
            "id": "video_68f42ccd5874819088ca80c3d36dd2e801bf0a36681edcec",
            "object": "video",
            "created_at": 1760832717,
            "status": "completed",
            "completed_at": 1760832791,
            "error": null,
            "expires_at": 1760836391,
            "model": "sora-2",
            "progress": 100,
            "remixed_from_video_id": null,
            "seconds": "4",
            "size": "720x1280"
        },
        {
            "id": "video_68f42cd163cc8193812eaf290e2fe72f04b97ac67b0bc928",
            "object": "video",
            "created_at": 1760832721,
            "status": "completed",
            "completed_at": 1760832792,
            "error": null,
            "expires_at": 1760836392,
            "model": "sora-2",
            "progress": 100,
            "remixed_from_video_id": null,
            "seconds": "4",
            "size": "720x1280"
        }
    ],
    "first_id": "video_68efe12033d0819189d99905d424d56e0b51aaad6b95e54a",
    "has_more": false,
    "last_id": "video_68f42cd163cc8193812eaf290e2fe72f04b97ac67b0bc928"
}
```

<br>

## Remix video

[Create a video remix](https://platform.openai.com/docs/api-reference/videos/remix)

```pascal
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.JSONRequestClear;
  var VideoId := Edit1.Text; //e.g. video_68f42b7120d081919b3daed817c163ed0d041027cfe1806e

  //Asynchronous promise example
  var Promise := Client.Video.AsyncAwaitRemix(VideoId,
    procedure (Params: TRemixParams)
    begin
      Params.Prompt('Extend the scene with the cat taking a bow to the cheering audience');
      TutorialHub.JSONRequest := Params.ToFormat();
    end);

  Promise
    .&Then<TVideoJob>(
      function (Value: TVideoJob): TVideoJob
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
//  Client.Video.AsynRemix(VideoId,
//    procedure (Params: TRemixParams)
//    begin
//      Params.Prompt('Extend the scene with the cat taking a bow to the cheering audience');
//      TutorialHub.JSONRequest := Params.ToFormat();
//    end,
//    function : TAsynVideoJob
//    begin
//      Result.Sender := TutorialHub;
//      Result.OnStart := Start;
//      Result.OnSuccess := Display;
//      Result.OnError := Display;
//    end);

  //Synchronous example
//  var Value := Client.Video.Remix(VideoId,
//    procedure (Params: TRemixParams)
//    begin
//      Params.Prompt('Extend the scene with the cat taking a bow to the cheering audience');
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
    "id": "video_68f42e34d72c8198957733bdebbbd0bf0a4767fb7c42df68",
    "object": "video",
    "created_at": 1760833076,
    "status": "queued",
    "completed_at": null,
    "error": null,
    "expires_at": null,
    "model": "sora-2",
    "progress": 0,
    "remixed_from_video_id": "video_68f42cd163cc8193812eaf290e2fe72f04b97ac67b0bc928",
    "seconds": "4",
    "size": "720x1280"
}
```

<br>

## Retrieve video content

[Download video content](https://platform.openai.com/docs/api-reference/videos/content)

```pascal
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.JSONRequestClear;
  TutorialHub.FileName := 'myVideo.mp4';
  var VideoId := Edit1.Text;

  //Asynchronous promise example
  var Promise := Client.Video.AsyncAwaitDownload(VideoId);

  Promise
    .&Then<TVideoDownloaded>(
      function (Value: TVideoDownloaded): TVideoDownloaded
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
//  Client.Video.AsynDownload(VideoId,
//    function : TAsynVideoDownloaded
//    begin
//      Result.Sender := TutorialHub;
//      Result.OnStart := Start;
//      Result.OnSuccess := Display;
//      Result.OnError := Display;
//    end);

  //Synchronous example
//  var Value := Client.Video.Download(VideoId);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

Code of the display method:

```pascal
procedure Display(Sender: TObject; Value: TVideoDownloaded);
begin
  if TutorialHub.FileName.IsEmpty then
    Exit;
  Value.SaveToFile(TutorialHub.FileName); // save to file 
  Display(Sender, TutorialHub.FileName + ' downloaded');
end;
```