# AngryKeyboard distribution

**Status:** ready-for-agent

## Problem Statement

AngryKeyboard is finished and there is no way to hand it to anyone, including a future version of Zac on another Mac. The Mac App Store and notarization both need the paid Apple Developer Program, which is out of the question for a hobby app. Zac wants to learn how a GitHub Actions pipeline builds and releases an Xcode project, and he wants a DMG on a release page with a changelog and an honest warning for anyone who downloads it. He also wants to keep developing the app without disturbing the copy he actually uses, which means a second app that can run beside the first.

## Solution

Releases are driven by git tags that Release Please creates from conventional commits. Release Please opens a release PR that updates `CHANGELOG.md`. Merging that PR creates the tag, and a build job on an `xcode-27` runner then builds the Release app, signs it with the `AngryKeyboard Production` certificate kept in a repository secret, stages it with an `/Applications` symlink, wraps it in a DMG, writes a checksum, attests provenance, and uploads everything to the GitHub Release.

Two channels grow out of the same sources. Production is what CI builds and what people download. Dev is what Xcode builds for daily work. They carry separate bundle ids, names, certificates, and icons so both can run at the same time.

The app is signed but not notarized, so macOS blocks the first launch. The README, the release notes, and a text file inside the DMG explain how to get past Gatekeeper and state that this is a hobby build.

The first release is `v0.1.0`.

## Decisions

- Distribution is GitHub Releases only. No Mac App Store, no Homebrew, no in-app updates.
- No Apple Developer Program membership, so no Developer ID and no notarization.
- There are two channels, mapped to the two build configurations: Debug is dev, Release is production. See ADR 0009.
- The channels differ in bundle id, display name, product name, certificate, and app icon. See the Channels section.
- Release builds are signed with a self-signed certificate named `AngryKeyboard Production`, which is imported into CI and into Zac's login keychain. Dev builds are signed with `AngryKeyboard Dev`. See ADR 0007.
- The committed project signs ad-hoc so a stranger can build it. The certificate names live in gitignored per-configuration files. CI passes the production identity on the `xcodebuild` command line.
- The git tag is the only release version source. CI injects `MARKETING_VERSION` from the tag and `CURRENT_PROJECT_VERSION` from the Actions run number. See ADR 0008.
- Dev builds derive their version from `git describe` at build time, so the dev app's About panel shows the exact commit. See the Version section.
- Version bumps stay below 1.0.0 until Zac says otherwise. While the major version is 0, `feat` and `fix` bump the patch, and a breaking change bumps the minor.
- The artifact is a single `AngryKeyboard.dmg` with a fixed filename, plus a `.sha256` file. No ZIP.
- The build is universal, `arm64` and `x86_64`.
- The minimum macOS is 14.0, so the install instructions cover both the macOS 14 flow and the macOS 15 and later flow.
- Third-party sounds come from Pixabay and are credited in `CREDITS.md`.

## Channels

Production and dev are the same code, built as two apps. The channel is the Xcode build configuration, so there is one app target and no duplicated target settings.

| | Production | Dev |
| --- | --- | --- |
| Configuration | Release | Debug |
| Bundle id | `com.zzacong.AngryKeyboard` | `com.zzacong.AngryKeyboard.dev` |
| Display name | Angry Keyboard | Angry Keyboard Dev |
| Product name | `AngryKeyboard` | `AngryKeyboardDev` |
| Certificate | `AngryKeyboard Production` | `AngryKeyboard Dev` |
| App icon | `AppIcon` | `AppIconDev` |
| Built by | CI, and locally | Xcode |
| Released | yes | no |

The display name is what appears in Input Monitoring and in Login Items, so it has to differ or the two entries are indistinguishable. The product name has to differ or Finder cannot keep both `.app` files in `/Applications`.

Preferences need no work. `UserDefaults.standard` keys off the bundle id, so the two channels already have separate `volume`, `muted`, and `playbackMode` values. Launch at Login stays in both. Enabling it in both apps means two Login Items, which is allowed and is Zac's choice.

### Channel-aware code

The app already reads its name from `CFBundleDisplayName` through `AppDelegate.displayName`, so the About panel, the Quit item, the tooltip, and the permission explainer are channel-aware with no change.

Two lookups hardcode production assets and must change:

- `AppDelegate.applicationIcon` hardcodes `NSImage(named: "AppIcon")`. It reads `CFBundleIconName`, which Xcode writes from `ASSETCATALOG_COMPILER_APPICON_NAME`, so each channel loads its own icon.
- `AppDelegate.refreshStatusIcon` hardcodes `MenuBarGlyph` and `MenuBarGlyphMuted`. It reads two custom Info.plist keys, `AKMenuBarGlyph` and `AKMenuBarGlyphMuted`, falling back to the current names.

