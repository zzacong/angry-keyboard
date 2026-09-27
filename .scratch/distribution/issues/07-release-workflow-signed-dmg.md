# 07: Release workflow publishes a signed DMG

**What to build:** When Release Please creates a release, the pipeline should build the release app, sign it with the production certificate from the keychain, and attach a DMG to the GitHub release. The DMG holds the app and an Applications shortcut so a user can drag it in, plus a short text file with the install warning. The release also carries a checksum, a build provenance attestation, and the same warning appended to the notes.

The build must run in the same workflow as the Release Please job. A release created by the pipeline token does not trigger another workflow, so a separate release-triggered workflow would never run.

**Blocked by:** 01, 03, 06.

**Status:** resolved

- [x] Creating a release produces a GitHub release with a DMG named for the app and a checksum file.
- [x] The app inside the DMG is signed with the production certificate, and its signature verifies.
- [x] The DMG contains the app, an Applications shortcut, and the install warning text.
- [x] The release notes include the install warning.
- [x] The DMG carries a build provenance attestation.
- [x] The workflow does not rely on a personal access token.

## Comments

Implemented the `build` job in `.github/workflows/release.yml`. It runs after
`release-please` only when a release was created, checks out the tag, imports
the production certificate from `CERTIFICATE_P12_BASE64` into a temporary
keychain, builds Release with `MARKETING_VERSION` from the tag and
`CURRENT_PROJECT_VERSION` from the run number, signs with
`vars.SIGNING_IDENTITY`, packages `AngryKeyboard.dmg` and its `.sha256`,
verifies both signatures, attests provenance, appends
`packaging/RELEASE-NOTES.md` to the notes, uploads the two assets, and deletes
the keychain in an `if: always()` step.

Both jobs share one workflow on purpose, since a release created with the
built-in token does not trigger another workflow.

Verified locally with Xcode 27.0 (27A266a), using the same commands the job
runs, against `-derivedDataPath build/release-verify`:

- The Release build signs with `Authority=AngryKeyboard Production`,
  `CFBundleShortVersionString=0.1.0`, `CFBundleVersion=1`, and
  `codesign --verify --deep --strict` passes.
- `hdiutil` produces `AngryKeyboard.dmg` holding `AngryKeyboard.app`, an
  `Applications` symlink, and `Read Me.txt`; the checksum writes to
  `AngryKeyboard.dmg.sha256`.
- Mounting the DMG and verifying the app inside passes, with the same
  production authority.
- The full test suite passes (44 tests).

Versions pinned after checking their latest releases:
`googleapis/release-please-action@v5`, `actions/checkout@v7`,
`actions/attest-build-provenance@v4`.

The GitHub-side steps (release creation, attestation, upload, notes edit) can
only run on a real tag. The first release cut by Release Please is their
end-to-end proof; that stays an open item on the spec and in ticket 09.

