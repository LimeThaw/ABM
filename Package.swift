import PackageDescription

let package = Package(
    name: "ABM",
    targets: [
        Target(name: "Util", dependencies: []),
        Target(name: "ABM", dependencies: ["Util"])
    ],
    dependencies: [
        .Package(url: "https://github.com/mauriciosantos/Buckets-Swift", majorVersion: 2)
    ]
)
