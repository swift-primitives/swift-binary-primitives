extension Binary {
    /// Copies bytes from a source buffer into a destination buffer at the given offset.
    ///
    /// This is the canonical algorithm for copying bytes between `Binary.Contiguous`
    /// and `Binary.Mutable` types. Use this for cross-type copying operations.
    ///
    /// ## Example
    ///
    /// ```swift
    /// var destination = [UInt8](repeating: 0, count: 16)
    /// let source: [UInt8] = [1, 2, 3, 4]
    /// Binary.copy(from: source, into: &destination, at: 4)
    /// // destination is now [0, 0, 0, 0, 1, 2, 3, 4, 0, 0, 0, 0, 0, 0, 0, 0]
    /// ```
    ///
    /// - Parameters:
    ///   - source: The source buffer to copy from.
    ///   - destination: The destination buffer to copy into.
    ///   - offset: The byte offset in the destination where copying begins. Defaults to 0.
    ///
    /// - Precondition: `offset >= 0`
    /// - Precondition: `offset + source.count <= destination.count`
    @inlinable
    public static func copy<
        Source: Binary.Contiguous & ~Copyable,
        Destination: Binary.Mutable & ~Copyable
    >(
        from source: borrowing Source,
        into destination: inout Destination,
        at offset: Int = 0
    ) {
        precondition(offset >= 0, "offset must be non-negative")
        precondition(
            offset + source.count <= destination.count,
            "source exceeds destination bounds"
        )

        // swiftlint:disable:next empty_count
        guard source.count > 0 else { return }

        source.withUnsafeBytes { srcBuffer in
            destination.withUnsafeMutableBytes { dstBuffer in
                guard let srcBase = srcBuffer.baseAddress,
                    let dstBase = dstBuffer.baseAddress
                else { return }
                dstBase.advanced(by: offset)
                    .copyMemory(from: srcBase, byteCount: srcBuffer.count)
            }
        }
    }

    /// Copies bytes from a raw buffer pointer into a destination buffer at the given offset.
    ///
    /// Use this overload when working with raw pointers from system calls or
    /// other low-level APIs.
    ///
    /// - Parameters:
    ///   - source: The raw buffer pointer to copy from.
    ///   - destination: The destination buffer to copy into.
    ///   - offset: The byte offset in the destination where copying begins. Defaults to 0.
    ///
    /// - Precondition: `offset >= 0`
    /// - Precondition: `offset + source.count <= destination.count`
    @inlinable
    public static func copy<Destination: Binary.Mutable & ~Copyable>(
        from source: UnsafeRawBufferPointer,
        into destination: inout Destination,
        at offset: Int = 0
    ) {
        precondition(offset >= 0, "offset must be non-negative")
        precondition(
            offset + source.count <= destination.count,
            "source exceeds destination bounds"
        )

        guard !source.isEmpty else { return }

        destination.withUnsafeMutableBytes { dstBuffer in
            guard let srcBase = source.baseAddress,
                let dstBase = dstBuffer.baseAddress
            else { return }
            dstBase.advanced(by: offset)
                .copyMemory(from: srcBase, byteCount: source.count)
        }
    }

    /// Copies bytes from a source buffer into a raw mutable buffer pointer at the given offset.
    ///
    /// Use this overload when copying into raw pointers for system calls or
    /// other low-level APIs.
    ///
    /// - Parameters:
    ///   - source: The source buffer to copy from.
    ///   - destination: The raw mutable buffer pointer to copy into.
    ///   - offset: The byte offset in the destination where copying begins. Defaults to 0.
    ///
    /// - Precondition: `offset >= 0`
    /// - Precondition: `offset + source.count <= destination.count`
    @inlinable
    public static func copy<Source: Binary.Contiguous & ~Copyable>(
        from source: borrowing Source,
        into destination: UnsafeMutableRawBufferPointer,
        at offset: Int = 0
    ) {
        precondition(offset >= 0, "offset must be non-negative")
        precondition(
            offset + source.count <= destination.count,
            "source exceeds destination bounds"
        )

        // swiftlint:disable:next empty_count
        guard source.count > 0 else { return }

        source.withUnsafeBytes { srcBuffer in
            guard let srcBase = srcBuffer.baseAddress,
                let dstBase = destination.baseAddress
            else { return }
            dstBase.advanced(by: offset)
                .copyMemory(from: srcBase, byteCount: srcBuffer.count)
        }
    }
}
