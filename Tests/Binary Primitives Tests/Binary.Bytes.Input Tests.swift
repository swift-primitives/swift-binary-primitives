import Testing
@testable import Binary_Primitives
import Parsing_Primitives

@Suite("Binary.Bytes.Input")
struct BinaryBytesInputTests {

    // MARK: - Initialization

    @Suite("Initialization")
    struct InitializationTests {
        @Test("initializes from Array")
        func initializesFromArray() {
            let bytes: [UInt8] = [0x01, 0x02, 0x03]
            let input = Binary.Bytes.Input(bytes)
            #expect(input.count == 3)
            #expect(!input.isEmpty)
        }

        @Test("initializes from ArraySlice")
        func initializesFromArraySlice() {
            let bytes: [UInt8] = [0x01, 0x02, 0x03, 0x04, 0x05]
            let slice = bytes[1..<4]
            let input = Binary.Bytes.Input(slice)
            #expect(input.count == 3)
        }

        @Test("initializes from any Collection of UInt8")
        func initializesFromCollection() {
            let bytes: [UInt8] = [0x41, 0x42, 0x43]
            let input = Binary.Bytes.Input(bytes)
            #expect(input.first == 0x41)
        }

        @Test("initializes empty")
        func initializesEmpty() {
            let input = Binary.Bytes.Input([])
            #expect(input.isEmpty)
            #expect(input.count == 0)
            #expect(input.first == nil)
        }
    }

    // MARK: - Properties

    @Suite("Properties")
    struct PropertiesTests {
        @Test("isEmpty returns true for empty input")
        func isEmptyForEmpty() {
            let input = Binary.Bytes.Input([])
            #expect(input.isEmpty)
        }

        @Test("isEmpty returns false for non-empty input")
        func isEmptyForNonEmpty() {
            let input = Binary.Bytes.Input([0x01])
            #expect(!input.isEmpty)
        }

        @Test("count returns correct value")
        func countIsCorrect() {
            let input = Binary.Bytes.Input([0x01, 0x02, 0x03, 0x04, 0x05])
            #expect(input.count == 5)
        }

        @Test("first returns first byte")
        func firstReturnsFirstByte() {
            let input = Binary.Bytes.Input([0xAB, 0xCD, 0xEF])
            #expect(input.first == 0xAB)
        }

        @Test("first returns nil for empty input")
        func firstReturnsNilForEmpty() {
            let input = Binary.Bytes.Input([])
            #expect(input.first == nil)
        }

        @Test("consumedCount starts at zero")
        func consumedCountStartsAtZero() {
            let input = Binary.Bytes.Input([0x01, 0x02, 0x03])
            #expect(input.consumedCount == 0)
        }
    }

    // MARK: - Mutation

    @Suite("Mutation")
    struct MutationTests {
        @Test("removeFirst removes and returns first byte")
        func removeFirstRemovesAndReturns() {
            var input = Binary.Bytes.Input([0x41, 0x42, 0x43])
            let byte = input.removeFirst()
            #expect(byte == 0x41)
            #expect(input.count == 2)
            #expect(input.first == 0x42)
        }

        @Test("removeFirst updates consumedCount")
        func removeFirstUpdatesConsumedCount() {
            var input = Binary.Bytes.Input([0x01, 0x02, 0x03])
            _ = input.removeFirst()
            #expect(input.consumedCount == 1)
            _ = input.removeFirst()
            #expect(input.consumedCount == 2)
        }

        @Test("removeFirst(n) removes multiple bytes")
        func removeFirstNRemovesMultiple() {
            var input = Binary.Bytes.Input([0x01, 0x02, 0x03, 0x04, 0x05])
            input.removeFirst(3)
            #expect(input.count == 2)
            #expect(input.first == 0x04)
            #expect(input.consumedCount == 3)
        }

        @Test("removeFirst(0) is no-op")
        func removeFirstZeroIsNoOp() {
            var input = Binary.Bytes.Input([0x01, 0x02])
            input.removeFirst(0)
            #expect(input.count == 2)
            #expect(input.consumedCount == 0)
        }

        @Test("consuming all bytes makes input empty")
        func consumingAllMakesEmpty() {
            var input = Binary.Bytes.Input([0x01, 0x02, 0x03])
            input.removeFirst(3)
            #expect(input.isEmpty)
            #expect(input.first == nil)
            #expect(input.consumedCount == 3)
        }
    }

    // MARK: - Subscript

    @Suite("Subscript")
    struct SubscriptTests {
        @Test("subscript accesses byte at offset")
        func subscriptAccessesByteAtOffset() {
            let input = Binary.Bytes.Input([0x10, 0x20, 0x30, 0x40])
            #expect(input[offset: 0] == 0x10)
            #expect(input[offset: 1] == 0x20)
            #expect(input[offset: 2] == 0x30)
            #expect(input[offset: 3] == 0x40)
        }

        @Test("subscript respects consumed bytes")
        func subscriptRespectsConsumed() {
            var input = Binary.Bytes.Input([0x10, 0x20, 0x30, 0x40])
            _ = input.removeFirst()
            #expect(input[offset: 0] == 0x20)
            #expect(input[offset: 1] == 0x30)
        }
    }

    // MARK: - Starts With

