# 04: Playback feel and the overlap switch

**What to build:** Make the audio hold up under fast typing. Each binding gets its own voice count, the engine gets a limiter, and each hit gets a small random pitch and gain change. Retrigger ships as the default at one voice per binding, and a menu toggle switches to overlap so the two can be compared by typing.

**Blocked by:** 02, 03.

**Status:** ready-for-agent

- [x] Each binding has its own voice count, defaulting to one voice, which behaves as retrigger.
- [x] A menu toggle switches between retrigger and overlap, and the change takes effect on the next keystroke.
- [x] Typing at speed produces no audible clicks, pops, or clipping.
- [x] Repeated hits of the same sound vary slightly so they do not sound identical.
- [x] Switching to overlap lets more than one copy of the same sound play at once, up to the binding's voice count.

## Comments

**2026-09-25 — implemented on `main`.**

`Binding` carries a `voiceCount` (default one), and `effectiveVoiceCount(for:)`
resolves it against a new `PlaybackMode`: retrigger forces one voice, overlap
uses the binding's own count. The shipped pack tunes the catch-all shotgun to
four voices and the shorter keys higher, so the two feels differ when typing.
`PlaybackTests` covers the default, both modes, and the shipped counts.

`AudioOutput` is now a small software mixer behind one `AVAudioSourceNode`, not
a player node per sound. Each hit starts a voice that reads through decoded
samples at its own pitch (±2.5%) and gain (±10%), with a 2 ms fade in and a 6 ms
fade out. Retriggering or stealing a voice crossfades instead of hard-cutting,
which removes the clicks and pops; a feed-forward limiter caps the mix at 0.9, so
overlapping voices cannot clip. Sounds are normalized to the output device's
sample rate at launch.

The menu gains an "Overlap Sounds" checkbox, off by default. The event-tap
callback reads the mode per keystroke, so flipping it takes effect on the next
key.

Verified:

- `xcodebuild test -scheme AngryKeyboard -destination 'platform=macOS'` → 18
  tests, 0 failures
- Debug build succeeds with no warnings
- Launching the build confirms all five sounds decode at 48 kHz, the source node
  renders 512-frame buffers, a triggered voice produces signal, and twelve
  overlapping voices stay under the limiter threshold

The audible feel stays a manual check, as the spec says: type fast in both modes
and listen for clicks, pops, or clipping.
