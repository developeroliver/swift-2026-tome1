// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ConcurrentDataEngine",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "ConcurrentDataEngine",
            path: "Sources/ConcurrentDataEngine"
        )
    ]
)
