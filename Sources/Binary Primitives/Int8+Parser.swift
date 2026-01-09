//
//  Int8+Parser.swift
//  swift-standards
//
//  ParserPrinter for Int8 binary serialization.
//

extension Int8 {
    /// A parser that reads a single byte as an `Int8`.
    ///
    /// Although endianness is irrelevant for single-byte values, the parameter
    /// is accepted for API consistency with multi-byte integer parsers.
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
            guard let byte = input.first else {
                throw .unexpected(expected: "1 byte for Int8")
            }
            input.removeFirst()
            return Int8(bitPattern: byte)
        }

        @inlinable
        public func print(_ output: Int8, into input: inout Input) {
            input.insert(UInt8(bitPattern: output), at: input.startIndex)
        }
    }
}
