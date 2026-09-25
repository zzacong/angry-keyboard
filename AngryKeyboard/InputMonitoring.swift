import AppKit
import CoreGraphics

/// The Input Monitoring permission, read live from the system.
///
/// The app keeps no copy of this state; every read asks the system, so what the
/// menu shows can never drift from System Settings.
enum InputMonitoring {
    /// Whether the app may observe keyboard events system wide.
    static var isGranted: Bool { CGPreflightListenEventAccess() }

    /// Triggers the one-time system prompt and adds the app to the Input
    /// Monitoring list. Calling it again after the first prompt does nothing.
    @discardableResult
    static func request() -> Bool { CGRequestListenEventAccess() }

    /// Opens System Settings to Privacy & Security > Input Monitoring.
    static func openSettings() {
        let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ListenEvent")!
        NSWorkspace.shared.open(url)
    }
}
