## MODIFIED

### REQUIREMENT REQ-godot-004

Native verification SHALL build `SwiftGodotKit`, run its tests without launching or mutating a live Godot project, and validate the canonical governance metadata for case-sensitive test paths, requirement identifiers, and source mappings.

Acceptance Criteria
- The strict SpecSync check validates the corrected `Tests/` path, `REQ-godot-*` namespace, and `Sources/SwiftGodotKit/` mapping.
- The native Fledge verification lane builds `SwiftGodotKit` and passes its test suite without launching Godot.

### SPEC SECTION Purpose

Provide the existing declarative Swift extensions, property wrappers, asynchronous signal utilities, node protocols, and extensions for Godot 4.4 development, plus the independently built demonstration target. The canonical source mapping covers the Swift package manifest and the SwiftGodotKit library sources without changing runtime behavior.
