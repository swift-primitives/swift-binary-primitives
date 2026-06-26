// Int32 Tests.swift

import Binary_Primitives_Test_Support
import Testing

@testable import Binary_Primitives

// MARK: - Test Suites

/// Tests for Int32 byte encoding - uses parallel namespace pattern
/// since Int32 is a stdlib type.
@Suite
struct `Int32 - Byte encoding Tests` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}
    @Suite(.serialized) struct Performance {}
}

// MARK: - Unit Tests

extension `Int32 - Byte encoding Tests`.Unit {

    @Test
    func `encode to bytes little-endian`() {
        let value: Int32 = 0x1234_5678
        let bytes = value.bytes(endianness: .little)
        #expect(bytes == [0x78, 0x56, 0x34, 0x12])
    }

    @Test
    func `encode to bytes big-endian`() {
        let value: Int32 = 0x1234_5678
        let bytes = value.bytes(endianness: .big)
        #expect(bytes == [0x12, 0x34, 0x56, 0x78])
    }

    @Test
    func `encode zero`() {
        let value: Int32 = 0
        #expect(value.bytes(endianness: .little) == [0x00, 0x00, 0x00, 0x00])
        #expect(value.bytes(endianness: .big) == [0x00, 0x00, 0x00, 0x00])
    }

    @Test
    func `encode positive max value`() {
        let value: Int32 = .max  // 0x7FFF_FFFF
        #expect(value.bytes(endianness: .little) == [0xFF, 0xFF, 0xFF, 0x7F])
        #expect(value.bytes(endianness: .big) == [0x7F, 0xFF, 0xFF, 0xFF])
    }

    @Test
    func `encode negative value`() {
        let value: Int32 = -1
        #expect(value.bytes(endianness: .little) == [0xFF, 0xFF, 0xFF, 0xFF])
        #expect(value.bytes(endianness: .big) == [0xFF, 0xFF, 0xFF, 0xFF])
    }

    @Test
    func `encode negative min value`() {
        let value: Int32 = .min  // -0x8000_0000
        #expect(value.bytes(endianness: .little) == [0x00, 0x00, 0x00, 0x80])
        #expect(value.bytes(endianness: .big) == [0x80, 0x00, 0x00, 0x00])
    }

    @Test
    func `encode-decode isomorphism little-endian`() {
        // encode ∘ decode ≡ id
        let original: Int32 = 0x1234_5678
        let bytes = original.bytes(endianness: .little)
        let recovered = Int32(bytes: bytes, endianness: .little)
        #expect(recovered == original)
    }

    @Test
    func `encode-decode isomorphism big-endian`() {
        // encode ∘ decode ≡ id
        let original: Int32 = -0x1234_5678
        let bytes = original.bytes(endianness: .big)
        let recovered = Int32(bytes: bytes, endianness: .big)
        #expect(recovered == original)
    }

    @Test
    func `round-trip multiple values`() {
        let values: [Int32] = [.min, -1_000_000, -1, 0, 1, 1_000_000, .max]

        for original in values {
            let bytesLE = original.bytes(endianness: .little)
            let recoveredLE = Int32(bytes: bytesLE, endianness: .little)
            #expect(recoveredLE == original)

            let bytesBE = original.bytes(endianness: .big)
            let recoveredBE = Int32(bytes: bytesBE, endianness: .big)
            #expect(recoveredBE == original)
        }
    }

    @Test
    func `byte count matches memory layout`() {
        let value: Int32 = 0x1234_5678
        let bytes = value.bytes(endianness: .little)
        #expect(bytes.count == MemoryLayout<Int32>.size)
        #expect(bytes.count == 4)
    }
}
