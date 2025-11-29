#if DEBUG
  import CoreGraphics
  import Foundation
  import SwiftUI

  @available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
  final class MockVisionBenchmarkRunner: VisionBenchmarkRunner {
    func run(configuration: BenchmarkConfiguration) -> AsyncThrowingStream<BenchmarkResult, Error> {
      AsyncThrowingStream { continuation in
        let result = BenchmarkResult(
          deviceModel: "MacBook Pro",
          socIdentifier: "M4 Max",
          configuration: configuration,
          totalDuration: 12.3,
          totalFrames: 480,
          sustainedFPS: 38.9,
          averagePipelineLatency: 0.022,
          perTaskLatency: [.objectDetection: 0.021, .faceDetection: 0.018],
          thermalDegradationScore: 14
        )
        continuation.yield(result)
        continuation.finish()
      }
    }

    func runLive(configuration: BenchmarkConfiguration) -> AsyncThrowingStream<LiveAnalysisResult, Error> {
      AsyncThrowingStream { continuation in
        let overlays: [OverlayElement] = [
          .boundingBox(
            id: UUID(),
            rect: CGRect(x: 0.2, y: 0.3, width: 0.35, height: 0.4),
            label: "Person",
            color: .green
          ),
          .textBubble(
            id: UUID(),
            rect: CGRect(x: 0.55, y: 0.1, width: 0.25, height: 0.12),
            text: "FPS 28"
          )
        ]

        let result = LiveAnalysisResult(
          timestamp: Date().timeIntervalSince1970,
          fps: 26.4,
          latency: 0.035,
          thermalScore: 42,
          overlays: overlays,
          droppedFrameCount: 1,
          frameSize: CGSize(width: 1920, height: 1080),
          currentFrame: Self.makeFrame()
        )
        continuation.yield(result)
        continuation.finish()
      }
    }

    func updateLiveConfiguration(_ configuration: BenchmarkConfiguration) {}

    static func makeFrame() -> CGImage? {
      let colorSpace = CGColorSpaceCreateDeviceRGB()
      let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
      guard
        let context = CGContext(
          data: nil,
          width: 640,
          height: 360,
          bitsPerComponent: 8,
          bytesPerRow: 0,
          space: colorSpace,
          bitmapInfo: bitmapInfo
        )
      else { return nil }

      let gradientColors = [
        CGColor(red: 0.1, green: 0.1, blue: 0.2, alpha: 1),
        CGColor(red: 0.2, green: 0.45, blue: 0.7, alpha: 1)
      ]

      let locations: [CGFloat] = [0.0, 1.0]
      guard
        let gradient = CGGradient(
          colorsSpace: colorSpace,
          colors: gradientColors as CFArray,
          locations: locations
        )
      else {
        return nil
      }
      let rect = CGRect(origin: .zero, size: CGSize(width: 640, height: 360))

      context.drawLinearGradient(
        gradient,
        start: CGPoint.zero,
        end: CGPoint(x: rect.maxX, y: rect.maxY),
        options: []
      )

      return context.makeImage()
    }
  }

  @available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
  extension VisualIntelligenceBenchmarkViewModel {
    public static func previewSynthetic() -> VisualIntelligenceBenchmarkViewModel {
      let useCase = RunVisionPipelineBenchmarkUseCase(runner: MockVisionBenchmarkRunner())
      let vm = VisualIntelligenceBenchmarkViewModel(useCase: useCase)
      vm.configuration = BenchmarkConfiguration(
        selectedTasks: [.faceDetection, .objectDetection],
        iterationCount: 900,
        forceCPU: false,
        stressMultiplier: 2,
        mode: .synthetic,
        useFrontCamera: false,
        targetFrameRate: 30,
        enableMirageEffect: true,
        adaptiveThrottling: true,
        minimumConfidence: 0.4
      )
      vm.currentResult = BenchmarkResult(
        deviceModel: "MacBook Pro",
        socIdentifier: "M4 Max",
        configuration: vm.configuration,
        totalDuration: 12.3,
        totalFrames: 480,
        sustainedFPS: 38.9,
        averagePipelineLatency: 0.022,
        perTaskLatency: [.objectDetection: 0.021, .faceDetection: 0.018],
        thermalDegradationScore: 14
      )
      vm.progress = 0.65
      vm.isRunning = false
      return vm
    }

    public static func previewLive() -> VisualIntelligenceBenchmarkViewModel {
      let useCase = RunVisionPipelineBenchmarkUseCase(runner: MockVisionBenchmarkRunner())
      let vm = VisualIntelligenceBenchmarkViewModel(useCase: useCase)
      vm.configuration = BenchmarkConfiguration(
        selectedTasks: [.bodyPose, .objectDetection],
        iterationCount: 600,
        forceCPU: false,
        stressMultiplier: 1,
        mode: .liveCamera,
        useFrontCamera: false,
        targetFrameRate: 30,
        enableMirageEffect: true,
        adaptiveThrottling: true,
        minimumConfidence: 0.5
      )
      vm.liveState = .streaming
      vm.currentFPS = 26.4
      vm.thermalScore = 42
      vm.liveOverlays = [
        .boundingBox(
          id: UUID(),
          rect: CGRect(x: 0.25, y: 0.25, width: 0.35, height: 0.4),
          label: "Person",
          color: .green
        ),
        .textBubble(
          id: UUID(),
          rect: CGRect(x: 0.62, y: 0.12, width: 0.2, height: 0.1),
          text: "26 FPS"
        ),
        .skeleton(
          id: UUID(),
          joints: [
            CGPoint(x: 0.3, y: 0.2),
            CGPoint(x: 0.35, y: 0.35),
            CGPoint(x: 0.4, y: 0.5)
          ],
          connections: [[CGPoint(x: 0.3, y: 0.2), CGPoint(x: 0.35, y: 0.35)]]
        )
      ]
      vm.currentFrameSize = CGSize(width: 1920, height: 1080)
      vm.lastLiveFrame = MockVisionBenchmarkRunner.makeFrame()
      vm.sessionStartTime = Date().addingTimeInterval(-12)
      vm.isRunning = false
      return vm
    }
  }
#endif
