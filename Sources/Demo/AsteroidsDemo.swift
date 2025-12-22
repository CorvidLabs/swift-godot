import SwiftGodotKit
import Game
import Foundation

// MARK: - Asteroids Demo

/// Classic Asteroids game with physics-based movement and screen wrap
@Godot
class AsteroidsGame: Node2D {

    // MARK: - Constants

    private let gameWidth: Float = 1024
    private let gameHeight: Float = 600
    private let shipRotSpeed: Float = 5.0
    private let shipThrust: Float = 300.0
    private let maxSpeed: Float = 400.0
    private let friction: Float = 0.98
    private let bulletSpeed: Float = 500.0
    private let bulletLifetime: Float = 1.5

    // MARK: - Node References

    @GodotNode("UI/ScoreLabel") var scoreLabel: Label?
    @GodotNode("UI/LivesLabel") var livesLabel: Label?
    @GodotNode("UI/LevelLabel") var levelLabel: Label?
    @GodotNode("UI/GameOverLabel") var gameOverLabel: Label?
    @GodotNode("BackButton") var backButton: Button?
    @GodotNode("PauseMenu") var pauseMenu: PauseMenu?
    @GodotNode("GameArea") var gameArea: Node2D?

    // MARK: - State

    @GodotState var score: Int = 0
    @GodotState var lives: Int = 3
    @GodotState var level: Int = 1
    @GodotState var isGameOver: Bool = false

    private var shipPos: Vector2 = Vector2(x: 512, y: 300)
    private var shipVel: Vector2 = Vector2(x: 0, y: 0)
    private var shipRot: Float = -Float.pi / 2  // Pointing up
    private var shipNode: Node2D?
    private var isInvincible: Bool = false
    private var invincibleTimer: Float = 0

    private var bullets: [Bullet] = []
    private var asteroids: [Asteroid] = []

    private var shootCooldown: Float = 0
    private let shootDelay: Float = 0.2

    private var random = GameRandom()

    // MARK: - Lifecycle

    override func _ready() {
        configureNodes()
        setupSignals()
        createShip()
        spawnAsteroids(count: 4)

        GodotContext.log("""

        ╔═══════════════════════════════════════════╗
        ║            Asteroids Game                 ║
        ╠═══════════════════════════════════════════╣
        ║  Controls:                                ║
        ║  • Left/Right or A/D to rotate            ║
        ║  • Up or W to thrust                      ║
        ║  • Space to shoot                         ║
        ║  • Destroy all asteroids!                 ║
        ║  Press ESC for pause menu                 ║
        ╚═══════════════════════════════════════════╝

        """)
    }

    override func _process(delta: Double) {
        if $score.changed { scoreLabel?.text = "Score: \(score)" }
        if $lives.changed { livesLabel?.text = "Lives: \(lives)" }
        if $level.changed { levelLabel?.text = "Level: \(level)" }
        if $isGameOver.changed { gameOverLabel?.visible = isGameOver }

        $score.reset()
        $lives.reset()
        $level.reset()
        $isGameOver.reset()

        guard !isGameOver else {
            if Input.isActionJustPressed(action: "ui_accept") {
                restartGame()
            }
            return
        }

        handleInput(delta: delta)
        updateShip(delta: delta)
        updateBullets(delta: delta)
        updateAsteroids(delta: delta)
        checkCollisions()

        if shootCooldown > 0 {
            shootCooldown -= Float(delta)
        }

        if isInvincible {
            invincibleTimer -= Float(delta)
            if invincibleTimer <= 0 {
                isInvincible = false
                shipNode?.modulate = Color(r: 1, g: 1, b: 1, a: 1)
            } else {
                // Blink effect
                let visible = Int(invincibleTimer * 10) % 2 == 0
                shipNode?.modulate = Color(r: 1, g: 1, b: 1, a: visible ? 1.0 : 0.3)
            }
        }
    }

    // MARK: - Setup

