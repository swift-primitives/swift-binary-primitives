public import Serialization_Primitives

extension Binary.Serializable {
    /// Serialization witness bridged from protocol conformance.
    @inlinable
    public static var serializing: Serialization.Serializing.Buffer<Self, UInt8, Void> {
        .init { value, _, buffer in
            Self.serialize(value, into: &buffer)
        }
    }
}
