---
spec: godot.spec.md
---

## Requirements

### REQ-godot-001

Property wrappers SHALL preserve existing reactive state, typed node lookup, and declarative signal behavior.

Acceptance Criteria
- `GodotState`, `GodotNode`, and `GodotSignal` remain present in the validated public API inventory.
- `PropertyWrapperTests` passes its state initialization, mutation, change detection, reset, and two-way binding scenarios without launching a live Godot project.

Verification
- `fledge lanes run verify`

### REQ-godot-002

Async signal and frame utilities SHALL preserve timeout, cancellation, and Swift concurrency behavior.

Acceptance Criteria
- `AsyncSignal`, `SignalAwaiter`, and the Godot task APIs remain present in the validated public API inventory.
- The package build type-checks the async signal and task APIs, while `AsyncTests` validates the signal error cases and Sendable boxed state used by the async helpers.

Verification
- `fledge lanes run verify`

### REQ-godot-003

Controller protocols and node/object extensions SHALL retain their documented typed lifecycle and traversal APIs.

Acceptance Criteria
- `NodeController`, `SceneController`, `SignalEmitting`, and `SignalReceiving` remain present in the validated public API inventory.
- The package build type-checks the controller, signal, and extension APIs, while `ProtocolTests` validates the `NodeBuilder` empty-block contract without requiring Godot runtime state.

Verification
- `fledge lanes run verify`

### REQ-godot-004

Native verification SHALL build `SwiftGodotKit`, run its tests without launching or mutating a live Godot project, and validate the canonical governance metadata for case-sensitive test paths, requirement identifiers, and source mappings.

Acceptance Criteria
- The strict SpecSync check validates the corrected `Tests/` path, `REQ-godot-*` namespace, and `Sources/SwiftGodotKit/` mapping.
- The native Fledge verification lane builds `SwiftGodotKit` and passes its test suite without launching Godot.

## Constraints

- SwiftGodot and the supported Apple platform versions remain as declared by the package.
- Demo execution requires a separately installed Godot runtime.

## Out of Scope

- Changing APIs, dependency revisions, demo assets, releases, engine state, or Pages deployment.
