import SwiftGodot

// MARK: - Children Sequence

public extension Node {

    /// Lazy sequence of direct children.
    var children: some Sequence<Node> {
        (0..<getChildCount()).lazy.compactMap { [self] in self.getChild(idx: $0) }
    }

    /// Array of direct children (eager).
    var childArray: [Node] {
        (0..<getChildCount()).compactMap { getChild(idx: $0) }
    }

    /// Lazy sequence of all descendants (depth-first).
    var descendants: some Sequence<Node> {
        sequence(state: childArray as [Node]) { stack -> Node? in
            guard let node = stack.popLast() else { return nil }
            stack.append(contentsOf: node.childArray.reversed())
            return node
        }
    }
}

// MARK: - Type-Safe Queries

public extension Node {

    /// First child of type.
    func child<T: Node>(ofType: T.Type = T.self) -> T? {
        children.lazy.compactMap { $0 as? T }.first
    }

    /// All children of type.
    func children<T: Node>(ofType: T.Type = T.self) -> [T] {
        children.compactMap { $0 as? T }
    }

    /// All descendants of type (depth-first).
    func descendants<T: Node>(ofType: T.Type = T.self) -> [T] {
        descendants.compactMap { $0 as? T }
    }

    /// First child matching predicate.
    func child(where predicate: (Node) -> Bool) -> Node? {
        children.first(where: predicate)
    }

    /// All children matching predicate.
    func children(where predicate: (Node) -> Bool) -> [Node] {
        children.filter(predicate)
    }
}

// MARK: - Child Management

public extension Node {

    /// Add multiple children.
    func add(_ nodes: Node...) {
        nodes.forEach { addChild(node: $0) }
    }

    /// Add multiple children from array.
    func add(_ nodes: [Node]) {
        nodes.forEach { addChild(node: $0) }
    }

    /// Remove and free all children.
    func removeAllChildren() {
        childArray.reversed().forEach {
            removeChild(node: $0)
            $0.queueFree()
        }
    }

    /// Remove children matching predicate.
    func removeChildren(where predicate: (Node) -> Bool) {
        childArray.filter(predicate).forEach {
            removeChild(node: $0)
            $0.queueFree()
        }
    }

    /// Remove children of type.
    func removeChildren<T: Node>(ofType: T.Type) {
        removeChildren { $0 is T }
    }
}

// MARK: - Ancestry

public extension Node {

    /// Lazy sequence of ancestors (parent to root).
    var ancestors: AnySequence<Node> {
        guard let parent = getParent() else { return AnySequence([]) }
        return AnySequence(sequence(first: parent) { $0.getParent() })
    }

    /// First ancestor of type.
    func ancestor<T: Node>(ofType: T.Type = T.self) -> T? {
        ancestors.lazy.compactMap { $0 as? T }.first
    }

    /// Check if node is ancestor of another.
    func isAncestor(of node: Node) -> Bool {
        node.ancestors.contains { $0 === self }
    }

    /// Check if node is descendant of another.
    func isDescendant(of node: Node) -> Bool {
        node.isAncestor(of: self)
    }
}

// MARK: - Siblings

public extension Node {

    var nextSibling: Node? {
        guard let parent = getParent() else { return nil }
        let next = getIndex() + 1
        return next < parent.getChildCount() ? parent.getChild(idx: next) : nil
    }

    var previousSibling: Node? {
        guard getIndex() > 0 else { return nil }
        return getParent()?.getChild(idx: getIndex() - 1)
    }

    var siblings: [Node] {
        getParent()?.childArray.filter { $0 !== self } ?? []
    }
}

// MARK: - Scene Tree

public extension Node {

    var isInTree: Bool { isInsideTree() }

    var tree: SceneTree? { getTree() }

    var root: Window? { getTree()?.root }
}

// MARK: - Functional Utilities

public extension Node {

    /// Apply configuration to self.
    @discardableResult
    func configure(_ config: (Self) -> Void) -> Self {
        config(self)
        return self
    }

    /// Map over children.
    func mapChildren<T>(_ transform: (Node) -> T) -> [T] {
        children.map(transform)
    }

    /// Execute action for each child.
    func forEachChild(_ action: (Node) -> Void) {
        children.forEach(action)
    }
}
