/// A sound bundled with the app, named after the MP3 file it loads from.
///
/// Ticket 03's sound pack points its bindings at these cases; today the app
/// plays `shotgun` for every keystroke.
enum Sound: String, CaseIterable, Sendable {
    case explodeRock = "explode-rock"
    case rocketWhoosh = "rocket-whoosh"
    case shotgunBlast = "shotgun-blast"
    case shotgunCocking = "shotgun-cocking"
    case shotgun
}
