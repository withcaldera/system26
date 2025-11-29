import AVFoundation
import CoreMedia
import Foundation

public struct SendableSampleBuffer: @unchecked Sendable {
  public let sampleBuffer: CMSampleBuffer

  public init(_ sampleBuffer: CMSampleBuffer) {
    self.sampleBuffer = sampleBuffer
  }
}

public protocol CameraFrameProvider: Sendable {
  func frameStream() -> AsyncStream<SendableSampleBuffer>
  func start() async throws
  func stop() async
  func configure(position: AVCaptureDevice.Position, frameRate: Int) async throws
}