    private func configureNodes() {
        $scoreLabel.configure(owner: self)
        $livesLabel.configure(owner: self)
        $levelLabel.configure(owner: self)
        $gameOverLabel.configure(owner: self)
        $backButton.configure(owner: self)
        $pauseMenu.configure(owner: self)
        $gameArea.configure(owner: self)
    }

    private func setupSignals() {
        backButton?.on("pressed") { [weak self] in
            _ = self?.getTree()?.changeSceneToFile(path: "res://demo_menu.tscn")
        }
    }

    private func createShip() {
        guard let area = gameArea else { return }

        let ship = Node2D()

        // Ship body (triangle)
        let body = Polygon2D()
        body.polygon = PackedVector2Array([
            Vector2(x: 15, y: 0),     // Nose
            Vector2(x: -10, y: -10),  // Left wing
            Vector2(x: -5, y: 0),     // Back center
            Vector2(x: -10, y: 10)    // Right wing
        ])
        body.color = Color(r: 0.2, g: 0.8, b: 0.9, a: 1.0)
        ship.addChild(node: body)

        ship.position = shipPos
        ship.rotation = Double(shipRot)
        area.addChild(node: ship)
        shipNode = ship
    }

    private func spawnAsteroids(count: Int) {
        for _ in 0..<count {
            // Spawn away from ship
            var pos: Vector2
            repeat {
                pos = Vector2(
                    x: Float(random.nextInt(in: 0...(Int(gameWidth) - 1))),
                    y: Float(random.nextInt(in: 0...(Int(gameHeight) - 1)))
                )
            } while distance(pos, shipPos) < 150

            let speed = Float(random.nextInt(in: 30...79))
            let angle = Float(random.nextInt(in: 0...359)) * Float.pi / 180

            let asteroid = Asteroid(
                pos: pos,
                vel: Vector2(x: cos(angle) * speed, y: sin(angle) * speed),
                size: .large,
                random: &random
            )
            gameArea?.addChild(node: asteroid.node)
            asteroids.append(asteroid)
        }
    }

    private func restartGame() {
        // Clear everything
        for bullet in bullets {
            bullet.node.queueFree()
        }
        bullets.removeAll()

        for asteroid in asteroids {
            asteroid.node.queueFree()
        }
        asteroids.removeAll()

        shipNode?.queueFree()

        // Reset state
        shipPos = Vector2(x: gameWidth / 2, y: gameHeight / 2)
        shipVel = Vector2(x: 0, y: 0)
        shipRot = -Float.pi / 2
        score = 0
        lives = 3
        level = 1
        isGameOver = false
        isInvincible = false

        createShip()
        spawnAsteroids(count: 4)
        gameOverLabel?.visible = false
    }

    // MARK: - Input

    private func handleInput(delta: Double) {
        // Rotation
        if Input.isActionPressed(action: "ui_left") || Input.isActionPressed(action: "move_left") {
            shipRot -= shipRotSpeed * Float(delta)
        }
        if Input.isActionPressed(action: "ui_right") || Input.isActionPressed(action: "move_right") {
            shipRot += shipRotSpeed * Float(delta)
        }

        // Thrust
        if Input.isActionPressed(action: "ui_up") || Input.isActionPressed(action: "move_up") {
            let thrust = Vector2(x: cos(shipRot) * shipThrust, y: sin(shipRot) * shipThrust)
            shipVel.x += thrust.x * Float(delta)
            shipVel.y += thrust.y * Float(delta)

            // Clamp speed
            let speed = sqrt(shipVel.x * shipVel.x + shipVel.y * shipVel.y)
            if speed > maxSpeed {
                shipVel.x = shipVel.x / speed * maxSpeed
                shipVel.y = shipVel.y / speed * maxSpeed
            }
        }

        // Shoot
        if Input.isActionPressed(action: "ui_accept") && shootCooldown <= 0 {
            shoot()
            shootCooldown = shootDelay
        }
    }

