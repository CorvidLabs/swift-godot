import SwiftGodotKit
import Game

// MARK: - Dungeon Crawler Demo

/// Top-down dungeon crawler demonstrating A* pathfinding and procedural generation
@Godot
class DungeonGame: Node2D {

    // MARK: - Constants

    private let gridWidth: Int = 30
    private let gridHeight: Int = 20
    private let cellSize: Float = 25

    // MARK: - Node References

    @GodotNode("UI/HealthLabel") var healthLabel: Label?
    @GodotNode("UI/GoldLabel") var goldLabel: Label?
    @GodotNode("UI/LevelLabel") var levelLabel: Label?
    @GodotNode("UI/MessageLabel") var messageLabel: Label?
    @GodotNode("BackButton") var backButton: Button?
    @GodotNode("PauseMenu") var pauseMenu: PauseMenu?
    @GodotNode("DungeonGrid") var dungeonGrid: Node2D?

    // MARK: - State

    @GodotState var health: Int = 100
    @GodotState var gold: Int = 0
    @GodotState var dungeonLevel: Int = 1
    @GodotState var message: String = ""

    private var grid: Grid2D<TileType> = Grid2D(width: 30, height: 20, defaultValue: .wall)
    private var navGrid: NavigationGrid?
    private var gridCells: [[ColorRect]] = []

    private var playerPos: GridCoord = GridCoord(x: 1, y: 1)
    private var playerNode: ColorRect?

    private var enemies: [DungeonEnemy] = []
    private var treasures: [DungeonTreasure] = []

    private var moveCooldown: Float = 0
    private let moveDelay: Float = 0.15

    private var random = GameRandom()
    private let dice = Dice.d6

    // MARK: - Types

    enum TileType {
        case wall
        case floor
        case exit
    }

    // MARK: - Lifecycle

    override func _ready() {
        configureNodes()
        setupSignals()
        generateDungeon()

        GodotContext.log("""

        ╔═══════════════════════════════════════════╗
        ║          Dungeon Crawler                  ║
        ╠═══════════════════════════════════════════╣
        ║  Controls:                                ║
        ║  • Arrow keys / WASD to move              ║
        ║  • Walk into enemies to attack            ║
        ║  • Collect gold, reach the exit           ║
        ║  Press ESC for pause menu                 ║
        ╚═══════════════════════════════════════════╝

        """)
    }

    override func _process(delta: Double) {
        if $health.changed { healthLabel?.text = "HP: \(health)" }
        if $gold.changed { goldLabel?.text = "Gold: \(gold)" }
        if $dungeonLevel.changed { levelLabel?.text = "Depth: \(dungeonLevel)" }
        if $message.changed { messageLabel?.text = message }

        $health.reset()
        $gold.reset()
        $dungeonLevel.reset()
        $message.reset()

        if health <= 0 {
            return
        }

        if moveCooldown > 0 {
            moveCooldown -= Float(delta)
        } else {
            handleInput()
        }

        updateEnemies()
    }

    // MARK: - Setup

    private func configureNodes() {
        $healthLabel.configure(owner: self)
        $goldLabel.configure(owner: self)
        $levelLabel.configure(owner: self)
        $messageLabel.configure(owner: self)
        $backButton.configure(owner: self)
        $pauseMenu.configure(owner: self)
        $dungeonGrid.configure(owner: self)
    }

    private func setupSignals() {
        backButton?.on("pressed") { [weak self] in
            _ = self?.getTree()?.changeSceneToFile(path: "res://demo_menu.tscn")
        }
    }

    // MARK: - Dungeon Generation

