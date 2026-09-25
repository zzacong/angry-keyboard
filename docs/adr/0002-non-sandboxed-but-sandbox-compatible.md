# Ship non-sandboxed, but stay inside the sandbox-compatible subset

v1 is a personal tool. It will not be sandboxed and will not ship through the Mac App Store, because the developer account costs money. To avoid a rewrite if that changes, we voluntarily hold ourselves to what a sandboxed app can do: listen-only capture, Input Monitoring, and no synthetic event posting. Under the sandbox `CGEvent.post()` is a no-op and Accessibility is unavailable, so those are the two doors we leave shut. This restriction costs nothing today and keeps both a Developer ID release and an App Store release open.

Considered and rejected: sandboxing now. It adds an entitlements file and review constraints for no benefit to a personal tool.
