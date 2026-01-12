extension Binary.Bytes {
    /// Escapable input cursor for bytes parsing.
    ///
    /// This type provides an escapable cursor over bytes that can be used as
    /// `Parsing.Parser.Input`. It conforms to `Parsing.Input`, enabling use
    /// with all generic parsing combinators.
    ///
    /// ## Design Rationale
    ///
    /// Swift 6.2 does not allow `~Escapable` constraints on protocol associated
    /// types. Since `Span<UInt8>` is non-escapable, parsers cannot declare
    /// `Input == Span<UInt8>` directly. This cursor type bridges that gap:
    ///
    /// - It is **escapable** (can be stored in protocol associated types)
    /// - It uses **Span internally** for zero-copy parsing when available
    /// - It tracks **consumed count** for returning `(value, count)` results
    ///
    /// ## Invariants
    ///
    /// `0 <= position <= bytes.count`
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
    public struct Input: Sendable {
        /// The underlying byte storage (materialized for escapability).
        @usableFromInline
        internal var bytes: [UInt8]

        /// Current position in the buffer.
        @usableFromInline
        internal var position: Int

        /// The initial count at construction (for computing consumed count).
        @usableFromInline
        internal let initialCount: Int
    }
}
