# ``SwiftGodotKit``

Declarative Swift extensions for Godot 4.4 game development.

## Overview

SwiftGodotKit wraps and extends [SwiftGodot](https://github.com/migueldeicaza/SwiftGodot) with SwiftUI-inspired patterns, bringing declarative, reactive programming to Godot game development.

```swift
import SwiftGodotKit

@Godot
class Player: CharacterBody3D {
    @GodotState var health: Int = 100
    @GodotNode("HealthBar") var healthBar: ProgressBar?

    override func _process(delta: Double) {
        if $health.changed {
            healthBar?.value = Double(health)
        }
        $health.reset()
    }
}
```

### Key Features

- **Property Wrappers** - `@GodotState`, `@GodotNode`, `@GodotSignal` for declarative patterns
- **Protocol Abstractions** - Type-safe scene and node management
- **Async/Await** - Modern concurrency for signals and game loops
- **Swift 6.0** - Full strict concurrency support

## Topics

### Essentials

- <doc:GettingStarted>

### Property Wrappers

- ``GodotState``
- ``GodotNode``
- ``GodotSignal``

### Async Utilities

- ``SignalAwaiter``
- ``AsyncSignal``
- ``GodotTask``

### Protocols

- ``SceneController``
- ``NodeController``
- ``SignalEmitting``
- ``SignalReceiving``

### Signal Types

- ``Signal0``
- ``Signal1``
- ``Signal2``
- ``Signal3``

### Utilities

- ``Box``
- ``GodotContext``
