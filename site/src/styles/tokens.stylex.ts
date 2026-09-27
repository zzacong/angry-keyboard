import * as stylex from "@stylexjs/stylex";

// The zine palette and typefaces. Tokens compile to CSS custom properties, so
// the page reads them by name and any subtree could be re-themed without
// touching a component.
export const tokens = stylex.defineVars({
  blue: "#2B4E8C",
  card: "#FFFDF7",
  cardBar: "#F4EEE0",
  edge: "rgba(27, 23, 18, 0.18)",
  edgeStrong: "rgba(27, 23, 18, 0.4)",
  fontHand: '"Caveat Variable", "Bradley Hand", cursive',
  fontHead: '"Bricolage Grotesque Variable", system-ui, sans-serif',
  fontMono: '"IBM Plex Mono", ui-monospace, SFMono-Regular, Menlo, monospace',
  fontSans: '"IBM Plex Sans", system-ui, -apple-system, sans-serif',
  fontSerif: '"Newsreader Variable", Georgia, "Times New Roman", serif',
  ink: "#1B1712",
  inkSoft: "#6B6252",
  inkSoftest: "#9A9080",
  noteBlue: "#CFE3F5",
  notePink: "#F6CFC7",
  noteYellow: "#F7E9A0",
  paper: "#EDE8DC",
  red: "#C8281C",
  redDeep: "#A81F16",
  tape: "#C8A268",
});
