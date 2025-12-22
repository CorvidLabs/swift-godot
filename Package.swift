// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "swift-godot",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "SwiftGodotKit",
            targets: ["SwiftGodotKit"]
        ),
        .library(
            name: "SwiftGodotKitDemo",
            type: .dynamic,
            targets: ["Demo"]
        )
    ],
    dependencies: [
        // SwiftGodot uses unsafe build flags for C interop.
        // Branch tracking bypasses SPM's restriction on unsafe flags.
        .package(
            url: "https://github.com/migueldeicaza/SwiftGodot.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swiftlang/swift-docc-plugin.git",
            from: "1.4.0"
        ),
        // CorvidLabs Swift packages (local paths for development)
        .package(path: "../swift-game"),
        .package(path: "../swift-art"),
        .package(path: "../swift-color"),
        .package(path: "../swift-music"),
        .package(path: "../swift-qr"),
        .package(path: "../swift-graph"),
        .package(path: "../swift-parse"),
        .package(path: "../swift-stats")
    ],
    targets: [
        .target(
            name: "SwiftGodotKit",
            dependencies: [
                .product(name: "SwiftGodot", package: "SwiftGodot")
            ]
        ),
        .target(
            name: "Demo",
            dependencies: [
                "SwiftGodotKit",
                // CorvidLabs packages
                .product(name: "Game", package: "swift-game"),
                .product(name: "Art", package: "swift-art"),
                .product(name: "Color", package: "swift-color"),
                .product(name: "Music", package: "swift-music"),
                .product(name: "SwiftQR", package: "swift-qr"),
                .product(name: "Graph", package: "swift-graph"),
                .product(name: "Parse", package: "swift-parse"),
                .product(name: "Stats", package: "swift-stats")
            ],
            path: "Sources/Demo",
            plugins: [
                .plugin(name: "EntryPointGeneratorPlugin", package: "SwiftGodot")
            ]
        ),
        .testTarget(
            name: "SwiftGodotKitTests",
            dependencies: ["SwiftGodotKit"]
        )
    ]
)
