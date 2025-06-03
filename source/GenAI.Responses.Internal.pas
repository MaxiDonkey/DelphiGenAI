unit GenAI.Responses.Internal;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGenAI
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.SysUtils, System.Classes, System.Threading,
  GenAI.API.Params, GenAI.API, GenAI.Consts, GenAI.Types,
  GenAI.Async.Params, GenAI.Async.Support, GenAI.Async.Promise, GenAI.Chat.Parallel,
  GenAI.Responses.InputParams, GenAI.Responses.InputItemList, GenAI.Responses.OutputParams;

type
  /// <summary>
  /// Represents the callback procedure type used for processing streaming AI responses.
  /// </summary>
  /// <param name="Response">
  /// A variable of type TResponseStream containing the latest chunk of streamed response data.
  /// </param>
  /// <param name="IsDone">
  /// A Boolean value indicating whether the streaming response has completed.
  /// </param>
  /// <param name="Cancel">
  /// A variable Boolean that can be set to True to cancel further streaming events.
  /// </param>
  /// <remarks>
  /// TResponseEvent is used in streaming methods to deliver incremental response data.
  /// This callback is invoked repeatedly as new data becomes available. When <paramref name="IsDone"/> is True,
  /// the streaming process has finished, and no further updates will be sent. If needed, you can set <paramref name="Cancel"/>
  /// to True in order to stop receiving additional streamed data.
  /// </remarks>
  TResponseEvent = reference to procedure(var Response: TResponseStream; IsDone: Boolean; var Cancel: Boolean);

  /// <summary>
  /// Manages asynchronous responses callBacks for a responses request using <c>TResponse</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynResponse</c> type extends the <c>TAsynParams&lt;TResponse&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking chat operations and is specifically tailored for scenarios where multiple choices from a chat model are required.
  /// </remarks>
  TAsynResponse = TAsynCallBack<TResponse>;

  /// <summary>
  /// Manages asynchronous responses callBacks for a promise request using <c>TResponse</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TPromiseResponse</c> type extends the <c>TAsynParams&lt;TResponse&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// </remarks>
  TPromiseResponse = TPromiseCallBack<TResponse>;

  /// <summary>
  /// Manages asynchronous streaming responses callBacks for a responses request using <c>TResponseStream</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynResponseStream</c> type extends the <c>TAsynStreamParams&lt;TResponseStream&gt;</c> record to support the lifecycle of an asynchronous streaming responses operation.
  /// It provides callbacks for different stages, including when the operation starts, progresses with new data chunks, completes successfully, or encounters an error.
  /// This structure is ideal for handling scenarios where the responses response is streamed incrementally, providing real-time updates to the user interface.
  /// </remarks>
  TAsynResponseStream = TAsynStreamCallBack<TResponseStream>;

  /// <summary>
  /// Manages asynchronous streaming responses callBacks for a responses request using <c>TResponseStream</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TPromiseResponseStream</c> type extends the <c>TAsynStreamParams&lt;TResponseStream&gt;</c> record to support the lifecycle of an asynchronous streaming responses operation.
  /// It provides callbacks for different stages, including when the operation starts, progresses with new data chunks, completes successfully, or encounters an error.
  /// This structure is ideal for handling scenarios where the responses response is streamed incrementally, providing real-time updates to the user interface.
  /// </remarks>
  TPromiseResponseStream = TPromiseStreamCallBack<TResponseStream>;

  /// <summary>
  /// Manages asynchronous callbacks for a response deletion request.
  /// </summary>
  /// <remarks>
  /// This type is a specialized alias for <c>TAsynCallBack&lt;TResponseDelete&gt;</c> and is used to handle asynchronous operations
  /// related to deletion requests. It encapsulates a <c>TResponseDelete</c> instance containing details about the deletion outcome,
  /// including the identifier of the deleted response, the type of object involved, and a boolean flag indicating if the deletion
  /// was successful. This mechanism allows for non-blocking deletion operations and provides a consistent interface for handling
  /// deletion responses in asynchronous workflows.
  /// </remarks>
  TAsynResponseDelete = TAsynCallBack<TResponseDelete>;

  /// <summary>
  /// Manages asynchronous responses callBacks for a promise request using <c>TResponseDelete</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TPromiseResponseDelete</c> type extends the <c>TAsynParams&lt;TResponseDelete&gt;</c> record to handle the lifecycle of an asynchronous operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// </remarks>
  TPromiseResponseDelete = TPromiseCallBack<TResponseDelete>;

  /// <summary>
  /// Provides an asynchronous callback mechanism for handling operations that return a collection of responses.
  /// </summary>
  /// <remarks>
  /// This type is an alias for <c>TAsynCallBack&lt;TResponses&gt;</c>, which facilitates asynchronous workflows by encapsulating
  /// the results of operations that yield a paginated set of response items. The underlying <c>TResponses</c> type represents
  /// a structured collection that includes metadata for pagination (such as first and last identifiers, and a flag indicating
  /// whether more data is available) and an array of <c>TResponseItem</c> instances. Each <c>TResponseItem</c> may contain various
  /// elements such as text content, annotations, file search results, and tool call outputs. This design supports non-blocking
  /// operations and efficient handling of complex response data in an asynchronous context.
  /// </remarks>
  TAsynResponses = TAsynCallBack<TResponses>;

  /// <summary>
  /// Manages asynchronous responses callBacks for a promise request using <c>TResponses</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TPromiseResponses</c> type extends the <c>TAsynParams&lt;TResponses&gt;</c> record to handle the lifecycle of an asynchronous operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// </remarks>
  TPromiseResponses = TPromiseCallBack<TResponses>;

  TInternalStreaming = class(TGenAIRoute)
  const
    MaxTrail = 4;
  private
    {--- Persistent state for an SSE stream }
    FDecoder: TEncoding;
    FByteBuffer: TBytes;
    FCharBuffer: TStringBuilder;
    FCurrentEvent: string;
    FCurrentData: string;
  protected
    function ProcessLines(Event: TResponseEvent): Boolean;
    function DecodeChunk(const ABytes: TBytes; Event: TResponseEvent): Boolean;
    function InternalCreateStream(ParamProc: TProc<TResponsesParams>; Event: TResponseEvent): Boolean;
  end;

  TInternalResponseRoute = class(TInternalStreaming)
  protected
    procedure InternalAsynCreate(ParamProc: TProc<TResponsesParams>; CallBacks: TFunc<TAsynResponse>);
    procedure InternalAsynCreateStream(ParamProc: TProc<TResponsesParams>; CallBacks: TFunc<TAsynResponseStream>);
    procedure InternalCreateParallel(ParamProc: TProc<TBundleParams>; const CallBacks: TFunc<TAsynBundleList>);
    function Create(ParamProc: TProc<TResponsesParams>): TResponse; virtual; abstract;
    function CreateStream(ParamProc: TProc<TResponsesParams>; Event: TResponseEvent): Boolean; virtual; abstract;
  end;

