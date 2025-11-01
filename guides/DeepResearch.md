# Deep Research

- [Introduction](#introduction)
- [General Overview of Deep Research](#general-overview-of-deep-research)
- [Overall Deep Research Workflow](#overall-deep-research-workflow)
- [Internal Logic and Model Control](#internal-logic-and-model-control)
- [Deep Research-Specific Parameters](#deep-research-specific-parameters)
- [Streaming and Session Management](#streaming-and-session-management)
- [Special Cases and Error Messages](#special-cases-and-error-messages)
- [Functional Summary](#functional-smmary)
- [Key Takeaways](#key-takeaways)
- [Promise Orchestration for Stages 2 and 3](#promise-orchestration-for-stages-2-and-3)

<br>

---

## Introduction

This document details the implementation of the **Deep Research** function as integrated within the **File2Knowledge** project; a demonstration application designed to showcase the use of the **DelphiGenAI** wrapper.

Although *File2Knowledge* is built using the **VCL** framework, all concepts and code components described here are **fully transferable to FMX**.  
The project was designed with a strict **separation of concerns** between the user interface, application logic, and the OpenAI integration layer.  
This ensures that the asynchronous execution workflow of **Deep Research** remains independent of the visual framework.

Accordingly, this documentation should be regarded as a **best-practice reference** for implementing OpenAI’s *Deep Research* feature within modern Delphi applications.

For additional information:
- [Official OpenAI documentation](https://platform.openai.com/docs/guides/deep-research)
- [*File2Knowledge* project repository](https://github.com/MaxiDonkey/file2knowledge) 


<br>

## General Overview of Deep Research

The **Deep Research** feature enables the application to perform advanced, multi-step research tasks using OpenAI’s specialized models, such as `o3-deep-research` or `o4-mini-deep-research`.
These models go far beyond simple text generation: they can plan and execute multi-stage research, analyze data from multiple sources, and produce comprehensive, structured, and well-reasoned summaries, often including citations and references.

A Deep Research model combines several capabilities:

- **Web Search Preview:** to gather up-to-date information from public online sources.
- **Vector-based internal search:** to leverage private, pre-indexed documents or datasets.
- **Code Interpreter:** to execute calculations, analyze data, or compare results dynamically.

The goal is to deliver reliable, contextualized, and well-sourced results, blending external (web) and internal (vector store) knowledge.
This mode is particularly useful for scientific research, market analysis, technical reports, and document-based investigations.

Two key constraints always apply:

- The reasoning level is fixed at `medium`, the only value accepted by Deep Research models.
- The web search context size is also fixed to `medium`, ensuring a balanced scope and performance.

Finally, the execution engine automatically verifies that Deep Research is appropriate for the request.
If the task is a simple factual or one-step query, the system rejects Deep Research mode and suggests a lighter model, conserving resources for true research workflows.

<br>

## Overall Deep Research Workflow

A Deep Research workflow consists of **three distinct stages**:

1. **Clarification** of the user’s request.
2. **Construction** of the Deep Research instruction prompt.
3. **Execution** of the actual research and response generation.

Each stage corresponds to specific Delphi methods, as described below.

- [Stage 1 Clarification Phase](#stage-1-clarification-phase)
- [Stage 2 Building the Deep Research Instruction Prompt](#stage-2-building-the-deep-research-instruction-prompt)
- [Stage 3 Executing the Deep Research Request](#stage-3-executing-the-deep-research-request)

<br>

### Stage 1 Clarification Phase

The first step aims to **refine and complete the user’s request** before invoking a Deep Research model.
It gathers all required details to ensure that the subsequent research prompt is well-structured and unambiguous.

The engine uses asking\_clarifying\_questions.txt with a lightweight model (gpt-4.1) to guide this step.
The rules defined in that file enforce the following behavior:

- Ask only the **necessary questions** to fill missing details.
- Do not restate or repeat existing information.
- Structure the questions clearly (bullets or numbered lists).
- Do not perform any research at this stage; just collect clarifying input.

After this step, the system holds all relevant parameters (goals, scope, language, expected output format, etc.) needed to form a precise Deep Research brief.

**Entry point in code:**

```pascal
function ExecuteClarifying(const Prompt: string): TPromise<string>; // Provider.OpenAI.ExecutionEngine.pas
```

<br>

### Stage 2 Building the Deep Research Instruction Prompt

Once clarification is complete, the engine generates the instruction prompt for the Deep Research model.
This step relies on the file `system\_prompt\_context\_deep\_research.txt`, which defines how complex research requests must be framed.

The file enforces several essential rules:

- **Include all known user details** exactly as given.
- **Explicitly mark missing information** as “unspecified” rather than assuming values.
- Write in the **first person**, expressing the user’s perspective.
- Specify the **expected output format** (report, summary, comparison table, etc.).
- **Keep the response language** identical to the input unless otherwise requested.
- Prefer primary, **reliable sources** (official sites, publications).
- Personalize with `{{user\_name}}` if provided.

The result is a fully structured instruction string that is injected into the model’s parameters before execution.

**Relevant methods:**

```pascal
function BuildDeepResearchInstructions(const Prompt, UserName: string): string; // Provider.OpenAI.ExecutionEngine.pas (conceptual)
```

and

```pascal
function TPromptExecutionEngine.CreateStreamParams(const Turn: TChatTurn; const Instructions: string): TProc<TResponsesParams>;
```

<br>

### Stage 3 Executing the Deep Research Request

Once the instruction string is built, the execution engine (`TPromptExecutionEngine`) performs the actual research.
It creates a chat session, configures the model and its tools, and streams results asynchronously.

The automatic configuration includes:

- **Model:** `o3-deep-research` or `o4-mini-deep-research`
- **Reasoning level:** `medium` (via `CreateReasoningEffortDeepResearchParams`)
- **Web Search Preview:** SearchContextSize('medium')
- **Vector search:** enabled if stores are available
- **Code Interpreter:** `Container('auto')`
- **Streaming:** real-time SSE response flow

**Entry points in code:**
UI orchestrator:

```pascal
procedure HandleDeepResearchProcess(Sender: TObject); // UI.PromptEditor.VCL.pas
```

Core execution:

```pascal
function Execute(const Prompt, Instructions: string): TPromise<string>; // Provider.OpenAI.ExecutionEngine.pas
```

<br>

## Internal Logic and Model Control

**Central method:**

```pascal
function TPromptExecutionEngine.CreateStreamParams(const Turn: TChatTurn; const Instructions: string): TProc<TResponsesParams>;
```

Responsibilities:

- Detect whether the selected model is a **Deep Research** model.
- Force `Reasoning.Effort('medium')`.
- Enable Web Search Preview (`medium`) and the Code Interpreter.
- Inject the instruction string from Stage 2.
- Apply `DEEP\_RESEARCH\_NOT\_APPROPRIATE` if the query is too simple.

<br>

## Deep Research-Specific Parameters

- **Reasoning**

    ```pascal
    function CreateReasoningEffortDeepResearchParams: TReasoningParams;
    ```

  → Always sets `Effort('medium');` may add a summary if `Settings.UseSummary` is true.

<br>

- **Web Search**

    ```pascal
    function CreateWebSearchPreviewToolParamsWithContext: TResponseToolParams;
    ```

  → Forces `SearchContextSize('medium')`.

<br>

- **Code Interpreter**

    ```pascal
    function CreateCodeInterpreterContainer: TResponseCodeInterpreterParams;
    ```

  → Configures `Container('auto')` for automatic runtime selection.

<br>

## Streaming and Session Management

  Responses are streamed through:

  ```pascal
  FClient.Responses.AsyncAwaitCreateStream(...);
  ```

  Key callbacks: `OnStart`, `OnProgress`, `OnError`, `OnCancellation`, `OnSuccess`.
  Each chat turn (`TChatTurn`) is persisted in `PersistentChat`, storing:

- the user’s prompt,
- the generated instructions,
- the streamed output,
- and metadata (JSON serialization).

<br>

## Special Cases and Error Messages

- **Simple requests trigger:**

    ```text
    It’s not appropriate to use a deep research model for a simple web search.
    Please select another model.
    ```

<br>

- **User cancellations are handled by:**

    ```pascal
    procedure OnTurnDoCancel(Sender: TObject);
    ```

  which hides the reasoning bubble and marks the session as canceled.

<br>

- **Network or API errors are managed in:**

    ```pascal
    procedure OnTurnError(Sender: TObject; const Msg: string);
    ```

  ensuring UTF-8 clean output and proper UI recovery.

<br>

## Functional Summary

1. **Clarify**: `ExecuteClarifying(...)` collects missing info.
2. **Construct**: `BuildDeepResearchInstructions(...)` builds the research brief; `CreateStreamParams(...)` injects it.
3. **Execute**: `HandleDeepResearchProcess(...)` (UI) triggers `Execute(Prompt, Instructions)` (engine).
4. **Stream**: live response flow.
5. **Persist**: session and history updated.

<br>

## Key Takeaways

- Deep Research combines **external web data** and **internal vector-based knowledge**.
- The workflow follows a robust pipeline: **Clarify** → **Build Instructions** → **Research** → **Deliver**.
- Deep Research models always use `medium` **reasoning and context levels**.
- Execution is **asynchronous**, **persistent**, and **fully traceable**.
- Automatic model validation prevents inappropriate Deep Research use.

<br>

## Promise Orchestration for Stages 2 and 3

- [Control Logic: First vs. Second Invocation](#control-logic-first-vs-second-invocation)
- [Promise Chaining (Stage 2 → Stage 3)](#promise-chaining-stage-2--stage-3)
- [Optional Post-Processing (Naming Branch)](#optional-post-processing-naming-branch)
- [Error Handling and State Reset](#error-handling-and-state-reset)

<br>

  Stage 1 (**Clarifying**) runs independently through a direct call to `ExecuteClarifying`.
  Stages 2 and 3 (building and executing the Deep Research prompt) are **promise-chained** within

  ```pascal
  procedure TServicePrompt.HandleDeepResearchProcess(Sender: TObject); // UI.PromptEditor.VCL.pas
  ```

### Control Logic: First vs. Second Invocation

- **First invocation (`FDeepResearchPrompt.IsEmpty = True`):**

  - Retrieves and UTF-8 cleans the text from `FEditor.Lines.Text`.
  - Assigns it to `FDeepResearchPrompt`.
  - Executes only Stage 1:
    ```pascal
    OpenAI.ExecuteClarifying(Prompt).\&Catch(...);
    ```   
  - **No research yet:** only clarification.

<br>

  - **Second invocation (`FDeepResearchPrompt.IsEmpty = False`):**
      - Appends new user input to `FDeepResearchPrompt`.
      - Builds Deep Research instructions (Stage 2): 

        ```pascal 
        var Instructions := FSystemPromptBuilder.GetDeepReseachInstructions;
        var Promise := OpenAI.ExecuteSilently('gpt-4.1-nano', FDeepResearchPrompt, Instructions);
        EdgeDisplayer.ShowReasoning;
        ```
        Here, `ExecuteSilently('gpt-4.1-nano', …)` acts as an instruction composer, merging clarified data with `system\_prompt\_context\_deep\_research.txt` rules through `FSystemPromptBuilder`.

  <br>

### Promise Chaining (Stage 2 → Stage 3)

The **result** of the first promise (`Promise`, Stage 2) feeds into Stage 3:

  ```pascal
  Promise
    .\&Then<string>(
      function (Value: string): string
      begin
        // Value = final Deep Research instructions
        var DeepPromise := OpenAI.Execute(FDeepResearchPrompt, Value); // Stage 3
        ...
      end);
  ```

- `OpenAI.Execute(FDeepResearchPrompt, Value)` triggers the **actual Deep Research execution**, with Value as the instruction string.
- Before this chain, the UI shows the reasoning bubble (`EdgeDisplayer.ShowReasoning`), and hides it right after Stage 2 completes:

  ```pascal
    Promise
      .\&Then<string>(function (Value: string): string
        begin
          Result := Value;
          EdgeDisplayer.HideReasoning;
        end)
      .\&Catch(...);
    ``` 

  <br>

### Optional Post-Processing (Naming Branch)

  If `NeedToName` is `True`, an additional chain performs title generation:

1. **Prepare the naming prompt from the Deep Research output:**

   ```pascal
        .\&Then<string>(function (Value: string): string
          begin
            Result := PrepareNamingPromt(Value, Text);
          end)
        ```

2. **Generate a title using a small model:**

   ```pascal
        .\&Then(function (Value: string): TPromise<string>
          begin
            Result := OpenAI.ExecuteSilently('gpt-4.1-nano', Value, GetNamingInstructions);
          end)
        ```

3. **Apply and persist the title:**

   ```pascal
        .\&Then<string>(function (Value: string): string
          begin
            PersistentChat.CurrentChat.ApplyTitle(Value);
            PersistentChat.SaveToFile;
            ChatSessionHistoryView.Refresh(nil);
          end)
        ```

<br>

This sequence demonstrates **sequential promise orchestration**, where each asynchronous step explicitly depends on the previous output; ensuring clean state transitions and reliable UI behavior.

<br>

### Error Handling and State Reset

Each major promise segment includes its own `.Catch(...)` block:
- On Stage 2 (`Promise`) failure:
  - Displays the error (`AlertService.ShowError`).
  - Hides the reasoning bubble.
  - **Resets** `FDeepResearchPrompt := ''` to restart from Stage 1.
- On the naming branch, a local `Catch` prevents title errors from affecting the main Deep Research flow.

Finally, at the end of Stage 3, the system always resets:
```pascal
FDeepResearchPrompt := EmptyStr;
```

<br>

### In summary of Section 9:

- **Stage 1** runs independently and must precede all other calls.
- **Stages 2 and 3** are chained through promises in `HandleDeepResearchProcess`, with controlled reasoning-bubble UI state.
- The **optional naming phase** is fully promise-driven, with persistence and UI refresh.
- The internal variable `FDeepResearchPrompt` is **reset after each full cycle**, maintaining consistent execution flow.


This ensures that each new Deep Research cycle begins cleanly from the clarification phase.

<br>

### Reference code

To gain a comprehensive overview of the analyzed code and to develop a clear understanding of the promise orchestration in this specific context.

```pascal
procedure TServicePrompt.HandleDeepResearchProcess(Sender: TObject);
begin
  {--- We are keeping the stored files to stay in line with the philosophy of the POC. }
  if FileStoreManager.VectorStore.Trim.IsEmpty and not CanExecute then
    Exit;

  EdgeDisplayer.Show;

  var Prompt := TUtf8Mapping.CleanTextAsUTF8(FEditor.Lines.Text);
  if not string(Prompt).Trim.IsEmpty then
    begin
      if FDeepResearchPrompt.IsEmpty then
        begin
          FDeepResearchPrompt := Prompt;
          OpenAI.ExecuteClarifying(Prompt)
            .&Catch(
              procedure(E: Exception)
                begin
                  AlertService.ShowError(E.Message);
                end);
        end
      else
        begin
          var Instructions := FSystemPromptBuilder.GetDeepReseachInstructions;
          FDeepResearchPrompt := FDeepResearchPrompt + Prompt;
          Clear;
          var Promise := OpenAI.ExecuteSilently('gpt-4.1-nano', FDeepResearchPrompt, Instructions);
          EdgeDisplayer.ShowReasoning;

          Promise
            .&Then<string>(
              function (Value: string): string
              begin
                Result := Value;
                EdgeDisplayer.HideReasoning;
              end)
            .&Catch(
              procedure(E: Exception)
              begin
                AlertService.ShowError(E.Message);
                EdgeDisplayer.HideReasoning;
                FDeepResearchPrompt := EmptyStr;
              end);

          Promise
            .&Then<string>(
              function (Value: string): string
              begin
                var DeepPromise := OpenAI.Execute(FDeepResearchPrompt, Value);

                if NeedToName then
                  begin
                    DeepPromise
                      .&Then<string>(
                        function (Value: string): string
                        begin
                          Result := PrepareNamingPromt(Value, Text);
                        end)
                      .&Then(
                        function (Value: string): TPromise<string>
                        begin
                          {--- Find a fileName }
                          Result := OpenAI.ExecuteSilently('gpt-4.1-nano', Value, GetNamingInstructions);
                        end)
                      .&Then<string>(
                        function (Value: string): string
                        begin
                          PersistentChat.CurrentChat.ApplyTitle(Value);
                          PersistentChat.SaveToFile;
                          ChatSessionHistoryView.Refresh(nil);
                        end)
                      .&Catch(
                        procedure(E: Exception)
                        begin
                          AlertService.ShowError(E.Message);
                        end);
                  end;
                FDeepResearchPrompt := EmptyStr;
              end);
        end;
    end;
  SetFocus;
end;

```
