// Binary.Serializable.swift
// Streaming byte serialization protocol.

@_spi(Internal) import Identity_Primitives
public import Dimension_Primitives

/// Protocol for types that can serialize to byte streams.
///
/// Conforming types write their byte representation directly into any byte
/// collection, enabling efficient composition and streaming output. Use this
/// for building complex binary formats, HTML rendering, or protocol buffers.
///
/// ## Example
///
/// ```swift
/// struct Packet: Binary.Serializable {
///     let type: UInt8
///     let length: UInt16
///     let data: [UInt8]
///
///     static func serialize<Buffer: RangeReplaceableCollection>(
///         _ packet: Self,
///         into buffer: inout Buffer
///     ) where Buffer.Element == UInt8 {
///         buffer.append(packet.type)
///         buffer.append(contentsOf: packet.length.bytes(endianness: .big))
///         buffer.append(contentsOf: packet.data)
///     }
/// }
///
/// var output: [UInt8] = []
/// let packet = Packet(type: 1, length: 4, data: [0xDE, 0xAD, 0xBE, 0xEF])
/// packet.serialize(into: &output)
/// // output is now [1, 0, 4, 0xDE, 0xAD, 0xBE, 0xEF]
/// ```
extension Binary {
    public protocol Serializable: Sendable {
        /// Serializes a value into a byte buffer.
        ///
        /// Appends the byte representation to the buffer without clearing existing content.
        /// Implementations must be deterministic and infallible for valid values.
        ///
        /// - Parameters:
        ///   - serializable: The value to serialize
        ///   - buffer: The buffer to append bytes to
        static func serialize<Buffer: RangeReplaceableCollection>(
            _ serializable: Self,
            into buffer: inout Buffer
        ) where Buffer.Element == UInt8
    }
}

// MARK: - Convenience Extensions

extension Binary.Serializable {
    /// Serializes to a new byte array.
    ///
    /// Creates a new array and serializes into it. For repeated serialization,
    /// prefer `serialize(into:)` with a reusable buffer for better performance.

    public var bytes: [UInt8] {
        var buffer: [UInt8] = []
        Self.serialize(self, into: &buffer)
        return buffer
    }

    /// Serializes this value into a byte buffer.
    ///
    /// Instance method convenience that delegates to the static `serialize(_:into:)`.

    public func serialize<Buffer: RangeReplaceableCollection>(
        into buffer: inout Buffer
    ) where Buffer.Element == UInt8 {
        Self.serialize(self, into: &buffer)
    }
}

// MARK: - Static Returning Convenience

extension Binary.Serializable {
    /// Serializes to a new collection of the inferred type.
    ///
    /// Creates a new buffer and serializes into it. The return type is inferred
    /// from context, allowing serialization into any `RangeReplaceableCollection`.

    public static func serialize<Bytes: RangeReplaceableCollection>(
        _ serializable: Self
    ) -> Bytes where Bytes.Element == UInt8 {
        var buffer = Bytes()
        Self.serialize(serializable, into: &buffer)
        return buffer
    }
}

// MARK: - Zero-Copy Span Access

extension Binary.Serializable {
    /// Provides zero-copy access to serialized bytes via a Span.
    ///
    /// Default implementation creates a temporary ContiguousArray. Types with
    /// contiguous storage can override for true zero-copy access.
    ///
    /// - Parameters:
    ///   - value: The value to serialize
    ///   - body: Closure receiving borrowing access to the serialized bytes
    /// - Returns: The result of the body closure

    public static func withSerializedBytes<R, E: Error>(
        _ value: Self,
        _ body: (borrowing Span<UInt8>) throws(E) -> R
    ) throws(E) -> R {
        var buffer: ContiguousArray<UInt8> = []
        Self.serialize(value, into: &buffer)
        // Use Result to bridge typed throws across non-typed-throws boundary
        var result: Result<R, E>!
        buffer.withUnsafeBufferPointer { bufferPointer in
            let span = Span(_unsafeElements: bufferPointer)
            do throws(E) {
                result = .success(try body(span))
            } catch {
                result = .failure(error)
            }
        }
        return try result.get()
    }

