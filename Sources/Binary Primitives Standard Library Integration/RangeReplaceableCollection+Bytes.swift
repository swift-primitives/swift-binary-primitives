// RangeReplaceableCollection+Bytes.swift
// Mutation helpers for byte collections.

// MARK: - Byte Mutation Helpers (Byte primary)

extension RangeReplaceableCollection<Byte> {
    /// Appends a UTF-8 encoded string as bytes.
    ///
    /// Converts the string to UTF-8 and appends the bytes to the collection.
    /// Use this for building byte buffers from text content. The
    /// `String.UTF8View` (`UInt8` element) bridges to a `Buffer<Byte>` via the
    /// BSLI cross-domain `append(contentsOf:) where S.Element == UInt8`
    /// extension on `RangeReplaceableCollection where Element: Byte.Protocol`.
    ///
    /// ## Example
    ///
    /// ```swift
    /// var buffer: [Byte] = []
    /// RangeReplaceableCollection.append(utf8: "Hello", to: &buffer)
    /// // buffer is now [72, 101, 108, 108, 111]
    /// ```
    ///
    /// - Parameters:
    ///   - string: The string to append as UTF-8 bytes
    ///   - buffer: The buffer to append to
    @inlinable
    // swiftlint:disable:next prefer_self_in_static_references
    public static func append<S: StringProtocol, Buffer: RangeReplaceableCollection>(
        utf8 string: S,
        to buffer: inout Buffer
    ) where Buffer.Element == Byte {
        buffer.append(contentsOf: string.utf8)
    }

    /// Appends a UTF-8 encoded string as bytes.
    ///
    /// Converts the string to UTF-8 and appends the bytes to the collection.
    /// Use this for building byte buffers from text content.
    ///
    /// ## Example
    ///
    /// ```swift
    /// var buffer: [Byte] = []
    /// buffer.append(utf8: "Hello")
    /// // buffer is now [72, 101, 108, 108, 111]
    /// ```
    ///
    /// - Parameter string: The string to append as UTF-8 bytes
    @inlinable
    public mutating func append(utf8 string: some StringProtocol) {
        Self.append(utf8: string, to: &self)
    }

    /// Appends a single byte to the collection.
    ///
    /// ## Example
    ///
    /// ```swift
    /// var buffer: [Byte] = []
    /// RangeReplaceableCollection.append(0x41, to: &buffer)
    /// // buffer is now [65]
    /// ```
    ///
    /// - Parameters:
    ///   - value: The byte value to append
    ///   - buffer: The buffer to append to
    @inlinable
    // swiftlint:disable:next prefer_self_in_static_references
    public static func append<Buffer: RangeReplaceableCollection>(
        _ value: Byte,
        to buffer: inout Buffer
    ) where Buffer.Element == Byte {
        buffer.append(contentsOf: CollectionOfOne(value))
    }
}

// Stdlib-interop UInt8 forwarders live in
// `Binary Primitives Standard Library Integration` per [API-BYTE-007].
