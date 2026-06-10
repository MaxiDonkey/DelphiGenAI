unit WVPythia.Adapter;

interface

uses
  WVPythia.Types, WVPythia.Chat.ManagedFlow;

type
  TChatManagedItemRef = record
  private
    FId: string;
    FName: string;
  public
    class function Create(const AId, AName: string): TChatManagedItemRef; static;

    property Id: string read FId;
    property Name: string read FName;
  end;

  IChatManagedItemDialogService = interface
    ['{D6471685-67A1-42E6-8BA8-B517AA02A313}']

    function SelectItem(
      const AKind: TAdapterManagedItemKind;
      out AItem: TChatManagedItemRef): Boolean;

    function ActivateManagedItemEvent(
      const AKind: TAdapterManagedItemKind): Boolean; overload;

    function ActivateManagedItemEvent(
      const AState: TInputPromptState;
      const AOnFinalize: TManagedItemFinalizeProc): Boolean; overload;

    function ActivateCopyItemEvent(
      const APairId, AKind, AContent: string): Boolean;

    function ActivateCodeCopyItemEvent(
      const ALang, AText: string): Boolean;

    function ActivateNewChatEvent: Boolean;

    function ActivateCustomEvent(const ARawJson: string): Boolean;
  end;

implementation

{$REGION 'Dev notes'}

(*
    Developer Note

    This unit defines the shared adapter contract between the browser chat event
    layer and the concrete application service layer.

    Purpose
    -------
    Browser.Adapter exposes framework-neutral types used to delegate UI-driven
    browser actions without depending on VCL, FMX, or any concrete presentation
    framework.

    Main responsibilities:
    • Define the lightweight managed item reference returned by selection dialogs.
    • Declare the IChatManagedItemDialogService service boundary.
    • Keep the browser event layer decoupled from application-specific UI logic.
    • Provide a common contract shared by VCL, FMX, and other host layers.

    Managed item reference:
    • TChatManagedItemRef carries only the selected item identity:
      * Id
      * Name
    • It intentionally does not expose provider-specific metadata or UI state.
    • Additional data must be resolved by the concrete application layer when
      needed.

    Service contract:
    • SelectItem asks the host application to select an item of a given
      TAdapterManagedItemKind.
    • ActivateManagedItemEvent(AKind) delegates simple UI actions.
    • ActivateManagedItemEvent(AState, AOnFinalize) delegates prompt submission
      flow and returns completion through the finalize callback.
    • ActivateCopyItemEvent and ActivateCodeCopyItemEvent delegate copy actions.
    • ActivateNewChatEvent delegates creation of a new chat/session.
    • ActivateCustomEvent forwards custom-event JSON emitted by user JavaScript.

    Custom events:
    • ARawJson is passed as JSON text because the framework does not know the
      user-defined payload schema.
    • Implementations are responsible for parsing, validating, and dispatching
      the custom event according to their own rules.

    Design boundaries:
    • This unit contains no browser dispatch logic.
    • This unit contains no concrete dialog implementation.
    • This unit contains no VCL/FMX-specific code.
    • This unit does not parse or validate JSON payloads.
    • It only defines the stable adapter surface consumed by the event layer.

    Implementation rule:
    • Concrete services implement this interface in the application/UI layer.
    • Keep this contract small and stable.
    • Add methods here only when the browser layer needs a new application-level
      capability.

*)

{$ENDREGION}

{ TChatManagedItemRef }

class function TChatManagedItemRef.Create(
  const AId, AName: string): TChatManagedItemRef;
begin
  Result.FId := AId;
  Result.FName := AName;
end;

end.
