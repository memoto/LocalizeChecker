// swift-tools-version: 5.6

import PackageDescription
import Foundation

var targets: [Target] { checkerTargets + migratorTargets }

var checkerTargets: [Target] = [
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

var migratorTargets: [Target] {
    if includeMigrator {
        return [
            .executableTarget(
                name: "LocalizeMigratorCLI",
                dependencies: [
                    .product(name: "ArgumentParser", package: "swift-argument-parser"),
                    "LocalizeMigrator",
                    "LocalizeChecker"
                ]
            ),
            .target(
                name: "LocalizeMigrator",
                dependencies: [
                    .product(name: "SwiftSyntax", package: "swift-syntax"),
                    .product(name: "SwiftSyntaxParser", package: "swift-syntax"),
                    .product(name: "SwiftSyntaxBuilder", package: "swift-syntax")
                ]
            ),
            .testTarget(
                name: "LocalizeMigratorTests",
                dependencies: [
                    "LocalizeMigrator",
                    .product(name: "SwiftSyntax", package: "swift-syntax")
                ],
                path: "Tests/LocalizeMigrator",
                resources: [.copy("Fixtures")]
            )
        ]
    } else {
        return []
    }
}

var ENV: [String : String] = ProcessInfo.processInfo.environment

let includeMigrator = ENV["USE_LOCALIZE_MIGRATOR"] != nil && ENV["CI"] == nil

let package = Package(
    name: "LocalizeChecker",
    platforms: [.macOS(.v12)],
    products: [
        .executable(name: "check-localize", targets: ["LocalizeCheckerCLI"]),
        .library(name: "LocalizeChecker", targets: ["LocalizeChecker"])
    ] + (includeMigrator
         ? [.executable(name: "migrate-localize", targets: ["LocalizeMigratorCLI"])]
         : []
        ),
    dependencies: [
        .package(
            url: "https://github.com/apple/swift-syntax.git", 
            exact: "0.50600.1"
        ),
        .package(
            url: "https://github.com/apple/swift-argument-parser",
                exact: "1.1.2"
        )
    ],
    targets: checkerTargets + migratorTargets
)
