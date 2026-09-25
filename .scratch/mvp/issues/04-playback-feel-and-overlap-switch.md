# 04: Playback feel and the overlap switch

**What to build:** Make the audio hold up under fast typing. Each binding gets its own voice count, the engine gets a limiter, and each hit gets a small random pitch and gain change. Retrigger ships as the default at one voice per binding, and a menu toggle switches to overlap so the two can be compared by typing.

**Blocked by:** 02, 03.

**Status:** ready-for-agent

- [ ] Each binding has its own voice count, defaulting to one voice, which behaves as retrigger.
- [ ] A menu toggle switches between retrigger and overlap, and the change takes effect on the next keystroke.
- [ ] Typing at speed produces no audible clicks, pops, or clipping.
- [ ] Repeated hits of the same sound vary slightly so they do not sound identical.
- [ ] Switching to overlap lets more than one copy of the same sound play at once, up to the binding's voice count.
