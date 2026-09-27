# 09: Verify a fresh install on a clean account

**What to build:** Prove a download works on a machine that has never seen the app. On a second user account, download the released DMG, get past Gatekeeper, grant Input Monitoring, and hear a keystroke. Then, once a second release exists, confirm the grant survives an update.

**Blocked by:** 07.

**Status:** resolved

- [x] On a clean account, the released DMG installs and the app runs.
- [x] The Gatekeeper flow in the README matches what the user actually sees.
- [x] Input Monitoring can be granted and keystrokes make sound.
- [x] The install warning is reachable from inside the DMG.
- [x] After a second release, the Input Monitoring grant survives an in-place update.
