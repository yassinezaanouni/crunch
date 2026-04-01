import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 0) {
            if appState.showSettings {
                SettingsView()
            } else if appState.showResults {
                ResultsView()
            } else {
                mainView
            }
        }
        .frame(width: 380, height: 520)
        .background(Theme.background)
        .onPasteCommand(of: [.image, .fileURL, .tiff, .png]) { providers in
            appState.addImageFromPasteboard()
        }
    }

    private var mainView: some View {
        VStack(spacing: 0) {
            header
            Divider().overlay(Theme.border)

            if appState.hasItems {
                ImageQueueView()
            } else {
                DropZoneView()
            }

            Divider().overlay(Theme.border)
            ConversionBar()
        }
    }

    private var header: some View {
        HStack(spacing: 10) {
            if appState.hasItems {
                // Back button when images are queued
                Button {
                    appState.clearAll()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 11, weight: .semibold))
                        Text("Back")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundStyle(Theme.primary)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                Spacer()

                Text("\(appState.items.count) image\(appState.items.count == 1 ? "" : "s")")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(Theme.foreground)

                Spacer()

            } else {
                // App branding on empty state
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [Theme.primary, Theme.primary.opacity(0.7)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 28, height: 28)
                    Image(systemName: "arrow.down.right.and.arrow.up.left")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(Theme.primaryForeground)
                }

                VStack(alignment: .leading, spacing: 1) {
                    Text("Crunch")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.foreground)
                    Text("Image Converter")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(Theme.mutedForeground)
                }

                Spacer()
            }

            Button {
                appState.showSettings = true
            } label: {
                Image(systemName: "gearshape")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Theme.mutedForeground)
                    .frame(width: 28, height: 28)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
}
