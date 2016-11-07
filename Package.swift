import PackageDescription

let package = Package(
    name: "DDLogManager",
    targets: [
        Target(name: "DDLogManager"),
        Target(name: "DDLogManagerExec", dependencies: ["DDLogManager"])
    ]
)
