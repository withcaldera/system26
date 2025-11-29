import CoreGraphics
import Foundation

public struct LiveAnalysisResult: Sendable {
  public let id: UUID
  public let timestamp: TimeInterval
  public let fps: Double
  public let latency: TimeInterval
  public let thermalScore: Double
  public let overlays: [OverlayElement]
  public let droppedFrameCount: Int
  public let frameSize: CGSize
  public let currentFrame: CGImage?

  public init(
    timestamp: TimeInterval,
    fps: Double,
    latency: TimeInterval,
    thermalScore: Double,
    overlays: [OverlayElement],
    droppedFrameCount: Int,
    frameSize: CGSize = .zero,
    currentFrame: CGImage? = nil,
    id: UUID = UUID()
  ) {
    self.id = id
    self.timestamp = timestamp
    self.fps = fps
    self.latency = latency
    self.thermalScore = thermalScore
    self.overlays = overlays
    self.droppedFrameCount = droppedFrameCount
    self.frameSize = frameSize
    self.currentFrame = currentFrame
  }
}