    private func generateDungeon() {
        guard let dungeonNode = dungeonGrid else { return }

        // Clear existing
        for row in gridCells {
            for cell in row { cell.queueFree() }
        }
        gridCells.removeAll()

        for enemy in enemies { enemy.node.queueFree() }
        enemies.removeAll()

        for treasure in treasures { treasure.node.queueFree() }
        treasures.removeAll()

        playerNode?.queueFree()

        // Initialize grid with walls
        grid = Grid2D(width: gridWidth, height: gridHeight, defaultValue: .wall)

        // Carve rooms using random room placement
        var rooms: [Rect] = []
        let numRooms = 5 + dungeonLevel

        for _ in 0..<numRooms * 3 {  // Try multiple times
            let roomW = random.nextInt(in: 4...8)
            let roomH = random.nextInt(in: 3...6)
            let roomX = random.nextInt(in: 1...(gridWidth - roomW - 1))
            let roomY = random.nextInt(in: 1...(gridHeight - roomH - 1))

            let newRoom = Rect(x: roomX, y: roomY, w: roomW, h: roomH)

            // Check overlap
            var overlaps = false
            for room in rooms {
                if newRoom.intersects(room, margin: 1) {
                    overlaps = true
                    break
                }
            }

            if !overlaps {
                rooms.append(newRoom)
                carveRoom(newRoom)

                if rooms.count >= numRooms { break }
            }
        }

        // Connect rooms with corridors
        for i in 1..<rooms.count {
            let prev = rooms[i - 1].center
            let curr = rooms[i].center

            if random.nextInt(in: 0...1) == 0 {
                carveHorizontalCorridor(from: prev.x, to: curr.x, y: prev.y)
                carveVerticalCorridor(from: prev.y, to: curr.y, x: curr.x)
            } else {
                carveVerticalCorridor(from: prev.y, to: curr.y, x: prev.x)
                carveHorizontalCorridor(from: prev.x, to: curr.x, y: curr.y)
            }
        }

        // Place exit in last room
        if let lastRoom = rooms.last {
            let exitPos = lastRoom.center
            grid[exitPos.x, exitPos.y] = .exit
        }

        // Place player in first room
        if let firstRoom = rooms.first {
            playerPos = firstRoom.center
        }

        // Create navigation grid
        var walkableGrid = Grid2D<Bool>(width: gridWidth, height: gridHeight, defaultValue: false)
        for y in 0..<gridHeight {
            for x in 0..<gridWidth {
                walkableGrid[x, y] = grid[x, y] != .wall
            }
        }
        navGrid = NavigationGrid(grid: walkableGrid, allowDiagonal: false)

        // Render grid
        renderGrid(dungeonNode)

        // Spawn enemies in random rooms (not first room)
        for i in 1..<rooms.count {
            let enemyCount = 1 + dungeonLevel / 2
            for _ in 0..<enemyCount {
                let room = rooms[i]
                let pos = GridCoord(
                    x: random.nextInt(in: room.x...(room.x + room.w - 1)),
                    y: random.nextInt(in: room.y...(room.y + room.h - 1))
                )
                if grid[pos.x, pos.y] == .floor {
                    spawnEnemy(at: pos, in: dungeonNode)
                }
            }
        }

        // Spawn treasures
        for room in rooms {
            if random.nextInt(in: 0...2) == 0 {  // 33% chance per room
                let pos = GridCoord(
                    x: random.nextInt(in: room.x...(room.x + room.w - 1)),
                    y: random.nextInt(in: room.y...(room.y + room.h - 1))
                )
                if grid[pos.x, pos.y] == .floor {
                    spawnTreasure(at: pos, in: dungeonNode)
                }
            }
        }

        // Create player
        createPlayer(dungeonNode)

        message = "Explore the dungeon! Find the exit."
    }

    private func carveRoom(_ room: Rect) {
        for y in room.y..<(room.y + room.h) {
            for x in room.x..<(room.x + room.w) {
                grid[x, y] = .floor
            }
        }
    }

    private func carveHorizontalCorridor(from x1: Int, to x2: Int, y: Int) {
        for x in min(x1, x2)...max(x1, x2) {
            if x >= 0 && x < gridWidth && y >= 0 && y < gridHeight {
                grid[x, y] = .floor
            }
        }
    }

    private func carveVerticalCorridor(from y1: Int, to y2: Int, x: Int) {
        for y in min(y1, y2)...max(y1, y2) {
            if x >= 0 && x < gridWidth && y >= 0 && y < gridHeight {
                grid[x, y] = .floor
            }
        }
    }

