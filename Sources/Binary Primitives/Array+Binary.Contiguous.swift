// MARK: - Array Conformances

extension Array: Binary.Contiguous where Element == UInt8 {
    /// The address space for this storage type.
    public typealias Space = Binary.Space

    /// The scalar type for index arithmetic.
    public typealias Scalar = Int

    @inlinable
    public var bytes: Span<UInt8> {
        @_lifetime(borrow self)
        borrowing get {
            self.span
        }
    }
}

extension Array: Binary.Mutable where Element == UInt8 {
    @inlinable
    public var mutableBytes: MutableSpan<UInt8> {
        @_lifetime(&self)
        mutating get {
            self.mutableSpan
        }
    }
}

// MARK: - ContiguousArray Conformances

extension ContiguousArray: Binary.Contiguous where Element == UInt8 {
    /// The address space for this storage type.
    public typealias Space = Binary.Space

    /// The scalar type for index arithmetic.
    public typealias Scalar = Int

    @inlinable
    public var bytes: Span<UInt8> {
        @_lifetime(borrow self)
        borrowing get {
            self.span
        }
    }
}

extension ContiguousArray: Binary.Mutable where Element == UInt8 {
    @inlinable
    public var mutableBytes: MutableSpan<UInt8> {
        @_lifetime(&self)
        mutating get {
            self.mutableSpan
        }
    }
}
