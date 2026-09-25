# 03: The full sound pack and the keystroke resolver

**What to build:** The pack becomes data. A typed sound pack holds four bindings plus a catch-all, wired to the five supplied sounds: Enter plays the explosion, Esc the whoosh, Backspace the blast, Spacebar the cocking sound, and every other key the shotgun. The decision of which sound a keystroke plays becomes a pure function, covered by focused unit tests.

**Blocked by:** 02.

**Status:** resolved

- [x] Enter plays the explosion, Esc the whoosh, Backspace the blast, and Spacebar the cocking sound.
- [x] Every other key, including letters, numbers, arrows, and function keys, plays the shotgun sound.
- [x] The catch-all covers any keystroke without a binding of its own.
- [x] A pure function maps a keystroke to the binding to play, with no audio code and no permission code in it.
- [x] Unit tests cover the key-to-binding mapping, the catch-all fallback, and keystrokes that map to nothing.
- [x] The tests run from Xcode or the command line with the project's toolchain.

## Comments

**2026-09-25 — implemented on `main`.**

The pack is now data. `AngryKeyboardCore` holds the typed model shared by the app
and the test bundle: `Sound`, `Keystroke`, `Key`, `Binding`, `SoundPack`, and the
resolver in `Resolver.swift`. `SoundPack.shipped` binds Enter to the explosion,
Esc to the whoosh, Backspace to the blast, and Spacebar to the cocking sound,
with the shotgun as the catch-all. The event tap now passes a `Keystroke` (key
code plus modifier flags) instead of a bare key code, and `AppDelegate` resolves
the binding before playing it.

The resolver is a pure function on `SoundPack`: `binding(for:)` rejects modifier
keys and otherwise takes the first matching binding, so the catch-all covers any
key without a binding of its own. It holds no audio or permission code, so the
tests need no engine, no permission prompt, and no keyboard.

`AngryKeyboardCore` is a filesystem-synchronized group shared by both targets, so
the tests compile the same sources the app ships and never launch the app. That
matters: hosting the app would start the audio engine and present the Input
Monitoring explainer before a single assertion ran. A non-hosted
`AngryKeyboardTests` unit-test target covers the five bindings, the catch-all for
letters, numbers, arrows, and function keys, modifier handling, and the modifier
keys that map to nothing.

Verified:

- `xcodebuild test -scheme AngryKeyboard -destination 'platform=macOS'` → 12
  tests, 0 failures
- Debug build succeeds with no warnings

The shared `AngryKeyboard` scheme gains a Test action for the new target, so the
tests run from Xcode's Product > Test and from the command line.

The "maps to nothing" case is the modifier-key guard. Modifiers arrive as
`flagsChanged`, which the tap does not watch, so that path is defence in depth
rather than something the live tap produces; the tests exercise the resolver
directly. Held modifiers do not suppress an otherwise-bound key, so `Cmd-C` still
plays the shotgun, matching "every other key".
