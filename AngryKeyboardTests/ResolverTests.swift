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

    func testLettersDrawFromTheCatchAllPool() {
        XCTAssertEqual(pool(for: kVK_ANSI_A), SoundPack.catchAllPool)
    }

    func testNumbersDrawFromTheCatchAllPool() {
        XCTAssertEqual(pool(for: kVK_ANSI_1), SoundPack.catchAllPool)
    }

    func testArrowsPlayTheImpactPool() {
        for keyCode in [kVK_UpArrow, kVK_DownArrow, kVK_LeftArrow, kVK_RightArrow] {
            XCTAssertEqual(
                pool(for: keyCode),
                SoundPack.arrowImpacts,
                "key code \(keyCode) should draw from the impact pool"
            )
        }
    }

    func testFunctionKeysDrawFromTheCatchAllPool() {
        XCTAssertEqual(pool(for: kVK_F1), SoundPack.catchAllPool)
    }

    func testCatchAllIsTheOnlyAnyBindingAndComesLast() {
        XCTAssertEqual(pack.bindings.filter { $0.key == .any }.count, 1)
        XCTAssertEqual(pack.bindings.last?.key, .any)
        XCTAssertEqual(pack.bindings.last?.pool, SoundPack.catchAllPool)
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
            catchAll: SoundPool(.shotgun)
        )

        XCTAssertEqual(
            pack.binding(for: Keystroke(keyCode: CGKeyCode(kVK_ANSI_A), modifiers: .maskCommand))?.pool,
            SoundPool(.explodeRock)
        )
        XCTAssertEqual(
            pack.binding(for: Keystroke(keyCode: CGKeyCode(kVK_ANSI_A), modifiers: []))?.pool,
            SoundPool(.shotgun)
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

    private func pool(for keyCode: Int, modifiers: CGEventFlags = []) -> SoundPool? {
        pack.binding(for: Keystroke(keyCode: CGKeyCode(keyCode), modifiers: modifiers))?.pool
    }

    /// The single sound a deterministic binding plays, or `nil` for a binding
    /// that draws from a pool or matches nothing.
    private func sound(for keyCode: Int, modifiers: CGEventFlags = []) -> Sound? {
        guard let pool = pool(for: keyCode, modifiers: modifiers), pool.sounds.count == 1 else {
            return nil
        }
        return pool.sounds.first
    }
}
