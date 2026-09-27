import * as stylex from "@stylexjs/stylex";
import { tokens } from "./tokens.stylex";

// `createTheme` overrides tokens for the element it is applied to. Everything
// below keeps reading the same names, so one component renders both themes.
export const dark = stylex.createTheme(tokens, {
  paper: "#17140F",
  ink: "#EDE4CE",
  inkSoft: "#B9AE97",
  edge: "rgba(237, 228, 206, 0.24)",
});

export const styles = stylex.create({
  panel: {
    backgroundColor: tokens.paper,
    borderColor: tokens.edge,
    borderRadius: tokens.radius,
    borderStyle: "solid",
    borderWidth: 1,
    color: tokens.ink,
    paddingBlock: "18px",
    paddingInline: "20px",
  },
  heading: {
    fontFamily: tokens.fontHead,
    fontSize: "18px",
    marginBottom: "6px",
    marginTop: 0,
  },
  text: {
    color: tokens.inkSoft,
    fontFamily: tokens.fontBody,
    fontSize: "14px",
    lineHeight: 1.5,
    margin: 0,
  },
});
