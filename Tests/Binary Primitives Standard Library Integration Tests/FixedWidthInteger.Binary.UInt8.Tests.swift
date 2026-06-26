// FixedWidthInteger.Binary.UInt8.Tests.swift
//
// Tests for the stdlib-interop UInt8 forwarders on FixedWidthInteger
// byte serialization.

import Binary_Primitives
import Binary_Primitives_Standard_Library_Integration
import Testing

@Suite
struct `FixedWidthInteger+Binary UInt8 forwarder Tests` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}

    // MARK: - static bytes(_:endianness:) -> [UInt8]

    @Test
    func `static bytes(value, endianness:) -> [UInt8] little-endian`() {
        let value: UInt16 = 0x1234
        let bytes: [UInt8] = UInt16.bytes(value, endianness: .little)
        #expect(bytes == [0x34, 0x12])
    }

    @Test
    func `static bytes(value, endianness:) -> [UInt8] big-endian`() {
        let value: UInt32 = 0x1234_5678
        let bytes: [UInt8] = UInt32.bytes(value, endianness: .big)
        #expect(bytes == [0x12, 0x34, 0x56, 0x78])
    }

    // MARK: - instance bytes(endianness:) -> [UInt8]

    @Test
    func `instance bytes(endianness:) -> [UInt8] little-endian`() {
        let value: UInt32 = 0x1234_5678
        let bytes: [UInt8] = value.bytes(endianness: .little)
        #expect(bytes == [0x78, 0x56, 0x34, 0x12])
    }

    @Test
    func `instance bytes(endianness:) -> [UInt8] big-endian`() {
        let value: UInt16 = 0x1234
        let bytes: [UInt8] = value.bytes(endianness: .big)
        #expect(bytes == [0x12, 0x34])
    }

    // MARK: - init?(bytes: [UInt8], endianness:)

    @Test
    func `init?(bytes: [UInt8], endianness:) decodes little-endian`() {
        let bytes: [UInt8] = [0x78, 0x56, 0x34, 0x12]
        let value = UInt32(bytes: bytes, endianness: .little)
        #expect(value == 0x1234_5678)
    }

    @Test
    func `init?(bytes: [UInt8], endianness:) decodes big-endian`() {
        let bytes: [UInt8] = [0x12, 0x34, 0x56, 0x78]
        let value = UInt32(bytes: bytes, endianness: .big)
        #expect(value == 0x1234_5678)
    }

    @Test
    func `init?(bytes: [UInt8], endianness:) returns nil on wrong byte count`() {
        let tooFew: [UInt8] = [0x12, 0x34]
        #expect(UInt32(bytes: tooFew, endianness: .big) == nil)
    }

    // MARK: - Array<FixedWidthInteger>.init?<C: Collection>(bytes:) where C.Element == UInt8

    @Test
    func `Array<UInt16>.init?<C: Collection>(bytes: [UInt8], endianness:)`() {
        let bytes: [UInt8] = [0x01, 0x00, 0x02, 0x00]
        let values = [UInt16](bytes: bytes, endianness: .little)
        #expect(values == [1, 2])
    }

    @Test
    func `Array<UInt16>.init?<C: Collection>(bytes: [UInt8]) returns nil on odd count`() {
        let odd: [UInt8] = [0x01, 0x00, 0x02]
        #expect([UInt16](bytes: odd, endianness: .little) == nil)
    }
}
