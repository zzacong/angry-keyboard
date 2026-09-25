import AppKit

/// The menu's volume row: a speaker glyph and a slider in one menu item.
///
/// A menu item with a custom view has no title of its own, so the glyph is what
/// identifies the control. The slider writes through the target/action given at
/// construction; the menu re-reads `volume` from `Settings` each time it opens,
/// so the stored value stays the source of truth.
final class VolumeMenuItem: NSMenuItem {
    private static let rowSize = NSSize(width: 224, height: 28)
    private static let glyphSize: CGFloat = 18

    private let slider: NSSlider

    init(volume: Double, target: AnyObject, action: Selector) {
        slider = NSSlider(
            value: volume,
            minValue: 0,
            maxValue: 1,
            target: target,
            action: action
        )
        super.init(title: "", action: nil, keyEquivalent: "")

        slider.isContinuous = true
        slider.setAccessibilityLabel("Volume")

        let row = NSView(frame: NSRect(origin: .zero, size: Self.rowSize))

        let glyph = NSImageView(frame: NSRect(x: 14, y: 5, width: Self.glyphSize, height: Self.glyphSize))
        glyph.image = NSImage(systemSymbolName: "speaker.wave.2", accessibilityDescription: nil)
        glyph.contentTintColor = .secondaryLabelColor
        glyph.imageScaling = .scaleProportionallyDown

        slider.frame = NSRect(x: 40, y: 3, width: Self.rowSize.width - 40 - 14, height: 22)
        slider.autoresizingMask = [.width]

        row.addSubview(glyph)
        row.addSubview(slider)
        view = row
    }

    required init(coder: NSCoder) {
        fatalError("VolumeMenuItem is created in code only")
    }

    /// The slider's current value. The menu sets it from `Settings` whenever it
    /// opens, so the slider always reflects what was persisted.
    var volume: Double {
        get { slider.doubleValue }
        set { slider.doubleValue = newValue }
    }
}
