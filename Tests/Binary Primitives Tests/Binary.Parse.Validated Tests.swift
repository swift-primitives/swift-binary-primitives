// Binary.Parse.Validated Tests.swift
// swift-binary-primitives
//
// Tests for RawRepresentable parsing with validation.

import Testing
@testable import Binary_Primitives

// MARK: - Test Types

private enum Status: UInt8, Sendable {
    case inactive = 0
    case active = 1
    case pending = 2
}

private enum Priority: UInt16, Sendable {
    case low = 0x0001
    case medium = 0x0002
    case high = 0x0003
    case critical = 0xFFFF
}

private enum SignedCode: Int8, Sendable {
    case negative = -1
    case zero = 0
    case positive = 1
}

// MARK: - Basic Parsing Tests

@Suite("Binary.Parse.Validated Basic")
struct ValidatedBasicTests {

    @Test("parse valid enum value")
    func parseValidValue() throws {
        let parser = Binary.Parse.Validated<Status>(endianness: .big)
        var input: ArraySlice<UInt8> = [0x01]
        let status = try parser.parse(&input)
        #expect(status == .active)
    }

    @Test("parse all valid Status values")
    func parseAllStatusValues() throws {
        let parser = Binary.Parse.Validated<Status>(endianness: .big)

        var input0: ArraySlice<UInt8> = [0x00]
        #expect(try parser.parse(&input0) == .inactive)

        var input1: ArraySlice<UInt8> = [0x01]
        #expect(try parser.parse(&input1) == .active)

        var input2: ArraySlice<UInt8> = [0x02]
        #expect(try parser.parse(&input2) == .pending)
    }

    @Test("parse UInt16 backed enum big-endian")
    func parseUInt16BackedBigEndian() throws {
        let parser = Binary.Parse.Validated<Priority>(endianness: .big)

        var inputLow: ArraySlice<UInt8> = [0x00, 0x01]
        #expect(try parser.parse(&inputLow) == .low)

        var inputCritical: ArraySlice<UInt8> = [0xFF, 0xFF]
        #expect(try parser.parse(&inputCritical) == .critical)
    }

    @Test("parse UInt16 backed enum little-endian")
    func parseUInt16BackedLittleEndian() throws {
        let parser = Binary.Parse.Validated<Priority>(endianness: .little)

        var inputLow: ArraySlice<UInt8> = [0x01, 0x00]
        #expect(try parser.parse(&inputLow) == .low)

        var inputMedium: ArraySlice<UInt8> = [0x02, 0x00]
        #expect(try parser.parse(&inputMedium) == .medium)
    }

    @Test("parse signed enum values")
    func parseSignedEnum() throws {
        let parser = Binary.Parse.Validated<SignedCode>(endianness: .big)

        var inputNeg: ArraySlice<UInt8> = [0xFF]  // -1
        #expect(try parser.parse(&inputNeg) == .negative)

        var inputZero: ArraySlice<UInt8> = [0x00]
        #expect(try parser.parse(&inputZero) == .zero)

        var inputPos: ArraySlice<UInt8> = [0x01]
        #expect(try parser.parse(&inputPos) == .positive)
    }
}

// MARK: - Invalid Value Tests

@Suite("Binary.Parse.Validated Invalid")
struct ValidatedInvalidTests {

    @Test("throws on invalid raw value")
    func throwsOnInvalidValue() {
        let parser = Binary.Parse.Validated<Status>(endianness: .big)
        var input: ArraySlice<UInt8> = [0xFF]  // 255 is not a valid Status

        #expect(throws: Binary.Parse.Validated<Status>.Error.self) {
            try parser.parse(&input)
        }
    }

    @Test("invalid error contains raw value")
    func invalidErrorContainsRawValue() {
        let parser = Binary.Parse.Validated<Status>(endianness: .big)
        var input: ArraySlice<UInt8> = [0x42]

        do {
            _ = try parser.parse(&input)
            Issue.record("Should have thrown")
        } catch let error as Binary.Parse.Validated<Status>.Error {
            if case .invalid(let rawValue) = error {
                #expect(rawValue == 0x42)
            } else {
                Issue.record("Expected .invalid case")
            }
        } catch {
            Issue.record("Unexpected error type")
        }
    }

    @Test("throws for value just outside range")
    func throwsForValueJustOutsideRange() {
        let parser = Binary.Parse.Validated<Status>(endianness: .big)
        var input: ArraySlice<UInt8> = [0x03]  // Status only has 0, 1, 2

        #expect(throws: Binary.Parse.Validated<Status>.Error.self) {
            try parser.parse(&input)
        }
    }

    @Test("UInt16 enum with gap in values")
    func enumWithGapInValues() {
        let parser = Binary.Parse.Validated<Priority>(endianness: .big)
        var input: ArraySlice<UInt8> = [0x00, 0x04]  // 4 is not a valid Priority

        #expect(throws: Binary.Parse.Validated<Priority>.Error.self) {
            try parser.parse(&input)
        }
    }
}

// MARK: - End of Input Tests

@Suite("Binary.Parse.Validated EndOfInput")
struct ValidatedEndOfInputTests {

