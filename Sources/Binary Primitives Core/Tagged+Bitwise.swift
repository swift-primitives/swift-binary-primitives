// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-binary-primitives open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-binary-primitives project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

// MARK: - Bitwise Operations for Tagged<Tag, FixedWidthInteger>

// These extensions enable type-safe bitwise operations on Tagged values
// wrapping FixedWidthInteger types (UInt32, UInt64, etc.).
// Used for CPU register manipulation, flag checking, etc.

// MARK: - Bitwise AND

/// Bitwise AND of two tagged values.
@inlinable
public func & <Tag, RawValue: FixedWidthInteger>(
    lhs: Tagged<Tag, RawValue>,
    rhs: Tagged<Tag, RawValue>
) -> Tagged<Tag, RawValue> {
    Tagged(__unchecked: (), lhs.rawValue & rhs.rawValue)
}

/// Bitwise AND of a tagged value with a raw integer literal.
@inlinable
public func & <Tag, RawValue: FixedWidthInteger>(
    lhs: Tagged<Tag, RawValue>,
    rhs: RawValue
) -> Tagged<Tag, RawValue> {
    Tagged(__unchecked: (), lhs.rawValue & rhs)
}

/// Bitwise AND of a raw integer literal with a tagged value.
@inlinable
public func & <Tag, RawValue: FixedWidthInteger>(
    lhs: RawValue,
    rhs: Tagged<Tag, RawValue>
) -> Tagged<Tag, RawValue> {
    Tagged(__unchecked: (), lhs & rhs.rawValue)
}

// MARK: - Bitwise OR

/// Bitwise OR of two tagged values.
@inlinable
public func | <Tag, RawValue: FixedWidthInteger>(
    lhs: Tagged<Tag, RawValue>,
    rhs: Tagged<Tag, RawValue>
) -> Tagged<Tag, RawValue> {
    Tagged(__unchecked: (), lhs.rawValue | rhs.rawValue)
}

/// Bitwise OR of a tagged value with a raw integer literal.
@inlinable
public func | <Tag, RawValue: FixedWidthInteger>(
    lhs: Tagged<Tag, RawValue>,
    rhs: RawValue
) -> Tagged<Tag, RawValue> {
    Tagged(__unchecked: (), lhs.rawValue | rhs)
}

/// Bitwise OR of a raw integer literal with a tagged value.
@inlinable
public func | <Tag, RawValue: FixedWidthInteger>(
    lhs: RawValue,
    rhs: Tagged<Tag, RawValue>
) -> Tagged<Tag, RawValue> {
    Tagged(__unchecked: (), lhs | rhs.rawValue)
}

// MARK: - Bitwise XOR

/// Bitwise XOR of two tagged values.
@inlinable
public func ^ <Tag, RawValue: FixedWidthInteger>(
    lhs: Tagged<Tag, RawValue>,
    rhs: Tagged<Tag, RawValue>
) -> Tagged<Tag, RawValue> {
    Tagged(__unchecked: (), lhs.rawValue ^ rhs.rawValue)
}

/// Bitwise XOR of a tagged value with a raw integer literal.
@inlinable
public func ^ <Tag, RawValue: FixedWidthInteger>(
    lhs: Tagged<Tag, RawValue>,
    rhs: RawValue
) -> Tagged<Tag, RawValue> {
    Tagged(__unchecked: (), lhs.rawValue ^ rhs)
}

/// Bitwise XOR of a raw integer literal with a tagged value.
@inlinable
public func ^ <Tag, RawValue: FixedWidthInteger>(
    lhs: RawValue,
    rhs: Tagged<Tag, RawValue>
) -> Tagged<Tag, RawValue> {
    Tagged(__unchecked: (), lhs ^ rhs.rawValue)
}

// MARK: - Bitwise NOT

/// Bitwise NOT of a tagged value.
@inlinable
public prefix func ~ <Tag, RawValue: FixedWidthInteger>(
    value: Tagged<Tag, RawValue>
) -> Tagged<Tag, RawValue> {
    value.map { ~$0 }
}

// MARK: - Left Shift

/// Left shift a tagged value by an integer amount.
@inlinable
public func << <Tag, RawValue: FixedWidthInteger>(
    lhs: Tagged<Tag, RawValue>,
    rhs: Int
) -> Tagged<Tag, RawValue> {
    Tagged(__unchecked: (), lhs.rawValue << rhs)
}

/// Left shift a tagged value by a tagged shift amount.
@inlinable
public func << <Tag, RawValue: FixedWidthInteger, ShiftTag>(
    lhs: Tagged<Tag, RawValue>,
    rhs: Tagged<ShiftTag, Int>
) -> Tagged<Tag, RawValue> {
    Tagged(__unchecked: (), lhs.rawValue << rhs.rawValue)
}

// MARK: - Right Shift

