# Getting Started with SwiftGodotKit

This guide walks you through creating your first Godot game with SwiftGodotKit.

## Prerequisites

- **macOS 14.0+** or **iOS 17.0+**
- **Swift 6.0+** (included with Xcode 16+)
- **Godot 4.4+** ([download](https://godotengine.org/download))

## Step 1: Create a Swift Package

Create a new Swift package for your game:

```bash
mkdir MyGodotGame
cd MyGodotGame
swift package init --type library --name MyGodotGame
```

## Step 2: Configure Package.swift

Update your `Package.swift`:

```swift
// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "MyGodotGame",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "MyGodotGame",
            type: .dynamic,
            targets: ["MyGodotGame"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/CorvidLabs/swift-godot.git", from: "0.1.0")
    ],
    targets: [
        .target(
            name: "MyGodotGame",
            dependencies: [
                .product(name: "SwiftGodotKit", package: "swift-godot")
            ],
            plugins: [
                .plugin(name: "EntryPointGeneratorPlugin", package: "SwiftGodot")
            ]
        )
    ]
)
```

## Step 3: Create Your First Node

Create `Sources/MyGodotGame/Player.swift`:

```swift
import SwiftGodotKit

@Godot
public class Player: CharacterBody3D {
    // Reactive state
    @GodotState var health: Int = 100
    @GodotState var speed: Float = 5.0

    // Node references
    @GodotNode("HealthBar") var healthBar: ProgressBar?
    @GodotNode("Camera3D") var camera: Camera3D?

    public override func _ready() {
        // Configure node references
        $healthBar.configure(owner: self)
        $camera.configure(owner: self)

        print("Player ready with \(health) health")
    }

    public override func _process(delta: Double) {
        // React to state changes
        if $health.changed {
            healthBar?.value = Double(health)

            if health <= 0 {
                die()
            }
        }

        // Reset change tracking
        $health.reset()
    }

    public override func _physicsProcess(delta: Double) {
        handleMovement(delta: delta)
    }

    private func handleMovement(delta: Double) {
        var velocity = Vector3.zero

        if Input.isActionPressed(action: "move_forward") {
            velocity.z -= 1
        }
        if Input.isActionPressed(action: "move_back") {
            velocity.z += 1
        }
        if Input.isActionPressed(action: "move_left") {
            velocity.x -= 1
        }
        if Input.isActionPressed(action: "move_right") {
            velocity.x += 1
        }

        if velocity != .zero {
            velocity = velocity.normalized() * speed
        }

        self.velocity = velocity
        moveAndSlide()
    }

    public func takeDamage(_ amount: Int) {
        health = max(0, health - amount)
    }

    private func die() {
        print("Player died!")
        queueFree()
    }
}
```

## Step 4: Build the Library

```bash
swift build -c release
```

This creates `libMyGodotGame.dylib` in `.build/release/`.

## Step 5: Set Up Godot Project

1. Create a new Godot project or open an existing one

2. Create a `.gdextension` file (e.g., `MyGodotGame.gdextension`):

```ini
[configuration]
entry_symbol = "swift_entry_point"
compatibility_minimum = 4.2

[libraries]
macos.debug = "res://bin/libMyGodotGame.dylib"
macos.release = "res://bin/libMyGodotGame.dylib"
```

3. Create a `bin/` directory in your Godot project

4. Copy the built libraries:
```bash
cp .build/release/libMyGodotGame.dylib /path/to/godot/project/bin/
cp .build/release/libSwiftGodot.dylib /path/to/godot/project/bin/
```

## Step 6: Use Your Swift Node in Godot

1. Open your Godot project
2. Create a new scene
3. Add a **CharacterBody3D** node
4. In the Inspector, change its script to your `Player` class
5. Add child nodes as needed (HealthBar, Camera3D, etc.)

## Step 7: Run Your Game

Press F5 in Godot to run your game!

## Next Steps

- **[Quick Start](QUICKSTART.md)** - 5-minute overview
- **[Testing Guide](TESTING.md)** - Running tests and demos
- **[API Reference](../Sources/SwiftGodotKit/SwiftGodotKit.docc)** - Full documentation

## Troubleshooting

### Library not loading

- Ensure the `.gdextension` file path matches your library location
- Verify both `libMyGodotGame.dylib` and `libSwiftGodot.dylib` are in the bin folder
- Check Godot console for error messages

### Node not appearing

- Verify your class has the `@Godot` attribute
- Ensure the class is `public`
- Rebuild after changes: `swift build -c release`

### Changes not reflecting

- Restart Godot after rebuilding the library
- Godot caches extensions; a full restart may be needed
