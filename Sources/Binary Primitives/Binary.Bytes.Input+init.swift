extension Binary.Bytes.Input {
    /// Creates an input cursor from any byte collection.
    ///
    /// Uses `withContiguousStorageIfAvailable` for contiguous collections,
    /// otherwise materializes to an array.
    ///
    /// - Parameter bytes: The bytes to parse.
    @inlinable
    public init<Bytes: Collection>(_ bytes: Bytes) where Bytes.Element == UInt8 {
        // Materialize to array for escapability
        // This is the slow path; the fast path uses Span within bridge implementations
        let array = Array(bytes)
        self.bytes = array
        self.position = 0
        self.initialCount = array.count
    }

    /// Creates an input cursor from an array (no copy needed).
    ///
    /// - Parameter bytes: The byte array to parse.
    @inlinable
    public init(_ bytes: [UInt8]) {
        self.bytes = bytes
        self.position = 0
        self.initialCount = bytes.count
    }

    /// Creates an input cursor from an array slice.
    ///
    /// - Parameter bytes: The byte slice to parse.
    @inlinable
    public init(_ bytes: ArraySlice<UInt8>) {
        self.bytes = Array(bytes)
        self.position = 0
        self.initialCount = bytes.count
    }
}
