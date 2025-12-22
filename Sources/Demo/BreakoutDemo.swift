import SwiftGodotKit
import Game
import Foundation

// MARK: - Breakout Demo

/// Classic Breakout game with paddle, ball, and brick destruction
@Godot
class BreakoutGame: Node2D {

    // MARK: - Constants

    private let paddleWidth: Float = 100
    private let paddleHeight: Float = 15
    private let ballRadius: Float = 8
    private let brickWidth: Float = 60
    private let brickHeight: Float = 20
    private let brickRows: Int = 6
    private let brickCols: Int = 12
    private let gameWidth: Float = 800
    private let gameHeight: Float = 550

    // MARK: - Node References

    @GodotNode("UI/ScoreLabel") var scoreLabel: Label?
    @GodotNode("UI/LivesLabel") var livesLabel: Label?
    @GodotNode("UI/GameOverLabel") var gameOverLabel: Label?
    @GodotNode("BackButton") var backButton: Button?
    @GodotNode("PauseMenu") var pauseMenu: PauseMenu?
    @GodotNode("GameArea") var gameArea: Node2D?

    // MARK: - State

    @GodotState var score: Int = 0
    @GodotState var lives: Int = 3
    @GodotState var isGameOver: Bool = false
    @GodotState var isWin: Bool = false

    private var paddleX: Float = 400
    private var ballPos: Vector2 = Vector2(x: 400, y: 450)
    private var ballVel: Vector2 = Vector2(x: 200, y: -300)
    private var ballLaunched: Bool = false

    private var paddle: ColorRect?
    private var ball: ColorRect?
    private var bricks: [[ColorRect?]] = []
    private var brickHealth: [[Int]] = []

    private let paddleSpeed: Float = 500
    private let ballSpeed: Float = 400

    private var random = GameRandom()

    // Row colors (from top to bottom)
    private let rowColors: [Color] = [
        Color(r: 1.0, g: 0.2, b: 0.2, a: 1.0),  // Red
        Color(r: 1.0, g: 0.5, b: 0.2, a: 1.0),  // Orange
        Color(r: 1.0, g: 0.9, b: 0.2, a: 1.0),  // Yellow
        Color(r: 0.2, g: 0.9, b: 0.2, a: 1.0),  // Green
        Color(r: 0.2, g: 0.6, b: 1.0, a: 1.0),  // Blue
        Color(r: 0.7, g: 0.3, b: 1.0, a: 1.0)   // Purple
    ]

    // MARK: - Lifecycle

    override func _ready() {
        configureNodes()
        setupSignals()
        setupGame()

        GodotContext.log("""

        ╔═══════════════════════════════════════════╗
        ║            Breakout Game                  ║
        ╠═══════════════════════════════════════════╣
        ║  Controls:                                ║
        ║  • Arrow keys / A/D to move paddle        ║
        ║  • Space to launch ball                   ║
        ║  • Break all bricks to win!               ║
        ║  Press ESC for pause menu                 ║
        ╚═══════════════════════════════════════════╝

        """)
    }

    override func _process(delta: Double) {
        handleInput(delta: delta)

        if $score.changed {
            scoreLabel?.text = "Score: \(score)"
        }
        if $lives.changed {
            livesLabel?.text = "Lives: \(lives)"
        }
        if $isGameOver.changed || $isWin.changed {
            gameOverLabel?.visible = isGameOver || isWin
        }

        $score.reset()
        $lives.reset()
        $isGameOver.reset()
        $isWin.reset()

        guard !isGameOver && !isWin else { return }

        if ballLaunched {
            updateBall(delta: delta)
        }
    }

    // MARK: - Setup

