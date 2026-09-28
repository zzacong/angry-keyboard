# AngryKeyboard marketing site

The AngryKeyboard public homepage: one Astro page, styled with StyleX, ported
from the zine prototype in `.scratch/marketing-site/`. It tells the story, runs
a live deck on the app's own sounds, lists the key bindings, and hands over the
download.

Hosted on Vercel with the project's Root Directory set to `site`.

## Commands

Run commands from the repository root with `just`: `just site-dev`,
`just site-build`, `just site-preview`, `just site-check`, `just site-fmt`.
Every script in `site/package.json` is also reachable as
`pnpm --dir site run <script>`, and those scripts are the source of truth.

## Layout

- `src/pages/index.astro` composes the sections.
- `src/components/*.astro` are the sections, each with a sibling `*.stylex.ts`
  style module.
- `src/lib/deck.ts` is the live deck: the keystroke resolver and the Web Audio
  board that mirrors the app.
- `src/assets/sprite.svg` holds the mascot and sticker symbols, inlined once by
  `Layout.astro` and referenced with `<use>`.
- `src/styles/tokens.stylex.ts` is the zine palette and type scale.

The twelve sounds are imported straight from `AngryKeyboard/Sounds/`, so the
site and the app share one source of truth. Fonts are self-hosted with
Fontsource.

In-project imports use the `@/` alias for `src/`, declared in `tsconfig.json`
and picked up by Astro's Vite config. It is mirrored into `astro.config.mjs` for
StyleX, whose Babel pass has its own resolver. The sound imports stay relative:
they reach outside this project.

## Styling

Styles live in `*.stylex.ts` modules next to the components that use them. See
`AGENTS.md` for the StyleX conventions and the two things that fail silently.
