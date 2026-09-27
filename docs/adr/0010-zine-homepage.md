# Build the homepage as the zine direction

AngryKeyboard needs one marketing page: what it is, why it exists, and a way to hear it before installing. A throwaway prototype under `.scratch/marketing-site/` explored six directions over three rounds, switched with `?variant=`. The winner is the zine, variant F. That direction becomes the real homepage.

The page is a single scroll. It opens with the pitch in the first person, because the reason the app exists is personal and funny. Mechanical keyboards were annoying Zac, so he built the opposite. The hero is followed by a live deck, the six key bindings, the install steps, and the download. There is no pricing page, no feature grid, and no second page.

Two constraints shaped every revision.

The deck and a download button both sit in the first viewport, judged at 1400 by 900. A visitor should never scroll to find the demo or the way to install. Variants that buried either one were cut from the prototype rather than patched.

The tone stays handmade rather than themed. The directions that failed wore a costume, one as hazard signage and one as arcade neon. The zine carries its theme through structure instead: newsprint, halftone dots, taped cards, handwriting, and a war sticker set drawn as flat SVG in the app's own palette. The stickers are decoration, so they hold a lower stacking order than content, take no pointer events, and are hidden on narrow screens except for the sheet.

The demo is the strongest thing on the page, so it was built to match the app rather than approximate it. The nine bundled MP3s are inlined as data URIs, so the page is one file that works from disk with no server. It applies the same resolver: Enter is the explosion, Esc the rocket whoosh, Backspace the shotgun blast, Space the shotgun cock, the arrow keys fire one of four impacts, and every other key fires the shotgun. It keeps one voice per sound and retriggers on repeat, covers arrow impacts at three voices, adds a small random pitch and gain per hit, and puts a compressor on the mix in place of the app's limiter.

The intended build is Astro with StyleX, per Zac. The prototype is deliberately stack-free HTML so the design could be judged without a toolchain. Treat it as a reference for the port, not code to lift. The mascot is the app icon's keycap and every sticker is inline SVG, so both carry across unchanged.

Deferred, not decided here: the download link and the release artifact behind it, a notarized or Developer ID build, an FAQ covering the Input Monitoring request, and an illustrated sticker set to replace the prototype's vector shapes.

Considered and rejected: the five other directions. Live Fire and Field Manual kept the app icon's palette and read as competent and a little generic. Blueprint was content-rich, but a technical drawing fits a specification more than a homepage. Control Panel was the most crafted and is the best runner-up. Poster was the most restrained and the most likely to read as a product rather than a joke. All five remain in `.scratch/marketing-site/` on branch `opencode/marketing-site`, which is the primary source for the exploration.
