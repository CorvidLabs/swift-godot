import SwiftGodotKit

// MARK: - Demo Entry Point

/// Main entry point for the SwiftGodotKit demo
@Godot
class DemoScene: Node, SignalReceiving {

    // MARK: - Node References

    @GodotNode(.unique("Player")) var player: Player?
    @GodotNode(.unique("GameManager")) var gameManager: GameManager?
    @GodotNode(.unique("GameUI")) var gameUI: GameUI?
    @GodotNode(.unique("EnemySpawner")) var enemySpawner: EnemySpawner?

    // MARK: - State

    @GodotState var isInitialized: Bool = false

    // MARK: - Lifecycle

    override func _ready() {
        configureNodes()
        connectSignals()
        isInitialized = true

        GodotContext.log("Demo scene ready!")
        printDemoInfo()
    }

    // MARK: - Setup

    private func configureNodes() {
        $player.configure(owner: self)
        $gameManager.configure(owner: self)
        $gameUI.configure(owner: self)
        $enemySpawner.configure(owner: self)
    }

    private func connectSignals() {
        // Connect player signals to UI
        if let player = player {
            player.on(Player.healthChanged.name) { [weak self] in
                self?.gameUI?.updateHealth(self?.player?.health ?? 0)
            }

            player.once(Player.died.name) { [weak self] in
                self?.onGameOver()
            }
        }

        // Connect game manager signals
        if let gameManager = gameManager {
            gameManager.on(GameManager.waveStarted.name) { [weak self] in
                self?.gameUI?.updateWave(self?.gameManager?.currentWave ?? 0)
            }

            gameManager.on(GameManager.gameEnded.name) { [weak self] in
                self?.gameUI?.showGameOver(score: self?.gameManager?.score ?? 0)
            }
        }

        // Connect UI signals
        if let gameUI = gameUI {
            gameUI.on(GameUI.restartRequested.name) { [weak self] in
                self?.restartGame()
            }
        }
    }

    // MARK: - Game Events

    private func onGameOver() {
        enemySpawner?.clearAllEnemies()
    }

    private func restartGame() {
        _ = getTree()?.reloadCurrentScene()
    }

    // MARK: - Debug Info

    private func printDemoInfo() {
        GodotContext.log("""

        ╔═══════════════════════════════════════════╗
        ║         SwiftGodotKit Demo v1.0           ║
        ╠═══════════════════════════════════════════╣
        ║                                           ║
        ║  Features Demonstrated:                   ║
        ║  • @GodotState - Reactive state           ║
        ║  • @GodotNode - Node references           ║
        ║  • @GodotSignal - Signal handlers         ║
        ║  • SignalEmitting/Receiving protocols     ║
        ║  • SignalAwaiter - Async signals          ║
        ║  • AsyncSignal - Signal streams           ║
        ║  • GodotTask - Frame sync tasks           ║
        ║  • NodeController - Declarative nodes     ║
        ║  • Box - Thread-safe state                ║
        ║  • GodotContext - Main thread utils       ║
        ║                                           ║
        ╚═══════════════════════════════════════════╝

        """)
    }
}

// MARK: - Quick Examples

/// Quick examples of SwiftGodotKit features
enum Examples {

    /// Example: Using @GodotState for reactive properties
    static func stateExample() {
        @GodotState var counter: Int = 0

        counter += 1
        print("Changed: \($counter.changed)")  // true
        print("Previous: \($counter.previous ?? -1)")  // 0

        $counter.reset()
        print("Changed after reset: \($counter.changed)")  // false
    }

    /// Example: Awaiting a signal (call from @MainActor context)
    static func asyncSignalExample() {
        print("SignalAwaiter.wait(for: button, signal: \"pressed\")")
        print("- Awaits until the signal is emitted")
    }

    /// Example: Streaming signals (call from @MainActor context)
    static func signalStreamExample() {
        print("for await _ in AsyncSignal(source: timer, signal: \"timeout\")")
        print("- Streams signal emissions as an AsyncSequence")
    }

    /// Example: Frame-synchronized async
    static func frameAsyncExample() async {
        await GodotTask.nextFrame()
        await GodotTask.frames(10)
        await GodotTask.nextPhysicsFrame()
        await GodotTask.waitGodot(seconds: 1.5)
    }

    /// Example: Building node hierarchies
    static func nodeControllerExample() -> Node {
        class RootController: NodeController {
            typealias NodeType = Node3D
            let node = Node3D()

            var children: [any NodeController] {
                [ChildA(), ChildB()]
            }

            func configure() {
                node.name = "Root"
            }
        }

        class ChildA: NodeController {
            typealias NodeType = MeshInstance3D
            let node = MeshInstance3D()

            func configure() {
                node.name = "MeshA"
            }
        }

        class ChildB: NodeController {
            typealias NodeType = MeshInstance3D
            let node = MeshInstance3D()

            func configure() {
                node.name = "MeshB"
            }
        }

        return RootController().build()
    }
}
