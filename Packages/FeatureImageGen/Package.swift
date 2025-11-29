// swift-tools-version: 6.2
import PackageDescription

let package = Package(
  name: "FeatureImageGen",
  platforms: [
    .macOS(.v26),
    .iOS(.v26),
    .visionOS(.v26)
  ],
  products: [
    .library(name: "FeatureImageGen", targets: ["FeatureImageGen"])
  ],
  dependencies: [
    .package(path: "../Core"),
    .package(path: "../DesignSystem")
  ],
  targets: [
    .target(
      name: "FeatureImageGen",
      dependencies: [
        "Core",
        "DesignSystem"
      ]
    )
  ]
)
