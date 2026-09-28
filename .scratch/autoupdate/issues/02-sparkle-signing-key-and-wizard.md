# 02: Sparkle signing key and wizard

**What to build:** A run-once wizard that creates the EdDSA keypair Sparkle uses to trust updates, prints the public key, stores the private key as the CI secret, and walks you through backing it up. When it finishes, the public key is in hand and the secret is set.

**Blocked by:** None (can start immediately).

**Status:** resolved

- [x] A guided wizard generates the keypair and prints the public key.
- [x] The private key is stored as the CI secret under the agreed name and is never committed to the repo.
- [x] The key is backed up somewhere durable, and the backup's location is recorded beside the signing certificate's.
- [x] Re-running the wizard cannot silently overwrite an existing key.

## Comments

- Ran `Scripts/setup-sparkle-key.sh` on the maintainer's Mac. It generated the
  keypair, set the `SPARKLE_PRIVATE_KEY` secret, and copied the private key to
  `~/Documents/AngryKeyboard-sparkle-ed25519-private-key.txt`, beside the
  production certificate's `.p12`.
- The public key `AAOBc5/b7krj/V7p75BaXhvKa2uKLbptJsVXjoKAMmE=` is recorded as
  `SUPublicEDKey` in `Config/Info.plist`. The wizard prints the public key but
  does not edit the plist itself, because no standard plist tool preserves the
  file's comments.
- Re-running reuses the Keychain key (`generate_keys` never overwrites one) and
  only asks before replacing an existing secret or backup.
