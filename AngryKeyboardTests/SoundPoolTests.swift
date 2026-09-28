import XCTest

/// Covers the sound pool: the sounds a binding draws from, and the weighted draw
/// that picks one per hit. The generator is seeded, so the draw is deterministic
/// and the test does not depend on system entropy.
final class SoundPoolTests: XCTestCase {
    /// The pool the shipped arrow keys draw from: the uniform multi-sound case.
    private let impacts = SoundPack.arrowImpacts

    /// The pool the catch-all draws from: the weighted case.
    private let catchAll = SoundPack.catchAllPool

    func testAPoolOfOneAlwaysDrawsThatSound() {
        var generator = SeededGenerator(seed: 1)
        let pool = SoundPool(.shotgun)

        for _ in 0..<100 {
            XCTAssertEqual(pool.draw(using: &generator), .shotgun)
        }
    }

    func testADrawAlwaysComesFromThePool() {
        var generator = SeededGenerator(seed: 2)

        for _ in 0..<1000 {
            XCTAssertTrue(impacts.sounds.contains(impacts.draw(using: &generator)))
        }
    }

    func testEverySoundInThePoolCanBeDrawn() {
        var generator = SeededGenerator(seed: 3)
        var drawn: Set<Sound> = []

        for _ in 0..<1000 {
            drawn.insert(impacts.draw(using: &generator))
        }

        XCTAssertEqual(drawn, Set(impacts.sounds))
    }

    func testTheDrawIsRoughlyUniform() {
        var generator = SeededGenerator(seed: 4)
        let draws = 4000
        let expected = draws / impacts.sounds.count
        let tolerance = expected / 4
        var counts: [Sound: Int] = [:]

        for _ in 0..<draws {
            counts[impacts.draw(using: &generator), default: 0] += 1
        }

        // A fair draw lands each sound near an equal share. The band is wide
        // enough for the seeded sequence's natural wobble but still fails a
        // selector that favours one sound.
        for sound in impacts.sounds {
            let count = counts[sound] ?? 0
            XCTAssertGreaterThan(count, expected - tolerance, "\(sound) drawn too rarely: \(count)")
            XCTAssertLessThan(count, expected + tolerance, "\(sound) drawn too often: \(count)")
        }
    }

    func testAUniformPoolWeightsEverySoundTheSame() {
        XCTAssertEqual(impacts.weights, Array(repeating: 1, count: impacts.sounds.count))
    }

    func testAWeightedPoolFavoursTheHeavySound() {
        var generator = SeededGenerator(seed: 5)
        let draws = 8000
        var counts: [Sound: Int] = [:]

        for _ in 0..<draws {
            counts[catchAll.draw(using: &generator), default: 0] += 1
        }

        // The shotgun carries four of the seven total weight, so it should land
        // near 4/7 of hits, clearly ahead of each weight-one reaction. The band
        // is wide enough for the seeded sequence's natural wobble.
        let shotgun = counts[.shotgun] ?? 0
        XCTAssertGreaterThan(shotgun, draws / 2)
        XCTAssertLessThan(shotgun, draws * 2 / 3)
        for reaction in catchAll.sounds where reaction != .shotgun {
            let count = counts[reaction] ?? 0
            XCTAssertGreaterThan(count, 0, "\(reaction) was never drawn")
            XCTAssertLessThan(count, shotgun, "\(reaction) should trail the shotgun")
        }
    }

    func testEverySoundInAWeightedPoolCanBeDrawn() {
        var generator = SeededGenerator(seed: 6)
        var drawn: Set<Sound> = []

        for _ in 0..<1000 {
            drawn.insert(catchAll.draw(using: &generator))
        }

        XCTAssertEqual(drawn, Set(catchAll.sounds))
    }
}

/// A small deterministic generator so a draw test does not depend on system
/// entropy: xorshift64*, which is plenty for choosing an index.
private struct SeededGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state ^= state >> 12
        state ^= state << 25
        state ^= state >> 27
        return state &* 2685821657736338717
    }
}
