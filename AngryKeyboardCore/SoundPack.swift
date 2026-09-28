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

/// One rule in a sound pack: a key and the sounds it plays.
///
/// `pool` is the set of sounds the binding draws from: one sound for an ordinary
/// binding, several for one that plays a different sound each hit. `voiceCount`
/// is how many copies may play at once under `PlaybackMode.overlap`, counted
/// across the whole pool. The default of one is a retrigger: a new hit replaces
/// the copy already playing.
nonisolated struct Binding: Equatable, Sendable {
    let key: Key
    let pool: SoundPool
    let voiceCount: Int

    init(key: Key, pool: SoundPool, voiceCount: Int = 1) {
        self.key = key
        self.pool = pool
        self.voiceCount = voiceCount
    }

    /// A binding to a single sound: the deterministic case.
    init(key: Key, sound: Sound, voiceCount: Int = 1) {
        self.init(key: key, pool: SoundPool(sound), voiceCount: voiceCount)
    }
}

nonisolated extension Binding {
    /// How many copies of the pool's sounds may play at once in `mode`.
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

/// A named set of bindings and the sound pools they point at.
///
/// A pack always ends in exactly one catch-all, so any keystroke without a
/// binding of its own still finds a match. The initializer appends the catch-all
/// rather than taking it as another binding, which makes "exactly one, and last"
/// impossible to get wrong.
nonisolated struct SoundPack: Sendable {
    let name: String
    let bindings: [Binding]

    init(name: String, bindings: [Binding], catchAll: SoundPool, catchAllVoiceCount: Int = 1) {
        self.name = name
        self.bindings = bindings + [
            Binding(key: .any, pool: catchAll, voiceCount: catchAllVoiceCount)
        ]
    }
}

nonisolated extension SoundPack {
    /// The pack v1 ships: Enter gets the explosion, Esc the whoosh, Backspace
    /// the blast, Spacebar the cocking sound, the arrow keys draw from a pool of
    /// impact sounds, and every other key draws from a pool that is mostly the
    /// shotgun with an occasional reaction.
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
            Binding(key: Key(CGKeyCode(kVK_UpArrow)), pool: arrowImpacts, voiceCount: 3),
            Binding(key: Key(CGKeyCode(kVK_DownArrow)), pool: arrowImpacts, voiceCount: 3),
            Binding(key: Key(CGKeyCode(kVK_LeftArrow)), pool: arrowImpacts, voiceCount: 3),
            Binding(key: Key(CGKeyCode(kVK_RightArrow)), pool: arrowImpacts, voiceCount: 3),
        ],
        catchAll: catchAllPool,
        catchAllVoiceCount: 4
    )

    /// The pool the arrow keys draw from: one impact sound per press, uniform.
    /// All four arrows share it, so their voices count together.
    static let arrowImpacts = SoundPool([.combatImpact, .kungFuYell, .punchImpactHit, .punch])

    /// The pool the catch-all draws from: mostly the shotgun, with a reaction
    /// sound now and then. A weight of four against one each makes the shotgun
    /// about 57% of hits. Every default key shares this pool, so their voices
    /// count together.
    static let catchAllPool = SoundPool(
        [.shotgun, .ahhh, .ouch, .ough],
        weights: [4, 1, 1, 1]
    )

    /// Every pack the app can offer. v1 ships one; the menu hides the picker
    /// until a second pack makes the choice meaningful.
    static let available: [SoundPack] = [.shipped]
}
