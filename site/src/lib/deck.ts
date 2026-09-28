import * as stylex from "@stylexjs/stylex";
import { styles } from "@/components/deck.stylex";
import { onsetSeconds } from "@/lib/onset";
import ahhhUrl from "../../../AngryKeyboard/Sounds/ahhh.mp3?url";
import combatImpactUrl from "../../../AngryKeyboard/Sounds/combat-impact.mp3?url";
import explodeRockUrl from "../../../AngryKeyboard/Sounds/explode-rock.mp3?url";
import kungFuYellUrl from "../../../AngryKeyboard/Sounds/kung-fu-yell.mp3?url";
import ouchUrl from "../../../AngryKeyboard/Sounds/ouch.mp3?url";
import oughUrl from "../../../AngryKeyboard/Sounds/ough.mp3?url";
import punchImpactUrl from "../../../AngryKeyboard/Sounds/punch-impact-hit.mp3?url";
import punchUrl from "../../../AngryKeyboard/Sounds/punch.mp3?url";
import rocketWhooshUrl from "../../../AngryKeyboard/Sounds/rocket-whoosh.mp3?url";
import shotgunBlastUrl from "../../../AngryKeyboard/Sounds/shotgun-blast.mp3?url";
import shotgunCockingUrl from "../../../AngryKeyboard/Sounds/shotgun-cocking.mp3?url";
import shotgunUrl from "../../../AngryKeyboard/Sounds/shotgun.mp3?url";

// The live demo deck. It mirrors the shipped app: one binding per keystroke,
// one voice per sound retriggered on repeat, three voices on arrow impacts, and
// a small random pitch and gain on every hit, starting where the sound does
// past any dead air. The twelve MP3s are imported from the app's own Sounds
// directory, so the site can never drift from the app.

const IMPACTS = [
  "combat-impact",
  "kung-fu-yell",
  "punch",
  "punch-impact-hit",
] as const;

export type ImpactSound = (typeof IMPACTS)[number];

// The catch-all pool, mirroring the app's SoundPool: the shotgun is four times
// as likely as each reaction. The catch-all covers every key without its own
// sound.
const CATCH_ALL_POOL = [
  ["shotgun", 4],
  ["ahhh", 1],
  ["ouch", 1],
  ["ough", 1],
] as const satisfies readonly (readonly [SoundName, number])[];

type CatchAllSound = (typeof CATCH_ALL_POOL)[number][0];

export type SoundName =
  | "ahhh"
  | "explode-rock"
  | "ouch"
  | "ough"
  | "rocket-whoosh"
  | "shotgun"
  | "shotgun-blast"
  | "shotgun-cocking"
  | ImpactSound;

// Voices are counted per pool, so the four impacts share one cap of three and
// the four catch-all sounds share one cap of one.
type Pool =
  | "catch-all"
  | "explode-rock"
  | "impact"
  | "rocket-whoosh"
  | "shotgun-blast"
  | "shotgun-cocking";

const SOURCES = {
  ahhh: ahhhUrl,
  "combat-impact": combatImpactUrl,
  "explode-rock": explodeRockUrl,
  "kung-fu-yell": kungFuYellUrl,
  ouch: ouchUrl,
  ough: oughUrl,
  punch: punchUrl,
  "punch-impact-hit": punchImpactUrl,
  "rocket-whoosh": rocketWhooshUrl,
  shotgun: shotgunUrl,
  "shotgun-blast": shotgunBlastUrl,
  "shotgun-cocking": shotgunCockingUrl,
} satisfies Record<SoundName, string>;

const VOICES: Record<Pool, number> = {
  "catch-all": 1,
  "explode-rock": 1,
  impact: 3,
  "rocket-whoosh": 1,
  "shotgun-blast": 1,
  "shotgun-cocking": 1,
};

const LABELS: Record<SoundName, string> = {
  ahhh: "ahhh",
  "combat-impact": "impact",
  "explode-rock": "explosion",
  "kung-fu-yell": "impact",
  ouch: "ouch",
  ough: "ough",
  punch: "impact",
  "punch-impact-hit": "impact",
  "rocket-whoosh": "rocket whoosh",
  shotgun: "shotgun",
  "shotgun-blast": "shotgun blast",
  "shotgun-cocking": "shotgun cock",
};

