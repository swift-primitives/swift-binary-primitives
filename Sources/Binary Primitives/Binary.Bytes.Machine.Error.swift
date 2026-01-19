// Binary.Bytes.Machine.Error.swift
// Error types for machine execution

extension Binary.Bytes.Machine {
    /// Errors that can occur during machine execution.
    public enum Fault: Swift.Error, Sendable, Equatable {
        /// Not enough bytes in input.
        case insufficientBytes(need: Int, have: Int)

        /// Expected a specific byte but found different or end.
        case unexpectedByte(expected: UInt8, found: UInt8?)

        /// Expected a specific byte sequence but found mismatch.
        case unexpectedBytes(expected: [UInt8], found: [UInt8])

        /// Expected end of input but bytes remain.
        case expectedEnd(remaining: Int)

        /// Byte did not satisfy predicate.
        case predicateFailed(byte: UInt8)

        /// Recursion depth exceeded.
        case depthExceeded(limit: Int)

        /// LEB128 decode overflow.
        case leb128Overflow

        /// No alternatives matched in oneOf.
        case noAlternativesMatched
    }
}
