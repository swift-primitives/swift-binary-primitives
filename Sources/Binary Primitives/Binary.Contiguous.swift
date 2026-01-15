extension Binary {
    /// A type that provides read-only access to its contiguous bytes.
    ///
    /// Conforming types guarantee that bytes are laid out contiguously in memory
    /// and provide safe, lifetime-bounded access via `Span`.
    ///
    /// ## Type Parameters
    ///
    /// - `Space`: A phantom type distinguishing different address spaces.
    /// - `Scalar`: The integer type for index arithmetic (default: `Int`).
    ///
    /// ## Safe-First Design
    ///
    /// - **Normative:** `bytes` is the primary access API. It returns a
    ///   compiler-enforced `Span<UInt8>` with lifetime safety guarantees.
    /// - **Escape Hatch:** `withBytes` (marked `@unsafe`) provides raw pointer
    ///   access for interop scenarios. Callers must acknowledge with `unsafe`.
    ///
    /// ## Invariants
    ///
    /// - `count >= 0`
    /// - `bytes.count == self.count`
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Safe: use Span for all algorithms
    /// func checksum<T: Binary.Contiguous>(_ data: borrowing T) -> UInt32 {
    ///     data.bytes.reduce(0) { $0 &+ UInt32($1) }
    /// }
    ///
    /// // Unsafe escape hatch: raw pointer for C interop
    /// func legacyChecksum<T: Binary.Contiguous>(_ data: borrowing T) -> UInt32 {
    ///     unsafe data.withBytes { ptr in
    ///         ptr.reduce(0) { $0 &+ UInt32($1) }
    ///     }
    /// }
    /// ```
    public protocol Contiguous: ~Copyable {
        /// The address space for typed positions and offsets.
        ///
        /// Downstream packages can define custom spaces to distinguish
        /// file offsets from buffer positions at compile time.
        associatedtype Space

        /// The scalar type for index arithmetic.
        ///
        /// Must be `FixedWidthInteger & Sendable` to support bitwise alignment
        /// operations and type-safe counts.
        /// Default is `Int` for ergonomics with Swift standard library.
        /// Use `UInt64` for file offsets or `Int64` for signed file positions.
        ///
        /// - Note: Negative values are programmer error; enforce non-negativity
        ///   at the boundaries (e.g., via `Binary.Count`).
        associatedtype Scalar: FixedWidthInteger & Sendable = Int

        /// The number of bytes in the buffer.
        ///
        /// This value is always non-negative and matches `bytes.count`.
        var count: Int { get }

        /// Read-only span of the buffer's contiguous bytes.
        ///
        /// This is the **normative** access API. Use it for all algorithms.
        /// The span is lifetime-dependent on `self` with compiler enforcement.
        ///
        /// Conformers must use `@_lifetime(borrow self)` on the getter.
        ///
        /// ## Lifetime Contract
        ///
        /// - The span is valid ONLY for the duration of the borrow of `self`.
        /// - The span MUST NOT be stored, returned, or allowed to escape.
        /// - The compiler enforces these constraints.
        var bytes: Span<UInt8> { get }
    }
}

// MARK: - Typed Count

extension Binary.Contiguous {
    /// The byte count as a typed value in this storage's space.
    @inlinable
    public var typedCount: Binary.Count<Scalar, Space> {
        Binary.Count(unchecked: Scalar(count))
    }
}
