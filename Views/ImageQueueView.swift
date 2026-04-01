import SwiftUI

struct ImageQueueView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(appState.items) { item in
                    ImageQueueRow(item: item) {
                        appState.removeItem(item)
                    }

                    if item.id != appState.items.last?.id {
                        Divider().padding(.leading, 56)
                    }
                }
            }
            .padding(.vertical, 4)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onDrop(of: [.fileURL], isTargeted: nil) { providers in
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
            return true
        }
    }
}

private struct ImageQueueRow: View {
    let item: ImageItem
    let onRemove: () -> Void

    @State private var isHovered = false

    var body: some View {
        HStack(spacing: 10) {
            // Thumbnail
            Image(nsImage: item.image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 40, height: 40)
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .strokeBorder(Theme.border, lineWidth: 0.5)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(item.filename)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Theme.foreground)
                    .lineLimit(1)
                    .truncationMode(.middle)

                HStack(spacing: 6) {
                    Text(formatBytes(item.originalSize))
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundStyle(Theme.mutedForeground)

                    Text("\(Int(item.dimensions.width))×\(Int(item.dimensions.height))")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundStyle(Theme.mutedForeground.opacity(0.7))
                }
            }

            Spacer()

            // Status indicator
            switch item.status {
            case .queued:
                if isHovered {
                    Button {
                        onRemove()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(Theme.mutedForeground)
                            .frame(width: 22, height: 22)
                            .background(Circle().fill(Theme.muted))
                            .contentShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .transition(.scale.combined(with: .opacity))
                }
            case .converting:
                ProgressView()
                    .controlSize(.small)
                    .tint(Theme.primary)
            case .done(let result):
                Text(result.savingsLabel)
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundStyle(result.didShrink ? Theme.success : Theme.destructive)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        Capsule().fill(
                            (result.didShrink ? Theme.success : Theme.destructive).opacity(0.12)
                        )
                    )
            case .failed:
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.destructive)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .onHover { isHovered = $0 }
        .animation(.easeOut(duration: 0.15), value: isHovered)
    }
}

func formatBytes(_ bytes: Int64) -> String {
    let formatter = ByteCountFormatter()
    formatter.countStyle = .file
    return formatter.string(fromByteCount: bytes)
}
