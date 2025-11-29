import Core
import CoreGraphics
import Foundation
import FoundationModels
import PencilKit

#if canImport(ImagePlayground)
  import ImagePlayground
#endif

@Generable
@available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
struct ConceptResponse {
  @Guide(description: "3 distinct visual elements (1-3 words max per item, NO sentences).")
  var visualConcepts: [String]

  @Guide(description: "5 single-word style or mood keywords.")
  var relatedKeywords: [String]
}

@Generable
@available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
struct SeedResponse {
  @Guide(description: "Generate a creative concept, 1-3 words max.")
  var seed: String
}

@available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
public final class ImageGenService: ImageGenServiceProtocol {
  public init() {}

  public func generateRandomSeed() -> AsyncThrowingStream<String, Error> {
    AsyncThrowingStream { continuation in
      Task {
        do {
          let model = SystemLanguageModel.default
          guard model.isAvailable else {
            throw NSError(
              domain: "ImageGen",
              code: 1,
              userInfo: [NSLocalizedDescriptionKey: Localization.string("MODEL_NOT_AVAILABLE")]
            )
          }

          let session = LanguageModelSession(model: model)
          let stream = session.streamResponse(
            to: "Generate a creative concept, 1-3 words max.",
            generating: SeedResponse.self
          )

          for try await snapshot in stream {
            if let seed = snapshot.content.seed {
              continuation.yield(seed)
            }
          }
          continuation.finish()
        } catch {
          continuation.finish(throwing: error)
        }
      }
    }
  }

  public func generateConcepts(for theme: String) -> AsyncThrowingStream<
    ([String], [String]), Error
  > {
    AsyncThrowingStream { continuation in
      Task {
        do {
          let model = SystemLanguageModel.default
          guard model.isAvailable else {
            throw NSError(
              domain: "ImageGen",
              code: 1,
              userInfo: [NSLocalizedDescriptionKey: Localization.string("MODEL_NOT_AVAILABLE")]
            )
          }

          let session = LanguageModelSession(model: model)
          let stream = session.streamResponse(
            to: "Generate concepts for the theme: \(theme)",
            generating: ConceptResponse.self
          )

          for try await snapshot in stream {
            let partial = snapshot.content
            let v = partial.visualConcepts ?? []
            let r = partial.relatedKeywords ?? []
            continuation.yield((v, r))
          }
          continuation.finish()
        } catch {
          continuation.finish(throwing: error)
        }
      }
    }
  }

  public func generateImages(request: GenerationRequest) -> AsyncThrowingStream<
    (CGImage, Int), Error
  > {
    AsyncThrowingStream { continuation in
      Task {
        do {
          #if canImport(ImagePlayground)
            let creator = try await ImageCreator()
            let available = creator.availableStyles
            guard !available.isEmpty else {
              throw NSError(
                domain: "System26",
                code: 5,
                userInfo: [NSLocalizedDescriptionKey: Localization.string("IMAGE_STYLES_UNAVAILABLE")]
              )
            }

            let style =
              available.first {
                String(describing: $0) == String(describing: request.style)
              } ?? available.first

            guard let resolvedStyle = style else {
              throw NSError(
                domain: "System26",
                code: 5,
                userInfo: [NSLocalizedDescriptionKey: Localization.string("IMAGE_STYLES_UNAVAILABLE")]
              )
            }
            var concepts: [ImagePlaygroundConcept] = []

            for text in request.concepts {
              concepts.append(.text(text))
            }

            if let cgImage = request.referenceImage {
              let normalized = try normalizeReferenceImage(cgImage)
              concepts.append(.image(normalized))
            }

            if let drawing = request.sketch {
              concepts.append(.drawing(drawing))
            }

            if request.useExtraction && !request.extractionSourceText.isEmpty {
              let title = request.extractionTitle.isEmpty ? nil : request.extractionTitle
              concepts.append(.extracted(from: request.extractionSourceText, title: title))
            }

            if concepts.isEmpty {
              guard !request.themeInput.isEmpty else {
                throw NSError(
                  domain: "System26",
                  code: 4,
                  userInfo: [NSLocalizedDescriptionKey: Localization.string("NO_INPUTS_ERROR")]
                )
              }
              concepts.append(.text(request.themeInput))
            }

            func runGeneration(activeConcepts: [ImagePlaygroundConcept]) async throws {
              let stream = creator.images(
                for: activeConcepts,
                style: resolvedStyle,
                limit: request.limit
              )
              var count = 0
              for try await created in stream {
                count += 1
                continuation.yield((created.cgImage, count))
              }
            }

            do {
              try await runGeneration(activeConcepts: concepts)
            } catch {
              guard error.localizedDescription.contains("conceptsRequirePersonIdentity") else {
                throw error
              }

              let fallback = [
                ImagePlaygroundConcept.text(
                  request.themeInput.isEmpty
                    ? Localization.string("DEFAULT_ARTISTIC_THEME") : request.themeInput)
              ]
              try await runGeneration(activeConcepts: fallback)
            }

            continuation.finish()
          #else
            throw NSError(
              domain: "System26",
              code: 2,
              userInfo: [NSLocalizedDescriptionKey: Localization.string("IMAGEPLAYGROUND_MISSING")]
            )
          #endif
        } catch {
          continuation.finish(throwing: error)
        }
      }
    }
  }

