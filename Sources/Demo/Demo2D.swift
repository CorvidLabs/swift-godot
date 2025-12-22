import SwiftGodotKit

// MARK: - 2D Demo Entry Point

/// Main entry point for the 2D SwiftGodotKit demo
@Godot
class Demo2DScene: Node2D, SignalReceiving {

    // MARK: - Node References

    @GodotNode(.unique("Player2D")) var player: Player2D?
    @GodotNode(.unique("EnemySpawner2D")) var enemySpawner: EnemySpawner2D?
    @GodotNode("UI/HealthBar") var healthBar: ProgressBar?
    @GodotNode("UI/ScoreLabel") var scoreLabel: Label?
    @GodotNode("UI/WaveLabel") var waveLabel: Label?

    // MARK: - State

    @GodotState var currentWave: Int = 0
    @GodotState var isGameActive: Bool = false

    private var waveTimer: Double = 0
    private let waveDelay: Double = 3.0

    // MARK: - Lifecycle

    override func _ready() {
        $player.configure(owner: self)
        $enemySpawner.configure(owner: self)
        $healthBar.configure(owner: self)
        $scoreLabel.configure(owner: self)
        $waveLabel.configure(owner: self)

        setupSignals()
        startGame()

        GodotContext.log("2D Demo ready!")
    }

    override func _process(delta: Double) {
        if isGameActive {
            processWaveLogic(delta: delta)
        }

        if $currentWave.changed {
            waveLabel?.text = "Wave \(currentWave)"
        }
        $currentWave.reset()
    }

    // MARK: - Game Logic

    private func startGame() {
        isGameActive = true
        currentWave = 0
        waveTimer = waveDelay
    }

    private func processWaveLogic(delta: Double) {
        if let spawner = enemySpawner, !spawner.isSpawning && spawner.activeEnemyCount == 0 {
            waveTimer -= delta
            if waveTimer <= 0 {
                startNextWave()
            }
        }
    }

    private func startNextWave() {
        currentWave += 1
        let enemyCount = currentWave * 2 + 1
        enemySpawner?.startWave(enemyCount: enemyCount)
        waveTimer = waveDelay
        GodotContext.log("Wave \(currentWave) started with \(enemyCount) enemies")
    }

    private func setupSignals() {
        player?.on(Player2D.healthChanged.name) { [weak self] in
            self?.healthBar?.value = Double(self?.player?.health ?? 0)
        }

        player?.on(Player2D.scoreChanged.name) { [weak self] in
            self?.scoreLabel?.text = "Score: \(self?.player?.score ?? 0)"
        }

        player?.once(Player2D.died.name) { [weak self] in
            self?.onGameOver()
        }
    }

    private func onGameOver() {
        isGameActive = false
        enemySpawner?.clearAllEnemies()
        GodotContext.log("Game Over! Final Score: \(player?.score ?? 0)")
    }
}

// MARK: - Player2D

/// 2D Player with WASD movement
@Godot
class Player2D: CharacterBody2D, SignalEmitting {

    // MARK: - Signals

    static let healthChanged = Signal1<Int>("health_changed")
    static let scoreChanged = Signal1<Int>("score_changed")
    static let died = Signal0("died")

    // MARK: - State

    @GodotState var health: Int = 100
    @GodotState var score: Int = 0
    @GodotState var isAlive: Bool = true
    @GodotState var speed: Double = 200.0

    // MARK: - Visuals

    private var sprite: ColorRect?
    private var collision: CollisionShape2D?

    // MARK: - Lifecycle

    override func _ready() {
        setupVisuals()
        setupCollision()
    }

    override func _process(delta: Double) {
        if $health.changed {
            emit(Self.healthChanged.name, Variant(health))
            if health <= 0 && isAlive {
                die()
            }
        }

        if $score.changed {
            emit(Self.scoreChanged.name, Variant(score))
        }

        $health.reset()
        $score.reset()
    }

