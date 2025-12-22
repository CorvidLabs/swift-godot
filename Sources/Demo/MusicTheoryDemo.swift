import SwiftGodotKit
import Music

// MARK: - Music Theory Demo

/// Demonstrates swift-music theory with SwiftGodotKit
@Godot
class MusicTheoryShowcase: Control {

    // MARK: - Node References

    @GodotNode("VBox/ButtonRow/ChordsBtn") var chordsBtn: Button?
    @GodotNode("VBox/ButtonRow/ScalesBtn") var scalesBtn: Button?
    @GodotNode("VBox/ButtonRow/FreqBtn") var freqBtn: Button?
    @GodotNode("VBox/ButtonRow2/PrevBtn") var prevBtn: Button?
    @GodotNode("VBox/ButtonRow2/NextBtn") var nextBtn: Button?
    @GodotNode("VBox/StatusLabel") var statusLabel: Label?
    @GodotNode("Canvas") var canvas: Control?
    @GodotNode("BackButton") var backButton: Button?
    @GodotNode("PauseMenu") var pauseMenu: PauseMenu?

    // MARK: - State

    @GodotState var statusText: String = "Explore music theory concepts!"
    @GodotState var currentMode: MusicMode = .chords

    private var pianoKeys: [ColorRect] = []
    private var textLabels: [Label] = []
    private var markers: [ColorRect] = []

    private var currentChordIndex = 0
    private var currentScaleIndex = 0

    enum MusicMode {
        case chords, scales, frequency
    }

    private let allChords: [(Chord, String)] = [
        (.cMajor, "C Major - The most common chord"),
        (.cMinor, "C Minor - Darker, emotional quality"),
        (Chord(root: .c, quality: .major7), "CMaj7 - Jazz staple"),
        (Chord(root: .c, quality: .dominant7), "C7 - Blues & jazz"),
        (Chord(root: .c, quality: .minor7), "Cm7 - Smooth minor"),
        (Chord(root: .c, quality: .diminished), "Cdim - Tense, unstable"),
        (Chord(root: .c, quality: .augmented), "Caug - Mysterious"),
        (Chord(root: .c, quality: .sus4), "Csus4 - Suspended tension"),
        (.gMajor, "G Major - Bright, open"),
        (.fMajor, "F Major - Warm, soft"),
        (.aMinor, "Am - Relative minor of C"),
        (.dMinor, "Dm - Melancholic")
    ]

    private let allScales: [(Scale, String)] = [
        (Scale(root: .c, pattern: .major), "C Major - 'Happy' scale"),
        (Scale(root: .c, pattern: .naturalMinor), "C Natural Minor - 'Sad' scale"),
        (Scale(root: .c, pattern: .harmonicMinor), "C Harmonic Minor - Eastern flavor"),
        (Scale(root: .c, pattern: .melodicMinor), "C Melodic Minor - Jazz"),
        (Scale(root: .c, pattern: .dorian), "C Dorian - Minor with raised 6th"),
        (Scale(root: .c, pattern: .phrygian), "C Phrygian - Spanish/Flamenco"),
        (Scale(root: .c, pattern: .lydian), "C Lydian - Dreamy, ethereal"),
        (Scale(root: .c, pattern: .mixolydian), "C Mixolydian - Blues/rock"),
        (Scale(root: .c, pattern: .majorPentatonic), "C Major Pentatonic - Folk"),
        (Scale(root: .c, pattern: .minorPentatonic), "C Minor Pentatonic - Rock/blues"),
        (Scale(root: .c, pattern: .blues), "C Blues - The blues scale"),
        (Scale(root: .c, pattern: .wholeTone), "C Whole Tone - Impressionist")
    ]

    // MARK: - Lifecycle

