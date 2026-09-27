# Download thank-you dialog

## Problem

Clicking "Download for macOS" fires a DMG download and gives nothing back. The
visitor is left guessing whether anything happened, and the one thing they need
at that moment — the Gatekeeper block they are about to hit — sits in a note
above the button that is easy to scroll past.

## What we are building

A small modal that opens when the DMG download starts. It thanks the visitor and
restates the two hurdles between the download and a working app.

## Decisions

| Decision | Choice |
| --- | --- |
| Trigger | Only the real DMG link in `GetIt.astro`. The hero button stays an in-page anchor to `#f-get`. |
| Container | One native `<dialog>` opened with `showModal()`, mounted at page level in `Layout.astro`. |
| Content | Thanks plus the two install hurdles. Acknowledgement only — no form, no rating, no star prompt. |
| Look | Variant (a) from the prototype: a taped note card, red mono kicker, Caveat on the retry line. |
| Motion | A ~150ms settle-in, disabled by the global `prefers-reduced-motion` rule already in `global.css`. |
| Dismissal | Esc, a close button, and a backdrop click. Focus returns to the button that started the download. |
| Repeat | Every click, guarded so it cannot open while already open. No persistence. |
| Copy | Option B, verbatim (below). |

### Copy

> thanks for downloading
> **Now the annoying part.**
> macOS will say it can't verify the app. That's expected — it's signed, just not
> notarized. Open it anyway, then say yes to Input Monitoring so it can hear your
> keys.
> Didn't start? Download it again

## Why it does not earn an ADR

Reversible, unsurprising, and not a close call between genuine alternatives. The
zine direction it inherits is already recorded in `docs/adr/0010-zine-homepage.md`.

## Notes

- The download is not intercepted. The browser starts the DMG as usual and the
  dialog opens alongside it, so a refused or blocked download still gets the
  retry link inside the card.
- Cross-origin means we cannot confirm the download started. The retry link is
  the hedge.
- Middle-click and "save link as" fire `auxclick`/context menu, not `click`, so
  those visitors do not see the dialog. Accepted.
- `downloadUrl` moves to `site/src/lib/download.ts` so the button and the retry
  link cannot point at different releases.

## Out of scope

Analytics, a feedback form, changes to `InstallNote.astro`, and any second
download affordance on the page.

## Prototype

`index.html` and `README.md` in this directory are the throwaway prototype that
picked the card. Four variants, switchable with `?variant=a|b|c|d`. Variant (a)
won. Screenshots are in `shots/`.

## Verification

No test harness exists for the site, so this is checked by `pnpm --dir site run
check`, a production build, and a real-browser pass: the dialog opens on the DMG
link, Esc and the backdrop dismiss it, focus returns to the button, the hero
button still only scrolls, a middle-click or "save link as" download gets no
dialog, and the card fits at 375px and 1400x900 with no internal scrolling.
