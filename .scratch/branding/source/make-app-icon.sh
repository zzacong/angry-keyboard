#!/bin/sh
# Rebuilds an appiconset from an app-icon master.
#
#   ./make-app-icon.sh app-icon-blackout.svg              # rewrite AppIcon
#   ./make-app-icon.sh app-icon-kraft-kit.svg AppIconDev  # write the dev set
#
# The optional second argument is the appiconset name; it defaults to AppIcon.
# The set's Contents.json is committed and left alone, so create it when adding
# a new set.
#
# Needs rsvg-convert and ImageMagick (magick) on PATH. Regenerate the masters
# first with `python3 gen_icons.py` after editing them.
set -eu
src="$1"
set_name="${2:-AppIcon}"
[ -f "$src" ] || { echo "no such master: $src" >&2; exit 1; }
root="$(cd "$(dirname "$0")/../../.." && pwd)"
set_dir="$root/AngryKeyboard/Assets.xcassets/$set_name.appiconset"
[ -d "$set_dir" ] || { echo "no such appiconset: $set_dir" >&2; exit 1; }
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

rsvg-convert -w 1024 -h 1024 "$src" -o "$tmp/master.png"
gen() { magick "$tmp/master.png" -filter Lanczos -resize "${1}x${1}" "$set_dir/$2"; }
gen 16   icon_16x16.png
gen 32   icon_16x16@2x.png
gen 32   icon_32x32.png
gen 64   icon_32x32@2x.png
gen 128  icon_128x128.png
gen 256  icon_128x128@2x.png
gen 256  icon_256x256.png
gen 512  icon_256x256@2x.png
gen 512  icon_512x512.png
gen 1024 icon_512x512@2x.png
echo "rebuilt $set_name.appiconset from $src"
