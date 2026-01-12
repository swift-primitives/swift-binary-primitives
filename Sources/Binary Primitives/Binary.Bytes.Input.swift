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
    /// ## Not Sendable
    ///
    /// This type is deliberately NOT Sendable. Borrowed storage cannot safely
    /// cross concurrency boundaries. The cursor is ephemeral and stack-bound.
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
    public struct Input {
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
