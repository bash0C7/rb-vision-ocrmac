// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "VisionOcrmac",
    platforms: [.macOS(.v12)],
    products: [
        .library(
            name: "VisionOcrmac",
            type: .dynamic,
            targets: ["VisionOcrmac"]
        ),
    ],
    targets: [
        .target(
            name: "VisionOcrmac"
        ),
    ]
)