Both lookups live in `AngryKeyboardCore/ChannelAssets.swift` so the fallbacks are unit-tested.

Xcode 27 drops custom keys written as `INFOPLIST_KEY_<name>` from the generated Info.plist. The two glyph keys therefore come from a real `Config/Info.plist` that is merged with the generated one (`INFOPLIST_FILE = Config/Info.plist` alongside `GENERATE_INFOPLIST_FILE = YES`). Its values are build settings, `$(AK_MENU_BAR_GLYPH)` and `$(AK_MENU_BAR_GLYPH_MUTED)`, so the per-channel names still live in the xcconfig files.

### Dev assets

The dev app icon is a second appiconset, `AppIconDev`, generated from the existing Kraft Kit master, which is one command in `.scratch/branding/source`. It stays in place until the blueprint pick is implemented.

The blueprint design pass lives in `.scratch/branding`: `icon-prototype-dev-blueprint.html` shows five white-and-blue app icon variants and five shape-distinct menu bar glyphs, with the 1024 masters and glyph SVGs next to it in `source/`. The menu bar glyph stays deferred until Zac picks one. `AKMenuBarGlyph` and `AKMenuBarGlyphMuted` point at the production assets in both channels for now, so the two menu bar icons look identical. Repointing the dev channel at its own glyph is small but not two lines: the chosen glyph needs its own imageset, with a muted variant, and `Config/Debug.xcconfig` names it.

The blueprint theme cannot be applied to the menu bar glyph. `refreshStatusIcon` sets `isTemplate = true`, so macOS recolors the glyph to match the menu bar, black in light mode and white in dark mode. The dev glyph has to differ from production by shape, not color. The blueprint palette is for the app icon, which is drawn at large sizes and in color.

## Workflows

### ci.yml

Runs on every push and pull request. Builds both channels and runs the unit tests, so a broken dev build is caught as well as a broken release build.

```yaml
name: ci

on:
  push:
    branches: [main]
  pull_request:

jobs:
  test:
    runs-on: xcode-27
    steps:
      - uses: actions/checkout@v4
      - run: xcodebuild test -scheme AngryKeyboard -destination 'platform=macOS'
      - run: xcodebuild build -scheme AngryKeyboard -configuration Debug -destination 'generic/platform=macOS'
      - run: xcodebuild build -scheme AngryKeyboard -configuration Release -destination 'generic/platform=macOS'
```

### release.yml

Runs on push to main. The first job runs Release Please. The second job builds and publishes, and it only runs when Release Please created a release.

The two jobs have to live in one workflow. Release Please creates the tag and the release with `GITHUB_TOKEN`, and GitHub does not start workflows from events that `GITHUB_TOKEN` caused, so a separate `on: release: published` workflow would never fire. Reading the action outputs inside the same workflow avoids a personal access token.

```yaml
name: release

on:
  push:
    branches: [main]

permissions:
  contents: write
  pull-requests: write

jobs:
  release-please:
    runs-on: ubuntu-latest
    outputs:
      released: ${{ steps.release.outputs.release_created }}
      tag: ${{ steps.release.outputs.tag_name }}
    steps:
      - uses: googleapis/release-please-action@v4
        id: release
        with:
          config-file: release-please-config.json
          manifest-file: .release-please-manifest.json

  build:
    needs: release-please
    if: needs.release-please.outputs.released == 'true'
    runs-on: xcode-27
    permissions:
      contents: write
      id-token: write
      attestations: write
    steps:
      - uses: actions/checkout@v4
        with:
          ref: ${{ needs.release-please.outputs.tag }}
      # sign, build, package, attest, upload
```

Confirm the current major version of `release-please-action` and its output names when implementing. Those names changed between major versions.

## Signing

### Certificates

Create two self-signed code signing certificates in Keychain Access, both valid for ten years.

- `AngryKeyboard Dev`, used by Debug builds.
- `AngryKeyboard Production`, used by Release builds, both in CI and on Zac's Mac.

Export `AngryKeyboard Production` and its private key as a `.p12`, and keep a backup of that file. It is the identity every recipient's Input Monitoring grant keys to, and regenerating it makes everyone grant permission again. Zac imports the same `.p12` locally so a local Release build has the same identity as the released app.

### Repository secrets

- `CERTIFICATE_P12_BASE64`: the production `.p12`, base64 encoded.
- `CERTIFICATE_PASSWORD`: the `.p12` password.
- `KEYCHAIN_PASSWORD`: any random string for the temporary CI keychain.

