/// The sounds a binding draws from, one per keystroke.
///
/// A pool of one is the ordinary binding: it plays that sound every time. A
/// larger pool is drawn uniformly at random, so the same key can play a
/// different sound on each hit. The pool is also the unit the audio engine
/// counts voices against, so every binding that shares a pool shares its voice
/// count.
nonisolated struct SoundPool: Equatable, Sendable {
    let sounds: [Sound]

    /// Creates a pool from one or more sounds. A pool with no sounds could never
    /// play, so an empty list is a programmer error.
    init(_ sounds: [Sound]) {
        precondition(!sounds.isEmpty, "a sound pool must hold at least one sound")
        self.sounds = sounds
    }

    /// Creates a pool of one: the deterministic case.
    init(_ sound: Sound) {
        self.init([sound])
    }

    /// One sound drawn uniformly at random, using `generator`.
    func draw(using generator: inout some RandomNumberGenerator) -> Sound {
        sounds[Int.random(in: 0..<sounds.count, using: &generator)]
    }
}
