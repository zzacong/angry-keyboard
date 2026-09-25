/// How a sound behaves when its key is hit again before the last hit finished.
///
/// `retrigger` uses one voice per binding and restarts it on every hit, which
/// keeps fast typing from turning into mud. `overlap` lets a binding use its
/// own voice count so several copies can stack. The menu toggle exists so the
/// two feels can be judged by ear rather than by argument.
nonisolated enum PlaybackMode: String, Sendable, CaseIterable {
    case retrigger
    case overlap
}
