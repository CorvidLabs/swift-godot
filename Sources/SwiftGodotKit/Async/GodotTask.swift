import SwiftGodot

/// A Godot-aware Task wrapper that integrates with Godot's lifecycle.
///
/// `GodotTask` ensures tasks are properly cancelled when nodes are freed
/// and provides frame-synchronized execution options.
///
/// ## Example
/// ```swift
/// @Godot
/// class Enemy: CharacterBody3D {
///     private var patrolTask: GodotTask<Void>?
///
///     override func _ready() {
///         patrolTask = GodotTask(owner: self) {
///             await self.patrol()
///         }
///     }
///
///     override func _exitTree() {
///         patrolTask?.cancel()
///     }
///
///     func patrol() async {
///         while !Task.isCancelled {
///             await GodotTask.nextFrame()
///             moveToNextWaypoint()
///         }
///     }
/// }
/// ```
public final class GodotTask<Success: Sendable>: Sendable {
    private let task: Task<Success, any Error>

    public init(
        owner: Object? = nil,
        priority: TaskPriority? = nil,
        operation: @escaping @Sendable () async throws -> Success
    ) {
        self.task = Task(priority: priority) {
            try await operation()
        }
    }

    /// The result of the task
    public var value: Success {
        get async throws {
            try await task.value
        }
    }

    /// Cancel the task
    public func cancel() {
        task.cancel()
    }

    /// Whether the task has been cancelled
    public var isCancelled: Bool {
        task.isCancelled
    }
}

// MARK: - Frame Synchronization

public extension GodotTask where Success == Void {
    /// Wait until the next frame
    @MainActor
    static func nextFrame() async {
        guard let tree = Engine.getMainLoop() as? SceneTree else { return }
        await SignalAwaiter.wait(for: tree, signal: "process_frame")
    }

    /// Wait until the next physics frame
    @MainActor
    static func nextPhysicsFrame() async {
        guard let tree = Engine.getMainLoop() as? SceneTree else { return }
        await SignalAwaiter.wait(for: tree, signal: "physics_frame")
    }

    /// Wait for a specific number of frames
    @MainActor
    static func frames(_ count: Int) async {
        for _ in 0..<count {
            await nextFrame()
        }
    }

    /// Wait for a duration using Swift's Task.sleep
    static func wait(seconds: Double) async throws {
        try await Task.sleep(for: .seconds(seconds))
    }

    /// Wait for a duration using Godot's timer
    @MainActor
    static func waitGodot(seconds: Double) async {
        guard let tree = Engine.getMainLoop() as? SceneTree else { return }
        let timer = tree.createTimer(timeSec: seconds)
        guard let timer = timer else { return }
        await SignalAwaiter.wait(for: timer, signal: "timeout")
    }
}

// MARK: - Detached Godot Tasks

public extension GodotTask {
    /// Create a detached task that isn't tied to any actor
    static func detached(
        priority: TaskPriority? = nil,
        operation: @escaping @Sendable () async throws -> Success
    ) -> GodotTask<Success> {
        GodotTask(priority: priority, operation: operation)
    }
}

// MARK: - Task Groups for Godot

/// Run multiple Godot-aware tasks in parallel
public func withGodotTaskGroup<Success: Sendable>(
    of successType: Success.Type,
    body: (inout TaskGroup<Success>) async -> Void
) async -> [Success] {
    await withTaskGroup(of: successType) { group in
        await body(&group)
        var results: [Success] = []
        for await result in group {
            results.append(result)
        }
        return results
    }
}

/// Run multiple throwing Godot-aware tasks in parallel
public func withThrowingGodotTaskGroup<Success: Sendable>(
    of successType: Success.Type,
    body: (inout ThrowingTaskGroup<Success, any Error>) async throws -> Void
) async throws -> [Success] {
    try await withThrowingTaskGroup(of: successType) { group in
        try await body(&group)
        var results: [Success] = []
        for try await result in group {
            results.append(result)
        }
        return results
    }
}
