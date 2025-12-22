import SwiftGodotKit

// MARK: - Feature Catalog

/// Interactive catalog demonstrating SwiftGodotKit features
@Godot
class FeatureCatalog: Control {

    // MARK: - Node References

    @GodotNode("VBox/OutputLabel") var outputLabel: Label?
    @GodotNode("VBox/Buttons/NodeExtBtn") var nodeExtBtn: Button?
    @GodotNode("VBox/Buttons/MetadataBtn") var metadataBtn: Button?
    @GodotNode("VBox/Buttons/ContextBtn") var contextBtn: Button?
    @GodotNode("VBox/Buttons/SignalsBtn") var signalsBtn: Button?
    @GodotNode("BackButton") var backButton: Button?

    // MARK: - Test Nodes

    @GodotNode("TestNodes") var testContainer: Node?

    // MARK: - Lifecycle

    override func _ready() {
        configureNodes()
        setupButtons()
        setupTestHierarchy()
        output("Feature Catalog ready!\nSelect a feature to explore.")

        GodotContext.log("""

        ╔═══════════════════════════════════════════╗
        ║           Feature Catalog                 ║
        ╠═══════════════════════════════════════════╣
        ║  Interactive demos of all features:       ║
        ║  • Node Extensions                        ║
        ║  • Object Metadata                        ║
        ║  • GodotContext Utilities                 ║
        ║  • Typed Signals                          ║
        ╚═══════════════════════════════════════════╝

        """)
    }

    // MARK: - Setup

    private func configureNodes() {
        $outputLabel.configure(owner: self)
        $nodeExtBtn.configure(owner: self)
        $metadataBtn.configure(owner: self)
        $contextBtn.configure(owner: self)
        $signalsBtn.configure(owner: self)
        $backButton.configure(owner: self)
        $testContainer.configure(owner: self)
    }

    private func setupButtons() {
        nodeExtBtn?.on("pressed") { [weak self] in self?.demoNodeExtensions() }
        metadataBtn?.on("pressed") { [weak self] in self?.demoMetadata() }
        contextBtn?.on("pressed") { [weak self] in self?.demoContext() }
        signalsBtn?.on("pressed") { [weak self] in self?.demoSignals() }

        backButton?.on("pressed") { [weak self] in
            _ = self?.getTree()?.changeSceneToFile(path: "res://demo_menu.tscn")
        }
    }

    private func setupTestHierarchy() {
        // Create test node hierarchy for demonstrations
        guard let container = testContainer else { return }

        let level1 = Node()
        level1.name = "Level1"

        let level2a = Node()
        level2a.name = "Level2_A"
        let level2b = Node()
        level2b.name = "Level2_B"

        let level3 = Node()
        level3.name = "Level3"

        level1.addChild(node: level2a)
        level1.addChild(node: level2b)
        level2a.addChild(node: level3)

        container.addChild(node: level1)
    }

    // MARK: - Demo: Node Extensions

    private func demoNodeExtensions() {
        var lines: [String] = ["=== Node Extensions ===\n"]

        guard let container = testContainer,
              let level1 = container.child(ofType: Node.self) else {
            output("Test hierarchy not found")
            return
        }

        // Children
        lines.append("Children of container:")
        for child in container.children {
            lines.append("  • \(child.name)")
        }

        // Descendants
        lines.append("\nDescendants (depth-first):")
        for descendant in container.descendants {
            lines.append("  → \(descendant.name)")
        }

        // Ancestors
        if let level3 = container.descendants(ofType: Node.self).first(where: { $0.name == "Level3" }) {
            lines.append("\nAncestors of Level3:")
            for ancestor in level3.ancestors {
                lines.append("  ↑ \(ancestor.name)")
            }
        }

        // Siblings
        if let level2a = level1.child(where: { $0.name == "Level2_A" }) {
            lines.append("\nSiblings of Level2_A:")
            for sibling in level2a.siblings {
                lines.append("  ↔ \(sibling.name)")
            }

            if let next = level2a.nextSibling {
                lines.append("  Next sibling: \(next.name)")
            }
        }

        // Type queries
        let allNodes = container.descendants(ofType: Node.self)
        lines.append("\nTotal descendants: \(allNodes.count)")

        output(lines.joined(separator: "\n"))
    }

    // MARK: - Demo: Metadata

