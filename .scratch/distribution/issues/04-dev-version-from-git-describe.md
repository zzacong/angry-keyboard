# 04: Dev version from git describe

**What to build:** The dev app's About panel should show the exact commit it was built from instead of the committed placeholder. Derive the version from the repository's git description at build time, strip the leading `v`, and write it into the built app's version before it is signed. The release build keeps the version the pipeline injects. This applies only to the dev configuration. The committed placeholder becomes `0.1.0`.

**Blocked by:** 01.

**Status:** ready-for-agent

- [ ] The dev app's About panel shows the git description, with a dirty suffix when there are uncommitted changes.
- [ ] A release build is unaffected and still shows the version injected by the pipeline.
- [ ] When the version cannot be derived, the build succeeds and falls back to the committed placeholder.
- [ ] The committed placeholder is `0.1.0`.
