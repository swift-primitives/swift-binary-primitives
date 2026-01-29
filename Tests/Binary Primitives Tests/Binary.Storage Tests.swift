// Binary.Storage Tests.swift
// Tests for Binary.Storage and Binary.MutableStorage protocol conformances.

import Testing

@testable import Binary_Primitives
import Binary_Primitives_Test_Support

// MARK: - Test Suites

/// Tests for Binary.Storage protocol - uses parallel namespace pattern per [TEST-004]
/// since Binary.Storage is a protocol.
@Suite("Binary.Storage")
struct BinaryStorageTests {
    @Suite struct Unit {}
    @Suite struct EdgeCase {}
    @Suite struct Integration {}
    @Suite(.serialized) struct Performance {}
}

/// Tests for Binary.MutableStorage protocol.
@Suite("Binary.MutableStorage")
struct BinaryMutableStorageTests {
    @Suite struct Unit {}
    @Suite struct EdgeCase {}
    @Suite struct Integration {}
    @Suite(.serialized) struct Performance {}
}

// MARK: - Binary.Storage Unit Tests

extension BinaryStorageTests.Unit {

    // MARK: - Array<UInt8> Conformance

    @Test
    func `Array conforms to Binary.Storage`() {
        let array: [UInt8] = [1, 2, 3, 4, 5]

        let span = array.bytes
        #expect(span.count == 5)
    }

    @Test
    func `Array count matches bytes count`() {
        let array: [UInt8] = [10, 20, 30]

        #expect(array.bytes.count == array.count)
    }

    @Test
    func `Array empty buffer has zero count`() {
        let array: [UInt8] = []

        #expect(array.isEmpty)
        #expect(array.bytes.count == 0)
    }

    // MARK: - ContiguousArray<UInt8> Conformance

    @Test
    func `ContiguousArray conforms to Binary.Storage`() {
        let array: ContiguousArray<UInt8> = [10, 20, 30]

        #expect(array.bytes.count == 3)
    }

    // MARK: - Generic Usage

    @Test
    func `generic function accepts Binary.Storage`() {
        func readFirstByte<S: Binary.Storage>(_ data: borrowing S) -> UInt8? {
            let span = data.bytes
            guard span.count > 0 else { return nil }
            return span[0]
        }

        let array: [UInt8] = [0x42, 0x43]
        let contiguousArray: ContiguousArray<UInt8> = [0x44, 0x45]

        #expect(readFirstByte(array) == 0x42)
        #expect(readFirstByte(contiguousArray) == 0x44)
    }

    @Test
    func `generic function uses count property`() {
        func byteCount<S: Binary.Storage>(_ data: borrowing S) -> Int {
            data.count
        }

        let array: [UInt8] = [1, 2, 3, 4, 5]
        #expect(byteCount(array) == 5)
    }
}

// MARK: - Binary.MutableStorage Unit Tests

extension BinaryMutableStorageTests.Unit {

    // MARK: - Array<UInt8> Conformance

    @Test
    func `Array conforms to Binary.MutableStorage`() {
        var array: [UInt8] = [0, 0, 0]

        // MutableSpan mutation must happen in single expression scope
        array.withUnsafeMutableBytes { ptr in
            ptr[0] = 0xAA
            ptr[1] = 0xBB
            ptr[2] = 0xCC
        }

        #expect(array == [0xAA, 0xBB, 0xCC])
    }

    @Test
    func `Array mutable count matches buffer count`() {
        var array: [UInt8] = [1, 2, 3, 4]
        let expectedCount = array.count

        #expect(array.mutableBytes.count == expectedCount)
    }

    // MARK: - ContiguousArray<UInt8> Conformance

    @Test
    func `ContiguousArray conforms to Binary.MutableStorage`() {
        var array: ContiguousArray<UInt8> = [0, 0]

        array.withUnsafeMutableBytes { ptr in
            ptr[0] = 0x12
            ptr[1] = 0x34
        }

        #expect(array == [0x12, 0x34])
    }

    // MARK: - MutableStorage Refines Storage

    @Test
    func `Binary.MutableStorage type can be read via Binary.Storage`() {
        func readFirst<S: Binary.MutableStorage>(_ data: borrowing S) -> UInt8? {
            let span = data.bytes
            guard span.count > 0 else { return nil }
            return span[0]
        }

        let array: [UInt8] = [0x99]
        #expect(readFirst(array) == 0x99)
    }

    // MARK: - Generic Usage

    @Test
    func `generic function accepts Binary.MutableStorage for read`() {
        func byteCount<S: Binary.MutableStorage>(_ data: borrowing S) -> Int {
            data.count
        }

        let array: [UInt8] = [1, 2, 3]
        let contiguousArray: ContiguousArray<UInt8> = [4, 5]

        #expect(byteCount(array) == 3)
        #expect(byteCount(contiguousArray) == 2)
    }
}
