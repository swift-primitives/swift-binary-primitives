// FixedWidthInteger+Optionator.Assignment.swift
// swift-binary-primitives
//
// Optional-producing arithmetic assignment operators for FixedWidthInteger.

extension Optional where Wrapped: FixedWidthInteger {
    /// Adds and assigns, setting to `nil` on overflow.
    ///
    /// ## Example
    ///
    /// ```swift
    /// var total: Int? = 100
    /// total +?= 50  // total == 150
    /// total +?= Int.max  // total == nil (overflow)
    /// ```
    @inlinable
    public static func +?= (lhs: inout Self, rhs: Self) {
        lhs = lhs +? rhs
    }

    /// Subtracts and assigns, setting to `nil` on overflow.
    @inlinable
    public static func -?= (lhs: inout Self, rhs: Self) {
        lhs = lhs -? rhs
    }

    /// Multiplies and assigns, setting to `nil` on overflow.
    ///
    /// ## Example
    ///
    /// ```swift
    /// var value: Int? = 1000
    /// value *?= 1000  // value == 1_000_000
    /// value *?= Int.max  // value == nil (overflow)
    /// ```
    @inlinable
    public static func *?= (lhs: inout Self, rhs: Self) {
        lhs = lhs *? rhs
    }

    /// Divides and assigns, setting to `nil` on division by zero or overflow.
    @inlinable
    public static func /?= (lhs: inout Self, rhs: Self) {
        lhs = lhs /? rhs
    }

    /// Computes remainder and assigns, setting to `nil` on division by zero or overflow.
    @inlinable
    public static func %?= (lhs: inout Self, rhs: Self) {
        lhs = lhs %? rhs
    }
}
