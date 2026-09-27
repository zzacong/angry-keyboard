# Capture keystrokes with a listen-only CGEventTap and Input Monitoring

AngryKeyboard observes every keystroke system wide. There are three ways to do this on macOS and they need different privacy permissions: a listen-only CGEventTap needs Input Monitoring, `NSEvent` global monitors need Accessibility, and `IOHIDManager` needs Input Monitoring but far more code. We use a listen-only CGEventTap because it is the lowest-privilege option and the only one Apple supports inside the App Sandbox, which keeps the sandbox-compatible subset in ADR 0002 available.

Two costs come with it. The system disables the tap after a timeout, so the callback must re-enable it. The tap must run on a dedicated thread rather than the main thread, or audio work will stall it. One consequence worth remembering: Secure Input (a focused password field) silences the tap. That is correct behavior, not a failure.
