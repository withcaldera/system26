// swift-tools-version: 6.2
import PackageDescription

let package = Package(
  name: "Core",
  defaultLocalization: "en",
  platforms: [
    .macOS(.v26),
    .iOS(.v26),
    .visionOS(.v26)
  ],
  products: [
    .library(name: "Core", targets: ["Core"])
  ],
  targets: [
    .target(
      name: "Core",
      dependencies: [],
      resources: [
        .process("Resources/Localizable.xcstrings")
      ])
  ]
)
