# 02: A sound on every keystroke

**What to build:** The end-to-end path. A first-run explainer asks for Input Monitoring and offers a button that opens the right System Settings pane, with live permission status in the menu. Once granted, a listen-only event tap captures every keystroke system wide, and a single bundled sound plays on each one. This ticket also bundles the five supplied sound files and decodes them to memory, so nothing depends on the Desktop copy.

**Blocked by:** 01.

**Status:** ready-for-agent

- [ ] On first launch the app explains why it needs Input Monitoring and opens the Input Monitoring pane when asked.
- [ ] The menu shows whether Input Monitoring is granted and updates when it changes.
- [ ] Before permission is granted the app captures nothing and stays silent.
- [ ] After permission is granted, pressing any key in any app plays a sound.
- [ ] Holding a key down repeats the sound.
- [ ] Audio keeps working after long idle periods, with no manual restart needed.
- [ ] The five supplied sound files ship inside the app and load with no Desktop or network dependency.
- [ ] Mouse clicks, scrolls, and modifier-only presses produce no sound.
- [ ] Typing into a focused password field produces no sound.