implementation

{ TInternalResponseRoute }

procedure TInternalResponseRoute.InternalAsynCreate(
  ParamProc: TProc<TResponsesParams>; CallBacks: TFunc<TAsynResponse>);
begin
  with TAsynCallBackExec<TAsynResponse, TResponse>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TResponse
      begin
        Result := Self.Create(ParamProc);
      end);
  finally
    Free;
  end;
end;

procedure TInternalResponseRoute.InternalAsynCreateStream(
  ParamProc: TProc<TResponsesParams>; CallBacks: TFunc<TAsynResponseStream>);
begin
  var CallBackParams := TUseParamsFactory<TAsynResponseStream>.CreateInstance(CallBacks);

  var Sender := CallBackParams.Param.Sender;
  var OnStart := CallBackParams.Param.OnStart;
  var OnSuccess := CallBackParams.Param.OnSuccess;
  var OnProgress := CallBackParams.Param.OnProgress;
  var OnError := CallBackParams.Param.OnError;
  var OnCancellation := CallBackParams.Param.OnCancellation;
  var OnDoCancel := CallBackParams.Param.OnDoCancel;
  var CancelTag := 0;

  var Task: ITask := TTask.Create(
          procedure()
          begin
            {--- Pass the instance of the current class in case no value was specified. }
            if not Assigned(Sender) then
              Sender := Self;

            {--- Trigger OnStart callback }
            if Assigned(OnStart) then
              TThread.Queue(nil,
                procedure
                begin
                  OnStart(Sender);
                end);
            try
              var Stop := False;

              {--- Processing }
              CreateStream(ParamProc,
                procedure (var Response: TResponseStream; IsDone: Boolean; var Cancel: Boolean)
                begin
                  {--- Check that the process has not been canceled }
                  if Assigned(OnDoCancel) and (CancelTag = 0) then
                    TThread.Queue(nil,
                        procedure
                        begin
                          Stop := OnDoCancel();
                          if Stop then
                            Inc(CancelTag);
                        end);
                  if Stop then
                    begin
                      {--- Trigger when processus was stopped }
                      if (CancelTag = 1) and Assigned(OnCancellation) then
                        TThread.Queue(nil,
                        procedure
                        begin
                          OnCancellation(Sender);
                        end);
                      Inc(CancelTag);
                      Cancel := True;
                      Exit;
                    end;
                  if not IsDone and Assigned(Response) then
                    begin
                      var LocalResponse := Response;
                      Response := nil;

                      {--- Triggered when processus is progressing }
                      if Assigned(OnProgress) then
                        TThread.Synchronize(TThread.Current,
                        procedure
                        begin
                          try
                            OnProgress(Sender, LocalResponse);
                          finally
                            {--- Makes sure to release the instance containing the data obtained
                                 following processing}
                            LocalResponse.Free;
                          end;
                        end)
                     else
                       LocalResponse.Free;
                    end
                  else
                  if IsDone then
                    begin
                      {--- Trigger OnEnd callback when the process is done }
                      if Assigned(OnSuccess) then
                        TThread.Queue(nil,
                        procedure
                        begin
                          OnSuccess(Sender);
                        end);
                    end;
                end);
            except
              on E: Exception do
                begin
                  var Error := AcquireExceptionObject;
                  try
                    var ErrorMsg := (Error as Exception).Message;

                    {--- Trigger OnError callback if the process has failed }
                    if Assigned(OnError) then
                      TThread.Queue(nil,
                      procedure
                      begin
                        OnError(Sender, ErrorMsg);
                      end);
                  finally
                    {--- Ensures that the instance of the caught exception is released}
                    Error.Free;
                  end;
                end;
            end;
          end);
  Task.Start;
