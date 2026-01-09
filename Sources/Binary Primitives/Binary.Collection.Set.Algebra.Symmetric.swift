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

extension Binary.Collection.Set.Algebra {
    /// Namespace for symmetric set operations.
    public struct Symmetric: Sendable {
        @usableFromInline
        var set: Binary.Collection.Set

        @usableFromInline
        init(set: Binary.Collection.Set) {
            self.set = set
        }
    }
}

// MARK: - Symmetric Operations

extension Binary.Collection.Set.Algebra.Symmetric {
    /// Returns the symmetric difference of this set and another.
    ///
    /// The result contains elements that are in exactly one of the two sets.
    ///
    /// - Parameter other: The set to compare with.
    /// - Returns: A new set containing elements in exactly one set.
    /// - Complexity: O(n/w) where w is word bit width
    @inlinable
    public func difference(_ other: Binary.Collection.Set) -> Binary.Collection.Set {
        let maxCount = Swift.max(set.words.count, other.words.count)
        var result = [UInt](repeating: 0, count: maxCount)

        for i in 0..<maxCount {
            let selfWord = i < set.words.count ? set.words[i] : 0
            let otherWord = i < other.words.count ? other.words[i] : 0
            result[i] = selfWord ^ otherWord
        }

        return Binary.Collection.Set(words: result)
    }

    /// Forms the symmetric difference of this set with another.
    ///
    /// - Parameter other: The set to compare with.
    /// - Complexity: O(n/w) where w is word bit width
    @inlinable
    public mutating func formDifference(_ other: Binary.Collection.Set) {
        set = difference(other)
    }
}
