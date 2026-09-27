import * as stylex from "@stylexjs/stylex";
import { tokens } from "@/styles/tokens.stylex";

// A card being slapped down. The timing function overshoots slightly so the
// paper settles rather than easing flat. `global.css` already switches every
// animation off under `prefers-reduced-motion: reduce`, so no rule here repeats
// that media query.
const settle = stylex.keyframes({
  from: { opacity: 0, transform: "rotate(-4.2deg) scale(1.035)" },
  to: { opacity: 1, transform: "rotate(-1.2deg) scale(1)" },
});

// The thank-you dialog opened by `DownloadThanks.astro`. The card is plain
// paper on purpose: the numbered cards in the section behind it are solid
// yellow, blue and pink, so an uncoloured card does not read as "step 4".
//
// Nothing here fights the page decor for stacking order. The dialog is a native
// <dialog>, which lives in the browser's top layer when opened.
export const styles = stylex.create({
  // The dimmed sheet behind the card. It sits on its own class so the `dialog`
  // rule stays free of pseudo-element keys. Dimmed paper, not a black curtain —
  // the section behind stays legible through it.
  backdrop: {
    "::backdrop": {
      backdropFilter: "blur(1.5px)",
      backgroundColor: "rgba(43, 35, 26, 0.34)",
    },
  },
  body: {
    margin: 0,
    fontFamily: tokens.fontSerif,
    fontSize: "1rem",
    lineHeight: 1.6,
    maxWidth: "46ch",
  },
  card: {
    borderColor: tokens.ink,
    borderRadius: "2px",
    borderStyle: "solid",
    borderWidth: "1.5px",
    paddingBlock: "1.7rem",
    paddingInline: "1.5rem",
    animationDuration: "150ms",
    animationFillMode: "both",
    animationName: settle,
    animationTimingFunction: "cubic-bezier(0.2, 0.85, 0.3, 1.1)",
    backgroundColor: tokens.card,
    boxShadow: "5px 7px 0 rgba(27, 23, 18, 0.22)",
    // The site sets no global border-box, so `width` below would otherwise be
    // the content width and the padding would push the card past the viewport
    // on a phone.
    boxSizing: "border-box",
    color: tokens.ink,
    position: "relative",
    transform: "rotate(-1.2deg)",
    width: "min(520px, 92vw)",
  },
  close: {
    borderColor: tokens.ink,
    borderRadius: "2px",
    borderStyle: "solid",
    borderWidth: "1.5px",
    placeItems: "center",
    backgroundColor: { default: tokens.card, ":hover": tokens.ink },
    // Keeps the touch target at a true 34px, matching the card above.
    boxSizing: "border-box",
    color: { default: tokens.ink, ":hover": tokens.card },
    cursor: "pointer",
    display: "grid",
    fontFamily: tokens.fontHead,
    fontSize: "19px",
    fontWeight: 800,
    lineHeight: 1,
    position: "absolute",
    transitionDuration: "120ms",
    transitionProperty: "background-color, color",
    transitionTimingFunction: "ease",
    zIndex: 3,
    height: "34px",
    right: "0.5rem",
    top: "0.5rem",
    width: "34px",
  },
  // Resets the user-agent dialog box down to a bare centred container. The card
  // inside supplies the paper.
  dialog: {
    inset: 0,
    margin: "auto",
    padding: 0,
    borderWidth: 0,
    overflow: "visible",
    backgroundColor: "transparent",
    color: tokens.ink,
    position: "fixed",
    height: "fit-content",
    maxHeight: "none",
    maxWidth: "none",
    width: "fit-content",
  },
  kicker: {
    color: tokens.red,
    fontFamily: tokens.fontMono,
    fontSize: "11px",
    fontWeight: 600,
    letterSpacing: "0.14em",
    textTransform: "uppercase",
    marginBottom: "0.35rem",
    marginTop: 0,
  },
  retry: {
    color: tokens.blue,
    fontFamily: tokens.fontHand,
    fontSize: "1.5rem",
    lineHeight: 1.15,
    transform: "rotate(-0.6deg)",
    marginBottom: 0,
    marginTop: "0.55rem",
  },
  retryLink: {
    color: tokens.red,
    fontWeight: 600,
    textDecorationLine: "underline",
    textUnderlineOffset: "2px",
  },
  // Taped at the corners, overhanging the card, rather than the inset
  // `shared.tapeLeft`/`shared.tapeRight` that hold the demo card down. The
  // material is still shared; only the placement differs.
  tapeLeft: {
    transform: "rotate(-8deg)",
    left: { default: "-16px", "@media (max-width: 480px)": "-6px" },
    top: "-14px",
  },
  tapeRight: {
    transform: "rotate(7deg)",
    right: { default: "-16px", "@media (max-width: 480px)": "-6px" },
    top: "-14px",
  },
  title: {
    fontFamily: tokens.fontHead,
    fontSize: "clamp(1.45rem, 2.4vw, 1.95rem)",
    fontWeight: 800,
    letterSpacing: "-0.02em",
    lineHeight: 1.03,
    marginBottom: "0.6rem",
    marginTop: 0,
  },
});
