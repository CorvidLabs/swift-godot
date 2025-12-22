import SwiftGodotKit

// MARK: - Platformer Demo Scene

/// Platformer demo showcasing physics, NodeController, and game patterns
@Godot
class PlatformerScene: Node2D {

    // MARK: - Node References

    @GodotNode(.unique("PlatformerPlayer")) var player: PlatformerPlayer?
    @GodotNode("UI/ScoreLabel") var scoreLabel: Label?
    @GodotNode("UI/CoinsLabel") var coinsLabel: Label?
    @GodotNode("BackButton") var backButton: Button?
    @GodotNode("Platforms") var platformContainer: Node2D?

    // MARK: - State

    @GodotState var score: Int = 0
    @GodotState var coins: Int = 0

    // MARK: - Lifecycle

    override func _ready() {
        configureNodes()
        setupSignals()
        generatePlatforms()

        GodotContext.log("""

        ╔═══════════════════════════════════════════╗
        ║          Platformer Demo                  ║
        ╠═══════════════════════════════════════════╣
        ║  Controls:                                ║
        ║  • Arrow keys / WASD to move              ║
        ║  • Space / W / Up to jump                 ║
        ║  • Collect coins for points!              ║
        ╚═══════════════════════════════════════════╝

        """)
    }

    override func _process(delta: Double) {
        if $score.changed {
            scoreLabel?.text = "Score: \(score)"
        }
        if $coins.changed {
            coinsLabel?.text = "Coins: \(coins)"
        }

        $score.reset()
        $coins.reset()

        // Respawn if player falls
        if let player = player, player.position.y > 600 {
            player.position = Vector2(x: 400, y: 100)
        }
    }

    // MARK: - Setup

    private func configureNodes() {
        $player.configure(owner: self)
        $scoreLabel.configure(owner: self)
        $coinsLabel.configure(owner: self)
        $backButton.configure(owner: self)
        $platformContainer.configure(owner: self)
    }

    private func setupSignals() {
        backButton?.on("pressed") { [weak self] in
            _ = self?.getTree()?.changeSceneToFile(path: "res://demo_menu.tscn")
        }

        player?.on(PlatformerPlayer.coinCollected.name) { [weak self] in
            self?.coins += 1
            self?.score += 10
        }
    }

    // MARK: - Platform Generation using NodeController

    private func generatePlatforms() {
        guard let container = platformContainer else { return }

        // Use NodeController pattern to build platform hierarchy
        let levelController = LevelController()
        let levelNode = levelController.build()
        container.addChild(node: levelNode)

        // Add some collectible coins
        spawnCoins()
    }

    private func spawnCoins() {
        let coinPositions: [Vector2] = [
            Vector2(x: 300, y: 250),
            Vector2(x: 500, y: 200),
            Vector2(x: 700, y: 300),
            Vector2(x: 200, y: 350),
            Vector2(x: 600, y: 150)
        ]

        for pos in coinPositions {
            let coin = Coin()
            coin.position = pos
            coin.collector = player
            addChild(node: coin)
        }
    }
}

// MARK: - Platformer Player

/// 2D platformer character with jump mechanics
@Godot
class PlatformerPlayer: CharacterBody2D, SignalEmitting {

    // MARK: - Signals

    static let coinCollected = Signal0("coin_collected")
    static let jumped = Signal0("jumped")
    static let landed = Signal0("landed")

    // MARK: - State

    @GodotState var speed: Float = 250.0
    @GodotState var jumpVelocity: Float = -400.0
    @GodotState var wasOnFloor: Bool = false

    private let gravity: Float = 800.0

    // MARK: - Visuals

    private var sprite: ColorRect?
    private var collision: CollisionShape2D?

    // MARK: - Lifecycle

    override func _ready() {
        setupVisuals()
        setupCollision()
    }

    override func _physicsProcess(delta: Double) {
        handleGravity(delta: delta)
        handleJump()
        handleMovement()
        moveAndSlide()
        checkLanding()
    }

    // MARK: - Setup

    private func setupVisuals() {
        let rect = ColorRect()
        rect.color = Color(r: 0.2, g: 0.7, b: 0.9, a: 1.0)
        rect.customMinimumSize = Vector2(x: 32, y: 48)
        rect.setSize(Vector2(x: 32, y: 48))
        rect.setPosition(Vector2(x: -16, y: -48))
        addChild(node: rect)
        self.sprite = rect
    }

    private func setupCollision() {
        let shape = CollisionShape2D()
        let rect = RectangleShape2D()
        rect.size = Vector2(x: 32, y: 48)
        shape.shape = rect
        shape.position = Vector2(x: 0, y: -24)
        addChild(node: shape)
        self.collision = shape
    }

    // MARK: - Physics

    private func handleGravity(delta: Double) {
        if !isOnFloor() {
            velocity.y += gravity * Float(delta)
        }
    }

    private func handleJump() {
        let jumpPressed = Input.isActionJustPressed(action: "ui_accept") ||
                          Input.isActionJustPressed(action: "ui_up") ||
                          Input.isActionJustPressed(action: "jump")

        if jumpPressed && isOnFloor() {
            velocity.y = jumpVelocity
            emit(Self.jumped)
        }
    }

