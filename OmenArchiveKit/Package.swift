// swift-tools-version: 6.0

import PackageDescription

var archiveKitTestDependencies: [Target.Dependency] = [
    "OmenArchiveKit",
    .product(name: "OmenMechanics", package: "OmenCore")
]

#if !os(Linux)
archiveKitTestDependencies += [
    .product(name: "OmenCoreMechanics", package: "OmenCore"),
    .product(name: "OmenSpellcastingMechanics", package: "OmenCore")
]
#endif

let package = Package(
    name: "OmenArchiveKit",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(name: "OmenArchiveKit", targets: ["OmenArchiveKit"]),
        .executable(name: "omen-archive", targets: ["omen-archive"])
    ],
    dependencies: [
        .package(path: "../../OmenCore"),
        .package(url: "https://github.com/jpsim/Yams.git", from: "5.1.3")
    ],
    targets: [
        .target(
            name: "OmenArchiveKit",
            dependencies: [
                .product(name: "OmenMechanics", package: "OmenCore"),
                .product(name: "OmenURI", package: "OmenCore"),
                .product(name: "Yams", package: "yams")
            ],
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]
        ),
        .executableTarget(
            name: "omen-archive",
            dependencies: ["OmenArchiveKit"],
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]
        ),
        .testTarget(
            name: "OmenArchiveKitTests",
            dependencies: archiveKitTestDependencies,
            resources: [.copy("Fixtures/archive-format.json")],
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]
        )
    ]
)
