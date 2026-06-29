// swift-tools-version: 6.3.1

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
            name: "Binary Primitive",
            targets: ["Binary Primitive"]
        ),
        // MARK: - Variants
        .library(
            name: "Binary Endianness Primitives",
            targets: ["Binary Endianness Primitives"]
        ),
        // MARK: - Standard Library Integration
        .library(
            name: "Binary Primitives Standard Library Integration",
            targets: ["Binary Primitives Standard Library Integration"]
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
        .package(url: "https://github.com/swift-primitives/swift-byte-primitives.git", branch: "main"),
    ],
    targets: [
        // MARK: - Namespace
        //
        // Dependency-free binary-domain namespace (`enum Binary {}`). The
        // 2026-06-22 truly-primitive review superseded the 2026-05-20
        // owned-storage v3.0.0 promotion (which had made Binary a ~Copyable
        // struct over an owned typed byte buffer carrying five L1 deps — Byte,
        // Cardinal, Index, Memory, Ownership). binary-primitives is now
        // namespace + endianness + codec only: owned byte storage is
        // `Storage.Contiguous<Byte>` (swift-storage-primitives) and borrowed
        // byte views are `Swift.Span<Byte>`. The package floor is byte-only —
        // the codec (in the SLI target) is the sole Byte consumer; the
        // namespace target itself carries zero deps. See
        // `binary-byte-namespace-domain-foundations.md`.
        .target(
            name: "Binary Primitive",
            dependencies: []
        ),

        // MARK: - Core (removed 2026-05-20)
        //
        // The Binary Primitives Core target was deleted entirely after
        // the modularization arc completed — every domain split out into
        // its own per-namespace variant target (Alignment, Bitwise, Count,
        // Cursor, Endianness, Error, Format, Mask, Pattern, Position,
        // Space) and every stdlib-extension file relocated to the SLI
        // target per [MOD-010]. Consumers MUST import the specific variant
        // they need, or the umbrella product `Binary Primitives` for the
        // full surface. Follows the swift-memory-primitives precedent
        // ([MEMP-002]).

        // MARK: - Error (relocated 2026-06-22 to swift-binary-cursor-primitives)
        //
        // The `Binary.Error` taxonomy moved to the cursor package as the
        // per-type `Binary.Cursor.Error` / `Binary.Reader.Error` — its only
        // consumers. Removing it drops the error-domain surface from
        // binary-primitives, keeping the package truly primitive.

        // MARK: - Endianness
        //
        // Byte-order policy (`Binary.Endianness` 2-case enum + Tagged Value
        // typealias). Leaf variant — depends only on Binary Namespace and
        // Tagged Primitives directly (the only Dimension dep was via Tagged
        // re-export; Tagged owns Tagged so import Tagged directly).
        .target(
            name: "Binary Endianness Primitives",
            dependencies: [
                "Binary Primitive",
            ]
        ),

        // MARK: - Pattern (relocated to swift-bit-primitives)
        //
        // `Binary.Pattern<Carrier>` was a single-carrier bit-ring (Z/2^w)
        // operation — no byte-sequence or endianness semantics, i.e. bit-domain,
        // not binary-domain. Re-homed as `Bit.Pattern<Carrier>` in
        // swift-bit-primitives. Zero institute consumers at removal.

        // MARK: - Mask (removed — superseded by Memory.Alignment.mask)
        //
        // `Binary.Mask` was an Int-based alignment bitmask, fully covered by
        // `Memory.Alignment.mask<Carrier>()` / `Memory.Shift.mask<Carrier>()`
        // (which it already steered callers toward). Zero institute consumers
        // at removal; deleted rather than relocated. Drops the
        // swift-carrier-primitives dependency.

        // MARK: - Position / Offset / Count / Aligned / Space (removed 2026-05-20)
        //
        // These five variants (Binary.Position<Scalar, Space>, Binary.Offset,
        // Binary.Count, Binary.Aligned protocol, Binary.Space phantom type)
        // were deleted entirely after impact analysis showed zero institute-org
        // consumers (swift-primitives / swift-foundations / swift-standards).
        // Binary.Cursor + Binary.Reader had already migrated to the institute
        // canonical `Index<Storage>` typed-position pattern from
        // swift-index-primitives — making the dimensional Coordinate.X /
        // Displacement.X / Extent.X / Spatial vocabulary redundant. Removal
        // drops the swift-dimension-primitives dep entirely.
        //
        // Non-institute consumers (coenttb/) migrate to `Index<Space>` from
        // swift-index-primitives (the same pattern Binary.Cursor uses).

        // MARK: - Cursor (extracted 2026-05-22 to swift-binary-cursor-primitives)
        //
        // `Binary.Cursor<Storage>` + `Binary.Reader<Storage>` now live in
        // the sibling package `swift-binary-cursor-primitives`. Consumers
        // import `Binary_Cursor_Primitives` directly (subject-first naming
        // per `[API-NAME-001b]`).

        // MARK: - Format (extracted 2026-05-22)
        //
        // The former `Binary.Format` namespace was extracted and no longer
        // lives in this package.

        // MARK: - Standard Library Integration
        .target(
            name: "Binary Primitives Standard Library Integration",
            dependencies: [
                "Binary Primitive",
                "Binary Endianness Primitives",
                .product(name: "Byte Primitives", package: "swift-byte-primitives"),
                .product(name: "Byte Primitives Standard Library Integration", package: "swift-byte-primitives"),
            ]
        ),

        // MARK: - Umbrella
        .target(
            name: "Binary Primitives",
            dependencies: [
                "Binary Primitive",
                "Binary Endianness Primitives",
                "Binary Primitives Standard Library Integration",
            ]
        ),

        // MARK: - Test Support
        .target(
            name: "Binary Primitives Test Support",
            dependencies: [
                "Binary Primitives",
            ],
            path: "Tests/Support"
        ),
        .testTarget(
            name: "Binary Primitives Tests",
            dependencies: [
                "Binary Primitives",
                "Binary Primitives Standard Library Integration",
                "Binary Primitives Test Support",
            ]
        ),
        .testTarget(
            name: "Binary Primitives Standard Library Integration Tests",
            dependencies: [
                "Binary Primitives",
                "Binary Primitives Standard Library Integration",
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