const MODIFIER_KEYS = new Set([
  "Alt",
  "CapsLock",
  "ContextMenu",
  "Control",
  "Meta",
  "Shift",
]);

function isImpact(name: SoundName): name is ImpactSound {
  return (IMPACTS as readonly string[]).includes(name);
}

function isCatchAll(name: SoundName): name is CatchAllSound {
  return CATCH_ALL_POOL.some(([sound]) => sound === name);
}

const poolOf = (name: SoundName): Pool => {
  if (isImpact(name)) return "impact";
  if (isCatchAll(name)) return "catch-all";
  return name;
};

/** One sound from `pool`, drawn in proportion to its weight. */
function pickWeighted(
  pool: readonly (readonly [SoundName, number])[],
): SoundName {
  let pick = Math.random() * pool.reduce((sum, [, weight]) => sum + weight, 0);
  for (const [sound, weight] of pool) {
    if (pick < weight) return sound;
    pick -= weight;
  }
  return pool[0]![0];
}

type Clip = {
  buffer: AudioBuffer;
  /** Where the sound actually starts, past any dead air the file opens with. */
  onset: number;
};

/** The app's resolver, as a plain function over a key name. */
export function resolveSound(key: string): SoundName | null {
  if (MODIFIER_KEYS.has(key)) return null;
  switch (key) {
    case "Enter":
      return "explode-rock";
    case "Escape":
      return "rocket-whoosh";
    case "Backspace":
      return "shotgun-blast";
    case " ":
      return "shotgun-cocking";
    default:
      break;
  }
  if (key.startsWith("Arrow")) {
    const pick = IMPACTS[Math.floor(Math.random() * IMPACTS.length)];
    return pick ?? "combat-impact";
  }
  return pickWeighted(CATCH_ALL_POOL);
}

type Board = {
  ensure: () => Promise<void>;
  fire: (name: SoundName) => void;
  setMuted: (muted: boolean) => void;
  setVolume: (volume: number) => void;
};

function createBoard(): Board {
  let context: AudioContext | null = null;
  let master: GainNode | null = null;
  let clips: Record<SoundName, Clip> | null = null;
  let loading: Promise<void> | null = null;
  const playing: Partial<Record<Pool, AudioBufferSourceNode[]>> = {};
  let volume = 0.6;
  let muted = false;

  function ensure(): Promise<void> {
    if (loading) return loading;
    context = new AudioContext();
    if (context.state === "suspended") void context.resume();

    const limiter = context.createDynamicsCompressor();
    limiter.threshold.value = -6;
    limiter.knee.value = 6;
    limiter.ratio.value = 12;

    master = context.createGain();
    master.gain.value = muted ? 0 : volume;
    master.connect(limiter).connect(context.destination);

    loading = Promise.all(
      Object.entries(SOURCES).map(async ([name, url]) => {
        const bytes = await (await fetch(url)).arrayBuffer();
        const buffer = await context!.decodeAudioData(bytes);
        clips = {
          ...(clips ?? ({} as Record<SoundName, Clip>)),
          [name]: { buffer, onset: onsetSeconds(buffer) },
        };
      }),
    ).then(() => undefined);
    return loading;
  }

  function fire(name: SoundName): void {
    if (!context || !clips || !master) return;
    const clip = clips[name];
    if (!clip) return;

    const pool = poolOf(name);
    const source = context.createBufferSource();
    source.buffer = clip.buffer;
    source.playbackRate.value = 1 + (Math.random() * 0.1 - 0.05);

    // A short fade in, matching the app, so starting on the onset never steps
    // the waveform into a click.
    const gain = context.createGain();
    const now = context.currentTime;
    gain.gain.setValueAtTime(0, now);
    gain.gain.linearRampToValueAtTime(0.9 + Math.random() * 0.2, now + 0.002);
    source.connect(gain).connect(master);

    // Retrigger: a pool of one steals its own voice; larger pools stack to the cap.
    const live = playing[pool] ?? (playing[pool] = []);
    if (live.length >= VOICES[pool]) live.shift()?.stop();
    live.push(source);
    source.onended = () => {
      const index = live.indexOf(source);
      if (index > -1) live.splice(index, 1);
    };
    // Start where the sound does, so dead air in the file never delays the key.
    source.start(0, clip.onset);

    // The hook the animation pass listens for.
    document.dispatchEvent(new CustomEvent("ak:fire"));
  }

  return {
    ensure,
    fire,
    setMuted(next: boolean) {
      muted = next;
      if (master) master.gain.value = next ? 0 : volume;
    },
    setVolume(next: number) {
      volume = next;
      if (master) master.gain.value = muted ? 0 : next;
    },
  };
}

