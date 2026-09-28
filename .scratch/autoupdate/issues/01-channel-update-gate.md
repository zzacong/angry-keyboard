# 01: Channel update gate

**What to build:** The app can be told, per channel, whether it checks for updates at all. Production opts in, dev opts out, and a bundle that says nothing is treated as opted out. Nothing visible changes yet — this is the switch the updater will read.

**Blocked by:** None (can start immediately).

**Status:** ready-for-agent

- [ ] A bundle that turns the update flag on is reported as update-enabled; turning it off, or omitting it, reports disabled.
- [ ] The decision is read through the same injected-bundle-dictionary seam the channel assets use; no test touches the real bundle or starts Sparkle.
- [ ] The production channel builds with updates enabled and the dev channel builds with them disabled.
- [ ] Behavior is otherwise unchanged: nothing starts the updater yet, and the dev build is identical to today.
