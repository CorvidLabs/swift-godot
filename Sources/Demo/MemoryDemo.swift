import SwiftGodotKit
import Game

// MARK: - Memory Match Demo

/// Memory matching card game demonstrating grid layouts and state management
@Godot
class MemoryGame: Node2D {

    // MARK: - Constants

    private let gridRows: Int = 4
    private let gridCols: Int = 4
    private let cardWidth: Float = 100
    private let cardHeight: Float = 120
    private let cardSpacing: Float = 15

    // MARK: - Node References

    @GodotNode("UI/MovesLabel") var movesLabel: Label?
    @GodotNode("UI/PairsLabel") var pairsLabel: Label?
    @GodotNode("UI/TimeLabel") var timeLabel: Label?
    @GodotNode("UI/WinLabel") var winLabel: Label?
    @GodotNode("BackButton") var backButton: Button?
    @GodotNode("PauseMenu") var pauseMenu: PauseMenu?
    @GodotNode("CardGrid") var cardGrid: Node2D?

    // MARK: - State

    @GodotState var moves: Int = 0
    @GodotState var pairsFound: Int = 0
    @GodotState var elapsedTime: Float = 0
    @GodotState var isWin: Bool = false

    private var cards: [MemoryCard] = []
    private var firstFlipped: MemoryCard?
    private var secondFlipped: MemoryCard?
    private var isChecking: Bool = false
    private var checkTimer: Float = 0
    private var gameStarted: Bool = false

    private let totalPairs: Int = 8
    private var random = GameRandom()

    // Card pattern colors
    private let patternColors: [Color] = [
        Color(r: 1.0, g: 0.3, b: 0.3, a: 1.0),  // Red
        Color(r: 0.3, g: 0.8, b: 0.3, a: 1.0),  // Green
        Color(r: 0.3, g: 0.5, b: 1.0, a: 1.0),  // Blue
        Color(r: 1.0, g: 0.8, b: 0.2, a: 1.0),  // Yellow
        Color(r: 0.8, g: 0.3, b: 0.8, a: 1.0),  // Purple
        Color(r: 1.0, g: 0.5, b: 0.2, a: 1.0),  // Orange
        Color(r: 0.2, g: 0.8, b: 0.8, a: 1.0),  // Cyan
        Color(r: 0.9, g: 0.4, b: 0.6, a: 1.0)   // Pink
    ]

    // MARK: - Lifecycle

    override func _ready() {
        configureNodes()
        setupSignals()
        setupGame()

        GodotContext.log("""

        ╔═══════════════════════════════════════════╗
        ║          Memory Match Game                ║
        ╠═══════════════════════════════════════════╣
        ║  • Click cards to flip them               ║
        ║  • Match pairs to clear them              ║
        ║  • Find all pairs to win!                 ║
        ║  Press ESC for pause menu                 ║
        ╚═══════════════════════════════════════════╝

        """)
    }

    override func _process(delta: Double) {
        if $moves.changed {
            movesLabel?.text = "Moves: \(moves)"
        }
        if $pairsFound.changed {
            pairsLabel?.text = "Pairs: \(pairsFound)/\(totalPairs)"
        }
        if $isWin.changed {
            winLabel?.visible = isWin
        }

        $moves.reset()
        $pairsFound.reset()
        $isWin.reset()

        // Update timer
        if gameStarted && !isWin {
            elapsedTime += Float(delta)
            timeLabel?.text = String(format: "Time: %.1fs", elapsedTime)
        }

        // Check for match after delay
        if isChecking {
            checkTimer -= Float(delta)
            if checkTimer <= 0 {
                checkMatch()
            }
        }
    }

    override func _input(event: InputEvent?) {
        guard let event = event as? InputEventMouseButton,
              event.pressed,
              event.buttonIndex == .left,
              !isChecking,
              !isWin else { return }

        let mousePos = getGlobalMousePosition()
        handleClick(at: mousePos)
    }

    // MARK: - Setup

    private func configureNodes() {
        $movesLabel.configure(owner: self)
        $pairsLabel.configure(owner: self)
        $timeLabel.configure(owner: self)
        $winLabel.configure(owner: self)
        $backButton.configure(owner: self)
        $pauseMenu.configure(owner: self)
        $cardGrid.configure(owner: self)
    }

    private func setupSignals() {
        backButton?.on("pressed") { [weak self] in
            _ = self?.getTree()?.changeSceneToFile(path: "res://demo_menu.tscn")
        }
    }