    private func handleMovement() {
        var direction: Float = 0

        if Input.isActionPressed(action: "ui_left") || Input.isActionPressed(action: "move_left") {
            direction -= 1
        }
        if Input.isActionPressed(action: "ui_right") || Input.isActionPressed(action: "move_right") {
            direction += 1
        }

        velocity.x = direction * speed
    }

    private func checkLanding() {
        let onFloor = isOnFloor()
        if onFloor && !wasOnFloor {
            emit(Self.landed)
        }
        wasOnFloor = onFloor
    }

    // MARK: - Coin Collection

    func collectCoin() {
        emit(Self.coinCollected)
    }
}

// MARK: - Platform (using NodeController)

/// Platform controller demonstrating NodeController pattern
class PlatformController: NodeController {
    typealias NodeType = StaticBody2D

    let node = StaticBody2D()
    let width: Float
    let height: Float
    let color: Color

    init(width: Float = 100, height: Float = 20, color: Color = Color(r: 0.4, g: 0.3, b: 0.2, a: 1.0)) {
        self.width = width
        self.height = height
        self.color = color
    }

    var children: [any NodeController] { [] }

    func configure() {
        // Add visual
        let rect = ColorRect()
        rect.color = color
        rect.customMinimumSize = Vector2(x: width, y: height)
        rect.setSize(Vector2(x: width, y: height))
        rect.setPosition(Vector2(x: -width / 2, y: -height / 2))
        node.addChild(node: rect)

        // Add collision
        let shape = CollisionShape2D()
        let rectShape = RectangleShape2D()
        rectShape.size = Vector2(x: width, y: height)
        shape.shape = rectShape
        node.addChild(node: shape)
    }
}

// MARK: - Level Controller

/// Level layout using NodeController hierarchy
class LevelController: NodeController {
    typealias NodeType = Node2D

    let node = Node2D()

    var children: [any NodeController] {
        // Create platforms at various positions
        [
            PositionedPlatform(x: 400, y: 500, width: 800, height: 30),  // Ground
            PositionedPlatform(x: 200, y: 400, width: 150),
            PositionedPlatform(x: 500, y: 350, width: 120),
            PositionedPlatform(x: 300, y: 280, width: 100),
            PositionedPlatform(x: 600, y: 220, width: 130),
            PositionedPlatform(x: 150, y: 180, width: 80),
            PositionedPlatform(x: 700, y: 400, width: 100)
        ]
    }

    func configure() {
        node.name = "Level"
    }

    func didAddChildren() {
        GodotContext.log("Level generated with \(children.count) platforms")
    }
}

/// Helper to position platforms
class PositionedPlatform: NodeController {
    typealias NodeType = StaticBody2D

    let node = StaticBody2D()
    let x: Float
    let y: Float
    let width: Float
    let height: Float

    init(x: Float, y: Float, width: Float = 100, height: Float = 20) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    }

    var children: [any NodeController] { [] }

    func configure() {
        node.position = Vector2(x: x, y: y)

        // Visual
        let rect = ColorRect()
        rect.color = Color(r: 0.35, g: 0.25, b: 0.15, a: 1.0)
        rect.customMinimumSize = Vector2(x: width, y: height)
        rect.setSize(Vector2(x: width, y: height))
        rect.setPosition(Vector2(x: -width / 2, y: -height / 2))
        node.addChild(node: rect)

        // Collision
        let shape = CollisionShape2D()
        let rectShape = RectangleShape2D()
        rectShape.size = Vector2(x: width, y: height)
        shape.shape = rectShape
        node.addChild(node: shape)
    }
}

// MARK: - Collectible Coin

/// Collectible coin
@Godot
class Coin: Area2D {

    weak var collector: PlatformerPlayer?

    private var sprite: ColorRect?
    private var collected = false
    private var fadeTimer: Float = 0
    private var isFading = false

    override func _ready() {
        setupVisuals()
        setupCollision()
        setupCollection()
    }

    override func _process(delta: Double) {
        if isFading {
            fadeTimer += Float(delta) * 4
            let scaleVal = 1.0 + fadeTimer * 0.3
            scale = Vector2(x: scaleVal, y: scaleVal)
            modulate = Color(r: 1, g: 1, b: 1, a: max(0, 1 - fadeTimer))

            if fadeTimer >= 1.0 {
                queueFree()
            }
        }
    }

    private func setupVisuals() {
        let rect = ColorRect()
        rect.color = Color(r: 1.0, g: 0.85, b: 0.0, a: 1.0)
        rect.customMinimumSize = Vector2(x: 20, y: 20)
        rect.setSize(Vector2(x: 20, y: 20))
        rect.setPosition(Vector2(x: -10, y: -10))
        addChild(node: rect)
        self.sprite = rect
    }

    private func setupCollision() {
        let shape = CollisionShape2D()
        let circle = CircleShape2D()
        circle.radius = 12
        shape.shape = circle
        addChild(node: shape)
    }

    private func setupCollection() {
        on("body_entered") { [weak self] in
            self?.collect()
        }
    }

    private func collect() {
        guard !collected else { return }
        collected = true
        collector?.collectCoin()
        isFading = true
    }
}