    private func shoot() {
        guard let area = gameArea else { return }

        let bulletPos = Vector2(
            x: shipPos.x + cos(shipRot) * 20,
            y: shipPos.y + sin(shipRot) * 20
        )
        let bulletVel = Vector2(
            x: cos(shipRot) * bulletSpeed + shipVel.x * 0.5,
            y: sin(shipRot) * bulletSpeed + shipVel.y * 0.5
        )

        let bullet = Bullet(pos: bulletPos, vel: bulletVel, lifetime: bulletLifetime)
        area.addChild(node: bullet.node)
        bullets.append(bullet)
    }

    // MARK: - Updates

    private func updateShip(delta: Double) {
        // Apply friction
        shipVel.x *= friction
        shipVel.y *= friction

        // Update position
        shipPos.x += shipVel.x * Float(delta)
        shipPos.y += shipVel.y * Float(delta)

        // Screen wrap
        wrapPosition(&shipPos)

        // Update visual
        shipNode?.position = shipPos
        shipNode?.rotation = Double(shipRot)
    }

    private func updateBullets(delta: Double) {
        var toRemove: [Int] = []

        for (index, bullet) in bullets.enumerated() {
            bullet.pos.x += bullet.vel.x * Float(delta)
            bullet.pos.y += bullet.vel.y * Float(delta)
            bullet.lifetime -= Float(delta)

            wrapPosition(&bullet.pos)
            bullet.node.setPosition(bullet.pos)

            if bullet.lifetime <= 0 {
                toRemove.append(index)
            }
        }

        for index in toRemove.reversed() {
            bullets[index].node.queueFree()
            bullets.remove(at: index)
        }
    }

    private func updateAsteroids(delta: Double) {
        for asteroid in asteroids {
            asteroid.pos.x += asteroid.vel.x * Float(delta)
            asteroid.pos.y += asteroid.vel.y * Float(delta)
            asteroid.rotation += asteroid.rotSpeed * Float(delta)

            wrapPosition(&asteroid.pos)
            asteroid.node.position = asteroid.pos
            asteroid.node.rotation = Double(asteroid.rotation)
        }
    }

    private func wrapPosition(_ pos: inout Vector2) {
        if pos.x < -50 { pos.x = gameWidth + 50 }
        if pos.x > gameWidth + 50 { pos.x = -50 }
        if pos.y < -50 { pos.y = gameHeight + 50 }
        if pos.y > gameHeight + 50 { pos.y = -50 }
    }

    // MARK: - Collisions

    private func checkCollisions() {
        var bulletsToRemove: [Int] = []
        var asteroidsToRemove: [Int] = []
        var asteroidsToAdd: [Asteroid] = []

        // Bullet-asteroid collisions
        for (bIndex, bullet) in bullets.enumerated() {
            for (aIndex, asteroid) in asteroids.enumerated() {
                if asteroidsToRemove.contains(aIndex) { continue }

                let dist = distance(bullet.pos, asteroid.pos)
                if dist < asteroid.radius {
                    bulletsToRemove.append(bIndex)
                    asteroidsToRemove.append(aIndex)

                    // Score based on size
                    switch asteroid.size {
                    case .large: score += 20
                    case .medium: score += 50
                    case .small: score += 100
                    }

                    // Split asteroid
                    if let smaller = asteroid.size.smaller {
                        for _ in 0..<2 {
                            let angle = Float(random.nextInt(in: 0...359)) * Float.pi / 180
                            let speed = Float(random.nextInt(in: 40...99))
                            let newAsteroid = Asteroid(
                                pos: asteroid.pos,
                                vel: Vector2(x: cos(angle) * speed, y: sin(angle) * speed),
                                size: smaller,
                                random: &random
                            )
                            asteroidsToAdd.append(newAsteroid)
                        }
                    }

                    break
                }
            }
        }

        // Remove destroyed
        for index in bulletsToRemove.reversed() {
            if index < bullets.count {
                bullets[index].node.queueFree()
                bullets.remove(at: index)
            }
        }

        for index in asteroidsToRemove.sorted().reversed() {
            if index < asteroids.count {
                asteroids[index].node.queueFree()
                asteroids.remove(at: index)
            }
        }

        // Add new asteroids
        for asteroid in asteroidsToAdd {
            gameArea?.addChild(node: asteroid.node)
            asteroids.append(asteroid)
        }

        // Ship-asteroid collision
        if !isInvincible {
            for asteroid in asteroids {
                let dist = distance(shipPos, asteroid.pos)
                if dist < asteroid.radius + 10 {
                    shipHit()
                    break
                }
            }
        }

        // Level complete
        if asteroids.isEmpty {
            level += 1
            spawnAsteroids(count: 3 + level)
        }
    }

