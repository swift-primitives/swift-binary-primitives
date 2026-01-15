// MARK: - Binary.Contiguous Unsafe Access

extension Binary.Contiguous where Self: ~Copyable {
    /// Unsafe escape hatch for closure-based byte access.
    ///
    /// Prefer `bytes` for all new code.
    ///
    /// Usage:
    /// ```swift
    /// unsafe data.withBytes { ptr in ... }
    /// unsafe data.withBytes(in: 0..<16) { ptr in ... }
    /// ```
    @inlinable
    public var withBytes: Binary.WithBytes {
        @_lifetime(borrow self)
        borrowing get {
            var ptr: UnsafePointer<UInt8>!
            var cnt: Int = 0
            let span = bytes
            unsafe span.withUnsafeBufferPointer { buffer in
                unsafe ptr = buffer.baseAddress
                cnt = buffer.count
            }
            return unsafe Binary.WithBytes(pointer: ptr, count: cnt)
        }
    }
}

// MARK: - Binary.Mutable Unsafe Access

extension Binary.Mutable where Self: ~Copyable {
    /// Unsafe escape hatch for closure-based byte access.
    ///
    /// Prefer `mutableBytes` for all new code.
    ///
    /// Usage:
    /// ```swift
    /// unsafe buffer.withBytes { ptr in ... }              // read-only
    /// unsafe buffer.withBytes.mutable { ptr in ... }      // mutable
    /// unsafe buffer.withBytes.mutable(in: 0..<16) { ... } // mutable subrange
    /// ```
    @inlinable
    public var withBytes: Binary.WithMutableBytes {
        @_lifetime(&self)
        mutating get {
            var ptr: UnsafeMutablePointer<UInt8>!
            var cnt: Int = 0
            // Use read-only access to get the pointer, then cast to mutable
            // This is safe because we have exclusive mutable access to self
            unsafe mutableBytes.withUnsafeBufferPointer { buffer in
                unsafe ptr = UnsafeMutablePointer(mutating: buffer.baseAddress!)
                cnt = buffer.count
            }
            return unsafe Binary.WithMutableBytes(pointer: ptr, count: cnt)
        }
    }
}
