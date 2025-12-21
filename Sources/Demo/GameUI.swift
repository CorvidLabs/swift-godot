import SwiftGodotKit

/// Example UI class demonstrating @GodotNode and signal connections
@Godot
class GameUI: Control, SignalReceiving {

    // MARK: - Signals

    static let pauseRequested = Signal0("pause_requested")
    static let resumeRequested = Signal0("resume_requested")
    static let restartRequested = Signal0("restart_requested")

    // MARK: - State

    @GodotState var isPaused: Bool = false

    // MARK: - Node References (various lookup strategies)

    // By path
    @GodotNode("HUD/HealthBar") var healthBar: ProgressBar?
    @GodotNode("HUD/ScoreLabel") var scoreLabel: Label?
    @GodotNode("HUD/WaveLabel") var waveLabel: Label?

    // By unique name (% in scene tree)
    @GodotNode(.unique("PauseMenu")) var pauseMenu: Control?
    @GodotNode(.unique("GameOverPanel")) var gameOverPanel: Control?

    // By group
    @GodotNode(.group("buttons")) var firstButton: Button?

    // MARK: - Signal Handlers

    @GodotSignal("pressed") var onPausePressed: () -> Void = {}
    @GodotSignal("pressed") var onResumePressed: () -> Void = {}
    @GodotSignal("pressed") var onRestartPressed: () -> Void = {}

    // MARK: - Lifecycle

    override func _ready() {
        configureNodeReferences()
        setupSignalHandlers()
        hideMenus()
    }

    override func _process(delta: Double) {
        // Handle pause state changes
        if $isPaused.changed {
            pauseMenu?.visible = isPaused
            getTree()?.paused = isPaused
        }
        $isPaused.reset()

        // Process wave animation
        processWaveAnimation(delta: delta)
    }

    override func _input(event: InputEvent?) {
        guard let event = event else { return }

        // Handle pause key
        if event.isActionPressed(action: "pause") {
            togglePause()
        }
    }

    // MARK: - Configuration

    private func configureNodeReferences() {
        $healthBar.configure(owner: self)
        $scoreLabel.configure(owner: self)
        $waveLabel.configure(owner: self)
        $pauseMenu.configure(owner: self)
        $gameOverPanel.configure(owner: self)
        $firstButton.configure(owner: self)
    }

    private func setupSignalHandlers() {
        // Configure signal handlers
        onPausePressed = { [weak self] in
            self?.togglePause()
        }

        onResumePressed = { [weak self] in
            self?.resume()
        }

        onRestartPressed = { [weak self] in
            self?.requestRestart()
        }
    }

    private func hideMenus() {
        pauseMenu?.visible = false
        gameOverPanel?.visible = false
    }

    // MARK: - UI Updates

    func updateHealth(_ value: Int) {
        healthBar?.value = Double(value)

        // Change color based on health
        if value <= 25 {
            healthBar?.modulate = Color(r: 1, g: 0.3, b: 0.3, a: 1)
        } else if value <= 50 {
            healthBar?.modulate = Color(r: 1, g: 0.8, b: 0.3, a: 1)
        } else {
            healthBar?.modulate = Color(r: 0.3, g: 1, b: 0.3, a: 1)
        }
    }

    func updateScore(_ value: Int) {
        scoreLabel?.text = "Score: \(value)"
    }

    func updateWave(_ wave: Int) {
        waveLabel?.text = "Wave \(wave)"

        // Scale up for emphasis (will be animated back in _process)
        waveLabel?.scale = Vector2(x: 1.5, y: 1.5)
        waveAnimationTimer = 0.5
    }

    private var waveAnimationTimer: Double = 0

    private func processWaveAnimation(delta: Double) {
        guard waveAnimationTimer > 0, let label = waveLabel else { return }

        waveAnimationTimer -= delta
        if waveAnimationTimer <= 0 {
            label.scale = Vector2(x: 1, y: 1)
        }
    }

    // MARK: - Pause Handling

    func togglePause() {
        if isPaused {
            resume()
        } else {
            pause()
        }
    }

    func pause() {
        isPaused = true
        emitSignal(Self.pauseRequested.name)
    }

    func resume() {
        isPaused = false
        emitSignal(Self.resumeRequested.name)
    }

    // MARK: - Game Over

    func showGameOver(score: Int) {
        gameOverPanel?.visible = true

        // Find and update the final score label
        if let finalScoreLabel = gameOverPanel?.child(ofType: Label.self) {
            finalScoreLabel.text = "Final Score: \(score)"
        }
    }

    func hideGameOver() {
        gameOverPanel?.visible = false
    }

    // MARK: - Restart

    private func requestRestart() {
        emitSignal(Self.restartRequested.name)
    }
}

// MARK: - Animated Button Example

/// Example of a button with hover animations
@Godot
class AnimatedButton: Button {

    @GodotState var isHovered: Bool = false
    private var originalScale: Vector2 = Vector2(x: 1, y: 1)

    private let hoverScale: Vector2 = Vector2(x: 1.1, y: 1.1)
    private let animationSpeed: Float = 10.0

    override func _ready() {
        originalScale = scale

        // Connect hover signals
        on("mouse_entered") { [weak self] in
            self?.isHovered = true
        }

        on("mouse_exited") { [weak self] in
            self?.isHovered = false
        }
    }

    override func _process(delta: Double) {
        let targetScale = isHovered ? hoverScale : originalScale
        scale = scale.lerp(to: targetScale, weight: Float(delta) * animationSpeed)
    }
}
