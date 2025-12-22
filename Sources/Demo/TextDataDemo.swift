import SwiftGodotKit
import Foundation
import Parse
import Stats

// MARK: - Text & Data Demo

/// Demonstrates swift-parse and swift-stats with SwiftGodotKit
@Godot
class TextDataShowcase: Control {

    // MARK: - Node References

    @GodotNode("VBox/ButtonRow/NamesBtn") var namesBtn: Button?
    @GodotNode("VBox/ButtonRow/TextBtn") var textBtn: Button?
    @GodotNode("VBox/ButtonRow/StatsBtn") var statsBtn: Button?
    @GodotNode("VBox/ButtonRow2/MarkovBtn") var markovBtn: Button?
    @GodotNode("VBox/ButtonRow2/HistBtn") var histBtn: Button?
    @GodotNode("VBox/ButtonRow2/RegenBtn") var regenBtn: Button?
    @GodotNode("VBox/StatusLabel") var statusLabel: Label?
    @GodotNode("Canvas") var canvas: Control?
    @GodotNode("BackButton") var backButton: Button?
    @GodotNode("PauseMenu") var pauseMenu: PauseMenu?

    // MARK: - State

    @GodotState var statusText: String = "Explore text processing and statistics!"
    @GodotState var currentMode: DataMode = .names

    private var textLabels: [Label] = []
    private var bars: [ColorRect] = []
    private var seed: UInt64 = 42

    enum DataMode {
        case names, text, stats, markov, histogram
    }

    // MARK: - Lifecycle

