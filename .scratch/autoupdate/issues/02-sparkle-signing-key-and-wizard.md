# 02: Sparkle signing key and wizard

**What to build:** A run-once wizard that creates the EdDSA keypair Sparkle uses to trust updates, prints the public key, stores the private key as the CI secret, and walks you through backing it up. When it finishes, the public key is in hand and the secret is set.

**Blocked by:** None (can start immediately).

**Status:** ready-for-human

- [ ] A guided wizard generates the keypair and prints the public key.
- [ ] The private key is stored as the CI secret under the agreed name and is never committed to the repo.
- [ ] The key is backed up somewhere durable, and the backup's location is recorded beside the signing certificate's.
- [ ] Re-running the wizard cannot silently overwrite an existing key.

## Comments

- The wizard `Scripts/setup-sparkle-key.sh` is built and committed; the criteria
  above stay unchecked until it runs on the maintainer's Mac.
- It generates the keypair with Sparkle's `generate_keys`, stores the private
  key as the `SPARKLE_PRIVATE_KEY` secret, backs it up beside the certificate's
  `.p12`, and writes the public key to `SUPublicEDKey` in `Config/Info.plist`.
- Remaining human steps: run the wizard and approve the Keychain prompt, then
  check the criteria and mark this ticket `resolved`.
