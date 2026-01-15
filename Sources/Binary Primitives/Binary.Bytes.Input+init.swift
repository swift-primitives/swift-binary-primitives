extension Binary.Bytes.Input {
    /// Creates an input cursor from any byte collection.
    ///
    /// Materializes to an array for owned storage.
    ///
    /// - Parameter bytes: The bytes to parse.
    @inlinable
    public init<Bytes: Collection>(_ bytes: Bytes) where Bytes.Element == UInt8 {
        unsafe self.storage = .owned(Array(bytes))
        self.position = 0
    }

    /// Creates an input cursor from an array (no copy needed).
    ///
    /// - Parameter bytes: The byte array to parse.
    @inlinable
    public init(_ bytes: [UInt8]) {
        unsafe self.storage = .owned(bytes)
        self.position = 0
    }

    /// Creates an input cursor from an array slice.
    ///
    /// - Parameter bytes: The byte slice to parse.
    @inlinable
    public init(_ bytes: ArraySlice<UInt8>) {
        unsafe self.storage = .owned(Array(bytes))
        self.position = 0
    }

    /// Creates an input cursor that borrows external buffer storage.
    ///
    /// - Warning: The cursor MUST NOT escape the closure scope that owns
    ///   the buffer pointer. Use only within `withUnsafeBufferPointer` or
    ///   `withContiguousStorageIfAvailable` closures.
    ///
    /// - Parameter buffer: The buffer to borrow.
    @inlinable
    public init(borrowing buffer: UnsafeBufferPointer<UInt8>) {
        unsafe self.storage = .borrowed(buffer)
        self.position = 0
    }
}
