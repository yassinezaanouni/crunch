import SwiftUI

struct ResultsView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        VStack(spacing: 0) {
            // Header
            resultsHeader
            Divider().overlay(Theme.border)

            // Summary
            if appState.items.contains(where: \.isDone) {
                summaryBar
                Divider().overlay(Theme.border)
            }

            // Results list
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(appState.items) { item in
                        ResultRow(item: item)
                        if item.id != appState.items.last?.id {
                            Divider().padding(.leading, 56)
                        }
                    }
                }
                .padding(.vertical, 4)
            }

            Divider().overlay(Theme.border)

            // Crunch more
            Button {
                appState.clearAll()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "plus")
                        .font(.system(size: 12, weight: .bold))
                    Text("Crunch More")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                }
                .foregroundStyle(Theme.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Theme.primary.opacity(0.12))
                )
                .contentShape(RoundedRectangle(cornerRadius: 10))
            }
            .buttonStyle(.plain)
            .padding(16)
        }
    }

    private var resultsHeader: some View {
        HStack {
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                    appState.showResults = false
                    appState.items.removeAll()
                }
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

            Text("Results")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(Theme.foreground)

            Spacer()

            // Balance spacer
            Text("Back").font(.system(size: 12)).hidden()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    private var summaryBar: some View {
        HStack(spacing: 8) {
            let doneCount = appState.items.filter(\.isDone).count

            Text("\(doneCount) image\(doneCount == 1 ? "" : "s") crunched")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(Theme.foreground)

            Spacer()

            if appState.totalOriginalSize > 0 {
                HStack(spacing: 4) {
                    Text(formatBytes(appState.totalOriginalSize))
                        .foregroundStyle(Theme.mutedForeground)
                    Image(systemName: "arrow.right")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundStyle(Theme.mutedForeground)
                    Text(formatBytes(appState.totalNewSize))
                        .foregroundStyle(Theme.foreground)
                }
                .font(.system(size: 11, weight: .medium, design: .monospaced))

                Text("\(Int(appState.totalSavingsPercent))% saved")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundStyle(Theme.success)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Capsule().fill(Theme.success.opacity(0.12)))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Theme.muted.opacity(0.5))
    }
}

private struct ResultRow: View {
    let item: ImageItem

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

            VStack(alignment: .leading, spacing: 3) {
                Text(item.filename)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Theme.foreground)
                    .lineLimit(1)
                    .truncationMode(.middle)

                if let result = item.result {
                    HStack(spacing: 4) {
                        Text(formatBytes(result.originalSize))
                            .foregroundStyle(Theme.mutedForeground)
                        Image(systemName: "arrow.right")
                            .font(.system(size: 7, weight: .bold))
                            .foregroundStyle(Theme.mutedForeground)
                        Text(formatBytes(result.newSize))
                            .foregroundStyle(Theme.foreground)
                    }
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                } else if case .failed(let msg) = item.status {
                    Text(msg)
                        .font(.system(size: 10))
                        .foregroundStyle(Theme.destructive)
                        .lineLimit(1)
                }
            }

            Spacer()

            if let result = item.result {
                // Savings badge
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

                // Show in Finder
                Button {
                    NSWorkspace.shared.activateFileViewerSelecting([result.outputURL])
                } label: {
                    Image(systemName: "folder")
                        .font(.system(size: 11))
                        .foregroundStyle(Theme.mutedForeground)
                        .frame(width: 24, height: 24)
                        .background(Circle().fill(Theme.muted))
                        .contentShape(Circle())
                }
                .buttonStyle(.plain)
            } else if case .failed = item.status {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.destructive)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}
