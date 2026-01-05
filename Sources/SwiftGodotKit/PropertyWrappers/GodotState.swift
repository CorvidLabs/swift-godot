import Foundation

/**
 A property wrapper providing reactive state with change tracking.

 ```swift
 @Godot
 class Player: CharacterBody3D {
     @GodotState var health: Int = 100

     override func _process(delta: Double) {
         if $health.changed {
             updateHealthBar()
         }
         $health.reset()
     }
 }
 ```
 */
@propertyWrapper
public struct GodotState<Value: Sendable>: Sendable {

    private let box: StateBox<Value>

    public var wrappedValue: Value {
        get { box.value }
        nonmutating set { box.value = newValue }
    }

    public var projectedValue: StateBox<Value> { box }

    public init(wrappedValue: Value) {
        self.box = StateBox(wrappedValue)
    }
}

/// Observable state container with change tracking.
public final class StateBox<Value: Sendable>: @unchecked Sendable {

    private var _value: Value
    private var _previous: Value?
    private var _changed: Bool = false

    init(_ initial: Value) {
        self._value = initial
    }

    /// Current value.
    public var value: Value {
        get { _value }
        set {
            _previous = _value
            _value = newValue
            _changed = true
        }
    }

    /// Whether value changed since last `reset()`.
    public var changed: Bool { _changed }

    /// Previous value before last change.
    public var previous: Value? { _previous }

    /// Reset change tracking. Call at end of frame.
    public func reset() {
        _changed = false
        _previous = nil
    }

    /// Update value only if different (requires Equatable).
    public func update(_ newValue: Value) where Value: Equatable {
        guard _value != newValue else { return }
        value = newValue
    }

    /// Transform value in place.
    public func modify(_ transform: (inout Value) -> Void) {
        _previous = _value
        transform(&_value)
        _changed = true
    }

    /// Two-way binding.
    public var binding: Binding<Value> {
        Binding(get: { self.value }, set: { self.value = $0 })
    }
}

/// Two-way binding for state values.
public struct Binding<Value: Sendable>: Sendable {

    private let getter: @Sendable () -> Value
    private let setter: @Sendable (Value) -> Void

    public init(
        get: @escaping @Sendable () -> Value,
        set: @escaping @Sendable (Value) -> Void
    ) {
        self.getter = get
        self.setter = set
    }

    public var value: Value {
        get { getter() }
        nonmutating set { setter(newValue) }
    }

    /// Create a derived binding via key path.
    public func map<T: Sendable>(
        _ keyPath: WritableKeyPath<Value, T> & Sendable
    ) -> Binding<T> where Value: Sendable {
        Binding<T>(
            get: { self.getter()[keyPath: keyPath] },
            set: { newValue in
                var current = self.getter()
                current[keyPath: keyPath] = newValue
                self.setter(current)
            }
        )
    }
}

// MARK: - Equatable Conveniences

public extension StateBox where Value: Equatable {

    /// Whether value actually differs from previous.
    var actuallyChanged: Bool {
        guard let previous else { return _changed }
        return _value != previous
    }
}

// MARK: - Numeric Conveniences

public extension StateBox where Value: Numeric {

    static func += (lhs: StateBox, rhs: Value) {
        lhs.value += rhs
    }

    static func -= (lhs: StateBox, rhs: Value) {
        lhs.value -= rhs
    }
}

public extension StateBox where Value == Int {

    func increment() { value += 1 }
    func decrement() { value -= 1 }
}

public extension StateBox where Value == Bool {

    func toggle() { value.toggle() }
}
