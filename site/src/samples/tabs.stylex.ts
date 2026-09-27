import * as stylex from "@stylexjs/stylex";
import { tokens } from "./tokens.stylex";

export const styles = stylex.create({
  root: {
    display: "flex",
    flexWrap: "wrap",
    gap: "8px",
  },
  tab: {
    backgroundColor: "transparent",
    borderColor: tokens.edge,
    borderRadius: "999px",
    borderStyle: "solid",
    borderWidth: 1,
    color: tokens.inkSoft,
    cursor: "pointer",
    fontFamily: tokens.fontMono,
    fontSize: "13px",
    paddingBlock: "7px",
    paddingInline: "14px",
    ":hover": { borderColor: tokens.ink, color: tokens.ink },
  },
  selected: {
    backgroundColor: tokens.ink,
    borderColor: tokens.ink,
    color: tokens.paper,
    ":hover": { color: tokens.paper },
  },
  panel: {
    backgroundColor: tokens.paper,
    borderColor: tokens.edge,
    borderRadius: tokens.radius,
    borderStyle: "solid",
    borderWidth: 1,
    fontFamily: tokens.fontBody,
    fontSize: "15px",
    lineHeight: 1.5,
    marginTop: "14px",
    paddingBlock: "16px",
    paddingInline: "18px",
  },
});
