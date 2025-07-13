
// swift-tools-version:5.5
// import PackageDescription

// let package = Package(
//     name: "OpenSSL",
//     platforms: [
//         .iOS(.v12),
//         .macOS(.v10_15)
//     ],
//     products: [
//         .library(
//             name: "OpenSSL",
//             targets: ["OpenSSLBinary"]
//         ),
//     ],
//     targets: [
//         .binaryTarget(
//             name: "OpenSSLBinary",
//             url: "https://github.com/ios-poc/OpenSSL-SPM/releases/download/0.0.6/OpenSSL.xcframework.zip",
//             checksum: "221eabb03ecfe09c1130a2aa30ade835971192d86be76ff9cf676a781c71c710"
//         )
//     ]
// )
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
            dependencies: ["OpenSSLBinary"],
            path: "Sources/OpenSSL",  // to resolve the OpenSSL.h header
            publicHeadersPath: "."
        ),
        .binaryTarget(
            name: "OpenSSLBinary",
            path: "OpenSSL.xcframework"
        )
    ]
)

