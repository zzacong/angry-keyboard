# Ship non-sandboxed, but stay inside the sandbox-compatible subset

v1 is not sandboxed. It also will not ship through the Mac App Store. The distribution channel is not settled: v1 may stay a personal, locally built tool, or it may ship directly to other people as a Developer ID build. Both a Developer ID release and an App Store release need a paid Apple Developer Program membership, so the membership is a cost of shipping at all, not a cost specific to the App Store. That call is deferred rather than made here.

To keep both paths open without committing, we voluntarily hold ourselves to what a sandboxed app can do: listen-only capture, Input Monitoring, and no synthetic event posting. Under the sandbox `CGEvent.post()` is a no-op and Accessibility is unavailable, so those are the two doors we leave shut. This restriction costs nothing today and means adopting the sandbox later is not a rewrite.

Considered and rejected: sandboxing now. It adds an entitlements file and review constraints for a tool that gains nothing from them yet.
