import SwiftGodotKit

// MARK: - Particles Demo Scene

/// Demonstrates SwiftGodotKit particle system capabilities
@Godot
class ParticlesShowcase: Node2D {

    // MARK: - Node References

    @GodotNode("UI/StatusLabel") var statusLabel: Label?
    @GodotNode("UI/BackButton") var backButton: Button?
    @GodotNode("UI/Buttons/ExplosionBtn") var explosionBtn: Button?
    @GodotNode("UI/Buttons/FireBtn") var fireBtn: Button?
    @GodotNode("UI/Buttons/SparkBtn") var sparkBtn: Button?
    @GodotNode("UI/Buttons/ClearBtn") var clearBtn: Button?
    @GodotNode("PauseMenu") var pauseMenu: PauseMenu?

    // MARK: - State

    @GodotState var statusText: String = "Click buttons or click anywhere to spawn particles!"

    private var activeParticles: [Node] = []
    private var trailEmitter: CPUParticles2D?
    private var isTrailing = false

    // MARK: - Lifecycle

    override func _ready() {
        configureNodes()
        setupButtons()

        GodotContext.log("""

        ╔═══════════════════════════════════════════╗
        ║           Particles Demo                  ║
        ╠═══════════════════════════════════════════╣
        ║  • Left Click: Spawn explosion            ║
        ║  • Hold Right Click: Create trail         ║
        ║  • Buttons: Different particle effects    ║
        ║  • Press ESC for controls                 ║
        ╚═══════════════════════════════════════════╝

        """)
    }

    override func _process(delta: Double) {
        if $statusText.changed {
            statusLabel?.text = statusText
        }
        $statusText.reset()

        // Update trail position
        if isTrailing, let trail = trailEmitter {
            trail.position = getLocalMousePosition()
        }

        // Clean up finished one-shot particles
        activeParticles.removeAll { node in
            if let particles = node as? CPUParticles2D {
                if !particles.emitting && particles.oneShot {
                    particles.queueFree()
                    return true
                }
            }
            return false
        }
    }

    override func _input(event: InputEvent) {
        if let mouseEvent = event as? InputEventMouseButton {
            let mousePos = getLocalMousePosition()

            // Left click - explosion
            if mouseEvent.buttonIndex == .left && mouseEvent.pressed {
                spawnExplosion(at: mousePos)
                statusText = "Explosion at (\(Int(mousePos.x)), \(Int(mousePos.y)))"
            }

            // Right click - trail
            if mouseEvent.buttonIndex == .right {
                if mouseEvent.pressed {
                    startTrail(at: mousePos)
                    statusText = "Creating particle trail..."
                } else {
                    stopTrail()
                    statusText = "Trail stopped"
                }
            }
        }
    }

    // MARK: - Setup

    private func configureNodes() {
        $statusLabel.configure(owner: self)
        $backButton.configure(owner: self)
        $explosionBtn.configure(owner: self)
        $fireBtn.configure(owner: self)
        $sparkBtn.configure(owner: self)
        $clearBtn.configure(owner: self)
        $pauseMenu.configure(owner: self)
    }

    private func setupButtons() {
        backButton?.on("pressed") { [weak self] in
            _ = self?.getTree()?.changeSceneToFile(path: "res://demo_menu.tscn")
        }

        explosionBtn?.on("pressed") { [weak self] in
            let center = Vector2(x: 512, y: 350)
            self?.spawnExplosion(at: center)
            self?.statusText = "Explosion effect!"
        }

        fireBtn?.on("pressed") { [weak self] in
            let center = Vector2(x: 512, y: 400)
            self?.spawnFire(at: center)
            self?.statusText = "Fire effect (5 seconds)"
        }

        sparkBtn?.on("pressed") { [weak self] in
            let center = Vector2(x: 512, y: 350)
            self?.spawnSparks(at: center)
            self?.statusText = "Spark burst!"
        }

        clearBtn?.on("pressed") { [weak self] in
            self?.clearAllParticles()
            self?.statusText = "All particles cleared"
        }
    }

    // MARK: - Particle Effects

    private func createColorGradient(colors: [(offset: Double, color: Color)]) -> Gradient {
        let gradient = Gradient()
        for (index, item) in colors.enumerated() {
            if index == 0 {
                gradient.setColor(point: 0, color: item.color)
                gradient.setOffset(point: 0, offset: item.offset)
            } else if index == colors.count - 1 {
                gradient.setColor(point: 1, color: item.color)
                gradient.setOffset(point: 1, offset: item.offset)
            } else {
                gradient.addPoint(offset: item.offset, color: item.color)
            }
        }
        return gradient
    }

    private func spawnExplosion(at position: Vector2) {
        let particles = CPUParticles2D()

        // Basic setup
        particles.position = position
        particles.emitting = true
        particles.oneShot = true
        particles.explosiveness = 1.0
        particles.amount = 50
        particles.lifetime = 0.8

        // Emission shape - sphere
        particles.emissionShape = .sphere
        particles.emissionSphereRadius = 5.0

        // Movement
        particles.direction = Vector2(x: 0, y: -1)
        particles.spread = 180.0
        particles.initialVelocityMin = 100.0
        particles.initialVelocityMax = 200.0
        particles.gravity = Vector2(x: 0, y: 200)

        // Appearance
        particles.scaleAmountMin = 3.0
        particles.scaleAmountMax = 6.0

        // Color gradient: yellow -> orange -> red -> transparent
        let gradient = createColorGradient(colors: [
            (0.0, Color(r: 1.0, g: 1.0, b: 0.3, a: 1.0)),
            (0.3, Color(r: 1.0, g: 0.6, b: 0.1, a: 1.0)),
            (0.7, Color(r: 1.0, g: 0.2, b: 0.1, a: 0.8)),
            (1.0, Color(r: 0.5, g: 0.1, b: 0.1, a: 0.0))
        ])
        particles.colorRamp = gradient

        addChild(node: particles)
        activeParticles.append(particles)

        GodotContext.log("Spawned explosion at \(position)")
    }

