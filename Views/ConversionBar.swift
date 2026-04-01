import SwiftUI

struct ConversionBar: View {
    @Environment(AppState.self) private var appState
    @Environment(\.colorScheme) private var colorScheme

    private var isDark: Bool { colorScheme == .dark }

    var body: some View {
        @Bindable var state = appState
        VStack(spacing: 10) {
            // Format pills
            HStack(spacing: 3) {
                ForEach(OutputFormat.allCases, id: \.self) { format in
                    let isActive = appState.outputFormat == format
                    Button {
                        appState.outputFormat = format
                    } label: {
                        Text(format.label)
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundStyle(isActive ? Theme.primaryForeground : Theme.mutedForeground)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(
                                Capsule().fill(isActive ? Theme.primary : Theme.muted)
                            )
                            .contentShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }

                Spacer()

                // Quality
                if appState.outputFormat.isLossy {
                    HStack(spacing: 6) {
                        Slider(value: $state.quality, in: 0.1...1.0, step: 0.05)
                            .frame(width: 60)
                            .tint(Theme.primary)

                        Text("\(Int(appState.quality * 100))%")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundStyle(Theme.foreground)
                            .frame(width: 32, alignment: .trailing)
                    }
                }
            }

            // Convert button
            Button {
                appState.convertAll()
            } label: {
                HStack(spacing: 6) {
                    if appState.isConverting {
                        ProgressView()
                            .controlSize(.small)
                            .tint(Theme.primaryForeground)
                    } else {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 12, weight: .bold))
                    }
                    Text(appState.isConverting ? "Crunching..." : "Crunch \(appState.items.count)")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                }
                .foregroundStyle(Theme.primaryForeground)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Theme.primary)
                        .shadow(color: Theme.primary.opacity(0.3), radius: 8, y: 2)
                )
                .contentShape(RoundedRectangle(cornerRadius: 10))
            }
            .buttonStyle(.plain)
            .disabled(!appState.hasItems || appState.isConverting)
            .opacity(appState.hasItems ? 1.0 : 0.5)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}
