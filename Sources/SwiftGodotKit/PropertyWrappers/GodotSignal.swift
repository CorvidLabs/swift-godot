@preconcurrency import SwiftGodot

// MARK: - Signal Protocol

/// Protocol for typed signal definitions.
public protocol SignalType {
    var name: StringName { get }
}

// MARK: - Typed Signal Definitions

/// Zero-argument signal definition.
public struct Signal0: SignalType, Equatable {
    public let name: StringName

    public init(_ name: String) {
        self.name = StringName(name)
    }
}

/// One-argument signal definition.
public struct Signal1<T>: SignalType {
    public let name: StringName

    public init(_ name: String) {
        self.name = StringName(name)
    }
}

/// Two-argument signal definition.
public struct Signal2<T1, T2>: SignalType {
    public let name: StringName

    public init(_ name: String) {
        self.name = StringName(name)
    }
}

/// Three-argument signal definition.
public struct Signal3<T1, T2, T3>: SignalType {
    public let name: StringName

    public init(_ name: String) {
        self.name = StringName(name)
    }
}

// MARK: - Sendable Conformance

extension Signal0: @unchecked Sendable {}
extension Signal1: @unchecked Sendable {}
extension Signal2: @unchecked Sendable {}
extension Signal3: @unchecked Sendable {}

// MARK: - Signal Handler Property Wrapper

/// Declarative signal handler binding.
///
/// ```swift
/// @Godot
/// class MyButton: Button {
///     @GodotSignal("pressed")
///     var onPressed: () -> Void = {}
///
///     override func _ready() {
///         $onPressed.bind(to: self)
///     }
/// }
/// ```
@propertyWrapper
public struct GodotSignal<Handler> {

    private let storage: SignalStorage<Handler>

    public var wrappedValue: Handler {
        get { storage.handler }
        set { storage.handler = newValue }
    }

    public var projectedValue: SignalStorage<Handler> { storage }

    public init(wrappedValue: Handler, _ signalName: String) {
        self.storage = SignalStorage(
            signalName: StringName(signalName),
            handler: wrappedValue
        )
    }
}

/// Storage and connection management for signal handlers.
public final class SignalStorage<Handler>: @unchecked Sendable {

    public let signalName: StringName
    public var handler: Handler

    private var callable: Callable?
    private weak var source: Object?

    init(signalName: StringName, handler: Handler) {
        self.signalName = signalName
        self.handler = handler
    }

    /// Bind handler to source object's signal.
    @discardableResult
    public func bind(to source: Object) -> GodotError where Handler == () -> Void {
        disconnect()

        let handler = self.handler
        let callable = Callable { _ in
            handler()
            return nil
        }

        self.callable = callable
        self.source = source

        return source.connect(signal: signalName, callable: callable)
    }

    /// Disconnect from source.
    public func disconnect() {
        guard let source, let callable else { return }
        if source.isConnected(signal: signalName, callable: callable) {
            source.disconnect(signal: signalName, callable: callable)
        }
        self.callable = nil
        self.source = nil
    }

    /// Whether currently connected.
    public var isConnected: Bool {
        guard let source, let callable else { return false }
        return source.isConnected(signal: signalName, callable: callable)
    }

    deinit {
        disconnect()
    }
}