    override func _physicsProcess(delta: Double) {
        handleMovement()
    }

    // MARK: - Setup

    private func setupVisuals() {
        let rect = ColorRect()
        rect.color = Color(r: 0.2, g: 0.6, b: 1.0, a: 1.0)
        rect.customMinimumSize = Vector2(x: 32, y: 32)
        rect.setSize(Vector2(x: 32, y: 32))
        rect.setPosition(Vector2(x: -16, y: -16))
        addChild(node: rect)
        self.sprite = rect
    }

    private func setupCollision() {
        let shape = CollisionShape2D()
        let rect = RectangleShape2D()
        rect.size = Vector2(x: 32, y: 32)
        shape.shape = rect
        addChild(node: shape)
        self.collision = shape
    }

    // MARK: - Movement

    private func handleMovement() {
        guard isAlive else { return }

        var direction = Vector2.zero

        if Input.isActionPressed(action: "ui_left") || Input.isActionPressed(action: "move_left") {
            direction.x -= 1
        }
        if Input.isActionPressed(action: "ui_right") || Input.isActionPressed(action: "move_right") {
            direction.x += 1
        }
        if Input.isActionPressed(action: "ui_up") || Input.isActionPressed(action: "move_forward") {
            direction.y -= 1
        }
        if Input.isActionPressed(action: "ui_down") || Input.isActionPressed(action: "move_back") {
            direction.y += 1
        }

        if direction != .zero {
            direction = direction.normalized()
        }

        velocity = direction * speed
        moveAndSlide()
    }

    // MARK: - Public API

    func takeDamage(_ amount: Int) {
        guard isAlive else { return }
        health = max(0, health - amount)
    }

    func addScore(_ points: Int) {
        score += points
    }

    private func die() {
        isAlive = false
        emit(Self.died)
        collision?.disabled = true
        sprite?.color = Color(r: 0.5, g: 0.5, b: 0.5, a: 1.0)
        GodotContext.log("Player died!")
    }
}

// MARK: - Enemy2D

/// 2D Enemy that chases the player
@Godot
class Enemy2D: CharacterBody2D {

    // MARK: - Signals

    static let defeated = Signal0("defeated")

    // MARK: - State

    @GodotState var health: Int = 1
    @GodotState var speed: Double = 100.0

    weak var target: Player2D?

    private var sprite: ColorRect?
    private var collision: CollisionShape2D?
    private var attackCooldown: Double = 0

    // MARK: - Lifecycle

    override func _ready() {
        setupVisuals()
        setupCollision()
    }

    override func _physicsProcess(delta: Double) {
        moveTowardTarget()
        checkPlayerCollision(delta: delta)
    }

    // MARK: - Setup

    private func setupVisuals() {
        let rect = ColorRect()
        rect.color = Color(r: 0.9, g: 0.2, b: 0.2, a: 1.0)
        rect.customMinimumSize = Vector2(x: 24, y: 24)
        rect.setSize(Vector2(x: 24, y: 24))
        rect.setPosition(Vector2(x: -12, y: -12))
        addChild(node: rect)
        self.sprite = rect
    }

    private func setupCollision() {
        let shape = CollisionShape2D()
        let rect = RectangleShape2D()
        rect.size = Vector2(x: 24, y: 24)
        shape.shape = rect
        addChild(node: shape)
        self.collision = shape
    }

    // MARK: - AI

    private func moveTowardTarget() {
        guard let target = target, target.isAlive else { return }

        let direction = (target.globalPosition - globalPosition).normalized()
        velocity = direction * speed
        moveAndSlide()
    }

    private func checkPlayerCollision(delta: Double) {
        attackCooldown -= delta
        guard attackCooldown <= 0 else { return }

        guard let target = target, target.isAlive else { return }

        let distance = globalPosition.distanceTo(target.globalPosition)
        if distance < 30 {
            target.takeDamage(10)
            attackCooldown = 1.0

            // Knockback
            let knockback = (globalPosition - target.globalPosition).normalized() * 50
            globalPosition += knockback
        }
    }

