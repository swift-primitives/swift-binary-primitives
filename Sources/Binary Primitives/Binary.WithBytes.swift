// MARK: - Unsafe Byte Access Types

extension Binary {
    /// Accessor for unsafe closure-based read-only byte access.
    ///
    /// Stores raw pointer and count to avoid ~Escapable storage issues.
    /// Usage:
    /// ```swift
    /// unsafe data.withBytes { ptr in ... }
    /// unsafe data.withBytes(in: 0..<16) { ptr in ... }
    /// ```
    @unsafe
    public struct WithBytes: ~Copyable, ~Escapable {
        @usableFromInline
        let pointer: UnsafePointer<UInt8>
        @usableFromInline
        let count: Int

        @inlinable
        @_lifetime(immortal)
        init(pointer: UnsafePointer<UInt8>, count: Int) {
            unsafe self.pointer = pointer
            unsafe self.count = count
        }

        /// Read-only pointer access.
        @unsafe
        @inlinable
        public borrowing func callAsFunction<R, E: Swift.Error>(
            _ body: (UnsafeRawBufferPointer) throws(E) -> R
        ) throws(E) -> R {
            let buffer = unsafe UnsafeRawBufferPointer(start: pointer, count: count)
            return try unsafe body(buffer)
        }

        /// Read-only pointer access to a subrange.
        @unsafe
        @inlinable
        public borrowing func callAsFunction<R, E: Swift.Error>(
            in range: Range<Int>,
            _ body: (UnsafeRawBufferPointer) throws(E) -> R
        ) throws(E) -> R {
            precondition(range.lowerBound >= 0, "range.lowerBound must be non-negative")
            precondition(unsafe range.upperBound <= count, "range.upperBound exceeds buffer bounds")
            let buffer = unsafe UnsafeRawBufferPointer(start: pointer.advanced(by: range.lowerBound), count: range.count)
            return try unsafe body(buffer)
        }

        /// Read-only pointer access from offset to end.
        @unsafe
        @inlinable
        public borrowing func callAsFunction<R, E: Swift.Error>(
            from offset: Int,
            _ body: (UnsafeRawBufferPointer) throws(E) -> R
        ) throws(E) -> R {
            precondition(offset >= 0, "offset must be non-negative")
            precondition(unsafe offset <= count, "offset exceeds buffer bounds")
            let buffer = unsafe UnsafeRawBufferPointer(start: pointer.advanced(by: offset), count: count - offset)
            return try unsafe body(buffer)
        }
    }

    /// Accessor for unsafe closure-based mutable byte access.
    ///
    /// Stores raw pointer and count to avoid ~Escapable storage issues.
    /// Usage:
    /// ```swift
    /// unsafe buffer.withBytes.mutable { ptr in ... }
    /// unsafe buffer.withBytes.mutable(in: 0..<16) { ptr in ... }
    /// ```
    @unsafe
    public struct WithMutableBytes: ~Copyable, ~Escapable {
        @usableFromInline
        let pointer: UnsafeMutablePointer<UInt8>
        @usableFromInline
        let count: Int

        @inlinable
        @_lifetime(immortal)
        init(pointer: UnsafeMutablePointer<UInt8>, count: Int) {
            unsafe self.pointer = pointer
            unsafe self.count = count
        }

        /// Read-only pointer access.
        @unsafe
        @inlinable
        public borrowing func callAsFunction<R, E: Swift.Error>(
            _ body: (UnsafeRawBufferPointer) throws(E) -> R
        ) throws(E) -> R {
            let buffer = unsafe UnsafeRawBufferPointer(start: pointer, count: count)
            return try unsafe body(buffer)
        }

        /// Read-only pointer access to a subrange.
        @unsafe
        @inlinable
        public borrowing func callAsFunction<R, E: Swift.Error>(
            in range: Range<Int>,
            _ body: (UnsafeRawBufferPointer) throws(E) -> R
        ) throws(E) -> R {
            precondition(range.lowerBound >= 0, "range.lowerBound must be non-negative")
            precondition(unsafe range.upperBound <= count, "range.upperBound exceeds buffer bounds")
            let buffer = unsafe UnsafeRawBufferPointer(start: pointer.advanced(by: range.lowerBound), count: range.count)
            return try unsafe body(buffer)
        }

        /// Mutable pointer access.
        public var mutable: Mutable {
            unsafe Mutable(pointer: pointer, count: count)
        }

        /// Mutable accessor nested type.
        @unsafe
        public struct Mutable: ~Copyable {
            @usableFromInline
            let pointer: UnsafeMutablePointer<UInt8>
            @usableFromInline
            let count: Int

            @inlinable
            init(pointer: UnsafeMutablePointer<UInt8>, count: Int) {
                unsafe self.pointer = pointer
                unsafe self.count = count
            }

            /// Mutable pointer access.
            @unsafe
            @inlinable
            public borrowing func callAsFunction<R, E: Swift.Error>(
                _ body: (UnsafeMutableRawBufferPointer) throws(E) -> R
            ) throws(E) -> R {
                let buffer = unsafe UnsafeMutableRawBufferPointer(start: pointer, count: count)
                return try unsafe body(buffer)
            }

            /// Mutable pointer access to a subrange.
            @unsafe
            @inlinable
            public borrowing func callAsFunction<R, E: Swift.Error>(
                in range: Range<Int>,
                _ body: (UnsafeMutableRawBufferPointer) throws(E) -> R
            ) throws(E) -> R {
                precondition(range.lowerBound >= 0, "range.lowerBound must be non-negative")
                precondition(unsafe range.upperBound <= count, "range.upperBound exceeds buffer bounds")
                let buffer = unsafe UnsafeMutableRawBufferPointer(start: pointer.advanced(by: range.lowerBound), count: range.count)
                return try unsafe body(buffer)
            }

            /// Mutable pointer access from offset to end.
            @unsafe
            @inlinable
            public borrowing func callAsFunction<R, E: Swift.Error>(
                from offset: Int,
                _ body: (UnsafeMutableRawBufferPointer) throws(E) -> R
            ) throws(E) -> R {
                precondition(offset >= 0, "offset must be non-negative")
                precondition(unsafe offset <= count, "offset exceeds buffer bounds")
                let buffer = unsafe UnsafeMutableRawBufferPointer(start: pointer.advanced(by: offset), count: count - offset)
                return try unsafe body(buffer)
            }
        }
    }
}
