# 05: CI builds both channels

**What to build:** Every push and pull request should prove both channels build and the tests pass. The pipeline runs the unit tests and builds the dev and release configurations on the pinned macOS runner.

**Blocked by:** 01.

**Status:** resolved

- [x] A push and a pull request both trigger the pipeline.
- [x] The unit tests run.
- [x] The dev and release configurations each build.
- [x] A failure in either channel fails the run.
- [x] The runner provides the toolchain the project requires.

## Comments

Implemented `.github/workflows/ci.yml`. It runs on push to `main` and on every
pull request, and the job runs on `runs-on: xcode-27`. The first step prints
`xcodebuild -version` and fails unless it reports Xcode 27, so a runner without
the right toolchain stops before the build. The project needs that pin because
`project.pbxproj` is objectVersion 110, which Xcode 26 cannot open.

The job then runs the three commands from the spec in order: `xcodebuild test`
on the `AngryKeyboard` scheme, a Debug build, and a Release build, each with
`-destination 'generic/platform=macOS'`. Because the steps run in sequence, a
broken Debug or Release build fails the run. `concurrency` cancels an in-flight
run when the same branch is pushed again, and `permissions` drops to
`contents: read`.

Verified locally with Xcode 27.0 (27A266a) against a scratch
`-derivedDataPath build/ci-verify`, using the same three commands:

- `xcodebuild test` passes 44 tests.
- The Debug build produces `AngryKeyboardDev.app`.
- The Release build produces `AngryKeyboard.app`.

The `Config/*.local.xcconfig` files are gitignored and absent on the runner, so
the app builds use `CODE_SIGN_IDENTITY = -` and sign ad-hoc, as ticket 03
verified for a clone with no certificates. The test target resolves
`CODE_SIGN_IDENTITY = -` under its own `CODE_SIGN_STYLE = Automatic`, so it needs
no development team either.