    @Suite("starts(with:)")
    struct StartsWithTests {
        @Test("returns true for matching prefix")
        func returnsTrueForMatchingPrefix() {
            let input = Binary.Bytes.Input([0x01, 0x02, 0x03, 0x04])
            #expect(input.starts(with: [0x01, 0x02]))
        }

        @Test("returns false for non-matching prefix")
        func returnsFalseForNonMatchingPrefix() {
            let input = Binary.Bytes.Input([0x01, 0x02, 0x03])
            #expect(!input.starts(with: [0x01, 0x03]))
        }

        @Test("returns true for empty prefix")
        func returnsTrueForEmptyPrefix() {
            let input = Binary.Bytes.Input([0x01, 0x02])
            #expect(input.starts(with: []))
        }

        @Test("returns false when prefix is longer than input")
        func returnsFalseWhenPrefixTooLong() {
            let input = Binary.Bytes.Input([0x01, 0x02])
            #expect(!input.starts(with: [0x01, 0x02, 0x03]))
        }

        @Test("returns true when prefix equals entire input")
        func returnsTrueForExactMatch() {
            let input = Binary.Bytes.Input([0x01, 0x02, 0x03])
            #expect(input.starts(with: [0x01, 0x02, 0x03]))
        }

        @Test("respects consumed bytes")
        func startsWithRespectsConsumed() {
            var input = Binary.Bytes.Input([0x01, 0x02, 0x03])
            _ = input.removeFirst()
            #expect(input.starts(with: [0x02, 0x03]))
            #expect(!input.starts(with: [0x01, 0x02]))
        }
    }

    // MARK: - Sendable

    @Suite("Sendable")
    struct SendableTests {
        @Test("can be sent to concurrent context")
        func canBeSentToConcurrentContext() async {
            let input = Binary.Bytes.Input([0x01, 0x02, 0x03])
            let task = Task {
                input.count
            }
            let count = await task.value
            #expect(count == 3)
        }
    }

    // MARK: - Usage Pattern

    @Suite("Usage Pattern")
    struct UsagePatternTests {
        @Test("consumedCount enables prefix result calculation")
        func consumedCountEnablesPrefixResult() {
            var input = Binary.Bytes.Input([0x31, 0x32, 0x33, 0x41, 0x42])

            // Parse ASCII digits manually
            var value = 0
            while let byte = input.first, byte >= 0x30 && byte <= 0x39 {
                value = value * 10 + Int(byte - 0x30)
                _ = input.removeFirst()
            }

            #expect(value == 123)
            #expect(input.consumedCount == 3)
            #expect(input.count == 2)
        }

        @Test("supports sequential byte consumption")
        func supportsSequentialByteConsumption() {
            var input = Binary.Bytes.Input([0x01, 0x02, 0x03, 0x04])

            let first = input.removeFirst()
            let second = input.removeFirst()
            let third = input.removeFirst()

            #expect(first == 0x01)
            #expect(second == 0x02)
            #expect(third == 0x03)
            #expect(input.consumedCount == 3)
            #expect(input.count == 1)
        }

        @Test("can parse fixed-width integer")
        func canParseFixedWidthInteger() {
            var input = Binary.Bytes.Input([0xDE, 0xAD, 0xBE, 0xEF])

            let b0 = input.removeFirst()
            let b1 = input.removeFirst()
            let b2 = input.removeFirst()
            let b3 = input.removeFirst()

            let value = UInt32(b0) << 24 | UInt32(b1) << 16 | UInt32(b2) << 8 | UInt32(b3)

            #expect(value == 0xDEADBEEF)
            #expect(input.isEmpty)
            #expect(input.consumedCount == 4)
        }
    }

    // MARK: - Parsing.Input Conformance

    @Suite("Parsing.Input Conformance")
    struct ParsingInputConformanceTests {
        @Test("works with Parsing.First.Element")
        func worksWithFirstElement() throws {
            var input = Binary.Bytes.Input([0x41, 0x42, 0x43])
            let parser = Parsing.First.Element<Binary.Bytes.Input>()

            let result = try parser.parse(&input)

            #expect(result == 0x41)
            #expect(input.consumedCount == 1)
            #expect(input.count == 2)
        }

        @Test("supports sequential parsing with combinators")
        func supportsSequentialParsing() throws {
            var input = Binary.Bytes.Input([0x01, 0x02, 0x03, 0x04])
            let parser = Parsing.First.Element<Binary.Bytes.Input>()

            let first = try parser.parse(&input)
            let second = try parser.parse(&input)
            let third = try parser.parse(&input)

            #expect(first == 0x01)
            #expect(second == 0x02)
            #expect(third == 0x03)
            #expect(input.consumedCount == 3)
            #expect(input.count == 1)
        }

        @Test("combinators compose correctly")
        func combinatorsComposeCorrectly() throws {
            var input = Binary.Bytes.Input([0x41, 0x42])
            let parser = Parsing.First.Element<Binary.Bytes.Input>()

            // Parse first byte
            let first = try parser.parse(&input)
            #expect(first == 0x41)

            // Parse second byte
            let second = try parser.parse(&input)
            #expect(second == 0x42)

            // Input is now empty
            #expect(input.isEmpty)
            #expect(input.consumedCount == 2)
        }
    }
}
