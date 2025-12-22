import SwiftGodotKit
// SwiftColor typealias is defined in SwiftColorAlias.swift

// MARK: - Color Lab Demo

/// Demonstrates swift-color color science with SwiftGodotKit
@Godot
class ColorLabShowcase: Control {

    // MARK: - Node References

    @GodotNode("VBox/ButtonRow/HarmonyBtn") var harmonyBtn: Button?
    @GodotNode("VBox/ButtonRow/AccessBtn") var accessBtn: Button?
    @GodotNode("VBox/ButtonRow/BlindBtn") var blindBtn: Button?
    @GodotNode("VBox/ButtonRow2/GradientBtn") var gradientBtn: Button?
    @GodotNode("VBox/ButtonRow2/BlendBtn") var blendBtn: Button?
    @GodotNode("VBox/ButtonRow2/RandomBtn") var randomBtn: Button?
    @GodotNode("VBox/StatusLabel") var statusLabel: Label?
    @GodotNode("Canvas") var canvas: Control?
    @GodotNode("BackButton") var backButton: Button?
    @GodotNode("PauseMenu") var pauseMenu: PauseMenu?

    // MARK: - State

    @GodotState var statusText: String = "Explore color science and accessibility!"
    @GodotState var currentMode: ColorMode = .harmony

    private var swatches: [ColorRect] = []
    private var labels: [Label] = []
    private let canvasSize: Int = 400

    enum ColorMode {
        case harmony, accessibility, blindness, gradient, blend, random
    }

    // MARK: - Lifecycle

