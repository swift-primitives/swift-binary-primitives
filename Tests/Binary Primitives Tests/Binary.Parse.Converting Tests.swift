// Binary.Parse.Converting Tests.swift
// swift-binary-primitives
//
// Tests for type-converting integer parsing.

import Testing
@testable import Binary_Primitives

// MARK: - Basic Conversion Tests

@Suite("Binary.Parse.Converting Basic")
struct ConvertingBasicTests {

    @Test("parse UInt32 as Int big-endian")
    func parseUInt32AsIntBigEndian() throws {
        let parser = Binary.Parse.Converting<UInt32, Int>(endianness: .big)
        var input: ArraySlice<UInt8> = [0x00, 0x01, 0x00, 0x00]
        let value = try parser.parse(&input)
        #expect(value == 65536)
    }

    @Test("parse UInt32 as Int little-endian")
    func parseUInt32AsIntLittleEndian() throws {
        let parser = Binary.Parse.Converting<UInt32, Int>(endianness: .little)
        var input: ArraySlice<UInt8> = [0x00, 0x00, 0x01, 0x00]
        let value = try parser.parse(&input)
        #expect(value == 65536)
    }

    @Test("parse UInt8 as Int")
    func parseUInt8AsInt() throws {
        let parser = Binary.Parse.Converting<UInt8, Int>(endianness: .big)
        var input: ArraySlice<UInt8> = [0xFF]
        let value = try parser.parse(&input)
        #expect(value == 255)
    }

    @Test("parse UInt16 as UInt64")
    func parseUInt16AsUInt64() throws {
        let parser = Binary.Parse.Converting<UInt16, UInt64>(endianness: .big)
        var input: ArraySlice<UInt8> = [0xAB, 0xCD]
        let value = try parser.parse(&input)
        #expect(value == 0xABCD)
    }

    @Test("parse Int16 as Int32")
    func parseInt16AsInt32() throws {
        let parser = Binary.Parse.Converting<Int16, Int32>(endianness: .big)
        var input: ArraySlice<UInt8> = [0xFF, 0xFE]  // -2 as Int16
        let value = try parser.parse(&input)
        #expect(value == -2)
    }
}

// MARK: - Overflow Tests

@Suite("Binary.Parse.Converting Overflow")
struct ConvertingOverflowTests {

    @Test("throws on UInt32 to UInt8 overflow")
    func uint32ToUint8Overflow() {
        let parser = Binary.Parse.Converting<UInt32, UInt8>(endianness: .big)
        var input: ArraySlice<UInt8> = [0x00, 0x00, 0x01, 0x00]  // 256

        #expect(throws: Binary.Parse.Converting<UInt32, UInt8>.Error.self) {
            try parser.parse(&input)
        }
    }

    @Test("throws on UInt16 to Int8 overflow")
    func uint16ToInt8Overflow() {
        let parser = Binary.Parse.Converting<UInt16, Int8>(endianness: .big)
        var input: ArraySlice<UInt8> = [0x00, 0x80]  // 128, too large for Int8

        #expect(throws: Binary.Parse.Converting<UInt16, Int8>.Error.self) {
            try parser.parse(&input)
        }
    }

    @Test("succeeds at UInt8 to Int8 boundary")
    func uint8ToInt8Boundary() throws {
        let parser = Binary.Parse.Converting<UInt8, Int8>(endianness: .big)

        // 127 fits in Int8
        var input127: ArraySlice<UInt8> = [0x7F]
        #expect(try parser.parse(&input127) == 127)

        // 128 does not fit in Int8
        var input128: ArraySlice<UInt8> = [0x80]
        #expect(throws: Binary.Parse.Converting<UInt8, Int8>.Error.self) {
            try parser.parse(&input128)
        }
    }

    @Test("Int32 negative to UInt32 fails")
    func int32NegativeToUint32Fails() {
        let parser = Binary.Parse.Converting<Int32, UInt32>(endianness: .big)
        var input: ArraySlice<UInt8> = [0xFF, 0xFF, 0xFF, 0xFE]  // -2 as Int32

        #expect(throws: Binary.Parse.Converting<Int32, UInt32>.Error.self) {
            try parser.parse(&input)
        }
    }

    @Test("UInt64 max to Int64 fails")
    func uint64MaxToInt64Fails() {
        let parser = Binary.Parse.Converting<UInt64, Int64>(endianness: .big)
        var input: ArraySlice<UInt8> = [0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF]

        #expect(throws: Binary.Parse.Converting<UInt64, Int64>.Error.self) {
            try parser.parse(&input)
        }
    }
}

