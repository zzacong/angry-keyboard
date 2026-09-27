import * as stylex from "@stylexjs/stylex";
import { tokens } from "@/styles/tokens.stylex";

export const styles = stylex.create({
  link: {
    color: { default: "inherit", ":hover": tokens.red },
    textDecorationLine: "none",
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
    fontFamily: tokens.fontMono,
    fontSize: "12px",
  },
  top: {
    gap: "1rem",
    alignItems: "center",
    display: "flex",
    justifyContent: "space-between",
    paddingTop: "1.4rem",
  },
});
