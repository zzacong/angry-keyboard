import * as stylex from "@stylexjs/stylex";
import { tokens } from "@/styles/tokens.stylex";

export const styles = stylex.create({
  link: {
    gap: "0.4em",
    alignItems: "center",
    color: { default: "inherit", ":hover": tokens.red },
    display: "inline-flex",
    textDecorationLine: "none",
  },
  mark: {
    display: "block",
    height: "14px",
    width: "14px",
  },
  name: {
    fontFamily: tokens.fontHead,
    fontSize: "20px",
    fontWeight: 800,
    letterSpacing: "-0.015em",
  },
  nav: {
    gap: "1.2rem",
    color: tokens.inkSoft,
    display: "flex",
    flexWrap: "wrap",
    fontFamily: tokens.fontMono,
    fontSize: "12px",
    justifyContent: "flex-end",
    rowGap: "0.5rem",
  },
  top: {
    gap: "1rem",
    alignItems: "center",
    display: "flex",
    justifyContent: "space-between",
    paddingTop: "1.4rem",
  },
});