Store the signing identity name as a repository variable `SIGNING_IDENTITY` so it is not duplicated across workflows.

### CI keychain steps

```bash
echo "$CERTIFICATE_P12_BASE64" | base64 --decode > certificate.p12
security create-keychain -p "$KEYCHAIN_PASSWORD" build.keychain
security default-keychain -s build.keychain
security unlock-keychain -p "$KEYCHAIN_PASSWORD" build.keychain
security import certificate.p12 -k build.keychain -P "$CERTIFICATE_PASSWORD" -T /usr/bin/codesign
security set-key-partition-list -S apple-tool:,apple: -s -k "$KEYCHAIN_PASSWORD" build.keychain
security find-identity -v -p codesigning build.keychain
```

`security set-key-partition-list` is what lets `codesign` use the key without a prompt. Without it the build hangs or fails. Delete the `.p12` and the keychain in an `if: always()` step.

### Project configuration

The committed project must build with no certificate so that a stranger who clones it can build. Each of the app target's build configurations gets a base configuration file. The channel values live there, because each file belongs to one configuration.

`Config/Debug.xcconfig`:

```
PRODUCT_BUNDLE_IDENTIFIER = com.zzacong.AngryKeyboard.dev
PRODUCT_NAME = AngryKeyboardDev
INFOPLIST_KEY_CFBundleDisplayName = Angry Keyboard Dev
ASSETCATALOG_COMPILER_APPICON_NAME = AppIconDev
AK_MENU_BAR_GLYPH = MenuBarGlyph
AK_MENU_BAR_GLYPH_MUTED = MenuBarGlyphMuted

CODE_SIGN_STYLE = Manual
CODE_SIGN_IDENTITY = -
#include? "Debug.local.xcconfig"
```

`Config/Release.xcconfig`:

```
PRODUCT_BUNDLE_IDENTIFIER = com.zzacong.AngryKeyboard
PRODUCT_NAME = AngryKeyboard
INFOPLIST_KEY_CFBundleDisplayName = Angry Keyboard
ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon
AK_MENU_BAR_GLYPH = MenuBarGlyph
AK_MENU_BAR_GLYPH_MUTED = MenuBarGlyphMuted

CODE_SIGN_STYLE = Manual
CODE_SIGN_IDENTITY = -
#include? "Release.local.xcconfig"
```

The two `*.local.xcconfig` files are gitignored and hold one line each, `CODE_SIGN_IDENTITY = AngryKeyboard Dev` and `CODE_SIGN_IDENTITY = AngryKeyboard Production`. The `#include?` is optional, so a clone without them builds ad-hoc.

The target build settings must not override what the configuration files set, so `PRODUCT_BUNDLE_IDENTIFIER`, `PRODUCT_NAME`, `INFOPLIST_KEY_CFBundleDisplayName`, `ASSETCATALOG_COMPILER_APPICON_NAME`, `CODE_SIGN_STYLE`, and `CODE_SIGN_IDENTITY` come out of the target. The test target keeps its own settings and automatic signing.

CI overrides the identity on the command line, which takes precedence over any configuration file:

```bash
CODE_SIGN_IDENTITY="$SIGNING_IDENTITY"
```

## Version and changelog

`release-please-config.json`:

```json
{
  "release-type": "simple",
  "bump-minor-pre-major": true,
  "bump-patch-for-minor-pre-major": true,
  "packages": {
    ".": {}
  }
}
```

`.release-please-manifest.json`:

```json
{
  ".": "0.0.0"
}
```

While the major version is 0, `fix`, `feat`, `perf`, and `revert` bump the patch, and a breaking change bumps the minor. `chore`, `docs`, `build`, `test`, `ci`, `refactor`, and `style` produce no release on their own. The major version only moves with a commit footer `Release-As: 1.0.0`.

Bootstrap the first release with a commit carrying a `Release-As: 0.1.0` footer. Release Please ignores the pre-major flags at `0.0.0` and would otherwise choose the first version itself.

`release-type: simple` maintains `version.txt` and `CHANGELOG.md`. Only `CHANGELOG.md` is read by a human.

The committed `MARKETING_VERSION` changes from `1.0` to `0.1.0`. It is a placeholder for local Release builds, since CI injects the tag.

### Dev version from git

The dev channel derives its version at build time so the About panel shows the exact commit instead of the placeholder. A Run Script phase, `Scripts/set-dev-version.sh`, runs only for Debug:

```sh
[ "$CONFIGURATION" = "Debug" ] || exit 0

cd "$SRCROOT" || exit 0
VERSION=$(git describe --tags --dirty --always 2>/dev/null | sed 's/^v//')
[ -n "$VERSION" ] || exit 0

/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $VERSION" \
  "$TARGET_BUILD_DIR/$INFOPLIST_PATH"
```

