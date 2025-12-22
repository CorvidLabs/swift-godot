import SwiftGodotKit

// MARK: - Demo Menu Hub

/// Main menu hub linking to all SwiftGodotKit demos
@Godot
class DemoMenu: Control {

    // MARK: - Node References

    @GodotNode("VBox/Game3DButton") var game3DButton: Button?
    @GodotNode("VBox/Game2DButton") var game2DButton: Button?
    @GodotNode("VBox/AsyncButton") var asyncButton: Button?
    @GodotNode("VBox/PlatformerButton") var platformerButton: Button?
    @GodotNode("VBox/CatalogButton") var catalogButton: Button?

    // MARK: - Lifecycle

    override func _ready() {
        $game3DButton.configure(owner: self)
        $game2DButton.configure(owner: self)
        $asyncButton.configure(owner: self)
        $platformerButton.configure(owner: self)
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
        game3DButton?.on("pressed") { [weak self] in
            self?.loadScene("res://demo.tscn")
        }

        game2DButton?.on("pressed") { [weak self] in
            self?.loadScene("res://demo2d.tscn")
        }

        asyncButton?.on("pressed") { [weak self] in
            self?.loadScene("res://async_demo.tscn")
        }

        platformerButton?.on("pressed") { [weak self] in
            self?.loadScene("res://platformer_demo.tscn")
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
