import SwiftGodotKit
import Game

// MARK: - Game Systems Demo

/// Demonstrates swift-game systems with SwiftGodotKit
@Godot
class GameSystemsShowcase: Control {

    // MARK: - Node References

    @GodotNode("VBox/ButtonRow/PathBtn") var pathBtn: Button?
    @GodotNode("VBox/ButtonRow/DiceBtn") var diceBtn: Button?
    @GodotNode("VBox/ButtonRow/LootBtn") var lootBtn: Button?
    @GodotNode("VBox/ButtonRow2/ResetBtn") var resetBtn: Button?
    @GodotNode("VBox/ButtonRow2/RandomBtn") var randomBtn: Button?
    @GodotNode("VBox/StatusLabel") var statusLabel: Label?
    @GodotNode("Canvas") var canvas: Control?
    @GodotNode("BackButton") var backButton: Button?
    @GodotNode("PauseMenu") var pauseMenu: PauseMenu?

    // MARK: - State

    @GodotState var statusText: String = "Explore game systems from swift-game!"
    @GodotState var currentMode: GameMode = .pathfinding

    private var gridCells: [[ColorRect]] = []
    private var pathMarkers: [ColorRect] = []
    private var textLabels: [Label] = []
    private var rng = GameRandom()

    private let gridSize = 15
    private let cellSize: Float = 25

    enum GameMode {
        case pathfinding, dice, loot
    }

    // MARK: - Lifecycle

