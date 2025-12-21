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

    // MARK: - Signal Definition Tests

    @Suite("Signal Definitions")
    struct SignalDefinitionTests {

        @Test("Signal0 with StringName")
        func signal0StringName() {
            let signal = Signal0(StringName("test"))
            #expect(signal.name == StringName("test"))
        }

        @Test("Signal1 generic type preserved")
        func signal1Generic() {
            let intSignal = Signal1<Int>("int_signal")
            let stringSignal = Signal1<String>("string_signal")

            #expect(intSignal.name == StringName("int_signal"))
            #expect(stringSignal.name == StringName("string_signal"))
        }

        @Test("Signal2 multiple types")
        func signal2Types() {
            let signal = Signal2<Int, Double>("multi_signal")
            #expect(signal.name == StringName("multi_signal"))
        }

        @Test("Signal3 three types")
        func signal3Types() {
            let signal = Signal3<Int, String, Bool>("triple_signal")
            #expect(signal.name == StringName("triple_signal"))
        }
    }
}
