# Changelog

All notable changes to SwiftGodotKit will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2025-01-05

### Added

- **Property Wrappers**
  - `@GodotState` - Reactive state with change tracking and bindings
  - `@GodotNode` - Type-safe node references with path, unique, and group lookup
  - `@GodotSignal` - Declarative signal connection with automatic cleanup

- **Async Utilities**
  - `SignalAwaiter` - Await Godot signals with async/await syntax
  - `AsyncSignal` - AsyncSequence wrapper for streaming signal events
  - `GodotTask` - Frame-synchronized async helpers (nextFrame, nextPhysicsFrame, wait)

- **Protocols**
  - `SceneController` - Lifecycle management for scene roots
  - `NodeController` - Declarative node hierarchy building with `@NodeBuilder`
  - `SignalEmitting` / `SignalReceiving` - Type-safe signal patterns

- **Extensions**
  - `Node+Extensions` - Child iteration, type-safe queries, ancestry traversal
  - `Object+Extensions` - Signal connection helpers, metadata access

- **Internal Utilities**
  - `GodotContext` - Engine state, logging, frame deferral helpers
  - `Box` - Thread-safe Sendable container for mutable state

- **Documentation**
  - Full DocC documentation with Getting Started guide
  - Comprehensive demo suite with 6 playable game examples

### Notes

- Requires Swift 6.0+, macOS 14.0+, iOS 17.0+, Godot 4.4+
- Re-exports SwiftGodot for seamless usage

[Unreleased]: https://github.com/CorvidLabs/swift-godot/compare/0.1.0...HEAD
[0.1.0]: https://github.com/CorvidLabs/swift-godot/releases/tag/0.1.0
