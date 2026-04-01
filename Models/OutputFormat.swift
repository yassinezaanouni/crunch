import UniformTypeIdentifiers

enum OutputFormat: String, CaseIterable, Codable {
    case webp
    case jpeg
    case png
    case heic

    var label: String {
        switch self {
        case .webp: "WebP"
        case .jpeg: "JPEG"
        case .png:  "PNG"
        case .heic: "HEIC"
        }
    }

    var ext: String { rawValue }

    var utType: UTType {
        switch self {
        case .webp: .webP
        case .jpeg: .jpeg
        case .png:  .png
        case .heic: .heic
        }
    }

    var isLossy: Bool {
        switch self {
        case .webp, .jpeg, .heic: true
        case .png: false
        }
    }
}
