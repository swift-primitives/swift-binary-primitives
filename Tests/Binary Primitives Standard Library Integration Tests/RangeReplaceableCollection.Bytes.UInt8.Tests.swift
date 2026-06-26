// RangeReplaceableCollection.Bytes.UInt8.Tests.swift
//
// Tests for the stdlib-interop UInt8 forwarders on RangeReplaceableCollection
// byte mutation helpers.

import Binary_Primitives
import Binary_Primitives_Standard_Library_Integration
import Testing

@Suite
struct `RangeReplaceableCollection+Bytes UInt8 forwarder Tests` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}

    // MARK: - UTF-8 Append

    @Test
    func `append UTF-8 string to [UInt8] buffer`() {
        var buffer: [UInt8] = []
        buffer.append(utf8: "Hello")
        #expect(buffer == [72, 101, 108, 108, 111])
    }

    @Test
    func `append UTF-8 string static method on [UInt8]`() {
        var buffer: [UInt8] = []
        [UInt8].append(utf8: "World", to: &buffer)
        #expect(buffer == [87, 111, 114, 108, 100])
    }

    @Test
    func `append UTF-8 to existing [UInt8] content`() {
        var buffer: [UInt8] = [72, 105]  // "Hi"
        buffer.append(utf8: " there")
        #expect(String(decoding: buffer, as: UTF8.self) == "Hi there")
    }

    @Test
    func `append empty UTF-8 to [UInt8] buffer`() {
        var buffer: [UInt8] = [1, 2, 3]
        buffer.append(utf8: "")
        #expect(buffer == [1, 2, 3])
    }

    // MARK: - Single Byte Append

    @Test
    func `append single byte to [UInt8] buffer`() {
        var buffer: [UInt8] = []
        [UInt8].append(0x41, to: &buffer)
        #expect(buffer == [0x41])
    }

    // MARK: - ContiguousArray<UInt8> Support

    @Test
    func `append UTF-8 to ContiguousArray<UInt8>`() {
        var buffer: ContiguousArray<UInt8> = []
        buffer.append(utf8: "Test")
        #expect(Array(buffer) == [84, 101, 115, 116])
    }
}
