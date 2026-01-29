// RangeReplaceableCollection+Bytes Tests.swift

import Testing

@testable import Binary_Primitives
import Binary_Primitives_Test_Support

// MARK: - Test Suites

/// Tests for RangeReplaceableCollection byte operations - uses parallel namespace pattern
/// since these are protocol extensions.
@Suite("RangeReplaceableCollection+Bytes")
struct RangeReplaceableCollectionBytesTests {
    @Suite struct Unit {}
    @Suite struct EdgeCase {}
    @Suite struct Integration {}
    @Suite(.serialized) struct Performance {}
}

// MARK: - Unit Tests

extension RangeReplaceableCollectionBytesTests.Unit {

    // MARK: - UTF-8 Append

    @Test
    func `append UTF-8 string to buffer`() {
        var buffer: [UInt8] = []
        buffer.append(utf8: "Hello")
        #expect(buffer == [72, 101, 108, 108, 111])
    }

    @Test
    func `append UTF-8 string static method`() {
        var buffer: [UInt8] = []
        [UInt8].append(utf8: "World", to: &buffer)
        #expect(buffer == [87, 111, 114, 108, 100])
    }

    @Test
    func `append UTF-8 to existing content`() {
        var buffer: [UInt8] = [72, 105]  // "Hi"
        buffer.append(utf8: " there")
        #expect(String(decoding: buffer, as: UTF8.self) == "Hi there")
    }

    @Test
    func `append empty UTF-8 string`() {
        var buffer: [UInt8] = [1, 2, 3]
        buffer.append(utf8: "")
        #expect(buffer == [1, 2, 3])
    }

    @Test
    func `append UTF-8 unicode characters`() {
        var buffer: [UInt8] = []
        buffer.append(utf8: "Hello")
        #expect(String(decoding: buffer, as: UTF8.self) == "Hello")
    }

    // MARK: - Single Byte Append

    @Test
    func `append single byte to buffer`() {
        var buffer: [UInt8] = []
        [UInt8].append(0x41, to: &buffer)
        #expect(buffer == [0x41])
    }

    @Test
    func `append single byte instance method`() {
        var buffer: [UInt8] = []
        buffer.append(0x42)
        #expect(buffer == [0x42])
    }

    @Test
    func `append multiple single bytes`() {
        var buffer: [UInt8] = []
        buffer.append(0x01)
        buffer.append(0x02)
        buffer.append(0x03)
        #expect(buffer == [0x01, 0x02, 0x03])
    }

    // MARK: - ContiguousArray Support

    @Test
    func `append UTF-8 to ContiguousArray`() {
        var buffer: ContiguousArray<UInt8> = []
        buffer.append(utf8: "Test")
        #expect(Array(buffer) == [84, 101, 115, 116])
    }

    @Test
    func `append byte to ContiguousArray`() {
        var buffer: ContiguousArray<UInt8> = []
        buffer.append(0xFF)
        #expect(Array(buffer) == [0xFF])
    }
}