function element<T extends Element>(
  root: ParentNode,
  selector: string,
): T | null {
  return root.querySelector<T>(selector);
}

function mountDeck(root: HTMLElement, board: Board): void {
  const input = element<HTMLTextAreaElement>(root, "[data-demo-input]");
  const status = element<HTMLElement>(root, "[data-demo-status]");
  const dot = element<HTMLElement>(root, "[data-demo-dot]");
  const lastEl = element<HTMLElement>(root, "[data-demo-last]");
  const logEl = element<HTMLElement>(root, "[data-demo-log]");
  const muteBtn = element<HTMLButtonElement>(root, "[data-demo-mute]");
  const volumeEl = element<HTMLInputElement>(root, "[data-demo-vol]");
  const flash = element<HTMLElement>(root, "[data-demo-flash]");
  if (
    !input ||
    !status ||
    !dot ||
    !lastEl ||
    !logEl ||
    !muteBtn ||
    !volumeEl ||
    !flash
  ) {
    return;
  }

  const countEls = root.querySelectorAll<HTMLElement>("[data-demo-count]");
  let shots = 0;
  let armed = false;

  const arm = (): void => {
    if (armed) return;
    armed = true;
    void board.ensure();
    status.textContent = "Live";
    dot.className = stylex.props(styles.dot, styles.dotLive).className ?? "";
    status.className =
      stylex.props(styles.statusText, styles.statusTextLive).className ?? "";
  };

  input.addEventListener("focus", arm);
  input.addEventListener("pointerdown", arm);

  input.addEventListener("keydown", (event) => {
    const sound = resolveSound(event.key);
    // Keep Tab inside the deck, and let Escape leave it; both still fire.
    if (event.key === "Tab") event.preventDefault();
    if (event.key === "Escape") input.blur();
    if (!sound) return;

    arm();
    board.fire(sound);

    shots += 1;
    countEls.forEach((el) => {
      el.textContent = String(shots);
    });
    lastEl.textContent = LABELS[sound];

    flash.className = stylex.props(styles.flash).className ?? "";
    void flash.offsetWidth;
    flash.className =
      stylex.props(styles.flash, styles.flashHit).className ?? "";

    const chip = document.createElement("span");
    chip.className = stylex.props(styles.chip).className ?? "";
    chip.textContent = LABELS[sound];
    logEl.prepend(chip);
    while (logEl.children.length > 5) logEl.lastElementChild?.remove();
  });

  muteBtn.addEventListener("click", () => {
    const next = muteBtn.getAttribute("aria-pressed") !== "true";
    muteBtn.setAttribute("aria-pressed", String(next));
    muteBtn.textContent = next ? "muted" : "mute";
    muteBtn.className =
      stylex.props(styles.mute, next && styles.muteOn).className ?? "";
    board.setMuted(next);
  });

  volumeEl.addEventListener("input", () => {
    board.setVolume(Number(volumeEl.value) / 100);
  });
}

/** Mount every deck on the page. One page, one deck, but the hook is generic. */
export function mountDecks(): void {
  const board = createBoard();
  document.querySelectorAll<HTMLElement>("[data-demo]").forEach((root) => {
    mountDeck(root, board);
  });
  // Prime the audio context on the first real gesture, so the first keystroke
  // is not swallowed by the browser's autoplay policy.
  window.addEventListener("pointerdown", () => void board.ensure(), {
    once: true,
  });
}
