import Foundation

/// Thread-safe mutable container for values across isolation boundaries.
///
/// Use when you need mutable shared state with Sendable conformance.
/// For new code, prefer actors when possible.
@propertyWrapper
public final class Box<Value>: @unchecked Sendable {

    private var _value: Value

    public var wrappedValue: Value {
        get { _value }
        set { _value = newValue }
    }

    public var projectedValue: Box<Value> { self }

    public init(wrappedValue: Value) {
        self._value = wrappedValue
    }

    /// Access value with transformation.
    @discardableResult
    public func modify<T>(_ transform: (inout Value) throws -> T) rethrows -> T {
        try transform(&_value)
    }

    /// Replace value, returning old value.
    @discardableResult
    public func replace(with newValue: Value) -> Value {
        let old = _value
        _value = newValue
        return old
    }
}

// MARK: - Equatable

extension Box: Equatable where Value: Equatable {
    public static func == (lhs: Box, rhs: Box) -> Bool {
        lhs._value == rhs._value
    }
}

// MARK: - Hashable

extension Box: Hashable where Value: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(_value)
    }
}

// MARK: - Numeric Operations

public extension Box where Value: Numeric {

    static func += (lhs: Box, rhs: Value) {
        lhs._value += rhs
    }

    static func -= (lhs: Box, rhs: Value) {
        lhs._value -= rhs
    }

    static func *= (lhs: Box, rhs: Value) {
        lhs._value *= rhs
    }
}

public extension Box where Value == Int {

    func increment() -> Int {
        _value += 1
        return _value
    }

    func decrement() -> Int {
        _value -= 1
        return _value
    }
}

public extension Box where Value == Bool {

    func toggle() {
        _value.toggle()
    }
}

// MARK: - Optional

public extension Box where Value: ExpressibleByNilLiteral {

    convenience init() {
        self.init(wrappedValue: nil)
    }
}

// MARK: - Collection

public extension Box where Value: RangeReplaceableCollection {

    convenience init() {
        self.init(wrappedValue: Value())
    }

    func append(_ element: Value.Element) {
        _value.append(element)
    }

    func removeAll() {
        _value.removeAll()
    }
}

// MARK: - Type Aliases

/// Boxed optional value.
public typealias OptionalBox<T> = Box<T?> where T: Sendable

/// Boxed array.
public typealias ArrayBox<T> = Box<[T]> where T: Sendable

/// Boxed dictionary.
public typealias DictBox<K: Hashable, V> = Box<[K: V]> where K: Sendable, V: Sendable
