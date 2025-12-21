import Testing
@testable import SwiftGodotKit

@Suite("Async Tests")
struct AsyncTests {

    // MARK: - SignalAwaiterError Tests

    @Suite("SignalAwaiterError")
    struct SignalAwaiterErrorTests {

        @Test("Error cases exist")
        func errorCases() {
            let timeout = SignalAwaiterError.timeout
            let disconnected = SignalAwaiterError.disconnected
            let cancelled = SignalAwaiterError.cancelled

            #expect(timeout != disconnected)
            #expect(disconnected != cancelled)
            #expect(timeout != cancelled)
        }
    }

    // MARK: - SendableBox Tests

    @Suite("SendableBox")
    struct SendableBoxTests {

        @Test("Initial value is set")
        func initialValue() {
            let box = SendableBox(wrappedValue: 42)
            #expect(box.wrappedValue == 42)
        }

        @Test("Value can be mutated")
        func mutation() {
            let box = SendableBox(wrappedValue: 0)
            box.wrappedValue = 100
            #expect(box.wrappedValue == 100)
        }

        @Test("withValue provides exclusive access")
        func withValue() {
            let box = SendableBox(wrappedValue: 10)
            let result = box.withValue { value -> Int in
                value += 5
                return value
            }
            #expect(result == 15)
            #expect(box.wrappedValue == 15)
        }

        @Test("read provides read-only access")
        func read() {
            let box = SendableBox(wrappedValue: 42)
            let result = box.read { $0 * 2 }
            #expect(result == 84)
            #expect(box.wrappedValue == 42)
        }

        @Test("update transforms value")
        func update() {
            let box = SendableBox(wrappedValue: 5)
            box.update { $0 * 3 }
            #expect(box.wrappedValue == 15)
        }

        @Test("swap returns old value")
        func swap() {
            let box = SendableBox(wrappedValue: 10)
            let old = box.swap(20)
            #expect(old == 10)
            #expect(box.wrappedValue == 20)
        }

        @Test("Numeric add operation")
        func numericAdd() {
            let box = SendableBox(wrappedValue: 10)
            box.add(5)
            #expect(box.wrappedValue == 15)
        }

        @Test("Numeric subtract operation")
        func numericSubtract() {
            let box = SendableBox(wrappedValue: 20)
            box.subtract(8)
            #expect(box.wrappedValue == 12)
        }

        @Test("Int increment")
        func intIncrement() {
            let box = SendableBox(wrappedValue: 0)
            let result = box.increment()
            #expect(result == 1)
            #expect(box.wrappedValue == 1)
        }

        @Test("Int decrement")
        func intDecrement() {
            let box = SendableBox(wrappedValue: 5)
            let result = box.decrement()
            #expect(result == 4)
            #expect(box.wrappedValue == 4)
        }

        @Test("Bool toggle")
        func boolToggle() {
            let box = SendableBox(wrappedValue: false)
            box.toggle()
            #expect(box.wrappedValue == true)
            box.toggle()
            #expect(box.wrappedValue == false)
        }

        @Test("Thread safety with concurrent access")
        func threadSafety() async {
            let box = SendableBox(wrappedValue: 0)

            await withTaskGroup(of: Void.self) { group in
                for _ in 0..<100 {
                    group.addTask {
                        box.add(1)
                    }
                }
            }

            #expect(box.wrappedValue == 100)
        }

        @Test("Equatable conformance")
        func equatable() {
            let box1 = SendableBox(wrappedValue: 42)
            let box2 = SendableBox(wrappedValue: 42)
            let box3 = SendableBox(wrappedValue: 99)

            #expect(box1 == box2)
            #expect(box1 != box3)
        }

        @Test("Hashable conformance")
        func hashable() {
            let box = SendableBox(wrappedValue: 42)
            var hasher = Hasher()
            box.hash(into: &hasher)
            let hash = hasher.finalize()
            #expect(hash != 0)
        }
    }
}
