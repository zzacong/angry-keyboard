# 05: Menu controls and stored settings

**What to build:** The menu grows the controls the app needs day to day. A volume slider defaulting to 60%, a mute toggle that persists and changes the menu bar icon, launch-at-login read live from the system, and current permission status. The pack picker exists but stays hidden while only one pack exists.

**Blocked by:** 04.

**Status:** ready-for-agent

- [ ] The menu has a volume slider whose value defaults to 60% and survives a relaunch.
- [ ] The menu has a mute toggle whose state survives a relaunch.
- [ ] While muted, the menu bar icon changes, new keystrokes are silent, and unmuting restores sound.
- [ ] The menu has a launch-at-login toggle that reads its state live from the system, and the system is treated as the single source of truth.
- [ ] The menu shows current Input Monitoring permission status.
- [ ] A pack picker is implemented but hidden while only one pack exists.
