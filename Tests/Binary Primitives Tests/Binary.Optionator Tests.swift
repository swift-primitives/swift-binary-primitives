// Binary.Optionator Tests.swift
// swift-binary-primitives
//
// Tests for optional-producing arithmetic operators.

import Testing

@testable import Binary_Primitives
import Binary_Primitives_Test_Support

// MARK: - Test Suites

/// Tests for Binary.Optionator - uses parallel namespace pattern
/// since this tests global operators.
@Suite("Binary.Optionator")
struct BinaryOptionatorTests {
    @Suite struct Unit {}
    @Suite struct EdgeCase {}
    @Suite struct Integration {}
    @Suite(.serialized) struct Performance {}
}

// MARK: - Unit Tests - Addition

extension BinaryOptionatorTests.Unit {

    @Test
    func `addition succeeds without overflow`() {
        let a: Int? = 5
        let b: Int? = 10
        #expect(a +? b == 15)
    }

    @Test
    func `addition with non-optional lhs`() {
        let a: Int = 5
        let b: Int? = 10
        #expect(a +? b == 15)
    }

    @Test
    func `addition with non-optional rhs`() {
        let a: Int? = 5
        let b: Int = 10
        #expect(a +? b == 15)
    }

    @Test
    func `addition works with UInt8`() {
        let a: UInt8? = 200
        let b: UInt8? = 55
        #expect(a +? b == 255)
    }

    @Test
    func `subtraction succeeds without underflow`() {
        let a: Int? = 10
        let b: Int? = 5
        #expect(a -? b == 5)
    }

    @Test
    func `multiplication succeeds without overflow`() {
        let a: Int? = 100
        let b: Int? = 200
        #expect(a *? b == 20000)
    }

    @Test
    func `multiplication by zero succeeds`() {
        let a: Int? = Int.max
        let b: Int? = 0
        #expect(a *? b == 0)
    }

    @Test
    func `division succeeds`() {
        let a: Int? = 100
        let b: Int? = 5
        #expect(a /? b == 20)
    }

    @Test
    func `remainder succeeds`() {
        let a: Int? = 17
        let b: Int? = 5
        #expect(a %? b == 2)
    }

    @Test
    func `negation succeeds`() {
        let a: Int? = 42
        #expect(-?a == -42)

        let b: Int? = -42
        #expect(-?b == 42)
    }

    @Test
    func `negation of zero succeeds`() {
        let a: Int? = 0
        #expect(-?a == 0)
    }

    @Test
    func `add assignment succeeds`() {
        var a: Int? = 5
        a +?= 10
        #expect(a == 15)
    }

    @Test
    func `subtract assignment succeeds`() {
        var a: Int? = 10
        a -?= 3
        #expect(a == 7)
    }

    @Test
    func `multiply assignment succeeds`() {
        var a: Int? = 5
        a *?= 4
        #expect(a == 20)
    }

    @Test
    func `divide assignment succeeds`() {
        var a: Int? = 20
        a /?= 4
        #expect(a == 5)
    }

    @Test
    func `remainder assignment succeeds`() {
        var a: Int? = 17
        a %?= 5
        #expect(a == 2)
    }

    @Test
    func `chained assignments`() {
        var a: Int? = 10
        a +?= 5
        a *?= 2
        a -?= 10
        #expect(a == 20)
    }

    @Test
    func `half open range creates range when valid`() {
        let start: Int? = 0
        let end: Int? = 10
        let range = start ..<? end
        #expect(range == 0..<10)
    }

    @Test
    func `closed range creates range when valid`() {
        let start: Int? = 0
        let end: Int? = 10
        let range = start ...? end
        #expect(range == 0...10)
    }

    @Test
    func `closed range succeeds when start equals end`() {
        let val: Int? = 5
        #expect(val ...? val == 5...5)
    }

    @Test
    func `width times height pattern`() {
        let width: UInt32? = 4096
        let height: UInt32? = 4096
        let pixelCount = width *? height
        #expect(pixelCount == 16777216)
    }
}

// MARK: - Edge Case Tests

extension BinaryOptionatorTests.EdgeCase {

    @Test
    func `addition returns nil on overflow`() {
        let a: Int? = Int.max
        let b: Int? = 1
        #expect(a +? b == nil)
    }

    @Test
    func `addition returns nil when lhs is nil`() {
        let a: Int? = nil
        let b: Int? = 10
        #expect(a +? b == nil)
    }

    @Test
    func `addition returns nil when rhs is nil`() {
        let a: Int? = 5
        let b: Int? = nil
        #expect(a +? b == nil)
    }

