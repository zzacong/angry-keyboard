import ServiceManagement

/// Login item registration, read live from the system.
///
/// `SMAppService.mainApp` is the single source of truth: the app stores no copy
/// of this state, so the menu toggle cannot drift from System Settings. A
/// registration that still needs the user's approval reads as off, because the
/// app will not actually launch until it is approved.
enum LaunchAtLogin {
    /// Whether the app is registered to launch at login.
    static var isEnabled: Bool {
        SMAppService.mainApp.status == .enabled
    }

    /// Registers or unregisters the app. Errors are logged rather than shown in
    /// the menu, which has nowhere to report them; the toggle then re-reads the
    /// system and shows the truth.
    static func setEnabled(_ enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            NSLog("AngryKeyboard: could not \(enabled ? "enable" : "disable") launch at login: \(error)")
        }
    }
}
