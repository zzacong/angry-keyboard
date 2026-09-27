#!/bin/sh
#
# Stamps the dev build's version from the repository's git description, so the
# About panel shows the exact commit instead of the committed placeholder. The
# Release channel is untouched: CI injects its version from the release tag.
#
# Run as an app-target build phase, after the Info.plist is processed and before
# the app is signed. Exits 0 without patching when it cannot derive a version,
# leaving the committed placeholder in place.

[ "$CONFIGURATION" = "Debug" ] || exit 0

cd "$SRCROOT" || exit 0
VERSION=$(git describe --tags --dirty --always 2>/dev/null | sed 's/^v//')
[ -n "$VERSION" ] || exit 0

/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $VERSION" \
  "$TARGET_BUILD_DIR/$INFOPLIST_PATH"
