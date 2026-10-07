# AngryKeyboard MVP

**Status:** resolved

## Problem Statement

Zac types all day and the act is silent. He wants it to sound loud instead. He wants a gunshot on every keystroke, different sounds on the keys that deserve them, and a way to control it from the menu bar without a window in the way. He also wants to be able to try a couple of playback feels before committing to one, because he cannot predict which sounds better.

## Solution

AngryKeyboard is a macOS menu bar app. Once the user grants Input Monitoring, it listens to keystrokes system wide and plays a sound on each one. A sound pack assigns a sound to Enter, Esc, Backspace, and Spacebar, and a catch-all sound to every other key. The menu holds the controls: pack, volume, mute, an overlap toggle, launch at login, permission status, and quit. There is no window and no Dock icon.

The key mapping the app ships with:

| Key             | Sound                 | Length |
| --------------- | --------------------- | ------ |
| Enter           | `explode-rock.mp3`    | 5.85 s |
| Esc             | `rocket-whoosh.mp3`   | 3.84 s |
| Backspace       | `shotgun-blast.mp3`   | 2.98 s |
| Spacebar        | `shotgun-cocking.mp3` | 0.86 s |
| Every other key | `shotgun.mp3`         | 3.67 s |

## User Stories

1. As someone typing all day, I want a sound on every keystroke, so that typing feels loud instead of silent.
2. As a user, I want the app to live in the menu bar, so that it stays out of the way of my work.
3. As a user, I want no Dock icon and no window, so that the app never interrupts what I am doing.
4. As a user, I want to quit from the menu, so that I control when it stops.
5. As a user, I want a first-run explainer, so that I understand why the app needs Input Monitoring before macOS asks me.
6. As a user, I want a button that opens the exact System Settings pane, so that I do not have to hunt for it.
7. As a user, I want to see permission status in the menu, so that I know whether the app can hear me.
8. As a user, I want the status to update when I grant or revoke permission, so that I do not have to relaunch.
9. As a user, I want silence while permission is not granted, so that the app never pretends to work.
10. As a user, I want Enter to play the explosion, so that the most deliberate key has the biggest sound.
11. As a user, I want Esc to play the rocket whoosh, so that cancelling has its own sound.
12. As a user, I want Backspace to play the shotgun blast, so that correcting a mistake sounds like destruction.
13. As a user, I want Spacebar to play the shotgun cocking, so that the most common key still sounds distinct.
14. As a user, I want every other key to play the shotgun, so that nothing I type is silent.
15. As a user, I want a held key to keep firing, so that leaning on a key sounds like sustained fire.
16. As a user, I want no sound for mouse clicks, scrolls, or modifier-only presses, so that only typing fires.
17. As a user, I want silence while a password field is focused, so that my keystrokes are not announced while I sign in.
18. As a fast typist, I want a new sound to retrigger the previous one, so that rapid typing sounds like gunfire instead of mud.
19. As a user, I want a toggle to try overlap instead, so that I can pick the feel I prefer.
20. As a user, I want each key to control how many copies of its sound can play at once, so that the app can be tuned per key.
21. As a user, I want fast typing to avoid clicks and clipping, so that it never sounds broken.
22. As a user, I want repeated hits of the same sound to vary slightly, so that they do not sound like a loop.
23. As a user, I want a volume slider, so that I can fit the app to my room.
24. As a user, I want the default volume to be 60%, so that it starts at a sensible level.
25. As a user, I want volume to survive a relaunch, so that I only set it once.
26. As a user, I want a mute toggle, so that I can silence the app without quitting it.
27. As a user, I want mute to persist, so that I am not surprised by noise after a restart.
28. As a user, I want the menu bar icon to change while muted, so that I am never confused about why it is quiet.
29. As a user, I want the app to launch at login, so that it is there without me opening it.
30. As a user, I want the launch-at-login toggle to reflect the real system state, so that it never lies to me.
31. As a user, I want the pack picker to stay hidden while there is only one pack, so that the menu stays clean.
32. As a user, I want the app to bundle its sounds, so that it does not depend on files on my Desktop.
33. As a user, I want audio to keep working after long idle periods, so that the tap never silently dies.
34. As a user adding sounds later, I want the pack model to hold more than one pack, so that a second pack is a drop-in.
35. As a user considering sharing the app, I want a path to a signed and notarized build, so that a personal tool can become distributable.

## Implementation Decisions

