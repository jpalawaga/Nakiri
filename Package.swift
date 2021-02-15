// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import SwiftUI

let package = Package(
    name: "Nakiri",
    platforms: [
        .macOS(.v10_12)
    ],
    products: [
    .library(
        name: "Nakiri", targets: ["Nakiri"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log.git", from: "1.2.0"),
    ],
    targets: [
        .target(
            name: "Nakiri",
            dependencies: []),
        .target(
            name: "NakiriApp",
            dependencies: ["Nakiri", "Logging"]),
        .testTarget(
            name: "NakiriTests",
            dependencies: ["Nakiri"])
    ]
)
