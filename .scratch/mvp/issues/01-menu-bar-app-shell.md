# 01: Menu bar app shell

**What to build:** The app runs as a background menu bar app. Launching it shows a status item in the menu bar whose menu contains Quit. It has no Dock icon and opens no window.

**Blocked by:** None (can start immediately).

**Status:** resolved

- [x] Launching the app shows a status item in the menu bar.
- [x] Clicking the status item shows a menu containing Quit.
- [x] Quit terminates the app.
- [x] The app has no Dock icon and opens no window.
- [x] The hello-world window and its placeholder content are gone.

## Comments

**2026-09-25 — implemented in `5161f47`.**

`AppDelegate.swift` replaces the SwiftUI app scene and owns an `NSStatusItem` with a Quit menu item. `INFOPLIST_KEY_LSUIElement = YES` is set on Debug and Release, so the app has no Dock icon and opens no window.

Verified by building and launching: the process runs as a `UIElement`, `CGWindowList` reports no normal-level windows, the `keyboard` symbol resolves to a real image, and quitting terminates the process. Visual confirmation of the menu bar icon is still a manual check, since screen recording is unavailable to the tooling.

Follow-up: the target keeps `ENABLE_APP_SANDBOX = YES`, which contradicts ADR 0002. Out of scope here; should be flipped in ticket 02 or 06.

**2026-09-25 — correction found while building ticket 02.**

The status item never actually appeared. The `@main` type used AppKit's default `NSApplicationDelegate.main()`, which calls `NSApplicationMain` and expects the delegate to come from a main nib. There is no nib, so `AppDelegate` was never instantiated: `applicationDidFinishLaunching` never ran, the status item was never created, and the process was a no-op. The earlier check only confirmed that a windowless process launched, which a no-op also does.

Ticket 02 replaces the default entry point with a local `static func main()` that owns a strong reference to the delegate. Confirmed by launch that `applicationDidFinishLaunching` now runs.
