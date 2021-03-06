// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DC-Bot",
    dependencies: [
		.package(url: "https://github.com/vapor-community/postgresql-provider.git", .upToNextMajor(from: "2.1.0")),
		.package(url: "https://github.com/vapor/vapor.git", .upToNextMajor(from: "2.1.0")),
		.package(url: "https://github.com/Azoy/Sword.git", .upToNextMajor(from: "0.9.0"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "DC-Phonebook",
            dependencies: ["Sword", "Vapor", "PostgreSQLProvider"],
			path: "Sources",
			exclude: [
				"Config",
				"Public",
				"Resources",
				])
    ]
)
