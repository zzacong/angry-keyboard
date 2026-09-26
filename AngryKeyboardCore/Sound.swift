/// A sound bundled with the app, named after the MP3 file it loads from.
///
/// A `SoundPool` points bindings at these cases; the app decodes each one into
/// memory at launch.
nonisolated enum Sound: String, CaseIterable, Sendable {
    case explodeRock = "explode-rock"
    case rocketWhoosh = "rocket-whoosh"
    case shotgunBlast = "shotgun-blast"
    case shotgunCocking = "shotgun-cocking"
    case shotgun
    case combatImpact = "combat-impact"
    case kungFuYell = "kung-fu-yell"
    case punchImpactHit = "punch-impact-hit"
    case punch
}
