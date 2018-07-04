// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DC-Bot",
    dependencies: [
        .package(url: "https://github.com/vapor/fluent-sqlite.git", from: "3.0.0-rc.4"),
        .package(url: "https://github.com/Azoy/Sword.git", from: "0.9.0")
    ],
    targets: [
        .target(
            name: "DC-Bot",
//            dependencies: ["Sword"])
            dependencies: ["FluentSQLite", "Sword"])
    ]
)
