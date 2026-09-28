# AngryKeyboard default-key sound pool

**Status:** ready-for-agent

## Problem Statement

Every key without a binding of its own plays the same shotgun sound, forever. Three new Pixabay reaction sounds (`annn`, `ouch`, `ough`) should fold into the default keys so they mostly keep the shotgun but sometimes play a reaction. The pool cannot express that today: it draws uniformly, so a heavier sound has no way to dominate. The shotgun file is also 3.67 s, of which only the first second carries the blast; the rest is decay that lengthens every voice for nothing.

## Solution

A sound pool gains a weight per sound and draws in proportion to it; equal weights are the uniform behaviour, so the arrow pool is untouched. The catch-all becomes an ordinary binding to a pool of `shotgun` (weight 4) with `ahhh`, `ouch`, and `ough` (weight 1 each), keeping its voice cap of 4. The three reaction MP3s join `AngryKeyboard/Sounds/`, and `shotgun.mp3` is trimmed to its loudest first second. The site's live deck and sound list mirror the change.

## Decisions

- A pool draws in proportion to per-sound weights; equal weights are the uniform case. See ADR 0010.
- Weights live on the pool, not the binding, so bindings that share a pool share its draw and its voice count.
- A non-positive weight is a programmer error, like an empty pool.
- `SoundPack` takes its catch-all as a `SoundPool`, not a bare `Sound`.
- The catch-all pool is `shotgun` at weight 4 and `ahhh`, `ouch`, `ough` at weight 1 each: about 57% / 14% / 14% / 14%.
- The catch-all voice count stays 4; the trimmed shotgun frees the cap sooner on its own.
- `annn.mp3` is renamed `ahhh.mp3`; `ouch.mp3` and `ough.mp3` keep their names.
- `shotgun.mp3` is trimmed to its first 1.0 s (0.00–1.00) by stream copy, `ffmpeg -c copy`, with no re-encode: `ffmpeg -i shotgun.mp3 -t 1.0 -c copy <out>.mp3`.
- The three new sounds join the Pixabay list in `CREDITS.md`.
- The site mirrors the app: a weighted default pick in `deck.ts` and an updated catch-all row in `Sounds.astro`. App and site land in separate commits.

## Work

App:

- `Sound`: add `ahhh`, `ouch`, `ough` cases, raw values equal to the file names.
- `SoundPool`: carry per-sound weights, draw in proportion, reject non-positive weights. A weightless initializer stays for the uniform pools.
- `SoundPack`: `catchAll` becomes a `SoundPool`; the shipped pack points it at the weighted pool.
- `README.md`: the sound-pack description (lines 204–208) and the vocabulary line.
- `CREDITS.md`: the three new files.

Tests:

- `SoundPoolTests`: a pool of one still always draws it; the arrow pool still draws uniformly; the weighted pool draws in roughly its weight ratio; every sound can still be drawn.
- `ResolverTests`: the catch-all assertions move from "plays the shotgun" to "points at the weighted pool".
- `PlaybackTests`: unchanged; confirm the catch-all voice cap still reads from the pool.

Site:

- `site/src/lib/deck.ts`: import the three sounds, add them to `SoundName`, and make the default branch a weighted pick.
- `site/src/components/Sounds.astro`: the catch-all row reads "mostly the shotgun, plus ouch / ough / ahhh".
- `site/README.md`: "nine sounds" becomes twelve.

## Assets

`shotgun.mp3` trims from 0.00–1.00 s. Measured RMS per 0.25 s window: 4535, 2006, 465, 147, 187, 217, 315, 231, then silence after 2.0 s, so the head is the whole blast.
