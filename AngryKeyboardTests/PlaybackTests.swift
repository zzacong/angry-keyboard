import Carbon
import CoreGraphics
import XCTest

/// Covers the model behind the overlap switch: how many copies a binding may
/// play at once, and how the two playback modes shape that.
final class PlaybackTests: XCTestCase {
    func testABindingDefaultsToOneVoice() {
        let binding = Binding(key: Key(CGKeyCode(kVK_ANSI_A)), sound: .shotgun)
        XCTAssertEqual(binding.voiceCount, 1)
    }

    func testRetriggerAlwaysUsesOneVoiceHoweverTheBindingIsTuned() {
        let binding = Binding(key: Key(CGKeyCode(kVK_ANSI_A)), sound: .shotgun, voiceCount: 6)
        XCTAssertEqual(binding.effectiveVoiceCount(for: .retrigger), 1)
    }

    func testOverlapUsesTheBindingsOwnVoiceCount() {
        let binding = Binding(key: Key(CGKeyCode(kVK_ANSI_A)), sound: .shotgun, voiceCount: 6)
        XCTAssertEqual(binding.effectiveVoiceCount(for: .overlap), 6)
    }

    func testOverlapNeverUsesFewerThanOneVoice() {
        let binding = Binding(key: Key(CGKeyCode(kVK_ANSI_A)), sound: .shotgun, voiceCount: 0)
        XCTAssertEqual(binding.effectiveVoiceCount(for: .overlap), 1)
    }

    func testTheShippedCatchAllCanOverlapSoTypingCanBeCompared() {
        let catchAll = SoundPack.shipped.bindings.last
        XCTAssertEqual(catchAll?.key, .any)
        XCTAssertEqual(catchAll?.effectiveVoiceCount(for: .retrigger), 1)
        XCTAssertGreaterThan(catchAll?.effectiveVoiceCount(for: .overlap) ?? 0, 1)
    }

    func testEveryShippedBindingCanPlayAtLeastOneVoice() {
        for binding in SoundPack.shipped.bindings {
            XCTAssertGreaterThanOrEqual(binding.voiceCount, 1)
        }
    }

    func testTheArrowPoolIsCappedAtThreeVoices() {
        let arrows = SoundPack.shipped.bindings.filter { $0.pool == SoundPack.arrowImpacts }
        XCTAssertEqual(arrows.count, 4)
        for binding in arrows {
            XCTAssertEqual(binding.effectiveVoiceCount(for: .overlap), 3)
        }
    }
}
