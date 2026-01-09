// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-standards open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-standards project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

extension Binary {
    /// Namespace for binary collection types.
    ///
    /// Provides bit-level collection types for space-efficient storage:
    /// - `Binary.Collection.Set`: A set of non-negative integers using one bit per element.
    /// - `Binary.Collection.Array`: A dense boolean array using one bit per element.
    public enum Collection {}
}
