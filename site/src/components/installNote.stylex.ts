import * as stylex from "@stylexjs/stylex";
import { tokens } from "../styles/tokens.stylex";

// The install note: the one warning a visitor meets before they download,
// covering the Gatekeeper block on a signed-but-not-notarized build.
export const styles = stylex.create({
  body: {
    margin: 0,
    fontSize: "1rem",
    lineHeight: 1.6,
  },
  card: {
    borderColor: tokens.ink,
    borderRadius: "2px",
    borderStyle: "solid",
    borderWidth: "1.5px",
    paddingBlock: "1.3rem",
    paddingInline: "1.4rem",
    backgroundColor: tokens.card,
    boxShadow: "5px 7px 0 rgba(27, 23, 18, 0.22)",
    position: "relative",
    marginBottom: "1.6rem",
  },
  flow: {
    margin: 0,
    fontSize: "0.98rem",
    lineHeight: 1.6,
  },
  flowLabel: {
    color: tokens.inkSoft,
    display: "block",
    fontFamily: tokens.fontMono,
    fontSize: "11px",
    letterSpacing: "0.08em",
    textTransform: "uppercase",
    marginBottom: "0.25rem",
  },
  flows: {
    columnGap: "1.6rem",
    display: "grid",
    gridTemplateColumns: {
      default: "1fr 1fr",
      "@media (max-width: 980px)": "1fr",
    },
    rowGap: "1rem",
    marginTop: "1rem",
  },
  foot: {
    fontSize: "0.98rem",
    lineHeight: 1.6,
    marginBottom: 0,
    marginTop: "1rem",
  },
  hazard: {
    display: { default: "block", "@media (max-width: 560px)": "none" },
    filter: "drop-shadow(2px 3px 0 rgba(27, 23, 18, 0.24))",
    position: "absolute",
    transform: "rotate(12deg)",
    right: "16px",
    top: "-30px",
    width: "60px",
  },
  kicker: {
    color: tokens.blue,
    fontFamily: tokens.fontHand,
    fontSize: "1.5rem",
    lineHeight: 1.1,
    transform: "rotate(-1deg)",
    marginBottom: "0.2rem",
    marginTop: 0,
  },
  title: {
    fontFamily: tokens.fontHead,
    fontSize: "clamp(1.2rem, 2.2vw, 1.6rem)",
    fontWeight: 800,
    letterSpacing: "-0.02em",
    lineHeight: 1.05,
    marginBottom: "0.6rem",
    marginTop: 0,
  },
});
