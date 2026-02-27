// Binary.Reader Tests.swift

import Testing

import Binary_Primitives
import Binary_Primitives_Test_Support

// MARK: - Test Suites

/// Tests for Binary.Reader - uses parallel namespace pattern per [TEST-004]
/// since Binary.Reader is a generic type.
@Suite("Binary.Reader")
struct BinaryReaderTests {
    @Suite struct Unit {}
    @Suite struct EdgeCase {}
    @Suite struct Integration {}
    @Suite(.serialized) struct Performance {}
}

// MARK: - Unit Tests

extension BinaryReaderTests.Unit {

    // MARK: - Initialization

    @Test
    func `init with default index sets reader to zero`() {
        let storage: [UInt8] = [1, 2, 3, 4, 5]
        let reader = Binary.Reader(storage: storage)

        #expect(reader.readerIndex == 0)
        #expect(reader.remainingCount == 5)
    }

    @Test
    func `init with custom index preserves position`() throws {
        let storage: [UInt8] = [1, 2, 3, 4, 5]
        let reader = try Binary.Reader(storage: storage, readerIndex: 2)

        #expect(reader.readerIndex == 2)
        #expect(reader.remainingCount == 3)
    }

    @Test
    func `init unchecked bypasses validation`() {
        let storage: [UInt8] = [1, 2, 3, 4, 5]
        let reader = Binary.Reader(__unchecked: (), storage: storage, readerIndex: 2)

        #expect(reader.readerIndex == 2)
        #expect(reader.remainingCount == 3)
    }

    // MARK: - Move Reader Index

    @Test
    func `moveReaderIndex advances reader by offset`() throws {
        let storage: [UInt8] = [1, 2, 3, 4, 5]
        var reader = Binary.Reader(storage: storage)

        try reader.moveReaderIndex(by: 3)
        #expect(reader.readerIndex == 3)
        #expect(reader.remainingCount == 2)
    }

    @Test
    func `moveReaderIndex allows negative offset for rewind`() throws {
        let storage: [UInt8] = [1, 2, 3, 4, 5]
        var reader = try Binary.Reader(storage: storage, readerIndex: 3)

        try reader.moveReaderIndex(by: -2)
        #expect(reader.readerIndex == 1)
        #expect(reader.remainingCount == 4)
    }

    @Test
    func `moveReaderIndex unchecked advances reader`() {
        let storage: [UInt8] = [1, 2, 3, 4, 5]
        var reader = Binary.Reader(storage: storage)

        reader.moveReaderIndex(__unchecked: (), by: 3)
        #expect(reader.readerIndex == 3)
    }

    // MARK: - Set Reader Index

    @Test
    func `setReaderIndex sets absolute position`() throws {
        let storage: [UInt8] = [1, 2, 3, 4, 5]
        var reader = Binary.Reader(storage: storage)

        try reader.setReaderIndex(to: 4)
        #expect(reader.readerIndex == 4)
        #expect(reader.remainingCount == 1)
    }

    @Test
    func `setReaderIndex unchecked sets position`() {
        let storage: [UInt8] = [1, 2, 3, 4, 5]
        var reader = Binary.Reader(storage: storage)

        reader.setReaderIndex(__unchecked: (), to: 4)
        #expect(reader.readerIndex == 4)
    }

    // MARK: - Reset

    @Test
    func `reset clears reader index to zero`() throws {
        let storage: [UInt8] = [1, 2, 3, 4, 5]
        var reader = try Binary.Reader(storage: storage, readerIndex: 3)

        reader.reset()
        #expect(reader.readerIndex == 0)
        #expect(reader.remainingCount == 5)
    }

    // MARK: - Convenience Properties

    @Test
    func `hasRemaining returns true when bytes available`() {
        let storage: [UInt8] = [1, 2, 3]
        let reader = Binary.Reader(storage: storage)

        #expect(reader.hasRemaining == true)
    }

    @Test
    func `hasRemaining returns false at end`() throws {
        let storage: [UInt8] = [1, 2, 3]
        let reader = try Binary.Reader(storage: storage, readerIndex: 3)

        #expect(reader.hasRemaining == false)
    }

    @Test
    func `isAtEnd returns true at end`() throws {
        let storage: [UInt8] = [1, 2, 3]
        let reader = try Binary.Reader(storage: storage, readerIndex: 3)

        #expect(reader.isAtEnd == true)
    }

    @Test
    func `isAtEnd returns false when bytes remain`() {
        let storage: [UInt8] = [1, 2, 3]
        let reader = Binary.Reader(storage: storage)

        #expect(reader.isAtEnd == false)
    }

    // MARK: - Closure-Based Access

    @Test
    func `withRemainingBytes provides correct slice`() throws {
        let storage: [UInt8] = [1, 2, 3, 4, 5]
        let reader = try Binary.Reader(storage: storage, readerIndex: 2)

        unsafe reader.withRemainingBytes { ptr in
            #expect(ptr.count == 3)
            #expect(ptr[0] == 3)
            #expect(ptr[1] == 4)
            #expect(ptr[2] == 5)
        }
    }

    @Test
    func `withRemainingBytes returns empty for exhausted reader`() throws {
        let storage: [UInt8] = [1, 2, 3]
        let reader = try Binary.Reader(storage: storage, readerIndex: 3)

        unsafe reader.withRemainingBytes { ptr in
            #expect(ptr.isEmpty)
        }
    }

    // MARK: - Storage Access

    @Test
    func `storage property provides access to underlying data`() {
        let storage: [UInt8] = [10, 20, 30]
        let reader = Binary.Reader(storage: storage)

        #expect(reader.storage.count == 3)
        #expect(reader.storage[0] == 10)
    }
}

// MARK: - Edge Case Tests

extension BinaryReaderTests.EdgeCase {

    @Test
    func `moveReaderIndex throws on out of bounds`() {
        let storage: [UInt8] = [1, 2, 3]
        var reader = Binary.Reader(storage: storage)

        #expect(throws: Binary.Error.self) {
            try reader.moveReaderIndex(by: 10)
        }
    }

    @Test
    func `setReaderIndex throws on out of bounds`() {
        let storage: [UInt8] = [1, 2, 3]
        var reader = Binary.Reader(storage: storage)

        #expect(throws: Binary.Error.self) {
            try reader.setReaderIndex(to: 10)
        }
    }

    @Test
    func `withRemainingBytes propagates typed error`() {
        enum TestError: Error { case expected }

        let storage: [UInt8] = [1, 2, 3]
        let reader = Binary.Reader(storage: storage)

        #expect(throws: TestError.expected) {
            try unsafe reader.withRemainingBytes { (_: UnsafeRawBufferPointer) throws(TestError) in
                throw TestError.expected
            }
        }
    }
}
