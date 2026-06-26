// Array+Bytes Tests.swift

import Binary_Primitives_Test_Support
import Testing

@testable import Binary_Primitives

// MARK: - Test Suites

/// Tests for Array byte operations - uses parallel namespace pattern
/// since Array is a stdlib type.
@Suite
struct `Array+Bytes Tests` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}
    @Suite(.serialized) struct Performance {}
}

// MARK: - Unit Tests

extension `Array+Bytes Tests`.Unit {

    // MARK: - Single Integer Serialization

    @Test
    func `array from integer little endian`() {
        let bytes = [UInt8](UInt16(0x1234), endianness: .little)
        #expect(bytes == [0x34, 0x12])
    }

    @Test
    func `array from integer big endian`() {
        let bytes = [UInt8](UInt16(0x1234), endianness: .big)
        #expect(bytes == [0x12, 0x34])
    }

    @Test
    func `array from integer default endianness is little`() {
        let bytes = [UInt8](UInt16(0x1234))
        #expect(bytes == [0x34, 0x12])
    }

    @Test(arguments: [
        (UInt32(0x1234_5678), Binary.Endianness.little, [0x78, 0x56, 0x34, 0x12] as [UInt8]),
        (UInt32(0x1234_5678), Binary.Endianness.big, [0x12, 0x34, 0x56, 0x78] as [UInt8]),
    ])
    func `array from UInt32 with different endianness`(
        testCase: (UInt32, Binary.Endianness, [UInt8])
    ) {
        let (value, endianness, expected) = testCase
        let bytes = [UInt8](value, endianness: endianness)
        #expect(bytes == expected)
    }

    // MARK: - Collection Serialization

    @Test
    func `array from collection of integers`() {
        let values: [UInt16] = [1, 2, 3]
        let bytes = [UInt8](serializing: values, endianness: .little)
        #expect(bytes.count == 6)
        #expect(bytes == [1, 0, 2, 0, 3, 0])
    }

    @Test
    func `array from empty collection`() {
        let values: [UInt16] = []
        let bytes = [UInt8](serializing: values, endianness: .little)
        #expect(bytes.isEmpty)
    }

    @Test
    func `array from collection big endian`() {
        let values: [UInt16] = [0x1234, 0x5678]
        let bytes = [UInt8](serializing: values, endianness: .big)
        #expect(bytes == [0x12, 0x34, 0x56, 0x78])
    }

    // MARK: - String Conversions

    @Test
    func `array from UTF8 string`() {
        let bytes = [UInt8](utf8: "Hi")
        #expect(bytes == [72, 105])
    }

    @Test
    func `array from UTF8 empty string`() {
        let bytes = [UInt8](utf8: "")
        #expect(bytes.isEmpty)
    }

    @Test
    func `array from UTF8 unicode string`() {
        let bytes = [UInt8](utf8: "Hello")
        #expect(bytes.count > 0)
        #expect(String(decoding: bytes, as: UTF8.self) == "Hello")
    }

    // MARK: - Splitting

    @Test
    func `split by separator`() {
        let data: [UInt8] = [1, 2, 0, 0, 3, 4, 0, 0, 5]
        let parts = data.split(separator: [0, 0])
        #expect(parts.count == 3)
        #expect(parts[0] == [1, 2])
        #expect(parts[1] == [3, 4])
        #expect(parts[2] == [5])
    }

    @Test
    func `split static method`() {
        let data: [UInt8] = [1, 2, 0, 3, 4]
        let parts = [UInt8].split(data, separator: [0])
        #expect(parts.count == 2)
        #expect(parts[0] == [1, 2])
        #expect(parts[1] == [3, 4])
    }

    @Test
    func `split with empty separator returns original array`() {
        let data: [UInt8] = [1, 2, 3]
        let parts = data.split(separator: [])
        #expect(parts.count == 1)
        #expect(parts[0] == data)
    }

