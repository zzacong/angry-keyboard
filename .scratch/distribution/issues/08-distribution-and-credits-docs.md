# 08: Distribution and credits docs

**What to build:** A reader should be able to install the app and understand its licensing. The README covers both Gatekeeper flows, the two channels and their bundle ids, and the certificate situation. A credits file records the sound sources and states that the code license does not cover the audio.

**Blocked by:** 01, 07.

**Status:** resolved

- [x] The README explains how to install a download on macOS 15 and later and on macOS 14.
- [x] The README documents both channels and their bundle ids, and how to tell them apart.
- [x] The README states that the app is signed but not notarized, and why.
- [x] The credits file names where the sounds came from and says the code license does not cover them.

## Comments

Added an Install section to the README with the two Gatekeeper flows (macOS 15
and later through System Settings, macOS 14 through Control-click), and a
Channels section with the production and dev bundle ids, names, icons, and
glyphs. The License section now points at `CREDITS.md`, and the troubleshooting
bullet about a rebuild dropping the Input Monitoring grant now says that an
ad-hoc clone build is the cause and names the signing wizard as the fix.

`CREDITS.md` lists the nine sound files and names Pixabay as their source,
notes the Pixabay Content License terms, and states that the MIT license covers
the code and not the sounds.

The same install warning ships in `packaging/INSTALL.txt`, which the release
workflow copies into the DMG as `Read Me.txt`, and in
`packaging/RELEASE-NOTES.md`, which the workflow appends to the release notes.