Four costs come with this. The project has `ENABLE_USER_SCRIPT_SANDBOXING = YES`, so the app target must set it to `NO` or the script cannot run `git` and write the built plist. The script runs before code signing, so the signature covers the patched plist. Until the first tag exists, `git describe` falls back to a short commit hash, so the dev version reads as a hash rather than `0.1.0`. And it is gated to Debug so it never overwrites the tag injected into Release.

## Build and package

```bash
VERSION="${TAG#v}"

xcodebuild \
  -project AngryKeyboard.xcodeproj \
  -scheme AngryKeyboard \
  -configuration Release \
  -destination 'generic/platform=macOS' \
  -derivedDataPath build \
  MARKETING_VERSION="$VERSION" \
  CURRENT_PROJECT_VERSION="${{ github.run_number }}" \
  CODE_SIGN_STYLE=Manual \
  CODE_SIGN_IDENTITY="$SIGNING_IDENTITY" \
  build
```

The product lands at `build/Build/Products/Release/AngryKeyboard.app`.

Stage it and create the DMG:

```bash
mkdir -p dist/dmg
cp -R build/Build/Products/Release/AngryKeyboard.app dist/dmg/
ln -s /Applications dist/dmg/Applications
cp packaging/INSTALL.txt "dist/dmg/Read Me.txt"
hdiutil create -volname "Angry Keyboard" -srcfolder dist/dmg -ov -format UDZO dist/AngryKeyboard.dmg
shasum -a 256 dist/AngryKeyboard.dmg | awk '{print $1}' > dist/AngryKeyboard.dmg.sha256
```

`hdiutil` is used instead of `create-dmg`. `create-dmg` drives Finder through AppleScript to position icons, and that has a long history of timing out on GitHub's headless runners. `hdiutil` needs no Finder and produces the same drag-to-Applications arrangement. The cost is that icon positions use Finder defaults. Revisit `create-dmg` only if that default layout is unacceptable, and verify it on the runner before trusting it.

Verify the signature on the app and on the app inside the mounted DMG:

```bash
codesign --verify --deep --strict --verbose=2 build/Build/Products/Release/AngryKeyboard.app
hdiutil attach dist/AngryKeyboard.dmg -nobrowse -readonly
codesign --verify --deep --strict "/Volumes/Angry Keyboard/AngryKeyboard.app"
hdiutil detach "/Volumes/Angry Keyboard"
```

Do not run `spctl` as a gate. It is expected to reject a build that is signed but not notarized, so it would fail every release.

## Attestation

Add build provenance so a download can be traced to this repository and commit:

```yaml
- uses: actions/attest-build-provenance@v2
  with:
    subject-path: dist/AngryKeyboard.dmg
```

This needs `id-token: write` and `attestations: write`. A recipient can then run:

```bash
gh attestation verify AngryKeyboard.dmg --repo zzacong/angry-keyboard
```

It does not change the Gatekeeper block. It answers whether GitHub built the file from this repository, which is a different question.

## Release assets

`gh release upload` attaches:

- `AngryKeyboard.dmg`
- `AngryKeyboard.dmg.sha256`

The fixed DMG filename lets a future homepage link `releases/latest/download/AngryKeyboard.dmg` and have it keep working.

The build job appends the install warning to the release body after Release Please writes the notes:

```bash
gh release view "$TAG" --json body --jq .body > notes.md
cat packaging/RELEASE-NOTES.md >> notes.md
gh release edit "$TAG" --notes-file notes.md
```

## Install warning

The same text goes in the README, the release notes, and `packaging/INSTALL.txt` inside the DMG.

> AngryKeyboard is a hobby project I build for myself.
>
> This build is signed but not notarized, because notarization needs the $99/year Apple Developer Program and I do not pay it for this. macOS will block the first launch. Use it at your own risk.
>
> macOS 15 or later:
>
> 1. Open the app. macOS says it cannot be verified. Choose Done.
> 2. Open System Settings > Privacy & Security.
> 3. Find the AngryKeyboard message and click Open Anyway.
>
> macOS 14:
>
> Control-click the app and choose Open.
>
> The app then asks for Input Monitoring, which it needs to hear keystrokes. It only listens. It never records, stores, or sends what you type.

## Repository changes

