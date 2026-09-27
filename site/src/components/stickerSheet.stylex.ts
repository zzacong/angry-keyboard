import * as stylex from "@stylexjs/stylex";
import { tokens } from "../styles/tokens.stylex";

export const styles = stylex.create({
  note: {
    color: tokens.blue,
    fontFamily: tokens.fontHand,
    fontSize: "1.5rem",
    transform: "rotate(-1deg)",
    marginBottom: "1rem",
    marginTop: 0,
  },
  row: {
    alignItems: "center",
    columnGap: "1.6rem",
    display: "flex",
    flexWrap: "wrap",
    rowGap: "1.2rem",
  },
  sheet: {
    borderTopColor: "rgba(27, 23, 18, 0.3)",
    borderTopStyle: "solid",
    borderTopWidth: "1.5px",
    marginTop: "3.2rem",
    paddingTop: "1.3rem",
  },
  sticker: {
    filter: "drop-shadow(1px 2px 0 rgba(27, 23, 18, 0.2))",
    height: "auto",
    width: "clamp(46px, 6.5vw, 80px)",
  },
  stickerRot: (rot: number) => ({ transform: `rotate(${rot}deg)` }),
});
