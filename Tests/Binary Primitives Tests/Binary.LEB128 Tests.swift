// Binary.LEB128 Tests.swift
// swift-binary-primitives
//
// Tests for LEB128 serialization and error types.
// Parser tests are in swift-binary-parser-primitives.

import Testing

@testable import Binary_Primitives
import Binary_Primitives_Test_Support

// MARK: - Test Suites

/// Tests for Binary.LEB128 - uses parallel namespace pattern per [TEST-004]
/// since Binary.LEB128 is a namespace enum.
@Suite("Binary.LEB128")
struct BinaryLEB128Tests {
    @Suite struct Unit {}
    @Suite struct EdgeCase {}
    @Suite struct Integration {}
    @Suite(.serialized) struct Performance {}
}

// MARK: - Unit Tests

extension BinaryLEB128Tests.Unit {

    // MARK: - Unsigned Serialization

    @Test
    func `serialize unsigned single byte`() {
        #expect([UInt8](leb128: 0 as UInt32) == [0x00])
        #expect([UInt8](leb128: 1 as UInt32) == [0x01])
        #expect([UInt8](leb128: 127 as UInt32) == [0x7F])
    }

    @Test
    func `serialize unsigned multi-byte`() {
        #expect([UInt8](leb128: 128 as UInt32) == [0x80, 0x01])
        #expect([UInt8](leb128: 624485 as UInt32) == [0xE5, 0x8E, 0x26])
        #expect([UInt8](leb128: 300 as UInt32) == [0xAC, 0x02])
    }

    // MARK: - Signed Serialization

    @Test
    func `serialize signed positive`() {
        #expect([UInt8](leb128: 0 as Int32) == [0x00])
        #expect([UInt8](leb128: 1 as Int32) == [0x01])
        #expect([UInt8](leb128: 63 as Int32) == [0x3F])
    }

    @Test
    func `serialize signed negative`() {
        #expect([UInt8](leb128: -1 as Int32) == [0x7F])
        #expect([UInt8](leb128: -2 as Int32) == [0x7E])
        #expect([UInt8](leb128: -64 as Int32) == [0x40])
        #expect([UInt8](leb128: -128 as Int32) == [0x80, 0x7F])
    }
}

// MARK: - Edge Case Tests

extension BinaryLEB128Tests.EdgeCase {

    @Test
    func `error is Sendable`() async {
        let error: Binary.LEB128.Error = .overflow(bitWidth: 8)
        let task = Task { error }
        let received = await task.value
        #expect(received == .overflow(bitWidth: 8))
    }

    @Test
    func `error is Equatable`() {
        #expect(Binary.LEB128.Error.unterminated == Binary.LEB128.Error.unterminated)
        #expect(Binary.LEB128.Error.overflow(bitWidth: 8) == Binary.LEB128.Error.overflow(bitWidth: 8))
        #expect(Binary.LEB128.Error.overflow(bitWidth: 8) != Binary.LEB128.Error.overflow(bitWidth: 16))
        #expect(Binary.LEB128.Error.unterminated != Binary.LEB128.Error.overflow(bitWidth: 8))
    }
}
