import assert from "node:assert/strict";
import { test } from "node:test";
import { KEY_BINDINGS, keyGroupFor } from "./key-bindings.ts";

test("the guide covers each supported key group once", () => {
  assert.deepEqual(
    KEY_BINDINGS.map(({ group }) => group),
    ["space", "enter", "backspace", "escape", "arrows", "any"],
  );
});

test("the floating hint names each supported key group", () => {
  assert.deepEqual(
    KEY_BINDINGS.map(({ guideKey }) => guideKey),
    ["spacebar", "enter", "backspace", "escape", "arrow keys", "any key"],
  );
});

test("special keys map to their guide groups", () => {
  assert.equal(keyGroupFor(" "), "space");
  assert.equal(keyGroupFor("Enter"), "enter");
  assert.equal(keyGroupFor("Backspace"), "backspace");
  assert.equal(keyGroupFor("Escape"), "escape");
});

test("all arrow keys share one guide group", () => {
  assert.equal(keyGroupFor("ArrowUp"), "arrows");
  assert.equal(keyGroupFor("ArrowDown"), "arrows");
  assert.equal(keyGroupFor("ArrowLeft"), "arrows");
  assert.equal(keyGroupFor("ArrowRight"), "arrows");
});

test("ordinary sound-triggering keys use the catch-all group", () => {
  assert.equal(keyGroupFor("a"), "any");
  assert.equal(keyGroupFor("Tab"), "any");
});

test("modifier keys do not map to a sound group", () => {
  for (const key of [
    "Alt",
    "CapsLock",
    "ContextMenu",
    "Control",
    "Meta",
    "Shift",
  ]) {
    assert.equal(keyGroupFor(key), null);
  }
});
