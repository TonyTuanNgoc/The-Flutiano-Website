// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "TheFlutianoApp",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(
            name: "TheFlutianoApp",
            targets: ["TheFlutianoApp"]
        )
    ],
    targets: [
        .executableTarget(
            name: "TheFlutianoApp",
            resources: [
                .process("Resources")
            ]
        )
    ]
)