/// Right shift a tagged value by an integer amount.
@inlinable
public func >> <Tag, RawValue: FixedWidthInteger>(
    lhs: Tagged<Tag, RawValue>,
    rhs: Int
) -> Tagged<Tag, RawValue> {
    Tagged(__unchecked: (), lhs.rawValue >> rhs)
}

/// Right shift a tagged value by a tagged shift amount.
@inlinable
public func >> <Tag, RawValue: FixedWidthInteger, ShiftTag>(
    lhs: Tagged<Tag, RawValue>,
    rhs: Tagged<ShiftTag, Int>
) -> Tagged<Tag, RawValue> {
    Tagged(__unchecked: (), lhs.rawValue >> rhs.rawValue)
}

// MARK: - Cardinal Shift Operators

// Bare FixedWidthInteger << / >> Cardinal.Protocol operators live in
// bit-primitives (FixedWidthInteger+Cardinal.swift) — shifts are
// ℕ-indexed endomorphisms on Word, co-located with the bit domain.

/// Left shift a tagged value by a cardinal amount.
@inlinable
public func << <Tag, RawValue: FixedWidthInteger>(
    lhs: Tagged<Tag, RawValue>,
    rhs: some Cardinal.`Protocol`
) -> Tagged<Tag, RawValue> {
    Tagged(__unchecked: (), lhs.rawValue << rhs)
}

/// Right shift a tagged value by a cardinal amount.
@inlinable
public func >> <Tag, RawValue: FixedWidthInteger>(
    lhs: Tagged<Tag, RawValue>,
    rhs: some Cardinal.`Protocol`
) -> Tagged<Tag, RawValue> {
    Tagged(__unchecked: (), lhs.rawValue >> rhs)
}

/// Left shift assignment of a tagged value by a cardinal amount.
@inlinable
public func <<= <Tag, RawValue: FixedWidthInteger>(
    lhs: inout Tagged<Tag, RawValue>,
    rhs: some Cardinal.`Protocol`
) {
    lhs = lhs << rhs
}

/// Right shift assignment of a tagged value by a cardinal amount.
@inlinable
public func >>= <Tag, RawValue: FixedWidthInteger>(
    lhs: inout Tagged<Tag, RawValue>,
    rhs: some Cardinal.`Protocol`
) {
    lhs = lhs >> rhs
}

// MARK: - Compound Assignment

/// Bitwise AND assignment.
@inlinable
public func &= <Tag, RawValue: FixedWidthInteger>(
    lhs: inout Tagged<Tag, RawValue>,
    rhs: Tagged<Tag, RawValue>
) {
    lhs = lhs & rhs
}

/// Bitwise AND assignment with raw value.
@inlinable
public func &= <Tag, RawValue: FixedWidthInteger>(
    lhs: inout Tagged<Tag, RawValue>,
    rhs: RawValue
) {
    lhs = lhs & rhs
}

/// Bitwise OR assignment.
@inlinable
public func |= <Tag, RawValue: FixedWidthInteger>(
    lhs: inout Tagged<Tag, RawValue>,
    rhs: Tagged<Tag, RawValue>
) {
    lhs = lhs | rhs
}

/// Bitwise OR assignment with raw value.
@inlinable
public func |= <Tag, RawValue: FixedWidthInteger>(
    lhs: inout Tagged<Tag, RawValue>,
    rhs: RawValue
) {
    lhs = lhs | rhs
}

/// Bitwise XOR assignment.
@inlinable
public func ^= <Tag, RawValue: FixedWidthInteger>(
    lhs: inout Tagged<Tag, RawValue>,
    rhs: Tagged<Tag, RawValue>
) {
    lhs = lhs ^ rhs
}

/// Bitwise XOR assignment with raw value.
@inlinable
public func ^= <Tag, RawValue: FixedWidthInteger>(
    lhs: inout Tagged<Tag, RawValue>,
    rhs: RawValue
) {
    lhs = lhs ^ rhs
}

/// Left shift assignment.
@inlinable
public func <<= <Tag, RawValue: FixedWidthInteger>(
    lhs: inout Tagged<Tag, RawValue>,
    rhs: Int
) {
    lhs = lhs << rhs
}

/// Right shift assignment.
@inlinable
public func >>= <Tag, RawValue: FixedWidthInteger>(
    lhs: inout Tagged<Tag, RawValue>,
    rhs: Int
) {
    lhs = lhs >> rhs
}

// MARK: - Comparison with Zero (for flag checking)

/// Check if a tagged value is non-zero (useful after bitwise AND for flag checking).
extension Tagged where RawValue: FixedWidthInteger {
    /// Returns `true` if the value is non-zero.
    @inlinable
    public var isNonZero: Bool {
        rawValue != 0
    }

    /// Returns `true` if the value is zero.
    @inlinable
    public var isZero: Bool {
        rawValue == 0
    }
}
