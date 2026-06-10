unit Demo.OpenAI.Agent.LocalApply;

interface

uses
  System.SysUtils;

type
  TOpenAILocalApplyFile = record
    SandboxPath: string;
    LocalRelativePath: string;
    ChangeType: string;
    RequiresUserConfirmation: Boolean;
  end;

  TOpenAILocalApplyPlan = record
    ManifestText: string;
    DiffText: string;
    Files: TArray<TOpenAILocalApplyFile>;
  end;

  TOpenAILocalApply = record
  public const
    ManifestBegin = 'PYTHIA_LOCAL_APPLY_MANIFEST_BEGIN';
    ManifestEnd = 'PYTHIA_LOCAL_APPLY_MANIFEST_END';
    DiffBegin = 'PYTHIA_UNIFIED_DIFF_BEGIN';
    DiffEnd = 'PYTHIA_UNIFIED_DIFF_END';
  private
    class function ExtractBetween(const Text, BeginMarker,
      EndMarker: string; out Block: string): Boolean; static;
    class function StripCodeFence(const Text: string): string; static;
    class function ManifestValue(const Manifest, Key: string): string; static;
    class function SafeRelativePath(const RelativePath: string): Boolean; static;
    class function ResolveLocalPath(const LocalRoot,
      RelativePath: string): string; static;
    class function SplitLines(const Text: string): TArray<string>; static;
    class function SplitContentLines(const Text: string;
      out LineBreak: string; out HasFinalLineBreak: Boolean): TArray<string>; static;
    class function JoinContentLines(const Lines: TArray<string>;
      const LineBreak: string; const HasFinalLineBreak: Boolean): string; static;
    class function FindSequence(const Lines, Sequence: TArray<string>;
      const StartIndex: Integer): Integer; static;
    class function ReplaceRange(const Lines, NewLines: TArray<string>;
      const Index, Count: Integer): TArray<string>; static;
    class function ApplyUnifiedDiffToText(const Original,
      DiffText: string; out Updated, Error: string): Boolean; static;
  public
    class function TryExtract(const Text: string; out Plan: TOpenAILocalApplyPlan;
      out Error: string): Boolean; static;
    class function TryApply(const Plan: TOpenAILocalApplyPlan;
      const LocalRoot: string; out Detail: string): Boolean; static;
    class function PreviewMarkdown(const Plan: TOpenAILocalApplyPlan): string; static;
  end;

implementation

{$REGION 'Dev note'}
(*

  Local application of sandbox edit proposals for the pythia-openai FMX demo.

  OpenAI code_interpreter receives uploaded project files and works on that
  controlled copy. The agent must never directly edit the user's local disk.
  When it wants to offer a local change, it returns two explicit marker blocks:

    PYTHIA_LOCAL_APPLY_MANIFEST_BEGIN / END
    PYTHIA_UNIFIED_DIFF_BEGIN / END

  This unit extracts that response shape, validates the local relative path,
  builds a Markdown preview for the operator, and applies the diff to the
  selected local folder only after Pythia has asked for confirmation.

  The patch applier intentionally supports the small unified-diff subset needed
  by this demo card: one existing file, change_type=modify, with context that
  must still match the local file.

*)
{$ENDREGION}

uses
  System.Classes, System.IOUtils,
  WVPythia.TextFile.Helper;

class function TOpenAILocalApply.ExtractBetween(const Text, BeginMarker,
  EndMarker: string; out Block: string): Boolean;
begin
  Block := '';
  Result := False;

  var BeginPos := Pos(BeginMarker, Text);
  if BeginPos <= 0 then
    Exit;

  var Tail := Text.Substring(BeginPos + BeginMarker.Length - 1);
  var EndPos := Pos(EndMarker, Tail);
  if EndPos <= 0 then
    Exit;

  Block := Tail.Substring(0, EndPos - 1).Trim;
  Result := True;
end;

