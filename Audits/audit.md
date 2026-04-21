# Audit: swift-binary-primitives

## Legacy — Consolidated 2026-04-08

### From: swift-institute/Research/audit-primitives.md (2026-04-03)

**Pre-publication dependency-tree audit — P0/P1/P2 checks**

#### P1: Compound Type Name [API-NAME-001]

**File**: `Sources/Binary Format Primitives/Binary.Format.Radix.swift:74`

```swift
public struct SignDisplayStrategy: Sendable {
```

Nested inside `Binary.Format.Radix` extension. Full path is `Binary.Format.Radix.SignDisplayStrategy`. Per [API-NAME-001], should be `Sign.Display.Strategy` or decomposed into nested namespaces.

---

### From: swift-institute/Research/audits/implementation-naming-2026-03-20/swift-binary-primitives.md (2026-03-20)

**Implementation + naming audit**

HIGH=9, MEDIUM=19, LOW=18, INFO=0
Finding IDs: BIN-001, BIN-002, BIN-003, BIN-004, BIN-005, BIN-006, BIN-007, BIN-008, BIN-009, BIN-010, BIN-011, BIN-012, BIN-013, BIN-014, BIN-015 (+10 more)
