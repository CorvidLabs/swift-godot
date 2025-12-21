import Foundation
import SwiftGodot

/// Execution context utilities for Godot operations.
public enum GodotContext {

    // MARK: - Thread Context

    /// Whether currently on main thread.
    public static var isMainThread: Bool { Thread.isMainThread }

    /// Execute synchronously on main thread.
    @MainActor
    public static func onMain<T>(_ work: () throws -> T) rethrows -> T {
        try work()
    }

    /// Execute asynchronously on main thread.
    @MainActor
    public static func onMain<T: Sendable>(_ work: @Sendable () async throws -> T) async rethrows -> T {
        try await work()
    }

    // MARK: - Engine State

    /// Whether game is running (not in editor).
    public static var isRunning: Bool { !Engine.isEditorHint() }

    /// Whether in editor mode.
    public static var isEditor: Bool { Engine.isEditorHint() }

    /// Physics ticks per second.
    public static var physicsTPS: Int { Int(Engine.physicsTicksPerSecond) }

    /// Target FPS (0 = unlimited).
    public static var targetFPS: Int { Int(Engine.maxFps) }

    /// Current FPS.
    public static var fps: Double { Engine.getFramesPerSecond() }

    /// Time since engine start in seconds.
    public static var uptime: Double { Double(Time.getTicksMsec()) / 1000.0 }

    /// Current frame number.
    public static var frame: Int { Int(Engine.getProcessFrames()) }

    /// Current physics frame number.
    public static var physicsFrame: Int { Int(Engine.getPhysicsFrames()) }

    // MARK: - Frame Deferral

    /// Schedule work for end of current frame.
    public static func afterFrame(_ work: @escaping () -> Void) {
        guard let tree = Engine.getMainLoop() as? SceneTree else {
            work()
            return
        }
        connectOneShot(tree, signal: "process_frame", work: work)
    }

    /// Schedule work for next physics frame.
    public static func afterPhysicsFrame(_ work: @escaping () -> Void) {
        guard let tree = Engine.getMainLoop() as? SceneTree else {
            work()
            return
        }
        connectOneShot(tree, signal: "physics_frame", work: work)
    }

    private static func connectOneShot(_ object: Object, signal: String, work: @escaping () -> Void) {
        let callable = Callable { _ in
            work()
            return nil
        }
        object.connect(
            signal: StringName(signal),
            callable: callable,
            flags: UInt32(Object.ConnectFlags.oneShot.rawValue)
        )
    }
}

// MARK: - Logging

public extension GodotContext {

    /// Log debug message (debug builds only).
    static func log(_ message: String, file: String = #file, line: Int = #line) {
        #if DEBUG
        let filename = (file as NSString).lastPathComponent
        GD.print("[\(filename):\(line)] \(message)")
        #endif
    }

    /// Log warning.
    static func warn(_ message: String, file: String = #file, line: Int = #line) {
        let filename = (file as NSString).lastPathComponent
        GD.pushWarning("[\(filename):\(line)] \(message)")
    }

    /// Log error.
    static func error(_ message: String, file: String = #file, line: Int = #line) {
        let filename = (file as NSString).lastPathComponent
        GD.pushError("[\(filename):\(line)] \(message)")
    }
}

// MARK: - Scene Tree Access

public extension GodotContext {

    /// Current scene tree.
    static var tree: SceneTree? {
        Engine.getMainLoop() as? SceneTree
    }

    /// Root viewport.
    static var root: Window? {
        tree?.root
    }

    /// Current scene root node.
    static var currentScene: Node? {
        tree?.currentScene
    }

    /// Pause the game.
    static func pause() {
        tree?.paused = true
    }

    /// Resume the game.
    static func resume() {
        tree?.paused = false
    }

    /// Whether game is paused.
    static var isPaused: Bool {
        tree?.paused ?? false
    }

    /// Quit the game.
    static func quit(exitCode: Int = 0) {
        tree?.quit(exitCode: Int32(exitCode))
    }
}
