// Binary.Bytes.Machine.Builder.swift
// Builder context for constructing machine programs

extension Binary.Bytes.Machine {
    /// A builder context for constructing machine programs.
    public struct Builder {
        @usableFromInline
        var program: Program

        @usableFromInline
        init(maxDepth: Int? = nil) {
            self.program = Program(maxDepth: maxDepth)
        }

        @usableFromInline
        mutating func allocate(_ node: Node) -> Node.ID {
            program.allocate(node)
        }
    }

    /// An expression in the machine program, representing a parser that produces Output.
    public struct Expression<Output> {
        @usableFromInline
        let node: Node.ID

        @usableFromInline
        init(node: Node.ID) {
            self.node = node
        }
    }

    /// A reference to a node in the program, used for recursive grammar definitions.
    public struct Reference<Output> {
        @usableFromInline
        let node: Node.ID

        @usableFromInline
        init(node: Node.ID) {
            self.node = node
        }
    }
}
