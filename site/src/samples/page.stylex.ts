import * as stylex from "@stylexjs/stylex";
import { tokens } from "./tokens.stylex";

export const styles = stylex.create({
  page: {
    backgroundColor: tokens.paper,
    color: tokens.ink,
    fontFamily: tokens.fontBody,
    minHeight: "100vh",
    paddingBlock: "56px",
    paddingInline: "24px",
  },
  wrap: {
    marginInline: "auto",
    maxWidth: "920px",
  },
  kicker: {
    color: tokens.red,
    fontFamily: tokens.fontMono,
    fontSize: "12px",
    letterSpacing: "0.12em",
    textTransform: "uppercase",
  },
  title: {
    fontFamily: tokens.fontHead,
    fontSize: "42px",
    lineHeight: 1.1,
    marginBottom: "12px",
    marginTop: "10px",
  },
  lede: {
    color: tokens.inkSoft,
    fontSize: "17px",
    lineHeight: 1.55,
    marginBottom: 0,
    marginTop: 0,
    maxWidth: "62ch",
  },
  section: {
    borderTopColor: tokens.edge,
    borderTopStyle: "solid",
    borderTopWidth: 1,
    marginTop: "44px",
    paddingTop: "28px",
  },
  sectionTitle: {
    fontFamily: tokens.fontHead,
    fontSize: "22px",
    marginBottom: "4px",
    marginTop: 0,
  },
  note: {
    color: tokens.inkSoft,
    fontFamily: tokens.fontMono,
    fontSize: "13px",
    lineHeight: 1.5,
    marginBottom: "18px",
    marginTop: 0,
  },
  row: {
    alignItems: "center",
    display: "flex",
    flexWrap: "wrap",
    gap: "12px",
  },
  columns: {
    display: "grid",
    gap: tokens.gap,
    gridTemplateColumns: "1fr",
    "@media (min-width: 640px)": { gridTemplateColumns: "repeat(2, 1fr)" },
  },
  meters: {
    display: "grid",
    gap: "18px",
  },
});
