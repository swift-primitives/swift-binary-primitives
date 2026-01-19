// Binary.Bytes.Machine.Combine.swift
// Type-erased combine operation for sequencing

extension Binary.Bytes.Machine {
    /// Namespace for combine types.
    @usableFromInline
    enum Combine {}
}

extension Binary.Bytes.Machine.Combine {
    /// Type-erased combine function for sequencing two values.
    @safe
    @usableFromInline
    struct Erased {
        @usableFromInline
        let combine: (Binary.Bytes.Machine.Value, Binary.Bytes.Machine.Value) -> Binary.Bytes.Machine.Value

        @usableFromInline
        init<A, B, Out>(_ combineFn: @escaping (A, B) -> Out) {
            self.combine = { a, b in
                let aVal = a.unsafeTake(A.self)
                let bVal = b.unsafeTake(B.self)
                return Binary.Bytes.Machine.Value.make(combineFn(aVal, bVal))
            }
        }
    }
}
