# 05: Rehearsal produces a testable feed

**What to build:** A manual rehearsal run emits a signed feed and an archive as downloadable artifacts, so the update flow can be exercised without publishing a release.

**Blocked by:** 04 — Release publishes a signed feed.

**Status:** resolved

- [x] Dispatching the rehearsal workflow yields a signed feed and a DMG as artifacts.
- [x] The feed points at the artifact DMG, not at any published release.
- [x] The artifacts are enough to point a test build at an alternate feed and run a real update.

## Comments

- The `build-dmg` job gains a "Generate and sign the update feed" step between
  signature verification and attestation, mirroring the step release.yml gained
  in ticket 04. It stages the DMG and its checksum into `feed/` with the appcast,
  runs `generate_appcast` with `--ed-key-file -` (key piped over stdin, never on
  disk) and `--maximum-deltas 0`, then uploads `feed/appcast.xml` alongside the
  DMG and checksum.
- release.yml omits `--download-url-prefix` only because it wants the release
  URL. The rehearsal does not omit it; it passes `--download-url-prefix ./`.
  Omitting the flag is not enough to get a relative URL: `generate_appcast`
  falls back to the app's own `SUFeedURL` (the published release) as the
  enclosure base, so the feed would point at the release rather than the
  artifact. `./` keeps the enclosure as the bare `AngryKeyboard.dmg`.
- The step fails on a missing `SPARKLE_PRIVATE_KEY`, a missing tool, an empty
  feed, an enclosure that is not the relative `AngryKeyboard.dmg`, or a feed
  with no `sparkle:edSignature`. That last check matters because
  `generate_appcast` exits 0 while skipping signing when the app's
  `SUPublicEDKey` does not match the key.
- `upload-artifact` now lists the three `feed/` files rather than `dist/`, so the
  artifact unpacks to one flat directory. The feed and the DMG it names must be
  siblings for the relative enclosure to resolve when served.
- Sparkle resolves a relative enclosure against the feed URL
  (`SUAppcastItem.m` uses `URLWithString:relativeToURL:` with the appcast URL),
  and a `SUFeedURL` value in user defaults overrides the one in Info.plist
  (`SPUUpdater.m`), which is the documented alternate-feed test path. The recipe
  lives under "Rehearsing an update" in `docs/signing.md`.
- Local verification: built the Release app (`MARKETING_VERSION=9.9.9`,
  `CURRENT_PROJECT_VERSION=424242`), packaged a DMG, and ran the pinned Sparkle
  2.10.0 `generate_appcast` with a throwaway Ed25519 key over a `feed/`
  directory. The feed carried `sparkle:version` 424242,
  `sparkle:shortVersionString` 9.9.9, and a relative enclosure
  `AngryKeyboard.dmg` whose `sparkle:edSignature` both `openssl pkeyutl -verify`
  and Sparkle's `sign_update --verify` accepted. Serving the artifact directory
  over HTTP resolved the enclosure to the DMG and its SHA-256 matched the
  checksum artifact. actionlint v1.7.12 reported only the pre-existing custom
  `xcode-27` runner label, and every `run:` block passes `bash -n`.
