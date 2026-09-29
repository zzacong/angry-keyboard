import * as stylex from "@stylexjs/stylex";
import { tokens } from "@/styles/tokens.stylex";

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
  mascot: {
    // Matches the `#redface` symbol's viewBox (260x196) so the face fills the
    // box instead of being letterboxed inside it.
    aspectRatio: "260 / 196",
    height: "24px",
    width: "auto",
  },
});
