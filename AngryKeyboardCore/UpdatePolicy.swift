import Foundation

/// Whether the running channel checks for updates, read from the app's
/// Info.plist.
///
/// The two channels share one Info.plist, so the switch is the channel-
/// substituted key `AKEnableUpdates`: production substitutes `YES`, dev `NO`.
/// The default is `false`, so a bundle that says nothing stays quiet and a
/// missing key fails safe.
nonisolated enum UpdatePolicy {
    static let enableUpdatesKey = "AKEnableUpdates"

    /// Whether the bundle described by `info` should check for updates.
    ///
    /// The value is a plist string (`"YES"`/`"NO"`) in the shipped bundle, but
    /// a plist boolean is accepted too so the key can be set natively.
    static func checksForUpdates(in info: [String: Any]) -> Bool {
        switch info[enableUpdatesKey] {
        case let enabled as Bool: return enabled
        case let enabled as String: return (enabled as NSString).boolValue
        default: return false
        }
    }
}
