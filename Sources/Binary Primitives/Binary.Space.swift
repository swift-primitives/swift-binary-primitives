// Binary.Space.swift
// Binary address space phantom type.

@_exported import Dimension_Primitives

extension Binary {
    /// Default binary address space for in-memory operations.
    ///
    /// `Binary.Space` is a phantom type that parameterizes `Binary.Position`,
    /// `Binary.Offset`, and `Binary.Count` to distinguish different address spaces
    /// at compile time.
    ///
    /// Downstream packages can define their own spaces for type safety:
    ///
    /// ```swift
    /// // In swift-kernel:
    /// extension Kernel.File {
    ///     public enum Space {}
    /// }
    ///
    /// typealias FileOffset = Binary.Offset<Int64, Kernel.File.Space>
    /// ```
    ///
    /// ## Usage
    ///
    /// ```swift
    /// typealias BufferPos = Binary.Position<Int, Binary.Space>
    /// // or use the convenience alias:
    /// typealias BufferPos = Binary.Space.Position
    /// ```
    ///
    /// - Note: `Binary.Space` conforms to `Spatial` but NOT `Aligned`.
    ///   Alignment is a specialization for I/O operations, not a default.
    ///   Use nested aligned spaces like `Binary.Space.Page4096` for aligned operations.
    public enum Space: Spatial {
        public typealias Space = Binary.Space
    }
}