class function TOpenAILocalApply.StripCodeFence(const Text: string): string;
begin
  var Lines := SplitLines(Text.Trim);
  if Length(Lines) = 0 then
    Exit('');

  var First := 0;
  var Last := High(Lines);

  if Lines[First].Trim.StartsWith('```') then
    Inc(First);

  if (Last >= First) and Lines[Last].Trim.StartsWith('```') then
    Dec(Last);

  var SL := TStringList.Create;
  try
    for var index := First to Last do
      SL.Add(Lines[index]);
    Result := SL.Text.Trim;
  finally
    SL.Free;
  end;
end;

class function TOpenAILocalApply.SplitLines(const Text: string): TArray<string>;
begin
  var Normalized := Text.Replace(#13#10, #10, [rfReplaceAll])
    .Replace(#13, #10, [rfReplaceAll]);
  Result := Normalized.Split([#10]);
end;

class function TOpenAILocalApply.ManifestValue(
  const Manifest, Key: string): string;
begin
  Result := '';
  for var Line in SplitLines(Manifest) do
    begin
      var Trimmed := Line.Trim;
      if Trimmed.StartsWith(Key + '=', True) then
        Exit(Trimmed.Substring(Key.Length + 1).Trim);
    end;
end;

class function TOpenAILocalApply.SafeRelativePath(
  const RelativePath: string): Boolean;
begin
  Result := False;

  var SlashPath := RelativePath.Trim.Replace('\', '/', [rfReplaceAll]);
  if SlashPath.IsEmpty then
    Exit;

  if TPath.IsPathRooted(SlashPath) or SlashPath.StartsWith('/') then
    Exit;

  for var Part in SlashPath.Split(['/']) do
    if (Part = '..') or Part.Trim.IsEmpty then
      Exit;

  Result := True;
end;

class function TOpenAILocalApply.ResolveLocalPath(const LocalRoot,
  RelativePath: string): string;
begin
  if not SafeRelativePath(RelativePath) then
    raise Exception.Create('Unsafe relative path in local apply manifest: ' +
      RelativePath);

  var Root := TPath.GetFullPath(ExcludeTrailingPathDelimiter(LocalRoot.Trim));
  var RootWithDelimiter := IncludeTrailingPathDelimiter(Root);
  var LocalRelative := RelativePath.Replace('/', PathDelim, [rfReplaceAll]);
  Result := TPath.GetFullPath(TPath.Combine(RootWithDelimiter, LocalRelative));

  if not Result.StartsWith(RootWithDelimiter, True) then
    raise Exception.Create('Resolved path escapes the selected project folder: ' +
      RelativePath);
end;

class function TOpenAILocalApply.SplitContentLines(const Text: string;
  out LineBreak: string; out HasFinalLineBreak: Boolean): TArray<string>;
begin
  if Pos(#13#10, Text) > 0 then
    LineBreak := #13#10
  else
  if Pos(#10, Text) > 0 then
    LineBreak := #10
  else
    LineBreak := sLineBreak;

  HasFinalLineBreak :=
    Text.EndsWith(#13#10) or Text.EndsWith(#10) or Text.EndsWith(#13);

  var Normalized := Text.Replace(#13#10, #10, [rfReplaceAll])
    .Replace(#13, #10, [rfReplaceAll]);

  if HasFinalLineBreak and Normalized.EndsWith(#10) then
    Delete(Normalized, Length(Normalized), 1);

  if Normalized.IsEmpty then
    begin
      Result := [];
      Exit;
    end;

  Result := Normalized.Split([#10]);
end;

class function TOpenAILocalApply.JoinContentLines(const Lines: TArray<string>;
  const LineBreak: string; const HasFinalLineBreak: Boolean): string;
begin
  Result := string.Join(LineBreak, Lines);
  if HasFinalLineBreak then
    Result := Result + LineBreak;
end;

class function TOpenAILocalApply.FindSequence(const Lines,
  Sequence: TArray<string>; const StartIndex: Integer): Integer;
begin
  Result := -1;
  if Length(Sequence) = 0 then
    Exit;

  var LastStart := Length(Lines) - Length(Sequence);
  if LastStart < 0 then
    Exit;

  var First := StartIndex;
  if First < 0 then
    First := 0;

  for var I := First to LastStart do
    begin
      var Match := True;
      for var J := 0 to High(Sequence) do
        if Lines[I + J] <> Sequence[J] then
          begin
            Match := False;
            Break;
          end;

      if Match then
        Exit(I);
    end;
end;

class function TOpenAILocalApply.ReplaceRange(const Lines,
  NewLines: TArray<string>; const Index, Count: Integer): TArray<string>;
begin
  SetLength(Result, Length(Lines) - Count + Length(NewLines));

  var OutIndex := 0;
  for var I := 0 to Index - 1 do
    begin
      Result[OutIndex] := Lines[I];
      Inc(OutIndex);
    end;

  for var I := 0 to High(NewLines) do
    begin
      Result[OutIndex] := NewLines[I];
      Inc(OutIndex);
    end;

  for var I := Index + Count to High(Lines) do
    begin
      Result[OutIndex] := Lines[I];
      Inc(OutIndex);
    end;
end;

class function TOpenAILocalApply.ApplyUnifiedDiffToText(const Original,
  DiffText: string; out Updated, Error: string): Boolean;
begin
  Result := False;
  Error := '';
  Updated := Original;

  var LineBreak: string;
  var HasFinalLineBreak: Boolean;
  var Current := SplitContentLines(Original, LineBreak, HasFinalLineBreak);
  var DiffLines := SplitLines(StripCodeFence(DiffText));
  var SearchFrom := 0;
  var AppliedHunks := 0;

  var I := 0;
  while I <= High(DiffLines) do
    begin
      if not DiffLines[I].StartsWith('@@') then
        begin
          Inc(I);
          Continue;
        end;

      var OldLines: TArray<string> := [];
      var NewLines: TArray<string> := [];
      Inc(I);

      while I <= High(DiffLines) do
        begin
          var Line := DiffLines[I];
          if Line.StartsWith('@@') or Line.StartsWith('--- ') or
             Line.StartsWith('diff --git') then
            Break;

          if Line.StartsWith('\') then
            begin
              Inc(I);
              Continue;
            end;

          if Line.IsEmpty then
            begin
              Inc(I);
              Continue;
            end;

          var Prefix := Line[1];
          var Payload := Line.Substring(1);

          case Prefix of
            ' ':
              begin
                OldLines := OldLines + [Payload];
                NewLines := NewLines + [Payload];
              end;
            '-':
              OldLines := OldLines + [Payload];
            '+':
              NewLines := NewLines + [Payload];
          end;

          Inc(I);
        end;

      if Length(OldLines) = 0 then
        begin
          Error := 'Only modify hunks with existing context are supported.';
          Exit;
        end;

      var PosFound := FindSequence(Current, OldLines, SearchFrom);
      if PosFound < 0 then
        PosFound := FindSequence(Current, OldLines, 0);

      if PosFound < 0 then
        begin
          Error := 'The local file no longer matches the diff context.';
          Exit;
        end;

      Current := ReplaceRange(Current, NewLines, PosFound, Length(OldLines));
      SearchFrom := PosFound + Length(NewLines);
      Inc(AppliedHunks);
    end;

  if AppliedHunks = 0 then
    begin
      Error := 'No unified diff hunk was found.';
      Exit;
    end;

  Updated := JoinContentLines(Current, LineBreak, HasFinalLineBreak);
  Result := True;
end;

class function TOpenAILocalApply.TryExtract(const Text: string;
  out Plan: TOpenAILocalApplyPlan; out Error: string): Boolean;
begin
  Plan := Default(TOpenAILocalApplyPlan);
  Error := '';
  Result := False;

  var ManifestBlock := '';
  var DiffBlock := '';
  var HasManifest := ExtractBetween(Text, ManifestBegin, ManifestEnd, ManifestBlock);
  var HasDiff := ExtractBetween(Text, DiffBegin, DiffEnd, DiffBlock);

  if not HasManifest and not HasDiff then
    Exit;

  if not HasManifest or not HasDiff then
    begin
      Error := 'The local apply response must contain both manifest and diff markers.';
      Exit;
    end;

  Plan.ManifestText := StripCodeFence(ManifestBlock);
  Plan.DiffText := StripCodeFence(DiffBlock);

  var FileCount := 0;
  if not TryStrToInt(ManifestValue(Plan.ManifestText, 'files'), FileCount) then
    FileCount := 0;

  for var index := 0 to FileCount - 1 do
    begin
      var Item := Default(TOpenAILocalApplyFile);
      Item.SandboxPath :=
        ManifestValue(Plan.ManifestText, Format('file[%d].sandbox_path', [index]));
      Item.LocalRelativePath :=
        ManifestValue(Plan.ManifestText, Format('file[%d].local_relative_path', [index]));
      Item.ChangeType :=
        ManifestValue(Plan.ManifestText, Format('file[%d].change_type', [index]));
      if Item.ChangeType.Trim.IsEmpty then
        Item.ChangeType := 'modify';
      Item.RequiresUserConfirmation := SameText(
        ManifestValue(Plan.ManifestText,
          Format('file[%d].requires_user_confirmation', [index])), 'true');

      if Item.LocalRelativePath.Trim.IsEmpty then
        begin
          Error := Format('Missing local_relative_path for file[%d].', [index]);
          Exit;
        end;

      Plan.Files := Plan.Files + [Item];
    end;

  if Length(Plan.Files) = 0 then
    begin
      Error := 'The local apply manifest does not describe any file.';
      Exit;
    end;

  if Plan.DiffText.Trim.IsEmpty then
    begin
      Error := 'The unified diff block is empty.';
      Exit;
    end;

  Result := True;
end;

class function TOpenAILocalApply.TryApply(const Plan: TOpenAILocalApplyPlan;
  const LocalRoot: string; out Detail: string): Boolean;
begin
  Result := False;
  Detail := '';

  try
    if Length(Plan.Files) <> 1 then
      begin
        Detail := 'This first local-apply implementation supports exactly one modified file.';
        Exit;
      end;

    var Item := Plan.Files[0];
    if not SameText(Item.ChangeType, 'modify') then
      begin
        Detail := 'Only change_type=modify is supported in this first implementation.';
        Exit;
      end;

    var LocalPath := ResolveLocalPath(LocalRoot, Item.LocalRelativePath);
    if not TFile.Exists(LocalPath) then
      begin
        Detail := 'Local file not found: ' + LocalPath;
        Exit;
      end;

    var Original := TFileIOHelper.LoadFromFile(LocalPath);
    var Updated := '';
    var Error := '';
    if not ApplyUnifiedDiffToText(Original, Plan.DiffText, Updated, Error) then
      begin
        Detail := Error;
        Exit;
      end;

    if Original = Updated then
      begin
        Detail := 'The diff produced no local change for ' + Item.LocalRelativePath + '.';
        Exit(True);
      end;

    TFileIOHelper.SaveToFile(LocalPath, Updated, False);
    Detail := 'Applied local patch to ' + Item.LocalRelativePath + '.';
    Result := True;
  except
    on E: Exception do
      Detail := E.Message;
  end;
end;

class function TOpenAILocalApply.PreviewMarkdown(
  const Plan: TOpenAILocalApplyPlan): string;
begin
  var FilesText := '';
  for var Item in Plan.Files do
    begin
      if not FilesText.IsEmpty then
        FilesText := FilesText + sLineBreak;
      FilesText := FilesText + '- ' + Item.LocalRelativePath;
    end;

  var DiffPreview := Plan.DiffText.Trim;
  if DiffPreview.Length > 5000 then
    DiffPreview := DiffPreview.Substring(0, 5000) + sLineBreak +
      '... diff preview truncated ...';

  Result :=
    'The OpenAI agent processed the controlled workspace copy and returned ' +
    'a local patch proposal.' + sLineBreak + sLineBreak +
    '### Local files' + sLineBreak +
    FilesText + sLineBreak + sLineBreak +
    '### Unified diff' + sLineBreak +
    '```diff' + sLineBreak +
    DiffPreview + sLineBreak +
    '```';
end;

end.
