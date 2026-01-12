extension Binary.Bytes {
    /// Escapable input cursor for bytes parsing.
    ///
    /// This type provides an escapable cursor over bytes that can be used as
    /// `Parsing.Parser.Input`. Supports both owned and borrowed storage.
    ///
    /// ## Borrowed Storage Safety
    ///
    /// When initialized with `init(borrowing:)`, the cursor borrows external storage.
    /// It MUST NOT escape the closure scope that owns the buffer pointer.
    ///
    /// ## Invariants
    ///
    /// - `0 <= position <= totalCount`
    /// - `count == totalCount - position`
    /// - `consumedCount == position`
    ///
    /// ## Sendable
    ///
    /// This type conforms to `Sendable` to satisfy parsing combinator constraints.
    /// - **Owned inputs** are fully Sendable (backed by `[UInt8]`).
    /// - **Borrowed inputs** are logically non-sendable and MUST remain within the
    ///   borrowing closure scope. The `Sendable` conformance exists to satisfy
    ///   generic combinator requirements; it does NOT relax lifetime rules for
    ///   borrowed storage.
    ///
    /// ## Example
    ///
    /// ```swift
    /// struct MyParser: Parsing.Parser {
    ///     typealias Input = Binary.Bytes.Input
    ///     typealias Output = UInt8
    ///     typealias Failure = Parsing.Match.Error
    ///
    ///     func parse(_ input: inout Input) throws(Failure) -> UInt8 {
    ///         guard let byte = input.first else {
    ///             throw .unexpectedEnd
    ///         }
    ///         input.removeFirst()
    ///         return byte
    ///     }
    /// }
    /// ```
    public struct Input: @unchecked Sendable {
        @usableFromInline
        internal enum Storage {
            case owned([UInt8])
            case borrowed(UnsafeBufferPointer<UInt8>)
        }

        @usableFromInline
        internal var storage: Storage

        @usableFromInline
        internal var position: Int
    }
}
