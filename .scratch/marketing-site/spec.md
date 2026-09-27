# AngryKeyboard marketing site

**Status:** resolved

## Goal

Build the public homepage in Astro with StyleX, porting the chosen direction from
the prototype. One page: what the app is, why it exists, hear it, install it.

## Chosen direction

Variant F, the zine. The other five directions were rejected in the prototype:

- Live Fire and Field Manual read as competent and a little generic; they wore the
  app icon's palette without adding a voice.
- Blueprint was content-rich, but a technical drawing fits a specification more
  than a homepage.
- Control Panel was the most crafted and is the strongest runner-up.
- Poster was the most restrained and the most likely to read as a product rather
  than a joke.

The tone stays handmade rather than themed. The zine carries its theme through
structure — newsprint, halftone dots, taped cards, handwriting, and a war sticker
set drawn as flat SVG in the app's own palette — where the failures wore a
costume.

The prototype is the primary source, not code to lift:

- `.scratch/marketing-site/index.html`, the self-contained prototype
- `.scratch/marketing-site/_src/template.html`, the editable source
- `.scratch/marketing-site/_src/build.mjs`, which inlines the sounds
- `.scratch/marketing-site/README.md`, the variant map and design notes

## Constraints

- One page. No pricing page, no feature grid, no blog.
- The deck and a download button are both in the first viewport at 1400x900.
- The deck matches the app: the same resolver, one voice per sound retriggered on
  repeat, three voices on arrow impacts, random pitch and gain per hit.

## Content, top to bottom

1. Wordmark and a short nav.
2. First-person pitch, with the download button and a "hobby project" sticker.
3. The deck, presented as a taped-in card.
4. The six key bindings.
5. How to get it: the install note, three steps, then the download call to action.
6. The sticker sheet and a footer.

## Assets

- Sounds: `AngryKeyboard/Sounds/`, nine MP3s, already in the repo.
- Mascot: the keycap geometry from
  `.scratch/branding/source/app-icon-blackout.svg`.
- Stickers: the inline SVG sprite at the top of `_src/template.html`.
- Type: Bricolage Grotesque, Newsreader, Caveat, and IBM Plex Sans and Mono.

## Open items

The page is built in `site/`. The download buttons point at the latest GitHub
Release, so the link and its artifact are resolved.

- A notarized or Developer ID build to download. See ADR 0007 and ADR 0009.
- An FAQ for the Input Monitoring request. Step 3's "it only listens" line stands
  in for now.
- An illustrated sticker set to replace the prototype's vector shapes.
- Sticker and deck animation: smoke, fire, and sparks reacting to the live deck.
  Deferred to its own pass after this port.

## Out of scope

Analytics, a CMS, i18n, and a second page.
