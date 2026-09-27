# 04: Dev version from git describe

**What to build:** The dev app's About panel should show the exact commit it was built from instead of the committed placeholder. Derive the version from the repository's git description at build time, strip the leading `v`, and write it into the built app's version before it is signed. The release build keeps the version the pipeline injects. This applies only to the dev configuration. The committed placeholder becomes `0.1.0`.

**Blocked by:** 01.

**Status:** resolved

- [x] The dev app's About panel shows the git description, with a dirty suffix when there are uncommitted changes.
- [x] A release build is unaffected and still shows the version injected by the pipeline.
- [x] When the version cannot be derived, the build succeeds and falls back to the committed placeholder.
- [x] The committed placeholder is `0.1.0`.

## Comments

Implemented. `Scripts/set-dev-version.sh` is the Debug-only phase and
`project.pbxproj` adds it as the app target's final build phase, after
`Resources`, so it runs once the Info.plist is processed and before code signing.
The app target sets `ENABLE_USER_SCRIPT_SANDBOXING = NO` so the script can read
git and write the built plist, and the committed `MARKETING_VERSION` is now
`0.1.0`.

Verified:

- A Debug build stamps `AngryKeyboardDev.app`'s `CFBundleShortVersionString`
  with the repository's git description. There are no tags yet, so that is the
  short hash, with `-dirty` while tracked files are modified
  (`89e9a0a-dirty`). The About panel reads this key from the bundle.
- A Release build keeps `0.1.0`. The script exits when `CONFIGURATION` is not
  `Debug`, so the version the pipeline injects from the tag is untouched.
- When the version cannot be derived, the script exits 0 and the placeholder
  stands. Confirmed by pointing `SRCROOT` at a directory outside git.
- `codesign --verify` passes on the Debug build, so the signature covers the
  patched plist, and all 44 tests pass.
