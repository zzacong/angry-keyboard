import XCTest

/// Covers the persisted settings: what a fresh install starts at, and that both
/// values come back after a relaunch. Each test runs against its own suite, so
/// nothing here reads or writes the real app's defaults.
final class SettingsTests: XCTestCase {
    private var suiteName: String!
    private var defaults: UserDefaults!
    private var settings: Settings!

    override func setUp() {
        super.setUp()
        suiteName = "AngryKeyboardTests.settings.\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName)
        settings = Settings(defaults: defaults)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
        super.tearDown()
    }

    func testAFreshInstallStartsAtSixtyPercent() {
        XCTAssertEqual(settings.volume, 0.6)
    }

    func testAFreshInstallIsNotMuted() {
        XCTAssertFalse(settings.isMuted)
    }

    func testVolumeSurvivesARelaunch() {
        settings.volume = 0.25

        XCTAssertEqual(Settings(defaults: defaults).volume, 0.25)
    }

    func testMuteSurvivesARelaunch() {
        settings.isMuted = true

        XCTAssertTrue(Settings(defaults: defaults).isMuted)
    }

    func testZeroIsAStoredVolumeNotAMissingOne() {
        settings.volume = 0

        XCTAssertEqual(settings.volume, 0)
        XCTAssertEqual(Settings(defaults: defaults).volume, 0)
    }

    func testVolumeIsClampedToTheValidRange() {
        settings.volume = 4
        XCTAssertEqual(settings.volume, 1)

        settings.volume = -1
        XCTAssertEqual(settings.volume, 0)
    }
}
