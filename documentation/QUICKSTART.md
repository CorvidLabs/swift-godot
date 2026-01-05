# Quick Start

Get SwiftGodotKit running in 5 minutes.

## 1. Add Dependency

```swift
dependencies: [
    .package(url: "https://github.com/CorvidLabs/swift-godot.git", from: "0.1.0")
]
```

## 2. Import and Use

```swift
import SwiftGodotKit

@Godot
class Player: CharacterBody3D {
    @GodotState var health: Int = 100
    @GodotNode("HealthBar") var healthBar: ProgressBar?

    override func _ready() {
        $healthBar.configure(owner: self)
    }

    override func _process(delta: Double) {
        if $health.changed {
            healthBar?.value = Double(health)
        }
        $health.reset()
    }
}
```

## 3. Build

```bash
swift build -c release
```

## 4. Configure Godot

Create `YourGame.gdextension`:

```ini
[configuration]
entry_symbol = "swift_entry_point"
compatibility_minimum = 4.2

[libraries]
macos.debug = "res://bin/libYourGame.dylib"
macos.release = "res://bin/libYourGame.dylib"
```

## 5. Run

Copy dylibs to `bin/`, open Godot, press F5.

## Key Concepts

| Feature | Usage |
|---------|-------|
| `@GodotState` | Reactive state with change tracking |
| `@GodotNode` | Type-safe node references |
| `@GodotSignal` | Declarative signal connections |
| `SignalAwaiter` | Await signals with async/await |
| `GodotTask` | Frame-synchronized async work |

## Examples

### Await a Signal

```swift
await SignalAwaiter.wait(for: button, signal: "pressed")
```

### Stream Signals

```swift
for await _ in AsyncSignal(source: timer, signal: "timeout") {
    update()
}
```

### Wait for Next Frame

```swift
await GodotTask.nextFrame()
```

See [Getting Started](GETTING_STARTED.md) for a complete tutorial.
