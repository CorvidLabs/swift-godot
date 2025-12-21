import Testing
@testable import SwiftGodotKit

@Suite("Property Wrapper Tests")
struct PropertyWrapperTests {

    // MARK: - GodotState Tests

    @Suite("GodotState")
    struct GodotStateTests {

        @Test("Initial value is set correctly")
        func initialValue() {
            @GodotState var health: Int = 100
            #expect(health == 100)
        }

        @Test("Value can be mutated")
        func mutation() {
            @GodotState var score: Int = 0
            score = 50
            #expect(score == 50)
        }

        @Test("Change detection works")
        func changeDetection() {
            @GodotState var value: Int = 10
            #expect($value.changed == false)

            value = 20
            #expect($value.changed == true)
            #expect($value.previous == 10)
        }

        @Test("Reset change flag works")
        func resetChangeFlag() {
            @GodotState var value: Int = 10
            value = 20
            #expect($value.changed == true)

            $value.reset()
            #expect($value.changed == false)
            #expect($value.previous == nil)
        }

        @Test("Binding provides two-way access")
        func binding() {
            @GodotState var value: Int = 5
            let binding = $value.binding

            #expect(binding.value == 5)

            binding.value = 15
            #expect(value == 15)
        }

    }

    // Note: GodotSignal and Signal tests require Godot runtime initialization
    // and cannot run in a pure Swift test environment
}
