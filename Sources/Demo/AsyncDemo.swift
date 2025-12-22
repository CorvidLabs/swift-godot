import SwiftGodotKit

// MARK: - Async Patterns Showcase

/// Demonstrates SwiftGodotKit's async/await patterns
@Godot
class AsyncShowcase: Control {

    // MARK: - Node References

    @GodotNode("VBox/StatusLabel") var statusLabel: Label?
    @GodotNode("VBox/CounterLabel") var counterLabel: Label?
    @GodotNode("VBox/HBox/AwaitButton") var awaitButton: Button?
    @GodotNode("VBox/HBox/StreamButton") var streamButton: Button?
    @GodotNode("VBox/HBox/FrameButton") var frameButton: Button?
    @GodotNode("VBox/HBox/ParallelButton") var parallelButton: Button?
    @GodotNode("BackButton") var backButton: Button?

    // MARK: - State

    @GodotState var counter: Int = 0
    @GodotState var isRunning: Bool = false
    @GodotState var statusText: String = "Ready! Select a demo pattern."

    private var timer: Timer?

    // MARK: - Lifecycle

    override func _ready() {
        $statusLabel.configure(owner: self)
        $counterLabel.configure(owner: self)
        $awaitButton.configure(owner: self)
        $streamButton.configure(owner: self)
        $frameButton.configure(owner: self)
        $parallelButton.configure(owner: self)
        $backButton.configure(owner: self)

        setupButtons()

        GodotContext.log("""

        ╔═══════════════════════════════════════════╗
        ║         Async Patterns Showcase           ║
        ╠═══════════════════════════════════════════╣
        ║  • SignalAwaiter - await signals          ║
        ║  • AsyncSignal - stream signal events     ║
        ║  • GodotTask - frame synchronization      ║
        ║  • TaskGroup - parallel execution         ║
        ╚═══════════════════════════════════════════╝

        """)
    }

    override func _process(delta: Double) {
        if $counter.changed {
            counterLabel?.text = "Counter: \(counter)"
        }
        if $statusText.changed {
            statusLabel?.text = statusText
        }
        $counter.reset()
        $statusText.reset()
    }

    override func _exitTree() {
        timer?.queueFree()
    }

    // MARK: - Setup

    private func setupButtons() {
        awaitButton?.on("pressed") { [weak self] in
            self?.demoAwait()
        }

        streamButton?.on("pressed") { [weak self] in
            self?.demoStream()
        }

        frameButton?.on("pressed") { [weak self] in
            self?.demoFrames()
        }

        parallelButton?.on("pressed") { [weak self] in
            self?.demoParallel()
        }

        backButton?.on("pressed") { [weak self] in
            _ = self?.getTree()?.changeSceneToFile(path: "res://demo_menu.tscn")
        }
    }

    // MARK: - Demos

    private func demoAwait() {
        counter += 1
        statusText = "Signal await demo: Counter incremented!"
        GodotContext.log("""

        === SignalAwaiter Example ===
        await SignalAwaiter.wait(for: button, signal: "pressed")
        // Code continues after signal is emitted

        """)
    }

    private func demoStream() {
        if let existingTimer = timer {
            existingTimer.queueFree()
            timer = nil
            streamButton?.text = "Start Stream"
            statusText = "Stopped streaming timer signals."
            return
        }

        streamButton?.text = "Stop Stream"
        statusText = "Streaming timer signals..."

        let newTimer = Timer()
        newTimer.waitTime = 0.5
        newTimer.autostart = true
        addChild(node: newTimer)
        timer = newTimer

        newTimer.on("timeout") { [weak self] in
            self?.counter += 1
        }

        GodotContext.log("""

        === AsyncSignal Example ===
        for await _ in AsyncSignal(source: timer, signal: "timeout") {
            counter += 1
        }
        // Streams signals as AsyncSequence

        """)
    }

    private func demoFrames() {
        counter = 0
        statusText = "Frame sync: Counting 10 frames..."

        // Demonstrate frame counting using process
        var frameCount = 0
        let maxFrames = 10

        // Use deferred signal to simulate frame-by-frame counting
        GodotContext.afterFrame { [weak self] in
            frameCount += 1
            self?.counter = frameCount
            if frameCount >= maxFrames {
                self?.statusText = "Waited \(maxFrames) frames!"
            }
        }

        GodotContext.log("""

        === GodotTask Frame Sync Example ===
        await GodotTask.nextFrame()      // Wait one frame
        await GodotTask.frames(10)       // Wait 10 frames
        await GodotTask.waitGodot(1.5)   // Wait 1.5 seconds via Godot timer

        """)
    }

    private func demoParallel() {
        counter = 0
        statusText = "Parallel tasks demonstration"

        GodotContext.log("""

        === Parallel Task Group Example ===
        let results = await withGodotTaskGroup(of: Int.self) { group in
            group.addTask { await task1() }
            group.addTask { await task2() }
            group.addTask { await task3() }
        }
        // All tasks run concurrently

        """)

        // Simulate parallel work completion
        counter = 20
        statusText = "Parallel tasks complete! (simulated)"
    }
}