| Path | Change |
| --- | --- |
| `.github/workflows/ci.yml` | new, builds both configurations and runs tests |
| `.github/workflows/release.yml` | new |
| `release-please-config.json` | new |
| `.release-please-manifest.json` | new |
| `version.txt` | new, maintained by Release Please |
| `Config/Debug.xcconfig` | new, dev channel values and the ad-hoc signing default |
| `Config/Release.xcconfig` | new, production channel values and the ad-hoc signing default |
| `Config/Debug.local.xcconfig.example` | new, documents the dev certificate name |
| `Config/Release.local.xcconfig.example` | new, documents the production certificate name |
| `Config/Debug.local.xcconfig` | gitignored, holds the dev certificate name |
| `Config/Release.local.xcconfig` | gitignored, holds the production certificate name |
| `Scripts/set-dev-version.sh` | new, the Debug-only git describe build phase |
| `packaging/INSTALL.txt` | new, the warning and install steps |
| `packaging/RELEASE-NOTES.md` | new, the warning block appended to release notes |
| `CREDITS.md` | new, Pixabay sound credit |
| `AngryKeyboard/Assets.xcassets/AppIconDev.appiconset` | new, the dev app icon, generated from the Kraft Kit master until the blueprint redesign lands |
| `Config/Info.plist` | new, holds the custom glyph keys with build-setting values, merged into the generated Info.plist |
| `AngryKeyboard/AppDelegate.swift` | read the app icon and the glyph names through `ChannelAssets` instead of hardcoded assets |
| `AngryKeyboardCore/ChannelAssets.swift` | new, the channel asset name lookups and their production fallbacks |
| `AngryKeyboardTests/ChannelAssetsTests.swift` | new, pins the fallback behaviour |
| `AngryKeyboard.xcodeproj/project.pbxproj` | base each app configuration on its `Config/*.xcconfig`, remove the overridden settings, add the version script phase, set `ENABLE_USER_SCRIPT_SANDBOXING = NO` on the app target, change `MARKETING_VERSION` to `0.1.0` |
| `.gitignore` | add `Config/Debug.local.xcconfig`, `Config/Release.local.xcconfig`, `*.p12`, `dist/` |
| `README.md` | add a distribution section and the install flows, document both channels and their bundle ids, note the production certificate, update the rebuild caveat |

Repository secrets and variables live in GitHub settings, not in the repo: `CERTIFICATE_P12_BASE64`, `CERTIFICATE_PASSWORD`, `KEYCHAIN_PASSWORD`, and the `SIGNING_IDENTITY` variable.

## Open items

- Verify the fresh-install experience on a second user account or a second Mac. Confirm that a downloaded DMG gets through Gatekeeper, that Input Monitoring can be granted, and that the app makes sound. This is untested because it needs a machine that has never seen the app.
- After the second release, confirm that an Input Monitoring grant survives an update from the previous version, since both are signed with `AngryKeyboard Production`. This is the claim the signing setup rests on.
- The dev channel's blueprint proof sheet exists and waits on a pick. Implementing that pick ships the chosen master as `AppIconDev` and points the dev glyph keys at a shape-distinct glyph, since template images cannot carry color.

## Out of Scope

- The Mac App Store, a Developer ID certificate, and notarization.
- Homebrew casks and taps.
- In-app updates with Sparkle.
- A custom DMG background image and custom icon positions.
- The marketing homepage. The fixed DMG filename and the release page are the only parts it needs.
- Testing the Intel slice on real Intel hardware.
- A `-dev` version suffix scheme. The dev version comes from `git describe` instead.

## Further Notes

**Two install flows.** The minimum is macOS 14, but macOS 15 removed Control-click to open. The README and the DMG text must show the System Settings flow for 15 and later and the Control-click flow for 14.

**Toolchain.** The project file is written at Xcode 27's format, `objectVersion = 110`, so it will not open in Xcode 26 without saving it in an older format first. That is why the runner is pinned to `xcode-27`. Xcode 27 only runs on Apple silicon, so an Intel Mac can run the built app but cannot build it.

**Universal build.** The Release configuration builds `arm64` and `x86_64` because the deployment target is below 27.0. Xcode 27 drops the `x86_64` slice only when the deployment target is 27.0 or higher.

**Sounds.** The nine MP3 files come from Pixabay. The Pixabay Content License allows commercial and non-commercial use with no attribution required, and forbids redistributing the raw file as a standalone product, which a bundled app is not. `CREDITS.md` records the source, and the README says the MIT license covers the code and not the sounds.

**Channel identities are independent.** Production and dev have separate bundle ids, so they have separate preferences, separate Input Monitoring grants, and separate Login Items. Installing a release and a local build never shadows one another, because a release always carries `com.zzacong.AngryKeyboard` and a dev build always carries `com.zzacong.AngryKeyboard.dev`.