end;

procedure TInternalResponseRoute.InternalCreateParallel(
  ParamProc: TProc<TBundleParams>; const CallBacks: TFunc<TAsynBundleList>);
var
  Tasks: TArray<ITask>;
  BundleParams: TBundleParams;
  ReasoningEffort: string;
begin
  BundleParams := TBundleParams.Create;
  try
    if not Assigned(ParamProc) then
      raise Exception.Create('The lambda can''t be null');

    ParamProc(BundleParams);
    var Bundle := TBundleList.Create;
    var Ranking := 0;
    var ErrorExists := False;
    var Prompts := BundleParams.GetPrompt;
    var Counter := Length(Prompts);

    {--- Set the reasoning effort if necessary }
    if IsReasoningModel(BundleParams.GetModel) then
      ReasoningEffort := BundleParams.GetReasoningEffort
    else
      ReasoningEffort := EmptyStr;

    if Assigned(CallBacks.OnStart) then
      CallBacks.OnStart(CallBacks.Sender);

    SetLength(Tasks, Length(Prompts));
    for var index := 0 to Pred(Length(Prompts)) do
      begin
        Tasks[index] := TTask.Run(
          procedure
          begin
            var Buffer := Bundle.Add(index + 1);
            Buffer.Prompt := Prompts[index];
            try
              var Response := Create(
                procedure (Params: TResponsesParams)
                begin
                  {--- Set the model for the process }
                  Params.Model(BundleParams.GetModel);

                  {--- If reasoning model then set de reasoning parameters }
                  if not ReasoningEffort.IsEmpty then
                    Params.Reasoning(TReasoningParams.New.Effort(ReasoningEffort));

                  {--- Set the developer instructions }
                  Params.Instructions(BundleParams.GetSystem);

                  {--- Set the current prompt }
                  Params.Input(Buffer.Prompt);

                  {--- Set the web search parameters if necessary }
                  if not BundleParams.GetSearchSize.IsEmpty then
                    begin
                      var Search_web := TResponseWebSearchParams.New.SearchContextSize(BundleParams.GetSearchSize);

                      {---- Set the location if necessary }
                      if not BundleParams.GetCity.IsEmpty or
                         not BundleParams.GetCountry.IsEmpty then
                        begin
                          {--- "Location object" instantiation }
                          var Locate := TResponseUserLocationParams.New;

                          {--- Process for the city location }
                          if not BundleParams.GetCity.IsEmpty then
                            Locate.City(BundleParams.GetCity);

                            {--- Process for the country location }
                          if not BundleParams.GetCountry.IsEmpty then
                            Locate.Country(BundleParams.GetCountry);

                          {--- Sets the location object into the Search_web instance  }
                          Search_web.UserLocation(Locate);
                        end;

                      {--- Set the web search tool }
                      Params.Tools([Search_web]);
                    end;

                  {--- No storage because this type of treatment must be ephemeral }
                  Params.Store(False);
                end);
              Inc(Ranking);
              Buffer.FinishIndex := Ranking;

              {--- Construct the response as a directly usable text }
              for var Item in Response.Output do
                for var SubItem in Item.Content do
                  Buffer.Response := Buffer.Response + SubItem.Text + #10;

              {--- Return the "Response" object in the buffer }
              Buffer.Chat := Response;
            except
              on E: Exception do
                begin
                  {--- Catch the exception }
                  var Error := AcquireExceptionObject;
                  ErrorExists := True;
                  try
                    var ErrorMsg := (Error as Exception).Message;
                    {--- Trigger OnError callback if the process has failed }
                    if Assigned(CallBacks.OnError) then
                      TThread.Queue(nil,
                      procedure
                      begin
                        CallBacks.OnError(CallBacks.Sender, ErrorMsg);
                      end);
                  finally
                    {--- Ensures that the instance of the caught exception is released}
                    Error.Free;
                  end;
                end;
            end;
          end);

        if ErrorExists then
          Continue;

        {--- TTask.WaitForAll is not used due to a memory leak in TLightweightEvent/TCompleteEventsWrapper.
             See report RSP-12462 and RSP-25999. }
        TTaskHelper.ContinueWith(Tasks[Index],
          procedure
          begin
            Dec(Counter);
            if Counter = 0 then
              begin
                try
                  if not ErrorExists and Assigned(CallBacks.OnSuccess) then
                    CallBacks.OnSuccess(CallBacks.Sender, Bundle);
                finally
                  Bundle.Free;
                end;
              end;
          end);
        {--- Need a delay, otherwise the process runs only with the first task. }
        Sleep(30);
      end;
  finally
    BundleParams.Free;
  end;
