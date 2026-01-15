// Binary.LEB128 Tests.swift
// swift-binary-primitives
//
// Tests for LEB128 variable-length integer encoding.

import Testing
@testable import Binary_Primitives

// MARK: - Unsigned LEB128 Tests

@Suite("Binary.LEB128.Unsigned")
struct LEB128UnsignedTests {

    @Test("parse single byte value")
    func parseSingleByte() throws {
        var input: ArraySlice<UInt8> = [0x00]
        let parser = Binary.LEB128.Unsigned<UInt64>()
        #expect(try parser.parse(&input) == 0)

        var input2: ArraySlice<UInt8> = [0x01]
        #expect(try parser.parse(&input2) == 1)

        var input3: ArraySlice<UInt8> = [0x7F]
        #expect(try parser.parse(&input3) == 127)
    }

    @Test("parse multi-byte value")
    func parseMultiByte() throws {
        // 128 = 0x80 0x01
        var input: ArraySlice<UInt8> = [0x80, 0x01]
        let parser = Binary.LEB128.Unsigned<UInt64>()
        #expect(try parser.parse(&input) == 128)

        // 624485 = 0xE5 0x8E 0x26
        var input2: ArraySlice<UInt8> = [0xE5, 0x8E, 0x26]
        #expect(try parser.parse(&input2) == 624485)
    }

    @Test("parse known values")
    func parseKnownValues() throws {
        let parser = Binary.LEB128.Unsigned<UInt64>()

        // 300 = 0xAC 0x02
        var input300: ArraySlice<UInt8> = [0xAC, 0x02]
        #expect(try parser.parse(&input300) == 300)

        // 16384 = 0x80 0x80 0x01
        var input16384: ArraySlice<UInt8> = [0x80, 0x80, 0x01]
        #expect(try parser.parse(&input16384) == 16384)
    }

    @Test("throws on unterminated input")
    func throwsOnUnterminated() {
        var input: ArraySlice<UInt8> = [0x80, 0x80]  // continuation bits set but no terminator
        let parser = Binary.LEB128.Unsigned<UInt64>()

        #expect(throws: Binary.LEB128.Error.self) {
            try parser.parse(&input)
        }
    }

    @Test("throws on empty input")
    func throwsOnEmpty() {
        var input: ArraySlice<UInt8> = []
        let parser = Binary.LEB128.Unsigned<UInt64>()

        #expect(throws: Binary.LEB128.Error.unterminated) {
            try parser.parse(&input)
        }
    }

    @Test("throws on overflow")
    func throwsOnOverflow() {
        // Value too large for UInt8
        var input: ArraySlice<UInt8> = [0x80, 0x02]  // 256, too large for UInt8
        let parser = Binary.LEB128.Unsigned<UInt8>()

        #expect(throws: Binary.LEB128.Error.self) {
            try parser.parse(&input)
        }
    }

    @Test("consumes only necessary bytes")
    func consumesOnlyNecessaryBytes() throws {
        var input: ArraySlice<UInt8> = [0x7F, 0xAA, 0xBB]
        let parser = Binary.LEB128.Unsigned<UInt64>()
        let value = try parser.parse(&input)

        #expect(value == 127)
        #expect(input == [0xAA, 0xBB])
    }

    @Test("works with different integer types")
    func worksWithDifferentTypes() throws {
        var input8: ArraySlice<UInt8> = [0x7F]
        let parser8 = Binary.LEB128.Unsigned<UInt8>()
        #expect(try parser8.parse(&input8) == 127)

        var input16: ArraySlice<UInt8> = [0xFF, 0x7F]
        let parser16 = Binary.LEB128.Unsigned<UInt16>()
        #expect(try parser16.parse(&input16) == 16383)

        var input32: ArraySlice<UInt8> = [0xFF, 0xFF, 0xFF, 0xFF, 0x0F]
        let parser32 = Binary.LEB128.Unsigned<UInt32>()
        #expect(try parser32.parse(&input32) == UInt32.max)
    }
}

// MARK: - Signed LEB128 Tests

@Suite("Binary.LEB128.Signed")
struct LEB128SignedTests {

    @Test("parse positive values")
    func parsePositive() throws {
        let parser = Binary.LEB128.Signed<Int64>()

        var input0: ArraySlice<UInt8> = [0x00]
        #expect(try parser.parse(&input0) == 0)

        var input1: ArraySlice<UInt8> = [0x01]
        #expect(try parser.parse(&input1) == 1)

        var input63: ArraySlice<UInt8> = [0x3F]
        #expect(try parser.parse(&input63) == 63)
    }

    @Test("parse negative values")
    func parseNegative() throws {
        let parser = Binary.LEB128.Signed<Int64>()

        // -1 = 0x7F
        var inputNeg1: ArraySlice<UInt8> = [0x7F]
        #expect(try parser.parse(&inputNeg1) == -1)

        // -2 = 0x7E
        var inputNeg2: ArraySlice<UInt8> = [0x7E]
        #expect(try parser.parse(&inputNeg2) == -2)

        // -64 = 0x40
        var inputNeg64: ArraySlice<UInt8> = [0x40]
        #expect(try parser.parse(&inputNeg64) == -64)
    }

