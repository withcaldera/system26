// swift-tools-version: 6.2
import PackageDescription

let package = Package(
  name: "FeatureLLM",
  platforms: [
    .macOS(.v26),
    .iOS(.v26),
    .visionOS(.v26)
  ],
  products: [
    .library(name: "FeatureLLM", targets: ["FeatureLLM"])
  ],
  dependencies: [
    .package(path: "../Core"),
    .package(path: "../DesignSystem")
  ],
  targets: [
    .target(
      name: "FeatureLLM",
      dependencies: [
        "Core",
        "DesignSystem"
      ]
    )
  ]
)
