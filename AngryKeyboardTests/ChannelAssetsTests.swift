import XCTest

final class ChannelAssetsTests: XCTestCase {
    func testAppIconComesFromTheBundleIconName() {
        XCTAssertEqual(
            ChannelAssets.appIconName(in: ["CFBundleIconName": "AppIconDev"]),
            "AppIconDev"
        )
    }

    func testAppIconFallsBackToTheProductionName() {
        XCTAssertEqual(ChannelAssets.appIconName(in: [:]), "AppIcon")
    }

    func testMenuBarGlyphComesFromTheBundleKeys() {
        let info: [String: Any] = [
            "AKMenuBarGlyph": "MenuBarGlyphDev",
            "AKMenuBarGlyphMuted": "MenuBarGlyphDevMuted",
        ]
        XCTAssertEqual(ChannelAssets.menuBarGlyphName(in: info, muted: false), "MenuBarGlyphDev")
        XCTAssertEqual(ChannelAssets.menuBarGlyphName(in: info, muted: true), "MenuBarGlyphDevMuted")
    }

    func testMenuBarGlyphFallsBackToTheProductionNames() {
        XCTAssertEqual(ChannelAssets.menuBarGlyphName(in: [:], muted: false), "MenuBarGlyph")
        XCTAssertEqual(ChannelAssets.menuBarGlyphName(in: [:], muted: true), "MenuBarGlyphMuted")
    }
}
