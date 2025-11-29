import CoreGraphics
import Foundation

public struct ImageGenResult: Identifiable, @unchecked Sendable {
  public let id = UUID()
  public let prompt: String
  public let styleName: String
  public let totalGenerationTime: TimeInterval
  public let generatedCGImage: CGImage?
  public let timestamp = Date()

  public init(
    prompt: String, styleName: String, totalGenerationTime: TimeInterval, generatedCGImage: CGImage?
  ) {
    self.prompt = prompt
    self.styleName = styleName
    self.totalGenerationTime = totalGenerationTime
    self.generatedCGImage = generatedCGImage
  }
}
