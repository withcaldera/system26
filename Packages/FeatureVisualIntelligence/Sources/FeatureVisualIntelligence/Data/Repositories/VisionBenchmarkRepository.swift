import AVFoundation
import Core
import CoreImage
import CoreMedia
import Foundation
import ImageIO
@preconcurrency import Vision
import os.lock

#if canImport(UIKit)
  import UIKit
#elseif canImport(AppKit)
  import AppKit
#endif

public final class VisionBenchmarkRepository: VisionBenchmarkRunner {
  private let cameraService = CameraService.shared
  private let liveRenderer = LiveOverlayRenderer()
  private let configState = OSAllocatedUnfairLock<BenchmarkConfiguration?>(initialState: nil)

  public init() {}

  public func updateLiveConfiguration(_ configuration: BenchmarkConfiguration) {
    configState.withLock { $0 = configuration }
  }

  // MARK: - Synthetic Benchmark

  public func run(configuration: BenchmarkConfiguration) -> AsyncThrowingStream<
    BenchmarkResult, Error
  > {
    AsyncThrowingStream { continuation in
      let task = Task.detached(priority: .userInitiated) {
        do {
          try await self.performBenchmark(configuration: configuration, continuation: continuation)
        } catch {
          continuation.finish(throwing: error)
        }
      }

      continuation.onTermination = { @Sendable _ in
        task.cancel()
      }
    }
  }

  // MARK: - Live Camera Benchmark

  public func runLive(configuration: BenchmarkConfiguration) -> AsyncThrowingStream<
    LiveAnalysisResult, Error
  > {
    AsyncThrowingStream { continuation in
      let task = Task.detached(priority: .userInitiated) {
        do {
          try await self.performLiveBenchmark(
            configuration: configuration, continuation: continuation)
        } catch {
          continuation.finish(throwing: error)
        }
      }

      continuation.onTermination = { @Sendable [weak self] _ in
        task.cancel()
        Task { await self?.cameraService.stop() }
      }
    }
  }

