# Floating key hint

## Goal

Make the demo deck feel inviting and show visitors what they can press without adding another instructional panel or repeating the sound list.

## Design

Place one floating sentence at the bottom center of the typing area, in muted text. Use this copy:

> Go on, make a racket with the spacebar, enter, backspace, escape, arrow keys, or any key.

Show only the key names in the sentence. Keep the detailed sound mappings in the existing "The sounds" section below the deck.

When a key group is tried, its word jumps, flashes green, and settles into a green highlight. Keep the highlight for the rest of the page session. The guide must not block typing or cover the user's text.

## Interaction

- Space, Enter, Backspace, and Escape animate their matching words.
- Any arrow key animates "arrow keys".
- Any other key that triggers a sound animates "any key". Modifier keys remain excluded.
- Count a key only when the existing resolver accepts it and the deck fires its sound. Preserve current typing, sound, and Escape behavior.
- Announce the newly tried key group to assistive technology. Respect reduced-motion settings.

## Scope

- Replace the in-deck key grid with the floating sentence in `site/src/components/Deck.astro`.
- Style its placement and animation in `site/src/components/deck.stylex.ts`.
- Track groups from the existing keydown handler in `site/src/lib/deck.ts`.
- Keep the key names and sound descriptions in `site/src/lib/key-bindings.ts` shared with the "The sounds" section.
- Leave the sound resolver, playback, shot count, mute, volume, and textarea editing behavior unchanged.

## Acceptance criteria

- The muted sentence floats at the bottom center of the typing area, matching the marked position in the reference image.
- It names Spacebar, Enter, Backspace, Escape, arrow keys, and any key without showing sound descriptions or boxed keycaps.
- The first sound-triggering key in each group makes only that group's word jump and flash green before it stays highlighted.
- Modifier keys alone do not change a guide word or play a sound.
- The hint remains clickable-through, does not obscure typed text, and wraps cleanly on narrow screens.
- Reduced-motion preferences disable the jump animation while keeping the tried state visible.
- The site passes its typecheck, lint, formatting, tests, and production build.
