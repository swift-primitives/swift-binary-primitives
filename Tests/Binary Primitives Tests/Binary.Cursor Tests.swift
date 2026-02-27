// Binary.Cursor Tests.swift

import Testing

import Binary_Primitives
import Binary_Primitives_Test_Support

// MARK: - Test Suites

/// Tests for Binary.Cursor - uses parallel namespace pattern per [TEST-004]
/// since Binary.Cursor is a generic type.
@Suite("Binary.Cursor")
struct BinaryCursorTests {
    @Suite struct Unit {}
    @Suite struct EdgeCase {}
    @Suite struct Integration {}
    @Suite(.serialized) struct Performance {}
}

// MARK: - Unit Tests

extension BinaryCursorTests.Unit {

    // MARK: - Initialization

    @Test
    func `init with default indices sets reader and writer to zero`() {
        let storage: [UInt8] = [1, 2, 3, 4, 5]
        let cursor = Binary.Cursor(storage: storage)

        #expect(cursor.readerIndex == 0)
        #expect(cursor.writerIndex == 0)
        #expect(cursor.readableCount == 0)
        #expect(cursor.writableCount == 5)
    }

    @Test
    func `init with custom indices preserves positions`() throws {
        let storage: [UInt8] = [1, 2, 3, 4, 5]
        let cursor = try Binary.Cursor(
            storage: storage,
            readerIndex: 1,
            writerIndex: 4
        )

        #expect(cursor.readerIndex == 1)
        #expect(cursor.writerIndex == 4)
        #expect(cursor.readableCount == 3)
        #expect(cursor.writableCount == 1)
    }

    @Test
    func `init unchecked bypasses validation`() {
        let storage: [UInt8] = [1, 2, 3, 4, 5]
        let cursor = Binary.Cursor(
            __unchecked: (),
            storage: storage,
            readerIndex: 1,
            writerIndex: 4
        )

        #expect(cursor.readerIndex == 1)
        #expect(cursor.writerIndex == 4)
    }

    // MARK: - Move Reader Index

    @Test
    func `moveReaderIndex advances reader by offset`() throws {
        let storage: [UInt8] = [1, 2, 3, 4, 5]
        var cursor = try Binary.Cursor(
            storage: storage,
            readerIndex: 0,
            writerIndex: 5
        )

        try cursor.moveReaderIndex(by: 2)
        #expect(cursor.readerIndex == 2)
        #expect(cursor.readableCount == 3)
    }

    @Test
    func `moveReaderIndex unchecked advances reader`() throws {
        let storage: [UInt8] = [1, 2, 3, 4, 5]
        var cursor = try Binary.Cursor(
            storage: storage,
            readerIndex: 0,
            writerIndex: 5
        )

        cursor.moveReaderIndex(__unchecked: (), by: 2)
        #expect(cursor.readerIndex == 2)
    }

    // MARK: - Move Writer Index

    @Test
    func `moveWriterIndex advances writer by offset`() throws {
        let storage: [UInt8] = [1, 2, 3, 4, 5]
        var cursor = try Binary.Cursor(
            storage: storage,
            readerIndex: 0,
            writerIndex: 2
        )

        try cursor.moveWriterIndex(by: 2)
        #expect(cursor.writerIndex == 4)
        #expect(cursor.writableCount == 1)
    }

    @Test
    func `moveWriterIndex unchecked advances writer`() throws {
        let storage: [UInt8] = [1, 2, 3, 4, 5]
        var cursor = try Binary.Cursor(
            storage: storage,
            readerIndex: 0,
            writerIndex: 2
        )

        cursor.moveWriterIndex(__unchecked: (), by: 2)
        #expect(cursor.writerIndex == 4)
    }

    // MARK: - Set Reader Index

    @Test
    func `setReaderIndex sets absolute position`() throws {
        let storage: [UInt8] = [1, 2, 3, 4, 5]
        var cursor = try Binary.Cursor(
            storage: storage,
            readerIndex: 0,
            writerIndex: 5
        )

        try cursor.setReaderIndex(to: 3)
        #expect(cursor.readerIndex == 3)
    }

    @Test
    func `setReaderIndex unchecked sets absolute position`() throws {
        let storage: [UInt8] = [1, 2, 3, 4, 5]
        var cursor = try Binary.Cursor(
            storage: storage,
            readerIndex: 0,
            writerIndex: 5
        )

        cursor.setReaderIndex(__unchecked: (), to: 3)
        #expect(cursor.readerIndex == 3)
    }

    // MARK: - Set Writer Index

