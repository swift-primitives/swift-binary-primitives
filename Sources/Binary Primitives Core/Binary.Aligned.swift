// Binary.Aligned.swift
// Protocol for binary spaces with power-of-2 alignment requirements.
//
// Parallel to Quantized for geometric spaces.

@_exported import Dimension_Primitives

/// A binary space with power-of-2 alignment requirements.
///
/// Aligned spaces ensure all offsets and lengths snap to alignment boundaries,
/// which is essential for Direct I/O, memory mapping, and block device operations.
///
/// This protocol refines ``Memory/Aligned`` with ``Spatial`` conformance for
/// binary address spaces.
///
/// ## Mathematical Model
///
/// An aligned space defines valid byte positions as multiples of the alignment:
/// - The **alignment** `a` is a power of 2 (512, 4096, 16384, etc.)
/// - Every valid offset is an integer multiple of `a`: offset = n × a
/// - Alignment checks use efficient bitwise operations
///
/// ## Example
///
/// ```swift
/// extension Binary.Space {
///     public enum Sector512: Binary.Aligned {
///         public static var alignment: Memory.Alignment { .sector512 }
///     }
/// }
///
/// // Check if a value is aligned
/// Binary.Space.Sector512.alignment.isAligned(4096)  // true
/// Binary.Space.Sector512.alignment.isAligned(1000)  // false
///
/// // Round to alignment boundary
/// Binary.Space.Sector512.alignment.alignUp(1000)    // 1024
/// Binary.Space.Sector512.alignment.alignDown(1000)  // 512
/// ```
extension Binary {
    public protocol Aligned: Memory.Aligned, Spatial {}
}
