---
change: CHG-0003-complete-swiftgodotkit-source-coverage-public-api-traceability-requirement-acc
artifact: testing
---

# Testing

- `specsync check --strict --force --require-coverage 100` must report 43/43 files and 11,114/11,114 LOC with no undocumented exports.
- `specsync lifecycle enforce --strict --require-coverage 100` must validate the active canonical spec at full coverage without circularly requiring the verification evidence it is producing.
- `specsync agents status` must report Claude, Cursor, Codex, and Gemini installed.
- `fledge lanes run verify` must enforce the canonical lifecycle, build `SwiftGodotKit`, and pass the native test suite without launching Godot; the unified Trust action remains the outer change-evidence enforcement boundary.
- `REQ-godot-001` is evidenced by `Tests/SwiftGodotKitTests/PropertyWrapperTests.swift` and the successful library build.
- `REQ-godot-002` is evidenced by `Tests/SwiftGodotKitTests/AsyncTests.swift` and the successful library build.
- `REQ-godot-003` is evidenced by `Tests/SwiftGodotKitTests/ProtocolTests.swift` and the successful library build.
- `fledge trust doctor` and `fledge trust verify` must pass under the committed standard profile with progressive provenance.
- The exact PR head must pass hosted Trust and CodeQL before the draft is promoted or merged.
