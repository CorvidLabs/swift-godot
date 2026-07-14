## MODIFIED

### REQUIREMENT REQ-godot-001

Property wrappers SHALL preserve existing reactive state, typed node lookup, and declarative signal behavior.

Acceptance Criteria
- `GodotState`, `GodotNode`, and `GodotSignal` remain present in the validated public API inventory.
- `PropertyWrapperTests` passes its state initialization, mutation, change detection, reset, and two-way binding scenarios without launching a live Godot project.

Verification
- `fledge lanes run verify`

### REQUIREMENT REQ-godot-002

Async signal and frame utilities SHALL preserve timeout, cancellation, and Swift concurrency behavior.

Acceptance Criteria
- `AsyncSignal`, `SignalAwaiter`, and the Godot task APIs remain present in the validated public API inventory.
- The package build type-checks the async signal and task APIs, while `AsyncTests` validates the signal error cases and Sendable boxed state used by the async helpers.

Verification
- `fledge lanes run verify`

### REQUIREMENT REQ-godot-003

Controller protocols and node/object extensions SHALL retain their documented typed lifecycle and traversal APIs.

Acceptance Criteria
- `NodeController`, `SceneController`, `SignalEmitting`, and `SignalReceiving` remain present in the validated public API inventory.
- The package build type-checks the controller, signal, and extension APIs, while `ProtocolTests` validates the `NodeBuilder` empty-block contract without requiring Godot runtime state.

Verification
- `fledge lanes run verify`

### SPEC SECTION Public API

The `SwiftGodotKit` product re-exports SwiftGodot and exposes reactive state, node lookup and signal wrappers, async signal and frame utilities, controller and signal protocols, and node/object extensions. The dynamic demo product and Godot project remain examples rather than additional library guarantees.

#### Exported Symbols

