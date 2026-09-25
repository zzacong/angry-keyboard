import Carbon
import CoreGraphics
import XCTest

final class ResolverTests: XCTestCase {
    private let pack = SoundPack.shipped

    // MARK: - The shipped bindings

    func testEnterPlaysTheExplosion() {
        XCTAssertEqual(sound(for: kVK_Return), .explodeRock)
    }

    func testEscapePlaysTheWhoosh() {
        XCTAssertEqual(sound(for: kVK_Escape), .rocketWhoosh)
    }

    func testBackspacePlaysTheBlast() {
        XCTAssertEqual(sound(for: kVK_Delete), .shotgunBlast)
    }

    func testSpacebarPlaysTheCocking() {
        XCTAssertEqual(sound(for: kVK_Space), .shotgunCocking)
    }

    // MARK: - The catch-all

    func testLettersPlayTheShotgun() {
        XCTAssertEqual(sound(for: kVK_ANSI_A), .shotgun)
    }

    func testNumbersPlayTheShotgun() {
        XCTAssertEqual(sound(for: kVK_ANSI_1), .shotgun)
    }

    func testArrowsPlayTheShotgun() {
        XCTAssertEqual(sound(for: kVK_LeftArrow), .shotgun)
    }

    func testFunctionKeysPlayTheShotgun() {
        XCTAssertEqual(sound(for: kVK_F1), .shotgun)
    }

    func testCatchAllIsTheOnlyAnyBindingAndComesLast() {
        XCTAssertEqual(pack.bindings.filter { $0.key == .any }.count, 1)
        XCTAssertEqual(pack.bindings.last?.key, .any)
        XCTAssertEqual(pack.bindings.last?.sound, .shotgun)
    }

    // MARK: - Modifiers

    func testHeldModifiersDoNotSuppressABoundKey() {
        XCTAssertEqual(sound(for: kVK_Return, modifiers: [.maskCommand, .maskShift]), .explodeRock)
    }

    func testABindingThatRequiresAModifierMatchesOnlyWithIt() {
        let pack = SoundPack(
            name: "Test",
            bindings: [
                Binding(
                    key: .keyCode(CGKeyCode(kVK_ANSI_A), modifiers: .maskCommand),
                    sound: .explodeRock
                )
            ],
            catchAll: .shotgun
        )

        XCTAssertEqual(
            pack.binding(for: Keystroke(keyCode: CGKeyCode(kVK_ANSI_A), modifiers: .maskCommand))?.sound,
            .explodeRock
        )
        XCTAssertEqual(
            pack.binding(for: Keystroke(keyCode: CGKeyCode(kVK_ANSI_A), modifiers: []))?.sound,
            .shotgun
        )
    }

    // MARK: - Keystrokes that map to nothing

    func testEveryModifierKeyPlaysNothing() {
        let modifierKeys = [
            kVK_Command, kVK_RightCommand,
            kVK_Shift, kVK_RightShift,
            kVK_Option, kVK_RightOption,
            kVK_Control, kVK_RightControl,
            kVK_CapsLock, kVK_Function,
        ]

        for keyCode in modifierKeys {
            let keystroke = Keystroke(keyCode: CGKeyCode(keyCode), modifiers: [])
            XCTAssertNil(pack.binding(for: keystroke), "key code \(keyCode) should play nothing")
        }
    }

    // MARK: - Helpers

    private func sound(for keyCode: Int, modifiers: CGEventFlags = []) -> Sound? {
        pack.binding(for: Keystroke(keyCode: CGKeyCode(keyCode), modifiers: modifiers))?.sound
    }
}
