// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-standards open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-standards project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

extension Binary.Collection {
    /// A dense array of boolean values using one bit per element.
    ///
    /// `Binary.Collection.Array` provides space-efficient storage for a
    /// sequence of boolean values, using a single bit per element. Unlike
    /// `Binary.Collection.Set`, this type maintains a specific count and
    /// order, making it suitable for indexed boolean data.
    ///
    /// ## Storage Model
    ///
    /// The array stores its bits in an underlying `Binary.Collection.Set`,
    /// with an additional `count` to track the logical size. Each index
    /// from 0 to count-1 represents a boolean value.
    ///
    /// ## Performance
    ///
    /// - Index access: O(1)
    /// - Append: O(1) amortized
    /// - Remove last: O(1)
    ///
    /// ## Example
    ///
    /// ```swift
    /// var bits = Binary.Collection.Array()
    /// bits.append(true)
    /// bits.append(false)
    /// bits.append(true)
    ///
    /// print(bits[0])  // true
    /// print(bits[1])  // false
    /// print(bits.count)  // 3
    /// ```
    public struct Array: Sendable, Equatable, Hashable {
        /// The underlying bit storage.
        @usableFromInline
        var storage: Binary.Collection.Set

        /// The number of elements in the array.
        @usableFromInline
        var _count: Int

        /// Creates an empty bit array.
        @inlinable
        public init() {
            self.storage = Binary.Collection.Set()
            self._count = 0
        }

        /// Creates a bit array with the given storage and count.
        @usableFromInline
        init(storage: Binary.Collection.Set, count: Int) {
            self.storage = storage
            self._count = count
        }
    }
}

// MARK: - Core Properties

extension Binary.Collection.Array {
    /// The number of elements in the array.
    @inlinable
    public var count: Int { _count }

    /// Whether the array is empty.
    @inlinable
    public var isEmpty: Bool { _count == 0 }

    /// The valid index range.
    @inlinable
    public var indices: Range<Int> { 0..<_count }
}

// MARK: - Element Access

extension Binary.Collection.Array {
    /// Accesses the boolean value at the given index.
    ///
    /// - Parameter index: The position of the element to access.
    /// - Precondition: `index` must be in `0..<count`.
    @inlinable
    public subscript(index: Int) -> Bool {
        get {
            precondition(index >= 0 && index < _count, "Index out of bounds")
            return storage.contains(index)
        }
        set {
            precondition(index >= 0 && index < _count, "Index out of bounds")
            if newValue {
                storage.insert(index)
            } else {
                storage.remove(index)
            }
        }
    }

    /// Returns the first element, or `nil` if empty.
    @inlinable
    public var first: Bool? {
        isEmpty ? nil : self[0]
    }

    /// Returns the last element, or `nil` if empty.
    @inlinable
    public var last: Bool? {
        isEmpty ? nil : self[_count - 1]
    }
}

// MARK: - Modification

extension Binary.Collection.Array {
    /// Appends a boolean value to the array.
    ///
    /// - Parameter value: The boolean value to append.
    /// - Complexity: O(1) amortized
    @inlinable
    public mutating func append(_ value: Bool) {
        if value {
            storage.insert(_count)
        }
        _count += 1
    }

    /// Removes and returns the last element.
    ///
    /// - Returns: The last element, or `nil` if empty.
    /// - Complexity: O(1)
    @discardableResult
    @inlinable
    public mutating func popLast() -> Bool? {
        guard _count > 0 else { return nil }
        _count -= 1
        let value = storage.contains(_count)
        storage.remove(_count)
        return value
    }

    /// Removes the last element.
    ///
    /// - Precondition: The array must not be empty.
    /// - Complexity: O(1)
    @inlinable
    public mutating func removeLast() {
        precondition(_count > 0, "Cannot remove from empty array")
        _count -= 1
        storage.remove(_count)
    }

    /// Removes all elements from the array.
    ///
    /// - Parameter keepingCapacity: Whether to keep the underlying storage.
    @inlinable
    public mutating func removeAll(keepingCapacity: Bool = false) {
        storage.clear()
        _count = 0
    }
}

