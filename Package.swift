// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "PopZeit",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "PopZeit",
            targets: ["PopZeit"]
        )
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "PopZeit",
            path: "PopZeit/Sources",
            resources: [
                .copy("../Resources")
            ]
        ),
        .testTarget(
            name: "PopZeitTests",
            dependencies: ["PopZeit"],
            path: "PopZeit/Tests"
        )
    ]
)