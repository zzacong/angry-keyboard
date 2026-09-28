# 05: Rehearsal produces a testable feed

**What to build:** A manual rehearsal run emits a signed feed and an archive as downloadable artifacts, so the update flow can be exercised without publishing a release.

**Blocked by:** 04 — Release publishes a signed feed.

**Status:** ready-for-agent

- [ ] Dispatching the rehearsal workflow yields a signed feed and a DMG as artifacts.
- [ ] The feed points at the artifact DMG, not at any published release.
- [ ] The artifacts are enough to point a test build at an alternate feed and run a real update.
