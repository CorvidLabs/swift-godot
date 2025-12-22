import SwiftGodotKit
import Game

// MARK: - Snake Demo

/// Classic Snake game demonstrating grid-based movement and state management
@Godot
class SnakeGame: Node2D {

    // MARK: - Constants

    private let gridSize: Int = 20
    private let cellSize: Float = 20
    private let gridWidth: Int = 30
    private let gridHeight: Int = 25

    // MARK: - Node References

    @GodotNode("UI/ScoreLabel") var scoreLabel: Label?
    @GodotNode("UI/HighScoreLabel") var highScoreLabel: Label?
    @GodotNode("UI/GameOverLabel") var gameOverLabel: Label?
    @GodotNode("BackButton") var backButton: Button?
    @GodotNode("PauseMenu") var pauseMenu: PauseMenu?
    @GodotNode("GameArea") var gameArea: Node2D?

    // MARK: - State

    @GodotState var score: Int = 0
    @GodotState var highScore: Int = 0
    @GodotState var isGameOver: Bool = false

    private var snake: [Vector2i] = []
    private var direction: Vector2i = Vector2i(x: 1, y: 0)
    private var nextDirection: Vector2i = Vector2i(x: 1, y: 0)
    private var food: Vector2i = Vector2i(x: 15, y: 12)

    private var moveTimer: Float = 0
    private var moveInterval: Float = 0.12

    private var snakeSegments: [ColorRect] = []
    private var foodSprite: ColorRect?
    private var gridBackground: ColorRect?

    private var random = GameRandom()

    // MARK: - Lifecycle

    override func _ready() {
        configureNodes()
        setupSignals()
        setupGrid()
        startGame()

        GodotContext.log("""

        ╔═══════════════════════════════════════════╗
        ║              Snake Game                   ║
        ╠═══════════════════════════════════════════╣
        ║  Controls:                                ║
        ║  • Arrow keys / WASD to change direction  ║
        ║  • Eat food to grow                       ║
        ║  • Don't hit walls or yourself!           ║
        ║  Press ESC for pause menu                 ║
        ╚═══════════════════════════════════════════╝

        """)
    }

    override func _process(delta: Double) {
        handleInput()

        if $score.changed {
            scoreLabel?.text = "Score: \(score)"
        }
        if $highScore.changed {
            highScoreLabel?.text = "High Score: \(highScore)"
        }
        if $isGameOver.changed {
            gameOverLabel?.visible = isGameOver
        }

        $score.reset()
        $highScore.reset()
        $isGameOver.reset()

        guard !isGameOver else { return }

        moveTimer += Float(delta)
        if moveTimer >= moveInterval {
            moveTimer = 0
            moveSnake()
        }
    }

    // MARK: - Setup

