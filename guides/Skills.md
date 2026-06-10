# Skills

A **skill** is a versioned bundle of files plus a `SKILL.md` manifest (YAML frontmatter + instructions). Once uploaded, the model can load and run it on demand inside a Code Interpreter container to perform document generation, data processing or domain-specific workflows, while keeping the client-side surface minimal.

Skills are managed through `Client.Skills` (the skill entity) and `Client.Skills.Versions` (its immutable versions).

- [Overview](#overview)
- [Skill bundle structure](#skill-bundle-structure)
- [Skill lifecycle](#skill-lifecycle)
- [Skill management](#skill-management)
    - [Create a skill](#create-a-skill)
    - [List skills](#list-skills)
    - [Retrieve a skill](#retrieve-a-skill)
    - [Update a skill](#update-a-skill)
    - [Delete a skill](#delete-a-skill)
    - [Download a skill bundle](#download-a-skill-bundle)
- [Skill version management](#skill-version-management)
    - [Create a new version](#create-a-new-version)
    - [List versions](#list-versions)
    - [Retrieve a version](#retrieve-a-version)
    - [Delete a version](#delete-a-version)
    - [Download a version bundle](#download-a-version-bundle)
- [Using skills with the model](#using-skills-with-the-model)
- [Bundle requirements and limits](#bundle-requirements-and-limits)
- [References](#references)

___

<br>

## Overview

A skill bundles together everything the model needs to perform a task:

- a `SKILL.md` manifest, whose frontmatter provides the skill `name` and `description` (extracted automatically on upload),
- and any supporting files (scripts, templates, resources).

At a high level:

1. **Create** — upload a bundle; this creates the skill and its first immutable version.
2. **Use** — reference the skill (by `id`, optionally pinned to a version) from a Code Interpreter container or the skills tool of a `v1/responses` request.
3. **Version** — upload updated bundles as new immutable versions.
4. **List / retrieve** — inspect skills and versions.
5. **Delete** — remove versions, then the skill itself.

The model decides when a skill is relevant from its name and description; skills are not invoked explicitly by the client.

<br>

## Skill bundle structure

On disk, a skill is a **single top-level folder** containing a `SKILL.md` manifest at its root, plus any supporting files and subfolders (scripts, references, assets). The whole folder is what you upload as the bundle.

```text
pdf-extract/
├── SKILL.md            # manifest: YAML frontmatter + instructions
├── scripts/
│   └── extract.py
├── references/
│   └── layout-notes.md
└── README.md
```

`SKILL.md` opens with a YAML frontmatter block delimited by `---`, exposing at least `name` and `description` (read by OpenAI when the bundle is uploaded), followed by the instructions the model should follow:

```markdown
---
name: pdf-extract
description: Extract tables and key fields from PDF documents.
---

Use this skill to extract structured data from PDF files.
Run `scripts/extract.py` on the provided document and return the result as JSON.
```

>[!NOTE]
>Upload this folder either as repeated `files[]` parts — one per file, preserving the relative paths under the single top-level folder — or as a `.zip` that contains that single top-level folder. Exactly one `SKILL.md` is allowed per bundle.

<br>

## Skill lifecycle

| Step | Method | Endpoint |
| --- | --- | --- |
| Create a skill (+ first version) | `Client.Skills.Create` | `POST skills` |
| List skills | `Client.Skills.List` | `GET skills` |
| Retrieve a skill | `Client.Skills.Retrieve` | `GET skills/{id}` |
| Update a skill (default version) | `Client.Skills.Update` | `POST skills/{id}` |
| Delete a skill | `Client.Skills.Delete` | `DELETE skills/{id}` |
| Download a skill bundle | `Client.Skills.GetContent` | `GET skills/{id}/content` |
| Create a version | `Client.Skills.Versions.Create` | `POST skills/{id}/versions` |
| List versions | `Client.Skills.Versions.List` | `GET skills/{id}/versions` |
| Retrieve a version | `Client.Skills.Versions.Retrieve` | `GET skills/{id}/versions/{version}` |
| Delete a version | `Client.Skills.Versions.Delete` | `DELETE skills/{id}/versions/{version}` |
| Download a version bundle | `Client.Skills.Versions.GetContent` | `GET skills/{id}/versions/{version}/content` |

Each method also provides an asynchronous promise variant (`AsyncAwait...`) used throughout the examples below.

<br>

___

## Skill management

These operations act on the skill entity itself (its identity and lifecycle), independently of its versions.

### Create a skill

Creates a new skill and its first immutable version by uploading a bundle. Each file is sent as the multipart field `files[]`; the `name` and `description` are read from the bundle's `SKILL.md` manifest.

```pascal
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.JSONRequestClear;

  //Asynchronous promise example
  var Promise := Client.Skills.AsyncAwaitCreate(
    procedure (Params: TSkillCreateParams)
    begin
      Params.Files([
        'pdf-extract\SKILL.md',
        'pdf-extract\scripts\extract.py'
      ]);
    end);

  Promise
    .&Then<TSkill>(
      function (Value: TSkill): TSkill
      begin
        Result := Value;
        Display(TutorialHub, Value);
      end)
    .&Catch(
      procedure (E: Exception)
      begin
        Display(TutorialHub, E.Message);
      end);

  //Synchronous example
//  var Value := Client.Skills.Create(
//    procedure (Params: TSkillCreateParams)
//    begin
//      Params.Files([
//        'pdf-extract\SKILL.md',
//        'pdf-extract\scripts\extract.py'
//      ]);
//    end);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

>[!NOTE]
>`TSkillCreateParams` also exposes `&File(path)` and `&File(stream, fileName)` to add files one by one. All files must share a common top-level folder.

<br>

### List skills

Lists the skills available to your account. `TUrlSkillsParams` supports `After` (pagination cursor), `Limit` (1–100, default 20) and `Order` (`asc` / `desc`).

```pascal
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.JSONRequestClear;

  //Asynchronous promise example
  var Promise := Client.Skills.AsyncAwaitList(
    procedure (Params: TUrlSkillsParams)
    begin
      Params.Order('desc');
      Params.Limit(20);
    end);

  Promise
    .&Then<TSkills>(
      function (Value: TSkills): TSkills
      begin
        Result := Value;
        Display(TutorialHub, Value);
      end)
    .&Catch(
      procedure (E: Exception)
      begin
        Display(TutorialHub, E.Message);
      end);

  //Synchronous example
//  var Value := Client.Skills.List(
//    procedure (Params: TUrlSkillsParams)
//    begin
//      Params.Order('desc');
//      Params.Limit(20);
//    end);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

>[!NOTE]
>A parameterless overload `Client.Skills.List` (and `AsyncAwaitList`) returns the default page.

<br>

### Retrieve a skill

Retrieves a skill's metadata: `Id`, `Name`, `Description`, `CreatedAt`, `DefaultVersion` and `LatestVersion`.

```pascal
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.JSONRequestClear;
  var SkillId := Edit1.Text; //e.g. skill_68f4c6fdab0c8191...

  //Asynchronous promise example
  var Promise := Client.Skills.AsyncAwaitRetrieve(SkillId);

  Promise
    .&Then<TSkill>(
      function (Value: TSkill): TSkill
      begin
        Result := Value;
        Display(TutorialHub, Value);
      end)
    .&Catch(
      procedure (E: Exception)
      begin
        Display(TutorialHub, E.Message);
      end);

  //Synchronous example
//  var Value := Client.Skills.Retrieve(SkillId);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

<br>

### Update a skill

Updates the skill. The only mutable field is the **default version**, set with `DefaultVersion`. The default version is the one used when a request does not pin an explicit version.

```pascal
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.JSONRequestClear;
  var SkillId := Edit1.Text; //e.g. skill_68f4c6fdab0c8191...

  //Asynchronous promise example
  var Promise := Client.Skills.AsyncAwaitUpdate(SkillId,
    procedure (Params: TSkillUpdateParams)
    begin
      Params.DefaultVersion('2');
    end);

  Promise
    .&Then<TSkill>(
      function (Value: TSkill): TSkill
      begin
        Result := Value;
        Display(TutorialHub, Value);
      end)
    .&Catch(
      procedure (E: Exception)
      begin
        Display(TutorialHub, E.Message);
      end);

  //Synchronous example
//  var Value := Client.Skills.Update(SkillId,
//    procedure (Params: TSkillUpdateParams)
//    begin
//      Params.DefaultVersion('2');
//    end);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

<br>

### Delete a skill

Deletes a skill. You cannot delete a skill's default version; if needed, set another default version first.

```pascal
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.JSONRequestClear;
  var SkillId := Edit1.Text; //e.g. skill_68f4c6fdab0c8191...

  //Asynchronous promise example
  var Promise := Client.Skills.AsyncAwaitDelete(SkillId);

  Promise
    .&Then<TDeletion>(
      function (Value: TDeletion): TDeletion
      begin
        Result := Value;
        Display(TutorialHub, Value);
      end)
    .&Catch(
      procedure (E: Exception)
      begin
        Display(TutorialHub, E.Message);
      end);

  //Synchronous example
//  var Value := Client.Skills.Delete(SkillId);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

<br>

### Download a skill bundle

Downloads the zip bundle of the skill's default version. The result is a `TSkillContent`, exposing `AsString` (decoded text) and `SaveToFile` (writes the binary zip to disk).

```pascal
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.JSONRequestClear;
  var SkillId := Edit1.Text; //e.g. skill_68f4c6fdab0c8191...

  //Asynchronous promise example
  var Promise := Client.Skills.AsyncAwaitGetContent(SkillId);

  Promise
    .&Then<TSkillContent>(
      function (Value: TSkillContent): TSkillContent
      begin
        Result := Value;
        Value.SaveToFile('pdf-extract.zip');
        Display(TutorialHub, 'Skill bundle saved.');
      end)
    .&Catch(
      procedure (E: Exception)
      begin
        Display(TutorialHub, E.Message);
      end);

  //Synchronous example
//  var Value := Client.Skills.GetContent(SkillId);
//  try
//    Value.SaveToFile('pdf-extract.zip');
//  finally
//    Value.Free;
//  end;
```

<br>

___

## Skill version management

These operations act on the individual versions of a skill. Versions are **immutable** deployable snapshots and are reached through the `Client.Skills.Versions` sub-route.

### Create a new version

Uploads an updated bundle to an existing skill, creating a new immutable version. The skill `id` is unchanged. `TSkillVersionCreateParams` accepts the bundle files (`Files` / `&File`) and optional `Name` and `Description`.

```pascal
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.JSONRequestClear;
  var SkillId := Edit1.Text; //e.g. skill_68f4c6fdab0c8191...

  //Asynchronous promise example
  var Promise := Client.Skills.Versions.AsyncAwaitCreate(SkillId,
    procedure (Params: TSkillVersionCreateParams)
    begin
      Params.Files([
        'pdf-extract\SKILL.md',
        'pdf-extract\scripts\extract.py'
      ]);
      Params.Description('Improved table extraction.');
    end);

  Promise
    .&Then<TSkillVersion>(
      function (Value: TSkillVersion): TSkillVersion
      begin
        Result := Value;
        Display(TutorialHub, Value);
      end)
    .&Catch(
      procedure (E: Exception)
      begin
        Display(TutorialHub, E.Message);
      end);

  //Synchronous example
//  var Value := Client.Skills.Versions.Create(SkillId,
//    procedure (Params: TSkillVersionCreateParams)
//    begin
//      Params.Files([
//        'pdf-extract\SKILL.md',
//        'pdf-extract\scripts\extract.py'
//      ]);
//      Params.Description('Improved table extraction.');
//    end);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

<br>

### List versions

Lists all versions of a skill. The same `TUrlSkillsParams` (`After`, `Limit`, `Order`) applies.

```pascal
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.JSONRequestClear;
  var SkillId := Edit1.Text; //e.g. skill_68f4c6fdab0c8191...

  //Asynchronous promise example
  var Promise := Client.Skills.Versions.AsyncAwaitList(SkillId,
    procedure (Params: TUrlSkillsParams)
    begin
      Params.Order('desc');
    end);

  Promise
    .&Then<TSkillVersions>(
      function (Value: TSkillVersions): TSkillVersions
      begin
        Result := Value;
        Display(TutorialHub, Value);
      end)
    .&Catch(
      procedure (E: Exception)
      begin
        Display(TutorialHub, E.Message);
      end);

  //Synchronous example
//  var Value := Client.Skills.Versions.List(SkillId,
//    procedure (Params: TUrlSkillsParams)
//    begin
//      Params.Order('desc');
//    end);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

<br>

### Retrieve a version

Retrieves the metadata of a specific version: `Id`, `Version`, `SkillId`, `Name`, `Description` and `CreatedAt`.

```pascal
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.JSONRequestClear;
  var SkillId := Edit1.Text; //e.g. skill_68f4c6fdab0c8191...
  var Version := Edit2.Text; //e.g. 2

  //Asynchronous promise example
  var Promise := Client.Skills.Versions.AsyncAwaitRetrieve(SkillId, Version);

  Promise
    .&Then<TSkillVersion>(
      function (Value: TSkillVersion): TSkillVersion
      begin
        Result := Value;
        Display(TutorialHub, Value);
      end)
    .&Catch(
      procedure (E: Exception)
      begin
        Display(TutorialHub, E.Message);
      end);

  //Synchronous example
//  var Value := Client.Skills.Versions.Retrieve(SkillId, Version);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

<br>

### Delete a version

Deletes a single version of a skill. The default version cannot be deleted; set another default version first.

```pascal
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.JSONRequestClear;
  var SkillId := Edit1.Text; //e.g. skill_68f4c6fdab0c8191...
  var Version := Edit2.Text; //e.g. 2

  //Asynchronous promise example
  var Promise := Client.Skills.Versions.AsyncAwaitDelete(SkillId, Version);

  Promise
    .&Then<TDeletion>(
      function (Value: TDeletion): TDeletion
      begin
        Result := Value;
        Display(TutorialHub, Value);
      end)
    .&Catch(
      procedure (E: Exception)
      begin
        Display(TutorialHub, E.Message);
      end);

  //Synchronous example
//  var Value := Client.Skills.Versions.Delete(SkillId, Version);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

<br>

### Download a version bundle

Downloads the zip bundle of a specific version. As above, the `TSkillContent` result provides `AsString` and `SaveToFile`.

```pascal
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.JSONRequestClear;
  var SkillId := Edit1.Text; //e.g. skill_68f4c6fdab0c8191...
  var Version := Edit2.Text; //e.g. 2

  //Asynchronous promise example
  var Promise := Client.Skills.Versions.AsyncAwaitGetContent(SkillId, Version);

  Promise
    .&Then<TSkillContent>(
      function (Value: TSkillContent): TSkillContent
      begin
        Result := Value;
        Value.SaveToFile('pdf-extract-v2.zip');
        Display(TutorialHub, 'Skill version bundle saved.');
      end)
    .&Catch(
      procedure (E: Exception)
      begin
        Display(TutorialHub, E.Message);
      end);

  //Synchronous example
//  var Value := Client.Skills.Versions.GetContent(SkillId, Version);
//  try
//    Value.SaveToFile('pdf-extract-v2.zip');
//  finally
//    Value.Free;
//  end;
```

<br>

___

## Using skills with the model

A skill is not called directly: you make it available to the model and let it decide whether to use it. To do so, reference the skill (by `id`, optionally pinned to a `version`) when configuring:

- a **Code Interpreter container** — via the `Skills` parameter when creating a container (see [Create container](Containers.md#create-container));
- or a **`v1/responses`** request — via the skills tool (see [New tools in 2.0.0](Responses.md#new-tools-in-200)).

>[!TIP]
>Pin an explicit version in production for reproducibility, and rely on the default version during development.

<br>

___

## Bundle requirements and limits

A skill bundle must follow these rules (validated on upload):

- exactly one `SKILL.md` manifest, whose YAML frontmatter provides the `name` and `description`;
- all files must share a single top-level folder (upload a directory as repeated `files[]` parts, or a `.zip` containing a single top-level folder);
- maximum zip upload size: **50 MB**;
- maximum number of files per version: **500**;
- maximum uncompressed size per file: **25 MB**.

<br>

___

## References

- [Skills guide — OpenAI](https://developers.openai.com/api/docs/guides/tools-skills)
- [Skills API reference — OpenAI](https://platform.openai.com/docs/api-reference/skills)
- [Skills in the API (cookbook) — OpenAI](https://developers.openai.com/cookbook/examples/skills_in_api)