| Symbol | File | Existing contract |
|---|---|---|
| `SwiftColor` | `Sources/Demo/SwiftColorAlias.swift` | Compatibility alias exposing the SwiftColor module to the demo target. |
| `AsyncSignal` | `Sources/SwiftGodotKit/Async/AsyncSignal.swift` | AsyncSequence-based Godot signal delivery API. |
| `AsyncIterator` | `Sources/SwiftGodotKit/Async/AsyncSignal.swift` | AsyncSequence-based Godot signal delivery API. |
| `makeAsyncIterator` | `Sources/SwiftGodotKit/Async/AsyncSignal.swift` | AsyncSequence-based Godot signal delivery API. |
| `AsyncSignalIterator` | `Sources/SwiftGodotKit/Async/AsyncSignal.swift` | AsyncSequence-based Godot signal delivery API. |
| `next` | `Sources/SwiftGodotKit/Async/AsyncSignal.swift` | AsyncSequence-based Godot signal delivery API. |
| `init` | `Sources/SwiftGodotKit/Async/AsyncSignal.swift` | AsyncSequence-based Godot signal delivery API. |
| `signals` | `Sources/SwiftGodotKit/Async/AsyncSignal.swift` | AsyncSequence-based Godot signal delivery API. |
| `GodotTask` | `Sources/SwiftGodotKit/Async/GodotTask.swift` | Godot frame-aware task, wait, and cancellation API. |
| `value` | `Sources/SwiftGodotKit/Async/GodotTask.swift` | Godot frame-aware task, wait, and cancellation API. |
| `cancel` | `Sources/SwiftGodotKit/Async/GodotTask.swift` | Godot frame-aware task, wait, and cancellation API. |
| `isCancelled` | `Sources/SwiftGodotKit/Async/GodotTask.swift` | Godot frame-aware task, wait, and cancellation API. |
| `withGodotTaskGroup` | `Sources/SwiftGodotKit/Async/GodotTask.swift` | Godot frame-aware task, wait, and cancellation API. |
| `withThrowingGodotTaskGroup` | `Sources/SwiftGodotKit/Async/GodotTask.swift` | Godot frame-aware task, wait, and cancellation API. |
| `nextFrame` | `Sources/SwiftGodotKit/Async/GodotTask.swift` | Godot frame-aware task, wait, and cancellation API. |
| `nextPhysicsFrame` | `Sources/SwiftGodotKit/Async/GodotTask.swift` | Godot frame-aware task, wait, and cancellation API. |
| `frames` | `Sources/SwiftGodotKit/Async/GodotTask.swift` | Godot frame-aware task, wait, and cancellation API. |
| `wait` | `Sources/SwiftGodotKit/Async/GodotTask.swift` | Godot frame-aware task, wait, and cancellation API. |
| `waitGodot` | `Sources/SwiftGodotKit/Async/GodotTask.swift` | Godot frame-aware task, wait, and cancellation API. |
| `detached` | `Sources/SwiftGodotKit/Async/GodotTask.swift` | Godot frame-aware task, wait, and cancellation API. |
| `SignalAwaiter` | `Sources/SwiftGodotKit/Async/SignalAwaiter.swift` | Signal waiting, timeout, disconnection, and cancellation API. |
| `SignalAwaiterError` | `Sources/SwiftGodotKit/Async/SignalAwaiter.swift` | Signal waiting, timeout, disconnection, and cancellation API. |
| `awaitSignal` | `Sources/SwiftGodotKit/Async/SignalAwaiter.swift` | Signal waiting, timeout, disconnection, and cancellation API. |
| `timeout` | `Sources/SwiftGodotKit/Async/SignalAwaiter.swift` | Signal waiting, timeout, disconnection, and cancellation API. |
| `disconnected` | `Sources/SwiftGodotKit/Async/SignalAwaiter.swift` | Signal waiting, timeout, disconnection, and cancellation API. |
| `cancelled` | `Sources/SwiftGodotKit/Async/SignalAwaiter.swift` | Signal waiting, timeout, disconnection, and cancellation API. |
| `children` | `Sources/SwiftGodotKit/Extensions/Node+Extensions.swift` | Node hierarchy traversal, mutation, and controller-configuration API. |
| `childArray` | `Sources/SwiftGodotKit/Extensions/Node+Extensions.swift` | Node hierarchy traversal, mutation, and controller-configuration API. |
| `descendants` | `Sources/SwiftGodotKit/Extensions/Node+Extensions.swift` | Node hierarchy traversal, mutation, and controller-configuration API. |
| `child` | `Sources/SwiftGodotKit/Extensions/Node+Extensions.swift` | Node hierarchy traversal, mutation, and controller-configuration API. |
| `add` | `Sources/SwiftGodotKit/Extensions/Node+Extensions.swift` | Node hierarchy traversal, mutation, and controller-configuration API. |
| `removeAllChildren` | `Sources/SwiftGodotKit/Extensions/Node+Extensions.swift` | Node hierarchy traversal, mutation, and controller-configuration API. |
| `removeChildren` | `Sources/SwiftGodotKit/Extensions/Node+Extensions.swift` | Node hierarchy traversal, mutation, and controller-configuration API. |
| `ancestors` | `Sources/SwiftGodotKit/Extensions/Node+Extensions.swift` | Node hierarchy traversal, mutation, and controller-configuration API. |
| `ancestor` | `Sources/SwiftGodotKit/Extensions/Node+Extensions.swift` | Node hierarchy traversal, mutation, and controller-configuration API. |
| `isAncestor` | `Sources/SwiftGodotKit/Extensions/Node+Extensions.swift` | Node hierarchy traversal, mutation, and controller-configuration API. |
| `isDescendant` | `Sources/SwiftGodotKit/Extensions/Node+Extensions.swift` | Node hierarchy traversal, mutation, and controller-configuration API. |
| `nextSibling` | `Sources/SwiftGodotKit/Extensions/Node+Extensions.swift` | Node hierarchy traversal, mutation, and controller-configuration API. |
| `previousSibling` | `Sources/SwiftGodotKit/Extensions/Node+Extensions.swift` | Node hierarchy traversal, mutation, and controller-configuration API. |
| `siblings` | `Sources/SwiftGodotKit/Extensions/Node+Extensions.swift` | Node hierarchy traversal, mutation, and controller-configuration API. |
| `isInTree` | `Sources/SwiftGodotKit/Extensions/Node+Extensions.swift` | Node hierarchy traversal, mutation, and controller-configuration API. |
| `tree` | `Sources/SwiftGodotKit/Extensions/Node+Extensions.swift` | Node hierarchy traversal, mutation, and controller-configuration API. |
| `root` | `Sources/SwiftGodotKit/Extensions/Node+Extensions.swift` | Node hierarchy traversal, mutation, and controller-configuration API. |
| `configure` | `Sources/SwiftGodotKit/Extensions/Node+Extensions.swift` | Node hierarchy traversal, mutation, and controller-configuration API. |
| `mapChildren` | `Sources/SwiftGodotKit/Extensions/Node+Extensions.swift` | Node hierarchy traversal, mutation, and controller-configuration API. |
| `forEachChild` | `Sources/SwiftGodotKit/Extensions/Node+Extensions.swift` | Node hierarchy traversal, mutation, and controller-configuration API. |
| `on` | `Sources/SwiftGodotKit/Extensions/Object+Extensions.swift` | Object signal, metadata, identity, and connection extension API. |
| `once` | `Sources/SwiftGodotKit/Extensions/Object+Extensions.swift` | Object signal, metadata, identity, and connection extension API. |
| `onDeferred` | `Sources/SwiftGodotKit/Extensions/Object+Extensions.swift` | Object signal, metadata, identity, and connection extension API. |
| `has` | `Sources/SwiftGodotKit/Extensions/Object+Extensions.swift` | Object signal, metadata, identity, and connection extension API. |
| `hasConnections` | `Sources/SwiftGodotKit/Extensions/Object+Extensions.swift` | Object signal, metadata, identity, and connection extension API. |
| `connectionCount` | `Sources/SwiftGodotKit/Extensions/Object+Extensions.swift` | Object signal, metadata, identity, and connection extension API. |
| `instanceID` | `Sources/SwiftGodotKit/Extensions/Object+Extensions.swift` | Object signal, metadata, identity, and connection extension API. |
| `subscript` | `Sources/SwiftGodotKit/Extensions/Object+Extensions.swift` | Object signal, metadata, identity, and connection extension API. |
| `hasMeta` | `Sources/SwiftGodotKit/Extensions/Object+Extensions.swift` | Object signal, metadata, identity, and connection extension API. |
| `emit` | `Sources/SwiftGodotKit/Extensions/Object+Extensions.swift` | Object signal, metadata, identity, and connection extension API. |
| `GodotContext` | `Sources/SwiftGodotKit/Internal/GodotContext.swift` | Engine context, frame, scene, logging, pause, and shutdown API. |
| `isMainThread` | `Sources/SwiftGodotKit/Internal/GodotContext.swift` | Engine context, frame, scene, logging, pause, and shutdown API. |
| `onMain` | `Sources/SwiftGodotKit/Internal/GodotContext.swift` | Engine context, frame, scene, logging, pause, and shutdown API. |
| `isRunning` | `Sources/SwiftGodotKit/Internal/GodotContext.swift` | Engine context, frame, scene, logging, pause, and shutdown API. |
| `isEditor` | `Sources/SwiftGodotKit/Internal/GodotContext.swift` | Engine context, frame, scene, logging, pause, and shutdown API. |
| `physicsTPS` | `Sources/SwiftGodotKit/Internal/GodotContext.swift` | Engine context, frame, scene, logging, pause, and shutdown API. |
| `targetFPS` | `Sources/SwiftGodotKit/Internal/GodotContext.swift` | Engine context, frame, scene, logging, pause, and shutdown API. |
| `fps` | `Sources/SwiftGodotKit/Internal/GodotContext.swift` | Engine context, frame, scene, logging, pause, and shutdown API. |
| `uptime` | `Sources/SwiftGodotKit/Internal/GodotContext.swift` | Engine context, frame, scene, logging, pause, and shutdown API. |
| `frame` | `Sources/SwiftGodotKit/Internal/GodotContext.swift` | Engine context, frame, scene, logging, pause, and shutdown API. |
| `physicsFrame` | `Sources/SwiftGodotKit/Internal/GodotContext.swift` | Engine context, frame, scene, logging, pause, and shutdown API. |
| `afterFrame` | `Sources/SwiftGodotKit/Internal/GodotContext.swift` | Engine context, frame, scene, logging, pause, and shutdown API. |
| `afterPhysicsFrame` | `Sources/SwiftGodotKit/Internal/GodotContext.swift` | Engine context, frame, scene, logging, pause, and shutdown API. |
| `log` | `Sources/SwiftGodotKit/Internal/GodotContext.swift` | Engine context, frame, scene, logging, pause, and shutdown API. |
| `warn` | `Sources/SwiftGodotKit/Internal/GodotContext.swift` | Engine context, frame, scene, logging, pause, and shutdown API. |
| `error` | `Sources/SwiftGodotKit/Internal/GodotContext.swift` | Engine context, frame, scene, logging, pause, and shutdown API. |
| `currentScene` | `Sources/SwiftGodotKit/Internal/GodotContext.swift` | Engine context, frame, scene, logging, pause, and shutdown API. |
| `pause` | `Sources/SwiftGodotKit/Internal/GodotContext.swift` | Engine context, frame, scene, logging, pause, and shutdown API. |
| `resume` | `Sources/SwiftGodotKit/Internal/GodotContext.swift` | Engine context, frame, scene, logging, pause, and shutdown API. |
| `isPaused` | `Sources/SwiftGodotKit/Internal/GodotContext.swift` | Engine context, frame, scene, logging, pause, and shutdown API. |
| `quit` | `Sources/SwiftGodotKit/Internal/GodotContext.swift` | Engine context, frame, scene, logging, pause, and shutdown API. |
| `Box` | `Sources/SwiftGodotKit/Internal/SendableBox.swift` | Sendable boxed-state storage and collection or scalar convenience API. |
| `wrappedValue` | `Sources/SwiftGodotKit/Internal/SendableBox.swift` | Sendable boxed-state storage and collection or scalar convenience API. |
| `projectedValue` | `Sources/SwiftGodotKit/Internal/SendableBox.swift` | Sendable boxed-state storage and collection or scalar convenience API. |
| `modify` | `Sources/SwiftGodotKit/Internal/SendableBox.swift` | Sendable boxed-state storage and collection or scalar convenience API. |
| `replace` | `Sources/SwiftGodotKit/Internal/SendableBox.swift` | Sendable boxed-state storage and collection or scalar convenience API. |
| `==` | `Sources/SwiftGodotKit/Internal/SendableBox.swift` | Sendable boxed-state storage and collection or scalar convenience API. |
| `hash` | `Sources/SwiftGodotKit/Internal/SendableBox.swift` | Sendable boxed-state storage and collection or scalar convenience API. |
| `OptionalBox` | `Sources/SwiftGodotKit/Internal/SendableBox.swift` | Sendable boxed-state storage and collection or scalar convenience API. |
| `ArrayBox` | `Sources/SwiftGodotKit/Internal/SendableBox.swift` | Sendable boxed-state storage and collection or scalar convenience API. |
| `DictBox` | `Sources/SwiftGodotKit/Internal/SendableBox.swift` | Sendable boxed-state storage and collection or scalar convenience API. |
| `+=` | `Sources/SwiftGodotKit/Internal/SendableBox.swift` | Sendable boxed-state storage and collection or scalar convenience API. |
| `-=` | `Sources/SwiftGodotKit/Internal/SendableBox.swift` | Sendable boxed-state storage and collection or scalar convenience API. |
| `*=` | `Sources/SwiftGodotKit/Internal/SendableBox.swift` | Sendable boxed-state storage and collection or scalar convenience API. |
| `increment` | `Sources/SwiftGodotKit/Internal/SendableBox.swift` | Sendable boxed-state storage and collection or scalar convenience API. |
| `decrement` | `Sources/SwiftGodotKit/Internal/SendableBox.swift` | Sendable boxed-state storage and collection or scalar convenience API. |
| `toggle` | `Sources/SwiftGodotKit/Internal/SendableBox.swift` | Sendable boxed-state storage and collection or scalar convenience API. |
| `append` | `Sources/SwiftGodotKit/Internal/SendableBox.swift` | Sendable boxed-state storage and collection or scalar convenience API. |
| `removeAll` | `Sources/SwiftGodotKit/Internal/SendableBox.swift` | Sendable boxed-state storage and collection or scalar convenience API. |
| `NodeLookup` | `Sources/SwiftGodotKit/PropertyWrappers/GodotNode.swift` | Typed Godot node lookup property-wrapper and storage API. |
| `GodotNode` | `Sources/SwiftGodotKit/PropertyWrappers/GodotNode.swift` | Typed Godot node lookup property-wrapper and storage API. |
| `NodeStorage` | `Sources/SwiftGodotKit/PropertyWrappers/GodotNode.swift` | Typed Godot node lookup property-wrapper and storage API. |
| `lookup` | `Sources/SwiftGodotKit/PropertyWrappers/GodotNode.swift` | Typed Godot node lookup property-wrapper and storage API. |
| `invalidate` | `Sources/SwiftGodotKit/PropertyWrappers/GodotNode.swift` | Typed Godot node lookup property-wrapper and storage API. |
| `configured` | `Sources/SwiftGodotKit/PropertyWrappers/GodotNode.swift` | Typed Godot node lookup property-wrapper and storage API. |
| `path` | `Sources/SwiftGodotKit/PropertyWrappers/GodotNode.swift` | Typed Godot node lookup property-wrapper and storage API. |
| `unique` | `Sources/SwiftGodotKit/PropertyWrappers/GodotNode.swift` | Typed Godot node lookup property-wrapper and storage API. |
| `group` | `Sources/SwiftGodotKit/PropertyWrappers/GodotNode.swift` | Typed Godot node lookup property-wrapper and storage API. |
| `SignalType` | `Sources/SwiftGodotKit/PropertyWrappers/GodotSignal.swift` | Typed signal declaration, binding, handler, and connection API. |
| `Signal0` | `Sources/SwiftGodotKit/PropertyWrappers/GodotSignal.swift` | Typed signal declaration, binding, handler, and connection API. |
| `name` | `Sources/SwiftGodotKit/PropertyWrappers/GodotSignal.swift` | Typed signal declaration, binding, handler, and connection API. |
| `Signal1` | `Sources/SwiftGodotKit/PropertyWrappers/GodotSignal.swift` | Typed signal declaration, binding, handler, and connection API. |
| `Signal2` | `Sources/SwiftGodotKit/PropertyWrappers/GodotSignal.swift` | Typed signal declaration, binding, handler, and connection API. |
| `Signal3` | `Sources/SwiftGodotKit/PropertyWrappers/GodotSignal.swift` | Typed signal declaration, binding, handler, and connection API. |
| `GodotSignal` | `Sources/SwiftGodotKit/PropertyWrappers/GodotSignal.swift` | Typed signal declaration, binding, handler, and connection API. |
| `SignalStorage` | `Sources/SwiftGodotKit/PropertyWrappers/GodotSignal.swift` | Typed signal declaration, binding, handler, and connection API. |
| `signalName` | `Sources/SwiftGodotKit/PropertyWrappers/GodotSignal.swift` | Typed signal declaration, binding, handler, and connection API. |
| `handler` | `Sources/SwiftGodotKit/PropertyWrappers/GodotSignal.swift` | Typed signal declaration, binding, handler, and connection API. |
| `bind` | `Sources/SwiftGodotKit/PropertyWrappers/GodotSignal.swift` | Typed signal declaration, binding, handler, and connection API. |
| `disconnect` | `Sources/SwiftGodotKit/PropertyWrappers/GodotSignal.swift` | Typed signal declaration, binding, handler, and connection API. |
| `isConnected` | `Sources/SwiftGodotKit/PropertyWrappers/GodotSignal.swift` | Typed signal declaration, binding, handler, and connection API. |
| `GodotState` | `Sources/SwiftGodotKit/PropertyWrappers/GodotState.swift` | Reactive Sendable state, change tracking, and binding API. |
| `StateBox` | `Sources/SwiftGodotKit/PropertyWrappers/GodotState.swift` | Reactive Sendable state, change tracking, and binding API. |
| `changed` | `Sources/SwiftGodotKit/PropertyWrappers/GodotState.swift` | Reactive Sendable state, change tracking, and binding API. |
| `previous` | `Sources/SwiftGodotKit/PropertyWrappers/GodotState.swift` | Reactive Sendable state, change tracking, and binding API. |
| `reset` | `Sources/SwiftGodotKit/PropertyWrappers/GodotState.swift` | Reactive Sendable state, change tracking, and binding API. |
| `update` | `Sources/SwiftGodotKit/PropertyWrappers/GodotState.swift` | Reactive Sendable state, change tracking, and binding API. |
| `binding` | `Sources/SwiftGodotKit/PropertyWrappers/GodotState.swift` | Reactive Sendable state, change tracking, and binding API. |
| `Binding` | `Sources/SwiftGodotKit/PropertyWrappers/GodotState.swift` | Reactive Sendable state, change tracking, and binding API. |
| `map` | `Sources/SwiftGodotKit/PropertyWrappers/GodotState.swift` | Reactive Sendable state, change tracking, and binding API. |
| `actuallyChanged` | `Sources/SwiftGodotKit/PropertyWrappers/GodotState.swift` | Reactive Sendable state, change tracking, and binding API. |
| `NodeController` | `Sources/SwiftGodotKit/Protocols/NodeController.swift` | Typed node construction and node-controller lifecycle API. |
| `NodeBuilder` | `Sources/SwiftGodotKit/Protocols/NodeController.swift` | Typed node construction and node-controller lifecycle API. |
| `buildBlock` | `Sources/SwiftGodotKit/Protocols/NodeController.swift` | Typed node construction and node-controller lifecycle API. |
| `buildOptional` | `Sources/SwiftGodotKit/Protocols/NodeController.swift` | Typed node construction and node-controller lifecycle API. |
| `buildEither` | `Sources/SwiftGodotKit/Protocols/NodeController.swift` | Typed node construction and node-controller lifecycle API. |
| `buildArray` | `Sources/SwiftGodotKit/Protocols/NodeController.swift` | Typed node construction and node-controller lifecycle API. |
| `NodeType` | `Sources/SwiftGodotKit/Protocols/NodeController.swift` | Typed node construction and node-controller lifecycle API. |
| `node` | `Sources/SwiftGodotKit/Protocols/NodeController.swift` | Typed node construction and node-controller lifecycle API. |
| `didAddChildren` | `Sources/SwiftGodotKit/Protocols/NodeController.swift` | Typed node construction and node-controller lifecycle API. |
| `build` | `Sources/SwiftGodotKit/Protocols/NodeController.swift` | Typed node construction and node-controller lifecycle API. |
| `buildAny` | `Sources/SwiftGodotKit/Protocols/NodeController.swift` | Typed node construction and node-controller lifecycle API. |
| `withChildren` | `Sources/SwiftGodotKit/Protocols/NodeController.swift` | Typed node construction and node-controller lifecycle API. |
| `SceneController` | `Sources/SwiftGodotKit/Protocols/SceneController.swift` | Scene lifecycle, resource loading, and instantiation API. |
| `RootNode` | `Sources/SwiftGodotKit/Protocols/SceneController.swift` | Scene lifecycle, resource loading, and instantiation API. |
| `rootNode` | `Sources/SwiftGodotKit/Protocols/SceneController.swift` | Scene lifecycle, resource loading, and instantiation API. |
| `sceneDidEnterTree` | `Sources/SwiftGodotKit/Protocols/SceneController.swift` | Scene lifecycle, resource loading, and instantiation API. |
| `sceneDidBecomeReady` | `Sources/SwiftGodotKit/Protocols/SceneController.swift` | Scene lifecycle, resource loading, and instantiation API. |
| `sceneDidProcess` | `Sources/SwiftGodotKit/Protocols/SceneController.swift` | Scene lifecycle, resource loading, and instantiation API. |
| `sceneDidPhysicsProcess` | `Sources/SwiftGodotKit/Protocols/SceneController.swift` | Scene lifecycle, resource loading, and instantiation API. |
| `sceneWillExitTree` | `Sources/SwiftGodotKit/Protocols/SceneController.swift` | Scene lifecycle, resource loading, and instantiation API. |
| `load` | `Sources/SwiftGodotKit/Protocols/SceneController.swift` | Scene lifecycle, resource loading, and instantiation API. |
| `instantiate` | `Sources/SwiftGodotKit/Protocols/SceneController.swift` | Scene lifecycle, resource loading, and instantiation API. |
| `SignalEmitting` | `Sources/SwiftGodotKit/Protocols/SignalEmitting.swift` | Signal-emitting protocol and owner API. |
| `signalOwner` | `Sources/SwiftGodotKit/Protocols/SignalEmitting.swift` | Signal-emitting protocol and owner API. |
| `SignalReceiving` | `Sources/SwiftGodotKit/Protocols/SignalReceiving.swift` | Signal-receiving protocol and subscription API. |
| `signalReceiver` | `Sources/SwiftGodotKit/Protocols/SignalReceiving.swift` | Signal-receiving protocol and subscription API. |
| `receive` | `Sources/SwiftGodotKit/Protocols/SignalReceiving.swift` | Signal-receiving protocol and subscription API. |
| `receiveOnce` | `Sources/SwiftGodotKit/Protocols/SignalReceiving.swift` | Signal-receiving protocol and subscription API. |
| `SwiftGodotKit` | `Sources/SwiftGodotKit/SwiftGodotKit.swift` | SwiftGodotKit package namespace and version API. |
| `version` | `Sources/SwiftGodotKit/SwiftGodotKit.swift` | SwiftGodotKit package namespace and version API. |
