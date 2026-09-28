# AngryKeyboard

A macOS menu bar app that plays a sound on every keystroke, system wide.

It has no window and no Dock icon. The app lives in the menu bar as a keyboard icon.

Hear every sound in the browser at
[angry-keyboard.zzacong.com](https://angry-keyboard.zzacong.com).

## Requirements

- macOS 14.0 (Sonoma) or later

## Install

Download the latest `AngryKeyboard.dmg` from
[Releases](https://github.com/zzacong/angry-keyboard/releases/latest), open it,
and drag AngryKeyboard to Applications.

This is the only install you do by hand. After that the app checks GitHub
Releases once a day and offers a newer build in its menu bar, where a click
installs the build and relaunches the app.

AngryKeyboard is a hobby project I build for myself.

This build is signed but not notarized, because notarization needs the $99/year
Apple Developer Program and I do not pay it for this. macOS will block the first
launch. Use it at your own risk.

macOS 15 or later:

1. Open the app. macOS says it cannot be verified. Choose Done.
2. Open System Settings > Privacy & Security.
3. Find the AngryKeyboard message and click Open Anyway.

macOS 14:

Control-click the app and choose Open.

The app then asks for Input Monitoring, which it needs to hear keystrokes. It
only listens. It never records, stores, or sends what you type.

## Build and run

Building from source needs Xcode 27.0 or later. Running the app needs only
macOS; Xcode is not a runtime dependency.

The `justfile` wraps the common commands. Run `just` to list them.

```
just app-build   # build the Debug app into build/
just app-run     # build, then open the AngryKeyboardDev app
just app-test    # run the app test suite
```

Debug is the dev channel, which runs beside the production app that Release
builds.

Or open `AngryKeyboard.xcodeproj` in Xcode, select the AngryKeyboard scheme, and
press Run (Cmd-R).

Capture, audio, and permissions cannot be unit tested, so they have a manual
checklist below.

### Local signing

An ad-hoc signature is a hash of the binary, so it changes on every build and
macOS drops the Input Monitoring grant each time. Both channels therefore sign
with a stable self-signed certificate: `AngryKeyboard Dev` for Debug and
`AngryKeyboard Production` for Release. Production is the same identity CI uses,
so a local release matches the download.

Run the setup wizard once per Mac:

```
Scripts/setup-signing.sh
```

It creates both certificates in Keychain Access, writes the gitignored
`Config/Debug.local.xcconfig` and `Config/Release.local.xcconfig`, exports
production as a `.p12` for the release workflow, backs it up, and stores the
repository secrets (`CERTIFICATE_P12_BASE64`, `CERTIFICATE_PASSWORD`,
`KEYCHAIN_PASSWORD`) and the `SIGNING_IDENTITY` variable. What each of those
holds and how CI uses them is documented in `docs/signing.md`.

A clone with no certificates still builds both channels. The committed
`Config/Debug.xcconfig` and `Config/Release.xcconfig` sign ad-hoc, and each
`#include?`s its local file, so nothing in the repository depends on a
particular keychain.

A Git worktree is a fresh checkout, so those local files are absent and the
build falls back to ad-hoc, losing the Input Monitoring grant on every rebuild.
The root `.worktreeinclude` names `Config/*.local.xcconfig` so a newly created
worktree receives them.

A free Apple ID works too, with no certificate to manage: add it under Xcode >
Settings > Accounts, set the target's Team to the Personal Team, and Xcode signs
with an Apple Development certificate it renews each year. It needs an Apple ID
signed in, and it buys nothing locally that the self-signed certificate does not.

## Channels

The project builds two apps, production and dev, and they can run at the same
time.

|                     | Production                  | Dev                             |
| ------------------- | --------------------------- | ------------------------------- |
| Build configuration | Release                     | Debug                           |
| Bundle id           | `com.zzacong.AngryKeyboard` | `com.zzacong.AngryKeyboard.dev` |
| Display name        | Angry Keyboard              | Angry Keyboard Dev              |
| Product name        | `AngryKeyboard.app`         | `AngryKeyboardDev.app`          |
| App icon            | `AppIcon`                   | `AppIconDev`                    |
| Menu bar glyph      | keyboard                    | fuming key                      |
| Update checks       | yes, once a day             | no                              |
| Released            | yes                         | no                              |

Production is the download. Dev is what Xcode builds while working on the app.
They differ in bundle id, so macOS gives each its own volume, mute, and playback
mode settings, its own Input Monitoring entry, and its own Login Item. The menu
bar glyph and the name on the About panel tell them apart at a glance.

A local Release build is signed with the same `AngryKeyboard Production`
certificate as the download, so it carries the same identity. Debug builds sign
with `AngryKeyboard Dev`. See Local signing above.

## Grant Input Monitoring

AngryKeyboard hears every keystroke system wide, so macOS gates it behind Input
Monitoring. The app only listens. It never records, stores, or sends what you
type.

On first launch, the app shows an explainer before macOS asks anything. Click
Open System Settings. macOS adds AngryKeyboard to the list and opens System
Settings > Privacy & Security > Input Monitoring. System Settings lists the app
as Angry Keyboard. Turn that switch on.

If you dismissed the explainer, use the menu bar instead. Click the keyboard
icon, then Open Input Monitoring Settings. This does the same two things:
registers the app and opens the pane.

The menu shows the live status at the top, either "Input Monitoring: Granted" or
"Input Monitoring: Not Granted". The status updates on its own within a couple
of seconds of a change, and again on every menu open. No relaunch is needed.

If the menu flips to Granted but typing stays silent, quit and relaunch the app.
macOS sometimes holds a new Input Monitoring grant until the app restarts. If
the switch in System Settings will not turn on, remove AngryKeyboard from the
list with the minus button, then re-add it from the app.

## Stored settings

The app stores three preferences in UserDefaults under the bundle ID
`com.zzacong.AngryKeyboard`, which on a normal install is
`~/Library/Preferences/com.zzacong.AngryKeyboard.plist`:

- `volume`, a number from `0` to `1`, default `0.6`
- `muted`, a boolean, default off
- `playbackMode`, the string `retrigger` or `overlap`, default `retrigger`

You can read or change them with the `defaults` command:

```
defaults read com.zzacong.AngryKeyboard
defaults write com.zzacong.AngryKeyboard volume -float 0.4
defaults write com.zzacong.AngryKeyboard muted -bool true
defaults write com.zzacong.AngryKeyboard playbackMode -string overlap
defaults delete com.zzacong.AngryKeyboard volume
```

Always pass the type flag (`-float`, `-bool`, `-string`). Without one,
`defaults write` stores a string, and the volume read expects a number.

Quit the app before you write. The app reads these once at launch and macOS
caches them, so a write made while it runs can be overwritten when the app
flushes its own values. Quit, write, relaunch.

Launch at Login is not stored here. The app reads it from the system, so System
Settings > General > Login Items is the source of truth.

## Uninstall

To remove AngryKeyboard completely:

1. Quit the app from its menu bar icon.
2. Turn off Launch at Login if it is on. Removing the app does not always remove
   the login item, so after the app is gone check System Settings > General >
   Login Items and remove any leftover entry.
3. Drag AngryKeyboard from Applications to the Trash.
4. Remove the stored preferences:

   ```
   defaults delete com.zzacong.AngryKeyboard
   ```

   This clears the volume, mute, and playback mode settings and Sparkle's
   `SULastCheckTime` and `SUHasLaunchedBefore` update state.

5. Remove the cached update check:

   ```
   rm -rf ~/Library/Caches/com.zzacong.AngryKeyboard
   rm -rf ~/Library/HTTPStorages/com.zzacong.AngryKeyboard
   rm -f  ~/Library/HTTPStorages/com.zzacong.AngryKeyboard.binarycookies
   ```

   Sparkle fetches the update feed through the system URL cache, which leaves
   these behind even when no update was ever installed.

6. Clear the Input Monitoring permission:

   ```
   tccutil reset ListenEvent com.zzacong.AngryKeyboard
   ```

   This removes the saved grant. The row may stay in System Settings > Privacy &
   Security > Input Monitoring; select it and click the minus button to remove
   it.

The app has no helper process and no launch agent. Sparkle is the only other
writer, and these steps remove what it leaves behind.

## Manual verification

Check these by hand after a build.

### Capture

- Type in any app. Every key-down plays a sound.
- Enter plays the explosion, Esc the rocket whoosh, Backspace the shotgun blast,
  and Spacebar the shotgun cocking.
- Press any arrow key. It plays one of four impact sounds, chosen at random on
  every press.
- Every other key is usually the shotgun, with an occasional ahhh, ouch, or ough.
- Hold a key. The sound repeats while the key is held.
- Click, scroll, or press a modifier alone, such as Shift or Command. None of
  these make a sound.
- Focus a password field, then type. It stays silent. macOS Secure Input blocks
  the event tap, which is expected.

### Audio

- Move the volume slider while a sound is playing. The sound in flight follows
  the drag.
- Set a volume, quit, and relaunch. The slider comes back at the same value.
- Turn on Mute. The menu bar icon becomes the keyboard glyph struck through and
  keystrokes go silent. Quit and relaunch: it stays muted. Turn Mute off and sound
  returns.
- Toggle Overlap Sounds. Retrigger restarts one voice per key. Overlap stacks
  copies, so fast typing sounds different. Quit and relaunch: the choice is
  retained.
- Press arrow keys quickly in Overlap. The impact sounds stack, but never more
  than three at once.
- Type fast. There are no clicks, pops, or clipping.
- Hit the same key repeatedly. The pitch and level vary a little between hits.
- Sleep the Mac and wake it, or switch the output device. The next keystroke
  still makes a sound.

### Permission flow

- Remove AngryKeyboard from Input Monitoring if it is already listed, then
  launch. The explainer appears before any system prompt.
- Click Open System Settings. The system prompt appears, and System Settings
  opens to Privacy & Security > Input Monitoring with AngryKeyboard listed.
- Turn the switch on. The menu flips to Granted and typing makes sound without a
  relaunch.
- Turn the switch off. The menu flips to Not Granted and the app goes silent.
- Click Not Now on the explainer. The app stays silent, the menu reads Not
  Granted, and Open Input Monitoring Settings is still there.

### Menu controls

- Toggle Launch at Login. Open System Settings > General > Login Items and
  confirm the app matches the toggle.
- Click About Angry Keyboard. The standard About panel opens with the app name,
  icon, version, and build.
- Quit from the menu. The icon disappears.

## Troubleshooting

- If there is no sound, check the menu status is Granted, Mute is off, and the
  volume is not at zero.
- If the menu bar icon is missing, check Control Center's per-app Allow in Menu
  Bar switch on macOS 26. Turning it off hides the icon, but the app keeps
  running and playing. Turn it back on to reach the menu.
- After a rebuild, macOS may ask for Input Monitoring again when the build is
  ad-hoc signed. A clone with no certificate signs ad-hoc, and an ad-hoc
  signature is a hash of the binary, so the old grant no longer matches. Run
  `Scripts/setup-signing.sh` once to sign each channel with a stable
  certificate, or keep one build for everyday use.
- If a grant will not take, clear the stored approval and grant it again:

  ```
  tccutil reset ListenEvent com.zzacong.AngryKeyboard
  ```

  The reset drops the saved approval, so the next launch starts from the
  explainer and a fresh system request. It does not remove the app's row from
  the list; if that row is stuck, select it and click the minus button, which
  asks for your password.

## Logs

The app uses `NSLog` for audio load failures and audio engine failures. To
watch them while the app runs:

```
/usr/bin/log stream --predicate 'process == "AngryKeyboard"' --level debug
```

The full path matters. In zsh, the default shell on macOS, `log` is a shell
builtin and the bare command fails. Stop the stream with Ctrl-C.

## Learn more

- `CONTEXT.md` defines the vocabulary: keystroke, sound pack, binding, sound
  pool, catch-all, and playback mode.
- `docs/adr/` records the notable decisions.

## License

The code is MIT. See `LICENSE`. The sounds are not covered by it. See
`CREDITS.md`.