    private func renderGrid(_ parent: Node2D) {
        gridCells = []

        for y in 0..<gridHeight {
            var row: [ColorRect] = []
            for x in 0..<gridWidth {
                let cell = ColorRect()
                let tile = grid[x, y]

                switch tile {
                case .wall:
                    cell.color = Color(r: 0.2, g: 0.15, b: 0.1, a: 1.0)
                case .floor:
                    cell.color = Color(r: 0.35, g: 0.3, b: 0.25, a: 1.0)
                case .exit:
                    cell.color = Color(r: 0.2, g: 0.7, b: 0.3, a: 1.0)
                default:
                    cell.color = Color(r: 0.1, g: 0.1, b: 0.1, a: 1.0)
                }

                cell.setPosition(Vector2(x: Float(x) * cellSize, y: Float(y) * cellSize))
                cell.customMinimumSize = Vector2(x: cellSize - 1, y: cellSize - 1)
                cell.setSize(Vector2(x: cellSize - 1, y: cellSize - 1))
                parent.addChild(node: cell)
                row.append(cell)
            }
            gridCells.append(row)
        }
    }

    private func createPlayer(_ parent: Node2D) {
        let player = ColorRect()
        player.color = Color(r: 0.2, g: 0.6, b: 1.0, a: 1.0)
        player.customMinimumSize = Vector2(x: cellSize - 4, y: cellSize - 4)
        player.setSize(Vector2(x: cellSize - 4, y: cellSize - 4))
        parent.addChild(node: player)
        playerNode = player
        updatePlayerVisual()
    }

    private func updatePlayerVisual() {
        playerNode?.setPosition(Vector2(
            x: Float(playerPos.x) * cellSize + 2,
            y: Float(playerPos.y) * cellSize + 2
        ))
    }

    private func spawnEnemy(at pos: GridCoord, in parent: Node2D) {
        let enemy = DungeonEnemy(
            pos: pos,
            health: 10 + dungeonLevel * 5,
            damage: 5 + dungeonLevel * 2,
            cellSize: cellSize
        )
        parent.addChild(node: enemy.node)
        enemies.append(enemy)
    }

    private func spawnTreasure(at pos: GridCoord, in parent: Node2D) {
        let treasure = DungeonTreasure(pos: pos, value: 10 + random.nextInt(in: 0...(dungeonLevel * 5)), cellSize: cellSize)
        parent.addChild(node: treasure.node)
        treasures.append(treasure)
    }

    // MARK: - Input

    private func handleInput() {
        var moveDir: GridCoord?

        if Input.isActionPressed(action: "ui_up") || Input.isActionPressed(action: "move_up") {
            moveDir = GridCoord(x: 0, y: -1)
        } else if Input.isActionPressed(action: "ui_down") || Input.isActionPressed(action: "move_down") {
            moveDir = GridCoord(x: 0, y: 1)
        } else if Input.isActionPressed(action: "ui_left") || Input.isActionPressed(action: "move_left") {
            moveDir = GridCoord(x: -1, y: 0)
        } else if Input.isActionPressed(action: "ui_right") || Input.isActionPressed(action: "move_right") {
            moveDir = GridCoord(x: 1, y: 0)
        }

        guard let dir = moveDir else { return }

        let newPos = GridCoord(x: playerPos.x + dir.x, y: playerPos.y + dir.y)

        // Check bounds
        guard newPos.x >= 0 && newPos.x < gridWidth &&
              newPos.y >= 0 && newPos.y < gridHeight else { return }

        // Check for enemy collision (attack)
        for (index, enemy) in enemies.enumerated() {
            if enemy.pos == newPos {
                attackEnemy(index: index)
                moveCooldown = moveDelay
                return
            }
        }

        // Check for wall
        guard grid[newPos.x, newPos.y] != .wall else { return }

        // Move player
        playerPos = newPos
        updatePlayerVisual()
        moveCooldown = moveDelay

        // Check for treasure
        checkTreasurePickup()

        // Check for exit
        if grid[newPos.x, newPos.y] == .exit {
            nextLevel()
        }
    }

