import SwiftGodotKit
import Game

// MARK: - Rhythm Tapper Demo

/// Rhythm game with falling notes and timing-based scoring
@Godot
class RhythmGame: Node2D {

    // MARK: - Constants

    private let laneCount: Int = 4
    private let laneWidth: Float = 80
    private let laneSpacing: Float = 10
    private let hitZoneY: Float = 500
    private let noteHeight: Float = 30
    private let noteSpeed: Float = 300

    private let perfectWindow: Float = 0.05
    private let goodWindow: Float = 0.12
    private let okWindow: Float = 0.2

    // Lane keys
    private let laneKeys = ["rhythm_d", "rhythm_f", "rhythm_j", "rhythm_k"]
    private let laneColors: [Color] = [
        Color(r: 1.0, g: 0.3, b: 0.3, a: 1.0),  // Red
        Color(r: 0.3, g: 0.8, b: 0.3, a: 1.0),  // Green
        Color(r: 0.3, g: 0.6, b: 1.0, a: 1.0),  // Blue
        Color(r: 1.0, g: 0.8, b: 0.2, a: 1.0)   // Yellow
    ]

    // MARK: - Node References

    @GodotNode("UI/ScoreLabel") var scoreLabel: Label?
    @GodotNode("UI/ComboLabel") var comboLabel: Label?
    @GodotNode("UI/AccuracyLabel") var accuracyLabel: Label?
    @GodotNode("UI/FeedbackLabel") var feedbackLabel: Label?
    @GodotNode("BackButton") var backButton: Button?
    @GodotNode("PauseMenu") var pauseMenu: PauseMenu?
    @GodotNode("GameArea") var gameArea: Node2D?

    // MARK: - State

    @GodotState var score: Int = 0
    @GodotState var combo: Int = 0
    @GodotState var maxCombo: Int = 0

    private var notes: [RhythmNote] = []
    private var laneVisuals: [ColorRect] = []
    private var hitZoneMarkers: [ColorRect] = []
    private var hitFlashes: [ColorRect] = []

    private var totalHits: Int = 0
    private var perfectHits: Int = 0
    private var goodHits: Int = 0
    private var okHits: Int = 0
    private var misses: Int = 0

    private var spawnTimer: Float = 0
    private var gameTime: Float = 0
    private var songEnded: Bool = false

    private var random = GameRandom()
    private var feedbackTimer: Float = 0

    // MARK: - Lifecycle

    override func _ready() {
        configureNodes()
        setupSignals()
        setupLanes()
        registerInputActions()

        GodotContext.log("""

        ╔═══════════════════════════════════════════╗
        ║           Rhythm Tapper                   ║
        ╠═══════════════════════════════════════════╣
        ║  Controls:                                ║
        ║  • D, F, J, K keys for each lane          ║
        ║  • Hit notes when they reach the line    ║
        ║  • Build combos for higher scores!        ║
        ║  Press ESC for pause menu                 ║
        ╚═══════════════════════════════════════════╝

        """)
    }

    override func _process(delta: Double) {
        if $score.changed { scoreLabel?.text = "Score: \(score)" }
        if $combo.changed { comboLabel?.text = "Combo: \(combo)x" }

        $score.reset()
        $combo.reset()

        let totalNotes = perfectHits + goodHits + okHits + misses
        if totalNotes > 0 {
            let accuracy = Float(perfectHits * 100 + goodHits * 75 + okHits * 50) / Float(totalNotes)
            accuracyLabel?.text = String(format: "Accuracy: %.1f%%", accuracy)
        }

        // Feedback fade
        if feedbackTimer > 0 {
            feedbackTimer -= Float(delta)
            if feedbackTimer <= 0 {
                feedbackLabel?.text = ""
            }
        }

        // Update hit flash effects
        for flash in hitFlashes {
            let current = flash.modulate.alpha
            flash.modulate = Color(r: 1, g: 1, b: 1, a: max(0, current - Float(delta) * 5))
        }

        gameTime += Float(delta)

        // Spawn notes
        spawnTimer -= Float(delta)
        if spawnTimer <= 0 && gameTime < 30 {  // 30 second song
            spawnNote()
            spawnTimer = 0.3 + Float(random.nextInt(in: 0...19)) / 100  // Random interval
        }

        // Update notes
        updateNotes(delta: delta)

        // Handle input
        handleInput()
    }

