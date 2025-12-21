import SwiftGodot

// MARK: - Signal Connection

public extension Object {

    /// Connect to signal with handler.
    @discardableResult
    func on(_ signal: StringName, handler: @escaping () -> Void) -> GodotError {
        connect(signal: signal, callable: Callable { _ in handler(); return nil })
    }

    /// Connect to signal (string convenience).
    @discardableResult
    func on(_ signal: String, handler: @escaping () -> Void) -> GodotError {
        on(StringName(signal), handler: handler)
    }

    /// Connect to typed signal.
    @discardableResult
    func on(_ signal: Signal0, handler: @escaping () -> Void) -> GodotError {
        on(signal.name, handler: handler)
    }

    /// One-shot connection (auto-disconnects after first fire).
    @discardableResult
    func once(_ signal: StringName, handler: @escaping () -> Void) -> GodotError {
        connect(
            signal: signal,
            callable: Callable { _ in handler(); return nil },
            flags: UInt32(ConnectFlags.oneShot.rawValue)
        )
    }

    /// One-shot connection (string convenience).
    @discardableResult
    func once(_ signal: String, handler: @escaping () -> Void) -> GodotError {
        once(StringName(signal), handler: handler)
    }

    /// One-shot typed signal connection.
    @discardableResult
    func once(_ signal: Signal0, handler: @escaping () -> Void) -> GodotError {
        once(signal.name, handler: handler)
    }

    /// Deferred connection (called at end of frame).
    @discardableResult
    func onDeferred(_ signal: StringName, handler: @escaping () -> Void) -> GodotError {
        connect(
            signal: signal,
            callable: Callable { _ in handler(); return nil },
            flags: UInt32(ConnectFlags.deferred.rawValue)
        )
    }
}

// MARK: - Signal Queries

public extension Object {

    /// Whether object has signal.
    func has(signal: StringName) -> Bool {
        hasSignal(signal)
    }

    /// Whether object has signal (string convenience).
    func has(signal: String) -> Bool {
        has(signal: StringName(signal))
    }

    /// Whether signal has any connections.
    func hasConnections(for signal: StringName) -> Bool {
        !getSignalConnectionList(signal: signal).isEmpty()
    }

    /// Connection count for signal.
    func connectionCount(for signal: StringName) -> Int {
        Int(getSignalConnectionList(signal: signal).size())
    }
}

// MARK: - Object Identity

public extension Object {

    /// Instance ID as UInt.
    var instanceID: UInt { UInt(getInstanceId()) }
}

// MARK: - Metadata

public extension Object {

    /// Type-safe metadata subscript.
    subscript(meta key: String) -> Variant? {
        get {
            let name = StringName(key)
            guard hasMeta(name: name) else { return nil }
            return getMeta(name: name, default: nil)
        }
        set {
            let name = StringName(key)
            if let value = newValue {
                setMeta(name: name, value: value)
            } else {
                removeMeta(name: name)
            }
        }
    }

    /// Check if metadata exists.
    func hasMeta(_ key: String) -> Bool {
        hasMeta(name: StringName(key))
    }
}

// MARK: - Emit Helpers

public extension Object {

    /// Emit signal with no arguments.
    func emit(_ signal: Signal0) {
        emitSignal(signal.name)
    }

    /// Emit signal by name.
    func emit(_ signal: StringName) {
        emitSignal(signal)
    }

    /// Emit signal by name (string convenience).
    func emit(_ signal: String) {
        emitSignal(StringName(signal))
    }
}
