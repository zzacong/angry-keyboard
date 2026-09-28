# Signing

AngryKeyboard signs with two self-signed certificates, one per channel.

- `AngryKeyboard Dev` signs Debug builds.
- `AngryKeyboard Production` signs Release builds, on this Mac and in CI.

Each is a stable identity, so macOS keeps the Input Monitoring grant across
rebuilds. The names live in the gitignored `Config/Debug.local.xcconfig` and
`Config/Release.local.xcconfig`, so a clone with no certificates still builds
ad-hoc. `Scripts/setup-signing.sh` creates the certificates and writes those
files. The update key is separate: an EdDSA key on the Ed25519 curve, created by
`Scripts/setup-sparkle-key.sh`, that Sparkle signs the update feed and archive
with. The app verifies them against the public key in `Config/Info.plist`.

## GitHub entries

The release workflow reads five values from the repository settings. They are
not stored in the repo. Set them under Settings > Secrets and variables >
Actions.

| Name                     | Kind     | Holds                                                                                   | Used as                                            |
| ------------------------ | -------- | --------------------------------------------------------------------------------------- | -------------------------------------------------- |
| `CERTIFICATE_P12_BASE64` | secret   | The production certificate and its private key, exported as a `.p12` and base64 encoded | the file CI imports into its build keychain        |
| `CERTIFICATE_PASSWORD`   | secret   | The password set on that `.p12`                                                         | the import password                                |
| `KEYCHAIN_PASSWORD`      | secret   | A random string for the temporary keychain CI creates                                   | the password that unlocks that disposable keychain |
| `SIGNING_IDENTITY`       | variable | The certificate name `AngryKeyboard Production`                                         | the value of `CODE_SIGN_IDENTITY`                  |
| `SPARKLE_PRIVATE_KEY`    | secret   | The EdDSA private key Sparkle signs the update feed and archive with                    | the key piped to `generate_appcast` over stdin     |

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

The feed signing step pipes the update key to `generate_appcast` over stdin, so
the key never reaches the CI disk:

```
printf '%s' "$SPARKLE_PRIVATE_KEY" \
  | "$GENERATE_APPCAST" --ed-key-file - --download-url-prefix "$URL" feed
```

`generate_appcast` signs the archive and writes the signature into
`appcast.xml`. The release fails if the feed is unsigned, which is what catches
a `SPARKLE_PRIVATE_KEY` that does not match the app's `SUPublicEDKey`.

## Backups

macOS ties each Input Monitoring grant to the production private key. If that
key is lost, every recipient grants permission again and CI has nothing to sign
with. Keep the exported `.p12` somewhere durable and keep its password in a
password manager. `Scripts/setup-signing.sh` copies the `.p12` to a folder you
choose. Regenerating the certificate is possible, but it makes everyone approve
the app once more.

The Sparkle update key is the other release-critical secret. It is an EdDSA key
on the Ed25519 curve. Its private key lives in the login Keychain, in the
`SPARKLE_PRIVATE_KEY` CI secret, and in a backup beside the `.p12`:
`Scripts/setup-sparkle-key.sh` writes
`AngryKeyboard-sparkle-ed25519-private-key.txt` there by default. Losing the key
strands installed apps until users reinstall by hand, because Sparkle rejects a
feed signed with a key the app does not carry.

To restore the key on a new Mac, run the wizard:

```
Scripts/setup-sparkle-key.sh
```

When it asks for a key to import, give it the backup file. The wizard runs
`generate_keys -f`, which imports the private key into the login Keychain under
the `angrykeyboard` account, then re-stores the `SPARKLE_PRIVATE_KEY` secret and
re-copies the backup. If the Keychain already holds the key, the wizard reuses
it instead.

## Rehearsing an update

The `dmg-rehearsal` workflow builds a DMG, signs a feed for it with the same
`SPARKLE_PRIVATE_KEY` a release uses, and uploads the DMG, its checksum, and the
feed as one artifact. The feed's enclosure URL is relative (`AngryKeyboard.dmg`),
so Sparkle resolves it against the feed's own URL. That lets you serve the
artifacts from a single directory and run the real update flow without publishing
a release. Because the rehearsal signs with the release key, a normal Release
build already carries the matching `SUPublicEDKey`.

`Scripts/verify-update.sh` walks the steps below, pausing at each human check,
and appends the versions tested and the result to ticket 07.

1. Run the rehearsal and note the run id:

   ```
   gh workflow run dmg-rehearsal.yml
   gh run list --workflow dmg-rehearsal.yml
   ```

2. Download the artifact into one directory. The feed and the DMG it names land
   side by side:

   ```
   gh run download <run-id> -n AngryKeyboard-dmg-rehearsal -D rehearsal
   ls rehearsal   # appcast.xml  AngryKeyboard.dmg  AngryKeyboard.dmg.sha256
   ```

3. Serve that directory over HTTP. Sparkle resolves `AngryKeyboard.dmg` against
   the feed URL, so both files must sit under the same server root:

   ```
   python3 -m http.server 8000 --directory rehearsal
   ```

4. Install a Release build whose `CFBundleVersion` is lower than the rehearsal
   run number, which is the feed's `sparkle:version`. The run number is monotonic
   from ADR 0008, so an earlier run's build, or a local build with a lower
   `CURRENT_PROJECT_VERSION`, works.

5. Point the installed build at the local feed. Sparkle reads a `SUFeedURL` value
   in user defaults in preference to the one in Info.plist, which is how an
   alternate feed is tested. The ATS warning about a non-HTTPS feed is expected
   for localhost:

   ```
   defaults write com.zzacong.AngryKeyboard SUFeedURL http://localhost:8000/appcast.xml
   ```

6. Launch the app and choose "Check for Updates…" from the status menu. Sparkle
   fetches `appcast.xml`, downloads `AngryKeyboard.dmg`, verifies its EdDSA
   signature against `SUPublicEDKey`, installs, and relaunches. Confirm the Input
   Monitoring grant survived.

7. Clean up the override:

   ```
   defaults delete com.zzacong.AngryKeyboard SUFeedURL
   ```
