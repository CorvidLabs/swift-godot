import Testing
@testable import SwiftGodotKit

@Suite("Protocol Tests")
struct ProtocolTests {

    // MARK: - NodeBuilder Tests

    @Suite("NodeBuilder")
    struct NodeBuilderTests {

        @Test("Empty block returns empty array")
        func emptyBlock() {
            @NodeBuilder
            func build() -> [any NodeController] {
            }

            let result = build()
            #expect(result.isEmpty)
        }
    }

    // Note: Signal tests require Godot runtime initialization (StringName)
    // and cannot run in a pure Swift test environment
}
