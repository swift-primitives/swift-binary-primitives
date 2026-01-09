extension Binary.Contiguous {
    /// Accesses a contiguous subrange of bytes as a `Span`.
    ///
    /// This subscript provides zero-copy access to a subrange of the buffer.
    /// The returned span is lifetime-bound to `self` and must not escape.
    ///
    /// ## Example
    ///
    /// ```swift
    /// func processHeader<T: Binary.Contiguous>(_ data: borrowing T) {
    ///     let header = data[0..<16]
    ///     // header is a Span<UInt8> viewing the first 16 bytes
    /// }
    /// ```
    ///
    /// - Parameter range: The range of bytes to access.
    /// - Returns: A span viewing the specified range.
    ///
    /// - Precondition: `range.lowerBound >= 0`
    /// - Precondition: `range.upperBound <= count`
    @inlinable
    public subscript(range: Range<Int>) -> Span<UInt8> {
        @_lifetime(borrow self)
        borrowing get {
            // Bounds checking is performed by Span.extracting
            return bytes.extracting(range)
        }
    }

    /// Accesses bytes from a given offset to the end as a `Span`.
    ///
    /// - Parameter range: A partial range from a lower bound.
    /// - Returns: A span viewing from the offset to the end.
    ///
    /// - Precondition: `range.lowerBound >= 0`
    /// - Precondition: `range.lowerBound <= count`
    @inlinable
    public subscript(range: PartialRangeFrom<Int>) -> Span<UInt8> {
        @_lifetime(borrow self)
        borrowing get {
            let span = bytes
            return span.extracting(range.lowerBound..<span.count)
        }
    }

    /// Accesses bytes from the beginning up to a given offset as a `Span`.
    ///
    /// - Parameter range: A partial range up to an upper bound.
    /// - Returns: A span viewing from the beginning to the offset.
    ///
    /// - Precondition: `range.upperBound >= 0`
    /// - Precondition: `range.upperBound <= count`
    @inlinable
    public subscript(range: PartialRangeUpTo<Int>) -> Span<UInt8> {
        @_lifetime(borrow self)
        borrowing get {
            return bytes.extracting(0..<range.upperBound)
        }
    }

    /// Accesses bytes from the beginning through a given offset as a `Span`.
    ///
    /// - Parameter range: A partial range through an upper bound (inclusive).
    /// - Returns: A span viewing from the beginning through the offset.
    ///
    /// - Precondition: `range.upperBound >= 0`
    /// - Precondition: `range.upperBound < count`
    @inlinable
    public subscript(range: PartialRangeThrough<Int>) -> Span<UInt8> {
        @_lifetime(borrow self)
        borrowing get {
            return bytes.extracting(0...range.upperBound)
        }
    }
}
