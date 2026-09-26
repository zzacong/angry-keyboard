# Draw a binding's random sound at play time, and count voices per pool

The four arrow keys should play one of four impact sounds at random, not a fixed one-to-one mapping. That is a binding whose sound is not known until the moment it plays, which the model did not have: a binding pointed at exactly one sound, and the resolver is a pure function of the keystroke and the pack.

So a binding now points at a **sound pool**, and the sound is drawn in the audio output, not the resolver. The resolver still returns a binding from a keystroke alone, so it stays pure and its tests stay plain values with no generator. `AudioOutput.play` draws one sound from the pool and counts voices against the pool rather than the sound. All four arrow bindings share one pool, so retrigger keeps a single arrow voice and overlap caps the arrows at three together, no matter which sound each press drew.

Considered and rejected: drawing in the resolver with an injected generator. It keeps the choice in one place, but it makes the resolver impure and every resolver test has to carry a seeded generator to stay deterministic. Considered and rejected: counting voices per sound. It is simpler in the engine, since a voice already knows its sound, but it lets fast arrow presses stack four independent pools, so retrigger would no longer mean one arrow voice at a time, which defeats the mode.

The cost is that the audio engine now knows the pool as a voice key, and which sound plays is decided by a side-effecting component. That is where randomness already lives, next to the per-hit pitch and gain spread, so the resolver and the model stay deterministic.
