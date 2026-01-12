extension Binary.Bytes.Input {
    /// Removes and returns the first byte.
    ///
    /// - Precondition: The input must not be empty.
    /// - Returns: The first byte.
    @inlinable
    @discardableResult
    public mutating func removeFirst() -> UInt8 {
        precondition(position < totalCount, "removeFirst() called on empty input")
        let byte: UInt8
        switch storage {
        case .owned(let bytes): byte = bytes[position]
        case .borrowed(let buffer): byte = buffer[position]
        }
        position += 1
        return byte
    }

    /// Removes the first `n` bytes.
    ///
    /// - Parameter n: The number of bytes to remove.
    /// - Precondition: `n >= 0` and `n <= count`.
    @inlinable
    public mutating func removeFirst(_ n: Int) {
        precondition(n >= 0 && n <= count)
        position += n
    }
}
