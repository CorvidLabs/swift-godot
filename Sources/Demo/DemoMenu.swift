import SwiftGodotKit

// MARK: - Demo Menu Hub

/// Main menu hub linking to all SwiftGodotKit demos
@Godot
class DemoMenu: Control {

    // MARK: - Node References (Games)

    @GodotNode("VBox/HBox/GamesColumn/GamesSection/Game3DButton") var game3DButton: Button?
    @GodotNode("VBox/HBox/GamesColumn/GamesSection/Game2DButton") var game2DButton: Button?
    @GodotNode("VBox/HBox/GamesColumn/GamesSection/PlatformerButton") var platformerButton: Button?

    // MARK: - Node References (Systems)

    @GodotNode("VBox/HBox/SystemsColumn/SystemsSection/AudioButton") var audioButton: Button?
    @GodotNode("VBox/HBox/SystemsColumn/SystemsSection/TweenButton") var tweenButton: Button?
    @GodotNode("VBox/HBox/SystemsColumn/SystemsSection/CameraButton") var cameraButton: Button?
    @GodotNode("VBox/HBox/SystemsColumn/SystemsSection/ParticlesButton") var particlesButton: Button?

    // MARK: - Node References (Features)

    @GodotNode("VBox/HBox/FeaturesColumn/FeaturesSection/AsyncButton") var asyncButton: Button?
    @GodotNode("VBox/HBox/FeaturesColumn/FeaturesSection/CatalogButton") var catalogButton: Button?

    // MARK: - Lifecycle

    override func _ready() {
        // Games
        $game3DButton.configure(owner: self)
        $game2DButton.configure(owner: self)
        $platformerButton.configure(owner: self)

        // Systems
        $audioButton.configure(owner: self)
        $tweenButton.configure(owner: self)
        $cameraButton.configure(owner: self)
        $particlesButton.configure(owner: self)

        // Features
        $asyncButton.configure(owner: self)
        $catalogButton.configure(owner: self)

        setupButtons()

        GodotContext.log("""

        ╔═══════════════════════════════════════════╗
        ║       SwiftGodotKit Demo Suite            ║
        ╠═══════════════════════════════════════════╣
        ║  Select a demo to explore the library!    ║
        ╚═══════════════════════════════════════════╝

        """)
    }

    // MARK: - Setup

    private func setupButtons() {
        // Games
        game3DButton?.on("pressed") { [weak self] in
            self?.loadScene("res://demo.tscn")
        }

        game2DButton?.on("pressed") { [weak self] in
            self?.loadScene("res://demo2d.tscn")
        }

        platformerButton?.on("pressed") { [weak self] in
            self?.loadScene("res://platformer_demo.tscn")
        }

        // Systems
        audioButton?.on("pressed") { [weak self] in
            self?.loadScene("res://audio_demo.tscn")
        }

        tweenButton?.on("pressed") { [weak self] in
            self?.loadScene("res://tween_demo.tscn")
        }

        cameraButton?.on("pressed") { [weak self] in
            self?.loadScene("res://camera_demo.tscn")
        }

        particlesButton?.on("pressed") { [weak self] in
            self?.loadScene("res://particles_demo.tscn")
        }

        // Features
        asyncButton?.on("pressed") { [weak self] in
            self?.loadScene("res://async_demo.tscn")
        }

        catalogButton?.on("pressed") { [weak self] in
            self?.loadScene("res://feature_catalog.tscn")
        }
    }

    // MARK: - Navigation

    private func loadScene(_ path: String) {
        GodotContext.log("Loading: \(path)")
        _ = getTree()?.changeSceneToFile(path: path)
    }
}

// MARK: - Back Button Component

/// Reusable back button that returns to demo menu
@Godot
class BackToMenuButton: Button {

    override func _ready() {
        text = "← Back to Menu"
        on("pressed") { [weak self] in
            _ = self?.getTree()?.changeSceneToFile(path: "res://demo_menu.tscn")
        }
    }
}
