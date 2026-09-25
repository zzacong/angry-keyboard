# 05: Menu controls and stored settings

**What to build:** The menu grows the controls the app needs day to day. A volume slider defaulting to 60%, a mute toggle that persists and changes the menu bar icon, launch-at-login read live from the system, and current permission status. The pack picker exists but stays hidden while only one pack exists.

**Blocked by:** 04.

**Status:** resolved

- [x] The menu has a volume slider whose value defaults to 60% and survives a relaunch.
- [x] The menu has a mute toggle whose state survives a relaunch.
- [x] While muted, the menu bar icon changes, new keystrokes are silent, and unmuting restores sound.
- [x] The menu has a launch-at-login toggle that reads its state live from the system, and the system is treated as the single source of truth.
- [x] The menu shows current Input Monitoring permission status.
- [x] A pack picker is implemented but hidden while only one pack exists.

## Comments

**2026-09-25 — implemented on `main`.**

The menu carries the day-to-day controls now. `Settings` is a `UserDefaults`-backed struct in core. Volume defaults to 0.6 and mute defaults to off, and both survive a relaunch. `SettingsTests` covers the defaults, persistence, the case where a stored zero must not fall back to the default, and clamping.

`AudioOutput` has `setVolume` and `setMuted`. Volume is a master gain applied after the limiter, so the slider moves a sound that is already playing. Mute drops the voices in flight and blocks new ones, so unmuting starts clean instead of replaying the tail of an old sound. The event-tap callback checks the mute flag before it resolves a binding.

The menu order is: permission status and the Input Monitoring button, the pack picker, the volume slider, Mute, Overlap Sounds, Launch at Login, Quit. The slider is a custom `VolumeMenuItem` view with a speaker glyph. `LaunchAtLogin` wraps `SMAppService.mainApp` and reads `status == .enabled` live, so the app keeps no copy of that state; toggling re-reads the system. The status icon is a keyboard normally and a crossed-out speaker while muted, with a matching tooltip.

The pack picker is backed by `SoundPack.available` with selection and check marks wired, and hidden while only one pack exists, so a second pack is a drop-in.

A two-axis review caught four things, all fixed. The volume clamp was duplicated across `Settings` and `AudioOutput`, so it now lives only in `Settings.clamped`. The picker keyed items by pack name, which could collide, so items carry an index tag. Mute left in-flight voices advancing, which replayed a tail on unmute, so mute clears them. And `SoundPack.showsPicker` put menu policy on the core model, so the one-pack check moved into `AppDelegate`.

Verified:

- `xcodebuild test -scheme AngryKeyboard -destination 'platform=macOS'` reports 32 tests, 0 failures
- Debug build succeeds with no warnings
- A launch with `muted = true` and `volume = 0.25` persisted starts clean and stays alive; the defaults were restored after

The menu bar is a manual check because the tooling cannot capture the screen. Slider feel, the icon swap by eye, and the launch-at-login checkbox against System Settings still need a human pass.

**2026-09-25 — follow-up: persist the overlap mode.**

The overlap toggle was in-memory, so a relaunch reset it to retrigger. `PlaybackMode` is now `String`-raw so `Settings.playbackMode` can store it, defaulting to retrigger. `applyStoredSettings` seeds the live routing from the stored mode, and `toggleOverlapSounds` writes the flip back. Three `SettingsTests` cover the fresh default, the round trip, and the fallback when the stored value is not a mode this build knows.

Verified: 35 tests, 0 failures, and the Debug build has no warnings.
