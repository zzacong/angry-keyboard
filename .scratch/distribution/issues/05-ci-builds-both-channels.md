# 05: CI builds both channels

**What to build:** Every push and pull request should prove both channels build and the tests pass. The pipeline runs the unit tests and builds the dev and release configurations on the pinned macOS runner.

**Blocked by:** 01.

**Status:** ready-for-agent

- [ ] A push and a pull request both trigger the pipeline.
- [ ] The unit tests run.
- [ ] The dev and release configurations each build.
- [ ] A failure in either channel fails the run.
- [ ] The runner provides the toolchain the project requires.
