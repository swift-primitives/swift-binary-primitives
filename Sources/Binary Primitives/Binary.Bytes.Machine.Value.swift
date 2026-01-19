// Binary.Bytes.Machine.Value.swift
// Type-erased value storage for machine interpreter

extension Binary.Bytes.Machine {
    /// Type-erased value used by the machine interpreter.
    ///
    /// Values are stored as boxed references to maintain type safety while
    /// allowing heterogeneous value storage in the interpreter's arena.
    ///
    /// ## Invariant
    ///
    /// Values must not contain or reference lifetime-dependent data such as
    /// `Span` or `Input.View`. All values must be independently owned.
    @safe
    @usableFromInline
    struct Value {
        @usableFromInline
        let type: ObjectIdentifier

        @usableFromInline
        let box: AnyObject

        @usableFromInline
        init(type: ObjectIdentifier, box: AnyObject) {
            self.type = type
            self.box = box
        }
    }
}

// MARK: - Construction

extension Binary.Bytes.Machine.Value {
    /// Creates a type-erased value from a typed value.
    @inlinable
    static func make<T>(_ value: T) -> Binary.Bytes.Machine.Value {
        let box = Box(value)
        return Binary.Bytes.Machine.Value(
            type: ObjectIdentifier(T.self),
            box: box
        )
    }

    /// Internal box class for value storage.
    @usableFromInline
    final class Box<T> {
        @usableFromInline
        let value: T

        @usableFromInline
        init(_ value: T) {
            self.value = value
        }
    }
}

// MARK: - Extraction

extension Binary.Bytes.Machine.Value {
    /// Extracts the value if it matches the expected type.
    @inlinable
    func take<T>(_ expectedType: T.Type) -> T? {
        guard type == ObjectIdentifier(T.self) else {
            return nil
        }
        guard let typedBox = box as? Box<T> else {
            return nil
        }
        return typedBox.value
    }

    /// Extracts the value, asserting it matches the expected type.
    @inlinable
    func unsafeTake<T>(_ expectedType: T.Type) -> T {
        precondition(
            type == ObjectIdentifier(T.self),
            "Machine.Value type mismatch: expected \(T.self)"
        )
        guard let typedBox = box as? Box<T> else {
            fatalError("Machine.Value box downcast failed")
        }
        return typedBox.value
    }
}
