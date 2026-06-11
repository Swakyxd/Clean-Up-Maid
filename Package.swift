// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "CleanUpMaid",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "CleanUpMaid",
            path: "Sources/CleanUpMaid"
        )
    ]
)
