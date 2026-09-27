import * as stylex from "@stylexjs/stylex";
import { tokens } from "../styles/tokens.stylex";

export const styles = stylex.create({
  foot: {
    alignItems: "center",
    color: tokens.inkSoft,
    columnGap: "1.6rem",
    display: "flex",
    flexWrap: "wrap",
    fontFamily: tokens.fontMono,
    fontSize: "11.5px",
    rowGap: "0.7rem",
    borderTopColor: "rgba(27, 23, 18, 0.3)",
    borderTopStyle: "solid",
    borderTopWidth: "1.5px",
    marginTop: "3.4rem",
    paddingTop: "1.4rem",
  },
  mascot: {
    aspectRatio: "300 / 440",
    height: "44px",
    width: "auto",
  },
});
