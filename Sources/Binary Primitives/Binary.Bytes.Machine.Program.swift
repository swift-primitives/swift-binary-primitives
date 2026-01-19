// Binary.Bytes.Machine.Program.swift
// Program storage for machine nodes

extension Binary.Bytes.Machine {
    /// A program containing machine nodes.
    @usableFromInline
    struct Program {
        @usableFromInline
        var nodes: [Node]

        @usableFromInline
        let maxDepth: Int?

        @usableFromInline
        init(maxDepth: Int? = nil) {
            self.nodes = []
            self.maxDepth = maxDepth
        }

        @usableFromInline
        mutating func allocate(_ node: Node) -> Node.ID {
            let id = Node.ID(nodes.count)
            nodes.append(node)
            return id
        }

        @usableFromInline
        subscript(id: Node.ID) -> Node {
            get { nodes[id.rawValue] }
            set { nodes[id.rawValue] = newValue }
        }
    }
}
