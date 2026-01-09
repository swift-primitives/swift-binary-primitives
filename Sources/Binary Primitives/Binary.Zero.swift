extension Binary {
    /// Zeroes all bytes in the given buffer.
    ///
    /// This is the canonical algorithm for zeroing a `Binary.Mutable` buffer.
    ///
    /// ## Example
    ///
    /// ```swift
    /// var buffer = [UInt8](repeating: 0xFF, count: 16)
    /// Binary.zero(&buffer)
    /// // buffer is now all zeros
    /// ```
    ///
    /// - Parameter buffer: The buffer to zero.
    @inlinable
    public static func zero<Buffer: Binary.Mutable & ~Copyable>(
        _ buffer: inout Buffer
    ) {
        // swiftlint:disable:next empty_count
        guard buffer.count > 0 else { return }

        buffer.withUnsafeMutableBytes { ptr in
            guard let base = ptr.baseAddress else { return }
            base.initializeMemory(as: UInt8.self, repeating: 0, count: ptr.count)
        }
    }

    /// Zeroes bytes in the specified range of the given buffer.
    ///
    /// ## Example
    ///
    /// ```swift
    /// var buffer = [UInt8](repeating: 0xFF, count: 16)
    /// Binary.zero(&buffer, range: 4..<12)
    /// // buffer is now [0xFF, 0xFF, 0xFF, 0xFF, 0, 0, 0, 0, 0, 0, 0, 0, 0xFF, 0xFF, 0xFF, 0xFF]
    /// ```
    ///
    /// - Parameters:
    ///   - buffer: The buffer to partially zero.
    ///   - range: The range of bytes to zero.
    ///
    /// - Precondition: `range.lowerBound >= 0`
    /// - Precondition: `range.upperBound <= buffer.count`
    @inlinable
    public static func zero<Buffer: Binary.Mutable & ~Copyable>(
        _ buffer: inout Buffer,
        range: Range<Int>
    ) {
        precondition(range.lowerBound >= 0, "range.lowerBound must be non-negative")
        precondition(range.upperBound <= buffer.count, "range.upperBound exceeds buffer bounds")

        guard !range.isEmpty else { return }

        buffer.withUnsafeMutableBytes { ptr in
            guard let base = ptr.baseAddress else { return }
            base.advanced(by: range.lowerBound)
                .initializeMemory(as: UInt8.self, repeating: 0, count: range.count)
        }
    }

    /// Zeroes bytes from the given offset to the end of the buffer.
    ///
    /// ## Example
    ///
    /// ```swift
    /// var buffer = [UInt8](repeating: 0xFF, count: 16)
    /// Binary.zero(&buffer, from: 8)
    /// // buffer is now [0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0, 0, 0, 0, 0, 0, 0, 0]
    /// ```
    ///
    /// - Parameters:
    ///   - buffer: The buffer to partially zero.
    ///   - offset: The starting offset from which to zero.
    ///
    /// - Precondition: `offset >= 0`
    /// - Precondition: `offset <= buffer.count`
    @inlinable
    public static func zero<Buffer: Binary.Mutable & ~Copyable>(
        _ buffer: inout Buffer,
        from offset: Int
    ) {
        precondition(offset >= 0, "offset must be non-negative")
        precondition(offset <= buffer.count, "offset exceeds buffer bounds")

        zero(&buffer, range: offset..<buffer.count)
    }
}
