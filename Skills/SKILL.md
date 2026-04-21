---
name: binary-primitives
description: |
  Binary buffer and cursor primitives with lifetime-dependent borrowing.
  ALWAYS apply when working with binary data, buffers, or memory-safe parsing.

layer: implementation

requires:
  - primitives
  - memory
  - naming

applies_to:
  - swift
  - swift-primitives
  - swift-binary-primitives
---

# Binary Primitives

Memory-safe binary buffer and cursor primitives with strict lifetime tracking.

---

## Core Design Decisions

### [BIN-001] Lifetime-Dependent Cursors

**Statement**: Cursors MUST be lifetime-dependent on their source buffer.

```swift
public struct Binary.Cursor: ~Escapable {
    @_lifetime(borrow buffer)
    init(borrowing buffer: Binary.Buffer) { ... }
}
```

### [BIN-002] Borrowing Over Copying

**Statement**: Buffer access MUST prefer borrowing semantics over copying.

```swift
// CORRECT - borrowing cursor, no copy
func process(_ cursor: borrowing Binary.Cursor) { ... }

// INCORRECT - copying data
func process(_ data: [UInt8]) { ... }
```

### [BIN-003] Strict Memory Safety

**Statement**: Binary primitives MUST enable `.strictMemorySafety()`.

```swift
.target(name: "Binary Primitives", swiftSettings: [.strictMemorySafety()])
```

### [BIN-004] Span-Based Interface

**Statement**: Primary interface MUST use `Span` for contiguous access.

```swift
var span: Span<UInt8> {
    @_lifetime(borrow self) borrowing get { ... }
}
```

---

## Type Hierarchy

```
Binary
├── .Buffer              // Owned binary storage
│   ├── .Inline<N>       // Stack-allocated
│   └── .Heap            // Heap-allocated
├── .Cursor              // Borrowing reader (~Escapable)
│   ├── .Reader          // Forward reading
│   └── .Writer          // Forward writing
└── .View                // Non-owning window
```

---

## Key Patterns

### Cursor Lifetime Binding

```swift
let buffer = Binary.Buffer(...)
buffer.withCursor { cursor in
    // cursor is ~Escapable, cannot escape this scope
    let value = cursor.read(UInt32.self)
}
```

### Span Access

```swift
let buffer: Binary.Buffer = ...
let span: Span<UInt8> = buffer.span
// span is lifetime-bound to buffer
```

### Memory-Safe Parsing

```swift
struct Parser {
    func parse(_ cursor: borrowing Binary.Cursor) throws(Parse.Error) -> Message {
        let header = cursor.read(Header.self)
        let payload = cursor.readBytes(header.length)
        return Message(header: header, payload: payload)
    }
}
```

---

## SE-0458 Strict Memory Safety

Binary primitives serve as the reference implementation for SE-0458 compliance.

| Category | Description | Action |
|----------|-------------|--------|
| Bucket A | Operations requiring `unsafe` | Mark with `unsafe` |
| Bucket B | Struct has unsafe storage | Audit marker only |

---

## Cross-References

| Topic | Skill |
|-------|-------|
| Memory safety | **memory** |
| Span patterns | **memory** [MEM-SPAN-001] |
| Pointer operations | **pointer-primitives** |

Full analysis: `Research/Lifetime Dependent Borrowed Cursors.md`
