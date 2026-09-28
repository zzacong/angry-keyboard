export const KEY_BINDINGS = [
  {
    group: "space",
    guideKey: "spacebar",
    soundKey: "Spacebar",
    sound: "shotgun cock",
  },
  {
    group: "enter",
    guideKey: "enter",
    soundKey: "Enter",
    sound: "explosion",
  },
  {
    group: "backspace",
    guideKey: "backspace",
    soundKey: "Backspace",
    sound: "shotgun blast",
  },
  {
    group: "escape",
    guideKey: "escape",
    soundKey: "Escape",
    sound: "rocket whoosh",
  },
  {
    group: "arrows",
    guideKey: "arrow keys",
    soundKey: "Arrow keys",
    sound: "one of four impacts",
  },
  {
    group: "any",
    guideKey: "any key",
    soundKey: "Every other key",
    sound: "mostly the shotgun, plus ouch / ough / ahhh",
  },
] as const;

export type KeyGroup = (typeof KEY_BINDINGS)[number]["group"];

const MODIFIER_KEYS = new Set([
  "Alt",
  "CapsLock",
  "ContextMenu",
  "Control",
  "Meta",
  "Shift",
]);

/** Match a key to the guide group that the live deck sound resolver uses. */
export function keyGroupFor(key: string): KeyGroup | null {
  if (MODIFIER_KEYS.has(key)) return null;

  switch (key) {
    case " ":
      return "space";
    case "Enter":
      return "enter";
    case "Backspace":
      return "backspace";
    case "Escape":
      return "escape";
    default:
      return key.startsWith("Arrow") ? "arrows" : "any";
  }
}
