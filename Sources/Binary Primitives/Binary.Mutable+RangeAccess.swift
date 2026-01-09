extension Binary.Mutable {
    /// Provides mutable access to a subrange of bytes.
    ///
    /// This is the universal fallback for mutable range access when direct
    /// subscript access is not available. The closure-based API ensures
    /// proper lifetime scoping.
    ///
    /// ## Example
    ///
    /// ```swift
    /// func zeroHeader<T: Binary.Mutable>(_ data: inout T) {
    ///     data.withMutableBytes(in: 0..<16) { header in
    ///         header.initializeMemory(as: UInt8.self, repeating: 0)
    ///     }
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - range: The range of bytes to access.
    ///   - body: A closure that receives a mutable buffer pointer to the range.
    /// - Returns: The value returned by `body`.
    /// - Throws: The error thrown by `body`.
    ///
    /// - Precondition: `range.lowerBound >= 0`
    /// - Precondition: `range.upperBound <= count`
    @inlinable
    public mutating func withMutableBytes<R, E: Swift.Error>(
        in range: Range<Int>,
        _ body: (UnsafeMutableRawBufferPointer) throws(E) -> R
    ) throws(E) -> R {
        try withUnsafeMutableBytes { (buffer: UnsafeMutableRawBufferPointer) throws(E) -> R in
            precondition(range.lowerBound >= 0, "range.lowerBound must be non-negative")
            precondition(range.upperBound <= buffer.count, "range.upperBound exceeds buffer bounds")
            let subBuffer = UnsafeMutableRawBufferPointer(rebasing: buffer[range])
            return try body(subBuffer)
        }
    }

    /// Provides mutable access to bytes from a given offset to the end.
    ///
    /// - Parameters:
    ///   - offset: The starting offset.
    ///   - body: A closure that receives a mutable buffer pointer.
    /// - Returns: The value returned by `body`.
    /// - Throws: The error thrown by `body`.
    @inlinable
    public mutating func withMutableBytes<R, E: Swift.Error>(
        from offset: Int,
        _ body: (UnsafeMutableRawBufferPointer) throws(E) -> R
    ) throws(E) -> R {
        try withUnsafeMutableBytes { (buffer: UnsafeMutableRawBufferPointer) throws(E) -> R in
            precondition(offset >= 0, "offset must be non-negative")
            precondition(offset <= buffer.count, "offset exceeds buffer bounds")
            let subBuffer = UnsafeMutableRawBufferPointer(rebasing: buffer[offset...])
            return try body(subBuffer)
        }
    }
}

extension Binary.Contiguous {
    /// Provides read-only access to a subrange of bytes.
    ///
    /// This is the universal fallback for range access when direct
    /// subscript access is not available. The closure-based API ensures
    /// proper lifetime scoping.
    ///
    /// ## Example
    ///
    /// ```swift
    /// func readHeader<T: Binary.Contiguous>(_ data: borrowing T) -> UInt32 {
    ///     data.withUnsafeBytes(in: 0..<4) { header in
    ///         header.loadUnaligned(as: UInt32.self)
    ///     }
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - range: The range of bytes to access.
    ///   - body: A closure that receives a buffer pointer to the range.
    /// - Returns: The value returned by `body`.
    /// - Throws: The error thrown by `body`.
    ///
    /// - Precondition: `range.lowerBound >= 0`
    /// - Precondition: `range.upperBound <= count`
    @inlinable
    public func withUnsafeBytes<R, E: Swift.Error>(
        in range: Range<Int>,
        _ body: (UnsafeRawBufferPointer) throws(E) -> R
    ) throws(E) -> R {
        try withUnsafeBytes { (buffer: UnsafeRawBufferPointer) throws(E) -> R in
            precondition(range.lowerBound >= 0, "range.lowerBound must be non-negative")
            precondition(range.upperBound <= buffer.count, "range.upperBound exceeds buffer bounds")
            let subBuffer = UnsafeRawBufferPointer(rebasing: buffer[range])
            return try body(subBuffer)
        }
    }

    /// Provides read-only access to bytes from a given offset to the end.
    ///
    /// - Parameters:
    ///   - offset: The starting offset.
    ///   - body: A closure that receives a buffer pointer.
    /// - Returns: The value returned by `body`.
    /// - Throws: The error thrown by `body`.
    @inlinable
    public func withUnsafeBytes<R, E: Swift.Error>(
        from offset: Int,
        _ body: (UnsafeRawBufferPointer) throws(E) -> R
    ) throws(E) -> R {
        try withUnsafeBytes { (buffer: UnsafeRawBufferPointer) throws(E) -> R in
            precondition(offset >= 0, "offset must be non-negative")
            precondition(offset <= buffer.count, "offset exceeds buffer bounds")
            let subBuffer = UnsafeRawBufferPointer(rebasing: buffer[offset...])
            return try body(subBuffer)
        }
    }
}
