extension Binary {
    /// A type that provides mutable access to its contiguous bytes.
    ///
    /// `Mutable` refines `Contiguous`, so any mutable buffer is also readable.
    /// Conforming types guarantee that bytes are laid out contiguously in memory
    /// and provide safe, lifetime-bounded mutable access via `MutableSpan`.
    ///
    /// ## Type Parameters
    ///
    /// Inherits `Space` and `Scalar` from `Binary.Contiguous`:
    /// - `Space`: A phantom type distinguishing different address spaces.
    /// - `Scalar`: The integer type for index arithmetic (default: `Int`).
    ///
    /// ## Safe-First Design
    ///
    /// - **Normative:** `mutableBytes` is the primary mutable access API. It returns
    ///   a compiler-enforced `MutableSpan<UInt8>` with lifetime safety guarantees.
    /// - **Escape Hatch:** `withMutableBytes` (marked `@unsafe`) provides raw pointer
    ///   access for interop scenarios. Callers must acknowledge with `unsafe`.
    ///
    /// ## Invariants
    ///
    /// - `count >= 0`
    /// - `mutableBytes.count == self.count`
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Safe: use MutableSpan for all algorithms
    /// func zero<T: Binary.Mutable>(_ buffer: inout T) {
    ///     buffer.mutableBytes.update(repeating: 0)
    /// }
    ///
    /// // Unsafe escape hatch: raw pointer for C interop
    /// func legacyZero<T: Binary.Mutable>(_ buffer: inout T) {
    ///     unsafe buffer.withMutableBytes { ptr in
    ///         ptr.initializeMemory(as: UInt8.self, repeating: 0)
    ///     }
    /// }
    /// ```
    public protocol Mutable: Binary.Contiguous, ~Copyable {
        /// Mutable span of the buffer's contiguous bytes.
        ///
        /// This is the **normative** mutable access API. Use it for all algorithms.
        /// The span is lifetime-dependent on `self` with compiler enforcement.
        ///
        /// Conformers must use `@_lifetime(&self)` on the getter.
        ///
        /// ## Lifetime Contract
        ///
        /// - The span is valid ONLY for the duration of the exclusive mutable borrow.
        /// - The span MUST NOT be stored, returned, or allowed to escape.
        /// - No concurrent mutable borrows are permitted.
        /// - The compiler enforces these constraints.
        var mutableBytes: MutableSpan<UInt8> { mutating get }
    }
}

