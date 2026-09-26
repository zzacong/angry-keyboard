# 06: Release Please drives the version and changelog

**What to build:** Merging work to main should open a release pull request that updates the changelog and, when merged, creates the version tag. Bumps follow conventional commits: fixes and features bump the patch, a breaking change bumps the minor, and the major stays at zero until Zac asks for it. The first release is 0.1.0.

Do not merge the first release pull request until the release workflow exists, or the tag will have no DMG attached.

**Blocked by:** None (can start immediately).

**Status:** ready-for-agent

- [ ] A merge to main opens or updates a release pull request with a changelog built from the conventional commits.
- [ ] Merging that pull request creates the tag and the release notes.
- [ ] A fix or a feature bumps the patch; a breaking change bumps the minor; the major never moves on its own.
- [ ] Doc-only and chore-only stretches open no release.
- [ ] The first release pull request produces 0.1.0.
