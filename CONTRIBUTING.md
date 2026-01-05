# Contributing to SwiftGodotKit

Thank you for your interest in contributing to SwiftGodotKit!

## How to Contribute

### Reporting Issues

If you find a bug or have a feature request:

1. Check if the issue already exists in [GitHub Issues](https://github.com/CorvidLabs/swift-godot/issues)
2. If not, create a new issue with:
   - A clear, descriptive title
   - Steps to reproduce (for bugs)
   - Expected vs. actual behavior
   - Swift version, Godot version, and platform information

### Submitting Pull Requests

1. **Fork the repository** and create your branch from `main`:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes**:
   - Write clear, concise code following Swift conventions
   - Add tests for new functionality
   - Update documentation as needed

3. **Ensure tests pass**:
   ```bash
   swift build
   swift test
   ```

4. **Build the demo** to verify Godot integration:
   ```bash
   ./scripts/build-demo.sh
   ```

5. **Commit your changes**:
   - Use clear, descriptive commit messages
   - Reference any related issues

6. **Push to your fork** and submit a pull request

## Code Style

Follow the CorvidLabs Swift Conventions:

- **Explicit access control** - Add `public`/`internal`/`private` to all declarations
- **K&R brace style** - Opening brace on same line: `func foo() {`
- **No force unwrap** - Never use `!`, `try!`, or `as!`
- **async/await only** - No completion handlers
- **Sendable conformance** - All types crossing concurrency boundaries
- **Descriptive generics** - Use `Value`, `Output`, not `T`, `U`
- **4-space indentation** - No tabs
- **120 character line limit**

### Documentation

- Add documentation comments for public APIs
- Use `///` for documentation
- Include code examples where helpful

```swift
/// Returns the first child matching the given type.
///
/// - Parameter ofType: The type to search for.
/// - Returns: The first matching child, or `nil` if none found.
///
/// ```swift
/// if let healthBar = node.child(ofType: ProgressBar.self) {
///     healthBar.value = 100
/// }
/// ```
func child<T: Node>(ofType: T.Type = T.self) -> T?
```

## Testing

- Write tests for new features
- Ensure existing tests pass
- Test Godot integration with the demo project

```bash
# Run unit tests
swift test

# Build and run demo in Godot
./scripts/build-demo.sh
open -a Godot GodotProject/project.godot
```

## Documentation

- Update README.md if adding major features
- Add code examples for new functionality
- Document any breaking changes in CHANGELOG.md

## Questions?

Feel free to open an issue for questions or discussion!

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
