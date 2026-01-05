import SwiftGodot

/**
 A protocol that defines the lifecycle and management of a Godot scene.

 Conform to this protocol to create type-safe scene controllers with
 automatic resource management and lifecycle hooks.

 ## Example
 ```swift
 class GameScene: SceneController {
     typealias RootNode = Node3D
     var rootNode: Node3D?

     func sceneDidBecomeReady() {
         setupGame()
     }

     func sceneDidProcess(delta: Double) {
         updateGameLogic(delta: delta)
     }
 }
 ```
 */
public protocol SceneController: AnyObject {
    /// The root node type for this scene
    associatedtype RootNode: Node

    /// The scene's root node, available after the scene is loaded
    var rootNode: RootNode? { get set }

    /// Called when the scene enters the tree
    func sceneDidEnterTree()

    /// Called when the scene is ready
    func sceneDidBecomeReady()

    /// Called every frame with delta time
    func sceneDidProcess(delta: Double)

    /// Called every physics frame with delta time
    func sceneDidPhysicsProcess(delta: Double)

    /// Called when the scene exits the tree
    func sceneWillExitTree()
}

/// Default implementations for SceneController
public extension SceneController {
    func sceneDidEnterTree() {}
    func sceneDidBecomeReady() {}
    func sceneDidProcess(delta: Double) {}
    func sceneDidPhysicsProcess(delta: Double) {}
    func sceneWillExitTree() {}
}

/// Extension for loading scenes
public extension SceneController {
    /// Loads a scene from a resource path
    static func load(from path: String) -> RootNode? {
        guard let scene = GD.load(path: path) as? PackedScene else {
            return nil
        }
        return scene.instantiate() as? RootNode
    }

    /// Instantiates the scene and sets up the controller
    func instantiate(from path: String) -> Bool {
        guard let node = Self.load(from: path) else {
            return false
        }
        rootNode = node
        return true
    }
}