  private func performLiveBenchmark(
    configuration: BenchmarkConfiguration,
    continuation: AsyncThrowingStream<LiveAnalysisResult, Error>.Continuation
  ) async throws {
    configState.withLock { $0 = configuration }

    let position: AVCaptureDevice.Position = configuration.useFrontCamera ? .front : .back

    try await cameraService.configure(position: position, frameRate: configuration.targetFrameRate)
    try await cameraService.start()

    let frameStream = cameraService.frameStream()

    var latencyHistory: [TimeInterval] = []
    let latencyWindowSize = 30
    var coldBaselineLatency: TimeInterval?
    var droppedFrames = 0
    let ciContext = CIContext()

    let orientation: CGImagePropertyOrientation
    #if os(iOS)
      orientation = configuration.useFrontCamera ? .leftMirrored : .right
    #else
      orientation = .up
    #endif

    var currentConfig = configuration
    var requests = try createRequests(
      for: currentConfig.selectedTasks, forceCPU: currentConfig.forceCPU)

    for await wrappedSampleBuffer in frameStream {
      try Task.checkCancellation()

      let latestConfig = configState.withLock { $0 }

      if let newConfig = latestConfig, newConfig != currentConfig {
        if newConfig.selectedTasks != currentConfig.selectedTasks
          || newConfig.forceCPU != currentConfig.forceCPU {
          requests = try createRequests(for: newConfig.selectedTasks, forceCPU: newConfig.forceCPU)
        }
        currentConfig = newConfig
      }

      let start = CFAbsoluteTimeGetCurrent()
      let sampleBuffer = wrappedSampleBuffer.sampleBuffer

      guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { continue }

      if requests.isEmpty {
        let result = LiveAnalysisResult(
          timestamp: Date().timeIntervalSince1970,
          fps: 0,
          latency: 0,
          thermalScore: 0,
          overlays: [],
          droppedFrameCount: droppedFrames,
          frameSize: .zero,
          currentFrame: nil
        )
        continuation.yield(result)
        continue
      }

      let handler = VNImageRequestHandler(
        cvPixelBuffer: pixelBuffer, orientation: orientation, options: [:])

      do {
        if currentConfig.forceCPU {
          try handler.perform(requests)
        } else {
          try handler.perform(requests)
        }

        let end = CFAbsoluteTimeGetCurrent()
        let duration = end - start

        latencyHistory.append(duration)
        if latencyHistory.count > latencyWindowSize {
          latencyHistory.removeFirst()
        }

        let avgLatency = latencyHistory.reduce(0, +) / Double(latencyHistory.count)
        let fps = 1.0 / avgLatency

        if coldBaselineLatency == nil && latencyHistory.count >= 5 {
          coldBaselineLatency = avgLatency
        }
        let baseline = coldBaselineLatency ?? avgLatency
        let degradation = (avgLatency - baseline) / baseline
        let thermalScore = min(100.0, max(0.0, degradation * 400.0))

        let observations: [VNObservation] = requests.flatMap { request in
          (request.results ?? []).compactMap { $0 as? VNObservation }
        }

        let overlays = liveRenderer.map(
          observations, minimumConfidence: currentConfig.minimumConfidence)

        let width = CGFloat(CVPixelBufferGetWidth(pixelBuffer))
        let height = CGFloat(CVPixelBufferGetHeight(pixelBuffer))
        let effectiveSize: CGSize

        switch orientation {
        case .left, .right, .leftMirrored, .rightMirrored:
          effectiveSize = CGSize(width: height, height: width)

        default:
          effectiveSize = CGSize(width: width, height: height)
        }

        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let currentFrame = ciContext.createCGImage(ciImage, from: ciImage.extent)

        let result = LiveAnalysisResult(
          timestamp: Date().timeIntervalSince1970,
          fps: fps,
          latency: duration,
          thermalScore: thermalScore,
          overlays: overlays,
          droppedFrameCount: droppedFrames,
          frameSize: effectiveSize,
          currentFrame: currentFrame
        )

        continuation.yield(result)
      } catch {
        print("Vision Error: \(error)")
        droppedFrames += 1
      }
    }

    continuation.finish()
  }

  private func performBenchmark(
    configuration: BenchmarkConfiguration,
    continuation: AsyncThrowingStream<BenchmarkResult, Error>.Continuation
  ) async throws {
    let imageNames = (1...20).map { String(format: "VisionBenchmark_%03d", $0) }
    let cgImages: [CGImage] = try imageNames.compactMap { name in
      try loadCGImage(named: name)
    }

    guard !cgImages.isEmpty else {
      throw NSError(
        domain: "VisionBenchmarkRepository",
        code: 404,
        userInfo: [NSLocalizedDescriptionKey: Localization.string("BENCHMARK_IMAGES_MISSING")]
      )
    }

    var totalPipelineLatency: TimeInterval = 0
    var totalFramesProcessed: Int = 0
    let perTaskLatencies: [VisionTaskType: TimeInterval] = [:]

    var latencyHistory: [TimeInterval] = []
    let latencyWindowSize = 30
    var coldBaselineLatency: TimeInterval?

    let startTime = Date()
    let warmupIterations = 10
    let serialQueue = DispatchQueue(label: "com.system26.vision.serial", qos: .userInitiated)

    for i in 0..<(configuration.iterationCount + warmupIterations) {
      try Task.checkCancellation()

      let isWarmup = i < warmupIterations
      let imageIndex = i % cgImages.count
      let currentImage = cgImages[imageIndex]

      let requests = try createRequests(
        for: configuration.selectedTasks,
        forceCPU: configuration.forceCPU
      )
      let handler = VNImageRequestHandler(cgImage: currentImage, options: [:])

      let frameStartTime = CFAbsoluteTimeGetCurrent()

      for _ in 0..<configuration.stressMultiplier {
        if configuration.forceCPU {
          try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
            serialQueue.async {
              autoreleasepool {
                do {
                  try handler.perform(requests)
                  cont.resume()
                } catch {
                  cont.resume(throwing: error)
                }
              }
            }
          }
        } else {
          autoreleasepool {
            try? handler.perform(requests)
          }
        }
      }

      let frameDuration = CFAbsoluteTimeGetCurrent() - frameStartTime

      if isWarmup { continue }

      let framesInThisBatch = configuration.stressMultiplier
      totalFramesProcessed += framesInThisBatch
      totalPipelineLatency += frameDuration

      let perInferenceDuration = frameDuration / Double(framesInThisBatch)
      latencyHistory.append(perInferenceDuration)
      if latencyHistory.count > latencyWindowSize {
        latencyHistory.removeFirst()
      }

      let averageLatency = latencyHistory.reduce(0, +) / Double(latencyHistory.count)
      let instantaneousFPS = 1.0 / averageLatency

      if coldBaselineLatency == nil {
        coldBaselineLatency = averageLatency
      }

      let baseline = coldBaselineLatency ?? averageLatency
      let rawDegradation = (averageLatency - baseline) / baseline
      let amplifiedScore = max(0, rawDegradation) * 400.0
      let thermalScore = min(100.0, amplifiedScore)

      let result = BenchmarkResult(
        deviceModel: Self.getDeviceModel(),
        socIdentifier: Self.getSoCIdentifier(),
        configuration: configuration,
        totalDuration: Date().timeIntervalSince(startTime),
        totalFrames: totalFramesProcessed,
        sustainedFPS: instantaneousFPS,
        averagePipelineLatency: averageLatency,
        perTaskLatency: perTaskLatencies,
        thermalDegradationScore: thermalScore,
        id: UUID(),
        timestamp: Date()
      )

      continuation.yield(result)
    }

