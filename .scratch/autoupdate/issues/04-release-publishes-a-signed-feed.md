# 04: Release publishes a signed feed

**What to build:** Cutting a release also publishes the update feed, so installed apps can discover it. The feed is generated from the packaged build and signed with the CI key; the DMG, its checksum, and the install warning are untouched.

**Blocked by:** 02 — Sparkle signing key and wizard.

**Status:** ready-for-agent

- [ ] A release run produces a feed asset alongside the DMG, and that asset validates against the signing key.
- [ ] The feed names the release's build number and marketing version and points at that release's DMG.
- [ ] The existing DMG, checksum, and install-warning notes are unchanged, as is the published download path the site uses.
- [ ] Re-running the release job for the same tag replaces the feed rather than duplicating it.
