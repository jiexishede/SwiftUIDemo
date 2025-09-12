// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftUIDemo",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "SwiftUIDemo",
            targets: ["SwiftUIDemo"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.9.0")
    ],
    targets: [
        .target(
            name: "SwiftUIDemo",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ],
            path: "SwiftUIDemo"
        ),
        .testTarget(
            name: "SwiftUIDemoTests",
            dependencies: ["SwiftUIDemo"],
            path: "SwiftUIDemoTests"
        ),
    ]
)