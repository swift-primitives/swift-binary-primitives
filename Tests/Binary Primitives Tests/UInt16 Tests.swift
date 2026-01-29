// UInt16 Tests.swift

import Testing

@testable import Binary_Primitives
import Binary_Primitives_Test_Support

// MARK: - Test Suites

/// Tests for UInt16 byte encoding - uses parallel namespace pattern
/// since UInt16 is a stdlib type.
@Suite("UInt16 - Byte encoding")
struct UInt16ByteEncodingTests {
    @Suite struct Unit {}
    @Suite struct EdgeCase {}
    @Suite struct Integration {}
    @Suite(.serialized) struct Performance {}
}

// MARK: - Unit Tests

extension UInt16ByteEncodingTests.Unit {

    @Test
    func `encode to bytes little-endian`() {
        let value: UInt16 = 0x1234
        let bytes = value.bytes(endianness: .little)
        #expect(bytes == [0x34, 0x12])
    }

    @Test
    func `encode to bytes big-endian`() {
        let value: UInt16 = 0x1234
        let bytes = value.bytes(endianness: .big)
        #expect(bytes == [0x12, 0x34])
    }

    @Test
    func `encode zero`() {
        let value: UInt16 = 0
        #expect(value.bytes(endianness: .little) == [0x00, 0x00])
        #expect(value.bytes(endianness: .big) == [0x00, 0x00])
    }

    @Test
    func `encode max value`() {
        let value: UInt16 = .max  // 0xFFFF
        #expect(value.bytes(endianness: .little) == [0xFF, 0xFF])
        #expect(value.bytes(endianness: .big) == [0xFF, 0xFF])
    }

    @Test
    func `encode-decode isomorphism little-endian`() {
        // encode ∘ decode ≡ id
        let original: UInt16 = 0x1234
        let bytes = original.bytes(endianness: .little)
        let recovered = UInt16(bytes: bytes, endianness: .little)
        #expect(recovered == original)
    }

    @Test
    func `encode-decode isomorphism big-endian`() {
        // encode ∘ decode ≡ id
        let original: UInt16 = 0xABCD
        let bytes = original.bytes(endianness: .big)
        let recovered = UInt16(bytes: bytes, endianness: .big)
        #expect(recovered == original)
    }

    @Test
    func `decode-encode isomorphism`() {
        // decode ∘ encode ≡ id
        let originalBytes: [UInt8] = [0x12, 0x34]
        let value = UInt16(bytes: originalBytes, endianness: .little)
        let recoveredBytes = value?.bytes(endianness: .little)
        #expect(recoveredBytes == originalBytes)
    }

    @Test
    func `round-trip multiple values`() {
        let values: [UInt16] = [0, 1, 0xFF, 0x100, 0x1234, 0xABCD, .max]

        for original in values {
            let bytesLE = original.bytes(endianness: .little)
            let recoveredLE = UInt16(bytes: bytesLE, endianness: .little)
            #expect(recoveredLE == original)

            let bytesBE = original.bytes(endianness: .big)
            let recoveredBE = UInt16(bytes: bytesBE, endianness: .big)
            #expect(recoveredBE == original)
        }
    }

    @Test
    func `byte count matches memory layout`() {
        let value: UInt16 = 0x1234
        let bytes = value.bytes(endianness: .little)
        #expect(bytes.count == MemoryLayout<UInt16>.size)
        #expect(bytes.count == 2)
    }
}

// MARK: - Integration Tests

extension UInt16ByteEncodingTests.Integration {

    @Test
    func `round-trip conversion with Array`() {
        let values: [UInt16] = [100, 200, 300]
        let bytes = [UInt8](serializing: values)
        let recovered = [UInt16](bytes: bytes)
        #expect(recovered == values)
    }

    @Test
    func `collection works with ArraySlice`() {
        let values: [UInt16] = [100, 200, 300, 400, 500]
        let slice = values[1...3]  // ArraySlice containing [200, 300, 400]

        let bytes = [UInt8](serializing: slice)
        let recovered = [UInt16](bytes: bytes)
        #expect(recovered == Array(slice))
    }

    @Test
    func `collection works with ContiguousArray`() {
        let values = ContiguousArray<UInt16>([100, 200, 300])
        let bytes = [UInt8](serializing: values)
        let recovered = [UInt16](bytes: bytes)
        #expect(recovered == Array(values))
    }

    @Test
    func `collection works with prefix`() {
        let values: [UInt16] = [100, 200, 300, 400, 500]
        let prefix = values.prefix(3)  // [100, 200, 300]

        let bytes = [UInt8](serializing: prefix)
        let recovered = [UInt16](bytes: bytes)
        #expect(recovered == Array(prefix))
    }

    @Test
    func `collection works with suffix`() {
        let values: [UInt16] = [100, 200, 300, 400, 500]
        let suffix = values.suffix(2)  // [400, 500]

        let bytes = [UInt8](serializing: suffix)
        let recovered = [UInt16](bytes: bytes)
        #expect(recovered == Array(suffix))
    }

    @Test
    func `endianness with collection`() {
        let values: [UInt16] = [0x0102, 0x0304]

        let bytesLE = [UInt8](serializing: values, endianness: .little)
        let bytesBE = [UInt8](serializing: values, endianness: .big)

        // Little-endian: least significant byte first
        #expect(bytesLE == [0x02, 0x01, 0x04, 0x03])

        // Big-endian: most significant byte first
        #expect(bytesBE == [0x01, 0x02, 0x03, 0x04])
    }
}
