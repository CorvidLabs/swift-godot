// SwiftGodotKit.swift
// Re-export SwiftGodot for seamless usage

@_exported import SwiftGodot

/**
 SwiftGodotKit provides SwiftUI-like declarative patterns for Godot development.

 This library wraps and extends SwiftGodot with:
 - Property wrappers for reactive state management
 - Protocol abstractions for common patterns
 - Async/await helpers for signals and callbacks

 ## Example
 ```swift
 import SwiftGodotKit

 @Godot
 class Player: CharacterBody3D {
     @GodotState var health: Int = 100
     @GodotNode("HealthBar") var healthBar: ProgressBar?

     override func _ready() {
         $healthBar.configure(owner: self)
     }

     override func _process(delta: Double) {
         if $health.changed {
             healthBar?.value = Double(health)
         }
         $health.reset()
     }
 }
 ```
 */
public enum SwiftGodotKit {
    /// Current version of SwiftGodotKit
    public static let version = "0.1.0"
}
