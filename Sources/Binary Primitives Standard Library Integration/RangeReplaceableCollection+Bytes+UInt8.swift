// RangeReplaceableCollection+Bytes+UInt8.swift
//
// Stdlib-interop UInt8 forwarders for `RangeReplaceableCollection<UInt8>` byte
// mutation helpers. Primary byte-domain API lives alongside in
// `RangeReplaceableCollection+Bytes.swift`. These forwarders bridge stdlib
// callers carrying `[UInt8]` buffers. Per [API-BYTE-007] (byte-discipline skill).

internal import Byte_Primitives

extension RangeReplaceableCollection<UInt8> {
    /// Stdlib-interop forwarder: appends a UTF-8 encoded string as bytes into a `[UInt8]` buffer.
    @_disfavoredOverload
    @inlinable
    // swiftlint:disable:next prefer_self_in_static_references
    public static func append<S: StringProtocol, Buffer: RangeReplaceableCollection>(
        utf8 string: S,
        to buffer: inout Buffer
    ) where Buffer.Element == UInt8 {
        buffer.append(contentsOf: string.utf8)
    }

    /// Stdlib-interop forwarder: appends a UTF-8 encoded string as bytes into a `[UInt8]` buffer.
    @_disfavoredOverload
    @inlinable
    public mutating func append(utf8 string: some StringProtocol) {
        Self.append(utf8: string, to: &self)
    }

    /// Stdlib-interop forwarder: appends a single `UInt8` byte to a `[UInt8]` buffer.
    @_disfavoredOverload
    @inlinable
    // swiftlint:disable:next prefer_self_in_static_references
    public static func append<Buffer: RangeReplaceableCollection>(
        _ value: UInt8,
        to buffer: inout Buffer
    ) where Buffer.Element == UInt8 {
        buffer.append(contentsOf: CollectionOfOne(value))
    }
}