    private func configureNodes() {
        $scoreLabel.configure(owner: self)
        $livesLabel.configure(owner: self)
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

    private func setupGame() {
        guard let area = gameArea else { return }

        // Background
        let bg = ColorRect()
        bg.color = Color(r: 0.05, g: 0.05, b: 0.1, a: 1.0)
        bg.customMinimumSize = Vector2(x: gameWidth, y: gameHeight)
        bg.setSize(Vector2(x: gameWidth, y: gameHeight))
        area.addChild(node: bg)

        // Walls
        addWall(area: area, x: -10, y: 0, w: 10, h: gameHeight)  // Left
        addWall(area: area, x: gameWidth, y: 0, w: 10, h: gameHeight)  // Right
        addWall(area: area, x: 0, y: -10, w: gameWidth, h: 10)  // Top

        // Paddle
        let p = ColorRect()
        p.color = Color(r: 0.8, g: 0.8, b: 0.9, a: 1.0)
        p.customMinimumSize = Vector2(x: paddleWidth, y: paddleHeight)
        p.setSize(Vector2(x: paddleWidth, y: paddleHeight))
        area.addChild(node: p)
        paddle = p

        // Ball
        let b = ColorRect()
        b.color = Color(r: 1.0, g: 1.0, b: 1.0, a: 1.0)
        b.customMinimumSize = Vector2(x: ballRadius * 2, y: ballRadius * 2)
        b.setSize(Vector2(x: ballRadius * 2, y: ballRadius * 2))
        area.addChild(node: b)
        ball = b

        createBricks()
        resetBall()
    }

    private func addWall(area: Node2D, x: Float, y: Float, w: Float, h: Float) {
        let wall = ColorRect()
        wall.color = Color(r: 0.3, g: 0.3, b: 0.4, a: 1.0)
        wall.setPosition(Vector2(x: x, y: y))
        wall.customMinimumSize = Vector2(x: w, y: h)
        wall.setSize(Vector2(x: w, y: h))
        area.addChild(node: wall)
    }

    private func createBricks() {
        guard let area = gameArea else { return }

        // Clear existing bricks
        for row in bricks {
            for brick in row {
                brick?.queueFree()
            }
        }
        bricks = []
        brickHealth = []

        let startX: Float = (gameWidth - Float(brickCols) * (brickWidth + 4)) / 2 + 2
        let startY: Float = 50

        for row in 0..<brickRows {
            var brickRow: [ColorRect?] = []
            var healthRow: [Int] = []

            for col in 0..<brickCols {
                let brick = ColorRect()
                brick.color = rowColors[row % rowColors.count]
                brick.customMinimumSize = Vector2(x: brickWidth, y: brickHeight)
                brick.setSize(Vector2(x: brickWidth, y: brickHeight))
                brick.setPosition(Vector2(
                    x: startX + Float(col) * (brickWidth + 4),
                    y: startY + Float(row) * (brickHeight + 4)
                ))
                area.addChild(node: brick)
                brickRow.append(brick)
                healthRow.append(1)
            }
            bricks.append(brickRow)
            brickHealth.append(healthRow)
        }

        score = 0
        lives = 3
        isGameOver = false
        isWin = false
        gameOverLabel?.visible = false
    }

    private func resetBall() {
        paddleX = gameWidth / 2
        ballLaunched = false
        ballPos = Vector2(x: paddleX, y: gameHeight - 80)
        ballVel = Vector2(x: Float(random.nextInt(in: 0...1) == 0 ? -1 : 1) * 200, y: -ballSpeed)
        updatePositions()
    }

    // MARK: - Input

    private func handleInput(delta: Double) {
        if isGameOver || isWin {
            if Input.isActionJustPressed(action: "ui_accept") {
                createBricks()
                resetBall()
            }
            return
        }

        // Move paddle
        if Input.isActionPressed(action: "ui_left") || Input.isActionPressed(action: "move_left") {
            paddleX -= paddleSpeed * Float(delta)
        }
        if Input.isActionPressed(action: "ui_right") || Input.isActionPressed(action: "move_right") {
            paddleX += paddleSpeed * Float(delta)
        }

        // Clamp paddle position
        paddleX = max(paddleWidth / 2, min(gameWidth - paddleWidth / 2, paddleX))

        // Launch ball
        if !ballLaunched && Input.isActionJustPressed(action: "ui_accept") {
            ballLaunched = true
        }

        // Keep ball on paddle if not launched
        if !ballLaunched {
            ballPos.x = paddleX
            ballPos.y = gameHeight - 80
        }

        updatePositions()
    }

    private func updatePositions() {
        paddle?.setPosition(Vector2(x: paddleX - paddleWidth / 2, y: gameHeight - 40))
        ball?.setPosition(Vector2(x: ballPos.x - ballRadius, y: ballPos.y - ballRadius))
    }

    // MARK: - Ball Physics

    private func updateBall(delta: Double) {
        ballPos.x += ballVel.x * Float(delta)
        ballPos.y += ballVel.y * Float(delta)

        // Wall collisions
        if ballPos.x - ballRadius < 0 {
            ballPos.x = ballRadius
            ballVel.x = abs(ballVel.x)
        }
        if ballPos.x + ballRadius > gameWidth {
            ballPos.x = gameWidth - ballRadius
            ballVel.x = -abs(ballVel.x)
        }
        if ballPos.y - ballRadius < 0 {
            ballPos.y = ballRadius
            ballVel.y = abs(ballVel.y)
        }

        // Bottom - lose life
        if ballPos.y + ballRadius > gameHeight {
            lives -= 1
            if lives <= 0 {
                gameOver(win: false)
            } else {
                resetBall()
            }
            return
        }

        // Paddle collision
        let paddleTop = gameHeight - 40
        let paddleLeft = paddleX - paddleWidth / 2
        let paddleRight = paddleX + paddleWidth / 2

        if ballPos.y + ballRadius > paddleTop &&
           ballPos.y - ballRadius < paddleTop + paddleHeight &&
           ballPos.x > paddleLeft &&
           ballPos.x < paddleRight &&
           ballVel.y > 0 {

            // Reflect based on hit position
            let hitPos = (ballPos.x - paddleX) / (paddleWidth / 2)  // -1 to 1
            let angle = hitPos * Float.pi / 3  // -60 to 60 degrees

            let speed = sqrt(ballVel.x * ballVel.x + ballVel.y * ballVel.y)
            ballVel.x = sin(angle) * speed
            ballVel.y = -abs(cos(angle) * speed)

            ballPos.y = paddleTop - ballRadius
        }

        // Brick collision
        checkBrickCollisions()

        updatePositions()
    }

    private func checkBrickCollisions() {
        let startX: Float = (gameWidth - Float(brickCols) * (brickWidth + 4)) / 2 + 2
        let startY: Float = 50

        var bricksRemaining = 0

        for row in 0..<brickRows {
            for col in 0..<brickCols {
                guard brickHealth[row][col] > 0 else { continue }
                bricksRemaining += 1

                let brickX = startX + Float(col) * (brickWidth + 4)
                let brickY = startY + Float(row) * (brickHeight + 4)

                // Check collision
                if ballPos.x + ballRadius > brickX &&
                   ballPos.x - ballRadius < brickX + brickWidth &&
                   ballPos.y + ballRadius > brickY &&
                   ballPos.y - ballRadius < brickY + brickHeight {

                    // Hit brick
                    brickHealth[row][col] -= 1
                    if brickHealth[row][col] <= 0 {
                        bricks[row][col]?.visible = false
                        bricksRemaining -= 1

                        // Points based on row (top rows worth more)
                        score += (brickRows - row) * 10
                    }

                    // Determine reflection direction
                    let overlapLeft = ballPos.x + ballRadius - brickX
                    let overlapRight = brickX + brickWidth - (ballPos.x - ballRadius)
                    let overlapTop = ballPos.y + ballRadius - brickY
                    let overlapBottom = brickY + brickHeight - (ballPos.y - ballRadius)

                    let minOverlapX = min(overlapLeft, overlapRight)
                    let minOverlapY = min(overlapTop, overlapBottom)

                    if minOverlapX < minOverlapY {
                        ballVel.x = -ballVel.x
                    } else {
                        ballVel.y = -ballVel.y
                    }

                    return  // Only one collision per frame
                }
            }
        }

        if bricksRemaining == 0 {
            gameOver(win: true)
        }
    }

    private func gameOver(win: Bool) {
        isGameOver = !win
        isWin = win

        if win {
            gameOverLabel?.text = "You Win! Score: \(score)\nPress SPACE to play again"
            GodotContext.log("Breakout - Victory! Score: \(score)")
        } else {
            gameOverLabel?.text = "Game Over! Score: \(score)\nPress SPACE to restart"
            GodotContext.log("Breakout - Game Over. Score: \(score)")
        }
    }
}