    @Test
    func `split when separator not found`() {
        let data: [UInt8] = [1, 2, 3, 4]
        let parts = data.split(separator: [99])
        #expect(parts.count == 1)
        #expect(parts[0] == data)
    }

    // MARK: - Mutation Helpers

    @Test
    func `append UInt16`() {
        var buffer: [UInt8] = []
        buffer.append(UInt16(0x1234), endianness: .big)
        #expect(buffer == [0x12, 0x34])
    }

    @Test
    func `append UInt32`() {
        var buffer: [UInt8] = []
        buffer.append(UInt32(0x1234_5678), endianness: .big)
        #expect(buffer == [0x12, 0x34, 0x56, 0x78])
    }

    @Test
    func `append UInt64`() {
        var buffer: [UInt8] = []
        buffer.append(UInt64(0x0102_0304_0506_0708), endianness: .big)
        #expect(buffer == [0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08])
    }

    @Test
    func `append Int16`() {
        var buffer: [UInt8] = []
        buffer.append(Int16(0x1234), endianness: .big)
        #expect(buffer == [0x12, 0x34])
    }

    @Test
    func `append Int32`() {
        var buffer: [UInt8] = []
        buffer.append(Int32(0x1234_5678), endianness: .big)
        #expect(buffer == [0x12, 0x34, 0x56, 0x78])
    }

    @Test
    func `append Int64`() {
        var buffer: [UInt8] = []
        buffer.append(Int64(0x0102_0304_0506_0708), endianness: .big)
        #expect(buffer == [0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08])
    }

    @Test
    func `append Int`() {
        var buffer: [UInt8] = []
        buffer.append(Int(42), endianness: .little)
        #expect(buffer.count == MemoryLayout<Int>.size)
        #expect(buffer[0] == 42)
    }

    @Test
    func `append UInt`() {
        var buffer: [UInt8] = []
        buffer.append(UInt(42), endianness: .little)
        #expect(buffer.count == MemoryLayout<UInt>.size)
        #expect(buffer[0] == 42)
    }

    @Test
    func `append multiple values`() {
        var buffer: [UInt8] = []
        buffer.append(UInt16(1), endianness: .little)
        buffer.append(UInt16(2), endianness: .little)
        #expect(buffer == [1, 0, 2, 0])
    }
}

// MARK: - Joining Byte Arrays Tests

/// Tests for joining byte arrays - uses parallel namespace pattern
/// since [[UInt8]] is composed of stdlib types.
@Suite
struct `[[UInt8]] - Joining Tests` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}
    @Suite(.serialized) struct Performance {}
}

extension `[[UInt8]] - Joining Tests`.Unit {

    @Test
    func `join with separator`() {
        let parts: [[UInt8]] = [[1, 2], [3, 4], [5]]
        let joined = parts.joined(separator: [0, 0])
        #expect(joined == [1, 2, 0, 0, 3, 4, 0, 0, 5])
    }

    @Test
    func `join without separator`() {
        let parts: [[UInt8]] = [[1, 2], [3, 4], [5]]
        let joined = parts.joined()
        #expect(joined == [1, 2, 3, 4, 5])
    }

    @Test
    func `join empty array`() {
        let parts: [[UInt8]] = []
        let joined = parts.joined(separator: [0])
        #expect(joined.isEmpty)
    }

    @Test
    func `join single element`() {
        let parts: [[UInt8]] = [[1, 2, 3]]
        let joined = parts.joined(separator: [0])
        #expect(joined == [1, 2, 3])
    }

    @Test
    func `join with empty separator`() {
        let parts: [[UInt8]] = [[1], [2], [3]]
        let joined = parts.joined(separator: [])
        #expect(joined == [1, 2, 3])
    }

    @Test
    func `join preserves capacity efficiency`() {
        let parts: [[UInt8]] = [[1, 2], [3, 4], [5, 6]]
        let joined = parts.joined(separator: [0])
        // Should be [1, 2, 0, 3, 4, 0, 5, 6] = 8 bytes
        #expect(joined.count == 8)
    }
}
