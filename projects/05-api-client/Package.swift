// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "APIClient",
    targets: [
        .executableTarget(
            name: "APIClient",
            path: "Sources/APIClient"
        )
    ]
)
