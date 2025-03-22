code README.md
// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "AgeCalculator",
    platforms: [
        .macOS(.v11)
    ],
    products: [
        .executable(name: "AgeCalculator", targets: ["AgeCalculator"])
    ],
    dependencies: [
        .package(url: "https://github.com/soffes/HotKey", from: "0.1.3")
    ],
    targets: [
        .executableTarget(
            name: "AgeCalculator",
            dependencies: ["HotKey"]
        )
    ]
)

