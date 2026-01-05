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
        // CorvidLabs Swift packages
        .package(url: "https://github.com/CorvidLabs/swift-game.git", from: "0.1.0"),
        .package(url: "https://github.com/CorvidLabs/swift-art.git", from: "0.1.0"),
        .package(url: "https://github.com/CorvidLabs/swift-color.git", from: "0.1.0"),
        .package(url: "https://github.com/CorvidLabs/swift-music.git", from: "0.1.0"),
        .package(url: "https://github.com/CorvidLabs/swift-qr.git", from: "0.1.0"),
        .package(url: "https://github.com/CorvidLabs/swift-graph.git", from: "0.1.0"),
        .package(url: "https://github.com/CorvidLabs/swift-parse.git", from: "0.1.0"),
        .package(url: "https://github.com/CorvidLabs/swift-stats.git", from: "0.1.0")
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
