// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import SwiftUI

let package = Package(
    name: "Nakiri",
    products: [
    .library(
        name: "Nakiri", targets: ["Nakiri"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "Nakiri",
            dependencies: []),
        .target(
            name: "NakiriApp",
            dependencies: ["Nakiri"]),
        .testTarget(
            name: "NakiriTests",
            dependencies: ["Nakiri"])
    ]
)
