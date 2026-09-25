import Carbon
import CoreGraphics

/// A single key-down event captured from the keyboard: the physical key plus
/// the modifier flags held when it was pressed.
///
/// This is the resolver's input. Carrying the flags on the value, rather than
/// reading them later, keeps the decision a pure function of one keystroke.
nonisolated struct Keystroke: Equatable, Sendable {
    let keyCode: CGKeyCode
    let modifiers: CGEventFlags

    /// Whether the event is a modifier key itself.
    ///
    /// Modifiers are delivered as `flagsChanged`, never as key-downs, so this
    /// normally never fires. It guards the resolver if one arrives anyway: a
    /// lone modifier is not typing and should stay silent.
    var isModifierKey: Bool { Self.modifierKeyCodes.contains(keyCode) }

    private static let modifierKeyCodes: Set<CGKeyCode> = [
        CGKeyCode(kVK_Command),
        CGKeyCode(kVK_RightCommand),
        CGKeyCode(kVK_Shift),
        CGKeyCode(kVK_RightShift),
        CGKeyCode(kVK_Option),
        CGKeyCode(kVK_RightOption),
        CGKeyCode(kVK_Control),
        CGKeyCode(kVK_RightControl),
        CGKeyCode(kVK_CapsLock),
        CGKeyCode(kVK_Function),
    ]
}
