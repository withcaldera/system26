import Core
import CoreGraphics
import DesignSystem
import PencilKit
import SwiftUI

#if canImport(ImagePlayground)
  import ImagePlayground
#endif

@MainActor
@Observable
@available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
public final class ImageGenViewModel {
  public var themeInput: String = ""
  public var textConcepts: [String] = []
  public var suggestedConcepts: [String] = []
  public var referenceImage: CGImage?
  public var sketch: PKDrawing?
  public var extractionSourceText: String = ""
  public var extractionTitle: String = ""
  public var useExtraction: Bool = false
  public var availableStyles: [ImagePlaygroundStyle] = []
  public var selectedStyle: ImagePlaygroundStyle?
  public var requestedImageLimit: Int = 1
  public var isRunning: Bool = false
  public var progress: String = ""
  public var error: String?
  public var partialImage: Image?
  public var streamedImages: [Image] = []
  public var lastResult: ImageGenResult?
  public var isGeneratingConcepts: Bool = false
  public var isLoadingStyles: Bool = false
  public var elapsedTime: TimeInterval = 0

  private let service: ImageGenServiceProtocol
  private var currentTask: Task<Void, Never>?
  private var timerTask: Task<Void, Never>?

  public init(service: ImageGenServiceProtocol) {
    self.service = service
  }

  public func addConcept(_ concept: String) {
    let trimmed = concept.trimmingCharacters(in: .whitespacesAndNewlines)
    if !trimmed.isEmpty && !textConcepts.contains(trimmed) {
      textConcepts.append(trimmed)
    }
  }

  public func removeConcept(_ concept: String) {
    textConcepts.removeAll { $0 == concept }
  }

  public func activateSuggestion(_ concept: String) {
    addConcept(concept)
    suggestedConcepts.removeAll { $0 == concept }
  }

  public func generateConceptSeed() async {
    isGeneratingConcepts = true
    error = nil
    do {
      let stream = service.generateRandomSeed()
      for try await seed in stream {
        self.themeInput = seed
      }

      if !themeInput.isEmpty {
        await generateConcepts()
      } else {
        isGeneratingConcepts = false
      }
    } catch {
      self.error = error.localizedDescription
      isGeneratingConcepts = false
    }
  }

  public func ensureInitialConcepts() async {
    guard textConcepts.isEmpty else {
      return
    }

    if !themeInput.isEmpty {
      await generateConcepts()
    } else {
      await generateConceptSeed()
    }
  }

  public func generateConcepts() async {
    guard !themeInput.isEmpty else {
      return
    }
    isGeneratingConcepts = true
    suggestedConcepts = []
    error = nil

    do {
      let stream = service.generateConcepts(for: themeInput)
      for try await (visuals, keywords) in stream {
        let uniqueVisuals = Array(NSOrderedSet(array: visuals)).compactMap { $0 as? String }
        self.textConcepts = Array(uniqueVisuals.prefix(3))
        self.suggestedConcepts = keywords
      }
    } catch {
      self.error = error.localizedDescription
    }

    isGeneratingConcepts = false
  }

  public func stopBenchmark() {
    currentTask?.cancel()
    currentTask = nil
    timerTask?.cancel()
    timerTask = nil
    isRunning = false
    progress = ""
  }

  public func runBenchmark() {
    isRunning = true
    error = nil
    progress = Localization.string("PROGRESS_INITIALIZING")
    partialImage = nil
    streamedImages = []
    lastResult = nil

    if availableStyles.isEmpty {
      isRunning = false
      error = Localization.string("IMAGE_STYLES_UNAVAILABLE")
      return
    }

    guard let style = selectedStyle else {
      isRunning = false
      error = Localization.string("IMAGE_STYLES_UNAVAILABLE")
      return
    }

    let request = GenerationRequest(
      concepts: textConcepts,
      themeInput: themeInput,
      style: style,
      limit: requestedImageLimit,
      referenceImage: referenceImage,
      sketch: sketch,
      extractionSourceText: extractionSourceText,
      extractionTitle: extractionTitle,
      useExtraction: useExtraction
    )

    currentTask = Task {
      let startTime = Date()

      timerTask = Task {
        while !Task.isCancelled {
          try? await Task.sleep(for: .milliseconds(100))
          await MainActor.run {
            self.elapsedTime = Date().timeIntervalSince(startTime)
          }
        }
      }

      do {
        let stream = service.generateImages(request: request)

        var lastCG: CGImage?
        for try await (cgImage, count) in stream {
          let img = Image(decorative: cgImage, scale: 1.0, orientation: .up)
          self.partialImage = img
          self.streamedImages.append(img)
          lastCG = cgImage
          self.progress = String(
            format: Localization.string("PROGRESS_RECEIVING_IMAGE"), "\(count)")
        }

        let duration = Date().timeIntervalSince(startTime)

        timerTask?.cancel()
        self.elapsedTime = duration

        self.lastResult = ImageGenResult(
          prompt: request.concepts.joined(separator: ", "),
          styleName: style.displayName,
          totalGenerationTime: duration,
          generatedCGImage: lastCG
        )

        let formattedDuration = String(
          format: "%.2f %@", duration, "s")
        self.progress = String(format: Localization.string("PROGRESS_COMPLETE"), formattedDuration)
      } catch {
        timerTask?.cancel()
        self.error = error.localizedDescription
        self.progress = Localization.string("PROGRESS_FAILED")
      }
      self.isRunning = false
    }
  }

  public func loadAvailableStyles() async {
    guard !isLoadingStyles else {
      return
    }
    isLoadingStyles = true
    defer { isLoadingStyles = false }
    do {
      let styles = try await service.availableStyles()
      await MainActor.run {
        self.availableStyles = styles
        let selected = self.selectedStyle
        if let selected {
          let stillExists = styles.contains {
            String(describing: $0) == String(describing: selected)
          }
          if !stillExists {
            self.selectedStyle = styles.first
          }
        } else {
          self.selectedStyle = styles.first
        }
      }
    } catch {
      await MainActor.run {
        self.availableStyles = []
        self.selectedStyle = nil
        self.error = error.localizedDescription
      }
    }
  }
}
