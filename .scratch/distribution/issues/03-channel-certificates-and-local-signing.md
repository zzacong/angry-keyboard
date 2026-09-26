# 03: Channel certificates and local signing

**What to build:** Local builds should carry a stable identity per channel so an Input Monitoring grant survives a rebuild. Create two self-signed code signing certificates, one for the dev channel and one for production, and point each configuration at its own. Import the production certificate into the login keychain so a local release build has the same identity as the released app, export it as a password-protected file, back it up, and store it and its password as repository secrets for the pipeline. The certificate names stay in gitignored files so the repository never demands a particular keychain.

**Blocked by:** 01.

**Status:** ready-for-human

- [ ] A dev build is signed by the dev certificate and a release build by the production certificate, confirmed with `codesign`.
- [ ] Rebuilding either channel no longer invalidates its Input Monitoring grant.
- [ ] The production certificate file is backed up and stored as a repository secret for the pipeline.
- [ ] A clone with no certificates still builds both channels.
