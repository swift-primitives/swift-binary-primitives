// FixedWidthInteger+Optionator.swift
// swift-binary-primitives
//
// Optional-producing arithmetic operators for FixedWidthInteger.
// Extends Optional<FixedWidthInteger> following Apple's pattern.

// MARK: - Arithmetic Operators

extension Optional where Wrapped: FixedWidthInteger {
    /// Adds two optional integers, returning `nil` if either is `nil` or overflow occurs.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let a: Int8? = 100
    /// let b: Int8? = 50
    /// let sum = a +? b  // nil (overflow)
    ///
    /// let c: Int? = nil
    /// let d: Int? = 5
    /// let result = c +? d  // nil (nil input)
    /// ```
    @inlinable
    public static func +? (lhs: Self, rhs: Self) -> Self {
        guard let a = lhs, let b = rhs else { return nil }
        let (result, overflow) = a.addingReportingOverflow(b)
        return overflow ? nil : result
    }

    /// Subtracts two optional integers, returning `nil` if either is `nil` or overflow occurs.
    @inlinable
    public static func -? (lhs: Self, rhs: Self) -> Self {
        guard let a = lhs, let b = rhs else { return nil }
        let (result, overflow) = a.subtractingReportingOverflow(b)
        return overflow ? nil : result
    }

    /// Multiplies two optional integers, returning `nil` if either is `nil` or overflow occurs.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let width: Int? = 1920
    /// let height: Int? = 1080
    /// let pixelCount = width *? height  // 2073600 (safe)
    ///
    /// let huge: Int? = Int.max
    /// let result = huge *? 2  // nil (overflow)
    /// ```
    @inlinable
    public static func *? (lhs: Self, rhs: Self) -> Self {
        guard let a = lhs, let b = rhs else { return nil }
        let (result, overflow) = a.multipliedReportingOverflow(by: b)
        return overflow ? nil : result
    }

    /// Divides two optional integers, returning `nil` if either is `nil`, divisor is zero, or overflow occurs.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let result: Int? = 10 /? 3  // 3
    /// let zero: Int? = 10 /? 0    // nil (division by zero)
    /// let overflow: Int? = Int.min /? (-1)  // nil (overflow)
    /// ```
    @inlinable
    public static func /? (lhs: Self, rhs: Self) -> Self {
        guard let a = lhs, let b = rhs, b != 0 else { return nil }
        let (result, overflow) = a.dividedReportingOverflow(by: b)
        return overflow ? nil : result
    }

    /// Computes remainder of two optional integers, returning `nil` if either is `nil`, divisor is zero, or overflow occurs.
    @inlinable
    public static func %? (lhs: Self, rhs: Self) -> Self {
        guard let a = lhs, let b = rhs, b != 0 else { return nil }
        let (result, overflow) = a.remainderReportingOverflow(dividingBy: b)
        return overflow ? nil : result
    }
}

// MARK: - Signed Negation

extension Optional where Wrapped: FixedWidthInteger & SignedNumeric {
    /// Negates an optional signed integer, returning `nil` if `nil` or overflow occurs.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let a: Int8? = -128
    /// let negated = -?a  // nil (Int8.min cannot be negated)
    /// ```
    @inlinable
    public static prefix func -? (value: Self) -> Self {
        guard let v = value else { return nil }
        let (result, overflow) = (0 as Wrapped).subtractingReportingOverflow(v)
        return overflow ? nil : result
    }
}
