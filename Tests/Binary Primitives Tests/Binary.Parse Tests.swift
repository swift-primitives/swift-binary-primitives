import Testing
@testable import Binary_Primitives
import Parsing_Primitives
import Serialization_Primitives

// MARK: - Test Parsers

/// A simple parser that consumes a single byte.
private struct SingleByteParser: Parsing.Parser, Sendable {
    typealias Input = Binary.Bytes.Input
    typealias Output = UInt8
    typealias Failure = Parsing.EndOfInput.Error

    func parse(_ input: inout Input) throws(Failure) -> Output {
        guard !input.isEmpty else { throw .unexpected(expected: "byte") }
        return input.removeFirst()
    }
}

/// A parser that consumes exactly 4 bytes and returns them as UInt32 (big-endian).
private struct UInt32Parser: Parsing.Parser, Sendable {
    typealias Input = Binary.Bytes.Input
    typealias Output = UInt32
    typealias Failure = Parsing.EndOfInput.Error

    func parse(_ input: inout Input) throws(Failure) -> Output {
        guard input.count >= 4 else { throw .unexpected(expected: "4 bytes") }
        let b0 = input.removeFirst()
        let b1 = input.removeFirst()
        let b2 = input.removeFirst()
        let b3 = input.removeFirst()
        return UInt32(b0) << 24 | UInt32(b1) << 16 | UInt32(b2) << 8 | UInt32(b3)
    }
}

/// A parser that parses ASCII digits until a non-digit is encountered.
private struct ASCIIIntParser: Parsing.Parser, Sendable {
    typealias Input = Binary.Bytes.Input
    typealias Output = Int
    typealias Failure = Never

    func parse(_ input: inout Input) throws(Failure) -> Output {
        var value = 0
        while let byte = input.first, byte >= 0x30 && byte <= 0x39 {
            value = value * 10 + Int(byte - 0x30)
            _ = input.removeFirst()
        }
        return value
    }
}

// MARK: - Binary.Parse.Access Tests

@Suite("Binary.Parse.Access")
struct BinaryParseAccessTests {

    @Test("provides whole parsing via accessor")
    func providesWholeViaParse() throws {
        let parser = UInt32Parser()
        let bytes: [UInt8] = [0xDE, 0xAD, 0xBE, 0xEF]

        let result = try parser.parse.whole(bytes)

        #expect(result == 0xDEADBEEF)
    }

    @Test("provides prefix parsing via accessor")
    func providesPrefixViaParse() {
        let parser = ASCIIIntParser()
        let bytes: [UInt8] = [0x31, 0x32, 0x33, 0x41]  // "123A"

        let result = parser.parse.prefix(bytes)

        #expect(result.value == 123)
        #expect(result.count == 3)
    }

