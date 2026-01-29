// Binary.Reader.swift
// Read-only position-tracked view with typed throws.

@_spi(Internal) import Identity_Primitives

extension Binary {
    /// A read-only position-tracked view over contiguous storage.
    ///
    /// Uses typed throws for all validation. All index arithmetic uses
    /// overflow-checking operations to prevent silent traps.
    ///
    /// ## Initializer Pattern
    ///
    /// - **Default**: `init(storage:)` — index at zero, throws on count conversion
    /// - **Validated**: `init(storage:readerIndex:) throws` — validates at runtime
    /// - **Unchecked**: `init(__unchecked:storage:readerIndex:)` — precondition only
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Default (reader = 0)
    /// var reader = try Binary.Reader(storage: buffer)
    ///
    /// // Validated (throws on invalid index)
    /// var reader = try Binary.Reader(storage: buffer, readerIndex: 5)
    ///
    /// // Unchecked (trusted caller)
    /// var reader = Binary.Reader(__unchecked: (), storage: buffer, readerIndex: 5)
    /// ```
    ///
    /// ## Invariants
    ///
    /// `0 <= readerIndex <= count`
    ///
    /// The `count` is stored as `Storage.Scalar` and validated once at construction.
    public struct Reader<Storage: Binary.Storage>: ~Copyable {
        /// The underlying storage.
        public let storage: Storage

        /// The storage count as Scalar (computed once, validated).
        @usableFromInline
        internal let _count: Storage.Scalar

        /// The current read position (internal storage).
        @usableFromInline
        internal var _readerIndex: Binary.Position<Storage.Scalar, Storage.Space>

        /// The current read position.

        public var readerIndex: Binary.Position<Storage.Scalar, Storage.Space> {
            _readerIndex
        }

        /// The storage count.

        public var count: Storage.Scalar {
            _count
        }
    }
}

// MARK: - Default Initializer

extension Binary.Reader {
    /// Creates a reader over the given storage with index at zero.
    ///
    /// - Parameter storage: The underlying storage.
    /// - Throws: `Binary.Error.overflow` if storage.count exceeds Scalar range.

    public init(storage: consuming Storage) throws(Binary.Error) {
        guard let count = Storage.Scalar(exactly: storage.count) else {
            throw .overflow(.init(operation: .conversion, field: .count))
        }
        self.storage = storage
        self._count = count
        self._readerIndex = Binary.Position(Storage.Scalar(0))
    }
}

// MARK: - Validated Initializer

extension Binary.Reader {
    /// Creates a reader over the given storage with validated index.
    ///
    /// - Parameters:
    ///   - storage: The underlying storage.
    ///   - readerIndex: The initial reader position.
    /// - Throws: `Binary.Error` if index violates invariants or storage.count exceeds Scalar range.

    public init(
        storage: consuming Storage,
        readerIndex: Binary.Position<Storage.Scalar, Storage.Space>
    ) throws(Binary.Error) {
        guard let count = Storage.Scalar(exactly: storage.count) else {
            throw .overflow(.init(operation: .conversion, field: .count))
        }

        guard readerIndex.rawValue >= 0 else {
            throw .negative(.init(field: .reader, value: readerIndex.rawValue))
        }

        guard readerIndex.rawValue <= count else {
            throw .bounds(
                .init(
                    field: .reader,
                    value: readerIndex.rawValue,
                    lower: Storage.Scalar(0),
                    upper: count
                )
            )
        }

        self.storage = storage
        self._count = count
        self._readerIndex = readerIndex
    }
}

// MARK: - Unchecked Initializer

extension Binary.Reader {
    /// Creates a reader without validation.
    ///
    /// Use this in performance-critical paths where invariants are
    /// guaranteed by construction or prior validation.
    ///
    /// - Parameters:
    ///   - __unchecked: Marker parameter (pass `()` or omit).
    ///   - storage: The underlying storage.
    ///   - readerIndex: The initial reader position.
    /// - Precondition: `storage.count` must fit in `Storage.Scalar`.
    /// - Precondition: `0 <= readerIndex <= storage.count`

    public init(
        __unchecked: Void = (),
        storage: consuming Storage,
        readerIndex: Binary.Position<Storage.Scalar, Storage.Space>? = nil
    ) {
        let readerIndex = readerIndex ?? Binary.Position(Storage.Scalar(0))
        let count = Storage.Scalar(exactly: storage.count)
        precondition(count != nil, "storage.count exceeds Scalar range")
        precondition(readerIndex.rawValue >= 0)
        precondition(readerIndex.rawValue <= count!)
        self.storage = storage
        self._count = count!
        self._readerIndex = readerIndex
    }
}

// MARK: - Computed Properties

extension Binary.Reader {
    /// Bytes remaining to read.

