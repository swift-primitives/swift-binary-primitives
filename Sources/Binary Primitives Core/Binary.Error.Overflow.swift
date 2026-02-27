// Binary.Error.Overflow.swift
// Overflow error.

extension Binary.Error {
    /// An arithmetic operation would overflow.
    ///
    /// Thrown when index arithmetic (addition or subtraction) would
    /// overflow the scalar type's representable range.
    public struct Overflow: Swift.Error, Sendable, Equatable {
        /// The kind of operation that overflowed.
        public let operation: Operation

        /// The field being computed.
        public let field: Field

        public init(operation: Operation, field: Field) {
            self.operation = operation
            self.field = field
        }
    }
}

// MARK: - Operation

extension Binary.Error.Overflow {
    /// The kind of arithmetic operation.
    public enum Operation: Sendable, Equatable {
        /// Addition overflowed.
        case addition

        /// Subtraction underflowed.
        case subtraction

        /// Conversion from a wider type.
        case conversion
    }
}

// MARK: - Field

extension Binary.Error.Overflow {
    /// The field being computed.
    public enum Field: Sendable, Equatable {
        /// Reader index computation.
        case reader

        /// Writer index computation.
        case writer

        /// Count computation.
        case count
    }
}

// MARK: - CustomStringConvertible

extension Binary.Error.Overflow: CustomStringConvertible {
    public var description: String {
        "\(field) \(operation) overflow"
    }
}

extension Binary.Error.Overflow.Operation: CustomStringConvertible {
    public var description: String {
        switch self {
        case .addition: return "addition"
        case .subtraction: return "subtraction"
        case .conversion: return "conversion"
        }
    }
}

extension Binary.Error.Overflow.Field: CustomStringConvertible {
    public var description: String {
        switch self {
        case .reader: return "readerIndex"
        case .writer: return "writerIndex"
        case .count: return "count"
        }
    }
}
