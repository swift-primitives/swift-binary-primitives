// RangeReplaceableCollection+Bytes Tests.swift

import Binary_Primitives_Test_Support
import Testing

@testable import Binary_Primitives

// MARK: - Test Suites

/// Tests for RangeReplaceableCollection byte operations - uses parallel namespace pattern
/// since these are protocol extensions.
@Suite
struct `RangeReplaceableCollection+Bytes Tests` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}
    @Suite(.serialized) struct Performance {}
}

// MARK: - Unit Tests

extension `RangeReplaceableCollection+Bytes Tests`.Unit {

    // MARK: - UTF-8 Append

    @Test
    func `append UTF-8 string to buffer`() {
        var buffer: [Byte] = []
        buffer.append(utf8: "Hello")
        #expect(buffer == [72, 101, 108, 108, 111])
    }

    @Test
    func `append UTF-8 string static method`() {
        var buffer: [Byte] = []
        [Byte].append(utf8: "World", to: &buffer)
        #expect(buffer == [87, 111, 114, 108, 100])
    }

    @Test
    func `append UTF-8 to existing content`() {
        var buffer: [Byte] = [72, 105]  // "Hi"
        buffer.append(utf8: " there")
        #expect(String(buffer) == "Hi there")
    }

    @Test
    func `append empty UTF-8 string`() {
        var buffer: [Byte] = [1, 2, 3]
        buffer.append(utf8: "")
        #expect(buffer == [1, 2, 3])
    }

    @Test
    func `append UTF-8 unicode characters`() {
        var buffer: [Byte] = []
        buffer.append(utf8: "Hello")
        #expect(String(buffer) == "Hello")
    }

    // MARK: - Single Byte Append

    @Test
    func `append single byte to buffer`() {
        var buffer: [Byte] = []
        [Byte].append(0x41, to: &buffer)
        #expect(buffer == [0x41])
    }

    @Test
    func `append single byte instance method`() {
        var buffer: [Byte] = []
        buffer.append(0x42)
        #expect(buffer == [0x42])
    }

    @Test
    func `append multiple single bytes`() {
        var buffer: [Byte] = []
        buffer.append(0x01)
        buffer.append(0x02)
        buffer.append(0x03)
        #expect(buffer == [0x01, 0x02, 0x03])
    }

    // MARK: - ContiguousArray Support

    @Test
    func `append UTF-8 to ContiguousArray`() {
        var buffer: ContiguousArray<Byte> = []
        buffer.append(utf8: "Test")
        let expected: [Byte] = [84, 101, 115, 116]
        #expect([Byte](buffer) == expected)
    }

    @Test
    func `append byte to ContiguousArray`() {
        var buffer: ContiguousArray<Byte> = []
        buffer.append(0xFF)
        let expected: [Byte] = [0xFF]
        #expect([Byte](buffer) == expected)
    }
}
