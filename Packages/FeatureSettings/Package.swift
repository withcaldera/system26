// swift-tools-version: 6.2
import PackageDescription

let package = Package(
  name: "FeatureSettings",
  platforms: [
    .macOS(.v26),
    .iOS(.v26),
    .visionOS(.v26)
  ],
  products: [
    .library(name: "FeatureSettings", targets: ["FeatureSettings"])
  ],
  dependencies: [
    .package(path: "../Core"),
    .package(path: "../DesignSystem")
  ],
  targets: [
    .target(
      name: "FeatureSettings",
      dependencies: [
        "Core",
        "DesignSystem"
      ]
    )
  ]
)