    private func spawnFire(at position: Vector2) {
        let particles = CPUParticles2D()

        // Basic setup
        particles.position = position
        particles.emitting = true
        particles.oneShot = false
        particles.amount = 30
        particles.lifetime = 1.0
        particles.preprocess = 0.5

        // Emission from bottom
        particles.emissionShape = .rectangle
        particles.emissionRectExtents = Vector2(x: 30, y: 5)

        // Movement - upward
        particles.direction = Vector2(x: 0, y: -1)
        particles.spread = 20.0
        particles.initialVelocityMin = 50.0
        particles.initialVelocityMax = 100.0
        particles.gravity = Vector2(x: 0, y: -50)  // Negative - fire rises

        // Randomness
        particles.angularVelocityMin = -50.0
        particles.angularVelocityMax = 50.0

        // Scale
        particles.scaleAmountMin = 4.0
        particles.scaleAmountMax = 8.0

        // Color: yellow core -> orange -> red edges -> fade
        let gradient = createColorGradient(colors: [
            (0.0, Color(r: 1.0, g: 1.0, b: 0.5, a: 0.9)),
            (0.3, Color(r: 1.0, g: 0.7, b: 0.2, a: 0.8)),
            (0.6, Color(r: 1.0, g: 0.3, b: 0.1, a: 0.6)),
            (1.0, Color(r: 0.3, g: 0.1, b: 0.1, a: 0.0))
        ])
        particles.colorRamp = gradient

        addChild(node: particles)
        activeParticles.append(particles)

        // Auto-stop after 5 seconds
        GodotContext.afterFrame { [weak particles] in
            guard let particles = particles else { return }

            // Create timer to stop fire
            let timer = Timer()
            timer.waitTime = 5.0
            timer.oneShot = true
            timer.autostart = true
            particles.addChild(node: timer)

            timer.on("timeout") { [weak particles] in
                particles?.emitting = false
            }
        }

        GodotContext.log("Spawned fire effect at \(position)")
    }

    private func spawnSparks(at position: Vector2) {
        let particles = CPUParticles2D()

        // Basic setup
        particles.position = position
        particles.emitting = true
        particles.oneShot = true
        particles.explosiveness = 0.8
        particles.amount = 25
        particles.lifetime = 0.5

        // Emission
        particles.emissionShape = .point

        // Movement - burst outward
        particles.direction = Vector2(x: 0, y: -1)
        particles.spread = 180.0
        particles.initialVelocityMin = 150.0
        particles.initialVelocityMax = 300.0
        particles.gravity = Vector2(x: 0, y: 400)

        // Appearance - small bright dots
        particles.scaleAmountMin = 1.0
        particles.scaleAmountMax = 3.0

        // Color: bright white/yellow -> fade
        let gradient = createColorGradient(colors: [
            (0.0, Color(r: 1.0, g: 1.0, b: 1.0, a: 1.0)),
            (0.2, Color(r: 1.0, g: 1.0, b: 0.5, a: 1.0)),
            (1.0, Color(r: 1.0, g: 0.8, b: 0.3, a: 0.0))
        ])
        particles.colorRamp = gradient

        addChild(node: particles)
        activeParticles.append(particles)

        GodotContext.log("Spawned sparks at \(position)")
    }

    private func startTrail(at position: Vector2) {
        stopTrail()  // Clear any existing trail

        let particles = CPUParticles2D()

        // Basic setup
        particles.position = position
        particles.emitting = true
        particles.oneShot = false
        particles.amount = 20
        particles.lifetime = 0.6

        // Emission
        particles.emissionShape = .point

        // Movement - slight drift
        particles.direction = Vector2(x: 0, y: 1)
        particles.spread = 30.0
        particles.initialVelocityMin = 10.0
        particles.initialVelocityMax = 30.0
        particles.gravity = Vector2(x: 0, y: 50)

        // Appearance
        particles.scaleAmountMin = 2.0
        particles.scaleAmountMax = 5.0

        // Color: cyan -> blue -> fade
        let gradient = createColorGradient(colors: [
            (0.0, Color(r: 0.3, g: 0.9, b: 1.0, a: 0.8)),
            (0.5, Color(r: 0.2, g: 0.5, b: 1.0, a: 0.6)),
            (1.0, Color(r: 0.1, g: 0.2, b: 0.8, a: 0.0))
        ])
        particles.colorRamp = gradient

        addChild(node: particles)
        trailEmitter = particles
        isTrailing = true

        GodotContext.log("Started particle trail")
    }

    private func stopTrail() {
        if let trail = trailEmitter {
            trail.emitting = false
            // Let remaining particles finish, then clean up
            activeParticles.append(trail)
        }
        trailEmitter = nil
        isTrailing = false
    }

    private func clearAllParticles() {
        for node in activeParticles {
            node.queueFree()
        }
        activeParticles.removeAll()
        stopTrail()

        GodotContext.log("Cleared all particles")
    }
}
