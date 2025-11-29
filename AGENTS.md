# System26 - On-Device AI Performance Explorer

## Project Overview

**System26** is a native Swift application for iOS, macOS, and visionOS designed to showcase Apple's on-device `SystemLanguageModel` framework. It lets users see real-time inference performance (throughput, latency, memory, thermals) of local Foundation Models across Apple Silicon devices.

### Key Technologies
*   **Language:** Swift 6+
*   **UI Framework:** SwiftUI
*   **Architecture:** Modularized Monorepo using Swift Package Manager (SPM).
*   **Apple Frameworks:** `SystemLanguageModel` (Private/Public API dependent on OS version), `NaturalLanguage`, `Combine`, `Charts`.

### Architecture

The project follows a modular architecture to separate concerns and enable code sharing across targets.

*   **`System26/`**: The main app target. Contains the `App` entry point (`System26App.swift`), main navigation (`System26AppView.swift`), and composition root.
*   **`Packages/`**: Contains local Swift packages:
    *   **`Core`**: Shared domain logic, localization (`Localization.swift`), and utilities.
    *   **`DesignSystem`**: Reusable SwiftUI components (buttons, cards, charts) and style definitions (`Theme.swift`).
*   **`FeatureLLM`**: Logic and UI for running Large Language Models (Text Generation) with live metrics.
*   **`FeatureImageGen`**: Logic and UI for Image Generation runs with on-device performance readouts.
*   **`FeatureVisualIntelligence`**: Logic and UI for Vision model runs with camera and synthetic pipelines.
    *   **`FeatureSettings`**: App configuration and settings UI.

## Building and Running

### Prerequisites
*   **Xcode 26+**
*   **macOS 26+** (for Mac target) or **iOS 26+** (for iPhone target).
*   Device with Apple Silicon (M-series or A-series).

### Commands

*   **Build & Run:** Open `System26.xcodeproj` in Xcode, select your target (My Mac, iPhone, or Apple Vision Pro), and press `Cmd + R`.
*   **Run Checks (Format & Lint):**
    ```bash
    make checks
    # Or directly:
    ./scripts/checks.sh
    ```
    This runs `swift-format` (Apple) and `swiftlint` (Realm), automatically fixing formatting issues where possible.

## Development Conventions

*   **Localization:** We use a single **String Catalog (`Localizable.xcstrings`)** in `Packages/Core/Sources/Core/Resources/` (SwiftPM resource) backed by `Localization.string(_:)`.
    *   Add/modify strings by editing `Localizable.xcstrings`; translations for all supported locales live there.
    *   Access copy via `Localization.string("KEY")` (already points at the catalog) or `String(localized: "KEY", bundle: Localization.bundle)` if you need interpolation APIs.
    *   This replaces the former dictionary-based system; do **not** add `.strings` files.
*   **Styling:** Use `Theme` from the `DesignSystem` package for colors, fonts, and spacing.
    *   Example: `Text("Hello").font(Theme.sectionHeader).foregroundStyle(Theme.secondaryColor)`
*   **Dependency Injection:** Dependencies (Services, Repositories) are instantiated in `System26App.swift` and injected into ViewModels. ViewModels are usually `@Observable` or `@StateObject`.
*   **Formatting:** Code is strictly formatted using `swift-format`. Always run `./scripts/checks.sh` before committing.

## Directory Structure

*   `System26/` - Main Xcode target and app entry point.
*   `Packages/` - Modular features and core logic.
*   `scripts/` - Utility scripts (CI/CD, linting).
*   `docs/` - Documentation and assets.
*   `Makefile` - Entry point for scripts.
