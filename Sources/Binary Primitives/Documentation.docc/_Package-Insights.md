# Binary Primitives Insights

<!--
---
title: Binary Primitives Insights
version: 1.0.0
last_updated: 2026-01-19
applies_to: [swift-binary-primitives]
normative: false
---
-->

@Metadata {
    @TitleHeading("Binary Primitives")
}

Design decisions, implementation patterns, and lessons learned specific to this package.

## Overview

This document captures insights that emerged during development of swift-binary-primitives. These are not API requirements—they are recorded decisions and patterns that inform future work on this package.

**Document type**: Non-normative (recorded decisions, not requirements).

**Consolidation source**: Reflection entries tagged with `[Package: swift-binary-primitives]`.

---

## The Non-Closure Runner Surface as Structural Necessity

**Date**: 2026-01-19

**Context**: Implementing zero-copy borrowed parsing APIs with `~Escapable` input views, discovering that the "protocol approach" isn't a stylistic choice—it's the only valid design under Swift 6.x.

### The Constraint Triangle

You cannot simultaneously have:

1. **Reuse existing combinators** (`Parsing.Parser` infrastructure)
2. **Keep `Input.View` `~Escapable`** (compile-time lifetime safety)
3. **Keep zero-copy borrowed parsing** (no copying)

Swift 6.x does not allow `~Escapable` constraints on protocol associated types. This means `Binary.Bytes.Input.View` (which is Span-backed and `~Escapable`) cannot participate in `Parsing.Parser`'s combinator infrastructure.

### Structural Requirement, Not Workaround

If `Input.View` is `~Escapable`, then some non-closure, non-associated-type dispatch mechanism is **structurally required**. Whether you call it a protocol, a generic struct with a parse method, or a functor—the shape is unavoidable.

Method invocation (not closure capture) is the only way to pass `~Escapable` values under current Swift.

### The Unacceptable Path

Using the owned `Binary.Bytes.Input` (which copies) as the "borrowed" API is unacceptable. The borrowed path must be truly borrowed:

- `withInput`: Exists for owned/copying semantics
- `withBorrowed`: Must deliver true zero-copy

Any design that makes copying the canonical borrowed path has failed the API's stated purpose.

**Applies to**: `Binary.Bytes.Parser` protocol, `Binary.Bytes.withBorrowed` runner.

---

## Two Canonical Worlds as Architectural Settlement

**Date**: 2026-01-19

**Context**: Designing the relationship between `Parsing.Parser` (owned) and `Binary.Bytes.Parser` (borrowed) protocols.

### The Two Worlds

| World | Input Type | Protocol | Safety | Performance |
|-------|-----------|----------|--------|-------------|
| **Owned** | `Binary.Bytes.Input` | `Parsing.Parser` | Runtime contract | Copies on non-array inputs |
| **Borrowed** | `Binary.Bytes.Input.View` | `Binary.Bytes.Parser` | Compile-time enforced | True zero-copy |

Neither world is superior. Each serves different use cases:

- **Owned**: Cross-task transfer, storage, combinator composition via `Parsing.Parser`
- **Borrowed**: Maximum performance in scoped parsing, compile-time lifetime guarantees

### Reuse Strategies

Two paths preserve combinator reuse across the two worlds:

**Strategy 1: Bridge Layer**
Keep `Parsing.Parser` for owned inputs. Introduce bridge combinators that wrap owned parsers for borrowed execution—copying occurs at explicit bridge points.

**Strategy 2: Defunctionalized Machine Execution**
Build a `BorrowedProgram` that interprets node graphs against `Input.View` directly, never putting `~Escapable` into an associated type position. Heavier to implement, but avoids new protocol surface.

Recommendation: Strategy 1 for simplicity. Strategy 2 for high-performance recursive grammars on borrowed input.

### Why This Is Not Compromise

The two-world model isn't a compromise with Swift's limitations—it's architecturally correct. Owned and borrowed inputs have genuinely different semantics:

- Owned inputs can be stored, transferred across tasks, used in recursive data structures
- Borrowed inputs are scoped, cannot outlive their source, enable zero-copy

Pretending they're the same (by making everything owned, or by unsafe escape hatches) creates worse code than honest separation.

**Applies to**: Package architecture, `Binary.Bytes.Parser` vs `Parsing.Parser` design.

---

## The ~Escapable Closure Integration Gap

**Date**: 2026-01-19

**Context**: Understanding why closure-based APIs fundamentally cannot work with `~Escapable` types in Swift 6.x.

### The Structural Limitation

Swift 6.x's lifetime checker cannot reason about `~Escapable` values passed to closure parameters—even `@noescape` closures. When you write `withBorrowed { view in ... }` where `view` is `~Escapable`, the compiler sees a potential escape through the closure boundary.

This extends to:
- Protocol witness methods
- Generic function calls
- Any function boundary crossing

The compiler's dataflow analysis cannot currently prove that a `~Escapable` value remains within its parent's lifetime when crossing these boundaries.

### The Fundamental Tension

The ergonomic API shape (`withSomething { borrowed in ... }`) is exactly the shape Swift 6.x rejects for `~Escapable` types. You cannot have both lifetime safety via `~Escapable` AND closure-based APIs. One must yield.

### Design Implication

Any type holding a `Span` (or otherwise `~Escapable`) must be designed with this constraint from the start. Retrofit is painful. The defunctionalized Machine pattern emerged as the escape hatch—but it requires architectural commitment, not a local fix.

