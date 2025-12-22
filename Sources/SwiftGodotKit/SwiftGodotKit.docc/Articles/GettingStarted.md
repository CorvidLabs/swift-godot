# Getting Started with SwiftGodotKit

Learn how to set up SwiftGodotKit and create your first Godot game with Swift.

## Overview

SwiftGodotKit provides SwiftUI-inspired patterns for Godot game development. This guide walks you through installation, basic setup, and your first reactive game class.

## Requirements

| Platform | Minimum Version |
|----------|-----------------|
| macOS    | 14.0+           |
| iOS      | 17.0+           |
| Swift    | 6.0+            |
| Godot    | 4.4+            |

## Installation

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
    ],
    plugins: [
        .plugin(name: "EntryPointGeneratorPlugin", package: "SwiftGodot")
    ]
)
```

> Note: The `EntryPointGeneratorPlugin` automatically generates the GDExtension entry point for your classes.

## Your First Class

Create a player class using SwiftGodotKit's property wrappers:

```swift
import SwiftGodotKit

@Godot
class Player: CharacterBody3D {
    // Reactive state with automatic change tracking
    @GodotState var health: Int = 100
    @GodotState var score: Int = 0

    // Type-safe node references
    @GodotNode("UI/HealthBar") var healthBar: ProgressBar?
    @GodotNode("UI/ScoreLabel") var scoreLabel: Label?

    override func _ready() {
        // Configure node references
        $healthBar.configure(owner: self)
        $scoreLabel.configure(owner: self)
    }

    override func _process(delta: Double) {
        // React to state changes
        if $health.changed {
            healthBar?.value = Double(health)
        }

        if $score.changed {
            scoreLabel?.text = "Score: \(score)"
        }

        // Reset change flags
        $health.reset()
        $score.reset()
    }

    func takeDamage(_ amount: Int) {
        health = max(0, health - amount)
    }

    func addPoints(_ points: Int) {
        score += points
    }
}
```

## Understanding @GodotState

The ``GodotState`` property wrapper provides reactive state management:

```swift
@GodotState var health: Int = 100

// Check if value changed this frame
if $health.changed {
    // React to change
}

// Access previous value
if let previous = $health.previous {
    // Animate from previous to current
}

// Reset change flag (call at end of frame)
$health.reset()
```

## Understanding @GodotNode

The ``GodotNode`` property wrapper provides type-safe node references:

```swift
// By path
@GodotNode("UI/HealthBar") var healthBar: ProgressBar?

// By unique name (% prefix in Godot scene)
@GodotNode(.unique("Player")) var player: CharacterBody3D?

// By group
@GodotNode(.group("enemies")) var firstEnemy: Node?
```

Always call `configure(owner:)` in `_ready()`:

```swift
override func _ready() {
    $healthBar.configure(owner: self)
}
```

## Next Steps

- Learn about async signal handling with ``SignalAwaiter``
- Create reusable components with ``NodeController``
- Manage scenes with ``SceneController``
