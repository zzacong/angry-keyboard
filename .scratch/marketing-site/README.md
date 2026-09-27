# AngryKeyboard marketing site (prototype)

Throwaway prototype, not production. It answers one question: what should the
AngryKeyboard homepage look like, and how should the "type and hear it" demo be
presented?

The decision is recorded in `docs/adr/0010-zine-homepage.md`. The brief for
building it is `spec.md`, next to this file.

Six homepage variants live in one self-contained file, switchable with the
`?variant=` URL param and the floating bar at the bottom of the page. F is the
pinned direction and opens by default, with no param needed.

## Hard rule for every variant

The deck and a download button are both in the first viewport. Nobody should have
to scroll to reach the demo or the download. Variants are rendered at 1400x900
when judging this.

## Run it

Double-click `index.html`. That is the whole thing. It is one file with the nine
app sounds inlined as data URIs, so it works straight from disk with no server.

To rebuild after editing `_src/template.html` or swapping a sound:

    bun .scratch/marketing-site/_src/build.mjs

Then open `index.html`.

## The variants

| Param | Name | Shape |
| --- | --- | --- |
| `?variant=A` | Live Fire | The demo is the hero. Headline and download on the left, the deck on the right. Brand palette. |
| `?variant=C` | Field Manual | Dense placard. Everything sits in bordered panels in a dry spec-sheet voice. Brand palette. |
| `?variant=F` | Zine | Newsprint and kraft. Light theme, serif body, red accents, halftone dots, a taped demo card, war stickers, and notes in Caveat. **Pinned.** |
| `?variant=G` | Blueprint | An annotated schematic. The app drawn as a signal chain, keys into resolver into a live audio engine into output, on blueprint grid paper. |
| `?variant=H` | Control panel | A warm grey hardware console with an input channel holding the deck, a segmented output meter that moves on each shot, power and mute lamps, and a key-select legend. |
| `?variant=I` | Poster | A Swiss graphic poster. Huge Archivo type, a red download block, and the deck in a black band across the lower viewport. |

The left and right arrow keys cycle variants too, unless a text field has focus.

## Retired variants

B (The Rant), D (Range Day) and E (Arcade) were cut for pushing the deck below the
fold or for reading as costume. They are recoverable from commit `7f452c6`.

## Design notes

A and C use the shipped app icon's palette: blackout `#17140F`, signal red
`#CE2B1E`, bone `#EDE4CE`, with `#2C2419` for lifted keycaps. Type there is Big
Shoulders Display with Big Shoulders Stencil for the wordmark, IBM Plex Sans for
body, and IBM Plex Mono for keycap glyphs.

F goes light and handmade: newsprint `#EDE8DC`, ink, red `#C8281C`, Bricolage
Grotesque for headlines, Newsreader for body, and Caveat for the written-by-hand
notes.

G goes technical: blueprint blue `#0E2A57`, cyan `#6FD3FF` for the live accents,
and Space Grotesk for headings. H goes industrial: warm grey `#D9D5CB`, red
`#C8281C`, amber `#DE9526`, and Saira Condensed for panel legends. I goes graphic:
near-white `#F2F2EE`, near-black `#111110`, red `#E0301E`, and Archivo at weight 900.

Every variant draws the mascot from the same SVG geometry in
`.scratch/branding/source/app-icon-blackout.svg`.

## F decorations

F carries a war sticker set, drawn as flat SVG in the same palette as the mascot
rather than pulled from clip art, so the whole set reads as one sheet. The
symbols live in the sprite at the top of `_src/template.html`: `s-boom`, `s-pow`,
`s-bomb`, `s-grenade`, `s-missile`, `s-bullet`, `s-crate`, `s-hazard`, `s-free`
and `s-fist`.

Composite shapes are drawn twice. A cream layer paints the die-cut halo, then the
colored layer sits on top, so the outline stays a single clean edge the way a real
sticker does.

Stickers are placed two ways. A handful are stuck around the page at the edges of
the hero, the demo card, the sounds list and the download block, and the rest sit
in a labelled sticker sheet near the footer.

Three rules kept them from wrecking the page: decor never covers text (it holds a
lower z-index than content, so anything overlapping shows the sticker tucked
behind), decor is `pointer-events: none`, and the scattered stickers are hidden
below 980px, leaving only the sticker sheet.

There is no entrance animation on the stickers. A staggered settle was the first
attempt and it read as a scattered effect rather than one gesture.

## The demo

Every variant mounts the same sound board, and it follows the app:

- one voice per sound, retriggered on repeat, so fast typing sounds like fire
- arrow keys stack up to three overlapping impacts
- a small random pitch and gain on each hit
- a compressor on the mix, standing in for the app's peak limiter

The key mapping matches the app. Enter is the explosion, Esc the rocket whoosh,
Backspace the shotgun blast, Space the shotgun cock, the arrow keys fire one of
four impacts, and every other key fires the shotgun.

The board dispatches an `ak:fire` event on every shot. H's output meter listens for
it, so the meter and the audio stay in step instead of being two separate guesses.

## What is stubbed

- Every "Download for macOS" button points at `#`. There is no release artifact yet.
- Fonts load from the Google Fonts CDN. Offline, they fall back to system faces.
- Nothing talks to a backend, and the demo keeps no state beyond the tab.

## Cleanup

This directory is throwaway. When one direction wins, fold it into the real site
and move the losing variants aside. The variant switcher and its bottom bar both
carry comments marking them as prototype-only.