    private func attackEnemy(index: Int) {
        let damage = dice.roll(using: &random) + dice.roll(using: &random)
        enemies[index].health -= damage
        message = "Hit enemy for \(damage) damage!"

        if enemies[index].health <= 0 {
            enemies[index].node.queueFree()
            enemies.remove(at: index)
            gold += 5 + dungeonLevel * 2
            message = "Enemy defeated! +\(5 + dungeonLevel * 2) gold"
        }
    }

    private func checkTreasurePickup() {
        for (index, treasure) in treasures.enumerated().reversed() {
            if treasure.pos == playerPos {
                gold += treasure.value
                message = "Found \(treasure.value) gold!"
                treasure.node.queueFree()
                treasures.remove(at: index)
            }
        }
    }

    private func nextLevel() {
        dungeonLevel += 1
        health = min(100, health + 20)
        message = "Descended to level \(dungeonLevel)!"
        generateDungeon()
    }

    // MARK: - Enemy AI

    private func updateEnemies() {
        guard let nav = navGrid else { return }

        for enemy in enemies {
            enemy.moveCooldown -= 0.016  // Approximate delta

            if enemy.moveCooldown <= 0 {
                enemy.moveCooldown = 0.5  // Enemies move slower

                // Use A* to find path to player
                let path = AStar.findPathInGrid(in: nav, from: enemy.pos, to: playerPos)

                if path.found && path.nodes.count > 1 {
                    let nextPos = path.nodes[1]

                    // Check if player is at next position (attack)
                    if nextPos == playerPos {
                        let damage = dice.roll(using: &random) + dungeonLevel
                        health -= damage
                        message = "Enemy hit you for \(damage) damage!"

                        if health <= 0 {
                            message = "You died! Game Over."
                            GodotContext.log("Dungeon Crawler - Game Over at depth \(dungeonLevel)")
                        }
                    } else {
                        // Check if another enemy is there
                        let blocked = enemies.contains { $0.pos == nextPos && $0 !== enemy }
                        if !blocked {
                            enemy.pos = nextPos
                            enemy.updateVisual()
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Helper Types

struct Rect {
    let x, y, w, h: Int

    var center: GridCoord {
        GridCoord(x: x + w / 2, y: y + h / 2)
    }

    func intersects(_ other: Rect, margin: Int = 0) -> Bool {
        return x - margin < other.x + other.w + margin &&
               x + w + margin > other.x - margin &&
               y - margin < other.y + other.h + margin &&
               y + h + margin > other.y - margin
    }
}

class DungeonEnemy {
    let node: ColorRect
    var pos: GridCoord
    var health: Int
    let damage: Int
    let cellSize: Float
    var moveCooldown: Float = 0

    init(pos: GridCoord, health: Int, damage: Int, cellSize: Float) {
        self.pos = pos
        self.health = health
        self.damage = damage
        self.cellSize = cellSize

        node = ColorRect()
        node.color = Color(r: 0.9, g: 0.2, b: 0.2, a: 1.0)
        node.customMinimumSize = Vector2(x: cellSize - 4, y: cellSize - 4)
        node.setSize(Vector2(x: cellSize - 4, y: cellSize - 4))
        updateVisual()
    }

    func updateVisual() {
        node.setPosition(Vector2(
            x: Float(pos.x) * cellSize + 2,
            y: Float(pos.y) * cellSize + 2
        ))
    }
}

class DungeonTreasure {
    let node: ColorRect
    let pos: GridCoord
    let value: Int

    init(pos: GridCoord, value: Int, cellSize: Float) {
        self.pos = pos
        self.value = value

        node = ColorRect()
        node.color = Color(r: 1.0, g: 0.85, b: 0.2, a: 1.0)
        node.customMinimumSize = Vector2(x: cellSize - 8, y: cellSize - 8)
        node.setSize(Vector2(x: cellSize - 8, y: cellSize - 8))
        node.setPosition(Vector2(
            x: Float(pos.x) * cellSize + 4,
            y: Float(pos.y) * cellSize + 4
        ))
    }
}
