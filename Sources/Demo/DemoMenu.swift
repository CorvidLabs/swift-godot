import SwiftGodotKit

// MARK: - Demo Menu Hub

/// Main menu hub linking to all SwiftGodotKit demos
@Godot
class DemoMenu: Control {

    // MARK: - Node References (Games)

    @GodotNode("VBox/HBox/GamesColumn/GamesSection/Game3DButton") var game3DButton: Button?
    @GodotNode("VBox/HBox/GamesColumn/GamesSection/Game2DButton") var game2DButton: Button?
    @GodotNode("VBox/HBox/GamesColumn/GamesSection/PlatformerButton") var platformerButton: Button?
    @GodotNode("VBox/HBox/GamesColumn/GamesSection/SnakeButton") var snakeButton: Button?
    @GodotNode("VBox/HBox/GamesColumn/GamesSection/BreakoutButton") var breakoutButton: Button?
    @GodotNode("VBox/HBox/GamesColumn/GamesSection/MemoryButton") var memoryButton: Button?
    @GodotNode("VBox/HBox/GamesColumn/GamesSection/AsteroidsButton") var asteroidsButton: Button?
    @GodotNode("VBox/HBox/GamesColumn/GamesSection/DungeonButton") var dungeonButton: Button?
    @GodotNode("VBox/HBox/GamesColumn/GamesSection/RhythmButton") var rhythmButton: Button?

    // MARK: - Node References (Systems)

    @GodotNode("VBox/HBox/SystemsColumn/SystemsSection/AudioButton") var audioButton: Button?
    @GodotNode("VBox/HBox/SystemsColumn/SystemsSection/TweenButton") var tweenButton: Button?
    @GodotNode("VBox/HBox/SystemsColumn/SystemsSection/CameraButton") var cameraButton: Button?
    @GodotNode("VBox/HBox/SystemsColumn/SystemsSection/ParticlesButton") var particlesButton: Button?

    // MARK: - Node References (Features)

    @GodotNode("VBox/HBox/FeaturesColumn/FeaturesSection/AsyncButton") var asyncButton: Button?
    @GodotNode("VBox/HBox/FeaturesColumn/FeaturesSection/CatalogButton") var catalogButton: Button?

    // MARK: - Node References (CorvidLabs)

    @GodotNode("VBox/HBox/CorvidColumn/CorvidSection/ArtButton") var artButton: Button?
    @GodotNode("VBox/HBox/CorvidColumn/CorvidSection/ColorButton") var colorButton: Button?
    @GodotNode("VBox/HBox/CorvidColumn/CorvidSection/GameButton") var gameButton: Button?
    @GodotNode("VBox/HBox/CorvidColumn/CorvidSection/MusicButton") var musicButton: Button?
    @GodotNode("VBox/HBox/CorvidColumn/CorvidSection/TextButton") var textButton: Button?
    @GodotNode("VBox/HBox/CorvidColumn/CorvidSection/QRButton") var qrButton: Button?

    // MARK: - Lifecycle

    override func _ready() {
        // Games
        $game3DButton.configure(owner: self)
        $game2DButton.configure(owner: self)
        $platformerButton.configure(owner: self)
        $snakeButton.configure(owner: self)
        $breakoutButton.configure(owner: self)
        $memoryButton.configure(owner: self)
        $asteroidsButton.configure(owner: self)
        $dungeonButton.configure(owner: self)
        $rhythmButton.configure(owner: self)

        // Systems
        $audioButton.configure(owner: self)
        $tweenButton.configure(owner: self)
        $cameraButton.configure(owner: self)
        $particlesButton.configure(owner: self)

        // Features
        $asyncButton.configure(owner: self)
        $catalogButton.configure(owner: self)

        // CorvidLabs
        $artButton.configure(owner: self)
        $colorButton.configure(owner: self)
        $gameButton.configure(owner: self)
        $musicButton.configure(owner: self)
        $textButton.configure(owner: self)
        $qrButton.configure(owner: self)

        setupButtons()

        GodotContext.log("""

        ╔═══════════════════════════════════════════╗
        ║       SwiftGodotKit Demo Suite            ║
        ╠═══════════════════════════════════════════╣
        ║  21 demos • CorvidLabs Swift packages     ║
        ║  Select a demo to explore!                ║
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

        snakeButton?.on("pressed") { [weak self] in
            self?.loadScene("res://snake_demo.tscn")
        }

        breakoutButton?.on("pressed") { [weak self] in
            self?.loadScene("res://breakout_demo.tscn")
        }

        memoryButton?.on("pressed") { [weak self] in
            self?.loadScene("res://memory_demo.tscn")
        }

        asteroidsButton?.on("pressed") { [weak self] in
            self?.loadScene("res://asteroids_demo.tscn")
        }

        dungeonButton?.on("pressed") { [weak self] in
            self?.loadScene("res://dungeon_demo.tscn")
        }

        rhythmButton?.on("pressed") { [weak self] in
            self?.loadScene("res://rhythm_demo.tscn")
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

        // CorvidLabs
        artButton?.on("pressed") { [weak self] in
            self?.loadScene("res://procedural_art_demo.tscn")
        }

        colorButton?.on("pressed") { [weak self] in
            self?.loadScene("res://color_lab_demo.tscn")
        }

        gameButton?.on("pressed") { [weak self] in
            self?.loadScene("res://game_systems_demo.tscn")
        }

        musicButton?.on("pressed") { [weak self] in
            self?.loadScene("res://music_theory_demo.tscn")
        }

        textButton?.on("pressed") { [weak self] in
            self?.loadScene("res://text_data_demo.tscn")
        }

        qrButton?.on("pressed") { [weak self] in
            self?.loadScene("res://qr_code_demo.tscn")
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
