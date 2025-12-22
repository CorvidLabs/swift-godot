import SwiftGodotKit
import SwiftQR

// MARK: - QR Code Demo

/// Demonstrates swift-qr QR code generation with SwiftGodotKit
@Godot
class QRCodeShowcase: Control {

    // MARK: - Node References

    @GodotNode("VBox/InputRow/TextInput") var textInput: LineEdit?
    @GodotNode("VBox/ButtonRow/LowBtn") var lowBtn: Button?
    @GodotNode("VBox/ButtonRow/MedBtn") var medBtn: Button?
    @GodotNode("VBox/ButtonRow/QuartBtn") var quartBtn: Button?
    @GodotNode("VBox/ButtonRow/HighBtn") var highBtn: Button?
    @GodotNode("VBox/StatusLabel") var statusLabel: Label?
    @GodotNode("Canvas") var canvas: Control?
    @GodotNode("BackButton") var backButton: Button?
    @GodotNode("PauseMenu") var pauseMenu: PauseMenu?

    // MARK: - State

    @GodotState var statusText: String = "Enter text and select error correction level"
    @GodotState var currentLevel: QRErrorCorrectionLevel = .medium

    private var qrModules: [ColorRect] = []
    private var textLabels: [Label] = []
    private var currentText: String = "https://corvidlabs.com"

    // MARK: - Lifecycle

