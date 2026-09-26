#!/bin/sh
# Rebuilds a menu bar glyph pair from the source SVGs.
#
#   ./make-menu-bar-glyph.sh                                  # production pair
#   ./make-menu-bar-glyph.sh MenuBarGlyphDev menu-bar-glyph-dev-3
#
# The first argument is the asset base name, the second the source stem. Both
# default to the production pair, MenuBarGlyph and menu-bar-glyph.
#
# The normal glyph ships as a vector template. The muted glyph ships as 1x/2x
# PNGs because its knockout gap needs a mask, which the asset SVG importer does
# not guarantee to render. Create the imageset's Contents.json before first use.
set -eu
here="$(cd "$(dirname "$0")" && pwd)"
root="$(cd "$here/../../.." && pwd)"
out="$root/AngryKeyboard/Assets.xcassets"
base="${1:-MenuBarGlyph}"
stem="${2:-menu-bar-glyph}"

cp "$here/$stem.svg" "$out/$base.imageset/$stem.svg"

mkdir -p "$out/${base}Muted.imageset"
rsvg-convert -w 18 -h 18 "$here/$stem-muted.svg" -o "$out/${base}Muted.imageset/$stem-muted.png"
rsvg-convert -w 36 -h 36 "$here/$stem-muted.svg" -o "$out/${base}Muted.imageset/$stem-muted@2x.png"

echo "rebuilt $base glyph assets"
