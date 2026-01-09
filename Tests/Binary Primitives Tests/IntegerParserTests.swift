import Test_Support_Primitives
import Testing

@testable import Binary_Primitives

@Suite
struct IntegerParserTests {

    // MARK: - UInt8.Parser

    @Test
    func `UInt8 parse single byte`() throws {
        var input: ArraySlice<UInt8> = [0x42, 0x00]
        let parser = UInt8.Parser(endianness: .big)
        let value = try parser.parse(&input)

        #expect(value == 0x42)
        #expect(input == [0x00])
    }

    @Test
    func `UInt8 parse fails on empty input`() {
        var input: ArraySlice<UInt8> = []
        let parser = UInt8.Parser(endianness: .big)

        #expect(throws: Parsing.EndOfInput.Error.self) {
            try parser.parse(&input)
        }
    }

    @Test
    func `UInt8 print prepends byte`() {
        var input: ArraySlice<UInt8> = [0x00]
        let parser = UInt8.Parser(endianness: .big)
        parser.print(0x42, into: &input)

        #expect(input == [0x42, 0x00])
    }

    @Test
    func `UInt8 roundtrip`() throws {
        let original: UInt8 = 0xAB
        let parser = UInt8.Parser(endianness: .big)

        var output: ArraySlice<UInt8> = []
        parser.print(original, into: &output)

        let parsed = try parser.parse(&output)
        #expect(parsed == original)
        #expect(output.isEmpty)
    }

    // MARK: - Int8.Parser

    @Test
    func `Int8 parse negative value`() throws {
        var input: ArraySlice<UInt8> = [0xFF]
        let parser = Int8.Parser(endianness: .big)
        let value = try parser.parse(&input)

        #expect(value == -1)
    }

    @Test
    func `Int8 roundtrip negative`() throws {
        let original: Int8 = -42
        let parser = Int8.Parser(endianness: .big)

        var output: ArraySlice<UInt8> = []
        parser.print(original, into: &output)

        let parsed = try parser.parse(&output)
        #expect(parsed == original)
    }

    // MARK: - UInt16.Parser

    @Test
    func `UInt16 parse big endian`() throws {
        var input: ArraySlice<UInt8> = [0x12, 0x34]
        let parser = UInt16.Parser(endianness: .big)
        let value = try parser.parse(&input)

        #expect(value == 0x1234)
    }

    @Test
    func `UInt16 parse little endian`() throws {
        var input: ArraySlice<UInt8> = [0x34, 0x12]
        let parser = UInt16.Parser(endianness: .little)
        let value = try parser.parse(&input)

        #expect(value == 0x1234)
    }

    @Test
    func `UInt16 parse fails on insufficient bytes`() {
        var input: ArraySlice<UInt8> = [0x12]
        let parser = UInt16.Parser(endianness: .big)

        #expect(throws: Parsing.EndOfInput.Error.self) {
            try parser.parse(&input)
        }
    }

    @Test
    func `UInt16 roundtrip big endian`() throws {
        let original: UInt16 = 0xABCD
        let parser = UInt16.Parser(endianness: .big)

        var output: ArraySlice<UInt8> = []
        parser.print(original, into: &output)

        #expect(output == [0xAB, 0xCD])

        let parsed = try parser.parse(&output)
        #expect(parsed == original)
    }

    @Test
    func `UInt16 roundtrip little endian`() throws {
        let original: UInt16 = 0xABCD
        let parser = UInt16.Parser(endianness: .little)

        var output: ArraySlice<UInt8> = []
        parser.print(original, into: &output)

        #expect(output == [0xCD, 0xAB])

        let parsed = try parser.parse(&output)
        #expect(parsed == original)
    }

    // MARK: - Int16.Parser

    @Test
    func `Int16 parse negative big endian`() throws {
        var input: ArraySlice<UInt8> = [0xFF, 0xFE]
        let parser = Int16.Parser(endianness: .big)
        let value = try parser.parse(&input)

        #expect(value == -2)
    }

    @Test
    func `Int16 roundtrip negative`() throws {
        let original: Int16 = -1000
        let parser = Int16.Parser(endianness: .big)

        var output: ArraySlice<UInt8> = []
        parser.print(original, into: &output)

        let parsed = try parser.parse(&output)
        #expect(parsed == original)
    }

    // MARK: - UInt32.Parser

    @Test
    func `UInt32 parse big endian`() throws {
        var input: ArraySlice<UInt8> = [0x12, 0x34, 0x56, 0x78]
        let parser = UInt32.Parser(endianness: .big)
        let value = try parser.parse(&input)

        #expect(value == 0x12345678)
    }

    @Test
    func `UInt32 parse little endian`() throws {
        var input: ArraySlice<UInt8> = [0x78, 0x56, 0x34, 0x12]
        let parser = UInt32.Parser(endianness: .little)
        let value = try parser.parse(&input)

        #expect(value == 0x12345678)
    }

    @Test
    func `UInt32 parse fails on insufficient bytes`() {
        var input: ArraySlice<UInt8> = [0x12, 0x34, 0x56]
        let parser = UInt32.Parser(endianness: .big)

        #expect(throws: Parsing.EndOfInput.Error.self) {
            try parser.parse(&input)
        }
    }

    @Test
    func `UInt32 roundtrip`() throws {
        let original: UInt32 = 0xDEADBEEF
        let parser = UInt32.Parser(endianness: .big)

        var output: ArraySlice<UInt8> = []
        parser.print(original, into: &output)

        let parsed = try parser.parse(&output)
        #expect(parsed == original)
    }

    // MARK: - Int32.Parser

    @Test
    func `Int32 parse negative big endian`() throws {
        var input: ArraySlice<UInt8> = [0xFF, 0xFF, 0xFF, 0xFE]
        let parser = Int32.Parser(endianness: .big)
        let value = try parser.parse(&input)

        #expect(value == -2)
    }

    @Test
    func `Int32 roundtrip negative`() throws {
        let original: Int32 = -100_000
        let parser = Int32.Parser(endianness: .little)

        var output: ArraySlice<UInt8> = []
        parser.print(original, into: &output)

        let parsed = try parser.parse(&output)
        #expect(parsed == original)
    }

    // MARK: - UInt64.Parser

    @Test
    func `UInt64 parse big endian`() throws {
        var input: ArraySlice<UInt8> = [0x12, 0x34, 0x56, 0x78, 0x9A, 0xBC, 0xDE, 0xF0]
        let parser = UInt64.Parser(endianness: .big)
        let value = try parser.parse(&input)

        #expect(value == 0x123456789ABCDEF0)
    }

    @Test
    func `UInt64 parse little endian`() throws {
        var input: ArraySlice<UInt8> = [0xF0, 0xDE, 0xBC, 0x9A, 0x78, 0x56, 0x34, 0x12]
        let parser = UInt64.Parser(endianness: .little)
        let value = try parser.parse(&input)

        #expect(value == 0x123456789ABCDEF0)
    }

    @Test
    func `UInt64 parse fails on insufficient bytes`() {
        var input: ArraySlice<UInt8> = [0x12, 0x34, 0x56, 0x78, 0x9A, 0xBC, 0xDE]
        let parser = UInt64.Parser(endianness: .big)

        #expect(throws: Parsing.EndOfInput.Error.self) {
            try parser.parse(&input)
        }
    }

    @Test
    func `UInt64 roundtrip`() throws {
        let original: UInt64 = 0xCAFEBABEDEADBEEF
        let parser = UInt64.Parser(endianness: .big)

        var output: ArraySlice<UInt8> = []
        parser.print(original, into: &output)

        let parsed = try parser.parse(&output)
        #expect(parsed == original)
    }

    // MARK: - Int64.Parser

    @Test
    func `Int64 parse negative big endian`() throws {
        var input: ArraySlice<UInt8> = [0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFE]
        let parser = Int64.Parser(endianness: .big)
        let value = try parser.parse(&input)

        #expect(value == -2)
    }

    @Test
    func `Int64 roundtrip negative`() throws {
        let original: Int64 = -9_000_000_000
        let parser = Int64.Parser(endianness: .little)

        var output: ArraySlice<UInt8> = []
        parser.print(original, into: &output)

        let parsed = try parser.parse(&output)
        #expect(parsed == original)
    }

    // MARK: - Composition Tests

    @Test
    func `sequential parsing with multiple parsers`() throws {
        var input: ArraySlice<UInt8> = [
            0x12, 0x34,  // UInt16 big endian
            0x56, 0x78, 0x9A, 0xBC,  // UInt32 big endian
        ]

        let uint16Parser = UInt16.Parser(endianness: .big)
        let uint32Parser = UInt32.Parser(endianness: .big)

        let first = try uint16Parser.parse(&input)
        let second = try uint32Parser.parse(&input)

        #expect(first == 0x1234)
        #expect(second == 0x56789ABC)
        #expect(input.isEmpty)
    }

    @Test
    func `print then parse recovers original values`() throws {
        let value1: UInt16 = 0x1234
        let value2: UInt32 = 0xDEADBEEF

        let uint16Parser = UInt16.Parser(endianness: .big)
        let uint32Parser = UInt32.Parser(endianness: .big)

        var buffer: ArraySlice<UInt8> = []

        // Print in reverse order (printers prepend)
        uint32Parser.print(value2, into: &buffer)
        uint16Parser.print(value1, into: &buffer)

        // Parse in forward order
        let parsed1 = try uint16Parser.parse(&buffer)
        let parsed2 = try uint32Parser.parse(&buffer)

        #expect(parsed1 == value1)
        #expect(parsed2 == value2)
    }

    // MARK: - Edge Cases

    @Test
    func `parse zero values`() throws {
        var input16: ArraySlice<UInt8> = [0x00, 0x00]
        var input32: ArraySlice<UInt8> = [0x00, 0x00, 0x00, 0x00]
        var input64: ArraySlice<UInt8> = [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]

        #expect(try UInt16.Parser(endianness: .big).parse(&input16) == 0)
        #expect(try UInt32.Parser(endianness: .big).parse(&input32) == 0)
        #expect(try UInt64.Parser(endianness: .big).parse(&input64) == 0)
    }

    @Test
    func `parse max values`() throws {
        var input16: ArraySlice<UInt8> = [0xFF, 0xFF]
        var input32: ArraySlice<UInt8> = [0xFF, 0xFF, 0xFF, 0xFF]
        var input64: ArraySlice<UInt8> = [0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF]

        #expect(try UInt16.Parser(endianness: .big).parse(&input16) == UInt16.max)
        #expect(try UInt32.Parser(endianness: .big).parse(&input32) == UInt32.max)
        #expect(try UInt64.Parser(endianness: .big).parse(&input64) == UInt64.max)
    }

    @Test
    func `endianness consistency with FixedWidthInteger extensions`() throws {
        // Verify our parsers produce the same results as the existing extensions
        let testValue: UInt32 = 0x12345678

        let bigEndianBytes = testValue.bytes(endianness: .big)
        var bigInput = ArraySlice(bigEndianBytes)
        let parsedBig = try UInt32.Parser(endianness: .big).parse(&bigInput)
        #expect(parsedBig == testValue)

        let littleEndianBytes = testValue.bytes(endianness: .little)
        var littleInput = ArraySlice(littleEndianBytes)
        let parsedLittle = try UInt32.Parser(endianness: .little).parse(&littleInput)
        #expect(parsedLittle == testValue)
    }
}