    override func _ready() {
        configureNodes()
        setupButtons()

        textInput?.text = currentText
        generateQRCode()

        GodotContext.log("""

        ╔═══════════════════════════════════════════╗
        ║            QR Code Demo                   ║
        ╠═══════════════════════════════════════════╣
        ║  Package: swift-qr                        ║
        ║  • Real-time QR generation                ║
        ║  • Multiple error correction levels       ║
        ║  • Enter any text or URL                  ║
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
        $textInput.configure(owner: self)
        $lowBtn.configure(owner: self)
        $medBtn.configure(owner: self)
        $quartBtn.configure(owner: self)
        $highBtn.configure(owner: self)
        $statusLabel.configure(owner: self)
        $canvas.configure(owner: self)
        $backButton.configure(owner: self)
        $pauseMenu.configure(owner: self)
    }

    private func setupButtons() {
        textInput?.on("text_changed") { [weak self] in
            self?.currentText = self?.textInput?.text ?? ""
            self?.generateQRCode()
        }

        textInput?.on("text_submitted") { [weak self] in
            self?.currentText = self?.textInput?.text ?? ""
            self?.generateQRCode()
        }

        lowBtn?.on("pressed") { [weak self] in
            self?.currentLevel = .low
            self?.generateQRCode()
        }

        medBtn?.on("pressed") { [weak self] in
            self?.currentLevel = .medium
            self?.generateQRCode()
        }

        quartBtn?.on("pressed") { [weak self] in
            self?.currentLevel = .quartile
            self?.generateQRCode()
        }

        highBtn?.on("pressed") { [weak self] in
            self?.currentLevel = .high
            self?.generateQRCode()
        }

        backButton?.on("pressed") { [weak self] in
            _ = self?.getTree()?.changeSceneToFile(path: "res://demo_menu.tscn")
        }
    }

    // MARK: - Clear Canvas

    private func clearCanvas() {
        for module in qrModules {
            module.queueFree()
        }
        qrModules.removeAll()

        for label in textLabels {
            label.queueFree()
        }
        textLabels.removeAll()
    }

    private func addLabel(text: String, at position: Vector2, fontSize: Int = 12, color: Color? = nil) {
        let label = Label()
        label.text = text
        label.setPosition(position)
        label.addThemeFontSizeOverride(name: "font_size", fontSize: Int32(fontSize))
        if let color = color {
            label.addThemeColorOverride(name: "font_color", color: color)
        }
        canvas?.addChild(node: label)
        textLabels.append(label)
    }

    // MARK: - QR Code Generation

    private func generateQRCode() {
        clearCanvas()

        guard !currentText.isEmpty else {
            statusText = "Enter text to generate QR code"
            return
        }

        do {
            let qrCode = try QRCode.encode(currentText, errorCorrection: currentLevel)

            let levelName: String
            let levelDescription: String
            switch currentLevel {
            case .low:
                levelName = "L (Low)"
                levelDescription = "~7% recovery"
            case .medium:
                levelName = "M (Medium)"
                levelDescription = "~15% recovery"
            case .quartile:
                levelName = "Q (Quartile)"
                levelDescription = "~25% recovery"
            case .high:
                levelName = "H (High)"
                levelDescription = "~30% recovery"
            }

            statusText = "QR v\(qrCode.version.number) • \(qrCode.size)x\(qrCode.size) • EC: \(levelName)"

            renderQRCode(qrCode)

            // Add info labels
            var yOffset = Float(qrCode.size) * 3 + 30

            addLabel(text: "Error Correction Levels:", at: Vector2(x: 0, y: yOffset), fontSize: 14)
            yOffset += 22

            let levels: [(QRErrorCorrectionLevel, String, String)] = [
                (.low, "L - Low", "~7% data recovery"),
                (.medium, "M - Medium", "~15% data recovery"),
                (.quartile, "Q - Quartile", "~25% data recovery"),
                (.high, "H - High", "~30% data recovery")
            ]

            for (level, name, desc) in levels {
                let isActive = level == currentLevel
                let color = isActive
                    ? Color(r: 0.5, g: 0.9, b: 0.6, a: 1.0)
                    : Color(r: 0.7, g: 0.7, b: 0.7, a: 1.0)

                addLabel(text: "\(isActive ? "▶ " : "  ")\(name): \(desc)",
                        at: Vector2(x: 0, y: yOffset), fontSize: 11, color: color)
                yOffset += 18
            }

            yOffset += 15
            addLabel(text: "Higher error correction = larger QR code",
                    at: Vector2(x: 0, y: yOffset), fontSize: 10,
                    color: Color(r: 0.6, g: 0.6, b: 0.7, a: 1.0))
            yOffset += 14
            addLabel(text: "but more resilient to damage/dirt",
                    at: Vector2(x: 0, y: yOffset), fontSize: 10,
                    color: Color(r: 0.6, g: 0.6, b: 0.7, a: 1.0))

            GodotContext.log("Generated QR code: v\(qrCode.version.number), \(qrCode.size)x\(qrCode.size), EC=\(currentLevel.rawValue)")

        } catch {
            statusText = "Error: Text too long for QR code"
            addLabel(text: "Could not generate QR code.",
                    at: Vector2(x: 0, y: 0), color: Color(r: 1.0, g: 0.4, b: 0.4, a: 1.0))
            addLabel(text: "Text may be too long.",
                    at: Vector2(x: 0, y: 20), color: Color(r: 0.7, g: 0.7, b: 0.7, a: 1.0))

            GodotContext.log("Failed to generate QR code: \(error)")
        }
    }

    private func renderQRCode(_ qrCode: QRCode) {
        let moduleSize: Float = 3
        let quietZone: Float = 4 * moduleSize
        let offsetX = quietZone
        let offsetY: Float = 0

        // Background (quiet zone)
        let totalSize = Float(qrCode.size) * moduleSize + quietZone * 2
        let background = ColorRect()
        background.color = Color(r: 1.0, g: 1.0, b: 1.0, a: 1.0)
        background.setPosition(Vector2(x: offsetX - quietZone, y: offsetY))
        background.customMinimumSize = Vector2(x: totalSize, y: totalSize)
        background.setSize(Vector2(x: totalSize, y: totalSize))
        canvas?.addChild(node: background)
        qrModules.append(background)

        // Render each module
        for moduleInfo in qrCode.modules() {
            if moduleInfo.isDark {
                let module = ColorRect()
                module.color = Color(r: 0.0, g: 0.0, b: 0.0, a: 1.0)
                module.setPosition(Vector2(
                    x: offsetX + Float(moduleInfo.x) * moduleSize,
                    y: offsetY + quietZone + Float(moduleInfo.y) * moduleSize
                ))
                module.customMinimumSize = Vector2(x: moduleSize, y: moduleSize)
                module.setSize(Vector2(x: moduleSize, y: moduleSize))
                canvas?.addChild(node: module)
                qrModules.append(module)
            }
        }
    }
}
