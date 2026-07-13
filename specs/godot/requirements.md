---
spec: godot.spec.md
---

## Requirements

- **REQ-godot-001** (stable): Property wrappers shall preserve existing reactive state, typed node lookup, and declarative signal behavior.
- **REQ-godot-002** (stable): Async signal and frame utilities shall preserve timeout, cancellation, and Swift concurrency behavior.
- **REQ-godot-003** (stable): Controller protocols and node/object extensions shall retain their documented typed lifecycle and traversal APIs.

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
