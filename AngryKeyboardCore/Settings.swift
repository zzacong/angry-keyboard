import Foundation

/// The preferences that must survive a relaunch: playback volume and mute.
///
/// Backed by `UserDefaults`, which is injected so tests can use their own suite
/// and never touch the real app's domain. Reads clamp to the valid range, so a
/// hand-edited default cannot push the slider out of bounds.
nonisolated struct Settings {
    /// The volume a fresh install starts at, as a fraction of full scale. A
    /// stored value of zero is honoured, so "unset" stays distinct from "silent".
    static let defaultVolume: Double = 0.6

    private enum Key {
        static let volume = "volume"
        static let muted = "muted"
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    /// The output volume, `0...1`. Defaults to `defaultVolume` until the user
    /// moves the slider.
    var volume: Double {
        get {
            guard defaults.object(forKey: Key.volume) != nil else {
                return Self.defaultVolume
            }
            return Self.clamped(defaults.double(forKey: Key.volume))
        }
        nonmutating set {
            defaults.set(Self.clamped(newValue), forKey: Key.volume)
        }
    }

    /// Whether new keystrokes stay silent. Off on a fresh install.
    var isMuted: Bool {
        get { defaults.bool(forKey: Key.muted) }
        nonmutating set { defaults.set(newValue, forKey: Key.muted) }
    }

    /// Pins a volume to `0...1`. Shared with the audio output so a stray value
    /// is clamped once, the same way, wherever it enters.
    static func clamped(_ volume: Double) -> Double {
        min(max(volume, 0), 1)
    }
}
