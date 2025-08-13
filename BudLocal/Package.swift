// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BudLocal",
    products: [
        // BudLocal
        .library(
            name: "BudLocal",
            targets: ["BudLocal"]
        ),
    ],
    targets: [
        // BudLocal
        .target(
            name: "BudLocal"
        ),
        .testTarget(
            name: "BudLocalTests",
            dependencies: ["BudLocal"]
        ),
    ]
)
