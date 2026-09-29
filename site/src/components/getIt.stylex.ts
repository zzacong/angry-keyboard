import * as stylex from "@stylexjs/stylex";
import { tokens } from "@/styles/tokens.stylex";

export const styles = stylex.create({
  cardBlue: {
    backgroundColor: tokens.noteBlue,
    transform: "rotate(1deg)",
  },
  cardPink: {
    backgroundColor: tokens.notePink,
    transform: "rotate(-0.5deg)",
  },
  cardYellow: {
    backgroundColor: tokens.noteYellow,
    transform: "rotate(-1.3deg)",
  },
  cta: {
    gap: "1.2rem",
    alignItems: "center",
    display: "flex",
    flexWrap: "wrap",
    marginTop: "2.6rem",
  },
  free: {
    transform: "rotate(9deg)",
    left: "300px",
    top: "-55px",
    width: "98px",
  },
  meta: {
    color: tokens.inkSoft,
    fontFamily: tokens.fontMono,
    fontSize: "12px",
  },
  metaLink: {
    color: { default: tokens.ink, ":hover": tokens.red },
    textDecorationColor: "rgba(27, 23, 18, 0.4)",
    textDecorationLine: "underline",
    textUnderlineOffset: "3px",
  },
  missile: {
    transform: "rotate(-13deg)",
    bottom: "-6px",
    right: "70px",
    width: "170px",
  },
  noteCard: {
    paddingInline: "1.2rem",
    boxShadow: "3px 4px 0 rgba(27, 23, 18, 0.18)",
    fontFamily: tokens.fontHand,
    fontSize: "1.32rem",
    lineHeight: 1.25,
    paddingBlockEnd: "1.4rem",
    paddingBlockStart: "1.2rem",
  },
  noteTitle: {
    display: "block",
    fontFamily: tokens.fontHead,
    fontSize: "1.6rem",
    fontWeight: 800,
    marginBottom: "0.2rem",
  },
  notes: {
    gap: "1.6rem",
    display: "grid",
    gridTemplateColumns: {
      default: "repeat(3, 1fr)",
      "@media (max-width: 980px)": "1fr",
    },
  },
  section: {
    position: "relative",
    marginTop: "3.6rem",
  },
  title: {
    fontFamily: tokens.fontHead,
    fontSize: "clamp(1.5rem, 3.2vw, 2.3rem)",
    fontWeight: 800,
    letterSpacing: "-0.02em",
    lineHeight: 1.02,
    marginBottom: "1.4rem",
    marginTop: 0,
  },
});
