// Binary.Bytes.Machine.Finalize.swift
// Type-erased finalize operation for collecting many values

extension Binary.Bytes.Machine {
    /// Namespace for finalize types.
    @usableFromInline
    enum Finalize {}
}

extension Binary.Bytes.Machine.Finalize {
    /// Finalizes an array of values into a single typed array value.
    @safe
    @usableFromInline
    struct Array {
        @usableFromInline
        let finalize: ([Binary.Bytes.Machine.Value]) -> Binary.Bytes.Machine.Value

        @usableFromInline
        init<T>(_ elementType: T.Type) {
            self.finalize = { values in
                Binary.Bytes.Machine.Value.make(values.map { $0.unsafeTake(T.self) })
            }
        }
    }
}
