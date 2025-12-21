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

    // MARK: - GodotSignal Tests

    @Suite("GodotSignal")
    struct GodotSignalTests {

        @Test("Signal name is stored correctly")
        func signalName() {
            @GodotSignal("pressed") var onPressed: () -> Void = {}
            #expect($onPressed.signalName == StringName("pressed"))
        }

        @Test("Handler can be set")
        func handlerSetting() {
            var callCount = 0
            @GodotSignal("pressed") var onPressed: () -> Void = { callCount += 1 }

            onPressed()
            #expect(callCount == 1)

            onPressed = { callCount += 10 }
            onPressed()
            #expect(callCount == 11)
        }

        @Test("Connection state tracking")
        func connectionState() {
            @GodotSignal("pressed") var onPressed: () -> Void = {}
            #expect($onPressed.isConnected == false)
        }
    }

    // MARK: - Signal Definition Tests

    @Suite("Signal Definitions")
    struct SignalDefinitionTests {

        @Test("Signal0 stores name")
        func signal0() {
            let signal = Signal0("my_signal")
            #expect(signal.name == StringName("my_signal"))
        }

        @Test("Signal1 stores name with type")
        func signal1() {
            let signal = Signal1<Int>("value_changed")
            #expect(signal.name == StringName("value_changed"))
        }

        @Test("Signal2 stores name with types")
        func signal2() {
            let signal = Signal2<Int, String>("combo_signal")
            #expect(signal.name == StringName("combo_signal"))
        }
    }
}
