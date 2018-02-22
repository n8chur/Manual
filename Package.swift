import PackageDescription
import Foundation

let package = Package(
    name: "Manual",
    targets: [
      Target(name: "ManualKit"),
      Target(name: "FixtureGen", dependencies: ["ManualKit"]),
      Target(name: "GoGen", dependencies: ["ManualKit"]),
      Target(name: "manual", dependencies: [
        "FixtureGen",
        "GoGen"
      ])
    ],
    dependencies: [
        .Package(url: "https://github.com/Automatic/SwaggerParser.git", majorVersion: 0, minor: 6),
        .Package(url: "https://github.com/nsomar/Guaka", majorVersion: 0, minor: 1)
    ]
)
