import SwiftGodotKit

// MARK: - Pause Menu System

/// Reusable pause menu that shows controls for any demo
/// Press ESC to toggle pause and see controls
@Godot
class PauseMenu: CanvasLayer {

    // MARK: - State

    @GodotState var isPaused: Bool = false

    /// The controls text to display (set by parent scene)
    var controlsDescription: String = "No controls defined"

    /// The demo title
    var demoTitle: String = "Demo"

    // MARK: - UI Elements

    private var overlay: ColorRect?
    private var panel: PanelContainer?
    private var titleLabel: Label?
    private var controlsLabel: Label?
    private var hintLabel: Label?
    private var resumeButton: Button?
    private var menuButton: Button?

    // MARK: - Lifecycle

    override func _ready() {
        layer = 100  // Always on top
        processMode = .always  // Process even when paused
        visible = false

        setupUI()
    }

    override func _input(event: InputEvent) {
        guard let keyEvent = event as? InputEventKey else { return }

        if keyEvent.pressed && keyEvent.keycode == .escape {
            togglePause()
            getViewport()?.setInputAsHandled()
        }
    }

    // MARK: - Pause Control

    func togglePause() {
        isPaused.toggle()
        getTree()?.paused = isPaused
        visible = isPaused

        if isPaused {
            GodotContext.log("Game paused - showing controls")
        }
    }

    func resume() {
        if isPaused {
            togglePause()
        }
    }

    // MARK: - UI Setup

    private func setupUI() {
        // Dark overlay
        let darkOverlay = ColorRect()
        darkOverlay.color = Color(r: 0, g: 0, b: 0, a: 0.7)
        darkOverlay.setAnchorsPreset(Control.LayoutPreset.fullRect)
        addChild(node: darkOverlay)
        overlay = darkOverlay

        // Center panel
        let centerPanel = PanelContainer()
        centerPanel.setAnchorsPreset(Control.LayoutPreset.center)
        centerPanel.customMinimumSize = Vector2(x: 400, y: 300)
        centerPanel.setPosition(Vector2(x: -200, y: -150))
        addChild(node: centerPanel)
        panel = centerPanel

        // VBox for content
        let vbox = VBoxContainer()
        vbox.setAnchorsPreset(Control.LayoutPreset.fullRect)
        vbox.addThemeConstantOverride(name: "separation", constant: 15)
        centerPanel.addChild(node: vbox)

        // Title
        let title = Label()
        title.text = "PAUSED"
        title.horizontalAlignment = .center
        title.addThemeFontSizeOverride(name: "font_size", fontSize: 28)
        vbox.addChild(node: title)
        titleLabel = title

        // Demo name
        let demoLabel = Label()
        demoLabel.text = demoTitle
        demoLabel.horizontalAlignment = .center
        demoLabel.addThemeFontSizeOverride(name: "font_size", fontSize: 18)
        vbox.addChild(node: demoLabel)

        // Separator
        let sep = HSeparator()
        vbox.addChild(node: sep)

        // Controls header
        let controlsHeader = Label()
        controlsHeader.text = "Controls:"
        controlsHeader.addThemeFontSizeOverride(name: "font_size", fontSize: 16)
        vbox.addChild(node: controlsHeader)

        // Controls content
        let controls = Label()
        controls.text = controlsDescription
        controls.autowrapMode = .word
        controls.customMinimumSize = Vector2(x: 350, y: 80)
        vbox.addChild(node: controls)
        controlsLabel = controls

        // Button container
        let buttonBox = HBoxContainer()
        buttonBox.alignment = .center
        buttonBox.addThemeConstantOverride(name: "separation", constant: 20)
        vbox.addChild(node: buttonBox)

        // Resume button
        let resumeBtn = Button()
        resumeBtn.text = "Resume"
        resumeBtn.customMinimumSize = Vector2(x: 120, y: 40)
        resumeBtn.on("pressed") { [weak self] in
            self?.resume()
        }
        buttonBox.addChild(node: resumeBtn)
        resumeButton = resumeBtn

        // Menu button
        let menuBtn = Button()
        menuBtn.text = "Back to Menu"
        menuBtn.customMinimumSize = Vector2(x: 120, y: 40)
        menuBtn.on("pressed") { [weak self] in
            self?.goToMenu()
        }
        buttonBox.addChild(node: menuBtn)
        menuButton = menuBtn

        // Hint at bottom
        let hint = Label()
        hint.text = "Press ESC to resume"
        hint.horizontalAlignment = .center
        hint.addThemeColorOverride(name: "font_color", color: Color(r: 0.6, g: 0.6, b: 0.6, a: 1))
        vbox.addChild(node: hint)
        hintLabel = hint
    }

    private func goToMenu() {
        getTree()?.paused = false
        _ = getTree()?.changeSceneToFile(path: "res://demo_menu.tscn")
    }

    // MARK: - Configuration

    /// Configure the pause menu for a specific demo
    func configure(title: String, controls: String) {
        demoTitle = title
        controlsDescription = controls

        // Update labels if already created
        if let controlsLabel = controlsLabel {
            controlsLabel.text = controls
        }
    }
}

// MARK: - Pause Menu Factory

/// Factory to create pre-configured pause menus for each demo
enum PauseMenuFactory {

    static func create(for demo: DemoType) -> PauseMenu {
        let menu = PauseMenu()
        let (title, controls) = demo.info
        menu.configure(title: title, controls: controls)
        return menu
    }

    enum DemoType {
        case game3D
        case game2D
        case platformer
        case audio
        case tween
        case camera
        case particles
        case async
        case catalog

        var info: (title: String, controls: String) {
            switch self {
            case .game3D:
                return ("3D Game Demo", """
                WASD / Arrows: Move
                Space: Jump
                Survive the enemy waves!
                """)
            case .game2D:
                return ("2D Game Demo", """
                WASD / Arrows: Move
                Enemies spawn automatically
                Avoid contact with enemies!
                """)
            case .platformer:
                return ("Platformer Demo", """
                WASD / Arrows: Move left/right
                Space / W / Up: Jump
                Collect coins for points!
                """)
            case .audio:
                return ("Audio Demo", """
                Click buttons to play sounds
                Drag slider to adjust volume
                Toggle music on/off
                """)
            case .tween:
                return ("Tween & Animation Demo", """
                Click buttons to trigger animations
                Watch different easing functions
                See property interpolation in action
                """)
            case .camera:
                return ("Camera Demo", """
                WASD / Arrows: Move target
                Left Click: Trigger camera shake
                Scroll Wheel: Zoom in/out
                """)
            case .particles:
                return ("Particles Demo", """
                Left Click: Spawn explosion
                Hold Right Click: Create trail
                Watch GPU particle effects!
                """)
            case .async:
                return ("Async Patterns Demo", """
                Click buttons to demo patterns
                Watch counter and status updates
                See async code in console
                """)
            case .catalog:
                return ("Feature Catalog", """
                Click buttons to explore features
                View output in the text area
                Reference for SwiftGodotKit APIs
                """)
            }
        }
    }
}
