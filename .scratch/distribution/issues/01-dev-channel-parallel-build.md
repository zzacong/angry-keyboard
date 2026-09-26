# 01: Dev channel builds and runs beside production

**What to build:** Building for development and building for release should produce two apps that can be installed and run at the same time. The dev build carries its own bundle id, display name, and product name, and the release build keeps the production ones. Each gets its own preferences and its own Input Monitoring entry for free, because macOS keys those to the bundle id. The committed project must still build for someone who clones it and has no certificate, so it signs ad-hoc by default and the certificate names never enter the repository.

**Blocked by:** None (can start immediately).

**Status:** resolved

- [x] Debug builds an app with display name "Angry Keyboard Dev" and bundle id `com.zzacong.AngryKeyboard.dev`; Release builds "Angry Keyboard" with `com.zzacong.AngryKeyboard`.
- [x] Both apps install side by side and run at the same time.
- [x] The two apps keep separate volume, mute, and playback mode values.
- [x] A clean clone with no certificate builds both configurations.
- [x] The channel values live in committed per-configuration files rather than scattered across the target settings.

## Comments

Implemented in the working tree. `Config/Debug.xcconfig` and
`Config/Release.xcconfig` are the base configurations for the app target's two
build configurations, and the six channel settings moved out of the target. Each
file ends with `#include? "<Config>.local.xcconfig"`, which is gitignored, so a
clone with no certificate signs ad-hoc via `CODE_SIGN_IDENTITY = -`.

Verified:

- Debug builds `AngryKeyboardDev.app` with bundle id
  `com.zzacong.AngryKeyboard.dev` and display name "Angry Keyboard Dev"; Release
  builds `AngryKeyboard.app` with `com.zzacong.AngryKeyboard` and "Angry
  Keyboard". Both are ad-hoc signed (`Signature=adhoc`, `TeamIdentifier=not
  set`).
- The full test suite passes (40 tests).
- A local override in `Config/Debug.local.xcconfig` is picked up and git ignores
  it.
- Separate preferences follow from the separate bundle ids: `Settings` reads
  `UserDefaults.standard`, so volume, mute, and playback mode live in a distinct
  domain per channel with no code change.

Deferred on purpose:

- The dev app icon (`AppIconDev`) is ticket 02. `ASSETCATALOG_COMPILER_APPICON_NAME`
  is `AppIcon` in both files until that asset exists, so the dev app keeps a real
  icon in the meantime. Ticket 02 flips the Debug line.
- `Config/*.local.xcconfig.example`, `*.p12`, and `dist/` belong to tickets 03
  and 07. Only `Config/*.local.xcconfig` is ignored here.

Finding for ticket 02: `INFOPLIST_KEY_<custom>` does not reach the generated
`Info.plist` on Xcode 27. Setting `INFOPLIST_KEY_AKMenuBarGlyph` resolves in
build settings but the key is absent from the built plist, so the glyph keys
were left out rather than committed as dead config. Ticket 02 needs another
route (a real `Info.plist` file, a build phase, or a per-channel asset name).
The spec's "Config/*.xcconfig" snippets should be corrected.

The shared scheme still names `AngryKeyboard.app`, while Debug now emits
`AngryKeyboardDev.app`. `xcodebuild` builds and tests both configurations fine;
Xcode resolves the runnable through the target and build settings, not the
scheme's `BuildableName`. Worth a quick Cmd-R check in each configuration.