    @Test
    func `setWriterIndex sets absolute position`() throws {
        let storage: [UInt8] = [1, 2, 3, 4, 5]
        var cursor = try Binary.Cursor(
            storage: storage,
            readerIndex: 0,
            writerIndex: 2
        )

        try cursor.setWriterIndex(to: 4)
        #expect(cursor.writerIndex == 4)
    }

    @Test
    func `setWriterIndex unchecked sets absolute position`() throws {
        let storage: [UInt8] = [1, 2, 3, 4, 5]
        var cursor = try Binary.Cursor(
            storage: storage,
            readerIndex: 0,
            writerIndex: 2
        )

        cursor.setWriterIndex(__unchecked: (), to: 4)
        #expect(cursor.writerIndex == 4)
    }

    // MARK: - Reset

    @Test
    func `reset clears both indices to zero`() throws {
        let storage: [UInt8] = [1, 2, 3, 4, 5]
        var cursor = try Binary.Cursor(
            storage: storage,
            readerIndex: 2,
            writerIndex: 4
        )

        cursor.reset()
        #expect(cursor.readerIndex == 0)
        #expect(cursor.writerIndex == 0)
    }

    // MARK: - Readable/Writable Checks

    @Test
    func `isReadable returns true when bytes available`() throws {
        let storage: [UInt8] = [1, 2, 3]
        let cursor = try Binary.Cursor(
            storage: storage,
            readerIndex: 0,
            writerIndex: 3
        )

        #expect(cursor.isReadable == true)
    }

    @Test
    func `isReadable returns false when no bytes available`() throws {
        let storage: [UInt8] = [1, 2, 3]
        let cursor = try Binary.Cursor(
            storage: storage,
            readerIndex: 3,
            writerIndex: 3
        )

        #expect(cursor.isReadable == false)
    }

    @Test
    func `isWritable returns true when space available`() throws {
        let storage: [UInt8] = [1, 2, 3]
        let cursor = try Binary.Cursor(
            storage: storage,
            readerIndex: 0,
            writerIndex: 1
        )

        #expect(cursor.isWritable == true)
    }

    @Test
    func `isWritable returns false when no space available`() throws {
        let storage: [UInt8] = [1, 2, 3]
        let cursor = try Binary.Cursor(
            storage: storage,
            readerIndex: 0,
            writerIndex: 3
        )

        #expect(cursor.isWritable == false)
    }

    // MARK: - Closure-Based Access

    @Test
    func `withReadableBytes provides correct slice`() throws {
        let storage: [UInt8] = [1, 2, 3, 4, 5]
        let cursor = try Binary.Cursor(
            storage: storage,
            readerIndex: 1,
            writerIndex: 4
        )

        unsafe cursor.withReadableBytes { ptr in
            #expect(ptr.count == 3)
            #expect(ptr[0] == 2)
            #expect(ptr[1] == 3)
            #expect(ptr[2] == 4)
        }
    }
}

// MARK: - Edge Case Tests

extension BinaryCursorTests.EdgeCase {

    @Test
    func `init throws when reader exceeds writer`() {
        let storage: [UInt8] = [1, 2, 3]

        #expect(throws: Binary.Error.self) {
            _ = try Binary.Cursor(
                storage: storage,
                readerIndex: 2,
                writerIndex: 1
            )
        }
    }

    @Test
    func `init throws when writer exceeds storage count`() {
        let storage: [UInt8] = [1, 2, 3]

        #expect(throws: Binary.Error.self) {
            _ = try Binary.Cursor(
                storage: storage,
                readerIndex: 0,
                writerIndex: 10
            )
        }
    }

    @Test
    func `moveReaderIndex throws when exceeding writer`() throws {
        let storage: [UInt8] = [1, 2, 3, 4, 5]
        var cursor = try Binary.Cursor(
            storage: storage,
            readerIndex: 0,
            writerIndex: 3
        )

        #expect(throws: Binary.Error.self) {
            try cursor.moveReaderIndex(by: 5)
        }
    }

    @Test
    func `moveWriterIndex throws when exceeding storage count`() throws {
        let storage: [UInt8] = [1, 2, 3, 4, 5]
        var cursor = try Binary.Cursor(
            storage: storage,
            readerIndex: 0,
            writerIndex: 3
        )

        #expect(throws: Binary.Error.self) {
            try cursor.moveWriterIndex(by: 10)
        }
    }

    @Test
    func `withReadableBytes propagates typed error`() throws {
        enum TestError: Error { case expected }

        let storage: [UInt8] = [1, 2, 3]
        let cursor = try Binary.Cursor(
            storage: storage,
            readerIndex: 0,
            writerIndex: 3
        )

        #expect(throws: TestError.expected) {
            try unsafe cursor.withReadableBytes { (_: UnsafeRawBufferPointer) throws(TestError) in
                throw TestError.expected
            }
        }
    }
}
