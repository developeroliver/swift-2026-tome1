// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "TodoCLI",
    targets: [
        .executableTarget(
            name: "TodoCLI",
            path: "Sources/TodoCLI"
        )
    ]
)
