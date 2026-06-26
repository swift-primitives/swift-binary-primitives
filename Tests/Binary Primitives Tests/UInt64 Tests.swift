// UInt64 Tests.swift

import Binary_Primitives_Standard_Library_Integration
import Binary_Primitives_Test_Support
import Testing

@testable import Binary_Primitives

// MARK: - Test Suites

/// Tests for UInt64 byte encoding - uses parallel namespace pattern
/// since UInt64 is a stdlib type.
@Suite
struct `UInt64 - Byte encoding Tests` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}
    @Suite(.serialized) struct Performance {}
}

// MARK: - Unit Tests

extension `UInt64 - Byte encoding Tests`.Unit {

    @Test
    func `encode to bytes little-endian`() {
        let value: UInt64 = 0x1234_5678_9ABC_DEF0
        let bytes = value.bytes(endianness: .little)
        #expect(bytes == [0xF0, 0xDE, 0xBC, 0x9A, 0x78, 0x56, 0x34, 0x12])
    }

    @Test
    func `encode to bytes big-endian`() {
        let value: UInt64 = 0x1234_5678_9ABC_DEF0
        let bytes = value.bytes(endianness: .big)
        #expect(bytes == [0x12, 0x34, 0x56, 0x78, 0x9A, 0xBC, 0xDE, 0xF0])
    }

    @Test
    func `encode zero`() {
        let value: UInt64 = 0
        #expect(value.bytes(endianness: .little) == [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])
        #expect(value.bytes(endianness: .big) == [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])
    }

    @Test
    func `encode max value`() {
        let value: UInt64 = .max  // 0xFFFF_FFFF_FFFF_FFFF
        #expect(value.bytes(endianness: .little) == [0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF])
        #expect(value.bytes(endianness: .big) == [0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF])
    }

    @Test
    func `encode-decode isomorphism little-endian`() {
        // encode ∘ decode ≡ id
        let original: UInt64 = 0x1234_5678_9ABC_DEF0
        let bytes = original.bytes(endianness: .little)
        let recovered = UInt64(bytes: bytes, endianness: .little)
        #expect(recovered == original)
    }

    @Test
    func `encode-decode isomorphism big-endian`() {
        // encode ∘ decode ≡ id
        let original: UInt64 = 0xABCD_EF01_2345_6789
        let bytes = original.bytes(endianness: .big)
        let recovered = UInt64(bytes: bytes, endianness: .big)
        #expect(recovered == original)
    }

    @Test
    func `decode-encode isomorphism`() {
        // decode ∘ encode ≡ id
        let originalBytes: [Byte] = [0x12, 0x34, 0x56, 0x78, 0x9A, 0xBC, 0xDE, 0xF0]
        let value = UInt64(bytes: originalBytes, endianness: .little)
        let recoveredBytes = value?.bytes(endianness: .little)
        #expect(recoveredBytes == originalBytes)
    }

    @Test
    func `round-trip multiple values`() {
        let values: [UInt64] = [0, 1, 0xFF, 0x1_0000_0000, 0x1234_5678_9ABC_DEF0, .max]

        for original in values {
            let bytesLE = original.bytes(endianness: .little)
            let recoveredLE = UInt64(bytes: bytesLE, endianness: .little)
            #expect(recoveredLE == original)

            let bytesBE = original.bytes(endianness: .big)
            let recoveredBE = UInt64(bytes: bytesBE, endianness: .big)
            #expect(recoveredBE == original)
        }
    }

    @Test
    func `byte count matches memory layout`() {
        let value: UInt64 = 0x1234_5678_9ABC_DEF0
        let bytes = value.bytes(endianness: .little)
        #expect(bytes.count == MemoryLayout<UInt64>.size)
        #expect(bytes.count == 8)
    }
}
