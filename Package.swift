// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ExploreCitadel",
    platforms: [.macOS(.v13), .iOS(.v16)],
    dependencies: [
        .package(
            url: "https://github.com/apple/swift-argument-parser.git",
            .upToNextMajor(from: "1.5.0")),
        .package(url: "https://github.com/orlandos-nl/Citadel/", from: "0.9.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(name: "ExploreCitadel", dependencies: [
            .product(name: "ArgumentParser", package: "swift-argument-parser"),
            .product(name: "Citadel", package: "Citadel"),
        ]),
    ]
)
