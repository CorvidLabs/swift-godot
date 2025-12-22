import SwiftGodotKit
import Art
// SwiftColor typealias is defined in SwiftColorAlias.swift

// MARK: - Procedural Art Demo

/// Demonstrates swift-art procedural generation with SwiftGodotKit
@Godot
class ProceduralArtShowcase: Control {

    // MARK: - Node References

    @GodotNode("VBox/ButtonRow/NoiseBtn") var noiseBtn: Button?
    @GodotNode("VBox/ButtonRow/LifeBtn") var lifeBtn: Button?
    @GodotNode("VBox/ButtonRow/FractalBtn") var fractalBtn: Button?
    @GodotNode("VBox/ButtonRow2/VoronoiBtn") var voronoiBtn: Button?
    @GodotNode("VBox/ButtonRow2/GradientBtn") var gradientBtn: Button?
    @GodotNode("VBox/ButtonRow2/RegenBtn") var regenBtn: Button?
    @GodotNode("VBox/StatusLabel") var statusLabel: Label?
    @GodotNode("Canvas") var canvas: TextureRect?
    @GodotNode("BackButton") var backButton: Button?
    @GodotNode("PauseMenu") var pauseMenu: PauseMenu?

    // MARK: - State

    @GodotState var statusText: String = "Select a procedural art type to generate!"
    @GodotState var currentMode: ArtMode = .noise

    private var imageTexture: ImageTexture?
    private let canvasSize: Int = 256
    private var gameOfLife: GameOfLife?
    private var lifeTimer: Timer?
    private var seed: UInt64 = 42

    enum ArtMode {
        case noise, life, fractal, voronoi, gradient
    }

    // MARK: - Lifecycle

