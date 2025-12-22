import SwiftGodot

// MARK: - Children Sequence

public extension Node {

    /// A lazy sequence of this node's direct children.
    ///
    /// Use this property when you need to iterate over children without
    /// creating an intermediate array. The sequence is evaluated lazily.
    ///
    /// ```swift
    /// for child in node.children {
    ///     print(child.name)
    /// }
    /// ```
    var children: some Sequence<Node> {
        (0..<getChildCount()).lazy.compactMap { [self] in self.getChild(idx: $0) }
    }

    /// An array containing all direct children of this node.
    ///
    /// Unlike ``children``, this property eagerly creates an array,
    /// which is useful when you need to modify children during iteration.
    ///
    /// ```swift
    /// let allChildren = node.childArray
    /// for child in allChildren {
    ///     child.queueFree()  // Safe: iterating over copy
    /// }
    /// ```
    var childArray: [Node] {
        (0..<getChildCount()).compactMap { getChild(idx: $0) }
    }

    /// A lazy sequence of all descendants in depth-first order.
    ///
    /// Traverses the entire subtree rooted at this node, yielding each
    /// descendant exactly once in depth-first order.
    ///
    /// ```swift
    /// for descendant in node.descendants {
    ///     if let enemy = descendant as? Enemy {
    ///         enemy.reset()
    ///     }
    /// }
    /// ```
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

    /// Returns the first child that can be cast to the specified type.
    ///
    /// - Parameter ofType: The type to search for. Defaults to the inferred type.
    /// - Returns: The first matching child, or `nil` if none found.
    ///
    /// ```swift
    /// if let healthBar = node.child(ofType: ProgressBar.self) {
    ///     healthBar.value = 100
    /// }
    /// ```
    func child<T: Node>(ofType: T.Type = T.self) -> T? {
        children.lazy.compactMap { $0 as? T }.first
    }

    /// Returns all children that can be cast to the specified type.
    ///
    /// - Parameter ofType: The type to filter by. Defaults to the inferred type.
    /// - Returns: An array of all matching children.
    ///
    /// ```swift
    /// let buttons: [Button] = panel.children(ofType: Button.self)
    /// buttons.forEach { $0.disabled = true }
    /// ```
    func children<T: Node>(ofType: T.Type = T.self) -> [T] {
        children.compactMap { $0 as? T }
    }

    /// Returns all descendants that can be cast to the specified type.
    ///
    /// Searches the entire subtree in depth-first order.
    ///
    /// - Parameter ofType: The type to filter by. Defaults to the inferred type.
    /// - Returns: An array of all matching descendants.
    ///
    /// ```swift
    /// let allEnemies: [Enemy] = level.descendants(ofType: Enemy.self)
    /// ```
    func descendants<T: Node>(ofType: T.Type = T.self) -> [T] {
        descendants.compactMap { $0 as? T }
    }

    /// Returns the first child matching the given predicate.
    ///
    /// - Parameter predicate: A closure that returns `true` for the desired child.
    /// - Returns: The first matching child, or `nil` if none found.
    func child(where predicate: (Node) -> Bool) -> Node? {
        children.first(where: predicate)
    }

    /// Returns all children matching the given predicate.
    ///
    /// - Parameter predicate: A closure that returns `true` for desired children.
    /// - Returns: An array of all matching children.
    func children(where predicate: (Node) -> Bool) -> [Node] {
        children.filter(predicate)
    }
}

// MARK: - Child Management

public extension Node {

    /// Adds multiple children to this node.
    ///
    /// - Parameter nodes: The nodes to add as children.
    ///
    /// ```swift
    /// container.add(label, button, progressBar)
    /// ```
    func add(_ nodes: Node...) {
        nodes.forEach { addChild(node: $0) }
    }

    /// Adds an array of children to this node.
    ///
    /// - Parameter nodes: An array of nodes to add as children.
    ///
    /// ```swift
    /// let items = createMenuItems()
    /// menu.add(items)
    /// ```
    func add(_ nodes: [Node]) {
        nodes.forEach { addChild(node: $0) }
    }

    /// Removes and frees all children of this node.
    ///
    /// Each child is removed from the tree and queued for deletion.
    /// Children are removed in reverse order to avoid index shifting issues.
    ///
    /// ```swift
    /// container.removeAllChildren()  // Clears all children
    /// ```
    func removeAllChildren() {
        childArray.reversed().forEach {
            removeChild(node: $0)
            $0.queueFree()
        }
    }

