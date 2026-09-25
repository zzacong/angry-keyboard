import Foundation

/// The preferences that must survive a relaunch: playback volume, mute, and the
/// playback mode.
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
        static let playbackMode = "playbackMode"
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

    /// How a binding behaves when its key is hit again. Defaults to retrigger on
    /// a fresh install, and to retrigger again if the stored value is not a mode
    /// this build knows.
    var playbackMode: PlaybackMode {
        get {
            guard let raw = defaults.string(forKey: Key.playbackMode),
                  let mode = PlaybackMode(rawValue: raw)
            else { return .retrigger }
            return mode
        }
        nonmutating set {
            defaults.set(newValue.rawValue, forKey: Key.playbackMode)
        }
    }

    /// Pins a volume to `0...1`. Shared with the audio output so a stray value
    /// is clamped once, the same way, wherever it enters.
    static func clamped(_ volume: Double) -> Double {
        min(max(volume, 0), 1)
    }
}
