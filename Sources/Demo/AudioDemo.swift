import SwiftGodotKit
import Foundation

// MARK: - Audio Demo Scene

/// Demonstrates SwiftGodotKit audio capabilities
@Godot
class AudioShowcase: Control {

    // MARK: - Node References

    @GodotNode("VBox/MusicSection/MusicToggle") var musicToggle: Button?
    @GodotNode("VBox/MusicSection/VolumeSlider") var volumeSlider: HSlider?
    @GodotNode("VBox/MusicSection/VolumeLabel") var volumeLabel: Label?
    @GodotNode("VBox/SFXSection/SFXButtons/ClickBtn") var clickBtn: Button?
    @GodotNode("VBox/SFXSection/SFXButtons/ExplosionBtn") var explosionBtn: Button?
    @GodotNode("VBox/SFXSection/SFXButtons/PowerupBtn") var powerupBtn: Button?
    @GodotNode("VBox/SFXSection/SFXButtons/JumpBtn") var jumpBtn: Button?
    @GodotNode("VBox/StatusLabel") var statusLabel: Label?
    @GodotNode("BackButton") var backButton: Button?
    @GodotNode("PauseMenu") var pauseMenu: PauseMenu?

    // MARK: - Audio Players

    private var musicPlayer: AudioStreamPlayer?
    private var sfxPlayers: [String: AudioStreamPlayer] = [:]

    // MARK: - State

    @GodotState var isMusicPlaying: Bool = false
    @GodotState var volume: Float = 0.8
    @GodotState var statusText: String = "Audio demo ready!"

    // MARK: - Lifecycle

    override func _ready() {
        configureNodes()
        setupAudioPlayers()
        setupUI()

        GodotContext.log("""

        ╔═══════════════════════════════════════════╗
        ║            Audio Demo                     ║
        ╠═══════════════════════════════════════════╣
        ║  • Toggle background music                ║
        ║  • Adjust volume with slider              ║
        ║  • Click buttons for sound effects        ║
        ║  • Press ESC for controls                 ║
        ╚═══════════════════════════════════════════╝

        """)
    }

    override func _process(delta: Double) {
        if $statusText.changed {
            statusLabel?.text = statusText
        }
        $statusText.reset()
    }

    override func _exitTree() {
        musicPlayer?.stop()
    }

    // MARK: - Setup

    private func configureNodes() {
        $musicToggle.configure(owner: self)
        $volumeSlider.configure(owner: self)
        $volumeLabel.configure(owner: self)
        $clickBtn.configure(owner: self)
        $explosionBtn.configure(owner: self)
        $powerupBtn.configure(owner: self)
        $jumpBtn.configure(owner: self)
        $statusLabel.configure(owner: self)
        $backButton.configure(owner: self)
        $pauseMenu.configure(owner: self)
    }

    private func setupAudioPlayers() {
        // Create music player with procedural "music"
        let music = AudioStreamPlayer()
        music.volumeDb = Double(linearToDb(volume))
        addChild(node: music)
        musicPlayer = music

        // Create SFX players - we'll generate simple tones
        let sfxNames = ["click", "explosion", "powerup", "jump"]
        for name in sfxNames {
            let player = AudioStreamPlayer()
            player.volumeDb = Double(linearToDb(volume))
            addChild(node: player)
            sfxPlayers[name] = player
        }
    }

    private func setupUI() {
        // Music toggle
        musicToggle?.text = "Play Music"
        musicToggle?.on("pressed") { [weak self] in
            self?.toggleMusic()
        }

        // Volume slider
        volumeSlider?.minValue = 0.0
        volumeSlider?.maxValue = 1.0
        volumeSlider?.value = Double(volume)
        volumeSlider?.step = 0.05
        volumeSlider?.on("value_changed") { [weak self] in
            if let slider = self?.volumeSlider {
                self?.setVolume(Float(slider.value))
            }
        }
        volumeLabel?.text = "Volume: \(Int(volume * 100))%"

        // SFX buttons
        clickBtn?.on("pressed") { [weak self] in
            self?.playSFX("click")
        }

        explosionBtn?.on("pressed") { [weak self] in
            self?.playSFX("explosion")
        }

        powerupBtn?.on("pressed") { [weak self] in
            self?.playSFX("powerup")
        }

        jumpBtn?.on("pressed") { [weak self] in
            self?.playSFX("jump")
        }

        // Back button
        backButton?.on("pressed") { [weak self] in
            _ = self?.getTree()?.changeSceneToFile(path: "res://demo_menu.tscn")
        }
    }