// MARK: - Bulk Operations

extension Binary.Collection.Array {
    /// Creates a bit array from a sequence of booleans.
    ///
    /// - Parameter elements: The boolean values to include.
    @inlinable
    public init<S: Sequence>(_ elements: S) where S.Element == Bool {
        self.init()
        for element in elements {
            append(element)
        }
    }

    /// Creates a bit array with a repeated value.
    ///
    /// - Parameters:
    ///   - repeating: The value to repeat.
    ///   - count: The number of times to repeat the value.
    @inlinable
    public init(repeating value: Bool, count: Int) {
        precondition(count >= 0, "Count must be non-negative")
        self.init()
        self._count = count
        if value {
            // Set all bits up to count
            for i in 0..<count {
                storage.insert(i)
            }
        }
    }
}

// MARK: - Bitwise Operations

extension Binary.Collection.Array {
    /// Toggles the value at the given index.
    ///
    /// - Parameter index: The position of the element to toggle.
    /// - Precondition: `index` must be in `0..<count`.
    @inlinable
    public mutating func toggle(_ index: Int) {
        precondition(index >= 0 && index < _count, "Index out of bounds")
        if storage.contains(index) {
            storage.remove(index)
        } else {
            storage.insert(index)
        }
    }

    /// Returns the number of `true` values in the array.
    ///
    /// - Complexity: O(n/w) where w is word bit width
    @inlinable
    public var trueCount: Int {
        storage.count
    }

    /// Returns the number of `false` values in the array.
    ///
    /// - Complexity: O(n/w) where w is word bit width
    @inlinable
    public var falseCount: Int {
        _count - storage.count
    }

    /// Whether all elements are `true`.
    @inlinable
    public var allTrue: Bool {
        storage.count == _count
    }

    /// Whether all elements are `false`.
    @inlinable
    public var allFalse: Bool {
        storage.isEmpty
    }
}

// MARK: - Sequence

extension Binary.Collection.Array: Sequence {
    /// An iterator over the elements of a bit array.
    public struct Iterator: IteratorProtocol {
        @usableFromInline
        let storage: Binary.Collection.Set

        @usableFromInline
        let count: Int

        @usableFromInline
        var index: Int

        @usableFromInline
        init(storage: Binary.Collection.Set, count: Int) {
            self.storage = storage
            self.count = count
            self.index = 0
        }

        @inlinable
        public mutating func next() -> Bool? {
            guard index < count else { return nil }
            defer { index += 1 }
            return storage.contains(index)
        }
    }

    @inlinable
    public func makeIterator() -> Iterator {
        Iterator(storage: storage, count: _count)
    }
}

extension Binary.Collection.Array.Iterator: Sendable {}

// MARK: - Collection

extension Binary.Collection.Array: RandomAccessCollection {
    public typealias Index = Int
    public typealias Element = Bool

    @inlinable
    public var startIndex: Index { 0 }

    @inlinable
    public var endIndex: Index { _count }

    @inlinable
    public func index(after i: Index) -> Index { i + 1 }

    @inlinable
    public func index(before i: Index) -> Index { i - 1 }
}

// MARK: - Equatable

extension Binary.Collection.Array {
    @inlinable
    public static func == (lhs: Binary.Collection.Array, rhs: Binary.Collection.Array) -> Bool {
        guard lhs._count == rhs._count else { return false }
        // Compare only bits within the valid range
        return lhs.storage == rhs.storage
    }
}

// MARK: - Hashable

extension Binary.Collection.Array {
    @inlinable
    public func hash(into hasher: inout Hasher) {
        hasher.combine(_count)
        hasher.combine(storage)
    }
}

// MARK: - CustomStringConvertible

extension Binary.Collection.Array: CustomStringConvertible {
    public var description: String {
        let bits = prefix(64).map { $0 ? "1" : "0" }.joined()
        let suffix = _count > 64 ? "..." : ""
        return "BitArray(\(bits)\(suffix))"
    }
}
