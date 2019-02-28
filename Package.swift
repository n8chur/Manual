// swift-tools-version:4.2
import PackageDescription

let package = Package(
    name: "Manual",
    products: [
        .executable(name: "manual", targets: ["manual"])
    ],
    dependencies: [
        .package(url: "https://github.com/n8chur/SwaggerParser.git", .exact("0.6.2")),
        .package(url: "https://github.com/nsomar/Guaka", .exact("0.3.1"))
    ],
    targets: [
        .target(name: "ManualKit", dependencies: ["SwaggerParser", "Guaka"]),
        .target(name: "FixtureGen", dependencies: ["ManualKit"]),
        .target(name: "GoGen", dependencies: ["ManualKit"]),
        .target(name: "manual", dependencies: [
            "FixtureGen",
            "GoGen"
        ]),
        .testTarget(name: "FixtureGenTests", dependencies: ["FixtureGen"]),
        .testTarget(name: "GoGenTests", dependencies: ["GoGen"])
    ],
    swiftLanguageVersions: [.v4]
)
