// swift-tools-version: 5.9
// Package.swift — DKParkingSDK
// Phase 9 Vertical Slice

import PackageDescription

let package = Package(
    name: "DKParkingSDK",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "DKParkingSDK",
            targets: ["DKParkingSDK"]
        )
    ],
    targets: [
        .target(
            name: "DKParkingSDK",
            path: "Sources/DKParkingSDK"
        ),
        .testTarget(
            name: "DKParkingSDKTests",
            dependencies: ["DKParkingSDK"],
            path: "Tests/DKParkingSDKTests"
        )
    ]
)
