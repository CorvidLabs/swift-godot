# SwiftGodotKit

[![macOS](https://img.shields.io/github/actions/workflow/status/CorvidLabs/swift-godot/macOS.yml?label=macOS&branch=main)](https://github.com/CorvidLabs/swift-godot/actions/workflows/macOS.yml)
[![License](https://img.shields.io/github/license/CorvidLabs/swift-godot)](https://github.com/CorvidLabs/swift-godot/blob/main/LICENSE)
[![Version](https://img.shields.io/github/v/release/CorvidLabs/swift-godot)](https://github.com/CorvidLabs/swift-godot/releases)

> **Pre-1.0 Notice**: This library is under active development. The API may change between minor versions until 1.0.

Declarative Swift extensions for Godot 4.4 game development. Built with Swift 6 and async/await.

## Features

- **Property Wrappers** - `@GodotState`, `@GodotNode`, `@GodotSignal` for SwiftUI-like declarative patterns
- **Async/Await** - Modern concurrency for signals, frame sync, and game loops
- **Protocol Abstractions** - Type-safe scene and node lifecycle management
- **Swift 6** - Full strict concurrency support with `Sendable` conformance
- **Re-exports SwiftGodot** - Drop-in enhancement, no additional imports needed

## Installation

### Swift Package Manager

Add SwiftGodotKit to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/CorvidLabs/swift-godot.git", from: "0.1.0")
]
```

Then add the dependency to your target:

```swift
.target(
    name: "YourGame",
    dependencies: [
        .product(name: "SwiftGodotKit", package: "swift-godot")
    ]
)
```

## Documentation

- **[Getting Started](documentation/GETTING_STARTED.md)** - Step-by-step guide for your first game
- **[Quick Start](documentation/QUICKSTART.md)** - Get running in 5 minutes
- **[Testing Guide](documentation/TESTING.md)** - Running tests and demo games
- **[Security](SECURITY.md)** - Thread safety and memory management
- **[Contributing](CONTRIBUTING.md)** - How to contribute to the project

## Quick Start

### Basic Player Class

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
        $health.reset()
    }

    func takeDamage(_ amount: Int) {
        health = max(0, health - amount)
    }
}
```

## Core Concepts

### Property Wrappers

#### @GodotState - Reactive State

```swift
@GodotState var score: Int = 0

// Check if changed this frame
if $score.changed {
    updateScoreDisplay()
}

// Get previous value for animations
if let previous = $score.previous {
    animateScoreChange(from: previous, to: score)
}

// Create bindings for UI
let binding = $score.binding
```

#### @GodotNode - Type-Safe Node References

```swift
// By path
@GodotNode("UI/HealthBar") var healthBar: ProgressBar?

// By unique name (% prefix in scene)
@GodotNode(.unique("Player")) var player: CharacterBody3D?

// By group
@GodotNode(.group("enemies")) var firstEnemy: Node?
```

#### @GodotSignal - Declarative Signal Connections

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

### Node Extensions

```swift
// Iterate children
for child in node.children {
    print(child.name)
}

// Type-safe queries
let buttons: [Button] = panel.children(ofType: Button.self)
let allEnemies: [Enemy] = level.descendants(ofType: Enemy.self)

// Fluent configuration
let label = Label().configure {
    $0.text = "Hello"
    $0.horizontalAlignment = .center
}
```

## Architecture

The library is organized into key components:

- **Property Wrappers**: `@GodotState`, `@GodotNode`, `@GodotSignal`
- **Async Utilities**: `SignalAwaiter`, `AsyncSignal`, `GodotTask`
- **Protocols**: `SceneController`, `NodeController`, `SignalEmitting`, `SignalReceiving`
- **Extensions**: `Node+Extensions`, `Object+Extensions`
- **Internal**: `GodotContext`, `Box`

All components are designed for Swift 6 strict concurrency with proper `Sendable` conformance.

## Requirements

| Platform | Minimum Version |
|----------|-----------------|
| macOS    | 14.0+           |
| iOS      | 17.0+           |
| Swift    | 6.0+            |
| Godot    | 4.4+            |

## Running the Demo

The repository includes a comprehensive demo suite with 6 playable games:

```bash
# Build the demo library
./scripts/build-demo.sh

# Open in Godot
open -a Godot GodotProject/project.godot
```

**Demo Games**: Breakout, Platformer, Snake, Asteroids, Rhythm, Dungeon

**Feature Demos**: Audio, Tween, Camera, Particles, Async, Color Lab, Music Theory, QR Code

## License

MIT License - See [LICENSE](LICENSE) for details.

## Contributing

Contributions are welcome! See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## Resources

- [SwiftGodot](https://github.com/migueldeicaza/SwiftGodot) - Swift bindings for Godot
- [Godot Engine](https://godotengine.org) - Game engine
- [Swift.org](https://swift.org) - Swift programming language

## Credits

Built with love for the Swift and Godot communities.
