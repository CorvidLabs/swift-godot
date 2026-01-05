# Testing Guide

This guide covers running tests and the demo games for SwiftGodotKit.

## Unit Tests

Run the Swift unit tests:

```bash
swift test
```

The test suite covers:

- **PropertyWrapperTests** - `@GodotState` initialization, mutation, change tracking, bindings
- **AsyncTests** - `Box` operations, `SignalAwaiterError` cases
- **ProtocolTests** - `@NodeBuilder` DSL validation

### Test Limitations

Some features require a running Godot engine and cannot be tested in pure Swift:

- Signal connections and emissions
- Node tree operations
- `GodotTask` async frame waiting

These are tested via the demo project instead.

## Demo Project

The repository includes a comprehensive demo suite with playable games.

### Building the Demo

```bash
# Build the demo library (release mode)
./scripts/build-demo.sh

# Or manually:
swift build -c release --product SwiftGodotKitDemo
cp .build/release/libSwiftGodotKitDemo.dylib GodotProject/bin/
cp .build/release/libSwiftGodot.dylib GodotProject/bin/
```

### Running the Demo

```bash
# Open in Godot
open -a Godot GodotProject/project.godot
```

Then press F5 to run, or open individual scenes.

### Demo Games

| Game | Description | Features Demonstrated |
|------|-------------|----------------------|
| **Breakout** | Classic brick-breaker | Physics, collision, state |
| **Platformer** | Side-scrolling platform game | Movement, animation |
| **Snake** | Classic snake game | Grid-based movement |
| **Asteroids** | Space shooter | Rotation, projectiles |
| **Rhythm** | Music/rhythm game | Timing, audio sync |
| **Dungeon** | Dungeon crawler | Procedural generation |

### Feature Demos

| Demo | Features |
|------|----------|
| **Audio** | Sound playback, music |
| **Tween** | Animations, easing |
| **Camera** | Camera control, follow |
| **Particles** | Particle systems |
| **Async** | Signal awaiting, frame sync |
| **Color Lab** | Color manipulation |
| **Music Theory** | Scales, chords |
| **QR Code** | QR generation |

## Verifying Changes

Before submitting a pull request:

1. **Run unit tests**:
   ```bash
   swift test
   ```

2. **Build the library**:
   ```bash
   swift build
   ```

3. **Build and test the demo**:
   ```bash
   ./scripts/build-demo.sh
   open -a Godot GodotProject/project.godot
   ```

4. **Verify demo games work**:
   - Open the Demo Menu scene
   - Test each game briefly
   - Check console for errors

## Continuous Integration

The repository uses GitHub Actions for CI:

- **macOS.yml** - Builds and tests on macOS with Xcode
- **docs.yml** - Generates and deploys DocC documentation

CI runs on every push to any branch.

## Troubleshooting

### Tests fail with "module not found"

```bash
swift package clean
swift build
swift test
```

### Demo crashes on launch

- Ensure Godot 4.4+ is installed
- Rebuild: `./scripts/build-demo.sh`
- Check Godot console for specific errors

### Changes not reflecting in Godot

- Rebuild the demo library
- Restart Godot completely (not just reload project)
- Verify dylibs were copied to `GodotProject/bin/`
