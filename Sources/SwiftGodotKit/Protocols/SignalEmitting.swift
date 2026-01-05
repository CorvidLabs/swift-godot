import SwiftGodot

/**
 A protocol for types that can emit Godot signals.

 ## Example
 ```swift
 @Godot
 class Player: CharacterBody3D, SignalEmitting {
     static let healthChanged = Signal1<Int>("health_changed")
     static let died = Signal0("died")

     func takeDamage(_ amount: Int) {
         health -= amount
         emitSignal(Self.healthChanged.name, Variant(health))
         if health <= 0 {
             emitSignal(Self.died.name)
         }
     }
 }
 ```
 */
public protocol SignalEmitting {
    /// The Godot object that owns the signals
    var signalOwner: Object { get }
}

public extension SignalEmitting where Self: Object {
    var signalOwner: Object { self }
}

// MARK: - Signal Emission Helpers

public extension SignalEmitting {
    /// Emit a signal with no arguments
    func emit(_ signal: Signal0) {
        signalOwner.emitSignal(signal.name)
    }

    /// Emit a signal by name with no arguments
    func emit(_ signalName: StringName) {
        signalOwner.emitSignal(signalName)
    }

    /// Emit a signal by name with one variant argument
    func emit(_ signalName: StringName, _ arg: Variant) {
        signalOwner.emitSignal(signalName, arg)
    }

    /// Emit a signal by name with two variant arguments
    func emit(_ signalName: StringName, _ arg1: Variant, _ arg2: Variant) {
        signalOwner.emitSignal(signalName, arg1, arg2)
    }

    /// Emit a signal by name with three variant arguments
    func emit(_ signalName: StringName, _ arg1: Variant, _ arg2: Variant, _ arg3: Variant) {
        signalOwner.emitSignal(signalName, arg1, arg2, arg3)
    }
}
