// Binary.Reader Tests.swift

import Testing

@testable import Binary_Primitives

@Suite
struct `Binary.Reader Tests` {

    // MARK: - Initialization

    @Test
    func `reader initializes with default index`() throws {
        let storage: [UInt8] = [1, 2, 3, 4, 5]
        let reader = try Binary.Reader(storage: storage)

        #expect(reader.readerIndex.rawValue == 0)
        #expect(reader.remainingCount.rawValue == 5)
    }

    @Test
    func `reader initializes with custom index`() throws {
        let storage: [UInt8] = [1, 2, 3, 4, 5]
        let reader = try Binary.Reader(storage: storage, readerIndex: Binary.Position(2))

        #expect(reader.readerIndex.rawValue == 2)
        #expect(reader.remainingCount.rawValue == 3)
    }

    @Test
    func `reader initializes with unchecked`() {
        let storage: [UInt8] = [1, 2, 3, 4, 5]
        let reader = Binary.Reader(__unchecked: (), storage: storage, readerIndex: Binary.Position(2))

        #expect(reader.readerIndex.rawValue == 2)
        #expect(reader.remainingCount.rawValue == 3)
    }

    // MARK: - Index Mutation

    @Test
    func `move index advances reader`() throws {
        let storage: [UInt8] = [1, 2, 3, 4, 5]
        var reader = try Binary.Reader(storage: storage)

        try reader.moveReaderIndex(by: Binary.Offset(3))
        #expect(reader.readerIndex.rawValue == 3)
        #expect(reader.remainingCount.rawValue == 2)
    }

    @Test
    func `move index allows negative offset (rewind)`() throws {
        let storage: [UInt8] = [1, 2, 3, 4, 5]
        var reader = try Binary.Reader(storage: storage, readerIndex: Binary.Position(3))

        try reader.moveReaderIndex(by: Binary.Offset(-2))
        #expect(reader.readerIndex.rawValue == 1)
        #expect(reader.remainingCount.rawValue == 4)
    }

    @Test
    func `set index sets absolute position`() throws {
        let storage: [UInt8] = [1, 2, 3, 4, 5]
        var reader = try Binary.Reader(storage: storage)

        try reader.setReaderIndex(to: Binary.Position(4))
        #expect(reader.readerIndex.rawValue == 4)
        #expect(reader.remainingCount.rawValue == 1)
    }

    @Test
    func `reset clears reader index`() throws {
        let storage: [UInt8] = [1, 2, 3, 4, 5]
        var reader = try Binary.Reader(storage: storage, readerIndex: Binary.Position(3))

        reader.reset()
        #expect(reader.readerIndex.rawValue == 0)
        #expect(reader.remainingCount.rawValue == 5)
    }

    // MARK: - Unchecked Variants

    @Test
    func `moveReaderIndex unchecked works`() throws {
        let storage: [UInt8] = [1, 2, 3, 4, 5]
        var reader = try Binary.Reader(storage: storage)

        reader.moveReaderIndex(__unchecked: (), by: Binary.Offset(3))
        #expect(reader.readerIndex.rawValue == 3)
    }

    @Test
    func `setReaderIndex unchecked works`() throws {
        let storage: [UInt8] = [1, 2, 3, 4, 5]
        var reader = try Binary.Reader(storage: storage)

        reader.setReaderIndex(__unchecked: (), to: Binary.Position(4))
        #expect(reader.readerIndex.rawValue == 4)
    }

    // MARK: - Convenience Properties

    @Test
    func `hasRemaining returns true when bytes available`() throws {
        let storage: [UInt8] = [1, 2, 3]
        let reader = try Binary.Reader(storage: storage)
        let hasRemaining = reader.hasRemaining

        #expect(hasRemaining == true)
    }

    @Test
    func `hasRemaining returns false at end`() throws {
        let storage: [UInt8] = [1, 2, 3]
        let reader = try Binary.Reader(storage: storage, readerIndex: Binary.Position(3))
        let hasRemaining = reader.hasRemaining

        #expect(hasRemaining == false)
    }

    @Test
    func `isAtEnd returns true at end`() throws {
        let storage: [UInt8] = [1, 2, 3]
        let reader = try Binary.Reader(storage: storage, readerIndex: Binary.Position(3))
        let isAtEnd = reader.isAtEnd

        #expect(isAtEnd == true)
    }

    @Test
    func `isAtEnd returns false when bytes remain`() throws {
        let storage: [UInt8] = [1, 2, 3]
        let reader = try Binary.Reader(storage: storage)
        let isAtEnd = reader.isAtEnd

        #expect(isAtEnd == false)
    }

    // MARK: - Closure-Based Access

    @Test
    func `withRemainingBytes provides correct slice`() throws {
        let storage: [UInt8] = [1, 2, 3, 4, 5]
        let reader = try Binary.Reader(storage: storage, readerIndex: Binary.Position(2))

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
        let reader = try Binary.Reader(storage: storage, readerIndex: Binary.Position(3))

        unsafe reader.withRemainingBytes { ptr in
            #expect(ptr.isEmpty)
        }
    }

    // MARK: - Typed Throws

    @Test
    func `withRemainingBytes propagates typed error`() throws {
        enum TestError: Error { case expected }

        let storage: [UInt8] = [1, 2, 3]
        let reader = try Binary.Reader(storage: storage)

        #expect(throws: TestError.expected) {
            try unsafe reader.withRemainingBytes { (_: UnsafeRawBufferPointer) throws(TestError) in
                throw TestError.expected
            }
        }
    }

    // MARK: - Storage Access

    @Test
    func `storage property provides access to underlying data`() throws {
        let storage: [UInt8] = [10, 20, 30]
        let reader = try Binary.Reader(storage: storage)

        #expect(reader.storage.count == 3)
        #expect(reader.storage[0] == 10)
    }

    // MARK: - Error Cases

    @Test
    func `moveReaderIndex throws on overflow`() throws {
        let storage: [UInt8] = [1, 2, 3]
        var reader = try Binary.Reader(storage: storage)

        #expect(throws: Binary.Error.self) {
            try reader.moveReaderIndex(by: Binary.Offset(Int.max))
        }
    }

    @Test
    func `moveReaderIndex throws on out of bounds`() throws {
        let storage: [UInt8] = [1, 2, 3]
        var reader = try Binary.Reader(storage: storage)

        #expect(throws: Binary.Error.self) {
            try reader.moveReaderIndex(by: Binary.Offset(10))
        }
    }

    @Test
    func `setReaderIndex throws on negative`() throws {
        let storage: [UInt8] = [1, 2, 3]
        var reader = try Binary.Reader(storage: storage)

        #expect(throws: Binary.Error.self) {
            try reader.setReaderIndex(to: Binary.Position(-1))
        }
    }
}
