// Binary.Optionator Tests.swift
// swift-binary-primitives
//
// Tests for optional-producing arithmetic operators.

import Testing
@testable import Binary_Primitives

// MARK: - Addition Operator Tests

@Suite("Optionator +?")
struct OptionalAdditionTests {

    @Test("addition succeeds without overflow")
    func additionSucceeds() {
        let a: Int? = 5
        let b: Int? = 10
        #expect(a +? b == 15)
    }

    @Test("addition returns nil on overflow")
    func additionOverflows() {
        let a: Int? = Int.max
        let b: Int? = 1
        #expect(a +? b == nil)
    }

    @Test("addition returns nil when lhs is nil")
    func additionNilLhs() {
        let a: Int? = nil
        let b: Int? = 10
        #expect(a +? b == nil)
    }

    @Test("addition returns nil when rhs is nil")
    func additionNilRhs() {
        let a: Int? = 5
        let b: Int? = nil
        #expect(a +? b == nil)
    }

    @Test("addition returns nil when both nil")
    func additionBothNil() {
        let a: Int? = nil
        let b: Int? = nil
        #expect(a +? b == nil)
    }

    @Test("addition with non-optional lhs")
    func additionNonOptionalLhs() {
        let a: Int = 5
        let b: Int? = 10
        #expect(a +? b == 15)
    }

    @Test("addition with non-optional rhs")
    func additionNonOptionalRhs() {
        let a: Int? = 5
        let b: Int = 10
        #expect(a +? b == 15)
    }

    @Test("addition works with UInt8")
    func additionUInt8() {
        let a: UInt8? = 200
        let b: UInt8? = 55
        #expect(a +? b == 255)

        let c: UInt8? = 200
        let d: UInt8? = 56
        #expect(c +? d == nil)  // 256 overflows
    }
}

// MARK: - Subtraction Operator Tests

@Suite("Optionator -?")
struct OptionalSubtractionTests {

    @Test("subtraction succeeds without underflow")
    func subtractionSucceeds() {
        let a: Int? = 10
        let b: Int? = 5
        #expect(a -? b == 5)
    }

    @Test("subtraction returns nil on underflow")
    func subtractionUnderflows() {
        let a: Int? = Int.min
        let b: Int? = 1
        #expect(a -? b == nil)
    }

    @Test("unsigned subtraction returns nil on underflow")
    func unsignedSubtractionUnderflows() {
        let a: UInt? = 5
        let b: UInt? = 10
        #expect(a -? b == nil)
    }

    @Test("subtraction returns nil when operand is nil")
    func subtractionNilOperand() {
        let a: Int? = nil
        let b: Int? = 5
        #expect(a -? b == nil)

        let c: Int? = 10
        let d: Int? = nil
        #expect(c -? d == nil)
    }
}

// MARK: - Multiplication Operator Tests

@Suite("Optionator *?")
struct OptionalMultiplicationTests {

    @Test("multiplication succeeds without overflow")
    func multiplicationSucceeds() {
        let a: Int? = 100
        let b: Int? = 200
        #expect(a *? b == 20000)
    }

    @Test("multiplication returns nil on overflow")
    func multiplicationOverflows() {
        let a: Int? = Int.max
        let b: Int? = 2
        #expect(a *? b == nil)
    }

    @Test("multiplication by zero succeeds")
    func multiplicationByZero() {
        let a: Int? = Int.max
        let b: Int? = 0
        #expect(a *? b == 0)
    }

    @Test("multiplication returns nil when operand is nil")
    func multiplicationNilOperand() {
        let a: Int? = nil
        let b: Int? = 5
        #expect(a *? b == nil)
    }

    @Test("width times height pattern")
    func widthTimesHeight() {
        let width: UInt32? = 4096
        let height: UInt32? = 4096
        let pixelCount = width *? height
        #expect(pixelCount == 16777216)

        let bigWidth: UInt32? = 100000
        let bigHeight: UInt32? = 100000
        let overflow = bigWidth *? bigHeight
        #expect(overflow == nil)
    }
}

// MARK: - Division Operator Tests

@Suite("Optionator /?")
struct OptionalDivisionTests {

    @Test("division succeeds")
    func divisionSucceeds() {
        let a: Int? = 100
        let b: Int? = 5
        #expect(a /? b == 20)
    }

    @Test("division by zero returns nil")
    func divisionByZero() {
        let a: Int? = 100
        let b: Int? = 0
        #expect(a /? b == nil)
    }

    @Test("division returns nil when operand is nil")
    func divisionNilOperand() {
        let a: Int? = nil
        let b: Int? = 5
        #expect(a /? b == nil)

        let c: Int? = 100
        let d: Int? = nil
        #expect(c /? d == nil)
    }

    @Test("Int.min divided by -1 returns nil")
    func minDividedByNegativeOne() {
        let a: Int? = Int.min
        let b: Int? = -1
        #expect(a /? b == nil)  // Would overflow
    }
}

// MARK: - Remainder Operator Tests

@Suite("Optionator %?")
struct OptionalRemainderTests {

    @Test("remainder succeeds")
    func remainderSucceeds() {
        let a: Int? = 17
        let b: Int? = 5
        #expect(a %? b == 2)
    }

    @Test("remainder by zero returns nil")
    func remainderByZero() {
        let a: Int? = 17
        let b: Int? = 0
        #expect(a %? b == nil)
    }

