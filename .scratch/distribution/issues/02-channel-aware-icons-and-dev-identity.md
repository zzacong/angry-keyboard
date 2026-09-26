# 02: Channel-aware icons and the blueprint dev identity

**What to build:** The dev app should be visually distinct from production at the places it is seen. The app icon drawn in the About panel, the permission alert, and Finder should follow the channel, which means the app reads its icon name from the bundle instead of a fixed asset. The menu bar glyph should follow the channel too, with both channels sharing the production glyph until a dev one exists.

Then run a design pass for the dev channel's blueprint identity: a white-and-blue app icon and a menu bar glyph that differs from production by shape. The status item is a template image that macOS recolors, so the glyph cannot carry the palette; only its shape can. Produce several variants as prototypes in the branding folder, present them, and wait for a choice before generating the chosen app icon and repointing the glyph keys.

**Blocked by:** 01.

**Status:** needs-info

- [x] The dev app shows its own icon in Finder, the About panel, and the permission alert; production keeps the shipped icon.
- [x] The menu bar glyph name comes from the bundle, and production's glyph is unchanged.
- [x] Several blueprint app icon variants and at least one shape-distinct dev menu bar glyph exist as prototypes.
- [ ] Zac chooses a variant before the design is finalized.
- [ ] The chosen app icon ships in the dev app's asset set, and the dev menu bar glyph differs from production by shape.
- [x] Nothing about production's icon or glyph changes.

## Comments

Channel plumbing is in place.

- `AppDelegate.applicationIcon` reads `CFBundleIconName`, and
  `refreshStatusIcon` reads `AKMenuBarGlyph` / `AKMenuBarGlyphMuted`, both through
  `AngryKeyboardCore/ChannelAssets.swift`. Four tests pin the production
  fallbacks.
- Custom `INFOPLIST_KEY_` keys are dropped by Xcode 27, as ticket 01 found. The
  two glyph keys now come from `Config/Info.plist`, merged with the generated
  plist, with `$(AK_MENU_BAR_GLYPH)` values set in the xcconfig files. The spec
  snippets are corrected.
- `AppIconDev` is generated from the Kraft Kit master and Debug points at it.
  Verified in built plists: Debug has `CFBundleIconName = AppIconDev` and Release
  has `AppIcon`, both with the glyph keys pointing at the production names.
  `assetutil` confirms each `Assets.car` carries the matching app icon.
- The blueprint proof sheet is at
  `.scratch/branding/icon-prototype-dev-blueprint.html`: five app icon variants
  (A-E) and five glyphs (1-5), each glyph shown in light, dark, and muted. The
  1024 masters and glyph SVGs sit in `.scratch/branding/source`.

Waiting on Zac for the pick. Reply with an app icon letter and a glyph number,
for example "icon C, glyph 3". Then the chosen master rasterizes into
`AppIconDev.appiconset` and the two `AK_MENU_BAR_GLYPH` lines in
`Config/Debug.xcconfig` are repointed. Production keys and artwork do not change.

Note: Xcode is open on the project and rewrote `project.pbxproj` mid-session
(product reference renamed to `AngryKeyboardDev.app`, groups reordered). That
churn was reverted before the commit.
