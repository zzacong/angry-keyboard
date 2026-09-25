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
nonisolated struct Binding: Equatable, Sendable {
    let key: Key
    let sound: Sound
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

    init(name: String, bindings: [Binding], catchAll: Sound) {
        self.name = name
        self.bindings = bindings + [Binding(key: .any, sound: catchAll)]
    }
}

nonisolated extension SoundPack {
    /// The pack v1 ships: Enter gets the explosion, Esc the whoosh, Backspace
    /// the blast, Spacebar the cocking sound, and every other key the shotgun.
    static let shipped = SoundPack(
        name: "Angry Keyboard",
        bindings: [
            Binding(key: Key(CGKeyCode(kVK_Return)), sound: .explodeRock),
            Binding(key: Key(CGKeyCode(kVK_Escape)), sound: .rocketWhoosh),
            Binding(key: Key(CGKeyCode(kVK_Delete)), sound: .shotgunBlast),
            Binding(key: Key(CGKeyCode(kVK_Space)), sound: .shotgunCocking),
        ],
        catchAll: .shotgun
    )
}
