# `System26`

System26 is a native utility designed to monitor and showcase Apple's on-device Foundation Models. It provides real-time performance metrics for **Language Models**, **Image Generation**, and **Computer Vision** across the Apple ecosystem.

<p align="right">
    <a href="https://example.com" style="text-decoration: none;">
        <img src="docs/mac-app-store.svg" alt="Download on the Mac App Store" width="156" />
    </a>
    <a href="https://example.com" style="text-decoration: none;">
        <img src="docs/app-store.svg" alt="Download on the App Store" width="120" />
    </a>
</p>

## Localized Documentation

*   [简体中文 (Simplified Chinese)](docs/readmes/README_zh-Hans.md)
*   [Español (Spanish)](docs/readmes/README_es.md)
*   [Français (French)](docs/readmes/README_fr.md)
*   [Português (Portuguese)](docs/readmes/README_pt.md)
*   [Deutsch (German)](docs/readmes/README_de.md)
*   [Italiano (Italian)](docs/readmes/README_it.md)
*   [日本語 (Japanese)](docs/readmes/README_ja.md)
*   [한국어 (Korean)](docs/readmes/README_ko.md)
*   [Tiếng Việt (Vietnamese)](docs/readmes/README_vi.md)

## Purpose

The application serves as an interactive lab for exploring the capabilities of local inference on Apple Silicon. It allows developers and enthusiasts to inspect the performance of on-device AI without relying on cloud connectivity.

## Supported Platforms

*   **macOS:** Optimized for desktop workflows.
*   **iOS (iPhone/iPad):** Fully responsive mobile interface with camera integration.
*   **visionOS:** Immersive spatial computing experience.

## Features

### 🧠 Large Language Models (LLM)
Monitor the performance of the `SystemLanguageModel` framework.
*   **Metrics:**
    *   **Throughput:** Tokens Per Second (TPS).
    *   **Latency:** Time to First Token (TTFT).
    *   **Memory:** Resident memory usage.
*   **Modes:**
    *   **General Purpose:** Open-ended text generation.
    *   **Content Tagging:** Specialized extraction and classification.

### 🎨 Image Generation
Test on-device image synthesis using `ImagePlayground`.
*   **Styles:** Animation, Illustration, Sketch.
*   **Capabilities:** Text-to-Image, Sketch-to-Image (iOS/visionOS), and Concept Extraction.
*   **Performance:** Measures generation time per image.

### 👁️ Computer Vision
Experience computer vision pipelines using `Vision` framework.
*   **Modes:**
    *   **Live Camera:** Real-time analysis overlay on camera feed.
    *   **Synthetic:** Offline stress test using standard asset sets.
*   **Tasks:**
    *   Text Recognition (OCR)
    *   Object Detection
    *   Face Detection
    *   Body Pose Estimation
    *   Feature Print Generation
*   **Thermal Analysis:** Tracks device thermal state and throttling impact during sustained workloads.

## Development

### Prerequisites
*   **Xcode 26+** (Required for Swift 6.0+ support).
*   **macOS 26+** (Tahoe) or newer.
*   **iOS/iPadOS/visionOS 26+** for device targets.
*   **Device:** Apple Silicon (M-Series) or A-Series chip with Neural Engine.

### Setup
1.  Clone the repository.
2.  Open `System26.xcodeproj` in Xcode.
3.  Wait for Swift Package Manager to resolve dependencies (see `Package.resolved`).
4.  Select your target scheme (`System26`) and device.
5.  Build and Run (**Cmd + R**).

### Code Quality
This project enforces strict linting and formatting standards.

*   **SwiftLint:** Enforces Swift style and conventions.
*   **SwiftFormat:** Automatically formats code.

To run checks locally before committing:

```bash
make checks
```

This command runs `./scripts/checks.sh` which executes both SwiftFormat and SwiftLint.

### Release Automation
Fastlane drives App Store Connect uploads from both CI and local machines

**GitHub Action secrets**
- `APP_STORE_KEY_ID`, `APP_STORE_KEY_ISSUER`, `APP_STORE_KEY_CONTENT`: App Store Connect API key pieces (`APP_STORE_KEY_CONTENT` can be raw `.p8` text or base64).
- `MATCH_GIT_URL`, `MATCH_PASSWORD`, `MATCH_GIT_BRANCH` (optional): certificate/provisioning repository.
- `MATCH_KEYCHAIN_NAME`, `MATCH_KEYCHAIN_PASSWORD` (optional): overrides for the ephemeral CI keychain.

**Lanes**
- iOS/iPadOS TestFlight: `bundle exec fastlane ios deploy_ios`
- visionOS TestFlight: `bundle exec fastlane ios deploy_visionos`
- macOS TestFlight: `bundle exec fastlane mac deploy_mac`

The GitHub workflow at `.github/workflows/deploy.yml` runs these lanes in a matrix

### Architecture
The project is modularized using Swift Packages:
*   `Core`: Shared utilities, localization, and base models.
*   `DesignSystem`: Reusable UI components (Liquid backgrounds, metrics cards).
*   `FeatureLLM`: Logic and UI for Language Model runs with live performance signals.
*   `FeatureImageGen`: Integration with ImagePlayground.
*   `FeatureVisualIntelligence`: Vision framework pipelines and camera handling with real-time metrics.
*   `FeatureSettings`: App-wide settings and about screen.

---
Copyright © 2025 Caldera. All rights reserved.
