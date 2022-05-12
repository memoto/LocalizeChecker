// swift-tools-version: 5.5

import PackageDescription

let package = Package(
    name: "LocalizeChecker",
    platforms: [.macOS(.v12)],
    products: [
        .executable(name: "check-localize", targets: ["LocalizeCheckerCLI"]),
        .library(name: "LocalizeChecker", targets: ["LocalizeChecker"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/apple/swift-syntax.git",
            "0.50600.1"..."0.50600.1"
        ),
        .package(
            url: "https://github.com/apple/swift-argument-parser",
            "1.0.3"..."1.0.3"
        )
    ],
    targets: [
        .executableTarget(
            name: "LocalizeCheckerCLI",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                "LocalizeChecker",
            ]
        ),
        .target(
            name: "LocalizeChecker",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxParser", package: "swift-syntax")
            ]
        ),
        .testTarget(
            name: "LocalizeCheckerTests",
            dependencies: [
                "LocalizeChecker",
                .product(name: "SwiftSyntax", package: "swift-syntax")
            ],
            path: "Tests",
            resources: [.copy("Fixtures")]
        )
    ]
)
