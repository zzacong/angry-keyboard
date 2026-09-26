# 07: Release workflow publishes a signed DMG

**What to build:** When Release Please creates a release, the pipeline should build the release app, sign it with the production certificate from the keychain, and attach a DMG to the GitHub release. The DMG holds the app and an Applications shortcut so a user can drag it in, plus a short text file with the install warning. The release also carries a checksum, a build provenance attestation, and the same warning appended to the notes.

The build must run in the same workflow as the Release Please job. A release created by the pipeline token does not trigger another workflow, so a separate release-triggered workflow would never run.

**Blocked by:** 01, 03, 06.

**Status:** ready-for-agent

- [ ] Creating a release produces a GitHub release with a DMG named for the app and a checksum file.
- [ ] The app inside the DMG is signed with the production certificate, and its signature verifies.
- [ ] The DMG contains the app, an Applications shortcut, and the install warning text.
- [ ] The release notes include the install warning.
- [ ] The DMG carries a build provenance attestation.
- [ ] The workflow does not rely on a personal access token.
