# 02: Channel-aware icons and the blueprint dev identity

**What to build:** The dev app should be visually distinct from production at the places it is seen. The app icon drawn in the About panel, the permission alert, and Finder should follow the channel, which means the app reads its icon name from the bundle instead of a fixed asset. The menu bar glyph should follow the channel too, with both channels sharing the production glyph until a dev one exists.

Then run a design pass for the dev channel's blueprint identity: a white-and-blue app icon and a menu bar glyph that differs from production by shape. The status item is a template image that macOS recolors, so the glyph cannot carry the palette; only its shape can. Produce several variants as prototypes in the branding folder, present them, and wait for a choice before generating the chosen app icon and repointing the glyph keys.

**Blocked by:** 01.

**Status:** ready-for-agent

- [ ] The dev app shows its own icon in Finder, the About panel, and the permission alert; production keeps the shipped icon.
- [ ] The menu bar glyph name comes from the bundle, and production's glyph is unchanged.
- [ ] Several blueprint app icon variants and at least one shape-distinct dev menu bar glyph exist as prototypes.
- [ ] Zac chooses a variant before the design is finalized.
- [ ] The chosen app icon ships in the dev app's asset set, and the dev menu bar glyph differs from production by shape.
- [ ] Nothing about production's icon or glyph changes.
