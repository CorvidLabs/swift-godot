import SwiftGodot

/// An AsyncSequence wrapper for Godot signals, enabling for-await-in loops.
///
/// ## Example
/// ```swift
/// // Stream button presses
/// for await _ in AsyncSignal(source: button, signal: "pressed") {
///     handleButtonPress()
/// }
/// ```
public struct AsyncSignal<Element: Sendable>: AsyncSequence {
    public typealias AsyncIterator = AsyncSignalIterator<Element>

    private let source: Object
    private let signalName: StringName
    private let transform: @Sendable ([Variant]) -> Element?

    /// Create an AsyncSignal for signals with no meaningful return value
    public init(source: Object, signal signalName: StringName) where Element == Void {
        self.source = source
        self.signalName = signalName
        self.transform = { _ in () }
    }

    /// Create an AsyncSignal for signals with no meaningful return value (string overload)
    public init(source: Object, signal signalName: String) where Element == Void {
        self.init(source: source, signal: StringName(signalName))
    }

    /// Create an AsyncSignal with a custom transform
    public init(
        source: Object,
        signal signalName: StringName,
        transform: @escaping @Sendable ([Variant]) -> Element?
    ) {
        self.source = source
        self.signalName = signalName
        self.transform = transform
    }

    /// Create an AsyncSignal for typed signals
    public init(source: Object, signal: Signal0) where Element == Void {
        self.init(source: source, signal: signal.name)
    }

    public func makeAsyncIterator() -> AsyncSignalIterator<Element> {
        AsyncSignalIterator(source: source, signalName: signalName, transform: transform)
    }
}

/// Iterator for AsyncSignal
public final class AsyncSignalIterator<Element: Sendable>: AsyncIteratorProtocol, @unchecked Sendable {
    private let source: Object
    private let signalName: StringName
    private let transform: @Sendable ([Variant]) -> Element?
    private var stream: AsyncStream<Element>?
    private var continuation: AsyncStream<Element>.Continuation?
    private var iterator: AsyncStream<Element>.AsyncIterator?
    private var callable: Callable?

    init(
        source: Object,
        signalName: StringName,
        transform: @escaping @Sendable ([Variant]) -> Element?
    ) {
        self.source = source
        self.signalName = signalName
        self.transform = transform

        setupStream()
    }

    private func setupStream() {
        let (stream, cont) = AsyncStream<Element>.makeStream()
        self.stream = stream
        self.continuation = cont
        self.iterator = stream.makeAsyncIterator()

        let transform = self.transform
        let continuation = cont

        let callable = Callable { _ in
            // For signals without arguments, just yield
            if let element = transform([]) {
                continuation.yield(element)
            }
            return nil
        }

        self.callable = callable
        source.connect(signal: signalName, callable: callable)
    }

    public func next() async -> Element? {
        await iterator?.next()
    }

    deinit {
        continuation?.finish()
        if let callable = callable {
            source.disconnect(signal: signalName, callable: callable)
        }
    }
}

// MARK: - Convenience Extensions

public extension Object {
    /// Create an AsyncSignal for this object
    func signals(_ signalName: StringName) -> AsyncSignal<Void> {
        AsyncSignal(source: self, signal: signalName)
    }

    /// Create an AsyncSignal for this object (string overload)
    func signals(_ signalName: String) -> AsyncSignal<Void> {
        AsyncSignal(source: self, signal: signalName)
    }

    /// Create an AsyncSignal for a typed signal
    func signals(_ signal: Signal0) -> AsyncSignal<Void> {
        AsyncSignal(source: self, signal: signal)
    }
}
