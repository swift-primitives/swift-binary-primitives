//
//  UInt64+Parser.swift
//  swift-binary-primitives
//
//  ParserPrinter for UInt64 binary serialization.
//  Parsing logic delegated to Machine IR for single source of truth.
//

extension UInt64 {
    /// A parser that reads eight bytes as a `UInt64`.
    ///
    /// ## Implementation
    ///
    /// Parsing is delegated to `Binary.Bytes.Machine` for canonical byte-level operations.
    /// Printing uses direct byte insertion.
    ///
    /// ## Example
    ///
    /// ```swift
    /// var input: ArraySlice<UInt8> = [0x12, 0x34, 0x56, 0x78, 0x9A, 0xBC, 0xDE, 0xF0, 0x00][...]
    /// let parser = UInt64.Parser(endianness: .big)
    /// let value = try parser.parse(&input)
    /// // value == 0x123456789ABCDEF0, input == [0x00]
    /// ```
    public struct Parser: Parsing.ParserPrinter, Sendable {
        public typealias Input = ArraySlice<UInt8>
        public typealias Output = UInt64
        public typealias Failure = Parsing.EndOfInput.Error

        public let endianness: Binary.Endianness

        public init(endianness: Binary.Endianness) {
            self.endianness = endianness
        }

        @inlinable
        public func parse(_ input: inout Input) throws(Failure) -> UInt64 {
            do {
                switch endianness {
                case .little:
                    return try Binary.Bytes.Machine.u64leParser().parse(&input)
                case .big:
                    return try Binary.Bytes.Machine.u64beParser().parse(&input)
                }
            } catch {
                throw error.asEndOfInputError(for: "UInt64")
            }
        }

        @inlinable
        public func print(_ output: UInt64, into input: inout Input) {
            let bytes = output.bytes(endianness: endianness)
            input.insert(contentsOf: bytes, at: input.startIndex)
        }
    }
}
