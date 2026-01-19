//
//  UInt16+Parser.swift
//  swift-binary-primitives
//
//  ParserPrinter for UInt16 binary serialization.
//  Parsing logic delegated to Machine IR for single source of truth.
//

extension UInt16 {
    /// A parser that reads two bytes as a `UInt16`.
    ///
    /// ## Implementation
    ///
    /// Parsing is delegated to `Binary.Bytes.Machine` for canonical byte-level operations.
    /// Printing uses direct byte insertion.
    ///
    /// ## Example
    ///
    /// ```swift
    /// var input: ArraySlice<UInt8> = [0x12, 0x34, 0x00][...]
    /// let parser = UInt16.Parser(endianness: .big)
    /// let value = try parser.parse(&input)
    /// // value == 0x1234, input == [0x00]
    /// ```
    public struct Parser: Parsing.ParserPrinter, Sendable {
        public typealias Input = ArraySlice<UInt8>
        public typealias Output = UInt16
        public typealias Failure = Parsing.EndOfInput.Error

        public let endianness: Binary.Endianness

        public init(endianness: Binary.Endianness) {
            self.endianness = endianness
        }

        @inlinable
        public func parse(_ input: inout Input) throws(Failure) -> UInt16 {
            do {
                switch endianness {
                case .little:
                    return try Binary.Bytes.Machine.u16leParser().parse(&input)
                case .big:
                    return try Binary.Bytes.Machine.u16beParser().parse(&input)
                }
            } catch {
                throw error.asEndOfInputError(for: "UInt16")
            }
        }

        @inlinable
        public func print(_ output: UInt16, into input: inout Input) {
            let bytes = output.bytes(endianness: endianness)
            input.insert(contentsOf: bytes, at: input.startIndex)
        }
    }
}
