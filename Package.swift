// swift-tools-version: 6.3

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
        // MARK: - Namespace
        .library(
            name: "Binary Namespace",
            targets: ["Binary Namespace"]
        ),
        // MARK: - Core
        .library(
            name: "Binary Primitives Core",
            targets: ["Binary Primitives Core"]
        ),
        .library(
            name: "Binary Cursor Primitives",
            targets: ["Binary Cursor Primitives"]
        ),
        .library(
            name: "Binary LEB128 Primitives",
            targets: ["Binary LEB128 Primitives"]
        ),
        // MARK: - Variants
        .library(
            name: "Binary Format Primitives",
            targets: ["Binary Format Primitives"]
        ),
        .library(
            name: "Binary Serializable Primitives",
            targets: ["Binary Serializable Primitives"]
        ),
        // MARK: - Umbrella
        .library(
            name: "Binary Primitives",
            targets: ["Binary Primitives"]
        ),
        // MARK: - Test Support
        .library(
            name: "Binary Primitives Test Support",
            targets: ["Binary Primitives Test Support"]
        ),
    ],
    dependencies: [
        .package(path: "../swift-bit-primitives"),
        .package(path: "../swift-dimension-primitives"),
        .package(path: "../swift-format-primitives"),
        .package(path: "../swift-index-primitives"),
        .package(path: "../swift-memory-primitives"),
        .package(path: "../swift-serializer-primitives"),
        .package(path: "../swift-standard-library-extensions"),
    ],
    targets: [
        // MARK: - Namespace
        .target(
            name: "Binary Namespace",
            dependencies: []
        ),

        // MARK: - Core
        .target(
            name: "Binary Primitives Core",
            dependencies: [
                "Binary Namespace",
                .product(name: "Bit Primitives", package: "swift-bit-primitives"),
                .product(name: "Dimension Primitives", package: "swift-dimension-primitives"),
                .product(name: "Index Primitives", package: "swift-index-primitives"),
                .product(name: "Memory Primitives Core", package: "swift-memory-primitives"),
                .product(name: "Standard Library Extensions", package: "swift-standard-library-extensions"),
            ]
        ),

        // MARK: - Cursor
        .target(
            name: "Binary Cursor Primitives",
            dependencies: [
                "Binary Primitives Core",
            ]
        ),

        // MARK: - LEB128
        .target(
            name: "Binary LEB128 Primitives",
            dependencies: [
                "Binary Primitives Core",
            ]
        ),

        // MARK: - Variants
        .target(
            name: "Binary Format Primitives",
            dependencies: [
                "Binary Primitives Core",
                .product(name: "Format Primitives", package: "swift-format-primitives"),
            ]
        ),
        .target(
            name: "Binary Serializable Primitives",
            dependencies: [
                "Binary Primitives Core",
                .product(name: "Serialization Primitives", package: "swift-serializer-primitives"),
            ]
        ),

        // MARK: - Umbrella
        .target(
            name: "Binary Primitives",
            dependencies: [
                "Binary Namespace",
                "Binary Primitives Core",
                "Binary Cursor Primitives",
                "Binary LEB128 Primitives",
                "Binary Format Primitives",
                "Binary Serializable Primitives",
            ]
        ),

        // MARK: - Test Support
        .target(
            name: "Binary Primitives Test Support",
            dependencies: [
                "Binary Primitives",
                .product(name: "Memory Primitives Test Support", package: "swift-memory-primitives"),
                .product(name: "Bit Primitives Test Support", package: "swift-bit-primitives"),
            ],
            path: "Tests/Support"
        ),
        .testTarget(
            name: "Binary Primitives Tests",
            dependencies: [
                "Binary Primitives",
                "Binary Primitives Test Support",
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("LifetimeDependence"),
        .enableExperimentalFeature("Lifetimes"),
        .enableExperimentalFeature("SuppressedAssociatedTypes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
        .enableUpcomingFeature("LifetimeDependence"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
