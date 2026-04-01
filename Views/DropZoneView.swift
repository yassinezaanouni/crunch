import SwiftUI
import UniformTypeIdentifiers

struct DropZoneView: View {
    @Environment(AppState.self) private var appState
    @State private var dashPhase: CGFloat = 0
    @State private var isHovering = false

    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            // Icon
            ZStack {
                Circle()
                    .fill(Theme.primary.opacity(isHovering ? 0.2 : 0.08))
                    .frame(width: 72, height: 72)
                    .scaleEffect(isHovering ? 1.1 : 1.0)

                Image(systemName: "arrow.down.to.line.compact")
                    .font(.system(size: 28, weight: .medium))
                    .foregroundStyle(Theme.primary)
                    .scaleEffect(isHovering ? 1.15 : 1.0)
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isHovering)

            VStack(spacing: 6) {
                Text("Drop images or click to select")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(Theme.foreground)

                Text("or **\u{2318}V** to paste from clipboard")
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.mutedForeground)
            }

            // Supported formats
            HStack(spacing: 6) {
                ForEach(["PNG", "JPG", "HEIC", "TIFF", "BMP", "GIF", "WebP"], id: \.self) { fmt in
                    Text(fmt)
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundStyle(Theme.mutedForeground)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(
                            Capsule().fill(Theme.muted)
                        )
                }
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(
                    Theme.primary.opacity(isHovering ? 1.0 : 0.4),
                    style: StrokeStyle(
                        lineWidth: isHovering ? 2.5 : 1.5,
                        dash: [8, 6],
                        dashPhase: dashPhase
                    )
                )
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isHovering ? Theme.accent : .clear)
                )
        )
        .contentShape(RoundedRectangle(cornerRadius: 16))
        .onTapGesture { openFilePicker() }
        .padding(16)
        .onAppear {
            withAnimation(.linear(duration: 12).repeatForever(autoreverses: false)) {
                dashPhase = 56
            }
        }
        .onDrop(of: [.fileURL], isTargeted: $isHovering) { providers in
            handleDrop(providers)
            return true
        }
    }

    private func openFilePicker() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = false
        panel.allowedContentTypes = [.image, .png, .jpeg, .heic, .tiff, .bmp, .gif, .webP]
        panel.title = "Select Images"

        // Show as sheet-like floating panel above the menu bar window
        panel.level = .floating
        panel.begin { response in
            if response == .OK {
                appState.addImages(from: panel.urls)
            }
        }
    }

    private func handleDrop(_ providers: [NSItemProvider]) {
        for provider in providers {
            provider.loadItem(forTypeIdentifier: "public.file-url", options: nil) { data, _ in
                guard let data = data as? Data,
                      let urlString = String(data: data, encoding: .utf8),
                      let url = URL(string: urlString) else { return }

                let imageExtensions = ["png", "jpg", "jpeg", "heic", "heif", "tiff", "tif", "bmp", "gif", "webp"]
                guard imageExtensions.contains(url.pathExtension.lowercased()) else { return }

                DispatchQueue.main.async {
                    appState.addImages(from: [url])
                }
            }
        }
    }
}
