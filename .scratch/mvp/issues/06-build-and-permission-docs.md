# 06: Build and permission docs

**What to build:** A short README covering how to build the app, how to run it, and how to grant Input Monitoring, plus the manual checklist for the parts that cannot be unit tested: real capture, real audio, and the permission flow. This leaves the project ready for a DMG later.

**Blocked by:** 05.

**Status:** resolved

- [x] A README explains how to build and run the app.
- [x] The README explains how to grant Input Monitoring, including the System Settings pane and the first-run prompt.
- [x] The README lists manual verification steps for capture, audio, and the permission flow.
- [x] A reader can go from a clean checkout to hearing the app by following the README alone.

## Comments

**2026-09-25 — implemented on `main`.**

`README.md` at the repo root covers the clean checkout to hearing the app path.
It gives both ways to build: open the Xcode project and Run, or
`xcodebuild -scheme AngryKeyboard -configuration Debug -derivedDataPath build build`
followed by `open build/Build/Products/Debug/AngryKeyboard.app`. It states the
requirements from the project itself, macOS 26.7 and Xcode 27.0.

The permission section describes what the reader sees on first launch: the
explainer runs before macOS asks anything, and Open System Settings both
registers the app and opens Privacy & Security > Input Monitoring. It notes that
System Settings lists the app under its display name, Angry Keyboard. It also
covers the menu item path when the explainer was dismissed, the live menu status,
and the macOS quirk where a new grant needs a relaunch.

Manual verification is split into capture, audio, permission flow, and menu
controls. Each item is a concrete check: the key sounds, held-key repeats,
silence for mouse and modifiers, Secure Input silence, volume and mute
persistence, overlap persistence, no clipping on fast typing, audio across
sleep and device change, the explainer and both switch directions, launch at
login against the system, and quit.

Verified:

- `xcodebuild test -scheme AngryKeyboard -destination 'platform=macOS'` reports
  35 tests, 0 failures
- `xcodebuild -scheme AngryKeyboard -configuration Debug -derivedDataPath build build`
  succeeds, and the app builds at `build/Build/Products/Debug/AngryKeyboard.app`

Nothing here needs a unit test, so the two-axis code review was not run. The
README was checked against the four acceptance criteria directly.

**2026-09-25 — follow-up: document the stored settings CLI.**

The README gains a Stored settings section: the three UserDefaults keys with
their types and defaults, the `defaults` read, write, and delete commands, the
type-flag requirement, the quit, write, relaunch rule for the cfprefsd cache,
and a note that Launch at Login is not stored because the system owns it.
