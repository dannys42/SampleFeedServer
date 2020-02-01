// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "SampleFeed",
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),
        
        // 🔵 Swift ORM (queries, models, relations, etc) built on SQLite 3.
        .package(url: "https://github.com/vapor/fluent-sqlite.git", from: "3.0.0"),
        
        // 👤 Authentication and Authorization layer for Fluent.
        .package(url: "https://github.com/vapor/auth.git", from: "2.0.0"),

        .package(url: "https://github.com/vapor-community/vapor-ext.git", from: "0.1.0"),
        
        .package(url: "https://github.com/onevcat/Rainbow.git", from: "3.0.0"),
        
        // For logging
        .package(url: "https://github.com/vapor/console.git", from: "3.0.0"),
        
        .package(path: "../SampleUtilities")
    ],
    targets: [
        .target(name: "App", dependencies: ["Authentication", "FluentSQLite", "Vapor", "VaporExt", "Rainbow", "Logging" ]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App", "SampleUtilities"])
    ]
)

