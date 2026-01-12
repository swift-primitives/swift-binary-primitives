extension Binary.Bytes.Input {
    /// Whether there are no more bytes to parse.
    @inlinable
    public var isEmpty: Bool {
        position >= bytes.count
    }

    /// The number of bytes remaining to parse.
    @inlinable
    public var count: Int {
        bytes.count - position
    }

    /// The first byte, or `nil` if empty.
    @inlinable
    public var first: UInt8? {
        guard position < bytes.count else { return nil }
        return bytes[position]
    }

    /// The number of bytes consumed since construction.
    ///
    /// This enables returning `(value, count)` from prefix parsing
    /// without baking a remainder type into the API.
    @inlinable
    public var consumedCount: Int {
        position
    }
}