    @Test("whole fails when bytes remain")
    func wholeFailsWhenBytesRemain() {
        let parser = SingleByteParser()
        let bytes: [UInt8] = [0x41, 0x42, 0x43]

        #expect(throws: (any Error).self) {
            try parser.parse.whole(bytes)
        }
    }

    @Test("prefix allows bytes to remain")
    func prefixAllowsBytesToRemain() throws {
        let parser = SingleByteParser()
        let bytes: [UInt8] = [0x41, 0x42, 0x43]

        let result = try parser.parse.prefix(bytes)

        #expect(result.value == 0x41)
        #expect(result.count == 1)
    }

    @Test("works with ArraySlice")
    func worksWithArraySlice() throws {
        let parser = UInt32Parser()
        let allBytes: [UInt8] = [0x00, 0xDE, 0xAD, 0xBE, 0xEF, 0xFF]
        let slice: ArraySlice<UInt8> = allBytes[1..<5]

        let result = try parser.parse.whole(slice)

        #expect(result == 0xDEADBEEF)
    }

    @Test("prefix with ArraySlice")
    func prefixWithArraySlice() {
        let parser = ASCIIIntParser()
        let allBytes: [UInt8] = [0x00, 0x37, 0x38, 0x39, 0x41]  // padding + "789A"
        let slice: ArraySlice<UInt8> = allBytes[1...]

        let result = parser.parse.prefix(slice)

        #expect(result.value == 789)
        #expect(result.count == 3)
    }

    @Test("parses prefix and returns consumed count")
    func parsesPrefixWithCount() {
        let parser = ASCIIIntParser()
        let bytes: [UInt8] = [0x31, 0x32, 0x33, 0x41, 0x42]  // "123AB"

        let result = parser.parse.prefix(bytes)

        #expect(result.value == 123)
        #expect(result.count == 3)
    }

    @Test("count enables remainder computation")
    func countEnablesRemainderComputation() {
        let parser = ASCIIIntParser()
        let bytes: [UInt8] = [0x34, 0x35, 0x36, 0x58, 0x59]  // "456XY"

        let result = parser.parse.prefix(bytes)
        let remainder = Array(bytes.dropFirst(result.count))

        #expect(result.value == 456)
        #expect(remainder == [0x58, 0x59])  // "XY"
    }

    @Test("returns zero count when nothing consumed")
    func returnsZeroCountWhenNothingConsumed() {
        let parser = ASCIIIntParser()
        let bytes: [UInt8] = [0x41, 0x42, 0x43]  // "ABC" (no digits)

        let result = parser.parse.prefix(bytes)

        #expect(result.value == 0)
        #expect(result.count == 0)
    }

    @Test("propagates parser failure")
    func propagatesParserFailure() {
        let parser = UInt32Parser()
        let bytes: [UInt8] = [0x01, 0x02]  // Too few bytes

        #expect(throws: Parsing.EndOfInput.Error.self) {
            try parser.parse.prefix(bytes)
        }
    }

    @Test("allows bytes to remain in prefix")
    func allowsBytesToRemainInPrefix() throws {
        let parser = UInt32Parser()
        let bytes: [UInt8] = [0xCA, 0xFE, 0xBA, 0xBE, 0x00, 0x01, 0x02]

        let result = try parser.parse.prefix(bytes)

        #expect(result.value == 0xCAFEBABE)
        #expect(result.count == 4)
    }

    @Test("reports remaining count on whole failure")
    func reportsRemainingCountOnWholeFailure() {
        let parser = UInt32Parser()
        let bytes: [UInt8] = [0x01, 0x02, 0x03, 0x04, 0x05, 0x06]

        do {
            _ = try parser.parse.whole(bytes)
            Issue.record("Should have thrown")
        } catch {
            if case .right(let endError) = error as? Parsing.Either<Parsing.EndOfInput.Error, Binary.Parse.Error> {
                if case .end(let remaining) = endError {
                    #expect(remaining == 2)
                } else {
                    Issue.record("Unexpected error case")
                }
            } else {
                Issue.record("Expected .right error")
            }
        }
    }

    @Test("propagates parser failure on whole")
    func propagatesParserFailureOnWhole() {
        let parser = UInt32Parser()
        let bytes: [UInt8] = [0x01, 0x02]  // Too few bytes

        do {
            _ = try parser.parse.whole(bytes)
            Issue.record("Should have thrown")
        } catch {
            if case .left = error as? Parsing.Either<Parsing.EndOfInput.Error, Binary.Parse.Error> {
                // Expected
            } else {
                Issue.record("Expected .left error")
            }
        }
    }
}

// MARK: - Binary.Parse.Error Tests

@Suite("Binary.Parse.Error")
struct BinaryParseErrorTests {

    @Test("end error contains remaining count")
    func endErrorContainsRemainingCount() {
        let error: Binary.Parse.Error = .end(remaining: 42)

        if case .end(let remaining) = error {
            #expect(remaining == 42)
        } else {
            Issue.record("Expected .end case")
        }
    }

    @Test("error conforms to Swift.Error")
    func conformsToSwiftError() {
        let error: any Swift.Error = Binary.Parse.Error.end(remaining: 5)
        #expect(error is Binary.Parse.Error)
    }

    @Test("error is Sendable")
    func errorIsSendable() async {
        let error: Binary.Parse.Error = .end(remaining: 10)
        let task = Task {
            error
        }
        let received = await task.value
        if case .end(let remaining) = received {
            #expect(remaining == 10)
        }
    }
}

// MARK: - Round-Trip Tests

@Suite("Round-Trip")
struct BinaryParseRoundTripTests {

    @Test("serialize then parse produces original value")
    func serializeThenParseRoundTrip() throws {
        // Serializer
        let serializer: Serialization.Serializing.Buffer<UInt32, UInt8, Void> = .init { value, _, buffer in
            buffer.append(UInt8(truncatingIfNeeded: value >> 24))
            buffer.append(UInt8(truncatingIfNeeded: value >> 16))
            buffer.append(UInt8(truncatingIfNeeded: value >> 8))
            buffer.append(UInt8(truncatingIfNeeded: value))
        }

        // Parser with accessor
        let parser = UInt32Parser()

        let original: UInt32 = 0xCAFEBABE
        let serialized = serializer.returning(original)
        let parsed = try parser.parse.whole(serialized)

        #expect(parsed == original)
    }

    @Test("parse prefix then derive remainder")
    func parsePrefixThenDeriveRemainder() {
        let parser = ASCIIIntParser()
        let bytes: [UInt8] = [0x31, 0x32, 0x33, 0x44, 0x45, 0x46]  // "123DEF"

        let result = parser.parse.prefix(bytes)
        let remainder = Array(bytes.dropFirst(result.count))

        #expect(result.value == 123)
        #expect(remainder == [0x44, 0x45, 0x46])  // "DEF"
    }
}
