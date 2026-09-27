import * as stylex from "@stylexjs/stylex";
import { tokens } from "@/styles/tokens.stylex";

export const styles = stylex.create({
  actions: {
    gap: "1.2rem",
    alignItems: "center",
    display: "flex",
    flexWrap: "wrap",
    marginTop: "1.5rem",
  },
  art: {
    alignItems: "center",
    display: "flex",
    flexDirection: "column",
    justifyContent: "center",
  },
  boom: {
    transform: "rotate(-10deg)",
    left: "56%",
    top: "-24px",
    width: "136px",
  },
  bullet1: {
    transform: "rotate(14deg)",
    right: "-24px",
    top: "26%",
    width: "26px",
  },
  bullet2: {
    transform: "rotate(24deg)",
    right: "-30px",
    top: "38%",
    width: "26px",
  },
  em: {
    color: tokens.red,
    fontStyle: "normal",
  },
  hero: {
    gap: {
      default: "clamp(1.5rem, 4vw, 3rem)",
      "@media (max-width: 980px)": "1.4rem",
    },
    alignItems: "center",
    display: "grid",
    gridTemplateColumns: {
      default: "1.3fr 0.7fr",
      "@media (max-width: 980px)": "1fr",
    },
    position: "relative",
    paddingTop: "clamp(1.4rem, 4vh, 2.6rem)",
  },
  mascot: {
    aspectRatio: "300 / 440",
    height: "auto",
    width: {
      default: "min(230px, 64%)",
      "@media (max-width: 980px)": "min(200px, 52%)",
    },
  },
  note: {
    color: tokens.blue,
    fontFamily: tokens.fontHand,
    fontSize: "clamp(1.3rem, 2.6vw, 1.9rem)",
    lineHeight: 1.15,
    transform: "rotate(-1.6deg)",
    marginBottom: 0,
    marginTop: "1rem",
  },
  noteArt: {
    textAlign: "center",
    marginTop: "0.7rem",
  },
  title: {
    fontFamily: tokens.fontHead,
    fontSize: "clamp(2.3rem, 5.4vw, 4.4rem)",
    fontWeight: 800,
    letterSpacing: "-0.025em",
    lineHeight: 0.97,
    marginBottom: 0,
    marginTop: 0,
    maxWidth: "12em",
  },
});
