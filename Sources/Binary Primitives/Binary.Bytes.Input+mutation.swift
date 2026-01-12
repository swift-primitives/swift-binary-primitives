extension Binary.Bytes.Input {
    /// Removes and returns the first byte.
    ///
    /// - Precondition: The input must not be empty.
    /// - Returns: The first byte.
    @inlinable
    @discardableResult
    public mutating func removeFirst() -> UInt8 {
        precondition(position < bytes.count, "removeFirst() called on empty input")
        defer { position += 1 }
        return bytes[position]
    }

    /// Removes the first `n` bytes.
    ///
    /// - Parameter n: The number of bytes to remove.
    /// - Precondition: `n >= 0` and `n <= count`.
    @inlinable
    public mutating func removeFirst(_ n: Int) {
        precondition(n >= 0, "removeFirst(_:) called with negative count")
        precondition(n <= count, "removeFirst(_:) called with count exceeding remaining bytes")
        position += n
    }
}
