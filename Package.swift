// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "BRBON",
    products: [library(name: "BRBON", targets: ["BRBON"])],
    dependencies: [
        .package(url: "https://github.com/Balancingrock/BRUtils", from: "1.1.5")
    ],
    targets: [
        .target(name: "BRBON", dependencies: ["BRUtils"]),
        .testTarget(name: "BRBONTests", dependencies: ["BRBON"])
    ],
    swiftLanguageVersions: [.v4, .v4_2, .v5]
)
