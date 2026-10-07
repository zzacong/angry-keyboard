# Capture keystrokes with a listen-only CGEventTap

AngryKeyboard observes every keystroke system wide. macOS offers three ways to do this, each behind a different privacy permission: a listen-only CGEventTap needs Input Monitoring, `NSEvent` global monitors need Accessibility, and `IOHIDManager` needs Input Monitoring but far more code. We use the listen-only tap because it is the lowest-privilege option and the only one Apple supports inside the App Sandbox.

The tap has costs. The system disables it after a timeout, so the callback must re-enable it, and it must run on a dedicated thread rather than the main thread or audio work will stall it. Secure Input, which a focused password field turns on, silences the tap. That is correct behavior, not a failure.

v1 ships non-sandboxed. Distribution is settled in ADR 0007, and the app gains nothing from sandboxing today. We still hold voluntarily to the sandbox-compatible subset: listen-only capture, Input Monitoring, and no synthetic event posting. Under the sandbox, synthetic posting is a no-op and Accessibility is unavailable, so those are the two doors we keep shut. The restriction costs nothing today and means adopting the sandbox later is not a rewrite.

Considered and rejected: sandboxing now. It adds an entitlements file and a set of restrictions to a tool that ships outside the App Store and gains nothing from them yet.
