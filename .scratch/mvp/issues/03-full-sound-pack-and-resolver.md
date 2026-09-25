# 03: The full sound pack and the keystroke resolver

**What to build:** The pack becomes data. A typed sound pack holds four bindings plus a catch-all, wired to the five supplied sounds: Enter plays the explosion, Esc the whoosh, Backspace the blast, Spacebar the cocking sound, and every other key the shotgun. The decision of which sound a keystroke plays becomes a pure function, covered by focused unit tests.

**Blocked by:** 02.

**Status:** ready-for-agent

- [ ] Enter plays the explosion, Esc the whoosh, Backspace the blast, and Spacebar the cocking sound.
- [ ] Every other key, including letters, numbers, arrows, and function keys, plays the shotgun sound.
- [ ] The catch-all covers any keystroke without a binding of its own.
- [ ] A pure function maps a keystroke to the binding to play, with no audio code and no permission code in it.
- [ ] Unit tests cover the key-to-binding mapping, the catch-all fallback, and keystrokes that map to nothing.
- [ ] The tests run from Xcode or the command line with the project's toolchain.
