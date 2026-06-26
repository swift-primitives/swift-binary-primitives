// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-binary-primitives open source project
//
// Copyright (c) 2024-2026 Coen ten Thije Boonkkamp and the swift-binary-primitives project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

/// The binary-domain namespace.
///
/// `Binary` is a pure, dependency-free namespace grouping the binary-domain
/// vocabulary: byte-order policy (``Binary/Endianness``) and the
/// fixed-width-integer ↔ byte codec (`value.bytes(endianness:)` /
/// `T(bytes:endianness:)`, defined in the
/// `Binary Primitives Standard Library Integration` target). It carries no
/// storage of its own.
///
/// - Owned byte buffers: use `Storage.Contiguous<Byte>`
///   (swift-storage-primitives).
/// - Borrowed byte views: use `Swift.Span<Byte>`; binary-domain parse /
///   serialize operations attach to `Span.\`Protocol\`` where `Element == Byte`
///   (swift-binary-parser-primitives / swift-binary-serializer-primitives).
///
/// ## History
///
/// A 2026-05-20 promotion (v3.0.0) made `Binary` an owned `~Copyable` storage
/// struct over an owned typed byte buffer. The 2026-06-22 truly-primitive
/// review superseded that promotion: `Binary` reverts to a dependency-free
/// namespace (endianness + codec only); owned byte storage is
/// `Storage.Contiguous<Byte>`. See
/// `swift-institute/Research/binary-byte-namespace-domain-foundations.md`.
public enum Binary {}