    /// Removes and frees children matching the given predicate.
    ///
    /// - Parameter predicate: A closure that returns `true` for children to remove.
    ///
    /// ```swift
    /// // Remove all disabled buttons
    /// container.removeChildren { ($0 as? Button)?.disabled == true }
    /// ```
    func removeChildren(where predicate: (Node) -> Bool) {
        childArray.filter(predicate).forEach {
            removeChild(node: $0)
            $0.queueFree()
        }
    }

    /// Removes and frees all children of the specified type.
    ///
    /// - Parameter ofType: The type of children to remove.
    ///
    /// ```swift
    /// level.removeChildren(ofType: Enemy.self)
    /// ```
    func removeChildren<T: Node>(ofType: T.Type) {
        removeChildren { $0 is T }
    }
}

// MARK: - Ancestry

public extension Node {

    /// A lazy sequence of ancestors from parent to root.
    ///
    /// Traverses up the tree, yielding each ancestor in order.
    ///
    /// ```swift
    /// for ancestor in node.ancestors {
    ///     if let gameManager = ancestor as? GameManager {
    ///         gameManager.handleEvent()
    ///     }
    /// }
    /// ```
    var ancestors: AnySequence<Node> {
        guard let parent = getParent() else { return AnySequence([]) }
        return AnySequence(sequence(first: parent) { $0.getParent() })
    }

    /// Returns the first ancestor of the specified type.
    ///
    /// - Parameter ofType: The type to search for. Defaults to the inferred type.
    /// - Returns: The first matching ancestor, or `nil` if none found.
    ///
    /// ```swift
    /// if let level = enemy.ancestor(ofType: Level.self) {
    ///     level.enemyDefeated()
    /// }
    /// ```
    func ancestor<T: Node>(ofType: T.Type = T.self) -> T? {
        ancestors.lazy.compactMap { $0 as? T }.first
    }

    /// Returns whether this node is an ancestor of another node.
    ///
    /// - Parameter node: The potential descendant.
    /// - Returns: `true` if this node is an ancestor of the given node.
    func isAncestor(of node: Node) -> Bool {
        node.ancestors.contains { $0 === self }
    }

    /// Returns whether this node is a descendant of another node.
    ///
    /// - Parameter node: The potential ancestor.
    /// - Returns: `true` if this node is a descendant of the given node.
    func isDescendant(of node: Node) -> Bool {
        node.isAncestor(of: self)
    }
}

// MARK: - Siblings

public extension Node {

    /// The next sibling in the parent's child list, or `nil` if this is the last child.
    var nextSibling: Node? {
        guard let parent = getParent() else { return nil }
        let next = getIndex() + 1
        return next < parent.getChildCount() ? parent.getChild(idx: next) : nil
    }

    /// The previous sibling in the parent's child list, or `nil` if this is the first child.
    var previousSibling: Node? {
        guard getIndex() > 0 else { return nil }
        return getParent()?.getChild(idx: getIndex() - 1)
    }

    /// An array of all siblings (other children of the same parent).
    var siblings: [Node] {
        getParent()?.childArray.filter { $0 !== self } ?? []
    }
}

// MARK: - Scene Tree

public extension Node {

    /// Whether this node is currently in the scene tree.
    var isInTree: Bool { isInsideTree() }

    /// The scene tree this node belongs to, or `nil` if not in tree.
    var tree: SceneTree? { getTree() }

    /// The root window of the scene tree, or `nil` if not in tree.
    var root: Window? { getTree()?.root }
}

// MARK: - Functional Utilities

public extension Node {

    /// Applies a configuration closure to this node and returns self.
    ///
    /// Enables fluent configuration patterns.
    ///
    /// - Parameter config: A closure that configures this node.
    /// - Returns: This node, for chaining.
    ///
    /// ```swift
    /// let label = Label().configure {
    ///     $0.text = "Hello"
    ///     $0.horizontalAlignment = .center
    /// }
    /// ```
    @discardableResult
    func configure(_ config: (Self) -> Void) -> Self {
        config(self)
        return self
    }

    /// Maps a transform over all children.
    ///
    /// - Parameter transform: A closure that transforms each child.
    /// - Returns: An array of transformed results.
    func mapChildren<T>(_ transform: (Node) -> T) -> [T] {
        children.map(transform)
    }

    /// Executes an action for each child.
    ///
    /// - Parameter action: A closure to execute for each child.
    func forEachChild(_ action: (Node) -> Void) {
        children.forEach(action)
    }
}
