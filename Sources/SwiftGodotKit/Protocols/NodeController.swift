import SwiftGodot

/// A protocol defining reactive node management with automatic child binding.
///
/// Use `NodeController` to create nodes with declarative child management
/// and automatic signal connections.
///
/// ## Example
/// ```swift
/// class PlayerController: NodeController {
///     typealias NodeType = CharacterBody3D
///     let node = CharacterBody3D()
///
///     var children: [any NodeController] {
///         [HealthBarController(), WeaponController()]
///     }
///
///     func configure() {
///         node.name = "Player"
///     }
/// }
/// ```
public protocol NodeController: AnyObject {
    /// The underlying Godot node type
    associatedtype NodeType: Node

    /// The managed node instance
    var node: NodeType { get }

    /// Child controllers to be automatically added
    var children: [any NodeController] { get }

    /// Configure the node after initialization
    func configure()

    /// Called when all children have been added
    func didAddChildren()
}

public extension NodeController {
    var children: [any NodeController] { [] }
    func configure() {}
    func didAddChildren() {}

    /// Builds the node hierarchy and returns the root node
    @discardableResult
    func build() -> NodeType {
        configure()
        for child in children {
            node.addChild(node: child.buildAny())
        }
        didAddChildren()
        return node
    }

    /// Type-erased build method
    func buildAny() -> Node {
        build()
    }
}

// MARK: - Node Builder DSL

/// Result builder for declarative node hierarchy construction
@resultBuilder
public struct NodeBuilder {
    public static func buildBlock(_ components: any NodeController...) -> [any NodeController] {
        components
    }

    public static func buildOptional(_ component: [any NodeController]?) -> [any NodeController] {
        component ?? []
    }

    public static func buildEither(first component: [any NodeController]) -> [any NodeController] {
        component
    }

    public static func buildEither(second component: [any NodeController]) -> [any NodeController] {
        component
    }

    public static func buildArray(_ components: [[any NodeController]]) -> [any NodeController] {
        components.flatMap { $0 }
    }
}

/// Protocol extension for using the node builder DSL
public extension NodeController {
    /// Creates children using a result builder
    func withChildren(@NodeBuilder _ builder: () -> [any NodeController]) -> Self {
        let childControllers = builder()
        for child in childControllers {
            node.addChild(node: child.buildAny())
        }
        return self
    }
}
