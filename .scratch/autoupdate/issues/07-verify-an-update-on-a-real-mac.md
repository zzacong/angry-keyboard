# 07: Verify an update on a real Mac + wizard

**What to build:** A wizard walks the manual end-to-end test on a real Mac, and the result is recorded: an older build updates to a newer one from the rehearsal feed, relaunches, keeps Input Monitoring, and is not blocked by Gatekeeper.

**Blocked by:** 03 — App checks for updates when enabled; 05 — Rehearsal produces a testable feed.

**Status:** resolved

- [x] A wizard guides installing an older build, pointing it at the rehearsal feed, and triggering the update.
- [x] The update installs and the app relaunches into the new version.
- [x] The Input Monitoring grant survives: sound keeps working after the relaunch with no re-approval.
- [x] Gatekeeper does not re-prompt on the updated launch; if it does, the behavior is recorded and ADR 0010 is updated.
- [x] Preferences, sound pack, volume, and the Login Item survive.

## Comments

- The guided wizard is built at `Scripts/verify-update.sh`, linked from
  "Rehearsing an update" in `docs/signing.md`. The end-to-end run on a real Mac
  remains human: the wizard pauses at each check, appends its result here, and
  leaves `Status` at `ready-for-human` until a person runs it and commits the
  record.

- 2026-09-28 — human run of `Scripts/verify-update.sh` on macOS 26.7 (arm64).
  An older Release build 0.0.1 (0) updated to the rehearsal build 0.1.0 (2)
  from rehearsal run 36389253646 (https://github.com/zzacong/angry-keyboard/actions/runs/36389253646), relaunched, and reported:
  - Input Monitoring and sound: yes
  - Preferences: volume=0.42, playbackMode=overlap, muted=0
  - Login Item: yes
  - Gatekeeper: no re-prompt on the updated launch.
- The one-time `Scripts/verify-update.sh` wizard was retired after this run; the
  durable procedure is the "Rehearsing an update" recipe in `docs/signing.md`.
