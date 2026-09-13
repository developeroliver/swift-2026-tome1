// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "SwiftTaskManager",
    platforms: [.macOS(.v13)],
    products: [
        .library(name: "TaskManagerCore", targets: ["TaskManagerCore"])
    ],
    targets: [
        .target(
            name: "TaskManagerCore"
        ),
        .executableTarget(
            name: "TaskManagerCLI",
            dependencies: ["TaskManagerCore"]
        ),
        .testTarget(
            name: "TaskManagerCoreTests",
            dependencies: ["TaskManagerCore"]
        )
    ]
)
