// Bit.Order Tests.swift

import Testing

@testable import Binary_Primitives
import Binary_Primitives_Test_Support

// MARK: - Test Suites

/// Tests for Bit.Order type.
@Suite("Bit.Order")
struct BitOrderTests {
    @Suite struct Unit {}
    @Suite struct EdgeCase {}
    @Suite struct Integration {}
    @Suite(.serialized) struct Performance {}
}

// MARK: - Unit Tests

extension BitOrderTests.Unit {

    @Test
    func `cases are distinct`() {
        let msb: Bit.Order = .msb
        let lsb: Bit.Order = .lsb
        #expect(msb != lsb)
    }

    @Test
    func `opposite returns correct value`() {
        #expect(Bit.Order.msb.opposite == .lsb)
        #expect(Bit.Order.lsb.opposite == .msb)
    }

    @Test
    func `negation operator`() {
        #expect(!Bit.Order.msb == .lsb)
        #expect(!Bit.Order.lsb == .msb)
    }

    @Test
    func `CaseIterable conformance`() {
        #expect(Bit.Order.allCases.count == 2)
        #expect(Bit.Order.allCases.contains(.msb))
        #expect(Bit.Order.allCases.contains(.lsb))
    }

    @Test
    func `aliases`() {
        #expect(Bit.Order.`most significant bit first` == .msb)
        #expect(Bit.Order.`least significant bit first` == .lsb)
    }
}
