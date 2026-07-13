---
change: CHG-0002-correct-godot-governance-path-coverage-canonical-requirement-identifiers-and-s
artifact: context
---

# Context

The rollout review found three governance metadata gaps. The case-sensitive meaningful-path list covers `Sources/` but not `Tests/`; the stable requirement IDs do not use the registered `godot` module prefix; and the canonical spec maps only `Package.swift` instead of the library sources it describes. Correcting these records changes no Swift source, public API, dependency, demo asset, or runtime behavior.
