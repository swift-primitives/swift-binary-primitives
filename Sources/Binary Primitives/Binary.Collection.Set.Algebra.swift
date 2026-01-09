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

// MARK: - Algebra Accessor

extension Binary.Collection.Set {
    /// Nested accessor for set algebra operations.
    ///
    /// Provides set-theoretic operations using word-level bit operations
    /// for efficiency.
    ///
    /// ```swift
    /// let union = a.algebra.union(b)
    /// let intersection = a.algebra.intersection(b)
    /// let difference = a.algebra.subtract(b)
    /// let symmetric = a.algebra.symmetric.difference(b)
    /// ```
    @inlinable
    public var algebra: Algebra {
        Algebra(set: self)
    }
}

// MARK: - Algebra Type

extension Binary.Collection.Set {
    /// Namespace for set algebra operations.
    public struct Algebra: Sendable {
        @usableFromInline
        var set: Binary.Collection.Set

        @usableFromInline
        init(set: Binary.Collection.Set) {
            self.set = set
        }
    }
}

// MARK: - Algebra Operations

extension Binary.Collection.Set.Algebra {
    /// Returns the union of this set and another.
    ///
    /// The result contains all elements from both sets.
    ///
    /// - Parameter other: The set to union with.
    /// - Returns: A new set containing elements from both sets.
    /// - Complexity: O(n/w) where w is word bit width
    @inlinable
    public func union(_ other: Binary.Collection.Set) -> Binary.Collection.Set {
        let maxCount = Swift.max(set.words.count, other.words.count)
        var result = [UInt](repeating: 0, count: maxCount)

        for i in 0..<set.words.count {
            result[i] = set.words[i]
        }
        for i in 0..<other.words.count {
            result[i] |= other.words[i]
        }

        return Binary.Collection.Set(words: result)
    }

    /// Returns the intersection of this set and another.
    ///
    /// The result contains only elements present in both sets.
    ///
    /// - Parameter other: The set to intersect with.
    /// - Returns: A new set containing elements common to both sets.
    /// - Complexity: O(n/w) where w is word bit width
    @inlinable
    public func intersection(_ other: Binary.Collection.Set) -> Binary.Collection.Set {
        let minCount = Swift.min(set.words.count, other.words.count)
        var result = [UInt](repeating: 0, count: minCount)

        for i in 0..<minCount {
            result[i] = set.words[i] & other.words[i]
        }

        return Binary.Collection.Set(words: result)
    }

    /// Returns this set minus another.
    ///
    /// The result contains elements from this set that are not in the other.
    ///
    /// - Parameter other: The set to subtract.
    /// - Returns: A new set containing elements not in `other`.
    /// - Complexity: O(n/w) where w is word bit width
    @inlinable
    public func subtract(_ other: Binary.Collection.Set) -> Binary.Collection.Set {
        var result = set.words

        let minCount = Swift.min(result.count, other.words.count)
        for i in 0..<minCount {
            result[i] &= ~other.words[i]
        }

        return Binary.Collection.Set(words: result)
    }

    /// Accessor for symmetric difference operations.
    @inlinable
    public var symmetric: Symmetric {
        Symmetric(set: set)
    }
}

// MARK: - Mutating Operations

extension Binary.Collection.Set.Algebra {
    /// Forms the union of this set with another.
    ///
    /// - Parameter other: The set to union with.
    /// - Complexity: O(n/w) where w is word bit width
    @inlinable
    public mutating func formUnion(_ other: Binary.Collection.Set) {
        set = union(other)
    }

    /// Forms the intersection of this set with another.
    ///
    /// - Parameter other: The set to intersect with.
    /// - Complexity: O(n/w) where w is word bit width
    @inlinable
    public mutating func formIntersection(_ other: Binary.Collection.Set) {
        set = intersection(other)
    }

    /// Subtracts another set from this set.
    ///
    /// - Parameter other: The set to subtract.
    /// - Complexity: O(n/w) where w is word bit width
    @inlinable
    public mutating func formSubtract(_ other: Binary.Collection.Set) {
        set = subtract(other)
    }
}

// MARK: - Predicates

extension Binary.Collection.Set.Algebra {
    /// Returns whether this set is a subset of another.
    ///
    /// - Parameter other: The potential superset.
    /// - Returns: `true` if every element in this set is also in `other`.
    /// - Complexity: O(n/w) where w is word bit width
    @inlinable
    public func isSubset(_ other: Binary.Collection.Set) -> Bool {
        for i in set.words.indices {
            let selfWord = set.words[i]
            let otherWord = i < other.words.count ? other.words[i] : 0
            if selfWord & ~otherWord != 0 {
                return false
            }
        }
        return true
    }

    /// Returns whether this set is a superset of another.
    ///
    /// - Parameter other: The potential subset.
    /// - Returns: `true` if every element in `other` is also in this set.
    /// - Complexity: O(n/w) where w is word bit width
    @inlinable
    public func isSuperset(_ other: Binary.Collection.Set) -> Bool {
        for i in other.words.indices {
            let otherWord = other.words[i]
            let selfWord = i < set.words.count ? set.words[i] : 0
            if otherWord & ~selfWord != 0 {
                return false
            }
        }
        return true
    }

    /// Returns whether this set is disjoint with another.
    ///
    /// - Parameter other: The set to test.
    /// - Returns: `true` if the sets have no elements in common.
    /// - Complexity: O(n/w) where w is word bit width
    @inlinable
    public func isDisjoint(_ other: Binary.Collection.Set) -> Bool {
        let minCount = Swift.min(set.words.count, other.words.count)
        for i in 0..<minCount {
            if set.words[i] & other.words[i] != 0 {
                return false
            }
        }
        return true
    }
}
