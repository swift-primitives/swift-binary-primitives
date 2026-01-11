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
    ],
    dependencies: [
        .package(path: "../swift-dimension-primitives"),
        .package(path: "../swift-formatting-primitives"),
        .package(path: "../swift-parsing-primitives"),
        .package(path: "../swift-test-primitives"),
    ],
    targets: [
        .target(
            name: "Binary Primitives",
            dependencies: [
                .product(name: "Dimension Primitives", package: "swift-dimension-primitives"),
                .product(name: "Formatting Primitives", package: "swift-formatting-primitives"),
                .product(name: "Parsing Primitives", package: "swift-parsing-primitives"),
            ]
        ),
        .testTarget(
            name: "Binary Primitives Tests",
            dependencies: [
                "Binary Primitives",
                .product(name: "Test Primitives", package: "swift-test-primitives"),
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin].contains(target.type) {
    let settings: [SwiftSetting] = [
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableExperimentalFeature("Lifetimes"),
    ]
    target.swiftSettings = (target.swiftSettings ?? []) + settings
}