end;

{ TInternalStreaming }

function TInternalStreaming.DecodeChunk(const ABytes: TBytes;
  Event: TResponseEvent): Boolean;
var
  SafeLen: Integer;
  Utf8Enc: TEncoding;
  ChunkStr: string;
begin
  Result := False;

  {--- Stacks the data }
  FByteBuffer := FByteBuffer + ABytes;

  {--- Search for the last safe UTF-8 boundary }
  SafeLen := Length(FByteBuffer);
  if SafeLen > 0 then
    begin
      var i := 0;
      Utf8Enc := TEncoding.UTF8;

      while (i < MaxTrail) and (SafeLen - i > 0) do
        begin
          if Utf8Enc.IsBufferValid(@FByteBuffer[0], SafeLen - i) then
            begin
              SafeLen := SafeLen - i;
              Break;
            end;
          Inc(i);
        end;
      if (i = MaxTrail) and (not Utf8Enc.IsBufferValid(@FByteBuffer[0], SafeLen)) then
        {--- No complete ending yet }
        Exit(False);
    end;

  {--- Decodes the complete part, stores the remainder }
  if SafeLen > 0 then
    begin
      SetLength(ChunkStr, 0);
      SetString(ChunkStr, PChar(nil), 0);
      ChunkStr := TEncoding.UTF8.GetString(FByteBuffer, 0, SafeLen);
      FCharBuffer.Append(ChunkStr);

      if SafeLen < Length(FByteBuffer) then
        FByteBuffer := Copy(FByteBuffer, SafeLen, MaxInt)
      else
        SetLength(FByteBuffer, 0);
    end;

  {--- Processes complete lines }
  if FCharBuffer.Length > 0 then
    Result := ProcessLines(Event);
end;

function TInternalStreaming.InternalCreateStream(
  ParamProc: TProc<TResponsesParams>; Event: TResponseEvent): Boolean;
