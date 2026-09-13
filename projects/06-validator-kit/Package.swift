// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "ValidatorKit",
    platforms: [.macOS(.v13)],
    products: [
        .library(name: "ValidatorKit", targets: ["ValidatorKit"])
    ],
    targets: [
        .target(
            name: "ValidatorKit"
        ),
        .executableTarget(
            name: "ValidatorKitDemo",
            dependencies: ["ValidatorKit"]
        ),
        .testTarget(
            name: "ValidatorKitTests",
            dependencies: ["ValidatorKit"]
        )
    ]
)
