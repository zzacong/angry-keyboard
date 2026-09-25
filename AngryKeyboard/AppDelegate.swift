import AppKit

/// Owns the app's lifetime and its only visible surface, the menu bar status
/// item. AngryKeyboard is a background agent: it has no window and no Dock
/// icon, so the status item is created here rather than declared as a scene.
@main
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?

    /// The name shown to the user, read from the bundle so the menu and the
    /// accessibility label stay in step with the app's display name.
    private var displayName: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
            ?? ProcessInfo.processInfo.processName
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        installStatusItem()
    }

    /// Adds the status item to the system menu bar and gives it its menu.
    private func installStatusItem() {
        let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        let icon = NSImage(systemSymbolName: "keyboard", accessibilityDescription: displayName)
        icon?.isTemplate = true
        statusItem.button?.image = icon
        statusItem.button?.toolTip = displayName

        let menu = NSMenu()
        menu.addItem(
            withTitle: "Quit \(displayName)",
            action: #selector(NSApplication.terminate(_:)),
            keyEquivalent: "q"
        )
        statusItem.menu = menu

        self.statusItem = statusItem
    }
}
