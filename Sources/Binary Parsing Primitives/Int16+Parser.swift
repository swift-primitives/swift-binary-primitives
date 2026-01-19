//
//  Int16+Parser.swift
//  swift-binary-primitives
//
//  ParserPrinter for Int16 binary serialization.
//  Parsing logic delegated to Machine IR for single source of truth.
//

extension Int16 {
    /// A parser that reads two bytes as an `Int16`.
    ///
    /// ## Implementation
    ///
    /// Parsing is delegated to `Binary.Bytes.Machine` for canonical byte-level operations.
    /// Printing uses direct byte insertion.
    ///
    /// ## Example
    ///
    /// ```swift
    /// var input: ArraySlice<UInt8> = [0xFF, 0xFE, 0x00][...]
    /// let parser = Int16.Parser(endianness: .big)
    /// let value = try parser.parse(&input)
    /// // value == -2, input == [0x00]
    /// ```
    public struct Parser: Parsing.ParserPrinter, Sendable {
        public typealias Input = ArraySlice<UInt8>
        public typealias Output = Int16
        public typealias Failure = Parsing.EndOfInput.Error

        public let endianness: Binary.Endianness

        public init(endianness: Binary.Endianness) {
            self.endianness = endianness
        }

        @inlinable
        public func parse(_ input: inout Input) throws(Failure) -> Int16 {
            do {
                switch endianness {
                case .little:
                    return try Binary.Bytes.Machine.i16leParser().parse(&input)
                case .big:
                    return try Binary.Bytes.Machine.i16beParser().parse(&input)
                }
            } catch {
                throw error.asEndOfInputError(for: "Int16")
            }
        }

        @inlinable
        public func print(_ output: Int16, into input: inout Input) {
            let bytes = output.bytes(endianness: endianness)
            input.insert(contentsOf: bytes, at: input.startIndex)
        }
    }
}
