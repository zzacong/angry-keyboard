import XCTest

final class UpdatePolicyTests: XCTestCase {
    func testUpdatesAreEnabledWhenTheBundleOptsIn() {
        XCTAssertTrue(UpdatePolicy.checksForUpdates(in: ["AKEnableUpdates": true]))
    }

    func testUpdatesAreDisabledWhenTheBundleOptsOut() {
        XCTAssertFalse(UpdatePolicy.checksForUpdates(in: ["AKEnableUpdates": false]))
    }

    func testUpdatesAreDisabledWhenTheBundleSaysNothing() {
        XCTAssertFalse(UpdatePolicy.checksForUpdates(in: [:]))
    }

    func testUpdatesFollowTheSubstitutedPlistString() {
        XCTAssertTrue(UpdatePolicy.checksForUpdates(in: ["AKEnableUpdates": "YES"]))
        XCTAssertFalse(UpdatePolicy.checksForUpdates(in: ["AKEnableUpdates": "NO"]))
    }
}
