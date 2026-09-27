# 06: Release Please drives the version and changelog

**What to build:** Merging work to main should open a release pull request that updates the changelog and, when merged, creates the version tag. Bumps follow conventional commits: fixes and features bump the patch, a breaking change bumps the minor, and the major stays at zero until Zac asks for it. The first release is 0.1.0.

Do not merge the first release pull request until the release workflow exists, or the tag will have no DMG attached.

**Blocked by:** None (can start immediately).

**Status:** resolved

- [x] A merge to main opens or updates a release pull request with a changelog built from the conventional commits.
- [x] Merging that pull request creates the tag and the release notes.
- [x] A fix or a feature bumps the patch; a breaking change bumps the minor; the major never moves on its own.
- [x] Doc-only and chore-only stretches open no release.
- [x] The first release pull request produces 0.1.0.

## Comments

Implemented. `release-please-config.json` sets the `simple` release type with both
pre-major flags, and `.release-please-manifest.json` starts the root package at
`0.0.0`. `version.txt` holds `0.0.0` because the simple strategy updates that file
in place and does not create it. `.github/workflows/release.yml` runs
`googleapis/release-please-action@v5` on push to `main` and exposes `released`
and `tag` for the build job that ticket 07 adds to the same workflow.

The first release is forced to `0.1.0` by a `Release-As: 0.1.0` footer on the
implementation commit. Without it, release-please ignores the pre-major flags at
`0.0.0` and picks `1.0.0`.

Verified against release-please 17.11.2, which satisfies the `^17.6.0` range the
v5 action depends on. Parsing this repository's commits produces a `RELEASE AS`
note of `0.1.0`, and the versioning strategy returns `0.1.0` from `0.0.0`. On
`0.1.0`, `feat`, `fix`, `perf`, and `revert` bump the patch, `feat!` bumps the
minor to `0.2.0`, and no case reaches `1.0.0`. A changelog built only from
`docs`, `chore`, `build`, `ci`, `test`, `style`, and `refactor` commits is the
version header alone, so release-please skips the pull request. The JSON and
YAML parse.

Three deviations from the spec's snippets:

- The action is `@v5`, not `@v4`. `v5.0.0` is the latest release, and its only
  breaking change is the move to node24. The root outputs this workflow reads,
  `release_created` and `tag_name`, are unchanged.
- The job grants `issues: write` as well as `contents` and `pull-requests`.
  Release Please labels the pull request through the issues API.
- The workflow has a `concurrency` group, matching `ci.yml`, so an earlier run
  is cancelled when a newer push to `main` arrives.

One step lives outside the repo. The workflow needs "Allow GitHub Actions to
create and approve pull requests" enabled under Settings > Actions > General,
or the release pull request will not open.

Do not merge the first release pull request until ticket 07 lands. Until then
the tag would point at a release with no DMG attached.