    continuation.finish()
  }

  private func createRequests(for tasks: Set<VisionTaskType>, forceCPU: Bool) throws -> [VNRequest] {
    var requests: [VNRequest] = []

    for task in tasks {
      let request: VNRequest
      switch task {
      case .textRecognition:
        let r = VNRecognizeTextRequest()
        r.recognitionLevel = .accurate
        request = r

      case .objectDetection:
        let r = VNDetectRectanglesRequest()
        request = r

      case .faceDetection:
        let r = VNDetectFaceRectanglesRequest()
        request = r

      case .featurePrint:
        let r = VNGenerateImageFeaturePrintRequest()
        request = r

      case .bodyPose:
        let r = VNDetectHumanBodyPoseRequest()
        request = r
      }

      if forceCPU {
        if request.responds(to: Selector(("usesCPUOnly"))) {
          request.setValue(true, forKey: "usesCPUOnly")
        }
        request.preferBackgroundProcessing = true
      }

      requests.append(request)
    }

    return requests
  }

  private func loadCGImage(named name: String) throws -> CGImage? {
    #if canImport(UIKit)
      guard let image = UIImage(named: name, in: .module, compatibleWith: nil) else {
        return nil
      }
      return image.cgImage
    #elseif canImport(AppKit)
      let bundle = Bundle.module
      guard let image = bundle.image(forResource: name) else {
        return nil
      }
      return image.cgImage(forProposedRect: nil, context: nil, hints: nil)
    #else
      return nil
    #endif
  }

  private static func getDeviceModel() -> String {
    var systemInfo = utsname()
    uname(&systemInfo)
    let machineMirror = Mirror(reflecting: systemInfo.machine)
    let identifier = machineMirror.children.reduce("") { identifier, element in
      guard let value = element.value as? Int8, value != 0 else {
        return identifier
      }
      return identifier + String(UnicodeScalar(UInt8(value)))
    }
    return identifier
  }

  private static func getSoCIdentifier() -> String {
    #if os(iOS)
      return "Apple Silicon"
    #elseif os(macOS)
      return "Apple Silicon"
    #elseif os(visionOS)
      return "Apple Silicon"
    #else
      return "Unknown"
    #endif
  }
}
