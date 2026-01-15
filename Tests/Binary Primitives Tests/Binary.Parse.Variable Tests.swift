// Binary.Parse.Variable Tests.swift
// swift-binary-primitives
//
// Tests for variable byte-count integer parsing.

import Testing
@testable import Binary_Primitives

// MARK: - Unsigned Variable Parsing Tests

@Suite("Binary.Parse.Variable Unsigned")
struct VariableUnsignedTests {

    @Test("parse 1 byte as UInt32 big-endian")
    func parse1ByteUInt32BigEndian() throws {
        let parser = Binary.Parse.Variable<UInt32>(count: 1, endianness: .big)
        var input: ArraySlice<UInt8> = [0x42]
        let value = try parser.parse(&input)
        #expect(value == 0x42)
        #expect(input.isEmpty)
    }

    @Test("parse 2 bytes as UInt32 big-endian")
    func parse2BytesUInt32BigEndian() throws {
        let parser = Binary.Parse.Variable<UInt32>(count: 2, endianness: .big)
        var input: ArraySlice<UInt8> = [0x12, 0x34]
        let value = try parser.parse(&input)
        #expect(value == 0x1234)
    }

    @Test("parse 3 bytes as UInt32 big-endian")
    func parse3BytesUInt32BigEndian() throws {
        let parser = Binary.Parse.Variable<UInt32>(count: 3, endianness: .big)
        var input: ArraySlice<UInt8> = [0x12, 0x34, 0x56]
        let value = try parser.parse(&input)
        #expect(value == 0x123456)
    }

    @Test("parse 4 bytes as UInt32 big-endian")
    func parse4BytesUInt32BigEndian() throws {
        let parser = Binary.Parse.Variable<UInt32>(count: 4, endianness: .big)
        var input: ArraySlice<UInt8> = [0x12, 0x34, 0x56, 0x78]
        let value = try parser.parse(&input)
        #expect(value == 0x12345678)
    }

    @Test("parse 1 byte as UInt32 little-endian")
    func parse1ByteUInt32LittleEndian() throws {
        let parser = Binary.Parse.Variable<UInt32>(count: 1, endianness: .little)
        var input: ArraySlice<UInt8> = [0x42]
        let value = try parser.parse(&input)
        #expect(value == 0x42)
    }

    @Test("parse 2 bytes as UInt32 little-endian")
    func parse2BytesUInt32LittleEndian() throws {
        let parser = Binary.Parse.Variable<UInt32>(count: 2, endianness: .little)
        var input: ArraySlice<UInt8> = [0x34, 0x12]
        let value = try parser.parse(&input)
        #expect(value == 0x1234)
    }

    @Test("parse 3 bytes as UInt32 little-endian")
    func parse3BytesUInt32LittleEndian() throws {
        let parser = Binary.Parse.Variable<UInt32>(count: 3, endianness: .little)
        var input: ArraySlice<UInt8> = [0x56, 0x34, 0x12]
        let value = try parser.parse(&input)
        #expect(value == 0x123456)
    }

    @Test("parse high byte values")
    func parseHighByteValues() throws {
        let parser = Binary.Parse.Variable<UInt32>(count: 3, endianness: .big)
        var input: ArraySlice<UInt8> = [0xFF, 0xFF, 0xFF]
        let value = try parser.parse(&input)
        #expect(value == 0xFFFFFF)
    }
}

// MARK: - Signed Variable Parsing Tests

@Suite("Binary.Parse.Variable Signed")
struct VariableSignedTests {

    @Test("parse positive 1 byte as Int32")
    func parsePositive1Byte() throws {
        let parser = Binary.Parse.Variable<Int32>(count: 1, endianness: .big)
        var input: ArraySlice<UInt8> = [0x42]
        let value = try parser.parse(&input)
        #expect(value == 0x42)
    }

    @Test("parse negative 1 byte as Int32 (sign extension)")
    func parseNegative1Byte() throws {
        let parser = Binary.Parse.Variable<Int32>(count: 1, endianness: .big)
        var input: ArraySlice<UInt8> = [0xFF]  // -1 as 8-bit
        let value = try parser.parse(&input)
        #expect(value == -1)
    }

    @Test("parse negative 2 bytes as Int32 (sign extension)")
    func parseNegative2Bytes() throws {
        let parser = Binary.Parse.Variable<Int32>(count: 2, endianness: .big)
        var input: ArraySlice<UInt8> = [0xFF, 0xFE]  // -2 as 16-bit
        let value = try parser.parse(&input)
        #expect(value == -2)
    }

    @Test("parse negative 3 bytes as Int32 big-endian")
    func parseNegative3BytesBigEndian() throws {
        let parser = Binary.Parse.Variable<Int32>(count: 3, endianness: .big)
        var input: ArraySlice<UInt8> = [0xFF, 0x12, 0x34]
        let value = try parser.parse(&input)
        // 0xFF1234 with sign extension = -60876
        #expect(value == -60876)
    }

    @Test("parse negative 3 bytes as Int32 little-endian")
    func parseNegative3BytesLittleEndian() throws {
        let parser = Binary.Parse.Variable<Int32>(count: 3, endianness: .little)
        var input: ArraySlice<UInt8> = [0x34, 0x12, 0xFF]
        let value = try parser.parse(&input)
        // Same value, different byte order
        #expect(value == -60876)
    }