    @Test("remainder returns nil when operand is nil")
    func remainderNilOperand() {
        let a: Int? = nil
        let b: Int? = 5
        #expect(a %? b == nil)
    }
}

// MARK: - Negation Operator Tests

@Suite("Optionator -? prefix")
struct OptionalNegationTests {

    @Test("negation succeeds")
    func negationSucceeds() {
        let a: Int? = 42
        #expect(-?a == -42)

        let b: Int? = -42
        #expect(-?b == 42)
    }

    @Test("negation of Int.min returns nil")
    func negationOfMinReturnsNil() {
        let a: Int? = Int.min
        #expect(-?a == nil)
    }

    @Test("negation of nil returns nil")
    func negationOfNilReturnsNil() {
        let a: Int? = nil
        #expect(-?a == nil)
    }

    @Test("negation of zero succeeds")
    func negationOfZero() {
        let a: Int? = 0
        #expect(-?a == 0)
    }
}

// MARK: - Assignment Operator Tests

@Suite("Optionator Assignment")
struct OptionalAssignmentTests {

    @Test("+?= assignment succeeds")
    func addAssignmentSucceeds() {
        var a: Int? = 5
        a +?= 10
        #expect(a == 15)
    }

    @Test("+?= assignment returns nil on overflow")
    func addAssignmentOverflows() {
        var a: Int? = Int.max
        a +?= 1
        #expect(a == nil)
    }

    @Test("-?= assignment succeeds")
    func subAssignmentSucceeds() {
        var a: Int? = 10
        a -?= 3
        #expect(a == 7)
    }

    @Test("*?= assignment succeeds")
    func mulAssignmentSucceeds() {
        var a: Int? = 5
        a *?= 4
        #expect(a == 20)
    }

    @Test("/?= assignment succeeds")
    func divAssignmentSucceeds() {
        var a: Int? = 20
        a /?= 4
        #expect(a == 5)
    }

    @Test("/?= assignment by zero returns nil")
    func divAssignmentByZero() {
        var a: Int? = 20
        a /?= 0
        #expect(a == nil)
    }

    @Test("%?= assignment succeeds")
    func modAssignmentSucceeds() {
        var a: Int? = 17
        a %?= 5
        #expect(a == 2)
    }

    @Test("chained assignments")
    func chainedAssignments() {
        var a: Int? = 10
        a +?= 5
        a *?= 2
        a -?= 10
        #expect(a == 20)
    }

    @Test("nil propagates through assignments")
    func nilPropagates() {
        var a: Int? = Int.max
        a +?= 1  // Overflow, becomes nil
        a +?= 5  // Still nil
        #expect(a == nil)
    }
}

// MARK: - Range Operator Tests

@Suite("Optionator Range")
struct OptionalRangeTests {

    @Test("..<? creates range when valid")
    func halfOpenRangeValid() {
        let start: Int? = 0
        let end: Int? = 10
        let range = start ..<? end
        #expect(range == 0..<10)
    }

    @Test("..<? returns nil when start >= end")
    func halfOpenRangeInvalid() {
        let start: Int? = 10
        let end: Int? = 5
        #expect(start ..<? end == nil)

        let same: Int? = 5
        #expect(same ..<? same == nil)
    }

    @Test("..<? returns nil when operand is nil")
    func halfOpenRangeNil() {
        let start: Int? = nil
        let end: Int? = 10
        #expect(start ..<? end == nil)

        let s: Int? = 0
        let e: Int? = nil
        #expect(s ..<? e == nil)
    }

    @Test("...? creates closed range when valid")
    func closedRangeValid() {
        let start: Int? = 0
        let end: Int? = 10
        let range = start ...? end
        #expect(range == 0...10)
    }

    @Test("...? returns nil when start > end")
    func closedRangeInvalid() {
        let start: Int? = 10
        let end: Int? = 5
        #expect(start ...? end == nil)
    }

    @Test("...? succeeds when start == end")
    func closedRangeSameValue() {
        let val: Int? = 5
        #expect(val ...? val == 5...5)
    }

    @Test("...? returns nil when operand is nil")
    func closedRangeNil() {
        let start: Int? = nil
        let end: Int? = 10
        #expect(start ...? end == nil)
    }
}

// MARK: - Integration Tests

@Suite("Optionator Integration")
struct OptionalOperatorIntegrationTests {

    @Test("image buffer size calculation")
    func imageBufferSizeCalculation() {
        func calculateBufferSize(width: UInt32?, height: UInt32?, bytesPerPixel: UInt32?) -> UInt32? {
            width *? height *? bytesPerPixel
        }

        #expect(calculateBufferSize(width: 1920, height: 1080, bytesPerPixel: 4) == 8294400)
        #expect(calculateBufferSize(width: 100000, height: 100000, bytesPerPixel: 4) == nil)
        #expect(calculateBufferSize(width: nil, height: 1080, bytesPerPixel: 4) == nil)
    }

    @Test("offset calculation with bounds check")
    func offsetCalculation() {
        func safeOffset(base: Int?, offset: Int?) -> Swift.Range<Int>? {
            guard let start = base, let length = offset else { return nil }
            let end = start +? length
            return start ..<? end
        }

        #expect(safeOffset(base: 100, offset: 50) == 100..<150)
        #expect(safeOffset(base: Int.max - 10, offset: 20) == nil)
        #expect(safeOffset(base: Optional<Int>.none, offset: 50) == nil)
    }
}
