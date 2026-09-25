# 02: A sound on every keystroke

**What to build:** The end-to-end path. A first-run explainer asks for Input Monitoring and offers a button that opens the right System Settings pane, with live permission status in the menu. Once granted, a listen-only event tap captures every keystroke system wide, and a single bundled sound plays on each one. This ticket also bundles the five supplied sound files and decodes them to memory, so nothing depends on the Desktop copy.

**Blocked by:** 01.

**Status:** ready-for-agent

- [x] On first launch the app explains why it needs Input Monitoring and opens the Input Monitoring pane when asked.
- [x] The menu shows whether Input Monitoring is granted and updates when it changes.
- [x] Before permission is granted the app captures nothing and stays silent.
- [ ] After permission is granted, pressing any key in any app plays a sound.
- [ ] Holding a key down repeats the sound.
- [ ] Audio keeps working after long idle periods, with no manual restart needed.
- [x] The five supplied sound files ship inside the app and load with no Desktop or network dependency.
- [x] Mouse clicks, scrolls, and modifier-only presses produce no sound.
- [ ] Typing into a focused password field produces no sound.

## Comments

**2026-09-25 — implemented on `main`.**

Added `InputMonitoring`, `KeystrokeEventTap`, `AudioOutput`, and `Sound`, and rewrote `AppDelegate` to wire them together. The event tap is listen-only, runs on its own thread, watches key-down only, and re-enables itself on `tapDisabledByTimeout` and `tapDisabledByUserInput`. One `AVAudioEngine` decodes all five bundled MP3s into memory at launch and retriggers the shotgun on each keystroke. The engine restarts on `AVAudioEngineConfigurationChange`, so sleep and output-device changes do not silence it.

The five MP3s now live in `AngryKeyboard/Sounds/` and land in `Contents/Resources`. `ENABLE_APP_SANDBOX` is `NO` on Debug and Release, as ADR 0002 requires and ticket 01 flagged. That ticket also carried the real entry-point bug, a default `main()` that never instantiated the delegate; ticket 02 replaces it.

Verified by building and launching:

- the app runs as a UIElement and `applicationDidFinishLaunching` executes
- the first-run explainer alert renders when access is missing
- with no access, no tap is installed, so the app captures nothing
- with access present, the tap appears with listen-only options and mask `1024` (key-down only)
- all five sounds decode and the audio engine reports running

Four boxes stay open because they need Input Monitoring granted plus ears: that a key makes a sound, that a held key repeats, that audio survives a long idle, and that a password field stays silent. The password case relies on Secure Input silencing the tap, which ADR 0001 documents. The README in ticket 06 carries the manual checklist.
