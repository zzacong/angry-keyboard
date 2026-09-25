import XCTest

/// Covers the leading-silence scan: where a decoded sound really begins, and
/// how it behaves at the edges (all silence, a stray blip, one busy channel).
final class SoundOnsetTests: XCTestCase {
    private let sampleRate = 48000.0
    private let window = 96  // SoundOnset.windowSeconds at 48 kHz

    func testASoundThatStartsAtFrameZeroHasNoOnset() {
        let samples = Array(repeating: Float(0.5), count: 480)
        XCTAssertEqual(SoundOnset.frame(of: [samples], sampleRate: sampleRate), 0)
    }

    func testAllSilenceHasNoOnsetSoTheCallerLeavesItUntouched() {
        let samples = Array(repeating: Float(0), count: 4800)
        XCTAssertEqual(SoundOnset.frame(of: [samples], sampleRate: sampleRate), 0)
    }

    func testLeadingSilenceIsSkipped() {
        let silence = Array(repeating: Float(0), count: 480)
        let tone = Array(repeating: Float(0.5), count: 4800)
        XCTAssertEqual(SoundOnset.frame(of: [silence + tone], sampleRate: sampleRate), 480)
    }

    func testOnsetLandsWithinOneWindowOfTheTrueStart() {
        let trueStart = 336  // 7 ms
        let samples = Array(repeating: Float(0), count: trueStart)
            + Array(repeating: Float(0.5), count: 4800)
        let onset = SoundOnset.frame(of: [samples], sampleRate: sampleRate)
        XCTAssertGreaterThan(onset, trueStart - window)
        XCTAssertLessThanOrEqual(onset, trueStart)
    }

    func testAStrayBlipBelowTheThresholdDoesNotSetTheOnset() {
        var samples = Array(repeating: Float(0), count: 4800)
        samples[10] = 0.0005  // below -60 dBFS
        for frame in 1920..<samples.count { samples[frame] = 0.5 }
        XCTAssertEqual(SoundOnset.frame(of: [samples], sampleRate: sampleRate), 1920)
    }

    func testAnOnsetInOneChannelIsEnough() {
        let left = Array(repeating: Float(0), count: 960)
            + Array(repeating: Float(0.5), count: 1920)
        let right = Array(repeating: Float(0), count: 2880)
        XCTAssertEqual(SoundOnset.frame(of: [left, right], sampleRate: sampleRate), 960)
    }

    func testUnequalChannelLengthsDoNotCrash() {
        XCTAssertEqual(SoundOnset.frame(of: [[0.5, 0.5], [0.5]], sampleRate: sampleRate), 0)
    }

    func testNoChannelsHasNoOnset() {
        XCTAssertEqual(SoundOnset.frame(of: [], sampleRate: sampleRate), 0)
    }
}
