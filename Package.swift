import PackageDescription

let package = Package(
    name: "BRBON",
    dependencies: [
        .Package(url: "https://github.com/Balancingrock/BRUtils", Version(0, 11, 1))
    ]
)