    override func _ready() {
        configureNodes()
        setupButtons()
        showChords()

        GodotContext.log("""

        ╔═══════════════════════════════════════════╗
        ║          Music Theory Demo                ║
        ╠═══════════════════════════════════════════╣
        ║  Package: swift-music                     ║
        ║  • Chord types & construction             ║
        ║  • Scale patterns & modes                 ║
        ║  • Frequency relationships                ║
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
        $chordsBtn.configure(owner: self)
        $scalesBtn.configure(owner: self)
        $freqBtn.configure(owner: self)
        $prevBtn.configure(owner: self)
        $nextBtn.configure(owner: self)
        $statusLabel.configure(owner: self)
        $canvas.configure(owner: self)
        $backButton.configure(owner: self)
        $pauseMenu.configure(owner: self)
    }

    private func setupButtons() {
        chordsBtn?.on("pressed") { [weak self] in
            self?.currentMode = .chords
            self?.showChords()
        }

        scalesBtn?.on("pressed") { [weak self] in
            self?.currentMode = .scales
            self?.showScales()
        }

        freqBtn?.on("pressed") { [weak self] in
            self?.currentMode = .frequency
            self?.showFrequencies()
        }

        prevBtn?.on("pressed") { [weak self] in
            self?.showPrevious()
        }

        nextBtn?.on("pressed") { [weak self] in
            self?.showNext()
        }

        backButton?.on("pressed") { [weak self] in
            _ = self?.getTree()?.changeSceneToFile(path: "res://demo_menu.tscn")
        }
    }

    private func showPrevious() {
        switch currentMode {
        case .chords:
            currentChordIndex = (currentChordIndex - 1 + allChords.count) % allChords.count
            showChords()
        case .scales:
            currentScaleIndex = (currentScaleIndex - 1 + allScales.count) % allScales.count
            showScales()
        case .frequency:
            break
        }
    }

    private func showNext() {
        switch currentMode {
        case .chords:
            currentChordIndex = (currentChordIndex + 1) % allChords.count
            showChords()
        case .scales:
            currentScaleIndex = (currentScaleIndex + 1) % allScales.count
            showScales()
        case .frequency:
            break
        }
    }

    // MARK: - Clear Canvas

    private func clearCanvas() {
        for key in pianoKeys {
            key.queueFree()
        }
        pianoKeys.removeAll()

        for label in textLabels {
            label.queueFree()
        }
        textLabels.removeAll()

        for marker in markers {
            marker.queueFree()
        }
        markers.removeAll()
    }

    // MARK: - Piano Keyboard

    private func drawPiano(highlightedNotes: Set<PitchClass>, octave: Int = 4, yOffset: Float = 0) {
        let whiteKeyWidth: Float = 35
        let whiteKeyHeight: Float = 120
        let blackKeyWidth: Float = 20
        let blackKeyHeight: Float = 70

        // White keys layout: C D E F G A B
        let whiteKeys: [PitchClass] = [.c, .d, .e, .f, .g, .a, .b]
        let blackKeyPositions: [(PitchClass, Int)] = [
            (.cSharp, 0), (.dSharp, 1), (.fSharp, 3), (.gSharp, 4), (.aSharp, 5)
        ]

        // Draw white keys
        for (i, pitch) in whiteKeys.enumerated() {
            let key = ColorRect()
            let isHighlighted = highlightedNotes.contains(pitch)

            if isHighlighted {
                key.color = Color(r: 0.3, g: 0.7, b: 0.9, a: 1.0)
            } else {
                key.color = Color(r: 0.95, g: 0.95, b: 0.9, a: 1.0)
            }

            key.setPosition(Vector2(x: Float(i) * whiteKeyWidth, y: yOffset))
            key.customMinimumSize = Vector2(x: whiteKeyWidth - 2, y: whiteKeyHeight)
            key.setSize(Vector2(x: whiteKeyWidth - 2, y: whiteKeyHeight))
            canvas?.addChild(node: key)
            pianoKeys.append(key)

            // Add note name
            let label = Label()
            label.text = pitch.displayName
            label.setPosition(Vector2(x: Float(i) * whiteKeyWidth + 8, y: yOffset + whiteKeyHeight - 25))
            label.addThemeFontSizeOverride(name: "font_size", fontSize: 14)
            label.addThemeColorOverride(name: "font_color", color: Color(r: 0.2, g: 0.2, b: 0.2, a: 1.0))
            canvas?.addChild(node: label)
            textLabels.append(label)
        }

        // Draw black keys
        for (pitch, whiteKeyIndex) in blackKeyPositions {
            let key = ColorRect()
            let isHighlighted = highlightedNotes.contains(pitch)

            if isHighlighted {
                key.color = Color(r: 0.2, g: 0.5, b: 0.7, a: 1.0)
            } else {
                key.color = Color(r: 0.15, g: 0.15, b: 0.15, a: 1.0)
            }

            let xPos = Float(whiteKeyIndex) * whiteKeyWidth + whiteKeyWidth - blackKeyWidth / 2
            key.setPosition(Vector2(x: xPos, y: yOffset))
            key.customMinimumSize = Vector2(x: blackKeyWidth, y: blackKeyHeight)
            key.setSize(Vector2(x: blackKeyWidth, y: blackKeyHeight))
            key.zIndex = 1
            canvas?.addChild(node: key)
            pianoKeys.append(key)
        }
    }

    // MARK: - Chords Display

    private func showChords() {
        clearCanvas()

        let (chord, description) = allChords[currentChordIndex]
        statusText = "Chords (\(currentChordIndex + 1)/\(allChords.count)): \(description)"

        // Title
        let titleLabel = Label()
        titleLabel.text = "Chord: \(chord.symbol)"
        titleLabel.setPosition(Vector2(x: 0, y: 0))
        titleLabel.addThemeFontSizeOverride(name: "font_size", fontSize: 20)
        canvas?.addChild(node: titleLabel)
        textLabels.append(titleLabel)

        // Draw piano with highlighted notes
        let highlightedNotes = Set(chord.pitchClasses)
        drawPiano(highlightedNotes: highlightedNotes, yOffset: 40)

        // Show chord info
        var yOffset: Float = 180

        let qualityLabel = Label()
        qualityLabel.text = "Quality: \(chord.quality.displayName)"
        qualityLabel.setPosition(Vector2(x: 0, y: yOffset))
        canvas?.addChild(node: qualityLabel)
        textLabels.append(qualityLabel)
        yOffset += 25

        let notesLabel = Label()
        let noteNames = chord.pitchClasses.map { $0.displayName }.joined(separator: " - ")
        notesLabel.text = "Notes: \(noteNames)"
        notesLabel.setPosition(Vector2(x: 0, y: yOffset))
        canvas?.addChild(node: notesLabel)
        textLabels.append(notesLabel)
        yOffset += 25

        let intervalsLabel = Label()
        let intervals = chord.quality.intervals.map { String($0) }.joined(separator: ", ")
        intervalsLabel.text = "Intervals (semitones): \(intervals)"
        intervalsLabel.setPosition(Vector2(x: 0, y: yOffset))
        canvas?.addChild(node: intervalsLabel)
        textLabels.append(intervalsLabel)
        yOffset += 25

        // Show frequencies for octave 4
        let notes = chord.notes(octave: 4)
        let freqLabel = Label()
        let freqs = notes.map { String(format: "%.1f", $0.frequency) }.joined(separator: ", ")
        freqLabel.text = "Frequencies (Hz): \(freqs)"
        freqLabel.setPosition(Vector2(x: 0, y: yOffset))
        canvas?.addChild(node: freqLabel)
        textLabels.append(freqLabel)

        GodotContext.log("Showing chord: \(chord.symbol)")
    }

    // MARK: - Scales Display

    private func showScales() {
        clearCanvas()

        let (scale, description) = allScales[currentScaleIndex]
        statusText = "Scales (\(currentScaleIndex + 1)/\(allScales.count)): \(description)"

        // Title
        let titleLabel = Label()
        titleLabel.text = "Scale: \(scale.displayName)"
        titleLabel.setPosition(Vector2(x: 0, y: 0))
        titleLabel.addThemeFontSizeOverride(name: "font_size", fontSize: 20)
        canvas?.addChild(node: titleLabel)
        textLabels.append(titleLabel)

        // Draw piano with highlighted notes
        let highlightedNotes = Set(scale.pitchClasses)
        drawPiano(highlightedNotes: highlightedNotes, yOffset: 40)

        // Show scale info
        var yOffset: Float = 180

        let patternLabel = Label()
        patternLabel.text = "Pattern: \(scale.pattern.name)"
        patternLabel.setPosition(Vector2(x: 0, y: yOffset))
        canvas?.addChild(node: patternLabel)
        textLabels.append(patternLabel)
        yOffset += 25

        let notesLabel = Label()
        let noteNames = scale.pitchClasses.map { $0.displayName }.joined(separator: " - ")
        notesLabel.text = "Notes: \(noteNames)"
        notesLabel.setPosition(Vector2(x: 0, y: yOffset))
        canvas?.addChild(node: notesLabel)
        textLabels.append(notesLabel)
        yOffset += 25

        let intervalsLabel = Label()
        let intervals = scale.pattern.intervals.map { String($0) }.joined(separator: ", ")
        intervalsLabel.text = "Intervals (semitones): \(intervals)"
        intervalsLabel.setPosition(Vector2(x: 0, y: yOffset))
        canvas?.addChild(node: intervalsLabel)
        textLabels.append(intervalsLabel)
        yOffset += 25

        // Show step pattern (whole/half steps)
        let stepsLabel = Label()
        var steps: [String] = []
        let ints = scale.pattern.intervals
        for i in 0..<(ints.count - 1) {
            let diff = ints[i + 1] - ints[i]
            steps.append(diff == 1 ? "H" : diff == 2 ? "W" : "W+H")
        }
        stepsLabel.text = "Steps: \(steps.joined(separator: "-"))"
        stepsLabel.setPosition(Vector2(x: 0, y: yOffset))
        canvas?.addChild(node: stepsLabel)
        textLabels.append(stepsLabel)
        yOffset += 25

        // Relative scale info
        if let relative = scale.relative {
            let relativeLabel = Label()
            relativeLabel.text = "Relative: \(relative.displayName)"
            relativeLabel.setPosition(Vector2(x: 0, y: yOffset))
            canvas?.addChild(node: relativeLabel)
            textLabels.append(relativeLabel)
        }

        GodotContext.log("Showing scale: \(scale.displayName)")
    }

    // MARK: - Frequency Display

    private func showFrequencies() {
        clearCanvas()
        statusText = "Frequency Relationships (swift-music)"

        var yOffset: Float = 0

        // Title
        let titleLabel = Label()
        titleLabel.text = "Note Frequencies (Equal Temperament, A4 = 440 Hz)"
        titleLabel.setPosition(Vector2(x: 0, y: yOffset))
        titleLabel.addThemeFontSizeOverride(name: "font_size", fontSize: 16)
        canvas?.addChild(node: titleLabel)
        textLabels.append(titleLabel)
        yOffset += 30

        // Show chromatic scale frequencies for octave 4
        let chromaticNotes: [PitchClass] = [.c, .cSharp, .d, .dSharp, .e, .f, .fSharp, .g, .gSharp, .a, .aSharp, .b]

        for pitch in chromaticNotes {
            let note = Note(pitchClass: pitch, octave: 4)

            let nameLabel = Label()
            nameLabel.text = "\(pitch.displayName)4"
            nameLabel.setPosition(Vector2(x: 0, y: yOffset))
            nameLabel.customMinimumSize = Vector2(x: 50, y: 20)
            canvas?.addChild(node: nameLabel)
            textLabels.append(nameLabel)

            let freqLabel = Label()
            freqLabel.text = String(format: "%.2f Hz", note.frequency)
            freqLabel.setPosition(Vector2(x: 60, y: yOffset))
            freqLabel.customMinimumSize = Vector2(x: 80, y: 20)
            canvas?.addChild(node: freqLabel)
            textLabels.append(freqLabel)

            let midiLabel = Label()
            midiLabel.text = "MIDI: \(note.midiNumber)"
            midiLabel.setPosition(Vector2(x: 160, y: yOffset))
            canvas?.addChild(node: midiLabel)
            textLabels.append(midiLabel)

            // Visual frequency bar
            let barWidth = Float(note.frequency) / 4.0  // Scale for display
            let bar = ColorRect()
            bar.color = Color(r: 0.3, g: 0.6, b: 0.9, a: 0.8)
            bar.setPosition(Vector2(x: 240, y: yOffset + 3))
            bar.customMinimumSize = Vector2(x: barWidth, y: 14)
            bar.setSize(Vector2(x: barWidth, y: 14))
            canvas?.addChild(node: bar)
            markers.append(bar)

            yOffset += 22
        }

        // Show octave relationships
        yOffset += 20
        let octaveLabel = Label()
        octaveLabel.text = "Octave Relationships (frequency doubles per octave):"
        octaveLabel.setPosition(Vector2(x: 0, y: yOffset))
        canvas?.addChild(node: octaveLabel)
        textLabels.append(octaveLabel)
        yOffset += 25

        for octave in 2...6 {
            let note = Note(pitchClass: .a, octave: octave)
            let label = Label()
            label.text = "A\(octave): \(String(format: "%.1f", note.frequency)) Hz"
            label.setPosition(Vector2(x: Float((octave - 2) * 90), y: yOffset))
            canvas?.addChild(node: label)
            textLabels.append(label)
        }

        GodotContext.log("Showing frequency relationships")
    }
}
