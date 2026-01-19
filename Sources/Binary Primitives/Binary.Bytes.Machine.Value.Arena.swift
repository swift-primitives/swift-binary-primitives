// Binary.Bytes.Machine.Value.Arena.swift
// Arena-based storage for interpreter values

extension Binary.Bytes.Machine.Value {
    /// Arena-based storage for interpreter values.
    ///
    /// The Arena provides storage for Value objects, improving allocation
    /// overhead compared to scattered heap allocations. Values are accessed
    /// via handles rather than direct references.
    ///
    /// ## Memory Layout
    ///
    /// Values are stored in a growable array:
    /// ```
    /// ┌─────────┬─────────┬─────────┬─────────┐
    /// │ Value 0 │ Value 1 │ Value 2 │ ...     │
    /// └─────────┴─────────┴─────────┴─────────┘
    /// ```
    @usableFromInline
    struct Arena: ~Copyable {
        @usableFromInline
        var values: [Binary.Bytes.Machine.Value?]

        @usableFromInline
        var nextSlot: UInt32

        /// Creates a new arena with the specified initial capacity.
        @inlinable
        init(capacity: Int) {
            self.values = []
            self.values.reserveCapacity(capacity)
            self.nextSlot = 0
        }

        /// Allocates a value in the arena and returns a handle to it.
        @inlinable
        mutating func allocate(_ value: consuming Binary.Bytes.Machine.Value) -> Handle {
            let slot = nextSlot
            if Int(slot) < values.count {
                values[Int(slot)] = value
            } else {
                values.append(value)
            }
            nextSlot += 1
            return Handle(slot: slot)
        }

        /// Reads a value from the arena without removing it.
        @inlinable
        func read(_ handle: Handle) -> Binary.Bytes.Machine.Value {
            guard let value = values[Int(handle.slot)] else {
                fatalError("Arena: reading released handle")
            }
            return value
        }

        /// Releases a value from the arena and returns it.
        @inlinable
        @discardableResult
        mutating func release(_ handle: Handle) -> Binary.Bytes.Machine.Value {
            guard let value = values[Int(handle.slot)] else {
                fatalError("Arena: releasing already-released handle")
            }
            values[Int(handle.slot)] = nil
            return value
        }

        /// Resets the arena, invalidating all handles.
        @inlinable
        mutating func reset() {
            for i in 0..<Int(nextSlot) {
                values[i] = nil
            }
            nextSlot = 0
        }

        /// The number of values currently allocated.
        @inlinable
        var count: Int {
            Int(nextSlot)
        }
    }
}
