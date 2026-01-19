// Binary.Bytes.Machine.Value.Handle.swift
// Lightweight handle to a value stored in the arena

extension Binary.Bytes.Machine.Value {
    /// A handle to a value stored in the arena.
    @usableFromInline
    struct Handle: Equatable {
        @usableFromInline
        let slot: UInt32

        @inlinable
        init(slot: UInt32) {
            self.slot = slot
        }
    }
}
