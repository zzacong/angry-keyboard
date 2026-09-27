## Running things

Run from the repository root. `just site-dev`, `just site-build`,
`just site-preview`, `just site-check`, and `just site-fmt` cover the common
cases, and every script in `site/package.json` is reachable as
`pnpm --dir site run <script>`. Those scripts are the source of truth.

Start the dev server in the background, because a foreground server blocks the
session: `pnpm --dir site run dev:bg`, then `dev:stop` or `dev:logs`.

## Styling

StyleX runs through the Vite plugin in `astro.config.mjs`. Its Babel pass skips
`.astro` files, so styles live in `*.stylex.ts` modules next to the components
that use them. Define them with `stylex.create()` and apply them with
`stylex.attrs()` spread onto the element:

```astro
<button {...stylex.attrs(styles.base, active && styles.active)} />
```

`attrs` returns `class` and a serialized `style`. `stylex.props()` returns
`className` and a style object, and is only for React.

Two things fail silently if you disturb them:

- `src/styles/global.css` must stay imported from `src/layouts/Layout.astro`.
  The plugin appends the extracted rules to that CSS asset and drops them
  without an error when no asset exists.
- `src/components/StylexDev.astro` hand-links the dev stylesheet and the HMR
  runtime, because Astro does not run Vite's HTML transform in dev. It renders
  nothing in a production build.

StyleX emits into `@layer` blocks. Plain CSS and Astro `<style>` blocks are
unlayered, and unlayered rules win over layered rules regardless of specificity.
