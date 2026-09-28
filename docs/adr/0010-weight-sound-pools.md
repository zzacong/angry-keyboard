# Weight a sound pool's draw, and let the catch-all be a pool

The catch-all played one sound, the shotgun. Adding three reaction sounds means the default keys should mostly keep the shotgun but sometimes play a reaction, so the draw has to favour one sound over the others. ADR 0006 fixed the pool as the unit of selection and voice-counting, but drew uniformly.

So a pool now carries a weight per sound and draws in proportion to it; equal weights are the uniform case, so the arrow pool is unchanged. Weights live on the pool rather than the binding because the pool is already the shared unit: two bindings pointing at one pool share its draw and its voice count, and it would be odd to share one and not the other. The catch-all is now an ordinary binding to a pool instead of a bare sound, which removes a special case from `SoundPack`.

Considered and rejected: repeating a sound in the list to weight it. It needs no new type, but the same sound appears many times, the weights are invisible in the data, and the pool stops being a set. Considered and rejected: a separate weighted pool type. It protects the uniform pool, but the audio engine and voice keying would handle two pool types for no gain.

A non-positive weight is rejected, matching the empty-pool precondition: a sound that never plays does not belong in the pool. Pool identity now includes the weights, which is what voice counting wants — a reweighted pool is a different pool.
