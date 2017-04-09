import PackageDescription

let package = Package(
    name: "ABM",
    targets: [
        Target(name: "Util", dependencies: []),
        Target(name: "ABM", dependencies: ["Util", "SwiftDataStructures"])
    ]
)