    @Test("boundary between positive and negative")
    func boundaryPositiveNegative() throws {
        let parser = Binary.Parse.Variable<Int32>(count: 1, endianness: .big)

        // 0x7F = 127 (positive, no sign extension)
        var input1: ArraySlice<UInt8> = [0x7F]
        #expect(try parser.parse(&input1) == 127)

        // 0x80 = -128 (negative, sign extended)
        var input2: ArraySlice<UInt8> = [0x80]
        #expect(try parser.parse(&input2) == -128)
    }

    @Test("sign extension preserves value")
    func signExtensionPreservesValue() throws {
        // -1 should be -1 regardless of byte count
        for count in 1...4 {
            let parser = Binary.Parse.Variable<Int32>(count: count, endianness: .big)
            var input = ArraySlice([UInt8](repeating: 0xFF, count: count))
            let value = try parser.parse(&input)
            #expect(value == -1, "count=\(count) should give -1")
        }
    }
}

// MARK: - Error Handling Tests

@Suite("Binary.Parse.Variable Errors")
struct VariableErrorTests {

    @Test("throws on insufficient input")
    func throwsOnInsufficientInput() {
        let parser = Binary.Parse.Variable<UInt32>(count: 3, endianness: .big)
        var input: ArraySlice<UInt8> = [0x12, 0x34]  // Only 2 bytes

        #expect(throws: Parsing.EndOfInput.Error.self) {
            try parser.parse(&input)
        }
    }

    @Test("throws on empty input")
    func throwsOnEmptyInput() {
        let parser = Binary.Parse.Variable<UInt32>(count: 1, endianness: .big)
        var input: ArraySlice<UInt8> = []

        #expect(throws: Parsing.EndOfInput.Error.self) {
            try parser.parse(&input)
        }
    }
}

// MARK: - Consumption Tests

@Suite("Binary.Parse.Variable Consumption")
struct VariableConsumptionTests {

    @Test("consumes exactly count bytes")
    func consumesExactlyCountBytes() throws {
        let parser = Binary.Parse.Variable<UInt32>(count: 2, endianness: .big)
        var input: ArraySlice<UInt8> = [0x12, 0x34, 0x56, 0x78]
        _ = try parser.parse(&input)
        #expect(input == [0x56, 0x78])
    }

    @Test("sequential parsing")
    func sequentialParsing() throws {
        let parser1 = Binary.Parse.Variable<UInt16>(count: 1, endianness: .big)
        let parser2 = Binary.Parse.Variable<UInt32>(count: 2, endianness: .big)
        let parser3 = Binary.Parse.Variable<UInt64>(count: 3, endianness: .big)

        var input: ArraySlice<UInt8> = [0x11, 0x22, 0x33, 0x44, 0x55, 0x66]

        let v1 = try parser1.parse(&input)
        let v2 = try parser2.parse(&input)
        let v3 = try parser3.parse(&input)

        #expect(v1 == 0x11)
        #expect(v2 == 0x2233)
        #expect(v3 == 0x445566)
        #expect(input.isEmpty)
    }
}

// MARK: - Type Width Tests

@Suite("Binary.Parse.Variable Type Widths")
struct VariableTypeWidthTests {

    @Test("UInt8 with count 1")
    func uint8Count1() throws {
        let parser = Binary.Parse.Variable<UInt8>(count: 1, endianness: .big)
        var input: ArraySlice<UInt8> = [0xAB]
        #expect(try parser.parse(&input) == 0xAB)
    }

    @Test("UInt16 with count 1 and 2")
    func uint16Counts() throws {
        let parser1 = Binary.Parse.Variable<UInt16>(count: 1, endianness: .big)
        var input1: ArraySlice<UInt8> = [0xAB]
        #expect(try parser1.parse(&input1) == 0xAB)

        let parser2 = Binary.Parse.Variable<UInt16>(count: 2, endianness: .big)
        var input2: ArraySlice<UInt8> = [0xAB, 0xCD]
        #expect(try parser2.parse(&input2) == 0xABCD)
    }

    @Test("UInt64 with various counts")
    func uint64VariousCounts() throws {
        let parser5 = Binary.Parse.Variable<UInt64>(count: 5, endianness: .big)
        var input5: ArraySlice<UInt8> = [0x01, 0x02, 0x03, 0x04, 0x05]
        #expect(try parser5.parse(&input5) == 0x0102030405)

        let parser8 = Binary.Parse.Variable<UInt64>(count: 8, endianness: .big)
        var input8: ArraySlice<UInt8> = [0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08]
        #expect(try parser8.parse(&input8) == 0x0102030405060708)
    }

    @Test("Int64 sign extension from 5 bytes")
    func int64SignExtension5Bytes() throws {
        let parser = Binary.Parse.Variable<Int64>(count: 5, endianness: .big)
        var input: ArraySlice<UInt8> = [0xFF, 0xFF, 0xFF, 0xFF, 0xFF]
        #expect(try parser.parse(&input) == -1)

        var input2: ArraySlice<UInt8> = [0x80, 0x00, 0x00, 0x00, 0x00]
        #expect(try parser.parse(&input2) < 0)  // Should be negative
    }
}
