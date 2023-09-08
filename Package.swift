// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SliderControl",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        .library(name: "SliderControl", targets: ["SliderControl"])
    ],
    targets: [
        .target(name: "SliderControl", dependencies: [])
    ]
)
