// Comparable+Optionator.Range.swift
// swift-binary-primitives
//
// Optional-producing range operators for Comparable types.

extension Optional where Wrapped: Comparable {
    /// Creates a half-open range if bounds are valid, otherwise returns `nil`.
    ///
    /// Returns `nil` when:
    /// - Either bound is `nil`
    /// - Lower bound is greater than or equal to upper bound
    ///
    /// ## Example
    ///
    /// ```swift
    /// let start: Int? = 0
    /// let end: Int? = 10
    /// let validRange = start ..<? end  // Range(0..<10)
    ///
    /// let invalidRange: Range<Int>? = 10 ..<? 5  // nil (lower >= upper)
    /// let nilRange: Range<Int>? = nil ..<? 10   // nil (nil input)
    /// ```
    @inlinable
    public static func ..<? (lhs: Self, rhs: Self) -> Range<Wrapped>? {
        guard let a = lhs, let b = rhs, a < b else { return nil }
        return a..<b
    }

    /// Creates a closed range if bounds are valid, otherwise returns `nil`.
    ///
    /// Returns `nil` when:
    /// - Either bound is `nil`
    /// - Lower bound is greater than upper bound
    ///
    /// ## Example
    ///
    /// ```swift
    /// let start: Int? = 0
    /// let end: Int? = 10
    /// let validRange = start ...? end  // ClosedRange(0...10)
    ///
    /// let singleElement: ClosedRange<Int>? = 5 ...? 5  // ClosedRange(5...5) (valid)
    /// let invalidRange: ClosedRange<Int>? = 10 ...? 5  // nil (lower > upper)
    /// ```
    @inlinable
    public static func ...? (lhs: Self, rhs: Self) -> ClosedRange<Wrapped>? {
        guard let a = lhs, let b = rhs, a <= b else { return nil }
        return a...b
    }
}
