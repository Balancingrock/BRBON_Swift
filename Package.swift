import PackageDescription

let package = Package(
    name: "BRBON",
    dependencies: [
        .Package(url: "../BRUtils", Version(0, 9, 0))
    ]
)
