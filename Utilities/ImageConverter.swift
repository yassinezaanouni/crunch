import Foundation
import AppKit
import ImageIO
import UniformTypeIdentifiers

enum ConversionError: LocalizedError {
    case noCGImage
    case destinationFailed
    case webpEncoderNotFound
    case webpEncodingFailed(String)
    case outputLocationInvalid

    var errorDescription: String? {
        switch self {
        case .noCGImage: "Could not extract image data"
        case .destinationFailed: "Could not create output file"
        case .webpEncoderNotFound: "cwebp not found — install with: brew install webp"
        case .webpEncodingFailed(let msg): "WebP encoding failed: \(msg)"
        case .outputLocationInvalid: "Cannot determine output location"
        }
    }
}

enum ImageConverter {

    static func convert(
        _ item: ImageItem,
        to format: OutputFormat,
        quality: Double,
        outputLocation: OutputLocation
    ) async throws -> ConversionResult {
        let outputURL = try resolveOutputURL(for: item, format: format, location: outputLocation)

        switch format {
        case .webp:
            try await convertToWebP(item: item, outputURL: outputURL, quality: quality)
        case .jpeg, .png, .heic:
            try convertWithImageIO(item: item, format: format, outputURL: outputURL, quality: quality)
        }

        let newSize = try FileManager.default.attributesOfItem(atPath: outputURL.path)[.size] as? Int64 ?? 0

        return ConversionResult(
            outputURL: outputURL,
            originalSize: item.originalSize,
            newSize: newSize,
            format: format
        )
    }

    // MARK: - WebP via cwebp CLI

    private static func convertToWebP(item: ImageItem, outputURL: URL, quality: Double) async throws {
        // First, write a temporary PNG for cwebp to read
        let tempDir = FileManager.default.temporaryDirectory
        let tempPNG = tempDir.appendingPathComponent("\(item.id.uuidString).png")

        defer { try? FileManager.default.removeItem(at: tempPNG) }

        guard let cgImage = item.image.cgImage(forProposedRect: nil, context: nil, hints: nil),
              let dest = CGImageDestinationCreateWithURL(tempPNG as CFURL, UTType.png.identifier as CFString, 1, nil)
        else { throw ConversionError.noCGImage }

        CGImageDestinationAddImage(dest, cgImage, nil)
        guard CGImageDestinationFinalize(dest) else { throw ConversionError.destinationFailed }

        // Find cwebp
        let cwebpPath = findCwebp()
        guard let cwebp = cwebpPath else { throw ConversionError.webpEncoderNotFound }

        let qualityInt = Int(quality * 100)

        let process = Process()
        process.executableURL = URL(fileURLWithPath: cwebp)
        process.arguments = [
            "-q", "\(qualityInt)",
            tempPNG.path,
            "-o", outputURL.path
        ]

        let errorPipe = Pipe()
        process.standardError = errorPipe

        try process.run()
        process.waitUntilExit()

        if process.terminationStatus != 0 {
            let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
            let errorMsg = String(data: errorData, encoding: .utf8) ?? "Unknown error"
            throw ConversionError.webpEncodingFailed(errorMsg)
        }
    }

    private static func findCwebp() -> String? {
        let paths = [
            "/opt/homebrew/bin/cwebp",
            "/usr/local/bin/cwebp",
            "/usr/bin/cwebp"
        ]
        return paths.first { FileManager.default.fileExists(atPath: $0) }
    }

    // MARK: - ImageIO (JPEG, PNG, HEIC)

    private static func convertWithImageIO(
        item: ImageItem,
        format: OutputFormat,
        outputURL: URL,
        quality: Double
    ) throws {
        guard let cgImage = item.image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            throw ConversionError.noCGImage
        }

        guard let dest = CGImageDestinationCreateWithURL(
            outputURL as CFURL,
            format.utType.identifier as CFString,
            1,
            nil
        ) else {
            throw ConversionError.destinationFailed
        }

        var options: [String: Any] = [:]
        if format.isLossy {
            options[kCGImageDestinationLossyCompressionQuality as String] = quality
        }

        CGImageDestinationAddImage(dest, cgImage, options as CFDictionary)

        guard CGImageDestinationFinalize(dest) else {
            throw ConversionError.destinationFailed
        }
    }

    // MARK: - Output Path

    private static func resolveOutputURL(
        for item: ImageItem,
        format: OutputFormat,
        location: OutputLocation
    ) throws -> URL {
        let dir: URL
        switch location {
        case .sameFolder:
            if let source = item.sourceURL {
                dir = source.deletingLastPathComponent()
            } else {
                dir = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first
                    ?? FileManager.default.temporaryDirectory
            }
        case .downloads:
            dir = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first
                ?? FileManager.default.temporaryDirectory
        }

        var outputURL = dir.appendingPathComponent("\(item.filename).\(format.ext)")

        // Avoid overwriting — append number if exists
        var counter = 1
        while FileManager.default.fileExists(atPath: outputURL.path) {
            outputURL = dir.appendingPathComponent("\(item.filename)-\(counter).\(format.ext)")
            counter += 1
        }

        return outputURL
    }
}
