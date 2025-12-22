import SwiftGodot

// MARK: - Signal Connection

public extension Object {

    /// Connects a handler to a signal.
    ///
    /// The handler will be called each time the signal is emitted.
    ///
    /// - Parameters:
    ///   - signal: The signal name to connect to.
    ///   - handler: The closure to call when the signal is emitted.
    /// - Returns: A `GodotError` indicating success or failure.
    ///
    /// ```swift
    /// button.on("pressed") {
    ///     print("Button pressed!")
    /// }
    /// ```
    @discardableResult
    func on(_ signal: StringName, handler: @escaping () -> Void) -> GodotError {
        connect(signal: signal, callable: Callable { _ in handler(); return nil })
    }

    /// Connects a handler to a signal using a string name.
    ///
    /// - Parameters:
    ///   - signal: The signal name as a String.
    ///   - handler: The closure to call when the signal is emitted.
    /// - Returns: A `GodotError` indicating success or failure.
    @discardableResult
    func on(_ signal: String, handler: @escaping () -> Void) -> GodotError {
        on(StringName(signal), handler: handler)
    }

    /// Connects a handler to a typed signal definition.
    ///
    /// - Parameters:
    ///   - signal: The typed signal definition.
    ///   - handler: The closure to call when the signal is emitted.
    /// - Returns: A `GodotError` indicating success or failure.
    ///
    /// ```swift
    /// player.on(Player.died) {
    ///     showGameOver()
    /// }
    /// ```
    @discardableResult
    func on(_ signal: Signal0, handler: @escaping () -> Void) -> GodotError {
        on(signal.name, handler: handler)
    }

    /// Connects a one-shot handler that disconnects after first invocation.
    ///
    /// The handler will be called only once, then automatically disconnected.
    ///
    /// - Parameters:
    ///   - signal: The signal name to connect to.
    ///   - handler: The closure to call when the signal is emitted.
    /// - Returns: A `GodotError` indicating success or failure.
    ///
    /// ```swift
    /// animation.once("animation_finished") {
    ///     enemy.queueFree()
    /// }
    /// ```
    @discardableResult
    func once(_ signal: StringName, handler: @escaping () -> Void) -> GodotError {
        connect(
            signal: signal,
            callable: Callable { _ in handler(); return nil },
            flags: UInt32(ConnectFlags.oneShot.rawValue)
        )
    }

    /// Connects a one-shot handler using a string name.
    ///
    /// - Parameters:
    ///   - signal: The signal name as a String.
    ///   - handler: The closure to call when the signal is emitted.
    /// - Returns: A `GodotError` indicating success or failure.
    @discardableResult
    func once(_ signal: String, handler: @escaping () -> Void) -> GodotError {
        once(StringName(signal), handler: handler)
    }

    /// Connects a one-shot handler to a typed signal definition.
    ///
    /// - Parameters:
    ///   - signal: The typed signal definition.
    ///   - handler: The closure to call when the signal is emitted.
    /// - Returns: A `GodotError` indicating success or failure.
    @discardableResult
    func once(_ signal: Signal0, handler: @escaping () -> Void) -> GodotError {
        once(signal.name, handler: handler)
    }

    /// Connects a deferred handler that runs at the end of the frame.
    ///
    /// Useful when you need to ensure other signal handlers complete first.
    ///
    /// - Parameters:
    ///   - signal: The signal name to connect to.
    ///   - handler: The closure to call when the signal is emitted.
    /// - Returns: A `GodotError` indicating success or failure.
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

    /// Returns whether this object has the specified signal.
    ///
    /// - Parameter signal: The signal name to check.
    /// - Returns: `true` if the signal exists on this object.
    func has(signal: StringName) -> Bool {
        hasSignal(signal)
    }

    /// Returns whether this object has the specified signal.
    ///
    /// - Parameter signal: The signal name as a String.
    /// - Returns: `true` if the signal exists on this object.
    func has(signal: String) -> Bool {
        has(signal: StringName(signal))
    }

    /// Returns whether the signal has any connections.
    ///
    /// - Parameter signal: The signal name to check.
    /// - Returns: `true` if at least one handler is connected.
    func hasConnections(for signal: StringName) -> Bool {
        !getSignalConnectionList(signal: signal).isEmpty()
    }

    /// Returns the number of connections for a signal.
    ///
    /// - Parameter signal: The signal name to check.
    /// - Returns: The number of connected handlers.
    func connectionCount(for signal: StringName) -> Int {
        Int(getSignalConnectionList(signal: signal).size())
    }
}

// MARK: - Object Identity

public extension Object {

    /// The unique instance ID of this object as a UInt.
    var instanceID: UInt { UInt(getInstanceId()) }
}

// MARK: - Metadata

public extension Object {

    /// Type-safe subscript access to object metadata.
    ///
    /// Metadata provides a way to attach arbitrary data to Godot objects.
    ///
    /// ```swift
    /// node[meta: "score"] = Variant(100)
    /// if let score = node[meta: "score"]?.asInt() {
    ///     print("Score: \(score)")
    /// }
    /// ```
    ///
    /// - Parameter key: The metadata key.
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

    /// Returns whether metadata exists for the given key.
    ///
    /// - Parameter key: The metadata key to check.
    /// - Returns: `true` if metadata exists for this key.
    func hasMeta(_ key: String) -> Bool {
        hasMeta(name: StringName(key))
    }
}

// MARK: - Emit Helpers

public extension Object {

    /// Emits a typed signal with no arguments.
    ///
    /// - Parameter signal: The signal definition to emit.
    ///
    /// ```swift
    /// emit(Player.died)
    /// ```
    func emit(_ signal: Signal0) {
        emitSignal(signal.name)
    }

    /// Emits a signal by name.
    ///
    /// - Parameter signal: The signal name to emit.
    func emit(_ signal: StringName) {
        emitSignal(signal)
    }

    /// Emits a signal by string name.
    ///
    /// - Parameter signal: The signal name as a String.
    func emit(_ signal: String) {
        emitSignal(StringName(signal))
    }
}