    override func _ready() {
        configureNodes()
        setupButtons()
        showPathfinding()

        GodotContext.log("""

        ╔═══════════════════════════════════════════╗
        ║          Game Systems Demo                ║
        ╠═══════════════════════════════════════════╣
        ║  Package: swift-game                      ║
        ║  • A* Pathfinding                         ║
        ║  • Dice roller & statistics               ║
        ║  • Loot table generator                   ║
        ║  Press ESC for controls                   ║
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
        $pathBtn.configure(owner: self)
        $diceBtn.configure(owner: self)
        $lootBtn.configure(owner: self)
        $resetBtn.configure(owner: self)
        $randomBtn.configure(owner: self)
        $statusLabel.configure(owner: self)
        $canvas.configure(owner: self)
        $backButton.configure(owner: self)
        $pauseMenu.configure(owner: self)
    }

    private func setupButtons() {
        pathBtn?.on("pressed") { [weak self] in
            self?.currentMode = .pathfinding
            self?.showPathfinding()
        }

        diceBtn?.on("pressed") { [weak self] in
            self?.currentMode = .dice
            self?.showDice()
        }

        lootBtn?.on("pressed") { [weak self] in
            self?.currentMode = .loot
            self?.showLoot()
        }

        resetBtn?.on("pressed") { [weak self] in
            self?.regenerate()
        }

        randomBtn?.on("pressed") { [weak self] in
            self?.rng = GameRandom()
            self?.regenerate()
        }

        backButton?.on("pressed") { [weak self] in
            _ = self?.getTree()?.changeSceneToFile(path: "res://demo_menu.tscn")
        }
    }

    private func regenerate() {
        switch currentMode {
        case .pathfinding: showPathfinding()
        case .dice: showDice()
        case .loot: showLoot()
        }
    }

    // MARK: - Clear Canvas

    private func clearCanvas() {
        for row in gridCells {
            for cell in row {
                cell.queueFree()
            }
        }
        gridCells.removeAll()

        for marker in pathMarkers {
            marker.queueFree()
        }
        pathMarkers.removeAll()

        for label in textLabels {
            label.queueFree()
        }
        textLabels.removeAll()
    }

    // MARK: - Pathfinding Demo

    private func showPathfinding() {
        clearCanvas()
        statusText = "A* Pathfinding (swift-game)"

        // Create grid visualization
        gridCells = []
        for y in 0..<gridSize {
            var row: [ColorRect] = []
            for x in 0..<gridSize {
                let cell = ColorRect()
                cell.color = Color(r: 0.2, g: 0.25, b: 0.3, a: 1.0)
                cell.setPosition(Vector2(x: Float(x) * cellSize + 2, y: Float(y) * cellSize + 2))
                cell.customMinimumSize = Vector2(x: cellSize - 2, y: cellSize - 2)
                cell.setSize(Vector2(x: cellSize - 2, y: cellSize - 2))
                canvas?.addChild(node: cell)
                row.append(cell)
            }
            gridCells.append(row)
        }

        // Create navigation grid with some obstacles
        var grid = Grid2D<Bool>(width: gridSize, height: gridSize, defaultValue: true)

        // Add random obstacles
        let numObstacles = rng.nextInt(in: 15...25)
        for _ in 0..<numObstacles {
            let x = rng.nextInt(in: 1...(gridSize - 2))
            let y = rng.nextInt(in: 1...(gridSize - 2))
            grid[x, y] = false
            gridCells[y][x].color = Color(r: 0.4, g: 0.2, b: 0.2, a: 1.0)
        }

        // Create navigation grid
        let navGrid = NavigationGrid(grid: grid, allowDiagonal: false)

        // Random start and goal
        let start = GridCoord(x: 0, y: rng.nextInt(in: 0...(gridSize - 1)))
        let goal = GridCoord(x: gridSize - 1, y: rng.nextInt(in: 0...(gridSize - 1)))

        // Make sure start and goal are walkable
        gridCells[start.y][start.x].color = Color(r: 0.2, g: 0.8, b: 0.3, a: 1.0)  // Green
        gridCells[goal.y][goal.x].color = Color(r: 0.9, g: 0.3, b: 0.2, a: 1.0)    // Red

        // Find path using A*
        let path = AStar.findPathInGrid(in: navGrid, from: start, to: goal)

        if path.found {
            // Draw path
            for (i, node) in path.nodes.enumerated() {
                if node != start && node != goal {
                    let cell = gridCells[node.y][node.x]
                    cell.color = Color(r: 0.3, g: 0.6, b: 0.9, a: 1.0)  // Blue

                    // Add step number
                    let label = Label()
                    label.text = "\(i)"
                    label.setPosition(Vector2(
                        x: Float(node.x) * cellSize + 6,
                        y: Float(node.y) * cellSize + 4
                    ))
                    label.addThemeFontSizeOverride(name: "font_size", fontSize: 10)
                    canvas?.addChild(node: label)
                    textLabels.append(label)
                }
            }

            statusText = "Path found! Length: \(path.nodes.count), Cost: \(String(format: "%.1f", path.cost))"
            GodotContext.log("A* found path with \(path.nodes.count) nodes, cost \(path.cost)")

        } else {
            statusText = "No path found! Try regenerating."
            GodotContext.log("A* could not find path")
        }

        // Add legend
        let legendY: Float = Float(gridSize) * cellSize + 10
        let colors: [(Color, String)] = [
            (Color(r: 0.2, g: 0.8, b: 0.3, a: 1.0), "Start"),
            (Color(r: 0.9, g: 0.3, b: 0.2, a: 1.0), "Goal"),
            (Color(r: 0.3, g: 0.6, b: 0.9, a: 1.0), "Path"),
            (Color(r: 0.4, g: 0.2, b: 0.2, a: 1.0), "Wall")
        ]

        for (i, (color, text)) in colors.enumerated() {
            let marker = ColorRect()
            marker.color = color
            marker.setPosition(Vector2(x: Float(i * 100), y: legendY))
            marker.customMinimumSize = Vector2(x: 20, y: 20)
            marker.setSize(Vector2(x: 20, y: 20))
            canvas?.addChild(node: marker)
            pathMarkers.append(marker)

            let label = Label()
            label.text = text
            label.setPosition(Vector2(x: Float(i * 100) + 25, y: legendY + 2))
            canvas?.addChild(node: label)
            textLabels.append(label)
        }
    }

    // MARK: - Dice Demo

    private func showDice() {
        clearCanvas()
        statusText = "Dice Roller (swift-game)"

        let diceTypes: [Dice] = [.d4, .d6, .d8, .d10, .d12, .d20, .twod6, .threed6]
        var yOffset: Float = 0

        // Header
        let header = Label()
        header.text = "Dice Statistics (1000 rolls each):"
        header.setPosition(Vector2(x: 0, y: yOffset))
        canvas?.addChild(node: header)
        textLabels.append(header)
        yOffset += 30

        for dice in diceTypes {
            // Roll 1000 times and collect stats
            var results: [Int] = []
            for _ in 0..<1000 {
                results.append(dice.roll(using: &rng))
            }

            let actual = Double(results.reduce(0, +)) / Double(results.count)
            let minResult = results.min() ?? 0
            let maxResult = results.max() ?? 0

            // Dice name
            let nameLabel = Label()
            nameLabel.text = dice.description
            nameLabel.setPosition(Vector2(x: 0, y: yOffset))
            nameLabel.customMinimumSize = Vector2(x: 60, y: 25)
            canvas?.addChild(node: nameLabel)
            textLabels.append(nameLabel)

            // Stats
            let statsLabel = Label()
            statsLabel.text = String(format: "Range: %d-%d  Avg: %.1f (expected: %.1f)  Min: %d  Max: %d",
                                     dice.minimum, dice.maximum, actual, dice.average, minResult, maxResult)
            statsLabel.setPosition(Vector2(x: 70, y: yOffset))
            canvas?.addChild(node: statsLabel)
            textLabels.append(statsLabel)

            // Visual histogram (simplified)
            let histogramX: Float = 0
            let histogramY = yOffset + 22
            let barWidth: Float = 15

            // Count distribution
            var counts: [Int: Int] = [:]
            for result in results {
                counts[result, default: 0] += 1
            }

            let maxCount = counts.values.max() ?? 1
            for value in dice.minimum...min(dice.maximum, dice.minimum + 20) {
                let count = counts[value] ?? 0
                let barHeight = Float(count) / Float(maxCount) * 20

                let bar = ColorRect()
                bar.color = Color(r: 0.3, g: 0.6, b: 0.9, a: 0.8)
                bar.setPosition(Vector2(x: histogramX + Float(value - dice.minimum) * barWidth, y: histogramY + 20 - barHeight))
                bar.customMinimumSize = Vector2(x: barWidth - 2, y: barHeight)
                bar.setSize(Vector2(x: barWidth - 2, y: barHeight))
                canvas?.addChild(node: bar)
                pathMarkers.append(bar)
            }

            yOffset += 55
        }

        GodotContext.log("Generated dice statistics")
    }

    // MARK: - Loot Table Demo

    private func showLoot() {
        clearCanvas()
        statusText = "Loot Table Generator (swift-game)"

        // Define loot items
        enum LootItem: String, Sendable, Hashable, CaseIterable {
            case gold = "Gold Coins"
            case potion = "Health Potion"
            case sword = "Iron Sword"
            case shield = "Wooden Shield"
            case gem = "Rare Gem"
            case artifact = "Ancient Artifact"
        }

        // Create loot table with weights
        let entries: [LootTable<LootItem>.Entry] = [
            .init(item: .gold, weight: 40, quantity: 10...50),
            .init(item: .potion, weight: 25, quantity: 1...3),
            .init(item: .sword, weight: 15, quantity: 1...1),
            .init(item: .shield, weight: 10, quantity: 1...1),
            .init(item: .gem, weight: 7, quantity: 1...2),
            .init(item: .artifact, weight: 3, quantity: 1...1)
        ]

        let lootTable = LootTable<LootItem>.guaranteed(entries: entries)

        var yOffset: Float = 0

        // Header
        let header = Label()
        header.text = "Loot Table with Weighted Drops:"
        header.setPosition(Vector2(x: 0, y: yOffset))
        canvas?.addChild(node: header)
        textLabels.append(header)
        yOffset += 25

        // Show weights
        let totalWeight = entries.reduce(0.0) { $0 + $1.weight }
        for entry in entries {
            let percentage = (entry.weight / totalWeight) * 100

            // Item label
            let itemLabel = Label()
            itemLabel.text = "\(entry.item.rawValue)"
            itemLabel.setPosition(Vector2(x: 0, y: yOffset))
            itemLabel.customMinimumSize = Vector2(x: 150, y: 20)
            canvas?.addChild(node: itemLabel)
            textLabels.append(itemLabel)

            // Probability bar
            let barWidth = Float(percentage) * 2
            let bar = ColorRect()
            bar.color = colorForItem(entry.item)
            bar.setPosition(Vector2(x: 160, y: yOffset + 2))
            bar.customMinimumSize = Vector2(x: barWidth, y: 16)
            bar.setSize(Vector2(x: barWidth, y: 16))
            canvas?.addChild(node: bar)
            pathMarkers.append(bar)

            // Percentage label
            let pctLabel = Label()
            pctLabel.text = String(format: "%.1f%%", percentage)
            pctLabel.setPosition(Vector2(x: 170 + barWidth, y: yOffset))
            canvas?.addChild(node: pctLabel)
            textLabels.append(pctLabel)

            yOffset += 25
        }

        // Simulate rolls
        yOffset += 20
        let rollHeader = Label()
        rollHeader.text = "Simulating 100 chest opens:"
        rollHeader.setPosition(Vector2(x: 0, y: yOffset))
        canvas?.addChild(node: rollHeader)
        textLabels.append(rollHeader)
        yOffset += 25

        let results = lootTable.rollCombined(count: 100, using: &rng)
        let sortedResults = results.sorted { $0.value > $1.value }

        for (item, quantity) in sortedResults {
            let resultLabel = Label()
            resultLabel.text = "\(item.rawValue): \(quantity)"
            resultLabel.setPosition(Vector2(x: 20, y: yOffset))
            canvas?.addChild(node: resultLabel)
            textLabels.append(resultLabel)

            // Result bar
            let maxQty = sortedResults.first?.value ?? 1
            let barWidth = Float(quantity) / Float(maxQty) * 200
            let bar = ColorRect()
            bar.color = colorForItem(item)
            bar.setPosition(Vector2(x: 200, y: yOffset + 2))
            bar.customMinimumSize = Vector2(x: barWidth, y: 16)
            bar.setSize(Vector2(x: barWidth, y: 16))
            canvas?.addChild(node: bar)
            pathMarkers.append(bar)

            yOffset += 25
        }

        GodotContext.log("Generated loot table simulation")
    }

    private func colorForItem(_ item: some RawRepresentable<String>) -> Color {
        let value = item.rawValue
        switch value {
        case "Gold Coins": return Color(r: 1.0, g: 0.85, b: 0.3, a: 1.0)
        case "Health Potion": return Color(r: 0.9, g: 0.2, b: 0.3, a: 1.0)
        case "Iron Sword": return Color(r: 0.6, g: 0.6, b: 0.7, a: 1.0)
        case "Wooden Shield": return Color(r: 0.6, g: 0.4, b: 0.2, a: 1.0)
        case "Rare Gem": return Color(r: 0.3, g: 0.9, b: 0.9, a: 1.0)
        case "Ancient Artifact": return Color(r: 0.8, g: 0.3, b: 0.9, a: 1.0)
        default: return Color(r: 0.5, g: 0.5, b: 0.5, a: 1.0)
        }
    }
}
