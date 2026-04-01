import AppKit
import SwiftUI

/// Manages the NSStatusItem (menu bar icon) and the floating panel.
/// Replaces MenuBarExtra to give us full control over window behavior.
final class StatusBarController {
    static let shared = StatusBarController()

    private var statusItem: NSStatusItem!
    private(set) var panel: FloatingPanel!
    let appState = AppState()

    private init() {}

    func setup() {
        NSApp?.setActivationPolicy(.accessory)

        // Status item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem.button {
            button.image = NSImage(
                systemSymbolName: "arrow.down.right.and.arrow.up.left",
                accessibilityDescription: "Crunch"
            )
            button.action = #selector(togglePanel)
            button.target = self
        }

        // Panel
        let hostingView = NSHostingView(
            rootView: ContentView()
                .environment(appState)
        )
        panel = FloatingPanel(contentRect: NSRect(x: 0, y: 0, width: 380, height: 520))
        panel.contentView = hostingView
    }

    @objc private func togglePanel() {
        if panel.isVisible {
            panel.close()
        } else {
            positionPanel()
            panel.makeKeyAndOrderFront(nil)
            NSApp?.activate(ignoringOtherApps: false)
        }
    }

    private func positionPanel() {
        guard let button = statusItem.button,
              let buttonWindow = button.window else { return }

        let buttonRect = buttonWindow.convertToScreen(button.convert(button.bounds, to: nil))
        let panelWidth = panel.frame.width
        let panelHeight = panel.frame.height

        var x = buttonRect.midX - panelWidth / 2
        let y = buttonRect.minY - panelHeight - 4

        if let screen = NSScreen.main {
            let screenFrame = screen.visibleFrame
            x = max(screenFrame.minX + 8, min(x, screenFrame.maxX - panelWidth - 8))
        }

        panel.setFrameOrigin(NSPoint(x: x, y: y))
    }
}
