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

    private var spawnedEnemies: [Enemy] = []
    private var spawnQueue: Int = 0
    private var spawnTimer: Double = 0

    // MARK: - Configuration

    var spawnDelay: Double = 0.5
    var maxConcurrentEnemies: Int = 20

    // MARK: - Node References

    @GodotNode("SpawnPoints") var spawnPointsContainer: Node3D?
    @GodotNode(.unique("Player")) var player: Player?

    // MARK: - Lifecycle

    override func _ready() {
        $spawnPointsContainer.configure(owner: self)
        $player.configure(owner: self)
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
        let enemy = Enemy()
        enemy.name = "Enemy_\(spawnedEnemies.count)"
        enemy.target = player

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

// MARK: - Enemy

/// Enemy that chases the player and deals damage on contact
@Godot
class Enemy: CharacterBody3D {

    // MARK: - Signals

    static let defeated = Signal0("defeated")

    // MARK: - State

    @GodotState var health: Int = 1
    @GodotState var speed: Float = 3.0

    weak var target: Player?

    private var mesh: MeshInstance3D?
    private var collision: CollisionShape3D?
    private var attackCooldown: Double = 0

    // MARK: - Lifecycle

    override func _ready() {
        setupVisuals()
        setupCollision()
    }

    override func _physicsProcess(delta: Double) {
        moveTowardTarget(delta: delta)
        checkPlayerCollision(delta: delta)
    }

    // MARK: - Setup

    private func setupVisuals() {
        let meshInstance = MeshInstance3D()

        let capsule = CapsuleMesh()
        capsule.radius = 0.4
        capsule.height = 1.5
        meshInstance.mesh = capsule

        let material = StandardMaterial3D()
        material.albedoColor = Color(r: 0.9, g: 0.2, b: 0.2, a: 1.0)
        meshInstance.materialOverride = material

        meshInstance.position = Vector3(x: 0, y: 0.75, z: 0)
        addChild(node: meshInstance)
        self.mesh = meshInstance
    }

    private func setupCollision() {
        let shape = CollisionShape3D()

        let capsule = CapsuleShape3D()
        capsule.radius = 0.4
        capsule.height = 1.5
        shape.shape = capsule

        shape.position = Vector3(x: 0, y: 0.75, z: 0)
        addChild(node: shape)
        self.collision = shape
    }

    // MARK: - AI

    private func moveTowardTarget(delta: Double) {
        guard let target = target, target.isAlive else { return }

        let direction = (target.globalPosition - globalPosition).normalized()
        let moveVelocity = Vector3(x: direction.x * speed, y: 0, z: direction.z * speed)

        velocity = moveVelocity
        moveAndSlide()
    }

    private func checkPlayerCollision(delta: Double) {
        attackCooldown -= delta
        guard attackCooldown <= 0 else { return }

        guard let target = target, target.isAlive else { return }

        let distance = globalPosition.distanceTo(target.globalPosition)
        if distance < 1.2 {
            target.takeDamage(10)
            attackCooldown = 1.0

            // Knockback
            let knockback = (globalPosition - target.globalPosition).normalized() * 2
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
