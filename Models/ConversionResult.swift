import Foundation

struct ConversionResult {
    let outputURL: URL
    let originalSize: Int64
    let newSize: Int64
    let format: OutputFormat

    var savingsPercent: Double {
        guard originalSize > 0 else { return 0 }
        return Double(originalSize - newSize) / Double(originalSize) * 100
    }

    var savingsLabel: String {
        if newSize >= originalSize {
            return "+\(Int(abs(savingsPercent)))%"
        }
        return "-\(Int(savingsPercent))%"
    }

    var didShrink: Bool { newSize < originalSize }
}
