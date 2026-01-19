//
//  UInt8+Parser.swift
//  swift-binary-primitives
//
//  ParserPrinter for UInt8 binary serialization.
//  Parsing logic delegated to Machine IR for single source of truth.
//

extension UInt8 {
    /// A parser that reads a single byte as a `UInt8`.
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
    /// var input: ArraySlice<UInt8> = [0x42, 0x00]
    /// let parser = UInt8.Parser(endianness: .big)
    /// let value = try parser.parse(&input)
    /// // value == 0x42, input == [0x00]
    /// ```
    public struct Parser: Parsing.ParserPrinter, Sendable {
        public typealias Input = ArraySlice<UInt8>
        public typealias Output = UInt8
        public typealias Failure = Parsing.EndOfInput.Error

        public let endianness: Binary.Endianness

        public init(endianness: Binary.Endianness) {
            self.endianness = endianness
        }

        @inlinable
        public func parse(_ input: inout Input) throws(Failure) -> UInt8 {
            do {
                return try Binary.Bytes.Machine.u8Parser().parse(&input)
            } catch {
                throw error.asEndOfInputError(for: "UInt8")
            }
        }

        @inlinable
        public func print(_ output: UInt8, into input: inout Input) {
            input.insert(output, at: input.startIndex)
        }
    }
}
