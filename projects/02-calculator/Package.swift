// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Calculator",
    targets: [
        .executableTarget(
            name: "Calculator",
            path: "Sources/Calculator"
        )
    ]
)
