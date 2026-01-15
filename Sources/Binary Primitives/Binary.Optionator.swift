// Binary.Optionator.swift
// swift-binary-primitives
//
// Optional-producing arithmetic operator declarations.
// Returns nil on overflow instead of trapping.

// MARK: - Prefix Operators

/// Optional-producing negation. Returns `nil` on overflow (e.g., negating Int.min).
prefix operator -?

// MARK: - Arithmetic Operators

/// Optional-producing addition. Returns `nil` on overflow.
///
/// ```swift
/// let sum = a +? b  // nil if overflow
/// ```
infix operator +? : AdditionPrecedence

/// Optional-producing subtraction. Returns `nil` on overflow.
///
/// ```swift
/// let diff = a -? b  // nil if overflow
/// ```
infix operator -? : AdditionPrecedence

/// Optional-producing multiplication. Returns `nil` on overflow.
///
/// ```swift
/// let product = a *? b  // nil if overflow
/// ```
infix operator *? : MultiplicationPrecedence

/// Optional-producing division. Returns `nil` on division by zero or overflow.
///
/// ```swift
/// let quotient = a /? b  // nil if b == 0 or overflow
/// ```
infix operator /? : MultiplicationPrecedence

/// Optional-producing remainder. Returns `nil` on division by zero or overflow.
///
/// ```swift
/// let remainder = a %? b  // nil if b == 0 or overflow
/// ```
infix operator %? : MultiplicationPrecedence

// MARK: - Assignment Operators

/// Optional-producing addition assignment. Sets to `nil` on overflow.
infix operator +?= : AssignmentPrecedence

/// Optional-producing subtraction assignment. Sets to `nil` on overflow.
infix operator -?= : AssignmentPrecedence

/// Optional-producing multiplication assignment. Sets to `nil` on overflow.
infix operator *?= : AssignmentPrecedence

/// Optional-producing division assignment. Sets to `nil` on division by zero or overflow.
infix operator /?= : AssignmentPrecedence

/// Optional-producing remainder assignment. Sets to `nil` on division by zero or overflow.
infix operator %?= : AssignmentPrecedence

// MARK: - Range Operators

/// Optional-producing half-open range. Returns `nil` if bounds are invalid.
///
/// ```swift
/// let range = start..<? end  // nil if start >= end
/// ```
infix operator ..<? : RangeFormationPrecedence

/// Optional-producing closed range. Returns `nil` if bounds are invalid.
///
/// ```swift
/// let range = start...? end  // nil if start > end
/// ```
infix operator ...? : RangeFormationPrecedence
