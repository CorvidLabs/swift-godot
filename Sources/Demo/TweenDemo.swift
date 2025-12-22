import SwiftGodotKit

// MARK: - Tween & Animation Demo Scene

/// Demonstrates SwiftGodotKit tween and animation capabilities
@Godot
class TweenShowcase: Control {

    // MARK: - Node References

    @GodotNode("VBox/ButtonRow/MoveBtn") var moveBtn: Button?
    @GodotNode("VBox/ButtonRow/ScaleBtn") var scaleBtn: Button?
    @GodotNode("VBox/ButtonRow/RotateBtn") var rotateBtn: Button?
    @GodotNode("VBox/ButtonRow/ColorBtn") var colorBtn: Button?
    @GodotNode("VBox/ButtonRow2/ChainBtn") var chainBtn: Button?
    @GodotNode("VBox/ButtonRow2/ParallelBtn") var parallelBtn: Button?
    @GodotNode("VBox/ButtonRow2/LoopBtn") var loopBtn: Button?
    @GodotNode("VBox/ButtonRow2/ResetBtn") var resetBtn: Button?
    @GodotNode("VBox/StatusLabel") var statusLabel: Label?
    @GodotNode("AnimationArea") var animationArea: Control?
    @GodotNode("BackButton") var backButton: Button?
    @GodotNode("PauseMenu") var pauseMenu: PauseMenu?

    // MARK: - Animation Targets

    private var targetSprite: ColorRect?
    private var targetContainer: Control?
    private var currentTween: Tween?

    // MARK: - State

    @GodotState var statusText: String = "Click a button to see tween animations!"
    private var originalPosition: Vector2 = Vector2(x: 400, y: 350)
    private var originalScale: Vector2 = Vector2(x: 1, y: 1)

    // MARK: - Lifecycle

