// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "swift-binary-primitives",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
        .visionOS(.v26),
    ],
    products: [
        .library(
            name: "Binary Primitives",
            targets: ["Binary Primitives"]
        ),
        .library(
            name: "Binary Parsing Primitives",
            targets: ["Binary Parsing Primitives"]
        ),
    ],
    dependencies: [
        .package(path: "../swift-bit-primitives"),
        .package(path: "../swift-dimension-primitives"),
        .package(path: "../swift-formatting-primitives"),
        .package(path: "../swift-input-primitives"),
        .package(path: "../swift-machine-primitives"),
        .package(path: "../swift-parsing-primitives"),
        .package(path: "../swift-serialization-primitives"),
        .package(path: "../swift-standard-library-extensions"),
    ],
    targets: [
        // Base target: fundamental binary concepts, no Parsing/Machine dependencies
        .target(
            name: "Binary Primitives",
            dependencies: [
                .product(name: "Bit Primitives", package: "swift-bit-primitives"),
                .product(name: "Dimension Primitives", package: "swift-dimension-primitives"),
                .product(name: "Formatting Primitives", package: "swift-formatting-primitives"),
                .product(name: "Serialization Primitives", package: "swift-serialization-primitives"),
                .product(name: "Standard Library Extensions", package: "swift-standard-library-extensions"),
            ]
        ),
        // Parsing target: Machine IR, interpreters, ParserPrinter types
        .target(
            name: "Binary Parsing Primitives",
            dependencies: [
                "Binary Primitives",
                .product(name: "Input Primitives", package: "swift-input-primitives"),
                .product(name: "Machine Primitives", package: "swift-machine-primitives"),
                .product(name: "Parsing Primitives", package: "swift-parsing-primitives"),
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let settings: [SwiftSetting] = [
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableExperimentalFeature("Lifetimes"),
        .strictMemorySafety(),
    ]
    target.swiftSettings = (target.swiftSettings ?? []) + settings
}
