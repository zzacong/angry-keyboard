# AngryKeyboard marketing site

The AngryKeyboard public homepage. It is an Astro site that compiles styles with
StyleX. The homepage is not built yet, and will be built later from the brief in
`.scratch/marketing-site/spec.md`.

## Commands

Run commands from the repository root with `just`: `just site-dev`,
`just site-build`, `just site-preview`, `just site-check`, `just site-fmt`.
Every script in `site/package.json` is also reachable as
`pnpm --dir site run <script>`, and those scripts are the source of truth.

## Styling

Styles live in `*.stylex.ts` modules next to the components that use them.