    override func _ready() {
        configureNodes()
        setupButtons()
        showNames()

        GodotContext.log("""

        ╔═══════════════════════════════════════════╗
        ║          Text & Data Demo                 ║
        ╠═══════════════════════════════════════════╣
        ║  Packages: swift-parse, swift-stats       ║
        ║  • Random name generation                 ║
        ║  • Text statistics                        ║
        ║  • Statistical analysis                   ║
        ║  • Markov chain text                      ║
        ║  • Histograms                             ║
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
        $namesBtn.configure(owner: self)
        $textBtn.configure(owner: self)
        $statsBtn.configure(owner: self)
        $markovBtn.configure(owner: self)
        $histBtn.configure(owner: self)
        $regenBtn.configure(owner: self)
        $statusLabel.configure(owner: self)
        $canvas.configure(owner: self)
        $backButton.configure(owner: self)
        $pauseMenu.configure(owner: self)
    }

    private func setupButtons() {
        namesBtn?.on("pressed") { [weak self] in
            self?.currentMode = .names
            self?.showNames()
        }

        textBtn?.on("pressed") { [weak self] in
            self?.currentMode = .text
            self?.showTextStats()
        }

        statsBtn?.on("pressed") { [weak self] in
            self?.currentMode = .stats
            self?.showStatistics()
        }

        markovBtn?.on("pressed") { [weak self] in
            self?.currentMode = .markov
            self?.showMarkov()
        }

        histBtn?.on("pressed") { [weak self] in
            self?.currentMode = .histogram
            self?.showHistogram()
        }

        regenBtn?.on("pressed") { [weak self] in
            self?.regenerate()
        }

        backButton?.on("pressed") { [weak self] in
            _ = self?.getTree()?.changeSceneToFile(path: "res://demo_menu.tscn")
        }
    }

    private func regenerate() {
        seed = UInt64.random(in: 0...UInt64.max)
        switch currentMode {
        case .names: showNames()
        case .text: showTextStats()
        case .stats: showStatistics()
        case .markov: showMarkov()
        case .histogram: showHistogram()
        }
    }

    // MARK: - Clear Canvas

    private func clearCanvas() {
        for label in textLabels {
            label.queueFree()
        }
        textLabels.removeAll()

        for bar in bars {
            bar.queueFree()
        }
        bars.removeAll()
    }

    private func addLabel(text: String, at position: Vector2, fontSize: Int = 14, color: Color? = nil) {
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

    // MARK: - Name Generation

    private func showNames() {
        clearCanvas()
        statusText = "Random Name Generator (swift-parse)"

        var yOffset: Float = 0

        addLabel(text: "Generated Names:", at: Vector2(x: 0, y: yOffset), fontSize: 16)
        yOffset += 30

        var generator = NameGenerator(seed: seed)

        // Generate various name types
        addLabel(text: "Full Names:", at: Vector2(x: 0, y: yOffset))
        yOffset += 22

        for _ in 0..<5 {
            let name = generator.fullName()
            addLabel(text: "  • \(name)", at: Vector2(x: 0, y: yOffset))
            yOffset += 20
        }

        yOffset += 15
        addLabel(text: "Usernames:", at: Vector2(x: 0, y: yOffset))
        yOffset += 22

        for _ in 0..<3 {
            let username = generator.username(separator: "_")
            addLabel(text: "  • \(username)", at: Vector2(x: 0, y: yOffset))
            yOffset += 20
        }

        yOffset += 15
        addLabel(text: "Email Addresses:", at: Vector2(x: 0, y: yOffset))
        yOffset += 22

        for _ in 0..<3 {
            let email = generator.email(domain: "corvidlabs.com")
            addLabel(text: "  • \(email)", at: Vector2(x: 0, y: yOffset))
            yOffset += 20
        }

        yOffset += 15
        addLabel(text: "Initials:", at: Vector2(x: 0, y: yOffset))
        yOffset += 22

        var initials: [String] = []
        for _ in 0..<6 {
            initials.append(generator.initials())
        }
        addLabel(text: "  \(initials.joined(separator: ", "))", at: Vector2(x: 0, y: yOffset))

        GodotContext.log("Generated random names")
    }

    // MARK: - Text Statistics

    private func showTextStats() {
        clearCanvas()
        statusText = "Text Statistics (swift-parse)"

        let sampleText = """
        Swift is a powerful and intuitive programming language for iOS, macOS, watchOS, and tvOS. \
        Writing Swift code is interactive and fun, the syntax is concise yet expressive, \
        and Swift includes modern features developers love. Swift code is safe by design, \
        yet also produces software that runs lightning-fast.
        """

        var yOffset: Float = 0

        addLabel(text: "Sample Text Analysis:", at: Vector2(x: 0, y: yOffset), fontSize: 16)
        yOffset += 25

        // Show sample text (truncated)
        let displayText = String(sampleText.prefix(100)) + "..."
        addLabel(text: "\"\(displayText)\"", at: Vector2(x: 0, y: yOffset), fontSize: 11,
                 color: Color(r: 0.7, g: 0.7, b: 0.8, a: 1.0))
        yOffset += 40

        let stats = sampleText.statistics

        addLabel(text: "Statistics:", at: Vector2(x: 0, y: yOffset))
        yOffset += 22

        let statItems = [
            ("Characters (total)", "\(stats.characterCount)"),
            ("Characters (no space)", "\(stats.characterCountWithoutWhitespace)"),
            ("Words", "\(stats.wordCount)"),
            ("Sentences", "\(stats.sentenceCount)"),
            ("Syllables (approx)", "\(stats.syllableCount)"),
            ("Avg Word Length", String(format: "%.1f", stats.averageWordLength)),
            ("Avg Sentence Length", String(format: "%.1f words", stats.averageSentenceLength)),
            ("Longest Word", stats.longestWord ?? "N/A"),
            ("Shortest Word", stats.shortestWord ?? "N/A")
        ]

        for (label, value) in statItems {
            addLabel(text: "  \(label):", at: Vector2(x: 0, y: yOffset))
            addLabel(text: value, at: Vector2(x: 180, y: yOffset),
                     color: Color(r: 0.5, g: 0.9, b: 0.6, a: 1.0))
            yOffset += 20
        }

        GodotContext.log("Analyzed text statistics")
    }

    // MARK: - Statistical Analysis

    private func showStatistics() {
        clearCanvas()
        statusText = "Statistical Analysis (swift-stats)"

        var yOffset: Float = 0

        addLabel(text: "Dataset Analysis:", at: Vector2(x: 0, y: yOffset), fontSize: 16)
        yOffset += 25

        // Generate sample data
        var rng = Parse.RandomSource(seed: seed)
        var data: [Double] = []
        for _ in 0..<50 {
            // Generate roughly normally distributed data
            let u1 = rng.nextDouble()
            let u2 = rng.nextDouble()
            let z = sqrt(-2 * log(u1)) * cos(2 * .pi * u2)
            data.append(50 + z * 15)  // mean=50, std=15
        }

        // Show first few values
        let preview = data.prefix(8).map { String(format: "%.1f", $0) }.joined(separator: ", ")
        addLabel(text: "Data: [\(preview), ...]", at: Vector2(x: 0, y: yOffset), fontSize: 11,
                 color: Color(r: 0.7, g: 0.7, b: 0.8, a: 1.0))
        yOffset += 25

        // Calculate statistics
        do {
            let stats = try Statistics.calculate(from: data)

            addLabel(text: "Descriptive Statistics:", at: Vector2(x: 0, y: yOffset))
            yOffset += 22

            let statItems = [
                ("Count", "\(stats.count)"),
                ("Sum", String(format: "%.1f", stats.sum)),
                ("Mean", String(format: "%.2f", stats.mean)),
                ("Median", String(format: "%.2f", stats.median)),
                ("Minimum", String(format: "%.2f", stats.minimum)),
                ("Maximum", String(format: "%.2f", stats.maximum)),
                ("Range", String(format: "%.2f", stats.range)),
                ("Variance", String(format: "%.2f", stats.variance)),
                ("Std Deviation", String(format: "%.2f", stats.standardDeviation))
            ]

            for (label, value) in statItems {
                addLabel(text: "  \(label):", at: Vector2(x: 0, y: yOffset))
                addLabel(text: value, at: Vector2(x: 140, y: yOffset),
                         color: Color(r: 0.5, g: 0.9, b: 0.6, a: 1.0))
                yOffset += 20
            }

            if !stats.mode.isEmpty {
                let modeStr = stats.mode.map { String(format: "%.1f", $0) }.joined(separator: ", ")
                addLabel(text: "  Mode:", at: Vector2(x: 0, y: yOffset))
                addLabel(text: modeStr, at: Vector2(x: 140, y: yOffset),
                         color: Color(r: 0.5, g: 0.9, b: 0.6, a: 1.0))
            }

        } catch {
            addLabel(text: "Error calculating statistics", at: Vector2(x: 0, y: yOffset))
        }

        GodotContext.log("Calculated statistics from dataset")
    }

    // MARK: - Markov Chain

    private func showMarkov() {
        clearCanvas()
        statusText = "Markov Chain Text (swift-parse)"

        var yOffset: Float = 0

        addLabel(text: "Markov Chain Text Generator:", at: Vector2(x: 0, y: yOffset), fontSize: 16)
        yOffset += 25

        // Training corpus
        let trainingText = """
        The quick brown fox jumps over the lazy dog. The dog was sleeping peacefully in the sun.
        The fox was looking for food in the forest. The forest was full of tall trees and beautiful flowers.
        The sun was shining brightly in the clear blue sky. The sky was filled with fluffy white clouds.
        Birds were singing in the trees. The trees provided shade and shelter for many creatures.
        A gentle breeze rustled the leaves. The leaves were turning golden in the autumn sun.
        """

        addLabel(text: "Training on sample corpus...", at: Vector2(x: 0, y: yOffset), fontSize: 11,
                 color: Color(r: 0.7, g: 0.7, b: 0.8, a: 1.0))
        yOffset += 25

        let markov = MarkovChain(text: trainingText, order: 2)

        addLabel(text: "Generated Sentences:", at: Vector2(x: 0, y: yOffset))
        yOffset += 22

        // Generate multiple sentences with different seeds
        var rng = Parse.RandomSource(seed: seed)
        for i in 0..<5 {
            let nextSeed = rng.nextUInt64()
            let sentence = markov.generateSentence(maxWords: 12, seed: nextSeed)
            if !sentence.isEmpty {
                // Wrap long text
                let wrapped = wrapText(sentence, maxWidth: 50)
                for line in wrapped {
                    addLabel(text: "  \(i + 1). \(line)", at: Vector2(x: 0, y: yOffset), fontSize: 12)
                    yOffset += 18
                }
                yOffset += 5
            }
        }

        yOffset += 15
        addLabel(text: "Note: Markov chains learn word patterns from", at: Vector2(x: 0, y: yOffset), fontSize: 11,
                 color: Color(r: 0.6, g: 0.6, b: 0.7, a: 1.0))
        yOffset += 16
        addLabel(text: "training text to generate new sequences.", at: Vector2(x: 0, y: yOffset), fontSize: 11,
                 color: Color(r: 0.6, g: 0.6, b: 0.7, a: 1.0))

        GodotContext.log("Generated Markov chain text")
    }

    private func wrapText(_ text: String, maxWidth: Int) -> [String] {
        var lines: [String] = []
        var currentLine = ""

        for word in text.split(separator: " ") {
            if currentLine.count + word.count + 1 > maxWidth {
                if !currentLine.isEmpty {
                    lines.append(currentLine)
                }
                currentLine = String(word)
            } else {
                if currentLine.isEmpty {
                    currentLine = String(word)
                } else {
                    currentLine += " " + word
                }
            }
        }

        if !currentLine.isEmpty {
            lines.append(currentLine)
        }

        return lines
    }

    // MARK: - Histogram

    private func showHistogram() {
        clearCanvas()
        statusText = "Histogram Visualization (swift-stats)"

        var yOffset: Float = 0

        addLabel(text: "Data Distribution Histogram:", at: Vector2(x: 0, y: yOffset), fontSize: 16)
        yOffset += 30

        // Generate data
        var rng = Parse.RandomSource(seed: seed)
        var data: [Double] = []
        for _ in 0..<200 {
            // Mix of distributions
            if rng.nextDouble() < 0.7 {
                let u1 = rng.nextDouble()
                let u2 = rng.nextDouble()
                let z = sqrt(-2 * log(u1)) * cos(2 * .pi * u2)
                data.append(50 + z * 10)
            } else {
                data.append(rng.nextDouble() * 100)
            }
        }

        do {
            let histogram = try data.histogram(binCount: 10)

            let maxFreq = histogram.bins.map { $0.frequency }.max() ?? 1
            let barMaxWidth: Float = 250
            let barHeight: Float = 22

            for (i, bin) in histogram.bins.enumerated() {
                let barWidth = Float(bin.frequency) / Float(maxFreq) * barMaxWidth

                // Bin label
                let rangeLabel = String(format: "%.0f-%.0f", bin.lowerBound, bin.upperBound)
                addLabel(text: rangeLabel, at: Vector2(x: 0, y: yOffset + 3), fontSize: 11)

                // Bar
                let bar = ColorRect()
                let hue = Float(i) / Float(histogram.bins.count)
                bar.color = Color(r: 0.3 + hue * 0.5, g: 0.6, b: 0.9 - hue * 0.3, a: 0.9)
                bar.setPosition(Vector2(x: 60, y: yOffset))
                bar.customMinimumSize = Vector2(x: barWidth, y: barHeight - 4)
                bar.setSize(Vector2(x: barWidth, y: barHeight - 4))
                canvas?.addChild(node: bar)
                bars.append(bar)

                // Frequency label
                let freqLabel = "\(bin.frequency) (\(String(format: "%.0f%%", bin.relativeFrequency * 100)))"
                addLabel(text: freqLabel, at: Vector2(x: 65 + barWidth, y: yOffset + 3), fontSize: 11)

                yOffset += barHeight
            }

            yOffset += 20
            addLabel(text: "Total samples: \(histogram.totalCount)", at: Vector2(x: 0, y: yOffset))

        } catch {
            addLabel(text: "Error creating histogram", at: Vector2(x: 0, y: yOffset))
        }

        GodotContext.log("Generated histogram visualization")
    }
}
