// Binary.Parse.Error.swift
// swift-binary-primitives
//
// Error type for whole-buffer parsing.

public import Index_Primitives

extension Binary.Parse {
    /// Error indicating parsing did not consume entire input.
    public enum Error: Swift.Error, Sendable, Equatable {
        /// Parsing succeeded but bytes remain.
        ///
        /// - Parameter remaining: The number of unconsumed bytes.
        case end(remaining: Index<UInt8>.Count)
    }
}
