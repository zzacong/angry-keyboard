# Download modal (prototype)

Throwaway prototype, not production. It answers one question: what should the
"thanks for downloading" modal card look like when a visitor clicks the real
download button on the AngryKeyboard site?

Four card variants live in one self-contained file, switchable with the
`?variant=` URL param and the floating bar at the bottom of the page. Variant
`a` (the recommended direction) opens by default, with no param needed.

## Run it

Double-click `index.html`. That is the whole thing. It opens straight from disk
with no build step and no server. Fonts load from the Google Fonts CDN; offline,
they fall back to system faces.

## The variants

| Param | Name | Shape |
| --- | --- | --- |
| `?variant=a` | Taped note | A rotated paper card with tape at the corners, a small red kicker, and the retry line in Caveat. Number-free, so it reads as a note, not "step 4". **Recommended.** |
| `?variant=b` | Receipt | An order slip in IBM Plex Mono: dashed torn edges, a perforated line, a line-item body, and `TOTAL $0.00`. |
| `?variant=c` | Dispatch | A form-like slip carrying a big angled AIR MAIL stamp and a mailed missile sticker, as if it arrived by post. |
| `?variant=d` | Install note | The visual language of the real `InstallNote.astro` card: hazard sticker, mono kicker, Bricolage Grotesque title, serif body. |

The left and right arrow keys cycle variants too. Switching variants closes and
reopens the modal so the entrance motion replays on the new card.

## The modal

It is a native `<dialog>` opened with `showModal()`, so it lives in the browser's
top layer and needs no z-index tuning. Esc, the close button, and a click on the
backdrop all dismiss it, and closing returns focus to the "Download for macOS"
button. The card settles in over ~150ms; `prefers-reduced-motion: reduce`
disables that. The `::backdrop` is dimmed paper, not a hard black curtain.

Rendered behind the modal is a faithful copy of the site's "How to get it"
section — halftone paper, the numbered note cards, the red download button, and
the free/missile stickers — so the card can be judged against the page it lands
on. That context is not part of the prototype's answer.

## Screenshots

Not kept. The verification captures (each variant at 1400x900, plus two at 375px)
were throwaway review artifacts; re-render them from `index.html` if you want
them again.

## Cleanup

This directory is throwaway. When one direction wins, fold it into the real
`GetIt.astro` / a new Astro component and delete the rest. The floating switcher
bar and its script carry comments marking them as prototype-only.
