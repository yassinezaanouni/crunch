import SwiftUI
import UniformTypeIdentifiers

// MARK: - Back Button

struct BackButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
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
    }
}

// MARK: - Page Header

struct PageHeader<Trailing: View>: View {
    let title: String
    let onBack: () -> Void
    @ViewBuilder let trailing: Trailing

    init(title: String, onBack: @escaping () -> Void, @ViewBuilder trailing: () -> Trailing = { EmptyView() }) {
        self.title = title
        self.onBack = onBack
        self.trailing = trailing()
    }

    var body: some View {
        HStack {
            BackButton(action: onBack)
            Spacer()
            Text(title)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(Theme.foreground)
            Spacer()
            trailing
                .frame(minWidth: 40, alignment: .trailing)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
}

// MARK: - Mini Drop Zone

struct MiniDropZone: View {
    let onTap: () -> Void
    let onDrop: ([URL]) -> Void

    @State private var isHovering = false
    @State private var dashPhase: CGFloat = 0

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "plus")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Theme.primary)
            Text("Drop or click to add more")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(Theme.mutedForeground)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(
                    Theme.primary.opacity(isHovering ? 0.8 : 0.3),
                    style: StrokeStyle(lineWidth: 1.2, dash: [6, 4], dashPhase: dashPhase)
                )
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isHovering ? Theme.accent : .clear)
                )
        )
        .contentShape(RoundedRectangle(cornerRadius: 10))
        .onTapGesture { onTap() }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .onAppear {
            withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
                dashPhase = 40
            }
        }
        .onDrop(of: [.fileURL], isTargeted: $isHovering) { providers in
            handleDrop(providers)
            return true
        }
        .animation(.easeOut(duration: 0.15), value: isHovering)
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
                    onDrop([url])
                }
            }
        }
    }
}

// MARK: - File Picker Helper

func openImagePicker(onSelect: @escaping ([URL]) -> Void) {
    let panel = NSOpenPanel()
    panel.allowsMultipleSelection = true
    panel.canChooseDirectories = false
    panel.allowedContentTypes = [.image, .png, .jpeg, .heic, .tiff, .bmp, .gif, .webP]
    panel.title = "Select Images"
    panel.level = .floating
    panel.begin { response in
        if response == .OK {
            onSelect(panel.urls)
        }
    }
}

// MARK: - Byte Formatter

func formatBytes(_ bytes: Int64) -> String {
    let formatter = ByteCountFormatter()
    formatter.countStyle = .file
    return formatter.string(fromByteCount: bytes)
}
