import SwiftUI

// MARK: - Adaptive Color Helper

extension Color {
    init(light: Color, dark: Color) {
        self.init(nsColor: NSColor(name: nil) { appearance in
            let isDark = appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
            return isDark ? NSColor(dark) : NSColor(light)
        })
    }
}

// MARK: - Industrial Design Tokens

enum Theme {

    // ─── Core ───

    static let background = Color(
        light: Color(red: 0.941, green: 0.941, blue: 0.925),
        dark: Color(red: 0.102, green: 0.102, blue: 0.102)
    )
    static let foreground = Color(
        light: Color(red: 0.102, green: 0.102, blue: 0.102),
        dark: Color(red: 0.910, green: 0.910, blue: 0.894)
    )

    // ─── Card ───

    static let card = Color(
        light: Color(red: 0.980, green: 0.980, blue: 0.969),
        dark: Color(red: 0.141, green: 0.141, blue: 0.141)
    )
    static let cardForeground = Color(
        light: Color(red: 0.102, green: 0.102, blue: 0.102),
        dark: Color(red: 0.910, green: 0.910, blue: 0.894)
    )

    // ─── Primary (Lime) ───

    static let primary = Color(
        light: Color(red: 0.478, green: 0.722, blue: 0.0),
        dark: Color(red: 0.745, green: 1.0, blue: 0.275)
    )
    static let primaryForeground = Color(
        light: Color(red: 1.0, green: 1.0, blue: 1.0),
        dark: Color(red: 0.08, green: 0.08, blue: 0.08)
    )

    // ─── Muted ───

    static let muted = Color(
        light: Color(red: 0.894, green: 0.894, blue: 0.878),
        dark: Color(red: 0.165, green: 0.165, blue: 0.165)
    )
    static let mutedForeground = Color(
        light: Color(red: 0.541, green: 0.541, blue: 0.525),
        dark: Color(red: 0.533, green: 0.533, blue: 0.518)
    )

    // ─── Border ───

    static let border = Color(
        light: Color(red: 0.863, green: 0.863, blue: 0.847),
        dark: Color(red: 0.200, green: 0.200, blue: 0.200)
    )

    // ─── Destructive ───

    static let destructive = Color(
        light: Color(red: 0.851, green: 0.310, blue: 0.310),
        dark: Color(red: 1.0, green: 0.420, blue: 0.420)
    )

    // ─── Success ───

    static let success = Color(
        light: Color(red: 0.176, green: 0.624, blue: 0.243),
        dark: Color(red: 0.290, green: 0.871, blue: 0.502)
    )

    // ─── Accent (Subtle lime tint) ───

    static let accent = Color(
        light: Color(red: 0.745, green: 1.0, blue: 0.275).opacity(0.12),
        dark: Color(red: 0.745, green: 1.0, blue: 0.275).opacity(0.08)
    )
}

// MARK: - View Modifiers

extension View {
    func pointerCursor() -> some View {
        self.onHover { inside in
            if inside { NSCursor.pointingHand.push() } else { NSCursor.pop() }
        }
    }
}
