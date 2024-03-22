// swift-tools-version: 5.9

import PackageDescription
import Foundation

let package = Package(
    name: "LocalizeChecker",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "check-localize", targets: ["LocalizeCheckerCLI"]),
        .library(name: "LocalizeChecker", targets: ["LocalizeChecker"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/apple/swift-syntax.git", 
            from: "509.0.0"
        ),
        .package(
            url: "https://github.com/apple/swift-argument-parser",
            from: "1.1.3"
        )
    ],
    targets: [
        .executableTarget(
            name: "LocalizeCheckerCLI",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftParser", package: "swift-syntax"),
                "LocalizeChecker",
            ]
        ),
        .target(
            name: "LocalizeChecker",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftParser", package: "swift-syntax")
            ]
        ),
        .testTarget(
            name: "LocalizeCheckerTests",
            dependencies: [
                "LocalizeChecker",
                .product(name: "SwiftSyntax", package: "swift-syntax")
            ],
            path: "Tests/LocalizeChecker",
            resources: [.copy("Fixtures")]
        )
    ]
)
