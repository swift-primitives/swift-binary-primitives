//
//  Int8+Parser.swift
//  swift-binary-primitives
//
//  ParserPrinter for Int8 binary serialization.
//  Parsing logic delegated to Machine IR for single source of truth.
//

extension Int8 {
    /// A parser that reads a single byte as an `Int8`.
    ///
    /// Although endianness is irrelevant for single-byte values, the parameter
    /// is accepted for API consistency with multi-byte integer parsers.
    ///
    /// ## Implementation
    ///
    /// Parsing is delegated to `Binary.Bytes.Machine` for canonical byte-level operations.
    /// Printing uses direct byte insertion.
    ///
    /// ## Example
    ///
    /// ```swift
    /// var input: ArraySlice<UInt8> = [0xFF, 0x00]
    /// let parser = Int8.Parser(endianness: .big)
    /// let value = try parser.parse(&input)
    /// // value == -1, input == [0x00]
    /// ```
    public struct Parser: Parsing.ParserPrinter, Sendable {
        public typealias Input = ArraySlice<UInt8>
        public typealias Output = Int8
        public typealias Failure = Parsing.EndOfInput.Error

        public let endianness: Binary.Endianness

        public init(endianness: Binary.Endianness) {
            self.endianness = endianness
        }

        @inlinable
        public func parse(_ input: inout Input) throws(Failure) -> Int8 {
            do {
                return try Binary.Bytes.Machine.i8Parser().parse(&input)
            } catch {
                throw error.asEndOfInputError(for: "Int8")
            }
        }

        @inlinable
        public func print(_ output: Int8, into input: inout Input) {
            input.insert(UInt8(bitPattern: output), at: input.startIndex)
        }
    }
}
