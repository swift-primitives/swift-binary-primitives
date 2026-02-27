// Memory.Alignment+Binary.Position.swift
// Binary.Position-specific operations for Memory.Alignment.

// MARK: - Typed Position Operations

extension Memory.Alignment {
    /// Checks if a typed position is aligned.
    ///
    /// Computes the alignment check in the position's scalar ring.
    ///
    /// - Precondition: `shift < Scalar.bitWidth`
    public func isAligned<Scalar: FixedWidthInteger, Space>(
        _ value: Binary.Position<Scalar, Space>
    ) -> Bool {
        let mask: Scalar = shift.mask()
        return value.rawValue & mask == 0
    }

    /// Rounds a typed position up to the nearest alignment boundary.
    ///
    /// Computes the alignment in the position's scalar ring using overflow-safe operators.
    ///
    /// - Precondition: `shift < Scalar.bitWidth`
    public func alignUp<Scalar: FixedWidthInteger, Space>(
        _ value: Binary.Position<Scalar, Space>
    ) -> Binary.Position<Scalar, Space> {
        let mask: Scalar = shift.mask()
        return Binary.Position((value.rawValue &+ mask) & ~mask)
    }

    /// Rounds a typed position down to the nearest alignment boundary.
    ///
    /// Computes the alignment in the position's scalar ring using overflow-safe operators.
    ///
    /// - Precondition: `shift < Scalar.bitWidth`
    public func alignDown<Scalar: FixedWidthInteger, Space>(
        _ value: Binary.Position<Scalar, Space>
    ) -> Binary.Position<Scalar, Space> {
        let mask: Scalar = shift.mask()
        return Binary.Position(value.rawValue & ~mask)
    }
}

// MARK: - Typed Position Operations (Throwing)

extension Memory.Alignment {
    /// Checks if a typed position is aligned, with shift validation.
    ///
    /// - Throws: `Memory.Alignment.Error.shiftExceedsBitWidth` if shift >= scalar bit width.
    public func isAlignedThrowing<Scalar: FixedWidthInteger, Space>(
        _ value: Binary.Position<Scalar, Space>
    ) throws(Memory.Alignment.Error) -> Bool {
        guard Int(shift.rawValue) < Scalar.bitWidth else {
            throw .shiftExceedsBitWidth(shift: shift.rawValue, bitWidth: Scalar.bitWidth)
        }
        let mask: Scalar = shift.mask()
        return value.rawValue & mask == 0
    }

    /// Rounds a typed position up, with shift validation.
    ///
    /// - Throws: `Memory.Alignment.Error.shiftExceedsBitWidth` if shift >= scalar bit width.
    public func alignUpThrowing<Scalar: FixedWidthInteger, Space>(
        _ value: Binary.Position<Scalar, Space>
    ) throws(Memory.Alignment.Error) -> Binary.Position<Scalar, Space> {
        guard Int(shift.rawValue) < Scalar.bitWidth else {
            throw .shiftExceedsBitWidth(shift: shift.rawValue, bitWidth: Scalar.bitWidth)
        }
        let mask: Scalar = shift.mask()
        return Binary.Position((value.rawValue &+ mask) & ~mask)
    }

    /// Rounds a typed position down, with shift validation.
    ///
    /// - Throws: `Memory.Alignment.Error.shiftExceedsBitWidth` if shift >= scalar bit width.
    public func alignDownThrowing<Scalar: FixedWidthInteger, Space>(
        _ value: Binary.Position<Scalar, Space>
    ) throws(Memory.Alignment.Error) -> Binary.Position<Scalar, Space> {
        guard Int(shift.rawValue) < Scalar.bitWidth else {
            throw .shiftExceedsBitWidth(shift: shift.rawValue, bitWidth: Scalar.bitWidth)
        }
        let mask: Scalar = shift.mask()
        return Binary.Position(value.rawValue & ~mask)
    }
}
