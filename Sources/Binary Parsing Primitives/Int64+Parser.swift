//
//  Int64+Parser.swift
//  swift-binary-primitives
//
//  ParserPrinter for Int64 binary serialization.
//  Parsing logic delegated to Machine IR for single source of truth.
//

extension Int64 {
    /// A parser that reads eight bytes as an `Int64`.
    ///
    /// ## Implementation
    ///
    /// Parsing is delegated to `Binary.Bytes.Machine` for canonical byte-level operations.
    /// Printing uses direct byte insertion.
    ///
    /// ## Example
    ///
    /// ```swift
    /// var input: ArraySlice<UInt8> = [0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFE, 0x00][...]
    /// let parser = Int64.Parser(endianness: .big)
    /// let value = try parser.parse(&input)
    /// // value == -2, input == [0x00]
    /// ```
    public struct Parser: Parsing.ParserPrinter, Sendable {
        public typealias Input = ArraySlice<UInt8>
        public typealias Output = Int64
        public typealias Failure = Parsing.EndOfInput.Error

        public let endianness: Binary.Endianness

        public init(endianness: Binary.Endianness) {
            self.endianness = endianness
        }

        @inlinable
        public func parse(_ input: inout Input) throws(Failure) -> Int64 {
            do {
                switch endianness {
                case .little:
                    return try Binary.Bytes.Machine.i64leParser().parse(&input)
                case .big:
                    return try Binary.Bytes.Machine.i64beParser().parse(&input)
                }
            } catch {
                throw error.asEndOfInputError(for: "Int64")
            }
        }

        @inlinable
        public func print(_ output: Int64, into input: inout Input) {
            let bytes = output.bytes(endianness: endianness)
            input.insert(contentsOf: bytes, at: input.startIndex)
        }
    }
}