    private func demoMetadata() {
        var lines: [String] = ["=== Object Metadata ===\n"]

        // Set metadata using subscript
        self[meta: "player_score"] = Variant(1500)
        self[meta: "player_name"] = Variant("Swift Hero")
        self[meta: "is_premium"] = Variant(true)

        lines.append("Set metadata:")
        lines.append("  [meta: \"player_score\"] = 1500")
        lines.append("  [meta: \"player_name\"] = \"Swift Hero\"")
        lines.append("  [meta: \"is_premium\"] = true")

        // Read metadata
        lines.append("\nRead metadata:")
        if let score = self[meta: "player_score"] {
            lines.append("  Score: \(score)")
        }
        if let name = self[meta: "player_name"] {
            lines.append("  Name: \(name)")
        }

        // Check existence
        lines.append("\nCheck existence:")
        lines.append("  hasMeta(\"player_score\"): \(hasMeta("player_score"))")
        lines.append("  hasMeta(\"nonexistent\"): \(hasMeta("nonexistent"))")

        // Remove metadata
        self[meta: "player_score"] = nil
        lines.append("\nRemoved player_score")
        lines.append("  hasMeta(\"player_score\"): \(hasMeta("player_score"))")

        output(lines.joined(separator: "\n"))
    }

    // MARK: - Demo: GodotContext

    private func demoContext() {
        var lines: [String] = ["=== GodotContext Utilities ===\n"]

        // Engine state
        lines.append("Engine State:")
        lines.append("  isRunning: \(GodotContext.isRunning)")
        lines.append("  isEditor: \(GodotContext.isEditor)")

        // Performance
        lines.append("\nPerformance:")
        lines.append("  FPS: \(GodotContext.fps)")
        lines.append("  Frame: \(GodotContext.frame)")
        lines.append("  Physics Frame: \(GodotContext.physicsFrame)")

        // Timing
        let uptime = GodotContext.uptime
        lines.append("\nTiming:")
        lines.append("  Uptime: \(String(format: "%.2f", uptime))s")

        // Logging
        lines.append("\nLogging (check console):")
        GodotContext.log("This is a log message")
        GodotContext.warn("This is a warning")
        lines.append("  GodotContext.log(\"...\")")
        lines.append("  GodotContext.warn(\"...\")")

        // Instance ID
        lines.append("\nObject Identity:")
        lines.append("  instanceID: \(instanceID)")

        output(lines.joined(separator: "\n"))
    }

    // MARK: - Demo: Typed Signals

    private func demoSignals() {
        var lines: [String] = ["=== Typed Signals ===\n"]

        // Create a signal emitter
        let emitter = SignalEmitterDemo()
        addChild(node: emitter)

        lines.append("Created SignalEmitterDemo node")
        lines.append("\nSignal Definitions:")
        lines.append("  Signal0(\"simple_event\")")
        lines.append("  Signal1<Int>(\"score_changed\")")
        lines.append("  Signal2<String, Int>(\"item_collected\")")

        // Connect to signals
        var eventCount = 0

        emitter.on(SignalEmitterDemo.simpleEvent) {
            eventCount += 1
        }

        // Note: For Signal1/2, we use the string name since Swift can't infer types
        emitter.on(SignalEmitterDemo.scoreChanged.name) {
            // Signal received (args available via signal parameters)
        }

        lines.append("\nConnected handlers using on(Signal0)")
        lines.append("Emitting signals...")

        // Emit signals
        emitter.emit(SignalEmitterDemo.simpleEvent)
        emitter.emitSignal(SignalEmitterDemo.scoreChanged.name, Variant(100))
        emitter.emitSignal(SignalEmitterDemo.itemCollected.name, Variant("Gold Coin"), Variant(50))

        lines.append("\nSignal queries:")
        lines.append("  has(signal: \"simple_event\"): \(emitter.has(signal: "simple_event"))")
        lines.append("  hasConnections(for: \"simple_event\"): \(emitter.hasConnections(for: StringName("simple_event")))")
        lines.append("  connectionCount: \(emitter.connectionCount(for: StringName("simple_event")))")

        // Cleanup
        emitter.queueFree()

        output(lines.joined(separator: "\n"))
    }

    // MARK: - Helpers

    private func output(_ text: String) {
        outputLabel?.text = text
    }
}

// MARK: - Signal Emitter Demo

/// Demo class showing typed signal definitions
@Godot
class SignalEmitterDemo: Node, SignalEmitting {

    // Typed signal definitions
    static let simpleEvent = Signal0("simple_event")
    static let scoreChanged = Signal1<Int>("score_changed")
    static let itemCollected = Signal2<String, Int>("item_collected")
}
