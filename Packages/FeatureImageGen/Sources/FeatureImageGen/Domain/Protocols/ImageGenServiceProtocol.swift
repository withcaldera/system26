import CoreGraphics
import Foundation
import PencilKit

#if canImport(ImagePlayground)
  import ImagePlayground
#else
  public struct ImagePlaygroundStyle: Hashable, Sendable, Identifiable {
    public let id: String

    public init(id: String) { self.id = id }

    public static let illustration = ImagePlaygroundStyle(id: "illustration")
    public static let animation = ImagePlaygroundStyle(id: "animation")
    public static let sketch = ImagePlaygroundStyle(id: "sketch")
    public static let messagesBackground = ImagePlaygroundStyle(id: "messages-background")
  }
#endif

@available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
public struct GenerationRequest: @unchecked Sendable {
  public let concepts: [String]
  public let themeInput: String
  public let style: ImagePlaygroundStyle
  public let limit: Int
  public let referenceImage: CGImage?
  public let sketch: PKDrawing?
  public let extractionSourceText: String
  public let extractionTitle: String
  public let useExtraction: Bool

  public init(
    concepts: [String],
    themeInput: String,
    style: ImagePlaygroundStyle,
    limit: Int,
    referenceImage: CGImage? = nil,
    sketch: PKDrawing? = nil,
    extractionSourceText: String = "",
    extractionTitle: String = "",
    useExtraction: Bool = false
  ) {
    self.concepts = concepts
    self.themeInput = themeInput
    self.style = style
    self.limit = limit
    self.referenceImage = referenceImage
    self.sketch = sketch
    self.extractionSourceText = extractionSourceText
    self.extractionTitle = extractionTitle
    self.useExtraction = useExtraction
  }
}

@available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
public protocol ImageGenServiceProtocol: Sendable {
  func generateImages(request: GenerationRequest) -> AsyncThrowingStream<(CGImage, Int), Error>
  func generateConcepts(for theme: String) -> AsyncThrowingStream<([String], [String]), Error>
  func generateRandomSeed() -> AsyncThrowingStream<String, Error>
  func availableStyles() async throws -> [ImagePlaygroundStyle]
}