    @Test
    func `addition returns nil when both nil`() {
        let a: Int? = nil
        let b: Int? = nil
        #expect(a +? b == nil)
    }

    @Test
    func `addition with UInt8 returns nil on overflow`() {
        let c: UInt8? = 200
        let d: UInt8? = 56
        #expect(c +? d == nil)  // 256 overflows
    }

    @Test
    func `subtraction returns nil on underflow`() {
        let a: Int? = Int.min
        let b: Int? = 1
        #expect(a -? b == nil)
    }

    @Test
    func `unsigned subtraction returns nil on underflow`() {
        let a: UInt? = 5
        let b: UInt? = 10
        #expect(a -? b == nil)
    }

    @Test
    func `subtraction returns nil when operand is nil`() {
        let a: Int? = nil
        let b: Int? = 5
        #expect(a -? b == nil)

        let c: Int? = 10
        let d: Int? = nil
        #expect(c -? d == nil)
    }

    @Test
    func `multiplication returns nil on overflow`() {
        let a: Int? = Int.max
        let b: Int? = 2
        #expect(a *? b == nil)
    }

    @Test
    func `multiplication returns nil when operand is nil`() {
        let a: Int? = nil
        let b: Int? = 5
        #expect(a *? b == nil)
    }

    @Test
    func `width times height overflow returns nil`() {
        let bigWidth: UInt32? = 100000
        let bigHeight: UInt32? = 100000
        let overflow = bigWidth *? bigHeight
        #expect(overflow == nil)
    }

    @Test
    func `division by zero returns nil`() {
        let a: Int? = 100
        let b: Int? = 0
        #expect(a /? b == nil)
    }

    @Test
    func `division returns nil when operand is nil`() {
        let a: Int? = nil
        let b: Int? = 5
        #expect(a /? b == nil)

        let c: Int? = 100
        let d: Int? = nil
        #expect(c /? d == nil)
    }

    @Test
    func `Int.min divided by -1 returns nil`() {
        let a: Int? = Int.min
        let b: Int? = -1
        #expect(a /? b == nil)  // Would overflow
    }

    @Test
    func `remainder by zero returns nil`() {
        let a: Int? = 17
        let b: Int? = 0
        #expect(a %? b == nil)
    }

    @Test
    func `remainder returns nil when operand is nil`() {
        let a: Int? = nil
        let b: Int? = 5
        #expect(a %? b == nil)
    }

    @Test
    func `negation of Int.min returns nil`() {
        let a: Int? = Int.min
        #expect(-?a == nil)
    }

    @Test
    func `negation of nil returns nil`() {
        let a: Int? = nil
        #expect(-?a == nil)
    }

    @Test
    func `add assignment returns nil on overflow`() {
        var a: Int? = Int.max
        a +?= 1
        #expect(a == nil)
    }

    @Test
    func `divide assignment by zero returns nil`() {
        var a: Int? = 20
        a /?= 0
        #expect(a == nil)
    }

    @Test
    func `nil propagates through assignments`() {
        var a: Int? = Int.max
        a +?= 1  // Overflow, becomes nil
        a +?= 5  // Still nil
        #expect(a == nil)
    }

    @Test
    func `half open range returns nil when start >= end`() {
        let start: Int? = 10
        let end: Int? = 5
        #expect(start ..<? end == nil)

        let same: Int? = 5
        #expect(same ..<? same == nil)
    }

    @Test
    func `half open range returns nil when operand is nil`() {
        let start: Int? = nil
        let end: Int? = 10
        #expect(start ..<? end == nil)

        let s: Int? = 0
        let e: Int? = nil
        #expect(s ..<? e == nil)
    }

    @Test
    func `closed range returns nil when start > end`() {
        let start: Int? = 10
        let end: Int? = 5
        #expect(start ...? end == nil)
    }

    @Test
    func `closed range returns nil when operand is nil`() {
        let start: Int? = nil
        let end: Int? = 10
        #expect(start ...? end == nil)
    }
}

// MARK: - Integration Tests

extension BinaryOptionatorTests.Integration {

    @Test
    func `image buffer size calculation`() {
        func calculateBufferSize(width: UInt32?, height: UInt32?, bytesPerPixel: UInt32?) -> UInt32? {
            width *? height *? bytesPerPixel
        }

        #expect(calculateBufferSize(width: 1920, height: 1080, bytesPerPixel: 4) == 8294400)
        #expect(calculateBufferSize(width: 100000, height: 100000, bytesPerPixel: 4) == nil)
        #expect(calculateBufferSize(width: nil, height: 1080, bytesPerPixel: 4) == nil)
    }

    @Test
    func `offset calculation with bounds check`() {
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
