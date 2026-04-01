import SwiftUI

@main
struct CrunchApp: App {

    init() {
        // Setup status bar + floating panel after NSApp is ready
        NotificationCenter.default.addObserver(
            forName: NSApplication.didFinishLaunchingNotification,
            object: nil,
            queue: .main
        ) { _ in
            StatusBarController.shared.setup()
        }
    }

    var body: some Scene {
        // No visible scene — everything is managed by StatusBarController
        Settings { EmptyView() }
    }
}