// MARK: - End of Input Tests

@Suite("Binary.Parse.Converting EndOfInput")
struct ConvertingEndOfInputTests {

    @Test("throws on insufficient bytes")
    func throwsOnInsufficientBytes() {
        let parser = Binary.Parse.Converting<UInt32, Int>(endianness: .big)
        var input: ArraySlice<UInt8> = [0x00, 0x01]  // Only 2 bytes

        #expect(throws: Binary.Parse.Converting<UInt32, Int>.Error.self) {
            try parser.parse(&input)
        }
    }

    @Test("throws on empty input")
    func throwsOnEmptyInput() {
        let parser = Binary.Parse.Converting<UInt16, Int>(endianness: .big)
        var input: ArraySlice<UInt8> = []

        #expect(throws: Binary.Parse.Converting<UInt16, Int>.Error.self) {
            try parser.parse(&input)
        }
    }
}

// MARK: - Consumption Tests

@Suite("Binary.Parse.Converting Consumption")
struct ConvertingConsumptionTests {

    @Test("consumes source type bytes")
    func consumesSourceTypeBytes() throws {
        let parser = Binary.Parse.Converting<UInt16, Int>(endianness: .big)
        var input: ArraySlice<UInt8> = [0x12, 0x34, 0x56, 0x78]
        _ = try parser.parse(&input)
        #expect(input == [0x56, 0x78])
    }

    @Test("sequential converting parsers")
    func sequentialConverting() throws {
        let parser16to32 = Binary.Parse.Converting<UInt16, UInt32>(endianness: .big)
        let parser8to64 = Binary.Parse.Converting<UInt8, UInt64>(endianness: .big)

        var input: ArraySlice<UInt8> = [0x12, 0x34, 0x56]

        let v1 = try parser16to32.parse(&input)
        let v2 = try parser8to64.parse(&input)

        #expect(v1 == 0x1234)
        #expect(v2 == 0x56)
        #expect(input.isEmpty)
    }
}

// MARK: - Error Type Tests

@Suite("Binary.Parse.Converting.Error")
struct ConvertingErrorTests {

    @Test("error is Sendable")
    func errorIsSendable() async {
        let error: Binary.Parse.Converting<UInt32, UInt8>.Error = .overflow(source: 256)
        let task = Task { error }
        let received = await task.value
        if case .overflow(let source) = received {
            #expect(source == 256)
        } else {
            Issue.record("Expected overflow error")
        }
    }

    @Test("error description for overflow")
    func errorDescriptionOverflow() {
        let error: Binary.Parse.Converting<UInt32, UInt8>.Error = .overflow(source: 1000)
        let description = error.description
        #expect(description.contains("1000"))
        #expect(description.contains("UInt8"))
    }

    @Test("error description for end of input")
    func errorDescriptionEndOfInput() {
        let error: Binary.Parse.Converting<UInt32, Int>.Error = .endOfInput(expected: "4 bytes for UInt32")
        let description = error.description
        #expect(description.contains("4 bytes"))
    }
}

// MARK: - Practical Use Cases

@Suite("Binary.Parse.Converting Practical")
struct ConvertingPracticalTests {

    @Test("read file size as UInt32, use as Int")
    func readFileSizePattern() throws {
        // Common pattern: file format stores size as UInt32, but Swift APIs use Int
        let parser = Binary.Parse.Converting<UInt32, Int>(endianness: .little)
        var input: ArraySlice<UInt8> = [0x00, 0x10, 0x00, 0x00]  // 4096
        let size = try parser.parse(&input)
        #expect(size == 4096)
    }

    @Test("read timestamp as UInt32, convert to Int64")
    func readTimestampPattern() throws {
        // Unix timestamp stored as 32-bit, need 64-bit for future dates
        let parser = Binary.Parse.Converting<UInt32, Int64>(endianness: .big)
        var input: ArraySlice<UInt8> = [0x65, 0x8F, 0x34, 0x00]
        let timestamp = try parser.parse(&input)
        #expect(timestamp == 0x658F3400)
    }
}