    public var remainingCount: Binary.Count<Storage.Scalar, Storage.Space> {
        // Safe: invariant guarantees count >= reader
        Binary.Count(unchecked: _count - _readerIndex.rawValue)
    }

    /// Whether there are bytes remaining to read.

    public var hasRemaining: Bool {
        _count > _readerIndex.rawValue
    }

    /// Whether the reader has consumed all bytes.

    public var isAtEnd: Bool {
        _readerIndex.rawValue >= _count
    }
}

// MARK: - Move Reader Index

extension Binary.Reader {
    /// Move reader index by offset.
    ///
    /// - Parameter offset: The displacement to apply.
    /// - Throws: `Binary.Error` if resulting index would be invalid or overflow occurs.

    public mutating func moveReaderIndex(
        by offset: Binary.Offset<Storage.Scalar, Storage.Space>
    ) throws(Binary.Error) {
        let (newIndex, overflow) = _readerIndex.rawValue.addingReportingOverflow(offset.rawValue)

        guard !overflow else {
            throw .overflow(.init(operation: .addition, field: .reader))
        }

        guard newIndex >= 0 else {
            throw .bounds(
                .init(
                    field: .reader,
                    value: newIndex,
                    lower: Storage.Scalar(0),
                    upper: _count
                )
            )
        }

        guard newIndex <= _count else {
            throw .bounds(
                .init(
                    field: .reader,
                    value: newIndex,
                    lower: Storage.Scalar(0),
                    upper: _count
                )
            )
        }

        _readerIndex = Binary.Position(newIndex)
    }

    /// Move reader index by offset (unchecked).
    ///
    /// - Parameters:
    ///   - __unchecked: Marker parameter (pass `()` or omit).
    ///   - offset: The displacement to apply.
    /// - Precondition: No overflow occurs.
    /// - Precondition: Result must satisfy `0 <= readerIndex <= count`.

    public mutating func moveReaderIndex(
        __unchecked: Void = (),
        by offset: Binary.Offset<Storage.Scalar, Storage.Space>
    ) {
        let (newIndex, overflow) = _readerIndex.rawValue.addingReportingOverflow(offset.rawValue)
        precondition(!overflow, "readerIndex arithmetic overflow")
        precondition(newIndex >= 0 && newIndex <= _count)
        _readerIndex = Binary.Position(newIndex)
    }
}

// MARK: - Set Reader Index

extension Binary.Reader {
    /// Set reader index to position.
    ///
    /// - Parameter position: The new reader position.
    /// - Throws: `Binary.Error` if position is invalid.

    public mutating func setReaderIndex(
        to position: Binary.Position<Storage.Scalar, Storage.Space>
    ) throws(Binary.Error) {
        guard position.rawValue >= 0 else {
            throw .negative(.init(field: .reader, value: position.rawValue))
        }

        guard position.rawValue <= _count else {
            throw .bounds(
                .init(
                    field: .reader,
                    value: position.rawValue,
                    lower: Storage.Scalar(0),
                    upper: _count
                )
            )
        }

        _readerIndex = position
    }

    /// Set reader index to position (unchecked).
    ///
    /// - Parameters:
    ///   - __unchecked: Marker parameter (pass `()` or omit).
    ///   - position: The new reader position.
    /// - Precondition: `0 <= position <= count`.

    public mutating func setReaderIndex(
        __unchecked: Void = (),
        to position: Binary.Position<Storage.Scalar, Storage.Space>
    ) {
        precondition(position.rawValue >= 0)
        precondition(position.rawValue <= _count)
        _readerIndex = position
    }
}

// MARK: - Reset

extension Binary.Reader {
    /// Reset reader index to zero.

    public mutating func reset() {
        _readerIndex = Binary.Position(Storage.Scalar(0))
    }
}

// MARK: - Region Access

extension Binary.Reader {
    /// Returns a span of the remaining bytes region.
    ///
    /// The remaining region is `storage[readerIndex..<count]`.
    /// The span is lifetime-bound to the reader.
    @inlinable
    public var remainingBytes: Span<UInt8> {
        @_lifetime(borrow self)
        borrowing get {
            let readerIdx = Int(_readerIndex.rawValue)
            let storageCount = Int(_count)
            return storage.bytes.extracting(readerIdx..<storageCount)
        }
    }

    /// Provides read-only access to the remaining bytes region via closure.
    ///
    /// The remaining region is `storage[readerIndex..<count]`.
    /// The buffer pointer is valid only within the closure scope.
    @inlinable
    public func withRemainingBytes<R, E: Swift.Error>(
        _ body: (UnsafeRawBufferPointer) throws(E) -> R
    ) throws(E) -> R {
        let span = remainingBytes
        return try unsafe span.withUnsafeBytes { (rawBuffer: UnsafeRawBufferPointer) throws(E) -> R in
            try unsafe body(rawBuffer)
        }
    }
}
