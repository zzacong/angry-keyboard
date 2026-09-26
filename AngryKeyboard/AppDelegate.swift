import AppKit
import os

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
    private var volumeMenuItem: VolumeMenuItem?
    private var muteItem: NSMenuItem?
    private var overlapItem: NSMenuItem?
    private var launchAtLoginItem: NSMenuItem?
    private var permissionTimer: Timer?
    private var packItems: [NSMenuItem] = []

    /// The settings that survive a relaunch. The menu writes them; the audio
    /// output and the status icon read them.
    private let settings = Settings()

    /// What the keystroke callback reads: which pack is active and how its
    /// bindings behave. The menu writes both on the main thread, so they live
    /// behind one lock and the callback always sees a consistent pair.
    /// Retrigger and the shipped pack are the defaults.
    private struct Routing {
        var mode: PlaybackMode = .retrigger
        var pack: SoundPack = .shipped
    }
    private let routingLock = OSAllocatedUnfairLock(initialState: Routing())

    private let audio = AudioOutput()
    private let eventTap = KeystrokeEventTap()

    /// The name shown to the user, read from the bundle so the menu and the
    /// accessibility label stay in step with the app's display name.
    private var displayName: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
            ?? ProcessInfo.processInfo.processName
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        eventTap.onKeystroke = { [audio, routingLock] keystroke in
            let routing = routingLock.withLock { $0 }
            guard let binding = routing.pack.binding(for: keystroke) else { return }
            audio.play(binding.sound, maxVoices: binding.effectiveVoiceCount(for: routing.mode))
        }

        applyStoredSettings()
        installStatusItem()
        presentExplainerIfNeeded()
        refreshPermission()
    }

    /// Pushes the persisted settings into the engine and the routing before the
    /// tap can fire, so a muted relaunch never makes a sound on the way up and
    /// the overlap choice is in force from the first key.
    private func applyStoredSettings() {
        audio.setVolume(settings.volume)
        audio.setMuted(settings.isMuted)
        let mode = settings.playbackMode
        routingLock.withLock { $0.mode = mode }
    }

    // MARK: - Menu bar

    /// Adds the status item to the system menu bar and builds its menu: the
    /// permission state and, while access is missing, a way to open the right
    /// System Settings pane; the pack, volume, and playback controls; launch at
    /// login; and quit.
    private func installStatusItem() {
        let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

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

        installPackPicker(in: menu)

        let volumeItem = VolumeMenuItem(
            volume: settings.volume,
            target: self,
            action: #selector(volumeChanged(_:))
        )
        menu.addItem(volumeItem)
        volumeMenuItem = volumeItem

        let muteItem = NSMenuItem(
            title: "Mute",
            action: #selector(toggleMute),
            keyEquivalent: ""
        )
        muteItem.target = self
        menu.addItem(muteItem)
        self.muteItem = muteItem

        let overlapItem = NSMenuItem(
            title: "Overlap Sounds",
            action: #selector(toggleOverlapSounds),
            keyEquivalent: ""
        )
        overlapItem.target = self
        menu.addItem(overlapItem)
        self.overlapItem = overlapItem

        menu.addItem(.separator())

        let launchAtLoginItem = NSMenuItem(
            title: "Launch at Login",
            action: #selector(toggleLaunchAtLogin),
            keyEquivalent: ""
        )
        launchAtLoginItem.target = self
        menu.addItem(launchAtLoginItem)
        self.launchAtLoginItem = launchAtLoginItem

        menu.addItem(.separator())

        let aboutItem = NSMenuItem(
            title: "About \(displayName)",
            action: #selector(showAboutPanel),
            keyEquivalent: ""
        )
        aboutItem.target = self
        // Tahoe draws an icon for standard actions like Quit but not for custom
        // ones, so About supplies its own to keep the pair looking even.
        aboutItem.image = NSImage(systemSymbolName: "info.circle", accessibilityDescription: nil)
        aboutItem.image?.isTemplate = true
        menu.addItem(aboutItem)

        menu.addItem(
            withTitle: "Quit \(displayName)",
            action: #selector(NSApplication.terminate(_:)),
            keyEquivalent: "q"
        )

        statusItem.menu = menu
        self.statusItem = statusItem
        refreshStatusIcon()
    }

    /// Adds the pack picker, hidden while there is only one pack to pick. The
    /// data is real either way, so a second pack appears with no menu work.
    private func installPackPicker(in menu: NSMenu) {
        let packs = SoundPack.available

        let picker = NSMenuItem(title: "Sound Pack", action: nil, keyEquivalent: "")
        let submenu = NSMenu()
        for (index, pack) in packs.enumerated() {
            let item = NSMenuItem(
                title: pack.name,
                action: #selector(selectPack(_:)),
                keyEquivalent: ""
            )
            item.target = self
            item.tag = index
            submenu.addItem(item)
            packItems.append(item)
        }
        picker.submenu = submenu
        picker.isHidden = packs.count <= 1
        menu.addItem(picker)
    }

    /// Refreshes the controls just before the menu appears, so nothing in it is
    /// stale when the user looks at it.
    func menuWillOpen(_ menu: NSMenu) {
        refreshPermission()
        syncPlaybackItems()
        syncSettingsItems()
    }

    // MARK: - Playback controls

    /// Flips between retrigger and overlap and stores the choice. The event-tap
    /// callback reads the mode per keystroke, so the change takes effect on the
    /// next key.
    @objc private func toggleOverlapSounds() {
        let mode: PlaybackMode = settings.playbackMode == .retrigger ? .overlap : .retrigger
        settings.playbackMode = mode
        routingLock.withLock { $0.mode = mode }
        syncPlaybackItems()
    }

    /// Points the checkbox and the pack check marks at what the engine is
    /// actually reading.
    private func syncPlaybackItems() {
        overlapItem?.state = routingLock.withLock { $0.mode == .overlap ? .on : .off }
        syncPackItems()
    }

    /// Switches the active pack. The event-tap callback reads the pack per
    /// keystroke, so the change takes effect on the next key.
    @objc private func selectPack(_ sender: NSMenuItem) {
        guard SoundPack.available.indices.contains(sender.tag) else { return }
        let pack = SoundPack.available[sender.tag]
        routingLock.withLock { $0.pack = pack }
        syncPackItems()
    }

    private func syncPackItems() {
        let active = routingLock.withLock { $0.pack.name }
        for (index, item) in packItems.enumerated() {
            item.state = SoundPack.available[index].name == active ? .on : .off
        }
    }

    // MARK: - Settings controls

    /// Stores the slider value and applies it to the mix. The slider is
    /// continuous, so the level follows the drag.
    @objc private func volumeChanged(_ sender: NSSlider) {
        let volume = sender.doubleValue
        settings.volume = volume
        audio.setVolume(volume)
    }

    /// Silences the app without stopping the tap. The setting persists and the
    /// icon changes, so a muted relaunch is never a mystery.
    @objc private func toggleMute() {
        let muted = !settings.isMuted
        settings.isMuted = muted
        audio.setMuted(muted)
        syncSettingsItems()
    }

    /// Registers or unregisters the login item, then re-reads the system so the
    /// checkbox shows the truth even when registration needs approval.
    @objc private func toggleLaunchAtLogin() {
        LaunchAtLogin.setEnabled(!LaunchAtLogin.isEnabled)
        syncSettingsItems()
    }

    private func syncSettingsItems() {
        volumeMenuItem?.volume = settings.volume
        muteItem?.state = settings.isMuted ? .on : .off
        launchAtLoginItem?.state = LaunchAtLogin.isEnabled ? .on : .off
        refreshStatusIcon()
    }

    /// Repaints the menu bar glyph: the plain keyboard normally, the crossed-out
    /// speaker while muted. The change is the only thing that explains a silent
    /// app, so it is refreshed whenever mute changes.
    private func refreshStatusIcon() {
        let symbol = settings.isMuted ? "speaker.slash" : "keyboard"
        let icon = NSImage(systemSymbolName: symbol, accessibilityDescription: displayName)
            ?? NSImage(systemSymbolName: "keyboard", accessibilityDescription: displayName)
        icon?.isTemplate = true
        statusItem?.button?.image = icon
        statusItem?.button?.toolTip = settings.isMuted ? "\(displayName) (muted)" : displayName
    }

    // MARK: - About

    /// Opens the standard About panel. The app is an accessory with no app menu,
    /// so there is nowhere for the usual About item to live and the panel is
    /// asked for by hand. Activation comes first, because an accessory app's
    /// windows otherwise open behind the active app. The panel reads the rest,
    /// version and build, from the bundle; the display name is the one override,
    /// since the default would be the bundle's unspaced `CFBundleName`.
    @objc private func showAboutPanel() {
        NSApp.activate()
        NSApp.orderFrontStandardAboutPanel(options: [
            .applicationName: displayName
        ])
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
