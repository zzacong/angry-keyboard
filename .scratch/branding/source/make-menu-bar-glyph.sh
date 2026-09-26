#!/bin/sh
# Rebuilds the menu bar glyph assets from the source SVGs.
#
#   ./make-menu-bar-glyph.sh
#
# The normal glyph ships as a vector template. The muted glyph ships as 1x/2x
# PNGs because its knockout gap needs a mask, which the asset SVG importer does
# not guarantee to render.
set -eu
here="$(cd "$(dirname "$0")" && pwd)"
root="$(cd "$here/../../.." && pwd)"
out="$root/AngryKeyboard/Assets.xcassets"

cp "$here/menu-bar-glyph.svg" "$out/MenuBarGlyph.imageset/menu-bar-glyph.svg"

mkdir -p "$out/MenuBarGlyphMuted.imageset"
rsvg-convert -w 18 -h 18 "$here/menu-bar-glyph-muted.svg" -o "$out/MenuBarGlyphMuted.imageset/menu-bar-glyph-muted.png"
rsvg-convert -w 36 -h 36 "$here/menu-bar-glyph-muted.svg" -o "$out/MenuBarGlyphMuted.imageset/menu-bar-glyph-muted@2x.png"

echo "rebuilt menu bar glyph assets"