    /// Instance method convenience for zero-copy Span access.

    public func withSerializedBytes<R, E: Error>(
        _ body: (borrowing Span<UInt8>) throws(E) -> R
    ) throws(E) -> R {
        try Self.withSerializedBytes(self, body)
    }
}

// MARK: - RangeReplaceableCollection Append

extension RangeReplaceableCollection<UInt8> {
    /// Appends a serializable value to the collection.
    ///
    /// Serializes the value and appends its bytes to the collection.

    @_disfavoredOverload
    public mutating func append<S: Binary.Serializable>(_ serializable: S) {
        S.serialize(serializable, into: &self)
    }
}

// MARK: - Collection Initializers

extension Array where Element == UInt8 {
    /// Creates a byte array from a serializable value.
    ///
    /// Serializes the value into a new array.

    @_disfavoredOverload
    public init<S: Binary.Serializable>(_ serializable: S) {
        self = []
        S.serialize(serializable, into: &self)
    }
}

extension ContiguousArray where Element == UInt8 {
    /// Creates a contiguous byte array from a serializable value.
    ///
    /// Serializes the value into a new contiguous array for better cache locality.

    @_disfavoredOverload
    public init<S: Binary.Serializable>(_ serializable: S) {
        self = []
        S.serialize(serializable, into: &self)
    }
}

// MARK: - String Conversion

extension StringProtocol {
    /// Creates a string by decoding a serializable value's UTF-8 output.
    ///
    /// Serializes the value to bytes and decodes as UTF-8.

    public init<T: Binary.Serializable>(_ value: T) {
        self = Self(decoding: value.bytes, as: UTF8.self)
    }
}

// MARK: - Direct Byte Array Conversions

extension String {
    /// Creates a string by decoding UTF-8 bytes.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let bytes: [UInt8] = [72, 101, 108, 108, 111]
    /// let string = String(bytes)
    /// // "Hello"
    /// ```
    ///
    /// - Parameter bytes: The UTF-8 encoded bytes to decode

    public init(_ bytes: [UInt8]) {
        self = String(decoding: bytes, as: UTF8.self)
    }

    /// Creates a string by decoding UTF-8 bytes from an array slice.
    ///
    /// - Parameter bytes: The UTF-8 encoded bytes to decode

    public init(_ bytes: ArraySlice<UInt8>) {
        self = String(decoding: bytes, as: UTF8.self)
    }
}

// MARK: - RawRepresentable Default Implementations

extension Binary.Serializable where Self: RawRepresentable, Self.RawValue: StringProtocol {
    /// Default serialization for string-backed `RawRepresentable` types.
    ///
    /// Serializes the raw value as UTF-8 bytes.

    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ serializable: Self,
        into buffer: inout Buffer
    ) where Buffer.Element == UInt8 {
        buffer.append(contentsOf: serializable.rawValue.utf8)
    }
}

extension Binary.Serializable where Self: RawRepresentable, Self.RawValue == [UInt8] {
    /// Default serialization for byte-array-backed `RawRepresentable` types.
    ///
    /// Serializes the raw value directly as bytes.

    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ serializable: Self,
        into buffer: inout Buffer
    ) where Buffer.Element == UInt8 {
        buffer.append(contentsOf: serializable.rawValue)
    }
}

// MARK: - Zero-Copy Optimization for RawRepresentable Types

extension Binary.Serializable where Self: RawRepresentable, Self.RawValue == [UInt8] {
    /// Optimized zero-copy access for [UInt8]-backed types.

    public static func withSerializedBytes<R, E: Error>(
        _ value: Self,
        _ body: (borrowing Span<UInt8>) throws(E) -> R
    ) throws(E) -> R {
        var result: Result<R, E>!
        value.rawValue.withUnsafeBufferPointer { bufferPointer in
            let span = Span(_unsafeElements: bufferPointer)
            do throws(E) {
                result = .success(try body(span))
            } catch {
                result = .failure(error)
            }
        }
        return try result.get()
    }
}

