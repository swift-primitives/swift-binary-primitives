// Binary.Bytes.Machine.Frame.swift
// Stack frame for machine interpreter

extension Binary.Bytes.Machine {
    /// Checkpoint for backtracking - just the cursor position.
    @usableFromInline
    typealias Checkpoint = Int

    /// Stack frame for the interpreter.
    @safe
    @usableFromInline
    enum Frame {
        @safe
        @usableFromInline
        enum Sequence {
            case second(b: Node.ID, combine: Combine.Erased)
            case combine(firstHandle: Value.Handle, combine: Combine.Erased)
        }

        case map(transform: Transform.Erased)
        case tryMap(transform: Transform.Throwing)
        case sequence(Sequence)
        case oneOf(alternatives: [Node.ID], index: Int, savedCheckpoint: Checkpoint)
        case many(child: Node.ID, savedCheckpoint: Checkpoint, resultHandles: [Value.Handle], finalize: Finalize.Array)
        case optional(savedCheckpoint: Checkpoint, wrapSome: Transform.Erased, noneHandle: Value.Handle)
        case recursiveExit
    }
}
