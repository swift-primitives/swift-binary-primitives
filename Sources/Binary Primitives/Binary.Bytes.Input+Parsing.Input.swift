public import Parsing_Primitives

extension Binary.Bytes.Input: Parsing.Input {
    public typealias Element = UInt8

    /// Returns self for composability.
    @inlinable
    public var remaining: Self {
        self
    }
}
