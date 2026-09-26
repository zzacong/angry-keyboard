# Branding decisions

Notes for the app icon and the menu bar glyph. The design explorations are the
`icon-prototype*.html` files next to this one.

## Menu bar glyph

Pinned to batch 1 glyph 5, "Keyboard + Burst". It ships as the template image
`MenuBarGlyph` in `AngryKeyboard/Assets.xcassets`, drawn at 18pt by
`AppDelegate.refreshStatusIcon`.

The muted state is the same glyph struck through, shipped as the template image
`MenuBarGlyphMuted`. Regenerate both with `source/make-menu-bar-glyph.sh`.

## App icon

The shipped default is batch 3 candidate M, "Blackout": near-black tile, red
ring and keycap, cream angry face, bone smoke.

Two alternates are kept so the icon can be switched later:

- L, "Kraft Kit": kraft tile, red keycap with a moulded base, ink face.
- K, "Flat Red": signal-red tile, cream keycap, ink face, ink smoke.

All three masters sit on Apple's macOS icon grid: a 1024 canvas, an 824 art box
centered at (100,100), corner radius 185.4, continuous corners. macOS does not
mask app icons, so the squircle is part of the artwork.

## Dev blueprint (pending)

The dev channel needs its own identity: a white-and-blue app icon and a menu bar
glyph that differs from production by shape, because the status item is a
template image and macOS recolors it. `icon-prototype-dev-blueprint.html` holds
five app icon variants (A-E) and five glyphs (1-5) in light, dark, and muted. The
masters are `source/app-icon-blueprint-{a..e}.svg`, built by
`source/gen_dev_blueprint.py` onto the same icon grid, and the glyphs are
`source/menu-bar-glyph-dev-{1..5}.svg`. No pick has been made yet.

## Regenerate or switch

    cd .scratch/branding/source
    python3 gen_icons.py                        # rewrite the masters
    ./make-app-icon.sh app-icon-kraft-kit.svg   # ship L instead of M

Files:

- `source/app-icon-blackout.svg` (M, shipped)
- `source/app-icon-kraft-kit.svg` (L, alternate)
- `source/app-icon-flat-red.svg` (K, alternate)
- `source/gen_icons.py` writes the masters
- `source/make-app-icon.sh` rasterizes one master into `AppIcon.appiconset`
- `source/menu-bar-glyph.svg` and `source/menu-bar-glyph-muted.svg`
- `source/make-menu-bar-glyph.sh` rasterizes both into the asset catalog
