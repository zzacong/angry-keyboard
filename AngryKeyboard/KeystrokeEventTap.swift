import CoreGraphics
import Foundation

/// Captures system-wide key-down events with a listen-only event tap.
///
/// The tap is created and serviced on a dedicated thread, never the main thread,
/// so audio work cannot stall the UI. It observes key-down events only, so mouse
/// clicks, scrolls, and modifier-only presses never reach it. It is listen-only
/// and never posts events, which keeps the app inside the sandbox-compatible
/// subset (see ADR 0002). Secure Input silences the tap while a password field
/// is focused, so those keystrokes never reach it either.
///
/// Start the tap only after Input Monitoring is granted. A denied permission
/// makes `start()` fail quietly and leaves the tap stopped, which is what keeps
/// the app silent until the user grants access.
final nonisolated class KeystrokeEventTap: @unchecked Sendable {
    /// Called on the tap thread for every key-down event, including the repeats
    /// macOS generates while a key is held. Set this before calling `start()`.
    var onKeystroke: (@Sendable (CGKeyCode) -> Void)?

    private let lock = NSLock()
    private var port: CFMachPort?
    private var thread: Thread?

    /// Installs the tap on a fresh thread. Does nothing when already running,
    /// so callers can treat it as idempotent and retry it after granting
    /// permission.
    func start() {
        lock.lock()
        guard thread == nil else {
            lock.unlock()
            return
        }
        let thread = Thread { [weak self] in self?.run() }
        thread.name = "AngryKeyboard keystroke tap"
        thread.qualityOfService = .userInteractive
        self.thread = thread
        lock.unlock()
        thread.start()
    }

    /// Creates the tap, wires it into this thread's run loop, and services
    /// events until the app exits. On failure the thread clears itself so a
    /// later `start()` can try again.
    private func run() {
        let mask = CGEventMask(1 << CGEventType.keyDown.rawValue)
        guard let port = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .listenOnly,
            eventsOfInterest: mask,
            callback: Self.callback,
            userInfo: Unmanaged.passUnretained(self).toOpaque()
        ) else {
            clearThread()
            return
        }
        guard let source = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, port, 0) else {
            clearThread()
            return
        }

        lock.lock()
        self.port = port
        lock.unlock()

        CFRunLoopAddSource(CFRunLoopGetCurrent(), source, .commonModes)
        CGEvent.tapEnable(tap: port, enable: true)
        CFRunLoopRun()
    }

    /// Re-enables the tap after macOS disables it for being slow or at the
    /// user's request. Without this the app would go quiet until relaunch.
    private func reenable() {
        lock.lock()
        defer { lock.unlock() }
        guard let port else { return }
        CGEvent.tapEnable(tap: port, enable: true)
    }

    private func clearThread() {
        lock.lock()
        defer { lock.unlock() }
        thread = nil
    }

    /// The C callback. It cannot capture context, so the instance arrives through
    /// `userInfo`. Disable notices are handled here; every other event in the
    /// mask is a key-down.
    private static let callback: CGEventTapCallBack = { _, type, event, userInfo in
        guard let userInfo else { return Unmanaged.passUnretained(event) }
        let tap = Unmanaged<KeystrokeEventTap>.fromOpaque(userInfo).takeUnretainedValue()

        if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
            tap.reenable()
        } else if type == .keyDown {
            let keyCode = CGKeyCode(event.getIntegerValueField(.keyboardEventKeycode))
            tap.onKeystroke?(keyCode)
        }
        return Unmanaged.passUnretained(event)
    }
}
