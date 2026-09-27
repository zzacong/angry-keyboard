// Wires the download buttons to the thank-you dialog. The dialog is a native
// <dialog>, so opening it traps focus and inerts the page on its own; this
// module only decides when it opens and where focus goes afterwards.
//
// The click is never intercepted. The browser starts the DMG download as usual
// and the dialog opens alongside it, so a blocked download still leaves the
// retry link in the card to fall back on.

const TRIGGER = "[data-download]";
const DIALOG = "[data-thanks]";
const CLOSE = "[data-thanks-close]";

/** Mount the thank-you dialog. One per page; any download trigger opens it. */
export function mountDownloadThanks(): void {
  const dialog = document.querySelector<HTMLDialogElement>(DIALOG);
  if (!dialog) return;

  // The trigger is remembered so focus can go back to it. Native <dialog> would
  // restore focus too, but not if the click never focused the link.
  let trigger: HTMLElement | null = null;

  const open = (from: HTMLElement): void => {
    // A second click cannot reach the page through an open modal, so this only
    // guards against a programmatic reopen replaying the entrance animation.
    if (dialog.open) return;
    trigger = from;
    dialog.showModal();
  };

  document.querySelectorAll<HTMLElement>(TRIGGER).forEach((element) => {
    element.addEventListener("click", () => open(element));
  });

  dialog.querySelectorAll<HTMLElement>(CLOSE).forEach((element) => {
    element.addEventListener("click", () => dialog.close());
  });

  // Clicks on the backdrop report the dialog itself as the target, because
  // ::backdrop is the dialog's own pseudo-element. Clicks on the card do not.
  dialog.addEventListener("click", (event) => {
    if (event.target === dialog) dialog.close();
  });

  dialog.addEventListener("close", () => trigger?.focus());
}