    private func configureNodes() {
        $scoreLabel.configure(owner: self)
        $highScoreLabel.configure(owner: self)
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

    private func setupGrid() {
        guard let area = gameArea else { return }

        // Grid background
        let bg = ColorRect()
        bg.color = Color(r: 0.1, g: 0.15, b: 0.1, a: 1.0)
        bg.customMinimumSize = Vector2(x: Float(gridWidth) * cellSize, y: Float(gridHeight) * cellSize)
        bg.setSize(Vector2(x: Float(gridWidth) * cellSize, y: Float(gridHeight) * cellSize))
        area.addChild(node: bg)
        gridBackground = bg

        // Grid lines (subtle)
        for x in 0...gridWidth {
            let line = ColorRect()
            line.color = Color(r: 0.15, g: 0.2, b: 0.15, a: 0.5)
            line.setPosition(Vector2(x: Float(x) * cellSize, y: 0))
            line.customMinimumSize = Vector2(x: 1, y: Float(gridHeight) * cellSize)
            line.setSize(Vector2(x: 1, y: Float(gridHeight) * cellSize))
            area.addChild(node: line)
        }
        for y in 0...gridHeight {
            let line = ColorRect()
            line.color = Color(r: 0.15, g: 0.2, b: 0.15, a: 0.5)
            line.setPosition(Vector2(x: 0, y: Float(y) * cellSize))
            line.customMinimumSize = Vector2(x: Float(gridWidth) * cellSize, y: 1)
            line.setSize(Vector2(x: Float(gridWidth) * cellSize, y: 1))
            area.addChild(node: line)
        }

        // Food sprite
        let food = ColorRect()
        food.color = Color(r: 1.0, g: 0.3, b: 0.3, a: 1.0)
        food.customMinimumSize = Vector2(x: cellSize - 2, y: cellSize - 2)
        food.setSize(Vector2(x: cellSize - 2, y: cellSize - 2))
        area.addChild(node: food)
        foodSprite = food
    }

    private func startGame() {
        // Clear old snake
        for segment in snakeSegments {
            segment.queueFree()
        }
        snakeSegments.removeAll()

        // Initialize snake in the center
        let startX = gridWidth / 2
        let startY = gridHeight / 2
        snake = [
            Vector2i(x: Int32(startX), y: Int32(startY)),
            Vector2i(x: Int32(startX - 1), y: Int32(startY)),
            Vector2i(x: Int32(startX - 2), y: Int32(startY))
        ]

        direction = Vector2i(x: 1, y: 0)
        nextDirection = Vector2i(x: 1, y: 0)
        score = 0
        isGameOver = false
        moveInterval = 0.12
        moveTimer = 0

        spawnFood()
        updateSnakeVisuals()

        gameOverLabel?.visible = false
    }

    // MARK: - Input

    private func handleInput() {
        if isGameOver {
            if Input.isActionJustPressed(action: "ui_accept") {
                startGame()
            }
            return
        }

        // Prevent 180-degree turns
        if Input.isActionJustPressed(action: "ui_up") || Input.isActionJustPressed(action: "move_up") {
            if direction.y != 1 {
                nextDirection = Vector2i(x: 0, y: -1)
            }
        } else if Input.isActionJustPressed(action: "ui_down") || Input.isActionJustPressed(action: "move_down") {
            if direction.y != -1 {
                nextDirection = Vector2i(x: 0, y: 1)
            }
        } else if Input.isActionJustPressed(action: "ui_left") || Input.isActionJustPressed(action: "move_left") {
            if direction.x != 1 {
                nextDirection = Vector2i(x: -1, y: 0)
            }
        } else if Input.isActionJustPressed(action: "ui_right") || Input.isActionJustPressed(action: "move_right") {
            if direction.x != -1 {
                nextDirection = Vector2i(x: 1, y: 0)
            }
        }
    }

    // MARK: - Game Logic

    private func moveSnake() {
        direction = nextDirection

        // Calculate new head position
        let head = snake[0]
        let newHead = Vector2i(x: head.x + direction.x, y: head.y + direction.y)

        // Check wall collision
        if newHead.x < 0 || newHead.x >= Int32(gridWidth) ||
           newHead.y < 0 || newHead.y >= Int32(gridHeight) {
            gameOver()
            return
        }

        // Check self collision
        for segment in snake {
            if newHead.x == segment.x && newHead.y == segment.y {
                gameOver()
                return
            }
        }

        // Move snake
        snake.insert(newHead, at: 0)

        // Check food collision
        if newHead.x == food.x && newHead.y == food.y {
            score += 10
            if score > highScore {
                highScore = score
            }

            // Speed up slightly
            moveInterval = max(0.05, moveInterval - 0.002)

            spawnFood()
        } else {
            // Remove tail if no food eaten
            snake.removeLast()
        }

        updateSnakeVisuals()
    }

    private func spawnFood() {
        var validPosition = false
        var attempts = 0

        while !validPosition && attempts < 100 {
            let x = random.nextInt(in: 0...(gridWidth - 1))
            let y = random.nextInt(in: 0...(gridHeight - 1))
            food = Vector2i(x: Int32(x), y: Int32(y))

            validPosition = true
            for segment in snake {
                if segment.x == food.x && segment.y == food.y {
                    validPosition = false
                    break
                }
            }
            attempts += 1
        }

        // Update food position
        foodSprite?.setPosition(Vector2(
            x: Float(food.x) * cellSize + 1,
            y: Float(food.y) * cellSize + 1
        ))
    }

    private func updateSnakeVisuals() {
        guard let area = gameArea else { return }

        // Add new segments if needed
        while snakeSegments.count < snake.count {
            let segment = ColorRect()
            segment.customMinimumSize = Vector2(x: cellSize - 2, y: cellSize - 2)
            segment.setSize(Vector2(x: cellSize - 2, y: cellSize - 2))
            area.addChild(node: segment)
            snakeSegments.append(segment)
        }

        // Remove excess segments
        while snakeSegments.count > snake.count {
            snakeSegments.last?.queueFree()
            snakeSegments.removeLast()
        }

        // Update positions and colors
        for (index, segment) in snakeSegments.enumerated() {
            let pos = snake[index]
            segment.setPosition(Vector2(
                x: Float(pos.x) * cellSize + 1,
                y: Float(pos.y) * cellSize + 1
            ))

            // Gradient from head (bright green) to tail (dark green)
            let t = Float(index) / Float(max(1, snake.count - 1))
            let green = 0.9 - t * 0.5
            let red = 0.2 + t * 0.1
            segment.color = Color(r: red, g: green, b: 0.2, a: 1.0)
        }
    }

    private func gameOver() {
        isGameOver = true
        gameOverLabel?.text = "Game Over! Score: \(score)\nPress SPACE to restart"
        GodotContext.log("Snake Game Over! Final Score: \(score)")
    }
}
