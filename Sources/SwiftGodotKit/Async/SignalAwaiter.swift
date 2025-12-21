import SwiftGodot

/// Enables awaiting Godot signals with async/await syntax.
///
/// ## Example
/// ```swift
/// // Wait for a button press
/// await SignalAwaiter.wait(for: button, signal: "pressed")
///
/// // Wait with timeout
/// let result = try await SignalAwaiter.wait(
///     for: enemy,
///     signal: "died",
///     timeout: .seconds(5)
/// )
/// ```
public enum SignalAwaiter {

    /// Wait for a signal with no return value
    public static func wait(
        for source: Object,
        signal signalName: StringName
    ) async {
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            var callable: Callable!
            callable = Callable { _ in
                continuation.resume()
                source.disconnect(signal: signalName, callable: callable)
                return nil
            }
            source.connect(signal: signalName, callable: callable, flags: UInt32(Object.ConnectFlags.oneShot.rawValue))
        }
    }

    /// Wait for a signal with no return value (string overload)
    public static func wait(
        for source: Object,
        signal signalName: String
    ) async {
        await wait(for: source, signal: StringName(signalName))
    }

    /// Wait for a signal with timeout
    /// - Returns: `true` if signal was received, `false` if timeout occurred
    @MainActor
    public static func wait(
        for source: Object,
        signal signalName: StringName,
        timeout: Duration
    ) async throws -> Bool {
        // Use a simple race between signal and timeout
        // Since we're MainActor-isolated, we can safely work with the Object
        let signalReceived = Box(wrappedValue: false)

        var callable: Callable!
        callable = Callable { _ in
            signalReceived.wrappedValue = true
            return nil
        }
        source.connect(signal: signalName, callable: callable, flags: UInt32(Object.ConnectFlags.oneShot.rawValue))

        // Wait for timeout duration
        try await Task.sleep(for: timeout)

        // Check if signal was received
        if signalReceived.wrappedValue {
            return true
        }

        // Timeout occurred, disconnect the signal handler if still connected
        if source.isConnected(signal: signalName, callable: callable) {
            source.disconnect(signal: signalName, callable: callable)
        }
        return false
    }

    /// Wait for a typed signal
    public static func wait(
        for source: Object,
        signal: Signal0
    ) async {
        await wait(for: source, signal: signal.name)
    }
}

/// Errors that can occur when awaiting signals
public enum SignalAwaiterError: Error, Sendable {
    case timeout
    case disconnected
    case cancelled
}

// MARK: - Object Extension for Convenient Awaiting

public extension Object {
    /// Await a signal on this object
    func awaitSignal(_ signalName: StringName) async {
        await SignalAwaiter.wait(for: self, signal: signalName)
    }

    /// Await a signal on this object (string overload)
    func awaitSignal(_ signalName: String) async {
        await SignalAwaiter.wait(for: self, signal: signalName)
    }

    /// Await a typed signal
    func awaitSignal(_ signal: Signal0) async {
        await SignalAwaiter.wait(for: self, signal: signal)
    }
}
