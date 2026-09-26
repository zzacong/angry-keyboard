/// Names of the channel-specific image assets, read from the app's Info.plist.
///
/// The two channels ship different app icons and menu bar glyphs, and the bundle
/// is the only thing that differs at runtime. Production sets the standard
/// `CFBundleIconName` and omits the custom glyph keys; dev may override either.
/// The fallbacks are the production names, so a bundle without the keys keeps
/// the shipped artwork.
nonisolated enum ChannelAssets {
    static let defaultAppIcon = "AppIcon"
    static let defaultMenuBarGlyph = "MenuBarGlyph"
    static let defaultMenuBarGlyphMuted = "MenuBarGlyphMuted"

    /// The asset catalog name of the app icon, from `CFBundleIconName`.
    static func appIconName(in info: [String: Any]) -> String {
        info["CFBundleIconName"] as? String ?? defaultAppIcon
    }

    /// The asset catalog name of the menu bar glyph for the current mute state,
    /// from `AKMenuBarGlyph` or `AKMenuBarGlyphMuted`.
    static func menuBarGlyphName(in info: [String: Any], muted: Bool) -> String {
        let key = muted ? "AKMenuBarGlyphMuted" : "AKMenuBarGlyph"
        let fallback = muted ? defaultMenuBarGlyphMuted : defaultMenuBarGlyph
        return info[key] as? String ?? fallback
    }
}