    override func _ready() {
        configureNodes()
        setupButtons()
        generateNoise()

        GodotContext.log("""

        ╔═══════════════════════════════════════════╗
        ║         Procedural Art Demo               ║
        ╠═══════════════════════════════════════════╣
        ║  Packages: swift-art, swift-color         ║
        ║  • Perlin noise terrain                   ║
        ║  • Game of Life simulation                ║
        ║  • Mandelbrot fractal                     ║
        ║  • Voronoi diagrams                       ║
        ║  • Color gradients                        ║
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

    override func _exitTree() {
        lifeTimer?.stop()
        lifeTimer?.queueFree()
    }

    // MARK: - Setup

    private func configureNodes() {
        $noiseBtn.configure(owner: self)
        $lifeBtn.configure(owner: self)
        $fractalBtn.configure(owner: self)
        $voronoiBtn.configure(owner: self)
        $gradientBtn.configure(owner: self)
        $regenBtn.configure(owner: self)
        $statusLabel.configure(owner: self)
        $canvas.configure(owner: self)
        $backButton.configure(owner: self)
        $pauseMenu.configure(owner: self)
    }

    private func setupButtons() {
        noiseBtn?.on("pressed") { [weak self] in
            self?.currentMode = .noise
            self?.generateNoise()
        }

        lifeBtn?.on("pressed") { [weak self] in
            self?.currentMode = .life
            self?.startGameOfLife()
        }

        fractalBtn?.on("pressed") { [weak self] in
            self?.currentMode = .fractal
            self?.generateFractal()
        }

        voronoiBtn?.on("pressed") { [weak self] in
            self?.currentMode = .voronoi
            self?.generateVoronoi()
        }

        gradientBtn?.on("pressed") { [weak self] in
            self?.currentMode = .gradient
            self?.generateGradient()
        }

        regenBtn?.on("pressed") { [weak self] in
            self?.regenerate()
        }

        backButton?.on("pressed") { [weak self] in
            self?.lifeTimer?.stop()
            _ = self?.getTree()?.changeSceneToFile(path: "res://demo_menu.tscn")
        }
    }

    // MARK: - Regenerate

    private func regenerate() {
        seed = UInt64.random(in: 0...UInt64.max)
        switch currentMode {
        case .noise: generateNoise()
        case .life: startGameOfLife()
        case .fractal: generateFractal()
        case .voronoi: generateVoronoi()
        case .gradient: generateGradient()
        }
    }

    // MARK: - Perlin Noise

    private func generateNoise() {
        lifeTimer?.stop()
        statusText = "Perlin Noise (swift-art) - Seed: \(seed)"

        let noise = PerlinNoise(seed: seed)
        guard let image = Image.create(width: Int32(canvasSize), height: Int32(canvasSize), useMipmaps: false, format: .rgb8) else { return }

        let scale = 0.02

        for y in 0..<canvasSize {
            for x in 0..<canvasSize {
                let value = noise.sample(x: Double(x) * scale, y: Double(y) * scale)
                let normalized = (value + 1.0) / 2.0

                // Create terrain-like coloring
                let color = terrainColor(height: normalized)
                image.setPixel(x: Int32(x), y: Int32(y), color: color)
            }
        }

        updateCanvas(with: image)
        GodotContext.log("Generated Perlin noise terrain with seed \(seed)")
    }

    private func terrainColor(height: Double) -> SwiftGodot.Color {
        if height < 0.3 {
            // Deep water
            return SwiftGodot.Color(r: 0.1, g: 0.2, b: 0.6, a: 1.0)
        } else if height < 0.4 {
            // Shallow water
            return SwiftGodot.Color(r: 0.2, g: 0.4, b: 0.7, a: 1.0)
        } else if height < 0.45 {
            // Beach
            return SwiftGodot.Color(r: 0.9, g: 0.85, b: 0.6, a: 1.0)
        } else if height < 0.65 {
            // Grass
            return SwiftGodot.Color(r: 0.3, g: 0.6, b: 0.2, a: 1.0)
        } else if height < 0.8 {
            // Mountain
            return SwiftGodot.Color(r: 0.5, g: 0.4, b: 0.3, a: 1.0)
        } else {
            // Snow
            return SwiftGodot.Color(r: 0.95, g: 0.95, b: 0.95, a: 1.0)
        }
    }

    // MARK: - Game of Life

    private func startGameOfLife() {
        lifeTimer?.stop()
        lifeTimer?.queueFree()
        lifeTimer = nil

        statusText = "Game of Life (swift-art) - Running..."

        // Initialize Game of Life
        let gridSize = canvasSize / 4  // Each cell is 4x4 pixels
        var life = GameOfLife(width: gridSize, height: gridSize)
        life.randomize(probability: 0.3, seed: seed)
        gameOfLife = life

        // Render initial state
        renderGameOfLife()

        // Create timer for updates
        let timer = Timer()
        timer.waitTime = 0.1
        timer.autostart = true
        addChild(node: timer)
        lifeTimer = timer

        timer.on("timeout") { [weak self] in
            self?.stepGameOfLife()
        }

        GodotContext.log("Started Game of Life simulation")
    }

    private func stepGameOfLife() {
        gameOfLife?.step()
        renderGameOfLife()

        if let life = gameOfLife {
            statusText = "Game of Life - Population: \(life.populationCount)"
        }
    }

    private func renderGameOfLife() {
        guard let life = gameOfLife else { return }
        guard let image = Image.create(width: Int32(canvasSize), height: Int32(canvasSize), useMipmaps: false, format: .rgb8) else { return }

        let cellSize = canvasSize / life.width
        let aliveColor = SwiftGodot.Color(r: 0.2, g: 0.8, b: 0.3, a: 1.0)
        let deadColor = SwiftGodot.Color(r: 0.1, g: 0.1, b: 0.15, a: 1.0)

        for y in 0..<life.height {
            for x in 0..<life.width {
                let alive = life.isAlive(x: x, y: y)
                let color = alive ? aliveColor : deadColor

                // Fill cell
                for dy in 0..<cellSize {
                    for dx in 0..<cellSize {
                        let px = x * cellSize + dx
                        let py = y * cellSize + dy
                        if px < canvasSize && py < canvasSize {
                            image.setPixel(x: Int32(px), y: Int32(py), color: color)
                        }
                    }
                }
            }
        }

        updateCanvas(with: image)
    }

    // MARK: - Mandelbrot Fractal

    private func generateFractal() {
        lifeTimer?.stop()
        statusText = "Mandelbrot Fractal (swift-art)"

        guard let image = Image.create(width: Int32(canvasSize), height: Int32(canvasSize), useMipmaps: false, format: .rgb8) else { return }

        // Mandelbrot parameters
        let xMin = -2.5
        let xMax = 1.0
        let yMin = -1.5
        let yMax = 1.5
        let maxIterations = 100

        for py in 0..<canvasSize {
            for px in 0..<canvasSize {
                let x0 = xMin + (xMax - xMin) * Double(px) / Double(canvasSize)
                let y0 = yMin + (yMax - yMin) * Double(py) / Double(canvasSize)

                var x = 0.0
                var y = 0.0
                var iteration = 0

                while x * x + y * y <= 4 && iteration < maxIterations {
                    let xTemp = x * x - y * y + x0
                    y = 2 * x * y + y0
                    x = xTemp
                    iteration += 1
                }

                let color = fractalColor(iteration: iteration, maxIterations: maxIterations)
                image.setPixel(x: Int32(px), y: Int32(py), color: color)
            }
        }

        updateCanvas(with: image)
        GodotContext.log("Generated Mandelbrot fractal")
    }

    private func fractalColor(iteration: Int, maxIterations: Int) -> SwiftGodot.Color {
        if iteration == maxIterations {
            return SwiftGodot.Color(r: 0, g: 0, b: 0, a: 1)
        }

        let t = Double(iteration) / Double(maxIterations)

        // Smooth coloring using swift-color palette
        let hue = t * 360.0
        let saturation = 0.8
        let lightness = 0.5

        // Convert HSL to RGB manually
        let c = (1 - abs(2 * lightness - 1)) * saturation
        let h = hue / 60.0
        let x = c * (1 - abs(h.truncatingRemainder(dividingBy: 2) - 1))
        let m = lightness - c / 2

        var r = 0.0, g = 0.0, b = 0.0

        if h < 1 { r = c; g = x; b = 0 }
        else if h < 2 { r = x; g = c; b = 0 }
        else if h < 3 { r = 0; g = c; b = x }
        else if h < 4 { r = 0; g = x; b = c }
        else if h < 5 { r = x; g = 0; b = c }
        else { r = c; g = 0; b = x }

        return SwiftGodot.Color(r: Float(r + m), g: Float(g + m), b: Float(b + m), a: 1)
    }

    // MARK: - Voronoi

    private func generateVoronoi() {
        lifeTimer?.stop()
        statusText = "Voronoi Diagram (swift-art)"

        guard let image = Image.create(width: Int32(canvasSize), height: Int32(canvasSize), useMipmaps: false, format: .rgb8) else { return }

        // Generate random points
        var rng = RandomSource(seed: seed)
        let numPoints = 20
        var points: [(x: Int, y: Int, color: SwiftGodot.Color)] = []

        for _ in 0..<numPoints {
            let x = rng.nextInt(in: 0...(canvasSize - 1))
            let y = rng.nextInt(in: 0...(canvasSize - 1))
            let color = SwiftGodot.Color(
                r: Float(rng.nextDouble()),
                g: Float(rng.nextDouble()),
                b: Float(rng.nextDouble()),
                a: 1.0
            )
            points.append((x, y, color))
        }

        // Render Voronoi cells
        for py in 0..<canvasSize {
            for px in 0..<canvasSize {
                var minDist = Double.infinity
                var nearestColor = SwiftGodot.Color(r: 0, g: 0, b: 0, a: 1)

                for point in points {
                    let dx = Double(px - point.x)
                    let dy = Double(py - point.y)
                    let dist = dx * dx + dy * dy

                    if dist < minDist {
                        minDist = dist
                        nearestColor = point.color
                    }
                }

                image.setPixel(x: Int32(px), y: Int32(py), color: nearestColor)
            }
        }

        // Draw cell centers
        for point in points {
            for dy in -2...2 {
                for dx in -2...2 {
                    let px = point.x + dx
                    let py = point.y + dy
                    if px >= 0 && px < canvasSize && py >= 0 && py < canvasSize {
                        image.setPixel(x: Int32(px), y: Int32(py),
                                      color: SwiftGodot.Color(r: 0, g: 0, b: 0, a: 1))
                    }
                }
            }
        }

        updateCanvas(with: image)
        GodotContext.log("Generated Voronoi diagram with \(numPoints) cells")
    }

    // MARK: - Gradient (using swift-color)

    private func generateGradient() {
        lifeTimer?.stop()
        statusText = "Color Gradients (swift-color)"

        guard let image = Image.create(width: Int32(canvasSize), height: Int32(canvasSize), useMipmaps: false, format: .rgb8) else { return }

        // Create multiple gradient bands using swift-color
        // Note: Using available colors from swift-color (no orange/purple)
        let colors: [SwiftColor] = [
            .red, .yellow, .green, .cyan, .blue, .magenta, .red
        ]

        for py in 0..<canvasSize {
            for px in 0..<canvasSize {
                // Calculate position in gradient
                let t = Double(px) / Double(canvasSize - 1)
                let bandPos = t * Double(colors.count - 1)
                let bandIndex = Int(bandPos)
                let bandT = bandPos - Double(bandIndex)

                let color1 = colors[min(bandIndex, colors.count - 1)]
                let color2 = colors[min(bandIndex + 1, colors.count - 1)]

                // Mix colors
                let mixed = color1.mix(with: color2, ratio: bandT)

                // Add vertical variation based on y position
                let yFactor = Double(py) / Double(canvasSize)
                let lightened = mixed.lighten(by: (1 - yFactor) * 0.3)

                let godotColor = SwiftGodot.Color(
                    r: Float(lightened.red),
                    g: Float(lightened.green),
                    b: Float(lightened.blue),
                    a: 1.0
                )
                image.setPixel(x: Int32(px), y: Int32(py), color: godotColor)
            }
        }

        updateCanvas(with: image)
        GodotContext.log("Generated color gradient using swift-color")
    }

    // MARK: - Canvas Update

    private func updateCanvas(with image: Image) {
        let texture = ImageTexture.createFromImage(image)
        canvas?.texture = texture
        imageTexture = texture
    }
}
