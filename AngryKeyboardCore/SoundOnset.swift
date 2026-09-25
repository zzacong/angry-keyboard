/// Finds where a decoded sound actually begins, so a file authored with dead
/// air does not delay the key that plays it.
///
/// A pure scan over channel samples: no decoding and no audio engine, so it can
/// be tested with plain arrays. The app trims each sound to this frame at load,
/// which keeps every bundled sound, present or future, starting on the key.
nonisolated enum SoundOnset {
    /// The level a window must reach to count as sound, in linear amplitude
    /// (−60 dBFS). Anything below reads as silence.
    static let threshold: Float = 0.001

    /// The window used to judge, long enough that a single stray sample cannot
    /// set the onset.
    static let windowSeconds: Double = 0.002

    /// The first frame that carries sound, or zero when the whole sound reads
    /// as silence so callers leave it untouched.
    ///
    /// The scan steps in non-overlapping windows, so the result lands within
    /// one window of the true onset. A sound crossing the threshold in any
    /// channel counts, since a channel panned hard is still the sound.
    static func frame(of channels: [[Float]], sampleRate: Double) -> Int {
        let frameCount = channels.map(\.count).min() ?? 0
        guard frameCount > 0 else { return 0 }

        let window = max(1, Int(windowSeconds * sampleRate))
        var start = 0
        while start < frameCount {
            let end = min(start + window, frameCount)
            var energy: Float = 0
            for frame in start..<end {
                var peak: Float = 0
                for channel in channels {
                    let amplitude = abs(channel[frame])
                    if amplitude > peak { peak = amplitude }
                }
                energy += peak * peak
            }
            if (energy / Float(end - start)).squareRoot() >= threshold { return start }
            start = end
        }
        return 0
    }
}
