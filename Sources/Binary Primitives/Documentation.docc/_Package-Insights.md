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

## Topics

### Related Documents

- <doc:Binary>
