---
change: CHG-0002-correct-godot-governance-path-coverage-canonical-requirement-identifiers-and-s
artifact: testing
---

# Testing

Run `fledge spec check --strict --json` to validate the corrected SpecSync metadata, then run `fledge lanes run verify --json` to build and test SwiftGodotKit without launching a live Godot engine. Confirm the diff contains only governance metadata and lifecycle evidence.
