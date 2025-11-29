import AVFoundation
import Core
import CoreMedia
import Foundation

public final class CameraService: NSObject, CameraFrameProvider,
  AVCaptureVideoDataOutputSampleBufferDelegate, @unchecked Sendable {
  public static let shared = CameraService()

  public let session = AVCaptureSession()
  private let videoOutput = AVCaptureVideoDataOutput()
  private var continuation: AsyncStream<SendableSampleBuffer>.Continuation?
  private let sessionQueue = DispatchQueue(label: "com.system26.camera.session")
  private let frameQueue = DispatchQueue(label: "com.system26.camera.frames", qos: .userInteractive)

  private override init() {
    super.init()
  }

  public func frameStream() -> AsyncStream<SendableSampleBuffer> {
    AsyncStream(bufferingPolicy: .bufferingNewest(1)) { continuation in
      self.continuation = continuation
      continuation.onTermination = { @Sendable [weak self] _ in
        self?.stopSession()
      }
    }
  }

  public func configure(position: AVCaptureDevice.Position, frameRate: Int) async throws {
    #if os(visionOS)
      throw NSError(
        domain: "CameraService",
        code: -1,
        userInfo: [NSLocalizedDescriptionKey: Localization.string("LIVE_CAMERA_UNAVAILABLE")])
    #else
      try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
        sessionQueue.async {
          do {
            self.session.beginConfiguration()

            guard
              let device = AVCaptureDevice.default(
                .builtInWideAngleCamera, for: .video, position: position)
            else {
              throw NSError(
                domain: "CameraService",
                code: 404,
                userInfo: [NSLocalizedDescriptionKey: Localization.string("CAMERA_NOT_FOUND")]
              )
            }

            let input = try AVCaptureDeviceInput(device: device)

            self.session.inputs.forEach { self.session.removeInput($0) }

            if self.session.canAddInput(input) {
              self.session.addInput(input)
            }

            self.videoOutput.setSampleBufferDelegate(self, queue: self.frameQueue)
            self.videoOutput.videoSettings = [
              kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
            ]
            self.videoOutput.alwaysDiscardsLateVideoFrames = true

            self.session.outputs.forEach { self.session.removeOutput($0) }

            if self.session.canAddOutput(self.videoOutput) {
              self.session.addOutput(self.videoOutput)
            }

            try device.lockForConfiguration()
            let targetDuration = CMTime(value: 1, timescale: CMTimeScale(frameRate))
            device.activeVideoMinFrameDuration = targetDuration
            device.activeVideoMaxFrameDuration = targetDuration
            device.unlockForConfiguration()

            self.session.commitConfiguration()
            continuation.resume()
          } catch {
            self.session.commitConfiguration()
            continuation.resume(throwing: error)
          }
        }
      }
    #endif
  }

  public func start() async throws {
    guard !session.isRunning else {
      return
    }
    sessionQueue.async {
      self.session.startRunning()
    }
  }

  public func stop() async {
    stopSession()
  }

  private func stopSession() {
    sessionQueue.async {
      if self.session.isRunning {
        self.session.stopRunning()
      }
    }
  }

  // MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

  @objc
  public func captureOutput(
    _ output: AVCaptureOutput,
    didOutput sampleBuffer: CMSampleBuffer,
    from connection: AVCaptureConnection
  ) {
    continuation?.yield(SendableSampleBuffer(sampleBuffer))
  }

  @objc
  public func captureOutput(
    _ output: AVCaptureOutput,
    didDrop sampleBuffer: CMSampleBuffer,
    from connection: AVCaptureConnection
  ) {
  }
}
