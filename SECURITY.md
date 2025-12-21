# Security Policy

## Reporting a Vulnerability

**Do not open a public GitHub issue for security vulnerabilities.**

Please report security issues directly to the maintainers with:
- Description of the vulnerability
- Steps to reproduce
- Potential impact
- Any suggested fixes

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 0.1.x   | :white_check_mark: |

## Security Considerations

SwiftGodotKit is a wrapper library for SwiftGodot. Security considerations primarily relate to:

### Thread Safety
- Property wrappers use `@unchecked Sendable` for performance
- Signal handlers execute on Godot's main thread
- Use appropriate synchronization for shared state

### Memory Management
- Node references are weak to prevent retain cycles
- Signal connections are cleaned up on deinit

## Best Practices

1. Validate all external input before processing
2. Use type-safe APIs where available
3. Handle errors appropriately
4. Keep dependencies updated

## Dependencies

This library depends on:
- [SwiftGodot](https://github.com/migueldeicaza/SwiftGodot) - Swift bindings for Godot

Report SwiftGodot security issues to that project directly.
