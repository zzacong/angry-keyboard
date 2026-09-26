# Distribute outside the App Store, signed but not notarized

A Mac app that opens with a plain double-click normally needs a Developer ID certificate and a notarization ticket, and both come from the paid Apple Developer Program. This is a hobby app, so Zac will not pay the fee. The app ships from GitHub Releases signed with a self-signed `AngryKeyboard Production` certificate and is not notarized.

The consequence is that Gatekeeper blocks the first launch on every recipient's Mac, so the install instructions ship in the README, the release notes, and a text file inside the DMG. The certificate still does real work. It gives the app a stable code identity, so an Input Monitoring grant survives an update signed with the same certificate. An ad-hoc signature pins a hash of the binary instead, so every release looks like a new app and every recipient grants the permission again. That stability benefit is only proven on a machine that trusts the certificate, and it is an open item to verify on a fresh account or a second Mac.

Considered and rejected: ad-hoc signing for releases. It needs no secret in CI, but it loses the stable identity described above. Considered and rejected: a free Apple ID development certificate. It needs a signed-in Apple account on the build machine, it expires and must be renewed, and it still does not satisfy Gatekeeper, so it buys nothing over self-signed.

Because the identity is what the permission grants key to, the production certificate's private key must be backed up. Regenerating it makes every recipient grant Input Monitoring once more. The same certificate is imported into Zac's login keychain, so a local Release build carries the same identity as the released app.
