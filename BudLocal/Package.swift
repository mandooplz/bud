// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BudLocal",
    platforms: [.macOS(.v26)],
    products: [
        // BudLocal
        .library(
            name: "BudLocal",
            targets: ["BudLocal"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-collections.git", from: "1.0.4"),
        .package(url: "https://github.com/mandooplz/budmacro.git", branch: "main")
    ],
    targets: [
        // BudLocal
        .target(
            name: "BudLocal",
            dependencies: [
                "ValueSuite"
            ]
        ),
        .testTarget(
            name: "BudLocalTests",
            dependencies: ["BudLocal", "ValueSuite"]
        ),
        
        
        // Values
        .target(
            name: "ValueSuite",
            dependencies: [
                .product(name: "Collections", package: "swift-collections"),
                .product(name: "BudMacro", package: "budmacro")
            ]
        )
    ]
)
