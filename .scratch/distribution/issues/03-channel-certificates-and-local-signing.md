# 03: Channel certificates and local signing

**What to build:** Local builds should carry a stable identity per channel so an Input Monitoring grant survives a rebuild. Create two self-signed code signing certificates, one for the dev channel and one for production, and point each configuration at its own. Import the production certificate into the login keychain so a local release build has the same identity as the released app, export it as a password-protected file, back it up, and store it and its password as repository secrets for the pipeline. The certificate names stay in gitignored files so the repository never demands a particular keychain.

**Blocked by:** 01.

**Status:** ready-for-human

- [ ] A dev build is signed by the dev certificate and a release build by the production certificate, confirmed with `codesign`.
- [ ] Rebuilding either channel no longer invalidates its Input Monitoring grant.
- [ ] The production certificate file is backed up and stored as a repository secret for the pipeline.
- [x] A clone with no certificates still builds both channels.

## Comments

The repository side is in place; the certificates themselves need the Keychain
Access GUI, so the last step is a wizard on the Mac that will hold them.

Committed:

- `Config/Debug.local.xcconfig.example` and `Config/Release.local.xcconfig.example`
  document the two identity names. The real `Config/*.local.xcconfig` files are
  still gitignored, so the repo never names a keychain.
- `.gitignore` now ignores `*.p12`.
- `Scripts/setup-signing.sh` is the wizard. It checks the tools, walks the two
  Keychain Access certificates into existence and trust, writes the gitignored
  local configs, exports production as a password-protected `.p12`, checks it
  imports the way CI imports it, backs it up, and sets the three repository
  secrets plus the `SIGNING_IDENTITY` variable with `gh`.
- `README.md`'s local signing section is corrected: it described setting the
  identity in Xcode's Signing & Capabilities, which ticket 01 replaced with the
  local xcconfig files.

Verified for the clone case: with no `Config/*.local.xcconfig` present, Debug
builds `AngryKeyboardDev.app` and Release builds `AngryKeyboard.app`, both ad-hoc
signed and verifying under `codesign`, and all 44 tests pass.

Why the certificate step is not automated: a self-signed code signing identity
is `CSSMERR_TP_NOT_TRUSTED` until it is trusted, and adding trust opens the
Keychain authorization prompt. A script cannot get past it, so the certificate
creation stays in Keychain Access and the wizard guides it.

Still to do by hand: run `Scripts/setup-signing.sh` on the Mac that will hold
the certificates. Then the first three boxes can be checked. `gh` is
authenticated on this machine and no secrets or variables are set yet, so the
wizard's secret stage will run cleanly.
