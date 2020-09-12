// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Nakiri",
    dependencies: [
    ],
    targets: [
        .target(
            name: "Nakiri",
            dependencies: []),
        .testTarget(
            name: "NakiriTests",
            dependencies: ["Nakiri"])
    ]
)
