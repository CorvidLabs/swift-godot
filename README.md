# SwiftGodotKit

Declarative Swift extensions for Godot 4.4 game development

[![Swift 6.0+](https://img.shields.io/badge/Swift-6.0+-orange.svg)](https://swift.org)
[![Godot 4.4](https://img.shields.io/badge/Godot-4.4-blue.svg)](https://godotengine.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![macOS](https://img.shields.io/badge/macOS-14.0+-lightgrey.svg)]()
[![iOS](https://img.shields.io/badge/iOS-17.0+-lightgrey.svg)]()

SwiftGodotKit wraps and extends [SwiftGodot](https://github.com/migueldeicaza/SwiftGodot) with SwiftUI-inspired patterns, bringing declarative, reactive programming to Godot game development.

## Features

- **Property Wrappers** - `@GodotState`, `@GodotNode`, `@GodotSignal` for declarative patterns
- **Protocol Abstractions** - Type-safe scene and node management
- **Async/Await** - Modern concurrency for signals and game loops
- **Swift 6.0** - Full strict concurrency support with `Sendable` conformance
- **Re-exports SwiftGodot** - Drop-in enhancement, no additional imports needed

## Requirements

| Platform | Minimum Version |
|----------|-----------------|
| macOS    | 14.0+           |
| iOS      | 17.0+           |
| Swift    | 6.0+            |
| Godot    | 4.4+            |

## Getting Started

### Installation

Add SwiftGodotKit to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/CorvidLabs/swift-godot.git", from: "0.1.0")
]
```

Then add it to your target:

```swift
.target(
    name: "YourGame",
    dependencies: [
        .product(name: "SwiftGodotKit", package: "swift-godot")
    ]
)
```

### Basic Usage

```swift
import SwiftGodotKit  // Includes all of SwiftGodot

@Godot
class Player: CharacterBody3D {
    // Reactive state with change tracking
    @GodotState var health: Int = 100
    @GodotState var isAlive: Bool = true

    // Declarative node references
    @GodotNode("HealthBar") var healthBar: ProgressBar?
    @GodotNode(.unique("AnimPlayer")) var animator: AnimationPlayer?

    override func _ready() {
        $healthBar.configure(owner: self)
        $animator.configure(owner: self)
    }

    override func _process(delta: Double) {
        // React to state changes
        if $health.changed {
            healthBar?.value = Double(health)
            if health <= 0 { isAlive = false }
        }

        // Reset change flags at end of frame
        $health.reset()
    }

    func takeDamage(_ amount: Int) {
        health = max(0, health - amount)
    }
}
```

## Usage

### Property Wrappers

#### @GodotState

Reactive state management with change tracking:

```swift
@GodotState var score: Int = 0

// Check if changed this frame
if $score.changed {
    updateScoreDisplay()
}

// Get previous value
if let previous = $score.previous {
    animateScoreChange(from: previous, to: score)
}

// Create bindings for UI
let binding = $score.binding
```

#### @GodotNode

Type-safe node references with multiple lookup strategies:

```swift
// By path
@GodotNode("UI/HealthBar") var healthBar: ProgressBar?

// By unique name (% prefix in scene)
@GodotNode(.unique("Player")) var player: CharacterBody3D?

// By group
@GodotNode(.group("enemies")) var firstEnemy: Node?
```

#### @GodotSignal

Declarative signal connections:

```swift
@GodotSignal("pressed")
var onPressed: () -> Void = { print("Pressed!") }
```

### Async/Await

#### Awaiting Signals

```swift
// Wait for a signal
await SignalAwaiter.wait(for: button, signal: "pressed")

// Wait with timeout
let succeeded = try await SignalAwaiter.wait(
    for: enemy,
    signal: "died",
    timeout: .seconds(5)
)
```

#### Signal Streams

```swift
// Stream signals as AsyncSequence
for await _ in AsyncSignal(source: timer, signal: "timeout") {
    updateGame()
}
```

#### Frame Synchronization

```swift
// Wait for next frame
await GodotTask.nextFrame()

// Wait for physics frame
await GodotTask.nextPhysicsFrame()

// Wait specific duration
await GodotTask.wait(seconds: 1.5)
```

### Protocols

#### SceneController

```swift
class GameScene: SceneController {
    typealias RootNode = Node3D
    var rootNode: Node3D?

    func sceneDidBecomeReady() {
        setupGame()
    }

    func sceneDidProcess(delta: Double) {
        updateGameLogic(delta: delta)
    }
}
```

#### NodeController

```swift
class PlayerController: NodeController {
    typealias NodeType = CharacterBody3D
    let node = CharacterBody3D()

    var children: [any NodeController] {
        [HealthBarController(), WeaponController()]
    }

    func configure() {
        node.name = "Player"
    }
}
```

## Documentation

Full documentation is available via DocC:

```bash
swift package generate-documentation
```

## Contributing

Contributions are welcome! Please open an issue or pull request.

## License

SwiftGodotKit is available under the MIT license. See [LICENSE](LICENSE) for details.

---

Built with love for the Swift and Godot communities.
