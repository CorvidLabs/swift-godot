---
module: godot
version: 1
status: active
files:
  - Package.swift
  - Sources/SwiftGodotKit/

db_tables: []
depends_on: []
---

# SwiftGodotKit

## Purpose

Provide the existing declarative Swift extensions, property wrappers, asynchronous signal utilities, node protocols, and extensions for Godot 4.4 development, plus the independently built demonstration target.

## Public API

### Package Interface

The `SwiftGodotKit` product re-exports SwiftGodot and exposes reactive state, node lookup and signal wrappers, async signal and frame utilities, controller and signal protocols, and node/object extensions. The dynamic demo product and Godot project remain examples rather than additional library guarantees.

## Invariants

1. Property wrappers preserve their documented value, change, lookup, and signal-connection semantics.
2. Async utilities resume or terminate according to Godot signal, frame, cancellation, and timeout behavior without violating Swift concurrency isolation.
3. Controller protocols and extensions preserve type-safe node ownership and traversal behavior.
4. The SwiftGodot dependency remains pinned to its known-good immutable revision.
5. Launching Godot or interacting with a live engine remains independently authorized and outside the blocking pull-request lane.

## Behavioral Examples

```
Given a Godot node configured through a SwiftGodotKit property wrapper
When the node enters its documented lifecycle
Then lookup, state tracking, or signal delivery follows the existing typed API
```

## Error Cases

| Error | When | Behavior |
|-------|------|----------|
| Missing node | A configured path, unique name, or group has no matching node | Preserve optional lookup behavior |
| Signal timeout | An awaited signal does not arrive before its deadline | Return the existing timeout failure |
| Cancellation | An async wait is cancelled | Terminate without leaking the continuation |
| Unsupported engine context | Runtime-only behavior is invoked without Godot | Surface the existing failure rather than fabricate engine state |

## Dependencies

- Swift 6 and supported macOS/iOS versions
- SwiftGodot at the immutable revision declared in `Package.swift`
- CorvidLabs demo dependencies and Swift-DocC plugin

## Change Log

| Version | Date | Changes |
|---------|------|---------|
| 1 | 2026-07-12 | Initial spec |