  #if canImport(ImagePlayground)
    @available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
    public func availableStyles() async throws -> [ImagePlaygroundStyle] {
      let creator = try await ImageCreator()
      let styles = creator.availableStyles
      guard !styles.isEmpty else {
        throw NSError(
          domain: "System26",
          code: 5,
          userInfo: [NSLocalizedDescriptionKey: Localization.string("IMAGE_STYLES_UNAVAILABLE")]
        )
      }
      return styles
    }
  #else
    public func availableStyles() async throws -> [ImagePlaygroundStyle] {
      throw NSError(
        domain: "System26",
        code: 2,
        userInfo: [NSLocalizedDescriptionKey: Localization.string("IMAGEPLAYGROUND_MISSING")]
      )
    }
  #endif

  private func normalizeReferenceImage(_ image: CGImage) throws -> CGImage {
    let width = image.width
    let height = image.height
    let minSide = min(width, height)

    guard minSide > 0 else {
      throw NSError(
        domain: "System26",
        code: 6,
        userInfo: [NSLocalizedDescriptionKey: Localization.string("REFERENCE_IMAGE_INVALID")]
      )
    }

    let cropSize = minSide
    let originX = (width - cropSize) / 2
    let originY = (height - cropSize) / 2
    guard let cropped = image.cropping(to: CGRect(x: originX, y: originY, width: cropSize, height: cropSize)) else {
      throw NSError(
        domain: "System26",
        code: 7,
        userInfo: [NSLocalizedDescriptionKey: Localization.string("REFERENCE_IMAGE_CROP_FAILED")]
      )
    }

    let targetSide = min(cropSize, 2048)
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    guard
      let context = CGContext(
        data: nil,
        width: targetSide,
        height: targetSide,
        bitsPerComponent: 8,
        bytesPerRow: targetSide * 4,
        space: colorSpace,
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
      )
    else {
      throw NSError(
        domain: "System26",
        code: 8,
        userInfo: [NSLocalizedDescriptionKey: Localization.string("REFERENCE_IMAGE_RESIZE_FAILED")]
      )
    }

    context.interpolationQuality = .high
    context.draw(cropped, in: CGRect(x: 0, y: 0, width: targetSide, height: targetSide))

    guard let scaled = context.makeImage() else {
      throw NSError(
        domain: "System26",
        code: 8,
        userInfo: [NSLocalizedDescriptionKey: Localization.string("REFERENCE_IMAGE_RESIZE_FAILED")]
      )
    }

    if scaled.width > 4096 || scaled.height > 4096 {
      throw NSError(
        domain: "System26",
        code: 9,
        userInfo: [NSLocalizedDescriptionKey: Localization.string("REFERENCE_IMAGE_TOO_LARGE")]
      )
    }

    return scaled
  }
}
