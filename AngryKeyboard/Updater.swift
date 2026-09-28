import AppKit
import Sparkle

/// Runs Sparkle's standard updater for the production channel and turns its
/// background reminders into an annotation on the status menu.
///
/// AngryKeyboard is a dockless agent, so Sparkle's standard scheduled-update
/// window would open behind whatever the user is doing. This adopts Sparkle's
/// gentle-reminders API instead: a scheduled check that finds a newer build
/// does not open a window, it annotates the "Check for Updates…" item with the
/// available version. Clicking the item still runs the standard flow, which is
/// the only path that installs anything.
///
/// The dev channel never creates one of these. `AppDelegate` consults
/// `UpdatePolicy` first, so nothing here runs when `AKEnableUpdates` is false.
@MainActor
final class Updater: NSObject {
    /// Sparkle's standard controller. The menu item targets it directly so
    /// Sparkle keeps enabling and disabling the item while a check or install
    /// is in flight.
    let controller: SPUStandardUpdaterController

    /// The reminder delegate. Sparkle holds it weakly, so this keeps it alive.
    private let reminder: ScheduledUpdateReminder

    /// The version Sparkle found in the background, or nil when none is pending.
    private var availableVersion: String?

    /// The status-menu item to annotate. Weak, because the menu owns it.
    private weak var updateItem: NSMenuItem?

    private static let restingTitle = "Check for Updates…"

    override init() {
        // Sparkle takes its user-driver delegate at init time and holds it
        // weakly, so a small forwarding object is created first and pointed
        // back at this updater once `self` exists.
        let reminder = ScheduledUpdateReminder()
        self.controller = SPUStandardUpdaterController(
            startingUpdater: false,
            updaterDelegate: nil,
            userDriverDelegate: reminder
        )
        self.reminder = reminder
        super.init()
        reminder.updater = self
        controller.startUpdater()
    }

    /// Builds the permanent "Check for Updates…" item. The caller places it in
    /// the menu directly above About.
    func makeMenuItem() -> NSMenuItem {
        let item = NSMenuItem(
            title: Self.restingTitle,
            action: #selector(SPUStandardUpdaterController.checkForUpdates(_:)),
            keyEquivalent: ""
        )
        item.target = controller
        updateItem = item
        renderAvailability()
        return item
    }

    /// Records the version Sparkle found in the background.
    fileprivate func markUpdateAvailable(version: String) {
        availableVersion = version
        renderAvailability()
    }

    /// Clears the annotation once the update has been seen or the session ends.
    fileprivate func clearUpdate() {
        availableVersion = nil
        renderAvailability()
    }

    /// Annotates the item with the version Sparkle found, or returns it to its
    /// resting title when nothing is pending.
    private func renderAvailability() {
        guard let item = updateItem else { return }
        if let version = availableVersion {
            item.title = "\(Self.restingTitle) (\(version))"
        } else {
            item.title = Self.restingTitle
        }
    }
}

/// Forwards Sparkle's standard-user-driver callbacks to the `Updater`.
///
/// Sparkle wants the delegate at `SPUStandardUpdaterController` init time,
/// before `Updater` can reference itself. This object fills that slot and is
/// pointed at the updater immediately after. The callbacks arrive on the main
/// thread, so each hops back to the main actor to touch the menu item.
private nonisolated final class ScheduledUpdateReminder: NSObject, SPUStandardUserDriverDelegate {
    weak var updater: Updater?

    var supportsGentleScheduledUpdateReminders: Bool { true }

    /// Handles every scheduled update here: the menu annotation is the
    /// reminder. User-initiated checks never reach this method, so they keep
    /// Sparkle's standard flow.
    func standardUserDriverShouldHandleShowingScheduledUpdate(
        _ update: SUAppcastItem,
        andInImmediateFocus immediateFocus: Bool
    ) -> Bool {
        false
    }

    /// Called before an update is shown. Scheduled updates that we handle pass
    /// `handleShowingUpdate == false`, which is when the item is annotated.
    /// User-initiated checks pass true and are left to Sparkle.
    func standardUserDriverWillHandleShowingUpdate(
        _ handleShowingUpdate: Bool,
        forUpdate update: SUAppcastItem,
        state: SPUUserUpdateState
    ) {
        guard !handleShowingUpdate else { return }
        MainActor.assumeIsolated {
            updater?.markUpdateAvailable(version: update.displayVersionString)
        }
    }

    /// The user has seen the update, so the annotation has done its job.
    func standardUserDriverDidReceiveUserAttention(forUpdate update: SUAppcastItem) {
        MainActor.assumeIsolated {
            updater?.clearUpdate()
        }
    }

    /// The update session ended; clear any lingering annotation.
    func standardUserDriverWillFinishUpdateSession() {
        MainActor.assumeIsolated {
            updater?.clearUpdate()
        }
    }
}
