import * as stylex from "@stylexjs/stylex";
import { tokens } from "./tokens.stylex";

export const styles = stylex.create({
  base: {
    alignItems: "center",
    borderColor: tokens.ink,
    borderRadius: tokens.radius,
    borderStyle: "solid",
    borderWidth: 2,
    cursor: "pointer",
    display: "inline-flex",
    fontFamily: tokens.fontHead,
    fontSize: "15px",
    fontWeight: 700,
    gap: "8px",
    paddingBlock: "10px",
    paddingInline: "18px",
    transitionDuration: "120ms",
    transitionProperty: "background-color, color, transform",
    transitionTimingFunction: "ease",
    ":active": { transform: "translateY(1px)" },
    ":disabled": { cursor: "not-allowed", opacity: 0.45, transform: "none" },
    ":focus-visible": {
      outlineColor: tokens.red,
      outlineOffset: "2px",
      outlineStyle: "solid",
      outlineWidth: 3,
    },
  },
  primary: {
    backgroundColor: tokens.red,
    color: tokens.paper,
    ":hover": { backgroundColor: tokens.ink },
  },
  ghost: {
    backgroundColor: "transparent",
    color: tokens.ink,
    ":hover": { backgroundColor: tokens.ink, color: tokens.paper },
  },
});