    // MARK: - Damage

    func takeDamage(_ amount: Int) {
        health -= amount
        if health <= 0 {
            die()
        }
    }

    private func die() {
        emitSignal(Self.defeated.name)
        queueFree()
    }
}

// MARK: - EnemySpawner2D

/// Spawns 2D enemies around the screen edges
@Godot
class EnemySpawner2D: Node2D, SignalEmitting {

    // MARK: - Signals

    static let enemySpawned = Signal0("enemy_spawned")
    static let allEnemiesDefeated = Signal0("all_enemies_defeated")

    // MARK: - State

    @GodotState var activeEnemyCount: Int = 0
    @GodotState var isSpawning: Bool = false

    private var spawnedEnemies: [Enemy2D] = []
    private var spawnQueue: Int = 0
    private var spawnTimer: Double = 0

    // MARK: - Configuration

    var spawnDelay: Double = 0.5
    var maxConcurrentEnemies: Int = 20
    var spawnMargin: Float = 50.0

    // MARK: - Node References

    @GodotNode(.unique("Player2D")) var player: Player2D?

    // MARK: - Lifecycle

    override func _ready() {
        $player.configure(owner: self)
    }

    override func _process(delta: Double) {
        if spawnQueue > 0 && activeEnemyCount < maxConcurrentEnemies {
            spawnTimer -= delta
            if spawnTimer <= 0 {
                spawnEnemy()
                spawnQueue -= 1
                spawnTimer = spawnDelay

                if spawnQueue == 0 {
                    isSpawning = false
                }
            }
        }

        checkDefeatedEnemies()
    }

    // MARK: - Spawning

    func startWave(enemyCount: Int) {
        guard !isSpawning else { return }

        isSpawning = true
        spawnQueue = enemyCount
        spawnTimer = 0
    }

    private func spawnEnemy() {
        let enemy = Enemy2D()
        enemy.name = "Enemy2D_\(spawnedEnemies.count)"
        enemy.target = player

        // Spawn at random edge of viewport
        enemy.globalPosition = getRandomSpawnPosition()

        spawnedEnemies.append(enemy)
        activeEnemyCount += 1

        getTree()?.currentScene?.addChild(node: enemy)
        emit(Self.enemySpawned)
    }

    private func getRandomSpawnPosition() -> Vector2 {
        let viewportSize = getViewportRect().size
        let edge = Int.random(in: 0...3)

        switch edge {
        case 0: // Top
            return Vector2(x: Float.random(in: 0...Float(viewportSize.x)), y: -spawnMargin)
        case 1: // Bottom
            return Vector2(x: Float.random(in: 0...Float(viewportSize.x)), y: Float(viewportSize.y) + spawnMargin)
        case 2: // Left
            return Vector2(x: -spawnMargin, y: Float.random(in: 0...Float(viewportSize.y)))
        default: // Right
            return Vector2(x: Float(viewportSize.x) + spawnMargin, y: Float.random(in: 0...Float(viewportSize.y)))
        }
    }

    // MARK: - Enemy Management

    private func checkDefeatedEnemies() {
        let removedCount = spawnedEnemies.filter { !$0.isInsideTree() }.count
        spawnedEnemies.removeAll { !$0.isInsideTree() }
        activeEnemyCount -= removedCount

        if activeEnemyCount == 0 && !isSpawning && spawnedEnemies.isEmpty {
            emit(Self.allEnemiesDefeated)
        }
    }

    func clearAllEnemies() {
        for enemy in spawnedEnemies {
            enemy.queueFree()
        }
        spawnedEnemies.removeAll()
        activeEnemyCount = 0
        spawnQueue = 0
        isSpawning = false
    }
}
