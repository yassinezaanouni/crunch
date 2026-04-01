import SwiftUI

enum OutputLocation: Equatable {
    case sameFolder
    case downloads

    var label: String {
        switch self {
        case .sameFolder: "Same Folder"
        case .downloads: "Downloads"
        }
    }
}

@Observable
final class AppState {

    // MARK: - Persisted

    var outputFormat: OutputFormat = {
        if let raw = UserDefaults.standard.string(forKey: "crunch.format"),
           let fmt = OutputFormat(rawValue: raw) {
            return fmt
        }
        return .webp
    }() {
        didSet { UserDefaults.standard.set(outputFormat.rawValue, forKey: "crunch.format") }
    }

    var quality: Double = {
        let v = UserDefaults.standard.double(forKey: "crunch.quality")
        return v > 0 ? v : 0.80
    }() {
        didSet { UserDefaults.standard.set(quality, forKey: "crunch.quality") }
    }

    var outputLocation: OutputLocation = {
        let v = UserDefaults.standard.integer(forKey: "crunch.outputLocation")
        return v == 1 ? .downloads : .sameFolder
    }() {
        didSet {
            UserDefaults.standard.set(outputLocation == .downloads ? 1 : 0, forKey: "crunch.outputLocation")
        }
    }

    var appearanceMode: Int = UserDefaults.standard.integer(forKey: "crunch.appearance") {
        didSet {
            UserDefaults.standard.set(appearanceMode, forKey: "crunch.appearance")
            applyAppearance()
        }
    }

    // MARK: - Transient

    var items: [ImageItem] = []
    var isConverting = false
    var showResults = false
    var showSettings = false
    var isDropTargeted = false

    // MARK: - Computed

    var hasItems: Bool { !items.isEmpty }
    var allDone: Bool { !items.isEmpty && items.allSatisfy(\.isDone) }
    var queuedCount: Int { items.filter { $0.status == .queued }.count }

    var totalOriginalSize: Int64 {
        items.compactMap(\.result).reduce(0) { $0 + $1.originalSize }
    }
    var totalNewSize: Int64 {
        items.compactMap(\.result).reduce(0) { $0 + $1.newSize }
    }
    var totalSavingsPercent: Double {
        guard totalOriginalSize > 0 else { return 0 }
        return Double(totalOriginalSize - totalNewSize) / Double(totalOriginalSize) * 100
    }

    // MARK: - Init

    init() {
        applyAppearance()
    }

    func applyAppearance() {
        DispatchQueue.main.async {
            guard let app = NSApp else { return }
            switch self.appearanceMode {
            case 1: app.appearance = NSAppearance(named: .aqua)
            case 2: app.appearance = NSAppearance(named: .darkAqua)
            default: app.appearance = nil
            }
        }
    }

    // MARK: - Actions

    func addImages(from urls: [URL]) {
        for url in urls {
            guard let image = NSImage(contentsOf: url) else { continue }
            let size = (try? FileManager.default.attributesOfItem(atPath: url.path)[.size] as? Int64) ?? 0
            let dims = image.representations.first.map {
                CGSize(width: $0.pixelsWide, height: $0.pixelsHigh)
            } ?? image.size
            let item = ImageItem(
                sourceURL: url,
                image: image,
                originalSize: size,
                filename: url.deletingPathExtension().lastPathComponent,
                dimensions: dims
            )
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                items.append(item)
            }
        }
    }

    func addImageFromPasteboard() {
        let pb = NSPasteboard.general

        // Try file URLs first
        if let urls = pb.readObjects(forClasses: [NSURL.self], options: [
            .urlReadingFileURLsOnly: true,
            .urlReadingContentsConformToTypes: ["public.image"]
        ]) as? [URL], !urls.isEmpty {
            addImages(from: urls)
            return
        }

        // Try image data
        if let imageData = pb.data(forType: .tiff) ?? pb.data(forType: .png),
           let image = NSImage(data: imageData) {
            let item = ImageItem(
                sourceURL: nil,
                image: image,
                originalSize: Int64(imageData.count),
                filename: "clipboard-\(Int(Date().timeIntervalSince1970))",
                dimensions: image.representations.first.map {
                    CGSize(width: $0.pixelsWide, height: $0.pixelsHigh)
                } ?? image.size
            )
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                items.append(item)
            }
        }
    }

    func removeItem(_ item: ImageItem) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
            items.removeAll { $0.id == item.id }
        }
    }

    func clearAll() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
            items.removeAll()
            showResults = false
        }
    }

    /// Go back to queue view keeping existing results, ready to add more images
    func addMoreFromResults() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
            showResults = false
        }
    }

    func convertAll() {
        isConverting = true
        let format = outputFormat
        let quality = quality
        let location = outputLocation

        Task {
            for i in items.indices {
                // Skip already converted items
                guard items[i].status == .queued else { continue }

                await MainActor.run {
                    items[i].status = .converting
                }

                do {
                    let result = try await ImageConverter.convert(
                        items[i],
                        to: format,
                        quality: quality,
                        outputLocation: location
                    )
                    await MainActor.run {
                        if i < items.count {
                            items[i].status = .done(result)
                        }
                    }
                } catch {
                    await MainActor.run {
                        if i < items.count {
                            items[i].status = .failed(error.localizedDescription)
                        }
                    }
                }
            }

            await MainActor.run {
                isConverting = false
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    showResults = true
                }
            }
        }
    }
}
