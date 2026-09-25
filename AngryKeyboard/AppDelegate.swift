import AppKit

/// Owns the app's lifetime and its only visible surface, the menu bar status
/// item. AngryKeyboard is a background agent: it has no window and no Dock
/// icon, so the status item is created here rather than declared as a scene.
///
/// This is also where the three pieces of the keystroke path meet: the
/// permission check, the event tap, and the audio output.
@main
final class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    /// AppKit's default `main()` calls `NSApplicationMain`, which expects the
    /// delegate to come from a main nib. AngryKeyboard has no nib, so this sets
    /// the delegate itself and runs the app.
    static func main() {
        let app = NSApplication.shared
        let delegate = AppDelegate()
        app.setActivationPolicy(.accessory)
        app.delegate = delegate
        app.run()
    }

    private var statusItem: NSStatusItem?
    private var permissionStatusItem: NSMenuItem?
    private var openSettingsItem: NSMenuItem?
    private var permissionTimer: Timer?

    private let audio = AudioOutput()
    private let eventTap = KeystrokeEventTap()
    private let pack = SoundPack.shipped

    /// The name shown to the user, read from the bundle so the menu and the
    /// accessibility label stay in step with the app's display name.
    private var displayName: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
            ?? ProcessInfo.processInfo.processName
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        eventTap.onKeystroke = { [audio, pack] keystroke in
            guard let binding = pack.binding(for: keystroke) else { return }
            audio.play(binding.sound)
        }

        installStatusItem()
        presentExplainerIfNeeded()
        refreshPermission()
    }

    // MARK: - Menu bar

    /// Adds the status item to the system menu bar and builds its menu. The
    /// menu shows permission state and, while access is missing, a way to open
    /// the right System Settings pane.
    private func installStatusItem() {
        let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        let icon = NSImage(systemSymbolName: "keyboard", accessibilityDescription: displayName)
        icon?.isTemplate = true
        statusItem.button?.image = icon
        statusItem.button?.toolTip = displayName

        let menu = NSMenu()
        menu.delegate = self

        let permissionStatusItem = NSMenuItem(title: "", action: nil, keyEquivalent: "")
        permissionStatusItem.isEnabled = false
        menu.addItem(permissionStatusItem)
        self.permissionStatusItem = permissionStatusItem

        let openSettingsItem = NSMenuItem(
            title: "Open Input Monitoring Settings…",
            action: #selector(openInputMonitoringSettings),
            keyEquivalent: ""
        )
        openSettingsItem.target = self
        menu.addItem(openSettingsItem)
        self.openSettingsItem = openSettingsItem

        menu.addItem(.separator())
        menu.addItem(
            withTitle: "Quit \(displayName)",
            action: #selector(NSApplication.terminate(_:)),
            keyEquivalent: "q"
        )

        statusItem.menu = menu
        self.statusItem = statusItem
    }

    /// Refreshes permission state just before the menu appears, so the menu is
    /// never stale when the user looks at it.
    func menuWillOpen(_ menu: NSMenu) {
        refreshPermission()
    }

    // MARK: - Permission

    /// Reads permission from the system, reflects it in the menu, and starts the
    /// tap once access is granted. Polling continues until the tap is actually
    /// running, so a grant that fails to install a tap is retried instead of
    /// leaving the menu reading "Granted" over a dead tap.
    private func refreshPermission() {
        let granted = InputMonitoring.isGranted
        applyPermission(granted: granted)

        if granted {
            eventTap.start()
        }

        if granted && eventTap.isRunning {
            permissionTimer?.invalidate()
            permissionTimer = nil
        } else {
            startPermissionPolling()
        }
    }

    private func applyPermission(granted: Bool) {
        permissionStatusItem?.title = granted
            ? "Input Monitoring: Granted"
            : "Input Monitoring: Not Granted"
        openSettingsItem?.isHidden = granted
    }

    /// Polls until the tap is running. The interval is short enough that the app
    /// starts firing soon after the switch is flipped, and the timer stops
    /// itself once the tap is up.
    private func startPermissionPolling() {
        guard permissionTimer == nil else { return }
        let timer = Timer(timeInterval: 2, repeats: true) { [weak self] _ in
            self?.refreshPermission()
        }
        RunLoop.main.add(timer, forMode: .common)
        permissionTimer = timer
    }

    /// Explains why Input Monitoring is needed before macOS asks, then offers
    /// the exact System Settings pane. Shown on every launch while access is
    /// missing, so dismissing it once cannot hide the guided path for good.
    private func presentExplainerIfNeeded() {
        guard !InputMonitoring.isGranted else { return }

        NSApp.activate()
        let alert = NSAlert()
        alert.messageText = "\(displayName) needs Input Monitoring"
        alert.informativeText = """
            \(displayName) plays a sound on every keystroke, so it has to hear \
            your keyboard system wide. macOS calls this Input Monitoring.
            It only listens. It never records, stores, or sends what you type.
            """
        alert.addButton(withTitle: "Open System Settings")
        alert.addButton(withTitle: "Not Now")

        if alert.runModal() == .alertFirstButtonReturn {
            openInputMonitoringSettings()
        }
    }

    /// Asks the system to list the app for Input Monitoring and opens the pane
    /// where the user flips the switch.
    @objc private func openInputMonitoringSettings() {
        InputMonitoring.request()
        InputMonitoring.openSettings()
        refreshPermission()
    }
}
