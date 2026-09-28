import assert from "node:assert/strict";
import { test } from "node:test";
import { onsetFrame } from "./onset.ts";

/** Mirrors the app's `SoundOnsetTests` for the site's copy of the scan. */
const sampleRate = 48000;
const silence = (frames: number) => new Float32Array(frames);
const tone = (frames: number) => new Float32Array(frames).fill(0.5);

test("a sound that starts at frame zero has no onset", () => {
  assert.equal(onsetFrame([tone(480)], sampleRate), 0);
});

test("all silence has no onset so the caller leaves it untouched", () => {
  assert.equal(onsetFrame([silence(4800)], sampleRate), 0);
});

test("leading silence is skipped", () => {
  const samples = silence(480 + 4800);
  samples.fill(0.5, 480);
  assert.equal(onsetFrame([samples], sampleRate), 480);
});

test("the onset lands within one window of the true start", () => {
  const trueStart = 336; // 7 ms, not a window boundary
  const samples = silence(trueStart + 4800);
  samples.fill(0.5, trueStart);
  const onset = onsetFrame([samples], sampleRate);
  assert.ok(onset > trueStart - 96 && onset <= trueStart, `onset was ${onset}`);
});

test("a stray blip below the threshold does not set the onset", () => {
  const samples = silence(4800);
  samples[10] = 0.0005; // below −60 dBFS
  samples.fill(0.5, 1920);
  assert.equal(onsetFrame([samples], sampleRate), 1920);
});

test("an onset in one channel is enough", () => {
  const left = silence(960 + 1920);
  left.fill(0.5, 960);
  const right = silence(2880);
  assert.equal(onsetFrame([left, right], sampleRate), 960);
});
