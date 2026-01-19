public import Parsing_Primitives

extension Binary.Bytes.Input: Parsing.Input {
    public typealias Element = UInt8
    public typealias Checkpoint = Int

    /// The current position as a checkpoint for backtracking.
    @inlinable
    public var checkpoint: Checkpoint {
        position
    }

    /// Restores the input to a previously saved checkpoint.
    ///
    /// - Parameter checkpoint: A checkpoint obtained from `checkpoint`.
    /// - Precondition: The checkpoint was created from this input instance
    ///   and is within valid bounds.
    @inlinable
    public mutating func restore(to checkpoint: Checkpoint) {
        precondition(checkpoint >= 0 && checkpoint <= totalCount,
                     "Invalid checkpoint: \(checkpoint) not in 0...\(totalCount)")
        position = checkpoint
    }

    /// Returns self for composability.
    @inlinable
    public var remaining: Self {
        self
    }
}
