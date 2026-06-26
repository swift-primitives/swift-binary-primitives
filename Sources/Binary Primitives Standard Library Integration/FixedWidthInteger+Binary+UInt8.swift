// FixedWidthInteger+Binary+UInt8.swift
//
// Stdlib-interop UInt8 forwarders for `FixedWidthInteger` byte serialization.
// Primary byte-domain API lives alongside in `FixedWidthInteger+Binary.swift`;
// these forwarders bridge stdlib callers carrying `[UInt8]` / `Collection<UInt8>`
// (e.g. network buffers, file-read frames) via `[Byte](uint8s)` / `.underlying`.
// Per [API-BYTE-007] (byte-discipline skill).

public import Binary_Endianness_Primitives
internal import Byte_Primitives
internal import Byte_Primitives_Standard_Library_Integration

// MARK: - FixedWidthInteger Byte Serialization Forwarders

extension FixedWidthInteger {
    /// Stdlib-interop forwarder: static byte serialization returning `[UInt8]`.
    @_disfavoredOverload
    @inlinable
    public static func bytes(_ value: Self, endianness: Binary.Endianness = .little) -> [UInt8] {
        let typed: [Byte] = Self.bytes(value, endianness: endianness)
        return typed.underlying
    }

    /// Stdlib-interop forwarder: instance byte serialization returning `[UInt8]`.
    @_disfavoredOverload
    @inlinable
    public func bytes(endianness: Binary.Endianness = .little) -> [UInt8] {
        Self.bytes(self, endianness: endianness)
    }

    /// Stdlib-interop forwarder: init from `[UInt8]`.
    @_disfavoredOverload
    @inlinable
    public init?(bytes: [UInt8], endianness: Binary.Endianness = .little) {
        self.init(bytes: [Byte](bytes), endianness: endianness)
    }
}

// MARK: - Array<FixedWidthInteger> Deserialization Forwarder

extension Array where Element: FixedWidthInteger {
    /// Stdlib-interop forwarder: init from `Collection` of `UInt8`.
    @_disfavoredOverload
    @inlinable
    public init?<C: Swift.Collection>(bytes: C, endianness: Binary.Endianness = .little)
    where C.Element == UInt8 {
        self.init(bytes: bytes.lazy.map(Byte.init), endianness: endianness)
    }
}
