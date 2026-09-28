/** Finds where a decoded sound actually begins, so a file authored with dead air
 * does not delay the key that plays it. Mirrors the app's `SoundOnset`. */

/**
 * The first frame that carries sound, or zero when the whole clip reads as
 * silence. The scan steps in non-overlapping 2 ms windows and counts any
 * channel, matching the app, so the result lands within one window of the true
 * onset.
 */
export function onsetFrame(
  channels: Float32Array[],
  sampleRate: number,
): number {
  const frameCount =
    channels.length === 0
      ? 0
      : Math.min(...channels.map((channel) => channel.length));
  if (frameCount === 0) return 0;

  const threshold = 0.001; // −60 dBFS, in linear amplitude
  const window = Math.max(1, Math.round(0.002 * sampleRate));

  for (let start = 0; start < frameCount; start += window) {
    const end = Math.min(start + window, frameCount);
    let energy = 0;
    for (let frame = start; frame < end; frame++) {
      let peak = 0;
      for (const channel of channels) {
        const amplitude = Math.abs(channel[frame]!);
        if (amplitude > peak) peak = amplitude;
      }
      energy += peak * peak;
    }
    if (Math.sqrt(energy / (end - start)) >= threshold) return start;
  }
  return 0;
}

/** Where a decoded clip starts, in seconds: the offset a source should play from. */
export function onsetSeconds(buffer: AudioBuffer): number {
  const channels = Array.from(
    { length: buffer.numberOfChannels },
    (_, channel) => buffer.getChannelData(channel),
  );
  return onsetFrame(channels, buffer.sampleRate) / buffer.sampleRate;
}
