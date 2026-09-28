# Signing

AngryKeyboard signs with two self-signed certificates, one per channel.

- `AngryKeyboard Dev` signs Debug builds.
- `AngryKeyboard Production` signs Release builds, on this Mac and in CI.

Each is a stable identity, so macOS keeps the Input Monitoring grant across
rebuilds. The names live in the gitignored `Config/Debug.local.xcconfig` and
`Config/Release.local.xcconfig`, so a clone with no certificates still builds
ad-hoc. `Scripts/setup-signing.sh` creates the certificates and writes those
files. `Scripts/setup-sparkle-key.sh` creates the separate EdDSA key Sparkle
signs updates with.

## GitHub entries

The release workflow reads four values from the repository settings. They are
not stored in the repo. Set them under Settings > Secrets and variables >
Actions.

| Name                     | Kind     | Holds                                                                                   | Used as                                            |
| ------------------------ | -------- | --------------------------------------------------------------------------------------- | -------------------------------------------------- |
| `CERTIFICATE_P12_BASE64` | secret   | The production certificate and its private key, exported as a `.p12` and base64 encoded | the file CI imports into its build keychain        |
| `CERTIFICATE_PASSWORD`   | secret   | The password set on that `.p12`                                                         | the import password                                |
| `KEYCHAIN_PASSWORD`      | secret   | A random string for the temporary keychain CI creates                                   | the password that unlocks that disposable keychain |
| `SIGNING_IDENTITY`       | variable | The certificate name `AngryKeyboard Production`                                         | the value of `CODE_SIGN_IDENTITY`                  |

Secrets are encrypted and masked in logs. A variable is plain config, which fits
a certificate name that is not sensitive.

The `.p12` holds a private key, so it is a secret and must never be committed.
`.gitignore` covers `*.p12` in case one is exported inside the repo.

## How CI uses them

The release workflow decodes the `.p12`, creates a temporary keychain, imports
the identity, and signs the Release build with it.

```
echo "$CERTIFICATE_P12_BASE64" | base64 --decode > certificate.p12
security create-keychain -p "$KEYCHAIN_PASSWORD" build.keychain
security default-keychain -s build.keychain
security list-keychains -d user -s build.keychain
security unlock-keychain -p "$KEYCHAIN_PASSWORD" build.keychain
security import certificate.p12 -k build.keychain -P "$CERTIFICATE_PASSWORD" -T /usr/bin/codesign
security set-key-partition-list -S apple-tool:,apple: -s -k "$KEYCHAIN_PASSWORD" build.keychain
xcodebuild ... CODE_SIGN_IDENTITY="$SIGNING_IDENTITY" ...
```

`security default-keychain` makes the temporary keychain the default, and
`security list-keychains` makes it the only keychain `codesign` searches, so
`codesign` finds the identity without a prompt. `security set-key-partition-list`
lets `codesign` use the key. Without these the build hangs. The job deletes the
`.p12` and the keychain in an `if: always()` step.

## Backups

macOS ties each Input Monitoring grant to the production private key. If that
key is lost, every recipient grants permission again and CI has nothing to sign
with. Keep the exported `.p12` somewhere durable and keep its password in a
password manager. `Scripts/setup-signing.sh` copies the `.p12` to a folder you
choose. Regenerating the certificate is possible, but it makes everyone approve
the app once more.
