// InlineArray+Binary Tests.swift
// swift-binary-primitives
//
// Tests for InlineArray binary parsing.

import Testing
@testable import Binary_Primitives

// MARK: - Basic Parsing Tests

@Suite("InlineArray Parsing Basic")
struct InlineArrayBasicTests {

    @Test("parse InlineArray of UInt8 big-endian")
    func parseUInt8Array() throws {
        var input: ArraySlice<UInt8> = [0x01, 0x02, 0x03, 0x04]
        let array = try InlineArray<4, UInt8>(parsing: &input, endianness: .big)

        #expect(array[0] == 0x01)
        #expect(array[1] == 0x02)
        #expect(array[2] == 0x03)
        #expect(array[3] == 0x04)
        #expect(input.isEmpty)
    }

    @Test("parse InlineArray of UInt16 big-endian")
    func parseUInt16BigEndian() throws {
        var input: ArraySlice<UInt8> = [0x00, 0x01, 0x00, 0x02, 0x00, 0x03]
        let array = try InlineArray<3, UInt16>(parsing: &input, endianness: .big)

        #expect(array[0] == 1)
        #expect(array[1] == 2)
        #expect(array[2] == 3)
        #expect(input.isEmpty)
    }

    @Test("parse InlineArray of UInt16 little-endian")
    func parseUInt16LittleEndian() throws {
        var input: ArraySlice<UInt8> = [0x01, 0x00, 0x02, 0x00, 0x03, 0x00]
        let array = try InlineArray<3, UInt16>(parsing: &input, endianness: .little)

        #expect(array[0] == 1)
        #expect(array[1] == 2)
        #expect(array[2] == 3)
    }

    @Test("parse InlineArray of UInt32 big-endian")
    func parseUInt32BigEndian() throws {
        var input: ArraySlice<UInt8> = [
            0x00, 0x00, 0x00, 0x01,
            0x00, 0x00, 0x00, 0x02
        ]
        let array = try InlineArray<2, UInt32>(parsing: &input, endianness: .big)

        #expect(array[0] == 1)
        #expect(array[1] == 2)
    }

    @Test("parse InlineArray of UInt64")
    func parseUInt64() throws {
        var input: ArraySlice<UInt8> = [
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02
        ]
        let array = try InlineArray<2, UInt64>(parsing: &input, endianness: .big)

        #expect(array[0] == 1)
        #expect(array[1] == 2)
    }
}

// MARK: - Signed Integer Tests

@Suite("InlineArray Parsing Signed")
struct InlineArraySignedTests {

    @Test("parse InlineArray of Int8")
    func parseInt8() throws {
        var input: ArraySlice<UInt8> = [0xFF, 0x00, 0x01]  // -1, 0, 1
        let array = try InlineArray<3, Int8>(parsing: &input, endianness: .big)

        #expect(array[0] == -1)
        #expect(array[1] == 0)
        #expect(array[2] == 1)
    }

    @Test("parse InlineArray of Int16 big-endian")
    func parseInt16BigEndian() throws {
        var input: ArraySlice<UInt8> = [0xFF, 0xFE, 0x00, 0x00, 0x00, 0x01]  // -2, 0, 1
        let array = try InlineArray<3, Int16>(parsing: &input, endianness: .big)

        #expect(array[0] == -2)
        #expect(array[1] == 0)
        #expect(array[2] == 1)
    }

    @Test("parse InlineArray of Int32")
    func parseInt32() throws {
        var input: ArraySlice<UInt8> = [
            0xFF, 0xFF, 0xFF, 0xFF,  // -1
            0x00, 0x00, 0x00, 0x64   // 100
        ]
        let array = try InlineArray<2, Int32>(parsing: &input, endianness: .big)

        #expect(array[0] == -1)
        #expect(array[1] == 100)
    }
}

// MARK: - Error Handling Tests

@Suite("InlineArray Parsing Errors")
struct InlineArrayErrorTests {

    @Test("throws on insufficient bytes for UInt8")
    func throwsInsufficientUInt8() {
        var input: ArraySlice<UInt8> = [0x01, 0x02]  // Only 2 bytes, need 4

        #expect(throws: Parsing.EndOfInput.Error.self) {
            _ = try InlineArray<4, UInt8>(parsing: &input, endianness: .big)
        }
    }

    @Test("throws on insufficient bytes for UInt16")
    func throwsInsufficientUInt16() {
        var input: ArraySlice<UInt8> = [0x00, 0x01, 0x00]  // Only 3 bytes, need 4 for 2 UInt16s

        #expect(throws: Parsing.EndOfInput.Error.self) {
            _ = try InlineArray<2, UInt16>(parsing: &input, endianness: .big)
        }
    }

    @Test("throws on empty input")
    func throwsOnEmpty() {
        var input: ArraySlice<UInt8> = []

        #expect(throws: Parsing.EndOfInput.Error.self) {
            _ = try InlineArray<1, UInt8>(parsing: &input, endianness: .big)
        }
    }

    @Test("partial parse failure leaves input modified")
    func partialParseFailure() {
        var input: ArraySlice<UInt8> = [0x00, 0x01, 0x00]  // 3 bytes, need 4 for 2 UInt16s

        do {
            _ = try InlineArray<2, UInt16>(parsing: &input, endianness: .big)
            Issue.record("Should have thrown")
        } catch {
            // After parsing first UInt16, input should have 1 byte left
            // but we can't parse the second UInt16
        }
    }
}

