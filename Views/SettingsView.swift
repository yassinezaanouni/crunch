import SwiftUI

struct SettingsView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.colorScheme) private var colorScheme

    private var isDark: Bool { colorScheme == .dark }

    var body: some View {
        VStack(spacing: 0) {
            settingsHeader
            Divider().overlay(Theme.border)

            ScrollView {
                VStack(spacing: 16) {
                    outputLocationSection
                    defaultFormatSection
                    defaultQualitySection
                    appearanceSection
                    aboutSection
                }
                .padding(16)
            }
        }
    }

    private var settingsHeader: some View {
        PageHeader(title: "Settings", onBack: { appState.showSettings = false })
    }

    // MARK: - Sections

    private var outputLocationSection: some View {
        SettingsCard(isDark: isDark) {
            SettingsSectionHeader(icon: "folder", title: "Output Location")

            HStack(spacing: 3) {
                ForEach([OutputLocation.sameFolder, .downloads], id: \.label) { loc in
                    let isActive = appState.outputLocation == loc
                    Button {
                        appState.outputLocation = loc
                    } label: {
                        Text(loc.label)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(isActive ? Theme.foreground : Theme.mutedForeground)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(isActive ? Theme.card : .clear)
                                    .shadow(color: isActive && !isDark ? Color.black.opacity(0.06) : .clear, radius: 3, y: 1)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .strokeBorder(isActive ? Theme.border : .clear, lineWidth: 0.5)
                                    )
                            )
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(3)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isDark ? Color.black.opacity(0.3) : Color.black.opacity(0.05))
            )
        }
    }

    private var defaultFormatSection: some View {
        SettingsCard(isDark: isDark) {
            SettingsSectionHeader(icon: "doc.richtext", title: "Default Format")

            HStack(spacing: 3) {
                ForEach(OutputFormat.allCases, id: \.self) { format in
                    let isActive = appState.outputFormat == format
                    Button {
                        appState.outputFormat = format
                    } label: {
                        Text(format.label)
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundStyle(isActive ? Theme.primaryForeground : Theme.mutedForeground)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(isActive ? Theme.primary : .clear)
                            )
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(3)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isDark ? Color.black.opacity(0.3) : Color.black.opacity(0.05))
            )
        }
    }

    private var defaultQualitySection: some View {
        @Bindable var state = appState
        return SettingsCard(isDark: isDark) {
            SettingsSectionHeader(icon: "slider.horizontal.3", title: "Default Quality")

            HStack(spacing: 12) {
                Slider(value: $state.quality, in: 0.1...1.0, step: 0.05)
                    .tint(Theme.primary)

                Text("\(Int(appState.quality * 100))%")
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundStyle(Theme.foreground)
                    .frame(width: 40, alignment: .trailing)
            }

            Text("Lower quality = smaller file size. 80% recommended.")
                .font(.system(size: 10))
                .foregroundStyle(Theme.mutedForeground)
        }
    }

    private var appearanceSection: some View {
        SettingsCard(isDark: isDark) {
            SettingsSectionHeader(icon: "paintbrush", title: "Appearance")

            let options: [(Int, String, String)] = [
                (0, "sun.and.horizon", "System"),
                (1, "sun.max", "Light"),
                (2, "moon", "Dark"),
            ]

            HStack(spacing: 3) {
                ForEach(options, id: \.0) { mode, icon, label in
                    let isActive = appState.appearanceMode == mode
                    Button {
                        appState.appearanceMode = mode
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: icon)
                                .font(.system(size: 10, weight: .medium))
                            Text(label)
                                .font(.system(size: 11, weight: .semibold))
                        }
                        .foregroundStyle(isActive ? Theme.foreground : Theme.mutedForeground)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(isActive ? Theme.card : .clear)
                                .shadow(color: isActive && !isDark ? Color.black.opacity(0.06) : .clear, radius: 3, y: 1)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .strokeBorder(isActive ? Theme.border : .clear, lineWidth: 0.5)
                                )
                        )
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(3)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isDark ? Color.black.opacity(0.3) : Color.black.opacity(0.05))
            )
        }
    }

    private var aboutSection: some View {
        SettingsCard(isDark: isDark) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            LinearGradient(
                                colors: [Theme.primary, Theme.primary.opacity(0.7)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 40, height: 40)
                    Image(systemName: "arrow.down.right.and.arrow.up.left")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(Theme.primaryForeground)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("Crunch")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(Theme.foreground)
                    Text("Image Converter")
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.mutedForeground)
                }
                Spacer()
                Text("v1.0.0")
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundStyle(Theme.mutedForeground)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Theme.muted))
            }
        }
    }
}

// MARK: - Shared Components

private struct SettingsSectionHeader: View {
    let icon: String
    let title: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Theme.primary)
                .frame(width: 18)
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Theme.foreground)
        }
    }
}

private struct SettingsCard<Content: View>: View {
    let isDark: Bool
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) { content }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Theme.card)
                    .shadow(color: isDark ? .clear : Color.black.opacity(0.06), radius: 8, y: 2)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(Theme.border, lineWidth: 0.5)
                    )
            )
    }
}
