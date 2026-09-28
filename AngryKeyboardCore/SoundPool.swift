/// The sounds a binding draws from, one per keystroke, and how heavily the draw
/// favours each.
///
/// A pool of one is the ordinary binding: it plays that sound every time. A
/// larger pool is drawn at random in proportion to each sound's weight, so the
/// same key can play a different sound on each hit and a heavy sound can
/// dominate the pool. Equal weights make the draw uniform. The pool is also the
/// unit the audio engine counts voices against, so every binding that shares a
/// pool shares its voice count.
nonisolated struct SoundPool: Equatable, Sendable {
    let sounds: [Sound]

    /// One weight per sound, in the same order as `sounds`. A weight of one is
    /// the plain case; a higher weight makes a sound proportionally likelier.
    let weights: [Int]

    /// Creates a pool from sounds and their weights.
    ///
    /// A pool with no sounds could never play, a missing weight would leave a
    /// sound undefined, and a weight of zero or less would make a sound
    /// unreachable, so each of those is a programmer error.
    init(_ sounds: [Sound], weights: [Int]) {
        precondition(!sounds.isEmpty, "a sound pool must hold at least one sound")
        precondition(
            weights.count == sounds.count,
            "a sound pool needs one weight per sound"
        )
        precondition(
            weights.allSatisfy { $0 > 0 },
            "a sound pool's weights must be positive"
        )
        self.sounds = sounds
        self.weights = weights
    }

    /// Creates a uniform pool: every sound equally likely.
    init(_ sounds: [Sound]) {
        self.init(sounds, weights: Array(repeating: 1, count: sounds.count))
    }

    /// Creates a pool of one: the deterministic case.
    init(_ sound: Sound) {
        self.init([sound])
    }

    /// One sound drawn at random in proportion to its weight, using `generator`.
    func draw(using generator: inout some RandomNumberGenerator) -> Sound {
        var pick = Int.random(in: 0..<weights.reduce(0, +), using: &generator)
        for (sound, weight) in zip(sounds, weights) {
            if pick < weight { return sound }
            pick -= weight
        }
        preconditionFailure("a draw must land inside the pool")
    }
}