    // MARK: - Setup

    private func configureNodes() {
        $scoreLabel.configure(owner: self)
        $comboLabel.configure(owner: self)
        $accuracyLabel.configure(owner: self)
        $feedbackLabel.configure(owner: self)
        $backButton.configure(owner: self)
        $pauseMenu.configure(owner: self)
        $gameArea.configure(owner: self)
    }

    private func setupSignals() {
        backButton?.on("pressed") { [weak self] in
            _ = self?.getTree()?.changeSceneToFile(path: "res://demo_menu.tscn")
        }
    }

    private func registerInputActions() {
        // Add custom input actions for rhythm keys
        let keys: [(String, Key)] = [
            ("rhythm_d", .d),
            ("rhythm_f", .f),
            ("rhythm_j", .j),
            ("rhythm_k", .k)
        ]

        for (actionName, key) in keys {
            if !InputMap.hasAction(StringName(actionName)) {
                InputMap.addAction(StringName(actionName))
                let event = InputEventKey()
                event.keycode = key
                InputMap.actionAddEvent(action: StringName(actionName), event: event)
            }
        }
    }

    private func setupLanes() {
        guard let area = gameArea else { return }

        let totalWidth = Float(laneCount) * laneWidth + Float(laneCount - 1) * laneSpacing
        let startX = (1024 - totalWidth) / 2

        // Background for lanes
        let bg = ColorRect()
        bg.color = Color(r: 0.1, g: 0.1, b: 0.15, a: 1.0)
        bg.setPosition(Vector2(x: startX - 10, y: 50))
        bg.customMinimumSize = Vector2(x: totalWidth + 20, y: 500)
        bg.setSize(Vector2(x: totalWidth + 20, y: 500))
        area.addChild(node: bg)

        // Lane separators and hit zones
        for i in 0..<laneCount {
            let x = startX + Float(i) * (laneWidth + laneSpacing)

            // Lane background
            let lane = ColorRect()
            lane.color = Color(r: 0.15, g: 0.15, b: 0.2, a: 1.0)
            lane.setPosition(Vector2(x: x, y: 50))
            lane.customMinimumSize = Vector2(x: laneWidth, y: 500)
            lane.setSize(Vector2(x: laneWidth, y: 500))
            area.addChild(node: lane)
            laneVisuals.append(lane)

            // Hit zone marker
            let hitZone = ColorRect()
            hitZone.color = laneColors[i].darkened(amount: 0.5)
            hitZone.setPosition(Vector2(x: x, y: hitZoneY - 10))
            hitZone.customMinimumSize = Vector2(x: laneWidth, y: 20)
            hitZone.setSize(Vector2(x: laneWidth, y: 20))
            area.addChild(node: hitZone)
            hitZoneMarkers.append(hitZone)

            // Hit flash (invisible initially)
            let flash = ColorRect()
            flash.color = laneColors[i]
            flash.setPosition(Vector2(x: x, y: hitZoneY - 30))
            flash.customMinimumSize = Vector2(x: laneWidth, y: 60)
            flash.setSize(Vector2(x: laneWidth, y: 60))
            flash.modulate = Color(r: 1, g: 1, b: 1, a: 0)
            area.addChild(node: flash)
            hitFlashes.append(flash)

            // Lane label
            let label = Label()
            label.text = ["D", "F", "J", "K"][i]
            label.setPosition(Vector2(x: x + laneWidth / 2 - 10, y: hitZoneY + 20))
            label.addThemeFontSizeOverride(name: "font_size", fontSize: 24)
            area.addChild(node: label)
        }

        // Hit line
        let hitLine = ColorRect()
        hitLine.color = Color(r: 1.0, g: 1.0, b: 1.0, a: 0.8)
        hitLine.setPosition(Vector2(x: startX - 10, y: hitZoneY))
        hitLine.customMinimumSize = Vector2(x: totalWidth + 20, y: 3)
        hitLine.setSize(Vector2(x: totalWidth + 20, y: 3))
        area.addChild(node: hitLine)
    }

    // MARK: - Note Management

