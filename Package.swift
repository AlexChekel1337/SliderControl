// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "SliderControl",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(name: "SliderControl", targets: ["SliderControl"])
    ],
    targets: [
        .target(name: "SliderControl", dependencies: [])
    ]
)
