import SwiftGodot

/// A protocol for types that can receive and handle Godot signals.
public protocol SignalReceiving {
    /// The object that will receive signals
    var signalReceiver: Object { get }
}

public extension SignalReceiving where Self: Object {
    var signalReceiver: Object { self }
}

// MARK: - Signal Connection Helpers

public extension SignalReceiving {
    /// Connect to a signal with no arguments
    @discardableResult
    func receive(
        _ signal: Signal0,
        from source: Object,
        handler: @escaping () -> Void
    ) -> GodotError {
        let callable = Callable { _ in
            handler()
            return nil
        }
        return source.connect(signal: signal.name, callable: callable)
    }

    /// Connect to a signal by name
    @discardableResult
    func receive(
        signal signalName: StringName,
        from source: Object,
        handler: @escaping () -> Void
    ) -> GodotError {
        let callable = Callable { _ in
            handler()
            return nil
        }
        return source.connect(signal: signalName, callable: callable)
    }
}

// MARK: - One-Shot Signal Connections

public extension SignalReceiving {
    /// Connect to a signal that will only fire once
    @discardableResult
    func receiveOnce(
        _ signal: Signal0,
        from source: Object,
        handler: @escaping () -> Void
    ) -> GodotError {
        let callable = Callable { _ in
            handler()
            return nil
        }
        return source.connect(signal: signal.name, callable: callable, flags: UInt32(Object.ConnectFlags.oneShot.rawValue))
    }
}
