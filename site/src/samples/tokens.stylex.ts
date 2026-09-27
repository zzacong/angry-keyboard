import * as stylex from "@stylexjs/stylex";

// Design tokens compile to CSS custom properties, so components read them by
// name and a theme can swap the values on any subtree.
export const tokens = stylex.defineVars({
  paper: "#EDE8DC",
  ink: "#1B1712",
  inkSoft: "#4A4237",
  red: "#C8281C",
  tape: "#C8A268",
  edge: "rgba(27, 23, 18, 0.18)",
  radius: "10px",
  gap: "16px",
  fontHead: '"Bricolage Grotesque", system-ui, sans-serif',
  fontBody: '"IBM Plex Sans", system-ui, sans-serif',
  fontMono: '"IBM Plex Mono", ui-monospace, monospace',
});
