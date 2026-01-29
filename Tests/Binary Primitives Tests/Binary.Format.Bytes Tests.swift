// Binary.Format.Bytes Tests.swift

import Testing

import Binary_Primitives
import Binary_Primitives_Test_Support

// MARK: - Test Suites

/// Tests for Binary.Format.Bytes - non-generic type using type extension pattern per [TEST-003].
extension Binary.Format.Bytes {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
        @Suite struct Integration {}
        @Suite(.serialized) struct Performance {}
    }
}

// MARK: - Unit Tests

extension Binary.Format.Bytes.Test.Unit {

    // MARK: - Basic Decimal Formatting

    @Test
    func `basic byte formatting`() {
        #expect(0.formatted(Binary.Format.bytes) == "0 B")
        #expect(512.formatted(Binary.Format.bytes) == "512 B")
        #expect(999.formatted(Binary.Format.bytes) == "999 B")
    }

    @Test
    func `kilobyte formatting`() {
        #expect(1000.formatted(Binary.Format.bytes) == "1 KB")
        #expect(1500.formatted(Binary.Format.bytes) == "1.5 KB")
        #expect(500_000.formatted(Binary.Format.bytes) == "500 KB")
    }

    @Test
    func `megabyte formatting`() {
        #expect(1_000_000.formatted(Binary.Format.bytes) == "1 MB")
        #expect(1_500_000.formatted(Binary.Format.bytes) == "1.5 MB")
        #expect(500_000_000.formatted(Binary.Format.bytes) == "500 MB")
    }

    @Test
    func `gigabyte formatting`() {
        #expect(1_000_000_000.formatted(Binary.Format.bytes) == "1 GB")
        #expect(1_500_000_000.formatted(Binary.Format.bytes) == "1.5 GB")
    }

    @Test
    func `terabyte formatting`() {
        #expect(1_000_000_000_000.formatted(Binary.Format.bytes) == "1 TB")
        #expect(2_500_000_000_000.formatted(Binary.Format.bytes) == "2.5 TB")
    }

    // MARK: - Binary Unit Formatting

    @Test
    func `binary unit formatting`() {
        #expect(1024.formatted(Binary.Format.bytes(.binary)) == "1 KiB")
        #expect(1536.formatted(Binary.Format.bytes(.binary)) == "1.5 KiB")
        #expect(1_048_576.formatted(Binary.Format.bytes(.binary)) == "1 MiB")
        #expect(1_073_741_824.formatted(Binary.Format.bytes(.binary)) == "1 GiB")
    }

    @Test
    func `decimal vs binary difference`() {
        // 1024 bytes shows different values in each system
        #expect(1024.formatted(Binary.Format.bytes(.decimal)) == "1.02 KB")
        #expect(1024.formatted(Binary.Format.bytes(.binary)) == "1 KiB")

        // 1000 bytes
        #expect(1000.formatted(Binary.Format.bytes(.decimal)) == "1 KB")
        #expect(1000.formatted(Binary.Format.bytes(.binary)) == "1000 B")
    }

    // MARK: - Precision Control

    @Test
    func `precision formatting`() {
        #expect(1536.formatted(Binary.Format.bytes.precision(0)) == "2 KB")
        #expect(1536.formatted(Binary.Format.bytes.precision(1)) == "1.5 KB")
        #expect(1536.formatted(Binary.Format.bytes.precision(2)) == "1.54 KB")
        #expect(1536.formatted(Binary.Format.bytes.precision(3)) == "1.536 KB")
    }

    @Test
    func `auto precision strips trailing zeros`() {
        #expect(1000.formatted(Binary.Format.bytes) == "1 KB")
        #expect(1100.formatted(Binary.Format.bytes) == "1.1 KB")
        #expect(1120.formatted(Binary.Format.bytes) == "1.12 KB")
    }

    // MARK: - Notation Styles

    @Test
    func `spaced notation`() {
        #expect(1024.formatted(Binary.Format.bytes.notation(.spaced)) == "1.02 KB")
        #expect(1_000_000.formatted(Binary.Format.bytes.notation(.spaced)) == "1 MB")
    }

    @Test
    func `compact notation`() {
        #expect(1024.formatted(Binary.Format.bytes.notation(.compactName)) == "1.02KB")
        #expect(1_000_000.formatted(Binary.Format.bytes.notation(.compactName)) == "1MB")
    }

    // MARK: - Chaining

    @Test
    func `chained configuration`() {
        let format = Binary.Format.Bytes.bytes(.binary).precision(2).notation(.compactName)
        #expect(1536.formatted(format) == "1.50KiB")
    }

    @Test
    func `units via function`() {
        #expect(1024.formatted(Binary.Format.bytes(.binary)) == "1 KiB")
        #expect(1024.formatted(Binary.Format.bytes(.decimal)) == "1.02 KB")
    }

    @Test
    func `units via chaining`() {
        #expect(1024.formatted(Binary.Format.bytes.units(.binary)) == "1 KiB")
        #expect(1024.formatted(Binary.Format.bytes.units(.decimal)) == "1.02 KB")
    }

    // MARK: - Without Unit

    @Test
    func `without unit suffix`() {
        #expect(1024.formatted(Binary.Format.bytes.withoutUnit()) == "1.02")
        #expect(1_000_000.formatted(Binary.Format.bytes.withoutUnit()) == "1")
    }

    // MARK: - Different Integer Types

    @Test
    func `various integer types`() {
        #expect(UInt8(255).formatted(Binary.Format.bytes) == "255 B")
        #expect(Int16(1000).formatted(Binary.Format.bytes) == "1 KB")
        #expect(UInt32(1_000_000).formatted(Binary.Format.bytes) == "1 MB")
        #expect(Int64(1_000_000_000).formatted(Binary.Format.bytes) == "1 GB")
    }
}

// MARK: - Edge Case Tests

extension Binary.Format.Bytes.Test.EdgeCase {

    @Test
    func `zero bytes`() {
        #expect(0.formatted(Binary.Format.bytes) == "0 B")
        #expect(0.formatted(Binary.Format.bytes(.binary)) == "0 B")
    }

    @Test
    func `negative bytes`() {
        #expect((-1024).formatted(Binary.Format.bytes) == "-1.02 KB")
        #expect((-1024).formatted(Binary.Format.bytes(.binary)) == "-1 KiB")
    }

    @Test
    func `large values`() {
        #expect(1_000_000_000_000_000.formatted(Binary.Format.bytes) == "1 PB")
        #expect(1_125_899_906_842_624.formatted(Binary.Format.bytes(.binary)) == "1 PiB")
    }
}