    @Test("parse multi-byte negative")
    func parseMultiByteNegative() throws {
        let parser = Binary.LEB128.Signed<Int64>()

        // -128 = 0x80 0x7F
        var inputNeg128: ArraySlice<UInt8> = [0x80, 0x7F]
        #expect(try parser.parse(&inputNeg128) == -128)

        // -129 = 0xFF 0x7E
        var inputNeg129: ArraySlice<UInt8> = [0xFF, 0x7E]
        #expect(try parser.parse(&inputNeg129) == -129)
    }

    @Test("throws on unterminated input")
    func throwsOnUnterminated() {
        var input: ArraySlice<UInt8> = [0x80, 0x80]
        let parser = Binary.LEB128.Signed<Int64>()

        #expect(throws: Binary.LEB128.Error.unterminated) {
            try parser.parse(&input)
        }
    }

    @Test("works with different signed types")
    func worksWithDifferentTypes() throws {
        var input8: ArraySlice<UInt8> = [0x7F]
        let parser8 = Binary.LEB128.Signed<Int8>()
        #expect(try parser8.parse(&input8) == -1)

        var input16: ArraySlice<UInt8> = [0x80, 0x7F]
        let parser16 = Binary.LEB128.Signed<Int16>()
        #expect(try parser16.parse(&input16) == -128)
    }
}

// MARK: - Serialization Tests

@Suite("Binary.LEB128.Serialize")
struct LEB128SerializeTests {

    @Test("serialize unsigned single byte")
    func serializeUnsignedSingleByte() {
        #expect([UInt8](leb128: 0 as UInt32) == [0x00])
        #expect([UInt8](leb128: 1 as UInt32) == [0x01])
        #expect([UInt8](leb128: 127 as UInt32) == [0x7F])
    }

    @Test("serialize unsigned multi-byte")
    func serializeUnsignedMultiByte() {
        #expect([UInt8](leb128: 128 as UInt32) == [0x80, 0x01])
        #expect([UInt8](leb128: 624485 as UInt32) == [0xE5, 0x8E, 0x26])
        #expect([UInt8](leb128: 300 as UInt32) == [0xAC, 0x02])
    }

    @Test("serialize signed positive")
    func serializeSignedPositive() {
        #expect([UInt8](leb128: 0 as Int32) == [0x00])
        #expect([UInt8](leb128: 1 as Int32) == [0x01])
        #expect([UInt8](leb128: 63 as Int32) == [0x3F])
    }

    @Test("serialize signed negative")
    func serializeSignedNegative() {
        #expect([UInt8](leb128: -1 as Int32) == [0x7F])
        #expect([UInt8](leb128: -2 as Int32) == [0x7E])
        #expect([UInt8](leb128: -64 as Int32) == [0x40])
        #expect([UInt8](leb128: -128 as Int32) == [0x80, 0x7F])
    }

    @Test("unsigned round-trip")
    func unsignedRoundTrip() throws {
        let values: [UInt64] = [0, 1, 127, 128, 255, 256, 16383, 16384, 624485, UInt64.max >> 1]

        for original in values {
            let bytes = [UInt8](leb128: original)
            var input = ArraySlice(bytes)
            let parser = Binary.LEB128.Unsigned<UInt64>()
            let parsed = try parser.parse(&input)
            #expect(parsed == original, "Round-trip failed for \(original)")
        }
    }

    @Test("signed round-trip")
    func signedRoundTrip() throws {
        let values: [Int64] = [0, 1, -1, 63, -64, 64, -65, 127, -128, 128, -129, 8191, -8192]

        for original in values {
            let bytes = [UInt8](leb128: original)
            var input = ArraySlice(bytes)
            let parser = Binary.LEB128.Signed<Int64>()
            let parsed = try parser.parse(&input)
            #expect(parsed == original, "Round-trip failed for \(original)")
        }
    }
}

// MARK: - Error Tests

@Suite("Binary.LEB128.Error")
struct LEB128ErrorTests {

    @Test("error is Sendable")
    func errorIsSendable() async {
        let error: Binary.LEB128.Error = .overflow(bitWidth: 8)
        let task = Task { error }
        let received = await task.value
        #expect(received == .overflow(bitWidth: 8))
    }

    @Test("error is Equatable")
    func errorIsEquatable() {
        #expect(Binary.LEB128.Error.unterminated == Binary.LEB128.Error.unterminated)
        #expect(Binary.LEB128.Error.overflow(bitWidth: 8) == Binary.LEB128.Error.overflow(bitWidth: 8))
        #expect(Binary.LEB128.Error.overflow(bitWidth: 8) != Binary.LEB128.Error.overflow(bitWidth: 16))
        #expect(Binary.LEB128.Error.unterminated != Binary.LEB128.Error.overflow(bitWidth: 8))
    }
}
