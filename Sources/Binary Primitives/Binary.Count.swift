// Binary.Count.swift
// Non-negative byte count with typed throws.

@_spi(Internal) import Identity_Primitives
public import Dimension_Primitives

extension Binary {
    /// A non-negative byte count in a binary space.
    ///
    /// Construction enforces non-negativity via typed throws.
    ///
    /// ## API Pattern
    ///
    /// - **Primary**: `init(_:) throws(Binary.Error)` — validates at runtime
    /// - **Performance**: `init(unchecked:)` — debug assertion only
    /// - **Literals**: `ExpressibleByIntegerLiteral` — precondition (compile-time known)
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Throwing construction
    /// let count = try Binary.Count(value)
    ///
    /// // Performance path (known valid)
    /// let count = Binary.Count(unchecked: knownPositive)
    ///
    /// // Literals (compile-time checked)
    /// let count: Binary.Count<Int, Space> = 100
    ///
    /// // Error handling
    /// do {
    ///     let count = try Binary.Count(-1)
    /// } catch .negative(let e) {
    ///     print("\(e.field) was \(e.value)")
    /// }
    /// ```
    public struct Count<Scalar: BinaryInteger & Sendable, Space>: Sendable, Equatable, Hashable {
        /// The underlying non-negative value.
        @usableFromInline
        internal let _storage: Scalar

        /// The underlying non-negative value.

        public var rawValue: Scalar { _storage }

        /// Deprecated: Use `rawValue` instead.
        @available(*, deprecated, renamed: "rawValue", message: "Use 'rawValue' instead. '_rawValue' will be removed in a future version.")

        public var _rawValue: Scalar { _storage }
    }
}

// MARK: - Throwing Initializer

extension Binary.Count {
    /// Creates a count from a raw value.
    ///
    /// - Parameter value: The count value. Must be non-negative.
    /// - Throws: `Binary.Error.negative` if value < 0.

    public init(_ value: Scalar) throws(Binary.Error) {
        guard value >= 0 else {
            throw .negative(.init(field: .count, value: value))
        }
        self._storage = value
    }

    /// Creates a count from a typed extent.
    ///
    /// - Parameter extent: The extent value. Must be non-negative.
    /// - Throws: `Binary.Error.negative` if value < 0.

    public init(_ extent: Extent.X<Space>.Value<Scalar>) throws(Binary.Error) {
        guard extent._storage >= 0 else {
            throw .negative(.init(field: .count, value: extent._storage))
        }
        self._storage = extent._storage
    }
}

// MARK: - Unchecked Initializer

extension Binary.Count {
    /// Creates a count without validation.
    ///
    /// Use this in performance-critical paths where non-negativity
    /// is guaranteed by construction or prior validation.
    ///
    /// - Parameter value: The count value. Must be non-negative.
    /// - Precondition: `value >= 0` (debug-only assertion)

    public init(unchecked value: Scalar) {
        assert(value >= 0, "Count cannot be negative")
        self._storage = value
    }
}

// MARK: - ExpressibleByIntegerLiteral

extension Binary.Count: ExpressibleByIntegerLiteral where Scalar: ExpressibleByIntegerLiteral {
    /// Creates a count from an integer literal.
    ///
    /// Traps if the literal is negative (compile-time known).

    public init(integerLiteral value: Scalar.IntegerLiteralType) {
        let scalar = Scalar(integerLiteral: value)
        precondition(scalar >= 0, "Count literal cannot be negative")
        self._storage = scalar
    }
}

// MARK: - Comparable

extension Binary.Count: Comparable {

    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs._storage < rhs._storage
    }
}

// MARK: - Zero

extension Binary.Count {
    /// The zero count.

    public static var zero: Self {
        Self(unchecked: 0)
    }
}

// MARK: - Arithmetic (Non-Throwing)

extension Binary.Count {
    /// Adds two counts.
    ///
    /// Result is guaranteed non-negative since both operands are.

    public static func + (lhs: Self, rhs: Self) -> Self {
        Self(unchecked: lhs._storage + rhs._storage)
    }
}

// MARK: - Arithmetic (Throwing)

extension Binary.Count {
    /// Subtracts one count from another.
    ///
    /// - Throws: `Binary.Error.negative` if result would be negative.

    public static func - (lhs: Self, rhs: Self) throws(Binary.Error) -> Self {
        // Check BEFORE subtraction to avoid unsigned underflow trap
        guard lhs._storage >= rhs._storage else {
            // Compute what the negative result would be for error reporting
            // Use Int64 to avoid overflow in the error value
            let negativeResult = Int64(clamping: lhs._storage) - Int64(clamping: rhs._storage)
            throw .negative(.init(field: .count, value: negativeResult))
        }
        return Self(unchecked: lhs._storage - rhs._storage)
    }
}

// MARK: - CustomStringConvertible

extension Binary.Count: CustomStringConvertible {
    public var description: String {
        "\(_storage)"
    }
}
