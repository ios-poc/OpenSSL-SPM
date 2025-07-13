// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "OpenSSL",
    platforms: [
        .iOS(.v12),
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "OpenSSL",
            targets: ["OpenSSL"]
        ),
    ],
    targets: [
        .target(
            name: "OpenSSL",
            dependencies: ["OpenSSLBinary"]
        ),
        .binaryTarget(
          name: "OpenSSLBinary",
          url: "https://github.com/ios-poc/OpenSSL/releases/download/0.0.3/OpenSSL.xcframework.zip",
          checksum: "9806512c9b435d99b6475e957bd25be5606e13acf934dfe0f4329eeaccf45eee"
        )
    ]
)