(*
    {"type":"response.created","response":{"id":"resp_67ffeb4f88f4819183b0c7bfd76270970c4424583b6f214d","object":"response","created_at":1744825167,"status":"in_progress","error":null,"incomplete_details":null,"instructions":null,"max_output_tokens":null,"model":"gpt-4.1-nano-2025-04-14","output":[],"parallel_tool_calls":true,"previous_response_id":null,"reasoning":{"effort":null,"summary":null},"store":false,"temperature":1.0,"text":{"format":{"type":"text"}},"tool_choice":"auto","tools":[],"top_p":1.0,"truncation":"disabled","usage":null,"user":null,"metadata":{}}}
    {"type":"response.in_progress","response":{"id":"resp_67ffeb4f88f4819183b0c7bfd76270970c4424583b6f214d","object":"response","created_at":1744825167,"status":"in_progress","error":null,"incomplete_details":null,"instructions":null,"max_output_tokens":null,"model":"gpt-4.1-nano-2025-04-14","output":[],"parallel_tool_calls":true,"previous_response_id":null,"reasoning":{"effort":null,"summary":null},"store":false,"temperature":1.0,"text":{"format":{"type":"text"}},"tool_choice":"auto","tools":[],"top_p":1.0,"truncation":"disabled","usage":null,"user":null,"metadata":{}}}
    {"type":"response.output_item.added","output_index":0,"item":{"id":"msg_67ffeb4fbe28819193360cdfa54b544e0c4424583b6f214d","type":"message","status":"in_progress","content":[],"role":"assistant"}}
    {"type":"response.content_part.added","item_id":"msg_67ffeb4fbe28819193360cdfa54b544e0c4424583b6f214d","output_index":0,"content_index":0,"part":{"type":"output_text","annotations":[],"text":""}}
    {"type":"response.output_text.delta","item_id":"msg_67ffeb4fbe28819193360cdfa54b544e0c4424583b6f214d","output_index":0,"content_index":0,"delta":"Great"}
    ...
    {"type":"response.output_text.done","item_id":"msg_67ffeb4fbe28819193360cdfa54b544e0c4424583b6f214d","output_index":0,"content_index":0,"text":"message."}
    {"type":"response.content_part.done","item_id":"msg_67ffeb4fbe28819193360cdfa54b544e0c4424583b6f214d","output_index":0,"content_index":0,"part":{"type":"output_text","annotations":[],"text":"message"}}
    {"type":"response.output_item.done","output_index":0,"item":{"id":"msg_67ffeb4fbe28819193360cdfa54b544e0c4424583b6f214d","type":"message","status":"completed","content":[{"type":"output_text","annotations":[],"text":"messagele":"assistant"}}
*)

var
  Response: TMemoryStream;
  Consumed: Int64;
begin
  {--- Initialization of streaming fields }
  FDecoder := TEncoding.UTF8;
  FByteBuffer := nil;
  FCharBuffer := TStringBuilder.Create;
  FCurrentEvent := '';
  FCurrentData := '';

  Response := TMemoryStream.Create;
  Consumed := 0;

  try
    Result := API.Post<TResponsesParams>('responses', ParamProc, Response,
      procedure(const Sender: TObject;
        AContentLength, AReadCount: Int64;
        var AAbort: Boolean)
      var
        Delta : Int64;
        Chunk : TBytes;
      begin
        Delta := Response.Size - Consumed;
        if Delta <= 0 then Exit;

        SetLength(Chunk, Delta);
        Response.Position := Consumed;
        Response.ReadBuffer(Chunk[0], Delta);
        Consumed := Consumed + Delta;

        DecodeChunk(Chunk, Event);
      end);
  finally
    {--- Process any remaining balance }
    if FCharBuffer.Length > 0 then
      begin
        Result := ProcessLines(Event);
      end;

    FCharBuffer.Free;
    Response.Free;
  end;
end;

function TInternalStreaming.ProcessLines(Event: TResponseEvent): Boolean;
var
  RespObj: TResponseStream;
  IsDone: Boolean;
begin
  Result := False;

  var StartPos := 0;
  while True do
    begin
      var LFPos := FCharBuffer.ToString.IndexOf(#10, StartPos);
      if LFPos = -1 then Break;

      var Line := FCharBuffer.ToString.Substring(StartPos, LFPos - StartPos)
                         .Trim([' ', #13, #10]);
      StartPos := LFPos + 1;

      if Line = '' then
        begin
          if not FCurrentData.Trim.IsEmpty then
            begin
              IsDone := SameText(FCurrentEvent, 'response.completed');
              RespObj := nil;
              if not IsDone and
                 ((FCurrentData[1] = '{') or (FCurrentData[1] = '[')) then
              try
                RespObj := TApiDeserializer.Parse<TResponseStream>(FCurrentData);
              except
                RespObj := nil;
              end;

              Event(RespObj, IsDone, Result);
              RespObj.Free;
            end;

          FCurrentEvent := EmptyStr;
          FCurrentData := EmptyStr;
        end
      else
        if Line.StartsWith('event: ') then
          begin
            FCurrentEvent := Line.Substring(7).Trim;
          end
        else
          if Line.StartsWith('data: ') then
            begin
              if not FCurrentData.IsEmpty then
                FCurrentData := FCurrentData + sLineBreak;
              FCurrentData := FCurrentData + Line.Substring(6).Trim;
            end;
    end;

  if StartPos > 0 then
    FCharBuffer.Remove(0, StartPos);
end;

end.
