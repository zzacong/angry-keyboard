# AngryKeyboard

AngryKeyboard is a macOS menu bar app that plays a sound on every keystroke, system wide.

## Language

**Keystroke**:
A single key-down event captured from the user's keyboard.
_Avoid_: keypress, key hit, input event

**Sound pack**:
A named set of bindings and the sound pools they point at.
_Avoid_: theme, profile, preset, mapping

**Binding**:
One rule in a sound pack. It pairs a key with the sound pool that key plays,
plus the voice count that caps how many copies of that pool may overlap.
_Avoid_: mapping, assignment, rule, slot

**Sound pool**:
The sounds a binding draws from, one per keystroke. A pool of one plays that
sound every time; a larger pool is drawn uniformly at random, so a key can play
a different sound on each hit. The pool is also the unit voices are counted
against: every binding that shares a pool shares its voice count.
_Avoid_: sound set, group, list, playlist

**Playback mode**:
How a binding behaves when its key is hit again before the last hit finished.
Retrigger restarts the one voice; overlap stacks copies up to the binding's
voice count.
_Avoid_: polyphony, layering

**Catch-all**:
The binding that covers any keystroke without a binding of its own. A sound pack has exactly one, and it is the last rule.
_Avoid_: default binding, fallback, default
