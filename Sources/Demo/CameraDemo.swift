import SwiftGodotKit
import Foundation

// MARK: - Camera Demo Scene

/// Demonstrates SwiftGodotKit camera capabilities
@Godot
class CameraShowcase: Node2D {

    // MARK: - Node References

    @GodotNode(.unique("FollowCamera")) var camera: FollowCamera?
    @GodotNode(.unique("CameraTarget")) var target: CameraTarget?
    @GodotNode("UI/StatusLabel") var statusLabel: Label?
    @GodotNode("UI/ZoomLabel") var zoomLabel: Label?
    @GodotNode("UI/BackButton") var backButton: Button?
    @GodotNode("UI/ShakeButton") var shakeButton: Button?
    @GodotNode("UI/ResetButton") var resetButton: Button?
    @GodotNode("PauseMenu") var pauseMenu: PauseMenu?

    // MARK: - State

    @GodotState var statusText: String = "Move with WASD, Click to shake, Scroll to zoom"

    // MARK: - Lifecycle

    override func _ready() {
        configureNodes()
        setupUI()
        createBackground()

        // Link camera to target
        camera?.target = target

        GodotContext.log("""

        ╔═══════════════════════════════════════════╗
        ║            Camera Demo                    ║
        ╠═══════════════════════════════════════════╣
        ║  • WASD/Arrows: Move target               ║
        ║  • Left Click: Camera shake               ║
        ║  • Mouse Wheel: Zoom in/out               ║
        ║  • Press ESC for controls                 ║
        ╚═══════════════════════════════════════════╝

        """)
    }

    override func _process(delta: Double) {
        if $statusText.changed {
            statusLabel?.text = statusText
        }
        $statusText.reset()

        // Update zoom label
        if let cam = camera {
            zoomLabel?.text = String(format: "Zoom: %.1fx", cam.zoom.x)
        }
    }

    override func _input(event: InputEvent) {
        // Handle mouse click for shake
        if let mouseEvent = event as? InputEventMouseButton {
            if mouseEvent.pressed && mouseEvent.buttonIndex == .left {
                camera?.shake(intensity: 15, duration: 0.3)
                statusText = "Camera shake triggered!"
            }
        }

        // Handle scroll for zoom
        if let mouseEvent = event as? InputEventMouseButton {
            if mouseEvent.pressed {
                if mouseEvent.buttonIndex == .wheelUp {
                    camera?.zoomIn()
                    statusText = "Zooming in..."
                } else if mouseEvent.buttonIndex == .wheelDown {
                    camera?.zoomOut()
                    statusText = "Zooming out..."
                }
            }
        }
    }

    // MARK: - Setup

    private func configureNodes() {
        $camera.configure(owner: self)
        $target.configure(owner: self)
        $statusLabel.configure(owner: self)
        $zoomLabel.configure(owner: self)
        $backButton.configure(owner: self)
        $shakeButton.configure(owner: self)
        $resetButton.configure(owner: self)
        $pauseMenu.configure(owner: self)
    }

    private func setupUI() {
        backButton?.on("pressed") { [weak self] in
            _ = self?.getTree()?.changeSceneToFile(path: "res://demo_menu.tscn")
        }

        shakeButton?.on("pressed") { [weak self] in
            self?.camera?.shake(intensity: 20, duration: 0.5)
            self?.statusText = "Big shake!"
        }

        resetButton?.on("pressed") { [weak self] in
            self?.camera?.resetZoom()
            self?.target?.position = Vector2(x: 512, y: 300)
            self?.statusText = "Camera reset to default"
        }
    }

    private func createBackground() {
        // Create a grid pattern to show camera movement
        let gridSize: Float = 100
        let gridCount = 20

        for i in 0..<gridCount {
            for j in 0..<gridCount {
                let x = Float(i - gridCount / 2) * gridSize
                let y = Float(j - gridCount / 2) * gridSize

                // Create grid cell using Sprite2D with a simple colored texture
                let cell = ColorRect()
                let isEven = (i + j) % 2 == 0
                cell.color = isEven
                    ? Color(r: 0.15, g: 0.18, b: 0.22, a: 1.0)
                    : Color(r: 0.12, g: 0.14, b: 0.18, a: 1.0)
                cell.customMinimumSize = Vector2(x: gridSize - 2, y: gridSize - 2)
                cell.setSize(Vector2(x: gridSize - 2, y: gridSize - 2))
                cell.setPosition(Vector2(x: x, y: y))
                cell.zIndex = -10
                addChild(node: cell)
            }
        }

        // Add some landmarks
        let colors: [Color] = [
            Color(r: 0.8, g: 0.2, b: 0.2, a: 0.5),
            Color(r: 0.2, g: 0.8, b: 0.2, a: 0.5),
            Color(r: 0.2, g: 0.2, b: 0.8, a: 0.5),
            Color(r: 0.8, g: 0.8, b: 0.2, a: 0.5)
        ]

        let positions: [Vector2] = [
            Vector2(x: -300, y: -300),
            Vector2(x: 300, y: -300),
            Vector2(x: -300, y: 300),
            Vector2(x: 300, y: 300)
        ]

        for (index, pos) in positions.enumerated() {
            let landmark = ColorRect()
            landmark.color = colors[index]
            landmark.customMinimumSize = Vector2(x: 80, y: 80)
            landmark.setSize(Vector2(x: 80, y: 80))
            landmark.setPosition(pos)
            landmark.zIndex = -5
            addChild(node: landmark)
        }
    }
}

