// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CursorBuddy",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "CursorBuddy", targets: ["CursorBuddy"])
    ],
    targets: [
        .executableTarget(
            name: "CursorBuddy",
            path: "Sources"
        )
    ]
)
