// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "BRBON",
    products: [
        .library(name: "BRBON", targets: ["BRBON"])
    ],
    dependencies: [
        .package(url: "https://github.com/Balancingrock/BRUtils", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "BRBON",
            dependencies: ["BRUtils"]
        ),
        .testTarget(
            name: "BRBONTests",
            dependencies: ["BRBON"]
        )
    ]
)