    @Test("throws on insufficient bytes")
    func throwsOnInsufficientBytes() {
        let parser = Binary.Parse.Validated<Priority>(endianness: .big)
        var input: ArraySlice<UInt8> = [0x00]  // Need 2 bytes for UInt16

        #expect(throws: Binary.Parse.Validated<Priority>.Error.self) {
            try parser.parse(&input)
        }
    }

    @Test("throws on empty input")
    func throwsOnEmptyInput() {
        let parser = Binary.Parse.Validated<Status>(endianness: .big)
        var input: ArraySlice<UInt8> = []

        #expect(throws: Binary.Parse.Validated<Status>.Error.self) {
            try parser.parse(&input)
        }
    }
}

// MARK: - Consumption Tests

@Suite("Binary.Parse.Validated Consumption")
struct ValidatedConsumptionTests {

    @Test("consumes correct number of bytes")
    func consumesCorrectBytes() throws {
        let parser = Binary.Parse.Validated<Status>(endianness: .big)
        var input: ArraySlice<UInt8> = [0x01, 0x02, 0x03]
        _ = try parser.parse(&input)
        #expect(input == [0x02, 0x03])
    }

    @Test("UInt16 enum consumes 2 bytes")
    func uint16ConsumesTwo() throws {
        let parser = Binary.Parse.Validated<Priority>(endianness: .big)
        var input: ArraySlice<UInt8> = [0x00, 0x01, 0xAA, 0xBB]
        _ = try parser.parse(&input)
        #expect(input == [0xAA, 0xBB])
    }

    @Test("sequential validated parsing")
    func sequentialParsing() throws {
        let statusParser = Binary.Parse.Validated<Status>(endianness: .big)
        let priorityParser = Binary.Parse.Validated<Priority>(endianness: .big)

        var input: ArraySlice<UInt8> = [0x01, 0x00, 0x03]

        let status = try statusParser.parse(&input)
        let priority = try priorityParser.parse(&input)

        #expect(status == .active)
        #expect(priority == .high)
        #expect(input.isEmpty)
    }
}

// MARK: - Error Type Tests

@Suite("Binary.Parse.Validated.Error")
struct ValidatedErrorTests {

    @Test("error is Sendable")
    func errorIsSendable() async {
        let error: Binary.Parse.Validated<Status>.Error = .invalid(rawValue: 255)
        let task = Task { error }
        let received = await task.value
        if case .invalid(let rawValue) = received {
            #expect(rawValue == 255)
        } else {
            Issue.record("Expected invalid error")
        }
    }

    @Test("error description for invalid value")
    func errorDescriptionInvalid() {
        let error: Binary.Parse.Validated<Status>.Error = .invalid(rawValue: 99)
        let description = error.description
        #expect(description.contains("99"))
        #expect(description.contains("Status"))
    }

    @Test("error description for end of input")
    func errorDescriptionEndOfInput() {
        let error: Binary.Parse.Validated<Status>.Error = .endOfInput(expected: "1 bytes for UInt8")
        let description = error.description
        #expect(description.contains("1 bytes"))
    }

    @Test("error is Equatable")
    func errorIsEquatable() {
        let error1: Binary.Parse.Validated<Status>.Error = .invalid(rawValue: 5)
        let error2: Binary.Parse.Validated<Status>.Error = .invalid(rawValue: 5)
        let error3: Binary.Parse.Validated<Status>.Error = .invalid(rawValue: 6)

        #expect(error1 == error2)
        #expect(error1 != error3)
    }
}

// MARK: - Practical Use Cases

@Suite("Binary.Parse.Validated Practical")
struct ValidatedPracticalTests {

    @Test("parse message type from protocol header")
    func parseMessageType() throws {
        enum MessageType: UInt8, Sendable {
            case request = 0x01
            case response = 0x02
            case error = 0xFF
        }

        let parser = Binary.Parse.Validated<MessageType>(endianness: .big)

        var requestInput: ArraySlice<UInt8> = [0x01]
        #expect(try parser.parse(&requestInput) == .request)

        var errorInput: ArraySlice<UInt8> = [0xFF]
        #expect(try parser.parse(&errorInput) == .error)

        var invalidInput: ArraySlice<UInt8> = [0x03]
        #expect(throws: Binary.Parse.Validated<MessageType>.Error.self) {
            try parser.parse(&invalidInput)
        }
    }

    @Test("parse flags with validation")
    func parseFlags() throws {
        enum Flags: UInt8, Sendable {
            case none = 0b0000
            case read = 0b0001
            case write = 0b0010
            case readWrite = 0b0011
            case execute = 0b0100
        }

        let parser = Binary.Parse.Validated<Flags>(endianness: .big)

        var rwInput: ArraySlice<UInt8> = [0b0011]
        #expect(try parser.parse(&rwInput) == .readWrite)

        // 0b0101 is not a defined flag combination
        var invalidInput: ArraySlice<UInt8> = [0b0101]
        #expect(throws: Binary.Parse.Validated<Flags>.Error.self) {
            try parser.parse(&invalidInput)
        }
    }
}
