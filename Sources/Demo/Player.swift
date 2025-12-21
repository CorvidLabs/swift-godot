import SwiftGodotKit

/// Example Player class demonstrating @GodotState and @GodotNode usage
@Godot
class Player: CharacterBody3D, SignalEmitting {

    // MARK: - Signals

    static let healthChanged = Signal1<Int>("health_changed")
    static let died = Signal0("died")
    static let itemCollected = Signal1<String>("item_collected")

    // MARK: - State

    @GodotState var health: Int = 100
    @GodotState var isAlive: Bool = true
    @GodotState var score: Int = 0
    @GodotState var speed: Float = 5.0
    @GodotState var jumpVelocity: Float = 4.5

    // MARK: - Node References

    @GodotNode("UI/HealthBar") var healthBar: ProgressBar?
    @GodotNode("UI/ScoreLabel") var scoreLabel: Label?
    @GodotNode(.unique("AnimPlayer")) var animator: AnimationPlayer?
    @GodotNode("CollisionShape3D") var collisionShape: CollisionShape3D?

    // MARK: - Constants

    private let gravity: Float = 9.8

    // MARK: - Lifecycle

    override func _ready() {
        $healthBar.configure(owner: self)
        $scoreLabel.configure(owner: self)
        $animator.configure(owner: self)
        $collisionShape.configure(owner: self)

        updateUI()
        GodotContext.log("Player ready!")
    }

    override func _process(delta: Double) {
        handleStateChanges()
        resetChangeFlags()
    }

    override func _physicsProcess(delta: Double) {
        handleMovement(delta: delta)
    }

    // MARK: - State Changes

    private func handleStateChanges() {
        if $health.changed {
            healthBar?.value = Double(health)
            emit(Self.healthChanged.name, Variant(health))

            if let previous = $health.previous, health < previous {
                animator?.play(name: "hurt")
            }

            if health <= 0 && isAlive {
                die()
            }
        }

        if $score.changed {
            scoreLabel?.text = "Score: \(score)"

            if let previous = $score.previous, score > previous {
                animator?.play(name: "score_up")
            }
        }
    }

    private func resetChangeFlags() {
        $health.reset()
        $score.reset()
        $isAlive.reset()
    }

    // MARK: - Movement

    private func handleMovement(delta: Double) {
        guard isAlive else { return }

        var vel = velocity

        if !isOnFloor() {
            vel.y -= gravity * Float(delta)
        }

        if Input.isActionJustPressed(action: "jump") && isOnFloor() {
            vel.y = jumpVelocity
            animator?.play(name: "jump")
        }

        let inputDir = Input.getVector(
            negativeX: "move_left",
            positiveX: "move_right",
            negativeY: "move_forward",
            positiveY: "move_back"
        )

        let direction = (transform.basis * Vector3(x: inputDir.x, y: 0, z: inputDir.y)).normalized()

        if direction != .zero {
            vel.x = direction.x * speed
            vel.z = direction.z * speed
        } else {
            vel.x = vel.x.lerp(to: 0, weight: 0.1)
            vel.z = vel.z.lerp(to: 0, weight: 0.1)
        }

        velocity = vel
        moveAndSlide()
    }

    // MARK: - Public API

    func takeDamage(_ amount: Int) {
        guard isAlive else { return }
        health = max(0, health - amount)
    }

    func heal(_ amount: Int) {
        guard isAlive else { return }
        health = min(100, health + amount)
    }

    func addScore(_ points: Int) {
        score += points
    }

    func collectItem(named itemName: String, points: Int = 10) {
        addScore(points)
        emit(Self.itemCollected.name, Variant(itemName))
    }

    // MARK: - Private

    private func die() {
        isAlive = false
        animator?.play(name: "death")
        emit(Self.died)
        collisionShape?.disabled = true
        GodotContext.log("Player died!")
    }

    private func updateUI() {
        healthBar?.value = Double(health)
        healthBar?.maxValue = 100
        scoreLabel?.text = "Score: \(score)"
    }
}

// MARK: - Float Extension

private extension Float {
    func lerp(to target: Float, weight: Float) -> Float {
        self + (target - self) * weight
    }
}
