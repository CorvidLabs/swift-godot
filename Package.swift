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
        )
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
            dependencies: ["SwiftGodotKit"],
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
