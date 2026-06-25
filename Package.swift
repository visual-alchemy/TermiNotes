// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "TermiNotes",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "TermiNotes", targets: ["TermiNotes"])
    ],
    dependencies: [
        .package(url: "https://github.com/johnsundell/ink.git", from: "0.6.0")
    ],
    targets: [
        .executableTarget(
            name: "TermiNotes",
            dependencies: [
                .product(name: "Ink", package: "ink")
            ],
            path: "Sources",
            linkerSettings: [
                .linkedLibrary("sqlite3")
            ]
        )
    ]
)
