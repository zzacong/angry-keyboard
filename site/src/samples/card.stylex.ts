import * as stylex from "@stylexjs/stylex";
import { tokens } from "./tokens.stylex";

export const styles = stylex.create({
  grid: {
    display: "grid",
    gap: tokens.gap,
    gridTemplateColumns: "1fr",
    "@media (min-width: 640px)": { gridTemplateColumns: "repeat(2, 1fr)" },
    "@media (min-width: 960px)": { gridTemplateColumns: "repeat(3, 1fr)" },
  },
  card: {
    backgroundColor: tokens.paper,
    borderColor: tokens.edge,
    borderRadius: tokens.radius,
    borderStyle: "solid",
    borderWidth: 1,
    paddingBlock: "22px",
    paddingInline: "18px",
    position: "relative",
    "::before": {
      backgroundColor: tokens.tape,
      content: '""',
      height: "18px",
      left: "-6px",
      opacity: 0.85,
      position: "absolute",
      top: "-9px",
      transform: "rotate(-4deg)",
      width: "64px",
    },
  },
  label: {
    color: tokens.inkSoft,
    fontFamily: tokens.fontMono,
    fontSize: "11px",
    letterSpacing: "0.1em",
    marginBottom: "8px",
    textTransform: "uppercase",
  },
  title: {
    color: tokens.ink,
    fontFamily: tokens.fontHead,
    fontSize: "21px",
    fontWeight: 700,
    marginBottom: "8px",
    marginTop: 0,
  },
  body: {
    color: tokens.inkSoft,
    fontFamily: tokens.fontBody,
    fontSize: "15px",
    lineHeight: 1.5,
    margin: 0,
  },
});
