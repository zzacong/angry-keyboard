/// The keystroke resolver: which binding, if any, a keystroke plays.
///
/// A pure function of the keystroke and the pack. It holds no audio code and no
/// permission code, so it can be tested with plain values and no engine, tap,
/// or real keyboard.
nonisolated extension SoundPack {
    /// The binding `keystroke` should play, or `nil` for a keystroke that plays
    /// nothing. The pack's catch-all covers any key without a binding of its
    /// own.
    func binding(for keystroke: Keystroke) -> Binding? {
        guard !keystroke.isModifierKey else { return nil }
        return bindings.first { $0.key.matches(keystroke) }
    }
}