    override func _ready() {
        configureNodes()
        createAnimationTarget()
        setupButtons()

        GodotContext.log("""

        ╔═══════════════════════════════════════════╗
        ║         Tween & Animation Demo            ║
        ╠═══════════════════════════════════════════╣
        ║  • Position, scale, rotation, color       ║
        ║  • Chained and parallel tweens            ║
        ║  • Loop animations                        ║
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

    // MARK: - Setup

    private func configureNodes() {
        $moveBtn.configure(owner: self)
        $scaleBtn.configure(owner: self)
        $rotateBtn.configure(owner: self)
        $colorBtn.configure(owner: self)
        $chainBtn.configure(owner: self)
        $parallelBtn.configure(owner: self)
        $loopBtn.configure(owner: self)
        $resetBtn.configure(owner: self)
        $statusLabel.configure(owner: self)
        $animationArea.configure(owner: self)
        $backButton.configure(owner: self)
        $pauseMenu.configure(owner: self)
    }

    private func createAnimationTarget() {
        let sprite = ColorRect()
        sprite.color = Color(r: 0.3, g: 0.7, b: 0.9, a: 1.0)
        sprite.customMinimumSize = Vector2(x: 80, y: 80)
        sprite.setSize(Vector2(x: 80, y: 80))
        sprite.setPosition(Vector2(x: -40, y: -40))  // Center pivot
        sprite.pivotOffset = Vector2(x: 40, y: 40)

        // Create a container for proper positioning
        let container = Control()
        container.setPosition(originalPosition)
        container.addChild(node: sprite)

        animationArea?.addChild(node: container)
        targetSprite = sprite
        targetContainer = container
    }

    private func setupButtons() {
        moveBtn?.on("pressed") { [weak self] in
            self?.demoMove()
        }

        scaleBtn?.on("pressed") { [weak self] in
            self?.demoScale()
        }

        rotateBtn?.on("pressed") { [weak self] in
            self?.demoRotate()
        }

        colorBtn?.on("pressed") { [weak self] in
            self?.demoColor()
        }

        chainBtn?.on("pressed") { [weak self] in
            self?.demoChain()
        }

        parallelBtn?.on("pressed") { [weak self] in
            self?.demoParallel()
        }

        loopBtn?.on("pressed") { [weak self] in
            self?.demoLoop()
        }

        resetBtn?.on("pressed") { [weak self] in
            self?.resetTarget()
        }

        backButton?.on("pressed") { [weak self] in
            _ = self?.getTree()?.changeSceneToFile(path: "res://demo_menu.tscn")
        }
    }

    // MARK: - Tween Demos

    private func resetTarget() {
        currentTween?.kill()

        if let container = targetContainer {
            container.setPosition(originalPosition)
            container.scale = originalScale
            container.rotation = 0
        }
        targetSprite?.color = Color(r: 0.3, g: 0.7, b: 0.9, a: 1.0)

        statusText = "Reset to original state"
    }

    private func demoMove() {
        currentTween?.kill()
        guard let container = targetContainer else { return }

        let tween = createTween()
        currentTween = tween

        let target1 = Vector2(x: 600, y: 350)
        let target2 = Vector2(x: 200, y: 350)

        _ = tween?.tweenProperty(object: container, property: "position", finalVal: Variant(target1), duration: 0.5)
        _ = tween?.tweenProperty(object: container, property: "position", finalVal: Variant(target2), duration: 0.5)
        _ = tween?.tweenProperty(object: container, property: "position", finalVal: Variant(originalPosition), duration: 0.5)

        statusText = "Position tween animation"
        GodotContext.log("Tween: Moving sprite left and right")
    }

    private func demoScale() {
        currentTween?.kill()
        guard let container = targetContainer else { return }

        let tween = createTween()
        currentTween = tween

        let scaleUp = Vector2(x: 1.5, y: 1.5)
        let scaleDown = Vector2(x: 0.5, y: 0.5)

        _ = tween?.tweenProperty(object: container, property: "scale", finalVal: Variant(scaleUp), duration: 0.3)
        _ = tween?.tweenProperty(object: container, property: "scale", finalVal: Variant(scaleDown), duration: 0.3)
        _ = tween?.tweenProperty(object: container, property: "scale", finalVal: Variant(originalScale), duration: 0.3)

        statusText = "Scale tween animation"
        GodotContext.log("Tween: Scaling sprite up and down")
    }

    private func demoRotate() {
        currentTween?.kill()
        guard let container = targetContainer else { return }

        let tween = createTween()
        currentTween = tween

        let fullRotation = Double.pi * 2

        _ = tween?.tweenProperty(object: container, property: "rotation", finalVal: Variant(fullRotation), duration: 1.0)

        statusText = "Rotation tween animation"
        GodotContext.log("Tween: Rotating sprite 360 degrees")
    }

    private func demoColor() {
        currentTween?.kill()
        guard let sprite = targetSprite else { return }

        let tween = createTween()
        currentTween = tween

        let red = Color(r: 1.0, g: 0.2, b: 0.2, a: 1.0)
        let green = Color(r: 0.2, g: 1.0, b: 0.2, a: 1.0)
        let blue = Color(r: 0.2, g: 0.2, b: 1.0, a: 1.0)
        let original = Color(r: 0.3, g: 0.7, b: 0.9, a: 1.0)

        _ = tween?.tweenProperty(object: sprite, property: "color", finalVal: Variant(red), duration: 0.4)
        _ = tween?.tweenProperty(object: sprite, property: "color", finalVal: Variant(green), duration: 0.4)
        _ = tween?.tweenProperty(object: sprite, property: "color", finalVal: Variant(blue), duration: 0.4)
        _ = tween?.tweenProperty(object: sprite, property: "color", finalVal: Variant(original), duration: 0.4)

        statusText = "Color interpolation through RGB"
        GodotContext.log("Tween: Color cycling through red, green, blue")
    }

    private func demoChain() {
        currentTween?.kill()
        guard let container = targetContainer,
              let sprite = targetSprite else { return }

        let tween = createTween()
        currentTween = tween

        // Chain: move, then scale, then color, then rotate
        _ = tween?.tweenProperty(object: container, property: "position",
                               finalVal: Variant(Vector2(x: 500, y: 350)), duration: 0.4)
        _ = tween?.tweenProperty(object: container, property: "scale",
                               finalVal: Variant(Vector2(x: 1.3, y: 1.3)), duration: 0.3)
        _ = tween?.tweenProperty(object: sprite, property: "color",
                               finalVal: Variant(Color(r: 1.0, g: 0.5, b: 0.0, a: 1.0)), duration: 0.3)
        _ = tween?.tweenProperty(object: container, property: "rotation",
                               finalVal: Variant(Double.pi / 4), duration: 0.3)

        // Chain back
        _ = tween?.tweenProperty(object: container, property: "rotation",
                               finalVal: Variant(0.0), duration: 0.3)
        _ = tween?.tweenProperty(object: sprite, property: "color",
                               finalVal: Variant(Color(r: 0.3, g: 0.7, b: 0.9, a: 1.0)), duration: 0.3)
        _ = tween?.tweenProperty(object: container, property: "scale",
                               finalVal: Variant(originalScale), duration: 0.3)
        _ = tween?.tweenProperty(object: container, property: "position",
                               finalVal: Variant(originalPosition), duration: 0.4)

        statusText = "Chained sequential animations"
        GodotContext.log("Tween: Chained sequence - move, scale, color, rotate")
    }

    private func demoParallel() {
        currentTween?.kill()
        guard let container = targetContainer,
              let sprite = targetSprite,
              let tween = createTween() else { return }

        currentTween = tween

        // All these run in parallel (same time offset)
        _ = tween.parallel()?.tweenProperty(object: container, property: "position",
                                           finalVal: Variant(Vector2(x: 550, y: 250)), duration: 1.0)
        _ = tween.parallel()?.tweenProperty(object: container, property: "scale",
                                           finalVal: Variant(Vector2(x: 1.5, y: 1.5)), duration: 1.0)
        _ = tween.parallel()?.tweenProperty(object: container, property: "rotation",
                                           finalVal: Variant(Double.pi), duration: 1.0)
        _ = tween.parallel()?.tweenProperty(object: sprite, property: "color",
                                           finalVal: Variant(Color(r: 0.9, g: 0.3, b: 0.7, a: 1.0)), duration: 1.0)

        // Return in parallel
        _ = tween.parallel()?.tweenProperty(object: container, property: "position",
                                           finalVal: Variant(originalPosition), duration: 1.0)
        _ = tween.parallel()?.tweenProperty(object: container, property: "scale",
                                           finalVal: Variant(originalScale), duration: 1.0)
        _ = tween.parallel()?.tweenProperty(object: container, property: "rotation",
                                           finalVal: Variant(0.0), duration: 1.0)
        _ = tween.parallel()?.tweenProperty(object: sprite, property: "color",
                                           finalVal: Variant(Color(r: 0.3, g: 0.7, b: 0.9, a: 1.0)), duration: 1.0)

        statusText = "Parallel animations (all at once)"
        GodotContext.log("Tween: Parallel - move, scale, rotate, color simultaneously")
    }

    private func demoLoop() {
        currentTween?.kill()
        guard let container = targetContainer else { return }

        let tween = createTween()
        currentTween = tween

        // Set up looping
        _ = tween?.setLoops(3)

        _ = tween?.tweenProperty(object: container, property: "position",
                               finalVal: Variant(Vector2(x: 500, y: 350)), duration: 0.3)
        _ = tween?.tweenProperty(object: container, property: "position",
                               finalVal: Variant(Vector2(x: 300, y: 350)), duration: 0.3)
        _ = tween?.tweenProperty(object: container, property: "position",
                               finalVal: Variant(originalPosition), duration: 0.3)

        statusText = "Looping animation (3 times)"
        GodotContext.log("Tween: Looping 3 times")
    }
}
