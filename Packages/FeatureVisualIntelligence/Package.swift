// swift-tools-version: 6.2
import PackageDescription

let package = Package(
  name: "FeatureVisualIntelligence",
  platforms: [
    .macOS(.v26),
    .iOS(.v26),
    .visionOS(.v26)
  ],
  products: [
    .library(
      name: "FeatureVisualIntelligence", targets: ["FeatureVisualIntelligence"])
  ],
  dependencies: [
    .package(path: "../Core"),
    .package(path: "../DesignSystem")
  ],
  targets: [
    .target(
      name: "FeatureVisualIntelligence",
      dependencies: [
        "Core",
        "DesignSystem"
      ],
      resources: [
        .process("Resources")
      ]
    )
  ]
)