**App shape.** The app is a menu bar agent. It has no window and no Dock icon. It owns its status item through an `AppDelegate` rather than `MenuBarExtra`, so the process survives the macOS 26 "Allow in Menu Bar" toggle being switched off. See ADR 0003.

**Capture.** A listen-only `CGEventTap` inserted at the head of the session tap, running on a dedicated thread, not the main thread. It requires Input Monitoring. The app requests access with `CGRequestListenEventAccess` and checks it with `CGPreflightListenEventAccess`, because the request call only prompts once. The callback re-enables the tap on `tapDisabledByTimeout` and `tapDisabledByUserInput`. Secure Input silences the tap while a password field is focused, which is expected behavior.

**Audio.** A single `AVAudioEngine` starts at launch and stays running. The five MP3 files decode once at load into PCM buffers held in memory. Playback uses a pool of player nodes that stay in a playing state, with buffers scheduled into them, rather than calling play per keystroke. Each binding has a voice count. A voice count of one behaves as retrigger by stealing and restarting the single voice. A higher count allows overlap up to that count. A peak limiter sits on the mix, and each hit gets a small random pitch and gain change.

**Model.** A sound pack is a named list of bindings plus the sounds they point at. One binding is the catch-all, and it is the last rule. Vocabulary comes from `CONTEXT.md` (keystroke, sound pack, binding, catch-all). v1 ships one pack, expressed as typed Swift rather than parsed from a file, because one static pack does not need a parser and a misspelled key name becomes a compile error.

**Resolver.** The decision of which sound a keystroke plays is a pure function from a keystroke (key code plus modifier flags) to an optional binding. This is the single test seam for the feature.

**Settings.** Volume and mute persist across launches. Volume defaults to 60%. Launch at login uses `SMAppService.mainApp`, and its state is read live from the system rather than stored a second time. Permission state is read live and rechecked on launch and on focus.

**Distribution.** v1 is not sandboxed and does not ship through the Mac App Store. It voluntarily stays within the sandbox-compatible subset, meaning listen-only capture, Input Monitoring, and no synthetic event posting, so a later Developer ID or App Store release does not need a rewrite. See ADR 0001.

**Assets.** The five supplied MP3 files, sourced from `~/Desktop/assets`, are bundled inside the app. The app must not read them from the Desktop at runtime.

**Starting point.** Build from scratch. Do not read or reuse any worktree or proof of concept in or near this repo; ignore it entirely.

## Testing Decisions

A good test asserts external behavior, not implementation detail. For this feature that means a keystroke goes in and the binding to play comes out. A good test does not start an audio engine, request a permission, or touch a real keyboard.

The resolver is the module under test, and it is the same single seam described in the Implementation Decisions. Tests cover the key-to-binding mapping, the catch-all fallback for unbound keys, and keystrokes that map to nothing. The test target itself is created alongside this work, so there is no prior art in the repo yet; these are the first tests.

Everything the resolver cannot cover stays a manual checklist: the real event tap, the real audio path, and the permission flow. No UI snapshot tests.

## Out of Scope

- A second sound pack, user-imported sounds, and any per-key editing UI.
- A global mute hotkey.
- Trim windows that shorten a sound's tail.
- Sounds for mouse clicks, scrolls, media keys, or modifier-only presses.
- A Mac App Store release, code signing, notarization, and DMG packaging.
- App icon and branding work.

## Further Notes

**Source assets.** The five MP3 files and the key mapping text file live in `~/Desktop/assets`. Copy the audio into the repo so the project is self-contained. The Desktop copies are the originals and should be left alone.

**Why decode at launch.** The five files total about 17 seconds of audio, which decodes to roughly 3.5MB of PCM. Holding that in memory is trivial, it needs no build step, and it leaves no converted duplicates in the repo. Decoding lazily would add first-play latency.

**Why retrigger is the default.** The default shotgun is 3.67 seconds. At 80 words per minute a typist presses about 7 keys per second, so playing every sound to completion would need roughly 25 overlapping voices to avoid cutting, and 25 overlapping shotguns clip and turn to mud. Retrigger keeps one voice per key and produces the rapid-fire feel. The overlap toggle exists so this can be judged by ear rather than by argument.

**Ignore the worktree.** Any worktree or proof of concept found in or near this repo is off limits. Do not read its implementation and do not depend on it.

**Tickets.** The implementation is broken into tickets `01` through `06` under `.scratch/mvp/issues`, numbered in dependency order.
