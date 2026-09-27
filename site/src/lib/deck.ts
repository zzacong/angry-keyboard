import * as stylex from "@stylexjs/stylex";
import { styles } from "@/components/deck.stylex";
import combatImpactUrl from "../../../AngryKeyboard/Sounds/combat-impact.mp3?url";
import explodeRockUrl from "../../../AngryKeyboard/Sounds/explode-rock.mp3?url";
import kungFuYellUrl from "../../../AngryKeyboard/Sounds/kung-fu-yell.mp3?url";
import punchImpactUrl from "../../../AngryKeyboard/Sounds/punch-impact-hit.mp3?url";
import punchUrl from "../../../AngryKeyboard/Sounds/punch.mp3?url";
import rocketWhooshUrl from "../../../AngryKeyboard/Sounds/rocket-whoosh.mp3?url";
import shotgunBlastUrl from "../../../AngryKeyboard/Sounds/shotgun-blast.mp3?url";
import shotgunCockingUrl from "../../../AngryKeyboard/Sounds/shotgun-cocking.mp3?url";
import shotgunUrl from "../../../AngryKeyboard/Sounds/shotgun.mp3?url";

// The live demo deck. It mirrors the shipped app: one binding per keystroke,
// one voice per sound retriggered on repeat, three voices on arrow impacts, and
// a small random pitch and gain on every hit. The nine MP3s are imported from
// the app's own Sounds directory, so the site can never drift from the app.

const IMPACTS = [
  "combat-impact",
  "kung-fu-yell",
  "punch",
  "punch-impact-hit",
] as const;

export type ImpactSound = (typeof IMPACTS)[number];

export type SoundName =
  | "explode-rock"
  | "rocket-whoosh"
  | "shotgun"
  | "shotgun-blast"
  | "shotgun-cocking"
  | ImpactSound;

// Voices are counted per pool, so the four impacts share one cap of three.
type Pool =
  | "explode-rock"
  | "impact"
  | "rocket-whoosh"
  | "shotgun"
  | "shotgun-blast"
  | "shotgun-cocking";

const SOURCES = {
  "combat-impact": combatImpactUrl,
  "explode-rock": explodeRockUrl,
  "kung-fu-yell": kungFuYellUrl,
  punch: punchUrl,
  "punch-impact-hit": punchImpactUrl,
  "rocket-whoosh": rocketWhooshUrl,
  shotgun: shotgunUrl,
  "shotgun-blast": shotgunBlastUrl,
  "shotgun-cocking": shotgunCockingUrl,
} satisfies Record<SoundName, string>;

const VOICES: Record<Pool, number> = {
  "explode-rock": 1,
  impact: 3,
  "rocket-whoosh": 1,
  shotgun: 1,
  "shotgun-blast": 1,
  "shotgun-cocking": 1,
};

const LABELS: Record<SoundName, string> = {
  "combat-impact": "impact",
  "explode-rock": "explosion",
  "kung-fu-yell": "impact",
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

const poolOf = (name: SoundName): Pool => (isImpact(name) ? "impact" : name);

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
  return "shotgun";
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
  let buffers: Record<SoundName, AudioBuffer> | null = null;
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
        const decoded = await context!.decodeAudioData(bytes);
        buffers = {
          ...(buffers ?? ({} as Record<SoundName, AudioBuffer>)),
          [name]: decoded,
        };
      }),
    ).then(() => undefined);
    return loading;
  }

  function fire(name: SoundName): void {
    if (!context || !buffers || !master) return;
    const buffer = buffers[name];
    if (!buffer) return;

    const pool = poolOf(name);
    const source = context.createBufferSource();
    source.buffer = buffer;
    source.playbackRate.value = 1 + (Math.random() * 0.1 - 0.05);

    const gain = context.createGain();
    gain.gain.value = 0.9 + Math.random() * 0.2;
    source.connect(gain).connect(master);

    // Retrigger: a pool of one steals its own voice; larger pools stack to the cap.
    const live = playing[pool] ?? (playing[pool] = []);
    if (live.length >= VOICES[pool]) live.shift()?.stop();
    live.push(source);
    source.onended = () => {
      const index = live.indexOf(source);
      if (index > -1) live.splice(index, 1);
    };
    source.start();

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
