# AngryKeyboard

A macOS menu bar app that plays a sound on every keystroke, system wide.

It has no window and no Dock icon. The app lives in the menu bar as a keyboard icon.

## Requirements

- macOS 14.0 (Sonoma) or later

## Build and run

Building from source needs Xcode 27.0 or later. Running the app needs only
macOS; Xcode is not a runtime dependency.

### Xcode

1. Open the project:

   ```
   open AngryKeyboard.xcodeproj
   ```

2. Select the AngryKeyboard scheme and press Run (Cmd-R).
3. The app launches with no window. Look for the keyboard icon in the menu bar.

### Command line

```
xcodebuild -scheme AngryKeyboard -configuration Debug -derivedDataPath build build
open build/Build/Products/Debug/AngryKeyboard.app
```

The app is built at `build/Build/Products/Debug/AngryKeyboard.app`.

### Tests

```
xcodebuild test -scheme AngryKeyboard -destination 'platform=macOS'
```

The test target covers the resolver, the settings model, playback voice math, and
sound onset detection. Capture, audio, and permissions cannot be unit tested, so
they have a manual checklist below.

### Local signing

Xcode signs a build ad-hoc by default when there is no team. An ad-hoc
signature is identified by a hash of the binary, so it changes on every build.
macOS keys the Input Monitoring grant to that identity, so each rebuild looks
like a new app and the grant is lost. This is the rebuild caveat in
Troubleshooting.

To hold one identity across builds, sign with a self-signed certificate:

1. Open Keychain Access, then Keychain Access > Certificate Assistant > Create a
   Certificate.
2. Name it, set Identity Type to Self-Signed Root and Certificate Type to Code
   Signing. Check "Let me override defaults" to reach Validity Period, and set it
   to 3650 days (the default is 365).
3. In the project, select the AngryKeyboard target > Signing & Capabilities,
   uncheck Automatically manage signing, and set Signing Certificate to the
   certificate's name.
4. Grant Input Monitoring once. The grant then survives rebuilds.

A free Apple ID works too, with no certificate to manage: add it under Xcode >
Settings > Accounts, set the target's Team to the Personal Team, and Xcode signs
with an Apple Development certificate it renews each year. It needs an Apple ID
signed in, and it buys nothing locally that the self-signed certificate does not.

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

## Manual verification

Check these by hand after a build.

### Capture

- Type in any app. Every key-down plays a sound.
- Enter plays the explosion, Esc the rocket whoosh, Backspace the shotgun blast,
  and Spacebar the shotgun cocking.
- Press any arrow key. It plays one of four impact sounds, chosen at random on
  every press.
- Every other key plays the shotgun.
- Hold a key. The sound repeats while the key is held.
- Click, scroll, or press a modifier alone, such as Shift or Command. None of
  these make a sound.
- Focus a password field, then type. It stays silent. macOS Secure Input blocks
  the event tap, which is expected.

### Audio

- Move the volume slider while a sound is playing. The sound in flight follows
  the drag.
- Set a volume, quit, and relaunch. The slider comes back at the same value.
- Turn on Mute. The menu bar icon becomes a crossed-out speaker and keystrokes go
  silent. Quit and relaunch: it stays muted. Turn Mute off and sound returns.
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
- After a rebuild, macOS may ask for Input Monitoring again. A locally signed
  Debug build can change identity between builds, so the old grant no longer
  matches. Grant it again, or keep one build for everyday use.

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
- `.scratch/mvp/spec.md` is the MVP spec.

## License

MIT. See `LICENSE`.