    // MARK: - Audio Control

    private func toggleMusic() {
        isMusicPlaying.toggle()

        if isMusicPlaying {
            // Note: In a real project, you'd load an actual audio file:
            // musicPlayer?.stream = load("res://music/background.ogg")
            musicPlayer?.play()
            musicToggle?.text = "Stop Music"
            statusText = "Music playing... (simulated)"
            GodotContext.log("Music started - in a real project, load an AudioStream resource")
        } else {
            musicPlayer?.stop()
            musicToggle?.text = "Play Music"
            statusText = "Music stopped"
            GodotContext.log("Music stopped")
        }
    }

    private func setVolume(_ newVolume: Float) {
        volume = newVolume
        let db = Double(linearToDb(volume))

        musicPlayer?.volumeDb = db
        for player in sfxPlayers.values {
            player.volumeDb = db
        }

        volumeLabel?.text = "Volume: \(Int(volume * 100))%"
    }

    private func playSFX(_ name: String) {
        guard let player = sfxPlayers[name] else { return }

        // Note: In a real project, you'd load audio files:
        // player.stream = load("res://sfx/\(name).wav")
        player.play()

        statusText = "Playing: \(name.capitalized) SFX"
        GodotContext.log("SFX '\(name)' played - load an AudioStream for real audio")
    }

    // MARK: - Helpers

    private func linearToDb(_ linear: Float) -> Float {
        if linear <= 0 {
            return -80.0  // Essentially silent
        }
        return 20.0 * log10(linear)
    }
}

// MARK: - Spatial Audio Demo Node

/// Demonstrates 2D spatial audio with a moving source
@Godot
class SpatialAudioSource: AudioStreamPlayer2D {

    @GodotState var orbitRadius: Float = 200.0
    @GodotState var orbitSpeed: Float = 1.5

    private var angle: Float = 0
    private var centerPosition: Vector2 = Vector2(x: 400, y: 300)

    override func _ready() {
        // Configure spatial audio settings
        maxDistance = 500.0
        attenuation = 1.0

        GodotContext.log("Spatial audio source ready - orbits around center")
    }

    override func _process(delta: Double) {
        angle += orbitSpeed * Float(delta)

        let x = centerPosition.x + cos(angle) * orbitRadius
        let y = centerPosition.y + sin(angle) * orbitRadius
        position = Vector2(x: x, y: y)
    }

    func setCenter(_ center: Vector2) {
        centerPosition = center
    }
}

// MARK: - Audio Visualizer (Simple)

/// Simple audio level visualization
@Godot
class AudioVisualizer: ColorRect {

    @GodotState var level: Float = 0.0

    private var targetLevel: Float = 0.0
    private let smoothing: Float = 10.0
    private let baseHeight: Float = 10.0
    private let maxHeight: Float = 100.0

    override func _ready() {
        color = Color(r: 0.2, g: 0.8, b: 0.4, a: 1.0)
        customMinimumSize = Vector2(x: 30, y: baseHeight)
    }

    override func _process(delta: Double) {
        // Smooth the level changes
        level = level + (targetLevel - level) * smoothing * Float(delta)

        // Update visual height
        let height = baseHeight + level * (maxHeight - baseHeight)
        customMinimumSize = Vector2(x: 30, y: height)

        // Decay the target level
        targetLevel = max(0, targetLevel - Float(delta) * 2)
    }

    func pulse(intensity: Float = 1.0) {
        targetLevel = min(1.0, intensity)
    }
}
