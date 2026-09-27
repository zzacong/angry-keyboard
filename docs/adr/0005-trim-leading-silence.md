# Trim leading silence when a sound loads

A keystroke sound should start on the key. Three of the supplied MP3s are authored with dead air at the head: the explosion carries about 310 ms before its first audible sample, the blast about 300 ms, and the whoosh about 106 ms. The cocking sound and the shotgun are nearly clean, at about 12 ms and 16 ms. Untrimmed, Enter, Backspace, and Esc feel late, and holding one of those keys produces no row at all, because every key-repeat restarts the file inside its own silence and the sound never emerges.

We trim at load. `SoundOnset` scans the decoded channels in 2 ms windows and returns the first window whose RMS reaches −60 dBFS; `SoundSamples` then drops every frame before it and applies the usual end fades to the new start. The trim is in memory only, so the bundled MP3s stay untouched, and it is unconditional, so any sound added later is trimmed with no per-file configuration.

The trade-off is that this is a level heuristic, not a content detector. It removes near-silence, not a quiet intro that stays above the threshold, and a sound deliberately authored with a lead-in would lose it. That is the right default for an app whose whole job is to answer a key immediately, and the threshold and window sit in one place (`SoundOnset`) if it ever needs loosening.

Considered and rejected: a per-file trim offset in the pack. It would put a second, easily stale copy of each sound's shape in the model, and a new sound would need someone to measure it by hand. Considered and rejected: trimming the tail too. The spec puts tail trim windows out of scope, and a sound's decay is part of how it reads.
