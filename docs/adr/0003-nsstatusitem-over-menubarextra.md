# Build the menu bar item with NSStatusItem, not MenuBarExtra

SwiftUI's `MenuBarExtra` is the obvious choice for a menu bar app, and the least code. On macOS 26 it has a failure mode that rules it out here. macOS 26 adds a per-app "Allow in Menu Bar" toggle in Control Center. When the user turns it off, a `MenuBarExtra`-only process can be terminated with no crash log, because the scene owns the app's lifetime. AngryKeyboard must keep playing sounds while its icon is hidden, so it has to own its lifetime instead. We create the status item ourselves with `NSStatusItem` from an `AppDelegate`, and set `LSUIElement` so the app has no Dock icon.

Considered and rejected: `MenuBarExtra` plus an extra `Window` scene as a lifeboat. The app should have no window at all, and it must survive independently of its icon.
