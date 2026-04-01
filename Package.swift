// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "Crunch",
    platforms: [
        .macOS(.v14)
    ],
    targets: [
        .executableTarget(
            name: "Crunch",
            path: ".",
            exclude: ["Package.swift", "screenshots", "LICENSE", "README.md"],
            swiftSettings: [
                .unsafeFlags(["-parse-as-library"])
            ]
        )
    ]
)
