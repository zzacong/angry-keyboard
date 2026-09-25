# AngryKeyboard

AngryKeyboard is a macOS menu bar app that plays a sound on every keystroke, system wide.

## Language

**Keystroke**:
A single key-down event captured from the user's keyboard.
_Avoid_: keypress, key hit, input event

**Sound pack**:
A named set of bindings and the sounds they point at.
_Avoid_: theme, profile, preset, mapping

**Binding**:
One rule in a sound pack. It pairs a key with the sound that key plays.
_Avoid_: mapping, assignment, rule, slot

**Catch-all**:
The binding that covers any keystroke without a binding of its own. A sound pack has exactly one, and it is the last rule.
_Avoid_: default binding, fallback, default
