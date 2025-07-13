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
          url: "https://github.com/ios-poc/OpenSSL-SPM/releases/download/0.0.5/OpenSSL.xcframework.zip",
          checksum: "221eabb03ecfe09c1130a2aa30ade835971192d86be76ff9cf676a781c71c710"
        )
    ]
)
//https://github.com/ios-poc/OpenSSL-SPM/releases/tag/0.0.2#:~:text=OpenSSL.xcframework.zip
