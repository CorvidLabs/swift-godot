import SwiftGodotKit

/// Example EnemySpawner demonstrating state and signal patterns
@Godot
class EnemySpawner: Node3D, SignalEmitting {

    // MARK: - Signals

    static let enemySpawned = Signal0("enemy_spawned")
    static let allEnemiesDefeated = Signal0("all_enemies_defeated")

    // MARK: - State

    @GodotState var activeEnemyCount: Int = 0
    @GodotState var isSpawning: Bool = false

    private var spawnedEnemies: [Node] = []
    private var spawnQueue: Int = 0
    private var spawnTimer: Double = 0

    // MARK: - Configuration

    var spawnDelay: Double = 1.0
    var maxConcurrentEnemies: Int = 10

    // MARK: - Node References

    @GodotNode("SpawnPoints") var spawnPointsContainer: Node3D?

    // MARK: - Lifecycle

    override func _ready() {
        $spawnPointsContainer.configure(owner: self)
    }

    override func _process(delta: Double) {
        // Handle spawning in process loop
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

        // Check for defeated enemies
        checkDefeatedEnemies()
    }

    // MARK: - Spawning

    /// Start spawning a wave of enemies
    func startWave(enemyCount: Int) {
        guard !isSpawning else { return }

        isSpawning = true
        spawnQueue = enemyCount
        spawnTimer = 0
    }

    private func spawnEnemy() {
        let enemy = CharacterBody3D()
        enemy.name = "Enemy_\(spawnedEnemies.count)"

        // Get a random spawn point
        if let spawnPoint = getRandomSpawnPoint() {
            enemy.globalPosition = spawnPoint.globalPosition
        }

        // Track the enemy
        spawnedEnemies.append(enemy)
        activeEnemyCount += 1

        // Add to scene
        addChild(node: enemy)

        // Emit signal
        emit(Self.enemySpawned)
    }

    private func getRandomSpawnPoint() -> Node3D? {
        guard let container = spawnPointsContainer else { return nil }
        let spawnPoints = container.children(ofType: Node3D.self)
        guard !spawnPoints.isEmpty else { return nil }
        let index = Int.random(in: 0..<spawnPoints.count)
        return spawnPoints[index]
    }

    // MARK: - Enemy Management

    private func checkDefeatedEnemies() {
        // Check for defeated enemies
        let removedCount = spawnedEnemies.filter { !$0.isInsideTree() }.count
        spawnedEnemies.removeAll { !$0.isInsideTree() }
        activeEnemyCount -= removedCount

        // Check if all enemies defeated
        if activeEnemyCount == 0 && !isSpawning && spawnedEnemies.isEmpty {
            emit(Self.allEnemiesDefeated)
        }
    }

    /// Remove all active enemies
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

// MARK: - Spawn Point Marker

/// Simple spawn point marker
@Godot
class SpawnPoint: Marker3D {

    @GodotState var isActive: Bool = true
    @GodotState var cooldown: Double = 0

    let cooldownDuration: Double = 2.0

    override func _process(delta: Double) {
        if cooldown > 0 {
            cooldown -= delta
            if cooldown <= 0 {
                isActive = true
            }
        }
    }

    func use() {
        guard isActive else { return }
        isActive = false
        cooldown = cooldownDuration
    }
}

// MARK: - Object Pool Example

/// Generic object pool for Godot nodes
final class ObjectPool<T: Node> {

    private var available: [T] = []
    private var inUse: [T] = []

    private let factory: () -> T
    private let maxSize: Int

    init(maxSize: Int = 50, factory: @escaping () -> T) {
        self.maxSize = maxSize
        self.factory = factory
    }

    /// Get an object from the pool
    func acquire() -> T? {
        if let object = available.popLast() {
            inUse.append(object)
            return object
        }
        return createNew()
    }

    /// Return an object to the pool
    func release(_ object: T) {
        inUse.removeAll { $0 === object }
        if available.count < maxSize {
            available.append(object)
        } else {
            object.queueFree()
        }
    }

    private func createNew() -> T? {
        let total = available.count + inUse.count
        guard total < maxSize else { return nil }

        let object = factory()
        inUse.append(object)
        return object
    }

    /// Clear the pool
    func clear() {
        for object in available {
            object.queueFree()
        }
        available.removeAll()

        for object in inUse {
            object.queueFree()
        }
        inUse.removeAll()
    }
}
