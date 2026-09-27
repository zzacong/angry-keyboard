// Builds .scratch/marketing-site/index.html from _src/template.html.
// The nine MP3s from AngryKeyboard/Sounds are inlined as base64 data URIs so the
// prototype is one self-contained file that opens by double-click and survives
// being emailed around.
//
//   bun .scratch/marketing-site/_src/build.mjs        (or: node ...)
//
// Run from anywhere. Re-run after editing template.html or swapping a sound.

import { readFileSync, writeFileSync, readdirSync, existsSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { dirname, join } from "node:path";

const here = dirname(fileURLToPath(import.meta.url));
const protoDir = join(here, "..");
const soundsDir = join(protoDir, "..", "..", "AngryKeyboard", "Sounds");
const templatePath = join(here, "template.html");
const outPath = join(protoDir, "index.html");

if (!existsSync(soundsDir)) {
  console.error(`No sounds directory at ${soundsDir}`);
  process.exit(1);
}

const sounds = {};
for (const file of readdirSync(soundsDir).filter((f) => f.endsWith(".mp3")).sort()) {
  const name = file.replace(/\.mp3$/, "");
  const bytes = readFileSync(join(soundsDir, file));
  sounds[name] = `data:audio/mpeg;base64,${bytes.toString("base64")}`;
}

const keys = Object.keys(sounds);
if (keys.length === 0) {
  console.error("No .mp3 files found to inline.");
  process.exit(1);
}

const template = readFileSync(templatePath, "utf8");
if (!template.includes("__SOUNDS_JSON__")) {
  console.error("template.html is missing the __SOUNDS_JSON__ placeholder.");
  process.exit(1);
}

const html = template.replace("__SOUNDS_JSON__", JSON.stringify(sounds));
writeFileSync(outPath, html);

const kb = (Buffer.byteLength(html) / 1024).toFixed(0);
console.log(`Wrote ${outPath}`);
console.log(`Inlined ${keys.length} sounds: ${keys.join(", ")}`);
console.log(`Self-contained size: ${kb} KB`);