// MARK: - Consumption Tests

@Suite("InlineArray Parsing Consumption")
struct InlineArrayConsumptionTests {

    @Test("consumes exact bytes needed")
    func consumesExactBytes() throws {
        var input: ArraySlice<UInt8> = [0x01, 0x02, 0x03, 0xAA, 0xBB]
        _ = try InlineArray<3, UInt8>(parsing: &input, endianness: .big)
        #expect(input == [0xAA, 0xBB])
    }

    @Test("UInt16 array consumes 2 bytes per element")
    func uint16Consumption() throws {
        var input: ArraySlice<UInt8> = [0x00, 0x01, 0x00, 0x02, 0xFF]
        _ = try InlineArray<2, UInt16>(parsing: &input, endianness: .big)
        #expect(input == [0xFF])
    }

    @Test("UInt32 array consumes 4 bytes per element")
    func uint32Consumption() throws {
        var input: ArraySlice<UInt8> = [
            0x00, 0x00, 0x00, 0x01,
            0x00, 0x00, 0x00, 0x02,
            0xAA
        ]
        _ = try InlineArray<2, UInt32>(parsing: &input, endianness: .big)
        #expect(input == [0xAA])
    }
}

// MARK: - Parser Type Tests

@Suite("Binary.Parse.Inline")
struct BinaryParseInlineTests {

    @Test("parser parses correctly")
    func parserParses() throws {
        let parser = Binary.Parse.Inline<3, UInt16>(endianness: .big)
        var input: ArraySlice<UInt8> = [0x00, 0x01, 0x00, 0x02, 0x00, 0x03]

        let array = try parser.parse(&input)

        #expect(array[0] == 1)
        #expect(array[1] == 2)
        #expect(array[2] == 3)
    }

    @Test("parser is Sendable")
    func parserIsSendable() async throws {
        let parser = Binary.Parse.Inline<2, UInt32>(endianness: .big)

        let task = Task {
            var input: ArraySlice<UInt8> = [
                0x00, 0x00, 0x00, 0x01,
                0x00, 0x00, 0x00, 0x02
            ]
            return try parser.parse(&input)
        }

        let result = try await task.value
        #expect(result[0] == 1)
        #expect(result[1] == 2)
    }

    @Test("parser with little endian")
    func parserLittleEndian() throws {
        let parser = Binary.Parse.Inline<2, UInt16>(endianness: .little)
        var input: ArraySlice<UInt8> = [0x01, 0x00, 0x02, 0x00]

        let array = try parser.parse(&input)

        #expect(array[0] == 1)
        #expect(array[1] == 2)
    }
}

// MARK: - Practical Use Cases

@Suite("InlineArray Parsing Practical")
struct InlineArrayPracticalTests {

    @Test("parse fixed-size header fields")
    func parseHeaderFields() throws {
        // Simulate a header with magic bytes
        var input: ArraySlice<UInt8> = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A]
        let magic = try InlineArray<4, UInt8>(parsing: &input, endianness: .big)

        #expect(magic[0] == 0x89)
        #expect(magic[1] == 0x50)  // 'P'
        #expect(magic[2] == 0x4E)  // 'N'
        #expect(magic[3] == 0x47)  // 'G'
    }

    @Test("parse coordinates")
    func parseCoordinates() throws {
        // X, Y, Z coordinates as Int32
        var input: ArraySlice<UInt8> = [
            0x00, 0x00, 0x00, 0x0A,  // X = 10
            0x00, 0x00, 0x00, 0x14,  // Y = 20
            0x00, 0x00, 0x00, 0x1E   // Z = 30
        ]
        let coords = try InlineArray<3, Int32>(parsing: &input, endianness: .big)

        #expect(coords[0] == 10)
        #expect(coords[1] == 20)
        #expect(coords[2] == 30)
    }

    @Test("parse color components")
    func parseColorComponents() throws {
        // RGBA as UInt8
        var input: ArraySlice<UInt8> = [0xFF, 0x00, 0x80, 0xFF]
        let rgba = try InlineArray<4, UInt8>(parsing: &input, endianness: .big)

        #expect(rgba[0] == 255)  // R
        #expect(rgba[1] == 0)    // G
        #expect(rgba[2] == 128)  // B
        #expect(rgba[3] == 255)  // A
    }
}
