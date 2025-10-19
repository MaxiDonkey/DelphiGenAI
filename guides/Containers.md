# Containers managment

- [Containers](#containers)
    - [Create container](#create-container)
    - [List containers](#list-containers)
    - [Retrieve container](#retrieve-container)
    - [Delete a container](#delete-a-container)
- [Container Files](#container-files)
    - [Create container file](#create-container-file)
    - [List container files](#list-container-files)
    - [Retrieve container file](#retrieve-container-file)
    - [Retrieve container file content](#retrieve-container-file-content)
    - [Delete a container file](#delete-a-container-file)
___

## Containers

Create and manage containers for use with the `Code Interpreter` tool.

### Create container

[Create Container](https://platform.openai.com/docs/api-reference/containers/createContainers)

```pascal
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.JSONRequestClear;

  //Asynchronous promise example
  var Promise := Client.Containers.AsyncAwaitCreate(
    procedure (Params: TContainerParams)
    begin
      Params.Name('FirstContainer');
    end);

  Promise
    .&Then<TContainer>(
      function (Value: TContainer): TContainer
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
//  Client.Containers.AsynCreate(
//    procedure (Params: TContainerParams)
//    begin
//      Params.Name('FirstContainer');
//    end,
//    function : TAsynContainer
//    begin
//      Result.Sender := TutorialHub;
//      Result.OnStart := Start;
//      Result.OnSuccess := Display;
//      Result.OnError := Display;
//    end);

  //Synchronous example
//  var Value := Client.Containers.Create(
//    procedure (Params: TContainerParams)
//    begin
//      Params.Name('FirstContainer');
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
    "id": "cntr_68f4c6fdab0c81918453b59d132fa9170161944aa65b6ed8",
    "object": "container",
    "created_at": 1760872189,
    "status": "running",
    "expires_after": {
        "anchor": "last_active_at",
        "minutes": 20
    },
    "last_active_at": 1760872189,
    "name": "FirstContainer"
}
```

<br>

### List containers

[List Containers](https://platform.openai.com/docs/api-reference/containers/listContainers)

```pascal
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.JSONRequestClear;

  //Asynchronous promise example
  var Promise := Client.Containers.AsyncAwaitList(
    procedure (Params: TUrlContainerParams)
    begin
      Params.Order('desc');
    end);

  Promise
    .&Then<TContainerList>(
      function (Value: TContainerList): TContainerList
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
//  Client.Containers.AsynList(
//    procedure (Params: TUrlContainerParams)
//    begin
//      Params.Order('desc');
//    end,
//    function : TAsynContainerList
//    begin
//      Result.Sender := TutorialHub;
//      Result.OnStart := Start;
//      Result.OnSuccess := Display;
//      Result.OnError := Display;
//    end);

  //Synchronous example
//  var Value := Client.Containers.List(
//    procedure (Params: TUrlContainerParams)
//    begin
//      Params.Order('desc');
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
            "id": "cntr_68f4c6fdab0c81918453b59d132fa9170161944aa65b6ed8",
            "object": "container",
            "created_at": 1760872189,
            "status": "running",
            "expires_after": {
                "anchor": "last_active_at",
                "minutes": 20
            },
            "last_active_at": 1760872364,
            "name": "FirstContainer"
        }
    ],
    "first_id": "cntr_68f4c6fdab0c81918453b59d132fa9170161944aa65b6ed8",
    "has_more": false,
    "last_id": "cntr_68f4c6fdab0c81918453b59d132fa9170161944aa65b6ed8"
}
```

<br>

### Retrieve container

[Retrieve Container](https://platform.openai.com/docs/api-reference/containers/retrieveContainer)

```pascal
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.JSONRequestClear;
  var ContainerId := Edit1.Text; //e.g. cntr_68f4c6fdab0c81918453b59d132fa9170161944aa65b6ed8

  //Asynchronous promise example
  var Promise := Client.Containers.AsyncAwaitRetrieve(ContainerId);

  Promise
    .&Then<TContainer>(
      function (Value: TContainer): TContainer
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
//  Client.Containers.AsynRetrieve(ContainerId,
//    function : TAsynContainer
//    begin
//      Result.Sender := TutorialHub;
//      Result.OnStart := Start;
//      Result.OnSuccess := Display;
//      Result.OnError := Display;
//    end);

  //Synchronous example
//  var Value := Client.Containers.Retrieve(ContainerId);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

Result

```json
{
    "id": "cntr_68f4c6fdab0c81918453b59d132fa9170161944aa65b6ed8",
    "object": "container",
    "created_at": 1760872189,
    "status": "running",
    "expires_after": {
        "anchor": "last_active_at",
        "minutes": 20
    },
    "last_active_at": 1760872364,
    "name": "FirstContainer"
}
```

<br>

### Delete a container

[Delete Container](https://platform.openai.com/docs/api-reference/containers/deleteContainer)

```pascal
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.JSONRequestClear;
  var ContainerId := Edit1.Text; //e.g. cntr_68f4c6fdab0c81918453b59d132fa9170161944aa65b6ed8

  //Asynchronous promise example
  var Promise := Client.Containers.AsyncAwaitDelete(ContainerId);

  Promise
    .&Then<TContainersDelete>(
      function (Value: TContainersDelete): TContainersDelete
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
//  Client.Containers.AsynDelete(ContainerId,
//    function : TAsynContainersDelete
//    begin
//      Result.Sender := TutorialHub;
//      Result.OnStart := Start;
//      Result.OnSuccess := Display;
//      Result.OnError := Display;
//    end);

  //Synchronous example
//  var Value := Client.Containers.Delete(ContainerId);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

Result

```json
{
    "id": "cntr_68f4c6fdab0c81918453b59d132fa9170161944aa65b6ed8",
    "object": "container.deleted",
    "deleted": true
}
```

<br>

## Container Files

### Create container file

[Create a Container File](https://platform.openai.com/docs/api-reference/container-files/createContainerFile)

You can send either a multipart/form-data request with the raw file content, or a JSON request with a file ID.

```pascal
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.JSONRequestClear;
  var ContainerId := Edit1.Text; //e.g. cntr_68f4d2b9e3e48191bc139884ec951cfc02be9cefbf51ed07

  //Asynchronous promise example
  var Promise := Client.ContainerFiles.AsyncAwaitCreate(ContainerId,
    procedure (Params: TContainerFilesParams)
    begin
      Params.&File('realtime-webrtc-globals.js');
    end);

  Promise
    .&Then<TContainerFile>(
      function (Value: TContainerFile): TContainerFile
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
//  Client.ContainerFiles.AsynCreate(ContainerId,
//    procedure (Params: TContainerFilesParams)
//    begin
//      Params.&File('realtime-webrtc-globals.js');
//    end,
//    function : TAsynContainerFile
//    begin
//      Result.Sender := TutorialHub;
//      Result.OnStart := Start;
//      Result.OnSuccess := Display;
//      Result.OnError := Display;
//    end);

  //Synchronous example
//  var Value := Client.ContainerFiles.Create(ContainerId,
//    procedure (Params: TContainerFilesParams)
//    begin
//      Params.&File('realtime-webrtc-globals.js');
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
    "id": "cfile_68f4d4565ec48191b375049f23c7680b",
    "object": "container.file",
    "created_at": 1760875606,
    "bytes": 18114,
    "container_id": "cntr_68f4d2b9e3e48191bc139884ec951cfc02be9cefbf51ed07",
    "path": "\/mnt\/data\/6e20eba9030ed68734b5a9d563aab93e-realtime-webrtc-globals.js",
    "source": "user"
}
```

<br>

### List container files

[List Container files](https://platform.openai.com/docs/api-reference/container-files/listContainerFiles)

```pascal
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.JSONRequestClear;
  var ContainerId := Edit1.Text;  //e.g. cntr_68f4d2b9e3e48191bc139884ec951cfc02be9cefbf51ed07

  //Asynchronous promise example
  var Promise := Client.ContainerFiles.AsyncAwaitList(ContainerId,
    procedure (Params: TUrlContainerFileParams)
    begin
      Params.Order('desc');
    end);

  Promise
    .&Then<TContainerFileList>(
      function (Value: TContainerFileList): TContainerFileList
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
//  Client.ContainerFiles.AsynList(ContainerId,
//    procedure (Params: TUrlContainerFileParams)
//    begin
//      Params.Order('desc');
//    end,
//    function : TAsynContainerFileList
//    begin
//      Result.Sender := TutorialHub;
//      Result.OnStart := Start;
//      Result.OnSuccess := Display;
//      Result.OnError := Display;
//    end);

  //Synchronous example
//  var Value := Client.ContainerFiles.List(ContainerId,
//    procedure (Params: TUrlContainerFileParams)
//    begin
//      Params.Order('desc');
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
            "id": "cfile_68f4d4565ec48191b375049f23c7680b",
            "object": "container.file",
            "created_at": 1760875606,
            "bytes": 18114,
            "container_id": "cntr_68f4d2b9e3e48191bc139884ec951cfc02be9cefbf51ed07",
            "path": "\/mnt\/data\/6e20eba9030ed68734b5a9d563aab93e-realtime-webrtc-globals.js",
            "source": "user"
        }
    ],
    "first_id": "cfile_68f4d4565ec48191b375049f23c7680b",
    "has_more": false,
    "last_id": "cfile_68f4d4565ec48191b375049f23c7680b"
}
```

<br>

### Retrieve container file

[Retrieve Container File](https://platform.openai.com/docs/api-reference/container-files/retrieveContainerFile)

```pascal
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.JSONRequestClear;
  var ContainerId := Edit1.Text; //e.g. cntr_68f4d2b9e3e48191bc139884ec951cfc02be9cefbf51ed07
  var FileId := Edit2.Text; //e.g. cfile_68f4d4565ec48191b375049f23c7680b

  //Asynchronous promise example
  var Promise := Client.ContainerFiles.AsyncAwaitRetrieve(ContainerId, FileId);

  Promise
    .&Then<TContainerFile>(
      function (Value: TContainerFile): TContainerFile
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
//  Client.ContainerFiles.AsynRetrieve(ContainerId, FileId,
//    function : TAsynContainerFile
//    begin
//      Result.Sender := TutorialHub;
//      Result.OnStart := Start;
//      Result.OnSuccess := Display;
//      Result.OnError := Display;
//    end);

  //Synchronous example
//  var Value := Client.ContainerFiles.Retrieve(ContainerId, FileId);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

Result

```json
{
    "id": "cfile_68f4d4565ec48191b375049f23c7680b",
    "object": "container.file",
    "created_at": 1760875606,
    "bytes": 18114,
    "container_id": "cntr_68f4d2b9e3e48191bc139884ec951cfc02be9cefbf51ed07",
    "path": "\/mnt\/data\/6e20eba9030ed68734b5a9d563aab93e-realtime-webrtc-globals.js",
    "source": "user"
}
```

<br>

### Retrieve container file content

[Retrieve Container File Content](https://platform.openai.com/docs/api-reference/container-files/retrieveContainerFileContent)

```pascal
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.JSONRequestClear;
  var ContainerId := Edit1.Text; //e.g. cntr_68f4d2b9e3e48191bc139884ec951cfc02be9cefbf51ed07
  var FileId := Edit2.Text; //e.g. cfile_68f4d4565ec48191b375049f23c7680b

  //Asynchronous promise example
  var Promise := Client.ContainerFiles.AsyncAwaitGetContent(ContainerId, FileId);

  Promise
    .&Then<TContainerFileContent>(
      function (Value: TContainerFileContent): TContainerFileContent
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
//  Client.ContainerFiles.AsynGetContent(ContainerId, FileId,
//    function : TAsynContainerFileContent
//    begin
//      Result.Sender := TutorialHub;
//      Result.OnStart := Start;
//      Result.OnSuccess := Display;
//      Result.OnError := Display;
//    end);

  //Synchronous example
//  var Value := Client.ContainerFiles.GetContent(ContainerId, FileId);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

Code of the display method:

```pascal
procedure Display(Sender: TObject; Value: TContainerFileContent);
begin
  Display(Sender, 'Retrieve container file content');
  Display(Sender);
  Display(TutorialHub.Memo3, Value.AsString); 
end;
```

<br>

### Delete a container file

[Delete Container File](https://platform.openai.com/docs/api-reference/container-files/deleteContainerFile)

```pascal
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.JSONRequestClear;
  var ContainerId := Edit1.Text; //e.g. cntr_68f4d2b9e3e48191bc139884ec951cfc02be9cefbf51ed07
  var FileId := Edit2.Text; //e.g. cfile_68f4d4565ec48191b375049f23c7680b

  //Asynchronous promise example
  var Promise := Client.ContainerFiles.AsyncAwaitDelete(ContainerId, FileId);

  Promise
    .&Then<TContainerFilesDelete>(
      function (Value: TContainerFilesDelete): TContainerFilesDelete
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
//  Client.ContainerFiles.AsynDelete(ContainerId, FileId,
//    function : TAsynContainerFilesDelete
//    begin
//      Result.Sender := TutorialHub;
//      Result.OnStart := Start;
//      Result.OnSuccess := Display;
//      Result.OnError := Display;
//    end);

  //Synchronous example
//  var Value := Client.ContainerFiles.Delete(ContainerId, FileId);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

Result

```json
{
    "id": "cfile_68f4d4565ec48191b375049f23c7680b",
    "object": "container.file.deleted",
    "deleted": true
}
```