# 04: Release publishes a signed feed

**What to build:** Cutting a release also publishes the update feed, so installed apps can discover it. The feed is generated from the packaged build and signed with the CI key; the DMG, its checksum, and the install warning are untouched.

**Blocked by:** 02 — Sparkle signing key and wizard.

**Status:** resolved

- [x] A release run produces a feed asset alongside the DMG, and that asset validates against the signing key.
- [x] The feed names the release's build number and marketing version and points at that release's DMG.
- [x] The existing DMG, checksum, and install-warning notes are unchanged, as is the published download path the site uses.
- [x] Re-running the release job for the same tag replaces the feed rather than duplicating it.

## Comments

- The `build` job gains a "Generate and sign the update feed" step between
  signature verification and attestation. It stages the DMG in `feed/` and runs
  `generate_appcast` with `--ed-key-file -` (key piped over stdin, never on
  disk), `--download-url-prefix`, and `--maximum-deltas 0`, then uploads
  `feed/appcast.xml` with `--clobber`.
- It prefers `build/SourcePackages/artifacts/sparkle/Sparkle/bin/generate_appcast`
  and falls back to the pinned `Sparkle-2.10.0.tar.xz`, so the step works before
  and after ticket 03 lands the Swift package.
- The step fails on a missing `SPARKLE_PRIVATE_KEY`, a missing tool, an empty
  feed, a feed that does not point at `AngryKeyboard.dmg`, or a feed with no
  `sparkle:edSignature`. That last check matters because `generate_appcast`
  exits 0 while skipping signing when the app's `SUPublicEDKey` does not match
  the key; a mismatched secret would otherwise ship an unverifiable feed.
- Local verification: built the Release app, packaged a DMG, and ran
  `generate_appcast` with a throwaway Ed25519 key. The feed carried
  `sparkle:version` `424242`, `sparkle:shortVersionString` `9.9.9`, an enclosure
  at `.../releases/download/v9.9.9/AngryKeyboard.dmg` whose length and
  `sparkle:edSignature` verified with `openssl pkeyutl`. Re-running kept one
  `<item>` and one `appcast.xml`. A mismatched key produced an unsigned feed
  that the new guard rejects.
