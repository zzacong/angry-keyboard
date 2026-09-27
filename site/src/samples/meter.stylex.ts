import * as stylex from "@stylexjs/stylex";
import { tokens } from "./tokens.stylex";

const sweep = stylex.keyframes({
  from: { transform: "scaleX(0)" },
  to: { transform: "scaleX(1)" },
});

export const styles = stylex.create({
  label: {
    color: tokens.inkSoft,
    fontFamily: tokens.fontMono,
    fontSize: "12px",
    marginBottom: "8px",
  },
  track: {
    backgroundColor: tokens.edge,
    borderRadius: "999px",
    height: "12px",
    overflow: "hidden",
    width: "100%",
  },
  // A dynamic style. The function takes the value at render time and StyleX
  // passes it through a custom property instead of emitting a class per value.
  fill: (percent: number) => ({
    animationDuration: "900ms",
    animationFillMode: "both",
    animationName: sweep,
    animationTimingFunction: "ease-out",
    backgroundColor: tokens.red,
    height: "100%",
    transformOrigin: "left center",
    width: `${percent}%`,
  }),
});
