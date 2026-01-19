// Binary.Bytes.Machine.Transform.swift
// Type-erased transforms operating on Values

extension Binary.Bytes.Machine {
    /// Namespace for transform types.
    @usableFromInline
    enum Transform {}
}

// MARK: - Erased Transform

extension Binary.Bytes.Machine.Transform {
    /// Type-erased non-throwing transform.
    ///
    /// Transforms operate on `Value` only and must not capture
    /// input-bound or lifetime-dependent data.
    @safe
    @usableFromInline
    struct Erased {
        @usableFromInline
        let apply: (Binary.Bytes.Machine.Value) -> Binary.Bytes.Machine.Value

        @usableFromInline
        init<In, Out>(_ transform: @escaping (In) -> Out) {
            self.apply = { value in
                let input = value.unsafeTake(In.self)
                return Binary.Bytes.Machine.Value.make(transform(input))
            }
        }
    }
}

// MARK: - Throwing Transform

extension Binary.Bytes.Machine.Transform {
    /// Type-erased throwing transform.
    ///
    /// Throws `Machine.Fault` on failure.
    @safe
    @usableFromInline
    struct Throwing {
        @usableFromInline
        let apply: (Binary.Bytes.Machine.Value) throws(Binary.Bytes.Machine.Fault) -> Binary.Bytes.Machine.Value

        @usableFromInline
        init<In, Out>(_ transform: @escaping (In) throws(Binary.Bytes.Machine.Fault) -> Out) {
            self.apply = { (value: Binary.Bytes.Machine.Value) throws(Binary.Bytes.Machine.Fault) -> Binary.Bytes.Machine.Value in
                let input = value.unsafeTake(In.self)
                return Binary.Bytes.Machine.Value.make(try transform(input))
            }
        }
    }
}
