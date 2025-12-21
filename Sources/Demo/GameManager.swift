import SwiftGodotKit

/// Example GameManager demonstrating state management and signals
@Godot
class GameManager: Node {

    // MARK: - Signals

    static let gameStarted = Signal0("game_started")
    static let gameEnded = Signal1<Int>("game_ended")
    static let waveStarted = Signal1<Int>("wave_started")

    // MARK: - State

    @GodotState var currentWave: Int = 0
    @GodotState var isGameActive: Bool = false
    @GodotState var totalScore: Int = 0

    var score: Int { totalScore }

    // MARK: - Node References

    @GodotNode(.unique("Player")) var player: Player?
    @GodotNode("Spawners/EnemySpawner") var enemySpawner: Node?
    @GodotNode("UI/GameOverScreen") var gameOverScreen: Control?
    @GodotNode("UI/WaveLabel") var waveLabel: Label?

    // MARK: - Internal State

    private var isRunning: Bool = false
    private var waveTimer: Double = 0
    private var spawnTimer: Double = 0
    private var enemiesRemainingInWave: Int = 0
    private let waveDelay: Double = 2.0
    private let spawnDelay: Double = 0.5

    // MARK: - Lifecycle

    override func _ready() {
        $player.configure(owner: self)
        $enemySpawner.configure(owner: self)
        $gameOverScreen.configure(owner: self)
        $waveLabel.configure(owner: self)

        gameOverScreen?.visible = false

        setupPlayerSignals()
        startGame()
    }

    override func _process(delta: Double) {
        if $currentWave.changed {
            waveLabel?.text = "Wave \(currentWave)"
        }
        $currentWave.reset()

        if isRunning && isGameActive {
            processWaveLogic(delta: delta)
        }
    }

    override func _exitTree() {
        isRunning = false
    }

    // MARK: - Game Flow

    func startGame() {
        isGameActive = true
        isRunning = true
        currentWave = 0
        totalScore = 0
        waveTimer = waveDelay

        emitSignal(Self.gameStarted.name)
        GodotContext.log("Game started!")
    }

    private func processWaveLogic(delta: Double) {
        if enemiesRemainingInWave > 0 {
            spawnTimer -= delta
            if spawnTimer <= 0 {
                spawnEnemy()
                enemiesRemainingInWave -= 1
                spawnTimer = spawnDelay
            }
        } else {
            waveTimer -= delta
            if waveTimer <= 0 {
                startNextWave()
            }
        }
    }

    private func startNextWave() {
        currentWave += 1
        emitSignal(Self.waveStarted.name, Variant(currentWave))

        GodotContext.log("Starting wave \(currentWave)")

        enemiesRemainingInWave = currentWave * 3
        spawnTimer = 0
        waveTimer = waveDelay
    }

    private func spawnEnemy() {
        GodotContext.log("Spawning enemy")
    }

    // MARK: - Signal Handling

    private func setupPlayerSignals() {
        guard let player = player else { return }

        player.on(Player.healthChanged.name) { [weak self] in
            self?.onPlayerHealthChanged(self?.player?.health ?? 0)
        }

        player.once(Player.died.name) { [weak self] in
            self?.onPlayerDied()
        }
    }

    private func onPlayerHealthChanged(_ health: Int) {
        GodotContext.log("Player health: \(health)")

        if health <= 25 {
            GodotContext.warn("Player health critical!")
        }
    }

    private func onPlayerDied() {
        endGame()
    }

    // MARK: - Game End

    private func endGame() {
        isGameActive = false
        isRunning = false

        if let player = player {
            totalScore = player.score
        }

        gameOverScreen?.visible = true
        emitSignal(Self.gameEnded.name, Variant(totalScore))

        GodotContext.log("Game over! Final score: \(totalScore)")
    }
}

// MARK: - Wave Controller (NodeController Example)

class WaveController: NodeController {
    typealias NodeType = Node3D

    let node = Node3D()
    let waveNumber: Int
    let enemyCount: Int

    var children: [any NodeController] {
        (0..<enemyCount).map { _ in EnemyController() }
    }

    init(wave: Int) {
        self.waveNumber = wave
        self.enemyCount = wave * 3
    }

    func configure() {
        node.name = "Wave_\(waveNumber)"
    }

    func didAddChildren() {
        GodotContext.log("Wave \(waveNumber) configured with \(enemyCount) enemies")
    }
}

class EnemyController: NodeController {
    typealias NodeType = CharacterBody3D

    let node = CharacterBody3D()

    func configure() {
        node.name = "Enemy"
    }
}
