// Binary.Bytes.Machine.Node.swift
// IR node representing a parsing operation

public import Identity_Primitives

extension Binary.Bytes.Machine {
    /// A node in the machine's instruction graph.
    ///
    /// Nodes represent parsing operations that can be composed into programs.
    /// The `leaf` case contains an `Instruction` rather than a closure,
    /// enabling the interpreter to execute without passing `Input.View`
    /// across callable boundaries.
    @safe
    @usableFromInline
    enum Node {
        @usableFromInline
        enum Tag {}

        @usableFromInline
        typealias ID = Tagged<Tag, Int>

        /// A leaf instruction that operates on the input.
        case leaf(Instruction)

        /// A pure value that always succeeds.
        case pure(Value)

        /// Transform the child's output.
        case map(child: ID, transform: Transform.Erased)

        /// Transform the child's output with potential failure.
        case tryMap(child: ID, transform: Transform.Throwing)

        /// Sequence two operations and combine their results.
        case sequence(a: ID, b: ID, combine: Combine.Erased)

        /// Try alternatives in order until one succeeds.
        case oneOf([ID])

        /// Parse zero or more occurrences.
        case many(child: ID, finalize: Finalize.Array)

        /// Optionally parse the child.
        case optional(child: ID, wrapSome: Transform.Erased, noneValue: Value)

        /// Reference to another node (for recursion).
        case ref(ID)

        /// Placeholder for forward references.
        case hole
    }
}
