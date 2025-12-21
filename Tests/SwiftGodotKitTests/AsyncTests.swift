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

    // MARK: - Box Tests

    @Suite("Box")
    struct BoxTests {

        @Test("Initial value is set")
        func initialValue() {
            let box = Box(wrappedValue: 42)
            #expect(box.wrappedValue == 42)
        }

        @Test("Value can be mutated")
        func mutation() {
            let box = Box(wrappedValue: 0)
            box.wrappedValue = 100
            #expect(box.wrappedValue == 100)
        }

        @Test("modify provides exclusive access")
        func modify() {
            let box = Box(wrappedValue: 10)
            let result = box.modify { value -> Int in
                value += 5
                return value
            }
            #expect(result == 15)
            #expect(box.wrappedValue == 15)
        }

        @Test("replace returns old value")
        func replace() {
            let box = Box(wrappedValue: 10)
            let old = box.replace(with: 20)
            #expect(old == 10)
            #expect(box.wrappedValue == 20)
        }

        @Test("Int increment")
        func intIncrement() {
            let box = Box(wrappedValue: 0)
            let result = box.increment()
            #expect(result == 1)
            #expect(box.wrappedValue == 1)
        }

        @Test("Int decrement")
        func intDecrement() {
            let box = Box(wrappedValue: 5)
            let result = box.decrement()
            #expect(result == 4)
            #expect(box.wrappedValue == 4)
        }

        @Test("Bool toggle")
        func boolToggle() {
            let box = Box(wrappedValue: false)
            box.toggle()
            #expect(box.wrappedValue == true)
            box.toggle()
            #expect(box.wrappedValue == false)
        }

        @Test("Numeric operators")
        func numericOperators() {
            let box = Box(wrappedValue: 10)
            box += 5
            #expect(box.wrappedValue == 15)
            box -= 3
            #expect(box.wrappedValue == 12)
            box *= 2
            #expect(box.wrappedValue == 24)
        }

        @Test("Equatable conformance")
        func equatable() {
            let box1 = Box(wrappedValue: 42)
            let box2 = Box(wrappedValue: 42)
            let box3 = Box(wrappedValue: 99)

            #expect(box1 == box2)
            #expect(box1 != box3)
        }

        @Test("Hashable conformance")
        func hashable() {
            let box = Box(wrappedValue: 42)
            var hasher = Hasher()
            box.hash(into: &hasher)
            let hash = hasher.finalize()
            #expect(hash != 0)
        }
    }
}