    private func spawnNote() {
        guard let area = gameArea else { return }

        let lane = random.nextInt(in: 0...(laneCount - 1))
        let totalWidth = Float(laneCount) * laneWidth + Float(laneCount - 1) * laneSpacing
        let startX = (1024 - totalWidth) / 2
        let x = startX + Float(lane) * (laneWidth + laneSpacing)

        let note = RhythmNote(
            lane: lane,
            x: x,
            width: laneWidth,
            height: noteHeight,
            color: laneColors[lane]
        )
        area.addChild(node: note.node)
        notes.append(note)
    }

    private func updateNotes(delta: Double) {
        var toRemove: [Int] = []

        for (index, note) in notes.enumerated() {
            note.y += noteSpeed * Float(delta)
            note.node.setPosition(Vector2(x: note.x, y: note.y))

            // Check if missed (past hit zone)
            if note.y > hitZoneY + 50 && !note.hit {
                note.hit = true
                misses += 1
                combo = 0
                showFeedback("Miss", color: Color(r: 0.5, g: 0.5, b: 0.5, a: 1.0))
            }

            // Remove if off screen
            if note.y > 600 {
                toRemove.append(index)
            }
        }

        for index in toRemove.reversed() {
            notes[index].node.queueFree()
            notes.remove(at: index)
        }
    }

    // MARK: - Input

    private func handleInput() {
        for (lane, actionName) in laneKeys.enumerated() {
            if Input.isActionJustPressed(action: StringName(actionName)) {
                checkHit(lane: lane)
                hitFlashes[lane].modulate = Color(r: 1, g: 1, b: 1, a: 0.8)
            }
        }
    }

    private func checkHit(lane: Int) {
        // Find closest note in this lane
        var closestNote: RhythmNote?
        var closestDistance: Float = Float.greatestFiniteMagnitude

        for note in notes {
            guard note.lane == lane && !note.hit else { continue }

            let distance = abs(note.y - hitZoneY)
            if distance < closestDistance {
                closestDistance = distance
                closestNote = note
            }
        }

        guard let note = closestNote else { return }

        // Convert distance to time
        let timeDiff = closestDistance / noteSpeed

        if timeDiff <= perfectWindow {
            // Perfect!
            perfectHits += 1
            combo += 1
            maxCombo = max(maxCombo, combo)
            score += 100 * (1 + combo / 10)
            note.hit = true
            showFeedback("Perfect!", color: Color(r: 1.0, g: 0.9, b: 0.2, a: 1.0))
            note.node.modulate = Color(r: 1, g: 1, b: 1, a: 0.5)

        } else if timeDiff <= goodWindow {
            // Good
            goodHits += 1
            combo += 1
            maxCombo = max(maxCombo, combo)
            score += 75 * (1 + combo / 10)
            note.hit = true
            showFeedback("Good!", color: Color(r: 0.3, g: 0.9, b: 0.3, a: 1.0))
            note.node.modulate = Color(r: 1, g: 1, b: 1, a: 0.5)

        } else if timeDiff <= okWindow {
            // OK
            okHits += 1
            combo += 1
            score += 50 * (1 + combo / 10)
            note.hit = true
            showFeedback("OK", color: Color(r: 0.5, g: 0.7, b: 0.9, a: 1.0))
            note.node.modulate = Color(r: 1, g: 1, b: 1, a: 0.5)

        } else {
            // Too early/late = miss
            combo = 0
            showFeedback("Miss", color: Color(r: 0.5, g: 0.5, b: 0.5, a: 1.0))
        }
    }

    private func showFeedback(_ text: String, color: Color) {
        feedbackLabel?.text = text
        feedbackLabel?.addThemeColorOverride(name: "font_color", color: color)
        feedbackTimer = 0.5
    }
}

// MARK: - Rhythm Note

class RhythmNote {
    let node: ColorRect
    let lane: Int
    let x: Float
    var y: Float = -30  // Start above screen
    var hit: Bool = false

    init(lane: Int, x: Float, width: Float, height: Float, color: Color) {
        self.lane = lane
        self.x = x

        node = ColorRect()
        node.color = color
        node.customMinimumSize = Vector2(x: width - 4, y: height)
        node.setSize(Vector2(x: width - 4, y: height))
        node.setPosition(Vector2(x: x + 2, y: y))
    }
}
