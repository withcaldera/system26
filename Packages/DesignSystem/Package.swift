// swift-tools-version: 6.2
import PackageDescription

let package = Package(
  name: "DesignSystem",
  platforms: [
    .macOS(.v26),
    .iOS(.v26),
    .visionOS(.v26)
  ],
  products: [
    .library(name: "DesignSystem", targets: ["DesignSystem"])
  ],
  dependencies: [
    .package(path: "../Core")
  ],
  targets: [
    .target(name: "DesignSystem", dependencies: ["Core"], resources: [.process("Resources")])
  ]
)
