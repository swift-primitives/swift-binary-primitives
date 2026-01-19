// Binary.Bytes.Machine.Combinators.swift
// Combinator API for building machine programs

// MARK: - Instruction Expressions

extension Binary.Bytes.Machine {
    /// Creates an expression for the take1 instruction.
    @inlinable
    public static func take1(
        in builder: inout Builder
    ) -> Expression<UInt8> {
        let node = Node.leaf(.take1)
        let nodeID = builder.allocate(node)
        return Expression(node: nodeID)
    }

    /// Creates an expression for taking n bytes.
    @inlinable
    public static func take(
        _ n: Int,
        in builder: inout Builder
    ) -> Expression<[UInt8]> {
        let node = Node.leaf(.take(n))
        let nodeID = builder.allocate(node)
        return Expression(node: nodeID)
    }

    /// Creates an expression for skipping n bytes.
    @inlinable
    public static func skip(
        _ n: Int,
        in builder: inout Builder
    ) -> Expression<Void> {
        let node = Node.leaf(.skip(n))
        let nodeID = builder.allocate(node)
        return Expression(node: nodeID)
    }

    /// Creates an expression for matching a specific byte.
    @inlinable
    public static func byte(
        _ expected: UInt8,
        in builder: inout Builder
    ) -> Expression<UInt8> {
        let node = Node.leaf(.byte(expected))
        let nodeID = builder.allocate(node)
        return Expression(node: nodeID)
    }

    /// Creates an expression for matching a byte sequence.
    @inlinable
    public static func bytes(
        _ expected: [UInt8],
        in builder: inout Builder
    ) -> Expression<[UInt8]> {
        let node = Node.leaf(.bytes(expected))
        let nodeID = builder.allocate(node)
        return Expression(node: nodeID)
    }

    /// Creates an expression for matching end of input.
    @inlinable
    public static func end(
        in builder: inout Builder
    ) -> Expression<Void> {
        let node = Node.leaf(.end)
        let nodeID = builder.allocate(node)
        return Expression(node: nodeID)
    }

    /// Creates an expression for u32 little-endian.
    @inlinable
    public static func u32le(
        in builder: inout Builder
    ) -> Expression<UInt32> {
        let node = Node.leaf(.u32le)
        let nodeID = builder.allocate(node)
        return Expression(node: nodeID)
    }

    /// Creates an expression for u32 big-endian.
    @inlinable
    public static func u32be(
        in builder: inout Builder
    ) -> Expression<UInt32> {
        let node = Node.leaf(.u32be)
        let nodeID = builder.allocate(node)
        return Expression(node: nodeID)
    }
}

// MARK: - Pure

extension Binary.Bytes.Machine {
    /// Creates a pure expression that always succeeds with the given value.
    @inlinable
    public static func pure<Output>(
        _ value: Output,
        in builder: inout Builder
    ) -> Expression<Output> {
        let node = Node.pure(Value.make(value))
        let nodeID = builder.allocate(node)
        return Expression(node: nodeID)
    }
}

// MARK: - Map

extension Binary.Bytes.Machine.Expression {
    /// Transforms the output of this expression.
    @inlinable
    public func map<T>(
        _ transform: @escaping (Output) -> T,
        in builder: inout Binary.Bytes.Machine.Builder
    ) -> Binary.Bytes.Machine.Expression<T> {
        let node = Binary.Bytes.Machine.Node.map(
            child: self.node,
            transform: Binary.Bytes.Machine.Transform.Erased(transform)
        )
        let nodeID = builder.allocate(node)
        return Binary.Bytes.Machine.Expression(node: nodeID)
    }

    /// Transforms the output with a throwing function.
    @inlinable
    public func tryMap<T>(
        _ transform: @escaping (Output) throws(Binary.Bytes.Machine.Fault) -> T,
        in builder: inout Binary.Bytes.Machine.Builder
    ) -> Binary.Bytes.Machine.Expression<T> {
        let node = Binary.Bytes.Machine.Node.tryMap(
            child: self.node,
            transform: Binary.Bytes.Machine.Transform.Throwing(transform)
        )
        let nodeID = builder.allocate(node)
        return Binary.Bytes.Machine.Expression(node: nodeID)
    }
}

// MARK: - Sequence

extension Binary.Bytes.Machine {
    /// Sequences two expressions and combines their outputs.
    @inlinable
    public static func sequence<A, B, C>(
        _ a: Expression<A>,
        _ b: Expression<B>,
        combine: @escaping (A, B) -> C,
        in builder: inout Builder
    ) -> Expression<C> {
        let node = Node.sequence(
            a: a.node,
            b: b.node,
            combine: Combine.Erased(combine)
        )
        let nodeID = builder.allocate(node)
        return Expression(node: nodeID)
    }
}

// MARK: - OneOf

extension Binary.Bytes.Machine {
    /// Creates an expression that tries alternatives in order until one succeeds.
    @inlinable
    public static func oneOf<Output>(
        _ alternatives: [Expression<Output>],
        in builder: inout Builder
    ) -> Expression<Output> {
        let nodeIDs = alternatives.map { $0.node }
        let node = Node.oneOf(nodeIDs)
        let nodeID = builder.allocate(node)
        return Expression(node: nodeID)
    }
}

// MARK: - Many

extension Binary.Bytes.Machine {
    /// Creates an expression that parses zero or more occurrences.
    @inlinable
    public static func many<T>(
        _ expr: Expression<T>,
        in builder: inout Builder
    ) -> Expression<[T]> {
        let node = Node.many(
            child: expr.node,
            finalize: Finalize.Array(T.self)
        )
        let nodeID = builder.allocate(node)
        return Expression(node: nodeID)
    }
}

// MARK: - Optional

extension Binary.Bytes.Machine {
    /// Creates an expression that optionally parses its child.
    @inlinable
    public static func optional<T>(
        _ expr: Expression<T>,
        in builder: inout Builder
    ) -> Expression<T?> {
        let node = Node.optional(
            child: expr.node,
            wrapSome: Transform.Erased { (value: T) in Swift.Optional.some(value) },
            noneValue: Value.make(T?.none)
        )
        let nodeID = builder.allocate(node)
        return Expression(node: nodeID)
    }
}
