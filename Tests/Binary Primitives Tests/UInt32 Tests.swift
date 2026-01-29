// UInt32 Tests.swift

import Testing

@testable import Binary_Primitives
import Binary_Primitives_Test_Support

// MARK: - Test Suites

/// Tests for UInt32 byte encoding - uses parallel namespace pattern
/// since UInt32 is a stdlib type.
@Suite("UInt32 - Byte encoding")
struct UInt32ByteEncodingTests {
    @Suite struct Unit {}
    @Suite struct EdgeCase {}
    @Suite struct Integration {}
    @Suite(.serialized) struct Performance {}
}

// MARK: - Unit Tests

extension UInt32ByteEncodingTests.Unit {

    @Test
    func `encode to bytes little-endian`() {
        let value: UInt32 = 0x1234_5678
        let bytes = value.bytes(endianness: .little)
        #expect(bytes == [0x78, 0x56, 0x34, 0x12])
    }

    @Test
    func `encode to bytes big-endian`() {
        let value: UInt32 = 0x1234_5678
        let bytes = value.bytes(endianness: .big)
        #expect(bytes == [0x12, 0x34, 0x56, 0x78])
    }

    @Test
    func `encode zero`() {
        let value: UInt32 = 0
        #expect(value.bytes(endianness: .little) == [0x00, 0x00, 0x00, 0x00])
        #expect(value.bytes(endianness: .big) == [0x00, 0x00, 0x00, 0x00])
    }

    @Test
    func `encode max value`() {
        let value: UInt32 = .max  // 0xFFFF_FFFF
        #expect(value.bytes(endianness: .little) == [0xFF, 0xFF, 0xFF, 0xFF])
        #expect(value.bytes(endianness: .big) == [0xFF, 0xFF, 0xFF, 0xFF])
    }

    @Test
    func `encode-decode isomorphism little-endian`() {
        // encode ∘ decode ≡ id
        let original: UInt32 = 0x1234_5678
        let bytes = original.bytes(endianness: .little)
        let recovered = UInt32(bytes: bytes, endianness: .little)
        #expect(recovered == original)
    }

    @Test
    func `encode-decode isomorphism big-endian`() {
        // encode ∘ decode ≡ id
        let original: UInt32 = 0xABCD_EF01
        let bytes = original.bytes(endianness: .big)
        let recovered = UInt32(bytes: bytes, endianness: .big)
        #expect(recovered == original)
    }

    @Test
    func `decode-encode isomorphism`() {
        // decode ∘ encode ≡ id
        let originalBytes: [UInt8] = [0x12, 0x34, 0x56, 0x78]
        let value = UInt32(bytes: originalBytes, endianness: .little)
        let recoveredBytes = value?.bytes(endianness: .little)
        #expect(recoveredBytes == originalBytes)
    }

    @Test
    func `round-trip multiple values`() {
        let values: [UInt32] = [0, 1, 0xFF, 0x1_0000, 0x1234_5678, 0xABCD_EF01, .max]

        for original in values {
            let bytesLE = original.bytes(endianness: .little)
            let recoveredLE = UInt32(bytes: bytesLE, endianness: .little)
            #expect(recoveredLE == original)

            let bytesBE = original.bytes(endianness: .big)
            let recoveredBE = UInt32(bytes: bytesBE, endianness: .big)
            #expect(recoveredBE == original)
        }
    }

    @Test
    func `byte count matches memory layout`() {
        let value: UInt32 = 0x1234_5678
        let bytes = value.bytes(endianness: .little)
        #expect(bytes.count == MemoryLayout<UInt32>.size)
        #expect(bytes.count == 4)
    }
}
