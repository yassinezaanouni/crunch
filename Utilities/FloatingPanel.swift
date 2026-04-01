import AppKit

/// A custom NSPanel that stays visible when the app loses focus.
/// Unlike MenuBarExtra's built-in panel, this won't auto-close during drag & drop or file picker use.
final class FloatingPanel: NSPanel {

    init(contentRect: NSRect) {
        super.init(
            contentRect: contentRect,
            styleMask: [.titled, .closable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        isFloatingPanel = true
        level = .floating
        hidesOnDeactivate = false
        titleVisibility = .hidden
        titlebarAppearsTransparent = true
        isMovableByWindowBackground = false
        isOpaque = false
        backgroundColor = .windowBackgroundColor
        animationBehavior = .utilityWindow
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
    }

    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }

    override func resignKey() {
        super.resignKey()
        // Don't auto-close — let the user drag files from Finder
    }

    override func close() {
        orderOut(nil)
    }

    override func cancelOperation(_ sender: Any?) {
        close() // Escape key closes the panel
    }
}