extension Binary.Serializable where Self: RawRepresentable, Self.RawValue: StringProtocol {
    /// Optimized access for StringProtocol-backed types via UTF-8.

    public static func withSerializedBytes<R, E: Error>(
        _ value: Self,
        _ body: (borrowing Span<UInt8>) throws(E) -> R
    ) throws(E) -> R {
        let utf8 = ContiguousArray(value.rawValue.utf8)
        var result: Result<R, E>!
        utf8.withUnsafeBufferPointer { bufferPointer in
            let span = Span(_unsafeElements: bufferPointer)
            do throws(E) {
                result = .success(try body(span))
            } catch {
                result = .failure(error)
            }
        }
        return try result.get()
    }
}

// MARK: - RawRepresentable<FixedWidthInteger> Default Implementation

extension Binary.Serializable where Self: RawRepresentable, Self.RawValue: FixedWidthInteger {
    /// Default serialization for integer-backed `RawRepresentable` types.
    ///
    /// Serializes the raw value in native byte order for optimal performance.
    /// For cross-platform serialization, use `rawValue.bytes(endianness:)` explicitly.
    @inlinable
    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ value: Self,
        into buffer: inout Buffer
    ) where Buffer.Element == UInt8 {
        #if _endian(little)
        buffer.append(contentsOf: value.rawValue.bytes(endianness: .little))
        #else
        buffer.append(contentsOf: value.rawValue.bytes(endianness: .big))
        #endif
    }
}

// MARK: - Tagged Conformance
extension Tagged: Binary.Serializable where RawValue: Binary.Serializable {
    /// Serializes a tagged value by serializing its underlying raw value.
    ///
    /// Delegates to the raw value's serialization implementation.

    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ value: Self,
        into buffer: inout Buffer
    ) where Buffer.Element == UInt8 {
        RawValue.serialize(value._storage, into: &buffer)
    }

    /// Delegates to raw value's withSerializedBytes for optimal performance.

    public static func withSerializedBytes<R, E: Error>(
        _ value: Self,
        _ body: (borrowing Span<UInt8>) throws(E) -> R
    ) throws(E) -> R {
        try RawValue.withSerializedBytes(value._storage, body)
    }
}

// MARK: - Byte Collection Conformances

extension Array: Binary.Serializable where Element == UInt8 {
    /// Serializes a byte array by appending its contents directly.

    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ value: Self,
        into buffer: inout Buffer
    ) where Buffer.Element == UInt8 {
        buffer.append(contentsOf: value)
    }

    /// Zero-copy access to the array's bytes.

    public static func withSerializedBytes<R, E: Error>(
        _ value: Self,
        _ body: (borrowing Span<UInt8>) throws(E) -> R
    ) throws(E) -> R {
        var result: Result<R, E>!
        value.withUnsafeBufferPointer { bufferPointer in
            let span = Span(_unsafeElements: bufferPointer)
            do throws(E) {
                result = .success(try body(span))
            } catch {
                result = .failure(error)
            }
        }
        return try result.get()
    }
}

extension ContiguousArray: Binary.Serializable where Element == UInt8 {
    /// Serializes a contiguous byte array by appending its contents directly.

    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ value: Self,
        into buffer: inout Buffer
    ) where Buffer.Element == UInt8 {
        buffer.append(contentsOf: value)
    }

    /// Zero-copy access to the contiguous array's bytes.

    public static func withSerializedBytes<R, E: Error>(
        _ value: Self,
        _ body: (borrowing Span<UInt8>) throws(E) -> R
    ) throws(E) -> R {
        var result: Result<R, E>!
        value.withUnsafeBufferPointer { bufferPointer in
            let span = Span(_unsafeElements: bufferPointer)
            do throws(E) {
                result = .success(try body(span))
            } catch {
                result = .failure(error)
            }
        }
        return try result.get()
    }
}

extension ArraySlice: Binary.Serializable where Element == UInt8 {
    /// Serializes a byte array slice by appending its contents directly.

    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ value: Self,
        into buffer: inout Buffer
    ) where Buffer.Element == UInt8 {
        buffer.append(contentsOf: value)
    }
}
