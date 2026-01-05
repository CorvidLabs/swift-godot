import SwiftGodot

/// Strategy for looking up nodes in the scene tree.
public enum NodeLookup: Sendable, Equatable {
    /// Look up by relative path from owner
    case path(String)
    /// Look up by unique name (% prefix in scene tree)
    case unique(String)
    /// Look up first node in group
    case group(String)
}

/**
 A property wrapper for declarative, type-safe node references.

 `@GodotNode` provides lazy lookup with automatic caching.
 Configure the owner in `_ready()` to enable lookups.

 ```swift
 @Godot
 class GameUI: Control {
     @GodotNode("HealthBar") var healthBar: ProgressBar?
     @GodotNode(.unique("Player")) var player: CharacterBody3D?

     override func _ready() {
         $healthBar.configure(owner: self)
         $player.configure(owner: self)
     }
 }
 ```
 */
@propertyWrapper
public struct GodotNode<NodeType: Node> {

    private let storage: NodeStorage<NodeType>

    public var wrappedValue: NodeType? {
        get { storage.resolve() }
    }

    public var projectedValue: NodeStorage<NodeType> {
        storage
    }

    public init(_ path: String) {
        self.storage = NodeStorage(lookup: .path(path))
    }

    public init(_ lookup: NodeLookup) {
        self.storage = NodeStorage(lookup: lookup)
    }
}

/// Thread-safe storage for node references.
public final class NodeStorage<NodeType: Node>: @unchecked Sendable {

    public let lookup: NodeLookup

    private weak var owner: Node?
    private var cached: NodeType?
    private var isConfigured = false

    init(lookup: NodeLookup) {
        self.lookup = lookup
    }

    /// Configure with the owning node. Call in `_ready()`.
    public func configure(owner: Node) {
        self.owner = owner
        self.cached = nil
        self.isConfigured = true
    }

    /// Clear cached reference, forcing re-lookup on next access.
    public func invalidate() {
        cached = nil
    }

    /// Whether this node reference has been configured.
    public var configured: Bool { isConfigured }

    /// Resolve the node reference.
    func resolve() -> NodeType? {
        if let cached { return cached }
        guard let owner else { return nil }

        let node: NodeType? = {
            switch lookup {
            case .path(let path):
                return owner.getNodeOrNull(path: NodePath(path)) as? NodeType

            case .unique(let name):
                return owner.getNodeOrNull(path: NodePath("%\(name)")) as? NodeType

            case .group(let name):
                return owner.getTree()?
                    .getFirstNodeInGroup(StringName(name)) as? NodeType
            }
        }()

        cached = node
        return node
    }
}

// MARK: - Static Factories

public extension GodotNode {

    static func path(_ path: String) -> GodotNode {
        GodotNode(.path(path))
    }

    static func unique(_ name: String) -> GodotNode {
        GodotNode(.unique(name))
    }

    static func group(_ name: String) -> GodotNode {
        GodotNode(.group(name))
    }
}
