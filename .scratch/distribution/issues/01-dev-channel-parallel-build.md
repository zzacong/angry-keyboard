# 01: Dev channel builds and runs beside production

**What to build:** Building for development and building for release should produce two apps that can be installed and run at the same time. The dev build carries its own bundle id, display name, and product name, and the release build keeps the production ones. Each gets its own preferences and its own Input Monitoring entry for free, because macOS keys those to the bundle id. The committed project must still build for someone who clones it and has no certificate, so it signs ad-hoc by default and the certificate names never enter the repository.

**Blocked by:** None (can start immediately).

**Status:** ready-for-agent

- [ ] Debug builds an app with display name "Angry Keyboard Dev" and bundle id `com.zzacong.AngryKeyboard.dev`; Release builds "Angry Keyboard" with `com.zzacong.AngryKeyboard`.
- [ ] Both apps install side by side and run at the same time.
- [ ] The two apps keep separate volume, mute, and playback mode values.
- [ ] A clean clone with no certificate builds both configurations.
- [ ] The channel values live in committed per-configuration files rather than scattered across the target settings.