// MARK: - Follow Camera

/// Camera with smooth follow, shake, and zoom capabilities
@Godot
class FollowCamera: Camera2D {

    // MARK: - Configuration

    @GodotState var followSmoothing: Float = 5.0
    @GodotState var minZoom: Float = 0.5
    @GodotState var maxZoom: Float = 2.0
    @GodotState var zoomStep: Float = 0.1
    @GodotState var currentZoom: Float = 1.0

    // MARK: - Target

    weak var target: Node2D?

    // MARK: - Shake State

    private var shakeIntensity: Float = 0
    private var shakeDuration: Float = 0
    private var shakeTimer: Float = 0
    private var originalOffset: Vector2 = .zero

    // MARK: - Lifecycle

    override func _ready() {
        // Enable position smoothing
        positionSmoothingEnabled = true
        positionSmoothingSpeed = Double(followSmoothing)

        // Set initial zoom
        zoom = Vector2(x: currentZoom, y: currentZoom)

        // Set camera limits (optional - for bounded areas)
        // limitLeft = -1000
        // limitRight = 1000
        // limitTop = -1000
        // limitBottom = 1000

        GodotContext.log("FollowCamera ready - smoothing: \(followSmoothing)")
    }

    override func _process(delta: Double) {
        // Follow target
        if let target = target {
            // Using built-in smoothing, just set global position to track
            globalPosition = globalPosition.lerp(to: target.globalPosition, weight: followSmoothing * Float(delta))
        }

        // Process shake
        if shakeTimer > 0 {
            shakeTimer -= Float(delta)
            let progress = shakeTimer / shakeDuration
            let currentIntensity = shakeIntensity * progress

            // Random offset for shake effect
            let offsetX = Float.random(in: -currentIntensity...currentIntensity)
            let offsetY = Float.random(in: -currentIntensity...currentIntensity)
            offset = Vector2(x: offsetX, y: offsetY)

            if shakeTimer <= 0 {
                offset = originalOffset
            }
        }
    }

    // MARK: - Shake

    func shake(intensity: Float, duration: Float) {
        shakeIntensity = intensity
        shakeDuration = duration
        shakeTimer = duration
        originalOffset = offset

        GodotContext.log("Camera shake: intensity=\(intensity), duration=\(duration)s")
    }

    // MARK: - Zoom

    func zoomIn() {
        currentZoom = min(maxZoom, currentZoom + zoomStep)
        zoom = Vector2(x: currentZoom, y: currentZoom)
        GodotContext.log("Camera zoom in: \(currentZoom)x")
    }

    func zoomOut() {
        currentZoom = max(minZoom, currentZoom - zoomStep)
        zoom = Vector2(x: currentZoom, y: currentZoom)
        GodotContext.log("Camera zoom out: \(currentZoom)x")
    }

    func setZoomLevel(_ level: Float) {
        currentZoom = max(minZoom, min(maxZoom, level))
        zoom = Vector2(x: currentZoom, y: currentZoom)
    }

    func resetZoom() {
        currentZoom = 1.0
        zoom = Vector2(x: 1, y: 1)
        offset = .zero
        GodotContext.log("Camera reset to default zoom")
    }
}

// MARK: - Camera Target

/// Controllable target for camera to follow
@Godot
class CameraTarget: Node2D {

    // MARK: - Configuration

    @GodotState var moveSpeed: Float = 300.0

    // MARK: - Visuals

    private var sprite: ColorRect?

    // MARK: - Lifecycle

    override func _ready() {
        setupVisuals()
    }

    override func _process(delta: Double) {
        handleMovement(delta: delta)
    }

    // MARK: - Setup

    private func setupVisuals() {
        // Main body
        let body = ColorRect()
        body.color = Color(r: 0.3, g: 0.8, b: 0.4, a: 1.0)
        body.customMinimumSize = Vector2(x: 40, y: 40)
        body.setSize(Vector2(x: 40, y: 40))
        body.setPosition(Vector2(x: -20, y: -20))
        addChild(node: body)
        sprite = body

        // Direction indicator
        let indicator = ColorRect()
        indicator.color = Color(r: 0.9, g: 0.9, b: 0.9, a: 1.0)
        indicator.customMinimumSize = Vector2(x: 10, y: 10)
        indicator.setSize(Vector2(x: 10, y: 10))
        indicator.setPosition(Vector2(x: 15, y: -5))
        addChild(node: indicator)
    }

    // MARK: - Movement

    private func handleMovement(delta: Double) {
        var direction = Vector2.zero

        if Input.isActionPressed(action: "ui_left") || Input.isActionPressed(action: "move_left") {
            direction.x -= 1
        }
        if Input.isActionPressed(action: "ui_right") || Input.isActionPressed(action: "move_right") {
            direction.x += 1
        }
        if Input.isActionPressed(action: "ui_up") || Input.isActionPressed(action: "move_up") {
            direction.y -= 1
        }
        if Input.isActionPressed(action: "ui_down") || Input.isActionPressed(action: "move_down") {
            direction.y += 1
        }

        if direction != .zero {
            direction = direction.normalized()
            let speed = moveSpeed * Float(delta)
            let movement = Vector2(x: direction.x * speed, y: direction.y * speed)
            position = position + movement

            // Rotate indicator to face movement direction
            rotation = atan2(Double(direction.y), Double(direction.x))
        }
    }
}