**Applies to**: All API design involving `Binary.Bytes.Input.View` or any `~Escapable` type.

---

## Defunctionalization: The Machine Interpreter Pattern

**Date**: 2026-01-19

**Context**: Implementing Strategy 2 ("Defunctionalized Machine Execution") from the Two Worlds architecture.

### The Pattern

When closures cannot receive `~Escapable` values, represent computation as data instead. A "parser" becomes an instruction program (`Machine.Instruction`, `Machine.Node`, `Machine.Program`). The interpreter runs entirely within a single lexical scope that owns the `~Escapable` cursor.

Key insight: user code never receives the borrowed view. Users build programs (data); the interpreter consumes them. The view exists only inside `withBorrowed`, invisible to callers.

### The Cost

This is not free:
- **Closed-world instruction set**: Every parsing primitive must be an `Instruction` case
- **Type-erased storage**: The arena holds `Value` boxes, not typed results
- **Runtime overhead**: Switch dispatch per instruction
- **Implementation complexity**: Frames, backtracking, transforms

The alternative—abandoning `~Escapable` for `UnsafeBufferPointer`—throws away the endgame. The machine is the price of lifetime safety.

### When to Use

Defunctionalization is warranted when:
1. A `~Escapable` type must be consumed
2. Consumption logic is complex (not just "read N bytes")
3. Users need composable operations (sequence, choice, repetition)

For simple cases, inline consumption directly. The machine is for parser combinators, not one-off reads.

**Applies to**: `Binary.Bytes.Machine.*` infrastructure, `withBorrowed` API.

---

## The Temporary Parent Problem

**Date**: 2026-01-19

**Context**: Debugging "lifetime-dependent variable escapes its scope" errors in the Machine interpreter.

### The Misleading Diagnostic

The error message is precise but misleading:
```
lifetime-dependent variable 'view' escapes its scope
note: it depends on the lifetime of this parent value
note: this use of the lifetime-dependent value is out of scope
```

The "use out of scope" note points to a line deep in the interpreter—tempting you to fix that line. But the problem is at construction: `Input.View(bytes.span)` creates a view whose parent is `bytes.span` (a temporary expression), not `bytes` itself.

### Why It Manifests Deep in Control Flow

The compiler optimistically extends temporary lifetimes through simple control flow. But when the interpreter has `while true { switch { switch { while { ... } } } }`, the dataflow analysis gives up. The temporary's lifetime isn't extended through that complexity.

### The Fix Pattern

Establish an explicit scope where backing storage is unambiguously alive:

```swift
try bytes.withUnsafeBufferPointer { buffer throws(Machine.Fault) in
    let span = Span(buffer)
    var view = Input.View(span)
    // interpreter here
}
```

The closure parameter `buffer` has clear, lexical lifetime. The span borrows from it. The view borrows from the span. No temporaries; no ambiguity.

**Applies to**: `withBorrowed(_:_:)` implementation, any code constructing `Input.View` from arrays.

---

## Protocol-Mandated Lifetime Annotations

**Date**: 2026-01-19

**Context**: Understanding why the `Binary.Contiguous` overload worked without `withUnsafeBufferPointer` while `[UInt8]` required it.

### The Contrast

The `[UInt8]` overload needed `withUnsafeBufferPointer` to fix the temporary parent problem. The `Binary.Contiguous` overload did not. Why?

`Binary.Contiguous.bytes` has a documented requirement:
> Conformers must use `@_lifetime(borrow self)` on the getter.

When `source.bytes` returns a `Span<UInt8>` with this annotation, the span's lifetime is tied to the borrow of `source`—not to a temporary expression. Since `source` is `borrowing C` and lives for the entire function body, the span's lifetime extends accordingly.

### Design Principle

Protocol requirements can mandate lifetime safety. If `Array.span` in the stdlib had `@_lifetime(borrow self)`, the `withUnsafeBufferPointer` workaround would be unnecessary.

When designing protocols that vend borrowed references, explicitly require lifetime annotations in documentation. Make it a conformance contract, not an optional optimization. Conformers who violate it will fail to compile—that's the point.

**Applies to**: `Binary.Contiguous` protocol design, any protocol returning `Span` or borrowed references.

---

## Typed Throws Preservation Through Closure Boundaries

**Date**: 2026-01-19

**Context**: The `withUnsafeBufferPointer` call erasing `throws(Machine.Fault)` to `any Error`, and the fix.

### The Problem

The stdlib's `withUnsafeBufferPointer(_:)` uses `rethrows`, designed before typed throws. When you `try body()` inside a `rethrows` closure, the error type erases to `any Error`.

### The Solution

The typed-throws-preserving extension in `Standard_Library_Extensions` (per [API-ERR-007]) provides the fix. At the call site, explicitly annotate the closure:

```swift
try bytes.withUnsafeBufferPointer { buffer throws(Machine.Fault) in
    // ...
}
```

The explicit `throws(Machine.Fault)` tells the compiler what error type to expect. Without it, type inference fails.

> **Cross-reference**: See [API-ERR-007] Typed Throws Closure Annotation in Swift Institute API Errors documentation.

**Applies to**: `withBorrowed` implementation, any code using stdlib `withUnsafe*` methods with typed throws.

---

## Topics

### Related Documents

- <doc:Binary>
