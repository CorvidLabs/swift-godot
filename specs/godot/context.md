---
spec: godot.spec.md
---

## Context

The package is a pre-1.0 macOS-focused SwiftGodot extension with a public library, a dynamic demo target, scene assets, a Godot project, macOS CI, and independent DocC Pages publication.

## Related Modules

- SwiftGodot provides the engine bindings; CorvidLabs creative packages support the demo target.

## Design Decisions

- Preserve the immutable SwiftGodot revision and macOS runner.
- Verify the library and unit tests without launching a live Godot editor.
- Keep DocC Pages outside Trust-managed Atlas.
