# 06: Docs and credits

**What to build:** The docs tell the truth about updates. Sparkle is credited, the signing key's custody is written down beside the certificate's, and the README stops claiming there is no updater and gets uninstall steps that match what the app now leaves behind.

**Blocked by:** 03 — App checks for updates when enabled; 04 — Release publishes a signed feed.

**Status:** ready-for-agent

- [ ] Sparkle's license and attribution appear in the credits.
- [ ] The signing guide documents the update key next to the certificate: where the CI secret lives and how to restore it from backup.
- [ ] The README's "no updater" claim and its uninstall steps are corrected to match what Sparkle actually leaves behind, verified against a real install.
- [ ] The README tells users that, after the first manual install, updates arrive in the app.
