// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ExpenseTracker",
    targets: [
        .executableTarget(
            name: "ExpenseTracker",
            path: "Sources/ExpenseTracker"
        )
    ]
)
