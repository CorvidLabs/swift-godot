---
change: CHG-0003-complete-swiftgodotkit-source-coverage-public-api-traceability-requirement-acc
artifact: context
---

# Context

The rollout PR already maps the SwiftGodotKit source directory in prose, but released SpecSync 5.0.1 does not count a directory entry as file coverage. The current gate therefore reports 0/43 authored Swift files and a zero coverage threshold even though the product has an active canonical spec. Review also identified missing validated API tables, incomplete acceptance criteria for stable requirements, and governance authorities outside the meaningful-change policy.

This correction is governance-only. It must describe the existing library and demo sources without altering runtime behavior, public APIs, dependency revisions, or Godot project state.