    override func _ready() {
        configureNodes()
        setupButtons()
        showHarmonies()

        GodotContext.log("""

        ╔═══════════════════════════════════════════╗
        ║             Color Lab Demo                ║
        ╠═══════════════════════════════════════════╣
        ║  Package: swift-color                     ║
        ║  • Color harmonies                        ║
        ║  • WCAG accessibility                     ║
        ║  • Color blindness simulation             ║
        ║  • Perceptual gradients                   ║
        ║  • Blend modes                            ║
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
        $harmonyBtn.configure(owner: self)
        $accessBtn.configure(owner: self)
        $blindBtn.configure(owner: self)
        $gradientBtn.configure(owner: self)
        $blendBtn.configure(owner: self)
        $randomBtn.configure(owner: self)
        $statusLabel.configure(owner: self)
        $canvas.configure(owner: self)
        $backButton.configure(owner: self)
        $pauseMenu.configure(owner: self)
    }

    private func setupButtons() {
        harmonyBtn?.on("pressed") { [weak self] in
            self?.currentMode = .harmony
            self?.showHarmonies()
        }

        accessBtn?.on("pressed") { [weak self] in
            self?.currentMode = .accessibility
            self?.showAccessibility()
        }

        blindBtn?.on("pressed") { [weak self] in
            self?.currentMode = .blindness
            self?.showColorBlindness()
        }

        gradientBtn?.on("pressed") { [weak self] in
            self?.currentMode = .gradient
            self?.showGradients()
        }

        blendBtn?.on("pressed") { [weak self] in
            self?.currentMode = .blend
            self?.showBlendModes()
        }

        randomBtn?.on("pressed") { [weak self] in
            self?.regenerate()
        }

        backButton?.on("pressed") { [weak self] in
            _ = self?.getTree()?.changeSceneToFile(path: "res://demo_menu.tscn")
        }
    }

    // MARK: - Clear Canvas

    private func clearCanvas() {
        for swatch in swatches {
            swatch.queueFree()
        }
        for label in labels {
            label.queueFree()
        }
        swatches.removeAll()
        labels.removeAll()
    }

    // MARK: - Helpers

    private func toGodot(_ c: SwiftColor) -> SwiftGodot.Color {
        SwiftGodot.Color(r: Float(c.red), g: Float(c.green), b: Float(c.blue), a: Float(c.alpha))
    }

    private func addSwatch(at position: Vector2, size: Vector2, color: SwiftGodot.Color, labelText: String? = nil) {
        let rect = ColorRect()
        rect.color = color
        rect.setPosition(position)
        rect.customMinimumSize = size
        rect.setSize(size)
        canvas?.addChild(node: rect)
        swatches.append(rect)

        if let text = labelText {
            let label = Label()
            label.text = text
            label.setPosition(Vector2(x: position.x, y: position.y + size.y + 5))
            label.horizontalAlignment = .center
            label.addThemeFontSizeOverride(name: "font_size", fontSize: 12)
            canvas?.addChild(node: label)
            labels.append(label)
        }
    }

    private func regenerate() {
        switch currentMode {
        case .harmony: showHarmonies()
        case .accessibility: showAccessibility()
        case .blindness: showColorBlindness()
        case .gradient: showGradients()
        case .blend: showBlendModes()
        case .random: showRandomPalette()
        }
    }

    // MARK: - Color Harmonies

    private func showHarmonies() {
        clearCanvas()
        statusText = "Color Harmonies (swift-color)"

        let baseColor = SwiftColor.random()
        let swatchSize = Vector2(x: 70, y: 70)
        var yOffset: Float = 0

        // Show base color
        addSwatch(at: Vector2(x: 10, y: yOffset), size: swatchSize, color: toGodot(baseColor), labelText: "Base")

        // Complementary
        yOffset += 100
        let label1 = Label()
        label1.text = "Complementary:"
        label1.setPosition(Vector2(x: 10, y: yOffset))
        canvas?.addChild(node: label1)
        labels.append(label1)

        yOffset += 25
        for (i, color) in baseColor.complementary.enumerated() {
            addSwatch(at: Vector2(x: 10 + Float(i * 80), y: yOffset), size: swatchSize, color: toGodot(color))
        }

        // Triadic
        yOffset += 100
        let label2 = Label()
        label2.text = "Triadic:"
        label2.setPosition(Vector2(x: 10, y: yOffset))
        canvas?.addChild(node: label2)
        labels.append(label2)

        yOffset += 25
        for (i, color) in baseColor.triadic.enumerated() {
            addSwatch(at: Vector2(x: 10 + Float(i * 80), y: yOffset), size: swatchSize, color: toGodot(color))
        }

        // Tetradic
        yOffset += 100
        let label3 = Label()
        label3.text = "Tetradic:"
        label3.setPosition(Vector2(x: 10, y: yOffset))
        canvas?.addChild(node: label3)
        labels.append(label3)

        yOffset += 25
        for (i, color) in baseColor.tetradic.enumerated() {
            addSwatch(at: Vector2(x: 10 + Float(i * 80), y: yOffset), size: swatchSize, color: toGodot(color))
        }

        // Analogous
        yOffset += 100
        let label4 = Label()
        label4.text = "Analogous:"
        label4.setPosition(Vector2(x: 10, y: yOffset))
        canvas?.addChild(node: label4)
        labels.append(label4)

        yOffset += 25
        for (i, color) in baseColor.analogous(count: 5).enumerated() {
            addSwatch(at: Vector2(x: 10 + Float(i * 80), y: yOffset), size: swatchSize, color: toGodot(color))
        }

        GodotContext.log("Showing color harmonies from random base color")
    }

    // MARK: - Accessibility

    private func showAccessibility() {
        clearCanvas()
        statusText = "WCAG Accessibility (swift-color)"

        let swatchSize = Vector2(x: 150, y: 60)
        var yOffset: Float = 0

        // Test color combinations for accessibility
        let combinations: [(SwiftColor, SwiftColor, String)] = [
            (.black, .white, "Black/White"),
            (.red, .white, "Red/White"),
            (.blue, .white, "Blue/White"),
            (SwiftColor(r: 0.5, g: 0.5, b: 0.5), .white, "Gray/White"),
            (.yellow, .black, "Yellow/Black"),
            (.green, .white, "Green/White")
        ]

        let label1 = Label()
        label1.text = "WCAG Contrast Ratio (4.5:1 for AA, 7:1 for AAA)"
        label1.setPosition(Vector2(x: 10, y: yOffset))
        canvas?.addChild(node: label1)
        labels.append(label1)

        yOffset += 35

        for (fg, bg, name) in combinations {
            let ratio = fg.contrastRatio(with: bg)
            let passesAA = fg.isAccessible(on: bg, level: .aa)
            let passesAAA = fg.isAccessible(on: bg, level: .aaa)

            // Background swatch
            addSwatch(at: Vector2(x: 10, y: yOffset), size: swatchSize, color: toGodot(bg))

            // Foreground swatch (smaller, overlaid)
            addSwatch(at: Vector2(x: 30, y: yOffset + 15), size: Vector2(x: 30, y: 30), color: toGodot(fg))

            // Result label
            let resultLabel = Label()
            let aaStatus = passesAA ? "AA" : "FAIL"
            let aaaStatus = passesAAA ? "AAA" : "-"
            resultLabel.text = "\(name): \(String(format: "%.1f", ratio)):1 [\(aaStatus)] [\(aaaStatus)]"
            resultLabel.setPosition(Vector2(x: 170, y: yOffset + 20))
            canvas?.addChild(node: resultLabel)
            labels.append(resultLabel)

            yOffset += 70
        }

        GodotContext.log("Showing WCAG accessibility checks")
    }

    // MARK: - Color Blindness

    private func showColorBlindness() {
        clearCanvas()
        statusText = "Color Blindness Simulation (swift-color)"

        let testColors: [SwiftColor] = [.red, .green, .blue, .yellow, .cyan, .magenta]
        let swatchSize = Vector2(x: 60, y: 60)

        // Header labels
        let headers = ["Normal", "Protanopia", "Deuteranopia", "Tritanopia"]
        for (i, header) in headers.enumerated() {
            let label = Label()
            label.text = header
            label.setPosition(Vector2(x: 10 + Float(i * 95), y: 0))
            label.addThemeFontSizeOverride(name: "font_size", fontSize: 11)
            canvas?.addChild(node: label)
            labels.append(label)
        }

        for (row, color) in testColors.enumerated() {
            let yPos = Float(30 + row * 70)

            // Normal
            addSwatch(at: Vector2(x: 10, y: yPos), size: swatchSize, color: toGodot(color))

            // Protanopia (red-blind)
            addSwatch(at: Vector2(x: 105, y: yPos), size: swatchSize, color: toGodot(color.simulatedProtanopia))

            // Deuteranopia (green-blind)
            addSwatch(at: Vector2(x: 200, y: yPos), size: swatchSize, color: toGodot(color.simulatedDeuteranopia))

            // Tritanopia (blue-blind)
            addSwatch(at: Vector2(x: 295, y: yPos), size: swatchSize, color: toGodot(color.simulatedTritanopia))
        }

        GodotContext.log("Showing color blindness simulation")
    }

    // MARK: - Gradients

    private func showGradients() {
        clearCanvas()
        statusText = "Perceptual Gradients (swift-color)"

        let gradientHeight: Float = 40
        let gradientWidth: Float = 380
        var yOffset: Float = 0

        // RGB vs LAB gradient comparison
        let start = SwiftColor.red
        let end = SwiftColor.blue

        // Label
        let label1 = Label()
        label1.text = "RGB vs LAB (Perceptual) Gradient:"
        label1.setPosition(Vector2(x: 10, y: yOffset))
        canvas?.addChild(node: label1)
        labels.append(label1)
        yOffset += 25

        // RGB gradient
        let rgbGradient = start.gradient(to: end, steps: 20, perceptual: false)
        let stepWidth = gradientWidth / Float(rgbGradient.count)
        for (i, color) in rgbGradient.enumerated() {
            let rect = ColorRect()
            rect.color = toGodot(color)
            rect.setPosition(Vector2(x: 10 + Float(i) * stepWidth, y: yOffset))
            rect.customMinimumSize = Vector2(x: stepWidth, y: gradientHeight)
            rect.setSize(Vector2(x: stepWidth, y: gradientHeight))
            canvas?.addChild(node: rect)
            swatches.append(rect)
        }
        let rgbLabel = Label()
        rgbLabel.text = "RGB"
        rgbLabel.setPosition(Vector2(x: gradientWidth + 20, y: yOffset + 10))
        canvas?.addChild(node: rgbLabel)
        labels.append(rgbLabel)
        yOffset += gradientHeight + 10

        // LAB gradient (perceptual)
        let labGradient = start.gradient(to: end, steps: 20, perceptual: true)
        for (i, color) in labGradient.enumerated() {
            let rect = ColorRect()
            rect.color = toGodot(color)
            rect.setPosition(Vector2(x: 10 + Float(i) * stepWidth, y: yOffset))
            rect.customMinimumSize = Vector2(x: stepWidth, y: gradientHeight)
            rect.setSize(Vector2(x: stepWidth, y: gradientHeight))
            canvas?.addChild(node: rect)
            swatches.append(rect)
        }
        let labLabel = Label()
        labLabel.text = "LAB"
        labLabel.setPosition(Vector2(x: gradientWidth + 20, y: yOffset + 10))
        canvas?.addChild(node: labLabel)
        labels.append(labLabel)
        yOffset += gradientHeight + 30

        // Tonal scale
        let label2 = Label()
        label2.text = "Tonal Scale (Blue):"
        label2.setPosition(Vector2(x: 10, y: yOffset))
        canvas?.addChild(node: label2)
        labels.append(label2)
        yOffset += 25

        let tonalScale = SwiftColor.blue.tonalScale(count: 11)
        let toneWidth = gradientWidth / Float(tonalScale.count)
        for (i, color) in tonalScale.enumerated() {
            let rect = ColorRect()
            rect.color = toGodot(color)
            rect.setPosition(Vector2(x: 10 + Float(i) * toneWidth, y: yOffset))
            rect.customMinimumSize = Vector2(x: toneWidth, y: gradientHeight)
            rect.setSize(Vector2(x: toneWidth, y: gradientHeight))
            canvas?.addChild(node: rect)
            swatches.append(rect)
        }
        yOffset += gradientHeight + 30

        // Rainbow gradient
        let label3 = Label()
        label3.text = "Multi-stop Rainbow:"
        label3.setPosition(Vector2(x: 10, y: yOffset))
        canvas?.addChild(node: label3)
        labels.append(label3)
        yOffset += 25

        let rainbow = SwiftColor.red.multiGradient(
            through: [.yellow, .green, .cyan, .blue, .magenta],
            stepsPerSegment: 8
        )
        let rainbowWidth = gradientWidth / Float(rainbow.count)
        for (i, color) in rainbow.enumerated() {
            let rect = ColorRect()
            rect.color = toGodot(color)
            rect.setPosition(Vector2(x: 10 + Float(i) * rainbowWidth, y: yOffset))
            rect.customMinimumSize = Vector2(x: rainbowWidth, y: gradientHeight)
            rect.setSize(Vector2(x: rainbowWidth, y: gradientHeight))
            canvas?.addChild(node: rect)
            swatches.append(rect)
        }

        GodotContext.log("Showing gradient comparisons")
    }

    // MARK: - Blend Modes

    private func showBlendModes() {
        clearCanvas()
        statusText = "Blend Modes (swift-color)"

        let color1 = SwiftColor.red
        let color2 = SwiftColor.blue
        let swatchSize = Vector2(x: 80, y: 80)
        var yOffset: Float = 0

        // Source colors
        let label1 = Label()
        label1.text = "Source Colors:"
        label1.setPosition(Vector2(x: 10, y: yOffset))
        canvas?.addChild(node: label1)
        labels.append(label1)
        yOffset += 25

        addSwatch(at: Vector2(x: 10, y: yOffset), size: swatchSize, color: toGodot(color1), labelText: "Red")
        addSwatch(at: Vector2(x: 100, y: yOffset), size: swatchSize, color: toGodot(color2), labelText: "Blue")
        yOffset += 120

        // Blend results
        let label2 = Label()
        label2.text = "Blend Results:"
        label2.setPosition(Vector2(x: 10, y: yOffset))
        canvas?.addChild(node: label2)
        labels.append(label2)
        yOffset += 25

        // Mix
        addSwatch(at: Vector2(x: 10, y: yOffset), size: swatchSize, color: toGodot(color1.mix(with: color2)), labelText: "Mix 50%")

        // Multiply
        addSwatch(at: Vector2(x: 100, y: yOffset), size: swatchSize, color: toGodot(color1.multiply(with: color2)), labelText: "Multiply")

        // Screen
        addSwatch(at: Vector2(x: 190, y: yOffset), size: swatchSize, color: toGodot(color1.screen(with: color2)), labelText: "Screen")

        // Overlay
        addSwatch(at: Vector2(x: 280, y: yOffset), size: swatchSize, color: toGodot(color1.overlay(with: color2)), labelText: "Overlay")
        yOffset += 120

        // Manipulation
        let label3 = Label()
        label3.text = "Manipulation:"
        label3.setPosition(Vector2(x: 10, y: yOffset))
        canvas?.addChild(node: label3)
        labels.append(label3)
        yOffset += 25

        addSwatch(at: Vector2(x: 10, y: yOffset), size: swatchSize, color: toGodot(color1.lighten(by: 0.3)), labelText: "Lighten")
        addSwatch(at: Vector2(x: 100, y: yOffset), size: swatchSize, color: toGodot(color1.darken(by: 0.3)), labelText: "Darken")
        addSwatch(at: Vector2(x: 190, y: yOffset), size: swatchSize, color: toGodot(color1.desaturate(by: 0.5)), labelText: "Desat")
        addSwatch(at: Vector2(x: 280, y: yOffset), size: swatchSize, color: toGodot(color1.complement), labelText: "Complement")

        GodotContext.log("Showing blend modes and manipulation")
    }

    // MARK: - Random Palette

    private func showRandomPalette() {
        clearCanvas()
        statusText = "Distinct Random Palette (swift-color)"

        let palette = SwiftColor.distinctPalette(count: 12)
        let swatchSize = Vector2(x: 90, y: 90)

        let label = Label()
        label.text = "Golden Ratio Distinct Palette:"
        label.setPosition(Vector2(x: 10, y: 0))
        canvas?.addChild(node: label)
        labels.append(label)

        for (i, color) in palette.enumerated() {
            let row = i / 4
            let col = i % 4
            addSwatch(
                at: Vector2(x: 10 + Float(col * 100), y: 30 + Float(row * 110)),
                size: swatchSize,
                color: toGodot(color)
            )
        }

        GodotContext.log("Generated distinct random palette")
    }
}