    private func setupGame() {
        guard let grid = cardGrid else { return }

        // Clear existing cards
        for card in cards {
            card.node.queueFree()
        }
        cards = []

        // Create shuffled pair values
        var pairValues: [Int] = []
        for i in 0..<totalPairs {
            pairValues.append(i)
            pairValues.append(i)
        }

        // Fisher-Yates shuffle
        for i in stride(from: pairValues.count - 1, through: 1, by: -1) {
            let j = random.nextInt(in: 0...i)
            pairValues.swapAt(i, j)
        }

        // Create cards
        let totalWidth = Float(gridCols) * cardWidth + Float(gridCols - 1) * cardSpacing
        let totalHeight = Float(gridRows) * cardHeight + Float(gridRows - 1) * cardSpacing
        let startX = -totalWidth / 2 + cardWidth / 2
        let startY = -totalHeight / 2 + cardHeight / 2

        var index = 0
        for row in 0..<gridRows {
            for col in 0..<gridCols {
                let x = startX + Float(col) * (cardWidth + cardSpacing)
                let y = startY + Float(row) * (cardHeight + cardSpacing)

                let pairValue = pairValues[index]
                let card = MemoryCard(
                    pairValue: pairValue,
                    color: patternColors[pairValue % patternColors.count],
                    width: cardWidth,
                    height: cardHeight
                )
                card.node.position = Vector2(x: x, y: y)
                grid.addChild(node: card.node)
                cards.append(card)

                index += 1
            }
        }

        // Reset state
        moves = 0
        pairsFound = 0
        elapsedTime = 0
        isWin = false
        gameStarted = false
        firstFlipped = nil
        secondFlipped = nil
        isChecking = false

        winLabel?.visible = false
    }

    // MARK: - Game Logic

    private func handleClick(at globalPos: Vector2) {
        guard let grid = cardGrid else { return }

        let localPos = grid.toLocal(globalPoint: globalPos)

        for card in cards {
            guard !card.isMatched && !card.isFaceUp else { continue }

            let cardRect = Rect2(
                x: card.node.position.x - cardWidth / 2,
                y: card.node.position.y - cardHeight / 2,
                width: cardWidth,
                height: cardHeight
            )

            if cardRect.hasPoint(localPos) {
                flipCard(card)
                break
            }
        }
    }

    private func flipCard(_ card: MemoryCard) {
        if !gameStarted {
            gameStarted = true
        }

        card.flip(faceUp: true)

        if firstFlipped == nil {
            firstFlipped = card
        } else if secondFlipped == nil {
            secondFlipped = card
            moves += 1

            // Start check timer
            isChecking = true
            checkTimer = 0.8
        }
    }

    private func checkMatch() {
        isChecking = false

        guard let first = firstFlipped, let second = secondFlipped else { return }

        if first.pairValue == second.pairValue {
            // Match found
            first.setMatched()
            second.setMatched()
            pairsFound += 1

            if pairsFound >= totalPairs {
                winGame()
            }
        } else {
            // No match - flip back
            first.flip(faceUp: false)
            second.flip(faceUp: false)
        }

        firstFlipped = nil
        secondFlipped = nil
    }

    private func winGame() {
        isWin = true
        winLabel?.text = String(format: "You Win!\nMoves: %d • Time: %.1fs\nClick to play again", moves, elapsedTime)
        GodotContext.log(String(format: "Memory Match - Win! Moves: %d, Time: %.1fs", moves, elapsedTime))
    }
}

// MARK: - Memory Card

class MemoryCard {
    let node: Node2D
    let pairValue: Int
    let color: Color
    var isFaceUp: Bool = false
    var isMatched: Bool = false

    private let backColor = Color(r: 0.2, g: 0.25, b: 0.35, a: 1.0)
    private var frontFace: ColorRect
    private var backFace: ColorRect
    private var pattern: ColorRect

    init(pairValue: Int, color: Color, width: Float, height: Float) {
        self.pairValue = pairValue
        self.color = color
        self.node = Node2D()

        // Back face (card back)
        backFace = ColorRect()
        backFace.color = backColor
        backFace.customMinimumSize = Vector2(x: width, y: height)
        backFace.setSize(Vector2(x: width, y: height))
        backFace.setPosition(Vector2(x: -width / 2, y: -height / 2))
        node.addChild(node: backFace)

        // Pattern on back
        let patternBack = ColorRect()
        patternBack.color = Color(r: 0.15, g: 0.2, b: 0.3, a: 1.0)
        patternBack.customMinimumSize = Vector2(x: width - 20, y: height - 20)
        patternBack.setSize(Vector2(x: width - 20, y: height - 20))
        patternBack.setPosition(Vector2(x: -width / 2 + 10, y: -height / 2 + 10))
        node.addChild(node: patternBack)

        // Front face (hidden initially)
        frontFace = ColorRect()
        frontFace.color = Color(r: 0.9, g: 0.9, b: 0.95, a: 1.0)
        frontFace.customMinimumSize = Vector2(x: width, y: height)
        frontFace.setSize(Vector2(x: width, y: height))
        frontFace.setPosition(Vector2(x: -width / 2, y: -height / 2))
        frontFace.visible = false
        node.addChild(node: frontFace)

        // Pattern (the matchable symbol)
        pattern = ColorRect()
        pattern.color = color
        let patternSize = min(width, height) * 0.6
        pattern.customMinimumSize = Vector2(x: patternSize, y: patternSize)
        pattern.setSize(Vector2(x: patternSize, y: patternSize))
        pattern.setPosition(Vector2(x: -patternSize / 2, y: -patternSize / 2))
        pattern.visible = false
        node.addChild(node: pattern)
    }

    func flip(faceUp: Bool) {
        isFaceUp = faceUp
        frontFace.visible = faceUp
        pattern.visible = faceUp
        backFace.visible = !faceUp
    }

    func setMatched() {
        isMatched = true
        frontFace.color = Color(r: 0.7, g: 0.85, b: 0.7, a: 1.0)
        pattern.modulate = Color(r: 1.0, g: 1.0, b: 1.0, a: 0.7)
    }
}