    private func shipHit() {
        lives -= 1

        if lives <= 0 {
            isGameOver = true
            gameOverLabel?.text = "Game Over!\nScore: \(score)\nPress SPACE to restart"
            GodotContext.log("Asteroids - Game Over. Score: \(score)")
        } else {
            // Respawn with invincibility
            shipPos = Vector2(x: gameWidth / 2, y: gameHeight / 2)
            shipVel = Vector2(x: 0, y: 0)
            isInvincible = true
            invincibleTimer = 3.0
        }
    }

    private func distance(_ a: Vector2, _ b: Vector2) -> Float {
        let dx = a.x - b.x
        let dy = a.y - b.y
        return sqrt(dx * dx + dy * dy)
    }
}

// MARK: - Asteroid Size

enum AsteroidSize {
    case large, medium, small

    var radius: Float {
        switch self {
        case .large: return 40
        case .medium: return 25
        case .small: return 12
        }
    }

    var smaller: AsteroidSize? {
        switch self {
        case .large: return .medium
        case .medium: return .small
        case .small: return nil
        }
    }
}

// MARK: - Asteroid

class Asteroid {
    let node: Node2D
    let size: AsteroidSize
    var pos: Vector2
    var vel: Vector2
    var rotation: Float = 0
    var rotSpeed: Float

    var radius: Float { size.radius }

    init(pos: Vector2, vel: Vector2, size: AsteroidSize, random: inout GameRandom) {
        self.pos = pos
        self.vel = vel
        self.size = size
        self.rotSpeed = Float(random.nextInt(in: -2...2))

        node = Node2D()
        node.position = pos

        // Create irregular polygon
        let polygon = Polygon2D()
        var points: [Vector2] = []
        let numPoints = 8

        for i in 0..<numPoints {
            let angle = Float(i) * (2 * Float.pi / Float(numPoints))
            let radiusVar = size.radius * (0.7 + Float(random.nextInt(in: 0...29)) / 100)
            points.append(Vector2(
                x: cos(angle) * radiusVar,
                y: sin(angle) * radiusVar
            ))
        }

        polygon.polygon = PackedVector2Array(points)
        polygon.color = Color(r: 0.5, g: 0.45, b: 0.4, a: 1.0)
        node.addChild(node: polygon)

        // Outline
        let outline = Line2D()
        outline.points = PackedVector2Array(points + [points[0]])
        outline.width = 2
        outline.defaultColor = Color(r: 0.7, g: 0.65, b: 0.6, a: 1.0)
        node.addChild(node: outline)
    }
}

// MARK: - Bullet

class Bullet {
    let node: ColorRect
    var pos: Vector2
    var vel: Vector2
    var lifetime: Float

    init(pos: Vector2, vel: Vector2, lifetime: Float) {
        self.pos = pos
        self.vel = vel
        self.lifetime = lifetime

        node = ColorRect()
        node.color = Color(r: 1.0, g: 1.0, b: 0.5, a: 1.0)
        node.customMinimumSize = Vector2(x: 4, y: 4)
        node.setSize(Vector2(x: 4, y: 4))
        node.setPosition(pos)
    }
}
