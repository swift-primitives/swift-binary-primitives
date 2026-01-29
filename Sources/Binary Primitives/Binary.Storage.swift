// Binary.Storage.swift
// Minimal storage protocol for Binary cursor/reader types.

extension Binary {
    /// A type that provides read-only access to contiguous bytes with typed positioning.
    ///
    /// This protocol bridges memory-primitives' byte access with binary-primitives'
    /// typed position system. It requires:
    /// - `count`: The number of bytes
    /// - `bytes`: A `Span<UInt8>` for safe byte access
    ///
    /// ## Type Parameters
    ///
    /// - `Space`: A phantom type distinguishing different address spaces.
    /// - `Scalar`: The integer type for index arithmetic (default: `Int`).
    ///
    /// ## Example
    ///
    /// ```swift
    /// var reader = try Binary.Reader(storage: buffer)
    /// // reader uses buffer's Space and Scalar for typed positions
    /// ```
    public protocol Storage: ~Copyable {
        /// The address space for typed positions and offsets.
        associatedtype Space

        /// The scalar type for index arithmetic.
        associatedtype Scalar: FixedWidthInteger & Sendable = Int

        /// The number of bytes in the storage.
        var count: Int { get }

        /// Read-only span of the storage's contiguous bytes.
        var bytes: Span<UInt8> { get }
    }

    /// A type that provides mutable access to contiguous bytes with typed positioning.
    ///
    /// Extends `Binary.Storage` with mutable byte access via `MutableSpan<UInt8>`.
    public protocol MutableStorage: Binary.Storage {
        /// Mutable span of the storage's contiguous bytes.
        var mutableBytes: MutableSpan<UInt8> { mutating get }
    }
}

// MARK: - Array Conformances

extension Array: Binary.Storage where Element == UInt8 {
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

extension Array: Binary.MutableStorage where Element == UInt8 {
    @inlinable
    public var mutableBytes: MutableSpan<UInt8> {
        @_lifetime(&self)
        mutating get {
            self.mutableSpan
        }
    }
}

// MARK: - ContiguousArray Conformances

extension ContiguousArray: Binary.Storage where Element == UInt8 {
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

extension ContiguousArray: Binary.MutableStorage where Element == UInt8 {
    @inlinable
    public var mutableBytes: MutableSpan<UInt8> {
        @_lifetime(&self)
        mutating get {
            self.mutableSpan
        }
    }
}
