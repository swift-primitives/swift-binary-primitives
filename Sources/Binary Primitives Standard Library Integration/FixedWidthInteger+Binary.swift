// FixedWidthInteger+Binary.swift
// Byte operations for fixed-width integers.

public import Binary_Endianness_Primitives
public import Byte_Primitives

// MARK: - Byte Serialization

extension FixedWidthInteger {
    /// Converts the integer to a byte array.
    ///
    /// Serializes the integer to bytes using the specified byte order.
    /// Use this for portable binary representation across different platforms.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let x: UInt16 = 0x1234
    ///
    /// let bigEndian = UInt16.bytes(x, endianness: .big)
    /// // [0x12, 0x34]
    ///
    /// let littleEndian = UInt16.bytes(x, endianness: .little)
    /// // [0x34, 0x12]
    /// ```
    ///
    /// - Parameters:
    ///   - value: The integer value to serialize
    ///   - endianness: Byte order for the output (defaults to little-endian)
    /// - Returns: Array of bytes representing the integer
    @inlinable
    public static func bytes(_ value: Self, endianness: Binary.Endianness = .little) -> [Byte] {
        var output: [Byte] = []
        output.reserveCapacity(MemoryLayout<Self>.size)
        value.bytes(into: &output, endianness: endianness)
        return output
    }

    // Stdlib-interop UInt8 byte serialization forwarders (static + instance) live
    // in `Binary Primitives Standard Library Integration` per [API-BYTE-007].

    /// Converts the integer to a byte array.
    ///
    /// Serializes the integer to bytes using the specified byte order.
    /// Use this for portable binary representation across different platforms.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let x: UInt16 = 0x1234
    ///
    /// let bigEndian = x.bytes(endianness: .big)
    /// // [0x12, 0x34]
    ///
    /// let littleEndian = x.bytes(endianness: .little)
    /// // [0x34, 0x12]
    /// ```
    ///
    /// - Parameter endianness: Byte order for the output (defaults to little-endian)
    /// - Returns: Array of bytes representing the integer
    @inlinable
    public func bytes(endianness: Binary.Endianness = .little) -> [Byte] {
        Self.bytes(self, endianness: endianness)
    }

    /// Creates an integer from a byte array.
    ///
    /// Deserializes bytes to an integer using the specified byte order.
    /// Returns `nil` if the byte count doesn't match the integer's size.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let bytes: [Byte] = [0x12, 0x34, 0x56, 0x78]
    /// let value = UInt32(bytes: bytes, endianness: .big)
    /// // 0x12345678
    ///
    /// let tooFewBytes: [Byte] = [0x12, 0x34]
    /// let invalid = UInt32(bytes: tooFewBytes, endianness: .big)
    /// // nil
    /// ```
    ///
    /// - Parameters:
    ///   - bytes: Byte array to deserialize (must be exactly the size of the integer type)
    ///   - endianness: Byte order of the input (defaults to little-endian)
    @inlinable
    public init?(bytes: some Collection<Byte>, endianness: Binary.Endianness = .little) {
        let size = MemoryLayout<Self>.size
        guard bytes.count == size else { return nil }
        var result: Self = 0
        var position = 0
        for byte in bytes {
            let index = endianness == .little ? position : size - 1 - position
            result |= Self(truncatingIfNeeded: byte.underlying) &<< Self(truncatingIfNeeded: index &* 8)
            position &+= 1
        }
        self = result
    }

    /// Reads a fixed-width integer from a borrowed contiguous byte view — the
    /// zero-copy decode primitive.
    ///
    /// `nil` if `bytes.count != MemoryLayout<Self>.size`.
    @inlinable
    public init?(_ bytes: borrowing Swift.Span<Byte>, endianness: Binary.Endianness = .little) {
        let size = MemoryLayout<Self>.size
        guard bytes.count == size else { return nil }
        var result: Self = 0
        for position in 0..<size {
            let index = endianness == .little ? position : size - 1 - position
            result |= Self(truncatingIfNeeded: bytes[position].underlying) &<< Self(truncatingIfNeeded: index &* 8)
        }
        self = result
    }

    /// Appends this integer's bytes, in the given byte order, into a caller-owned sink.
    ///
    /// The allocation-free encode primitive (reuse the sink to avoid a per-call
    /// allocation). Writes exactly `MemoryLayout<Self>.size` bytes.
    @inlinable
    public func bytes<Sink: RangeReplaceableCollection>(
        into sink: inout Sink,
        endianness: Binary.Endianness = .little
    ) where Sink.Element == Byte {
        let size = MemoryLayout<Self>.size
        for position in 0..<size {
            let index = endianness == .little ? position : size - 1 - position
            sink.append(Byte(UInt8(truncatingIfNeeded: self &>> Self(truncatingIfNeeded: index &* 8))))
        }
    }

    /// Returns this integer's bytes, in the given byte order, as a fresh buffer.
    ///
    /// Produces the caller's chosen `RangeReplaceableCollection` type. Built on
    /// ``bytes(into:endianness:)``.
    @inlinable
    public func bytes<Output: RangeReplaceableCollection>(
        endianness: Binary.Endianness = .little
    ) -> Output where Output.Element == Byte {
        var output = Output()
        output.reserveCapacity(MemoryLayout<Self>.size)
        bytes(into: &output, endianness: endianness)
        return output
    }

    // Stdlib-interop UInt8 init forwarder lives in
    // `Binary Primitives Standard Library Integration` per [API-BYTE-007].
}

// MARK: - Array Deserialization

extension Array where Element: FixedWidthInteger {
    /// Creates an array of integers from a flat byte collection.
    ///
    /// Deserializes a sequence of bytes into an array of integers. The byte count
    /// must be a multiple of the integer size. Returns `nil` if the byte count
    /// is not evenly divisible.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let bytes: [UInt8] = [0x01, 0x00, 0x02, 0x00]
    /// let values = [UInt16](bytes: bytes, endianness: .little)
    /// // [1, 2]
    ///
    /// let oddBytes: [UInt8] = [0x01, 0x00, 0x02]
    /// let invalid = [UInt16](bytes: oddBytes)
    /// // nil (3 bytes is not a multiple of 2)
    /// ```
    ///
    /// - Parameters:
    ///   - bytes: Collection of bytes representing multiple integers
    ///   - endianness: Byte order of the input (defaults to little-endian)
    @inlinable
    public init?<C: Swift.Collection>(bytes: C, endianness: Binary.Endianness = .little)
    where C.Element == Byte {
        let elementSize = MemoryLayout<Element>.size
        guard bytes.count % elementSize == 0 else { return nil }

        var result: [Element] = []
        result.reserveCapacity(bytes.count / elementSize)

        let byteArray: [Byte] = .init(bytes)
        for i in stride(from: 0, to: byteArray.count, by: elementSize) {
            let chunk: [Byte] = .init(byteArray[i..<i + elementSize])
            guard let element = Element(bytes: chunk, endianness: endianness) else {
                return nil
            }
            result.append(element)
        }

        self = result
    }

    // Stdlib-interop UInt8-collection init forwarder lives in
    // `Binary Primitives Standard Library Integration` per [API-BYTE-007].
}
