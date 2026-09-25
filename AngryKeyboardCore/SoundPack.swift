import Carbon
import CoreGraphics

/// A key a binding answers to.
///
/// `modifiers` is the set of flags that must be held for the binding to match.
/// An empty set matches the key whatever modifiers are held, which is how the
/// shipped bindings behave.
nonisolated enum Key: Equatable, Sendable {
    case keyCode(CGKeyCode, modifiers: CGEventFlags)

    /// The catch-all key: matches any keystroke no earlier binding claimed.
    case any

    /// A key with no modifier requirement.
    init(_ keyCode: CGKeyCode) {
        self = .keyCode(keyCode, modifiers: [])
    }

    func matches(_ keystroke: Keystroke) -> Bool {
        switch self {
        case .keyCode(let keyCode, let required):
            return keyCode == keystroke.keyCode
                && keystroke.modifiers.isSuperset(of: required)
        case .any:
            return true
        }
    }
}

/// One rule in a sound pack: a key and the sound it plays.
///
/// `voiceCount` is how many copies of `sound` may play at once under
/// `PlaybackMode.overlap`. The default of one is a retrigger: a new hit
/// replaces the copy already playing.
nonisolated struct Binding: Equatable, Sendable {
    let key: Key
    let sound: Sound
    let voiceCount: Int

    init(key: Key, sound: Sound, voiceCount: Int = 1) {
        self.key = key
        self.sound = sound
        self.voiceCount = voiceCount
    }
}

nonisolated extension Binding {
    /// How many copies of `sound` may play at once in `mode`.
    ///
    /// Retrigger always uses a single voice, whatever the binding asks for, so
    /// the menu toggle is a true comparison: the same pack, one voice against
    /// the pack's own counts. A count below one is treated as one, since a
    /// sound that can never play is not a useful binding.
    func effectiveVoiceCount(for mode: PlaybackMode) -> Int {
        switch mode {
        case .retrigger: 1
        case .overlap: max(1, voiceCount)
        }
    }
}

/// A named set of bindings and the sounds they point at.
///
/// A pack always ends in exactly one catch-all, so any keystroke without a
/// binding of its own still finds a match. The initializer appends the catch-all
/// rather than taking it as another binding, which makes "exactly one, and last"
/// impossible to get wrong.
nonisolated struct SoundPack: Sendable {
    let name: String
    let bindings: [Binding]

    init(name: String, bindings: [Binding], catchAll: Sound, catchAllVoiceCount: Int = 1) {
        self.name = name
        self.bindings = bindings + [
            Binding(key: .any, sound: catchAll, voiceCount: catchAllVoiceCount)
        ]
    }
}

nonisolated extension SoundPack {
    /// The pack v1 ships: Enter gets the explosion, Esc the whoosh, Backspace
    /// the blast, Spacebar the cocking sound, and every other key the shotgun.
    ///
    /// The voice counts only bite in overlap mode, where they cap how many
    /// copies may stack. Short sounds take more copies, the long explosion
    /// fewer, so overlap stays legible instead of turning to mud.
    static let shipped = SoundPack(
        name: "Angry Keyboard",
        bindings: [
            Binding(key: Key(CGKeyCode(kVK_Return)), sound: .explodeRock, voiceCount: 2),
            Binding(key: Key(CGKeyCode(kVK_Escape)), sound: .rocketWhoosh, voiceCount: 2),
            Binding(key: Key(CGKeyCode(kVK_Delete)), sound: .shotgunBlast, voiceCount: 3),
            Binding(key: Key(CGKeyCode(kVK_Space)), sound: .shotgunCocking, voiceCount: 6),
        ],
        catchAll: .shotgun,
        catchAllVoiceCount: 4
    )
}
