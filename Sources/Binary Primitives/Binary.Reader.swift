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
    public struct Reader<Storage: Binary.Contiguous>: ~Copyable {
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
        self._readerIndex = 0
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

        guard readerIndex._storage >= 0 else {
            throw .negative(.init(field: .reader, value: readerIndex._storage))
        }

        guard readerIndex._storage <= count else {
            throw .bounds(
                .init(
                    field: .reader,
                    value: readerIndex._storage,
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
        readerIndex: Binary.Position<Storage.Scalar, Storage.Space> = 0
    ) {
        let count = Storage.Scalar(exactly: storage.count)
        precondition(count != nil, "storage.count exceeds Scalar range")
        precondition(readerIndex._storage >= 0)
        precondition(readerIndex._storage <= count!)
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
        Binary.Count(unchecked: _count - _readerIndex._storage)
    }

    /// Whether there are bytes remaining to read.

    public var hasRemaining: Bool {
        _count > _readerIndex._storage
    }

    /// Whether the reader has consumed all bytes.

    public var isAtEnd: Bool {
        _readerIndex._storage >= _count
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
        let (newIndex, overflow) = _readerIndex._storage.addingReportingOverflow(offset._storage)

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
        let (newIndex, overflow) = _readerIndex._storage.addingReportingOverflow(offset._storage)
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
        guard position._storage >= 0 else {
            throw .negative(.init(field: .reader, value: position._storage))
        }

        guard position._storage <= _count else {
            throw .bounds(
                .init(
                    field: .reader,
                    value: position._storage,
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
        precondition(position._storage >= 0)
        precondition(position._storage <= _count)
        _readerIndex = position
    }
}

// MARK: - Reset

extension Binary.Reader {
    /// Reset reader index to zero.

    public mutating func reset() {
        _readerIndex = 0
    }
}

// MARK: - Region Access

extension Binary.Reader {
    /// Provides read-only access to the remaining bytes region.
    ///
    /// The remaining region is `storage[readerIndex..<count]`.
    /// The buffer pointer is valid only within the closure scope.

    public func withRemainingBytes<R, E: Swift.Error>(
        _ body: (UnsafeRawBufferPointer) throws(E) -> R
    ) throws(E) -> R {
        let readerIdx = Int(_readerIndex._storage)
        let storageCount = Int(_count)
        return try storage.withUnsafeBytes { (ptr: UnsafeRawBufferPointer) throws(E) -> R in
            let slice = UnsafeRawBufferPointer(rebasing: ptr[readerIdx..<storageCount])
            return try body(slice)
        }
    }
}
