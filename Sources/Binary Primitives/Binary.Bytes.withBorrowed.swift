// Binary.Bytes.withBorrowed.swift
// Typed-throws trampoline for borrowed contiguous storage.

extension Binary.Bytes {
    /// Execute body with borrowed buffer, preserving typed throws.
    ///
    /// This is the core primitive. All other `withBorrowed` overloads delegate here.
    ///
    /// - Parameters:
    ///   - buffer: The buffer to borrow.
    ///   - body: A closure that receives a mutable `Binary.Bytes.Input` cursor.
    /// - Returns: The value returned by `body`.
    /// - Throws: The error thrown by `body`.
    @inlinable
    public static func withBorrowedBuffer<T, E: Swift.Error>(
        _ buffer: UnsafeBufferPointer<UInt8>,
        _ body: (inout Binary.Bytes.Input) throws(E) -> T
    ) throws(E) -> T {
        var input = Binary.Bytes.Input(borrowing: buffer)
        return try body(&input)
    }

    /// Execute body with borrowed storage from byte array.
    ///
    /// Uses `withUnsafeBufferPointer` for zero-allocation fast path.
    ///
    /// - Parameters:
    ///   - bytes: The byte array to borrow.
    ///   - body: A closure that receives a mutable `Binary.Bytes.Input` cursor.
    /// - Returns: The value returned by `body`.
    /// - Throws: The error thrown by `body`.
    @inlinable
    public static func withBorrowed<T, E: Swift.Error>(
        _ bytes: [UInt8],
        _ body: (inout Binary.Bytes.Input) throws(E) -> T
    ) throws(E) -> T {
        var r: Result<T, E>?
        bytes.withUnsafeBufferPointer { buffer in
            var input = Binary.Bytes.Input(borrowing: buffer)
            do throws(E) {
                let value = try body(&input)
                r = .success(value)
            } catch {
                r = .failure(error)
            }
        }
        guard let r else { preconditionFailure("withUnsafeBufferPointer did not execute closure") }
        return try r.get()
    }

    /// Execute body with borrowed storage from byte collection.
    ///
    /// Tries `withContiguousStorageIfAvailable` for zero-allocation fast path,
    /// falls back to materializing an array if contiguous storage unavailable.
    ///
    /// - Parameters:
    ///   - bytes: The byte collection to borrow.
    ///   - body: A closure that receives a mutable `Binary.Bytes.Input` cursor.
    /// - Returns: The value returned by `body`.
    /// - Throws: The error thrown by `body`.
    @inlinable
    public static func withBorrowed<Bytes, T, E: Swift.Error>(
        _ bytes: Bytes,
        _ body: (inout Binary.Bytes.Input) throws(E) -> T
    ) throws(E) -> T where Bytes: Collection, Bytes.Element == UInt8 {
        var r: Result<T, E>?
        _ = bytes.withContiguousStorageIfAvailable { buffer in
            var input = Binary.Bytes.Input(borrowing: buffer)
            do throws(E) {
                let value = try body(&input)
                r = .success(value)
            } catch {
                r = .failure(error)
            }
        }
        if let r {
            return try r.get()
        }
        // Fallback: materialize to array
        return try withBorrowed(Array(bytes), body)
    }

    /// Execute body with borrowed storage from string's UTF-8 view.
    ///
    /// Tries `withContiguousStorageIfAvailable` on UTF-8 view for zero-allocation
    /// fast path, falls back to materializing an array if unavailable.
    ///
    /// - Parameters:
    ///   - string: The string to borrow (UTF-8 encoded).
    ///   - body: A closure that receives a mutable `Binary.Bytes.Input` cursor.
    /// - Returns: The value returned by `body`.
    /// - Throws: The error thrown by `body`.
    @inlinable
    public static func withBorrowed<T, E: Swift.Error>(
        _ string: some StringProtocol,
        _ body: (inout Binary.Bytes.Input) throws(E) -> T
    ) throws(E) -> T {
        var r: Result<T, E>?
        _ = string.utf8.withContiguousStorageIfAvailable { buffer in
            var input = Binary.Bytes.Input(borrowing: buffer)
            do throws(E) {
                let value = try body(&input)
                r = .success(value)
            } catch {
                r = .failure(error)
            }
        }
        if let r {
            return try r.get()
        }
        // Fallback: materialize to array
        return try withBorrowed(Array(string.utf8), body)
    }
}
