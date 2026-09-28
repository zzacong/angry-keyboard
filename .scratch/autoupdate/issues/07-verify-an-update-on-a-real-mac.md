# 07: Verify an update on a real Mac + wizard

**What to build:** A wizard walks the manual end-to-end test on a real Mac, and the result is recorded: an older build updates to a newer one from the rehearsal feed, relaunches, keeps Input Monitoring, and is not blocked by Gatekeeper.

**Blocked by:** 03 — App checks for updates when enabled; 05 — Rehearsal produces a testable feed.

**Status:** ready-for-human

- [ ] A wizard guides installing an older build, pointing it at the rehearsal feed, and triggering the update.
- [ ] The update installs and the app relaunches into the new version.
- [ ] The Input Monitoring grant survives: sound keeps working after the relaunch with no re-approval.
- [ ] Gatekeeper does not re-prompt on the updated launch; if it does, the behavior is recorded and ADR 0010 is updated.
- [ ] Preferences, sound pack, volume, and the Login Item survive.

## Comments

- The guided wizard is built at `Scripts/verify-update.sh`, linked from
  "Rehearsing an update" in `docs/signing.md`. The end-to-end run on a real Mac
  remains human: the wizard pauses at each check, appends its result here, and
  leaves `Status` at `ready-for-human` until a person runs it and commits the
  record.
