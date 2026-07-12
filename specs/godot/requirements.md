---
spec: godot.spec.md
---

## Requirements

- **REQ-swift-godot-001** (stable): Property wrappers shall preserve existing reactive state, typed node lookup, and declarative signal behavior.
- **REQ-swift-godot-002** (stable): Async signal and frame utilities shall preserve timeout, cancellation, and Swift concurrency behavior.
- **REQ-swift-godot-003** (stable): Controller protocols and node/object extensions shall retain their documented typed lifecycle and traversal APIs.
- **REQ-swift-godot-004** (stable): Native verification shall build `SwiftGodotKit` and run its tests without launching or mutating a live Godot project.

## Constraints

- SwiftGodot and the supported Apple platform versions remain as declared by the package.
- Demo execution requires a separately installed Godot runtime.

## Out of Scope

- Changing APIs, dependency revisions, demo assets, releases, engine state, or Pages deployment.
