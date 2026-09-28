# 03: App checks for updates when enabled

**What to build:** The production app offers a manual check and checks on its own; dev does neither. Sparkle is embedded in production only. The check lives behind a predictable menu item, and a background check that finds something newer says so there instead of opening a window behind other apps. Nothing installs without a click.

**Blocked by:** 01 — Channel update gate; 02 — Sparkle signing key and wizard.

**Status:** ready-for-agent

- [ ] The production build embeds Sparkle and carries the feed URL and public key; the dev build neither starts the updater nor shows any update item.
- [ ] The production status menu shows a check-for-updates item above About; the dev menu is unchanged.
- [ ] A scheduled check that finds an update annotates that item with the available version; a check that finds nothing stays silent.
- [ ] Choosing the item opens the standard update flow, and confirming installs and relaunches into the new version.
- [ ] The app launches and behaves normally when the feed is unreachable; a failed check never blocks or crashes it.
