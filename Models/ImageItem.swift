import SwiftUI

enum ConversionStatus: Equatable {
    case queued
    case converting
    case done(ConversionResult)
    case failed(String)

    static func == (lhs: ConversionStatus, rhs: ConversionStatus) -> Bool {
        switch (lhs, rhs) {
        case (.queued, .queued), (.converting, .converting): return true
        case (.done(let a), .done(let b)): return a.outputURL == b.outputURL
        case (.failed(let a), .failed(let b)): return a == b
        default: return false
        }
    }
}

struct ImageItem: Identifiable {
    let id = UUID()
    let sourceURL: URL?
    let image: NSImage
    let originalSize: Int64
    let filename: String
    let dimensions: CGSize
    var status: ConversionStatus = .queued

    var isDone: Bool {
        if case .done = status { return true }
        return false
    }

    var result: ConversionResult? {
        if case .done(let r) = status { return r }
        return nil
    }
}
