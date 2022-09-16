// swift-tools-version: 5.6

import PackageDescription
import Foundation

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
            exact: "0.50600.1"
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
            path: "Tests/LocalizeChecker",
            resources: [.copy("Fixtures")]
        )
    ]
)
