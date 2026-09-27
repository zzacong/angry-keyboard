# Ship non-sandboxed, but stay inside the sandbox-compatible subset

**Updated 2026-09-28:** the distribution channel is settled by ADR 0007 — GitHub Releases, signed but not notarized — so the App Store is off the table. The sandbox-compatible subset below is still the shipped discipline.

v1 is not sandboxed and does not ship through the Mac App Store. Distribution is settled in ADR 0007: GitHub Releases, signed but not notarized, so no Apple Developer Program membership is needed either way.

At no cost, we voluntarily hold ourselves to what a sandboxed app can do: listen-only capture, Input Monitoring, and no synthetic event posting. Under the sandbox `CGEvent.post()` is a no-op and Accessibility is unavailable, so those are the two doors we leave shut. This restriction costs nothing today and means adopting the sandbox later is not a rewrite.

Considered and rejected: sandboxing now. It adds an entitlements file and review constraints for a tool that gains nothing from them yet.
